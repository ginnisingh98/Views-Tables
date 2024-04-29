--------------------------------------------------------
--  DDL for Package Body OKC_K_ARTICLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ARTICLES_PVT" AS
/* $Header: OKCVCATB.pls 120.1.12010000.4 2011/12/09 13:44:26 serukull ship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_UNABLE_TO_RESERVE_REC      CONSTANT VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
  G_RECORD_CHANGED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_LOCK_RECORD_DELETED        CONSTANT VARCHAR2(200) := OKC_API.G_LOCK_RECORD_DELETED;
  ---------------------------------------------------------------------------
  -- VALIDATION LEVELS
  ---------------------------------------------------------------------------
  G_REQUIRED_VALUE_VALID_LVL   CONSTANT NUMBER := 0; --OKC_API.G_REQUIRED_VALUE_VALID_LVL;
  G_VALID_VALUE_VALID_LVL      CONSTANT NUMBER := 0; --OKC_API.G_VALID_VALUE_VALID_LVL;
  G_LOOKUP_CODE_VALID_LVL      CONSTANT NUMBER := 0; --OKC_API.G_LOOKUP_CODE_VALID_LVL;
  G_FOREIGN_KEY_VALID_LVL      CONSTANT NUMBER := 0; --OKC_API.G_FOREIGN_KEY_VALID_LVL;
  G_RECORD_VALID_LVL           CONSTANT NUMBER := 0; --OKC_API.G_RECORD_VALID_LVL;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_K_ARTICLES_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_AMEND_CODE_DELETED         CONSTANT   VARCHAR2(30) := 'DELETED';
  G_AMEND_CODE_ADDED           CONSTANT   VARCHAR2(30) := 'ADDED';
  G_AMEND_CODE_UPDATED         CONSTANT   VARCHAR2(30) := 'UPDATED';
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION Get_Seq_Id (
    p_id                         IN NUMBER,
    x_id                         OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR c_seq IS
     SELECT OKC_K_ARTICLES_B_S.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF( p_id                         IS NULL ) THEN
      OPEN c_seq;
      FETCH c_seq INTO x_id                        ;
      IF c_seq%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c_seq;
    END IF;

    IF (l_debug = 'Y') THEN
     Okc_Debug.Log('200: Leaving get_seq_id', 2);
    END IF;
    RETURN G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('300: Leaving get_seq_id because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF c_seq%ISOPEN THEN
        CLOSE c_seq;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Seq_Id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ARTICLES_B
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_id                         IN NUMBER,
    p_major_version              IN NUMBER := NULL,
    x_sav_sae_id                 OUT NOCOPY NUMBER,
    x_document_type              OUT NOCOPY VARCHAR2,
    x_document_id                OUT NOCOPY NUMBER,
    x_cle_id                     OUT NOCOPY NUMBER,
    x_source_flag                OUT NOCOPY VARCHAR2,
    x_mandatory_yn               OUT NOCOPY VARCHAR2,
    x_scn_id                     OUT NOCOPY NUMBER,
    x_label                      OUT NOCOPY VARCHAR2,
    x_amendment_description      OUT NOCOPY VARCHAR2,
    x_amendment_operation_code   OUT NOCOPY VARCHAR2,
    x_article_version_id         OUT NOCOPY NUMBER,
    x_change_nonstd_yn           OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY NUMBER,
    x_orig_system_reference_id2  OUT NOCOPY NUMBER,
    x_display_sequence           OUT NOCOPY NUMBER,
    x_attribute_category         OUT NOCOPY VARCHAR2,
    x_attribute1                 OUT NOCOPY VARCHAR2,
    x_attribute2                 OUT NOCOPY VARCHAR2,
    x_attribute3                 OUT NOCOPY VARCHAR2,
    x_attribute4                 OUT NOCOPY VARCHAR2,
    x_attribute5                 OUT NOCOPY VARCHAR2,
    x_attribute6                 OUT NOCOPY VARCHAR2,
    x_attribute7                 OUT NOCOPY VARCHAR2,
    x_attribute8                 OUT NOCOPY VARCHAR2,
    x_attribute9                 OUT NOCOPY VARCHAR2,
    x_attribute10                OUT NOCOPY VARCHAR2,
    x_attribute11                OUT NOCOPY VARCHAR2,
    x_attribute12                OUT NOCOPY VARCHAR2,
    x_attribute13                OUT NOCOPY VARCHAR2,
    x_attribute14                OUT NOCOPY VARCHAR2,
    x_attribute15                OUT NOCOPY VARCHAR2,
    x_print_text_yn                OUT NOCOPY VARCHAR2,
    x_summary_amend_operation_code OUT NOCOPY VARCHAR2,
    x_ref_article_id               OUT NOCOPY NUMBER,
    x_ref_article_version_id       OUT NOCOPY NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER,
    x_created_by                 OUT NOCOPY NUMBER,
    x_creation_date              OUT NOCOPY DATE,
    x_last_updated_by            OUT NOCOPY NUMBER,
    x_last_update_login          OUT NOCOPY NUMBER,
    x_last_update_date           OUT NOCOPY DATE,
    x_last_amended_by            OUT NOCOPY NUMBER,
    x_last_amendment_date        OUT NOCOPY DATE,
   x_mandatory_rwa               OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR OKC_K_ARTICLES_B_pk_csr (cp_id IN NUMBER) IS
    SELECT
            SAV_SAE_ID,
            DOCUMENT_TYPE,
            DOCUMENT_ID,
            CLE_ID,
            SOURCE_FLAG,
            MANDATORY_YN,
            SCN_ID,
            LABEL,
            AMENDMENT_DESCRIPTION,
            AMENDMENT_OPERATION_CODE,
            ARTICLE_VERSION_ID,
            CHANGE_NONSTD_YN,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2,
            DISPLAY_SEQUENCE,
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
            PRINT_TEXT_YN,
            SUMMARY_AMEND_OPERATION_CODE,
            REF_ARTICLE_ID,
            REF_ARTICLE_VERSION_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            LAST_AMENDED_BY,
            LAST_AMENDMENT_DATE,
            MANDATORY_RWA
      FROM OKC_K_ARTICLES_B t
     WHERE t.ID = cp_id;
    CURSOR OKC_K_ARTICLES_BH_pk_csr (cp_id IN NUMBER, cp_major_version VARCHAR2) IS
    SELECT
            SAV_SAE_ID,
            DOCUMENT_TYPE,
            DOCUMENT_ID,
            CLE_ID,
            SOURCE_FLAG,
            MANDATORY_YN,
            SCN_ID,
            LABEL,
            AMENDMENT_DESCRIPTION,
            AMENDMENT_OPERATION_CODE,
            ARTICLE_VERSION_ID,
            CHANGE_NONSTD_YN,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2,
            DISPLAY_SEQUENCE,
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
            PRINT_TEXT_YN,
            SUMMARY_AMEND_OPERATION_CODE,
            REF_ARTICLE_ID,
            REF_ARTICLE_VERSION_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            LAST_AMENDED_BY,
            LAST_AMENDMENT_DATE,
            MANDATORY_RWA
      FROM OKC_K_ARTICLES_BH t
     WHERE t.ID = cp_id and major_version=cp_major_version;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    IF p_major_version IS NULL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('401: Get current database values', 2);
      END IF;

      -- Get current database values
      OPEN OKC_K_ARTICLES_B_pk_csr (p_id);
      FETCH OKC_K_ARTICLES_B_pk_csr INTO
            x_sav_sae_id,
            x_document_type,
            x_document_id,
            x_cle_id,
            x_source_flag,
            x_mandatory_yn,
            x_scn_id,
            x_label,
            x_amendment_description,
            x_amendment_operation_code,
            x_article_version_id,
            x_change_nonstd_yn,
            x_orig_system_reference_code,
            x_orig_system_reference_id1,
            x_orig_system_reference_id2,
            x_display_sequence,
            x_attribute_category,
            x_attribute1,
            x_attribute2,
            x_attribute3,
            x_attribute4,
            x_attribute5,
            x_attribute6,
            x_attribute7,
            x_attribute8,
            x_attribute9,
            x_attribute10,
            x_attribute11,
            x_attribute12,
            x_attribute13,
            x_attribute14,
            x_attribute15,
            x_print_text_yn,
            x_summary_amend_operation_code,
            x_ref_article_id,
            x_ref_article_version_id,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,
            x_last_amended_by,
            x_last_amendment_date,
            x_mandatory_rwa;
      IF OKC_K_ARTICLES_B_pk_csr%NOTFOUND THEN
        Okc_Api.Set_Message(G_APP_NAME,G_LOCK_RECORD_DELETED,
                   'ENTITYNAME','OKC_K_ARTICLES_B',
                   'PKEY',p_id,
                   'OVN',p_major_version
        );
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE OKC_K_ARTICLES_B_pk_csr;
     ELSE
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('402: Get history database values', 2);
      END IF;

      -- Get history database values
      OPEN OKC_K_ARTICLES_BH_pk_csr (p_id, p_major_version);
      FETCH OKC_K_ARTICLES_BH_pk_csr INTO
            x_sav_sae_id,
            x_document_type,
            x_document_id,
            x_cle_id,
            x_source_flag,
            x_mandatory_yn,
            x_scn_id,
            x_label,
            x_amendment_description,
            x_amendment_operation_code,
            x_article_version_id,
            x_change_nonstd_yn,
            x_orig_system_reference_code,
            x_orig_system_reference_id1,
            x_orig_system_reference_id2,
            x_display_sequence,
            x_attribute_category,
            x_attribute1,
            x_attribute2,
            x_attribute3,
            x_attribute4,
            x_attribute5,
            x_attribute6,
            x_attribute7,
            x_attribute8,
            x_attribute9,
            x_attribute10,
            x_attribute11,
            x_attribute12,
            x_attribute13,
            x_attribute14,
            x_attribute15,
            x_print_text_yn,
            x_summary_amend_operation_code,
            x_ref_article_id,
            x_ref_article_version_id,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,
            x_last_amended_by,
            x_last_amendment_date,
            x_mandatory_rwa;

      IF OKC_K_ARTICLES_BH_pk_csr%NOTFOUND THEN
        Okc_Api.Set_Message(G_APP_NAME,G_LOCK_RECORD_DELETED,
                   'ENTITYNAME','OKC_K_ARTICLES_BH',
                   'PKEY',p_id,
                   'OVN',p_major_version
        );
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE OKC_K_ARTICLES_BH_pk_csr;
    END IF;

    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('500: Leaving  get_rec ', 2);
    END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('600: Leaving get_rec because of NO_DATA_FOUND EXCEPTION.', 2);
      END IF;

-- moved upper where an exception is raised
--      Okc_Api.Set_Message(G_APP_NAME,G_LOCK_RECORD_DELETED,
--                   'ENTITYNAME','OKC_K_ARTICLES_BH',
--                   'PKEY',p_id,
--                   'OVN',p_major_version
--                    );

      IF OKC_K_ARTICLES_B_pk_csr%ISOPEN THEN
        CLOSE OKC_K_ARTICLES_B_pk_csr;
      END IF;

      IF OKC_K_ARTICLES_BH_pk_csr%ISOPEN THEN
        CLOSE OKC_K_ARTICLES_BH_pk_csr;
      END IF;

      RETURN G_RET_STS_ERROR ;

    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('600: Leaving get_rec because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF OKC_K_ARTICLES_B_pk_csr%ISOPEN THEN
        CLOSE OKC_K_ARTICLES_B_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_K_ARTICLES_B --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id               IN NUMBER,
    p_ref_article_version_id       IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE,

    x_sav_sae_id                 OUT NOCOPY NUMBER,
    x_document_type              OUT NOCOPY VARCHAR2,
    x_document_id                OUT NOCOPY NUMBER,
    x_cle_id                     OUT NOCOPY NUMBER,
    x_source_flag                OUT NOCOPY VARCHAR2,
    x_mandatory_yn               OUT NOCOPY VARCHAR2,
    x_scn_id                     OUT NOCOPY NUMBER,
    x_label                      OUT NOCOPY VARCHAR2,
    x_amendment_description      OUT NOCOPY VARCHAR2,
    x_object_version_number      OUT NOCOPY VARCHAR2,
    x_amendment_operation_code   OUT NOCOPY VARCHAR2,
    x_article_version_id         OUT NOCOPY NUMBER,
    x_change_nonstd_yn           OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY NUMBER,
    x_orig_system_reference_id2  OUT NOCOPY NUMBER,
    x_display_sequence           OUT NOCOPY NUMBER,
    x_attribute_category         OUT NOCOPY VARCHAR2,
    x_attribute1                 OUT NOCOPY VARCHAR2,
    x_attribute2                 OUT NOCOPY VARCHAR2,
    x_attribute3                 OUT NOCOPY VARCHAR2,
    x_attribute4                 OUT NOCOPY VARCHAR2,
    x_attribute5                 OUT NOCOPY VARCHAR2,
    x_attribute6                 OUT NOCOPY VARCHAR2,
    x_attribute7                 OUT NOCOPY VARCHAR2,
    x_attribute8                 OUT NOCOPY VARCHAR2,
    x_attribute9                 OUT NOCOPY VARCHAR2,
    x_attribute10                OUT NOCOPY VARCHAR2,
    x_attribute11                OUT NOCOPY VARCHAR2,
    x_attribute12                OUT NOCOPY VARCHAR2,
    x_attribute13                OUT NOCOPY VARCHAR2,
    x_attribute14                OUT NOCOPY VARCHAR2,
    x_attribute15                OUT NOCOPY VARCHAR2,
    x_print_text_yn                OUT NOCOPY VARCHAR2,
    x_summary_amend_operation_code OUT NOCOPY VARCHAR2,
    x_ref_article_id               OUT NOCOPY NUMBER,
    x_ref_article_version_id       OUT NOCOPY NUMBER,
    x_last_amended_by            OUT NOCOPY NUMBER,
    x_last_amendment_date        OUT NOCOPY DATE,
    x_mandatory_rwa               OUT NOCOPY VARCHAR2,
    p_mandatory_rwa               IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1);
    l_object_version_number      OKC_K_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_K_ARTICLES_B.CREATED_BY%TYPE;
    l_creation_date              OKC_K_ARTICLES_B.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_K_ARTICLES_B.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_K_ARTICLES_B.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_K_ARTICLES_B.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF( p_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_id                         => p_id,
        x_sav_sae_id                 => x_sav_sae_id,
        x_document_type              => x_document_type,
        x_document_id                => x_document_id,
        x_cle_id                     => x_cle_id,
        x_source_flag                => x_source_flag,
        x_mandatory_yn               => x_mandatory_yn,
        x_scn_id                     => x_scn_id,
        x_label                      => x_label,
        x_amendment_description      => x_amendment_description,
        x_amendment_operation_code   => x_amendment_operation_code,
        x_article_version_id         => x_article_version_id,
        x_change_nonstd_yn           => x_change_nonstd_yn,
        x_orig_system_reference_code => x_orig_system_reference_code,
        x_orig_system_reference_id1  => x_orig_system_reference_id1,
        x_orig_system_reference_id2  => x_orig_system_reference_id2,
        x_display_sequence           => x_display_sequence,
        x_attribute_category         => x_attribute_category,
        x_attribute1                 => x_attribute1,
        x_attribute2                 => x_attribute2,
        x_attribute3                 => x_attribute3,
        x_attribute4                 => x_attribute4,
        x_attribute5                 => x_attribute5,
        x_attribute6                 => x_attribute6,
        x_attribute7                 => x_attribute7,
        x_attribute8                 => x_attribute8,
        x_attribute9                 => x_attribute9,
        x_attribute10                => x_attribute10,
        x_attribute11                => x_attribute11,
        x_attribute12                => x_attribute12,
        x_attribute13                => x_attribute13,
        x_attribute14                => x_attribute14,
        x_attribute15                => x_attribute15,
        x_print_text_yn              => x_print_text_yn,
        x_summary_amend_operation_code => x_summary_amend_operation_code,
        x_ref_article_id               => x_ref_article_id,
        x_ref_article_version_id       => x_ref_article_version_id,
        x_object_version_number      => x_object_version_number,
        x_created_by                 => l_created_by,
        x_creation_date              => l_creation_date,
        x_last_updated_by            => l_last_updated_by,
        x_last_update_login          => l_last_update_login,
        x_last_update_date           => l_last_update_date,
        x_last_amended_by            => x_last_amended_by,
        x_last_amendment_date        => x_last_amendment_date,
       x_mandatory_rwa               => x_mandatory_rwa
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

    IF (p_mandatory_rwa = G_MISS_CHAR) THEN
        x_mandatory_rwa := NULL;
       ELSIF (p_MANDATORY_RWA IS NOT NULL) THEN
        x_mandatory_rwa := p_mandatory_rwa;
        x_mandatory_rwa := Upper( x_mandatory_rwa );
      END IF;
   IF (p_sav_sae_id = G_MISS_NUM) THEN
        x_sav_sae_id := NULL;
       ELSIF (p_SAV_SAE_ID IS NOT NULL) THEN
        x_sav_sae_id := p_sav_sae_id;
      END IF;

      IF (p_document_type = G_MISS_CHAR) THEN
        x_document_type := NULL;
       ELSIF (p_DOCUMENT_TYPE IS NOT NULL) THEN
        x_document_type := p_document_type;
      END IF;

      IF (p_document_id = G_MISS_NUM) THEN
        x_document_id := NULL;
       ELSIF (p_DOCUMENT_ID IS NOT NULL) THEN
        x_document_id := p_document_id;
      END IF;

      IF (p_cle_id = G_MISS_NUM) THEN
        x_cle_id := NULL;
       ELSIF (p_cle_id IS NOT NULL) THEN
        x_cle_id := p_cle_id;
      END IF;

      IF (p_source_flag = G_MISS_CHAR) THEN
        x_source_flag := NULL;
       ELSIF (p_SOURCE_FLAG IS NOT NULL) THEN
        x_source_flag := p_source_flag;
      END IF;

      IF (p_mandatory_yn = G_MISS_CHAR) THEN
        x_mandatory_yn := NULL;
       ELSIF (p_MANDATORY_YN IS NOT NULL) THEN
        x_mandatory_yn := p_mandatory_yn;
        x_mandatory_yn := Upper( x_mandatory_yn );
      END IF;

      IF (p_print_text_yn = G_MISS_CHAR) THEN
        x_print_text_yn := 'N';
       ELSIF (p_print_text_yn IS NOT NULL) THEN
        x_print_text_yn := p_print_text_yn;
        x_print_text_yn := Upper( x_print_text_yn );
      END IF;

      IF (p_summary_amend_operation_code = G_MISS_CHAR) THEN
        x_summary_amend_operation_code := NULL;
       ELSIF (p_summary_amend_operation_code IS NOT NULL) THEN
        x_summary_amend_operation_code := p_summary_amend_operation_code;
      END IF;

      IF (p_ref_article_id = G_MISS_NUM) THEN
        x_ref_article_id := NULL;
       ELSIF (p_ref_article_id IS NOT NULL) THEN
        x_ref_article_id := p_ref_article_id;
      END IF;

      IF (p_ref_article_version_id = G_MISS_NUM) THEN
        x_ref_article_version_id := NULL;
       ELSIF (p_ref_article_version_id IS NOT NULL) THEN
        x_ref_article_version_id := p_ref_article_version_id;
      END IF;

      IF (p_scn_id = G_MISS_NUM) THEN
        x_scn_id := NULL;
       ELSIF (p_SCN_ID IS NOT NULL) THEN
        x_scn_id := p_scn_id;
      END IF;

      IF (p_label = G_MISS_CHAR) THEN
        x_label := NULL;
       ELSIF (p_LABEL IS NOT NULL) THEN
        x_label := p_label;
      END IF;

      IF (p_amendment_description = G_MISS_CHAR) THEN
        x_amendment_description := NULL;
       ELSIF (p_AMENDMENT_DESCRIPTION IS NOT NULL) THEN
        x_amendment_description := p_amendment_description;
      END IF;

      IF (p_amendment_operation_code = G_MISS_CHAR) THEN
        x_amendment_operation_code := NULL;
       ELSIF (p_AMENDMENT_OPERATION_CODE IS NOT NULL) THEN
        x_amendment_operation_code := p_amendment_operation_code;
      END IF;

      IF p_amendment_operation_code IS NOT NULL
       AND p_amendment_operation_code <> G_MISS_CHAR
       AND x_amendment_operation_code IS NOT NULL
       THEN
        x_last_amendment_date := Sysdate;
        x_last_amended_by := Fnd_Global.User_Id;
      END IF;

      IF (p_last_amended_by = G_MISS_NUM) THEN
        x_last_amended_by := NULL;
      END IF;

      IF (p_last_amendment_date = G_MISS_DATE) THEN
        x_last_amendment_date := NULL;
      END IF;

      IF (p_article_version_id = G_MISS_NUM) THEN
        x_article_version_id := NULL;
       ELSIF (p_ARTICLE_VERSION_ID IS NOT NULL) THEN
        x_article_version_id := p_article_version_id;
      END IF;

      IF (p_change_nonstd_yn = G_MISS_CHAR) THEN
        x_change_nonstd_yn := 'N';
       ELSIF (p_CHANGE_NONSTD_YN IS NOT NULL) THEN
        x_change_nonstd_yn := p_change_nonstd_yn;
        x_change_nonstd_yn := Upper( x_change_nonstd_yn );
      END IF;

      IF (p_orig_system_reference_code = G_MISS_CHAR) THEN
        x_orig_system_reference_code := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_CODE IS NOT NULL) THEN
        x_orig_system_reference_code := p_orig_system_reference_code;
      END IF;

      IF (p_orig_system_reference_id1 = G_MISS_NUM) THEN
        x_orig_system_reference_id1 := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_ID1 IS NOT NULL) THEN
        x_orig_system_reference_id1 := p_orig_system_reference_id1;
      END IF;

      IF (p_orig_system_reference_id2 = G_MISS_NUM) THEN
        x_orig_system_reference_id2 := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_ID2 IS NOT NULL) THEN
        x_orig_system_reference_id2 := p_orig_system_reference_id2;
      END IF;

      IF (p_display_sequence = G_MISS_NUM) THEN
        x_display_sequence := NULL;
       ELSIF (p_DISPLAY_SEQUENCE IS NOT NULL) THEN
        x_display_sequence := p_display_sequence;
      END IF;

      IF (p_attribute_category = G_MISS_CHAR) THEN
        x_attribute_category := NULL;
       ELSIF (p_ATTRIBUTE_CATEGORY IS NOT NULL) THEN
        x_attribute_category := p_attribute_category;
      END IF;

      IF (p_attribute1 = G_MISS_CHAR) THEN
        x_attribute1 := NULL;
       ELSIF (p_ATTRIBUTE1 IS NOT NULL) THEN
        x_attribute1 := p_attribute1;
      END IF;

      IF (p_attribute2 = G_MISS_CHAR) THEN
        x_attribute2 := NULL;
       ELSIF (p_ATTRIBUTE2 IS NOT NULL) THEN
        x_attribute2 := p_attribute2;
      END IF;

      IF (p_attribute3 = G_MISS_CHAR) THEN
        x_attribute3 := NULL;
       ELSIF (p_ATTRIBUTE3 IS NOT NULL) THEN
        x_attribute3 := p_attribute3;
      END IF;

      IF (p_attribute4 = G_MISS_CHAR) THEN
        x_attribute4 := NULL;
       ELSIF (p_ATTRIBUTE4 IS NOT NULL) THEN
        x_attribute4 := p_attribute4;
      END IF;

      IF (p_attribute5 = G_MISS_CHAR) THEN
        x_attribute5 := NULL;
       ELSIF (p_ATTRIBUTE5 IS NOT NULL) THEN
        x_attribute5 := p_attribute5;
      END IF;

      IF (p_attribute6 = G_MISS_CHAR) THEN
        x_attribute6 := NULL;
       ELSIF (p_ATTRIBUTE6 IS NOT NULL) THEN
        x_attribute6 := p_attribute6;
      END IF;

      IF (p_attribute7 = G_MISS_CHAR) THEN
        x_attribute7 := NULL;
       ELSIF (p_ATTRIBUTE7 IS NOT NULL) THEN
        x_attribute7 := p_attribute7;
      END IF;

      IF (p_attribute8 = G_MISS_CHAR) THEN
        x_attribute8 := NULL;
       ELSIF (p_ATTRIBUTE8 IS NOT NULL) THEN
        x_attribute8 := p_attribute8;
      END IF;

      IF (p_attribute9 = G_MISS_CHAR) THEN
        x_attribute9 := NULL;
       ELSIF (p_ATTRIBUTE9 IS NOT NULL) THEN
        x_attribute9 := p_attribute9;
      END IF;

      IF (p_attribute10 = G_MISS_CHAR) THEN
        x_attribute10 := NULL;
       ELSIF (p_ATTRIBUTE10 IS NOT NULL) THEN
        x_attribute10 := p_attribute10;
      END IF;

      IF (p_attribute11 = G_MISS_CHAR) THEN
        x_attribute11 := NULL;
       ELSIF (p_ATTRIBUTE11 IS NOT NULL) THEN
        x_attribute11 := p_attribute11;
      END IF;

      IF (p_attribute12 = G_MISS_CHAR) THEN
        x_attribute12 := NULL;
       ELSIF (p_ATTRIBUTE12 IS NOT NULL) THEN
        x_attribute12 := p_attribute12;
      END IF;

      IF (p_attribute13 = G_MISS_CHAR) THEN
        x_attribute13 := NULL;
       ELSIF (p_ATTRIBUTE13 IS NOT NULL) THEN
        x_attribute13 := p_attribute13;
      END IF;

      IF (p_attribute14 = G_MISS_CHAR) THEN
        x_attribute14 := NULL;
       ELSIF (p_ATTRIBUTE14 IS NOT NULL) THEN
        x_attribute14 := p_attribute14;
      END IF;

      IF (p_attribute15 = G_MISS_CHAR) THEN
        x_attribute15 := NULL;
       ELSIF (p_ATTRIBUTE15 IS NOT NULL) THEN
        x_attribute15 := p_attribute15;
      END IF;
    END IF;
   RETURN G_RET_STS_SUCCESS ;
  END;
  -----------------------------------------
  -- End of Set_Attributes for:OKC_K_ARTICLES_B --
  -----------------------------------------

  ----------------------------------------------
  -- Validate_Attributes for: OKC_K_ARTICLES_B --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id               IN NUMBER,
    p_ref_article_version_id       IN NUMBER
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

    CURSOR lc_sav_sae_id is
     SELECT '!'
      FROM okc_articles_all
      WHERE article_id = p_sav_sae_id;

    CURSOR lc_scn_id is
     SELECT '!'
      FROM okc_sections_b
      WHERE ID = p_scn_id;

    CURSOR lc_article_version_id is
     SELECT '!'
      FROM okc_article_versions
      WHERE ARTICLE_VERSION_ID = p_article_version_id;

    CURSOR l_doc_type_csr is
     SELECT '!'
      FROM OKC_BUS_DOC_TYPES_V
      WHERE document_type = p_document_type;

    CURSOR l_validate_amend_mode_csr IS
    SELECT '!' FROM OKC_SECTIONS_B
    WHERE ID = p_scn_id
    AND   AMENDMENT_OPERATION_CODE = G_AMEND_CODE_DELETED;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('700: Entered Validate_Attributes', 2);
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LVL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('800: required values validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('900: - attribute ID ', 2);
      END IF;
      IF ( p_id IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1000: - attribute ID is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute DOCUMENT_TYPE ', 2);
      END IF;
      IF ( p_document_type IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute DOCUMENT_TYPE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DOCUMENT_TYPE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute DOCUMENT_ID ', 2);
      END IF;
      IF ( p_document_id IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute DOCUMENT_ID is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DOCUMENT_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute SCN_ID ', 2);
      END IF;
      IF ( p_scn_id IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute SCN_ID is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'SCN_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute DISPLAY_SEQUENCE ', 2);
      END IF;
      IF ( p_display_sequence IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute DISPLAY_SEQUENCE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DISPLAY_SEQUENCE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute SAV_SAE_ID', 2);
      END IF;
      IF ( p_sav_sae_id IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute SAV_SAE_ID is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'SAV_SAE_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;
    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LVL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1100: static values and range validation', 2);
      END IF;


      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1200: - attribute MANDATORY_YN ', 2);
      END IF;

      IF ( p_mandatory_yn NOT IN ('Y','N') AND p_mandatory_yn IS NOT NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1300: - attribute MANDATORY_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'MANDATORY_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1200: - attribute PRINT_TEXT_YN ', 2);
      END IF;

      IF ( p_print_text_yn NOT IN ('Y','N') AND p_print_text_yn IS NOT NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1300: - attribute PRINT_TEXT_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'PRINT_TEXT_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1200: - attribute CHANGE_NONSTD_YN ', 2);
      END IF;
      IF ( p_change_nonstd_yn NOT IN ('Y','N') AND p_change_nonstd_yn IS NOT NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1300: - attribute CHANGE_NONSTD_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CHANGE_NONSTD_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LVL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1400: lookup codes validation', 2);
      END IF;

      IF p_amendment_operation_code is not null THEN
       IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1500: - attribute AMENDMENT_OPERATION_CODE ', 2);
       END IF;

       l_return_status := Okc_Util.Check_Lookup_Code('OKC_AMEND_OPN_CODE',p_amendment_operation_code);

       IF (l_return_status <> G_RET_STS_SUCCESS) THEN
         Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'AMENDMENT_OPERATION_CODE');
        l_return_status := G_RET_STS_ERROR;
       END IF;

      IF p_summary_amend_operation_code is not null THEN
       IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1500: - attribute SUMMARY_AMEND_OPERATION_CODE ', 2);
       END IF;

       l_return_status := Okc_Util.Check_Lookup_Code('OKC_AMEND_OPN_CODE',p_summary_amend_operation_code);

       IF (l_return_status <> G_RET_STS_SUCCESS) THEN
         Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SUMMARY_AMEND_OPERATION_CODE');
        l_return_status := G_RET_STS_ERROR;
       END IF;
     END IF;

       IF p_amendment_operation_code IN (G_AMEND_CODE_UPDATED,G_AMEND_CODE_ADDED) THEN

           l_dummy_var := '?';

           OPEN  l_validate_amend_mode_csr;
           FETCH l_validate_amend_mode_csr INTO l_dummy_var;
           CLOSE l_validate_amend_mode_csr;
           IF l_dummy_var <> '?' THEN
               Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_AMEND_INVALID');
               l_return_status := G_RET_STS_ERROR;
           END IF;

      END IF;

    END IF;

    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LVL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: foreigh keys validation ', 2);
      END IF;

      IF p_document_type IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN  l_doc_type_csr;
        FETCH l_doc_type_csr INTO l_dummy_var;
        CLOSE l_doc_type_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute DOCUMENT_TYPE is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DOCUMENT_TYPE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute SAV_SAE_ID ', 2);
      END IF;
      IF p_sav_sae_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN lc_sav_sae_id;
        FETCH lc_sav_sae_id INTO l_dummy_var;
        CLOSE lc_sav_sae_id;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('1800: - attribute SAV_SAE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SAV_SAE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;


      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute SCN_ID ', 2);
      END IF;
      IF p_scn_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN lc_scn_id;
        FETCH lc_scn_id INTO l_dummy_var;
        CLOSE lc_scn_id;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('1800: - attribute SCN_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SCN_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute ARTICLE_VERSION_ID ', 2);
      END IF;
      IF p_article_version_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN lc_article_version_id;
        FETCH lc_article_version_id INTO l_dummy_var;
        CLOSE lc_article_version_id;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('1800: - attribute ARTICLE_VERSION_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ARTICLE_VERSION_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1900: Leaving Validate_Attributes ', 2);
    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      Okc_Debug.Log('2000: Leaving Validate_Attributes because of EXCEPTION: '||sqlerrm, 2);
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);


      IF lc_sav_sae_id%ISOPEN THEN
        CLOSE lc_sav_sae_id;
      END IF;

      IF lc_scn_id%ISOPEN THEN
        CLOSE lc_scn_id;
      END IF;
/*
      IF l_validate_amend_mode_csr%ISOPEN THEN
        CLOSE l_validate_amend_mode_csr;
      END IF;
*/

      IF lc_article_version_id%ISOPEN THEN
        CLOSE lc_article_version_id;
      END IF;

      IF l_doc_type_csr%ISOPEN THEN
        CLOSE l_doc_type_csr;
      END IF;


      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_K_ARTICLES_B --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	         IN NUMBER,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id               IN NUMBER,
    p_ref_article_version_id       IN NUMBER,
    p_mandatory_rwa               IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

    CURSOR l_validate_article_csr IS
    SELECT '!' FROM OKC_ARTICLE_VERSIONS
    WHERE ARTICLE_VERSION_ID = p_article_version_id
    AND   ARTICLE_ID        = p_sav_sae_id;


  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2100: Entered Validate_Record', 2);
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_id                         => p_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_summary_amend_operation_code => p_summary_amend_operation_code,
      p_ref_article_id               => p_ref_article_id,
      p_ref_article_version_id       => p_ref_article_version_id
    );

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('2200: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm, 2);
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;
    END IF;

    --- Record Level Validation
    IF p_validation_level > G_RECORD_VALID_LVL THEN
      IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2300: Entered Record Level Validations', 2);
      END IF;

      -- this validation is not required for templates
      IF p_sav_sae_id IS NOT NULL AND p_article_version_id IS NOT NULL
        AND p_document_type  <> OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
      THEN
         l_dummy_var := '?';
         OPEN l_validate_article_csr;
         FETCH l_validate_article_csr into l_dummy_var;
         CLOSE L_validate_article_csr;
        If l_dummy_var='?' THEN

         IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - Wrong Combination of Article_version_id and sav_sae_id', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_VERSION_ID');
        l_return_status := G_RET_STS_ERROR;
       END IF;
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('2400: Leaving Validate_Record : '||sqlerrm, 2);
    END IF;
    RETURN l_return_status ;

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('2500: Leaving Validate_Record because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF l_validate_article_csr%ISOPEN THEN
         CLOSE l_validate_article_csr;
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN G_RET_STS_UNEXP_ERROR ;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_K_ARTICLES_B --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	         IN NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id               IN NUMBER,
    p_ref_article_version_id       IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_mandatory_rwa               IN VARCHAR2
  ) IS
      l_sav_sae_id                 OKC_K_ARTICLES_B.SAV_SAE_ID%TYPE;
      l_document_type              OKC_K_ARTICLES_B.DOCUMENT_TYPE%TYPE;
      l_document_id                OKC_K_ARTICLES_B.DOCUMENT_ID%TYPE;
      l_cle_id                     OKC_K_ARTICLES_B.CLE_ID%TYPE;
      l_source_flag                OKC_K_ARTICLES_B.SOURCE_FLAG%TYPE;
      l_mandatory_yn               OKC_K_ARTICLES_B.MANDATORY_YN%TYPE;
     l_mandatory_rwa              OKC_K_ARTICLES_B.MANDATORY_RWA%TYPE;
      l_scn_id                     OKC_K_ARTICLES_B.SCN_ID%TYPE;
      l_label                      OKC_K_ARTICLES_B.LABEL%TYPE;
      l_amendment_description      OKC_K_ARTICLES_B.AMENDMENT_DESCRIPTION%TYPE;
      l_amendment_operation_code   OKC_K_ARTICLES_B.AMENDMENT_OPERATION_CODE%TYPE;
      l_article_version_id         OKC_K_ARTICLES_B.ARTICLE_VERSION_ID%TYPE;
      l_change_nonstd_yn           OKC_K_ARTICLES_B.CHANGE_NONSTD_YN%TYPE;
      l_orig_system_reference_code OKC_K_ARTICLES_B.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
      l_orig_system_reference_id1  OKC_K_ARTICLES_B.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
      l_orig_system_reference_id2  OKC_K_ARTICLES_B.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
      l_display_sequence           OKC_K_ARTICLES_B.DISPLAY_SEQUENCE%TYPE;
      l_attribute_category         OKC_K_ARTICLES_B.ATTRIBUTE_CATEGORY%TYPE;
      l_attribute1                 OKC_K_ARTICLES_B.ATTRIBUTE1%TYPE;
      l_attribute2                 OKC_K_ARTICLES_B.ATTRIBUTE2%TYPE;
      l_attribute3                 OKC_K_ARTICLES_B.ATTRIBUTE3%TYPE;
      l_attribute4                 OKC_K_ARTICLES_B.ATTRIBUTE4%TYPE;
      l_attribute5                 OKC_K_ARTICLES_B.ATTRIBUTE5%TYPE;
      l_attribute6                 OKC_K_ARTICLES_B.ATTRIBUTE6%TYPE;
      l_attribute7                 OKC_K_ARTICLES_B.ATTRIBUTE7%TYPE;
      l_attribute8                 OKC_K_ARTICLES_B.ATTRIBUTE8%TYPE;
      l_attribute9                 OKC_K_ARTICLES_B.ATTRIBUTE9%TYPE;
      l_attribute10                OKC_K_ARTICLES_B.ATTRIBUTE10%TYPE;
      l_attribute11                OKC_K_ARTICLES_B.ATTRIBUTE11%TYPE;
      l_attribute12                OKC_K_ARTICLES_B.ATTRIBUTE12%TYPE;
      l_attribute13                OKC_K_ARTICLES_B.ATTRIBUTE13%TYPE;
      l_attribute14                OKC_K_ARTICLES_B.ATTRIBUTE14%TYPE;
      l_attribute15                OKC_K_ARTICLES_B.ATTRIBUTE15%TYPE;
      l_print_text_yn              OKC_K_ARTICLES_B.print_text_yn%TYPE;
      l_summary_amend_operation_code OKC_K_ARTICLES_B.summary_amend_operation_code%TYPE;
      l_ref_article_id              OKC_K_ARTICLES_B.ref_article_id%TYPE;
      l_ref_article_version_id      OKC_K_ARTICLES_B.ref_article_version_id%TYPE;
      l_object_version_number      OKC_K_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by                 OKC_K_ARTICLES_B.CREATED_BY%TYPE;
      l_creation_date              OKC_K_ARTICLES_B.CREATION_DATE%TYPE;
      l_last_updated_by            OKC_K_ARTICLES_B.LAST_UPDATED_BY%TYPE;
      l_last_update_login          OKC_K_ARTICLES_B.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date           OKC_K_ARTICLES_B.LAST_UPDATE_DATE%TYPE;
      l_last_amended_by            OKC_K_ARTICLES_B.LAST_AMENDED_BY%TYPE;
      l_last_amendment_date        OKC_K_ARTICLES_B.LAST_AMENDMENT_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_id                         => p_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_summary_amend_operation_code => p_summary_amend_operation_code,
      p_ref_article_id               => p_ref_article_id,
      p_ref_article_version_id       => p_ref_article_version_id,
      p_object_version_number      => p_object_version_number,
      p_last_amended_by            => NULL,
      p_last_amendment_date        => NULL,
      x_sav_sae_id                 => l_sav_sae_id,
      x_document_type              => l_document_type,
      x_document_id                => l_document_id,
      x_cle_id                     => l_cle_id,
      x_source_flag                => l_source_flag,
      x_mandatory_yn               => l_mandatory_yn,
      x_scn_id                     => l_scn_id,
      x_label                      => l_label,
      x_amendment_description      => l_amendment_description,
      x_amendment_operation_code   => l_amendment_operation_code,
      x_article_version_id         => l_article_version_id,
      x_change_nonstd_yn           => l_change_nonstd_yn,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_display_sequence           => l_display_sequence,
      x_attribute_category         => l_attribute_category,
      x_attribute1                 => l_attribute1,
      x_attribute2                 => l_attribute2,
      x_attribute3                 => l_attribute3,
      x_attribute4                 => l_attribute4,
      x_attribute5                 => l_attribute5,
      x_attribute6                 => l_attribute6,
      x_attribute7                 => l_attribute7,
      x_attribute8                 => l_attribute8,
      x_attribute9                 => l_attribute9,
      x_attribute10                => l_attribute10,
      x_attribute11                => l_attribute11,
      x_attribute12                => l_attribute12,
      x_attribute13                => l_attribute13,
      x_attribute14                => l_attribute14,
      x_attribute15                => l_attribute15,
      x_print_text_yn              => l_print_text_yn,
      x_summary_amend_operation_code => l_summary_amend_operation_code,
      x_object_version_number        => l_object_version_number,
      x_ref_article_id               => l_ref_article_id,
      x_ref_article_version_id       => l_ref_article_version_id,
      x_last_amended_by            => l_last_amended_by,
      x_last_amendment_date        => l_last_amendment_date,
      p_mandatory_rwa              =>  p_mandatory_rwa,
      x_mandatory_rwa               => l_mandatory_rwa
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_id                         => p_id,
      p_sav_sae_id                 => l_sav_sae_id,
      p_document_type              => l_document_type,
      p_document_id                => l_document_id,
      p_cle_id                     => l_cle_id,
      p_source_flag                => l_source_flag,
      p_mandatory_yn               => l_mandatory_yn,
      p_scn_id                     => l_scn_id,
      p_label                      => l_label,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_article_version_id         => l_article_version_id,
      p_change_nonstd_yn           => l_change_nonstd_yn,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_display_sequence           => l_display_sequence,
      p_attribute_category         => l_attribute_category,
      p_attribute1                 => l_attribute1,
      p_attribute2                 => l_attribute2,
      p_attribute3                 => l_attribute3,
      p_attribute4                 => l_attribute4,
      p_attribute5                 => l_attribute5,
      p_attribute6                 => l_attribute6,
      p_attribute7                 => l_attribute7,
      p_attribute8                 => l_attribute8,
      p_attribute9                 => l_attribute9,
      p_attribute10                => l_attribute10,
      p_attribute11                => l_attribute11,
      p_attribute12                => l_attribute12,
      p_attribute13                => l_attribute13,
      p_attribute14                => l_attribute14,
      p_attribute15                => l_attribute15,
      p_print_text_yn              => l_print_text_yn,
      p_summary_amend_operation_code => l_summary_amend_operation_code,
      p_ref_article_id               => l_ref_article_id,
      p_ref_article_version_id       => l_ref_article_version_id,
       p_mandatory_rwa               => l_mandatory_rwa
    );

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2700: Leaving validate_row', 2);
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2800: Leaving Validate_Row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2900: Leaving Validate_Row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('3000: Leaving Validate_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Validate_Row;

  ---------------------------------------------------------------------------
  -- PROCEDURE Insert_Row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- Insert_Row for:OKC_K_ARTICLES_B --
  -------------------------------------
  FUNCTION Insert_Row(
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_cat_type                   IN VARCHAR2, -- Bug 3341342
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn                IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id               IN NUMBER,
    p_ref_article_version_id       IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE ,
    p_mandatory_rwa              IN VARCHAR2

  ) RETURN VARCHAR2 IS
   l_chr_id   NUMBER;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered Insert_Row function', 2);
    END IF;

    IF p_document_type IN ('OKC_SELL','OKC_BUY','OKO','OKS','OKE_SELL','OKE_BUY','OKL') THEN
      l_chr_id := okc_terms_util_pvt.get_chr_id_for_doc_id(p_document_id);
    END IF;

    INSERT INTO OKC_K_ARTICLES_B(
        ID,
        SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        CAT_TYPE,
        CHR_ID,
        CAT_ID,
        DNZ_CHR_ID,
        FULLTEXT_YN,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        CLE_ID,
        SOURCE_FLAG,
        MANDATORY_YN,
        SCN_ID,
        LABEL,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ARTICLE_VERSION_ID,
        CHANGE_NONSTD_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        DISPLAY_SEQUENCE,
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
        PRINT_TEXT_YN,
        SUMMARY_AMEND_OPERATION_CODE,
        REF_ARTICLE_ID,
        REF_ARTICLE_VERSION_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        ORIG_ARTICLE_ID,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE,
        MANDATORY_RWA )
      VALUES (
        p_id,
        p_sav_sae_id,
        Null,
        Null,
        p_cat_type,--Bug 3341342
        decode(p_cle_id,NULL,l_chr_id,NULL),
        Null,
        l_chr_id,
        Null,
        p_document_type,
        p_document_id,
        p_cle_id,
        p_source_flag,
        p_mandatory_yn,
        p_scn_id,
        p_label,
        p_amendment_description,
        p_amendment_operation_code,
        decode(p_document_type, OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,NULL,p_article_version_id),
        p_change_nonstd_yn,
        p_orig_system_reference_code,
        p_orig_system_reference_id1,
        p_orig_system_reference_id2,
        p_display_sequence,
        p_attribute_category,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15,
        p_print_text_yn,
        p_summary_amend_operation_code,
        p_ref_article_id,
        p_ref_article_version_id,
        p_object_version_number,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date,
        p_sav_sae_id,
        p_last_amended_by,
        p_last_amendment_date,
        p_mandatory_rwa);

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3200: Leaving Insert_Row', 2);
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3300: Leaving Insert_Row:OTHERS Exception', 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );

  END Insert_Row;

  -------------------------------------
  -- Insert_Row for:OKC_K_ARTICLES_B --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	         IN NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_cat_type                   IN VARCHAR2,--Bug 3341342
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id              IN NUMBER,
    p_ref_article_version_id      IN NUMBER,
    p_mandatory_rwa               IN VARCHAR2,
    x_id                         OUT NOCOPY NUMBER

  ) IS

    l_object_version_number      OKC_K_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_K_ARTICLES_B.CREATED_BY%TYPE;
    l_creation_date              OKC_K_ARTICLES_B.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_K_ARTICLES_B.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_K_ARTICLES_B.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_K_ARTICLES_B.LAST_UPDATE_DATE%TYPE;
    l_last_amended_by            OKC_K_ARTICLES_B.LAST_AMENDED_BY%TYPE;
    l_last_amendment_date        OKC_K_ARTICLES_B.LAST_AMENDMENT_DATE%TYPE;

  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3400: Entered Insert_Row', 2);
    END IF;

    --- Setting item attributes
    -- Set primary key value
    IF( p_id IS NULL ) THEN
      x_return_status := Get_Seq_Id(
        p_id => p_id,
        x_id => x_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
     ELSE
      x_id := p_id;
    END IF;
    -- Set Internal columns
    l_object_version_number      := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;
    IF p_amendment_operation_code IS NOT NULL THEN
      l_last_amendment_date := l_creation_date;
      l_last_amended_by := l_created_by;
    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_id                         => x_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_summary_amend_operation_code=> p_summary_amend_operation_code,
      p_ref_article_id              => p_ref_article_id,
      p_ref_article_version_id      => p_ref_article_version_id,
      p_mandatory_rwa               => p_mandatory_rwa
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------------
    -- Call the internal Insert_Row for each child record
    --------------------------------------------
    x_return_status := Insert_Row(
      p_id                         => x_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_cat_type                   => p_cat_type, --Bug 3341342
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_summary_amend_operation_code=> p_summary_amend_operation_code,
      p_ref_article_id              => p_ref_article_id,
      p_ref_article_version_id      => p_ref_article_version_id,
      p_object_version_number      => l_object_version_number,
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date,
      p_last_amended_by            => l_last_amended_by,
      p_last_amendment_date        => l_last_amendment_date,
      p_mandatory_rwa               => p_mandatory_rwa
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3500: Leaving Insert_Row', 2);
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3600: Leaving Insert_Row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3700: Leaving Insert_Row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3800: Leaving Insert_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Insert_Row;
  ---------------------------------------------------------------------------
  -- PROCEDURE Lock_Row
  ---------------------------------------------------------------------------
  -----------------------------------
  -- Lock_Row for:OKC_K_ARTICLES_B --
  -----------------------------------
  FUNCTION Lock_Row(
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
  ) RETURN VARCHAR2 IS


    CURSOR lock_csr (cp_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_K_ARTICLES_B
     WHERE ID = cp_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_K_ARTICLES_B
     WHERE ID = cp_id;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_K_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3900: Entered Lock_Row', 2);
    END IF;


    BEGIN

      OPEN lock_csr( p_id, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN

        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('4000: Leaving Lock_Row:E_Resource_Busy Exception', 2);
        END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
        RETURN( G_RET_STS_ERROR );
    END;

    IF ( l_row_notfound ) THEN
      l_return_status := G_RET_STS_ERROR;

      OPEN lchk_csr(p_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        Okc_Api.Set_Message(G_APP_NAME,G_LOCK_RECORD_DELETED,
                   'ENTITYNAME','OKC_K_ARTICLES_B',
                   'PKEY',p_id,
                   'OVN',p_object_version_number
                    );
      ELSIF l_object_version_number > p_object_version_number THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_CHANGED);
      ELSIF l_object_version_number = -1 THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      ELSE -- it can be the only above condition. It can happen after restore version
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_CHANGED);
      END IF;
     ELSE
      l_return_status := G_RET_STS_SUCCESS;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4100: Leaving Lock_Row', 2);
    END IF;

    RETURN( l_return_status );

  EXCEPTION
    WHEN OTHERS THEN

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      IF (lchk_csr%ISOPEN) THEN
        CLOSE lchk_csr;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('4200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );
  END Lock_Row;
  -----------------------------------
  -- Lock_Row for:OKC_K_ARTICLES_B --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
   ) IS
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4300: Entered Lock_Row', 2);
    END IF;

    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    x_return_status := Lock_Row(
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('4400: Leaving Lock_Row', 2);
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4500: Leaving Lock_Row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_ERROR;
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4600: Leaving Lock_Row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4700: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Lock_Row;
  ---------------------------------------------------------------------------
  -- PROCEDURE Update_Row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- Update_Row for:OKC_K_ARTICLES_B --
  -------------------------------------
  FUNCTION Update_Row(
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_mandatory_rwa              IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id              IN NUMBER,
    p_ref_article_version_id      IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE
   ) RETURN VARCHAR2 IS

   l_chr_id   NUMBER;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4800: Entered Update_Row', 2);
    END IF;
    IF p_document_type IN ('OKC_SELL','OKC_BUY','OKO','OKS','OKE_SELL','OKE_BUY','OKL') THEN
      l_chr_id := okc_terms_util_pvt.get_chr_id_for_doc_id(p_document_id);
    END IF;

    UPDATE OKC_K_ARTICLES_B
     SET SAV_SAE_ID                 = p_sav_sae_id,
         DOCUMENT_TYPE              = p_document_type,
         DOCUMENT_ID                = p_document_id,
         CLE_ID                     = p_cle_id,
         SOURCE_FLAG                = p_source_flag,
         MANDATORY_YN               = p_mandatory_yn,
         MANDATORY_RWA              = p_mandatory_rwa,
         SCN_ID                     = p_scn_id,
         CHR_ID                     = decode(p_cle_id,NULL,l_chr_id,NULL),
         DNZ_CHR_ID                 = l_chr_id,
         LABEL                      = p_label,
         AMENDMENT_DESCRIPTION      = p_amendment_description,
         AMENDMENT_OPERATION_CODE   = p_amendment_operation_code,
         ARTICLE_VERSION_ID         = decode(p_document_type,OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,NULL,p_article_version_id),
         CHANGE_NONSTD_YN           = p_change_nonstd_yn,
         ORIG_SYSTEM_REFERENCE_CODE = p_orig_system_reference_code,
         ORIG_SYSTEM_REFERENCE_ID1  = p_orig_system_reference_id1,
         ORIG_SYSTEM_REFERENCE_ID2  = p_orig_system_reference_id2,
         DISPLAY_SEQUENCE           = p_display_sequence,
         ATTRIBUTE_CATEGORY         = p_attribute_category,
         ATTRIBUTE1                 = p_attribute1,
         ATTRIBUTE2                 = p_attribute2,
         ATTRIBUTE3                 = p_attribute3,
         ATTRIBUTE4                 = p_attribute4,
         ATTRIBUTE5                 = p_attribute5,
         ATTRIBUTE6                 = p_attribute6,
         ATTRIBUTE7                 = p_attribute7,
         ATTRIBUTE8                 = p_attribute8,
         ATTRIBUTE9                 = p_attribute9,
         ATTRIBUTE10                = p_attribute10,
         ATTRIBUTE11                = p_attribute11,
         ATTRIBUTE12                = p_attribute12,
         ATTRIBUTE13                = p_attribute13,
         ATTRIBUTE14                = p_attribute14,
         ATTRIBUTE15                = p_attribute15,
         PRINT_TEXT_YN              = p_print_text_yn,
         SUMMARY_AMEND_OPERATION_CODE= p_summary_amend_operation_code,
         REF_ARTICLE_ID             = p_ref_article_id,
         REF_ARTICLE_VERSION_ID     = p_ref_article_version_id,
         OBJECT_VERSION_NUMBER      = p_object_version_number,
         LAST_UPDATED_BY            = p_last_updated_by,
         LAST_UPDATE_LOGIN          = p_last_update_login,
         LAST_UPDATE_DATE           = p_last_update_date,
         LAST_AMENDED_BY            = p_last_amended_by,
         LAST_AMENDMENT_DATE        = p_last_amendment_date
    WHERE ID                        = p_id;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Leaving Update_Row', 2);
    END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('5000: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Update_Row;
  -------------------------------------
  -- Update_Row for:OKC_K_ARTICLES_B --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	         IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER,
    p_source_flag                IN VARCHAR2,
    p_mandatory_yn               IN VARCHAR2,
    p_mandatory_rwa              IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_display_sequence           IN NUMBER,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2,
    p_print_text_yn              IN VARCHAR2,
    p_summary_amend_operation_code IN VARCHAR2,
    p_ref_article_id              IN NUMBER,
    p_ref_article_version_id      IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_last_amended_by            IN NUMBER,
    p_last_amendment_date        IN DATE

   ) IS

    l_sav_sae_id                 OKC_K_ARTICLES_B.SAV_SAE_ID%TYPE;
    l_document_type              OKC_K_ARTICLES_B.DOCUMENT_TYPE%TYPE;
    l_document_id                OKC_K_ARTICLES_B.DOCUMENT_ID%TYPE;
    l_cle_id                     OKC_K_ARTICLES_B.cle_id%TYPE;
    l_source_flag                OKC_K_ARTICLES_B.SOURCE_FLAG%TYPE;
    l_mandatory_yn               OKC_K_ARTICLES_B.MANDATORY_YN%TYPE;
    l_mandatory_rwa              OKC_K_ARTICLES_B.MANDATORY_RWA%TYPE;
    l_scn_id                     OKC_K_ARTICLES_B.SCN_ID%TYPE;
    l_label                      OKC_K_ARTICLES_B.LABEL%TYPE;
    l_amendment_description      OKC_K_ARTICLES_B.AMENDMENT_DESCRIPTION%TYPE;
    l_amendment_operation_code   OKC_K_ARTICLES_B.AMENDMENT_OPERATION_CODE%TYPE;
    l_article_version_id         OKC_K_ARTICLES_B.ARTICLE_VERSION_ID%TYPE;
    l_change_nonstd_yn           OKC_K_ARTICLES_B.CHANGE_NONSTD_YN%TYPE;
    l_orig_system_reference_code OKC_K_ARTICLES_B.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    l_orig_system_reference_id1  OKC_K_ARTICLES_B.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    l_orig_system_reference_id2  OKC_K_ARTICLES_B.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
    l_display_sequence           OKC_K_ARTICLES_B.DISPLAY_SEQUENCE%TYPE;
    l_attribute_category         OKC_K_ARTICLES_B.ATTRIBUTE_CATEGORY%TYPE;
    l_attribute1                 OKC_K_ARTICLES_B.ATTRIBUTE1%TYPE;
    l_attribute2                 OKC_K_ARTICLES_B.ATTRIBUTE2%TYPE;
    l_attribute3                 OKC_K_ARTICLES_B.ATTRIBUTE3%TYPE;
    l_attribute4                 OKC_K_ARTICLES_B.ATTRIBUTE4%TYPE;
    l_attribute5                 OKC_K_ARTICLES_B.ATTRIBUTE5%TYPE;
    l_attribute6                 OKC_K_ARTICLES_B.ATTRIBUTE6%TYPE;
    l_attribute7                 OKC_K_ARTICLES_B.ATTRIBUTE7%TYPE;
    l_attribute8                 OKC_K_ARTICLES_B.ATTRIBUTE8%TYPE;
    l_attribute9                 OKC_K_ARTICLES_B.ATTRIBUTE9%TYPE;
    l_attribute10                OKC_K_ARTICLES_B.ATTRIBUTE10%TYPE;
    l_attribute11                OKC_K_ARTICLES_B.ATTRIBUTE11%TYPE;
    l_attribute12                OKC_K_ARTICLES_B.ATTRIBUTE12%TYPE;
    l_attribute13                OKC_K_ARTICLES_B.ATTRIBUTE13%TYPE;
    l_attribute14                OKC_K_ARTICLES_B.ATTRIBUTE14%TYPE;
    l_attribute15                OKC_K_ARTICLES_B.ATTRIBUTE15%TYPE;
    l_print_text_yn              OKC_K_ARTICLES_B.print_text_yn%TYPE;
    l_summary_amend_operation_code OKC_K_ARTICLES_B.summary_amend_operation_code%TYPE;
    l_ref_article_id             OKC_K_ARTICLES_B.ref_article_id%TYPE;
    l_ref_article_version_id     OKC_K_ARTICLES_B.ref_article_version_id%TYPE;
    l_object_version_number      OKC_K_ARTICLES_B.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_K_ARTICLES_B.CREATED_BY%TYPE;
    l_creation_date              OKC_K_ARTICLES_B.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_K_ARTICLES_B.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_K_ARTICLES_B.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_K_ARTICLES_B.LAST_UPDATE_DATE%TYPE;
    l_last_amended_by            OKC_K_ARTICLES_B.LAST_AMENDED_BY%TYPE;
    l_last_amendment_date        OKC_K_ARTICLES_B.LAST_AMENDMENT_DATE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5100: Entered Update_Row', 2);
       Okc_Debug.Log('5200: Locking row', 2);
    END IF;

    x_return_status := Lock_row(
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5300: Setting attributes', 2);
    END IF;

    x_return_status := Set_Attributes(
      p_id                         => p_id,
      p_sav_sae_id                 => p_sav_sae_id,
      p_document_type              => p_document_type,
      p_document_id                => p_document_id,
      p_cle_id                     => p_cle_id,
      p_source_flag                => p_source_flag,
      p_mandatory_yn               => p_mandatory_yn,
      p_scn_id                     => p_scn_id,
      p_label                      => p_label,
      p_amendment_description      => p_amendment_description,
      p_amendment_operation_code   => p_amendment_operation_code,
      p_article_version_id         => p_article_version_id,
      p_change_nonstd_yn           => p_change_nonstd_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_display_sequence           => p_display_sequence,
      p_attribute_category         => p_attribute_category,
      p_attribute1                 => p_attribute1,
      p_attribute2                 => p_attribute2,
      p_attribute3                 => p_attribute3,
      p_attribute4                 => p_attribute4,
      p_attribute5                 => p_attribute5,
      p_attribute6                 => p_attribute6,
      p_attribute7                 => p_attribute7,
      p_attribute8                 => p_attribute8,
      p_attribute9                 => p_attribute9,
      p_attribute10                => p_attribute10,
      p_attribute11                => p_attribute11,
      p_attribute12                => p_attribute12,
      p_attribute13                => p_attribute13,
      p_attribute14                => p_attribute14,
      p_attribute15                => p_attribute15,
      p_print_text_yn              => p_print_text_yn,
      p_summary_amend_operation_code => p_summary_amend_operation_code,
      p_ref_article_id             => p_ref_article_id,
      p_ref_article_version_id     => p_ref_article_version_id,
      p_object_version_number      => p_object_version_number,
      p_last_amended_by            => p_last_amended_by,
      p_last_amendment_date        => p_last_amendment_date,
      x_sav_sae_id                 => l_sav_sae_id,
      x_document_type              => l_document_type,
      x_document_id                => l_document_id,
      x_cle_id                     => l_cle_id,
      x_source_flag                => l_source_flag,
      x_mandatory_yn               => l_mandatory_yn,
      x_scn_id                     => l_scn_id,
      x_label                      => l_label,
      x_amendment_description      => l_amendment_description,
      x_amendment_operation_code   => l_amendment_operation_code,
      x_article_version_id         => l_article_version_id,
      x_change_nonstd_yn           => l_change_nonstd_yn,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_display_sequence           => l_display_sequence,
      x_attribute_category         => l_attribute_category,
      x_attribute1                 => l_attribute1,
      x_attribute2                 => l_attribute2,
      x_attribute3                 => l_attribute3,
      x_attribute4                 => l_attribute4,
      x_attribute5                 => l_attribute5,
      x_attribute6                 => l_attribute6,
      x_attribute7                 => l_attribute7,
      x_attribute8                 => l_attribute8,
      x_attribute9                 => l_attribute9,
      x_attribute10                => l_attribute10,
      x_attribute11                => l_attribute11,
      x_attribute12                => l_attribute12,
      x_attribute13                => l_attribute13,
      x_attribute14                => l_attribute14,
      x_attribute15                => l_attribute15,
      x_print_text_yn              => l_print_text_yn,
      x_summary_amend_operation_code => l_summary_amend_operation_code,
      x_object_version_number       => l_object_version_number,
      x_ref_article_id              => l_ref_article_id,
      x_ref_article_version_id      => l_ref_article_version_id,
      x_last_amended_by            => l_last_amended_by,
      x_last_amendment_date        => l_last_amendment_date,
      p_mandatory_rwa               => p_mandatory_rwa,
      x_mandatory_rwa               => l_mandatory_rwa
    );

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5400: Record Validation', 2);
    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_id                         => p_id,
      p_sav_sae_id                 => l_sav_sae_id,
      p_document_type              => l_document_type,
      p_document_id                => l_document_id,
      p_cle_id                     => l_cle_id,
      p_source_flag                => l_source_flag,
      p_mandatory_yn               => l_mandatory_yn,
      p_scn_id                     => l_scn_id,
      p_label                      => l_label,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_article_version_id         => l_article_version_id,
      p_change_nonstd_yn           => l_change_nonstd_yn,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_display_sequence           => l_display_sequence,
      p_attribute_category         => l_attribute_category,
      p_attribute1                 => l_attribute1,
      p_attribute2                 => l_attribute2,
      p_attribute3                 => l_attribute3,
      p_attribute4                 => l_attribute4,
      p_attribute5                 => l_attribute5,
      p_attribute6                 => l_attribute6,
      p_attribute7                 => l_attribute7,
      p_attribute8                 => l_attribute8,
      p_attribute9                 => l_attribute9,
      p_attribute10                => l_attribute10,
      p_attribute11                => l_attribute11,
      p_attribute12                => l_attribute12,
      p_attribute13                => l_attribute13,
      p_attribute14                => l_attribute14,
      p_attribute15                => l_attribute15,
      p_print_text_yn              => l_print_text_yn,
      p_summary_amend_operation_code => l_summary_amend_operation_code,
      p_ref_article_id              => l_ref_article_id,
      p_ref_article_version_id      => l_ref_article_version_id,
      p_mandatory_rwa               => l_mandatory_rwa
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5500: Filling WHO columns', 2);
    END IF;

    -- Filling who columns
    l_last_update_date := SYSDATE;
    l_last_updated_by := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    -- Object version increment
    IF Nvl(l_object_version_number, 0) >= 0 THEN
      l_object_version_number := Nvl(l_object_version_number, 0) + 1;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5600: Updating Row', 2);
    END IF;

    --------------------------------------------
    -- Call the Update_Row for each child record
    --------------------------------------------
    x_return_status := Update_Row(
      p_id                         => p_id,
      p_sav_sae_id                 => l_sav_sae_id,
      p_document_type              => l_document_type,
      p_document_id                => l_document_id,
      p_cle_id                     => l_cle_id,
      p_source_flag                => l_source_flag,
      p_mandatory_yn               => l_mandatory_yn,
      p_mandatory_rwa              => l_mandatory_rwa,
      p_scn_id                     => l_scn_id,
      p_label                      => l_label,
      p_amendment_description      => l_amendment_description,
      p_amendment_operation_code   => l_amendment_operation_code,
      p_article_version_id         => l_article_version_id,
      p_change_nonstd_yn           => l_change_nonstd_yn,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_display_sequence           => l_display_sequence,
      p_attribute_category         => l_attribute_category,
      p_attribute1                 => l_attribute1,
      p_attribute2                 => l_attribute2,
      p_attribute3                 => l_attribute3,
      p_attribute4                 => l_attribute4,
      p_attribute5                 => l_attribute5,
      p_attribute6                 => l_attribute6,
      p_attribute7                 => l_attribute7,
      p_attribute8                 => l_attribute8,
      p_attribute9                 => l_attribute9,
      p_attribute10                => l_attribute10,
      p_attribute11                => l_attribute11,
      p_attribute12                => l_attribute12,
      p_attribute13                => l_attribute13,
      p_attribute14                => l_attribute14,
      p_attribute15                => l_attribute15,
      p_print_text_yn              => l_print_text_yn,
      p_summary_amend_operation_code => l_summary_amend_operation_code,
      p_ref_article_id              => l_ref_article_id,
      p_ref_article_version_id      => l_ref_article_version_id,
      p_object_version_number      => l_object_version_number,
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date,
      p_last_amended_by            => l_last_amended_by,
      p_last_amendment_date        => l_last_amendment_date
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('5700: Leaving Update_Row', 2);
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('5800: Leaving Update_Row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_ERROR;
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('5900: Leaving Update_Row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('6000: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Update_Row;

  ---------------------------------------------------------------------------
  -- PROCEDURE Delete_Row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- Delete_Row for:OKC_K_ARTICLES_B --
  -------------------------------------
  FUNCTION Delete_Row(
    p_id                         IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6100: Entered Delete_Row', 2);
    END IF;

    DELETE FROM OKC_K_ARTICLES_B WHERE ID = p_ID;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6200: Leaving Delete_Row', 2);
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6300: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );

  END Delete_Row;
  -------------------------------------
  -- Delete_Row for:OKC_K_ARTICLES_B --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
  ) IS

  l_standard_yn VARCHAR2(1) := 'Y';
  l_article_id NUMBER;
  l_article_version_id NUMBER;
  l_non_std_exists VARCHAR2(1) := 'N';
  l_return_status VARCHAR2(30);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  CURSOR l_art_csr (cp_id IN NUMBER) IS
    SELECT art.standard_yn,
           kart.sav_sae_id,
           kart.article_version_id
    FROM okc_k_articles_b kart,
         okc_articles_all art
    WHERE kart.id = cp_id
    AND art.article_id = kart.sav_sae_id;

  CURSOR l_non_std_exists_csr(cp_article_version_id IN NUMBER) IS
    SELECT 'Y'
    FROM okc_k_articles_b
    WHERE article_version_id = cp_article_version_id
    UNION ALL
    SELECT 'Y'
    FROM OKC_K_ARTICLES_BH
    WHERE article_version_id = cp_article_version_id;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Delete_Row', 2);
    END IF;

    OPEN l_art_csr(p_id);
    FETCH l_art_csr INTO l_standard_yn,l_article_id,l_article_version_id;
    CLOSE l_art_csr;

    x_return_status := Lock_row(
      p_id                         => p_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := Delete_Row( p_id => p_id );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_standard_yn = 'N' THEN
      OPEN l_non_std_exists_csr(l_article_version_id);
      FETCH l_non_std_exists_csr INTO l_non_std_exists;
      IF l_non_std_exists_csr%NOTFOUND THEN
        OKC_ARTICLES_GRP.delete_article(
                         p_api_version          => 1,
                         p_init_msg_list        => FND_API.G_FALSE,

                         x_return_status        => l_return_status,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_msg_data,

                         p_article_id           => l_article_id,
                         p_article_version_id   => l_article_version_id);


      END IF;
      CLOSE l_non_std_exists_csr;

      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6500: Leaving Delete_Row', 2);
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6600: Leaving Delete_Row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6700: Leaving Delete_Row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6800: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Row;

PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_scn_id                 IN NUMBER
) IS
  CURSOR lock_csr IS
    SELECT rowid
    FROM OKC_K_ARTICLES_B
    WHERE SCN_ID=P_SCN_ID
    FOR UPDATE NOWAIT;
BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered Delete_Set', 2);
       Okc_Debug.Log('9710: Locking Record', 2);
    END IF;
    -- making OPEN/CLOSE cursor to lock records
    OPEN lock_csr;
    CLOSE lock_csr;

    DELETE FROM OKC_K_ARTICLES_B
    WHERE SCN_ID=P_SCN_ID;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('11000: Leaving Delete_set', 2);
    END IF;

  EXCEPTION
    WHEN E_Resource_Busy THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('000: Leaving Delete_set:E_Resource_Busy Exception', 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11100: Leaving Delete_Set:FND_API.G_EXC_ERROR Exception', 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

END delete_set;

PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_doc_type               IN VARCHAR2,
    p_doc_id                 IN NUMBER
    ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
) IS
    CURSOR lock_csr IS
    SELECT rowid
    FROM OKC_K_ARTICLES_B
    WHERE DOCUMENT_TYPE=p_doc_type
    AND DOCUMENT_ID = p_doc_id
    AND (( p_retain_lock_terms_yn = 'N')
           OR
          (p_retain_lock_terms_yn ='Y' AND amendment_operation_code IS NULL)
         )
    FOR UPDATE NOWAIT;

BEGIN
 IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered Delete_Set', 2);
       Okc_Debug.Log('9710: Locking Records', 2);
    END IF;


  -- making OPEN/CLOSE cursor to lock records
    OPEN lock_csr;
    CLOSE lock_csr;

    DELETE FROM OKC_K_ARTICLES_B
    WHERE DOCUMENT_TYPE=p_doc_type
    AND DOCUMENT_ID = p_doc_id
    AND (( p_retain_lock_terms_yn = 'N')
           OR
          (p_retain_lock_terms_yn ='Y' AND amendment_operation_code IS NULL)
         );


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('11000: Leaving Delete_set', 2);
    END IF;

  EXCEPTION
      WHEN E_Resource_Busy THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('000: Leaving Delete_set:E_Resource_Busy Exception', 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11100: Leaving Delete_Set:FND_API.G_EXC_ERROR Exception', 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

END delete_set;

--This function is to be called from versioning API OKC_VERSION_PVT
-- Location: Base Table API
  FUNCTION Create_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS

  l_article_version_id OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE;
  l_article_id  OKC_ARTICLES_ALL.ARTICLE_ID%TYPE;
  l_article_number OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(4000);

  CURSOR non_std_csr IS
    SELECT KART.ID,
        KART.SAV_SAE_ID,
        KART.ARTICLE_VERSION_ID
      FROM OKC_K_ARTICLES_B KART,
           OKC_ARTICLES_ALL ART
      WHERE KART.document_type = p_doc_type
      AND   KART.document_id = p_doc_id
      AND   KART.SAV_SAE_ID = ART.ARTICLE_ID
      AND   ART.STANDARD_YN = 'N';

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6900: Entered create_version', 2);
    END IF;

    -----------------------------------------
    -- Saving Base Table
    -----------------------------------------
    INSERT INTO OKC_K_ARTICLES_BH (
        major_version,
        ID,
        SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        CAT_TYPE,
        CHR_ID,
        CAT_ID,
        DNZ_CHR_ID,
        FULLTEXT_YN,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        CLE_ID,
        SOURCE_FLAG,
        MANDATORY_YN,
        SCN_ID,
        LABEL,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ARTICLE_VERSION_ID,
        CHANGE_NONSTD_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        DISPLAY_SEQUENCE,
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
        PRINT_TEXT_YN,
        SUMMARY_AMEND_OPERATION_CODE,
        REF_ARTICLE_ID,
        REF_ARTICLE_VERSION_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        ORIG_ARTICLE_ID,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE,
        MANDATORY_RWA)
     SELECT
        p_major_version,
        ID,
        SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        CAT_TYPE,
        CHR_ID,
        CAT_ID,
        DNZ_CHR_ID,
        FULLTEXT_YN,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        CLE_ID,
        SOURCE_FLAG,
        MANDATORY_YN,
        SCN_ID,
        LABEL,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ARTICLE_VERSION_ID,
        CHANGE_NONSTD_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        DISPLAY_SEQUENCE,
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
        PRINT_TEXT_YN,
        SUMMARY_AMEND_OPERATION_CODE,
        REF_ARTICLE_ID,
        REF_ARTICLE_VERSION_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        ORIG_ARTICLE_ID,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE,
        MANDATORY_RWA
      FROM OKC_K_ARTICLES_B
      WHERE document_type = p_doc_type
      AND   document_id = p_doc_id;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6910: Before Opening Non_std_csr', 2);
    END IF;

    FOR rec in non_std_csr LOOP

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6920: Before calling OKC_ARTICLES_GRP.copy_article()', 2);
      END IF;
      OKC_ARTICLES_GRP.copy_article( p_api_version        => 1,
                                       p_init_msg_list      => FND_API.G_FALSE,
                                       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                                       p_commit             => FND_API.G_FALSE,
                                       p_article_version_id => rec.article_version_id,
                                       p_new_article_title  => NULL,
                                       p_create_standard_yn => 'N',
                                       x_article_version_id => l_article_version_id,
                                       x_article_id         => l_article_id,
                                       x_article_number     => l_article_number,
                                       x_return_status      => l_return_status,
                                       x_msg_count          => l_msg_count,
                                       x_msg_data           => l_msg_data);

      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6920: Before updating new Non-Std in the OKC_K_ARTICLES_B', 2);
      END IF;


      -----------------------------------------
      -- Updating OKC_K_ARTICLES_B
      -----------------------------------------
      UPDATE OKC_K_ARTICLES_B
      SET  SAV_SAE_ID = l_article_id,
        ARTICLE_VERSION_ID = l_article_version_id
      WHERE ID = rec.id;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6930: After Updating Non-Std in OKC_K_ARTICLES_B', 2);
      END IF;

    END LOOP;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Leaving create_version', 2);
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('7100: Leaving Create_Version:FND_API.G_EXC_ERROR Exception', 2);
      END IF;

      IF (non_std_csr%ISOPEN) THEN
        CLOSE non_std_csr;
      END IF;
      RETURN G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('7200: Leaving Create_Version:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;

      IF (non_std_csr%ISOPEN) THEN
        CLOSE non_std_csr;
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Leaving create_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF (non_std_csr%ISOPEN) THEN
        CLOSE non_std_csr;
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
-- Location:Base Table API

  FUNCTION Restore_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7200: Entered restore_version', 2);
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    INSERT INTO OKC_K_ARTICLES_B (
        ID,
        SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        CAT_TYPE,
        CHR_ID,
        CLE_ID,
        CAT_ID,
        DNZ_CHR_ID,
        FULLTEXT_YN,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        SOURCE_FLAG,
        MANDATORY_YN,
        SCN_ID,
        LABEL,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ARTICLE_VERSION_ID,
        CHANGE_NONSTD_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        DISPLAY_SEQUENCE,
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
        PRINT_TEXT_YN,
        SUMMARY_AMEND_OPERATION_CODE,
        REF_ARTICLE_ID,
        REF_ARTICLE_VERSION_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        ORIG_ARTICLE_ID,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE,
         MANDATORY_RWA)
     SELECT
        ID,
        SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        CAT_TYPE,
        CHR_ID,
        CLE_ID,
        CAT_ID,
        DNZ_CHR_ID,
        FULLTEXT_YN,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        SOURCE_FLAG,
        MANDATORY_YN,
        SCN_ID,
        LABEL,
        AMENDMENT_DESCRIPTION,
        AMENDMENT_OPERATION_CODE,
        ARTICLE_VERSION_ID,
        CHANGE_NONSTD_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        DISPLAY_SEQUENCE,
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
        PRINT_TEXT_YN,
        SUMMARY_AMEND_OPERATION_CODE,
        REF_ARTICLE_ID,
        REF_ARTICLE_VERSION_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        ORIG_ARTICLE_ID,
        LAST_AMENDED_BY,
        LAST_AMENDMENT_DATE,
        MANDATORY_RWA
      FROM OKC_K_ARTICLES_BH
      WHERE document_type = p_doc_type
      AND document_id = p_doc_id
      AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Leaving restore_version', 2);
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Leaving restore_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END restore_version;

--This Function is called from Versioning API OKC_VERSION_PVT
-- to delete articles for specified version of document

  FUNCTION Delete_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7200: Entered Delete_Version', 2);
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    DELETE
      FROM OKC_K_ARTICLES_BH
      WHERE document_type = p_doc_type
      AND document_id = p_doc_id
      AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Leaving Delete_Version', 2);
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Leaving Delete_Version because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Delete_Version;

END OKC_K_ARTICLES_PVT;

/

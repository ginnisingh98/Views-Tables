--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLE_VERSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLE_VERSIONS_PVT" AS
/* $Header: OKCVAVNB.pls 120.5.12010000.13 2013/08/29 06:26:27 serukull ship $ */

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
  ---------------------------------------------------------------------------
  -- VALIDATION LEVELS
  ---------------------------------------------------------------------------
  G_REQUIRED_VALUE_VALID_LEVEL CONSTANT NUMBER := OKC_API.G_REQUIRED_VALUE_VALID_LEVEL;
  G_VALID_VALUE_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_VALID_VALUE_VALID_LEVEL;
  G_LOOKUP_CODE_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_LOOKUP_CODE_VALID_LEVEL;
  G_FOREIGN_KEY_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_FOREIGN_KEY_VALID_LEVEL;
  G_RECORD_VALID_LEVEL         CONSTANT NUMBER := OKC_API.G_RECORD_VALID_LEVEL;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ARTICLE_VERSIONS_PVT';
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
-- MOAC
--  G_CURRENT_ORG_ID             NUMBER := -99;
  G_CURRENT_ORG_ID             NUMBER ;

  G_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
-- MOAC
-- One Time fetch the current Org.
/*
  CURSOR CUR_ORG_CSR IS
        SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                                                   SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
        FROM DUAL;
*/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION Get_Seq_Id (
    p_article_version_id         IN NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_seq_csr IS
     SELECT OKC_ARTICLE_VERSIONS_S1.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF( p_article_version_id         IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_article_version_id        ;
      IF l_seq_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE l_seq_csr;
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

      IF l_seq_csr%ISOPEN THEN
        CLOSE l_seq_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Seq_Id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ARTICLE_VERSIONS
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_article_version_id         IN NUMBER,

    x_article_id                 OUT NOCOPY NUMBER,
    x_article_version_number     OUT NOCOPY NUMBER,
    x_article_text               OUT NOCOPY CLOB,
    x_provision_yn               OUT NOCOPY VARCHAR2,
    x_insert_by_reference        OUT NOCOPY VARCHAR2,
    x_lock_text                  OUT NOCOPY VARCHAR2,
    x_global_yn                  OUT NOCOPY VARCHAR2,
    x_article_language           OUT NOCOPY VARCHAR2,
    x_article_status             OUT NOCOPY VARCHAR2,
    x_sav_release                OUT NOCOPY VARCHAR2,
    x_start_date                 OUT NOCOPY DATE,
    x_end_date                   OUT NOCOPY DATE,
    x_std_article_version_id     OUT NOCOPY NUMBER,
    x_display_name               OUT NOCOPY VARCHAR2,
    x_translated_yn              OUT NOCOPY VARCHAR2,
    x_article_description        OUT NOCOPY VARCHAR2,
    x_date_approved              OUT NOCOPY DATE,
    x_default_section            OUT NOCOPY VARCHAR2,
    x_reference_source           OUT NOCOPY VARCHAR2,
    x_reference_text           OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id2  OUT NOCOPY VARCHAR2,
    x_additional_instructions    OUT NOCOPY VARCHAR2,
    x_variation_description      OUT NOCOPY VARCHAR2,
    x_date_published             OUT NOCOPY DATE,
    x_program_id                 OUT NOCOPY NUMBER,
    x_program_login_id           OUT NOCOPY NUMBER,
    x_program_application_id     OUT NOCOPY NUMBER,
    x_request_id                 OUT NOCOPY NUMBER,
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
    x_object_version_number      OUT NOCOPY NUMBER,
    x_edited_in_word             OUT NOCOPY VARCHAR2,
 	  x_article_text_in_word       OUT NOCOPY BLOB,
    x_created_by                 OUT NOCOPY NUMBER,
    x_creation_date              OUT NOCOPY DATE,
    x_last_updated_by            OUT NOCOPY NUMBER,
    x_last_update_login          OUT NOCOPY NUMBER,
    x_last_update_date           OUT NOCOPY DATE,
    x_variable_code              OUT NOCOPY VARCHAR2        --CLM

  ) RETURN VARCHAR2 IS
    CURSOR OKC_ARTICLE_VERSIONS_pk_csr (cp_article_version_id IN NUMBER) IS
    SELECT
            ARTICLE_ID,
            ARTICLE_VERSION_NUMBER,
            ARTICLE_TEXT,
            PROVISION_YN,
            INSERT_BY_REFERENCE,
            LOCK_TEXT,
            GLOBAL_YN,
            ARTICLE_LANGUAGE,
            ARTICLE_STATUS,
            SAV_RELEASE,
            START_DATE,
            END_DATE,
            STD_ARTICLE_VERSION_ID,
            DISPLAY_NAME,
            TRANSLATED_YN,
            ARTICLE_DESCRIPTION,
            DATE_APPROVED,
            DEFAULT_SECTION,
            REFERENCE_SOURCE,
            REFERENCE_TEXT,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2,
            ADDITIONAL_INSTRUCTIONS,
            VARIATION_DESCRIPTION,
		  DATE_PUBLISHED,
            PROGRAM_ID,
            PROGRAM_LOGIN_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
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
            OBJECT_VERSION_NUMBER,
	          EDITED_IN_WORD,
 	          ARTICLE_TEXT_IN_WORD,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            VARIABLE_CODE
      FROM OKC_ARTICLE_VERSIONS t
     WHERE t.ARTICLE_VERSION_ID = cp_article_version_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    -- Get current database values
    OPEN OKC_ARTICLE_VERSIONS_pk_csr (p_article_version_id);
    FETCH OKC_ARTICLE_VERSIONS_pk_csr INTO
            x_article_id,
            x_article_version_number,
            x_article_text,
            x_provision_yn,
            x_insert_by_reference,
            x_lock_text,
            x_global_yn,
            x_article_language,
            x_article_status,
            x_sav_release,
            x_start_date,
            x_end_date,
            x_std_article_version_id,
            x_display_name,
            x_translated_yn,
            x_article_description,
            x_date_approved,
            x_default_section,
            x_reference_source,
            x_reference_text,
            x_orig_system_reference_code,
            x_orig_system_reference_id1,
            x_orig_system_reference_id2,
            x_additional_instructions,
            x_variation_description,
		  x_date_published,
            x_program_id,
            x_program_login_id,
            x_program_application_id,
            x_request_id,
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
            x_object_version_number,
	          x_edited_in_word,
 	          x_article_text_in_word,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,
            x_variable_code;
    IF OKC_ARTICLE_VERSIONS_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_ARTICLE_VERSIONS_pk_csr;

   IF (l_debug = 'Y') THEN
      Okc_Debug.Log('500: Leaving  get_rec ', 2);
   END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
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

      IF OKC_ARTICLE_VERSIONS_pk_csr%ISOPEN THEN
        CLOSE OKC_ARTICLE_VERSIONS_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_ARTICLE_VERSIONS --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_program_id                 IN NUMBER,
    p_program_login_id           IN NUMBER,
    p_program_application_id     IN NUMBER,
    p_request_id                 IN NUMBER,
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
    p_object_version_number      IN NUMBER,
	  p_edited_in_word             IN VARCHAR2,
 	  p_article_text_in_word       IN BLOB,
    p_variable_code              IN VARCHAR2,         --clm

    x_article_id                 OUT NOCOPY NUMBER,
    x_article_version_number     OUT NOCOPY NUMBER,
    x_article_text               OUT NOCOPY CLOB,
    x_provision_yn               OUT NOCOPY VARCHAR2,
    x_insert_by_reference        OUT NOCOPY VARCHAR2,
    x_lock_text                  OUT NOCOPY VARCHAR2,
    x_global_yn                  OUT NOCOPY VARCHAR2,
    x_article_language           OUT NOCOPY VARCHAR2,
    x_article_status             OUT NOCOPY VARCHAR2,
    x_sav_release                OUT NOCOPY VARCHAR2,
    x_start_date                 OUT NOCOPY DATE,
    x_end_date                   OUT NOCOPY DATE,
    x_std_article_version_id     OUT NOCOPY NUMBER,
    x_display_name               OUT NOCOPY VARCHAR2,
    x_translated_yn              OUT NOCOPY VARCHAR2,
    x_article_description        OUT NOCOPY VARCHAR2,
    x_date_approved              OUT NOCOPY DATE,
    x_default_section            OUT NOCOPY VARCHAR2,
    x_reference_source           OUT NOCOPY VARCHAR2,
    x_reference_text           OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id2  OUT NOCOPY VARCHAR2,
    x_additional_instructions    OUT NOCOPY VARCHAR2,
    x_variation_description      OUT NOCOPY VARCHAR2,
    x_date_published             OUT NOCOPY DATE,
    x_program_id                 OUT NOCOPY NUMBER,
    x_program_login_id           OUT NOCOPY NUMBER,
    x_program_application_id     OUT NOCOPY NUMBER,
    x_request_id                 OUT NOCOPY NUMBER,
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
    x_edited_in_word             OUT NOCOPY VARCHAR2,
 	  x_article_text_in_word       OUT NOCOPY BLOB,
    x_variable_code              OUT NOCOPY VARCHAR2                 --clm
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number      OKC_ARTICLE_VERSIONS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_ARTICLE_VERSIONS.CREATED_BY%TYPE;
    l_creation_date              OKC_ARTICLE_VERSIONS.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_ARTICLE_VERSIONS.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_ARTICLE_VERSIONS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_ARTICLE_VERSIONS.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;

    IF( p_article_version_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_article_version_id         => p_article_version_id,
        x_article_id                 => x_article_id,
        x_article_version_number     => x_article_version_number,
        x_article_text               => x_article_text,
        x_provision_yn               => x_provision_yn,
        x_insert_by_reference        => x_insert_by_reference,
        x_lock_text                  => x_lock_text,
        x_global_yn                  => x_global_yn,
        x_article_language           => x_article_language,
        x_article_status             => x_article_status,
        x_sav_release                => x_sav_release,
        x_start_date                 => x_start_date,
        x_end_date                   => x_end_date,
        x_std_article_version_id     => x_std_article_version_id,
        x_display_name               => x_display_name,
        x_translated_yn              => x_translated_yn,
        x_article_description        => x_article_description,
        x_date_approved              => x_date_approved,
        x_default_section            => x_default_section,
        x_reference_source           => x_reference_source,
        x_reference_text           => x_reference_text,
        x_orig_system_reference_code => x_orig_system_reference_code,
        x_orig_system_reference_id1  => x_orig_system_reference_id1,
        x_orig_system_reference_id2  => x_orig_system_reference_id2,
        x_additional_instructions    => x_additional_instructions,
        x_variation_description      => x_variation_description,
        x_date_published             => x_date_published,
        x_program_id                 => x_program_id,
        x_program_login_id           => x_program_login_id,
        x_program_application_id     => x_program_application_id,
        x_request_id                 => x_request_id,
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
        x_object_version_number      => l_object_version_number,
	      x_edited_in_word             => x_edited_in_word,
 	      x_article_text_in_word       => x_article_text_in_word,
        x_created_by                 => l_created_by,
        x_creation_date              => l_creation_date,
        x_last_updated_by            => l_last_updated_by,
        x_last_update_login          => l_last_update_login,
        x_last_update_date           => l_last_update_date,
        x_variable_code              => x_variable_code                --clm
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_article_id = G_MISS_NUM) THEN
        x_article_id := NULL;
       ELSIF (p_ARTICLE_ID IS NOT NULL) THEN
        x_article_id := p_article_id;
      END IF;

      IF (p_article_version_number = G_MISS_NUM) THEN
        x_article_version_number := NULL;
       ELSIF (P_ARTICLE_VERSION_NUMBER IS NOT NULL) THEN
        x_article_version_number := p_article_version_number;
      END IF;

      IF dbms_lob.getlength(p_article_text) = length(G_MISS_CHAR)  THEN
        IF (dbms_lob.substr(p_article_text,dbms_lob.getlength(p_article_text)) = G_MISS_CHAR) THEN
          x_article_text := NULL;
	   END IF;
      ELSIF (p_ARTICLE_TEXT IS NOT NULL) THEN
        x_article_text := p_article_text;
      END IF;

      IF (p_provision_yn = G_MISS_CHAR) THEN
        x_provision_yn := NULL;
       ELSIF (p_PROVISION_YN IS NOT NULL) THEN
       -- x_provision_yn := p_provision_yn; -- Modified
        x_provision_yn := UPPER(p_provision_yn);
      END IF;

      IF (p_insert_by_reference = G_MISS_CHAR) THEN
        x_insert_by_reference := NULL;
       ELSIF (p_INSERT_BY_REFERENCE IS NOT NULL) THEN
       -- x_insert_by_reference := p_insert_by_reference; -- Modified
        x_insert_by_reference := UPPER(p_insert_by_reference);
      END IF;

      IF (p_lock_text = G_MISS_CHAR) THEN
        x_lock_text := NULL;
       ELSIF (p_LOCK_TEXT IS NOT NULL) THEN
       -- x_lock_text := p_lock_text; -- Modified
        x_lock_text := UPPER(p_lock_text);
      END IF;

      IF (p_global_yn = G_MISS_CHAR) THEN
        x_global_yn := NULL;
       ELSIF (p_GLOBAL_YN IS NOT NULL) THEN
       -- x_global_yn := p_global_yn; -- Modified
        x_global_yn := UPPER(p_global_yn);
      END IF;

      IF (p_article_language = G_MISS_CHAR) THEN
        x_article_language := NULL;
       ELSIF (p_ARTICLE_LANGUAGE IS NOT NULL) THEN
        x_article_language := p_article_language;
      END IF;

      IF (p_article_status = G_MISS_CHAR) THEN
        x_article_status := NULL;
       ELSIF (p_ARTICLE_STATUS IS NOT NULL) THEN
        x_article_status := p_article_status;
      END IF;

      IF (p_sav_release = G_MISS_CHAR) THEN
        x_sav_release := NULL;
       ELSIF (p_SAV_RELEASE IS NOT NULL) THEN
        x_sav_release := p_sav_release;
      END IF;

      IF (p_start_date = G_MISS_DATE) THEN
        x_start_date := NULL;
       ELSIF (p_START_DATE IS NOT NULL) THEN
        x_start_date := p_start_date;
      END IF;

      IF (p_end_date = G_MISS_DATE) THEN
        x_end_date := NULL;
       ELSIF (p_END_DATE IS NOT NULL) THEN
        x_end_date := p_end_date;
      END IF;

      IF (p_std_article_version_id = G_MISS_NUM) THEN
        x_std_article_version_id := NULL;
       ELSIF (p_STD_ARTICLE_VERSION_ID IS NOT NULL) THEN
        x_std_article_version_id := p_std_article_version_id;
      END IF;

      IF (p_display_name = G_MISS_CHAR) THEN
        x_display_name := NULL;
       ELSIF (p_DISPLAY_NAME IS NOT NULL) THEN
        x_display_name := p_display_name;
      END IF;

      IF (p_translated_yn = G_MISS_CHAR) THEN
        x_translated_yn := NULL;
       ELSIF (p_TRANSLATED_YN IS NOT NULL) THEN
       -- x_translated_yn := p_translated_yn; -- Modified
        x_translated_yn := UPPER(p_translated_yn);
      END IF;

      IF (p_article_description = G_MISS_CHAR) THEN
        x_article_description := NULL;
       ELSIF (p_ARTICLE_DESCRIPTION IS NOT NULL) THEN
        x_article_description := p_article_description;
      END IF;

      IF (p_date_approved = G_MISS_DATE) THEN
        x_date_approved := NULL;
       ELSIF (p_DATE_APPROVED IS NOT NULL) THEN
        x_date_approved := p_date_approved;
      END IF;

      IF (p_default_section = G_MISS_CHAR) THEN
        x_default_section := NULL;
       ELSIF (p_DEFAULT_SECTION IS NOT NULL) THEN
        x_default_section := p_default_section;
      END IF;

      IF (p_reference_source = G_MISS_CHAR) THEN
        x_reference_source := NULL;
       ELSIF (p_REFERENCE_SOURCE IS NOT NULL) THEN
        x_reference_source := p_reference_source;
      END IF;

      IF (p_reference_text = G_MISS_CHAR) THEN
        x_reference_text := NULL;
       ELSIF (p_REFERENCE_TEXT IS NOT NULL) THEN
        x_reference_text := p_reference_text;
      END IF;

      IF (p_orig_system_reference_code = G_MISS_CHAR) THEN
        x_orig_system_reference_code := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_CODE IS NOT NULL) THEN
        x_orig_system_reference_code := p_orig_system_reference_code;
      END IF;

      IF (p_orig_system_reference_id1 = G_MISS_CHAR) THEN
        x_orig_system_reference_id1 := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_ID1 IS NOT NULL) THEN
        x_orig_system_reference_id1 := p_orig_system_reference_id1;
      END IF;

      IF (p_orig_system_reference_id2 = G_MISS_CHAR) THEN
        x_orig_system_reference_id2 := NULL;
       ELSIF (p_ORIG_SYSTEM_REFERENCE_ID2 IS NOT NULL) THEN
        x_orig_system_reference_id2 := p_orig_system_reference_id2;
      END IF;

      IF (p_additional_instructions = G_MISS_CHAR) THEN
        x_additional_instructions := NULL;
       ELSIF (p_ADDITIONAL_INSTRUCTIONS IS NOT NULL) THEN
        x_additional_instructions := p_additional_instructions;
      END IF;

      IF (p_variation_description = G_MISS_CHAR) THEN
        x_variation_description := NULL;
       ELSIF (p_VARIATION_DESCRIPTION IS NOT NULL) THEN
        x_variation_description := p_variation_description;
      END IF;

      IF (p_date_published = G_MISS_DATE) THEN
        x_date_published := NULL;
       ELSIF (p_DATE_PUBLISHED IS NOT NULL) THEN
        x_date_published := p_date_published;
      END IF;

      IF (p_program_id = G_MISS_NUM) THEN
        x_program_id := NULL;
       ELSIF (p_PROGRAM_ID IS NOT NULL) THEN
        x_program_id := p_program_id;
      END IF;

      IF (p_program_login_id = G_MISS_NUM) THEN
        x_program_login_id := NULL;
       ELSIF (p_PROGRAM_LOGIN_ID IS NOT NULL) THEN
        x_program_login_id := p_program_login_id;
      END IF;

      IF (p_program_application_id = G_MISS_NUM) THEN
        x_program_application_id := NULL;
       ELSIF (p_PROGRAM_APPLICATION_ID IS NOT NULL) THEN
        x_program_application_id := p_program_application_id;
      END IF;

      IF (p_request_id = G_MISS_NUM) THEN
        x_request_id := NULL;
       ELSIF (p_REQUEST_ID IS NOT NULL) THEN
        x_request_id := p_request_id;
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

      IF (p_edited_in_word = G_MISS_CHAR) THEN
        x_edited_in_word := NULL;
       ELSIF (p_edited_in_word IS NOT NULL) THEN
        x_edited_in_word := UPPER(p_edited_in_word);
      END IF;

      IF dbms_lob.getlength(p_article_text_in_word) = length(G_MISS_CHAR)  THEN
        IF (dbms_lob.substr(p_article_text_in_word,dbms_lob.getlength(p_article_text_in_word)) = G_MISS_CHAR) THEN
          x_article_text_in_word := NULL;
        END IF;
      ELSIF (p_article_text_in_word IS NOT NULL) THEN
        x_article_text_in_word := p_article_text_in_word;
      END IF;

      --CLM
      IF (p_variable_code = G_MISS_CHAR) THEN
        x_variable_code := NULL;
       ELSIF (p_variable_code IS NOT NULL) THEN
        x_variable_code := UPPER(p_variable_code);
      END IF;

    ELSE
        x_article_id                 := p_article_id;
        x_article_version_number     := p_article_version_number;
        x_article_text               := p_article_text;
        x_provision_yn               := p_provision_yn;
        x_insert_by_reference        := p_insert_by_reference;
        x_lock_text                  := p_lock_text;
        x_global_yn                  := p_global_yn;
        x_article_language           := p_article_language;
        x_article_status             := p_article_status;
        x_sav_release                := p_sav_release;
        x_start_date                 := p_start_date;
        x_end_date                   := p_end_date;
        x_std_article_version_id     := p_std_article_version_id;
        x_display_name               := p_display_name;
        x_translated_yn              := p_translated_yn;
        x_article_description        := p_article_description;
        x_date_approved              := p_date_approved;
        x_default_section            := p_default_section;
        x_reference_source           := p_reference_source;
        x_reference_text           := p_reference_text;
        x_orig_system_reference_code := p_orig_system_reference_code;
        x_orig_system_reference_id1  := p_orig_system_reference_id1;
        x_orig_system_reference_id2  := p_orig_system_reference_id2;
        x_additional_instructions    := p_additional_instructions;
        x_variation_description      := p_variation_description;
        x_date_published             := p_date_published;
        x_program_id                 := p_program_id;
        x_program_login_id           := p_program_login_id;
        x_program_application_id     := p_program_application_id;
        x_request_id                 := p_request_id;
        x_attribute_category         := p_attribute_category;
        x_attribute1                 := p_attribute1;
        x_attribute2                 := p_attribute2;
        x_attribute3                 := p_attribute3;
        x_attribute4                 := p_attribute4;
        x_attribute5                 := p_attribute5;
        x_attribute6                 := p_attribute6;
        x_attribute7                 := p_attribute7;
        x_attribute8                 := p_attribute8;
        x_attribute9                 := p_attribute9;
        x_attribute10                := p_attribute10;
        x_attribute11                := p_attribute11;
        x_attribute12                := p_attribute12;
        x_attribute13                := p_attribute13;
        x_attribute14                := p_attribute14;
        x_attribute15                := p_attribute15;
	      x_edited_in_word             := p_edited_in_word;
 	      x_article_text_in_word       := p_article_text_in_word;
        x_variable_code              := p_variable_code;                --clm

    END IF;

    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('800: Leaving  Set_Attributes ', 2);
    END IF;

    RETURN G_RET_STS_SUCCESS ;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception', 2);
      END IF;
      RETURN G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      RETURN G_RET_STS_UNEXP_ERROR;

  END Set_Attributes ;

  ----------------------------------------------
  -- Validate_Attributes for: OKC_ARTICLE_VERSIONS --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,
    p_standard_yn                 IN VARCHAR2,

    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_program_id                 IN NUMBER,
    p_program_login_id           IN NUMBER,
    p_program_application_id     IN NUMBER,
    p_request_id                 IN NUMBER,
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
	  p_edited_in_word             IN VARCHAR2,
 	  p_article_text_in_word       IN BLOB,
    p_variable_code              IN VARCHAR2              --clm
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_tmp_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
    l_dummy_date    OKC_ARTICLE_VERSIONS.DATE_PUBLISHED%TYPE;
    l_art_XML                XMLType;


    CURSOR l_article_language_csr(p_article_id IN NUMBER, p_article_language IN VARCHAR2) is
     SELECT '!'
      FROM OKC_ARTICLES_ALL
      WHERE ARTICLE_LANGUAGE = p_article_language
        AND ARTICLE_ID = p_article_id;

    CURSOR l_std_article_version_id_csr is
     SELECT '!'
      FROM OKC_ARTICLES_ALL AA,OKC_ARTICLE_VERSIONS AV
      WHERE AA.ARTICLE_ID = AV.ARTICLE_ID
      AND   AV.ARTICLE_VERSION_ID = p_std_article_version_id
      AND   AA.STANDARD_YN = 'Y';

    -- Below Added for FAR/DFAR Import
    CURSOR l_date_published_csr is
     SELECT av.date_published
      FROM OKC_ARTICLE_VERSIONS AV
      WHERE AV.ARTICLE_VERSION_ID = p_article_version_id;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;

-- Article row will always be needed to test if this is a standard or not even for not null or FK checks

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_ID ', 2);
      END IF;
      IF nvl(p_import_Action,'*') <> 'N' Then -- bypass this check for validation of new article being imported
        IF ( p_article_id IS NULL) THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('1500: - attribute ARTICLE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

-- As of now validation of article version number is not needed as it is generated by the API.
/*
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_VERSION_NUMBER ', 2);
      END IF;
      IF ( p_article_version_number IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ARTICLE_VERSION_NUMBER is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_VERSION_NUMBER');
        l_return_status := G_RET_STS_ERROR;
      END IF;
*/

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_TEXT ', 2);
      END IF;
      IF ( p_article_text IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ARTICLE_TEXT is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, 'OKC_ARTICLE_TEXT_REQD');
        --Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_TEXT');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute PROVISION_YN ', 2);
      END IF;
      IF ( p_provision_yn IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute PROVISION_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PROVISION_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute INSERT_BY_REFERENCE ', 2);
      END IF;
      IF ( p_insert_by_reference IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute INSERT_BY_REFERENCE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'INSERT_BY_REFERENCE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute LOCK_TEXT ', 2);
      END IF;
      IF ( p_lock_text IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute LOCK_TEXT is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LOCK_TEXT');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute GLOBAL_YN ', 2);
      END IF;
      IF ( p_global_yn IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute GLOBAL_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'GLOBAL_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_LANGUAGE ', 2);
      END IF;
      IF ( p_article_language IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ARTICLE_LANGUAGE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_LANGUAGE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF p_standard_yn = 'Y' OR p_import_action IS NOT NULL Then
         IF (l_debug = 'Y') THEN
           Okc_Debug.Log('1400: - attribute START_DATE ', 2);
         END IF;
         IF ( p_start_date IS NULL) THEN
           IF (l_debug = 'Y') THEN
             Okc_Debug.Log('1500: - attribute START_DATE is invalid', 2);
           END IF;
           Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'START_DATE');
           l_return_status := G_RET_STS_ERROR;
         END IF;
      END IF;

  /*   IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1400: - attribute EDITED_IN_WORD ', 2);
     END IF;
     IF ( p_edited_in_word IS NULL) THEN
       IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1500: - attribute EDITED_IN_WORD is invalid', 2);
       END IF;
       Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'EDITED_IN_WORD');
       l_return_status := G_RET_STS_ERROR;
     END IF;		*/

     IF p_edited_in_word = 'Y' Then
       IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1400: - attribute ARTICLE_TEXT_IN_WORD ', 2);
       END IF;
       IF ( p_article_text_in_word IS NULL OR Dbms_Lob.SubStr(p_article_text_in_word,1,1) = '00') THEN
         IF (l_debug = 'Y') THEN
           Okc_Debug.Log('1500: - attribute ARTICLE_TEXT_IN_WORD is invalid', 2);
         END IF;
             Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_ERROR_IMPORT_WORD');
             l_return_status := G_RET_STS_ERROR;
       ELSE

            BEGIN

               -- Bug 16461613
               l_art_XML := XMLType(p_article_text_in_word,nls_CHARSET_ID('AL32UTF8'));


            EXCEPTION WHEN OTHERS THEN

               IF (l_debug = 'Y') THEN
                 Okc_Debug.Log('3000: - attribute ARTICLE_TEXT_IN_WORD is not a valid XML', 2);
                 Okc_Debug.Log('3005: - Error ' || SQLERRM, 2);
               END IF;
               Okc_Api.Set_Message(G_APP_NAME, 'OKC_INV_ART_TXT_WML');
               l_return_status := G_RET_STS_ERROR;

            END;

       END IF;
     END IF;
END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: static values and range validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute PROVISION_YN ', 2);
      END IF;
      IF p_provision_yn NOT IN ('Y','N') THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute PROVISION_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'PROVISION_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF p_insert_by_reference NOT IN ('Y','N') THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute INSERT_BY_REFERENCE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'INSERT_BY_REFERENCE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF p_lock_text NOT IN ('Y','N') THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute LOCK_TEXT is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'LOCK_TEXT');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute GLOBAL_YN ', 2);
      END IF;
      IF p_global_yn NOT IN ('Y','N') THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute GLOBAL_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'GLOBAL_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute TRANSLATED_YN ', 2);
      END IF;
      IF p_translated_yn NOT IN ('Y','N') THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute TRANSLATED_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'TRANSLATED_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1900: lookup codes validation', 2);
      END IF;

/* Status Check is not needed as it is always set by the UI.. For Articles Import this is pre-checked for certain statuses only

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute ARTICLE_STATUS ', 2);
      END IF;
      IF p_article_status IS NOT NULL THEN
        l_tmp_return_status := Okc_Util.Check_Lookup_Code('OKC_ARTICLE_STATUS',p_article_status);
        IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_STATUS');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
*/

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1500: - attribute DEFAULT_SECTION ', 2);
      END IF;
      IF p_default_section IS NOT NULL THEN
        l_tmp_return_status := Okc_Util.Check_Lookup_Code('OKC_ARTICLE_SECTION',p_default_section);
        IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_INVALID_SECTION');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
/*
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreign keys validation ', 2);
         Okc_Debug.Log('2200: - attribute ARTICLE_LANGAUGE ', 2);
      END IF;

-- This check is required only for article import .. For UI this is not required as it will be derived as USERENV(LANG)
-- This is a denormalized attribute and will be validated only from creating new version from Articles Import.


      IF p_article_language IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_article_language_csr;
        FETCH l_article_language_csr INTO l_dummy_var;
        CLOSE l_article_language_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute ARTICLE_LANGAUGE is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ARTICLE_LANGAUGE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
*/
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute STD_ARTICLE_VERSION_ID ', 2);
      END IF;
      IF p_std_article_version_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_std_article_version_id_csr;
        FETCH l_std_article_version_id_csr INTO l_dummy_var;
        CLOSE l_std_article_version_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute STD_ARTICLE_VERSION_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'STD_ARTICLE_VERSION_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

/*
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute DATE_PUBLISHED ', 2);
      END IF;
      IF p_date_published IS NOT NULL THEN
        OPEN l_date_published_csr;
        FETCH l_date_published_csr INTO l_dummy_date;
        CLOSE l_date_published_csr;
        IF (l_dummy_date >= p_date_published) THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute DATE_PUBLISHED is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DATE_PUBLISHED');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
*/

    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2400: Leaving Validate_Attributes ', 2);
    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      Okc_Debug.Log('2500: Leaving Validate_Attributes because of EXCEPTION: '||sqlerrm, 2);
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);


      IF l_article_language_csr%ISOPEN THEN
        CLOSE l_article_language_csr;
      END IF;

      IF l_std_article_version_id_csr%ISOPEN THEN
        CLOSE l_std_article_version_id_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;

-- fix for bug#4006749 start
-- muteshev
   /*
      this function should be used in validate_record for
      validation provision_yn flag setting in source article
      and target articles that take part in articles relationship
      (see bug#4006749)
   */
function provision_flag_in_relations(
    p_article_id     in number,
    p_org_id         in number,
    p_provision_yn   in varchar2
)
return varchar2
is
result varchar2(1) := 'S'; -- success
cursor l_rel_prov_csr(
   c_source_article_id in number,
   c_org_id in number,
   c_provision_yn in varchar2)
IS
   select 'E' result
   from
      okc_article_versions v,
      okc_article_relatns_all r
   where
      r.source_article_id = c_source_article_id
   and
      r.org_id = c_org_id
   and
      v.article_id = r.target_article_id
   and
      v.article_version_number = 1
   and
      v.provision_yn <> c_provision_yn;
begin
   FOR err IN l_rel_prov_csr(p_article_id, p_org_id, p_provision_yn)
   LOOP
      result := err.result; -- failure
   END LOOP;
   return result;
end;
-- fix for bug#4006749 end

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_ARTICLE_VERSIONS --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,

    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,
    p_current_org_id             IN NUMBER := NULL,
    p_date_published             IN DATE,
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
	  p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,
    p_variable_code              IN VARCHAR2 DEFAULT NULL,
    x_earlier_adoption_type      OUT NOCOPY VARCHAR2,
    x_earlier_version_number     OUT NOCOPY NUMBER,
    x_earlier_version_id         OUT NOCOPY NUMBER,
    x_article_language           OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var      VARCHAR2(1) := '?';
    l_dummy_var1     VARCHAR2(1) ;
    l_dummy_var2     VARCHAR2(1) ;

    l_standard_yn   VARCHAR2(1) ;
    l_article_language   OKC_ARTICLES_ALL.ARTICLE_LANGUAGE%TYPE;
    l_global_start_date DATE := TO_DATE('12313999','MMDDYYYY');
    l_rownotfound                BOOLEAN := FALSE;


-- Cursor to derive highest version excluding the current one.

    CURSOR l_highest_version_csr(p_article_id IN NUMBER, p_article_version_id IN NUMBER) IS
-- 8.1.7.4 compatibility
select
   av.global_yn,
   av.article_status,
   av.adoption_type,
   av.start_date,
   av.end_date,
   av.provision_yn,
   av.article_version_number,
   av.article_version_id,
   av.date_published
from
   okc_article_versions av
where
   av.article_id = p_article_id
and
   av.start_date =   (select
                        max(av1.start_date)
                     from
                        okc_article_versions av1
                     where
                        av1.article_id = av.article_id
                     and
                        av1.article_version_id <> p_article_version_id
                     );
/*
     SELECT S.GLOBAL_YN,
            S.ARTICLE_STATUS,
            S.ADOPTION_TYPE,
            S.START_DATE,
            S.END_DATE,
            S.MAX_START_DATE,
            S.ARTICLE_VERSION_NUMBER,
            S.ARTICLE_VERSION_ID
      FROM (
         SELECT
           A.GLOBAL_YN,
           A.ARTICLE_STATUS,
           A.ADOPTION_TYPE,
           A.START_DATE, A.END_DATE,
           MAX(A.START_DATE) OVER (PARTITION BY A.ARTICLE_ID) AS MAX_START_DATE,
           A.ARTICLE_VERSION_NUMBER,
           A.ARTICLE_VERSION_ID
         FROM OKC_ARTICLE_VERSIONS A
         WHERE A.ARTICLE_ID = p_article_id
          AND ARTICLE_VERSION_ID <> p_article_version_id
           ) S
     WHERE S.START_DATE = S.MAX_START_DATE;
*/

    CURSOR l_article_id_csr(p_article_id IN NUMBER) is
     SELECT standard_yn, article_language
      FROM OKC_ARTICLES_ALL
      WHERE ARTICLE_ID = p_article_id;

-- Bug#3672511: Validation of start date of a localized clause should be >= start date of global clause.

    CURSOR l_global_csr(p_article_version_id IN NUMBER, p_local_org_id IN NUMBER) is
     SELECT start_date
      FROM OKC_ARTICLE_VERSIONS AVN, OKC_ARTICLE_ADOPTIONS ADP
      WHERE ARTICLE_VERSION_ID = GLOBAL_ARTICLE_VERSION_ID
        AND LOCAL_ARTICLE_VERSION_ID  = p_article_version_id
        AND LOCAL_ORG_ID = p_local_org_id
        AND ADP.ADOPTION_TYPE = 'LOCALIZED' ;

   l_highest_version_rec  l_highest_version_csr%ROWTYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
       Okc_Debug.Log('1400: - attribute ARTICLE_VERSION_ID ', 2);
    END IF;
    x_earlier_version_number := NULL;
    l_article_language := p_article_language;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id();
    if p_current_org_id IS NOT NULL Then
       G_CURRENT_ORG_ID := p_current_org_id;
    else
       if G_CURRENT_ORG_ID IS NULL Then
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute G_CURRENT_ORG_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
          l_return_status := G_RET_STS_ERROR;
          RETURN l_return_status ;
       end if;

    end if;
    /*
    if p_current_org_id IS NULL Then
       OPEN cur_org_csr;
       FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
       CLOSE cur_org_csr;
    else
       G_CURRENT_ORG_ID := p_current_org_id;
    end if;
    */

    IF p_import_action in ('N', 'V', 'U') THEN
       l_standard_yn := 'Y';
       l_article_language := p_article_language;
    ELSIF p_article_id IS NOT NULL THEN
        l_standard_yn := '?';
        OPEN l_article_id_csr(p_article_id);
        FETCH l_article_id_csr INTO l_standard_yn, l_article_language;
        CLOSE l_article_id_csr;
        IF (l_standard_yn = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute ARTICLE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ARTICLE_ID');
          l_return_status := G_RET_STS_ERROR;
          RETURN l_return_status ;
       END IF;
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,
      p_import_action   => p_import_action,
      p_standard_yn        => l_standard_yn,               -- Introduced for checks related to Std version only.
      p_article_version_id         => p_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => p_article_version_number,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => p_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_program_id                 => p_program_id,
      p_program_login_id           => p_program_application_id,
      p_program_application_id     => p_program_application_id,
      p_request_id                 => p_request_id,
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
	    p_edited_in_word             => p_edited_in_word,
 	    p_article_text_in_word       => p_article_text_in_word,
      p_variable_code              => p_variable_code           --clm
    );
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('2700: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm, 2);
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;
    END IF;

-- The following lines will be used to:
--   1. Validate the current article attributes in the case of Standard Article from a previous version (if record level
--       validation is desired).
--   2. Generate the version number later in the case of inserts of a article version in insert_row API using the
--      x_previous_version_number parameter (even if record level validation is not desired).
--   3. Validate the effectivity even in case of approved.
-- Pls note additional checks are provided because start_date may not be passed
-- by an erroneous transaction during validation.

-- Also this will be called from import API in which case article versions
-- can be imported as approved or pending approval.
-- We would still need to check that an article cannot be imported as approved/
-- pending approval if earlier version is draft/pending approval/rejected.


    IF (l_standard_yn = 'Y') AND                 --  All cases of Standard Articles Only (except first version of Import)
       (nvl(p_import_action,'X') <> 'N') THEN
       IF p_article_status in ('DRAFT','REJECTED','PENDING_APPROVAL')  OR  -- All Non Approved or Local or Start Date as null
           p_global_yn = 'N'  OR
           p_import_action = 'V' OR -- Added by MSENGUPT on 05/24 Bug#3648236 as earlier version check is needed for new version of import
           p_start_date IS NOT NULL Then

 -- For new versions while importing, the article version id will be null, the
 -- API is expected to return back the highest article version in that case

          IF p_import_Action = 'V' THEN
              OPEN  l_highest_version_csr(p_article_id, -99);
          ELSE
              OPEN  l_highest_version_csr(p_article_id, p_article_version_id);
          END IF;
          FETCH l_highest_version_csr  INTO l_highest_version_rec ;
          CLOSE  l_highest_version_csr;
       END IF;
    END IF;

    --- Record Level Validation
    IF p_validation_level > G_RECORD_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2800: Entered Record Level Validations', 2);
      END IF;
/*+++++++++++++start of hand code +++++++++++++++++++*/
--  manual coding for Record Level Validations if required

      IF ( p_end_date is NOT NULL ) THEN
        IF ( p_end_date < p_start_date ) THEN
          IF (l_debug = 'Y') THEN
           Okc_Debug.Log('1300: attribute START_DATE IS greater then end date for standard article', 2);
          END IF;
          OKC_API.Set_Message(G_APP_NAME, 'OKC_ART_START_GT_END_DATE');
          l_return_status := G_RET_STS_ERROR;
        ELSIF p_article_status in ('DRAFT','REJECTED','PENDING_APPROVAL')   AND
              p_end_date < trunc(sysdate) THEN -- Added for Bug 3517002
          IF (l_debug = 'Y') THEN
             Okc_Debug.Log('1300: attribute END_DATE IS less then system date for standard article', 2);
          END IF;
          OKC_API.Set_Message(G_APP_NAME, 'OKC_ART_END_LT_SYS_DATE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

-- Bug 3696909

      IF ( p_insert_by_reference = 'Y' ) THEN
        IF ( p_reference_text IS NULL ) THEN
          IF (l_debug = 'Y') THEN
             Okc_Debug.Log('1300: attribute REFERENCE_TEXT cannot be null if INSERT_BY_REFERENCE is YES', 2);
          END IF;
          OKC_API.Set_Message(G_APP_NAME, 'OKC_ART_REF_TEXT_NULL');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;


-- The following is not required.
/*
      IF ( p_date_approved is NOT NULL ) THEN
        IF ( p_date_approved > nvl(p_end_date,p_date_approved + 1) ) THEN
          IF (l_debug = 'Y') THEN
             Okc_Debug.Log('1300: attribute END_DATE IS less then approved date for standard article', 2);
          END IF;
          OKC_API.Set_Message(G_APP_NAME, 'OKC_ART_APPROVED_GT_END_DATE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
*/
-- In case of Standard Articles ONLY
--   Validate that a global standard article cannot be created at a local org
-- From the earlier version check
-- 1. If global, current version cannot be local
-- 2. earlier version cannot be status = DRAFT, REJECTED, PENDING APPROVAL'
-- 3. Date Overlap

      IF l_standard_yn = 'Y' THEN
        IF (G_CURRENT_ORG_ID <> G_GLOBAL_ORG_ID AND
            p_global_yn = 'Y') Then
            IF (l_debug = 'Y') THEN
              Okc_Debug.Log('2300: - attribute Global Article cannot be created at a local org', 2);
            END IF;
            Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_GLOBAL_ART_LOCAL_ORG' );
            l_return_status := G_RET_STS_ERROR;
        END IF;
        -- Only first version exists or first version is imported
        -- skip comparison part with previous version
        IF    nvl(p_import_action,'X') = 'N'
           OR l_highest_version_rec.article_version_number IS NULL THEN
           -- do not perform the following checks - only possible in the case of the first version being inserted
          NULL;
        ELSE

          IF p_article_status in ('DRAFT','REJECTED','PENDING_APPROVAL')  OR
             p_global_yn = 'N'  OR
             -- done in above IF statement nvl(p_import_action, 'N') <> 'N' OR -- Added by MSENGUPT on 05/24 Bug#3648236 as earlier version check is needed for new version of import or update of an existing version
             p_start_date IS NOT NULL Then

         /** moved outside of the IF right above
         IF l_highest_version_rec.article_version_number IS NULL Then
           -- do not perform the following checks - only possible in the case of the first version being inserted
            NULL;
         ELSE
         **/

-- Added by MSENGUPT on 05/26 that a provision -> clause change cannot happen unless it is in the first version in draft status
-- New Version check should catch this exception (UIs already have this check/articles import will definitely validate this)

            IF nvl(l_highest_version_rec.provision_yn, 'N') <> nvl(p_provision_yn, 'N') THEN
                IF (l_debug = 'Y') THEN
                  Okc_Debug.Log('1800: - Earlier version is of Provison/Clause is different from current one.', 2);
                END IF;
                Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_EARLIER_VER_PROVISION' );
                l_return_status := G_RET_STS_ERROR;
            END IF;
-- End MSENGUPT 05/24
-- Begin MSENGUPT 06/24 Global flag check is needed only for draft status clauses and import of a NEW VERSION.
--         UI prohibits this change on approved clauses

            IF p_article_status IN ('DRAFT', 'REJECTED', 'PENDING_APPROVAL') THEN
            --No need for this.  p_import_action will never be 'N' OR (nvl(p_import_action, 'N') <> 'N')) THEN

              IF (l_highest_version_rec.global_yn = 'Y' and p_global_yn = 'N') THEN
                IF (l_debug = 'Y') THEN
                 Okc_Debug.Log('1800: - Earlier version is GLOBAL this version cannot be LOCAL', 2);
                END IF;
                Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_EARLIER_VER_GLOBAL' );
                l_return_status := G_RET_STS_ERROR;
              END IF;
            END IF;
-- End MSENGUPT 06/25
            IF (l_highest_version_rec.article_status IN ('DRAFT', 'REJECTED',
                'PENDING_APPROVAL')) AND
                (p_article_status IN ('DRAFT', 'REJECTED', 'PENDING_APPROVAL')) THEN
            --No need for this.  p_import_action will never be 'N' OR (nvl(p_import_action, 'N') <> 'N')) THEN

               IF (l_debug = 'Y') THEN
                 Okc_Debug.Log('1800: - Already have one version available in DRAFT,REJECTED OR PENDING_APPROVAL', 2);
               END IF;
               Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_EXIST_DRAFT_REJ');
               l_return_status := G_RET_STS_ERROR;
           END IF;

           -- Date Published Check
            IF (l_highest_version_rec.date_published) >= p_date_published AND p_import_action IS NOT NULL THEN
		      IF (l_debug = 'Y') THEN
			   Okc_Debug.Log('1800: - Date Published of existing version is greater than date published provided for new version',2);
			 END IF;
	         --Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DATE_PUBLISHED');
	         Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_EXIST_DATE_PUBLISHED');
																               l_return_status := G_RET_STS_ERROR;
																	     END IF;

-- Bug#3722445: Overlapping check - not required if later versions are APPROVED. UI will take care of that.
-- The following scenario will occur only if the future (highest) version is DRAFT
-- UI does not allow date updates if there is an approved version after the current version.

           IF p_article_status IN ('HOLD','APPROVED') AND
              p_start_date < l_highest_version_rec.start_date THEN

-- Trying to manually update an approved article end date when another higher version exists
-- if subsequent version is approved or on hold, then the end date of the current version cannot be set to NULL: UI will enforce too
-- if subsequent version is in draft/rejected or pending approval status, the end date should not overlap.

                if p_end_date IS NULL AND l_highest_version_rec.article_status in ('APPROVED', 'HOLD') THEN
                  Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_END_DATE_NULL');
                  l_return_status := G_RET_STS_ERROR;
                elsif nvl(p_end_date, l_highest_version_rec.start_date-1) >= l_highest_version_rec.start_date then
                  IF (l_debug = 'Y') THEN
                    Okc_Debug.Log('1800: - Date overlap with earlier version', 2);
                  END IF;
                  Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_DATE_OVRLP_EARLR_VER');
                  l_return_status := G_RET_STS_ERROR;
                end if;
           ELSIF (l_highest_version_rec.start_date >= p_start_date)  OR
              (nvl(l_highest_version_rec.end_date, p_start_date-1) >= p_start_date) THEN
             IF (l_debug = 'Y') THEN
               Okc_Debug.Log('1800: - Date overlap with earlier version', 2);
             END IF;
             Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_DATE_OVRLP_EARLR_VER');
             l_return_status := G_RET_STS_ERROR;
           END IF; -- (l_highest_version_rec.start_date >= p_start_date) OR..
         END IF; -- IF (l_highest_version_rec.global_yn = 'Y' and p_global_yn = 'N')
        --END IF;  --IF l_highest_version_rec.article_version_number IS NULL
        END IF; -- p_article_status in ('DRAFT','REJECTED','PENDING_APPROVAL') OR..
      END IF;  --IF p_import_action = 'N', l_highest_version_rec.article_version_number IS NULL

      IF p_article_status   IN ('HOLD', 'APPROVED') AND
         p_date_approved IS NULL  THEN
         Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DATE_APPROVED');
          l_return_status := G_RET_STS_ERROR;
      END IF;

-- Bug#3672511: Validation of start date of a localized clause should be >= start date of global clause.
-- This is done only for localized articles i.e. at a local org.
-- This can be done only for all draft/rejected clauses as well as all imported clauses (unless new)

      IF G_CURRENT_ORG_ID <> G_GLOBAL_ORG_ID  AND
         p_start_date IS NOT NULL AND
         nvl(l_highest_version_rec.adoption_type, 'LOCALIZED') = 'LOCALIZED' AND
         ((nvl(p_import_action,'N') <> 'N') OR p_article_status in ('DRAFT','REJECTED'))  THEN
        OPEN l_global_csr(p_article_version_id, G_CURRENT_ORG_ID);
        FETCH l_global_csr INTO l_global_start_date;
        l_rownotfound := l_global_csr%NOTFOUND;
        CLOSE l_global_csr;
        IF l_rownotfound THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - No Data found to check Start Date is less than Global Start Date', 2);
          END IF;
        ELSIF (l_global_start_date > p_start_date) THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - Start Date is greater than Global Start Date', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_CMP_START_DATE');
          l_return_status := G_RET_STS_ERROR;
          RETURN l_return_status ;
       END IF;
      END IF; -- end of if current org id <> global org id

-- End of fix for Bug#3672511

-- fix for bug#4006749 start
-- muteshev
   if provision_flag_in_relations(p_article_id, G_CURRENT_ORG_ID, p_provision_yn)='E' then
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_INV_RELATION_PROVISION');
          l_return_status := G_RET_STS_ERROR;
          RETURN l_return_status ;
   end if;
-- fix for bug#4006749 end

    END IF; -- if l_standard_yn = Y
    x_earlier_version_number := l_highest_version_rec.article_version_number;
    x_article_language := l_article_language;
    x_earlier_version_id := l_highest_version_rec.article_version_id;
    x_earlier_adoption_type := l_highest_version_rec.adoption_type;

/*+++++++++++++End of hand code +++++++++++++++++++*/

    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('2900: Leaving Validate_Record : '||sqlerrm, 2);
    END IF;
    RETURN l_return_status ;

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('3000: Leaving Validate_Record because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);


      IF l_article_id_csr%ISOPEN THEN
        CLOSE l_article_id_csr;
      END IF;
      IF l_global_csr%ISOPEN THEN
        CLOSE l_global_csr;
      END IF;
      IF l_highest_version_csr%ISOPEN THEN
        CLOSE l_highest_version_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_ARTICLE_VERSIONS --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_earlier_adoption_type      OUT NOCOPY VARCHAR2,
    x_earlier_version_id         OUT NOCOPY NUMBER,
    x_earlier_version_number     OUT NOCOPY NUMBER,

    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,
    p_current_org_id             IN NUMBER := NULL,
    p_date_published             IN DATE   ,

    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,

    p_object_version_number      IN NUMBER,
    p_edited_in_word             IN VARCHAR2,
 	  p_article_text_in_word       IN BLOB,
    p_variable_code              IN VARCHAR2 DEFAULT NULL                 --clm
  ) IS
      l_article_id                 OKC_ARTICLE_VERSIONS.ARTICLE_ID%TYPE;
      l_article_version_number     OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE;
      l_article_text               OKC_ARTICLE_VERSIONS.ARTICLE_TEXT%TYPE;
      l_provision_yn               OKC_ARTICLE_VERSIONS.PROVISION_YN%TYPE;
      l_insert_by_reference        OKC_ARTICLE_VERSIONS.INSERT_BY_REFERENCE%TYPE;
      l_lock_text                  OKC_ARTICLE_VERSIONS.LOCK_TEXT%TYPE;
      l_global_yn                  OKC_ARTICLE_VERSIONS.GLOBAL_YN%TYPE;
      l_article_language           OKC_ARTICLE_VERSIONS.ARTICLE_LANGUAGE%TYPE;
      l_article_language_out       OKC_ARTICLE_VERSIONS.ARTICLE_LANGUAGE%TYPE;
      l_article_status             OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;
      l_sav_release                OKC_ARTICLE_VERSIONS.SAV_RELEASE%TYPE;
      l_start_date                 OKC_ARTICLE_VERSIONS.START_DATE%TYPE;
      l_end_date                   OKC_ARTICLE_VERSIONS.END_DATE%TYPE;
      l_std_article_version_id     OKC_ARTICLE_VERSIONS.STD_ARTICLE_VERSION_ID%TYPE;
      l_display_name               OKC_ARTICLE_VERSIONS.DISPLAY_NAME%TYPE;
      l_translated_yn              OKC_ARTICLE_VERSIONS.TRANSLATED_YN%TYPE;
      l_article_description        OKC_ARTICLE_VERSIONS.ARTICLE_DESCRIPTION%TYPE;
      l_date_approved              OKC_ARTICLE_VERSIONS.DATE_APPROVED%TYPE;
      l_default_section            OKC_ARTICLE_VERSIONS.DEFAULT_SECTION%TYPE;
      l_reference_source           OKC_ARTICLE_VERSIONS.REFERENCE_SOURCE%TYPE;
      l_reference_text             OKC_ARTICLE_VERSIONS.REFERENCE_TEXT%TYPE;
      l_orig_system_reference_code OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
      l_orig_system_reference_id1  OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
      l_orig_system_reference_id2  OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
      l_additional_instructions    OKC_ARTICLE_VERSIONS.ADDITIONAL_INSTRUCTIONS%TYPE;
      l_variation_description      OKC_ARTICLE_VERSIONS.VARIATION_DESCRIPTION%TYPE;
      l_date_published             OKC_ARTICLE_VERSIONS.DATE_PUBLISHED%TYPE;
      l_program_id                 OKC_ARTICLE_VERSIONS.PROGRAM_ID%TYPE;
      l_program_login_id           OKC_ARTICLE_VERSIONS.PROGRAM_LOGIN_ID%TYPE;
      l_program_application_id     OKC_ARTICLE_VERSIONS.PROGRAM_APPLICATION_ID%TYPE;
      l_request_id                 OKC_ARTICLE_VERSIONS.REQUEST_ID%TYPE;
      l_attribute_category         OKC_ARTICLE_VERSIONS.ATTRIBUTE_CATEGORY%TYPE;
      l_attribute1                 OKC_ARTICLE_VERSIONS.ATTRIBUTE1%TYPE;
      l_attribute2                 OKC_ARTICLE_VERSIONS.ATTRIBUTE2%TYPE;
      l_attribute3                 OKC_ARTICLE_VERSIONS.ATTRIBUTE3%TYPE;
      l_attribute4                 OKC_ARTICLE_VERSIONS.ATTRIBUTE4%TYPE;
      l_attribute5                 OKC_ARTICLE_VERSIONS.ATTRIBUTE5%TYPE;
      l_attribute6                 OKC_ARTICLE_VERSIONS.ATTRIBUTE6%TYPE;
      l_attribute7                 OKC_ARTICLE_VERSIONS.ATTRIBUTE7%TYPE;
      l_attribute8                 OKC_ARTICLE_VERSIONS.ATTRIBUTE8%TYPE;
      l_attribute9                 OKC_ARTICLE_VERSIONS.ATTRIBUTE9%TYPE;
      l_attribute10                OKC_ARTICLE_VERSIONS.ATTRIBUTE10%TYPE;
      l_attribute11                OKC_ARTICLE_VERSIONS.ATTRIBUTE11%TYPE;
      l_attribute12                OKC_ARTICLE_VERSIONS.ATTRIBUTE12%TYPE;
      l_attribute13                OKC_ARTICLE_VERSIONS.ATTRIBUTE13%TYPE;
      l_attribute14                OKC_ARTICLE_VERSIONS.ATTRIBUTE14%TYPE;
      l_attribute15                OKC_ARTICLE_VERSIONS.ATTRIBUTE15%TYPE;
      l_object_version_number      OKC_ARTICLE_VERSIONS.OBJECT_VERSION_NUMBER%TYPE;
	    l_edited_in_word             OKC_ARTICLE_VERSIONS.EDITED_IN_WORD%TYPE;
 	    l_article_text_in_word       OKC_ARTICLE_VERSIONS.ARTICLE_TEXT_IN_WORD%TYPE;
      l_created_by                 OKC_ARTICLE_VERSIONS.CREATED_BY%TYPE;
      l_creation_date              OKC_ARTICLE_VERSIONS.CREATION_DATE%TYPE;
      l_last_updated_by            OKC_ARTICLE_VERSIONS.LAST_UPDATED_BY%TYPE;
      l_last_update_login          OKC_ARTICLE_VERSIONS.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date           OKC_ARTICLE_VERSIONS.LAST_UPDATE_DATE%TYPE;
      l_earlier_version_number     OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE;
      l_earlier_version_id         OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE;
      l_variable_code              OKC_ARTICLE_VERSIONS.VARIABLE_CODE%TYPE;                    --clm

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    IF p_import_action IS NOT NULL Then
      l_article_id                 := p_article_id;
      l_article_version_number     := p_article_version_number;
      l_article_text               := p_article_text;
      l_provision_yn               := p_provision_yn;
      l_insert_by_reference        := p_insert_by_reference;
      l_lock_text                  := p_lock_text;
      l_global_yn                  := p_global_yn;
      l_article_language           := p_article_language;
      l_article_status             := p_article_status;
      l_sav_release                := p_sav_release;
      l_start_date                 := p_start_date;
      l_end_date                   := p_end_date;
      l_std_article_version_id     := p_std_article_version_id;
      l_display_name               := p_display_name;
      l_translated_yn              := p_translated_yn;
      l_article_description        := p_article_description;
      l_date_approved              := p_date_approved;
      l_default_section            := p_default_section;
      l_reference_source           := p_reference_source;
      l_reference_text           := p_reference_text;
      l_orig_system_reference_code := p_orig_system_reference_code;
      l_orig_system_reference_id1  := p_orig_system_reference_id1;
      l_orig_system_reference_id2  := p_orig_system_reference_id2;
      l_additional_instructions    := p_additional_instructions;
      l_variation_description      := p_variation_description;
      l_date_published             := p_date_published;
      l_program_id                 := p_program_id;
      l_program_login_id           := p_program_login_id;
      l_program_application_id     := p_program_application_id;
      l_request_id                 := p_request_id;
      l_attribute_category         := p_attribute_category;
      l_attribute1                 := p_attribute1;
      l_attribute2                 := p_attribute2;
      l_attribute3                 := p_attribute3;
      l_attribute4                 := p_attribute4;
      l_attribute5                 := p_attribute5;
      l_attribute6                 := p_attribute6;
      l_attribute7                 := p_attribute7;
      l_attribute8                 := p_attribute8;
      l_attribute9                 := p_attribute9;
      l_attribute10                := p_attribute10;
      l_attribute11                := p_attribute11;
      l_attribute12                := p_attribute12;
      l_attribute13                := p_attribute13;
      l_attribute14                := p_attribute14;
      l_attribute15                := p_attribute15;
	    l_edited_in_word             := p_edited_in_word;
 	    l_article_text_in_word       := p_article_text_in_word;
      l_variable_code              := p_variable_code;               --clm
    ELSE
     x_return_status := Set_Attributes(
      p_article_version_id         => p_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => p_article_version_number,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => p_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_program_id                 => p_program_id,
      p_program_login_id           => p_program_login_id,
      p_program_application_id     => p_program_application_id,
      p_request_id                 => p_request_id,
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
      p_object_version_number      => p_object_version_number,
	    p_edited_in_word             => p_edited_in_word,
 	    p_article_text_in_word       => p_article_text_in_word,
      p_variable_code              => p_variable_code,                    --clm
      x_article_id                 => l_article_id,
      x_article_version_number     => l_article_version_number,
      x_article_text               => l_article_text,
      x_provision_yn               => l_provision_yn,
      x_insert_by_reference        => l_insert_by_reference,
      x_lock_text                  => l_lock_text,
      x_global_yn                  => l_global_yn,
      x_article_language           => l_article_language,
      x_article_status             => l_article_status,
      x_sav_release                => l_sav_release,
      x_start_date                 => l_start_date,
      x_end_date                   => l_end_date,
      x_std_article_version_id     => l_std_article_version_id,
      x_display_name               => l_display_name,
      x_translated_yn              => l_translated_yn,
      x_article_description        => l_article_description,
      x_date_approved              => l_date_approved,
      x_default_section            => l_default_section,
      x_reference_source           => l_reference_source,
      x_reference_text           => l_reference_text,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_additional_instructions    => l_additional_instructions,
      x_variation_description      => l_variation_description,
      x_date_published             => l_date_published,
      x_program_id                 => l_program_id,
      x_program_login_id           => l_program_login_id,
      x_program_application_id     => l_program_application_id,
      x_request_id                 => l_request_id,
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
	    x_edited_in_word             => l_edited_in_word,
 	    x_article_text_in_word       => l_article_text_in_word,
      x_variable_code              => l_variable_code            --clm
     );
     IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id();
    if p_current_org_id IS NOT NULL Then
       G_CURRENT_ORG_ID := p_current_org_id;
    else
       if G_CURRENT_ORG_ID IS NULL Then
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute G_CURRENT_ORG_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       end if;

    end if;
    /*
    if p_current_org_id IS NULL Then
       OPEN cur_org_csr;
       FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
       CLOSE cur_org_csr;
    else
       G_CURRENT_ORG_ID := p_current_org_id;
    end if;
    */
    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_import_action   => p_import_action,
      p_article_version_id         => p_article_version_id,
      p_article_id                 => l_article_id,
      p_article_version_number     => p_article_version_number,
      p_article_text               => l_article_text,
      p_provision_yn               => l_provision_yn,
      p_insert_by_reference        => l_insert_by_reference,
      p_lock_text                  => l_lock_text,
      p_global_yn                  => l_global_yn,
      p_article_language           => l_article_language,
      p_article_status             => l_article_status,
      p_sav_release                => l_sav_release,
      p_start_date                 => l_start_date,
      p_end_date                   => l_end_date,
      p_std_article_version_id     => l_std_article_version_id,
      p_display_name               => l_display_name,
      p_translated_yn              => l_translated_yn,
      p_article_description        => l_article_description,
      p_date_approved              => l_date_approved,
      p_default_section            => l_default_section,
      p_reference_source           => l_reference_source,
      p_reference_text           => l_reference_text,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_additional_instructions    => l_additional_instructions,
      p_variation_description      => l_variation_description,
      p_program_id                 => l_program_id,
      p_program_login_id           => l_program_login_id,
      p_program_application_id     => l_program_application_id,
      p_request_id                 => l_request_id,
      p_current_org_id             => G_CURRENT_ORG_ID,
      p_date_published             => l_date_published,
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
	    p_edited_in_word             => l_edited_in_word,
 	    p_article_text_in_word       => l_article_text_in_word,
      p_variable_code              => l_variable_code,                 --clm
      x_earlier_adoption_type      => x_earlier_adoption_type,
      x_article_language           => l_article_language_out,
      x_earlier_version_id         => x_earlier_version_id,
      x_earlier_version_number     => x_earlier_version_number
    );

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3200: Leaving validate_row', 2);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3300: Leaving Validate_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3400: Leaving Validate_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('3500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm, 2);
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
  -- Insert_Row for:OKC_ARTICLE_VERSIONS --
  -------------------------------------
  FUNCTION Insert_Row(
    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_adoption_type           IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_program_id                 IN NUMBER,
    p_program_login_id           IN NUMBER,
    p_program_application_id     IN NUMBER,
    p_request_id                 IN NUMBER,
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
    p_object_version_number      IN NUMBER,
	  p_edited_in_word             IN VARCHAR2,
 	  p_article_text_in_word       IN BLOB,
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE,
    p_variable_code              IN VARCHAR2 DEFAULT NULL               --clm

  ) RETURN VARCHAR2 IS


  l_program_id               OKC_ARTICLE_VERSIONS.PROGRAM_ID%TYPE;
  l_program_login_id         OKC_ARTICLE_VERSIONS.PROGRAM_LOGIN_ID%TYPE;
  l_program_appl_id          OKC_ARTICLE_VERSIONS.PROGRAM_APPLICATION_ID%TYPE;
  l_request_id               OKC_ARTICLE_VERSIONS.REQUEST_ID%TYPE;


  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;


    IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
       l_program_id := NULL;
       l_program_login_id := NULL;
    ELSE
       l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
       l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    END IF;
    IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
       l_program_appl_id := NULL;
    ELSE
       l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
    END IF;
    IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
       l_request_id := NULL;
    ELSE
       l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
    END IF;

    INSERT INTO OKC_ARTICLE_VERSIONS(
        ARTICLE_VERSION_ID,
        ARTICLE_ID,
        ARTICLE_VERSION_NUMBER,
        ARTICLE_TEXT,
        PROVISION_YN,
        INSERT_BY_REFERENCE,
        LOCK_TEXT,
        GLOBAL_YN,
        ARTICLE_LANGUAGE,
        ARTICLE_STATUS,
        SAV_RELEASE,
        START_DATE,
        END_DATE,
        STD_ARTICLE_VERSION_ID,
        DISPLAY_NAME,
        TRANSLATED_YN,
        ARTICLE_DESCRIPTION,
        DATE_APPROVED,
        DEFAULT_SECTION,
        ADOPTION_TYPE,
        REFERENCE_SOURCE,
        REFERENCE_TEXT,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        ADDITIONAL_INSTRUCTIONS,
        VARIATION_DESCRIPTION,
	   DATE_PUBLISHED,
        PROGRAM_ID,
        PROGRAM_LOGIN_ID,
        PROGRAM_APPLICATION_ID,
        REQUEST_ID,
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
        OBJECT_VERSION_NUMBER,
	      EDITED_IN_WORD,
 	      ARTICLE_TEXT_IN_WORD,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        VARIABLE_CODE)
      VALUES (
        p_article_version_id,
        p_article_id,
        p_article_version_number,
        p_article_text,
        p_provision_yn,
        p_insert_by_reference,
        p_lock_text,
        p_global_yn,
        p_article_language,
        p_article_status,
        p_sav_release,
        p_start_date,
        p_end_date,
        p_std_article_version_id,
        p_display_name,
        p_translated_yn,
        p_article_description,
        p_date_approved,
        p_default_section,
        p_adoption_type,
        p_reference_source,
        p_reference_text,
        p_orig_system_reference_code,
        p_orig_system_reference_id1,
        p_orig_system_reference_id2,
        p_additional_instructions,
        p_variation_description,
	   p_date_published,
        l_program_id,
        l_program_login_id,
        l_program_appl_id,
        l_request_id,
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
        p_object_version_number,
	      p_edited_in_word,
 	      p_article_text_in_word,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date,
        p_variable_code);

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3700: Leaving Insert_Row', 2);
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3800: Leaving Insert_Row:OTHERS Exception', 2);
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
  -- Insert_Row for:OKC_ARTICLE_VERSIONS --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,
    p_current_org_id             IN NUMBER := NULL,
    p_date_published             IN DATE   ,

    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
	  p_edited_in_word             IN VARCHAR2,
 	  p_article_text_in_word       IN BLOB,
    p_variable_code              IN VARCHAR2 DEFAULT NULL,             --clm
    x_earlier_adoption_type         OUT NOCOPY VARCHAR2,
    x_earlier_version_id         OUT NOCOPY NUMBER,
    x_article_version_id         OUT NOCOPY NUMBER

  ) IS

    l_object_version_number      OKC_ARTICLE_VERSIONS.OBJECT_VERSION_NUMBER%TYPE;
    l_article_version_number      OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE;
    l_adoption_type                 OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
    l_created_by                 OKC_ARTICLE_VERSIONS.CREATED_BY%TYPE;
    l_creation_date              OKC_ARTICLE_VERSIONS.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_ARTICLE_VERSIONS.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_ARTICLE_VERSIONS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_ARTICLE_VERSIONS.LAST_UPDATE_DATE%TYPE;
    l_article_language           OKC_ARTICLE_VERSIONS.ARTICLE_LANGUAGE%TYPE;

  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;
    --- Setting item attributes
    -- Set primary key value
    IF( p_article_version_id IS NULL ) THEN
      x_return_status := Get_Seq_Id(
        p_article_version_id => p_article_version_id,
        x_article_version_id => x_article_version_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
      x_article_version_id := p_article_version_id;
    END IF;

    -- Set Internal columns
    l_object_version_number      := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;

    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id();
    if p_current_org_id IS NOT NULL Then
       G_CURRENT_ORG_ID := p_current_org_id;
    else
       if G_CURRENT_ORG_ID IS NULL Then
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute G_CURRENT_ORG_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       end if;

    end if;
    /*
    if p_current_org_id IS NULL Then
       OPEN cur_org_csr;
       FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
       CLOSE cur_org_csr;
    else
       G_CURRENT_ORG_ID := p_current_org_id;
    end if;
   */
    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_article_version_id         => x_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => p_article_version_number,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => p_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_program_id                 => p_program_id,
      p_program_login_id           => p_program_login_id,
      p_program_application_id     => p_program_application_id,
      p_request_id                 => p_request_id,
      p_current_org_id             => G_CURRENT_ORG_ID,
      p_date_published             => p_date_published,
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
	    p_edited_in_word             => p_edited_in_word,
 	    p_article_text_in_word       => p_article_text_in_word,
      p_variable_code              => p_variable_code,                     --clm
      x_article_language           => l_article_language,
      x_earlier_adoption_type      => x_earlier_adoption_type,
      x_earlier_version_id         => x_earlier_version_id,
      x_earlier_version_number     => l_article_version_number
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --------------------------------------------
    -- Call the internal Insert_Row for each child record
    --------------------------------------------
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4300: Call the internal Insert_Row for Base Table', 2);
    END IF;
  -- Generate the highest article version number for the article in the case of insert. This was obtained from the validate  -- row while validating a number of attributes based on earlier version.
  -- Though this approach is not pretty but it does save an expensive SQL.

    l_article_version_number := nvl(l_article_version_number,0) + 1;
    l_adoption_type := x_earlier_adoption_type;
    if l_adoption_type IS NULL and
       G_CURRENT_ORG_ID <> G_GLOBAL_ORG_ID THEN
       l_adoption_type := 'LOCAL';
    end if;
    x_return_status := Insert_Row(
      p_article_version_id         => x_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => l_article_version_number,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => l_article_language,
      p_article_status             => p_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_adoption_type            => l_adoption_type,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_program_id                 => p_program_id,
      p_program_login_id           => p_program_login_id,
      p_program_application_id     => p_program_application_id,
      p_request_id                 => p_request_id,
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
      p_object_version_number      => l_object_version_number,
	    p_edited_in_word             => p_edited_in_word,
 	    p_article_text_in_word       => p_article_text_in_word,
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date,
      p_variable_code              => p_variable_code                      --clm
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;



    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4500: Leaving Insert_Row', 2);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4600: Leaving Insert_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4700: Leaving Insert_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4800: Leaving Insert_Row because of EXCEPTION: '||sqlerrm, 2);
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
  -- Lock_Row for:OKC_ARTICLE_VERSIONS --
  -----------------------------------
  FUNCTION Lock_Row(
    p_article_version_id         IN NUMBER,
    p_object_version_number      IN NUMBER
  ) RETURN VARCHAR2 IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (cp_article_version_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_ARTICLE_VERSIONS
     WHERE ARTICLE_VERSION_ID = cp_article_version_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_article_version_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_ARTICLE_VERSIONS
     WHERE ARTICLE_VERSION_ID = cp_article_version_id;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_ARTICLE_VERSIONS.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;


    BEGIN
      OPEN lock_csr( p_article_version_id, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN

        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('5000: Leaving Lock_Row:E_Resource_Busy Exception', 2);
        END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
        RETURN( G_RET_STS_ERROR );
    END;

    IF ( l_row_notfound ) THEN
      l_return_status := G_RET_STS_ERROR;

      OPEN lchk_csr(p_article_version_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        Okc_Api.Set_Message(G_FND_APP,G_RECORD_DELETED);
      ELSIF l_object_version_number > p_object_version_number THEN
        Okc_Api.Set_Message(G_FND_APP,G_RECORD_CHANGED);
      ELSIF l_object_version_number = -1 THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      ELSE -- it can be the only above condition. It can happen after restore version
        Okc_Api.Set_Message(G_FND_APP,G_RECORD_CHANGED);
      END IF;
     ELSE
      l_return_status := G_RET_STS_SUCCESS;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5100: Leaving Lock_Row', 2);
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
        Okc_Debug.Log('5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
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
  -- Lock_Row for:OKC_ARTICLE_VERSIONS --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_article_version_id         IN NUMBER,
    p_object_version_number      IN NUMBER
   ) IS
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5700: Entered Lock_Row', 2);
       Okc_Debug.Log('5800: Locking Row for Base Table', 2);
    END IF;

    --------------------------------------------
    -- Call the LOCK_ROW for each _B child record
    --------------------------------------------
    x_return_status := Lock_Row(
      p_article_version_id         => p_article_version_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;



    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('6000: Leaving Lock_Row', 2);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6100: Leaving Lock_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6200: Leaving Lock_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6300: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
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
  -- Update_Row for:OKC_ARTICLE_VERSIONS --
  -------------------------------------
  FUNCTION Update_Row(
    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE,
    p_program_id                 IN NUMBER,
    p_program_login_id           IN NUMBER,
    p_program_application_id     IN NUMBER,
    p_request_id                 IN NUMBER,
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
    p_object_version_number      IN NUMBER,
	  p_edited_in_word             IN VARCHAR2,
 	  p_article_text_in_word       IN BLOB,
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE,
    p_variable_code              IN VARCHAR2          --clm
   ) RETURN VARCHAR2 IS


  l_program_id               OKC_ARTICLE_VERSIONS.PROGRAM_ID%TYPE;
  l_program_login_id         OKC_ARTICLE_VERSIONS.PROGRAM_LOGIN_ID%TYPE;
  l_program_appl_id          OKC_ARTICLE_VERSIONS.PROGRAM_APPLICATION_ID%TYPE;
  l_request_id               OKC_ARTICLE_VERSIONS.REQUEST_ID%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;

    IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
       l_program_id := NULL;
       l_program_login_id := NULL;
    ELSE
       l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
       l_program_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    END IF;
    IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
       l_program_appl_id := NULL;
    ELSE
       l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
    END IF;
    IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
       l_request_id := NULL;
    ELSE
       l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
    END IF;


    UPDATE OKC_ARTICLE_VERSIONS
     SET ARTICLE_ID                 = p_article_id,
--       ARTICLE_VERSION_NUMBER     = p_article_version_number,
         ARTICLE_TEXT               = p_article_text,
         PROVISION_YN               = p_provision_yn,
         INSERT_BY_REFERENCE        = p_insert_by_reference,
         LOCK_TEXT                  = p_lock_text,
         GLOBAL_YN                  = p_global_yn,
--       ARTICLE_LANGUAGE           = p_article_language,
         ARTICLE_STATUS             = p_article_status,
         SAV_RELEASE                = p_sav_release,
         START_DATE                 = p_start_date,
         END_DATE                   = p_end_date,
         STD_ARTICLE_VERSION_ID     = p_std_article_version_id,
         DISPLAY_NAME               = p_display_name,
         TRANSLATED_YN              = p_translated_yn,
         ARTICLE_DESCRIPTION        = p_article_description,
         DATE_APPROVED              = p_date_approved,
         DEFAULT_SECTION            = p_default_section,
         REFERENCE_SOURCE           = p_reference_source,
         REFERENCE_TEXT           = p_reference_text,
         ORIG_SYSTEM_REFERENCE_CODE = p_orig_system_reference_code,
         ORIG_SYSTEM_REFERENCE_ID1  = p_orig_system_reference_id1,
         ORIG_SYSTEM_REFERENCE_ID2  = p_orig_system_reference_id2,
         ADDITIONAL_INSTRUCTIONS    = p_additional_instructions,
         VARIATION_DESCRIPTION      = p_variation_description,
--       DATE_PUBLISHED             = p_date_published,
         PROGRAM_ID                 = l_program_id,
         REQUEST_ID                 = l_request_id,
         PROGRAM_LOGIN_ID           = l_program_login_id,
         PROGRAM_APPLICATION_ID     = l_program_appl_id,
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
-- muteshev
         OBJECT_VERSION_NUMBER      = object_version_number+1,
	       EDITED_IN_WORD             = p_edited_in_word,
 	       ARTICLE_TEXT_IN_WORD       = p_article_text_in_word,
         LAST_UPDATED_BY            = p_last_updated_by,
         LAST_UPDATE_LOGIN          = p_last_update_login,
         LAST_UPDATE_DATE           = p_last_update_date,
--clm
         VARIABLE_CODE              = p_variable_code
    WHERE ARTICLE_VERSION_ID         = p_article_version_id;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6500: Leaving Update_Row', 2);
    END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6600: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
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
  -- Update_Row for:OKC_ARTICLE_VERSIONS --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text           IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,
    p_current_org_id             IN NUMBER := NULL,
    p_date_published             IN DATE   ,

    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_object_version_number      IN NUMBER,
	  p_edited_in_word             IN VARCHAR2,
 	  p_article_text_in_word       IN BLOB,
    p_variable_code              IN VARCHAR2 DEFAULT NULL,           ---clm
    x_article_status             IN VARCHAR2,
    x_article_id                 OUT NOCOPY NUMBER,
    x_earlier_version_id         OUT NOCOPY NUMBER
   ) IS

    l_article_id                 OKC_ARTICLE_VERSIONS.ARTICLE_ID%TYPE;
    l_article_version_number     OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE;
    l_article_text               OKC_ARTICLE_VERSIONS.ARTICLE_TEXT%TYPE;
    l_provision_yn               OKC_ARTICLE_VERSIONS.PROVISION_YN%TYPE;
    l_insert_by_reference        OKC_ARTICLE_VERSIONS.INSERT_BY_REFERENCE%TYPE;
    l_lock_text                  OKC_ARTICLE_VERSIONS.LOCK_TEXT%TYPE;
    l_global_yn                  OKC_ARTICLE_VERSIONS.GLOBAL_YN%TYPE;
    l_article_language           OKC_ARTICLE_VERSIONS.ARTICLE_LANGUAGE%TYPE;
    l_article_language_out       OKC_ARTICLE_VERSIONS.ARTICLE_LANGUAGE%TYPE;
    l_article_status             OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE;
    l_sav_release                OKC_ARTICLE_VERSIONS.SAV_RELEASE%TYPE;
    l_start_date                 OKC_ARTICLE_VERSIONS.START_DATE%TYPE;
    l_end_date                   OKC_ARTICLE_VERSIONS.END_DATE%TYPE;
    l_std_article_version_id     OKC_ARTICLE_VERSIONS.STD_ARTICLE_VERSION_ID%TYPE;
    l_display_name               OKC_ARTICLE_VERSIONS.DISPLAY_NAME%TYPE;
    l_translated_yn              OKC_ARTICLE_VERSIONS.TRANSLATED_YN%TYPE;
    l_article_description        OKC_ARTICLE_VERSIONS.ARTICLE_DESCRIPTION%TYPE;
    l_date_approved              OKC_ARTICLE_VERSIONS.DATE_APPROVED%TYPE;
    l_default_section            OKC_ARTICLE_VERSIONS.DEFAULT_SECTION%TYPE;
    l_reference_source           OKC_ARTICLE_VERSIONS.REFERENCE_SOURCE%TYPE;
    l_reference_text           OKC_ARTICLE_VERSIONS.REFERENCE_TEXT%TYPE;
    l_orig_system_reference_code OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    l_orig_system_reference_id1  OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    l_orig_system_reference_id2  OKC_ARTICLE_VERSIONS.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
    l_additional_instructions    OKC_ARTICLE_VERSIONS.ADDITIONAL_INSTRUCTIONS%TYPE;
    l_variation_description      OKC_ARTICLE_VERSIONS.VARIATION_DESCRIPTION%TYPE;
    l_date_published             OKC_ARTICLE_VERSIONS.DATE_PUBLISHED%TYPE;
    l_program_id                 OKC_ARTICLE_VERSIONS.PROGRAM_ID%TYPE;
    l_program_login_id           OKC_ARTICLE_VERSIONS.PROGRAM_LOGIN_ID%TYPE;
    l_program_application_id     OKC_ARTICLE_VERSIONS.PROGRAM_APPLICATION_ID%TYPE;
    l_request_id                 OKC_ARTICLE_VERSIONS.REQUEST_ID%TYPE;
    l_attribute_category         OKC_ARTICLE_VERSIONS.ATTRIBUTE_CATEGORY%TYPE;
    l_attribute1                 OKC_ARTICLE_VERSIONS.ATTRIBUTE1%TYPE;
    l_attribute2                 OKC_ARTICLE_VERSIONS.ATTRIBUTE2%TYPE;
    l_attribute3                 OKC_ARTICLE_VERSIONS.ATTRIBUTE3%TYPE;
    l_attribute4                 OKC_ARTICLE_VERSIONS.ATTRIBUTE4%TYPE;
    l_attribute5                 OKC_ARTICLE_VERSIONS.ATTRIBUTE5%TYPE;
    l_attribute6                 OKC_ARTICLE_VERSIONS.ATTRIBUTE6%TYPE;
    l_attribute7                 OKC_ARTICLE_VERSIONS.ATTRIBUTE7%TYPE;
    l_attribute8                 OKC_ARTICLE_VERSIONS.ATTRIBUTE8%TYPE;
    l_attribute9                 OKC_ARTICLE_VERSIONS.ATTRIBUTE9%TYPE;
    l_attribute10                OKC_ARTICLE_VERSIONS.ATTRIBUTE10%TYPE;
    l_attribute11                OKC_ARTICLE_VERSIONS.ATTRIBUTE11%TYPE;
    l_attribute12                OKC_ARTICLE_VERSIONS.ATTRIBUTE12%TYPE;
    l_attribute13                OKC_ARTICLE_VERSIONS.ATTRIBUTE13%TYPE;
    l_attribute14                OKC_ARTICLE_VERSIONS.ATTRIBUTE14%TYPE;
    l_attribute15                OKC_ARTICLE_VERSIONS.ATTRIBUTE15%TYPE;
    l_object_version_number      OKC_ARTICLE_VERSIONS.OBJECT_VERSION_NUMBER%TYPE;
	  l_edited_in_word             OKC_ARTICLE_VERSIONS.EDITED_IN_WORD%TYPE;
 	  l_article_text_in_word       OKC_ARTICLE_VERSIONS.ARTICLE_TEXT_IN_WORD%TYPE;
    l_created_by                 OKC_ARTICLE_VERSIONS.CREATED_BY%TYPE;
    l_creation_date              OKC_ARTICLE_VERSIONS.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_ARTICLE_VERSIONS.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_ARTICLE_VERSIONS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_ARTICLE_VERSIONS.LAST_UPDATE_DATE%TYPE;
    l_earlier_version_number    OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE;
    l_earlier_adoption_type     OKC_ARTICLE_VERSIONS.ADOPTION_TYPE%TYPE;
    l_variable_code             OKC_ARTICLE_VERSIONS.VARIABLE_CODE%TYPE;      ---clm

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_article_version_id         => p_article_version_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Setting attributes', 2);
    END IF;

    x_return_status := Set_Attributes(
      p_article_version_id         => p_article_version_id,
      p_article_id                 => p_article_id,
      p_article_version_number     => p_article_version_number,
      p_article_text               => p_article_text,
      p_provision_yn               => p_provision_yn,
      p_insert_by_reference        => p_insert_by_reference,
      p_lock_text                  => p_lock_text,
      p_global_yn                  => p_global_yn,
      p_article_language           => p_article_language,
      p_article_status             => p_article_status,
      p_sav_release                => p_sav_release,
      p_start_date                 => p_start_date,
      p_end_date                   => p_end_date,
      p_std_article_version_id     => p_std_article_version_id,
      p_display_name               => p_display_name,
      p_translated_yn              => p_translated_yn,
      p_article_description        => p_article_description,
      p_date_approved              => p_date_approved,
      p_default_section            => p_default_section,
      p_reference_source           => p_reference_source,
      p_reference_text           => p_reference_text,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_additional_instructions    => p_additional_instructions,
      p_variation_description      => p_variation_description,
      p_date_published             => p_date_published,
      p_program_id                 => p_program_id,
      p_program_login_id           => p_program_login_id,
      p_program_application_id     => p_program_application_id,
      p_request_id                 => p_request_id,
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
      p_object_version_number      => p_object_version_number,
	    p_edited_in_word             => p_edited_in_word,
 	    p_article_text_in_word       => p_article_text_in_word,
      p_variable_code              => p_variable_code,           --clm
      x_article_id                 => l_article_id,
      x_article_version_number     => l_article_version_number,
      x_article_text               => l_article_text,
      x_provision_yn               => l_provision_yn,
      x_insert_by_reference        => l_insert_by_reference,
      x_lock_text                  => l_lock_text,
      x_global_yn                  => l_global_yn,
      x_article_language           => l_article_language,
      x_article_status             => l_article_status,
      x_sav_release                => l_sav_release,
      x_start_date                 => l_start_date,
      x_end_date                   => l_end_date,
      x_std_article_version_id     => l_std_article_version_id,
      x_display_name               => l_display_name,
      x_translated_yn              => l_translated_yn,
      x_article_description        => l_article_description,
      x_date_approved              => l_date_approved,
      x_default_section            => l_default_section,
      x_reference_source           => l_reference_source,
      x_reference_text           => l_reference_text,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_additional_instructions    => l_additional_instructions,
      x_variation_description      => l_variation_description,
      x_date_published             => l_date_published,
      x_program_id                 => l_program_id,
      x_program_login_id           => l_program_login_id,
      x_program_application_id     => l_program_application_id,
      x_request_id                 => l_request_id,
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
	    x_edited_in_word             => l_edited_in_word,
 	    x_article_text_in_word       => l_article_text_in_word,
      x_variable_code              => l_variable_code              --clm
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Record Validation', 2);
    END IF;

    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id();
    if p_current_org_id IS NOT NULL Then
       G_CURRENT_ORG_ID := p_current_org_id;
    else
       if G_CURRENT_ORG_ID IS NULL Then
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute G_CURRENT_ORG_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
          x_return_status := G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
       end if;

    end if;
    /*
    if p_current_org_id IS NULL Then
       OPEN cur_org_csr;
       FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
       CLOSE cur_org_csr;
    else
       G_CURRENT_ORG_ID := p_current_org_id;
    end if;
    */
    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_article_version_id         => p_article_version_id,
      p_article_id                 => l_article_id,
      p_article_version_number     => l_article_version_number,
      p_article_text               => l_article_text,
      p_provision_yn               => l_provision_yn,
      p_insert_by_reference        => l_insert_by_reference,
      p_lock_text                  => l_lock_text,
      p_global_yn                  => l_global_yn,
      p_article_language           => l_article_language,
      p_article_status             => l_article_status,
      p_sav_release                => l_sav_release,
      p_start_date                 => l_start_date,
      p_end_date                   => l_end_date,
      p_std_article_version_id     => l_std_article_version_id,
      p_display_name               => l_display_name,
      p_translated_yn              => l_translated_yn,
      p_article_description        => l_article_description,
      p_date_approved              => l_date_approved,
      p_default_section            => l_default_section,
      p_reference_source           => l_reference_source,
      p_reference_text           => l_reference_text,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_additional_instructions    => l_additional_instructions,
      p_variation_description      => l_variation_description,
      p_date_published             => l_date_published,
      p_program_id                 => l_program_id,
      p_program_login_id           => l_program_login_id,
      p_program_application_id     => l_program_application_id,
      p_request_id                 => l_request_id,
      p_current_org_id             => G_CURRENT_ORG_ID,
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
	    p_edited_in_word             => l_edited_in_word,
 	    p_article_text_in_word       => l_article_text_in_word,
      p_variable_code              => l_variable_code,               --clm
      x_article_language           => l_article_language_out,
      x_earlier_adoption_type         => l_earlier_adoption_type,
      x_earlier_version_id         => x_earlier_version_id,
      x_earlier_version_number     => l_earlier_version_number
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7500: Filling WHO columns', 2);
    END IF;
    x_article_id := l_article_id;

    -- Filling who columns
    l_last_update_date := SYSDATE;
    l_last_updated_by := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    -- Object version increment
    IF Nvl(l_object_version_number, 0) >= 0 THEN
      l_object_version_number := Nvl(l_object_version_number, 0) + 1;
    END IF;
    --------------------------------------------
    -- Call the Update_Row for each child record
    --------------------------------------------
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7600: Updating Row', 2);
    END IF;

    x_return_status := Update_Row(
      p_article_version_id         => p_article_version_id,
      p_article_id                 => l_article_id,
      p_article_version_number     => l_article_version_number,
      p_article_text               => l_article_text,
      p_provision_yn               => l_provision_yn,
      p_insert_by_reference        => l_insert_by_reference,
      p_lock_text                  => l_lock_text,
      p_global_yn                  => l_global_yn,
      p_article_language           => l_article_language,
      p_article_status             => l_article_status,
      p_sav_release                => l_sav_release,
      p_start_date                 => l_start_date,
      p_end_date                   => l_end_date,
      p_std_article_version_id     => l_std_article_version_id,
      p_display_name               => l_display_name,
      p_translated_yn              => l_translated_yn,
      p_article_description        => l_article_description,
      p_date_approved              => l_date_approved,
      p_default_section            => l_default_section,
      p_reference_source           => l_reference_source,
      p_reference_text           => l_reference_text,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_additional_instructions    => l_additional_instructions,
      p_variation_description      => l_variation_description,
      p_date_published             => l_date_published,
      p_program_id                 => l_program_id,
      p_program_login_id           => l_program_login_id,
      p_program_application_id     => l_program_application_id,
      p_request_id                 => l_request_id,
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
      p_object_version_number      => l_object_version_number,
	    p_edited_in_word             => l_edited_in_word,
 	    p_article_text_in_word       => l_article_text_in_word,
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date,
      p_variable_code              => l_variable_code           --clm
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('7800: Leaving Update_Row', 2);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('7900: Leaving Update_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('8000: Leaving Update_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('8100: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
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
  -- Delete_Row for:OKC_ARTICLE_VERSIONS --
  -------------------------------------
  FUNCTION Delete_Row(
    p_article_version_id         IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;

    DELETE FROM OKC_ARTICLE_VERSIONS WHERE ARTICLE_VERSION_ID = P_ARTICLE_VERSION_ID;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8300: Leaving Delete_Row', 2);
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('8400: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
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
  -- Delete_Row for:OKC_ARTICLE_VERSIONS --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_object_version_number      IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_article_version_id         => p_article_version_id,
      p_object_version_number      => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9100: Removing _B row', 2);
    END IF;
    x_return_status := Delete_Row( p_article_version_id => p_article_version_id );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9300: Leaving Delete_Row', 2);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9400: Leaving Delete_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9500: Leaving Delete_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9600: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Row;

  -------------------------------------
  -- ArticleClob for creating a temporary clob
  -- in the database
  -- It is required to be used in Create Article, Create New Version
  -- and Update Article in Java Classes
  -------------------------------------
  FUNCTION ArticleClob
  RETURN CLOB IS

  c1 CLOB;

  BEGIN

    DBMS_LOB.CREATETEMPORARY(c1,true);
    DBMS_LOB.OPEN(c1,dbms_lob.lob_readwrite);
    DBMS_LOB.WRITE(c1,1,1,' ');
    RETURN c1;
  END ArticleClob;

	   -------------------------------------
 	   -- ArticleBlob for creating a temporary blob
 	   -- in the database
 	   -- It is required to be used in Create Article, Create New Version
 	   -- and Update Article in Java Classes
 	   -------------------------------------
 	   FUNCTION ArticleBlob
 	   RETURN BLOB IS

 	   b1 BLOB;

 	   BEGIN

 	     DBMS_LOB.CREATETEMPORARY(b1,true);
 	     DBMS_LOB.OPEN(b1,dbms_lob.lob_readwrite);
 	     RETURN b1;
 	   END ArticleBlob;


END OKC_ARTICLE_VERSIONS_PVT;

/

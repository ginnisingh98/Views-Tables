--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLES_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLES_ALL_PVT" AS
/* $Header: OKCVARTB.pls 120.1.12010000.3 2011/03/23 08:34:31 kkolukul ship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ARTICLES_ALL_PVT';
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

   pending boolean := false; -- pending flag

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION Get_Seq_Id (
    p_article_id                 IN NUMBER,
    x_article_id                 OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_seq_csr IS
     SELECT OKC_ARTICLES_ALL_S1.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF( p_article_id                 IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_article_id                ;
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
  -- FUNCTION get_rec for: OKC_ARTICLES_ALL
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_article_id                 IN NUMBER,

    x_article_title              OUT NOCOPY VARCHAR2,
    x_org_id                     OUT NOCOPY NUMBER,
    x_article_number             OUT NOCOPY VARCHAR2,
    x_standard_yn                OUT NOCOPY VARCHAR2,
    x_article_intent             OUT NOCOPY VARCHAR2,
    x_article_language           OUT NOCOPY VARCHAR2,
    x_article_type               OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id2  OUT NOCOPY VARCHAR2,
    x_cz_transfer_status_flag    OUT NOCOPY VARCHAR2,
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
    x_created_by                 OUT NOCOPY NUMBER,
    x_creation_date              OUT NOCOPY DATE,
    x_last_updated_by            OUT NOCOPY NUMBER,
    x_last_update_login          OUT NOCOPY NUMBER,
    x_last_update_date           OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_ARTICLES_ALL_pk_csr (cp_article_id IN NUMBER) IS
    SELECT
            ARTICLE_TITLE,
            ORG_ID,
            ARTICLE_NUMBER,
            STANDARD_YN,
            ARTICLE_INTENT,
            ARTICLE_LANGUAGE,
            ARTICLE_TYPE,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2,
            CZ_TRANSFER_STATUS_FLAG,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
      FROM OKC_ARTICLES_ALL t
     WHERE t.ARTICLE_ID = cp_article_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    -- Get current database values
    OPEN OKC_ARTICLES_ALL_pk_csr (p_article_id);
    FETCH OKC_ARTICLES_ALL_pk_csr INTO
            x_article_title,
            x_org_id,
            x_article_number,
            x_standard_yn,
            x_article_intent,
            x_article_language,
            x_article_type,
            x_orig_system_reference_code,
            x_orig_system_reference_id1,
            x_orig_system_reference_id2,
            x_cz_transfer_status_flag,
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
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date;
    IF OKC_ARTICLES_ALL_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_ARTICLES_ALL_pk_csr;

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

      IF OKC_ARTICLES_ALL_pk_csr%ISOPEN THEN
        CLOSE OKC_ARTICLES_ALL_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_ARTICLES_ALL --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
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

    x_article_title              OUT NOCOPY VARCHAR2,
    x_org_id                     OUT NOCOPY NUMBER,
    x_article_number             OUT NOCOPY VARCHAR2,
    x_standard_yn                OUT NOCOPY VARCHAR2,
    x_article_intent             OUT NOCOPY VARCHAR2,
    x_article_language           OUT NOCOPY VARCHAR2,
    x_article_type               OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id2  OUT NOCOPY VARCHAR2,
    x_cz_transfer_status_flag    OUT NOCOPY VARCHAR2,
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
    x_attribute15                OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number      OKC_ARTICLES_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_ARTICLES_ALL.CREATED_BY%TYPE;
    l_creation_date              OKC_ARTICLES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_ARTICLES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_ARTICLES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_ARTICLES_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;

    IF( p_article_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_article_id                 => p_article_id,
        x_article_title              => x_article_title,
        x_org_id                     => x_org_id,
        x_article_number             => x_article_number,
        x_standard_yn                => x_standard_yn,
        x_article_intent             => x_article_intent,
        x_article_language           => x_article_language,
        x_article_type               => x_article_type,
        x_orig_system_reference_code => x_orig_system_reference_code,
        x_orig_system_reference_id1  => x_orig_system_reference_id1,
        x_orig_system_reference_id2  => x_orig_system_reference_id2,
        x_cz_transfer_status_flag    => x_cz_transfer_status_flag,
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
        x_created_by                 => l_created_by,
        x_creation_date              => l_creation_date,
        x_last_updated_by            => l_last_updated_by,
        x_last_update_login          => l_last_update_login,
        x_last_update_date           => l_last_update_date
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic
   pending := false; -- reset pending flag
      IF (p_article_title = G_MISS_CHAR) THEN
        x_article_title := NULL;
         pending := true;  -- updating article_title set pending flag
       ELSIF (p_ARTICLE_TITLE IS NOT NULL) THEN
        x_article_title := p_article_title;
         pending := true;  -- updating article_title set pending flag
      END IF;

      IF (p_org_id = G_MISS_NUM) THEN
        x_org_id := NULL;
       ELSIF (p_ORG_ID IS NOT NULL) THEN
        x_org_id := p_org_id;
      END IF;

      IF (p_article_number = G_MISS_CHAR) THEN
        x_article_number := NULL;
       ELSIF (p_ARTICLE_NUMBER IS NOT NULL) THEN
        x_article_number := p_article_number;
      END IF;

      IF (p_standard_yn = G_MISS_CHAR) THEN
        x_standard_yn := NULL;
       ELSIF (p_STANDARD_YN IS NOT NULL) THEN
        -- x_standard_yn := p_standard_yn;   -- Modified
        x_standard_yn := UPPER(p_standard_yn);
      END IF;

      IF (p_article_intent = G_MISS_CHAR) THEN
        x_article_intent := NULL;
       ELSIF (p_ARTICLE_INTENT IS NOT NULL) THEN
        -- x_article_intent := p_article_intent; -- Modified
        x_article_intent := UPPER(p_article_intent);
      END IF;

      IF (p_article_language = G_MISS_CHAR) THEN
        x_article_language := NULL;
       ELSIF (p_ARTICLE_LANGUAGE IS NOT NULL) THEN
        x_article_language := p_article_language;
      END IF;

      IF (p_article_type = G_MISS_CHAR) THEN
        x_article_type := NULL;
       ELSIF (p_ARTICLE_TYPE IS NOT NULL) THEN
        x_article_type := p_article_type;
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

      IF (p_cz_transfer_status_flag = G_MISS_CHAR) THEN
        x_cz_transfer_status_flag := NULL;
       ELSIF (p_CZ_TRANSFER_STATUS_FLAG IS NOT NULL) THEN
        -- x_cz_transfer_status_flag := p_cz_transfer_status_flag; -- Modified
        x_cz_transfer_status_flag := UPPER(p_cz_transfer_status_flag);
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


      -- ?? converting to uppercase all _YN columns
      -- ?? per performance reason it can be moved into corresponding
      -- ?? ELSIF( column IS NOT NULL) section above
      -- ?? x_standard_yn := Upper( x_standard_yn );
    ELSE
        x_article_title              := p_article_title;
        x_org_id                     := p_org_id;
        x_article_number             := p_article_number;
        x_standard_yn                := p_standard_yn;
        x_article_intent             := p_article_intent;
        x_article_language           := p_article_language;
        x_article_type               := p_article_type;
        x_orig_system_reference_code := p_orig_system_reference_code;
        x_orig_system_reference_id1  := p_orig_system_reference_id1;
        x_orig_system_reference_id2  := p_orig_system_reference_id2;
        x_cz_transfer_status_flag    := p_cz_transfer_status_flag;
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
  -- Validate_Attributes for: OKC_ARTICLES_ALL --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,

    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
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
    p_attribute15                IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_tmp_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
    l_doc_sequence_type  VARCHAR2(1);
    l_article_number OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;

    CURSOR l_org_id_csr is
     SELECT '!'
      FROM HR_ALL_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = p_org_id;

    CURSOR l_article_language_csr is
     SELECT '!'
      FROM FND_LANGUAGES
      WHERE LANGUAGE_CODE = p_article_language
      AND   INSTALLED_FLAG in ('B','I');

-- Added Cursor for Bug 3673484 - For Non-Std Clauses, no need to check effectivity
    CURSOR l_article_type_csr is
     SELECT '!'
      FROM  FND_LOOKUPS FNDLKUP
      WHERE FNDLKUP.LOOKUP_TYPE = 'OKC_SUBJECT'
      AND   FNDLKUP.LOOKUP_CODE = p_article_type;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_ID ', 2);
      END IF;
      IF nvl(p_import_action,'X') <> 'N' THEN -- do not validate if this is called from import while validating NEW articles
        IF ( p_article_id IS NULL) THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('1500: - attribute ARTICLE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      ELSIF p_import_action = 'N' AND p_standard_yn = 'Y' AND p_article_number IS NULL THEN
      -- Check Sequence is defined or not
	   OKC_ARTICLES_GRP.GET_ARTICLE_SEQ_NUMBER
	    (p_article_number => p_article_number,
	     p_seq_type_info_only => 'Y',
	     p_org_id => p_org_id,
	     x_article_number => l_article_number,
	     x_doc_sequence_type => l_doc_sequence_type,
	     x_return_status => l_return_status);

	 IF l_return_status <> G_RET_STS_SUCCESS THEN
	    Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NUMBER_NOT_PROVIDED');
	    l_return_status := G_RET_STS_ERROR;
	 ELSIF l_doc_sequence_type <> 'A' THEN
	    Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NUMBER_NOT_PROVIDED');
	    l_return_status := G_RET_STS_ERROR;
	 END IF;
    END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_TITLE ', 2);
      END IF;
      IF ( p_article_title IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ARTICLE_TITLE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_TITLE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ORG_ID ', 2);
      END IF;
      IF ( p_org_id IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ORG_ID is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ORG_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_NUMBER ', 2);
      END IF;
      IF nvl(p_import_action,'X') <> 'N'  AND p_standard_yn = 'Y' THEN
        IF ( p_article_number IS NULL) THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('1500: - attribute ARTICLE_NUMBER is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_NUMBER');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute STANDARD_YN ', 2);
      END IF;
      IF ( p_standard_yn IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute STANDARD_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'STANDARD_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ARTICLE_INTENT ', 2);
      END IF;
      IF ( p_article_intent IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ARTICLE_INTENT is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_INTENT');
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

    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: static values and range validation', 2);
      END IF;
-- Modified
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute STANDARD_YN ', 2);
      END IF;
      IF  p_standard_yn NOT IN ('Y','N') THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute STANDARD_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'STANDARD_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute ARTICLE_INTENT ', 2);
      END IF;
      IF  p_article_intent NOT IN ('B','S') THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute ARTICLE_INTENT is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_INTENT');
        l_return_status := G_RET_STS_ERROR;
      END IF;

-- Modified
    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1900: lookup codes validation', 2);
      END IF;

-- Modified
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute ARTICLE_TYPE ', 2);
      END IF;

-- Standard clauses will be checked for valid lookup code the way it is now
-- Non Standard clauses - just check for existence of the lookup code and do not
-- care whether it is effective or not.
-- Use a new message suggested by PMs

      IF p_article_type IS NOT NULL THEN
         l_dummy_var := '?';
           IF p_standard_yn = 'N' THEN
              OPEN l_article_type_csr;
              FETCH l_article_type_csr INTO l_dummy_var;
              CLOSE l_article_type_csr;
              IF (l_dummy_var = '?') THEN
                IF (l_debug = 'Y') THEN
                  Okc_Debug.Log('2300: - attribute ARTICLE_TYPE is invalid for non-std clause', 2);
                END IF;
                Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_INVALID_TYPE');
                l_return_status := G_RET_STS_ERROR;
              END IF;
           ELSIF  p_standard_yn = 'Y' THEN
              l_tmp_return_status := Okc_Util.Check_Lookup_Code('OKC_SUBJECT',p_article_type);
              IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
                IF (l_debug = 'Y') THEN
                  Okc_Debug.Log('2300: - attribute ARTICLE_TYPE is invalid for std clause', 2);
                END IF;
                Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_INVALID_TYPE');
                l_return_status := G_RET_STS_ERROR;
              END IF;
           END IF;

      END IF;

-- Modified
    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreign keys validation ', 2);
      END IF;

-- org id will always be set. You cannot create articles for a different org. Therefore no need to validate
/*
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ORG_ID ', 2);
      END IF;
      IF p_org_id IS NOT NULL AND p_org_id <> -99 THEN
        l_dummy_var := '?';
        OPEN l_org_id_csr;
        FETCH l_org_id_csr INTO l_dummy_var;
        CLOSE l_org_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute ORG_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ORG_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ARTICLE_LANGAUGE ', 2);
      END IF;
*/
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

-- Modified
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

      IF l_org_id_csr%ISOPEN THEN
        CLOSE l_org_id_csr;
      END IF;

      IF l_article_language_csr%ISOPEN THEN
        CLOSE l_article_language_csr;
      END IF;

      IF l_article_type_csr%ISOPEN THEN
        CLOSE l_article_type_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_ARTICLES_ALL --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,

    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2 := NULL,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,
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
    p_attribute15                IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;

-- Modified
    l_dummy_var     VARCHAR2(1) := '?';
    l_row_found                BOOLEAN := TRUE;

-- The following cursor will check for duplicates of org_id and article_title
    CURSOR l_unq_csr(p_org_id IN NUMBER, p_article_id IN NUMBER, p_article_title IN VARCHAR2) is
       SELECT '1' FROM OKC_ARTICLES_ALL
       WHERE article_title = p_article_title
        AND  org_id = p_org_id
        AND  standard_yn = 'Y'
        AND  article_id <> nvl(p_article_id,-99)
        AND rownum < 2
       UNION ALL
       SELECT '1'
       FROM okc_articles_all art, okc_article_adoptions adp, okc_article_versions artv
       WHERE  adp.local_org_id = p_org_id
        AND  art.article_title = p_article_title
        AND  adp.adoption_type = 'ADOPTED'
        AND  adp.global_article_version_id = artv.article_version_id
        AND  art.article_id = artv.article_id
        AND  art.article_id <> nvl(p_article_id,-99)
        AND  rownum < 2;
-- Modified
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,
      p_import_action      => p_import_action,
      p_article_id                 => p_article_id,
      p_article_title              => p_article_title,
      p_org_id                     => p_org_id,
      p_article_number             => p_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_cz_transfer_status_flag    => p_cz_transfer_status_flag,
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
      p_attribute15                => p_attribute15
    );
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('2700: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm, 2);
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;
    END IF;

    --- Record Level Validation
    IF p_validation_level > G_RECORD_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2800: Entered Record Level Validations', 2);
      END IF;
/*+++++++++++++start of hand code +++++++++++++++++++*/
--  manual coding for Record Level Validations if required
      --dbms_output.put_line('checking for p_article_type2: '||p_article_type||'*'||length(p_article_type));
      IF ( p_standard_yn = 'Y' AND p_article_type IS  NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1300: - attribute ARTICLE_TYPE is null for standard article', 2);
        END IF;
          --dbms_output.put_line('attribute ARTICLE_TYPE is null for standard article');
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_TYPE');
        l_return_status := G_RET_STS_ERROR;
      END IF;
      l_dummy_var := '?';

      --dbms_output.put_line('Checking for uniqueness '||p_org_id||'*'||p_article_title||'*'|| p_article_id);
      l_row_found                := TRUE;
      IF ( p_standard_yn = 'Y' ) THEN
        IF p_org_id is NOT NULL and p_article_title is NOT NULL THEN
           OPEN l_unq_csr (p_org_id, p_article_id, p_article_title);
           FETCH l_unq_csr INTO l_dummy_var;
           l_row_found := l_unq_csr%FOUND;
           CLOSE l_unq_csr;
           IF (l_row_found) THEN  -- Duplicates exist
             IF (l_debug = 'Y') THEN
                 Okc_Debug.Log('1300: - attribute ARTICLE_TITLE is not unique for org ', 2);
             END IF;
            Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_DUP_TITLE_ORG');
            l_return_status := G_RET_STS_ERROR;
           END IF;
        END IF;
      END IF;

/*+++++++++++++End of hand code +++++++++++++++++++*/
    END IF;

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
-- Modified
      IF l_unq_csr%ISOPEN THEN
         CLOSE l_unq_csr;
      END IF;
-- Modified
      RETURN G_RET_STS_UNEXP_ERROR ;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_ARTICLES_ALL --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,


    x_return_status                OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2 := NULL,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,

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
    p_object_version_number      IN NUMBER   := NULL
  ) IS
      l_article_title              OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE;
      l_org_id                     OKC_ARTICLES_ALL.ORG_ID%TYPE;
      l_article_number             OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;
      l_standard_yn                OKC_ARTICLES_ALL.STANDARD_YN%TYPE;
      l_article_intent             OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE;
      l_article_language           OKC_ARTICLES_ALL.ARTICLE_LANGUAGE%TYPE;
      l_article_type               OKC_ARTICLES_ALL.ARTICLE_TYPE%TYPE;
      l_orig_system_reference_code OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
      l_orig_system_reference_id1  OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
      l_orig_system_reference_id2  OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
      l_cz_transfer_status_flag    OKC_ARTICLES_ALL.CZ_TRANSFER_STATUS_FLAG%TYPE;
      l_program_id                 OKC_ARTICLES_ALL.PROGRAM_ID%TYPE;
      l_program_login_id           OKC_ARTICLES_ALL.PROGRAM_LOGIN_ID%TYPE;
      l_program_application_id     OKC_ARTICLES_ALL.PROGRAM_APPLICATION_ID%TYPE;
      l_request_id                 OKC_ARTICLES_ALL.REQUEST_ID%TYPE;
      l_attribute_category         OKC_ARTICLES_ALL.ATTRIBUTE_CATEGORY%TYPE;
      l_attribute1                 OKC_ARTICLES_ALL.ATTRIBUTE1%TYPE;
      l_attribute2                 OKC_ARTICLES_ALL.ATTRIBUTE2%TYPE;
      l_attribute3                 OKC_ARTICLES_ALL.ATTRIBUTE3%TYPE;
      l_attribute4                 OKC_ARTICLES_ALL.ATTRIBUTE4%TYPE;
      l_attribute5                 OKC_ARTICLES_ALL.ATTRIBUTE5%TYPE;
      l_attribute6                 OKC_ARTICLES_ALL.ATTRIBUTE6%TYPE;
      l_attribute7                 OKC_ARTICLES_ALL.ATTRIBUTE7%TYPE;
      l_attribute8                 OKC_ARTICLES_ALL.ATTRIBUTE8%TYPE;
      l_attribute9                 OKC_ARTICLES_ALL.ATTRIBUTE9%TYPE;
      l_attribute10                OKC_ARTICLES_ALL.ATTRIBUTE10%TYPE;
      l_attribute11                OKC_ARTICLES_ALL.ATTRIBUTE11%TYPE;
      l_attribute12                OKC_ARTICLES_ALL.ATTRIBUTE12%TYPE;
      l_attribute13                OKC_ARTICLES_ALL.ATTRIBUTE13%TYPE;
      l_attribute14                OKC_ARTICLES_ALL.ATTRIBUTE14%TYPE;
      l_attribute15                OKC_ARTICLES_ALL.ATTRIBUTE15%TYPE;
      l_object_version_number      OKC_ARTICLES_ALL.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by                 OKC_ARTICLES_ALL.CREATED_BY%TYPE;
      l_creation_date              OKC_ARTICLES_ALL.CREATION_DATE%TYPE;
      l_last_updated_by            OKC_ARTICLES_ALL.LAST_UPDATED_BY%TYPE;
      l_last_update_login          OKC_ARTICLES_ALL.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date           OKC_ARTICLES_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    IF p_import_action IS NOT NULL THEN
      l_article_title              := p_article_title;
      l_org_id                     := p_org_id;
      l_article_number             := p_article_number;
      l_standard_yn                := p_standard_yn;
      l_article_intent             := p_article_intent;
      l_article_language           := p_article_language;
      l_article_type               := p_article_type;
      l_orig_system_reference_code := p_orig_system_reference_code;
      l_orig_system_reference_id1  := p_orig_system_reference_id1;
      l_orig_system_reference_id2  := p_orig_system_reference_id2;
      l_cz_transfer_status_flag    := p_cz_transfer_status_flag;
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
    ELSE
      x_return_status := Set_Attributes(
      p_article_id                 => p_article_id,
      p_article_title              => p_article_title,
      p_org_id                     => p_org_id,
      p_article_number             => p_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_cz_transfer_status_flag    => p_cz_transfer_status_flag,
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
      x_article_title              => l_article_title,
      x_org_id                     => l_org_id,
      x_article_number             => l_article_number,
      x_standard_yn                => l_standard_yn,
      x_article_intent             => l_article_intent,
      x_article_language           => l_article_language,
      x_article_type               => l_article_type,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_cz_transfer_status_flag    => l_cz_transfer_status_flag,
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
      x_attribute15                => l_attribute15
      );
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_import_action              => p_import_action,
      p_article_id                 => p_article_id,
      p_article_title              => l_article_title,
      p_org_id                     => l_org_id,
      p_article_number             => l_article_number,
      p_standard_yn                => l_standard_yn,
      p_article_intent             => l_article_intent,
      p_article_language           => l_article_language,
      p_article_type               => l_article_type,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_cz_transfer_status_flag    => l_cz_transfer_status_flag,
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
      p_attribute15                => l_attribute15
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
  -- Insert_Row for:OKC_ARTICLES_ALL --
  -------------------------------------
  FUNCTION Insert_Row(
    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
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
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE

  ) RETURN VARCHAR2 IS


  l_program_id               OKC_ARTICLES_ALL.PROGRAM_ID%TYPE;
  l_program_login_id         OKC_ARTICLES_ALL.PROGRAM_LOGIN_ID%TYPE;
  l_program_appl_id          OKC_ARTICLES_ALL.PROGRAM_APPLICATION_ID%TYPE;
  l_request_id               OKC_ARTICLES_ALL.REQUEST_ID%TYPE;

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


    INSERT INTO OKC_ARTICLES_ALL(
        ARTICLE_ID,
        ARTICLE_TITLE,
        ORG_ID,
        ARTICLE_NUMBER,
        STANDARD_YN,
        ARTICLE_INTENT,
        ARTICLE_LANGUAGE,
        ARTICLE_TYPE,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        CZ_TRANSFER_STATUS_FLAG,
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
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        p_article_id,
        p_article_title,
        p_org_id,
        p_article_number,
        p_standard_yn,
        p_article_intent,
        nvl(p_article_language,USERENV('LANG')),
        p_article_type,
        p_orig_system_reference_code,
        p_orig_system_reference_id1,
        p_orig_system_reference_id2,
        'N',          -- Default value for cz_transfer_status_flag
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
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date);

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
  -- Insert_Row for:OKC_ARTICLES_ALL --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER := NULL,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,

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

    x_article_number             OUT NOCOPY VARCHAR2,
    x_article_id                 OUT NOCOPY NUMBER

  ) IS

    l_object_version_number      OKC_ARTICLES_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_ARTICLES_ALL.CREATED_BY%TYPE;
    l_creation_date              OKC_ARTICLES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_ARTICLES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_ARTICLES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_ARTICLES_ALL.LAST_UPDATE_DATE%TYPE;


  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;

    --- Setting item attributes
    -- Set primary key value
    IF( p_article_id IS NULL ) THEN
      x_return_status := Get_Seq_Id(
        p_article_id => p_article_id,
        x_article_id => x_article_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
      x_article_id := p_article_id;
    END IF;
    -- Set Internal columns
    l_object_version_number      := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;
    x_article_number := p_article_number;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_article_id                 => x_article_id,
      p_article_title              => p_article_title,
      p_org_id                     => p_org_id,
      p_article_number             => p_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_cz_transfer_status_flag    => p_cz_transfer_status_flag,
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
      p_attribute15                => p_attribute15
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

    x_return_status := Insert_Row(
      p_article_id                 => x_article_id,
      p_article_title              => p_article_title,
      p_org_id                     => p_org_id,
      p_article_number             => p_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_cz_transfer_status_flag    => p_cz_transfer_status_flag,
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
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date
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
  -- Lock_Row for:OKC_ARTICLES_ALL --
  -----------------------------------
  FUNCTION Lock_Row(
    p_article_id                 IN NUMBER,
    p_object_version_number      IN NUMBER
  ) RETURN VARCHAR2 IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (cp_article_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_ARTICLES_ALL
     WHERE ARTICLE_ID = cp_article_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_article_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_ARTICLES_ALL
     WHERE ARTICLE_ID = cp_article_id;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_ARTICLES_ALL.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;


    BEGIN

      OPEN lock_csr( p_article_id, p_object_version_number );
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

      OPEN lchk_csr(p_article_id);
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
  -- Lock_Row for:OKC_ARTICLES_ALL --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
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
      p_article_id                 => p_article_id,
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
  -- Update_Row for:OKC_ARTICLES_ALL --
  -------------------------------------
  FUNCTION Update_Row(
    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
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
    p_created_by                 IN NUMBER,
    p_creation_date              IN DATE,
    p_last_updated_by            IN NUMBER,
    p_last_update_login          IN NUMBER,
    p_last_update_date           IN DATE
   ) RETURN VARCHAR2 IS


  l_program_id               OKC_ARTICLES_ALL.PROGRAM_ID%TYPE;
  l_program_login_id         OKC_ARTICLES_ALL.PROGRAM_LOGIN_ID%TYPE;
  l_program_appl_id          OKC_ARTICLES_ALL.PROGRAM_APPLICATION_ID%TYPE;
  l_request_id               OKC_ARTICLES_ALL.REQUEST_ID%TYPE;

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

    UPDATE OKC_ARTICLES_ALL
     SET ARTICLE_TITLE              = p_article_title,
--         ORG_ID                     = p_org_id,
         ARTICLE_NUMBER             = p_article_number,
         STANDARD_YN                = p_standard_yn,
         ARTICLE_INTENT             = p_article_intent,
--         ARTICLE_LANGUAGE           = p_article_language,
         ARTICLE_TYPE               = p_article_type,
         ORIG_SYSTEM_REFERENCE_CODE = p_orig_system_reference_code,
         ORIG_SYSTEM_REFERENCE_ID1  = p_orig_system_reference_id1,
         ORIG_SYSTEM_REFERENCE_ID2  = p_orig_system_reference_id2,
         CZ_TRANSFER_STATUS_FLAG    = p_cz_transfer_status_flag,
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
         OBJECT_VERSION_NUMBER      = p_object_version_number,
         LAST_UPDATED_BY            = p_last_updated_by,
         LAST_UPDATE_LOGIN          = p_last_update_login,
         LAST_UPDATE_DATE           = p_last_update_date
    WHERE ARTICLE_ID                 = p_article_id;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6500: Leaving Update_Row', 2);
    END IF;

-- if article_title updated - notify context index
    if pending  then
        update OKC_ARTICLE_VERSIONS
        set article_text = article_text
        where article_id = p_article_id;
    end if;

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
  -- Update_Row for:OKC_ARTICLES_ALL --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_article_intent                OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,

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

    p_object_version_number      IN NUMBER

   ) IS

    l_article_title              OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE;
    l_org_id                     OKC_ARTICLES_ALL.ORG_ID%TYPE;
    l_article_number             OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;
    l_standard_yn                OKC_ARTICLES_ALL.STANDARD_YN%TYPE;
    l_article_intent             OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE;
    l_article_language           OKC_ARTICLES_ALL.ARTICLE_LANGUAGE%TYPE;
    l_article_type               OKC_ARTICLES_ALL.ARTICLE_TYPE%TYPE;
    l_orig_system_reference_code OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    l_orig_system_reference_id1  OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    l_orig_system_reference_id2  OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
    l_cz_transfer_status_flag    OKC_ARTICLES_ALL.CZ_TRANSFER_STATUS_FLAG%TYPE;
    l_program_id                 OKC_ARTICLES_ALL.PROGRAM_ID%TYPE;
    l_program_login_id           OKC_ARTICLES_ALL.PROGRAM_LOGIN_ID%TYPE;
    l_program_application_id     OKC_ARTICLES_ALL.PROGRAM_APPLICATION_ID%TYPE;
    l_request_id                 OKC_ARTICLES_ALL.REQUEST_ID%TYPE;
    l_attribute_category         OKC_ARTICLES_ALL.ATTRIBUTE_CATEGORY%TYPE;
    l_attribute1                 OKC_ARTICLES_ALL.ATTRIBUTE1%TYPE;
    l_attribute2                 OKC_ARTICLES_ALL.ATTRIBUTE2%TYPE;
    l_attribute3                 OKC_ARTICLES_ALL.ATTRIBUTE3%TYPE;
    l_attribute4                 OKC_ARTICLES_ALL.ATTRIBUTE4%TYPE;
    l_attribute5                 OKC_ARTICLES_ALL.ATTRIBUTE5%TYPE;
    l_attribute6                 OKC_ARTICLES_ALL.ATTRIBUTE6%TYPE;
    l_attribute7                 OKC_ARTICLES_ALL.ATTRIBUTE7%TYPE;
    l_attribute8                 OKC_ARTICLES_ALL.ATTRIBUTE8%TYPE;
    l_attribute9                 OKC_ARTICLES_ALL.ATTRIBUTE9%TYPE;
    l_attribute10                OKC_ARTICLES_ALL.ATTRIBUTE10%TYPE;
    l_attribute11                OKC_ARTICLES_ALL.ATTRIBUTE11%TYPE;
    l_attribute12                OKC_ARTICLES_ALL.ATTRIBUTE12%TYPE;
    l_attribute13                OKC_ARTICLES_ALL.ATTRIBUTE13%TYPE;
    l_attribute14                OKC_ARTICLES_ALL.ATTRIBUTE14%TYPE;
    l_attribute15                OKC_ARTICLES_ALL.ATTRIBUTE15%TYPE;
    l_object_version_number      OKC_ARTICLES_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                 OKC_ARTICLES_ALL.CREATED_BY%TYPE;
    l_creation_date              OKC_ARTICLES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by            OKC_ARTICLES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login          OKC_ARTICLES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date           OKC_ARTICLES_ALL.LAST_UPDATE_DATE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_article_id                 => p_article_id,
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
      p_article_id                 => p_article_id,
      p_article_title              => p_article_title,
      p_org_id                     => p_org_id,
      p_article_number             => p_article_number,
      p_standard_yn                => p_standard_yn,
      p_article_intent             => p_article_intent,
      p_article_language           => p_article_language,
      p_article_type               => p_article_type,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1  => p_orig_system_reference_id1,
      p_orig_system_reference_id2  => p_orig_system_reference_id2,
      p_cz_transfer_status_flag    => p_cz_transfer_status_flag,
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
      x_article_title              => l_article_title,
      x_org_id                     => l_org_id,
      x_article_number             => l_article_number,
      x_standard_yn                => l_standard_yn,
      x_article_intent             => l_article_intent,
      x_article_language           => l_article_language,
      x_article_type               => l_article_type,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1  => l_orig_system_reference_id1,
      x_orig_system_reference_id2  => l_orig_system_reference_id2,
      x_cz_transfer_status_flag    => l_cz_transfer_status_flag,
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
      x_attribute15                => l_attribute15
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Record Validation', 2);
    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_article_id                 => p_article_id,
      p_article_title              => l_article_title,
      p_org_id                     => l_org_id,
      p_article_number             => l_article_number,
      p_standard_yn                => l_standard_yn,
      p_article_intent             => l_article_intent,
      p_article_language           => l_article_language,
      p_article_type               => l_article_type,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_cz_transfer_status_flag    => l_cz_transfer_status_flag,
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
      p_attribute15                => l_attribute15
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
      p_article_id                 => p_article_id,
      p_article_title              => l_article_title,
      p_org_id                     => l_org_id,
      p_article_number             => l_article_number,
      p_standard_yn                => l_standard_yn,
      p_article_intent             => l_article_intent,
      p_article_language           => l_article_language,
      p_article_type               => l_article_type,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1  => l_orig_system_reference_id1,
      p_orig_system_reference_id2  => l_orig_system_reference_id2,
      p_cz_transfer_status_flag    => l_cz_transfer_status_flag,
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
      p_created_by                 => l_created_by,
      p_creation_date              => l_creation_date,
      p_last_updated_by            => l_last_updated_by,
      p_last_update_login          => l_last_update_login,
      p_last_update_date           => l_last_update_date
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_article_intent := l_article_intent;


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
  -- Delete_Row for:OKC_ARTICLES_ALL --
  -------------------------------------
  FUNCTION Delete_Row(
    p_article_id                 IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;

    DELETE FROM OKC_ARTICLES_ALL WHERE ARTICLE_ID = p_ARTICLE_ID;

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
  -- Delete_Row for:OKC_ARTICLES_ALL --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_article_id                 IN NUMBER,
    p_object_version_number      IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_article_id                 => p_article_id,
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
    x_return_status := Delete_Row( p_article_id => p_article_id );
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
END OKC_ARTICLES_ALL_PVT;

/

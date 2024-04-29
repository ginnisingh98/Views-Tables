--------------------------------------------------------
--  DDL for Package Body OKC_ALLOWED_TMPL_USAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ALLOWED_TMPL_USAGES_PVT" AS
/* $Header: OKCVALDTMPLUSGB.pls 120.0 2005/05/25 18:48:22 appldev noship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ALDTMPLUSG_PVT';
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

  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION Get_Seq_Id (
    p_allowed_tmpl_usages_id IN NUMBER,
    x_allowed_tmpl_usages_id OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_seq_csr IS
     SELECT OKC_ALLOWED_TMPL_USAGES_S.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF( p_allowed_tmpl_usages_id IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_allowed_tmpl_usages_id;
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
  -- FUNCTION get_rec for: OKC_ALLOWED_TMPL_USAGES
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_allowed_tmpl_usages_id IN NUMBER,

    x_template_id            OUT NOCOPY NUMBER,
    x_document_type          OUT NOCOPY VARCHAR2,
    x_default_yn             OUT NOCOPY VARCHAR2,
    x_attribute_category     OUT NOCOPY VARCHAR2,
    x_attribute1             OUT NOCOPY VARCHAR2,
    x_attribute2             OUT NOCOPY VARCHAR2,
    x_attribute3             OUT NOCOPY VARCHAR2,
    x_attribute4             OUT NOCOPY VARCHAR2,
    x_attribute5             OUT NOCOPY VARCHAR2,
    x_attribute6             OUT NOCOPY VARCHAR2,
    x_attribute7             OUT NOCOPY VARCHAR2,
    x_attribute8             OUT NOCOPY VARCHAR2,
    x_attribute9             OUT NOCOPY VARCHAR2,
    x_attribute10            OUT NOCOPY VARCHAR2,
    x_attribute11            OUT NOCOPY VARCHAR2,
    x_attribute12            OUT NOCOPY VARCHAR2,
    x_attribute13            OUT NOCOPY VARCHAR2,
    x_attribute14            OUT NOCOPY VARCHAR2,
    x_attribute15            OUT NOCOPY VARCHAR2,
    x_object_version_number  OUT NOCOPY NUMBER,
    x_created_by             OUT NOCOPY NUMBER,
    x_creation_date          OUT NOCOPY DATE,
    x_last_updated_by        OUT NOCOPY NUMBER,
    x_last_update_login      OUT NOCOPY NUMBER,
    x_last_update_date       OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_ALLOWED_TMPL_USAGES_pk_csr (cp_allowed_tmpl_usages_id IN NUMBER) IS
    SELECT
            TEMPLATE_ID,
            DOCUMENT_TYPE,
            DEFAULT_YN,
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
      FROM OKC_ALLOWED_TMPL_USAGES t
     WHERE t.ALLOWED_TMPL_USAGES_ID = cp_allowed_tmpl_usages_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    -- Get current database values
    OPEN OKC_ALLOWED_TMPL_USAGES_pk_csr (p_allowed_tmpl_usages_id);
    FETCH OKC_ALLOWED_TMPL_USAGES_pk_csr INTO
            x_template_id,
            x_document_type,
            x_default_yn,
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
    IF OKC_ALLOWED_TMPL_USAGES_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_ALLOWED_TMPL_USAGES_pk_csr;

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

      IF OKC_ALLOWED_TMPL_USAGES_pk_csr%ISOPEN THEN
        CLOSE OKC_ALLOWED_TMPL_USAGES_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_ALLOWED_TMPL_USAGES --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,
    p_attribute_category     IN VARCHAR2,
    p_attribute1             IN VARCHAR2,
    p_attribute2             IN VARCHAR2,
    p_attribute3             IN VARCHAR2,
    p_attribute4             IN VARCHAR2,
    p_attribute5             IN VARCHAR2,
    p_attribute6             IN VARCHAR2,
    p_attribute7             IN VARCHAR2,
    p_attribute8             IN VARCHAR2,
    p_attribute9             IN VARCHAR2,
    p_attribute10            IN VARCHAR2,
    p_attribute11            IN VARCHAR2,
    p_attribute12            IN VARCHAR2,
    p_attribute13            IN VARCHAR2,
    p_attribute14            IN VARCHAR2,
    p_attribute15            IN VARCHAR2,
    p_object_version_number  IN NUMBER,

    x_template_id            OUT NOCOPY NUMBER,
    x_document_type          OUT NOCOPY VARCHAR2,
    x_default_yn             OUT NOCOPY VARCHAR2,
    x_attribute_category     OUT NOCOPY VARCHAR2,
    x_attribute1             OUT NOCOPY VARCHAR2,
    x_attribute2             OUT NOCOPY VARCHAR2,
    x_attribute3             OUT NOCOPY VARCHAR2,
    x_attribute4             OUT NOCOPY VARCHAR2,
    x_attribute5             OUT NOCOPY VARCHAR2,
    x_attribute6             OUT NOCOPY VARCHAR2,
    x_attribute7             OUT NOCOPY VARCHAR2,
    x_attribute8             OUT NOCOPY VARCHAR2,
    x_attribute9             OUT NOCOPY VARCHAR2,
    x_attribute10            OUT NOCOPY VARCHAR2,
    x_attribute11            OUT NOCOPY VARCHAR2,
    x_attribute12            OUT NOCOPY VARCHAR2,
    x_attribute13            OUT NOCOPY VARCHAR2,
    x_attribute14            OUT NOCOPY VARCHAR2,
    x_attribute15            OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number  OKC_ALLOWED_TMPL_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_ALLOWED_TMPL_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_ALLOWED_TMPL_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_ALLOWED_TMPL_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;

    IF( p_allowed_tmpl_usages_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
        x_template_id            => x_template_id,
        x_document_type          => x_document_type,
        x_default_yn             => x_default_yn,
        x_attribute_category     => x_attribute_category,
        x_attribute1             => x_attribute1,
        x_attribute2             => x_attribute2,
        x_attribute3             => x_attribute3,
        x_attribute4             => x_attribute4,
        x_attribute5             => x_attribute5,
        x_attribute6             => x_attribute6,
        x_attribute7             => x_attribute7,
        x_attribute8             => x_attribute8,
        x_attribute9             => x_attribute9,
        x_attribute10            => x_attribute10,
        x_attribute11            => x_attribute11,
        x_attribute12            => x_attribute12,
        x_attribute13            => x_attribute13,
        x_attribute14            => x_attribute14,
        x_attribute15            => x_attribute15,
        x_object_version_number  => l_object_version_number,
        x_created_by             => l_created_by,
        x_creation_date          => l_creation_date,
        x_last_updated_by        => l_last_updated_by,
        x_last_update_login      => l_last_update_login,
        x_last_update_date       => l_last_update_date
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_template_id = G_MISS_NUM) THEN
        x_template_id := NULL;
       ELSIF (p_template_id IS NOT NULL) THEN
        x_template_id := p_template_id;
      END IF;

      IF (p_document_type = G_MISS_CHAR) THEN
        x_document_type := NULL;
       ELSIF (p_document_type IS NOT NULL) THEN
        x_document_type := p_document_type;
      END IF;

      IF (p_default_yn = G_MISS_CHAR) THEN
        x_default_yn := NULL;
       ELSIF (p_default_yn IS NOT NULL) THEN
        x_default_yn := Upper( p_default_yn );
      END IF;

      IF (p_attribute_category = G_MISS_CHAR) THEN
        x_attribute_category := NULL;
       ELSIF (p_attribute_category IS NOT NULL) THEN
        x_attribute_category := p_attribute_category;
      END IF;

      IF (p_attribute1 = G_MISS_CHAR) THEN
        x_attribute1 := NULL;
       ELSIF (p_attribute1 IS NOT NULL) THEN
        x_attribute1 := p_attribute1;
      END IF;

      IF (p_attribute2 = G_MISS_CHAR) THEN
        x_attribute2 := NULL;
       ELSIF (p_attribute2 IS NOT NULL) THEN
        x_attribute2 := p_attribute2;
      END IF;

      IF (p_attribute3 = G_MISS_CHAR) THEN
        x_attribute3 := NULL;
       ELSIF (p_attribute3 IS NOT NULL) THEN
        x_attribute3 := p_attribute3;
      END IF;

      IF (p_attribute4 = G_MISS_CHAR) THEN
        x_attribute4 := NULL;
       ELSIF (p_attribute4 IS NOT NULL) THEN
        x_attribute4 := p_attribute4;
      END IF;

      IF (p_attribute5 = G_MISS_CHAR) THEN
        x_attribute5 := NULL;
       ELSIF (p_attribute5 IS NOT NULL) THEN
        x_attribute5 := p_attribute5;
      END IF;

      IF (p_attribute6 = G_MISS_CHAR) THEN
        x_attribute6 := NULL;
       ELSIF (p_attribute6 IS NOT NULL) THEN
        x_attribute6 := p_attribute6;
      END IF;

      IF (p_attribute7 = G_MISS_CHAR) THEN
        x_attribute7 := NULL;
       ELSIF (p_attribute7 IS NOT NULL) THEN
        x_attribute7 := p_attribute7;
      END IF;

      IF (p_attribute8 = G_MISS_CHAR) THEN
        x_attribute8 := NULL;
       ELSIF (p_attribute8 IS NOT NULL) THEN
        x_attribute8 := p_attribute8;
      END IF;

      IF (p_attribute9 = G_MISS_CHAR) THEN
        x_attribute9 := NULL;
       ELSIF (p_attribute9 IS NOT NULL) THEN
        x_attribute9 := p_attribute9;
      END IF;

      IF (p_attribute10 = G_MISS_CHAR) THEN
        x_attribute10 := NULL;
       ELSIF (p_attribute10 IS NOT NULL) THEN
        x_attribute10 := p_attribute10;
      END IF;

      IF (p_attribute11 = G_MISS_CHAR) THEN
        x_attribute11 := NULL;
       ELSIF (p_attribute11 IS NOT NULL) THEN
        x_attribute11 := p_attribute11;
      END IF;

      IF (p_attribute12 = G_MISS_CHAR) THEN
        x_attribute12 := NULL;
       ELSIF (p_attribute12 IS NOT NULL) THEN
        x_attribute12 := p_attribute12;
      END IF;

      IF (p_attribute13 = G_MISS_CHAR) THEN
        x_attribute13 := NULL;
       ELSIF (p_attribute13 IS NOT NULL) THEN
        x_attribute13 := p_attribute13;
      END IF;

      IF (p_attribute14 = G_MISS_CHAR) THEN
        x_attribute14 := NULL;
       ELSIF (p_attribute14 IS NOT NULL) THEN
        x_attribute14 := p_attribute14;
      END IF;

      IF (p_attribute15 = G_MISS_CHAR) THEN
        x_attribute15 := NULL;
       ELSIF (p_attribute15 IS NOT NULL) THEN
        x_attribute15 := p_attribute15;
      END IF;


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
  -- Validate_Attributes for: OKC_ALLOWED_TMPL_USAGES --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,
    p_attribute_category     IN VARCHAR2,
    p_attribute1             IN VARCHAR2,
    p_attribute2             IN VARCHAR2,
    p_attribute3             IN VARCHAR2,
    p_attribute4             IN VARCHAR2,
    p_attribute5             IN VARCHAR2,
    p_attribute6             IN VARCHAR2,
    p_attribute7             IN VARCHAR2,
    p_attribute8             IN VARCHAR2,
    p_attribute9             IN VARCHAR2,
    p_attribute10            IN VARCHAR2,
    p_attribute11            IN VARCHAR2,
    p_attribute12            IN VARCHAR2,
    p_attribute13            IN VARCHAR2,
    p_attribute14            IN VARCHAR2,
    p_attribute15            IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
    l_template_intent OKC_TERMS_TEMPLATES_ALL.INTENT%TYPE;
    l_doc_intent      OKC_BUS_DOC_TYPES_B.INTENT%TYPE;
    l_doc_type_name     OKC_BUS_DOC_TYPES_TL.NAME%TYPE;

    CURSOR l_template_id_csr is
     SELECT '!'
      FROM okc_terms_templates_all
      WHERE TEMPLATE_ID = p_template_id;

    CURSOR l_document_type_csr is
     SELECT '!'
      FROM okc_bus_doc_types_b
      WHERE DOCUMENT_TYPE = p_document_type;

    CURSOR l_template_intent_csr IS
     SELECT intent
     FROM okc_terms_templates_all
     WHERE template_id = p_template_id;

   CURSOR l_doc_intent_csr IS
    SELECT intent
    FROM OKC_BUS_DOC_TYPES_B
    WHERE document_type = p_document_type;

    CURSOR l_doc_name_csr IS
      SELECT name
      FROM okc_bus_doc_types_vl
      WHERE document_type = p_document_type;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;

      IF ( p_document_type IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1210: - attribute DOCUMENT_TYPE is null', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'DOCUMENT_TYPE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: static values and range validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute DEFAULT_YN ', 2);
      END IF;
      IF ( p_default_yn NOT IN ('Y','N') AND p_default_yn IS NOT NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute DEFAULT_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'DEFAULT_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1900: lookup codes validation', 2);
      END IF;
    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute TEMPLATE_ID ', 2);
      END IF;
      IF p_template_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_template_id_csr;
        FETCH l_template_id_csr INTO l_dummy_var;
        CLOSE l_template_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute TEMPLATE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TEMPLATE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ALLOWED_TMPL_USAGES_ID ', 2);
      END IF;
      IF p_document_type IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_document_type_csr;
        FETCH l_document_type_csr INTO l_dummy_var;
        CLOSE l_document_type_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute DOCUMENT_TYPE is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DOCUMENT_TYPE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (p_template_id IS NOT NULL AND p_document_type IS NOT NULL) THEN

        OPEN l_template_intent_csr;
        FETCH l_template_intent_csr INTO l_template_intent;
        CLOSE l_template_intent_csr;

        OPEN l_doc_intent_csr;
        FETCH l_doc_intent_csr INTO l_doc_intent;
        CLOSE l_doc_intent_csr;
        IF l_template_intent <> l_doc_intent THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2310: - Intents of Template and Document Type do not match', 2);
          END IF;
          OPEN l_doc_name_csr;
          FETCH l_doc_name_csr INTO l_doc_type_name;
          CLOSE l_doc_name_csr;

          IF l_doc_type_name IS NULL THEN
            l_doc_type_name := p_document_type;
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_ALWD_USG_WRONG_INTENT',
                               'DOCUMENT_TYPE',l_doc_type_name);
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

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


      IF l_template_id_csr%ISOPEN THEN
        CLOSE l_template_id_csr;
      END IF;

      IF l_document_type_csr%ISOPEN THEN
        CLOSE l_document_type_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_ALLOWED_TMPL_USAGES --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,
    p_attribute_category     IN VARCHAR2,
    p_attribute1             IN VARCHAR2,
    p_attribute2             IN VARCHAR2,
    p_attribute3             IN VARCHAR2,
    p_attribute4             IN VARCHAR2,
    p_attribute5             IN VARCHAR2,
    p_attribute6             IN VARCHAR2,
    p_attribute7             IN VARCHAR2,
    p_attribute8             IN VARCHAR2,
    p_attribute9             IN VARCHAR2,
    p_attribute10            IN VARCHAR2,
    p_attribute11            IN VARCHAR2,
    p_attribute12            IN VARCHAR2,
    p_attribute13            IN VARCHAR2,
    p_attribute14            IN VARCHAR2,
    p_attribute15            IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
    l_parent_tmpl_id   NUMBER;
    l_def_tmpl_name     OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
    l_doc_type_name     OKC_BUS_DOC_TYPES_TL.NAME%TYPE;
    l_org_id            OKC_TERMS_TEMPLATES_ALL.ORG_ID%TYPE;

    CURSOR l_default_tmpl_csr IS
      SELECT parent_template_id,org_id
      FROM   okc_terms_templates_all
      WHERE  template_id = p_template_id;

    CURSOR l_default_doc_type_csr(pc_parent_tmpl_id NUMBER,
                                  pc_org_id NUMBER) is
      SELECT tmpl.template_name
      FROM okc_allowed_tmpl_usages usg,
           okc_terms_templates_all tmpl
      WHERE document_type = p_document_type
      AND allowed_tmpl_usages_id <> nvl(p_allowed_tmpl_usages_id, -9999)
      AND nvl(usg.default_yn,'N') = 'Y'
      AND ((tmpl.template_id <> pc_parent_tmpl_id AND pc_parent_tmpl_id IS NOT NULL) OR
           (pc_parent_tmpl_id IS NULL))
      AND NVL(tmpl.org_id,-99) = NVL(pc_org_id,-99)
      AND usg.template_id = tmpl.template_id;
    CURSOR l_allowed_doc_exists_csr IS
      SELECT '!'
      FROM okc_allowed_tmpl_usages
      WHERE template_id = p_template_id
      AND document_type = p_document_type
      AND allowed_tmpl_usages_id <> nvl(p_allowed_tmpl_usages_id, -9999);
    CURSOR l_doc_name_csr IS
      SELECT name
      FROM okc_bus_doc_types_vl
      WHERE document_type = p_document_type;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15
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
-- ?? manual coding for Record Level Validations if required ??
      IF p_document_type IS NOT NULL AND p_default_yn = 'Y' THEN
        OPEN l_default_tmpl_csr;
        FETCH l_default_tmpl_csr INTO l_parent_tmpl_id,l_org_id;
        CLOSE l_default_tmpl_csr;

        OPEN l_default_doc_type_csr(l_parent_tmpl_id,l_org_id);
        FETCH l_default_doc_type_csr INTO l_def_tmpl_name;
        IF l_default_doc_type_csr%FOUND THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2810: - default template for this document type already exists', 2);
          END IF;
          OPEN l_doc_name_csr;
          FETCH l_doc_name_csr INTO l_doc_type_name;
          CLOSE l_doc_name_csr;

          IF l_doc_type_name IS NULL THEN
            l_doc_type_name := p_document_type;
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_MLTPL_DEF_USG',
                               'DOCUMENT_TYPE',l_doc_type_name,
                               'TEMPLATE_NAME',l_def_tmpl_name);
          l_return_status := G_RET_STS_ERROR;
        END IF;
        CLOSE l_default_doc_type_csr;
      END IF;

      OPEN l_allowed_doc_exists_csr;
      FETCH l_allowed_doc_exists_csr INTO l_dummy_var;
      IF l_allowed_doc_exists_csr%FOUND THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('2810: - This document type already exists', 2);
        END IF;

        OPEN l_doc_name_csr;
        FETCH l_doc_name_csr INTO l_doc_type_name;
        CLOSE l_doc_name_csr;

        IF l_doc_type_name IS NULL THEN
          l_doc_type_name := p_document_type;
        END IF;

        Okc_Api.Set_Message(G_APP_NAME, 'OKC_ALLOWED_TMPL_USG_DUP',
                               'DOCUMENT_TYPE',l_doc_type_name);
        l_return_status := G_RET_STS_ERROR;
      END IF;
      CLOSE l_allowed_doc_exists_csr;
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
      RETURN G_RET_STS_UNEXP_ERROR ;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_ALLOWED_TMPL_USAGES --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER
  ) IS
      l_template_id            OKC_ALLOWED_TMPL_USAGES.TEMPLATE_ID%TYPE;
      l_document_type          OKC_ALLOWED_TMPL_USAGES.DOCUMENT_TYPE%TYPE;
      l_default_yn             OKC_ALLOWED_TMPL_USAGES.DEFAULT_YN%TYPE;
      l_attribute_category     OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE_CATEGORY%TYPE;
      l_attribute1             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE1%TYPE;
      l_attribute2             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE2%TYPE;
      l_attribute3             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE3%TYPE;
      l_attribute4             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE4%TYPE;
      l_attribute5             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE5%TYPE;
      l_attribute6             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE6%TYPE;
      l_attribute7             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE7%TYPE;
      l_attribute8             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE8%TYPE;
      l_attribute9             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE9%TYPE;
      l_attribute10            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE10%TYPE;
      l_attribute11            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE11%TYPE;
      l_attribute12            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE12%TYPE;
      l_attribute13            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE13%TYPE;
      l_attribute14            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE14%TYPE;
      l_attribute15            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE15%TYPE;
      l_object_version_number  OKC_ALLOWED_TMPL_USAGES.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by             OKC_ALLOWED_TMPL_USAGES.CREATED_BY%TYPE;
      l_creation_date          OKC_ALLOWED_TMPL_USAGES.CREATION_DATE%TYPE;
      l_last_updated_by        OKC_ALLOWED_TMPL_USAGES.LAST_UPDATED_BY%TYPE;
      l_last_update_login      OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date       OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15,
      p_object_version_number  => p_object_version_number,
      x_template_id            => l_template_id,
      x_document_type          => l_document_type,
      x_default_yn             => l_default_yn,
      x_attribute_category     => l_attribute_category,
      x_attribute1             => l_attribute1,
      x_attribute2             => l_attribute2,
      x_attribute3             => l_attribute3,
      x_attribute4             => l_attribute4,
      x_attribute5             => l_attribute5,
      x_attribute6             => l_attribute6,
      x_attribute7             => l_attribute7,
      x_attribute8             => l_attribute8,
      x_attribute9             => l_attribute9,
      x_attribute10            => l_attribute10,
      x_attribute11            => l_attribute11,
      x_attribute12            => l_attribute12,
      x_attribute13            => l_attribute13,
      x_attribute14            => l_attribute14,
      x_attribute15            => l_attribute15
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_template_id            => l_template_id,
      p_document_type          => l_document_type,
      p_default_yn             => l_default_yn,
      p_attribute_category     => l_attribute_category,
      p_attribute1             => l_attribute1,
      p_attribute2             => l_attribute2,
      p_attribute3             => l_attribute3,
      p_attribute4             => l_attribute4,
      p_attribute5             => l_attribute5,
      p_attribute6             => l_attribute6,
      p_attribute7             => l_attribute7,
      p_attribute8             => l_attribute8,
      p_attribute9             => l_attribute9,
      p_attribute10            => l_attribute10,
      p_attribute11            => l_attribute11,
      p_attribute12            => l_attribute12,
      p_attribute13            => l_attribute13,
      p_attribute14            => l_attribute14,
      p_attribute15            => l_attribute15
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
  -- Insert_Row for:OKC_ALLOWED_TMPL_USAGES --
  -------------------------------------
  FUNCTION Insert_Row(
    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,
    p_attribute_category     IN VARCHAR2,
    p_attribute1             IN VARCHAR2,
    p_attribute2             IN VARCHAR2,
    p_attribute3             IN VARCHAR2,
    p_attribute4             IN VARCHAR2,
    p_attribute5             IN VARCHAR2,
    p_attribute6             IN VARCHAR2,
    p_attribute7             IN VARCHAR2,
    p_attribute8             IN VARCHAR2,
    p_attribute9             IN VARCHAR2,
    p_attribute10            IN VARCHAR2,
    p_attribute11            IN VARCHAR2,
    p_attribute12            IN VARCHAR2,
    p_attribute13            IN VARCHAR2,
    p_attribute14            IN VARCHAR2,
    p_attribute15            IN VARCHAR2,
    p_object_version_number  IN NUMBER,
    p_created_by             IN NUMBER,
    p_creation_date          IN DATE,
    p_last_updated_by        IN NUMBER,
    p_last_update_login      IN NUMBER,
    p_last_update_date       IN DATE

  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;

    INSERT INTO OKC_ALLOWED_TMPL_USAGES(
        TEMPLATE_ID,
        DOCUMENT_TYPE,
        DEFAULT_YN,
        ALLOWED_TMPL_USAGES_ID,
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
        p_template_id,
        p_document_type,
        p_default_yn,
        p_allowed_tmpl_usages_id,
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
  -- Insert_Row for:OKC_ALLOWED_TMPL_USAGES --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER  := NULL,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    x_allowed_tmpl_usages_id OUT NOCOPY NUMBER

  ) IS

    l_object_version_number  OKC_ALLOWED_TMPL_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_ALLOWED_TMPL_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_ALLOWED_TMPL_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_ALLOWED_TMPL_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;

    --- Setting item attributes
    -- Set primary key value
    IF( p_allowed_tmpl_usages_id IS NULL ) THEN
      x_return_status := Get_Seq_Id(
        p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
        x_allowed_tmpl_usages_id => x_allowed_tmpl_usages_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
      x_allowed_tmpl_usages_id := p_allowed_tmpl_usages_id;
    END IF;
    -- Set Internal columns
    l_object_version_number  := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;


    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_allowed_tmpl_usages_id => x_allowed_tmpl_usages_id,
      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15
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
      p_allowed_tmpl_usages_id => x_allowed_tmpl_usages_id,
      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15,
      p_object_version_number  => l_object_version_number,
      p_created_by             => l_created_by,
      p_creation_date          => l_creation_date,
      p_last_updated_by        => l_last_updated_by,
      p_last_update_login      => l_last_update_login,
      p_last_update_date       => l_last_update_date
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
  -- Lock_Row for:OKC_ALLOWED_TMPL_USAGES --
  -----------------------------------
  FUNCTION Lock_Row(
    p_allowed_tmpl_usages_id IN NUMBER,
    p_object_version_number  IN NUMBER
  ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);
    l_object_version_number       OKC_ALLOWED_TMPL_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;

    CURSOR lock_csr (cp_allowed_tmpl_usages_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_ALLOWED_TMPL_USAGES
     WHERE ALLOWED_TMPL_USAGES_ID = cp_allowed_tmpl_usages_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_allowed_tmpl_usages_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_ALLOWED_TMPL_USAGES
     WHERE ALLOWED_TMPL_USAGES_ID = cp_allowed_tmpl_usages_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;


    BEGIN

      OPEN lock_csr( p_allowed_tmpl_usages_id, p_object_version_number );
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

      OPEN lchk_csr(p_allowed_tmpl_usages_id);
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
  -- Lock_Row for:OKC_ALLOWED_TMPL_USAGES --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,
    p_object_version_number  IN NUMBER
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
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_object_version_number  => p_object_version_number
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
  -- Update_Row for:OKC_ALLOWED_TMPL_USAGES --
  -------------------------------------
  FUNCTION Update_Row(
    p_allowed_tmpl_usages_id IN NUMBER,
    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_attribute_category     IN VARCHAR2,
    p_attribute1             IN VARCHAR2,
    p_attribute2             IN VARCHAR2,
    p_attribute3             IN VARCHAR2,
    p_attribute4             IN VARCHAR2,
    p_attribute5             IN VARCHAR2,
    p_attribute6             IN VARCHAR2,
    p_attribute7             IN VARCHAR2,
    p_attribute8             IN VARCHAR2,
    p_attribute9             IN VARCHAR2,
    p_attribute10            IN VARCHAR2,
    p_attribute11            IN VARCHAR2,
    p_attribute12            IN VARCHAR2,
    p_attribute13            IN VARCHAR2,
    p_attribute14            IN VARCHAR2,
    p_attribute15            IN VARCHAR2,
    p_object_version_number  IN NUMBER,
    p_last_updated_by        IN NUMBER,
    p_last_update_login      IN NUMBER,
    p_last_update_date       IN DATE
   ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;

    UPDATE OKC_ALLOWED_TMPL_USAGES
     SET TEMPLATE_ID            = p_template_id,
         DOCUMENT_TYPE          = p_document_type,
         DEFAULT_YN             = p_default_yn,
         ATTRIBUTE_CATEGORY     = p_attribute_category,
         ATTRIBUTE1             = p_attribute1,
         ATTRIBUTE2             = p_attribute2,
         ATTRIBUTE3             = p_attribute3,
         ATTRIBUTE4             = p_attribute4,
         ATTRIBUTE5             = p_attribute5,
         ATTRIBUTE6             = p_attribute6,
         ATTRIBUTE7             = p_attribute7,
         ATTRIBUTE8             = p_attribute8,
         ATTRIBUTE9             = p_attribute9,
         ATTRIBUTE10            = p_attribute10,
         ATTRIBUTE11            = p_attribute11,
         ATTRIBUTE12            = p_attribute12,
         ATTRIBUTE13            = p_attribute13,
         ATTRIBUTE14            = p_attribute14,
         ATTRIBUTE15            = p_attribute15,
         OBJECT_VERSION_NUMBER  = p_object_version_number,
         LAST_UPDATED_BY        = p_last_updated_by,
         LAST_UPDATE_LOGIN      = p_last_update_login,
         LAST_UPDATE_DATE       = p_last_update_date
    WHERE ALLOWED_TMPL_USAGES_ID = p_allowed_tmpl_usages_id;

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
  -- Update_Row for:OKC_ALLOWED_TMPL_USAGES --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,

    p_template_id            IN NUMBER := NULL,
    p_document_type          IN VARCHAR2 := NULL,
    p_default_yn             IN VARCHAR2 := NULL,
    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER

   ) IS

    l_template_id            OKC_ALLOWED_TMPL_USAGES.TEMPLATE_ID%TYPE;
    l_document_type          OKC_ALLOWED_TMPL_USAGES.DOCUMENT_TYPE%TYPE;
    l_default_yn             OKC_ALLOWED_TMPL_USAGES.DEFAULT_YN%TYPE;
    l_attribute_category     OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE_CATEGORY%TYPE;
    l_attribute1             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE1%TYPE;
    l_attribute2             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE2%TYPE;
    l_attribute3             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE3%TYPE;
    l_attribute4             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE4%TYPE;
    l_attribute5             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE5%TYPE;
    l_attribute6             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE6%TYPE;
    l_attribute7             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE7%TYPE;
    l_attribute8             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE8%TYPE;
    l_attribute9             OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE9%TYPE;
    l_attribute10            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE10%TYPE;
    l_attribute11            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE11%TYPE;
    l_attribute12            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE12%TYPE;
    l_attribute13            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE13%TYPE;
    l_attribute14            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE14%TYPE;
    l_attribute15            OKC_ALLOWED_TMPL_USAGES.ATTRIBUTE15%TYPE;
    l_object_version_number  OKC_ALLOWED_TMPL_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_last_updated_by        OKC_ALLOWED_TMPL_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_ALLOWED_TMPL_USAGES.LAST_UPDATE_DATE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_object_version_number  => p_object_version_number
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
      p_template_id            => p_template_id,
      p_document_type          => p_document_type,
      p_default_yn             => p_default_yn,
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_attribute_category     => p_attribute_category,
      p_attribute1             => p_attribute1,
      p_attribute2             => p_attribute2,
      p_attribute3             => p_attribute3,
      p_attribute4             => p_attribute4,
      p_attribute5             => p_attribute5,
      p_attribute6             => p_attribute6,
      p_attribute7             => p_attribute7,
      p_attribute8             => p_attribute8,
      p_attribute9             => p_attribute9,
      p_attribute10            => p_attribute10,
      p_attribute11            => p_attribute11,
      p_attribute12            => p_attribute12,
      p_attribute13            => p_attribute13,
      p_attribute14            => p_attribute14,
      p_attribute15            => p_attribute15,
      p_object_version_number  => p_object_version_number,
      x_template_id            => l_template_id,
      x_document_type          => l_document_type,
      x_default_yn             => l_default_yn,
      x_attribute_category     => l_attribute_category,
      x_attribute1             => l_attribute1,
      x_attribute2             => l_attribute2,
      x_attribute3             => l_attribute3,
      x_attribute4             => l_attribute4,
      x_attribute5             => l_attribute5,
      x_attribute6             => l_attribute6,
      x_attribute7             => l_attribute7,
      x_attribute8             => l_attribute8,
      x_attribute9             => l_attribute9,
      x_attribute10            => l_attribute10,
      x_attribute11            => l_attribute11,
      x_attribute12            => l_attribute12,
      x_attribute13            => l_attribute13,
      x_attribute14            => l_attribute14,
      x_attribute15            => l_attribute15
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
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_template_id            => l_template_id,
      p_document_type          => l_document_type,
      p_default_yn             => l_default_yn,
      p_attribute_category     => l_attribute_category,
      p_attribute1             => l_attribute1,
      p_attribute2             => l_attribute2,
      p_attribute3             => l_attribute3,
      p_attribute4             => l_attribute4,
      p_attribute5             => l_attribute5,
      p_attribute6             => l_attribute6,
      p_attribute7             => l_attribute7,
      p_attribute8             => l_attribute8,
      p_attribute9             => l_attribute9,
      p_attribute10            => l_attribute10,
      p_attribute11            => l_attribute11,
      p_attribute12            => l_attribute12,
      p_attribute13            => l_attribute13,
      p_attribute14            => l_attribute14,
      p_attribute15            => l_attribute15
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
      l_object_version_number := Nvl(p_object_version_number, 0) + 1;
    END IF;

    --------------------------------------------
    -- Call the Update_Row for each child record
    --------------------------------------------
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7600: Updating Row', 2);
    END IF;

    x_return_status := Update_Row(
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_template_id            => l_template_id,
      p_document_type          => l_document_type,
      p_default_yn             => l_default_yn,
      p_attribute_category     => l_attribute_category,
      p_attribute1             => l_attribute1,
      p_attribute2             => l_attribute2,
      p_attribute3             => l_attribute3,
      p_attribute4             => l_attribute4,
      p_attribute5             => l_attribute5,
      p_attribute6             => l_attribute6,
      p_attribute7             => l_attribute7,
      p_attribute8             => l_attribute8,
      p_attribute9             => l_attribute9,
      p_attribute10            => l_attribute10,
      p_attribute11            => l_attribute11,
      p_attribute12            => l_attribute12,
      p_attribute13            => l_attribute13,
      p_attribute14            => l_attribute14,
      p_attribute15            => l_attribute15,
      p_object_version_number  => l_object_version_number,
      p_last_updated_by        => l_last_updated_by,
      p_last_update_login      => l_last_update_login,
      p_last_update_date       => l_last_update_date
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
  -- Delete_Row for:OKC_ALLOWED_TMPL_USAGES --
  -------------------------------------
  FUNCTION Delete_Row(
    p_allowed_tmpl_usages_id IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;

    DELETE FROM OKC_ALLOWED_TMPL_USAGES
      WHERE ALLOWED_TMPL_USAGES_ID = p_ALLOWED_TMPL_USAGES_ID;

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
  -- Delete_Row for:OKC_ALLOWED_TMPL_USAGES --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,
    p_object_version_number  IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id,
      p_object_version_number  => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9100: Removing _B row', 2);
    END IF;
    x_return_status := Delete_Row( p_allowed_tmpl_usages_id => p_allowed_tmpl_usages_id );
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

END OKC_ALLOWED_TMPL_USAGES_PVT;

/

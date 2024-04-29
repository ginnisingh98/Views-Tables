--------------------------------------------------------
--  DDL for Package Body OKC_REVIEW_UPLD_TERMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REVIEW_UPLD_TERMS_PVT" AS
/* $Header: OKCVRUTB.pls 120.55.12010000.11 2012/11/20 10:53:47 skavutha ship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REVIEW_UPLD_TERMS_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_MODULE                     CONSTANT   VARCHAR2(250)   := 'okc.plsql.'||G_PKG_NAME||'.';

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
  G_UNASSIGNED_SECTION_CODE    CONSTANT   VARCHAR2(30)  := 'UNASSIGNED';
  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION Get_Seq_Id (
    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    x_REVIEW_UPLD_TERMS_id OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_seq_csr IS
     SELECT OKC_REVIEW_UPLD_TERMS_S1.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF( p_REVIEW_UPLD_TERMS_id IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_REVIEW_UPLD_TERMS_id;
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
  -- FUNCTION get_rec for: OKC_REVIEW_UPLD_TERMS
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_REVIEW_UPLD_TERMS_id IN NUMBER,

    x_document_id              OUT NOCOPY NUMBER,
    x_document_type            OUT NOCOPY VARCHAR2,
    x_object_id                OUT NOCOPY NUMBER,
    x_object_type              OUT NOCOPY VARCHAR2,
    x_object_title             OUT NOCOPY CLOB,
    x_object_text              OUT NOCOPY CLOB,
    x_parent_object_type       OUT NOCOPY VARCHAR2,
    x_parent_id                OUT NOCOPY NUMBER,
    x_article_id               OUT NOCOPY NUMBER,
    x_article_version_id       OUT NOCOPY NUMBER,
    x_label                    OUT NOCOPY VARCHAR2,
    x_display_seq              OUT NOCOPY NUMBER,
    x_action                   OUT NOCOPY VARCHAR2,
    x_error_message_count      OUT NOCOPY NUMBER,
    x_warning_message_count    OUT NOCOPY NUMBER,
    x_object_version_number    OUT NOCOPY NUMBER,
    x_new_parent_id            OUT NOCOPY NUMBER,
    x_upload_level             OUT NOCOPY NUMBER,
    x_created_by               OUT NOCOPY NUMBER,
    x_creation_date            OUT NOCOPY DATE,
    x_last_updated_by          OUT NOCOPY NUMBER,
    x_last_update_login        OUT NOCOPY NUMBER,
    x_last_update_date         OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_REVIEW_TERMS_PK_CSR (cp_REVIEW_UPLD_TERMS_id IN NUMBER) IS
    SELECT
            DOCUMENT_ID,
            DOCUMENT_TYPE,
            OBJECT_ID,
            OBJECT_TYPE,
            OBJECT_TITLE,
            OBJECT_TEXT,
            PARENT_OBJECT_TYPE,
            PARENT_ID,
            ARTICLE_ID,
            ARTICLE_VERSION_ID,
            LABEL,
            DISPLAY_SEQ,
            ACTION,
            ERROR_MESSAGE_COUNT,
            WARNING_MESSAGE_COUNT,
            OBJECT_VERSION_NUMBER,
		NEW_PARENT_ID,
            UPLOAD_LEVEL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
      FROM OKC_REVIEW_UPLD_TERMS t
     WHERE t.REVIEW_UPLD_TERMS_ID = cp_REVIEW_UPLD_TERMS_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    -- Get current database values
    OPEN OKC_REVIEW_TERMS_PK_CSR (p_REVIEW_UPLD_TERMS_id);
    FETCH OKC_REVIEW_TERMS_PK_CSR INTO
            x_document_id,
            x_document_type,
            x_object_id,
            x_object_type,
            x_object_title,
            x_object_text,
            x_parent_object_type,
            x_parent_id,
            x_article_id,
            x_article_version_id,
            x_label,
            x_display_seq,
            x_action,
            x_error_message_count,
            x_warning_message_count,
            x_object_version_number,
            x_new_parent_id,
            x_upload_level,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date;
    IF OKC_REVIEW_TERMS_PK_CSR%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_REVIEW_TERMS_PK_CSR;

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

      IF OKC_REVIEW_TERMS_PK_CSR%ISOPEN THEN
        CLOSE OKC_REVIEW_TERMS_PK_CSR;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_REVIEW_UPLD_TERMS --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER,
    p_object_version_number    IN OUT NOCOPY NUMBER,

    x_document_id              OUT NOCOPY NUMBER,
    x_document_type            OUT NOCOPY VARCHAR2,
    x_object_id                OUT NOCOPY NUMBER,
    x_object_type              OUT NOCOPY CLOB,
    x_object_title             OUT NOCOPY VARCHAR2,
    x_object_text              OUT NOCOPY CLOB,
    x_parent_object_type       OUT NOCOPY VARCHAR2,
    x_parent_id                OUT NOCOPY NUMBER,
    x_article_id               OUT NOCOPY NUMBER,
    x_article_version_id       OUT NOCOPY NUMBER,
    x_label                    OUT NOCOPY VARCHAR2,
    x_display_seq              OUT NOCOPY NUMBER,
    x_action                   OUT NOCOPY VARCHAR2,
    x_error_message_count      OUT NOCOPY NUMBER,
    x_warning_message_count    OUT NOCOPY NUMBER,
    x_new_parent_id            OUT NOCOPY NUMBER,
    x_upload_level             OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number    OKC_REVIEW_UPLD_TERMS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by               OKC_REVIEW_UPLD_TERMS.CREATED_BY%TYPE;
    l_creation_date            OKC_REVIEW_UPLD_TERMS.CREATION_DATE%TYPE;
    l_last_updated_by          OKC_REVIEW_UPLD_TERMS.LAST_UPDATED_BY%TYPE;
    l_last_update_login        OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date         OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;

    IF( p_REVIEW_UPLD_TERMS_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
        x_document_id              => x_document_id,
        x_document_type            => x_document_type,
        x_object_id                => x_object_id,
        x_object_type              => x_object_type,
        x_object_title             => x_object_title,
        x_object_text              => x_object_text,
        x_parent_object_type       => x_parent_object_type,
        x_parent_id                => x_parent_id,
        x_article_id               => x_article_id,
        x_article_version_id       => x_article_version_id,
        x_label                    => x_label,
        x_display_seq              => x_display_seq,
        x_action                   => x_action,
        x_error_message_count      => x_error_message_count,
        x_warning_message_count    => x_warning_message_count,
        x_object_version_number    => l_object_version_number,
        x_new_parent_id            => x_new_parent_id,
	   x_upload_level             => x_upload_level,
        x_created_by               => l_created_by,
        x_creation_date            => l_creation_date,
        x_last_updated_by          => l_last_updated_by,
        x_last_update_login        => l_last_update_login,
        x_last_update_date         => l_last_update_date
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_document_id = G_MISS_NUM) THEN
        x_document_id := NULL;
       ELSIF (p_document_id IS NOT NULL) THEN
        x_document_id := p_document_id;
      END IF;

      IF (p_document_type = G_MISS_CHAR) THEN
        x_document_type := NULL;
       ELSIF (p_document_type IS NOT NULL) THEN
        x_document_type := p_document_type;
      END IF;

      IF (p_object_id = G_MISS_NUM) THEN
        x_object_id := NULL;
       ELSIF (p_object_id IS NOT NULL) THEN
        x_object_id := p_object_id;
      END IF;

      IF (p_object_type = G_MISS_CHAR) THEN
        x_object_type := NULL;
       ELSIF (p_object_type IS NOT NULL) THEN
        x_object_type := p_object_type;
      END IF;

      IF (p_object_title = G_MISS_CHAR) THEN
        x_object_title := NULL;
       ELSIF (p_object_title IS NOT NULL) THEN
        x_object_title := p_object_title;
      END IF;

      IF (p_object_text = G_MISS_CHAR) THEN
        x_object_text := NULL;
       ELSIF (p_object_text IS NOT NULL) THEN
        x_object_text := p_object_text;
      END IF;

      IF (p_parent_object_type = G_MISS_CHAR) THEN
        x_parent_object_type := NULL;
       ELSIF (p_parent_object_type IS NOT NULL) THEN
        x_parent_object_type := p_parent_object_type;
      END IF;

      IF (p_parent_id = G_MISS_NUM) THEN
        x_parent_id := NULL;
       ELSIF (p_parent_id IS NOT NULL) THEN
        x_parent_id := p_parent_id;
      END IF;

      IF (p_article_id = G_MISS_NUM) THEN
        x_article_id := NULL;
       ELSIF (p_article_id IS NOT NULL) THEN
        x_article_id := p_article_id;
      END IF;

      IF (p_article_version_id = G_MISS_NUM) THEN
        x_article_version_id := NULL;
       ELSIF (p_article_version_id IS NOT NULL) THEN
        x_article_version_id := p_article_version_id;
      END IF;

      IF (p_label = G_MISS_CHAR) THEN
        x_label := NULL;
       ELSIF (p_label IS NOT NULL) THEN
        x_label := p_label;
      END IF;

      IF (p_display_seq = G_MISS_NUM) THEN
        x_display_seq := NULL;
       ELSIF (p_display_seq IS NOT NULL) THEN
        x_display_seq := p_display_seq;
      END IF;

      IF (p_action = G_MISS_CHAR) THEN
        x_action := NULL;
       ELSIF (p_action IS NOT NULL) THEN
        x_action := p_action;
      END IF;

      IF (p_error_message_count = G_MISS_NUM) THEN
        x_error_message_count := NULL;
       ELSIF (p_error_message_count IS NOT NULL) THEN
        x_error_message_count := p_error_message_count;
      END IF;

      IF (p_warning_message_count = G_MISS_NUM) THEN
        x_warning_message_count := NULL;
       ELSIF (p_warning_message_count IS NOT NULL) THEN
        x_warning_message_count := p_warning_message_count;
      END IF;


      IF (p_object_version_number IS NULL) THEN
        p_object_version_number := l_object_version_number;
      END IF;

      IF (p_new_parent_id = G_MISS_NUM) THEN
        x_new_parent_id := NULL;
       ELSIF (p_new_parent_id IS NOT NULL) THEN
        x_new_parent_id := p_new_parent_id;
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
  -- Validate_Attributes for: OKC_REVIEW_UPLD_TERMS --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER

  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
/* ?? uncomment next part after you check and change this foreign key validation

    CURSOR l_REVIEW_UPLD_TERMS_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??REVIEW_UPLD_TERMS_ID?? = p_REVIEW_UPLD_TERMS_id;

    CURSOR l_document_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??DOCUMENT_ID?? = p_document_id;

    CURSOR l_object_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??OBJECT_ID?? = p_object_id;

    CURSOR l_parent_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??PARENT_ID?? = p_parent_id;

    CURSOR l_article_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??ARTICLE_ID?? = p_article_id;

    CURSOR l_article_version_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??ARTICLE_VERSION_ID?? = p_article_version_id;

*/
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;

    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: static values and range validation', 2);
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1900: lookup codes validation', 2);
      END IF;
/* ?? uncomment next part after you check and change this lokkup codes validation

*/
    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;
/* ?? uncomment next part after you check and change this foreign key validation

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute REVIEW_UPLD_TERMS_ID ', 2);
      END IF;
      IF p_REVIEW_UPLD_TERMS_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_REVIEW_UPLD_TERMS_id_csr;
        FETCH l_REVIEW_UPLD_TERMS_id_csr INTO l_dummy_var;
        CLOSE l_REVIEW_UPLD_TERMS_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute REVIEW_UPLD_TERMS_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REVIEW_UPLD_TERMS_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute DOCUMENT_ID ', 2);
      END IF;
      IF p_document_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_document_id_csr;
        FETCH l_document_id_csr INTO l_dummy_var;
        CLOSE l_document_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute DOCUMENT_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DOCUMENT_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute OBJECT_ID ', 2);
      END IF;
      IF p_object_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_object_id_csr;
        FETCH l_object_id_csr INTO l_dummy_var;
        CLOSE l_object_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute OBJECT_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OBJECT_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute PARENT_ID ', 2);
      END IF;
      IF p_parent_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_parent_id_csr;
        FETCH l_parent_id_csr INTO l_dummy_var;
        CLOSE l_parent_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute PARENT_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PARENT_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ARTICLE_ID ', 2);
      END IF;
      IF p_article_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_article_id_csr;
        FETCH l_article_id_csr INTO l_dummy_var;
        CLOSE l_article_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute ARTICLE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ARTICLE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ARTICLE_VERSION_ID ', 2);
      END IF;
      IF p_article_version_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_article_version_id_csr;
        FETCH l_article_version_id_csr INTO l_dummy_var;
        CLOSE l_article_version_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute ARTICLE_VERSION_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ARTICLE_VERSION_ID');
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

/* ?? uncomment next part after you check and change this foreign key validation

      IF l_REVIEW_UPLD_TERMS_id_csr%ISOPEN THEN
        CLOSE l_REVIEW_UPLD_TERMS_id_csr;
      END IF;

      IF l_document_id_csr%ISOPEN THEN
        CLOSE l_document_id_csr;
      END IF;

      IF l_object_id_csr%ISOPEN THEN
        CLOSE l_object_id_csr;
      END IF;

      IF l_parent_id_csr%ISOPEN THEN
        CLOSE l_parent_id_csr;
      END IF;

      IF l_article_id_csr%ISOPEN THEN
        CLOSE l_article_id_csr;
      END IF;

      IF l_article_version_id_csr%ISOPEN THEN
        CLOSE l_article_version_id_csr;
      END IF;

*/
      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_REVIEW_UPLD_TERMS --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_document_id              => p_document_id,
      p_document_type            => p_document_type,
      p_object_id                => p_object_id,
      p_object_type              => p_object_type,
      p_object_title             => p_object_title,
      p_object_text              => p_object_text,
      p_parent_object_type       => p_parent_object_type,
      p_parent_id                => p_parent_id,
      p_article_id               => p_article_id,
      p_article_version_id       => p_article_version_id,
      p_label                    => p_label,
      p_display_seq              => p_display_seq,
      p_action                   => p_action,
      p_error_message_count      => p_error_message_count,
      p_warning_message_count    => p_warning_message_count,
      p_new_parent_id            => p_new_parent_id,
      p_upload_level             => p_upload_level

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
  -- validate_row for:OKC_REVIEW_UPLD_TERMS --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER,


    p_object_version_number    IN NUMBER
  ) IS
      l_document_id              OKC_REVIEW_UPLD_TERMS.DOCUMENT_ID%TYPE;
      l_document_type            OKC_REVIEW_UPLD_TERMS.DOCUMENT_TYPE%TYPE;
      l_object_id                OKC_REVIEW_UPLD_TERMS.OBJECT_ID%TYPE;
      l_object_type              OKC_REVIEW_UPLD_TERMS.OBJECT_TYPE%TYPE;
      l_object_title             OKC_REVIEW_UPLD_TERMS.OBJECT_TITLE%TYPE;
      l_object_text              OKC_REVIEW_UPLD_TERMS.OBJECT_TEXT%TYPE;
      l_parent_object_type       OKC_REVIEW_UPLD_TERMS.PARENT_OBJECT_TYPE%TYPE;
      l_parent_id                OKC_REVIEW_UPLD_TERMS.PARENT_ID%TYPE;
      l_article_id               OKC_REVIEW_UPLD_TERMS.ARTICLE_ID%TYPE;
      l_article_version_id       OKC_REVIEW_UPLD_TERMS.ARTICLE_VERSION_ID%TYPE;
      l_label                    OKC_REVIEW_UPLD_TERMS.LABEL%TYPE;
      l_display_seq              OKC_REVIEW_UPLD_TERMS.DISPLAY_SEQ%TYPE;
      l_action                   OKC_REVIEW_UPLD_TERMS.ACTION%TYPE;
      l_error_message_count      OKC_REVIEW_UPLD_TERMS.ERROR_MESSAGE_COUNT%TYPE;
      l_warning_message_count    OKC_REVIEW_UPLD_TERMS.WARNING_MESSAGE_COUNT%TYPE;
      l_object_version_number    OKC_REVIEW_UPLD_TERMS.OBJECT_VERSION_NUMBER%TYPE;
      l_new_parent_id            OKC_REVIEW_UPLD_TERMS.NEW_PARENT_ID%TYPE;
	 l_upload_level             OKC_REVIEW_UPLD_TERMS.UPLOAD_LEVEL%TYPE;
      l_created_by               OKC_REVIEW_UPLD_TERMS.CREATED_BY%TYPE;
      l_creation_date            OKC_REVIEW_UPLD_TERMS.CREATION_DATE%TYPE;
      l_last_updated_by          OKC_REVIEW_UPLD_TERMS.LAST_UPDATED_BY%TYPE;
      l_last_update_login        OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date         OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_document_id              => p_document_id,
      p_document_type            => p_document_type,
      p_object_id                => p_object_id,
      p_object_type              => p_object_type,
      p_object_title             => p_object_title,
      p_object_text              => p_object_text,
      p_parent_object_type       => p_parent_object_type,
      p_parent_id                => p_parent_id,
      p_article_id               => p_article_id,
      p_article_version_id       => p_article_version_id,
      p_label                    => p_label,
      p_display_seq              => p_display_seq,
      p_action                   => p_action,
      p_error_message_count      => p_error_message_count,
      p_warning_message_count    => p_warning_message_count,
      p_new_parent_id            => p_new_parent_id,
      p_upload_level             => p_upload_level,
      p_object_version_number    => l_object_version_number,
      x_document_id              => l_document_id,
      x_document_type            => l_document_type,
      x_object_id                => l_object_id,
      x_object_type              => l_object_type,
      x_object_title             => l_object_title,
      x_object_text              => l_object_text,
      x_parent_object_type       => l_parent_object_type,
      x_parent_id                => l_parent_id,
      x_article_id               => l_article_id,
      x_article_version_id       => l_article_version_id,
      x_label                    => l_label,
      x_display_seq              => l_display_seq,
      x_action                   => l_action,
      x_error_message_count      => l_error_message_count,
      x_warning_message_count    => l_warning_message_count,
      x_new_parent_id            => l_new_parent_id,
      x_upload_level             => l_upload_level
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    l_object_version_number    := p_object_version_number   ;
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_document_id              => l_document_id,
      p_document_type            => l_document_type,
      p_object_id                => l_object_id,
      p_object_type              => l_object_type,
      p_object_title             => l_object_title,
      p_object_text              => l_object_text,
      p_parent_object_type       => l_parent_object_type,
      p_parent_id                => l_parent_id,
      p_article_id               => l_article_id,
      p_article_version_id       => l_article_version_id,
      p_label                    => l_label,
      p_display_seq              => l_display_seq,
      p_action                   => l_action,
      p_error_message_count      => l_error_message_count,
      p_warning_message_count    => l_warning_message_count,
      p_new_parent_id            => l_new_parent_id,
      p_upload_level             => l_upload_level
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
  -- Insert_Row for:OKC_REVIEW_UPLD_TERMS --
  -------------------------------------
  FUNCTION Insert_Row(
    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER,
    p_object_version_number    IN NUMBER,
    p_created_by               IN NUMBER,
    p_creation_date            IN DATE,
    p_last_updated_by          IN NUMBER,
    p_last_update_login        IN NUMBER,
    p_last_update_date         IN DATE

  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;

    INSERT INTO OKC_REVIEW_UPLD_TERMS(
        REVIEW_UPLD_TERMS_ID,
        DOCUMENT_ID,
        DOCUMENT_TYPE,
        OBJECT_ID,
        OBJECT_TYPE,
        OBJECT_TITLE,
        OBJECT_TEXT,
        PARENT_OBJECT_TYPE,
        PARENT_ID,
        ARTICLE_ID,
        ARTICLE_VERSION_ID,
        LABEL,
        DISPLAY_SEQ,
        ACTION,
        ERROR_MESSAGE_COUNT,
        WARNING_MESSAGE_COUNT,
        OBJECT_VERSION_NUMBER,
	  NEW_PARENT_ID,
        UPLOAD_LEVEL,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        p_REVIEW_UPLD_TERMS_id,
        p_document_id,
        p_document_type,
        p_object_id,
        p_object_type,
        p_object_title,
        p_object_text,
        p_parent_object_type,
        p_parent_id,
        p_article_id,
        p_article_version_id,
        p_label,
        p_display_seq,
        p_action,
        p_error_message_count,
        p_warning_message_count,
        p_object_version_number,
        p_new_parent_id,
        p_upload_level,
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
  -- Insert_Row for:OKC_REVIEW_UPLD_TERMS --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER,

    x_REVIEW_UPLD_TERMS_id OUT NOCOPY NUMBER

  ) IS

    l_object_version_number    OKC_REVIEW_UPLD_TERMS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by               OKC_REVIEW_UPLD_TERMS.CREATED_BY%TYPE;
    l_creation_date            OKC_REVIEW_UPLD_TERMS.CREATION_DATE%TYPE;
    l_last_updated_by          OKC_REVIEW_UPLD_TERMS.LAST_UPDATED_BY%TYPE;
    l_last_update_login        OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date         OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;

    --- Setting item attributes
    -- Set primary key value
    IF( p_REVIEW_UPLD_TERMS_id IS NULL ) THEN
      x_return_status := Get_Seq_Id(
        p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
        x_REVIEW_UPLD_TERMS_id => x_REVIEW_UPLD_TERMS_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
      x_REVIEW_UPLD_TERMS_id := p_REVIEW_UPLD_TERMS_id;
    END IF;
    -- Set Internal columns
    l_object_version_number    := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;


    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_REVIEW_UPLD_TERMS_id => x_REVIEW_UPLD_TERMS_id,
      p_document_id              => p_document_id,
      p_document_type            => p_document_type,
      p_object_id                => p_object_id,
      p_object_type              => p_object_type,
      p_object_title             => p_object_title,
      p_object_text              => p_object_text,
      p_parent_object_type       => p_parent_object_type,
      p_parent_id                => p_parent_id,
      p_article_id               => p_article_id,
      p_article_version_id       => p_article_version_id,
      p_label                    => p_label,
      p_display_seq              => p_display_seq,
      p_action                   => p_action,
      p_error_message_count      => p_error_message_count,
      p_warning_message_count    => p_warning_message_count,
      p_new_parent_id            => p_new_parent_id,
      p_upload_level             => p_upload_level
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
      p_REVIEW_UPLD_TERMS_id => x_REVIEW_UPLD_TERMS_id,
      p_document_id              => p_document_id,
      p_document_type            => p_document_type,
      p_object_id                => p_object_id,
      p_object_type              => p_object_type,
      p_object_title             => p_object_title,
      p_object_text              => p_object_text,
      p_parent_object_type       => p_parent_object_type,
      p_parent_id                => p_parent_id,
      p_article_id               => p_article_id,
      p_article_version_id       => p_article_version_id,
      p_label                    => p_label,
      p_display_seq              => p_display_seq,
      p_action                   => p_action,
      p_error_message_count      => p_error_message_count,
      p_warning_message_count    => p_warning_message_count,
      p_object_version_number    => l_object_version_number,
      p_new_parent_id            => p_new_parent_id,
      p_upload_level             => p_upload_level,
      p_created_by               => l_created_by,
      p_creation_date            => l_creation_date,
      p_last_updated_by          => l_last_updated_by,
      p_last_update_login        => l_last_update_login,
      p_last_update_date         => l_last_update_date
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
  -- Lock_Row for:OKC_REVIEW_UPLD_TERMS --
  -----------------------------------
  FUNCTION Lock_Row(
    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_object_version_number    IN NUMBER
  ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);
    l_object_version_number       OKC_REVIEW_UPLD_TERMS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;

    CURSOR lock_csr (cp_REVIEW_UPLD_TERMS_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_REVIEW_UPLD_TERMS
     WHERE REVIEW_UPLD_TERMS_ID = cp_REVIEW_UPLD_TERMS_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_REVIEW_UPLD_TERMS_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_REVIEW_UPLD_TERMS
     WHERE REVIEW_UPLD_TERMS_ID = cp_REVIEW_UPLD_TERMS_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;


    BEGIN

      OPEN lock_csr( p_REVIEW_UPLD_TERMS_id, p_object_version_number );
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

      OPEN lchk_csr(p_REVIEW_UPLD_TERMS_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_DELETED);
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
  -- Lock_Row for:OKC_REVIEW_UPLD_TERMS --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_object_version_number    IN NUMBER
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
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_object_version_number    => p_object_version_number
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
  -- Update_Row for:OKC_REVIEW_UPLD_TERMS --
  -------------------------------------
  FUNCTION Update_Row(
    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER,
    p_object_version_number    IN NUMBER,
    p_last_updated_by          IN NUMBER,
    p_last_update_login        IN NUMBER,
    p_last_update_date         IN DATE
   ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;

    UPDATE OKC_REVIEW_UPLD_TERMS
     SET DOCUMENT_ID              = p_document_id,
         DOCUMENT_TYPE            = p_document_type,
         OBJECT_ID                = p_object_id,
         OBJECT_TYPE              = p_object_type,
         OBJECT_TITLE             = p_object_title,
         OBJECT_TEXT              = p_object_text,
         PARENT_OBJECT_TYPE       = p_parent_object_type,
         PARENT_ID                = p_parent_id,
         ARTICLE_ID               = p_article_id,
         ARTICLE_VERSION_ID       = p_article_version_id,
         LABEL                    = p_label,
         DISPLAY_SEQ              = p_display_seq,
         ACTION                   = p_action,
         ERROR_MESSAGE_COUNT      = p_error_message_count,
         WARNING_MESSAGE_COUNT    = p_warning_message_count,
         OBJECT_VERSION_NUMBER    = p_object_version_number,
         NEW_PARENT_ID            = p_new_parent_id,
         UPLOAD_LEVEL             = p_upload_level,
         LAST_UPDATED_BY          = p_last_updated_by,
         LAST_UPDATE_LOGIN        = p_last_update_login,
         LAST_UPDATE_DATE         = p_last_update_date
    WHERE REVIEW_UPLD_TERMS_ID = p_REVIEW_UPLD_TERMS_id;

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
  -- Update_Row for:OKC_REVIEW_UPLD_TERMS --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,

    p_document_id              IN NUMBER := NULL,
    p_document_type            IN VARCHAR2 := NULL,
    p_object_id                IN NUMBER := NULL,
    p_object_type              IN VARCHAR2 := NULL,
    p_object_title             IN CLOB := NULL,
    p_object_text              IN CLOB := NULL,
    p_parent_object_type       IN VARCHAR2 := NULL,
    p_parent_id                IN NUMBER := NULL,
    p_article_id               IN NUMBER := NULL,
    p_article_version_id       IN NUMBER := NULL,
    p_label                    IN VARCHAR2 := NULL,
    p_display_seq              IN NUMBER := NULL,
    p_action                   IN VARCHAR2 := NULL,
    p_error_message_count      IN NUMBER := NULL,
    p_warning_message_count    IN NUMBER := NULL,
    p_new_parent_id            IN NUMBER := NULL,
    p_upload_level             IN NUMBER := NULL,
    p_object_version_number    IN NUMBER

   ) IS

    l_document_id              OKC_REVIEW_UPLD_TERMS.DOCUMENT_ID%TYPE;
    l_document_type            OKC_REVIEW_UPLD_TERMS.DOCUMENT_TYPE%TYPE;
    l_object_id                OKC_REVIEW_UPLD_TERMS.OBJECT_ID%TYPE;
    l_object_type              OKC_REVIEW_UPLD_TERMS.OBJECT_TYPE%TYPE;
    l_object_title             OKC_REVIEW_UPLD_TERMS.OBJECT_TITLE%TYPE;
    l_object_text              OKC_REVIEW_UPLD_TERMS.OBJECT_TEXT%TYPE;
    l_parent_object_type       OKC_REVIEW_UPLD_TERMS.PARENT_OBJECT_TYPE%TYPE;
    l_parent_id                OKC_REVIEW_UPLD_TERMS.PARENT_ID%TYPE;
    l_article_id               OKC_REVIEW_UPLD_TERMS.ARTICLE_ID%TYPE;
    l_article_version_id       OKC_REVIEW_UPLD_TERMS.ARTICLE_VERSION_ID%TYPE;
    l_label                    OKC_REVIEW_UPLD_TERMS.LABEL%TYPE;
    l_display_seq              OKC_REVIEW_UPLD_TERMS.DISPLAY_SEQ%TYPE;
    l_action                   OKC_REVIEW_UPLD_TERMS.ACTION%TYPE;
    l_error_message_count      OKC_REVIEW_UPLD_TERMS.ERROR_MESSAGE_COUNT%TYPE;
    l_warning_message_count    OKC_REVIEW_UPLD_TERMS.WARNING_MESSAGE_COUNT%TYPE;
    l_object_version_number    OKC_REVIEW_UPLD_TERMS.OBJECT_VERSION_NUMBER%TYPE;
    l_new_parent_id            OKC_REVIEW_UPLD_TERMS.NEW_PARENT_ID%TYPE;
    l_upload_level             OKC_REVIEW_UPLD_TERMS.UPLOAD_LEVEL%TYPE;
    l_last_updated_by          OKC_REVIEW_UPLD_TERMS.LAST_UPDATED_BY%TYPE;
    l_last_update_login        OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date         OKC_REVIEW_UPLD_TERMS.LAST_UPDATE_DATE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_object_version_number    => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Setting attributes', 2);
    END IF;

    l_object_version_number    := p_object_version_number;
    x_return_status := Set_Attributes(
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_document_id              => p_document_id,
      p_document_type            => p_document_type,
      p_object_id                => p_object_id,
      p_object_type              => p_object_type,
      p_object_title             => p_object_title,
      p_object_text              => p_object_text,
      p_parent_object_type       => p_parent_object_type,
      p_parent_id                => p_parent_id,
      p_article_id               => p_article_id,
      p_article_version_id       => p_article_version_id,
      p_label                    => p_label,
      p_display_seq              => p_display_seq,
      p_action                   => p_action,
      p_error_message_count      => p_error_message_count,
      p_warning_message_count    => p_warning_message_count,
      p_object_version_number    => l_object_version_number,
      p_new_parent_id            => p_new_parent_id,
      p_upload_level             => p_upload_level,
      x_document_id              => l_document_id,
      x_document_type            => l_document_type,
      x_object_id                => l_object_id,
      x_object_type              => l_object_type,
      x_object_title             => l_object_title,
      x_object_text              => l_object_text,
      x_parent_object_type       => l_parent_object_type,
      x_parent_id                => l_parent_id,
      x_article_id               => l_article_id,
      x_article_version_id       => l_article_version_id,
      x_label                    => l_label,
      x_display_seq              => l_display_seq,
      x_action                   => l_action,
      x_error_message_count      => l_error_message_count,
      x_warning_message_count    => l_warning_message_count,
      x_new_parent_id            => l_new_parent_id,
      x_upload_level             => l_upload_level
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
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_document_id              => l_document_id,
      p_document_type            => l_document_type,
      p_object_id                => l_object_id,
      p_object_type              => l_object_type,
      p_object_title             => l_object_title,
      p_object_text              => l_object_text,
      p_parent_object_type       => l_parent_object_type,
      p_parent_id                => l_parent_id,
      p_article_id               => l_article_id,
      p_article_version_id       => l_article_version_id,
      p_label                    => l_label,
      p_display_seq              => l_display_seq,
      p_action                   => l_action,
      p_error_message_count      => l_error_message_count,
      p_warning_message_count    => l_warning_message_count,
      p_new_parent_id            => l_new_parent_id,
      p_upload_level             => l_upload_level
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
--    IF Nvl(p_object_version_number, 0) >= 0 THEN
--      l_object_version_number := Nvl( p_object_version_number, 0) + 1;
--    END IF;
    l_object_version_number := l_object_version_number + 1; -- l_object_version_number should not be NULL because of Set_Attribute

    --------------------------------------------
    -- Call the Update_Row for each child record
    --------------------------------------------
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7600: Updating Row', 2);
    END IF;

    x_return_status := Update_Row(
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_document_id              => l_document_id,
      p_document_type            => l_document_type,
      p_object_id                => l_object_id,
      p_object_type              => l_object_type,
      p_object_title             => l_object_title,
      p_object_text              => l_object_text,
      p_parent_object_type       => l_parent_object_type,
      p_parent_id                => l_parent_id,
      p_article_id               => l_article_id,
      p_article_version_id       => l_article_version_id,
      p_label                    => l_label,
      p_display_seq              => l_display_seq,
      p_action                   => l_action,
      p_error_message_count      => l_error_message_count,
      p_warning_message_count    => l_warning_message_count,
      p_object_version_number    => l_object_version_number,
      p_new_parent_id            => l_new_parent_id,
      p_upload_level             => l_upload_level,
      p_last_updated_by          => l_last_updated_by,
      p_last_update_login        => l_last_update_login,
      p_last_update_date         => l_last_update_date
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
  -- Delete_Row for:OKC_REVIEW_UPLD_TERMS --
  -------------------------------------
  FUNCTION Delete_Row(
    p_REVIEW_UPLD_TERMS_id IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;

    DELETE FROM OKC_REVIEW_UPLD_TERMS
      WHERE REVIEW_UPLD_TERMS_ID = p_REVIEW_UPLD_TERMS_ID;

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
  -- Delete_Row for:OKC_REVIEW_UPLD_TERMS --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_object_version_number    IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id,
      p_object_version_number    => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9100: Removing _B row', 2);
    END IF;
    x_return_status := Delete_Row( p_REVIEW_UPLD_TERMS_id => p_REVIEW_UPLD_TERMS_id );
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


  PROCEDURE Accept_Changes (
      p_api_version      IN  NUMBER,
	 p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_mode             IN  VARCHAR2 := 'NORMAL',

      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,
      p_validate_commit  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_string IN VARCHAR2 := NULL,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
      ) IS


    TYPE rut_id_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.REVIEW_UPLD_TERMS_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE upld_level_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.UPLOAD_LEVEL%TYPE INDEX BY BINARY_INTEGER;
    TYPE obj_id_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.OBJECT_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE obj_type_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.OBJECT_TYPE%TYPE INDEX BY BINARY_INTEGER;
    TYPE obj_text_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.OBJECT_TEXT%TYPE INDEX BY BINARY_INTEGER;
    TYPE pobj_type_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.PARENT_OBJECT_TYPE%TYPE INDEX BY BINARY_INTEGER;
    TYPE pobj_id_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.PARENT_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE art_id_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE art_ver_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE ovn_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER;
    TYPE label_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.LABEL%TYPE INDEX BY BINARY_INTEGER;
    TYPE disp_seq_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.DISPLAY_SEQ%TYPE INDEX BY BINARY_INTEGER;
    TYPE action_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.ACTION%TYPE INDEX BY BINARY_INTEGER;
    TYPE non_std_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.NON_STANDARD_FLAG%TYPE INDEX BY BINARY_INTEGER;
    TYPE mandatory_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.MANDATORY_FLAG%TYPE INDEX BY BINARY_INTEGER;
    TYPE lock_text_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.LOCK_TEXT%TYPE INDEX BY BINARY_INTEGER;
    TYPE new_parent_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.NEW_PARENT_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE obj_title_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.OBJECT_TITLE%TYPE INDEX BY BINARY_INTEGER;
    TYPE orut_id_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.OLD_REVIEW_UPLD_TERMS_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE curr_obj_id_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE curr_disp_seq_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    --2 way word sync with clause edit
    TYPE obj_text_wml_tab IS TABLE OF OKC_ARTICLE_VERSIONS.ARTICLE_TEXT_IN_WORD%TYPE INDEX BY BINARY_INTEGER;

    rut_ids rut_id_tab;
    upld_levels upld_level_tab;
    obj_ids obj_id_tab;
    obj_types obj_type_tab;
    obj_texts obj_text_tab;
    pobj_types pobj_type_tab;
    pobj_ids pobj_id_tab;
    art_ids art_id_tab;
    art_vers art_ver_tab;
    ovns ovn_tab;
    labels label_tab;
    disp_seqs disp_seq_tab;
    actions action_tab;
    non_stds non_std_tab;
    mandatorys mandatory_tab;
    lock_texts lock_text_tab;
    new_parents new_parent_tab;
    obj_titles obj_title_tab;
    orut_ids orut_id_tab;
    curr_obj_ids curr_obj_id_tab;
    curr_disp_seqs curr_disp_seq_tab;
    --2 way word sync with clause edit
    obj_texts_wml obj_text_wml_tab;

   CURSOR accepted_terms_csr IS
   SELECT review_upld_terms_id,
          level upload_level,
          object_id,
          object_type,
          object_text,
          parent_object_type,
          parent_id,
          article_id,
          article_version_id,
          object_version_number,
          label,
          display_seq,
          action,
          non_standard_flag,
          mandatory_flag,
          lock_text,
          new_parent_id,
          object_title,
          old_review_upld_terms_id
    FROM okc_review_upld_terms
    WHERE document_id = p_document_id
    AND   document_type = p_document_type
    CONNECT BY PRIOR review_upld_terms_id = new_parent_id
    START WITH new_parent_id is null
    ORDER SIBLINGS BY review_upld_terms_id;

    --2 way word sync with clause edit

   CURSOR accepted_terms_with_wml_csr IS
   SELECT review_upld_terms_id,
          level upload_level,
          object_id,
          object_type,
          object_text,
          parent_object_type,
          parent_id,
          article_id,
          article_version_id,
          object_version_number,
          label,
          display_seq,
          action,
          non_standard_flag,
          mandatory_flag,
          lock_text,
          new_parent_id,
          object_title,
          old_review_upld_terms_id --,
          --OKC_WORD_DOWNLOAD_UPLOAD.UPLOAD_POST_PROCESSOR(p_document_id,p_document_type,object_id)
          --OKC_WORD_DOWNLOAD_UPLOAD.GET_LATEST_WMLBLOB(p_document_id,p_document_type, object_id)
    FROM okc_review_upld_terms
    WHERE document_id = p_document_id
    AND   document_type = p_document_type
    CONNECT BY PRIOR review_upld_terms_id = new_parent_id
    START WITH new_parent_id is null
    ORDER SIBLINGS BY review_upld_terms_id;


     cursor current_num_scheme is
    select doc_numbering_scheme from okc_template_usages
    where document_type = p_document_type and
          document_id = p_document_id;

    CURSOR is_article_ibr (p_review_upld_terms_id NUMBER) is
    SELECT 'Y'
      from okc_article_versions av, okc_review_upld_terms ar
      where av.article_version_id = ar.article_version_id
            and av.insert_by_reference = 'Y'
            and ar.review_upld_terms_id= p_review_upld_terms_id;

    CURSOR is_article_mandatory (p_review_upld_terms_id NUMBER) is
    SELECT 'Y'
      from okc_k_articles_b akb, okc_review_upld_terms ar
      where akb.id = ar.object_id
            and akb.mandatory_yn = 'Y'
            and ar.review_upld_terms_id= p_review_upld_terms_id;

    CURSOR is_article_text_locked (p_review_upld_terms_id NUMBER) is
    SELECT 'Y'
      from okc_article_versions av, okc_review_upld_terms ar
      where av.article_version_id = ar.article_version_id
            and av.lock_text = 'Y'
            and ar.review_upld_terms_id= p_review_upld_terms_id;

    cursor get_clause_type_csr(p_review_upld_terms_id NUMBER) is
       SELECT
	     aa.article_type
       from okc_articles_all aa, okc_review_upld_terms rev
	  where
	     rev.article_id = aa.article_id
		and rev.review_upld_terms_id = p_review_upld_terms_id;

    is_ibr VARCHAR2(1) := 'N';
    is_lock_text VARCHAR2(1) := 'N';
    is_mandatory_text VARCHAR2(1) := 'N';
    l_sec_with_mandatory_clause VARCHAR2(1) := 'N';
	 l_display_sequence NUMBER := 0;
       l_cat_id NUMBER;
       l_article_version_id  NUMBER;
    l_api_name         CONSTANT VARCHAR2(30) := 'Accept_Changes';
    l_api_version                 CONSTANT NUMBER := 1;
    l_ref_id NUMBER;
    l_ref_type VARCHAR2(30);
    l_scn_id NUMBER;
    l_user_access VARCHAR2(30);
    l_parent_id NUMBER;
    l_doc_num_scheme NUMBER;
    l_parent_object_title OKC_SECTIONS_B.HEADING%TYPE;
    l_parent_object_id OKC_REVIEW_UPLD_TERMS.OBJECT_ID%TYPE;
    l_article_type OKC_ARTICLES_ALL.ARTICLE_TYPE%TYPE;
    l_root_obj_type OKC_REVIEW_UPLD_TERMS.OBJECT_TYPE%TYPE;
    l_scn_code OKC_SECTIONS_B.SCN_CODE%TYPE;
    -- 2 way word sync with clause edit
    l_prof_value VARCHAR2(1);
    l_wml_i     NUMBER;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10000: Entering Accept_Changes');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_accept_changes;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_STD','N') THEN
      l_user_access := 'STD_AUTHOR';
      IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_NON_STD','N') THEN
	   l_user_access := 'NON_STD_AUTHOR';
        IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_SUPERUSER','N') THEN
	     l_user_access := 'SUPER_USER';
        END IF;
      END IF;
    ELSE
      l_user_access := 'NO_ACCESS';
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10200: After access test, l_user_access='||l_user_access);
    END IF;

    IF l_user_access NOT IN ('NON_STD_AUTHOR','SUPER_USER') THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10300: User has no privileges to accept changes');
      END IF;

    END IF;
--2 way word sync with clause edit begins
    l_prof_value := OKC_WORD_DOWNLOAD_UPLOAD.GET_WORD_SYNC_PROFILE;
    IF l_prof_value = 'Y' THEN
      OPEN accepted_terms_with_wml_csr;
      UPDATE okc_word_sync_t
      SET cat_id = NULL
      WHERE doc_id = p_document_id
      AND doc_type = p_document_type
      AND action = 'ADDEDASSIGNED';
      FETCH accepted_terms_with_wml_csr BULK COLLECT INTO
           rut_ids,
           upld_levels,
           obj_ids,
           obj_types,
           obj_texts,
           pobj_types,
           pobj_ids,
           art_ids,
           art_vers,
           ovns,
           labels,
           disp_seqs,
           actions,
           non_stds,
           mandatorys,
           lock_texts,
           new_parents,
           obj_titles,
           orut_ids;
           --obj_texts_wml;
      CLOSE accepted_terms_with_wml_csr;

      FOR i IN rut_ids.FIRST .. rut_ids.LAST
      LOOP
          IF obj_types(i) = 'ARTICLE' THEN
              obj_texts_wml(i) :=  OKC_WORD_DOWNLOAD_UPLOAD.GET_LATEST_WMLBLOB(p_document_id,p_document_type, obj_ids(i));
          ELSE
              obj_texts_wml(i) := NULL;
          END IF;
      END LOOP;

    ELSE
    --2 way word sync with clause edit ends
    OPEN accepted_terms_csr;
    FETCH accepted_terms_csr BULK COLLECT INTO
           rut_ids,
           upld_levels,
           obj_ids,
           obj_types,
           obj_texts,
           pobj_types,
           pobj_ids,
           art_ids,
           art_vers,
           ovns,
           labels,
           disp_seqs,
           actions,
           non_stds,
           mandatorys,
           lock_texts,
           new_parents,
           obj_titles,
           orut_ids;
    CLOSE accepted_terms_csr;
    END IF;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10400: After bulk collect of accepted_terms_csr');
    END IF;

    IF rut_ids.COUNT > 0 THEN
      FOR i IN rut_ids.FIRST .. rut_ids.LAST
      LOOP
        curr_obj_ids(rut_ids(i)) := obj_ids(i);
        curr_disp_seqs(rut_ids(i)) := 0;
	 END LOOP;

    END IF; --IF rut_ids.COUNT > 0 THEN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10500: After looping thru new_parents_csr');
    END IF;

    IF rut_ids.COUNT > 0 THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10600: Review records exist before looping');
      END IF;

      FOR i IN rut_ids.FIRST .. rut_ids.LAST
      LOOP

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10700: Looping thru review records');
        END IF;

        l_ref_id := null;
	   IF (new_parents(i) is not null and pobj_types(i) = 'SECTION') THEN
          l_ref_id := curr_obj_ids(new_parents(i));
	   END IF;

        pobj_ids(i) := l_ref_id;

        IF new_parents(i) is not NULL THEN
          BEGIN
            l_display_sequence := curr_disp_seqs(new_parents(i))+10;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_display_sequence := 10;
          END;

          curr_disp_seqs(new_parents(i)) := l_display_sequence;
          disp_seqs(i) := l_display_sequence;
	   END IF;

        IF actions(i) = 'ADDED' THEN

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10900: Action is ADDED');
          END IF;

          IF obj_types(i) = 'SECTION' THEN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11000: Object Type is SECTION');
            END IF;

            IF (to_char(obj_titles(i)) =
                  Okc_Util.Decode_Lookup('OKC_ARTICLE_SECTION',G_UNASSIGNED_SECTION_CODE)) THEN

              l_scn_code := G_UNASSIGNED_SECTION_CODE;

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11100: Section is Unassigned');
              END IF;
            ELSE
              l_scn_code := null;
            END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11200: Before calling OKC_TERMS_SECTIONS_GRP.add_section');
            END IF;

            OKC_TERMS_SECTIONS_GRP.add_section(
                p_api_version                  => p_api_version,
                p_init_msg_list                => p_init_msg_list,
                p_validation_level             => p_validation_level,
                p_validate_commit              => p_validate_commit,
                p_validation_string            => p_validation_string,
                p_commit                       => p_commit,
                p_mode                         => p_mode,
                x_return_status                => x_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data,
                p_id                           => NULL,
                p_ref_scn_id                   => l_ref_id,  -- Section ID fo section which was
                p_ref_point                    => 'S', --Possible values 'A'=After,'B'=Before,'S' = Subsection
                p_heading                      => substr(to_char(obj_titles(i)),1,80),
                p_description                  => NULL,
                p_document_type                => p_document_type,
                p_document_id                  => p_document_id,
                p_scn_code                     => l_scn_code,
                p_print_yn                     => 'Y',
                x_id                           => l_scn_id);

                curr_obj_ids(rut_ids(i)) := l_scn_id;
                obj_ids(i) := l_scn_id;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11300: After calling OKC_TERMS_SECTIONS_GRP.add_section');
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11400: lscn_id ='||l_scn_id);
            END IF;

          ELSIF obj_types(i) = 'ARTICLE' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11500: Object Type is ARTICLE');
            END IF;

            IF l_prof_value = 'Y' THEN
             NULL;
            ELSE
            obj_texts(i) :=
                 regexp_replace(regexp_replace(obj_texts(i),'<var name="[0-9,a-z,A-Z,_,$]*" type="[A-Z]*" meaning="','[@'),'"/>','@]');
            END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11600: Before calling OKC_K_NON_STD_ART_GRP.create_non_std_article');
            END IF;

            OKC_K_NON_STD_ART_GRP.create_non_std_article(
                p_api_version  =>  p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  p_validate_commit => p_validate_commit,
                  p_validation_string => p_validation_string,
                  p_commit => p_commit,
                  p_mode  => p_mode,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_article_title => substr(to_char(obj_titles(i)),1,450),
                  p_article_type  => 'IMPORTED', -- Article Version Attributes
                  p_article_text => obj_texts(i),
                  p_provision_yn  => 'N',
                  p_std_article_version_id  => art_vers(i),
                  p_display_name => null,
                  p_article_description => null,

                  -- K Article Attributes
                  p_ref_type    => 'SECTION',
                  p_ref_id      => l_ref_id,
                  p_doc_type    => p_document_type,
                  p_doc_id      => p_document_id,
                  p_cat_id      => l_cat_id,

                  p_amendment_description => NULL,
                  p_print_text_yn  => NULL,
                  x_cat_id  => l_cat_id,
                  x_article_version_id   => l_article_version_id    );

                  obj_ids(i) := l_cat_id;
			   art_vers(i) :=  l_article_version_id;

         IF l_prof_value = 'Y' THEN
             OKC_WORD_DOWNLOAD_UPLOAD.INSERT_WML_TEXT(l_article_version_id,obj_texts_wml(i));
         END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11700: After calling OKC_K_NON_STD_ART_GRP.create_non_std_article');
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11800: lcat_id='||l_cat_id);
            END IF;
          END IF; --IF obj_types(i) = 'SECTION' THEN
        ELSIF actions(i) = 'UPDATED' THEN

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'11900: Action is UPDATED');
          END IF;

          IF obj_types(i) = 'SECTION' THEN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12000: B4 call OKC_TERMS_SECTIONS_GRP.update_section');
            END IF;

            OKC_TERMS_SECTIONS_GRP.update_section(
                p_api_version                  => p_api_version,
                p_init_msg_list                => p_init_msg_list,
                p_validation_level             => p_validation_level,
                p_validate_commit              => p_validate_commit,
                p_validation_string            => p_validation_string,
                p_commit                       => p_commit,
                p_mode                         => p_mode,
                x_return_status                => x_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data,
                p_id                           => obj_ids(i),
                p_section_sequence             => l_display_sequence,
                p_label                        => NULL,
                p_scn_id                       => l_ref_id,
                p_heading                      => substr(to_char(obj_titles(i)),1,80),
                p_description                  => NULL,
                p_scn_code                     => FND_API.G_MISS_CHAR,
            p_object_version_number        => NULL);

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12100: After OKC_TERMS_SECTIONS_GRP.update_section');
            END IF;

          ELSIF obj_types(i) = 'ARTICLE' THEN

          IF l_prof_value = 'Y' THEN
            NULL;
          ELSE
            obj_texts(i) :=
                 regexp_replace(regexp_replace(obj_texts(i),'<var name="[0-9,a-z,A-Z,_,$]*" type="[A-Z]*" meaning="','[@'),'"/>','@]');
          END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12200: Object Type is ARTICLE');
            END IF;

            IF non_stds(i) = 'Y' THEN

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12300: Non-Std article');
              END IF;

              l_article_type := null;

              open get_clause_type_csr(rut_ids(i));
              fetch get_clause_type_csr into l_article_type;
              close get_clause_type_csr;

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12400: B4 call OKC_K_NON_STD_ART_GRP.update_non_std_article');
              END IF;

              OKC_K_NON_STD_ART_GRP.update_non_std_article(
                   p_api_version  =>  p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   p_validate_commit => p_validate_commit,
                   p_validation_string => p_validation_string,
                   p_commit => p_commit,
                   p_mode  => p_mode,
                   x_return_status => x_return_status,
                   x_msg_count => x_msg_count,
                   x_msg_data => x_msg_data,
                   p_article_title              => substr(to_char(obj_titles(i)),1,80),
                   p_article_type               => l_article_type,

                   -- Article Version Attributes
                   p_article_text               => obj_texts(i),
                   p_provision_yn               => 'N',
                   p_article_description        => NULL,
                   p_display_name        => substr(to_char(obj_titles(i)),1,450),

                   -- K Article Attributes
                   p_doc_type                   => p_document_type,
                   p_doc_id                     => p_document_id,
                   p_cat_id                     => obj_ids(i),
                   p_amendment_description      => NULL,
                   p_print_text_yn              => NULL,
                   x_cat_id                     => l_cat_id,
                   x_article_version_id         => l_article_version_id    ) ;

			    obj_ids(i) := l_cat_id;
			    art_vers(i) :=  l_article_version_id;
         IF l_prof_value = 'Y' THEN
             OKC_WORD_DOWNLOAD_UPLOAD.INSERT_WML_TEXT(l_article_version_id,obj_texts_wml(i));
         END IF;


              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12500: After OKC_K_NON_STD_ART_GRP.update_non_std_article');
              END IF;

            ELSE  --IF non_stds(i) = 'Y' THEN

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12600: Std article');
              END IF;

              is_ibr := 'N';
              is_lock_text := 'N';

              open is_article_ibr(rut_ids(i));
              fetch is_article_ibr into is_ibr;
              close is_article_ibr;

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12700: is_ibr='||is_ibr);
              END IF;

              IF (is_ibr <> 'Y') THEN

                open is_article_text_locked(rut_ids(i));
                fetch is_article_text_locked into is_lock_text;
                close is_article_text_locked;

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12800: is_lock_text='||is_lock_text);
                END IF;


                IF((l_user_access = 'SUPER_USER' and is_lock_text = 'Y') OR
                         is_lock_text <> 'Y') THEN

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'12900: This is the case of Make Non-Standard');
                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13000: Before invoking OKC_K_NON_STD_ART_GRP.create_non_std_article');
                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13100: Clause Title=' || obj_titles(i));
                  END IF;

                  UPDATE okc_k_articles_b
			   SET scn_id = l_ref_id
			   WHERE id = obj_ids(i);

                  OKC_K_NON_STD_ART_GRP.create_non_std_article(
                          p_api_version  =>  p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          p_validate_commit => p_validate_commit,
                          p_validation_string => p_validation_string,
                          p_commit => p_commit,
                          p_mode  => p_mode,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data,
                          p_article_title => substr(to_char(obj_titles(i)),1,450),
                          p_article_type  => 'IMPORTED',
                          -- Article Version Attributes
                          p_article_text => obj_texts(i),
                          p_provision_yn  => 'N',
                          p_std_article_version_id  => art_vers(i),
                          p_display_name => substr(to_char(obj_titles(i)),1,450),
                          p_article_description => null,

                          -- K Article Attributes
                          p_ref_type    => 'SECTION',
                          p_ref_id      => l_ref_id,
                          p_doc_type    => p_document_type,
                          p_doc_id      => p_document_id,
                          p_cat_id      => obj_ids(i),

                          p_amendment_description => NULL,
                          p_print_text_yn  => NULL,
                          x_cat_id  => l_cat_id,
                          x_article_version_id   => l_article_version_id    );



			     obj_ids(i) := l_cat_id;
			     art_vers(i) :=  l_article_version_id;
         IF l_prof_value = 'Y' THEN
             OKC_WORD_DOWNLOAD_UPLOAD.INSERT_WML_TEXT(l_article_version_id,obj_texts_wml(i));
         END IF;

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13200: After OKC_K_NON_STD_ART_GRP.create_non_std_article');
                  END IF;
                END IF; -- if l_user_access...
              END IF; -- if ibr_text <> 'Y'
            END IF;   -- IF non_stds(i) = 'Y' THEN
          END IF;

        ELSIF (actions(i) = 'DELETED' OR actions(i) = 'MERGED') THEN

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13300: Action='||actions(i));
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13400: object Type='||obj_types(i));
          END IF;

          IF obj_types(i) = 'SECTION' THEN
            IF p_mode = 'AMEND' THEN
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13500: p_mode='||p_mode);
              END IF;

              UPDATE okc_sections_b scn
              SET scn.last_updated_by = fnd_global.user_id,
                  scn.last_update_date = sysdate,
                  scn.amendment_operation_code = 'DELETED',
                  scn.summary_amend_operation_code =
                       okc_terms_util_pvt.get_summary_amend_code(
                                  scn.summary_amend_operation_code,
                                  scn.amendment_operation_code,
                                  'DELETED'),
                  scn.last_amended_by = fnd_global.user_id,
                  scn.last_amendment_date = sysdate
                  WHERE scn.id = obj_ids(i);
            ELSE

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13500: p_mode='||p_mode);
              END IF;

              DELETE FROM okc_sections_b
              WHERE id = obj_ids(i);
            END IF;  --IF p_mode = 'AMEND' THEN

          ELSIF obj_types(i) = 'ARTICLE' THEN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13800: Clause Title=' || obj_titles(i));
            END IF;

            is_mandatory_text := 'N';

            open is_article_mandatory(rut_ids(i));
            fetch is_article_mandatory into is_mandatory_text;
            close is_article_mandatory;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'13900: is_article_mandatory='|| is_mandatory_text);
            END IF;

            IF ((l_user_access = 'SUPER_USER' ) OR is_mandatory_text <> 'Y') then
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14000: Before invoking delete on okc_k_articles_b');
              END IF;
              IF p_mode = 'AMEND' THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14100: B4 delete k_art mode=AMEND, objectID='||obj_ids(i));
                END IF;

                UPDATE okc_k_articles_b kart
                SET kart.last_updated_by = fnd_global.user_id,
                           kart.last_update_date = sysdate,
                           kart.amendment_operation_code = 'DELETED',
                           kart.summary_amend_operation_code =
                                      okc_terms_util_pvt.get_summary_amend_code(
                                           kart.summary_amend_operation_code,
                                           kart.amendment_operation_code,
                                           'DELETED'),
                          kart.last_amended_by = fnd_global.user_id,
                          kart.last_amendment_date = sysdate
                       WHERE kart.id = obj_ids(i);
              ELSE

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14200: after delete k_art, objectID='||obj_ids(i));
                END IF;

                DELETE FROM okc_k_articles_b
                WHERE id = obj_ids(i);
              END IF;

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14300: After delete on okc_k_articles_b');
              END IF;
            END IF;   --IF ((l_user_access = 'SUPER_USER' )
          END IF; --IF obj_types(i) = 'SECTION' THEN
        --ELSE
        END IF; --IF actions(i) = 'ADDED'
      END LOOP;
    END IF; --IF rut_ids.COUNT > 0 THEN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14400: Before Bulk update of okc_sections_b');
    END IF;

    FORALL i IN rut_ids.FIRST..rut_ids.LAST
      UPDATE okc_sections_b
      SET scn_id = pobj_ids(i),
          section_sequence = disp_seqs(i)
      WHERE id = obj_ids(i)
      AND obj_types(i) = 'SECTION';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14500: Before Bulk update of okc_k_articles_b');
    END IF;

    FORALL i IN rut_ids.FIRST..rut_ids.LAST
      UPDATE okc_k_articles_b
      SET scn_id = pobj_ids(i),
          display_sequence = disp_seqs(i)
      WHERE id = obj_ids(i)
      AND obj_types(i) = 'ARTICLE';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14600: Before delete on Review Tables');
    END IF;

    OKC_TEMPLATE_USAGES_GRP.update_template_usages(
            p_api_version                  => l_api_version,
            p_init_msg_list                => p_init_msg_list ,
	       p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
	       p_commit                       => FND_API.G_FALSE,
	       x_return_status                => x_return_status,
	       x_msg_count                    => x_msg_count,
	       x_msg_data                     => x_msg_data,
	       p_document_type          => p_document_type,
	       p_document_id            => p_document_id,
	       p_lock_terms_flag        => 'N');

    delete from okc_REVIEW_UPLD_TERMS where document_type = p_document_type and
    document_id = p_document_id;

    delete from okc_review_upld_header where document_type = p_document_type and
    document_id = p_document_id;

    delete from okc_review_messages where REVIEW_UPLD_TERMS_ID
    in (select REVIEW_UPLD_TERMS_ID from okc_REVIEW_UPLD_TERMS where document_type = p_document_type and
    document_id = p_document_id);

    delete from OKC_REVIEW_VAR_VALUES where REVIEW_UPLD_TERMS_ID
    in (select REVIEW_UPLD_TERMS_ID from okc_REVIEW_UPLD_TERMS where document_type = p_document_type and
    document_id = p_document_id);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14700: After delete on Review Tables');
    END IF;

    open current_num_scheme;
        fetch current_num_scheme into l_doc_num_scheme;
    close current_num_scheme;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14800: l_doc_num_scheme=' || l_doc_num_scheme);
    END IF;

    IF (l_doc_num_scheme is NOT NULL) THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'14900: Before invoking apply_numbering_scheme');
      END IF;

      OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_commit => p_commit,
        p_validation_string => p_validation_string,
        p_doc_type => p_document_type,
        p_doc_id => p_document_id,
        p_num_scheme_id => l_doc_num_scheme);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15000: After invoking apply_numbering_scheme');
      END IF;
    END IF; --IF (l_doc_num_scheme is NOT NULL) THEN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'15100: After Accept Changes');
    END IF;

    -- Added for Performance after accepting the changes no longer required to retain data in this table.
    DELETE FROM okc_word_sync_t WHERE doc_id=p_document_id AND doc_type=p_document_type;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15200: Leaving accept_Changes: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_accept_changes;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15300: Leaving accept_Changes: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_accept_Changes;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'15400: Leaving accept_changes because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_accept_changes;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
  END Accept_Changes;

  PROCEDURE Reject_Changes (
      p_api_version      IN  NUMBER,
	 p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
  ) IS
    l_api_name         CONSTANT VARCHAR2(30) := 'Reject_Changes';
    l_api_version                 CONSTANT NUMBER := 1;

  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entering Reject_Changes');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_reject_changes;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OKC_REVIEW_UPLD_TERMS_PVT.delete_uploaded_terms(
          p_api_version                  => l_api_version,
          p_init_msg_list                => p_init_msg_list ,
          p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
          p_commit                       => FND_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_document_type          => p_document_type,
          p_document_id            => p_document_id
    );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: After delete_uploaded_terms');
    END IF;

     -- Added for Performance after accepting the changes no longer required to retain data in this table.
     DELETE FROM okc_word_sync_t WHERE doc_id=p_document_id AND doc_type=p_document_type;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Reject_Changes: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_reject_changes;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Reject_Changes: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_reject_Changes;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'700: Leaving reject_changes because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_reject_changes;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Reject_Changes;


  PROCEDURE Delete_Uploaded_Terms (
      p_api_version      IN  NUMBER,
	 p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
  ) IS
    l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Uploaded_Terms';
    l_api_version                 CONSTANT NUMBER := 1;

  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entering Delete_Uploaded_Terms');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_delete_uploaded_terms;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE
    FROM OKC_REVIEW_MESSAGES m
    WHERE m.REVIEW_UPLD_TERMS_id IN
    (SELECT REVIEW_UPLD_TERMS_id
    FROM okc_REVIEW_UPLD_TERMS
    WHERE document_id = p_document_id
    AND document_type = p_document_type);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: After Delete Review Messages');
    END IF;

    DELETE
    FROM OKC_REVIEW_VAR_VALUES v
    WHERE v.REVIEW_UPLD_TERMS_id IN
    (SELECT REVIEW_UPLD_TERMS_id
    FROM okc_REVIEW_UPLD_TERMS
    WHERE document_id = p_document_id
    AND document_type = p_document_type);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: After delete review variables');
    END IF;

    DELETE
    FROM OKC_REVIEW_UPLD_TERMS
    WHERE document_id = p_document_id
    AND document_type = p_document_type;

    DELETE
    FROM OKC_REVIEW_UPLD_HEADER
    WHERE document_id = p_document_id
    AND document_type = p_document_type;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: After delete review terms');
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Delete_Uploaded_Terms: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_delete_uploaded_terms;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Delete_Uploaded_terms: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_delete_uploaded_terms;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'700: Leaving delete_uploaded_Terms because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_delete_uploaded_terms;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END delete_uploaded_terms;


  PROCEDURE Sync_Review_Tables (
      p_api_version      IN  NUMBER,
	 p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,
     p_validation_string IN VARCHAR2 := NULL,
      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
  ) IS
    l_api_name         CONSTANT VARCHAR2(30) := 'Sync_Review_Tables';
    l_api_version                 CONSTANT NUMBER := 1;
    l_doc_exists       VARCHAR2(1);
    l_rev_id_for_doc   OKC_REVIEW_UPLD_TERMS.REVIEW_UPLD_TERMS_ID%TYPE;
    l_unassigned_scn_id OKC_SECTIONS_B.ID%TYPE;
    l_clauses_no_parent_exist VARCHAR2(1);
    l_clause_title           FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_section_title          FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_clause_counter    NUMBER;
    l_section_counter   NUMBER;
    l_doc_num_scheme    OKC_TEMPLATE_USAGES.DOC_NUMBERING_SCHEME%TYPE;
    l_user_access VARCHAR2(30);
    l_message_name      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
    l_sequence          OKC_K_ARTICLES_B.DISPLAY_SEQUENCE%TYPE;
    l_count             NUMBER;
    l_prev_rev_id       OKC_REVIEW_UPLD_TERMS.REVIEW_UPLD_TERMS_ID%TYPE;
    l_prev_new_parent_id OKC_REVIEW_UPLD_TERMS.NEW_PARENT_ID%TYPE;
    l_intent            OKC_BUS_DOC_TYPES_B.INTENT%TYPE;

    cursor check_document_row_exists IS
    select REVIEW_UPLD_TERMS_id from okc_REVIEW_UPLD_TERMS
    where document_type = p_document_type and document_id = p_document_id
    and object_id = p_document_id and object_type = p_document_type;

    cursor unresolved_del_rec is
    select REVIEW_UPLD_TERMS_id, object_id, object_type, parent_id, parent_object_type,
           new_parent_id from okc_REVIEW_UPLD_TERMS
           where document_type = p_document_type
            and  document_id = p_document_id
            and action = 'DELETED'
            and new_parent_id is null
            order by object_type ;

    cursor clauses_without_parent_exist is
        select 'Y'
	   from OKC_REVIEW_UPLD_TERMS
        where document_type = p_document_type
	   and document_id = p_document_id
        and  ( (object_type = 'ARTICLE'
	           and new_parent_id IS NULL)
             OR (object_type = 'ARTICLE'
		       and new_parent_id = (select review_upld_terms_id
                                      from okc_review_upld_terms
                                      where  document_type = p_document_type
							   and document_id = p_document_id
                                      and object_id = p_document_id
							   and object_type = p_document_type))
              OR  (object_type = 'SECTION' and new_parent_id IS NULL)
             );


    cursor clauses_without_parent_id is
    select REVIEW_UPLD_TERMS_id, object_id, object_type, parent_id, parent_object_type,
           new_parent_id from okc_REVIEW_UPLD_TERMS
           where document_type = p_document_type and document_id = p_document_id
           and   object_type = 'ARTICLE' and new_parent_id IS NULL and article_id is null and article_version_id is null;

    cursor clauses_no_parent_id_and_moved is
    select REVIEW_UPLD_TERMS_id, object_id, object_type, parent_id, parent_object_type,
           new_parent_id
		 from okc_REVIEW_UPLD_TERMS
           where document_type = p_document_type
		 and document_id = p_document_id
           and   ((object_type = 'ARTICLE'
		 and new_parent_id IS NULL
		 and article_id is not null
		 and article_version_id is not null)
		 OR (object_type = 'SECTION' and new_parent_id IS NULL));

    cursor unassigned_section_exists is
    select REVIEW_UPLD_TERMS_id from okc_REVIEW_UPLD_TERMS
        where document_type = p_document_type and document_id = p_document_id
        and   object_type = 'SECTION' and to_char(object_title) =  Okc_Util.Decode_Lookup('OKC_ARTICLE_SECTION',G_UNASSIGNED_SECTION_CODE);

    cursor review_variable_values is
    select rev_var.variable_value_id, rev_var.REVIEW_UPLD_TERMS_id, rev_var.variable_name,
           rev_var.language, rev_var.variable_code, rev_var.variable_type, rev_var.attribute_value_set_id,
           rev_var.variable_value_id
    from OKC_REVIEW_VAR_VALUES rev_var, okc_REVIEW_UPLD_TERMS rev
    where rev_var.REVIEW_UPLD_TERMS_id = rev.REVIEW_UPLD_TERMS_id
          and rev.document_type = p_document_type and rev.document_id = p_document_id;


    cursor current_variable_values is
    select art_var.cat_id, art_var.variable_code, art_var.variable_type, art_var.external_yn,
           art_var.attribute_value_set_id,art_var.variable_value_id, art_var.variable_value
           from okc_k_art_variables art_var, okc_k_articles_b kart
           where art_var.cat_id = kart.id
           and kart.document_type = p_document_type and kart.document_id = p_document_id;

    cursor variable_values_changed is
    SELECT rev_var.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,rev_var.variable_code variable_code,
           rev_var.variable_name variable_name,
           kart_var.variable_value kart_variable_value, rev_var.variable_value rev_variable_value,
		 kart_var.variable_type, rev_var.variable_value_id

    FROM OKC_REVIEW_VAR_VALUES rev_var, okc_k_art_variables kart_var,
         OKC_REVIEW_UPLD_TERMS rev, okc_article_versions av
    WHERE rev.object_id = kart_var.cat_id
    AND   rev.REVIEW_UPLD_TERMS_id = rev_var.REVIEW_UPLD_TERMS_id
    AND   kart_var.variable_code = rev_var.variable_code
    AND   av.article_version_id = rev.article_version_id
    AND  ((kart_var.variable_type='U' and kart_var.variable_value is null
           and (kart_var.variable_value is null
		 and (rev_var.variable_value is not null and rev_var.variable_value <> '_________' )
		 and exists(select 'x' from okc_bus_variables_tl bustl where bustl.variable_code = rev_var.variable_code)) OR
          (kart_var.variable_value is not null and rev_var.variable_value <> kart_var.variable_value))
		OR (kart_var.variable_type<>'U' and exists
		   (select 'x' from okc_variable_doc_types var_doc where var_doc.variable_code = rev_var.variable_code
		   and var_doc.doc_Type = p_document_type))
	    )
    and rev.document_type = p_document_type and rev.document_id = p_document_id
    and nvl(rev.action,'NOCHANGE') not in ('DELETED','MERGED')
    and nvl(av.insert_by_reference,'N') <> 'Y';

    cursor variables_removed is
       select rev.review_upld_terms_id, kart_var.variable_code, variable_name, language, description
	  from okc_k_art_variables kart_var, okc_review_upld_terms rev, okc_bus_variables_tl bustl, okc_article_versions av
       where rev.object_id = kart_var.cat_id
       and rev.document_type = p_document_type and rev.document_id = p_document_id
	  and rev.article_version_id = av.article_version_id
       and kart_var.variable_code not in (select variable_code from okc_review_Var_values rev_var
		                                where rev_var.review_upld_terms_id = rev.review_upld_terms_id)
       and rev.action not in ('DELETED','MERGED')
	  and bustl.variable_code = kart_var.variable_code
	  and language = userenv('LANG')
	  and nvl(av.insert_by_reference,'N') <> 'Y';

    cursor valid_variable_added(p_intent VARCHAR2) is
       select rev.review_upld_terms_id, rev_var.variable_code, rev_var.variable_type,
	         decode(rev_var.variable_value,
		           NULL, 'N',
				 'Y') modified
	   from okc_review_upld_Terms rev, okc_review_var_values rev_var, okc_article_versions av
	   where rev.document_type = p_document_type and rev.document_id = p_document_id
	   and rev_var.review_upld_terms_id = rev.review_upld_terms_id
	   and av.article_version_id = rev.article_version_id
	   and not exists(
	          select 'x' from okc_k_art_variables kart_var, okc_review_upld_Terms rev_upld where
		     rev_upld.review_upld_Terms_id = rev_var.review_upld_terms_id
			and rev_upld.object_id = kart_var.cat_id
			and rev_var.variable_code = kart_var.variable_code
			and (
			       (rev_var.variable_type = 'U'
	                   and exists (select 'x' from okc_bus_variables_b busb where busb.variable_code = rev_var.variable_code
				    and busb.variable_intent = p_intent)
				  )
				  OR
				  (rev_var.variable_type <> 'U'
				    and exists (select 'x' from okc_variable_doc_types var_doc where var_doc.variable_code = rev_var.variable_code
				                and var_doc.doc_type = p_document_type)
				  )
			    )

		   )
	  and rev.action not in ('DELETED','MERGED')
	  and nvl(av.insert_by_reference,'N') <> 'Y';

     cursor invalid_variable_added(p_intent VARCHAR2) is
	    select rev.review_upld_terms_id, rev_var.variable_code, rev_var.variable_type
	    from okc_review_upld_terms rev, okc_review_var_values rev_var
	    where document_type = p_document_type and rev.document_id = p_document_id
	    and rev_var.review_upld_terms_id = rev.review_upld_terms_id
	    and ((rev_var.variable_type in ('S','D') and not exists (select 'x' from okc_variable_doc_types var_doc where var_doc.variable_code = rev_var.variable_code
	          and var_doc.doc_type = p_document_type))
			OR (rev_var.variable_type = 'U' and not exists (select 'x' from okc_bus_variables_b busb where busb.variable_code = rev_var.variable_code
			                                                and busb.variable_intent = p_intent))
		   )
        and rev.action not in ('DELETED','MERGED') ;

     cursor valid_var_new_clause(p_intent VARCHAR2) is
	  select rev.review_upld_terms_id, rev_var.variable_code, rev_var.variable_type,
	      decode(rev_var.variable_value,
		        NULL, 'N', 'Y') modified
	  from okc_review_upld_Terms rev, okc_review_var_values rev_var
	  where rev.document_type = p_document_type and rev.document_id = p_document_id
	  and rev_var.review_upld_terms_id = rev.review_upld_terms_id
	  and (
	         (rev_var.variable_type = 'U'
	             and exists (select 'x' from okc_bus_variables_b busb where busb.variable_code = rev_var.variable_code
			               and busb.variable_intent = p_intent)
	         )
		    OR
		    (rev_var.variable_type <> 'U'
		        and exists (select 'x' from okc_variable_doc_types var_doc where var_doc.variable_code = rev_var.variable_code
			              and var_doc.doc_type = p_document_type)
		    )
		 )
	  and rev.action = 'ADDED' ;


       cursor valid_new_var_ibr(p_intent VARCHAR2) is
	     select rev.review_upld_terms_id, rev_var.variable_code, rev_var.variable_type,
		  decode(rev_var.variable_value,
		          NULL, 'N', 'Y') modified
		from okc_review_upld_terms rev, okc_review_var_values rev_var, okc_article_versions av
		where rev.document_type = p_document_type and rev.document_id = p_document_id
		and rev_var.review_upld_terms_id = rev.review_upld_terms_id
		and av.article_version_id = rev.article_version_id
		and (
	         (rev_var.variable_type = 'U'
	             and exists (select 'x' from okc_bus_variables_b busb where busb.variable_code = rev_var.variable_code
			               and busb.variable_intent = p_intent)
	         )
		    OR
		    (rev_var.variable_type <> 'U'
		        and exists (select 'x' from okc_variable_doc_types var_doc where var_doc.variable_code = rev_var.variable_code
			              and var_doc.doc_type = p_document_type)
		    )
		 )

		and nvl(av.insert_by_reference,'N') = 'Y';

    cursor empty_title_csr is
    SELECT rev.object_title, rev.REVIEW_UPLD_TERMS_id, rev.object_type
           from okc_REVIEW_UPLD_TERMS rev
           where document_type = p_document_type and
                 document_id   = p_document_id   and
                 object_title is null
                 and object_type IN ('ARTICLE', 'SECTION');
    cursor current_num_scheme is
    select doc_numbering_scheme from okc_template_usages
    where document_type = p_document_type and
          document_id = p_document_id;


    CURSOR is_article_ibr(p_user_access VARCHAR2) is
    SELECT 'Y', ACTION, review_upld_terms_id, object_title
      from okc_article_versions av, okc_review_upld_terms ar
      where av.article_version_id = ar.article_version_id
            and av.insert_by_reference = 'Y'
            and ar.document_type = p_document_type
            and ar.document_id   = p_document_id
            and ar.object_type   = 'ARTICLE'
            and ar.action        = 'UPDATED'
		  and p_user_access <> 'SUPER_USER';

    CURSOR is_article_mandatory(p_user_access VARCHAR2) is
    SELECT 'Y', ACTION, review_upld_terms_id, object_title
      from okc_k_articles_b akb, okc_review_upld_terms ar
      where akb.id = ar.object_id
            and akb.mandatory_yn = 'Y'
            and ar.document_type = p_document_type
            and ar.document_id   = p_document_id
            and ar.object_type   = 'ARTICLE'
            and ar.action        = 'DELETED'
		   and p_user_access <> 'SUPER_USER';

    CURSOR is_article_text_locked(p_user_access VARCHAR2) is
    SELECT 'Y', ACTION, review_upld_terms_id, object_title
      from okc_article_versions av, okc_review_upld_terms ar
      where av.article_version_id = ar.article_version_id
            and av.lock_text = 'Y'
            and ar.document_type = p_document_type
            and ar.document_id   = p_document_id
            and ar.object_type   = 'ARTICLE'
            and ar.action        = 'UPDATED'
		  and p_user_access <> 'SUPER_USER';

    CURSOR update_err_warn_csr is
        select
            count(*) err_warn_count,
            rev_msg.review_upld_terms_id,
            rev_msg.error_severity
        from
            okc_review_messages rev_msg ,
            okc_review_upld_terms rev_trm
        where
            rev_msg.review_upld_terms_id = rev_trm.review_upld_terms_id
            and rev_trm.document_type = p_document_type
            and rev_trm.document_id = p_document_id
        group by rev_msg.review_upld_terms_id, rev_msg.error_severity;

    /* This cursor is for debugging purposes. This cursor is invoked only when logging is enabled
     */
           cursor get_updated_articles_csr is
		         select review_upld_terms_id,
			    object_title,
			    regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ltrim(ut.object_text),'&NBSP;|&nbsp;',' '),
			    '<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>|
			    <A>|<a>|</A>|</a>|<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>|
			    <STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
			    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
			    |<HR>|</HR>|<hr>|</hr>',''),unistr('\00a0'),' '),' ',''),'&amp;|&|<Palign="justify">|<divalign="both">','') rev_text,
			    regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ver.article_text,'&NBSP;|&nbsp;',' '),
			    '<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>|<A>|<a>|</A>|</a>
			    |<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>|
			    <STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
			    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
			    |<HR>|</HR>|<hr>|</hr>',''),unistr('\00a0'),' '),' ',''), '&amp;|&|<Palign="justify">|<divalign="both">','') ver_text,
			    NVL(dbms_lob.compare(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ltrim(ut.object_text),
			    '&NBSP;|&nbsp;',' '),'<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>
			    |<A>|<a>|</A>|</a>|<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>
			    |<STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
			    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
			    |<HR>|</HR>|<hr>|</hr>',''),unistr('\00a0'),' '),' ',''), '&amp;|&|<Palign="justify">|<divalign="both">','') ,
			    regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ver.article_text,'&NBSP;|&nbsp;',' '),
			    '<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>
			    |<A>|<a>|</A>|</a>|<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>
			    |<STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
			    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
			    |<HR>|</HR>|<hr>|</hr>',''),unistr('\00a0'),' '),' ',''), '&amp;|&|<Palign="justify">|<divalign="both">','')),-1)  diff
			    from okc_review_upld_terms ut, okc_article_versions ver
			    where  ut.article_version_id = ver.article_version_id
			    and ut.article_version_id is not null
			    and ut.action = 'UPDATED'
			    and ut.document_type = p_document_type
			    and ut.document_id = p_document_id;

    cursor check_sec_clause_title is
        select review_upld_terms_id,
	     object_title, object_type
		from okc_review_upld_terms rev
		where rev.document_type = p_document_type
		and   rev.document_id   = p_document_id
		and   rev.object_type   in ('SECTION','ARTICLE')
		and   rev.action in ('ADDED','UPDATED')
		and   ((object_type = 'SECTION' and length(to_char(object_title)) > 80) OR (object_type = 'ARTICLE' and length(to_char(object_title)) > 450)) ;

    cursor terms_disp_csr is
    select review_upld_terms_id, object_type, object_id, object_title, action, display_seq, new_parent_id
    from okc_review_upld_Terms
    where document_type = p_document_type
    and document_id = p_document_id
    and nvl(action,'XXX') <> 'DELETED'
    start with new_parent_id  is null
    connect by prior review_upld_terms_id = new_parent_id
    order siblings by review_upld_terms_id;

    cursor parent_ids_csr is
    select review_upld_terms_id
    from okc_review_upld_Terms
    where document_type = p_document_type
    and document_id = p_document_id ;

    cursor deleted_terms_csr is
    select new_parent_id,
           display_seq
    from okc_review_upld_Terms
    where document_type = p_document_type
    and document_id = p_document_id
    and action = 'DELETED';

    --TYPE disp_seq_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE new_parent_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.NEW_PARENT_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE disp_seq_tab IS TABLE OF OKC_REVIEW_UPLD_TERMS.DISPLAY_SEQ%TYPE INDEX BY BINARY_INTEGER;

    curr_disp_seqs disp_seq_tab;
    del_disp_seqs disp_seq_tab;
    del_new_parents new_parent_tab;
    --disp_seqs disp_seq_tab;

    cursor get_intent_csr is
     select intent from okc_bus_doc_types_b
	 where document_type = p_document_type;

   l_prof_value VARCHAR2(1);
  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT g_reject_changes;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_STD','N') THEN
      l_user_access := 'STD_AUTHOR';
      IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_NON_STD','N') THEN
        l_user_access := 'NON_STD_AUTHOR';
        IF FND_FUNCTION.TEST('OKC_TERMS_AUTHOR_SUPERUSER','N') THEN
          l_user_access := 'SUPER_USER';
        END IF;
	 END IF;
    ELSE
       l_user_access := 'NO_ACCESS';
    END IF;

    open get_intent_csr;
      fetch get_intent_csr into l_intent;
    close get_intent_csr;

    open check_document_row_exists;
    fetch check_document_row_exists into l_doc_exists;
    if (check_document_row_exists%NOTFOUND) THEN
        INSERT into okc_REVIEW_UPLD_TERMS(
        REVIEW_UPLD_TERMS_ID,
        DOCUMENT_ID,
        DOCUMENT_TYPE,
        OBJECT_ID,
        OBJECT_TYPE,
        OBJECT_TITLE,
        OBJECT_TEXT,
        PARENT_OBJECT_TYPE,
        PARENT_ID,
        ARTICLE_ID,
        ARTICLE_VERSION_ID,
        OBJECT_VERSION_NUMBER,
        LABEL,
        DISPLAY_SEQ,
        ACTION,
        ERROR_MESSAGE_COUNT,
        WARNING_MESSAGE_COUNT,
        NEW_PARENT_ID,
        LAST_UPDATE_LOGIN,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE)
        (
            SELECT OKC_REVIEW_UPLD_TERMS_S1.NEXTVAL,
        P_DOCUMENT_ID,
        P_DOCUMENT_TYPE,
        p_document_id,
        P_DOCUMENT_TYPE,
        okc_terms_util_pvt.get_message('OKC','OKC_TERMS_CONTRACT_TERMS'),
        null,
        null,
        null,
        null,
        null,
        1,
        null,
        null,
        null,
        null,
        null,
        null,
        FND_GLOBAL.LOGIN_ID,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE from dual);

    END IF;
    CLOSE check_document_row_exists;

    open check_document_row_exists;
    fetch check_document_row_exists into l_rev_id_for_doc;
    close check_document_row_exists;


    update okc_REVIEW_UPLD_TERMS
    set new_parent_id = (select REVIEW_UPLD_TERMS_id from okc_REVIEW_UPLD_TERMS where
                         document_type = p_document_type and document_id = p_document_id
                         and object_type = p_document_type and object_id = p_document_id)
    where document_type = p_document_type and document_id = p_document_id
          and object_type = 'SECTION' and new_parent_id = p_document_id;


    update okc_REVIEW_UPLD_TERMS rev
    set rev.article_id = (select sav_sae_id from okc_k_articles_b
                            where document_type = p_document_type
                            and   document_id = p_document_id
                            and   id = rev.object_id)

    ,rev.article_version_id = (select article_version_id from okc_k_articles_b
                            where document_type = p_document_type
                            and   document_id = p_document_id
                            and   id = rev.object_id)
    where document_type = p_document_type
    and   document_id = p_document_id
    and   object_type = 'ARTICLE'
    and   object_id is not null
    and   article_id is null
    and   article_version_id is null
    and   exists (select 1 from okc_k_articles_b kart
                   where document_type = p_document_type
    and   document_id = p_document_id
    and   id = rev.object_id);


    update okc_Review_upld_terms rev_terms
    set action = 'ADDED',
        article_id = null,
	   article_version_id = null,
	   object_id = null
    where rev_terms.review_upld_terms_id > (select min(review_upld_terms_id) from okc_Review_upld_terms
                              where object_id = rev_terms.object_id
						and object_type = 'ARTICLE'
						and document_Type = p_document_type and document_id = p_document_id
						)
    and document_Type = p_document_type and document_id = p_document_id
    and object_type = 'ARTICLE' ;


    update okc_Review_upld_terms rev_terms
    set action = 'ADDED',
        article_id = null,
	   article_version_id = null,
	   object_id = null
    where rev_terms.review_upld_terms_id > (select min(review_upld_terms_id) from okc_Review_upld_terms
                              where object_id = rev_terms.object_id
						and object_type = 'SECTION'
						and document_Type = p_document_type and document_id = p_document_id)
    and document_Type = p_document_type and document_id = p_document_id
    and object_type = 'SECTION';



    UPDATE OKC_REVIEW_UPLD_TERMS
    SET ACTION='ADDED'
    WHERE OBJECT_ID IS NULL
    AND DOCUMENT_ID = P_DOCUMENT_ID
    AND DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND ACTION IS NULL
    AND object_type IN ('ARTICLE','SECTION');
    --AND NEW_PARENT_ID IS NOT NULL;

    UPDATE OKC_REVIEW_UPLD_TERMS UT
    SET ACTION='ADDED'
    WHERE ACTION IS NULL
    AND DOCUMENT_ID = P_DOCUMENT_ID
    AND DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND NEW_PARENT_ID IS NOT NULL
    AND ((OBJECT_TYPE = 'ARTICLE'
    AND ( NOT EXISTS (SELECT 1
    FROM OKC_K_ARTICLES_B A
    WHERE A.ID = UT.OBJECT_ID
          AND A.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
          AND A.DOCUMENT_ID   = UT.DOCUMENT_ID) OR
    EXISTS (SELECT 1
    FROM OKC_K_ARTICLES_B A1
    WHERE A1.ID = UT.OBJECT_ID
          AND A1.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
          AND A1.DOCUMENT_ID   = UT.DOCUMENT_ID
		AND NVL(A1.AMENDMENT_OPERATION_CODE,'ZZZ') = 'DELETED') )
    ) OR
    (OBJECT_TYPE = 'SECTION'
    AND (NOT EXISTS (SELECT 1
    FROM OKC_SECTIONS_B S
    WHERE S.ID = UT.OBJECT_ID
        AND S.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
        AND S.DOCUMENT_ID   = UT.DOCUMENT_ID )
	   OR
    EXISTS (SELECT 1
    FROM OKC_SECTIONS_B S1
    WHERE S1.ID = UT.OBJECT_ID
        AND S1.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
        AND S1.DOCUMENT_ID   = UT.DOCUMENT_ID
	   AND NVL(S1.AMENDMENT_OPERATION_CODE,'ZZZ') = 'DELETED' ))
	   ));

    INSERT INTO OKC_REVIEW_UPLD_TERMS(
    REVIEW_UPLD_TERMS_ID,
    DOCUMENT_ID,
    DOCUMENT_TYPE,
    OBJECT_ID,
    OBJECT_TYPE,
    OBJECT_TITLE,
    OBJECT_TEXT,
    PARENT_OBJECT_TYPE,
    PARENT_ID,
    ARTICLE_ID,
    ARTICLE_VERSION_ID,
    OBJECT_VERSION_NUMBER,
    LABEL,
    DISPLAY_SEQ,
    ACTION,
    ERROR_MESSAGE_COUNT,
    WARNING_MESSAGE_COUNT,
    NEW_PARENT_ID,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE)
    (SELECT OKC_REVIEW_UPLD_TERMS_S1.NEXTVAL,
    KART.DOCUMENT_ID,
    KART.DOCUMENT_TYPE,
    KART.ID,
    'ARTICLE',
    nvl(VER.DISPLAY_NAME,ART.ARTICLE_TITLE),
    --  Fix for bug# 5223552. Fix for inserting Clause/Reference Text based on IBR flag in review tbl based for 'Deleted' Clause
    (SELECT to_clob(ver.reference_text) FROM dual WHERE Nvl(ver.insert_by_reference,'N') = 'Y'
      UNION ALL
     SELECT VER.ARTICLE_TEXT FROM dual WHERE  Nvl(ver.insert_by_reference,'N') = 'N'
    ),
    'SECTION',
    KART.SCN_ID,
    KART.SAV_SAE_ID,
    KART.ARTICLE_VERSION_ID,
    1,
    KART.LABEL,
    KART.DISPLAY_SEQUENCE,
    'DELETED',
    NULL,
    NULL,
    (SELECT REVIEW_UPLD_TERMS_ID
                              FROM OKC_REVIEW_UPLD_TERMS PARENT
                              WHERE PARENT.OBJECT_ID = KART.SCN_ID
                              AND PARENT.DOCUMENT_TYPE = p_document_type
                              AND PARENT.DOCUMENT_ID = p_document_id),
--    KART.SCN_ID,
    FND_GLOBAL.LOGIN_ID,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE
    FROM OKC_K_ARTICLES_B KART,
    OKC_ARTICLES_ALL ART,
    OKC_ARTICLE_VERSIONS VER
    WHERE KART.SAV_SAE_ID = ART.ARTICLE_ID
    AND ART.ARTICLE_ID = VER.ARTICLE_ID
    AND KART.ARTICLE_VERSION_ID = VER.ARTICLE_VERSION_ID
    AND KART.DOCUMENT_ID = P_DOCUMENT_ID
    AND KART.DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND NOT EXISTS (SELECT 1
    FROM OKC_REVIEW_UPLD_TERMS UT
    WHERE UT.OBJECT_ID = KART.ID
    AND UT.OBJECT_TYPE = 'ARTICLE'
    AND UT.DOCUMENT_ID = P_DOCUMENT_ID
    AND UT.DOCUMENT_TYPE = P_DOCUMENT_TYPE));


    INSERT INTO OKC_REVIEW_UPLD_TERMS(
    REVIEW_UPLD_TERMS_ID,
    DOCUMENT_ID,
    DOCUMENT_TYPE,
    OBJECT_ID,
    OBJECT_TYPE,
    OBJECT_TITLE,
    OBJECT_TEXT,
    PARENT_OBJECT_TYPE,
    PARENT_ID,
    ARTICLE_ID,
    ARTICLE_VERSION_ID,
    OBJECT_VERSION_NUMBER,
    LABEL,
    DISPLAY_SEQ,
    ACTION,
    ERROR_MESSAGE_COUNT,
    WARNING_MESSAGE_COUNT,
    NEW_PARENT_ID,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE)
    (SELECT OKC_REVIEW_UPLD_TERMS_S1.NEXTVAL,
    SCN.DOCUMENT_ID,
    SCN.DOCUMENT_TYPE,
    SCN.ID,
    'SECTION',
    SCN.HEADING,
    NULL,
    DECODE(SCN.SCN_ID,NULL,p_document_type,'SECTION'),
    SCN.SCN_ID,
    NULL,
    NULL,
    1,
    SCN.LABEL,
    SCN.SECTION_SEQUENCE,
    'DELETED',
    NULL,
    NULL,
--    SCN.SCN_ID,
    DECODE(SCN.SCN_ID, NULL,l_rev_id_for_doc,
                       p_document_id, l_rev_id_for_doc,
           (SELECT REVIEW_UPLD_TERMS_ID
                              FROM OKC_REVIEW_UPLD_TERMS PARENT
                              WHERE PARENT.OBJECT_ID = SCN.SCN_ID
                              AND PARENT.DOCUMENT_TYPE = p_document_type
                              AND PARENT.DOCUMENT_ID = p_document_id)
        ),
    FND_GLOBAL.LOGIN_ID,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE
    FROM OKC_SECTIONS_B SCN
    WHERE SCN.DOCUMENT_ID = P_DOCUMENT_ID
    AND SCN.DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND NOT EXISTS (SELECT 1
    FROM OKC_REVIEW_UPLD_TERMS UT
    WHERE UT.OBJECT_ID = SCN.ID
         AND UT.DOCUMENT_TYPE = p_document_type
	    AND UT.DOCUMENT_ID = p_document_id
    AND UT.OBJECT_TYPE = 'SECTION'));


    for del_csr in unresolved_del_rec loop
       UPDATE OKC_REVIEW_UPLD_TERMS REV
       SET NEW_PARENT_ID = (SELECT REVIEW_UPLD_TERMS_ID
                          FROM OKC_REVIEW_UPLD_TERMS PARENT
                          WHERE PARENT.OBJECT_ID = REV.PARENT_ID
					 AND REV.REVIEW_UPLD_TERMS_id = del_csr.REVIEW_UPLD_TERMS_id
				      AND PARENT.DOCUMENT_TYPE = p_document_type
				      AND PARENT.document_id = p_document_id
					 )
       WHERE
        REV.REVIEW_UPLD_TERMS_id = del_csr.REVIEW_UPLD_TERMS_id;
    end loop;


    -- 2 way word sync with clause edit begins
    l_prof_value := OKC_WORD_DOWNLOAD_UPLOAD.GET_WORD_SYNC_PROFILE;
    IF l_prof_value = 'Y' THEN

    UPDATE OKC_REVIEW_UPLD_TERMS UT
    SET ACTION='UPDATED',
    DISPLAY_SEQ = (select KART.display_sequence
    FROM OKC_K_ARTICLES_B KART
    WHERE KART.ID = UT.OBJECT_ID)
    WHERE ACTION IS NULL
    AND DOCUMENT_ID = P_DOCUMENT_ID
    AND DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND OBJECT_TYPE = 'ARTICLE'
    AND EXISTS
    (
    SELECT 1
    FROM OKC_K_ARTICLES_B KART,
    OKC_ARTICLES_ALL ART,
    OKC_ARTICLE_VERSIONS VER
    WHERE KART.SAV_SAE_ID = ART.ARTICLE_ID
    AND ART.ARTICLE_ID = VER.ARTICLE_ID
    AND KART.ARTICLE_VERSION_ID = VER.ARTICLE_VERSION_ID
    AND KART.ID = UT.OBJECT_ID
    AND KART.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
    AND KART.DOCUMENT_ID   = UT.DOCUMENT_ID

    AND (
    (NVL(VER.DISPLAY_NAME,ART.ARTICLE_TITLE) <> to_char(UT.OBJECT_TITLE)) OR
    (EXISTS (SELECT 1 FROM OKC_WORD_SYNC_T WHERE DOC_ID = P_DOCUMENT_ID AND DOC_TYPE = P_DOCUMENT_TYPE AND CAT_ID = UT.OBJECT_ID AND action = 'UPDATEDASSIGNED'))));
--    ('UPDATED' = (SELECT ACTION FROM OKC_WORD_SYNC_T WHERE DOC_ID = P_DOCUMENT_ID AND DOC_TYPE = P_DOCUMENT_TYPE AND CAT_ID = UT.OBJECT_ID))));


    ELSE

    UPDATE OKC_REVIEW_UPLD_TERMS UT
    SET ACTION='UPDATED',
    DISPLAY_SEQ = (select KART.display_sequence
    FROM OKC_K_ARTICLES_B KART
    WHERE KART.ID = UT.OBJECT_ID)
    WHERE ACTION IS NULL
    AND DOCUMENT_ID = P_DOCUMENT_ID
    AND DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND OBJECT_TYPE = 'ARTICLE'
    AND EXISTS
    (
    SELECT 1
    FROM OKC_K_ARTICLES_B KART,
    OKC_ARTICLES_ALL ART,
    OKC_ARTICLE_VERSIONS VER
    WHERE KART.SAV_SAE_ID = ART.ARTICLE_ID
    AND ART.ARTICLE_ID = VER.ARTICLE_ID
    AND KART.ARTICLE_VERSION_ID = VER.ARTICLE_VERSION_ID
    AND KART.ID = UT.OBJECT_ID
    AND KART.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
    AND KART.DOCUMENT_ID   = UT.DOCUMENT_ID

    AND (
    (NVL(VER.DISPLAY_NAME,ART.ARTICLE_TITLE) <> to_char(UT.OBJECT_TITLE)) OR
    (NVL(ver.insert_by_reference,'N') = 'Y' AND
    NVL(dbms_lob.compare(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ut.object_text,'&NBSP;|&nbsp;',' '),
    '<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>
    |<A>|<a>|</A>|</a>|<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>|
    <STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
    |<HR>|</HR>|<hr>|</hr>|<br>|</br>|<BR>|</BR>|<br/>|<BR/>|([[:cntrl:]])',''),unistr('\00a0'),' '),' ',''),
	'&amp;|&|<Palign="justify">|<Palign="both">|<Palign="center">|<divalign="both">|<divalign="left">|<Palign="left">|<Palign="right">','') ,
    regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ver.reference_text,'&NBSP;|&nbsp;',' '),
    '<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>
    |<A>|<a>|</A>|</a>|<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>
    |<STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
    |<HR>|</HR>|<hr>|</hr>|<br>|</br>|<BR>|</BR>|<br/>|<BR/>|([[:cntrl:]])',''),unistr('\00a0'),' '),' ',''),
	'&amp;|&|<Palign="justify">|<Palign="both">|<Palign="center">|<divalign="both">|<Palign="left">|<Palign="right">|<ULtype="disc">||<ultype="disc">','')),-1) <> 0) OR
    (NVL(ver.insert_by_reference,'N') <> 'Y' AND
    NVL(dbms_lob.compare(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ut.object_text,'&NBSP;|&nbsp;',' '),
    '<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>
    |<A>|<a>|</A>|</a>|<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>|
    <STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
    |<HR>|</HR>|<hr>|</hr>|<br>|</br>|<BR>|</BR>|<br/>|<BR/>|([[:cntrl:]])',''),unistr('\00a0'),' '),' ',''),
	'&amp;|&|<Palign="justify">|<Palign="both">|<Palign="center">|<divalign="both">|<divalign="left">|<Palign="left">|<Palign="right">','') ,
    regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(ver.article_text,'&NBSP;|&nbsp;',' '),
    '<DIV>|<div>|<P>|<p>|<B>|<b>|</DIV>|</div>|</P>|</p>|</B>|</b>|<STRONG>|<strong>|</STRONG>|</strong>
    |<A>|<a>|</A>|</a>|<H3>|<h3>|</H3>|</h3>|<H2>|<h2>|</H2>|</h2>|<H1>|<h1>|</H1>|</h1>|<S>|<s>|</S>|</s>
    |<STRIKE>|<strike>|</STRIKE>|</strike>|<I>|<i>|</I>|</i>|<EM>|<em>|</EM>|</em>|<U>|<u>|</U>|</u>
    |<BLOCKQUOTE>|</BLOCKQUOTE>|<blockquote>|</blockquote>|<OL>|</OL>|<ol>|</ol>|<LI>|</LI>|<li>|</li>|<UL>|</UL>|<ul>|</ul>
    |<HR>|</HR>|<hr>|</hr>|<br>|</br>|<BR>|</BR>|<br/>|<BR/>|([[:cntrl:]])',''),unistr('\00a0'),' '),' ',''),
	'&amp;|&|<Palign="justify">|<Palign="both">|<Palign="center">|<divalign="both">|<Palign="left">|<Palign="right">|<ULtype="disc">||<ultype="disc">','')),-1) <> 0)));

    END IF;
    -- 2 way word sync with clause edit ends

    UPDATE OKC_REVIEW_UPLD_TERMS UT
    SET ACTION='UPDATED',
    DISPLAY_SEQ = (SELECT SECTION_SEQUENCE FROM OKC_SECTIONS_B SCN
    WHERE SCN.ID = UT.OBJECT_ID
    AND to_char(UT.OBJECT_TITLE) <> SCN.HEADING)
    WHERE ACTION IS NULL
    AND DOCUMENT_ID = P_DOCUMENT_ID
    AND DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND OBJECT_TYPE = 'SECTION'
    AND EXISTS (SELECT 1
    FROM OKC_SECTIONS_B SCN
    WHERE SCN.ID = UT.OBJECT_ID
    AND SCN.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
    AND SCN.DOCUMENT_ID = UT.DOCUMENT_ID

    AND to_char(UT.OBJECT_TITLE) <> SCN.HEADING);

    UPDATE OKC_REVIEW_UPLD_TERMS UT
    SET NON_STANDARD_FLAG = 'Y'
    WHERE DOCUMENT_ID = P_DOCUMENT_ID
    AND DOCUMENT_TYPE = P_DOCUMENT_TYPE
    AND OBJECT_TYPE = 'ARTICLE'
    AND EXISTS (SELECT 1
    FROM OKC_K_ARTICLES_B KART,
    OKC_ARTICLES_ALL ART
    WHERE KART.SAV_SAE_ID = ART.ARTICLE_ID
    AND KART.ID = UT.OBJECT_ID
    AND KART.DOCUMENT_TYPE = UT.DOCUMENT_TYPE
    AND KART.DOCUMENT_ID   = UT.DOCUMENT_ID

    AND ART.STANDARD_YN = 'N');

    open clauses_without_parent_exist;
    fetch clauses_without_parent_exist into l_clauses_no_parent_exist;
    if (clauses_without_parent_exist%FOUND) THEN
           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'120: Creating Unassgined Section ');
           END IF;
           open unassigned_section_exists;
           fetch unassigned_section_exists into l_unassigned_scn_id;
           if(unassigned_section_exists%NOTFOUND)THEN
                create_unassigned_section(p_api_version  => 1,
                     p_commit            => FND_API.G_FALSE,
                     p_document_type     => p_document_type,
                     p_document_id       => p_document_id,
                     p_new_parent_id     => l_rev_id_for_doc,
                     x_scn_id            =>   l_unassigned_scn_id,
                     x_return_status     => x_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data
                                                            );
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'130: l_unassigned_scn_id : '||l_unassigned_scn_id);
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'130: Cannot Create Unassgined Section : '||x_msg_data||' Status '||x_return_status);
                END IF;

                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                     RAISE FND_API.G_EXC_ERROR ;
                END IF;
          end if;
          close unassigned_section_exists;
    end if;
    close clauses_without_parent_exist;
    for clause_no_parent_csr in clauses_without_parent_id loop
        update okc_REVIEW_UPLD_TERMS
        set new_parent_id = l_unassigned_scn_id, action = 'ADDED'
        where REVIEW_UPLD_TERMS_id = clause_no_parent_csr.REVIEW_UPLD_TERMS_id;
    end loop;

    for clauses_moved_no_section_csr in clauses_no_parent_id_and_moved loop
        update OKC_REVIEW_UPLD_TERMS
	   set new_parent_id = l_unassigned_scn_id
	   where REVIEW_UPLD_TERMS_id =clauses_moved_no_section_csr.REVIEW_UPLD_TERMS_id;
	end loop;


      l_message_name := 'OKC_REVIEW_VAR_VAL_CHG';
      for var_csr in variable_values_changed loop
            update OKC_REVIEW_VAR_VALUES
            set changed = 'Y'
            where REVIEW_UPLD_TERMS_id = var_csr.REVIEW_UPLD_TERMS_id;

		  if(var_csr.variable_type = 'U') then
		     if(var_csr.variable_value_id is null) then
		        l_message_name := 'OKC_REVIEW_VAR_VAL_KNW_CHG';
			else
			   l_message_name := 'OKC_REVIEW_VAR_MAY_CHG';
			end if;
		  else
		     l_message_name := 'OKC_REVIEW_VAR_MAY_CHG';
		  end if;

            -- Insert the message only if the same message does not exist for that review_upld_terms_id
		  -- and variable_code
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number,
		  variable_code
            )
           (select okc_review_messages_s1.nextval review_messages_id,
               var_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity,l_message_name ,1 object_version_number, var_csr.variable_code from dual
			where not exists (select 1 from okc_review_messages where review_upld_terms_id = var_csr.review_upld_terms_id
			and variable_code = var_csr.variable_code and message_name = l_message_name));

      end loop;

      l_message_name := 'OKC_REVIEW_VAR_VAL_CHG';
      for valid_var_added_csr in valid_variable_added(l_intent) loop
	       -- Fix for bug# 5229387. Clauses should be marked as 'UPDATED' only if action is null
	       update okc_review_upld_terms
		  set action='UPDATED'
		  where review_upld_terms_id = valid_var_added_csr.review_upld_terms_id and action is null;

		   update OKC_REVIEW_VAR_VALUES
		   set changed = 'A'
		   where REVIEW_UPLD_TERMS_id = valid_var_added_csr.REVIEW_UPLD_TERMS_id;

            if(valid_var_added_csr.modified='Y') then
		    l_message_name := 'OKC_REVIEW_VAR_ADDED';
		  else
		    l_message_name := 'OKC_REVIEW_VAR_ADD_NO_VAL';
		  end if;

            -- Insert the message only if the same message does not exist for that review_upld_terms_id
		  -- and variable_code
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number,
		  variable_code
            )
           (select okc_review_messages_s1.nextval review_messages_id,
               valid_var_added_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity, l_message_name ,1 object_version_number, valid_var_added_csr.variable_code from dual
			where not exists (select 1 from okc_review_messages where review_upld_terms_id = valid_var_added_csr.review_upld_terms_id
			and variable_code = valid_var_added_csr.variable_code and message_name = l_message_name));
      end loop;

      for valid_var_new_clause_csr in valid_var_new_clause(l_intent) loop

		   update OKC_REVIEW_VAR_VALUES
		   set changed = 'A'
		   where REVIEW_UPLD_TERMS_id = valid_var_new_clause_csr.REVIEW_UPLD_TERMS_id;

            if(valid_var_new_clause_csr.modified='Y') then
		    l_message_name := 'OKC_REVIEW_VAR_ADDED';
		  else
		    l_message_name := 'OKC_REVIEW_VAR_ADD_NO_VAL';
		  end if;

            -- Insert the message only if the same message does not exist for that review_upld_terms_id
		  -- and variable_code
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number,
		  variable_code
            )
           (select okc_review_messages_s1.nextval review_messages_id,
               valid_var_new_clause_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity, l_message_name ,1 object_version_number, valid_var_new_clause_csr.variable_code from dual
			where not exists (select 1 from okc_review_messages where review_upld_terms_id = valid_var_new_clause_csr.review_upld_terms_id
			and variable_code = valid_var_new_clause_csr.variable_code and message_name = l_message_name));
      end loop;

      for valid_new_var_ibr_csr in valid_new_var_ibr(l_intent) loop

		   update OKC_REVIEW_VAR_VALUES
		   set changed = 'A'
		   where REVIEW_UPLD_TERMS_id = valid_new_var_ibr_csr.REVIEW_UPLD_TERMS_id;

            if(valid_new_var_ibr_csr.modified='Y') then
		    l_message_name := 'OKC_REVIEW_VAR_ADDED';
		  else
		    l_message_name := 'OKC_REVIEW_VAR_ADD_NO_VAL';
		  end if;

            -- Insert the message only if the same message does not exist for that review_upld_terms_id
		  -- and variable_code
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number,
		  variable_code
            )
           (select okc_review_messages_s1.nextval review_messages_id,
               valid_new_var_ibr_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity, l_message_name ,1 object_version_number, valid_new_var_ibr_csr.variable_code from dual
			where not exists (select 1 from okc_review_messages where review_upld_terms_id = valid_new_var_ibr_csr.review_upld_terms_id
			and variable_code = valid_new_var_ibr_csr.variable_code and message_name = l_message_name));
      end loop;

      for removed_var_csr in variables_removed loop
	       -- Fix for bug# 5229387. Clauses should be marked as 'UPDATED' only if action is null
	       update okc_review_upld_terms
		  set action='UPDATED'
		  where review_upld_terms_id = removed_var_csr.review_upld_terms_id and action is null;

            insert into okc_review_var_values(
		  review_var_values_id,
		  review_upld_terms_id,
		  variable_name,
		  language,
		  variable_code,
		  object_version_number,
		  changed)
		  (select okc_review_var_values_s1.nextval,
		   removed_var_csr.review_upld_terms_id,
		   removed_var_csr.variable_name,
		   removed_var_csr.language,
		   removed_var_csr.variable_code,
		   1,
		   'D' from dual);

            -- Insert the message only if the same message does not exist for that review_upld_terms_id
		  -- and variable_code
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number,
		  variable_code
            )
           (select okc_review_messages_s1.nextval review_messages_id,
               removed_var_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity,'OKC_REVIEW_VAR_REMOVED' message_name ,1 object_version_number, removed_var_csr.variable_code from dual
			where not exists (select 1 from okc_review_messages where review_upld_terms_id = removed_var_csr.review_upld_terms_id
			and variable_code = removed_var_csr.variable_code and message_name = 'OKC_REVIEW_VAR_REMOVED'));
      end loop;

      l_message_name := 'OKC_REVIEW_INVALID_VARIABLE';
      for invalid_var_added_csr in invalid_variable_added(l_intent) loop
	        -- Fix for bug# 5229387. Clauses should be marked as 'UPDATED' only if action is null
	       update okc_review_upld_terms
		  set action='UPDATED'
		  where review_upld_terms_id = invalid_var_added_csr.review_upld_terms_id and action is null;

            -- Insert the message only if the same message does not exist for that review_upld_terms_id
		  -- and variable_code
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number,
		  variable_code
            )
           (select okc_review_messages_s1.nextval review_messages_id,
               invalid_var_added_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity, l_message_name ,1 object_version_number, invalid_var_added_csr.variable_code from dual
			where not exists (select 1 from okc_review_messages where review_upld_terms_id = invalid_var_added_csr.review_upld_terms_id
			and variable_code = invalid_var_added_csr.variable_code and message_name = l_message_name));
      end loop;

      -- Delete the duplicate variable rows for the given document_type, document_id
	 delete from okc_review_var_values revvar
	        where revvar.rowid > (select min(rowid) from okc_review_var_values
		                         where review_upld_terms_id = revvar.review_upld_terms_id
							and revvar.variable_code = variable_code)
		   and exists(select 1 from okc_Review_upld_terms rev
		                       where revvar.review_upld_terms_id = rev.review_upld_terms_id
						   and rev.document_type = p_document_type
						   and rev.document_id = p_document_id);


-- 2 way word sync with clause edit begins
    l_prof_value := OKC_WORD_DOWNLOAD_UPLOAD.GET_WORD_SYNC_PROFILE;
    IF l_prof_value = 'Y' THEN
       NULL;
    ELSE

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5000: Begin: Logging the ones that were determined as UPDATED');
	       for upd_csr in get_updated_articles_csr loop
		    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5010: for review_upld_terms_id=' || upd_csr.review_upld_terms_id );
		  end loop;
	     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6000: End: Logging the ones that were determined as UPDATED');
	    END IF;

    END IF;
-- 2 way word sync with clause edit ends

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: After delete review terms');
    END IF;
    l_clause_title := OKC_TERMS_UTIL_PVT.Get_Message('OKC','OKC_TERMS_DUMMY_CLAUSE');
    l_section_title := OKC_TERMS_UTIL_PVT.Get_Message('OKC','OKC_TERMS_DUMMY_SECTION');
    l_clause_counter:= 1;
    l_section_counter := 1;
    for emp_csr in empty_title_csr loop
        if(emp_csr.object_type = 'ARTICLE') then
            update okc_REVIEW_UPLD_TERMS
            set object_title = l_clause_title || l_clause_counter
            where REVIEW_UPLD_TERMS_id = emp_csr.REVIEW_UPLD_TERMS_id;
            l_clause_counter := l_clause_counter + 1;
        end if;
        if(emp_csr.object_type = 'SECTION') then
            update okc_REVIEW_UPLD_TERMS
            set object_title = l_section_title || l_section_counter
            where REVIEW_UPLD_TERMS_id = emp_csr.REVIEW_UPLD_TERMS_id;
            l_section_counter := l_section_counter + 1;
        end if;
    end loop;


    update okc_review_upld_terms rev
    set action = 'DELETED',
        object_title = (select nvl(ver.display_name,art. article_title)
	                   from OKC_K_ARTICLES_B kart, OKC_ARTICLES_ALL ART, OKC_ARTICLE_VERSIONS VER
				    where kart.id = rev.object_id
				    and   kart.sav_sae_id = art.article_id
				    and   kart.article_version_id = ver.article_version_id
				    and   art.article_id = ver.article_id)
	   ,object_text = (select ver.article_text from OKC_K_ARTICLES_B kart, OKC_ARTICLE_VERSIONS VER
	                   where kart.id = rev.object_id
				    and kart.article_Version_id = ver.article_version_id)

    where document_type = p_document_type
    and document_id = p_document_id
    and object_type = 'ARTICLE'
    and action = 'UPDATED'
    and (DBMS_LOB.getlength(object_text)=0  OR object_text is null);

    for ibr_csr in is_article_ibr(l_user_access) loop
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number

            )
            (select okc_review_messages_s1.nextval review_messages_id,
               ibr_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity,'OKC_ARTICLE_UPDT_IBR' message_name ,1 object_version_number from dual);
    end loop;

    for mandatory_csr in is_article_mandatory(l_user_access) loop
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number

            )
            (select okc_review_messages_s1.nextval review_messages_id,
               mandatory_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity,'OKC_ARTICLE_IS_MANDATORY' message_name ,1 object_version_number from dual);
    end loop;

    for lock_csr in is_article_text_locked(l_user_access) loop
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number

            )
            (select okc_review_messages_s1.nextval review_messages_id,
               lock_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity,'OKC_ARTICLE_UPDT_LOCK' message_name ,1 object_version_number from dual);
    end loop;

    l_message_name := 'OKC_UPLOAD_CLAUSE_TITLE_LONG';
    for title_csr in check_sec_clause_title loop
           if(title_csr.object_Type='SECTION') then
		   l_message_name := 'OKC_UPLOAD_SECTION_NAME_LONG';
		 end if;
		 if(title_csr.object_type= 'ARTICLE') then
		   l_message_name := 'OKC_UPLOAD_CLAUSE_TITLE_LONG';
		 end if;
            insert into okc_review_messages (
            review_messages_id,
            REVIEW_UPLD_TERMS_id,
            error_severity,
            message_name,
            object_version_number

            )
            (select okc_review_messages_s1.nextval review_messages_id,
               title_csr.REVIEW_UPLD_TERMS_id REVIEW_UPLD_TERMS_id,
               'W' error_severity, l_message_name,1 object_version_number from dual);

    end loop;
    for upd_csr in update_err_warn_csr loop
        if (upd_csr.error_severity = 'E') then
            update okc_review_upld_terms
                set error_message_count = upd_csr.err_warn_count
                where review_upld_terms_id = upd_csr.review_upld_terms_id;
        end if;
        if (upd_csr.error_severity = 'W') then
            update okc_review_upld_terms
                set warning_message_count = upd_csr.err_warn_count
                where review_upld_terms_id = upd_csr.review_upld_terms_id;
        end if;
    end loop;
    OKC_TEMPLATE_USAGES_GRP.update_template_usages(
        p_api_version                  => l_api_version,
	   p_init_msg_list                => p_init_msg_list ,
	   p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
	   p_commit                       => FND_API.G_FALSE,
	   x_return_status                => x_return_status,
	   x_msg_count                    => x_msg_count,
	   x_msg_data                     => x_msg_data,
	   p_document_type          => p_document_type,
	   p_document_id            => p_document_id,
	   p_lock_terms_flag        => 'Y',
	   p_locked_by_user_id      => FND_GLOBAL.user_id);

    open current_num_scheme;
        fetch current_num_scheme into l_doc_num_scheme;
    close current_num_scheme;

  curr_disp_seqs.DELETE;
  del_new_parents.DELETE;
  del_disp_seqs.DELETE;

  FOR rec in parent_ids_csr LOOP
    curr_disp_seqs(rec.review_upld_terms_id) := 0;
  END LOOP;

  IF curr_disp_seqs.COUNT > 0 THEN
    curr_disp_seqs(-999) := 0;
  END IF;
  OPEN deleted_terms_csr;
  FETCH deleted_terms_csr BULK COLLECT INTO
    del_new_parents,del_disp_seqs;
  CLOSE deleted_terms_csr;

  l_sequence := 0;
  FOR disp_rec in terms_disp_csr LOOP
    IF disp_rec.object_type IN ('ARTICLE','SECTION') THEN
      l_sequence := curr_disp_seqs(NVL(disp_rec.new_parent_id,-999)) + 10;

      IF del_new_parents.COUNT > 0 THEN
        FOR i in del_new_parents.FIRST .. del_new_parents.LAST LOOP
          IF (NVL(del_new_parents(i),-999) = NVL(disp_rec.new_parent_id,-999) AND
	       del_disp_seqs(i) = l_sequence) THEN
	       l_sequence := l_sequence + 10;
	       EXIT;
          END IF;
        END LOOP;
      END IF;

    UPDATE okc_review_upld_terms
    SET display_seq = l_sequence
    WHERE review_upld_terms_id = disp_rec.review_upld_terms_id;

    curr_disp_seqs(NVL(disp_rec.new_parent_id,-999)) := l_sequence;
    END IF;

  END LOOP;


    for upd_csr in update_err_warn_csr loop
        if (upd_csr.error_severity = 'E') then
            update okc_review_upld_terms
                set error_message_count = upd_csr.err_warn_count
                where review_upld_terms_id = upd_csr.review_upld_terms_id;
        end if;
        if (upd_csr.error_severity = 'W') then
            update okc_review_upld_terms
                set warning_message_count = upd_csr.err_warn_count
                where review_upld_terms_id = upd_csr.review_upld_terms_id;
        end if;
    end loop;
    if(l_doc_num_scheme is NOT NULL) then
        OKC_NUMBER_SCHEME_GRP.apply_num_scheme_4_review(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_commit => p_commit,
        p_validation_string => p_validation_string,
        p_doc_type => p_document_type,
        p_doc_id => p_document_id,
        p_num_scheme_id => l_doc_num_scheme);
    end if;
    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Reject_Changes: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_reject_changes;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Reject_Changes: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_reject_Changes;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'700: Leaving reject_changes because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_reject_changes;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );
  END Sync_Review_Tables;

/*
-- PROCEDURE Create_Unassigned_Section
-- creating un-assigned sections in a document in okc_REVIEW_UPLD_TERMS table
*/
  PROCEDURE Create_Unassigned_Section (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_document_type          IN  VARCHAR2,
    p_document_id            IN  NUMBER,
    p_new_parent_id     IN  NUMBER,

    x_scn_id            OUT NOCOPY NUMBER
  ) IS
    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'Create_Unassigned_Section';
    l_meaning           VARCHAR2(100);
    l_sequence          NUMBER;
    l_scn_id            NUMBER;
    l_temp_id           NUMBER;
Cursor l_get_max_seq_csr IS
SELECT nvl(max(display_seq),0)+10
FROM OKC_REVIEW_UPLD_TERMS
WHERE DOCUMENT_TYPE= p_document_type
AND   DOCUMENT_ID  = p_document_id
AND   PARENT_ID IS NULL or new_parent_id = p_document_id;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7500: Entered Create_Unassigned_Section');
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT g_Create_Unassigned_Section;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    --------------------------------------------
    -- Call Simple API of okc_sections_b with following input
    -- doc_type=p_doc_type, doc_id=p_doc_id, scn_code=G_UNASSIGNED_SECTION_CODE,
    -- heading = < get meaning of G_UNASSIGNED_SECTION_CODE by quering fnd_lookups>.
    -- Set x_scn_id to id returned by simpel API.
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7600: Calling Simple API to Create a Section');
    END IF;
    --------------------------------------------
    l_meaning := Okc_Util.Decode_Lookup('OKC_ARTICLE_SECTION',G_UNASSIGNED_SECTION_CODE);

--Bug 3669528 Unassigned section should always come at the bottom, so use a 'high' value
/*
    OPEN  l_get_max_seq_csr;
    FETCH l_get_max_seq_csr INTO l_sequence;
    CLOSE l_get_max_seq_csr;
*/
    l_sequence:= 9999;
      x_return_status := Get_Seq_Id(
        p_REVIEW_UPLD_TERMS_id => l_temp_id,
        x_REVIEW_UPLD_TERMS_id => l_scn_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    x_scn_id := l_scn_id;
    INSERT INTO OKC_REVIEW_UPLD_TERMS(
    REVIEW_UPLD_TERMS_ID,
    DOCUMENT_ID,
    DOCUMENT_TYPE,
    OBJECT_ID,
    OBJECT_TYPE,
    OBJECT_TITLE,
    OBJECT_TEXT,
    PARENT_OBJECT_TYPE,
    PARENT_ID,
    ARTICLE_ID,
    ARTICLE_VERSION_ID,
    OBJECT_VERSION_NUMBER,
    LABEL,
    DISPLAY_SEQ,
    ACTION,
    ERROR_MESSAGE_COUNT,
    WARNING_MESSAGE_COUNT,
    NEW_PARENT_ID,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE)
    (SELECT l_scn_id,
    P_DOCUMENT_ID,
    P_DOCUMENT_TYPE,
    NULL,
    'SECTION',
    l_meaning,
    NULL,
    p_document_type,
    p_document_id,
    NULL,
    NULL,
    1,
    NULL,
    l_sequence,
    'ADDED',
    NULL,
    NULL,
    p_new_parent_id,
    FND_GLOBAL.LOGIN_ID,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE
    FROM dual);

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7700: Leaving Create_Unassigned_Section');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO g_Create_Unassigned_Section;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Create_Unassigned_Section : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO g_Create_Unassigned_Section;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Create_Unassigned_Section : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      ROLLBACK TO g_Create_Unassigned_Section;
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Create_Unassigned_Section because of EXCEPTION: '||sqlerrm);
      END IF;

      IF l_get_max_seq_csr%ISOPEN THEN
         CLOSE l_get_max_seq_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  END Create_Unassigned_Section ;


END OKC_REVIEW_UPLD_TERMS_PVT;

/

--------------------------------------------------------
--  DDL for Package Body OKC_DOC_QA_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DOC_QA_LIST_PVT" AS
/* $Header: OKCVQALB.pls 120.0 2005/05/25 19:45:57 appldev noship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_QAL_PVT';
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

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_DOC_QA_LISTS
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,

    x_severity_flag         OUT NOCOPY VARCHAR2,
    x_enable_qa_yn          OUT NOCOPY VARCHAR2,
    x_object_version_number OUT NOCOPY NUMBER,
    x_created_by            OUT NOCOPY NUMBER,
    x_creation_date         OUT NOCOPY DATE,
    x_last_updated_by       OUT NOCOPY NUMBER,
    x_last_update_login     OUT NOCOPY NUMBER,
    x_last_update_date      OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_DOC_QA_LISTS_pk_csr (cp_qa_code IN VARCHAR2,cp_document_type IN VARCHAR2) IS
    SELECT
            SEVERITY_FLAG,
            ENABLE_QA_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
      FROM OKC_DOC_QA_LISTS t
     WHERE t.QA_CODE = cp_qa_code and
           t.DOCUMENT_TYPE = cp_document_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    -- Get current database values
    OPEN OKC_DOC_QA_LISTS_pk_csr (p_qa_code, p_document_type);
    FETCH OKC_DOC_QA_LISTS_pk_csr INTO
            x_severity_flag,
            x_enable_qa_yn,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date;
    IF OKC_DOC_QA_LISTS_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_DOC_QA_LISTS_pk_csr;

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

      IF OKC_DOC_QA_LISTS_pk_csr%ISOPEN THEN
        CLOSE OKC_DOC_QA_LISTS_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_DOC_QA_LISTS --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,
    p_object_version_number IN NUMBER,

    x_object_version_number OUT NOCOPY NUMBER,
    x_severity_flag         OUT NOCOPY VARCHAR2,
    x_enable_qa_yn          OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number OKC_DOC_QA_LISTS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by            OKC_DOC_QA_LISTS.CREATED_BY%TYPE;
    l_creation_date         OKC_DOC_QA_LISTS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_DOC_QA_LISTS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_DOC_QA_LISTS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_DOC_QA_LISTS.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;

    IF( p_qa_code IS NOT NULL AND p_document_type IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_qa_code               => p_qa_code,
        p_document_type         => p_document_type,
        x_severity_flag         => x_severity_flag,
        x_enable_qa_yn         => x_enable_qa_yn,
        x_object_version_number => x_object_version_number,
        x_created_by            => l_created_by,
        x_creation_date         => l_creation_date,
        x_last_updated_by       => l_last_updated_by,
        x_last_update_login     => l_last_update_login,
        x_last_update_date      => l_last_update_date
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_severity_flag = G_MISS_CHAR) THEN
        x_severity_flag := NULL;
       ELSIF (p_SEVERITY_FLAG IS NOT NULL) THEN
        x_severity_flag := Upper( p_severity_flag );
      END IF;


      IF (p_enable_qa_yn = G_MISS_CHAR) THEN
        x_enable_qa_yn := NULL;
       ELSIF (p_SEVERITY_FLAG IS NOT NULL) THEN
        x_enable_qa_yn := Upper( p_enable_qa_yn );
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
  -- Validate_Attributes for: OKC_DOC_QA_LISTS --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
    CURSOR l_doc_type_csr is
     SELECT '!'
      FROM OKC_BUS_DOC_TYPES_V
      WHERE DOCUMENT_TYPE = p_document_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute QA_CODE ', 2);
      END IF;
      IF ( p_qa_code IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute QA_CODE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'QA_CODE');
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
        Okc_Debug.Log('1400: - attribute SEVERITY_FLAG ', 2);
      END IF;
      IF ( p_severity_flag IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute SEVERITY_FLAG is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'SEVERITY_FLAG');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute ENABLE_QA_YN ', 2);
      END IF;
      IF ( p_enable_qa_yn IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute ENABLE_QA_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ENABLE_QA_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;
    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: static values and range validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute SEVERITY_FLAG ', 2);
      END IF;
      IF ( p_severity_flag NOT IN ('E','W') AND p_severity_flag IS NOT NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute SEVERITY_FLAG is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SEVERITY_FLAG');
        l_return_status := G_RET_STS_ERROR;
      END IF;


      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute ENABLE_QA_YN ', 2);
      END IF;
      IF ( p_ENABLE_QA_YN NOT IN ('Y','N') AND p_ENABLE_QA_YN IS NOT NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute ENABLE_QA_YN is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ENABLE_QA_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;
    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1900: lookup codes validation', 2);
      END IF;
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute QA_CODE ', 2);
      END IF;
      IF p_qa_code IS NOT NULL THEN
        l_return_status := Okc_Util.Check_Lookup_Code('OKC_TERM_QA_LIST',p_qa_code);
        IF (l_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'QA_CODE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute DOCUMENT_TYPE ', 2);
      END IF;
      IF p_document_type IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_doc_type_csr ;
        FETCH l_doc_type_csr INTO l_dummy_var;
        CLOSE l_doc_type_csr ;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute DOCUMENT_TYPE is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DOCUMENT_TYPE');
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

      IF l_doc_type_csr%ISOPEN THEN
        CLOSE l_doc_type_csr ;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_DOC_QA_LISTS --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn
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
  -- validate_row for:OKC_DOC_QA_LISTS --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn             IN VARCHAR2,



    p_object_version_number IN NUMBER
  ) IS
      l_severity_flag         OKC_DOC_QA_LISTS.SEVERITY_FLAG%TYPE;
      l_enable_qa_yn          OKC_DOC_QA_LISTS.enable_qa_yn%TYPE;
      l_object_version_number OKC_DOC_QA_LISTS.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by            OKC_DOC_QA_LISTS.CREATED_BY%TYPE;
      l_creation_date         OKC_DOC_QA_LISTS.CREATION_DATE%TYPE;
      l_last_updated_by       OKC_DOC_QA_LISTS.LAST_UPDATED_BY%TYPE;
      l_last_update_login     OKC_DOC_QA_LISTS.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date      OKC_DOC_QA_LISTS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn,
      p_object_version_number => p_object_version_number,
      x_object_version_number => l_object_version_number,
      x_severity_flag         => l_severity_flag,
      x_enable_qa_yn          => l_enable_qa_yn
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => l_severity_flag,
      p_enable_qa_yn          => l_enable_qa_yn
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
  -- Insert_Row for:OKC_DOC_QA_LISTS --
  -------------------------------------
  FUNCTION Insert_Row(
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,
    p_object_version_number IN NUMBER,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE,
    p_last_updated_by       IN NUMBER,
    p_last_update_login     IN NUMBER,
    p_last_update_date      IN DATE

  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;

    INSERT INTO OKC_DOC_QA_LISTS(
        QA_CODE,
        DOCUMENT_TYPE,
        SEVERITY_FLAG,
        ENABLE_QA_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        p_qa_code,
        p_document_type,
        p_severity_flag,
        p_enable_qa_yn,
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
  -- Insert_Row for:OKC_DOC_QA_LISTS --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,



    x_qa_code               OUT NOCOPY VARCHAR2,
    x_document_type         OUT NOCOPY VARCHAR2

  ) IS

    l_object_version_number OKC_DOC_QA_LISTS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by            OKC_DOC_QA_LISTS.CREATED_BY%TYPE;
    l_creation_date         OKC_DOC_QA_LISTS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_DOC_QA_LISTS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_DOC_QA_LISTS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_DOC_QA_LISTS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;

    --- Setting item attributes
    -- Set primary key value
    x_qa_code := p_qa_code;
    x_document_type := p_document_type;
    -- Set Internal columns
    l_object_version_number := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;


    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_qa_code               => x_qa_code,
      p_document_type         => x_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn
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
      p_qa_code               => x_qa_code,
      p_document_type         => x_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn,
      p_object_version_number => l_object_version_number,
      p_created_by            => l_created_by,
      p_creation_date         => l_creation_date,
      p_last_updated_by       => l_last_updated_by,
      p_last_update_login     => l_last_update_login,
      p_last_update_date      => l_last_update_date
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
  -- Lock_Row for:OKC_DOC_QA_LISTS --
  -----------------------------------
  FUNCTION Lock_Row(
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_object_version_number IN NUMBER
  ) RETURN VARCHAR2 IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (cp_qa_code VARCHAR2, cp_document_type VARCHAR2, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_DOC_QA_LISTS
     WHERE QA_CODE = cp_qa_code AND DOCUMENT_TYPE = cp_document_type
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_qa_code VARCHAR2, cp_document_type VARCHAR2) IS
    SELECT object_version_number
      FROM OKC_DOC_QA_LISTS
     WHERE QA_CODE = cp_qa_code AND DOCUMENT_TYPE = cp_document_type;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_DOC_QA_LISTS.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;


    BEGIN

      OPEN lock_csr( p_qa_code, p_document_type, p_object_version_number );
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

      OPEN lchk_csr(p_qa_code, p_document_type);
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
  -- Lock_Row for:OKC_DOC_QA_LISTS --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_object_version_number IN NUMBER
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
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_object_version_number => p_object_version_number
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
  -- Update_Row for:OKC_DOC_QA_LISTS --
  -------------------------------------
  FUNCTION Update_Row(
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,
    p_object_version_number IN NUMBER,
    p_last_updated_by       IN NUMBER,
    p_last_update_login     IN NUMBER,
    p_last_update_date      IN DATE
   ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;

    UPDATE OKC_DOC_QA_LISTS
     SET SEVERITY_FLAG         = p_severity_flag,
         ENABLE_QA_YN          = p_enable_qa_yn,
         OBJECT_VERSION_NUMBER = p_object_version_number,
         LAST_UPDATED_BY       = p_last_updated_by,
         LAST_UPDATE_LOGIN     = p_last_update_login,
         LAST_UPDATE_DATE      = p_last_update_date
    WHERE QA_CODE               = p_qa_code AND DOCUMENT_TYPE         = p_document_type;

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
  -- Update_Row for:OKC_DOC_QA_LISTS --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2 := NULL,
    p_enable_qa_yn          IN VARCHAR2 := NULL,

    p_object_version_number IN NUMBER

   ) IS

    l_severity_flag         OKC_DOC_QA_LISTS.SEVERITY_FLAG%TYPE;
    l_enable_qa_yn          OKC_DOC_QA_LISTS.ENABLE_QA_YN%TYPE;
    l_object_version_number OKC_DOC_QA_LISTS.OBJECT_VERSION_NUMBER%TYPE;
    l_last_updated_by       OKC_DOC_QA_LISTS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_DOC_QA_LISTS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_DOC_QA_LISTS.LAST_UPDATE_DATE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_object_version_number => p_object_version_number
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
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => p_severity_flag,
      p_enable_qa_yn          => p_enable_qa_yn,
      p_object_version_number => p_object_version_number,
      x_object_version_number => l_object_version_number,
      x_severity_flag         => l_severity_flag,
      x_enable_qa_yn          => l_enable_qa_yn
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
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => l_severity_flag,
      p_enable_qa_yn          => l_enable_qa_yn
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
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_severity_flag         => l_severity_flag,
      p_enable_qa_yn          => l_enable_qa_yn,
      p_object_version_number => l_object_version_number,
      p_last_updated_by       => l_last_updated_by,
      p_last_update_login     => l_last_update_login,
      p_last_update_date      => l_last_update_date
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
  -- Delete_Row for:OKC_DOC_QA_LISTS --
  -------------------------------------
  FUNCTION Delete_Row(
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;

    DELETE FROM OKC_DOC_QA_LISTS
      WHERE QA_CODE = p_QA_CODE AND DOCUMENT_TYPE = p_DOCUMENT_TYPE;

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
  -- Delete_Row for:OKC_DOC_QA_LISTS --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_object_version_number IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_qa_code               => p_qa_code,
      p_document_type         => p_document_type,
      p_object_version_number => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9100: Removing _B row', 2);
    END IF;
    x_return_status := Delete_Row( p_qa_code => p_qa_code,p_document_type => p_document_type );
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



END OKC_DOC_QA_LIST_PVT;

/

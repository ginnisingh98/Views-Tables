--------------------------------------------------------
--  DDL for Package Body OKC_REVIEW_VAR_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REVIEW_VAR_VALUES_PVT" AS
/* $Header: OKCVRUVB.pls 120.2 2005/09/13 22:38 vnanjang noship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REVIEW_VAR_VALUES_PVT';
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
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    x_REVIEW_UPLD_TERMS_id  OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_seq_csr IS
     SELECT OKC_REVIEW_VAR_VALUES_S1.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF( p_REVIEW_UPLD_TERMS_id  IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_REVIEW_UPLD_TERMS_id ;
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
  -- FUNCTION get_rec for: OKC_REVIEW_VAR_VALUES
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,

    x_REVIEW_VAR_VALUES_id OUT NOCOPY NUMBER,
    x_variable_name             OUT NOCOPY VARCHAR2,
    x_variable_code             OUT NOCOPY VARCHAR2,
    x_variable_type             OUT NOCOPY VARCHAR2,
    x_variable_value_id         OUT NOCOPY NUMBER,
    x_variable_value            OUT NOCOPY VARCHAR2,
    x_attribute_value_set_id    OUT NOCOPY NUMBER,
    x_object_version_number     OUT NOCOPY NUMBER,
    x_created_by                OUT NOCOPY NUMBER,
    x_creation_date             OUT NOCOPY DATE,
    x_last_updated_by           OUT NOCOPY NUMBER,
    x_last_update_login         OUT NOCOPY NUMBER,
    x_last_update_date          OUT NOCOPY DATE,
    x_language                  OUT NOCOPY VARCHAR2

  ) RETURN VARCHAR2 IS
    CURSOR OKC_REVIEW_VAR_VALUES_pk_csr (cp_REVIEW_UPLD_TERMS_id IN NUMBER) IS
    SELECT
            REVIEW_VAR_VALUES_ID,
            VARIABLE_NAME,
            VARIABLE_CODE,
            VARIABLE_TYPE,
            VARIABLE_VALUE_ID,
            VARIABLE_VALUE,
            ATTRIBUTE_VALUE_SET_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            LANGUAGE
      FROM OKC_REVIEW_VAR_VALUES t
     WHERE t.REVIEW_UPLD_TERMS_ID = cp_REVIEW_UPLD_TERMS_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    -- Get current database values
    OPEN OKC_REVIEW_VAR_VALUES_pk_csr (p_REVIEW_UPLD_TERMS_id);
    FETCH OKC_REVIEW_VAR_VALUES_pk_csr INTO
            x_REVIEW_VAR_VALUES_id,
            x_variable_name,
            x_variable_code,
            x_variable_type,
            x_variable_value_id,
            x_variable_value,
            x_attribute_value_set_id,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,
            x_language;
    IF OKC_REVIEW_VAR_VALUES_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_REVIEW_VAR_VALUES_pk_csr;

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

      IF OKC_REVIEW_VAR_VALUES_pk_csr%ISOPEN THEN
        CLOSE OKC_REVIEW_VAR_VALUES_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_REVIEW_VAR_VALUES --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,
    p_attribute_value_set_id    IN NUMBER,
    p_object_version_number     IN OUT NOCOPY NUMBER,

    x_REVIEW_VAR_VALUES_id OUT NOCOPY NUMBER,
    x_variable_name             OUT NOCOPY VARCHAR2,
    x_variable_code             OUT NOCOPY VARCHAR2,
    x_variable_type             OUT NOCOPY VARCHAR2,
    x_variable_value_id         OUT NOCOPY NUMBER,
    x_variable_value            OUT NOCOPY VARCHAR2,
    x_attribute_value_set_id    OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number     OKC_REVIEW_VAR_VALUES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                OKC_REVIEW_VAR_VALUES.CREATED_BY%TYPE;
    l_creation_date             OKC_REVIEW_VAR_VALUES.CREATION_DATE%TYPE;
    l_last_updated_by           OKC_REVIEW_VAR_VALUES.LAST_UPDATED_BY%TYPE;
    l_last_update_login         OKC_REVIEW_VAR_VALUES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date          OKC_REVIEW_VAR_VALUES.LAST_UPDATE_DATE%TYPE;
    l_language                  OKC_REVIEW_VAR_VALUES.LANGUAGE%TYPE;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;

    IF( p_REVIEW_UPLD_TERMS_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
        x_REVIEW_VAR_VALUES_id => x_REVIEW_VAR_VALUES_id,
        x_variable_name             => x_variable_name,
        x_variable_code             => x_variable_code,
        x_variable_type             => x_variable_type,
        x_variable_value_id         => x_variable_value_id,
        x_variable_value            => x_variable_value,
        x_attribute_value_set_id    => x_attribute_value_set_id,
        x_object_version_number     => l_object_version_number,
        x_created_by                => l_created_by,
        x_creation_date             => l_creation_date,
        x_last_updated_by           => l_last_updated_by,
        x_last_update_login         => l_last_update_login,
        x_last_update_date          => l_last_update_date,
        x_language                  => l_language
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_REVIEW_VAR_VALUES_id = G_MISS_NUM) THEN
        x_REVIEW_VAR_VALUES_id := NULL;
       ELSIF (p_REVIEW_VAR_VALUES_id IS NOT NULL) THEN
        x_REVIEW_VAR_VALUES_id := p_REVIEW_VAR_VALUES_id;
      END IF;

      IF (p_variable_name = G_MISS_CHAR) THEN
        x_variable_name := NULL;
       ELSIF (p_variable_name IS NOT NULL) THEN
        x_variable_name := p_variable_name;
      END IF;

      IF (p_variable_code = G_MISS_CHAR) THEN
        x_variable_code := NULL;
       ELSIF (p_variable_code IS NOT NULL) THEN
        x_variable_code := p_variable_code;
      END IF;

      IF (p_variable_type = G_MISS_CHAR) THEN
        x_variable_type := NULL;
       ELSIF (p_variable_type IS NOT NULL) THEN
        x_variable_type := p_variable_type;
      END IF;

      IF (p_variable_value_id = G_MISS_NUM) THEN
        x_variable_value_id := NULL;
       ELSIF (p_variable_value_id IS NOT NULL) THEN
        x_variable_value_id := p_variable_value_id;
      END IF;

      IF (p_variable_value = G_MISS_CHAR) THEN
        x_variable_value := NULL;
       ELSIF (p_variable_value IS NOT NULL) THEN
        x_variable_value := p_variable_value;
      END IF;

      IF (p_attribute_value_set_id = G_MISS_NUM) THEN
        x_attribute_value_set_id := NULL;
       ELSIF (p_attribute_value_set_id IS NOT NULL) THEN
        x_attribute_value_set_id := p_attribute_value_set_id;
      END IF;


      IF (p_object_version_number IS NULL) THEN
        p_object_version_number := l_object_version_number;
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
  -- Validate_Attributes for: OKC_REVIEW_VAR_VALUES --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,
    p_attribute_value_set_id    IN NUMBER
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
/* ?? uncomment next part after you check and change this foreign key validation

    CURSOR l_REVIEW_VAR_VALUES_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??REVIEW_VAR_VALUES_ID?? = p_REVIEW_VAR_VALUES_id;

    CURSOR l_REVIEW_UPLD_TERMS_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??REVIEW_UPLD_TERMS_ID?? = p_REVIEW_UPLD_TERMS_id;

    CURSOR l_variable_value_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??VARIABLE_VALUE_ID?? = p_variable_value_id;

    CURSOR l_attribute_value_set_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??ATTRIBUTE_VALUE_SET_ID?? = p_attribute_value_set_id;

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

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute VARIABLE_CODE ', 2);
      END IF;
      IF p_variable_code IS NOT NULL THEN
        l_return_status := Okc_Util.Check_Lookup_Code(??'lookup_code_type'??,p_variable_code);
        IF (l_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'VARIABLE_CODE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

*/
    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;
/* ?? uncomment next part after you check and change this foreign key validation

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute REVIEW_VAR_VALUES_ID ', 2);
      END IF;
      IF p_REVIEW_VAR_VALUES_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_REVIEW_VAR_VALUES_id_csr;
        FETCH l_REVIEW_VAR_VALUES_id_csr INTO l_dummy_var;
        CLOSE l_REVIEW_VAR_VALUES_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute REVIEW_VAR_VALUES_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REVIEW_VAR_VALUES_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

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
         Okc_Debug.Log('2200: - attribute VARIABLE_VALUE_ID ', 2);
      END IF;
      IF p_variable_value_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_variable_value_id_csr;
        FETCH l_variable_value_id_csr INTO l_dummy_var;
        CLOSE l_variable_value_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute VARIABLE_VALUE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'VARIABLE_VALUE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ATTRIBUTE_VALUE_SET_ID ', 2);
      END IF;
      IF p_attribute_value_set_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_attribute_value_set_id_csr;
        FETCH l_attribute_value_set_id_csr INTO l_dummy_var;
        CLOSE l_attribute_value_set_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute ATTRIBUTE_VALUE_SET_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ATTRIBUTE_VALUE_SET_ID');
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

      IF l_REVIEW_VAR_VALUES_id_csr%ISOPEN THEN
        CLOSE l_REVIEW_VAR_VALUES_id_csr;
      END IF;

      IF l_REVIEW_UPLD_TERMS_id_csr%ISOPEN THEN
        CLOSE l_REVIEW_UPLD_TERMS_id_csr;
      END IF;

      IF l_variable_value_id_csr%ISOPEN THEN
        CLOSE l_variable_value_id_csr;
      END IF;

      IF l_attribute_value_set_id_csr%ISOPEN THEN
        CLOSE l_attribute_value_set_id_csr;
      END IF;

*/
      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_REVIEW_VAR_VALUES --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,
    p_attribute_value_set_id    IN NUMBER
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_REVIEW_VAR_VALUES_id => p_REVIEW_VAR_VALUES_id,
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_variable_name             => p_variable_name,
      p_variable_code             => p_variable_code,
      p_variable_type             => p_variable_type,
      p_variable_value_id         => p_variable_value_id,
      p_variable_value            => p_variable_value,
      p_attribute_value_set_id    => p_attribute_value_set_id
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
  -- validate_row for:OKC_REVIEW_VAR_VALUES --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,

    p_attribute_value_set_id    IN NUMBER := NULL,

    p_object_version_number     IN NUMBER
  ) IS
      l_REVIEW_VAR_VALUES_id OKC_REVIEW_VAR_VALUES.REVIEW_VAR_VALUES_ID%TYPE;
      l_variable_name             OKC_REVIEW_VAR_VALUES.VARIABLE_NAME%TYPE;
      l_variable_code             OKC_REVIEW_VAR_VALUES.VARIABLE_CODE%TYPE;
      l_variable_type             OKC_REVIEW_VAR_VALUES.VARIABLE_TYPE%TYPE;
      l_variable_value_id         OKC_REVIEW_VAR_VALUES.VARIABLE_VALUE_ID%TYPE;
      l_variable_value            OKC_REVIEW_VAR_VALUES.VARIABLE_VALUE%TYPE;
      l_attribute_value_set_id    OKC_REVIEW_VAR_VALUES.ATTRIBUTE_VALUE_SET_ID%TYPE;
      l_object_version_number     OKC_REVIEW_VAR_VALUES.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by                OKC_REVIEW_VAR_VALUES.CREATED_BY%TYPE;
      l_creation_date             OKC_REVIEW_VAR_VALUES.CREATION_DATE%TYPE;
      l_last_updated_by           OKC_REVIEW_VAR_VALUES.LAST_UPDATED_BY%TYPE;
      l_last_update_login         OKC_REVIEW_VAR_VALUES.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date          OKC_REVIEW_VAR_VALUES.LAST_UPDATE_DATE%TYPE;
      l_language                  OKC_REVIEW_VAR_VALUES.LANGUAGE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_REVIEW_VAR_VALUES_id => p_REVIEW_VAR_VALUES_id,
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_variable_name             => p_variable_name,
      p_variable_code             => p_variable_code,
      p_variable_type             => p_variable_type,
      p_variable_value_id         => p_variable_value_id,
      p_variable_value            => p_variable_value,
      p_attribute_value_set_id    => p_attribute_value_set_id,
      p_object_version_number     => l_object_version_number,
      x_REVIEW_VAR_VALUES_id => l_REVIEW_VAR_VALUES_id,
      x_variable_name             => l_variable_name,
      x_variable_code             => l_variable_code,
      x_variable_type             => l_variable_type,
      x_variable_value_id         => l_variable_value_id,
      x_variable_value            => l_variable_value,
      x_attribute_value_set_id    => l_attribute_value_set_id
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    l_object_version_number     := p_object_version_number    ;
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_REVIEW_VAR_VALUES_id => l_REVIEW_VAR_VALUES_id,
      p_variable_name             => l_variable_name,
      p_variable_code             => l_variable_code,
      p_variable_type             => l_variable_type,
      p_variable_value_id         => l_variable_value_id,
      p_variable_value            => l_variable_value,
      p_attribute_value_set_id    => l_attribute_value_set_id
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
  -- Insert_Row for:OKC_REVIEW_VAR_VALUES --
  -------------------------------------
  FUNCTION Insert_Row(
    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,
    p_attribute_value_set_id    IN NUMBER,
    p_object_version_number     IN NUMBER,
    p_created_by                IN NUMBER,
    p_creation_date             IN DATE,
    p_last_updated_by           IN NUMBER,
    p_last_update_login         IN NUMBER,
    p_last_update_date          IN DATE

  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;

    INSERT INTO OKC_REVIEW_VAR_VALUES(
        REVIEW_VAR_VALUES_ID,
        REVIEW_UPLD_TERMS_ID,
        VARIABLE_NAME,
        VARIABLE_CODE,
        VARIABLE_TYPE,
        VARIABLE_VALUE_ID,
        VARIABLE_VALUE,
        ATTRIBUTE_VALUE_SET_ID,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE
        )
      VALUES (
        p_REVIEW_VAR_VALUES_id,
        p_REVIEW_UPLD_TERMS_id,
        p_variable_name,
        p_variable_code,
        p_variable_type,
        p_variable_value_id,
        p_variable_value,
        p_attribute_value_set_id,
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
  -- Insert_Row for:OKC_REVIEW_VAR_VALUES --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,

    p_attribute_value_set_id    IN NUMBER := NULL,

    x_REVIEW_UPLD_TERMS_id  OUT NOCOPY NUMBER

  ) IS

    l_object_version_number     OKC_REVIEW_VAR_VALUES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                OKC_REVIEW_VAR_VALUES.CREATED_BY%TYPE;
    l_creation_date             OKC_REVIEW_VAR_VALUES.CREATION_DATE%TYPE;
    l_last_updated_by           OKC_REVIEW_VAR_VALUES.LAST_UPDATED_BY%TYPE;
    l_last_update_login         OKC_REVIEW_VAR_VALUES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date          OKC_REVIEW_VAR_VALUES.LAST_UPDATE_DATE%TYPE;
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
    l_object_version_number     := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;


    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_REVIEW_UPLD_TERMS_id  => x_REVIEW_UPLD_TERMS_id,
      p_REVIEW_VAR_VALUES_id => p_REVIEW_VAR_VALUES_id,
      p_variable_name             => p_variable_name,
      p_variable_code             => p_variable_code,
      p_variable_type             => p_variable_type,
      p_variable_value_id         => p_variable_value_id,
      p_variable_value            => p_variable_value,
      p_attribute_value_set_id    => p_attribute_value_set_id
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
      p_REVIEW_UPLD_TERMS_id  => x_REVIEW_UPLD_TERMS_id,
      p_REVIEW_VAR_VALUES_id => p_REVIEW_VAR_VALUES_id,
      p_variable_name             => p_variable_name,
      p_variable_code             => p_variable_code,
      p_variable_type             => p_variable_type,
      p_variable_value_id         => p_variable_value_id,
      p_variable_value            => p_variable_value,
      p_attribute_value_set_id    => p_attribute_value_set_id,
      p_object_version_number     => l_object_version_number,
      p_created_by                => l_created_by,
      p_creation_date             => l_creation_date,
      p_last_updated_by           => l_last_updated_by,
      p_last_update_login         => l_last_update_login,
      p_last_update_date          => l_last_update_date
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
  -- Lock_Row for:OKC_REVIEW_VAR_VALUES --
  -----------------------------------
  FUNCTION Lock_Row(
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_object_version_number     IN NUMBER
  ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);
    l_object_version_number       OKC_REVIEW_VAR_VALUES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;

    CURSOR lock_csr (cp_REVIEW_UPLD_TERMS_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_REVIEW_VAR_VALUES
     WHERE REVIEW_UPLD_TERMS_ID = cp_REVIEW_UPLD_TERMS_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_REVIEW_UPLD_TERMS_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_REVIEW_VAR_VALUES
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
  -- Lock_Row for:OKC_REVIEW_VAR_VALUES --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_object_version_number     IN NUMBER
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
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_object_version_number     => p_object_version_number
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
  -- Update_Row for:OKC_REVIEW_VAR_VALUES --
  -------------------------------------
  FUNCTION Update_Row(
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,
    p_attribute_value_set_id    IN NUMBER,
    p_object_version_number     IN NUMBER,
    p_last_updated_by           IN NUMBER,
    p_last_update_login         IN NUMBER,
    p_last_update_date          IN DATE
   ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;

    UPDATE OKC_REVIEW_VAR_VALUES
     SET REVIEW_VAR_VALUES_ID = p_REVIEW_VAR_VALUES_id,
         VARIABLE_NAME             = p_variable_name,
         VARIABLE_CODE             = p_variable_code,
         VARIABLE_TYPE             = p_variable_type,
         VARIABLE_VALUE_ID         = p_variable_value_id,
         VARIABLE_VALUE            = p_variable_value,
         ATTRIBUTE_VALUE_SET_ID    = p_attribute_value_set_id,
         OBJECT_VERSION_NUMBER     = p_object_version_number,
         LAST_UPDATED_BY           = p_last_updated_by,
         LAST_UPDATE_LOGIN         = p_last_update_login,
         LAST_UPDATE_DATE          = p_last_update_date
    WHERE REVIEW_UPLD_TERMS_ID  = p_REVIEW_UPLD_TERMS_id;

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
  -- Update_Row for:OKC_REVIEW_VAR_VALUES --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id  IN NUMBER,

    p_REVIEW_VAR_VALUES_id IN NUMBER := NULL,
    p_variable_name             IN VARCHAR2 := NULL,
    p_variable_code             IN VARCHAR2 := NULL,
    p_variable_type             IN VARCHAR2 := NULL,
    p_variable_value_id         IN NUMBER := NULL,
    p_variable_value            IN VARCHAR2 := NULL,
    p_attribute_value_set_id    IN NUMBER := NULL,

    p_object_version_number     IN NUMBER

   ) IS

    l_REVIEW_VAR_VALUES_id OKC_REVIEW_VAR_VALUES.REVIEW_VAR_VALUES_ID%TYPE;
    l_variable_name             OKC_REVIEW_VAR_VALUES.VARIABLE_NAME%TYPE;
    l_variable_code             OKC_REVIEW_VAR_VALUES.VARIABLE_CODE%TYPE;
    l_variable_type             OKC_REVIEW_VAR_VALUES.VARIABLE_TYPE%TYPE;
    l_variable_value_id         OKC_REVIEW_VAR_VALUES.VARIABLE_VALUE_ID%TYPE;
    l_variable_value            OKC_REVIEW_VAR_VALUES.VARIABLE_VALUE%TYPE;
    l_attribute_value_set_id    OKC_REVIEW_VAR_VALUES.ATTRIBUTE_VALUE_SET_ID%TYPE;
    l_object_version_number     OKC_REVIEW_VAR_VALUES.OBJECT_VERSION_NUMBER%TYPE;
    l_last_updated_by           OKC_REVIEW_VAR_VALUES.LAST_UPDATED_BY%TYPE;
    l_last_update_login         OKC_REVIEW_VAR_VALUES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date          OKC_REVIEW_VAR_VALUES.LAST_UPDATE_DATE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_object_version_number     => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Setting attributes', 2);
    END IF;

    l_object_version_number     := p_object_version_number;
    x_return_status := Set_Attributes(
      p_REVIEW_VAR_VALUES_id => p_REVIEW_VAR_VALUES_id,
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_variable_name             => p_variable_name,
      p_variable_code             => p_variable_code,
      p_variable_type             => p_variable_type,
      p_variable_value_id         => p_variable_value_id,
      p_variable_value            => p_variable_value,
      p_attribute_value_set_id    => p_attribute_value_set_id,
      p_object_version_number     => l_object_version_number,
      x_REVIEW_VAR_VALUES_id => l_REVIEW_VAR_VALUES_id,
      x_variable_name             => l_variable_name,
      x_variable_code             => l_variable_code,
      x_variable_type             => l_variable_type,
      x_variable_value_id         => l_variable_value_id,
      x_variable_value            => l_variable_value,
      x_attribute_value_set_id    => l_attribute_value_set_id
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
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_REVIEW_VAR_VALUES_id => l_REVIEW_VAR_VALUES_id,
      p_variable_name             => l_variable_name,
      p_variable_code             => l_variable_code,
      p_variable_type             => l_variable_type,
      p_variable_value_id         => l_variable_value_id,
      p_variable_value            => l_variable_value,
      p_attribute_value_set_id    => l_attribute_value_set_id
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
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_REVIEW_VAR_VALUES_id => l_REVIEW_VAR_VALUES_id,
      p_variable_name             => l_variable_name,
      p_variable_code             => l_variable_code,
      p_variable_type             => l_variable_type,
      p_variable_value_id         => l_variable_value_id,
      p_variable_value            => l_variable_value,
      p_attribute_value_set_id    => l_attribute_value_set_id,
      p_object_version_number     => l_object_version_number,
      p_last_updated_by           => l_last_updated_by,
      p_last_update_login         => l_last_update_login,
      p_last_update_date          => l_last_update_date
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
  -- Delete_Row for:OKC_REVIEW_VAR_VALUES --
  -------------------------------------
  FUNCTION Delete_Row(
    p_REVIEW_UPLD_TERMS_id  IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;

    DELETE FROM OKC_REVIEW_VAR_VALUES
      WHERE REVIEW_UPLD_TERMS_ID = p_REVIEW_UPLD_TERMS_ID;
      COMMIT;

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
  -- Delete_Row for:OKC_REVIEW_VAR_VALUES --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_REVIEW_UPLD_TERMS_id  IN NUMBER,
    p_object_version_number     IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_REVIEW_UPLD_TERMS_id  => p_REVIEW_UPLD_TERMS_id,
      p_object_version_number     => p_object_version_number
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





END OKC_REVIEW_VAR_VALUES_PVT;


/

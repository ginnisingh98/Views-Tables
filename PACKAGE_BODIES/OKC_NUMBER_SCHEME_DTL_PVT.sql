--------------------------------------------------------
--  DDL for Package Body OKC_NUMBER_SCHEME_DTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_NUMBER_SCHEME_DTL_PVT" AS
/* $Header: OKCVNSDB.pls 120.1 2005/11/03 01:46:21 ndoddi noship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_NSD_PVT';
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

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;

  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_NUMBER_SCHEME_DTLS
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,

    x_concatenation_yn      OUT NOCOPY VARCHAR2,
    x_end_character         OUT NOCOPY VARCHAR2,
    x_object_version_number OUT NOCOPY NUMBER,
    x_created_by            OUT NOCOPY NUMBER,
    x_creation_date         OUT NOCOPY DATE,
    x_last_updated_by       OUT NOCOPY NUMBER,
    x_last_update_login     OUT NOCOPY NUMBER,
    x_last_update_date      OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_NUMBER_SCHEME_DTLS_pk_csr (cp_num_scheme_id IN NUMBER,cp_num_sequence_code IN VARCHAR2,cp_sequence_level IN NUMBER) IS
    SELECT
            CONCATENATION_YN,
            END_CHARACTER,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
      FROM OKC_NUMBER_SCHEME_DTLS t
     WHERE t.NUM_SCHEME_ID = cp_num_scheme_id and
           t.NUM_SEQUENCE_CODE = cp_num_sequence_code and
           t.SEQUENCE_LEVEL = cp_sequence_level;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '400: Entered get_rec' );
    END IF;

    -- Get current database values
    OPEN OKC_NUMBER_SCHEME_DTLS_pk_csr (p_num_scheme_id, p_num_sequence_code, p_sequence_level);
    FETCH OKC_NUMBER_SCHEME_DTLS_pk_csr INTO
            x_concatenation_yn,
            x_end_character,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date;
    IF OKC_NUMBER_SCHEME_DTLS_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_NUMBER_SCHEME_DTLS_pk_csr;

   /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('500: Leaving  get_rec ', 2);
   END IF;*/

   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '500: Leaving get_rec ' );
   END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('600: Leaving get_rec because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '600: Leaving get_rec because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF OKC_NUMBER_SCHEME_DTLS_pk_csr%ISOPEN THEN
        CLOSE OKC_NUMBER_SCHEME_DTLS_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_NUMBER_SCHEME_DTLS --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,
    p_object_version_number IN NUMBER,

    x_concatenation_yn      OUT NOCOPY VARCHAR2,
    x_object_version_number        OUT NOCOPY VARCHAR2,
    x_end_character         OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number OKC_NUMBER_SCHEME_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by            OKC_NUMBER_SCHEME_DTLS.CREATED_BY%TYPE;
    l_creation_date         OKC_NUMBER_SCHEME_DTLS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_NUMBER_SCHEME_DTLS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_DATE%TYPE;
  BEGIN
    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '700: Entered Set_Attributes ' );
    END IF;

    IF( p_num_scheme_id IS NOT NULL AND p_num_sequence_code IS NOT NULL AND p_sequence_level IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_num_scheme_id         => p_num_scheme_id,
        p_num_sequence_code     => p_num_sequence_code,
        p_sequence_level        => p_sequence_level,
        x_concatenation_yn      => x_concatenation_yn,
        x_end_character         => x_end_character,
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

      IF (p_concatenation_yn = G_MISS_CHAR) THEN
        x_concatenation_yn := 'N';
       ELSIF (p_concatenation_yn IS NOT NULL) THEN
        x_concatenation_yn := Upper( Nvl( p_concatenation_yn, 'N' ) );
      END IF;

      IF (p_end_character = G_MISS_CHAR) THEN
        x_end_character := NULL;
       ELSIF (p_end_character IS NOT NULL) THEN
        x_end_character := p_end_character;
      END IF;

    END IF;

    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('800: Leaving  Set_Attributes ', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '800: Leaving  Set_Attributes ' );
    END IF;

    RETURN G_RET_STS_SUCCESS ;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
    	      G_PKG_NAME, '900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception' );
      END IF;
      RETURN G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
    	      G_PKG_NAME, '1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
    	      G_PKG_NAME, '1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm );
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
  -- Validate_Attributes for: OKC_NUMBER_SCHEME_DTLS --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

    CURSOR l_num_scheme_id_csr is
     SELECT '!'
      FROM OKC_NUMBER_SCHEMES_B
      WHERE NUM_SCHEME_ID = p_num_scheme_id;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '1200: Entered Validate_Attributes' );
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1300: required values validation' );
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute NUM_SCHEME_ID ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute NUM_SCHEME_ID ' );
      END IF;

      IF ( p_num_scheme_id IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute NUM_SCHEME_ID is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1500: - attribute NUM_SCHEME_ID is invalid' );
        END IF;

        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'NUM_SCHEME_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute NUM_SEQUENCE_CODE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute NUM_SEQUENCE_CODE ' );
      END IF;

      IF ( p_num_sequence_code IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute NUM_SEQUENCE_CODE is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1500: - attribute NUM_SEQUENCE_CODE is invalid' );
        END IF;

        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'NUM_SEQUENCE_CODE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute SEQUENCE_LEVEL ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute SEQUENCE_LEVEL ' );
      END IF;

      IF ( p_sequence_level IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute SEQUENCE_LEVEL is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1500: - attribute SEQUENCE_LEVEL is invalid' );
        END IF;

        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'SEQUENCE_LEVEL');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute CONCATENATION_YN ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute CONCATENATION_YN ' );
      END IF;

      IF ( p_concatenation_yn IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute CONCATENATION_YN is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1500: - attribute CONCATENATION_YN is invalid' );
        END IF;

        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CONCATENATION_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1600: static values and range validation', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1600: static values and range validation' );
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute CONCATENATION_YN ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1700: - attribute CONCATENATION_YN ' );
      END IF;

      IF ( p_concatenation_yn NOT IN ('Y','N') AND p_concatenation_yn IS NOT NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute CONCATENATION_YN is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1800: - attribute CONCATENATION_YN is invalid' );
        END IF;

        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CONCATENATION_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1900: lookup codes validation', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1900: lookup codes validation' );
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute NUM_SEQUENCE_CODE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2000: - attribute NUM_SEQUENCE_CODE ' );
      END IF;

      IF p_num_sequence_code IS NOT NULL THEN
        l_return_status := Okc_Util.Check_Lookup_Code('OKC_NUMBER_SEQUENCE',p_num_sequence_code);
        IF (l_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'NUM_SEQUENCE_CODE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2100: foreigh keys validation ' );
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2100: foreigh keys validation ' );
      END IF;

      IF p_num_scheme_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_num_scheme_id_csr;
        FETCH l_num_scheme_id_csr INTO l_dummy_var;
        CLOSE l_num_scheme_id_csr;
        IF (l_dummy_var = '?') THEN
          /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute NUM_SCHEME_ID is invalid', 2);
          END IF;*/

          IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
              FND_LOG.STRING(G_PROC_LEVEL,
                  G_PKG_NAME, '2300: - attribute NUM_SCHEME_ID is invalid' );
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'NUM_SCHEME_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;


    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2400: Leaving Validate_Attributes ', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '2400: Leaving Validate_Attributes ' );
    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      --Okc_Debug.Log('2500: Leaving Validate_Attributes because of EXCEPTION: '||sqlerrm, 2);

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
    	      G_PKG_NAME, '2500: Leaving Validate_Attributes because of EXCEPTION: '||sqlerrm );
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF l_num_scheme_id_csr%ISOPEN THEN
        CLOSE l_num_scheme_id_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_NUMBER_SCHEME_DTLS --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '2600: Entered Validate_Record' );
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character
    );
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('2700: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2700: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm );
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;
    END IF;

    --- Record Level Validation
    IF p_validation_level > G_RECORD_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2800: Entered Record Level Validations', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_PROC_LEVEL,
 	      G_PKG_NAME, '2800: Entered Record Level Validations' );
      END IF;
/*+++++++++++++start of hand code +++++++++++++++++++*/
-- ?? manual coding for Record Level Validations if required ??
/*+++++++++++++End of hand code +++++++++++++++++++*/
    END IF;

    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('2900: Leaving Validate_Record : '||sqlerrm, 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
    	FND_LOG.STRING(G_PROC_LEVEL,
     	    G_PKG_NAME, '2900: Leaving Validate_Record : '||sqlerrm );
    END IF;
    RETURN l_return_status ;

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('3000: Leaving Validate_Record because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '3000: Leaving Validate_Record because of EXCEPTION: '||sqlerrm );
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
  -- validate_row for:OKC_NUMBER_SCHEME_DTLS --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    p_object_version_number IN NUMBER
  ) IS
      l_concatenation_yn      OKC_NUMBER_SCHEME_DTLS.CONCATENATION_YN%TYPE;
      l_end_character         OKC_NUMBER_SCHEME_DTLS.END_CHARACTER%TYPE;
      l_object_version_number OKC_NUMBER_SCHEME_DTLS.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by            OKC_NUMBER_SCHEME_DTLS.CREATED_BY%TYPE;
      l_creation_date         OKC_NUMBER_SCHEME_DTLS.CREATION_DATE%TYPE;
      l_last_updated_by       OKC_NUMBER_SCHEME_DTLS.LAST_UPDATED_BY%TYPE;
      l_last_update_login     OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date      OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '3100: Entered validate_row' );
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character,
      p_object_version_number => p_object_version_number,
      x_concatenation_yn      => l_concatenation_yn,
      x_object_version_number => l_object_version_number,
      x_end_character         => l_end_character
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => l_concatenation_yn,
      p_end_character         => l_end_character
    );

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3200: Leaving validate_row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '3200: Leaving validate_row' );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3300: Leaving Validate_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '3300: Leaving Validate_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3400: Leaving Validate_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '3400: Leaving Validate_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('3500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '3500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm );
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
  -- Insert_Row for:OKC_NUMBER_SCHEME_DTLS --
  -------------------------------------
  FUNCTION Insert_Row(
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,
    p_object_version_number IN NUMBER,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE,
    p_last_updated_by       IN NUMBER,
    p_last_update_login     IN NUMBER,
    p_last_update_date      IN DATE

  ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '3600: Entered Insert_Row function' );
    END IF;

    INSERT INTO OKC_NUMBER_SCHEME_DTLS(
        NUM_SCHEME_ID,
        NUM_SEQUENCE_CODE,
        SEQUENCE_LEVEL,
        CONCATENATION_YN,
        END_CHARACTER,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        p_num_scheme_id,
        p_num_sequence_code,
        p_sequence_level,
        p_concatenation_yn,
        p_end_character,
        p_object_version_number,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date);

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3700: Leaving Insert_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '3700: Leaving Insert_Row' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('3800: Leaving Insert_Row:OTHERS Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '3800: Leaving Insert_Row:OTHERS Exception' );
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
  -- Insert_Row for:OKC_NUMBER_SCHEME_DTLS --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    x_num_scheme_id         OUT NOCOPY NUMBER,
    x_num_sequence_code     OUT NOCOPY VARCHAR2,
    x_sequence_level        OUT NOCOPY NUMBER

  ) IS

    l_object_version_number OKC_NUMBER_SCHEME_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by            OKC_NUMBER_SCHEME_DTLS.CREATED_BY%TYPE;
    l_creation_date         OKC_NUMBER_SCHEME_DTLS.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_NUMBER_SCHEME_DTLS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '4200: Entered Insert_Row' );
    END IF;

    --- Setting item attributes
    -- Set primary key value
    x_num_scheme_id := p_num_scheme_id;
    x_num_sequence_code := p_num_sequence_code;
    x_sequence_level := p_sequence_level;
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
      p_num_scheme_id         => x_num_scheme_id,
      p_num_sequence_code     => x_num_sequence_code,
      p_sequence_level        => x_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character
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
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4300: Call the internal Insert_Row for Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '4300: Call the internal Insert_Row for Base Table' );
    END IF;

    x_return_status := Insert_Row(
      p_num_scheme_id         => x_num_scheme_id,
      p_num_sequence_code     => x_num_sequence_code,
      p_sequence_level        => x_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character,
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



    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4500: Leaving Insert_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '4500: Leaving Insert_Row' );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4600: Leaving Insert_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '4600: Leaving Insert_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4700: Leaving Insert_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '4700: Leaving Insert_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('4800: Leaving Insert_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '4800: Leaving Insert_Row because of EXCEPTION: '||sqlerrm );
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
  -- Lock_Row for:OKC_NUMBER_SCHEME_DTLS --
  -----------------------------------
  FUNCTION Lock_Row(
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_object_version_number IN NUMBER
  ) RETURN VARCHAR2 IS

    CURSOR lock_csr (cp_num_scheme_id NUMBER, cp_num_sequence_code VARCHAR2, cp_sequence_level NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_NUMBER_SCHEME_DTLS
     WHERE NUM_SCHEME_ID = cp_num_scheme_id AND NUM_SEQUENCE_CODE = cp_num_sequence_code AND SEQUENCE_LEVEL = cp_sequence_level
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_num_scheme_id NUMBER, cp_num_sequence_code VARCHAR2, cp_sequence_level NUMBER) IS
    SELECT object_version_number
      FROM OKC_NUMBER_SCHEME_DTLS
     WHERE NUM_SCHEME_ID = cp_num_scheme_id AND NUM_SEQUENCE_CODE = cp_num_sequence_code AND SEQUENCE_LEVEL = cp_sequence_level;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_NUMBER_SCHEME_DTLS.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '4900: Entered Lock_Row' );
    END IF;

    BEGIN

      OPEN lock_csr( p_num_scheme_id, p_num_sequence_code, p_sequence_level, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN

        /*IF (l_debug = 'Y') THEN
           Okc_Debug.Log('5000: Leaving Lock_Row:E_Resource_Busy Exception', 2);
        END IF;*/

	IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	    FND_LOG.STRING(G_PROC_LEVEL,
	        G_PKG_NAME, '5000: Leaving Lock_Row:E_Resource_Busy Exception' );
	END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
        RETURN( G_RET_STS_ERROR );
    END;

    IF ( l_row_notfound ) THEN
      l_return_status := G_RET_STS_ERROR;

      OPEN lchk_csr(p_num_scheme_id, p_num_sequence_code, p_sequence_level);
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

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5100: Leaving Lock_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '5100: Leaving Lock_Row' );
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

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
      	      G_PKG_NAME, '5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm );
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
  -- Lock_Row for:OKC_NUMBER_SCHEME_DTLS --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_object_version_number IN NUMBER
   ) IS
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('5700: Entered Lock_Row', 2);
       Okc_Debug.Log('5800: Locking Row for Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
	FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '5700: Entered Lock_Row');
	FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '5800: Locking Row for Base Table');
    END IF;

    --------------------------------------------
    -- Call the LOCK_ROW for each _B child record
    --------------------------------------------
    x_return_status := Lock_Row(
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_object_version_number => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;



    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('6000: Leaving Lock_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '6000: Leaving Lock_Row' );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6100: Leaving Lock_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '6100: Leaving Lock_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6200: Leaving Lock_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '6200: Leaving Lock_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6300: Leaving Lock_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '6300: Leaving Lock_Row because of EXCEPTION: '||sqlerrm );
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
  -- Update_Row for:OKC_NUMBER_SCHEME_DTLS --
  -------------------------------------
  FUNCTION Update_Row(
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,
    p_object_version_number IN NUMBER,
    p_last_updated_by       IN NUMBER,
    p_last_update_login     IN NUMBER,
    p_last_update_date      IN DATE
   ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '6400: Entered Update_Row' );
    END IF;

    UPDATE OKC_NUMBER_SCHEME_DTLS
     SET CONCATENATION_YN      = p_concatenation_yn,
         END_CHARACTER         = p_end_character,
         OBJECT_VERSION_NUMBER = p_object_version_number,
         LAST_UPDATED_BY       = p_last_updated_by,
         LAST_UPDATE_LOGIN     = p_last_update_login,
         LAST_UPDATE_DATE      = p_last_update_date
    WHERE NUM_SCHEME_ID         = p_num_scheme_id AND NUM_SEQUENCE_CODE     = p_num_sequence_code AND SEQUENCE_LEVEL        = p_sequence_level;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6500: Leaving Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '6500: Leaving Update_Row' );
    END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('6600: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '6600: Leaving Update_Row because of EXCEPTION: '||sqlerrm );
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
  -- Update_Row for:OKC_NUMBER_SCHEME_DTLS --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2 := NULL,
    p_end_character         IN VARCHAR2 := NULL,

    p_object_version_number IN NUMBER

   ) IS

    l_concatenation_yn      OKC_NUMBER_SCHEME_DTLS.CONCATENATION_YN%TYPE;
    l_end_character         OKC_NUMBER_SCHEME_DTLS.END_CHARACTER%TYPE;
    l_object_version_number OKC_NUMBER_SCHEME_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    l_last_updated_by       OKC_NUMBER_SCHEME_DTLS.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_NUMBER_SCHEME_DTLS.LAST_UPDATE_DATE%TYPE;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7000: Entered Update_Row');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7100: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_object_version_number => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Setting attributes', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7300: Setting attributes');
    END IF;

    x_return_status := Set_Attributes(
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => p_concatenation_yn,
      p_end_character         => p_end_character,
      p_object_version_number => p_object_version_number,
      x_concatenation_yn      => l_concatenation_yn,
      x_object_version_number => l_object_version_number,
      x_end_character         => l_end_character
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Record Validation', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7400: Record Validation');
    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => l_concatenation_yn,
      p_end_character         => l_end_character
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7500: Filling WHO columns', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7500: Filling WHO columns');
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
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7600: Updating Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7600: Updating Row');
    END IF;

    x_return_status := Update_Row(
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_concatenation_yn      => l_concatenation_yn,
      p_end_character         => l_end_character,
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


    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('7800: Leaving Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7800: Leaving Update_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('7900: Leaving Update_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '7900: Leaving Update_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('8000: Leaving Update_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '8000: Leaving Update_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('8100: Leaving Update_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '8100: Leaving Update_Row because of EXCEPTION: '||sqlerrm );
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
  -- Delete_Row for:OKC_NUMBER_SCHEME_DTLS --
  -------------------------------------
  FUNCTION Delete_Row(
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '8200: Entered Delete_Row' );
    END IF;

    DELETE FROM OKC_NUMBER_SCHEME_DTLS
      WHERE NUM_SCHEME_ID = p_NUM_SCHEME_ID AND NUM_SEQUENCE_CODE = p_NUM_SEQUENCE_CODE AND SEQUENCE_LEVEL = p_SEQUENCE_LEVEL;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8300: Leaving Delete_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '8300: Leaving Delete_Row' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('8400: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
              G_PKG_NAME, '8400: Leaving Delete_Row because of EXCEPTION: '||sqlerrm );
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
  -- Delete_Row for:OKC_NUMBER_SCHEME_DTLS --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_object_version_number IN NUMBER
  ) IS
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '8800: Entered Delete_Row');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '8900: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_num_scheme_id         => p_num_scheme_id,
      p_num_sequence_code     => p_num_sequence_code,
      p_sequence_level        => p_sequence_level,
      p_object_version_number => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9100: Removing _B row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9100: Removing _B row' );
    END IF;
    x_return_status := Delete_Row( p_num_scheme_id => p_num_scheme_id,p_num_sequence_code => p_num_sequence_code,p_sequence_level => p_sequence_level );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9300: Leaving Delete_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9300: Leaving Delete_Row' );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9400: Leaving Delete_Row:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '9400: Leaving Delete_Row:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9500: Leaving Delete_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '9500: Leaving Delete_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('9600: Leaving Delete_Row because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
	  FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '9600: Leaving Delete_Row because of EXCEPTION: '||sqlerrm );
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
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER
  ) IS
    CURSOR lock_csr IS
    SELECT rowid
      FROM OKC_NUMBER_SCHEME_DTLS
     WHERE NUM_SCHEME_ID = p_num_scheme_id
    FOR UPDATE NOWAIT;

   BEGIN
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered Delete_Set', 2);
       Okc_Debug.Log('9800: Locking the Set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9700: Entered Delete_Set');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9800: Locking the Set');
    END IF;

    -- making OPEN/CLOSE cursor to lock records
    OPEN lock_csr;
    CLOSE lock_csr;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9900: Deleting the Set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9900: Deleting the Set' );
    END IF;

    DELETE FROM OKC_NUMBER_SCHEME_DTLS
      WHERE NUM_SCHEME_ID = p_NUM_SCHEME_ID ;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10000: Leaving Delete_set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '10000: Leaving Delete_set' );
    END IF;
  EXCEPTION
    WHEN E_Resource_Busy THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11000: Leaving Delete_set:E_Resource_Busy Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '11000: Leaving Delete_set:E_Resource_Busy Exception' );
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11100: Leaving Delete_Set:FND_API.G_EXC_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '11100: Leaving Delete_Set:FND_API.G_EXC_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
     	      G_PKG_NAME, '11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Set;

END OKC_NUMBER_SCHEME_DTL_PVT;

/

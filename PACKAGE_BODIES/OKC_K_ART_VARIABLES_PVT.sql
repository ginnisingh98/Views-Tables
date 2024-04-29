--------------------------------------------------------
--  DDL for Package Body OKC_K_ART_VARIABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ART_VARIABLES_PVT" AS
/* $Header: OKCVVARB.pls 120.1.12010000.8 2013/07/24 14:20:34 skavutha ship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_K_ART_VARIABLES_PVT';
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

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

  PROCEDURE delete_mrv_uda_data(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2,p_major_version IN NUMBER);

  FUNCTION  isArtVariableMRV(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE create_mrv_uda_data_version(p_cat_id IN NUMBER, p_major_version IN NUMBER);

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ART_VARIABLES
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    x_variable_type          OUT NOCOPY VARCHAR2,
    x_external_yn            OUT NOCOPY VARCHAR2,
    x_variable_value_id      OUT NOCOPY VARCHAR2,
    x_variable_value         OUT NOCOPY VARCHAR2,
    x_attribute_value_set_id OUT NOCOPY NUMBER,
    x_override_global_yn     OUT NOCOPY VARCHAR2,
    x_object_version_number  OUT NOCOPY NUMBER,
    x_created_by             OUT NOCOPY NUMBER,
    x_creation_date          OUT NOCOPY DATE,
    x_last_updated_by        OUT NOCOPY NUMBER,
    x_last_update_login      OUT NOCOPY NUMBER,
    x_last_update_date       OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_K_ART_VARIABLES_pk_csr (cp_cat_id IN NUMBER,cp_variable_code IN VARCHAR2) IS
    SELECT
            VARIABLE_TYPE,
            EXTERNAL_YN,
            VARIABLE_VALUE_ID,
            VARIABLE_VALUE,
            ATTRIBUTE_VALUE_SET_ID,
            OVERRiDE_GLOBAL_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
      FROM OKC_K_ART_VARIABLES t
     WHERE t.CAT_ID = cp_cat_id and
           t.VARIABLE_CODE = cp_variable_code;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '400: Entered get_rec' );
    END IF;

    -- Get current database values
    OPEN OKC_K_ART_VARIABLES_pk_csr (p_cat_id, p_variable_code);
    FETCH OKC_K_ART_VARIABLES_pk_csr INTO
            x_variable_type,
            x_external_yn,
            x_variable_value_id,
            x_variable_value,
            x_attribute_value_set_id,
            x_override_global_yn,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date;
    IF OKC_K_ART_VARIABLES_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_K_ART_VARIABLES_pk_csr;

   /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('500: Leaving  get_rec ', 2);
   END IF;*/

   IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       FND_LOG.STRING(G_PROC_LEVEL,
           G_PKG_NAME, '500: Leaving  get_rec ' );
   END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('600: Leaving get_rec because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '600: Leaving get_rec because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF OKC_K_ART_VARIABLES_pk_csr%ISOPEN THEN
        CLOSE OKC_K_ART_VARIABLES_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_K_ART_VARIABLES --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER,
    p_override_global_yn     IN VARCHAR2,
    p_object_version_number  IN NUMBER,

    x_variable_type          OUT NOCOPY VARCHAR2,
    x_object_version_number  OUT NOCOPY VARCHAR2,
    x_external_yn            OUT NOCOPY VARCHAR2,
    x_variable_value_id      OUT NOCOPY VARCHAR2,
    x_variable_value         OUT NOCOPY VARCHAR2,
    x_attribute_value_set_id OUT NOCOPY NUMBER,
    x_override_global_yn     OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number  OKC_K_ART_VARIABLES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_K_ART_VARIABLES.CREATED_BY%TYPE;
    l_creation_date          OKC_K_ART_VARIABLES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_K_ART_VARIABLES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_K_ART_VARIABLES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_K_ART_VARIABLES.LAST_UPDATE_DATE%TYPE;
  BEGIN
    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '700: Entered Set_Attributes ' );
    END IF;

    IF( p_cat_id IS NOT NULL AND p_variable_code IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_cat_id                 => p_cat_id,
        p_variable_code          => p_variable_code,
        x_variable_type          => x_variable_type,
        x_external_yn            => x_external_yn,
        x_variable_value_id      => x_variable_value_id,
        x_variable_value         => x_variable_value,
        x_attribute_value_set_id => x_attribute_value_set_id,
        x_override_global_yn     => x_override_global_yn,
        x_object_version_number  => x_object_version_number,
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

      IF (p_variable_type = G_MISS_CHAR) THEN
        x_variable_type := NULL;
       ELSIF (p_VARIABLE_TYPE IS NOT NULL) THEN
        x_variable_type := p_variable_type;
      END IF;

      IF (p_external_yn = G_MISS_CHAR) THEN
        x_external_yn := NULL;
       ELSIF (p_EXTERNAL_YN IS NOT NULL) THEN
        x_external_yn := p_external_yn;
        x_external_yn := Upper( x_external_yn );
      END IF;

      IF (p_variable_value_id = G_MISS_CHAR) THEN
        x_variable_value_id := NULL;
       ELSIF (p_VARIABLE_VALUE_ID IS NOT NULL) THEN
        x_variable_value_id := p_variable_value_id;
      END IF;

      IF (p_variable_value = G_MISS_CHAR) THEN
        x_variable_value := NULL;
       ELSIF (p_VARIABLE_VALUE IS NOT NULL) THEN
        x_variable_value := p_variable_value;
      END IF;

      IF (p_attribute_value_set_id = G_MISS_NUM) THEN
        x_attribute_value_set_id := NULL;
       ELSIF (p_ATTRIBUTE_VALUE_SET_ID IS NOT NULL) THEN
        x_attribute_value_set_id := p_attribute_value_set_id;
      END IF;


      IF (p_override_global_yn = G_MISS_CHAR) THEN
        x_override_global_yn := NULL;
       ELSIF (p_override_global_yn IS NOT NULL) THEN
        x_override_global_yn := p_override_global_yn;
        x_override_global_yn := upper(x_override_global_yn);
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

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception' );
      END IF;
      RETURN G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
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
  -- Validate_Attributes for: OKC_K_ART_VARIABLES --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER,
    p_override_global_yn     IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

    CURSOR l_cat_id_csr is
     SELECT '!'
      FROM OKC_K_ARTICLES_B
      WHERE ID = p_cat_id;

    CURSOR l_attribute_value_set_id_csr is
     SELECT '!'
      FROM fnd_flex_value_sets
      WHERE FLEX_VALUE_SET_ID = p_attribute_value_set_id;

    CURSOR l_variable_code_csr is
     SELECT '!'
      FROM OKC_BUS_VARIABLES_B
      WHERE VARIABLE_CODE = p_VARIABLE_CODE;
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
        Okc_Debug.Log('1400: - attribute CAT_ID ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute CAT_ID ' );
      END IF;
      IF ( p_cat_id IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute CAT_ID is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1500: - attribute CAT_ID is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CAT_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute VARIABLE_CODE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute VARIABLE_CODE ' );
      END IF;
      IF ( p_variable_code IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute VARIABLE_CODE is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1500: - attribute VARIABLE_CODE is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'VARIABLE_CODE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute VARIABLE_TYPE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute VARIABLE_TYPE ' );
      END IF;
      IF ( p_variable_type IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute VARIABLE_TYPE is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
             FND_LOG.STRING(G_PROC_LEVEL,
                 G_PKG_NAME, '1500: - attribute VARIABLE_TYPE is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'VARIABLE_TYPE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      /*IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute EXTERNAL_YN ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1400: - attribute EXTERNAL_YN ' );
      END IF;
      IF ( p_external_yn IS NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute EXTERNAL_YN is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1500: - attribute EXTERNAL_YN is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'EXTERNAL_YN');
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
         Okc_Debug.Log('1700: - attribute EXTERNAL_YN ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1700: - attribute EXTERNAL_YN ' );
      END IF;

      IF ( p_external_yn NOT IN ('Y','N') AND p_external_yn IS NOT NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute EXTERNAL_YN is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1800: - attribute EXTERNAL_YN is invalid' );
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'EXTERNAL_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;


      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1700: - attribute OVERRIDE_GLOBAL_YN ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '1700: - attribute OVERRIDE_GLOBAL_YN ' );
      END IF;

      IF ( p_OVERRIDE_GLOBAL_YN NOT IN ('Y','N') AND p_OVERRIDE_GLOBAL_YN IS NOT NULL) THEN
        /*IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1800: - attribute OVERRIDE_GLOBAL_YN is invalid', 2);
        END IF;*/

        IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_PROC_LEVEL,
                G_PKG_NAME, '1800: - attribute OVERRIDE_GLOBAL_YN is invalid' );
        END IF;

        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'OVERRIDE_GLOBAL_YN');
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
    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreign keys validation ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2100: foreign keys validation ' );
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute CAT_ID ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2200: - attribute CAT_ID ' );
      END IF;

      IF p_cat_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_cat_id_csr;
        FETCH l_cat_id_csr INTO l_dummy_var;
        CLOSE l_cat_id_csr;
        IF (l_dummy_var = '?') THEN
          /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute CAT_ID is invalid', 2);
          END IF;*/

	  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
 	      FND_LOG.STRING(G_PROC_LEVEL,
  	          G_PKG_NAME, '2300: - attribute CAT_ID is invalid' );
	  END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CAT_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
/*
--      IF (l_debug = 'Y') THEN
--         Okc_Debug.Log('2200: - attribute VARIABLE_VALUE_ID ', 2);
--      END IF;
--      IF p_variable_value_id IS NOT NULL THEN
--        l_dummy_var := '?';
--        OPEN l_variable_value_id_csr;
--        FETCH l_variable_value_id_csr INTO l_dummy_var;
--        CLOSE l_variable_value_id_csr;
--        IF (l_dummy_var = '?') THEN
--          IF (l_debug = 'Y') THEN
--            Okc_Debug.Log('2300: - attribute VARIABLE_VALUE_ID is invalid', 2);
--          END IF;
--          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'VARIABLE_VALUE_ID');
--          l_return_status := G_RET_STS_ERROR;
--        END IF;
--      END IF;
*/
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ATTRIBUTE_VALUE_SET_ID ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2200: - attribute ATTRIBUTE_VALUE_SET_ID ' );
      END IF;
      IF p_attribute_value_set_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_attribute_value_set_id_csr;
        FETCH l_attribute_value_set_id_csr INTO l_dummy_var;
        CLOSE l_attribute_value_set_id_csr;
        IF (l_dummy_var = '?') THEN
          /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute ATTRIBUTE_VALUE_SET_ID is invalid', 2);
          END IF;*/

          IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       	      FND_LOG.STRING(G_PROC_LEVEL,
                  G_PKG_NAME, '2300: - attribute ATTRIBUTE_VALUE_SET_ID is invalid' );
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ATTRIBUTE_VALUE_SET_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute VARIABLE_CODE ', 2);
      END IF;*/

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
              G_PKG_NAME, '2200: - attribute VARIABLE_CODE ' );
      END IF;
      IF p_variable_code IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_variable_code_csr;
        FETCH l_variable_code_csr INTO l_dummy_var;
        CLOSE l_variable_code_csr;
        IF (l_dummy_var = '?') THEN
          /*IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute VARIABLE_CODE is invalid', 2);
          END IF;*/

          IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
       	      FND_LOG.STRING(G_PROC_LEVEL,
                  G_PKG_NAME, '2300: - attribute VARIABLE_CODE is invalid' );
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'VARIABLE_CODE');
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


      IF l_cat_id_csr%ISOPEN THEN
        CLOSE l_cat_id_csr;
      END IF;


      IF l_attribute_value_set_id_csr%ISOPEN THEN
        CLOSE l_attribute_value_set_id_csr;
      END IF;

      IF l_variable_code_csr%ISOPEN THEN
        CLOSE l_variable_code_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_K_ART_VARIABLES --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER,
    p_override_global_yn     IN VARCHAR2
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

      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => p_variable_type,
      p_external_yn            => p_external_yn,
      p_variable_value_id      => p_variable_value_id,
      p_variable_value         => p_variable_value,
      p_attribute_value_set_id => p_attribute_value_set_id,
      p_override_global_yn     => p_override_global_yn
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

      IF P_ATTRIBUTE_VALUE_SET_ID IS NOT NULL AND
         P_VARIABLE_VALUE_ID IS NOT NULL THEN
        /* Need to put check here */
           Null;
      END IF;


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
  -- validate_row for:OKC_K_ART_VARIABLES --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	     IN NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER ,
    p_override_global_yn     IN VARCHAR2,

    p_object_version_number  IN NUMBER
  ) IS
      l_variable_type          OKC_K_ART_VARIABLES.VARIABLE_TYPE%TYPE;
      l_external_yn            OKC_K_ART_VARIABLES.EXTERNAL_YN%TYPE;
      l_variable_value_id      OKC_K_ART_VARIABLES.VARIABLE_VALUE_ID%TYPE;
      l_variable_value         OKC_K_ART_VARIABLES.VARIABLE_VALUE%TYPE;
      l_attribute_value_set_id OKC_K_ART_VARIABLES.ATTRIBUTE_VALUE_SET_ID%TYPE;
      l_override_global_yn     OKC_K_ART_VARIABLES.OVERRIDE_GLOBAL_YN%TYPE;
      l_object_version_number  OKC_K_ART_VARIABLES.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by             OKC_K_ART_VARIABLES.CREATED_BY%TYPE;
      l_creation_date          OKC_K_ART_VARIABLES.CREATION_DATE%TYPE;
      l_last_updated_by        OKC_K_ART_VARIABLES.LAST_UPDATED_BY%TYPE;
      l_last_update_login      OKC_K_ART_VARIABLES.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date       OKC_K_ART_VARIABLES.LAST_UPDATE_DATE%TYPE;
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
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => p_variable_type,
      p_external_yn            => p_external_yn,
      p_variable_value_id      => p_variable_value_id,
      p_variable_value         => p_variable_value,
      p_attribute_value_set_id => p_attribute_value_set_id,
      p_override_global_yn     => p_override_global_yn,
      p_object_version_number  => p_object_version_number,
      x_variable_type          => l_variable_type,
      x_object_version_number  => l_object_version_number,
      x_external_yn            => l_external_yn,
      x_variable_value_id      => l_variable_value_id,
      x_variable_value         => l_variable_value,
      x_attribute_value_set_id => l_attribute_value_set_id,
      x_override_global_yn     => l_override_global_yn
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => l_variable_type,
      p_external_yn            => l_external_yn,
      p_variable_value_id      => l_variable_value_id,
      p_variable_value         => l_variable_value,
      p_attribute_value_set_id => l_attribute_value_set_id,
      p_override_global_yn     => l_override_global_yn
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
  -- Insert_Row for:OKC_K_ART_VARIABLES --
  -------------------------------------
  FUNCTION Insert_Row(
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER,
    p_override_global_yn     IN VARCHAR2,
    p_object_version_number  IN NUMBER,
    p_created_by             IN NUMBER,
    p_creation_date          IN DATE,
    p_last_updated_by        IN NUMBER,
    p_last_update_login      IN NUMBER,
    p_last_update_date       IN DATE,
    p_global_variable_value  IN VARCHAR2 := NULL,
    p_global_var_value_id    IN NUMBER := NULL

  ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3600: Entered Insert_Row function', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '3600: Entered Insert_Row function' );
    END IF;
    INSERT INTO OKC_K_ART_VARIABLES(
        CAT_ID,
        VARIABLE_CODE,
        VARIABLE_TYPE,
        EXTERNAL_YN,
        VARIABLE_VALUE_ID,
        VARIABLE_VALUE,
        ATTRIBUTE_VALUE_SET_ID,
        OVERRIDE_GLOBAL_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        GLOBAL_VARIABLE_VALUE,
        GLOBAL_VARIABLE_VALUE_ID)
      VALUES (
        p_cat_id,
        p_variable_code,
        p_variable_type,
        p_external_yn,
        p_variable_value_id,
        p_variable_value,
        p_attribute_value_set_id,
        p_override_global_yn,
        p_object_version_number,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date,
        p_global_variable_value,
        p_global_var_value_id);

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
  -- Insert_Row for:OKC_K_ART_VARIABLES --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	     IN NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER,
    p_override_global_yn     IN VARCHAR2,
    p_global_variable_value  IN VARCHAR2 := NULL,
    p_global_var_value_id    IN NUMBER := NULL,
    x_cat_id                 OUT NOCOPY NUMBER,
    x_variable_code          OUT NOCOPY VARCHAR2

  ) IS

    l_object_version_number  OKC_K_ART_VARIABLES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_K_ART_VARIABLES.CREATED_BY%TYPE;
    l_creation_date          OKC_K_ART_VARIABLES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_K_ART_VARIABLES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_K_ART_VARIABLES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_K_ART_VARIABLES.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '4200: Entered Insert_Row' );
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
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => p_variable_type,
      p_external_yn            => p_external_yn,
      p_variable_value_id      => p_variable_value_id,
      p_variable_value         => p_variable_value,
      p_attribute_value_set_id => p_attribute_value_set_id,
      p_override_global_yn     => p_override_global_yn
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
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => p_variable_type,
      p_external_yn            => p_external_yn,
      p_variable_value_id      => p_variable_value_id,
      p_variable_value         => p_variable_value,
      p_attribute_value_set_id => p_attribute_value_set_id,
      p_override_global_yn     => p_override_global_yn,
      p_object_version_number  => l_object_version_number,
      p_created_by             => l_created_by,
      p_creation_date          => l_creation_date,
      p_last_updated_by        => l_last_updated_by,
      p_last_update_login      => l_last_update_login,
      p_last_update_date       => l_last_update_date,
      p_global_variable_value  => p_global_variable_value,
      p_global_var_value_id    => p_global_var_value_id
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
  -- Lock_Row for:OKC_K_ART_VARIABLES --
  -----------------------------------
  FUNCTION Lock_Row(
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_object_version_number  IN NUMBER
  ) RETURN VARCHAR2 IS


    CURSOR lock_csr (cp_cat_id NUMBER, cp_variable_code VARCHAR2, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_K_ART_VARIABLES
     WHERE CAT_ID = cp_cat_id AND VARIABLE_CODE = cp_variable_code
    AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_cat_id NUMBER, cp_variable_code VARCHAR2) IS
    SELECT object_version_number
      FROM OKC_K_ART_VARIABLES
     WHERE CAT_ID = cp_cat_id AND VARIABLE_CODE = cp_variable_code;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_K_ART_VARIABLES.OBJECT_VERSION_NUMBER%TYPE;

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

      OPEN lock_csr( p_cat_id, p_variable_code, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN

        /*IF (l_debug = 'Y') THEN
           Okc_Debug.Log('5000: Leaving Lock_Row:E_Resource_Busy Exception', 2);
        END IF;*/

        IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
            FND_LOG.STRING(G_EXCP_LEVEL,
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

      OPEN lchk_csr(p_cat_id, p_variable_code);
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
  -- Lock_Row for:OKC_K_ART_VARIABLES --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_object_version_number  IN NUMBER
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
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_object_version_number  => p_object_version_number
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
  -- Update_Row for:OKC_K_ART_VARIABLES --
  -------------------------------------
  FUNCTION Update_Row(
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER,
    p_override_global_yn     IN VARCHAR2,
    p_object_version_number  IN NUMBER,
    p_created_by             IN NUMBER,
    p_creation_date          IN DATE,
    p_last_updated_by        IN NUMBER,
    p_last_update_login      IN NUMBER,
    p_last_update_date       IN DATE
   ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '6400: Entered Update_Row' );
    END IF;

    UPDATE OKC_K_ART_VARIABLES
     SET VARIABLE_TYPE          = p_variable_type,
         EXTERNAL_YN            = p_external_yn,
         VARIABLE_VALUE_ID      = p_variable_value_id,
         VARIABLE_VALUE         = p_variable_value,
         ATTRIBUTE_VALUE_SET_ID = p_attribute_value_set_id,
         OVERRIDE_GLOBAL_YN     = p_override_global_yn,
         OBJECT_VERSION_NUMBER  = p_object_version_number,
         LAST_UPDATED_BY        = p_last_updated_by,
         LAST_UPDATE_LOGIN      = p_last_update_login,
         LAST_UPDATE_DATE       = p_last_update_date
    WHERE CAT_ID                 = p_cat_id
    AND VARIABLE_CODE          = p_variable_code;

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
  -- Update_Row for:OKC_K_ART_VARIABLES --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	     IN NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,

    p_attribute_value_set_id IN NUMBER := NULL,
    p_override_global_yn     IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER

   ) IS

    l_variable_type          OKC_K_ART_VARIABLES.VARIABLE_TYPE%TYPE;
    l_external_yn            OKC_K_ART_VARIABLES.EXTERNAL_YN%TYPE;
    l_variable_value_id      OKC_K_ART_VARIABLES.VARIABLE_VALUE_ID%TYPE;
    l_variable_value         OKC_K_ART_VARIABLES.VARIABLE_VALUE%TYPE;
    l_attribute_value_set_id OKC_K_ART_VARIABLES.ATTRIBUTE_VALUE_SET_ID%TYPE;
    l_override_global_yn     OKC_K_ART_VARIABLES.OVERRIDE_GLOBAL_YN%TYPE;
    l_object_version_number  OKC_K_ART_VARIABLES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_K_ART_VARIABLES.CREATED_BY%TYPE;
    l_creation_date          OKC_K_ART_VARIABLES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_K_ART_VARIABLES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_K_ART_VARIABLES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_K_ART_VARIABLES.LAST_UPDATE_DATE%TYPE;

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
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_object_version_number  => p_object_version_number
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
            G_PKG_NAME, '7300: Setting attributes' );
    END IF;

    x_return_status := Set_Attributes(
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => p_variable_type,
      p_external_yn            => p_external_yn,
      p_variable_value_id      => p_variable_value_id,
      p_variable_value         => p_variable_value,
      p_attribute_value_set_id => p_attribute_value_set_id,
      p_override_global_yn     => p_override_global_yn,
      p_object_version_number  => p_object_version_number,
      x_variable_type          => l_variable_type,
      x_object_version_number  => l_object_version_number,
      x_external_yn            => l_external_yn,
      x_variable_value_id      => l_variable_value_id,
      x_variable_value         => l_variable_value,
      x_attribute_value_set_id => l_attribute_value_set_id,
      x_override_global_yn     => l_override_global_yn
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
            G_PKG_NAME, '7400: Record Validation' );
    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => l_variable_type,
      p_external_yn            => l_external_yn,
      p_variable_value_id      => l_variable_value_id,
      p_variable_value         => l_variable_value,
      p_attribute_value_set_id => l_attribute_value_set_id,
      p_override_global_yn   => l_override_global_yn
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
            G_PKG_NAME, '7500: Filling WHO columns' );
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
            G_PKG_NAME, '7600: Updating Row' );
    END IF;

    x_return_status := Update_Row(
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_variable_type          => l_variable_type,
      p_external_yn            => l_external_yn,
      p_variable_value_id      => l_variable_value_id,
      p_variable_value         => l_variable_value,
      p_attribute_value_set_id => l_attribute_value_set_id,
      p_override_global_yn   => l_override_global_yn,
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


    /*IF (l_debug = 'Y') THEN
      Okc_Debug.Log('7800: Leaving Update_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7800: Leaving Update_Row' );
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
  -- Delete_Row for:OKC_K_ART_VARIABLES --
  -------------------------------------
  FUNCTION Delete_Row(
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2
  ) RETURN VARCHAR2 IS

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '8200: Entered Delete_Row' );
    END IF;

    IF isArtVariableMRV(p_cat_id =>p_CAT_ID, p_VARIABLE_CODE => p_VARIABLE_CODE)  = 'Y' THEN
     delete_mrv_uda_data(p_cat_id =>p_CAT_ID, p_VARIABLE_CODE => p_VARIABLE_CODE, p_major_version => NULL);
    END IF;

    DELETE FROM OKC_K_ART_VARIABLES WHERE CAT_ID = p_CAT_ID AND VARIABLE_CODE = p_VARIABLE_CODE;

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
  -- Delete_Row for:OKC_K_ART_VARIABLES --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_object_version_number  IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
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
      p_cat_id                 => p_cat_id,
      p_variable_code          => p_variable_code,
      p_object_version_number  => p_object_version_number
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
    x_return_status := Delete_Row( p_cat_id => p_cat_id,p_variable_code => p_variable_code );
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
    x_return_status          OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER
  )
IS
    CURSOR lock_csr IS
    SELECT rowid
    FROM OKC_K_ART_VARIABLES
     WHERE cat_id = p_cat_id
    FOR UPDATE NOWAIT;

   BEGIN
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered Delete_Set', 2);
       Okc_Debug.Log('9701: Locking Records', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9700: Entered Delete_Set');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9701: Locking Records');
    END IF;

 -- making OPEN/CLOSE cursor to lock records
    OPEN lock_csr;
    CLOSE lock_csr;

    IF isArtVariableMRV(p_cat_id =>p_CAT_ID, p_VARIABLE_CODE => null)  = 'Y' THEN
     delete_mrv_uda_data(p_cat_id =>p_CAT_ID, p_VARIABLE_CODE => null, p_major_version => NULL);
    END IF;

    DELETE FROM OKC_K_ART_VARIABLES
      WHERE cat_id = p_cat_id;


    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('11000: Leaving Delete_set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '11000: Leaving Delete_set' );
    END IF;

  EXCEPTION
    WHEN E_Resource_Busy THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('000: Leaving Delete_set:E_Resource_Busy Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '000: Leaving Delete_set:E_Resource_Busy Exception' );
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

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
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

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
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

  END Delete_Set;

  PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_scn_id                 IN NUMBER
  )
IS
    CURSOR lock_csr IS
    SELECT rowid
    FROM OKC_K_ART_VARIABLES
    WHERE CAT_ID IN (SELECT ID FROM OKC_K_ARTICLES_B
                     WHERE SCN_ID=p_scn_id)
    FOR UPDATE NOWAIT;

    CURSOR cat_mrv_csr
    IS
    SELECT kart.ID
      FROM OKC_K_ARTICLES_B KART
         , OKC_BUS_VARIABLES_B BUS_VAR
         , OKC_K_ART_VARIABLES KVAR
    WHERE kart.SCN_ID=p_scn_id
     AND  KVAR.cat_id=kart.id
    AND   KVAR.variable_code=BUS_VAR.variable_code
    AND   BUS_VAR.MRV_FLAG='Y';

   BEGIN
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered Delete_Set', 2);
       Okc_Debug.Log('9700: Locking Records', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9700: Entered Delete_Set');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9700: Locking Records');
    END IF;

 -- making OPEN/CLOSE cursor to lock records
    OPEN lock_csr;
    CLOSE lock_csr;

     FOR cat_rec IN cat_mrv_csr
     LOOP
         delete_mrv_uda_data(p_cat_id => cat_rec.ID, p_VARIABLE_CODE => null, p_major_version => NULL);
     END LOOP;


    DELETE FROM OKC_K_ART_VARIABLES
      WHERE CAT_ID IN (SELECT ID FROM OKC_K_ARTICLES_B
                       WHERE SCN_ID=p_scn_id);

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('11000: Leaving Delete_set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '11000: Leaving Delete_set' );
    END IF;

  EXCEPTION
     WHEN E_Resource_Busy THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('000: Leaving Delete_set:E_Resource_Busy Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '000: Leaving Delete_set:E_Resource_Busy Exception' );
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

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
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

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
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

  END Delete_Set;


  PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_doc_type               IN VARCHAR2,
    p_doc_id                 IN NUMBER
    ,p_retain_lock_terms_yn   IN VARCHAR2 := 'N'
  )
IS

CURSOR lock_csr IS
SELECT rowid
FROM OKC_K_ART_VARIABLES
WHERE cat_id IN (SELECT id FROM OKC_K_ARTICLES_B WHERE
                        document_type= p_doc_type AND
                        document_id = p_doc_id
                        AND
                          (( p_retain_lock_terms_yn = 'N')
                            OR
                           (p_retain_lock_terms_yn ='Y' AND amendment_operation_code IS NULL)
                          )
                 )
    FOR UPDATE NOWAIT;

    CURSOR doc_mrv_csr
    IS
     SELECT kart.ID
      FROM OKC_K_ARTICLES_B KART
         , OKC_BUS_VARIABLES_B BUS_VAR
         , OKC_K_ART_VARIABLES KVAR
    WHERE kart.document_type=p_doc_type
    AND   kart.document_id = p_doc_id
     AND  KVAR.cat_id=kart.id
    AND   KVAR.variable_code=BUS_VAR.variable_code
    AND   BUS_VAR.MRV_FLAG='Y'
    AND
                          (( p_retain_lock_terms_yn = 'N')
                            OR
                           (p_retain_lock_terms_yn ='Y' AND KART.amendment_operation_code IS NULL)
                          );


   BEGIN
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered Delete_Set', 2);
       Okc_Debug.Log('9710: Locking Records', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9700: Entered Delete_Set');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9710: Locking Records');
    END IF;

-- making OPEN/CLOSE cursor to lock records
    OPEN lock_csr;
    CLOSE lock_csr;

    FOR cat_rec IN doc_mrv_csr
    LOOP
       delete_mrv_uda_data(p_cat_id => cat_rec.ID, p_VARIABLE_CODE => null, p_major_version => NULL);
    END LOOP;


    DELETE FROM OKC_K_ART_VARIABLES
      WHERE cat_id IN (SELECT id FROM OKC_K_ARTICLES_B WHERE
                               document_type=p_doc_type AND
                               document_id = p_doc_id);




    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('11000: Leaving Delete_set', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '11000: Leaving Delete_set' );
    END IF;

  EXCEPTION
     WHEN E_Resource_Busy THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('000: Leaving Delete_set:E_Resource_Busy Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '000: Leaving Delete_set:E_Resource_Busy Exception' );
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

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception', 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '11200: Leaving Delete_Set:FND_API.G_EXC_UNEXPECTED_ERROR Exception' );
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      /*IF (l_debug = 'Y') THEN
         Okc_Debug.Log('11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '11300: Leaving Delete_Set because of EXCEPTION: '||sqlerrm );
      END IF;

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Set;

--This function is to be called from versioning API OKC_VERSION_PVT
-- Location: Base Table API
  FUNCTION Create_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS

  CURSOR doc_mrv_csr
   IS
     SELECT kart.ID
      FROM OKC_K_ARTICLES_B KART
         , OKC_BUS_VARIABLES_B BUS_VAR
         , OKC_K_ART_VARIABLES KVAR
    WHERE kart.document_type=p_doc_type
    AND   kart.document_id = p_doc_id
    AND  KVAR.cat_id=kart.id
    AND   KVAR.variable_code=BUS_VAR.variable_code
    AND   BUS_VAR.MRV_FLAG='Y';

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('9700: Entered create_version', 2);
       Okc_Debug.Log('9800: Saving Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9700: Entered create_version');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '9800: Saving Base Table');
    END IF;

    -----------------------------------------
    -- Saving Base Table
    -----------------------------------------
    INSERT INTO OKC_K_ART_VARIABLES_H (
        major_version,
        CAT_ID,
        VARIABLE_CODE,
        VARIABLE_TYPE,
        EXTERNAL_YN,
        VARIABLE_VALUE_ID,
        VARIABLE_VALUE,
        ATTRIBUTE_VALUE_SET_ID,
        override_global_yn,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        mr_variable_html,
        mr_variable_xml)
     SELECT
        p_major_version,
        CAT_ID,
        VARIABLE_CODE,
        VARIABLE_TYPE,
        EXTERNAL_YN,
        VARIABLE_VALUE_ID,
        VARIABLE_VALUE,
        ATTRIBUTE_VALUE_SET_ID,
        OVERRIDE_GLOBAL_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        mr_variable_html,
        mr_variable_xml
      FROM OKC_K_ART_VARIABLES
      WHERE cat_id in (SELECT ID FROM OKC_K_ARTICLES_B
                       WHERE DOCUMENT_TYPE = P_DOC_TYPE
                       AND DOCUMENT_ID = P_DOC_ID);
    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10000: Leaving create_version', 2);
    END IF;*/

    FOR cat_rec IN doc_mrv_csr LOOP
        create_mrv_uda_data_version(p_cat_id=>cat_rec.id, p_major_version => p_major_version);
    END LOOP;


    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '10000: Leaving create_version' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10100: Leaving create_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '10100: Leaving create_version because of EXCEPTION: '||sqlerrm );
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
--?? remove the function if the aPI doesn't need it

  FUNCTION Restore_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2
   IS

   CURSOR doc_ver_mrv_csr
   IS
     SELECT kart.ID
      FROM OKC_K_ARTICLES_BH KART
         , OKC_BUS_VARIABLES_B BUS_VAR
         , OKC_K_ART_VARIABLES_H KVAR
    WHERE kart.document_type=p_doc_type
    AND   kart.document_id = p_doc_id
    AND  KVAR.cat_id=kart.id
    AND   KVAR.variable_code=BUS_VAR.variable_code
    AND   BUS_VAR.MRV_FLAG='Y'
    AND   KART.major_version=p_major_version
    AND   KVAR.major_version=p_major_version;

  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10200: Entered restore_version', 2);
       Okc_Debug.Log('10300: Restoring Base Table', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '10200: Entered restore_version');
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '10300: Restoring Base Table');
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    INSERT INTO OKC_K_ART_VARIABLES (
        CAT_ID,
        VARIABLE_CODE,
        VARIABLE_TYPE,
        EXTERNAL_YN,
        VARIABLE_VALUE_ID,
        VARIABLE_VALUE,
        ATTRIBUTE_VALUE_SET_ID,
        OVERRIDE_GLOBAL_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        mr_variable_html,
        mr_variable_xml)
     SELECT
        CAT_ID,
        VARIABLE_CODE,
        VARIABLE_TYPE,
        EXTERNAL_YN,
        VARIABLE_VALUE_ID,
        VARIABLE_VALUE,
        ATTRIBUTE_VALUE_SET_ID,
        override_global_YN,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        mr_variable_html,
        mr_variable_xml
      FROM OKC_K_ART_VARIABLES_H
      WHERE cat_id in (SELECT ID FROM OKC_K_ARTICLES_BH
                       WHERE DOCUMENT_TYPE = P_DOC_TYPE
                       AND DOCUMENT_ID = P_DOC_ID)
      AND major_version = p_major_version;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10500: Leaving restore_version', 2);
    END IF;*/
    FOR cat_rec IN doc_ver_mrv_csr LOOP
         restore_mrv_uda_data_version(p_cat_id => cat_rec.id,p_major_version => p_major_version);
    END LOOP;

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '10500: Leaving restore_version' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('10600: Leaving restore_version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '10600: Leaving restore_version because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END restore_version;

  FUNCTION Delete_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2
  IS
   CURSOR doc_ver_mrv_csr
   IS
     SELECT kart.ID
      FROM OKC_K_ARTICLES_BH KART
         , OKC_BUS_VARIABLES_B BUS_VAR
         , OKC_K_ART_VARIABLES_H KVAR
    WHERE kart.document_type=p_doc_type
    AND   kart.document_id = p_doc_id
    AND  KVAR.cat_id=kart.id
    AND   KVAR.variable_code=BUS_VAR.variable_code
    AND   BUS_VAR.MRV_FLAG='Y'
    AND   KART.major_version=p_major_version
    AND   KVAR.major_version=p_major_version;
  BEGIN

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7200: Entered Delete_Version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7200: Entered Delete_Version' );
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    FOR  cat_rec IN doc_ver_mrv_csr LOOP
    delete_mrv_uda_data(p_cat_id => cat_rec.id,p_variable_code => NULL, p_major_version =>p_major_version);
    END LOOP;

    DELETE
      FROM OKC_K_ART_VARIABLES_H
      WHERE cat_id in (SELECT ID FROM OKC_K_ARTICLES_BH
                       WHERE document_type = p_doc_type and document_id = p_doc_id)
      AND major_version = p_major_version;

    /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7300: Leaving Delete_Version', 2);
    END IF;*/

    IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
        FND_LOG.STRING(G_PROC_LEVEL,
            G_PKG_NAME, '7300: Leaving Delete_Version' );
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      /*IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7400: Leaving Delete_Version because of EXCEPTION: '||sqlerrm, 2);
      END IF;*/

      IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, '7400: Leaving Delete_Version because of EXCEPTION: '||sqlerrm );
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Delete_Version;

  FUNCTION  isArtVariableMRV(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2)
  RETURN VARCHAR2
  IS
  l_mrv_flag VARCHAR2(1):= 'N';
  BEGIN

    IF p_cat_id IS NOT NULL THEN
       SELECT  'Y'
          INTO  l_mrv_flag
         FROM okc_k_art_variables kav
       WHERE cat_id = p_cat_id
       AND EXISTS (SELECT 1
                    FROM okc_bus_variables_b var
                   WHERE kav.variable_code=var.variable_code
                     AND var.mrv_flag='Y');
    ELSE
      SELECT Nvl(mrv_flag,'N')
         INTO l_mrv_flag
      FROM okc_bus_variables_b
      WHERE variable_code=p_variable_code;
    END IF;
      RETURN  l_mrv_flag;
  EXCEPTION
   WHEN OTHERS THEN
     RETURN 'N';
  END isArtVariableMRV;

PROCEDURE delete_mrv_uda_data(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2,p_major_version IN NUMBER)
  IS
  l_data_level NUMBER;
  l_major_version NUMBER;
  BEGIN

    l_major_version :=  p_major_version;
    IF p_major_version IS NULL THEN
      l_major_version := -99;
    END IF;

    IF l_major_version = -99 THEN
      SELECT  DATA_LEVEL_ID
              INTO l_data_level
              FROM    EGO_DATA_LEVEL_B
              WHERE   DATA_LEVEL_NAME = 'CLAUSE_VARIABLES';
    ELSE
      SELECT  DATA_LEVEL_ID
              INTO l_data_level
              FROM    EGO_DATA_LEVEL_B
              WHERE   DATA_LEVEL_NAME = 'CLAUSE_VARIABLES_HISTORY';
    END IF;

        IF   p_cat_id IS NOT NULL THEN
              IF  p_variable_code IS NOT NULL
              THEN
                  DELETE FROM OKC_K_ART_VAR_EXT_B
                  WHERE cat_id  =  p_cat_id
                  AND   variable_code =  p_variable_code
                  AND  data_level_id = l_data_level
                  AND   major_version =l_major_version;

                  DELETE FROM  OKC_K_ART_VAR_EXT_TL
                  WHERE cat_id  =  p_cat_id
                  AND   variable_code =  p_variable_code
                  AND  data_level_id = l_data_level
                  AND   major_version =l_major_version;

              ELSE
                  DELETE FROM OKC_K_ART_VAR_EXT_B
                  WHERE cat_id  =  p_cat_id
                  AND  data_level_id = l_data_level
                  AND   major_version =l_major_version;

                  DELETE FROM OKC_K_ART_VAR_EXT_TL
                  WHERE cat_id  =  p_cat_id
                  AND  data_level_id = l_data_level
                  AND   major_version =l_major_version;

              END IF;
         ELSE
          -- This should be an error condn;
          -- Cat id is a must
          NULL;
         END IF;
  EXCEPTION
   WHEN OTHERS THEN
    IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_EXCP_LEVEL,
	      G_PKG_NAME, ' Leaving delete_mrv_uda_data because of EXCEPTION: '||sqlerrm );
    END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
  END delete_mrv_uda_data;

PROCEDURE create_mrv_uda_data_version(p_cat_id IN NUMBER, p_major_version IN NUMBER)
  IS
  l_data_level NUMBER;
  l_data_level_h NUMBER;
  l_new_ext_id NUMBER;
  l_old_ext_id NUMBER;

  CURSOR cur_extension_ids IS
   SELECT EXTENSION_ID
   FROM  OKC_K_ART_VAR_EXT_B
    WHERE cat_id=p_cat_id
    AND data_level_id = l_data_level
    AND Nvl(major_version,-99) = -99 ;
  BEGIN

    SELECT  DATA_LEVEL_ID
              INTO l_data_level
              FROM    EGO_DATA_LEVEL_B
              WHERE   DATA_LEVEL_NAME = 'CLAUSE_VARIABLES';

    SELECT  DATA_LEVEL_ID
              INTO l_data_level_h
              FROM    EGO_DATA_LEVEL_B
              WHERE   DATA_LEVEL_NAME = 'CLAUSE_VARIABLES_HISTORY';


    FOR cur_rec IN cur_extension_ids LOOP
        l_old_ext_id := cur_rec.EXTENSION_ID;
        l_new_ext_id := EGO_EXTFWK_S.NEXTVAL;

            INSERT INTO okc_k_art_var_ext_b
            (
              EXTENSION_ID
              ,ATTR_GROUP_ID
              ,CAT_ID
              ,VARIABLE_CODE
              ,DATA_LEVEL_ID
              ,PK1_VALUE
              ,PK2_VALUE
              ,PK3_VALUE
              ,PK4_VALUE
              ,PK5_VALUE
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_LOGIN
              ,CREATED_BY
              ,CREATION_DATE
              ,C_EXT_ATTR1
              ,C_EXT_ATTR2
              ,C_EXT_ATTR3
              ,C_EXT_ATTR4
              ,C_EXT_ATTR5
              ,C_EXT_ATTR6
              ,C_EXT_ATTR7
              ,C_EXT_ATTR8
              ,C_EXT_ATTR9
              ,C_EXT_ATTR10
              ,C_EXT_ATTR11
              ,C_EXT_ATTR12
              ,C_EXT_ATTR13
              ,C_EXT_ATTR14
              ,C_EXT_ATTR15
              ,C_EXT_ATTR16
              ,C_EXT_ATTR17
              ,C_EXT_ATTR18
              ,C_EXT_ATTR19
              ,C_EXT_ATTR20
              ,C_EXT_ATTR21
              ,C_EXT_ATTR22
              ,C_EXT_ATTR23
              ,C_EXT_ATTR24
              ,C_EXT_ATTR25
              ,C_EXT_ATTR26
              ,C_EXT_ATTR27
              ,C_EXT_ATTR28
              ,C_EXT_ATTR29
              ,C_EXT_ATTR30
              ,C_EXT_ATTR31
              ,C_EXT_ATTR32
              ,C_EXT_ATTR33
              ,C_EXT_ATTR34
              ,C_EXT_ATTR35
              ,C_EXT_ATTR36
              ,C_EXT_ATTR37
              ,C_EXT_ATTR38
              ,C_EXT_ATTR39
              ,C_EXT_ATTR40
              ,N_EXT_ATTR1
              ,N_EXT_ATTR2
              ,N_EXT_ATTR3
              ,N_EXT_ATTR4
              ,N_EXT_ATTR5
              ,N_EXT_ATTR6
              ,N_EXT_ATTR7
              ,N_EXT_ATTR8
              ,N_EXT_ATTR9
              ,N_EXT_ATTR10
              ,N_EXT_ATTR11
              ,N_EXT_ATTR12
              ,N_EXT_ATTR13
              ,N_EXT_ATTR14
              ,N_EXT_ATTR15
              ,N_EXT_ATTR16
              ,N_EXT_ATTR17
              ,N_EXT_ATTR18
              ,N_EXT_ATTR19
              ,N_EXT_ATTR20
              ,UOM_EXT_ATTR1
              ,UOM_EXT_ATTR2
              ,UOM_EXT_ATTR3
              ,UOM_EXT_ATTR4
              ,UOM_EXT_ATTR5
              ,UOM_EXT_ATTR6
              ,UOM_EXT_ATTR7
              ,UOM_EXT_ATTR8
              ,UOM_EXT_ATTR9
              ,UOM_EXT_ATTR10
              ,UOM_EXT_ATTR11
              ,UOM_EXT_ATTR12
              ,UOM_EXT_ATTR13
              ,UOM_EXT_ATTR14
              ,UOM_EXT_ATTR15
              ,UOM_EXT_ATTR16
              ,UOM_EXT_ATTR17
              ,UOM_EXT_ATTR18
              ,UOM_EXT_ATTR19
              ,UOM_EXT_ATTR20
              ,D_EXT_ATTR1
              ,D_EXT_ATTR2
              ,D_EXT_ATTR3
              ,D_EXT_ATTR4
              ,D_EXT_ATTR5
              ,D_EXT_ATTR6
              ,D_EXT_ATTR7
              ,D_EXT_ATTR8
              ,D_EXT_ATTR9
              ,D_EXT_ATTR10
              ,CLASS_CODE
              ,MAJOR_VERSION
            )
            SELECT
                l_new_ext_id --extension_id
              , ATTR_GROUP_ID
              , CAT_ID
              , VARIABLE_CODE
              , l_data_level_h
              , PK1_VALUE
              , PK2_VALUE
              , PK3_VALUE
              , PK4_VALUE
              , PK5_VALUE
              , LAST_UPDATE_DATE
              , LAST_UPDATED_BY
              , LAST_UPDATE_LOGIN
              , CREATED_BY
              , CREATION_DATE
              , C_EXT_ATTR1
              , C_EXT_ATTR2
              , C_EXT_ATTR3
              , C_EXT_ATTR4
              , C_EXT_ATTR5
              , C_EXT_ATTR6
              , C_EXT_ATTR7
              , C_EXT_ATTR8
              , C_EXT_ATTR9
              , C_EXT_ATTR10
              , C_EXT_ATTR11
              , C_EXT_ATTR12
              , C_EXT_ATTR13
              , C_EXT_ATTR14
              , C_EXT_ATTR15
              , C_EXT_ATTR16
              , C_EXT_ATTR17
              , C_EXT_ATTR18
              , C_EXT_ATTR19
              , C_EXT_ATTR20
              , C_EXT_ATTR21
              , C_EXT_ATTR22
              , C_EXT_ATTR23
              , C_EXT_ATTR24
              , C_EXT_ATTR25
              , C_EXT_ATTR26
              , C_EXT_ATTR27
              , C_EXT_ATTR28
              , C_EXT_ATTR29
              , C_EXT_ATTR30
              , C_EXT_ATTR31
              , C_EXT_ATTR32
              , C_EXT_ATTR33
              , C_EXT_ATTR34
              , C_EXT_ATTR35
              , C_EXT_ATTR36
              , C_EXT_ATTR37
              , C_EXT_ATTR38
              , C_EXT_ATTR39
              , C_EXT_ATTR40
              , N_EXT_ATTR1
              , N_EXT_ATTR2
              , N_EXT_ATTR3
              , N_EXT_ATTR4
              , N_EXT_ATTR5
              , N_EXT_ATTR6
              , N_EXT_ATTR7
              , N_EXT_ATTR8
              , N_EXT_ATTR9
              , N_EXT_ATTR10
              , N_EXT_ATTR11
              , N_EXT_ATTR12
              , N_EXT_ATTR13
              , N_EXT_ATTR14
              , N_EXT_ATTR15
              , N_EXT_ATTR16
              , N_EXT_ATTR17
              , N_EXT_ATTR18
              , N_EXT_ATTR19
              , N_EXT_ATTR20
              , UOM_EXT_ATTR1
              , UOM_EXT_ATTR2
              , UOM_EXT_ATTR3
              , UOM_EXT_ATTR4
              , UOM_EXT_ATTR5
              , UOM_EXT_ATTR6
              , UOM_EXT_ATTR7
              , UOM_EXT_ATTR8
              , UOM_EXT_ATTR9
              , UOM_EXT_ATTR10
              , UOM_EXT_ATTR11
              , UOM_EXT_ATTR12
              , UOM_EXT_ATTR13
              , UOM_EXT_ATTR14
              , UOM_EXT_ATTR15
              , UOM_EXT_ATTR16
              , UOM_EXT_ATTR17
              , UOM_EXT_ATTR18
              , UOM_EXT_ATTR19
              , UOM_EXT_ATTR20
              , D_EXT_ATTR1
              , D_EXT_ATTR2
              , D_EXT_ATTR3
              , D_EXT_ATTR4
              , D_EXT_ATTR5
              , D_EXT_ATTR6
              , D_EXT_ATTR7
              , D_EXT_ATTR8
              , D_EXT_ATTR9
              , D_EXT_ATTR10
              , CLASS_CODE
              , p_major_version
              FROM  OKC_K_ART_VAR_EXT_B
            WHERE EXTENSION_ID = l_old_ext_id ;

            INSERT INTO OKC_K_ART_VAR_EXT_TL
            (EXTENSION_ID
        , ATTR_GROUP_ID
        , CAT_ID
        , VARIABLE_CODE
        , DATA_LEVEL_ID
        , SOURCE_LANG
        , LANGUAGE
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , LAST_UPDATE_LOGIN
        , CREATED_BY
        , CREATION_DATE
        , TL_EXT_ATTR1
        , TL_EXT_ATTR2
        , TL_EXT_ATTR3
        , TL_EXT_ATTR4
        , TL_EXT_ATTR5
        , TL_EXT_ATTR6
        , TL_EXT_ATTR7
        , TL_EXT_ATTR8
        , TL_EXT_ATTR9
        , TL_EXT_ATTR10
        , TL_EXT_ATTR11
        , TL_EXT_ATTR12
        , TL_EXT_ATTR13
        , TL_EXT_ATTR14
        , TL_EXT_ATTR15
        , TL_EXT_ATTR16
        , TL_EXT_ATTR17
        , TL_EXT_ATTR18
        , TL_EXT_ATTR19
        , TL_EXT_ATTR20
        , TL_EXT_ATTR21
        , TL_EXT_ATTR22
        , TL_EXT_ATTR23
        , TL_EXT_ATTR24
        , TL_EXT_ATTR25
        , TL_EXT_ATTR26
        , TL_EXT_ATTR27
        , TL_EXT_ATTR28
        , TL_EXT_ATTR29
        , TL_EXT_ATTR30
        , TL_EXT_ATTR31
        , TL_EXT_ATTR32
        , TL_EXT_ATTR33
        , TL_EXT_ATTR34
        , TL_EXT_ATTR35
        , TL_EXT_ATTR36
        , TL_EXT_ATTR37
        , TL_EXT_ATTR38
        , TL_EXT_ATTR39
        , TL_EXT_ATTR40
        , CLASS_CODE
        , MAJOR_VERSION
            )
            SELECT
          l_new_ext_id
        , ATTR_GROUP_ID
        , CAT_ID
        , VARIABLE_CODE
        , l_data_level_h
        , SOURCE_LANG
        , LANGUAGE
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , LAST_UPDATE_LOGIN
        , CREATED_BY
        , CREATION_DATE
        , TL_EXT_ATTR1
        , TL_EXT_ATTR2
        , TL_EXT_ATTR3
        , TL_EXT_ATTR4
        , TL_EXT_ATTR5
        , TL_EXT_ATTR6
        , TL_EXT_ATTR7
        , TL_EXT_ATTR8
        , TL_EXT_ATTR9
        , TL_EXT_ATTR10
        , TL_EXT_ATTR11
        , TL_EXT_ATTR12
        , TL_EXT_ATTR13
        , TL_EXT_ATTR14
        , TL_EXT_ATTR15
        , TL_EXT_ATTR16
        , TL_EXT_ATTR17
        , TL_EXT_ATTR18
        , TL_EXT_ATTR19
        , TL_EXT_ATTR20
        , TL_EXT_ATTR21
        , TL_EXT_ATTR22
        , TL_EXT_ATTR23
        , TL_EXT_ATTR24
        , TL_EXT_ATTR25
        , TL_EXT_ATTR26
        , TL_EXT_ATTR27
        , TL_EXT_ATTR28
        , TL_EXT_ATTR29
        , TL_EXT_ATTR30
        , TL_EXT_ATTR31
        , TL_EXT_ATTR32
        , TL_EXT_ATTR33
        , TL_EXT_ATTR34
        , TL_EXT_ATTR35
        , TL_EXT_ATTR36
        , TL_EXT_ATTR37
        , TL_EXT_ATTR38
        , TL_EXT_ATTR39
        , TL_EXT_ATTR40
        , CLASS_CODE
        , P_MAJOR_VERSION
            FROM OKC_K_ART_VAR_EXT_TL
            WHERE EXTENSION_ID = l_old_ext_id ;

    END LOOP;
END create_mrv_uda_data_version;

PROCEDURE restore_mrv_uda_data_version(p_cat_id IN NUMBER,p_major_version IN NUMBER)
IS
 l_data_level NUMBER;
  l_data_level_h NUMBER;
  l_count NUMBER;
  CURRENT_VERSION_EXISTS EXCEPTION;
BEGIN
    SELECT  DATA_LEVEL_ID
              INTO l_data_level
              FROM    EGO_DATA_LEVEL_B
              WHERE   DATA_LEVEL_NAME = 'CLAUSE_VARIABLES';

    SELECT  DATA_LEVEL_ID
              INTO l_data_level_h
              FROM    EGO_DATA_LEVEL_B
              WHERE   DATA_LEVEL_NAME = 'CLAUSE_VARIABLES_HISTORY';

    SELECT Count(1)
      INTO l_count
      FROM okc_k_art_var_ext_b
     WHERE CAT_ID = p_cat_id
       AND DATA_LEVEL_ID = l_data_level
       AND MAJOR_VERSION = -99;

    IF l_count > 0 THEN
      RAISE CURRENT_VERSION_EXISTS;
    END IF;

   UPDATE okc_k_art_var_ext_b
      SET DATA_LEVEL_ID = l_data_level,
          MAJOR_VERSION = -99
    WHERE CAT_ID = p_cat_id
      AND DATA_LEVEL_ID = l_data_level_h
      AND MAJOR_VERSION = p_major_version;

   UPDATE okc_k_art_var_ext_tl
      SET DATA_LEVEL_ID = l_data_level,
          MAJOR_VERSION = -99
    WHERE CAT_ID = p_cat_id
      AND DATA_LEVEL_ID = l_data_level_h
      AND MAJOR_VERSION = p_major_version;

END restore_mrv_uda_data_version;


END OKC_K_ART_VARIABLES_PVT;

/

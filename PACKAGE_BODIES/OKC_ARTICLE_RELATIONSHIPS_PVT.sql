--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLE_RELATIONSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLE_RELATIONSHIPS_PVT" AS
/* $Header: OKCVARLB.pls 120.0 2005/05/25 22:30:59 appldev noship $ */

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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ARTICLE_RELATIONSHIPS_PVT';
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
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
/*  FUNCTION Get_Seq_Id (
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    x_source_article_id     OUT NOCOPY NUMBER,
    x_target_article_id     OUT NOCOPY NUMBER,
    x_org_id                OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_seq_csr IS
     SELECT OKC_ARTICLES_ALL_S1.NEXTVAL FROM DUAL;
  BEGIN
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF( p_source_article_id     IS NULL AND p_target_article_id     IS NULL AND p_org_id                IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_source_article_id    , x_target_article_id    , x_org_id               ;
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
 */
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ARTICLE_RELATIONSHIPS
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,

    x_relationship_type     OUT NOCOPY VARCHAR2,
    x_object_version_number OUT NOCOPY NUMBER,
    x_created_by            OUT NOCOPY NUMBER,
    x_creation_date         OUT NOCOPY DATE,
    x_last_updated_by       OUT NOCOPY NUMBER,
    x_last_update_login     OUT NOCOPY NUMBER,
    x_last_update_date      OUT NOCOPY DATE

  ) RETURN VARCHAR2 IS
    CURSOR OKC_ART_REL_pk_csr (cp_source_article_id IN NUMBER,cp_target_article_id IN NUMBER,cp_org_id IN NUMBER) IS
    SELECT
            RELATIONSHIP_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE
      FROM OKC_ARTICLE_RELATNS_ALL t
     WHERE t.SOURCE_ARTICLE_ID = cp_source_article_id and
           t.TARGET_ARTICLE_ID = cp_target_article_id and
           t.ORG_ID = cp_org_id;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('400: Entered get_rec', 2);
    END IF;

    -- Get current database values
    OPEN OKC_ART_REL_pk_csr (p_source_article_id, p_target_article_id, p_org_id);
    FETCH OKC_ART_REL_pk_csr INTO
            x_relationship_type,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date;
    IF OKC_ART_REL_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_ART_REL_pk_csr;

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

      IF OKC_ART_REL_pk_csr%ISOPEN THEN
        CLOSE OKC_ART_REL_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_ARTICLE_RELATNS_ALL --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,
    p_object_version_number IN NUMBER,

    x_relationship_type     OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number OKC_ARTICLE_RELATNS_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by            OKC_ARTICLE_RELATNS_ALL.CREATED_BY%TYPE;
    l_creation_date         OKC_ARTICLE_RELATNS_ALL.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_ARTICLE_RELATNS_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF (l_debug = 'Y') THEN
      Okc_Debug.Log('700: Entered Set_Attributes ', 2);
    END IF;

    IF( p_source_article_id IS NOT NULL AND p_target_article_id IS NOT NULL AND p_org_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_source_article_id     => p_source_article_id,
        p_target_article_id     => p_target_article_id,
        p_org_id                => p_org_id,
        x_relationship_type     => x_relationship_type,
        x_object_version_number => l_object_version_number,
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

      IF (p_relationship_type = G_MISS_CHAR) THEN
        x_relationship_type := NULL;
       ELSIF (p_relationship_type IS NOT NULL) THEN
        x_relationship_type := p_relationship_type;
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
  -- Validate_Attributes for: OKC_ARTICLE_RELATNS_ALL --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_tmp_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

    CURSOR l_source_article_id_csr is
     SELECT '!'
      FROM OKC_ARTICLES_ALL
      WHERE ARTICLE_ID = p_source_article_id;

    CURSOR l_target_article_id_csr is
     SELECT '!'
      FROM OKC_ARTICLES_ALL
      WHERE ARTICLE_ID = p_target_article_id;

    CURSOR l_org_id_csr is
     SELECT '!'
      FROM HR_ALL_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = p_org_id;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1200: Entered Validate_Attributes', 2);
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1300: required values validation', 2);
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute SOURCE_ARTICLE_ID ', 2);
      END IF;
      IF ( p_source_article_id IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute SOURCE_ARTICLE_ID is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'SOURCE_ARTICLE_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
        Okc_Debug.Log('1400: - attribute TARGET_ARTICLE_ID ', 2);
      END IF;
      IF ( p_target_article_id IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute TARGET_ARTICLE_ID is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TARGET_ARTICLE_ID');
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
        Okc_Debug.Log('1400: - attribute RELATIONSHIP_TYPE ', 2);
      END IF;
      IF ( p_relationship_type IS NULL) THEN
        IF (l_debug = 'Y') THEN
          Okc_Debug.Log('1500: - attribute RELATIONSHIP_TYPE is invalid', 2);
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'RELATIONSHIP_TYPE');
        l_return_status := G_RET_STS_ERROR;
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

--Modified
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: - attribute RELATIONSHIP_TYPE ', 2);
      END IF;
      IF p_relationship_type IS NOT NULL THEN
        l_tmp_return_status := Okc_Util.Check_Lookup_Code('OKC_ARTICLE_RELATIONSHIP_TYPE',p_relationship_type);
        IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'RELATIONSHIP_TYPE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

-- Modified


    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2100: foreigh keys validation ', 2);
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute SOURCE_ARTICLE_ID ', 2);
      END IF;
      IF p_source_article_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_source_article_id_csr;
        FETCH l_source_article_id_csr INTO l_dummy_var;
        CLOSE l_source_article_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute SOURCE_ARTICLE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SOURCE_ARTICLE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute TARGET_ARTICLE_ID ', 2);
      END IF;
      IF p_target_article_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_target_article_id_csr;
        FETCH l_target_article_id_csr INTO l_dummy_var;
        CLOSE l_target_article_id_csr;
        IF (l_dummy_var = '?') THEN
          IF (l_debug = 'Y') THEN
            Okc_Debug.Log('2300: - attribute TARGET_ARTICLE_ID is invalid', 2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TARGET_ARTICLE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: - attribute ORG_ID ', 2);
      END IF;
      IF p_org_id IS NOT NULL THEN
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

      IF l_source_article_id_csr%ISOPEN THEN
        CLOSE l_source_article_id_csr;
      END IF;

      IF l_target_article_id_csr%ISOPEN THEN
        CLOSE l_target_article_id_csr;
      END IF;

      IF l_org_id_csr%ISOPEN THEN
        CLOSE l_org_id_csr;
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
    p_source_article_id in number,
    p_target_article_id in number
)
return varchar2
is
result varchar2(1);
source_provision varchar2(1);
target_provision varchar2(1);
cursor l_provision_csr(c_article_id in number)
IS
   select provision_yn
   from
      okc_article_versions
   where
      article_id = c_article_id
   and
      article_version_number = 1;
begin
   FOR source IN l_provision_csr(p_source_article_id)
   LOOP
      source_provision := source.provision_yn;
   END LOOP;

   FOR target IN l_provision_csr(p_target_article_id)
   LOOP
      target_provision := target.provision_yn;
   END LOOP;
   if source_provision = target_provision then
      result := 'S'; -- success
   else
      result := 'E'; -- failure
   end if;
   return result;
end;
-- fix for bug#4006749 end

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_ARTICLE_RELATNS_ALL --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_rowfound BOOLEAN := FALSE;
-- Modified
    l_dummy_var     VARCHAR2(1) := '?';
   CURSOR l_unq_csr(cp_source_article_id IN NUMBER,
                    cp_target_article_id IN NUMBER,
                    cp_org_id            IN NUMBER) IS
       SELECT '1' FROM OKC_ARTICLE_RELATNS_ALL
       WHERE  source_article_id = cp_source_article_id
       AND    target_article_id = cp_target_article_id
       AND    org_id            = cp_org_id
       AND    rownum            < 2;
-- Modified
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2600: Entered Validate_Record', 2);
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => p_relationship_type
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
      IF p_source_article_id = p_target_article_id THEN
          IF (l_debug='Y') THEN
              OKC_Debug.Log('2800: - attribute SOURCE_ARTICLE_ID , TARGET_ARTICLE_ID can not be same',2);
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_SAME_ART_RELTNSHP');
          l_return_status := G_RET_STS_ERROR;
-- fix for bug#4006749 start
-- muteshev
      elsif provision_flag_in_relations(p_source_article_id, p_target_article_id) = 'E' then
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_INV_PROVISION_RELATION');
          l_return_status := G_RET_STS_ERROR;
-- fix for bug#4006749 end
      END IF;

      l_rowfound := FALSE;
      --dbms_output.put_line('Source  Target: '||p_source_article_id||'*'||p_target_article_id);
      IF p_source_article_id is NOT NULL and
         p_target_article_id is NOT NULL and
         p_org_id is NOT NULL THEN
         OPEN l_unq_csr(p_source_article_id, p_target_article_id,  p_org_id);
         FETCH l_unq_csr INTO l_dummy_var;
         l_rowfound := l_unq_csr%FOUND;
         CLOSE l_unq_csr;
         IF l_rowfound THEN
            IF (l_debug='Y') THEN
              OKC_Debug.Log('2800: - attribute SOURCE_ARTICLE_ID , TARGET_ARTICLE_ID are not unique for Org',2);
            END IF;
            Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_DUP_RELTNSHP');
            l_return_status := G_RET_STS_ERROR;
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
      IF l_unq_csr%ISOPEN THEN
        CLOSE l_unq_csr;
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR ;

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKC_ARTICLE_RELATNS_ALL --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,



    p_object_version_number IN NUMBER
  ) IS
      l_relationship_type     OKC_ARTICLE_RELATNS_ALL.RELATIONSHIP_TYPE%TYPE;
      l_object_version_number OKC_ARTICLE_RELATNS_ALL.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by            OKC_ARTICLE_RELATNS_ALL.CREATED_BY%TYPE;
      l_creation_date         OKC_ARTICLE_RELATNS_ALL.CREATION_DATE%TYPE;
      l_last_updated_by       OKC_ARTICLE_RELATNS_ALL.LAST_UPDATED_BY%TYPE;
      l_last_update_login     OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date      OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('3100: Entered validate_row', 2);
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => p_relationship_type,
      p_object_version_number => p_object_version_number,
      x_relationship_type     => l_relationship_type
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => l_relationship_type
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
  -- Insert_Row for:OKC_ARTICLE_RELATNS_ALL --
  -------------------------------------
  FUNCTION Insert_Row(
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,
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
-- Create opposite rows (mutually related by flipping the source and target ids)
    INSERT INTO OKC_ARTICLE_RELATNS_ALL(
        SOURCE_ARTICLE_ID,
        TARGET_ARTICLE_ID,
        ORG_ID,
        RELATIONSHIP_TYPE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
      VALUES (
        p_source_article_id,
        p_target_article_id,
        p_org_id,
        p_relationship_type,
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
  -- Insert_Row for:OKC_ARTICLE_RELATNS_ALL --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level	      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,



    x_source_article_id     OUT NOCOPY NUMBER,
    x_target_article_id     OUT NOCOPY NUMBER,
    x_org_id                OUT NOCOPY NUMBER

  ) IS

    l_object_version_number OKC_ARTICLE_RELATNS_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by            OKC_ARTICLE_RELATNS_ALL.CREATED_BY%TYPE;
    l_creation_date         OKC_ARTICLE_RELATNS_ALL.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_ARTICLE_RELATNS_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4200: Entered Insert_Row', 2);
    END IF;

    --- Setting item attributes
    -- Set primary key value
    IF( p_source_article_id IS NULL OR p_target_article_id IS NULL OR p_org_id IS NULL ) THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSE
      x_source_article_id := p_source_article_id;
      x_target_article_id := p_target_article_id;
      x_org_id := p_org_id;
    END IF;
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
      p_source_article_id     => x_source_article_id,
      p_target_article_id     => x_target_article_id,
      p_org_id                => x_org_id,
      p_relationship_type     => p_relationship_type
    );
   --dbms_output.put_line('All the xs: '||x_source_article_id ||'*'||x_target_article_id);
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
      p_source_article_id     => x_source_article_id,
      p_target_article_id     => x_target_article_id,
      p_org_id                => x_org_id,
      p_relationship_type     => p_relationship_type,
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
  -- Lock_Row for:OKC_ARTICLE_RELATNS_ALL --
  -----------------------------------
  FUNCTION Lock_Row(
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_object_version_number IN NUMBER
  ) RETURN VARCHAR2 IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (cp_source_article_id NUMBER, cp_target_article_id NUMBER, cp_org_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_ARTICLE_RELATNS_ALL
     WHERE SOURCE_ARTICLE_ID = cp_source_article_id AND TARGET_ARTICLE_ID = cp_target_article_id AND ORG_ID = cp_org_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_source_article_id NUMBER, cp_target_article_id NUMBER, cp_org_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_ARTICLE_RELATNS_ALL
     WHERE SOURCE_ARTICLE_ID = cp_source_article_id AND TARGET_ARTICLE_ID = cp_target_article_id AND ORG_ID = cp_org_id;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_ARTICLE_RELATNS_ALL.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('4900: Entered Lock_Row', 2);
    END IF;


    BEGIN

      OPEN lock_csr( p_source_article_id, p_target_article_id, p_org_id, p_object_version_number );
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

      OPEN lchk_csr(p_source_article_id, p_target_article_id, p_org_id);
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
  -- Lock_Row for:OKC_ARTICLE_RELATNS_ALL --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
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
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
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
  -- Update_Row for:OKC_ARTICLE_RELATNS_ALL --
  -------------------------------------
  FUNCTION Update_Row(
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,
    p_object_version_number IN NUMBER,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE,
    p_last_updated_by       IN NUMBER,
    p_last_update_login     IN NUMBER,
    p_last_update_date      IN DATE
   ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('6400: Entered Update_Row', 2);
    END IF;

    UPDATE OKC_ARTICLE_RELATNS_ALL
     SET RELATIONSHIP_TYPE     = p_relationship_type,
         OBJECT_VERSION_NUMBER = p_object_version_number,
         CREATED_BY            = p_created_by,
         CREATION_DATE         = p_creation_date,
         LAST_UPDATED_BY       = p_last_updated_by,
         LAST_UPDATE_LOGIN     = p_last_update_login,
         LAST_UPDATE_DATE      = p_last_update_date
    WHERE SOURCE_ARTICLE_ID     = p_source_article_id AND TARGET_ARTICLE_ID     = p_target_article_id AND ORG_ID                = p_org_id;

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
  -- Update_Row for:OKC_ARTICLE_RELATNS_ALL --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,



    p_object_version_number IN NUMBER

   ) IS

    l_relationship_type     OKC_ARTICLE_RELATNS_ALL.RELATIONSHIP_TYPE%TYPE;
    l_object_version_number OKC_ARTICLE_RELATNS_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by            OKC_ARTICLE_RELATNS_ALL.CREATED_BY%TYPE;
    l_creation_date         OKC_ARTICLE_RELATNS_ALL.CREATION_DATE%TYPE;
    l_last_updated_by       OKC_ARTICLE_RELATNS_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login     OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date      OKC_ARTICLE_RELATNS_ALL.LAST_UPDATE_DATE%TYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('7000: Entered Update_Row', 2);
       Okc_Debug.Log('7100: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
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
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => p_relationship_type,
      p_object_version_number => p_object_version_number,
      x_relationship_type     => l_relationship_type
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
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => l_relationship_type
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
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
      p_relationship_type     => l_relationship_type,
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
  -- Delete_Row for:OKC_ARTICLE_RELATNS_ALL --
  -------------------------------------
  FUNCTION Delete_Row(
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER
  ) RETURN VARCHAR2 IS

  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8200: Entered Delete_Row', 2);
    END IF;
-- Delete opposite rows (mutually related by flipping the source and target ids)

    DELETE FROM OKC_ARTICLE_RELATNS_ALL
      WHERE SOURCE_ARTICLE_ID = p_SOURCE_ARTICLE_ID AND
      TARGET_ARTICLE_ID = p_TARGET_ARTICLE_ID AND
                 ORG_ID = p_ORG_ID;

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
  -- Delete_Row for:OKC_ARTICLE_RELATNS_ALL --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_object_version_number IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('8800: Entered Delete_Row', 2);
       Okc_Debug.Log('8900: Locking _B row', 2);
    END IF;

    x_return_status := Lock_row(
      p_source_article_id     => p_source_article_id,
      p_target_article_id     => p_target_article_id,
      p_org_id                => p_org_id,
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
    x_return_status := Delete_Row( p_source_article_id => p_source_article_id,p_target_article_id => p_target_article_id,p_org_id => p_org_id );
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



END OKC_ARTICLE_RELATIONSHIPS_PVT;

/

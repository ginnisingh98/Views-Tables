--------------------------------------------------------
--  DDL for Package Body OKC_TEMPLATE_USAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TEMPLATE_USAGES_PVT" AS
/* $Header: OKCVTMPLUSGB.pls 120.2.12010000.7 2012/06/14 09:09:28 nbingi ship $ */


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
  G_REQUIRED_VALUE_VALID_LEVEL CONSTANT NUMBER := OKC_API.G_REQUIRED_VALUE_VALID_LEVEL;
  G_VALID_VALUE_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_VALID_VALUE_VALID_LEVEL;
  G_LOOKUP_CODE_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_LOOKUP_CODE_VALID_LEVEL;
  G_FOREIGN_KEY_VALID_LEVEL    CONSTANT NUMBER := OKC_API.G_FOREIGN_KEY_VALID_LEVEL;
  G_RECORD_VALID_LEVEL         CONSTANT NUMBER := OKC_API.G_RECORD_VALID_LEVEL;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(40) := 'OKC_TEMPLATE_USAGES_PVT';
  G_MODULE                     CONSTANT   VARCHAR2(200)  := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_INTERNAL_PARTY_CODE        CONSTANT   VARCHAR2(30)   :=  'INTERNAL_ORG';

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
  -- FUNCTION get_rec for: OKC_TEMPLATE_USAGES
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,

    x_template_id            OUT NOCOPY NUMBER,
    x_doc_numbering_scheme   OUT NOCOPY NUMBER,
    x_document_number        OUT NOCOPY VARCHAR2,
    x_article_effective_date OUT NOCOPY DATE,
    x_config_header_id       OUT NOCOPY NUMBER,
    x_config_revision_number OUT NOCOPY NUMBER,
    x_valid_config_yn        OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1 OUT NOCOPY NUMBER,
    x_orig_system_reference_id2 OUT NOCOPY NUMBER,
    x_object_version_number  OUT NOCOPY NUMBER,
    x_created_by             OUT NOCOPY NUMBER,
    x_creation_date          OUT NOCOPY DATE,
    x_last_updated_by        OUT NOCOPY NUMBER,
    x_last_update_login      OUT NOCOPY NUMBER,
    x_last_update_date       OUT NOCOPY DATE,
--added for 10+ word integration and deviations report
    x_authoring_party_code   OUT NOCOPY VARCHAR2,
    x_contract_source_code   OUT NOCOPY VARCHAR2,
    x_approval_abstract_text OUT NOCOPY CLOB,
    x_autogen_deviations_flag OUT NOCOPY VARCHAR2,
 --added for bug# 3990983
    x_source_change_allowed_flag OUT NOCOPY VARCHAR2,
    x_lock_terms_flag        OUT NOCOPY VARCHAR2,
    x_enable_reporting_flag  OUT NOCOPY VARCHAR2,
    x_contract_admin_id      OUT NOCOPY NUMBER,
    x_legal_contact_id       OUT NOCOPY NUMBER,
    x_locked_by_user_id      OUT NOCOPY NUMBER

  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'Get_Rec';
    CURSOR OKC_TEMPLATE_USAGES_pk_csr (cp_document_type IN VARCHAR2,cp_document_id IN NUMBER) IS
    SELECT
            TEMPLATE_ID,
            DOC_NUMBERING_SCHEME,
            DOCUMENT_NUMBER,
            ARTICLE_EFFECTIVE_DATE,
            CONFIG_HEADER_ID,
            CONFIG_REVISION_NUMBER,
            VALID_CONFIG_YN,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            AUTHORING_PARTY_CODE,
            CONTRACT_SOURCE_CODE,
            APPROVAL_ABSTRACT_TEXT ,
            AUTOGEN_DEVIATIONS_FLAG,
		  -- Fix for bug# 3990983
		  SOURCE_CHANGE_ALLOWED_FLAG,
			 LOCK_TERMS_FLAG,
		     ENABLE_REPORTING_FLAG,
		     CONTRACT_ADMIN_ID,
		     LEGAL_CONTACT_ID,
             LOCKED_BY_USER_ID
      FROM OKC_TEMPLATE_USAGES t
     WHERE t.DOCUMENT_TYPE = cp_document_type and
           t.DOCUMENT_ID = cp_document_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
       '400: Entered get_rec');
    END IF;


    -- Get current database values
    OPEN OKC_TEMPLATE_USAGES_pk_csr (p_document_type, p_document_id);
    FETCH OKC_TEMPLATE_USAGES_pk_csr INTO
            x_template_id,
            x_doc_numbering_scheme,
            x_document_number,
            x_article_effective_date,
            x_config_header_id,
            x_config_revision_number,
            x_valid_config_yn,
            x_orig_system_reference_code,
            x_orig_system_reference_id1,
            x_orig_system_reference_id2,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,

            x_authoring_party_code,
            x_contract_source_code,
            x_approval_abstract_text,
            x_autogen_deviations_flag,
		    x_source_change_allowed_flag , -- Fix for bug# 3990983
		    x_lock_terms_flag,
		    x_enable_reporting_flag,
		    x_contract_admin_id,
		    x_legal_contact_id,
            x_locked_by_user_id;

    IF OKC_TEMPLATE_USAGES_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_TEMPLATE_USAGES_pk_csr;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
      '500: Leaving  get_rec ');
   END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
         '600: Leaving get_rec because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF OKC_TEMPLATE_USAGES_pk_csr%ISOPEN THEN
        CLOSE OKC_TEMPLATE_USAGES_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_TEMPLATE_USAGES --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,
    p_object_version_number  IN NUMBER,
    p_authoring_party_code   IN VARCHAR2,
    p_contract_source_code   IN VARCHAR2,
    p_approval_abstract_text IN CLOB,
    p_autogen_deviations_flag IN VARCHAR2,
 --added for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 ,

    x_template_id            OUT NOCOPY NUMBER,
    x_doc_numbering_scheme   OUT NOCOPY NUMBER,
    x_document_number        OUT NOCOPY VARCHAR2,
    x_article_effective_date OUT NOCOPY DATE,
    x_config_header_id       OUT NOCOPY NUMBER,
    x_config_revision_number OUT NOCOPY NUMBER,
    x_valid_config_yn        OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY  VARCHAR2,
    x_orig_system_reference_id1 OUT NOCOPY NUMBER,
    x_orig_system_reference_id2 OUT NOCOPY NUMBER,

--added for 10+ word integration and deviations report
    x_authoring_party_code   OUT NOCOPY VARCHAR2,
    x_contract_source_code   OUT NOCOPY VARCHAR2,
    x_approval_abstract_text OUT NOCOPY CLOB,
    x_autogen_deviations_flag OUT NOCOPY VARCHAR2,
--added for bug# 3990983
    x_source_change_allowed_flag OUT NOCOPY VARCHAR2,
    p_lock_terms_flag        IN VARCHAR2 ,
    p_enable_reporting_flag  IN VARCHAR2 ,
    p_contract_admin_id      IN NUMBER ,
    p_legal_contact_id       IN NUMBER ,
    p_locked_by_user_id      IN NUMBER,
    x_lock_terms_flag        OUT NOCOPY VARCHAR2,
    x_enable_reporting_flag  OUT NOCOPY VARCHAR2,
    x_contract_admin_id      OUT NOCOPY NUMBER,
    x_legal_contact_id       OUT NOCOPY NUMBER,
    x_locked_by_user_id      OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'Set_Attributes';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number  OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_TEMPLATE_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_TEMPLATE_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_TEMPLATE_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_TEMPLATE_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_TEMPLATE_USAGES.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
      '700: Entered Set_Attributes ');
    END IF;

    IF( p_document_type IS NOT NULL AND p_document_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_document_type          => p_document_type,
        p_document_id            => p_document_id,
        x_template_id            => x_template_id,
        x_doc_numbering_scheme   => x_doc_numbering_scheme,
        x_document_number        => x_document_number,
        x_article_effective_date => x_article_effective_date,
        x_config_header_id       => x_config_header_id,
        x_config_revision_number => x_config_revision_number,
        x_valid_config_yn        => x_valid_config_yn,
        x_orig_system_reference_code => x_orig_system_reference_code,
        x_orig_system_reference_id1 => x_orig_system_reference_id1,
        x_orig_system_reference_id2 => x_orig_system_reference_id2,
        x_object_version_number  => l_object_version_number,
        x_created_by             => l_created_by,
        x_creation_date          => l_creation_date,
        x_last_updated_by        => l_last_updated_by,
        x_last_update_login      => l_last_update_login,
        x_last_update_date       => l_last_update_date,
        x_authoring_party_code   => x_authoring_party_code ,
        x_contract_source_code   => x_contract_source_code ,
        x_approval_abstract_text => x_approval_abstract_text,
        x_autogen_deviations_flag => x_autogen_deviations_flag,
	   -- Fix for bug# 3990983
	   x_source_change_allowed_flag => x_source_change_allowed_flag,
        x_lock_terms_flag        => x_lock_terms_flag,
        x_enable_reporting_flag  => x_enable_reporting_flag,
        x_contract_admin_id      => x_contract_admin_id,
        x_legal_contact_id       => x_legal_contact_id,
        x_locked_by_user_id      => x_locked_by_user_id
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
       ELSIF (p_TEMPLATE_ID IS NOT NULL) THEN
        x_template_id := p_template_id;
      END IF;

      IF (p_doc_numbering_scheme = G_MISS_NUM) THEN
        x_doc_numbering_scheme := NULL;
       ELSIF (p_DOC_NUMBERING_SCHEME IS NOT NULL) THEN
        x_doc_numbering_scheme := p_doc_numbering_scheme;
      END IF;

      IF (p_document_number = G_MISS_CHAR) THEN
        x_document_number := NULL;
       ELSIF (p_DOCUMENT_NUMBER IS NOT NULL) THEN
        x_document_number := p_document_number;
      END IF;

      IF (p_article_effective_date = G_MISS_DATE) THEN
        x_article_effective_date := NULL;
       ELSIF (p_ARTICLE_EFFECTIVE_DATE IS NOT NULL) THEN
        x_article_effective_date := p_article_effective_date;
      END IF;

      IF (p_config_header_id = G_MISS_NUM) THEN
        x_config_header_id := NULL;
       ELSIF (p_CONFIG_HEADER_ID IS NOT NULL) THEN
        x_config_header_id := p_config_header_id;
      END IF;

      IF (p_config_revision_number = G_MISS_NUM) THEN
        x_config_revision_number := NULL;
       ELSIF (p_CONFIG_REVISION_NUMBER IS NOT NULL) THEN
        x_config_revision_number := p_config_revision_number;
      END IF;

      IF (p_valid_config_yn = G_MISS_CHAR) THEN
        x_valid_config_yn := NULL;
       ELSIF (p_VALID_CONFIG_YN IS NOT NULL) THEN
        x_valid_config_yn := p_valid_config_yn;
      END IF;

      IF (p_orig_system_reference_code = G_MISS_CHAR) THEN
        x_orig_system_reference_code := NULL;
       ELSIF (p_orig_system_reference_code IS NOT NULL) THEN
        x_orig_system_reference_code := p_orig_system_reference_code;
      END IF;

      IF (p_orig_system_reference_id1 = G_MISS_NUM) THEN
        x_orig_system_reference_id1 := NULL;
       ELSIF (p_orig_system_reference_id1 IS NOT NULL) THEN
        x_orig_system_reference_id1 := p_orig_system_reference_id1;
      END IF;

      IF (p_orig_system_reference_id2 = G_MISS_NUM) THEN
        x_orig_system_reference_id2 := NULL;
       ELSIF (p_orig_system_reference_id2 IS NOT NULL) THEN
        x_orig_system_reference_id2 := p_orig_system_reference_id2;
      END IF;


--added for 10+ word integration and deviations report
      IF (p_authoring_party_code = G_MISS_CHAR) THEN
        x_authoring_party_code := NULL;
       ELSIF (p_authoring_party_code IS NOT NULL) THEN
        x_authoring_party_code := p_authoring_party_code;
      END IF;

      IF (p_contract_source_code = G_MISS_CHAR) THEN
        x_contract_source_code := NULL;
       ELSIF (p_contract_source_code IS NOT NULL) THEN
        x_contract_source_code := p_contract_source_code;
      END IF;

      IF dbms_lob.getlength(p_approval_abstract_text) = length(G_MISS_CHAR) THEN
        IF (dbms_lob.substr(p_approval_abstract_text,dbms_lob.getlength(p_approval_abstract_text)) = G_MISS_CHAR) THEN
          x_approval_abstract_text := NULL;
        END IF;
      ELSIF (p_approval_abstract_text IS NOT NULL) THEN
        x_approval_abstract_text := p_approval_abstract_text;
      END IF;

      IF (p_autogen_deviations_flag = G_MISS_CHAR) THEN
        x_autogen_deviations_flag := NULL;
       ELSIF (p_autogen_deviations_flag IS NOT NULL) THEN
        x_autogen_deviations_flag := p_autogen_deviations_flag;
        x_autogen_deviations_flag := Upper( x_autogen_deviations_flag );
      END IF;
      IF (p_source_change_allowed_flag = G_MISS_CHAR) THEN
        x_source_change_allowed_flag := NULL;
       ELSIF (p_source_change_allowed_flag IS NOT NULL) THEN
        x_source_change_allowed_flag := p_source_change_allowed_flag;
        x_source_change_allowed_flag := Upper( x_source_change_allowed_flag );
      END IF;

      IF (p_lock_terms_flag = G_MISS_CHAR) THEN
        x_lock_terms_flag := NULL;
       ELSIF (p_lock_terms_flag IS NOT NULL) THEN
        x_lock_terms_flag := p_lock_terms_flag;
        x_lock_terms_flag := Upper( x_lock_terms_flag );
      END IF;

      IF (p_enable_reporting_flag = G_MISS_CHAR) THEN
        x_enable_reporting_flag := NULL;
       ELSIF (p_enable_reporting_flag IS NOT NULL) THEN
        x_enable_reporting_flag := p_enable_reporting_flag;
        x_enable_reporting_flag := Upper( x_enable_reporting_flag );
      END IF;

      IF (p_contract_admin_id = G_MISS_NUM) THEN
        x_contract_admin_id := NULL;
       ELSIF (p_contract_admin_id IS NOT NULL) THEN
        x_contract_admin_id := p_contract_admin_id;
      END IF;


      IF (p_legal_contact_id = G_MISS_NUM) THEN
        x_legal_contact_id := NULL;
       ELSIF (p_legal_contact_id IS NOT NULL) THEN
        x_legal_contact_id := p_legal_contact_id;
      END IF;


      IF (p_locked_by_user_id = G_MISS_NUM) THEN
        x_locked_by_user_id := NULL;
       ELSIF (p_locked_by_user_id IS NOT NULL) THEN
        x_locked_by_user_id := p_locked_by_user_id;
      END IF;


      -- ?? converting to uppercase all _YN columns
      -- ?? per performance reason it can be moved into corresponding
      -- ?? ELSIF( column IS NOT NULL) section above
      x_valid_config_yn := Upper( x_valid_config_yn );

    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
        '800: Leaving  Set_Attributes ');
    END IF;

    RETURN G_RET_STS_SUCCESS ;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
          '900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception');
      END IF;
      RETURN G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
          '1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
        '1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm);
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
  -- Validate_Attributes for: OKC_TEMPLATE_USAGES --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2,
    p_contract_source_code   IN VARCHAR2,
    p_approval_abstract_text IN CLOB,
    p_autogen_deviations_flag IN VARCHAR2,
-- fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2,
    p_lock_terms_flag        IN VARCHAR2 ,
    p_enable_reporting_flag  IN VARCHAR2 ,
    p_contract_admin_id      IN NUMBER ,
    p_legal_contact_id       IN NUMBER,
    p_locked_by_user_id      IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'Validate_Attributes';
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_tmp_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

    CURSOR l_template_id_csr is
     SELECT '!'
      FROM okc_terms_templates_all
      WHERE TEMPLATE_ID = p_template_id;

    CURSOR l_doc_number_scheme_csr is
     SELECT '!'
      FROM okc_number_schemes_b
      WHERE num_scheme_id = p_doc_numbering_scheme;

/*
    CURSOR l_config_header_id_csr is
     SELECT '!'
      FROM ??unknown_table??
      WHERE ??CONFIG_HEADER_ID?? = p_config_header_id;

*/

--added for 10+ word integration and deviations report
    CURSOR l_authoring_party_csr(p_party_code IN VARCHAR2) is
    SELECT 'Y'
     FROM  OKC_RESP_PARTIES_B del, OKC_BUS_DOC_TYPES_B types
     WHERE del.document_type_class = types.document_type_class
       AND types.document_type = p_document_type
       AND del.resp_party_code = p_party_code;


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1200: Entered Validate_Attributes');
    END IF;


    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1300: required values validation');
      END IF;

    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: static values and range validation');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1700: - attribute VALID_CONFIG_YN ');
      END IF;
      IF ( p_valid_config_yn NOT IN ('Y','N') AND p_valid_config_yn IS NOT NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: - attribute VALID_CONFIG_YN is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'VALID_CONFIG_YN');
        l_return_status := G_RET_STS_ERROR;
      END IF;


--added for 10+ word integration and deviations report
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2100: - attribute  AUTOGEN_DEVIATIONS_FLAG ');
      END IF;
      IF  (p_autogen_deviations_flag NOT IN ('Y','N') AND p_autogen_deviations_flag IS NOT NULL )THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: - attribute  AUTOGEN_DEVIATIONS_FLAG is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'AUTOGEN_DEVIATIONS_FLAG');
        l_return_status := G_RET_STS_ERROR;
      END IF;
    END IF;


    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: lookup codes validation');
      END IF;

--added for 10+ word integration and deviations report
--Validate lookup for authoring_party_code
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute AUTHORING_PARTY_CODE ');
      END IF;
      IF p_authoring_party_code IS NOT NULL THEN
         l_dummy_var := '?';
         OPEN  l_authoring_party_csr(p_authoring_party_code);
         FETCH l_authoring_party_csr INTO l_dummy_var;
         CLOSE l_authoring_party_csr;
         IF (l_dummy_var = '?') THEN
             Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'AUTHORING_PARTY_CODE');
             l_return_status := G_RET_STS_ERROR;
         END IF;
      END IF;

--added for 10+ word integration and deviations report
--Validate lookup for contract_source_code
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute CONTRACT_SOURCE_CODE ');
      END IF;
      l_tmp_return_status := Okc_Util.Check_Lookup_Code('OKC_CONTRACT_TERMS_SOURCES',p_contract_source_code);
      IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CONTRACT_SOURCE_CODE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2100: foreigh keys validation ');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute DOC_NUMBERING_SCHEME ');
      END IF;
      IF p_doc_numbering_scheme IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_doc_number_scheme_csr;
        FETCH l_doc_number_scheme_csr INTO l_dummy_var;
        CLOSE l_doc_number_scheme_csr;
        IF (l_dummy_var = '?') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: - attribute DOC_NUMBERING_SCHEME is invalid');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DOC_NUMBERING_SCHEME');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute TEMPLATE_ID ');
      END IF;
      IF p_template_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_template_id_csr;
        FETCH l_template_id_csr INTO l_dummy_var;
        CLOSE l_template_id_csr;
        IF (l_dummy_var = '?') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: - attribute TEMPLATE_ID is invalid');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TEMPLATE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      /*
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute CONFIG_HEADER_ID ');
      END IF;
      IF p_config_header_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_config_header_id_csr;
        FETCH l_config_header_id_csr INTO l_dummy_var;
        CLOSE l_config_header_id_csr;
        IF (l_dummy_var = '?') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: - attribute CONFIG_HEADER_ID is invalid');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONFIG_HEADER_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      */
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2400: Leaving Validate_Attributes ');
    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF l_doc_number_scheme_csr%ISOPEN THEN
        CLOSE l_doc_number_scheme_csr;
      END IF;

      IF l_template_id_csr%ISOPEN THEN
        CLOSE l_template_id_csr;
      END IF;

      /*
      IF l_config_header_id_csr%ISOPEN THEN
        CLOSE l_config_header_id_csr;
      END IF;
      */

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_TEMPLATE_USAGES --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2,
    p_contract_source_code   IN VARCHAR2,
    p_approval_abstract_text IN CLOB,
    p_autogen_deviations_flag IN VARCHAR2,
-- fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2,
    p_lock_terms_flag        IN VARCHAR2 ,
    p_enable_reporting_flag  IN VARCHAR2 ,
    p_contract_admin_id      IN NUMBER ,
    p_legal_contact_id       IN NUMBER,
    p_locked_by_user_id      IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'Validate_Record';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2600: Entered Validate_Record');
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => p_template_id,
      p_doc_numbering_scheme   => p_doc_numbering_scheme,
      p_document_number        => p_document_number,
      p_article_effective_date => p_article_effective_date,
      p_config_header_id       => p_config_header_id,
      p_config_revision_number => p_config_revision_number,
      p_valid_config_yn        => p_valid_config_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id2,

      p_authoring_party_code   => p_authoring_party_code,
      p_contract_source_code   => p_contract_source_code,
      p_approval_abstract_text => p_approval_abstract_text,
      p_autogen_deviations_flag => p_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => p_source_change_allowed_flag,
	 p_lock_terms_flag => p_lock_terms_flag,
	 p_enable_reporting_flag => p_enable_reporting_flag,
	 p_contract_admin_id => p_contract_admin_id,
	 p_legal_contact_id => p_legal_contact_id,
       p_locked_by_user_id => p_locked_by_user_id
);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2700: Leaving Validate_Record because of UNEXP_ERROR in Validate_Attributes: '||sqlerrm);
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;
    END IF;

    --- Record Level Validation
    IF p_validation_level > G_RECORD_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2800: Entered Record Level Validations');
      END IF;
/*+++++++++++++start of hand code +++++++++++++++++++*/
-- ?? manual coding for Record Level Validations if required ??
/*+++++++++++++End of hand code +++++++++++++++++++*/
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2900: Leaving Validate_Record : '||sqlerrm);
    END IF;
    RETURN l_return_status ;

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3000: Leaving Validate_Record because of EXCEPTION: '||sqlerrm);
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
  -- validate_row for:OKC_TEMPLATE_USAGES --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,

    p_object_version_number  IN NUMBER,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2,
    p_contract_source_code   IN VARCHAR2,
    p_approval_abstract_text IN CLOB,
    p_autogen_deviations_flag IN VARCHAR2,
 --Fix for bug# 3990983
    p_source_change_allowed_flag in VARCHAR2,
    p_lock_terms_flag        IN VARCHAR2 ,
    p_enable_reporting_flag  IN VARCHAR2 ,
    p_contract_admin_id      IN NUMBER ,
    p_legal_contact_id       IN NUMBER,
    p_locked_by_user_id      IN NUMBER
) IS
      l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
      l_template_id            OKC_TEMPLATE_USAGES.TEMPLATE_ID%TYPE;
      l_doc_numbering_scheme   OKC_TEMPLATE_USAGES.DOC_NUMBERING_SCHEME%TYPE;
      l_document_number        OKC_TEMPLATE_USAGES.DOCUMENT_NUMBER%TYPE;
      l_article_effective_date OKC_TEMPLATE_USAGES.ARTICLE_EFFECTIVE_DATE%TYPE;
      l_config_header_id       OKC_TEMPLATE_USAGES.CONFIG_HEADER_ID%TYPE;
      l_config_revision_number OKC_TEMPLATE_USAGES.CONFIG_REVISION_NUMBER%TYPE;
      l_valid_config_yn        OKC_TEMPLATE_USAGES.VALID_CONFIG_YN%TYPE;
      l_object_version_number  OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE;
      l_orig_system_reference_code OKC_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
      l_orig_system_reference_id1 OKC_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
      l_orig_system_reference_id2 OKC_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_ID2%TYPE;

      l_authoring_party_code   OKC_TEMPLATE_USAGES.AUTHORING_PARTY_CODE%TYPE;
      l_contract_source_code   OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;
      l_approval_abstract_text OKC_TEMPLATE_USAGES.APPROVAL_ABSTRACT_TEXT%TYPE;
      l_autogen_deviations_flag OKC_TEMPLATE_USAGES.AUTOGEN_DEVIATIONS_FLAG%TYPE;
--    Fix for bug# 3990983
      l_source_change_allowed_flag OKC_TEMPLATE_USAGES.SOURCE_CHANGE_ALLOWED_FLAG%TYPE;
      l_lock_terms_flag         OKC_TEMPLATE_USAGES.LOCK_TERMS_FLAG%TYPE;
      l_enable_reporting_flag   OKC_TEMPLATE_USAGES.ENABLE_REPORTING_FLAG%TYPE;
      l_contract_admin_id       OKC_TEMPLATE_USAGES.CONTRACT_ADMIN_ID%TYPE;
      l_legal_contact_id        OKC_TEMPLATE_USAGES.LEGAL_CONTACT_ID%TYPE;
      l_locked_by_user_id       OKC_TEMPLATE_USAGES.LOCKED_BY_USER_ID%TYPE;

      l_created_by             OKC_TEMPLATE_USAGES.CREATED_BY%TYPE;
      l_creation_date          OKC_TEMPLATE_USAGES.CREATION_DATE%TYPE;
      l_last_updated_by        OKC_TEMPLATE_USAGES.LAST_UPDATED_BY%TYPE;
      l_last_update_login      OKC_TEMPLATE_USAGES.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date       OKC_TEMPLATE_USAGES.LAST_UPDATE_DATE%TYPE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3100: Entered validate_row');
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => p_template_id,
      p_doc_numbering_scheme   => p_doc_numbering_scheme,
      p_document_number        => p_document_number,
      p_article_effective_date => p_article_effective_date,
      p_config_header_id       => p_config_header_id,
      p_config_revision_number => p_config_revision_number,
      p_valid_config_yn        => p_valid_config_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
      p_object_version_number  => p_object_version_number,
      p_authoring_party_code   => p_authoring_party_code,
      p_contract_source_code   => p_contract_source_code,
      p_approval_abstract_text => p_approval_abstract_text,
      p_autogen_deviations_flag => p_autogen_deviations_flag,
--Fix for bug# 3990983
      p_source_change_allowed_flag => p_source_change_allowed_flag,

      x_template_id            => l_template_id,
      x_doc_numbering_scheme   => l_doc_numbering_scheme,
      x_document_number        => l_document_number,
      x_article_effective_date => l_article_effective_date,
      x_config_header_id       => l_config_header_id,
      x_config_revision_number => l_config_revision_number,
      x_valid_config_yn        => l_valid_config_yn,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1 => l_orig_system_reference_id1,
      x_orig_system_reference_id2 => l_orig_system_reference_id2,
      x_authoring_party_code   => l_authoring_party_code,
      x_contract_source_code   => l_contract_source_code,
      x_approval_abstract_text => l_approval_abstract_text,
      x_autogen_deviations_flag => l_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 x_source_change_allowed_flag => l_source_change_allowed_flag,

      x_lock_terms_flag        => l_lock_terms_flag,
      x_enable_reporting_flag  => l_enable_reporting_flag,
      x_contract_admin_id      => l_contract_admin_id,
      x_legal_contact_id       => l_legal_contact_id,
      x_locked_by_user_id      => l_locked_by_user_id,
      p_lock_terms_flag        => p_lock_terms_flag,
      p_enable_reporting_flag  => p_enable_reporting_flag,
      p_contract_admin_id      => p_contract_admin_id,
      p_legal_contact_id       => p_legal_contact_id,
      p_locked_by_user_id      => p_locked_by_user_id
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => l_template_id,
      p_doc_numbering_scheme   => l_doc_numbering_scheme,
      p_document_number        => l_document_number,
      p_article_effective_date => l_article_effective_date,
      p_config_header_id       => l_config_header_id,
      p_config_revision_number => l_config_revision_number,
      p_valid_config_yn        => l_valid_config_yn,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1 => l_orig_system_reference_id1,
      p_orig_system_reference_id2 => l_orig_system_reference_id2,

      p_authoring_party_code   => l_authoring_party_code,
      p_contract_source_code   => l_contract_source_code,
      p_approval_abstract_text => l_approval_abstract_text,
      p_autogen_deviations_flag => l_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => l_source_change_allowed_flag,
     p_lock_terms_flag        => p_lock_terms_flag,
      p_enable_reporting_flag  => p_enable_reporting_flag,
      p_contract_admin_id      => p_contract_admin_id,
      p_legal_contact_id       => p_legal_contact_id,
      p_locked_by_user_id      => p_locked_by_user_id
);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3200: Leaving validate_row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3300: Leaving Validate_Row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3400: Leaving Validate_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm);
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
  -- Insert_Row for:OKC_TEMPLATE_USAGES --
  -------------------------------------
  FUNCTION Insert_Row(
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,
    p_object_version_number  IN NUMBER,
    p_created_by             IN NUMBER,
    p_creation_date          IN DATE,
    p_last_updated_by        IN NUMBER,
    p_last_update_login      IN NUMBER,
    p_last_update_date       IN DATE,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2,
    p_contract_source_code   IN VARCHAR2,
    p_approval_abstract_text IN CLOB,
    p_autogen_deviations_flag IN VARCHAR2,
--Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2,
    p_lock_terms_flag        IN VARCHAR2 ,
    p_enable_reporting_flag  IN VARCHAR2 ,
    p_contract_admin_id      IN NUMBER ,
    p_legal_contact_id       IN NUMBER,
    p_locked_by_user_id      IN NUMBER,
    p_contract_expert_finish_flag	    IN VARCHAR2
  ) RETURN VARCHAR2 IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3600: Entered Insert_Row function');
    END IF;

    INSERT INTO OKC_TEMPLATE_USAGES(
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        TEMPLATE_ID,
        DOC_NUMBERING_SCHEME,
        DOCUMENT_NUMBER,
        ARTICLE_EFFECTIVE_DATE,
        CONFIG_HEADER_ID,
        CONFIG_REVISION_NUMBER,
        VALID_CONFIG_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,

        AUTHORING_PARTY_CODE,
        CONTRACT_SOURCE_CODE ,
        APPROVAL_ABSTRACT_TEXT ,
        AUTOGEN_DEVIATIONS_FLAG,
	   --Fix for bug# 3990983
	   SOURCE_CHANGE_ALLOWED_FLAG,
       lock_terms_flag,
	   enable_reporting_flag,
	   contract_admin_id,
	   legal_contact_id,
       locked_by_user_id,
	   contract_expert_finish_flag)
      VALUES (
        p_document_type,
        p_document_id,
        p_template_id,
        p_doc_numbering_scheme,
        p_document_number,
        p_article_effective_date,
        p_config_header_id,
        p_config_revision_number,
        p_valid_config_yn,
        p_orig_system_reference_code,
        p_orig_system_reference_id1,
        p_orig_system_reference_id2,
        p_object_version_number,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date,

        p_authoring_party_code,
        p_contract_source_code,
        p_approval_abstract_text,
        p_autogen_deviations_flag,
	   -- Fix for bug# 3990983
	   p_source_change_allowed_flag,
	   p_lock_terms_flag,
	   p_enable_reporting_flag,
	   p_contract_admin_id,
	   p_legal_contact_id,
       p_locked_by_user_id,
	  p_contract_expert_finish_flag
	   );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3700: Leaving Insert_Row');
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3800: Leaving Insert_Row:OTHERS Exception');
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
  -- Insert_Row for:OKC_TEMPLATE_USAGES --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2,
    p_contract_source_code   IN VARCHAR2,
    p_approval_abstract_text IN CLOB,
    p_autogen_deviations_flag IN VARCHAR2,
--Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2,

    x_document_type          OUT NOCOPY VARCHAR2,
    x_document_id            OUT NOCOPY NUMBER,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id      IN NUMBER := NULL,
    p_contract_expert_finish_flag IN VARCHAR2 := NULL

  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_object_version_number  OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_TEMPLATE_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_TEMPLATE_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_TEMPLATE_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_TEMPLATE_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_TEMPLATE_USAGES.LAST_UPDATE_DATE%TYPE;
    l_authoring_party_code   OKC_TEMPLATE_USAGES.authoring_party_code%type;


  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4200: Entered Insert_Row');
    END IF;

    -- Set Internal columns
    l_object_version_number  := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;

--added for 10+ word integration and deviations report
--Set default value for p_authoring_party_code
    l_authoring_party_code := p_authoring_party_code;
    IF p_authoring_party_code is NULL THEN

	 l_authoring_party_code := G_INTERNAL_PARTY_CODE;

    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => p_template_id,
      p_doc_numbering_scheme   => p_doc_numbering_scheme,
      p_document_number        => p_document_number,
      p_article_effective_date => p_article_effective_date,
      p_config_header_id       => p_config_header_id,
      p_config_revision_number => p_config_revision_number,
      p_valid_config_yn        => p_valid_config_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id2,

      p_authoring_party_code   => l_authoring_party_code,
      p_contract_source_code   => p_contract_source_code,
      p_approval_abstract_text => p_approval_abstract_text,
      p_autogen_deviations_flag => p_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => p_source_change_allowed_flag,
    p_lock_terms_flag       => p_lock_terms_flag ,
    p_enable_reporting_flag => p_enable_reporting_flag,
    p_contract_admin_id     => p_contract_admin_id ,
    p_legal_contact_id      => p_legal_contact_id,
    p_locked_by_user_id     => p_locked_by_user_id
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
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4300: Call the internal Insert_Row for Base Table');
    END IF;

    x_return_status := Insert_Row(
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => p_template_id,
      p_doc_numbering_scheme   => p_doc_numbering_scheme,
      p_document_number        => p_document_number,
      p_article_effective_date => p_article_effective_date,
      p_config_header_id       => p_config_header_id,
      p_config_revision_number => p_config_revision_number,
      p_valid_config_yn        => p_valid_config_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
      p_object_version_number  => l_object_version_number,
      p_created_by             => l_created_by,
      p_creation_date          => l_creation_date,
      p_last_updated_by        => l_last_updated_by,
      p_last_update_login      => l_last_update_login,
      p_last_update_date       => l_last_update_date,

      p_authoring_party_code   => l_authoring_party_code,
      p_contract_source_code   => p_contract_source_code,
      p_approval_abstract_text => p_approval_abstract_text,
      p_autogen_deviations_flag => p_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => p_source_change_allowed_flag,
     p_lock_terms_flag        => p_lock_terms_flag,
      p_enable_reporting_flag  => p_enable_reporting_flag,
      p_contract_admin_id      => p_contract_admin_id,
      p_legal_contact_id       => p_legal_contact_id,
      p_locked_by_user_id      => p_locked_by_user_id,
	 p_contract_expert_finish_flag => p_contract_expert_finish_flag
);
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;



    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4500: Leaving Insert_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4600: Leaving Insert_Row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4700: Leaving Insert_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'4800: Leaving Insert_Row because of EXCEPTION: '||sqlerrm);
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
  -- Lock_Row for:OKC_TEMPLATE_USAGES --
  -----------------------------------
  FUNCTION Lock_Row(
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER
  ) RETURN VARCHAR2 IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (cp_document_type VARCHAR2, cp_document_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_TEMPLATE_USAGES
     WHERE DOCUMENT_TYPE = cp_document_type AND DOCUMENT_ID = cp_document_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_document_type VARCHAR2, cp_document_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_TEMPLATE_USAGES
     WHERE DOCUMENT_TYPE = cp_document_type AND DOCUMENT_ID = cp_document_id;

    l_return_status                VARCHAR2(1);
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_object_version_number       OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4900: Entered Lock_Row');
    END IF;


    BEGIN

      OPEN lock_csr( p_document_type, p_document_id, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5000: Leaving Lock_Row:E_Resource_Busy Exception');
        END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
        RETURN( G_RET_STS_ERROR );
    END;

    IF ( l_row_notfound ) THEN
      l_return_status := G_RET_STS_ERROR;

      OPEN lchk_csr(p_document_type, p_document_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        Okc_Api.Set_Message(G_FND_APP,G_LOCK_RECORD_DELETED,
                   'ENTITYNAME','OKC_TEMPLATE_USAGES',
                   'PKEY',p_document_type||':'||p_document_id,
                   'OVN',p_object_version_number
                    );
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

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5100: Leaving Lock_Row');
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

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'5200: Leaving Lock_Row because of EXCEPTION: '||sqlerrm);
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
  -- Lock_Row for:OKC_TEMPLATE_USAGES --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER
   ) IS
     l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5700: Entered Lock_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5800: Locking Row for Base Table');
    END IF;

    --------------------------------------------
    -- Call the LOCK_ROW for each _B child record
    --------------------------------------------
    x_return_status := Lock_Row(
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_object_version_number  => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;



    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6000: Leaving Lock_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6100: Leaving Lock_Row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6200: Leaving Lock_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6300: Leaving Lock_Row because of EXCEPTION: '||sqlerrm);
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
  -- Update_Row for:OKC_TEMPLATE_USAGES --
  -------------------------------------
  FUNCTION Update_Row(
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,
    p_object_version_number  IN NUMBER,
    --p_created_by             IN NUMBER,
    --p_creation_date          IN DATE,
    p_last_updated_by        IN NUMBER,
    p_last_update_login      IN NUMBER,
    p_last_update_date       IN DATE,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2,
    p_contract_source_code   IN VARCHAR2,
    p_approval_abstract_text IN CLOB,
    p_autogen_deviations_flag IN VARCHAR2,
 -- Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2,
    p_lock_terms_flag        IN VARCHAR2 ,
    p_enable_reporting_flag  IN VARCHAR2 ,
    p_contract_admin_id      IN NUMBER ,
    p_legal_contact_id       IN NUMBER,
    p_locked_by_user_id      IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6400: Entered Update_Row');
    END IF;

    UPDATE OKC_TEMPLATE_USAGES
     SET TEMPLATE_ID            = p_template_id,
         DOC_NUMBERING_SCHEME   = p_doc_numbering_scheme,
         DOCUMENT_NUMBER        = p_document_number,
         ARTICLE_EFFECTIVE_DATE = p_article_effective_date,
         CONFIG_HEADER_ID       = p_config_header_id,
         CONFIG_REVISION_NUMBER = p_config_revision_number,
         VALID_CONFIG_YN        = p_valid_config_yn,
         ORIG_SYSTEM_REFERENCE_CODE = p_orig_system_reference_code,
         ORIG_SYSTEM_REFERENCE_ID1 = p_orig_system_reference_id1,
         ORIG_SYSTEM_REFERENCE_ID2 = p_orig_system_reference_id2,
         OBJECT_VERSION_NUMBER  = p_object_version_number,
         --CREATED_BY             = p_created_by,
         --CREATION_DATE          = p_creation_date,
         LAST_UPDATED_BY        = p_last_updated_by,
         LAST_UPDATE_LOGIN      = p_last_update_login,
         LAST_UPDATE_DATE       = p_last_update_date,

         AUTHORING_PARTY_CODE   = p_authoring_party_code,
         CONTRACT_SOURCE_CODE   = p_contract_source_code,
         APPROVAL_ABSTRACT_TEXT = p_approval_abstract_text,
         AUTOGEN_DEVIATIONS_FLAG  =  p_autogen_deviations_flag,
	    -- Fix for bug# 3990983
	    SOURCE_CHANGE_ALLOWED_FLAG = p_source_change_allowed_flag,
        lock_terms_flag        = p_lock_terms_flag,
        enable_reporting_flag  = p_enable_reporting_flag,
        contract_admin_id      = p_contract_admin_id,
        legal_contact_id       = p_legal_contact_id,
        locked_by_user_id      = p_locked_by_user_id
    WHERE DOCUMENT_TYPE          = p_document_type AND DOCUMENT_ID            = p_document_id;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6500: Leaving Update_Row');
    END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'6600: Leaving Update_Row because of EXCEPTION: '||sqlerrm);
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
  -- Update_Row for:OKC_TEMPLATE_USAGES --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER := NULL,
    p_doc_numbering_scheme   IN NUMBER := NULL,
    p_document_number        IN VARCHAR2 := NULL,
    p_article_effective_date IN DATE := NULL,
    p_config_header_id       IN NUMBER := NULL,
    p_config_revision_number IN NUMBER := NULL,
    p_valid_config_yn        IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,

--added for 10+ word integration and deviations report
    p_object_version_number  IN NUMBER := NULL,
    p_authoring_party_code   IN VARCHAR2 := NULL,
    p_contract_source_code   IN VARCHAR2 := NULL,
    p_approval_abstract_text IN CLOB := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
-- Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2:= NULL ,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id      IN NUMBER := NULL
   ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_template_id            OKC_TEMPLATE_USAGES.TEMPLATE_ID%TYPE;
    l_doc_numbering_scheme   OKC_TEMPLATE_USAGES.DOC_NUMBERING_SCHEME%TYPE;
    l_document_number        OKC_TEMPLATE_USAGES.DOCUMENT_NUMBER%TYPE;
    l_article_effective_date OKC_TEMPLATE_USAGES.ARTICLE_EFFECTIVE_DATE%TYPE;
    l_config_header_id       OKC_TEMPLATE_USAGES.CONFIG_HEADER_ID%TYPE;
    l_config_revision_number OKC_TEMPLATE_USAGES.CONFIG_REVISION_NUMBER%TYPE;
    l_valid_config_yn        OKC_TEMPLATE_USAGES.VALID_CONFIG_YN%TYPE;
    l_orig_system_reference_code OKC_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    l_orig_system_reference_id1 OKC_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    l_orig_system_reference_id2 OKC_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_ID2%TYPE;

    l_authoring_party_code   OKC_TEMPLATE_USAGES.AUTHORING_PARTY_CODE%TYPE;
    l_contract_source_code   OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;
    l_approval_abstract_text OKC_TEMPLATE_USAGES.APPROVAL_ABSTRACT_TEXT%TYPE;
    l_autogen_deviations_flag OKC_TEMPLATE_USAGES.AUTOGEN_DEVIATIONS_FLAG%TYPE;
    -- Fix for bug# 3990983
    l_source_change_allowed_flag OKC_TEMPLATE_USAGES.SOURCE_CHANGE_ALLOWED_FLAG%TYPE;

    l_object_version_number  OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_TEMPLATE_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_TEMPLATE_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_TEMPLATE_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_TEMPLATE_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_TEMPLATE_USAGES.LAST_UPDATE_DATE%TYPE;


    l_lock_terms_flag        OKC_TEMPLATE_USAGES.LOCK_TERMS_FLAG%TYPE;
    l_enable_reporting_flag  OKC_TEMPLATE_USAGES.ENABLE_REPORTING_FLAG%TYPE;
    l_contract_admin_id      OKC_TEMPLATE_USAGES.CONTRACT_ADMIN_ID%TYPE;
    l_legal_contact_id       OKC_TEMPLATE_USAGES.LEGAL_CONTACT_ID%TYPE;
    l_locked_by_user_id      OKC_TEMPLATE_USAGES.LOCKED_BY_USER_ID%TYPE;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Entered Update_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_object_version_number  => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7300: Setting attributes');
    END IF;

    x_return_status := Set_Attributes(
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => p_template_id,
      p_doc_numbering_scheme   => p_doc_numbering_scheme,
      p_document_number        => p_document_number,
      p_article_effective_date => p_article_effective_date,
      p_config_header_id       => p_config_header_id,
      p_config_revision_number => p_config_revision_number,
      p_valid_config_yn        => p_valid_config_yn,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
      p_object_version_number  => p_object_version_number,
      p_authoring_party_code   => p_authoring_party_code,
      p_contract_source_code   => p_contract_source_code,
      p_approval_abstract_text => p_approval_abstract_text,
      p_autogen_deviations_flag => p_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => p_source_change_allowed_flag,

      x_template_id            => l_template_id,
      x_doc_numbering_scheme   => l_doc_numbering_scheme,
      x_document_number        => l_document_number,
      x_article_effective_date => l_article_effective_date,
      x_config_header_id       => l_config_header_id,
      x_config_revision_number => l_config_revision_number,
      x_valid_config_yn        => l_valid_config_yn,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1 => l_orig_system_reference_id1,
      x_orig_system_reference_id2 => l_orig_system_reference_id2,
      x_authoring_party_code   => l_authoring_party_code,
      x_contract_source_code   => l_contract_source_code,
      x_approval_abstract_text => l_approval_abstract_text,
      x_autogen_deviations_flag => l_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 x_source_change_allowed_flag => l_source_change_allowed_flag,
	 p_lock_terms_flag => p_lock_terms_flag,
	 p_enable_reporting_flag => p_enable_reporting_flag,
	 p_contract_admin_id => p_contract_admin_id,
	 p_legal_contact_id => p_legal_contact_id,
       p_locked_by_user_id => p_locked_by_user_id,

	 x_lock_terms_flag => l_lock_terms_flag,
	 x_enable_reporting_flag => l_enable_reporting_flag,
	 x_contract_admin_id => l_contract_admin_id,
	 x_legal_contact_id => l_legal_contact_id,
       x_locked_by_user_id => l_locked_by_user_id
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7400: Record Validation');
    END IF;

    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => l_template_id,
      p_doc_numbering_scheme   => l_doc_numbering_scheme,
      p_document_number        => l_document_number,
      p_article_effective_date => l_article_effective_date,
      p_config_header_id       => l_config_header_id,
      p_config_revision_number => l_config_revision_number,
      p_valid_config_yn        => l_valid_config_yn,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1 => l_orig_system_reference_id1,
      p_orig_system_reference_id2 => l_orig_system_reference_id2,
      p_authoring_party_code   => l_authoring_party_code,
      p_contract_source_code   => l_contract_source_code,
      p_approval_abstract_text => l_approval_abstract_text,
      p_autogen_deviations_flag => l_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => l_source_change_allowed_flag,
	 p_lock_terms_flag => l_lock_terms_flag,
	 p_enable_reporting_flag => l_enable_reporting_flag,
	 p_contract_admin_id => l_contract_admin_id,
	 p_legal_contact_id => l_legal_contact_id,
     p_locked_by_user_id => l_locked_by_user_id
);
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7500: Filling WHO columns');
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
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7600: Updating Row');
    END IF;

    x_return_status := Update_Row(
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_template_id            => l_template_id,
      p_doc_numbering_scheme   => l_doc_numbering_scheme,
      p_document_number        => l_document_number,
      p_article_effective_date => l_article_effective_date,
      p_config_header_id       => l_config_header_id,
      p_config_revision_number => l_config_revision_number,
      p_valid_config_yn        => l_valid_config_yn,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1 => l_orig_system_reference_id1,
      p_orig_system_reference_id2 => l_orig_system_reference_id2,
      p_object_version_number  => l_object_version_number,
      --p_created_by             => l_created_by,
      --p_creation_date          => l_creation_date,
      p_last_updated_by        => l_last_updated_by,
      p_last_update_login      => l_last_update_login,
      p_last_update_date       => l_last_update_date,

      p_authoring_party_code   => l_authoring_party_code,
      p_contract_source_code   => l_contract_source_code,
      p_approval_abstract_text => l_approval_abstract_text,
      p_autogen_deviations_flag => l_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => l_source_change_allowed_flag,
	 p_lock_terms_flag => l_lock_terms_flag,
	 p_enable_reporting_flag => l_enable_reporting_flag,
	 p_contract_admin_id => l_contract_admin_id,
	 p_legal_contact_id => l_legal_contact_id,
       p_locked_by_user_id => l_locked_by_user_id
       );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7800: Leaving Update_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Update_Row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Update_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8100: Leaving Update_Row because of EXCEPTION: '||sqlerrm);
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
  -- Delete_Row for:OKC_TEMPLATE_USAGES --
  -------------------------------------
  FUNCTION Delete_Row(
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8200: Entered Delete_Row');
    END IF;

    DELETE FROM OKC_TEMPLATE_USAGES WHERE DOCUMENT_TYPE = p_DOCUMENT_TYPE AND DOCUMENT_ID = p_DOCUMENT_ID;

    IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN
    	  DELETE FROM OKC_XPRT_DOC_QUES_RESPONSE WHERE DOC_TYPE = p_DOCUMENT_TYPE AND DOC_ID = p_DOCUMENT_ID;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8300: Leaving Delete_Row');
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8400: Leaving Delete_Row because of EXCEPTION: '||sqlerrm);
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
  -- Delete_Row for:OKC_TEMPLATE_USAGES --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER
   , p_retain_lock_xprt_yn  IN VARCHAR2 := 'N' -- Conc Mod Changes
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'Delete_Row';

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8800: Entered Delete_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8900: Locking _B row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8910: p_retain_lock_xprt_yn : '|| p_retain_lock_xprt_yn);
    END IF;

    -- Conc Mod Changes Start
    IF   (p_retain_lock_xprt_yn = 'Y'
     AND okc_k_entity_locks_grp.isLockExists(P_ENTITY_NAME => okc_k_entity_locks_grp.G_XPRT_ENTITY,
                                             p_LOCK_BY_DOCUMENT_TYPE => p_document_type,
                                             p_LOCK_BY_DOCUMENT_ID   => p_document_id
                                             ) = 'Y')
    THEN
      -- Lock exists so do not delete data.
      NULL;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9090: Lock Exists so not delteing data');
      END IF;
    ELSE
    -- Conc Mod Changes End
          x_return_status := Lock_row(
            p_document_type          => p_document_type,
            p_document_id            => p_document_id,
            p_object_version_number  => p_object_version_number
          );
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;


          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9100: Removing _B row');
          END IF;
          x_return_status := Delete_Row( p_document_type => p_document_type,p_document_id => p_document_id );
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9300: Leaving Delete_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'9400: Leaving Delete_Row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'9500: Leaving Delete_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'9600: Leaving Delete_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Row;


  FUNCTION Create_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_version';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9700: Entered create_version');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9800: Saving Base Table');
    END IF;

    -----------------------------------------
    -- Saving Base Table
    -----------------------------------------
    INSERT INTO OKC_TEMPLATE_USAGES_H (
        major_version,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        TEMPLATE_ID,
        DOC_NUMBERING_SCHEME,
        DOCUMENT_NUMBER,
        ARTICLE_EFFECTIVE_DATE,
        CONFIG_HEADER_ID,
        CONFIG_REVISION_NUMBER,
        VALID_CONFIG_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,

        AUTHORING_PARTY_CODE,
        CONTRACT_SOURCE_CODE,
        APPROVAL_ABSTRACT_TEXT,
        AUTOGEN_DEVIATIONS_FLAG,
	   -- Fix for bug# 3990983
	   SOURCE_CHANGE_ALLOWED_FLAG,
	   	     LOCK_TERMS_FLAG,
		     ENABLE_REPORTING_FLAG,
		     CONTRACT_ADMIN_ID,
		     LEGAL_CONTACT_ID,
                 LOCKED_BY_USER_ID,
			CONTRACT_EXPERT_FINISH_FLAG)
     SELECT
        p_major_version,
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        TEMPLATE_ID,
        DOC_NUMBERING_SCHEME,
        DOCUMENT_NUMBER,
        ARTICLE_EFFECTIVE_DATE,
        CONFIG_HEADER_ID,
        CONFIG_REVISION_NUMBER,
        VALID_CONFIG_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,

        AUTHORING_PARTY_CODE,
        CONTRACT_SOURCE_CODE,
        APPROVAL_ABSTRACT_TEXT,
        AUTOGEN_DEVIATIONS_FLAG,
	   -- Fix for bug# 3990983
	   SOURCE_CHANGE_ALLOWED_FLAG,
	   LOCK_TERMS_FLAG,
	   ENABLE_REPORTING_FLAG,
	   CONTRACT_ADMIN_ID,
	   LEGAL_CONTACT_ID,
         LOCKED_BY_USER_ID,
	   CONTRACT_EXPERT_FINISH_FLAG
     FROM OKC_TEMPLATE_USAGES
      WHERE document_type = p_doc_type and document_id = p_doc_id;

	--If contract expert uses new okc rules engine, then save responses also into history table.
	IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine
		OKC_XPRT_RULES_ENGINE_PVT.create_xprt_responses_version(p_doc_id, p_doc_type, p_major_version); -- stores responses into history table
	END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10000: Leaving create_version');
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'10100: Leaving create_version because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END create_version;


  FUNCTION Restore_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'restore_version';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10200: Entered restore_version');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10300: Restoring Base Table');
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    INSERT INTO OKC_TEMPLATE_USAGES (
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        TEMPLATE_ID,
        DOC_NUMBERING_SCHEME,
        DOCUMENT_NUMBER,
        ARTICLE_EFFECTIVE_DATE,
        CONFIG_HEADER_ID,
        CONFIG_REVISION_NUMBER,
        VALID_CONFIG_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,

        AUTHORING_PARTY_CODE,
        CONTRACT_SOURCE_CODE,
        APPROVAL_ABSTRACT_TEXT,
        AUTOGEN_DEVIATIONS_FLAG,
	   -- Fix for bug# 3990983
	   SOURCE_CHANGE_ALLOWED_FLAG,
	   LOCK_TERMS_FLAG,
	   ENABLE_REPORTING_FLAG,
	   CONTRACT_ADMIN_ID,
	   LEGAL_CONTACT_ID,
       LOCKED_BY_USER_ID,
	   CONTRACT_EXPERT_FINISH_FLAG)
    SELECT
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        TEMPLATE_ID,
        DOC_NUMBERING_SCHEME,
        DOCUMENT_NUMBER,
        ARTICLE_EFFECTIVE_DATE,
        CONFIG_HEADER_ID,
        CONFIG_REVISION_NUMBER,
        VALID_CONFIG_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,

        AUTHORING_PARTY_CODE,
        CONTRACT_SOURCE_CODE,
        APPROVAL_ABSTRACT_TEXT,
        AUTOGEN_DEVIATIONS_FLAG,
	   -- Fix for bug# 3990983
	   SOURCE_CHANGE_ALLOWED_FLAG,
	   LOCK_TERMS_FLAG,
	   ENABLE_REPORTING_FLAG,
	   CONTRACT_ADMIN_ID,
	   LEGAL_CONTACT_ID,
       LOCKED_BY_USER_ID,
	   CONTRACT_EXPERT_FINISH_FLAG
     FROM  OKC_TEMPLATE_USAGES_H
      WHERE document_type = p_doc_type and document_id = p_doc_id AND major_version = p_major_version;

	--If contract expert uses new okc rules engine, then copy resposnes from  history table to base table.
	IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine
		OKC_XPRT_RULES_ENGINE_PVT.restore_xprt_responses_version(p_doc_id, p_doc_type, p_major_version); -- copying responses from  history table
	END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'10500: Leaving restore_version');
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'10600: Leaving restore_version because of EXCEPTION: '||sqlerrm);
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
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_version';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7200: Entered Delete_Version');
    END IF;

    -----------------------------------------
    -- Restoring Base Table
    -----------------------------------------
    DELETE
      FROM OKC_TEMPLATE_USAGES_H
      WHERE document_type = p_doc_type
      AND document_id = p_doc_id
      AND major_version = p_major_version;

	--If contract expert uses new okc rules engine, then delete resposnes from history table.
	IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine
		OKC_XPRT_RULES_ENGINE_PVT.delete_xprt_responses_version(p_doc_id, p_doc_type, p_major_version); -- deleting responses from  history table
	END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7300: Leaving Delete_Version');
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7400: Leaving Delete_Version because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Delete_Version;


PROCEDURE Update_Template_Id(
            x_return_status         OUT NOCOPY VARCHAR2,
            p_old_template_id       IN NUMBER,
            p_new_template_id       IN NUMBER
    ) IS
      l_api_name CONSTANT VARCHAR2(30) := 'Update_Template_Id';
      E_Resource_Busy               EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr IS
        SELECT template_id
         FROM OKC_ALLOWED_TMPL_USAGES
         WHERE TEMPLATE_ID = p_old_template_id
         FOR UPDATE OF template_id NOWAIT;
     BEGIN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1100: Entered Update_Template_Id');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1200: Locking the Set');
      END IF;
      --------------------------------------------
      -- making OPEN/CLOSE cursor to lock records
      OPEN lock_csr;
      CLOSE lock_csr;
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1300: Updating the Set');
      END IF;
      UPDATE okc_allowed_tmpl_usages
       SET template_id = p_new_template_id ,
           OBJECT_VERSION_NUMBER   = OBJECT_VERSION_NUMBER+1,
           LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID,
           LAST_UPDATE_DATE        = Sysdate
       WHERE template_id= p_old_template_id;
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: Leaving Update_Template_Id');
      END IF;
     EXCEPTION
      WHEN E_Resource_Busy THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1500: Leaving Update_Template_Id: E_Resource_Busy Exception');
        END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
        x_return_status := G_RET_STS_ERROR ;
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1600: Leaving Update_Template_Id because of EXCEPTION: '||sqlerrm);
        END IF;

        x_return_status := G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
        END IF;
    END Update_Template_Id;

  --

    PROCEDURE Delete_Set(
            x_return_status         OUT NOCOPY VARCHAR2,
            p_template_id           IN NUMBER
    ) IS
      l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Set';
      E_Resource_Busy               EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr IS
        SELECT rowid
         FROM OKC_ALLOWED_TMPL_USAGES
         WHERE TEMPLATE_ID = p_template_id
         FOR UPDATE NOWAIT;
     BEGIN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Delete_Set');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Locking the Set');
      END IF;
      --------------------------------------------
      -- making OPEN/CLOSE cursor to lock records
      OPEN lock_csr;
      CLOSE lock_csr;
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Deleting the Set');
      END IF;
      DELETE
        FROM OKC_ALLOWED_TMPL_USAGES
        WHERE TEMPLATE_ID = p_template_id;
      --------------------------------------------
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: Leaving Delete_Set');
      END IF;
     EXCEPTION
      WHEN E_Resource_Busy THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Delete_Set:E_Resource_Busy Exception');
        END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
        x_return_status := G_RET_STS_ERROR ;
      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Delete_Set because of EXCEPTION: '||sqlerrm);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR ;
    END Delete_Set;
END OKC_TEMPLATE_USAGES_PVT;

/

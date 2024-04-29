--------------------------------------------------------
--  DDL for Package Body OKC_CONTRACT_DOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONTRACT_DOCS_PVT" AS
/* $Header: OKCVCONTRACTDOCB.pls 120.1 2006/02/21 16:16:30 vamuru noship $ */





    ---------------------------------------------------------------------------
    -- GLOBAL MESSAGE CONSTANTS
    ---------------------------------------------------------------------------
    G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
    G_UNABLE_TO_RESERVE_REC      CONSTANT VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
    G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
    G_NEW_RECORD_DELETED         CONSTANT VARCHAR2(200) := 'OKC_LOCK_RECORD_DELETED';
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
    G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_CONTRACT_DOCS_PVT';
    G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsql.'||G_PKG_NAME||'.';
    G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
    G_ENTITY_NAME                CONSTANT   VARCHAR2(200) := 'Contract Document';


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
  -- FUNCTION get_rec for: OKC_CONTRACT_DOCS
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,

    x_external_visibility_flag  OUT NOCOPY VARCHAR2,
    x_effective_from_type       OUT NOCOPY VARCHAR2,
    x_effective_from_id         OUT NOCOPY NUMBER,
    x_effective_from_version    OUT NOCOPY NUMBER,
    x_include_for_approval_flag OUT NOCOPY VARCHAR2,
    x_program_id                OUT NOCOPY NUMBER,
    x_program_application_id    OUT NOCOPY NUMBER,
    x_request_id                OUT NOCOPY NUMBER,
    x_program_update_date       OUT NOCOPY DATE,
    x_parent_attached_doc_id    OUT NOCOPY NUMBER,
    x_delete_flag               OUT NOCOPY VARCHAR2,
    x_generated_flag            OUT NOCOPY VARCHAR2,
    x_object_version_number     OUT NOCOPY NUMBER,
    x_created_by                OUT NOCOPY NUMBER,
    x_creation_date             OUT NOCOPY DATE,
    x_last_updated_by           OUT NOCOPY NUMBER,
    x_last_update_login         OUT NOCOPY NUMBER,
    x_last_update_date          OUT NOCOPY DATE,

    x_primary_contract_doc_flag OUT NOCOPY VARCHAR2,
    x_mergeable_doc_flag        OUT NOCOPY VARCHAR2

  ) RETURN VARCHAR2 IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'get_rec';
    CURSOR OKC_CONTRACT_DOCS_pk_csr (cp_business_document_type IN VARCHAR2,cp_business_document_id IN NUMBER,cp_business_document_version IN NUMBER,cp_attached_document_id IN NUMBER) IS
    SELECT
            EXTERNAL_VISIBILITY_FLAG,
            EFFECTIVE_FROM_TYPE,
            EFFECTIVE_FROM_ID,
            EFFECTIVE_FROM_VERSION,
            INCLUDE_FOR_APPROVAL_FLAG,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
            PARENT_ATTACHED_DOC_ID,
            DELETE_FLAG,
            GENERATED_FLAG,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            PRIMARY_CONTRACT_DOC_FLAG,
      MERGEABLE_DOC_FLAG
      FROM OKC_CONTRACT_DOCS t
     WHERE t.BUSINESS_DOCUMENT_TYPE = cp_business_document_type and
           t.BUSINESS_DOCUMENT_ID = cp_business_document_id and
           t.BUSINESS_DOCUMENT_VERSION = cp_business_document_version and
           t.ATTACHED_DOCUMENT_ID = cp_attached_document_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: Entered get_rec');
    END IF;

    -- Get current database values
    OPEN OKC_CONTRACT_DOCS_pk_csr (p_business_document_type, p_business_document_id, p_business_document_version, p_attached_document_id);
    FETCH OKC_CONTRACT_DOCS_pk_csr INTO
            x_external_visibility_flag,
            x_effective_from_type,
            x_effective_from_id,
            x_effective_from_version,
            x_include_for_approval_flag,
            x_program_id,
            x_program_application_id,
            x_request_id,
            x_program_update_date,
            x_parent_attached_doc_id,
            x_delete_flag,
            x_generated_flag,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,
            x_primary_contract_doc_flag,
      x_mergeable_doc_flag ;
    IF OKC_CONTRACT_DOCS_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_CONTRACT_DOCS_pk_csr;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: Leaving  get_rec ');
   END IF;

    RETURN G_RET_STS_SUCCESS ;

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving get_rec because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF OKC_CONTRACT_DOCS_pk_csr%ISOPEN THEN
        CLOSE OKC_CONTRACT_DOCS_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_CONTRACT_DOCS --
  -----------------------------------------
  FUNCTION Set_Attributes(
    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2,
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_delete_flag               IN VARCHAR2,
    p_generated_flag            IN VARCHAR2,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2,

    x_external_visibility_flag  OUT NOCOPY VARCHAR2,
    x_effective_from_type       OUT NOCOPY VARCHAR2,
    x_effective_from_id         OUT NOCOPY NUMBER,
    x_effective_from_version    OUT NOCOPY NUMBER,
    x_include_for_approval_flag OUT NOCOPY VARCHAR2,
    x_program_id                OUT NOCOPY NUMBER,
    x_program_application_id    OUT NOCOPY NUMBER,
    x_request_id                OUT NOCOPY NUMBER,
    x_program_update_date       OUT NOCOPY DATE,
    x_parent_attached_doc_id    OUT NOCOPY NUMBER,
    x_delete_flag               OUT NOCOPY VARCHAR2,
    x_generated_flag            OUT NOCOPY VARCHAR2,
    x_primary_contract_doc_flag OUT NOCOPY VARCHAR2,
    x_mergeable_doc_flag        OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'set_attributes';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number     OKC_CONTRACT_DOCS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                OKC_CONTRACT_DOCS.CREATED_BY%TYPE;
    l_creation_date             OKC_CONTRACT_DOCS.CREATION_DATE%TYPE;
    l_last_updated_by           OKC_CONTRACT_DOCS.LAST_UPDATED_BY%TYPE;
    l_last_update_login         OKC_CONTRACT_DOCS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date          OKC_CONTRACT_DOCS.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Entered Set_Attributes ');
    END IF;

    IF( p_business_document_type IS NOT NULL AND p_business_document_id IS NOT NULL AND p_business_document_version IS NOT NULL AND p_attached_document_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_business_document_type    => p_business_document_type,
        p_business_document_id      => p_business_document_id,
        p_business_document_version => p_business_document_version,
        p_attached_document_id      => p_attached_document_id,
        x_external_visibility_flag  => x_external_visibility_flag,
        x_effective_from_type       => x_effective_from_type,
        x_effective_from_id         => x_effective_from_id,
        x_effective_from_version    => x_effective_from_version,
        x_include_for_approval_flag => x_include_for_approval_flag,
        x_program_id                => x_program_id,
        x_program_application_id    => x_program_application_id,
        x_request_id                => x_request_id,
        x_program_update_date       => x_program_update_date,
        x_parent_attached_doc_id    => x_parent_attached_doc_id,
        x_delete_flag               => x_delete_flag,
        x_generated_flag            => x_generated_flag,
        x_object_version_number     => l_object_version_number,
        x_created_by                => l_created_by,
        x_creation_date             => l_creation_date,
        x_last_updated_by           => l_last_updated_by,
        x_last_update_login         => l_last_update_login,
        x_last_update_date          => l_last_update_date,
        x_primary_contract_doc_flag => x_primary_contract_doc_flag,
        x_mergeable_doc_flag        => x_mergeable_doc_flag
      );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_external_visibility_flag = G_MISS_CHAR) THEN
        x_external_visibility_flag := NULL;
       ELSIF (p_external_visibility_flag IS NOT NULL) THEN
        x_external_visibility_flag := p_external_visibility_flag;
      END IF;

      IF (p_effective_from_type = G_MISS_CHAR) THEN
        x_effective_from_type := NULL;
       ELSIF (p_effective_from_type IS NOT NULL) THEN
        x_effective_from_type := p_effective_from_type;
      END IF;

      IF (p_effective_from_id = G_MISS_NUM) THEN
        x_effective_from_id := NULL;
       ELSIF (p_effective_from_id IS NOT NULL) THEN
        x_effective_from_id := p_effective_from_id;
      END IF;

      IF (p_effective_from_version = G_MISS_NUM) THEN
        x_effective_from_version := NULL;
       ELSIF (p_effective_from_version IS NOT NULL) THEN
        x_effective_from_version := p_effective_from_version;
      END IF;

      IF (p_include_for_approval_flag = G_MISS_CHAR) THEN
        x_include_for_approval_flag := NULL;
       ELSIF (p_include_for_approval_flag IS NOT NULL) THEN
        x_include_for_approval_flag := p_include_for_approval_flag;
      END IF;

      IF (p_program_id = G_MISS_NUM) THEN
        x_program_id := NULL;
       ELSIF (p_program_id IS NOT NULL) THEN
        x_program_id := p_program_id;
      END IF;

      IF (p_program_application_id = G_MISS_NUM) THEN
        x_program_application_id := NULL;
       ELSIF (p_program_application_id IS NOT NULL) THEN
        x_program_application_id := p_program_application_id;
      END IF;

      IF (p_request_id = G_MISS_NUM) THEN
        x_request_id := NULL;
       ELSIF (p_request_id IS NOT NULL) THEN
        x_request_id := p_request_id;
      END IF;

      IF (p_program_update_date = G_MISS_DATE) THEN
        x_program_update_date := NULL;
       ELSIF (p_program_update_date IS NOT NULL) THEN
        x_program_update_date := p_program_update_date;
      END IF;

      IF (p_parent_attached_doc_id = G_MISS_NUM) THEN
        x_parent_attached_doc_id := NULL;
       ELSIF (p_parent_attached_doc_id IS NOT NULL) THEN
        x_parent_attached_doc_id := p_parent_attached_doc_id;
      END IF;

      IF (p_delete_flag = G_MISS_CHAR) THEN
        x_delete_flag := NULL;
       ELSIF (p_delete_flag IS NOT NULL) THEN
        x_delete_flag := p_delete_flag;
      END IF;

      IF (p_generated_flag = G_MISS_CHAR) THEN
        x_generated_flag := NULL;
       ELSIF (p_generated_flag IS NOT NULL) THEN
        x_generated_flag := p_generated_flag;
      END IF;


      IF (p_object_version_number IS NULL) THEN
        p_object_version_number := l_object_version_number;
      END IF;


      IF (p_primary_contract_doc_flag = G_MISS_CHAR) THEN
        x_primary_contract_doc_flag := NULL;
       ELSIF (p_primary_contract_doc_flag IS NOT NULL) THEN
        x_primary_contract_doc_flag := p_primary_contract_doc_flag;
      END IF;

      IF (p_mergeable_doc_flag = G_MISS_CHAR) THEN
        x_mergeable_doc_flag := NULL;
       ELSIF (p_mergeable_doc_flag IS NOT NULL) THEN
        x_mergeable_doc_flag := p_mergeable_doc_flag;
      END IF;

    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800: Leaving  Set_Attributes ');
    END IF;

    RETURN G_RET_STS_SUCCESS ;
   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving Set_Attributes:FND_API.G_EXC_ERROR Exception');
      END IF;
      RETURN G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving Set_Attributes:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      RETURN G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving Set_Attributes because of EXCEPTION: '||sqlerrm);
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
  -- Validate_Attributes for: OKC_CONTRACT_DOCS --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2,
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_delete_flag               IN VARCHAR2,
    p_generated_flag            IN VARCHAR2,

    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'validate_attributes';
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1200: Entered Validate_Attributes');
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1300: required values validation');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute BUSINESS_DOCUMENT_TYPE ');
      END IF;
      IF ( p_business_document_type IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute BUSINESS_DOCUMENT_TYPE is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'BUSINESS_DOCUMENT_TYPE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute BUSINESS_DOCUMENT_ID ');
      END IF;
      IF ( p_business_document_id IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute BUSINESS_DOCUMENT_ID is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'BUSINESS_DOCUMENT_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute BUSINESS_DOCUMENT_VERSION ');
      END IF;
      IF ( p_business_document_version IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute BUSINESS_DOCUMENT_VERSION is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'BUSINESS_DOCUMENT_VERSION');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute ATTACHED_DOCUMENT_ID ');
      END IF;
      IF ( p_attached_document_id IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute ATTACHED_DOCUMENT_ID is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ATTACHED_DOCUMENT_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute EXTERNAL_VISIBILITY_FLAG ');
      END IF;
      IF ( p_external_visibility_flag IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute EXTERNAL_VISIBILITY_FLAG is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'EXTERNAL_VISIBILITY_FLAG');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute EFFECTIVE_FROM_TYPE ');
      END IF;
      IF ( p_effective_from_type IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute EFFECTIVE_FROM_TYPE is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'EFFECTIVE_FROM_TYPE');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute EFFECTIVE_FROM_ID ');
      END IF;
      IF ( p_effective_from_id IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute EFFECTIVE_FROM_ID is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'EFFECTIVE_FROM_ID');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute EFFECTIVE_FROM_VERSION ');
      END IF;
      IF ( p_effective_from_version IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute EFFECTIVE_FROM_VERSION is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'EFFECTIVE_FROM_VERSION');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute INCLUDE_FOR_APPROVAL_FLAG ');
      END IF;
      IF ( p_include_for_approval_flag IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute INCLUDE_FOR_APPROVAL_FLAG is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'INCLUDE_FOR_APPROVAL_FLAG');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: static values and range validation');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1700: - attribute PRIMARY_CONTRACT_DOC_FLAG ');
      END IF;
      IF ( p_primary_contract_doc_flag NOT IN ('Y','N') AND p_primary_contract_doc_flag IS NOT NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: - attribute PRIMARY_CONTRACT_DOC_FLAG is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'PRIMARY_CONTRACT_DOC_FLAG');
        l_return_status := G_RET_STS_ERROR;
      END IF;

      IF ( p_mergeable_doc_flag NOT IN ('Y','N') AND p_mergeable_doc_flag IS NOT NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: - attribute mergeable_doc_flag is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'mergeable_doc_flag');
        l_return_status := G_RET_STS_ERROR;
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: lookup codes validation');
      END IF;

    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2100: foreigh keys validation ');
      END IF;

    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2400: Leaving Validate_Attributes ');
    END IF;

    RETURN l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2500: Leaving Validate_Attributes because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);


      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_CONTRACT_DOCS --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2,
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_delete_flag               IN VARCHAR2,
    p_generated_flag            IN VARCHAR2,

    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'validate_record';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2600: Entered Validate_Record');
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_external_visibility_flag  => p_external_visibility_flag,
      p_effective_from_type       => p_effective_from_type,
      p_effective_from_id         => p_effective_from_id,
      p_effective_from_version    => p_effective_from_version,
      p_include_for_approval_flag => p_include_for_approval_flag,
      p_program_id                => p_program_id,
      p_program_application_id    => p_program_application_id,
      p_request_id                => p_request_id,
      p_program_update_date       => p_program_update_date,
      p_parent_attached_doc_id    => p_parent_attached_doc_id,
      p_delete_flag               => p_delete_flag,
      p_generated_flag            => p_generated_flag,
      p_primary_contract_doc_flag => p_primary_contract_doc_flag,
      p_mergeable_doc_flag        => p_mergeable_doc_flag
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
  -- validate_row for:OKC_CONTRACT_DOCS --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2,
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_delete_flag               IN VARCHAR2,
    p_generated_flag            IN VARCHAR2,

    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2,

    p_object_version_number     IN NUMBER
  ) IS
      l_api_name                    CONSTANT VARCHAR2(30) := 'validate_row';
      l_external_visibility_flag  OKC_CONTRACT_DOCS.EXTERNAL_VISIBILITY_FLAG%TYPE;
      l_effective_from_type       OKC_CONTRACT_DOCS.EFFECTIVE_FROM_TYPE%TYPE;
      l_effective_from_id         OKC_CONTRACT_DOCS.EFFECTIVE_FROM_ID%TYPE;
      l_effective_from_version    OKC_CONTRACT_DOCS.EFFECTIVE_FROM_VERSION%TYPE;
      l_include_for_approval_flag OKC_CONTRACT_DOCS.INCLUDE_FOR_APPROVAL_FLAG%TYPE;
      l_program_id                OKC_CONTRACT_DOCS.PROGRAM_ID%TYPE;
      l_program_application_id    OKC_CONTRACT_DOCS.PROGRAM_APPLICATION_ID%TYPE;
      l_request_id                OKC_CONTRACT_DOCS.REQUEST_ID%TYPE;
      l_program_update_date       OKC_CONTRACT_DOCS.PROGRAM_UPDATE_DATE%TYPE;
      l_parent_attached_doc_id    OKC_CONTRACT_DOCS.PARENT_ATTACHED_DOC_ID%TYPE;
      l_delete_flag               OKC_CONTRACT_DOCS.DELETE_FLAG%TYPE;
      l_generated_flag            OKC_CONTRACT_DOCS.GENERATED_FLAG%TYPE;
      l_object_version_number     OKC_CONTRACT_DOCS.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by                OKC_CONTRACT_DOCS.CREATED_BY%TYPE;
      l_creation_date             OKC_CONTRACT_DOCS.CREATION_DATE%TYPE;
      l_last_updated_by           OKC_CONTRACT_DOCS.LAST_UPDATED_BY%TYPE;
      l_last_update_login         OKC_CONTRACT_DOCS.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date          OKC_CONTRACT_DOCS.LAST_UPDATE_DATE%TYPE;
      l_primary_contract_doc_flag OKC_CONTRACT_DOCS.PRIMARY_CONTRACT_DOC_FLAG%TYPE;
      l_mergeable_doc_flag        OKC_CONTRACT_DOCS.MERGEABLE_DOC_FLAG%TYPE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3100: Entered validate_row');
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_external_visibility_flag  => p_external_visibility_flag,
      p_effective_from_type       => p_effective_from_type,
      p_effective_from_id         => p_effective_from_id,
      p_effective_from_version    => p_effective_from_version,
      p_include_for_approval_flag => p_include_for_approval_flag,
      p_program_id                => p_program_id,
      p_program_application_id    => p_program_application_id,
      p_request_id                => p_request_id,
      p_program_update_date       => p_program_update_date,
      p_parent_attached_doc_id    => p_parent_attached_doc_id,
      p_delete_flag               => p_delete_flag,
      p_generated_flag            => p_generated_flag,
      p_object_version_number     => l_object_version_number,
      p_primary_contract_doc_flag => p_primary_contract_doc_flag,
      p_mergeable_doc_flag        => p_mergeable_doc_flag  ,

      x_external_visibility_flag  => l_external_visibility_flag,
      x_effective_from_type       => l_effective_from_type,
      x_effective_from_id         => l_effective_from_id,
      x_effective_from_version    => l_effective_from_version,
      x_include_for_approval_flag => l_include_for_approval_flag,
      x_program_id                => l_program_id,
      x_program_application_id    => l_program_application_id,
      x_request_id                => l_request_id,
      x_program_update_date       => l_program_update_date,
      x_parent_attached_doc_id    => l_parent_attached_doc_id,
      x_delete_flag               => l_delete_flag,
      x_generated_flag            => l_generated_flag,
      x_primary_contract_doc_flag => l_primary_contract_doc_flag,
      x_mergeable_doc_flag        => l_mergeable_doc_flag
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
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_external_visibility_flag  => l_external_visibility_flag,
      p_effective_from_type       => l_effective_from_type,
      p_effective_from_id         => l_effective_from_id,
      p_effective_from_version    => l_effective_from_version,
      p_include_for_approval_flag => l_include_for_approval_flag,
      p_program_id                => l_program_id,
      p_program_application_id    => l_program_application_id,
      p_request_id                => l_request_id,
      p_program_update_date       => l_program_update_date,
      p_parent_attached_doc_id    => l_parent_attached_doc_id,
      p_delete_flag               => l_delete_flag,
      p_generated_flag            => l_generated_flag,
      p_primary_contract_doc_flag => l_primary_contract_doc_flag,
      p_mergeable_doc_flag        => l_mergeable_doc_flag
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
  -- Insert_Row for:OKC_CONTRACT_DOCS --
  -------------------------------------
  FUNCTION Insert_Row(
    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2,
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_delete_flag               IN VARCHAR2,
    p_generated_flag            IN VARCHAR2,
    p_object_version_number     IN NUMBER,
    p_created_by                IN NUMBER,
    p_creation_date             IN DATE,
    p_last_updated_by           IN NUMBER,
    p_last_update_login         IN NUMBER,
    p_last_update_date          IN DATE,

    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3600: Entered Insert_Row function');
    END IF;

    INSERT INTO OKC_CONTRACT_DOCS(
        BUSINESS_DOCUMENT_TYPE,
        BUSINESS_DOCUMENT_ID,
        BUSINESS_DOCUMENT_VERSION,
        ATTACHED_DOCUMENT_ID,
        EXTERNAL_VISIBILITY_FLAG,
        EFFECTIVE_FROM_TYPE,
        EFFECTIVE_FROM_ID,
        EFFECTIVE_FROM_VERSION,
        INCLUDE_FOR_APPROVAL_FLAG,
        PROGRAM_ID,
        PROGRAM_APPLICATION_ID,
        REQUEST_ID,
        PROGRAM_UPDATE_DATE,
        PARENT_ATTACHED_DOC_ID,
        DELETE_FLAG,
        GENERATED_FLAG,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        PRIMARY_CONTRACT_DOC_FLAG,
  MERGEABLE_DOC_FLAG  )
      VALUES (
        p_business_document_type,
        p_business_document_id,
        p_business_document_version,
        p_attached_document_id,
        p_external_visibility_flag,
        p_effective_from_type,
        p_effective_from_id,
        p_effective_from_version,
        p_include_for_approval_flag,
        p_program_id,
        p_program_application_id,
        p_request_id,
        p_program_update_date,
        p_parent_attached_doc_id,
        p_delete_flag,
        p_generated_flag,
        p_object_version_number,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date,
        p_primary_contract_doc_flag,
  p_mergeable_doc_flag  );

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
  -- Insert_Row for:OKC_CONTRACT_DOCS --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2,
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_delete_flag               IN VARCHAR2,
    p_generated_flag            IN VARCHAR2,

    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2,

    x_business_document_type    OUT NOCOPY VARCHAR2,
    x_business_document_id      OUT NOCOPY NUMBER,
    x_business_document_version OUT NOCOPY NUMBER,
    x_attached_document_id      OUT NOCOPY NUMBER

  ) IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'insert_row';
    l_object_version_number     OKC_CONTRACT_DOCS.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by                OKC_CONTRACT_DOCS.CREATED_BY%TYPE;
    l_creation_date             OKC_CONTRACT_DOCS.CREATION_DATE%TYPE;
    l_last_updated_by           OKC_CONTRACT_DOCS.LAST_UPDATED_BY%TYPE;
    l_last_update_login         OKC_CONTRACT_DOCS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date          OKC_CONTRACT_DOCS.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4200: Entered Insert_Row');
    END IF;

      x_business_document_type := p_business_document_type;
      x_business_document_id := p_business_document_id;
      x_business_document_version := p_business_document_version;
      x_attached_document_id := p_attached_document_id;
    l_object_version_number     := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;


    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_business_document_type    => x_business_document_type,
      p_business_document_id      => x_business_document_id,
      p_business_document_version => x_business_document_version,
      p_attached_document_id      => x_attached_document_id,
      p_external_visibility_flag  => p_external_visibility_flag,
      p_effective_from_type       => p_effective_from_type,
      p_effective_from_id         => p_effective_from_id,
      p_effective_from_version    => p_effective_from_version,
      p_include_for_approval_flag => p_include_for_approval_flag,
      p_program_id                => p_program_id,
      p_program_application_id    => p_program_application_id,
      p_request_id                => p_request_id,
      p_program_update_date       => p_program_update_date,
      p_parent_attached_doc_id    => p_parent_attached_doc_id,
      p_delete_flag               => p_delete_flag,
      p_generated_flag            => p_generated_flag,
      p_primary_contract_doc_flag => p_primary_contract_doc_flag,
      p_mergeable_doc_flag        => p_mergeable_doc_flag
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
      p_business_document_type    => x_business_document_type,
      p_business_document_id      => x_business_document_id,
      p_business_document_version => x_business_document_version,
      p_attached_document_id      => x_attached_document_id,
      p_external_visibility_flag  => p_external_visibility_flag,
      p_effective_from_type       => p_effective_from_type,
      p_effective_from_id         => p_effective_from_id,
      p_effective_from_version    => p_effective_from_version,
      p_include_for_approval_flag => p_include_for_approval_flag,
      p_program_id                => p_program_id,
      p_program_application_id    => p_program_application_id,
      p_request_id                => p_request_id,
      p_program_update_date       => p_program_update_date,
      p_parent_attached_doc_id    => p_parent_attached_doc_id,
      p_delete_flag               => p_delete_flag,
      p_generated_flag            => p_generated_flag,
      p_object_version_number     => l_object_version_number,
      p_created_by                => l_created_by,
      p_creation_date             => l_creation_date,
      p_last_updated_by           => l_last_updated_by,
      p_last_update_login         => l_last_update_login,
      p_last_update_date          => l_last_update_date,
      p_primary_contract_doc_flag => p_primary_contract_doc_flag,
      p_mergeable_doc_flag        => p_mergeable_doc_flag
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
  -- Lock_Row for:OKC_CONTRACT_DOCS --
  -----------------------------------
  FUNCTION Lock_Row(
    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_object_version_number     IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status                VARCHAR2(1);
    l_object_version_number       OKC_CONTRACT_DOCS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    l_pk_string                    VARCHAR2(240);

    CURSOR lock_csr (cp_business_document_type VARCHAR2, cp_business_document_id NUMBER, cp_business_document_version NUMBER, cp_attached_document_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_CONTRACT_DOCS
     WHERE BUSINESS_DOCUMENT_TYPE = cp_business_document_type AND BUSINESS_DOCUMENT_ID = cp_business_document_id AND BUSINESS_DOCUMENT_VERSION = cp_business_document_version AND ATTACHED_DOCUMENT_ID = cp_attached_document_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_business_document_type VARCHAR2, cp_business_document_id NUMBER, cp_business_document_version NUMBER, cp_attached_document_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_CONTRACT_DOCS
     WHERE BUSINESS_DOCUMENT_TYPE = cp_business_document_type AND BUSINESS_DOCUMENT_ID = cp_business_document_id AND BUSINESS_DOCUMENT_VERSION = cp_business_document_version AND ATTACHED_DOCUMENT_ID = cp_attached_document_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4900: Entered Lock_Row');
    END IF;


    BEGIN

      OPEN lock_csr( p_business_document_type, p_business_document_id, p_business_document_version, p_attached_document_id, p_object_version_number );
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

      OPEN lchk_csr(p_business_document_type, p_business_document_id, p_business_document_version, p_attached_document_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        l_pk_string := p_business_document_type || ':' || p_business_document_id || ':' || p_business_document_version || ':' || p_attached_document_id;
                      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_NEW_RECORD_DELETED,
                                      p_token1       => 'ENTITYNAME',
                                      p_token1_value => G_ENTITY_NAME,
                                      p_token2       => 'PKEY',
                                      p_token2_value => l_pk_string,
                                      p_token3       => 'OVN',
                        p_token3_value => l_object_version_number);
        -- Okc_Api.Set_Message(G_FND_APP,G_RECORD_DELETED);

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
  -- Lock_Row for:OKC_CONTRACT_DOCS --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_object_version_number     IN NUMBER
   ) IS
     l_api_name                    CONSTANT VARCHAR2(30) := 'lock_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5700: Entered Lock_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'5800: Locking Row for Base Table');
    END IF;

    --------------------------------------------
    -- Call the LOCK_ROW for each _B child record
    --------------------------------------------
    x_return_status := Lock_Row(
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_object_version_number     => p_object_version_number
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
  -- Update_Row for:OKC_CONTRACT_DOCS --
  -------------------------------------
  FUNCTION Update_Row(
    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_external_visibility_flag  IN VARCHAR2,
    p_effective_from_type       IN VARCHAR2,
    p_effective_from_id         IN NUMBER,
    p_effective_from_version    IN NUMBER,
    p_include_for_approval_flag IN VARCHAR2,
    p_program_id                IN NUMBER,
    p_program_application_id    IN NUMBER,
    p_request_id                IN NUMBER,
    p_program_update_date       IN DATE,
    p_parent_attached_doc_id    IN NUMBER,
    p_delete_flag               IN VARCHAR2,
    p_generated_flag            IN VARCHAR2,
    p_object_version_number     IN NUMBER,
    p_last_updated_by           IN NUMBER,
    p_last_update_login         IN NUMBER,
    p_last_update_date          IN DATE,

    p_primary_contract_doc_flag IN VARCHAR2,
    p_mergeable_doc_flag        IN VARCHAR2
   ) RETURN VARCHAR2 IS
     l_api_name                    CONSTANT VARCHAR2(30) := 'update_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6400: Entered Update_Row');
    END IF;

    UPDATE OKC_CONTRACT_DOCS
     SET EXTERNAL_VISIBILITY_FLAG  = p_external_visibility_flag,
         EFFECTIVE_FROM_TYPE       = p_effective_from_type,
         EFFECTIVE_FROM_ID         = p_effective_from_id,
         EFFECTIVE_FROM_VERSION    = p_effective_from_version,
         INCLUDE_FOR_APPROVAL_FLAG = p_include_for_approval_flag,
         PROGRAM_ID                = p_program_id,
         PROGRAM_APPLICATION_ID    = p_program_application_id,
         REQUEST_ID                = p_request_id,
         PROGRAM_UPDATE_DATE       = p_program_update_date,
         PARENT_ATTACHED_DOC_ID    = p_parent_attached_doc_id,
         DELETE_FLAG               = p_delete_flag,
         GENERATED_FLAG            = p_generated_flag,
         OBJECT_VERSION_NUMBER     = p_object_version_number,
         LAST_UPDATED_BY           = p_last_updated_by,
         LAST_UPDATE_LOGIN         = p_last_update_login,
         LAST_UPDATE_DATE          = p_last_update_date,
         PRIMARY_CONTRACT_DOC_FLAG = p_primary_contract_doc_flag,
   MERGEABLE_DOC_FLAG        = p_mergeable_doc_flag
    WHERE BUSINESS_DOCUMENT_TYPE    = p_business_document_type AND BUSINESS_DOCUMENT_ID      = p_business_document_id AND BUSINESS_DOCUMENT_VERSION = p_business_document_version AND ATTACHED_DOCUMENT_ID      = p_attached_document_id;

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
  -- Update_Row for:OKC_CONTRACT_DOCS --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,

    p_external_visibility_flag  IN VARCHAR2 := NULL,
    p_effective_from_type       IN VARCHAR2 := NULL,
    p_effective_from_id         IN NUMBER := NULL,
    p_effective_from_version    IN NUMBER := NULL,
    p_include_for_approval_flag IN VARCHAR2 := NULL,
    p_program_id                IN NUMBER := NULL,
    p_program_application_id    IN NUMBER := NULL,
    p_request_id                IN NUMBER := NULL,
    p_program_update_date       IN DATE := NULL,
    p_parent_attached_doc_id    IN NUMBER := NULL,
    p_delete_flag               IN VARCHAR2 := NULL,
    p_generated_flag            IN VARCHAR2 := NULL,

    p_primary_contract_doc_flag IN VARCHAR2 := NULL,
    p_mergeable_doc_flag        IN VARCHAR2 := NULL,

    p_object_version_number     IN NUMBER

   ) IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'update_row';
    l_external_visibility_flag  OKC_CONTRACT_DOCS.EXTERNAL_VISIBILITY_FLAG%TYPE;
    l_effective_from_type       OKC_CONTRACT_DOCS.EFFECTIVE_FROM_TYPE%TYPE;
    l_effective_from_id         OKC_CONTRACT_DOCS.EFFECTIVE_FROM_ID%TYPE;
    l_effective_from_version    OKC_CONTRACT_DOCS.EFFECTIVE_FROM_VERSION%TYPE;
    l_include_for_approval_flag OKC_CONTRACT_DOCS.INCLUDE_FOR_APPROVAL_FLAG%TYPE;
    l_program_id                OKC_CONTRACT_DOCS.PROGRAM_ID%TYPE;
    l_program_application_id    OKC_CONTRACT_DOCS.PROGRAM_APPLICATION_ID%TYPE;
    l_request_id                OKC_CONTRACT_DOCS.REQUEST_ID%TYPE;
    l_program_update_date       OKC_CONTRACT_DOCS.PROGRAM_UPDATE_DATE%TYPE;
    l_parent_attached_doc_id    OKC_CONTRACT_DOCS.PARENT_ATTACHED_DOC_ID%TYPE;
    l_delete_flag               OKC_CONTRACT_DOCS.DELETE_FLAG%TYPE;
    l_generated_flag            OKC_CONTRACT_DOCS.GENERATED_FLAG%TYPE;
    l_object_version_number     OKC_CONTRACT_DOCS.OBJECT_VERSION_NUMBER%TYPE;
    l_last_updated_by           OKC_CONTRACT_DOCS.LAST_UPDATED_BY%TYPE;
    l_last_update_login         OKC_CONTRACT_DOCS.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date          OKC_CONTRACT_DOCS.LAST_UPDATE_DATE%TYPE;
    l_primary_contract_doc_flag OKC_CONTRACT_DOCS.PRIMARY_CONTRACT_DOC_FLAG%TYPE;
    l_mergeable_doc_flag        OKC_CONTRACT_DOCS.MERGEABLE_DOC_FLAG%TYPE;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Entered Update_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_object_version_number     => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7300: Setting attributes');
    END IF;

    l_object_version_number     := p_object_version_number;
    x_return_status := Set_Attributes(
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_external_visibility_flag  => p_external_visibility_flag,
      p_effective_from_type       => p_effective_from_type,
      p_effective_from_id         => p_effective_from_id,
      p_effective_from_version    => p_effective_from_version,
      p_include_for_approval_flag => p_include_for_approval_flag,
      p_program_id                => p_program_id,
      p_program_application_id    => p_program_application_id,
      p_request_id                => p_request_id,
      p_program_update_date       => p_program_update_date,
      p_parent_attached_doc_id    => p_parent_attached_doc_id,
      p_delete_flag               => p_delete_flag,
      p_generated_flag            => p_generated_flag,
      p_object_version_number     => l_object_version_number,
      p_primary_contract_doc_flag => p_primary_contract_doc_flag,
      p_mergeable_doc_flag        => p_mergeable_doc_flag,

      x_external_visibility_flag  => l_external_visibility_flag,
      x_effective_from_type       => l_effective_from_type,
      x_effective_from_id         => l_effective_from_id,
      x_effective_from_version    => l_effective_from_version,
      x_include_for_approval_flag => l_include_for_approval_flag,
      x_program_id                => l_program_id,
      x_program_application_id    => l_program_application_id,
      x_request_id                => l_request_id,
      x_program_update_date       => l_program_update_date,
      x_parent_attached_doc_id    => l_parent_attached_doc_id,
      x_delete_flag               => l_delete_flag,
      x_generated_flag            => l_generated_flag,
      x_primary_contract_doc_flag => l_primary_contract_doc_flag,
      x_mergeable_doc_flag        => l_mergeable_doc_flag
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
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_external_visibility_flag  => l_external_visibility_flag,
      p_effective_from_type       => l_effective_from_type,
      p_effective_from_id         => l_effective_from_id,
      p_effective_from_version    => l_effective_from_version,
      p_include_for_approval_flag => l_include_for_approval_flag,
      p_program_id                => l_program_id,
      p_program_application_id    => l_program_application_id,
      p_request_id                => l_request_id,
      p_program_update_date       => l_program_update_date,
      p_parent_attached_doc_id    => l_parent_attached_doc_id,
      p_delete_flag               => l_delete_flag,
      p_generated_flag            => l_generated_flag,
      p_primary_contract_doc_flag => l_primary_contract_doc_flag,
      p_mergeable_doc_flag        => l_mergeable_doc_flag
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
--    IF Nvl(p_object_version_number, 0) >= 0 THEN
--      l_object_version_number := Nvl( p_object_version_number, 0) + 1;
--    END IF;
    l_object_version_number := l_object_version_number + 1; -- l_object_version_number should not be NULL because of Set_Attribute

    --------------------------------------------
    -- Call the Update_Row for each child record
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7600: Updating Row');
    END IF;

    x_return_status := Update_Row(
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_external_visibility_flag  => l_external_visibility_flag,
      p_effective_from_type       => l_effective_from_type,
      p_effective_from_id         => l_effective_from_id,
      p_effective_from_version    => l_effective_from_version,
      p_include_for_approval_flag => l_include_for_approval_flag,
      p_program_id                => l_program_id,
      p_program_application_id    => l_program_application_id,
      p_request_id                => l_request_id,
      p_program_update_date       => l_program_update_date,
      p_parent_attached_doc_id    => l_parent_attached_doc_id,
      p_delete_flag               => l_delete_flag,
      p_generated_flag            => l_generated_flag,
      p_object_version_number     => l_object_version_number,
      p_last_updated_by           => l_last_updated_by,
      p_last_update_login         => l_last_update_login,
      p_last_update_date          => l_last_update_date,
      p_primary_contract_doc_flag => l_primary_contract_doc_flag,
      p_mergeable_doc_flag        => l_mergeable_doc_flag
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
  -- Delete_Row for:OKC_CONTRACT_DOCS --
  -------------------------------------
  FUNCTION Delete_Row(
    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'delete_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8200: Entered Delete_Row');
    END IF;

    DELETE FROM OKC_CONTRACT_DOCS
      WHERE BUSINESS_DOCUMENT_TYPE = p_BUSINESS_DOCUMENT_TYPE AND BUSINESS_DOCUMENT_ID = p_BUSINESS_DOCUMENT_ID AND BUSINESS_DOCUMENT_VERSION = p_BUSINESS_DOCUMENT_VERSION AND ATTACHED_DOCUMENT_ID = p_ATTACHED_DOCUMENT_ID;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8300: Leaving Delete_Row');
    END IF;

    RETURN( G_RET_STS_SUCCESS );

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8400: Leaving Delete_Row because of EXCEPTION: '||sqlerrm);
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
  -- Delete_Row for:OKC_CONTRACT_DOCS --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,
    p_object_version_number     IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8800: Entered Delete_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8900: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_business_document_type    => p_business_document_type,
      p_business_document_id      => p_business_document_id,
      p_business_document_version => p_business_document_version,
      p_attached_document_id      => p_attached_document_id,
      p_object_version_number     => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9100: Removing _B row');
    END IF;
    x_return_status := Delete_Row( p_business_document_type => p_business_document_type,p_business_document_id => p_business_document_id,p_business_document_version => p_business_document_version,p_attached_document_id => p_attached_document_id );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
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


  --API name      : reset_bus_doc_ver_to_current
  --Type          : Private.
  --Function      : When:  This API is invoked from the Repository module.  It is called when
  --                       a contract's current version is deleted and a previous version of that contract
  --                       exists.
  --              : What:  This API updates the previous version's attachments in OKC_CONTRACT_DOCS.
  --              : This function does two things:
  --              : 1.  Updates the BUSINESS_DOCUMENT_VERSION from its current value to -99.
  --              : 2.  Updates the EFFECTIVE_FROM_VERSION to -99 for those attachments that were effective
  --              : from this current version only (not added from a previous version).
  --              : Why: This reset is required since Contract Documents (module) requires attachments of the current
  --              : version of a business document (contract) to have a BUSINESS_DOCUMENT_VERSION of -99.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_business_document_type         IN VARCHAR2       Required
  --              : p_business_document_id           IN NUMBER         Required
  --              : p_business_document_version      IN NUMBER         Required
  --OUT           : Returns G_RET_STS_SUCCESS if resetting of version  number is succeeded.
  --Note          : This API is created as part of the fix of bug 5044121
  -- End of comments

  FUNCTION reset_bus_doc_ver_to_current(
      p_business_document_type    IN VARCHAR2,
      p_business_document_id      IN NUMBER,
      p_business_document_version IN NUMBER
 ) RETURN VARCHAR2 IS
    l_api_name      VARCHAR2(35);
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'Entered OKC_CONTRACT_DOCS_PVT.reset_bus_doc_ver_to_current');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_business_document_type is: ' || p_business_document_type);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_business_document_id is: ' || to_char(p_business_document_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                'p_business_document_version is: ' || to_char(p_business_document_version));
    END IF;

    l_api_name := 'reset_bus_doc_ver_to_current';

    -- Standard Start of API savepoint
    SAVEPOINT reset_bus_doc_ver_to_current;

    -- Initialize message list
      FND_MSG_PUB.initialize;

    -- Update the effective_from_version of the documents added in that version only
    UPDATE okc_contract_docs
    SET    effective_from_version = -99
    WHERE delete_flag = 'N'
    AND   business_document_version = p_business_document_version - 1
    AND   business_document_id = p_business_document_id
    AND   business_document_type = p_business_document_type
    AND   business_document_version = effective_from_version;


    -- Update the business_document_version of all the documents of previous version
    UPDATE okc_contract_docs
    SET    business_document_version = -99
    WHERE delete_flag = 'N'
    AND   business_document_version = p_business_document_version - 1
    AND   business_document_id = p_business_document_id
    AND   business_document_type = p_business_document_type;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                      'Leaving OKC_CONTRACT_DOCS_PVT.reset_bus_doc_ver_to_current');
    END IF;

    RETURN(G_RET_STS_SUCCESS);

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'Leaving OKC_CONTRACT_DOCS_PVT.reset_bus_doc_ver_to_current because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO reset_bus_doc_ver_to_current;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );

  END reset_bus_doc_ver_to_current;



END OKC_CONTRACT_DOCS_PVT;

/

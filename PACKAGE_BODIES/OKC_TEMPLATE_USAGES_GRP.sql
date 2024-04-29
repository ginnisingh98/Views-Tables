--------------------------------------------------------
--  DDL for Package Body OKC_TEMPLATE_USAGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TEMPLATE_USAGES_GRP" AS
/* $Header: OKCGTMPLUSGB.pls 120.2.12010000.3 2012/06/14 09:14:17 nbingi ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TEMPLATE_USAGES_GRP';
  G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsq.'||G_PKG_NAME||'.';
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

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';

  ---------------------------------------
  -- PROCEDURE validate_row  --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,

    p_approval_abstract_text IN CLOB := NULL,
    p_contract_source_code   IN VARCHAR2 := 'STRUCTURED',
    p_authoring_party_code   IN VARCHAR2 := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
 --Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 := 'Y',

    p_object_version_number  IN NUMBER,
	p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id       IN NUMBER := NULL

  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_validate_row';
    l_authoring_party_code   OKC_TEMPLATE_USAGES.authoring_party_code%type;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered validate_row');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_validate_row_GRP;
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

--added for 10+ word integration and deviations report
--Set default value for p_authoring_party_code
    l_authoring_party_code := p_authoring_party_code;
    IF p_authoring_party_code is NULL THEN

	 l_authoring_party_code := G_INTERNAL_PARTY_CODE;

    END IF;

    --------------------------------------------
    -- Calling Simple API for Validation
    --------------------------------------------
    OKC_TEMPLATE_USAGES_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
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

      p_approval_abstract_text => p_approval_abstract_text,
      p_contract_source_code   => p_contract_source_code  ,
      p_authoring_party_code   => l_authoring_party_code ,
      p_autogen_deviations_flag => p_autogen_deviations_flag ,
	 --Fix for bug# 3990983
	 p_source_change_allowed_flag => p_source_change_allowed_flag,
	 p_lock_terms_flag => p_lock_terms_flag,
	 p_enable_reporting_flag => p_enable_reporting_flag,
	 p_contract_admin_id => p_contract_admin_id,
	 p_legal_contact_id => p_legal_contact_id,
      p_locked_by_user_id => p_locked_by_user_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Leaving validate_row');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'300: Leaving Validate_Row: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving Validate_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Validate_Row because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_validate_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END validate_row;

  -------------------------------------
  -- PROCEDURE create_template_usages
  -------------------------------------
  PROCEDURE create_template_usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,

    p_approval_abstract_text IN CLOB := NULL,
    p_contract_source_code   IN VARCHAR2 := 'STRUCTURED',
    p_authoring_party_code   IN VARCHAR2 := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
    -- Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 := 'Y',
    x_document_type          OUT NOCOPY VARCHAR2,
    x_document_id            OUT NOCOPY NUMBER,
	p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id       IN NUMBER := NULL,
    p_contract_expert_finish_flag IN VARCHAR2 := NULL

  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'create_template_usages';
    l_object_version_number  OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by             OKC_TEMPLATE_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_TEMPLATE_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_TEMPLATE_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_TEMPLATE_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_TEMPLATE_USAGES.LAST_UPDATE_DATE%TYPE;
    l_authoring_party_code   OKC_TEMPLATE_USAGES.authoring_party_code%type;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600: Entered create_template_usages');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_insert_row_GRP;
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
--added for 10+ word integration and deviations report
--Set default value for p_authoring_party_code

    -- Fix for bug# 4116433. l_authoring_party_code is to be initialized with the value from p_authoring_party_code
    l_authoring_party_code := p_authoring_party_code;

    IF p_authoring_party_code is NULL THEN

	 l_authoring_party_code := G_INTERNAL_PARTY_CODE;

    END IF;

    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_TEMPLATE_USAGES_PVT.Insert_Row(
      p_validation_level           =>   p_validation_level,
      x_return_status              =>   x_return_status,
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
      x_document_type          => x_document_type,
      x_document_id            => x_document_id,

      p_approval_abstract_text => p_approval_abstract_text,
      p_contract_source_code   => p_contract_source_code ,
      p_authoring_party_code   => l_authoring_party_code ,
      p_autogen_deviations_flag => p_autogen_deviations_flag,
	 --Fix for bug# 3990983
	 p_source_change_allowed_flag => p_source_change_allowed_flag,
	 p_lock_terms_flag => p_lock_terms_flag,
	 p_enable_reporting_flag => p_enable_reporting_flag,
	 p_contract_admin_id => p_contract_admin_id,
	 p_legal_contact_id => p_legal_contact_id,
     p_locked_by_user_id => p_locked_by_user_id,
	 p_contract_expert_finish_flag => p_contract_expert_finish_flag
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Leaving create_template_usages');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'800: Leaving create_template_usages: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving insert_row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving insert_row because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END create_template_usages;
  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER
   ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_lock_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1100: Entered lock_row');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_lock_row_GRP;
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

    --------------------------------------------
    -- Calling Simple API for Locking A Row
    --------------------------------------------
    OKC_TEMPLATE_USAGES_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_object_version_number  => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1200: Leaving lock_row');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1300: Leaving lock_Row: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1400: Leaving lock_Row: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1500: Leaving lock_Row because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_lock_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_template_usages
  ---------------------------------------------------------------------------
  PROCEDURE update_template_usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

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

    p_approval_abstract_text  IN CLOB := NULL,
    p_contract_source_code    IN VARCHAR2 := NULL,
    p_authoring_party_code    IN VARCHAR2 := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
    -- Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER := NULL,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id       IN NUMBER := NULL

   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_update_template_usages';

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Entered update_template_usages');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1700: Locking row');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_row_GRP;
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

    --------------------------------------------
    -- Calling Simple API for Updating A Row
    --------------------------------------------
    OKC_TEMPLATE_USAGES_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
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
      p_contract_source_code   => p_contract_source_code,
      p_authoring_party_code   => p_authoring_party_code,
      p_autogen_deviations_flag => p_autogen_deviations_flag,
	 -- Fix for bug# 3990983
	 p_source_change_allowed_flag => p_source_change_allowed_flag,
 	 p_lock_terms_flag => p_lock_terms_flag,
	 p_enable_reporting_flag => p_enable_reporting_flag,
	 p_contract_admin_id => p_contract_admin_id,
	 p_legal_contact_id => p_legal_contact_id,
     p_locked_by_user_id => p_locked_by_user_id
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Leaving update_template_usages');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1900: Leaving update_template_usages: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_update_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving update_template_usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_update_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2100: Leaving update_template_usages because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_update_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END update_template_usages;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_template_usages
  ---------------------------------------------------------------------------
  PROCEDURE delete_template_usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_delete_template_usages';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: Entered delete_template_usages');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_delete_row_GRP;
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

    --------------------------------------------
    -- Calling Simple API for Deleting A Row
    --------------------------------------------
    OKC_TEMPLATE_USAGES_PVT.Delete_Row(
      x_return_status              =>   x_return_status,
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_object_version_number  => p_object_version_number
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: Leaving delete_template_usages');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving delete_template_usages: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2500: Leaving delete_template_usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2600: Leaving delete_template_usages because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END delete_template_usages;

  PROCEDURE Set_Contract_Source(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_document_type                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_contract_source_code         IN VARCHAR2,
    p_authoring_party_code         IN VARCHAR2,
    p_validation_string            IN VARCHAR2,

    p_document_number              IN VARCHAR2
    ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Set_Contract_Source';
    l_value                        VARCHAR2(1) := 'N';
    l_document_type                OKC_TEMPLATE_USAGES.DOCUMENT_TYPE%TYPE;
    l_document_id                  OKC_TEMPLATE_USAGES.DOCUMENT_ID%TYPE;
    l_contract_source_code         VARCHAR2(30);
    l_authoring_party_code         VARCHAR2(30);

    CURSOR l_template_usages_csr IS
     SELECT 'Y'
     FROM  OKC_TEMPLATE_USAGES
     WHERE document_id = p_document_id
     AND   document_type = p_document_type;

    CURSOR l_template_usages_details_csr IS
      SELECT contract_source_code,
             authoring_party_code
      FROM OKC_TEMPLATE_USAGES
      WHERE document_type = p_document_type
            AND document_id = p_document_id;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: Entered Set_Contract_Source');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_set_contract_source_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Check if anything changed. If no change, then nothing to update, return.
    OPEN  l_template_usages_csr;
    FETCH l_template_usages_csr into l_value;
    CLOSE l_template_usages_csr;

    IF l_value = 'Y' THEN
      OPEN  l_template_usages_details_csr;
      FETCH l_template_usages_details_csr into l_contract_source_code, l_authoring_party_code;
      CLOSE l_template_usages_details_csr;

      IF ( l_contract_source_code = p_contract_source_code
           AND l_authoring_party_code = p_authoring_party_code ) THEN
        RETURN;
      END IF;
    END IF;

    -- Bug 4003064. Added call to check if ok_to_commit()
    IF NOT FND_API.To_Boolean( OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version       => l_api_version,
                                         p_init_msg_list     => FND_API.G_FALSE,
                                         p_doc_type          => p_document_type,
                                         p_doc_id            => p_document_id,
                                         p_validation_string => p_validation_string,
                                         p_tmpl_change       => 'Y',
                                         x_return_status     => x_return_status,
                                         x_msg_data          => x_msg_data,
                                         x_msg_count         => x_msg_count )
                             ) THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'700: Issue with document header Record.Cannot commit');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN  l_template_usages_csr;
    FETCH l_template_usages_csr into l_value;
    CLOSE l_template_usages_csr;

    IF p_contract_source_code = 'STRUCTURED' THEN
        OKC_CONTRACT_DOCS_GRP.Clear_Primary_Doc_Flag(
                 p_document_type    => p_document_type,
                 p_document_id      => p_document_id  ,
                 x_return_status    => x_return_status );
    END IF;

    IF l_value = 'Y' THEN
       --update existing template usages record.
       OKC_TEMPLATE_USAGES_PVT.update_row(
                  x_return_status          => x_return_status ,

                  p_document_type          => p_document_type ,
                  p_document_id            => p_document_id ,
                  p_authoring_party_code   => p_authoring_party_code,
                  p_contract_source_code   => p_contract_source_code,
		  p_document_number        => p_document_number);

    ELSE
       --create new template usages record
       OKC_TEMPLATE_USAGES_PVT.insert_row(
                  x_return_status          =>  x_return_status,

                  p_document_type          =>  p_document_type ,
                  p_document_id            =>  p_document_id ,
                  p_template_id            =>  null,
                  p_doc_numbering_scheme   =>  null,
                  p_document_number        =>  p_document_number,
                  p_article_effective_date =>  null,
                  p_config_header_id       =>  null,
                  p_config_revision_number =>  null,
                  p_valid_config_yn        =>  null,
                  p_authoring_party_code   =>  p_authoring_party_code,
                  p_contract_source_code   =>  p_contract_source_code,

                  x_document_type          =>  l_document_type,
                  x_document_id            =>  l_document_id );

    END IF;

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: Leaving Set_Contract_Source');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving Set_Contract_Source: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_set_contract_source_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2500: Leaving Set_Contract_Source: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_set_contract_source_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2600: Leaving Set_Contract_Source because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_set_contract_source_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Set_Contract_Source;

  PROCEDURE Set_Contract_Source_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_document_type                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_contract_source_code         IN VARCHAR2,
    p_authoring_party_code         IN VARCHAR2,
    p_validation_string            IN VARCHAR2,

    p_document_number              IN VARCHAR2,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL

    ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_Set_Contract_Source_details';
    l_value                        VARCHAR2(1) := 'N';
    l_document_type                OKC_TEMPLATE_USAGES.DOCUMENT_TYPE%TYPE;
    l_document_id                  OKC_TEMPLATE_USAGES.DOCUMENT_ID%TYPE;
    l_contract_source_code         OKC_TEMPLATE_USAGES.contract_source_code%TYPE;
    l_authoring_party_code         OKC_TEMPLATE_USAGES.authoring_party_code%TYPE;

    l_contract_admin_id            OKC_TEMPLATE_USAGES.CONTRACT_ADMIN_ID%TYPE;
    l_legal_contact_id             OKC_TEMPLATE_USAGES.LEGAL_CONTACT_ID%TYPE;
    CURSOR l_template_usages_csr IS
     SELECT 'Y'
     FROM  OKC_TEMPLATE_USAGES
     WHERE document_id = p_document_id
     AND   document_type = p_document_type;

    CURSOR l_template_usages_details_csr IS
      SELECT contract_source_code,
             authoring_party_code
      FROM OKC_TEMPLATE_USAGES
      WHERE document_type = p_document_type
            AND document_id = p_document_id;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: Entered Set_Contract_Source');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_set_contract_src_dtls_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Check if anything changed. If no change, then nothing to update, return.
    OPEN  l_template_usages_csr;
    FETCH l_template_usages_csr into l_value;
    CLOSE l_template_usages_csr;



    -- Bug 4003064. Added call to check if ok_to_commit()
    IF NOT FND_API.To_Boolean( OKC_TERMS_UTIL_GRP.ok_to_commit (
                                         p_api_version       => l_api_version,
                                         p_init_msg_list     => FND_API.G_FALSE,
                                         p_doc_type          => p_document_type,
                                         p_doc_id            => p_document_id,
                                         p_validation_string => p_validation_string,
                                         p_tmpl_change       => 'Y',
                                         x_return_status     => x_return_status,
                                         x_msg_data          => x_msg_data,
                                         x_msg_count         => x_msg_count )
                             ) THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'700: Issue with document header Record.Cannot commit');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN  l_template_usages_csr;
    FETCH l_template_usages_csr into l_value;
    CLOSE l_template_usages_csr;

    IF p_contract_source_code = 'STRUCTURED' THEN
        OKC_CONTRACT_DOCS_GRP.Clear_Primary_Doc_Flag(
                 p_document_type    => p_document_type,
                 p_document_id      => p_document_id  ,
                 x_return_status    => x_return_status );
    END IF;

    IF l_value = 'Y' THEN
       --update existing template usages record.
       OKC_TEMPLATE_USAGES_PVT.update_row(
                  x_return_status          => x_return_status ,

                  p_document_type          => p_document_type ,
                  p_document_id            => p_document_id ,
                  p_authoring_party_code   => p_authoring_party_code,
                  p_contract_source_code   => p_contract_source_code,
		          p_document_number        => p_document_number,
                  p_enable_reporting_flag  => p_enable_reporting_flag,
                  p_contract_admin_id      => p_contract_admin_id,
                  p_legal_contact_id       => p_legal_contact_id
        );

    ELSE
       --create new template usages record

	  --Fix for bug# 4733056
	  l_contract_admin_id := p_contract_admin_id;
	  l_legal_contact_id  := p_legal_contact_id;
	  if(p_contract_admin_id = G_MISS_NUM) then
	    l_contract_admin_id :=  null;
	  end if;

	  if(p_legal_contact_id = G_MISS_NUM) then
	    l_legal_contact_id := null;
	  end if;


       OKC_TEMPLATE_USAGES_PVT.insert_row(
                  x_return_status          =>  x_return_status,

                  p_document_type          =>  p_document_type ,
                  p_document_id            =>  p_document_id ,
                  p_template_id            =>  null,
                  p_doc_numbering_scheme   =>  null,
                  p_document_number        =>  p_document_number,
                  p_article_effective_date =>  null,
                  p_config_header_id       =>  null,
                  p_config_revision_number =>  null,
                  p_valid_config_yn        =>  null,
                  p_authoring_party_code   =>  p_authoring_party_code,
                  p_contract_source_code   =>  p_contract_source_code,
                  p_enable_reporting_flag  => p_enable_reporting_flag,
                  p_contract_admin_id      => l_contract_admin_id,
                  p_legal_contact_id       => l_legal_contact_id,

                  x_document_type          =>  l_document_type,
                  x_document_id            =>  l_document_id );

    END IF;

    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: Leaving Set_Contract_Source_details');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving Set_Contract_Source_details: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_set_contract_src_dtls_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2500: Leaving Set_Contract_Source_details: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_set_contract_src_dtls_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2600: Leaving Set_Contract_Source_details because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_set_contract_src_dtls_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END Set_Contract_Source_details;

END OKC_TEMPLATE_USAGES_GRP;

/

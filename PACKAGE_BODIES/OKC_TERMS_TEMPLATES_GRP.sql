--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_TEMPLATES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_TEMPLATES_GRP" AS
/* $Header: OKCGTERMTMPLB.pls 120.1.12010000.2 2011/12/09 13:39:06 serukull ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_TEMPLATES_GRP';
  G_MODULE                     CONSTANT   VARCHAR2(250)   := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE	                     CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
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
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_name           IN VARCHAR2,
    p_template_id             IN NUMBER,
    p_working_copy_flag       IN VARCHAR2,
    p_intent                  IN VARCHAR2,
    p_status_code             IN VARCHAR2,
    p_start_date              IN DATE,
    p_end_date                IN DATE,
    p_global_flag             IN VARCHAR2,
    p_parent_template_id      IN NUMBER,
    p_print_template_id       IN NUMBER,
    p_contract_expert_enabled IN VARCHAR2,
    p_xprt_clause_mandatory_flag IN VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    p_template_model_id       IN NUMBER,
    p_instruction_text        IN VARCHAR2,
    p_tmpl_numbering_scheme   IN NUMBER,
    p_description             IN VARCHAR2,
    p_approval_wf_key         IN VARCHAR2,
    p_cz_export_wf_key        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,
    p_org_id                  IN NUMBER,

    p_attribute_category      IN VARCHAR2 := NULL,
    p_attribute1              IN VARCHAR2 := NULL,
    p_attribute2              IN VARCHAR2 := NULL,
    p_attribute3              IN VARCHAR2 := NULL,
    p_attribute4              IN VARCHAR2 := NULL,
    p_attribute5              IN VARCHAR2 := NULL,
    p_attribute6              IN VARCHAR2 := NULL,
    p_attribute7              IN VARCHAR2 := NULL,
    p_attribute8              IN VARCHAR2 := NULL,
    p_attribute9              IN VARCHAR2 := NULL,
    p_attribute10             IN VARCHAR2 := NULL,
    p_attribute11             IN VARCHAR2 := NULL,
    p_attribute12             IN VARCHAR2 := NULL,
    p_attribute13             IN VARCHAR2 := NULL,
    p_attribute14             IN VARCHAR2 := NULL,
    p_attribute15             IN VARCHAR2 := NULL,
    p_translated_from_tmpl_id IN NUMBER := NULL,
    p_language                IN VARCHAR2 := NULL,

    p_object_version_number   IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_validate_row';

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

    --------------------------------------------
    -- Calling Simple API for Validation
    --------------------------------------------
    OKC_TERMS_TEMPLATES_PVT.Validate_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_template_name           => p_template_name,
      p_template_id             => p_template_id,
      p_working_copy_flag       => p_working_copy_flag,
      p_intent                  => p_intent,
      p_status_code             => p_status_code,
      p_start_date              => p_start_date,
      p_end_date                => p_end_date,
      p_global_flag             => p_global_flag,
      p_parent_template_id      => p_parent_template_id,
      p_print_template_id       => p_print_template_id,
      p_contract_expert_enabled => p_contract_expert_enabled,
	 p_xprt_clause_mandatory_flag => p_xprt_clause_mandatory_flag, -- Added for 11.5.10+ : Contract Expert Changes
	 p_xprt_scn_code           => p_xprt_scn_code, -- Added for 11.5.10+ : Contract Expert Changes
      p_template_model_id       => p_template_model_id,
      p_instruction_text        => p_instruction_text,
      p_tmpl_numbering_scheme   => p_tmpl_numbering_scheme,
      p_description             => p_description,
      p_approval_wf_key         => p_approval_wf_key,
      p_cz_export_wf_key        => p_cz_export_wf_key,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id1,
      p_org_id                  => p_org_id,
      p_attribute_category      => p_attribute_category,
      p_attribute1              => p_attribute1,
      p_attribute2              => p_attribute2,
      p_attribute3              => p_attribute3,
      p_attribute4              => p_attribute4,
      p_attribute5              => p_attribute5,
      p_attribute6              => p_attribute6,
      p_attribute7              => p_attribute7,
      p_attribute8              => p_attribute8,
      p_attribute9              => p_attribute9,
      p_attribute10             => p_attribute10,
      p_attribute11             => p_attribute11,
      p_attribute12             => p_attribute12,
      p_attribute13             => p_attribute13,
      p_attribute14             => p_attribute14,
      p_attribute15             => p_attribute15,
--MLS for templates
      p_translated_from_tmpl_id => p_translated_from_tmpl_id,
      p_language               	=> p_language,
      p_object_version_number   => p_object_version_number
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
  -- PROCEDURE create_template
  -------------------------------------
  PROCEDURE create_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_name           IN VARCHAR2,
    p_template_id             IN NUMBER,
    p_working_copy_flag       IN VARCHAR2,
    p_intent                  IN VARCHAR2,
    p_status_code             IN VARCHAR2,
    p_start_date              IN DATE,
    p_end_date                IN DATE,
    p_global_flag             IN VARCHAR2,
    p_parent_template_id      IN NUMBER,
    p_print_template_id       IN NUMBER,
    p_contract_expert_enabled IN VARCHAR2,
    p_xprt_clause_mandatory_flag IN VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    p_template_model_id       IN NUMBER,
    p_instruction_text        IN VARCHAR2,
    p_tmpl_numbering_scheme   IN NUMBER,
    p_description             IN VARCHAR2,
    p_approval_wf_key         IN VARCHAR2 := NULL,
    p_cz_export_wf_key        IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,
    p_org_id                  IN NUMBER,

    p_attribute_category      IN VARCHAR2 := NULL,
    p_attribute1              IN VARCHAR2 := NULL,
    p_attribute2              IN VARCHAR2 := NULL,
    p_attribute3              IN VARCHAR2 := NULL,
    p_attribute4              IN VARCHAR2 := NULL,
    p_attribute5              IN VARCHAR2 := NULL,
    p_attribute6              IN VARCHAR2 := NULL,
    p_attribute7              IN VARCHAR2 := NULL,
    p_attribute8              IN VARCHAR2 := NULL,
    p_attribute9              IN VARCHAR2 := NULL,
    p_attribute10             IN VARCHAR2 := NULL,
    p_attribute11             IN VARCHAR2 := NULL,
    p_attribute12             IN VARCHAR2 := NULL,
    p_attribute13             IN VARCHAR2 := NULL,
    p_attribute14             IN VARCHAR2 := NULL,
    p_attribute15             IN VARCHAR2 := NULL,
    p_translated_from_tmpl_id IN NUMBER := NULL,
    p_language                IN VARCHAR2 := NULL,

    x_template_id             OUT NOCOPY NUMBER

  ) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_lock_row';
    l_object_version_number   OKC_TERMS_TEMPLATES_ALL.OBJECT_VERSION_NUMBER%TYPE := 1;
    l_created_by              OKC_TERMS_TEMPLATES_ALL.CREATED_BY%TYPE;
    l_creation_date           OKC_TERMS_TEMPLATES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by         OKC_TERMS_TEMPLATES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login       OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date        OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_DATE%TYPE;
    l_cz_export_wf_key        OKC_TERMS_TEMPLATES_ALL.CZ_EXPORT_WF_KEY%TYPE;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600: Entered create_template');
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

    --------------------------------------------
    -- Calling Simple API for Creating A Row
    --------------------------------------------
    OKC_TERMS_TEMPLATES_PVT.Insert_Row(
      p_validation_level           =>   p_validation_level,
      x_return_status              =>   x_return_status,
      p_template_name           => p_template_name,
      p_template_id             => p_template_id,
      p_working_copy_flag       => p_working_copy_flag,
      p_intent                  => p_intent,
      p_status_code             => p_status_code,
      p_start_date              => p_start_date,
      p_end_date                => p_end_date,
      p_global_flag             => p_global_flag,
      p_parent_template_id      => p_parent_template_id,
      p_print_template_id       => p_print_template_id,
      p_contract_expert_enabled => p_contract_expert_enabled,
	 p_xprt_clause_mandatory_flag => p_xprt_clause_mandatory_flag, -- Added for 11.5.10+: Contract Expert Changes
	 p_xprt_scn_code           => p_xprt_scn_code, -- Added for 11.5.10+: Contract Expert Changes
      p_template_model_id       => p_template_model_id,
      p_instruction_text        => p_instruction_text,
      p_tmpl_numbering_scheme   => p_tmpl_numbering_scheme,
      p_description             => p_description,
      p_approval_wf_key         => p_approval_wf_key,
      p_cz_export_wf_key        => p_cz_export_wf_key,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id1,
      p_org_id                  => p_org_id,
      p_attribute_category      => p_attribute_category,
      p_attribute1              => p_attribute1,
      p_attribute2              => p_attribute2,
      p_attribute3              => p_attribute3,
      p_attribute4              => p_attribute4,
      p_attribute5              => p_attribute5,
      p_attribute6              => p_attribute6,
      p_attribute7              => p_attribute7,
      p_attribute8              => p_attribute8,
      p_attribute9              => p_attribute9,
      p_attribute10             => p_attribute10,
      p_attribute11             => p_attribute11,
      p_attribute12             => p_attribute12,
      p_attribute13             => p_attribute13,
      p_attribute14             => p_attribute14,
      p_attribute15             => p_attribute15,
--MLS for templates
      p_translated_from_tmpl_id => p_translated_from_tmpl_id,
      p_language               	=> p_language,
      x_template_id             => x_template_id
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
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Leaving create_template');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'800: Leaving create_template: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving create_template: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving create_template because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_insert_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END create_template;
  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id             IN NUMBER,
    p_object_version_number   IN NUMBER
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
    OKC_TERMS_TEMPLATES_PVT.lock_row(
      x_return_status              =>   x_return_status,
      p_template_id             => p_template_id,
      p_object_version_number   => p_object_version_number
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
  -- PROCEDURE update_template
  ---------------------------------------------------------------------------
  PROCEDURE update_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_name           IN VARCHAR2,
    p_template_id             IN NUMBER,
    p_working_copy_flag       IN VARCHAR2,
    p_intent                  IN VARCHAR2,
    p_status_code             IN VARCHAR2,
    p_start_date              IN DATE,
    p_end_date                IN DATE,
    p_global_flag             IN VARCHAR2,
    p_parent_template_id      IN NUMBER,
    p_print_template_id       IN NUMBER,
    p_contract_expert_enabled IN VARCHAR2,
    p_xprt_clause_mandatory_flag IN VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    p_template_model_id       IN NUMBER,
    p_instruction_text        IN VARCHAR2,
    p_tmpl_numbering_scheme   IN NUMBER,
    p_description             IN VARCHAR2,
    p_approval_wf_key         IN VARCHAR2 := NULL,
    p_cz_export_wf_key        IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,
    p_org_id                  IN NUMBER,

    p_attribute_category      IN VARCHAR2 := NULL,
    p_attribute1              IN VARCHAR2 := NULL,
    p_attribute2              IN VARCHAR2 := NULL,
    p_attribute3              IN VARCHAR2 := NULL,
    p_attribute4              IN VARCHAR2 := NULL,
    p_attribute5              IN VARCHAR2 := NULL,
    p_attribute6              IN VARCHAR2 := NULL,
    p_attribute7              IN VARCHAR2 := NULL,
    p_attribute8              IN VARCHAR2 := NULL,
    p_attribute9              IN VARCHAR2 := NULL,
    p_attribute10             IN VARCHAR2 := NULL,
    p_attribute11             IN VARCHAR2 := NULL,
    p_attribute12             IN VARCHAR2 := NULL,
    p_attribute13             IN VARCHAR2 := NULL,
    p_attribute14             IN VARCHAR2 := NULL,
    p_attribute15             IN VARCHAR2 := NULL,
    p_translated_from_tmpl_id IN NUMBER := NULL,
    p_language                IN VARCHAR2 := NULL,

    p_object_version_number   IN NUMBER

   ) IS

    l_api_version             CONSTANT NUMBER := 1;
    l_api_name                CONSTANT VARCHAR2(30) := 'g_update_template';
    l_cz_export_wf_key        OKC_TERMS_TEMPLATES_ALL.CZ_EXPORT_WF_KEY%TYPE;


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Entered update_template');
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
    OKC_TERMS_TEMPLATES_PVT.Update_Row(
      p_validation_level           => p_validation_level,
      x_return_status              => x_return_status,
      p_template_name           => p_template_name,
      p_template_id             => p_template_id,
      p_working_copy_flag       => p_working_copy_flag,
      p_intent                  => p_intent,
      p_status_code             => p_status_code,
      p_start_date              => p_start_date,
      p_end_date                => p_end_date,
      p_global_flag             => p_global_flag,
      p_parent_template_id      => p_parent_template_id,
      p_print_template_id       => p_print_template_id,
      p_contract_expert_enabled => p_contract_expert_enabled,
      p_xprt_clause_mandatory_flag => p_xprt_clause_mandatory_flag, -- Added for 11.5.10+ : Contract Expert Changes
      p_xprt_scn_code           => p_xprt_scn_code, -- Added for 11.5.10+ : Contract Expert Changes
      p_template_model_id       => p_template_model_id,
      p_instruction_text        => p_instruction_text,
      p_tmpl_numbering_scheme   => p_tmpl_numbering_scheme,
      p_description             => p_description,
      p_approval_wf_key         => p_approval_wf_key,
      p_cz_export_wf_key        => p_cz_export_wf_key,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id1,
      p_org_id                  => p_org_id,
      p_attribute_category      => p_attribute_category,
      p_attribute1              => p_attribute1,
      p_attribute2              => p_attribute2,
      p_attribute3              => p_attribute3,
      p_attribute4              => p_attribute4,
      p_attribute5              => p_attribute5,
      p_attribute6              => p_attribute6,
      p_attribute7              => p_attribute7,
      p_attribute8              => p_attribute8,
      p_attribute9              => p_attribute9,
      p_attribute10             => p_attribute10,
      p_attribute11             => p_attribute11,
      p_attribute12             => p_attribute12,
      p_attribute13             => p_attribute13,
      p_attribute14             => p_attribute14,
      p_attribute15             => p_attribute15,
--MLS for templates
      p_translated_from_tmpl_id => p_translated_from_tmpl_id,
      p_language               	=> p_language,
      p_object_version_number   => p_object_version_number
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
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Leaving update_template');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1900: Leaving update_template: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_update_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving update_template: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_update_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2100: Leaving update_template because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_update_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END update_template;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_template
  ---------------------------------------------------------------------------
  PROCEDURE delete_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id             IN NUMBER,
    p_object_version_number   IN NUMBER
  ) IS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'g_delete_template';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: Entered delete_template');
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
    OKC_TERMS_TEMPLATES_PVT.Delete_Row(
      x_return_status              =>   x_return_status,
      p_template_id             => p_template_id,
      p_object_version_number   => p_object_version_number
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
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: Leaving delete_template');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving delete_template: OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;
      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2500: Leaving delete_template: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;
      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2600: Leaving delete_template because of EXCEPTION: '||sqlerrm);
      END IF;

      ROLLBACK TO g_delete_row_GRP;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END delete_template;

END OKC_TERMS_TEMPLATES_GRP;

/

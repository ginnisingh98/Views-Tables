--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_TEMPLATES_PVT" AS
/* $Header: OKCVTERMTMPLB.pls 120.3 2005/11/15 01:42:03 ndoddi noship $ */


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
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMTMPL_PVT';
  G_MODULE                     CONSTANT   VARCHAR2(250)   := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;

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
  FUNCTION Get_Seq_Id (
    p_template_id             IN NUMBER,
    x_template_id             OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'Get_Seq_Id';
    CURSOR l_seq_csr IS
     SELECT OKC_TERMS_TEMPLATES_ALL_S.NEXTVAL FROM DUAL;
  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered get_seq_id');
    END IF;

    IF( p_template_id             IS NULL ) THEN
      OPEN l_seq_csr;
      FETCH l_seq_csr INTO x_template_id            ;
      IF l_seq_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE l_seq_csr;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Leaving get_seq_id');
    END IF;
    RETURN G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'300: Leaving get_seq_id because of EXCEPTION: '||sqlerrm);
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
  -- FUNCTION get_rec for: OKC_TERMS_TEMPLATES_ALL
  ---------------------------------------------------------------------------
  FUNCTION Get_Rec (
    p_template_id             IN NUMBER,

    x_template_name           OUT NOCOPY VARCHAR2,
    x_working_copy_flag       OUT NOCOPY VARCHAR2,
    x_intent                  OUT NOCOPY VARCHAR2,
    x_status_code             OUT NOCOPY VARCHAR2,
    x_start_date              OUT NOCOPY DATE,
    x_end_date                OUT NOCOPY DATE,
    x_global_flag             OUT NOCOPY VARCHAR2,
    x_parent_template_id      OUT NOCOPY NUMBER,
    x_print_template_id       OUT NOCOPY NUMBER,
    x_contract_expert_enabled OUT NOCOPY VARCHAR2,
    x_xprt_clause_mandatory_flag OUT NOCOPY VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    x_xprt_scn_code           OUT NOCOPY VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    x_template_model_id       OUT NOCOPY NUMBER,
    x_instruction_text        OUT NOCOPY VARCHAR2,
    x_tmpl_numbering_scheme   OUT NOCOPY NUMBER,
    x_description             OUT NOCOPY VARCHAR2,
    x_approval_wf_key         OUT NOCOPY VARCHAR2,
    x_cz_export_wf_key        OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1 OUT NOCOPY NUMBER,
    x_orig_system_reference_id2 OUT NOCOPY NUMBER,
    x_org_id                  OUT NOCOPY NUMBER,
    x_attribute_category      OUT NOCOPY VARCHAR2,
    x_attribute1              OUT NOCOPY VARCHAR2,
    x_attribute2              OUT NOCOPY VARCHAR2,
    x_attribute3              OUT NOCOPY VARCHAR2,
    x_attribute4              OUT NOCOPY VARCHAR2,
    x_attribute5              OUT NOCOPY VARCHAR2,
    x_attribute6              OUT NOCOPY VARCHAR2,
    x_attribute7              OUT NOCOPY VARCHAR2,
    x_attribute8              OUT NOCOPY VARCHAR2,
    x_attribute9              OUT NOCOPY VARCHAR2,
    x_attribute10             OUT NOCOPY VARCHAR2,
    x_attribute11             OUT NOCOPY VARCHAR2,
    x_attribute12             OUT NOCOPY VARCHAR2,
    x_attribute13             OUT NOCOPY VARCHAR2,
    x_attribute14             OUT NOCOPY VARCHAR2,
    x_attribute15             OUT NOCOPY VARCHAR2,
    x_object_version_number   OUT NOCOPY NUMBER,
    x_created_by              OUT NOCOPY NUMBER,
    x_creation_date           OUT NOCOPY DATE,
    x_last_updated_by         OUT NOCOPY NUMBER,
    x_last_update_login       OUT NOCOPY NUMBER,
    x_last_update_date        OUT NOCOPY DATE,
    x_translated_from_tmpl_id OUT NOCOPY NUMBER,
    x_language                OUT NOCOPY VARCHAR2

  ) RETURN VARCHAR2 IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'get_rec';
    CURSOR OKC_TERMS_TEMPLATES_ALL_pk_csr (cp_template_id IN NUMBER) IS
    SELECT
            TEMPLATE_NAME,
            WORKING_COPY_FLAG,
            INTENT,
            STATUS_CODE,
            START_DATE,
            END_DATE,
            GLOBAL_FLAG,
            PARENT_TEMPLATE_ID,
            PRINT_TEMPLATE_ID,
            CONTRACT_EXPERT_ENABLED,
		  XPRT_CLAUSE_MANDATORY_FLAG, -- Added for 11.5.10+ : Contract Expert Changes
		  XPRT_SCN_CODE, -- Added for 11..510+ : Contract Expert Changes
            TEMPLATE_MODEL_ID,
            INSTRUCTION_TEXT,
            TMPL_NUMBERING_SCHEME,
            DESCRIPTION,
            APPROVAL_WF_KEY,
            CZ_EXPORT_WF_KEY,
            ORIG_SYSTEM_REFERENCE_CODE,
            ORIG_SYSTEM_REFERENCE_ID1,
            ORIG_SYSTEM_REFERENCE_ID2,
            ORG_ID,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
--MLS for templates
	    TRANSLATED_FROM_TMPL_ID,
            LANGUAGE
      FROM OKC_TERMS_TEMPLATES_ALL t
     WHERE t.TEMPLATE_ID = cp_template_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: Entered get_rec');
    END IF;

    -- Get current database values
    OPEN OKC_TERMS_TEMPLATES_ALL_pk_csr (p_template_id);
    FETCH OKC_TERMS_TEMPLATES_ALL_pk_csr INTO
            x_template_name,
            x_working_copy_flag,
            x_intent,
            x_status_code,
            x_start_date,
            x_end_date,
            x_global_flag,
            x_parent_template_id,
            x_print_template_id,
            x_contract_expert_enabled,
		  x_xprt_clause_mandatory_flag, -- Added for 11.5.10+ : Contract Expert Changes
		  x_xprt_scn_code, -- Added for 11.5.10+ : Contract Expert Changes
            x_template_model_id,
            x_instruction_text,
            x_tmpl_numbering_scheme,
            x_description,
            x_approval_wf_key,
            x_cz_export_wf_key,
            x_orig_system_reference_code,
            x_orig_system_reference_id1,
            x_orig_system_reference_id2,
            x_org_id,
            x_attribute_category,
            x_attribute1,
            x_attribute2,
            x_attribute3,
            x_attribute4,
            x_attribute5,
            x_attribute6,
            x_attribute7,
            x_attribute8,
            x_attribute9,
            x_attribute10,
            x_attribute11,
            x_attribute12,
            x_attribute13,
            x_attribute14,
            x_attribute15,
            x_object_version_number,
            x_created_by,
            x_creation_date,
            x_last_updated_by,
            x_last_update_login,
            x_last_update_date,
--MLS for templates
	    x_translated_from_tmpl_id,
            x_language ;
    IF OKC_TERMS_TEMPLATES_ALL_pk_csr%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE OKC_TERMS_TEMPLATES_ALL_pk_csr;

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

      IF OKC_TERMS_TEMPLATES_ALL_pk_csr%ISOPEN THEN
        CLOSE OKC_TERMS_TEMPLATES_ALL_pk_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Rec;

  -----------------------------------------
  -- Set_Attributes for:OKC_TERMS_TEMPLATES_ALL --
  -----------------------------------------
  FUNCTION Set_Attributes(
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
    p_xprt_clause_mandatory_flag IN VARCHAR2, -- Added for 11.5.10+ : Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2, -- Added for 11.5.10+ : Contract Expert Changes
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
    p_attribute_category      IN VARCHAR2,
    p_attribute1              IN VARCHAR2,
    p_attribute2              IN VARCHAR2,
    p_attribute3              IN VARCHAR2,
    p_attribute4              IN VARCHAR2,
    p_attribute5              IN VARCHAR2,
    p_attribute6              IN VARCHAR2,
    p_attribute7              IN VARCHAR2,
    p_attribute8              IN VARCHAR2,
    p_attribute9              IN VARCHAR2,
    p_attribute10             IN VARCHAR2,
    p_attribute11             IN VARCHAR2,
    p_attribute12             IN VARCHAR2,
    p_attribute13             IN VARCHAR2,
    p_attribute14             IN VARCHAR2,
    p_attribute15             IN VARCHAR2,
    p_translated_from_tmpl_id IN NUMBER,
--MLS for templates
    p_language 		      IN VARCHAR2,
    p_object_version_number   IN NUMBER,

    x_template_name           OUT NOCOPY VARCHAR2,
    x_working_copy_flag       OUT NOCOPY VARCHAR2,
    x_intent                  OUT NOCOPY VARCHAR2,
    x_status_code             OUT NOCOPY VARCHAR2,
    x_start_date              OUT NOCOPY DATE,
    x_end_date                OUT NOCOPY DATE,
    x_global_flag             OUT NOCOPY VARCHAR2,
    x_parent_template_id      OUT NOCOPY NUMBER,
    x_print_template_id       OUT NOCOPY NUMBER,
    x_contract_expert_enabled OUT NOCOPY VARCHAR2,
    x_xprt_clause_mandatory_flag OUT NOCOPY VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    x_xprt_scn_code           OUT NOCOPY VARCHAR2, -- Added for 11.5.10+: Contract Expert Changes
    x_template_model_id       OUT NOCOPY NUMBER,
    x_instruction_text        OUT NOCOPY VARCHAR2,
    x_tmpl_numbering_scheme   OUT NOCOPY NUMBER,
    x_description             OUT NOCOPY VARCHAR2,
    x_approval_wf_key         OUT NOCOPY VARCHAR2,
    x_cz_export_wf_key        OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1 OUT NOCOPY NUMBER,
    x_orig_system_reference_id2 OUT NOCOPY NUMBER,
    x_org_id                  OUT NOCOPY NUMBER,
    x_attribute_category      OUT NOCOPY VARCHAR2,
    x_attribute1              OUT NOCOPY VARCHAR2,
    x_attribute2              OUT NOCOPY VARCHAR2,
    x_attribute3              OUT NOCOPY VARCHAR2,
    x_attribute4              OUT NOCOPY VARCHAR2,
    x_attribute5              OUT NOCOPY VARCHAR2,
    x_attribute6              OUT NOCOPY VARCHAR2,
    x_attribute7              OUT NOCOPY VARCHAR2,
    x_attribute8              OUT NOCOPY VARCHAR2,
    x_attribute9              OUT NOCOPY VARCHAR2,
    x_attribute10             OUT NOCOPY VARCHAR2,
    x_attribute11             OUT NOCOPY VARCHAR2,
    x_attribute12             OUT NOCOPY VARCHAR2,
    x_attribute13             OUT NOCOPY VARCHAR2,
    x_attribute14             OUT NOCOPY VARCHAR2,
    x_attribute15             OUT NOCOPY VARCHAR2,
    x_translated_from_tmpl_id OUT NOCOPY NUMBER,
    x_language 		      OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'set_attributes';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_object_version_number   OKC_TERMS_TEMPLATES_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by              OKC_TERMS_TEMPLATES_ALL.CREATED_BY%TYPE;
    l_creation_date           OKC_TERMS_TEMPLATES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by         OKC_TERMS_TEMPLATES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login       OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date        OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Entered Set_Attributes ');
    END IF;

    IF( p_template_id IS NOT NULL ) THEN
      -- Get current database values
      l_return_status := Get_Rec(
        p_template_id             => p_template_id,
        x_template_name           => x_template_name,
        x_working_copy_flag       => x_working_copy_flag,
        x_intent                  => x_intent,
        x_status_code             => x_status_code,
        x_start_date              => x_start_date,
        x_end_date                => x_end_date,
        x_global_flag             => x_global_flag,
        x_parent_template_id      => x_parent_template_id,
        x_print_template_id       => x_print_template_id,
        x_contract_expert_enabled => x_contract_expert_enabled,
	   x_xprt_clause_mandatory_flag => x_xprt_clause_mandatory_flag, -- Added for 11.5.10+ : Contract Expert Changes
	   x_xprt_scn_code           => x_xprt_scn_code, -- Added for 11.5.10+ : Contract Expert Changes
        x_template_model_id       => x_template_model_id,
        x_instruction_text        => x_instruction_text,
        x_tmpl_numbering_scheme   => x_tmpl_numbering_scheme,
        x_description             => x_description,
        x_approval_wf_key         => x_approval_wf_key,
        x_cz_export_wf_key        => x_cz_export_wf_key,
        x_orig_system_reference_code => x_orig_system_reference_code,
        x_orig_system_reference_id1 => x_orig_system_reference_id1,
        x_orig_system_reference_id2 => x_orig_system_reference_id2,
        x_org_id                  => x_org_id,
        x_attribute_category      => x_attribute_category,
        x_attribute1              => x_attribute1,
        x_attribute2              => x_attribute2,
        x_attribute3              => x_attribute3,
        x_attribute4              => x_attribute4,
        x_attribute5              => x_attribute5,
        x_attribute6              => x_attribute6,
        x_attribute7              => x_attribute7,
        x_attribute8              => x_attribute8,
        x_attribute9              => x_attribute9,
        x_attribute10             => x_attribute10,
        x_attribute11             => x_attribute11,
        x_attribute12             => x_attribute12,
        x_attribute13             => x_attribute13,
        x_attribute14             => x_attribute14,
        x_attribute15             => x_attribute15,
        x_object_version_number   => l_object_version_number,
        x_created_by              => l_created_by,
        x_creation_date           => l_creation_date,
        x_last_updated_by         => l_last_updated_by,
        x_last_update_login       => l_last_update_login,
        x_last_update_date        => l_last_update_date,
        x_translated_from_tmpl_id => x_translated_from_tmpl_id,
        x_language 		  => x_language    );
      --- If any errors happen abort API
      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --- Reversing G_MISS/NULL values logic

      IF (p_template_name = G_MISS_CHAR) THEN
        x_template_name := NULL;
       ELSIF (p_TEMPLATE_NAME IS NOT NULL) THEN
        x_template_name := p_template_name;
      END IF;

      IF (p_working_copy_flag = G_MISS_CHAR) THEN
        x_working_copy_flag := NULL;
       ELSIF (p_WORKING_COPY_FLAG IS NOT NULL) THEN
        x_working_copy_flag := p_working_copy_flag;
      END IF;

      IF (p_intent = G_MISS_CHAR) THEN
        x_intent := NULL;
       ELSIF (p_INTENT IS NOT NULL) THEN
        x_intent := p_intent;
      END IF;

      IF (p_status_code = G_MISS_CHAR) THEN
        x_status_code := NULL;
       ELSIF (p_STATUS_CODE IS NOT NULL) THEN
        x_status_code := p_status_code;
      END IF;

      IF (p_start_date = G_MISS_DATE) THEN
        x_start_date := NULL;
       ELSIF (p_START_DATE IS NOT NULL) THEN
        x_start_date := p_start_date;
      END IF;

      IF (p_end_date = G_MISS_DATE) THEN
        x_end_date := NULL;
       ELSIF (p_END_DATE IS NOT NULL) THEN
        x_end_date := p_end_date;
      END IF;

      IF (p_global_flag = G_MISS_CHAR) THEN
        x_global_flag := NULL;
       ELSIF (p_GLOBAL_FLAG IS NOT NULL) THEN
        x_global_flag := p_global_flag;
      END IF;

      IF (p_parent_template_id = G_MISS_NUM) THEN
        x_parent_template_id := NULL;
       ELSIF (p_PARENT_TEMPLATE_ID IS NOT NULL) THEN
        x_parent_template_id := p_parent_template_id;
      END IF;

      IF (p_print_template_id = G_MISS_NUM) THEN
        x_print_template_id := NULL;
       ELSIF (p_PRINT_TEMPLATE_ID IS NOT NULL) THEN
        x_print_template_id := p_print_template_id;
      END IF;

      IF (p_contract_expert_enabled = G_MISS_CHAR) THEN
        x_contract_expert_enabled := NULL;
       ELSIF (p_CONTRACT_EXPERT_ENABLED IS NOT NULL) THEN
        x_contract_expert_enabled := p_contract_expert_enabled;
      END IF;

      IF (p_xprt_clause_mandatory_flag = G_MISS_CHAR) THEN
        x_xprt_clause_mandatory_flag := NULL;
       ELSIF (p_xprt_clause_mandatory_flag IS NOT NULL) THEN
        x_xprt_clause_mandatory_flag := p_xprt_clause_mandatory_flag;
      END IF;

      IF (p_xprt_scn_code = G_MISS_CHAR) THEN
        x_xprt_scn_code:= NULL;
       ELSIF (p_xprt_scn_code IS NOT NULL) THEN
        x_xprt_scn_code := p_xprt_scn_code;
      END IF;
IF (p_template_model_id = G_MISS_NUM) THEN
        x_template_model_id := NULL;
       ELSIF (p_TEMPLATE_MODEL_ID IS NOT NULL) THEN
        x_template_model_id := p_template_model_id;
      END IF;

      IF (p_instruction_text = G_MISS_CHAR) THEN
        x_instruction_text := NULL;
       ELSIF (p_INSTRUCTION_TEXT IS NOT NULL) THEN
        x_instruction_text := p_instruction_text;
      END IF;

      IF (p_tmpl_numbering_scheme = G_MISS_NUM) THEN
        x_tmpl_numbering_scheme := NULL;
       ELSIF (p_TMPL_NUMBERING_SCHEME IS NOT NULL) THEN
        x_tmpl_numbering_scheme := p_tmpl_numbering_scheme;
      END IF;

      IF (p_description = G_MISS_CHAR) THEN
        x_description := NULL;
       ELSIF (p_DESCRIPTION IS NOT NULL) THEN
        x_description := p_description;
      END IF;

      IF (p_approval_wf_key = G_MISS_CHAR) THEN
        x_approval_wf_key := NULL;
       ELSIF (p_approval_wf_key IS NOT NULL) THEN
        x_approval_wf_key := p_approval_wf_key;
      END IF;

      IF (p_cz_export_wf_key = G_MISS_CHAR) THEN
        x_cz_export_wf_key := NULL;
       ELSIF (p_cz_export_wf_key IS NOT NULL) THEN
        x_cz_export_wf_key := p_cz_export_wf_key;
      END IF;

      IF (p_org_id = G_MISS_NUM) THEN
        x_org_id := NULL;
       ELSIF (p_ORG_ID IS NOT NULL) THEN
        x_org_id := p_org_id;
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

      IF (p_attribute_category = G_MISS_CHAR) THEN
        x_attribute_category := NULL;
       ELSIF (p_ATTRIBUTE_CATEGORY IS NOT NULL) THEN
        x_attribute_category := p_attribute_category;
      END IF;

      IF (p_attribute1 = G_MISS_CHAR) THEN
        x_attribute1 := NULL;
       ELSIF (p_ATTRIBUTE1 IS NOT NULL) THEN
        x_attribute1 := p_attribute1;
      END IF;

      IF (p_attribute2 = G_MISS_CHAR) THEN
        x_attribute2 := NULL;
       ELSIF (p_ATTRIBUTE2 IS NOT NULL) THEN
        x_attribute2 := p_attribute2;
      END IF;

      IF (p_attribute3 = G_MISS_CHAR) THEN
        x_attribute3 := NULL;
       ELSIF (p_ATTRIBUTE3 IS NOT NULL) THEN
        x_attribute3 := p_attribute3;
      END IF;

      IF (p_attribute4 = G_MISS_CHAR) THEN
        x_attribute4 := NULL;
       ELSIF (p_ATTRIBUTE4 IS NOT NULL) THEN
        x_attribute4 := p_attribute4;
      END IF;

      IF (p_attribute5 = G_MISS_CHAR) THEN
        x_attribute5 := NULL;
       ELSIF (p_ATTRIBUTE5 IS NOT NULL) THEN
        x_attribute5 := p_attribute5;
      END IF;

      IF (p_attribute6 = G_MISS_CHAR) THEN
        x_attribute6 := NULL;
       ELSIF (p_ATTRIBUTE6 IS NOT NULL) THEN
        x_attribute6 := p_attribute6;
      END IF;

      IF (p_attribute7 = G_MISS_CHAR) THEN
        x_attribute7 := NULL;
       ELSIF (p_ATTRIBUTE7 IS NOT NULL) THEN
        x_attribute7 := p_attribute7;
      END IF;

      IF (p_attribute8 = G_MISS_CHAR) THEN
        x_attribute8 := NULL;
       ELSIF (p_ATTRIBUTE8 IS NOT NULL) THEN
        x_attribute8 := p_attribute8;
      END IF;

      IF (p_attribute9 = G_MISS_CHAR) THEN
        x_attribute9 := NULL;
       ELSIF (p_ATTRIBUTE9 IS NOT NULL) THEN
        x_attribute9 := p_attribute9;
      END IF;

      IF (p_attribute10 = G_MISS_CHAR) THEN
        x_attribute10 := NULL;
       ELSIF (p_ATTRIBUTE10 IS NOT NULL) THEN
        x_attribute10 := p_attribute10;
      END IF;

      IF (p_attribute11 = G_MISS_CHAR) THEN
        x_attribute11 := NULL;
       ELSIF (p_ATTRIBUTE11 IS NOT NULL) THEN
        x_attribute11 := p_attribute11;
      END IF;

      IF (p_attribute12 = G_MISS_CHAR) THEN
        x_attribute12 := NULL;
       ELSIF (p_ATTRIBUTE12 IS NOT NULL) THEN
        x_attribute12 := p_attribute12;
      END IF;

      IF (p_attribute13 = G_MISS_CHAR) THEN
        x_attribute13 := NULL;
       ELSIF (p_ATTRIBUTE13 IS NOT NULL) THEN
        x_attribute13 := p_attribute13;
      END IF;

      IF (p_attribute14 = G_MISS_CHAR) THEN
        x_attribute14 := NULL;
       ELSIF (p_ATTRIBUTE14 IS NOT NULL) THEN
        x_attribute14 := p_attribute14;
      END IF;

      IF (p_attribute15 = G_MISS_CHAR) THEN
        x_attribute15 := NULL;
       ELSIF (p_ATTRIBUTE15 IS NOT NULL) THEN
        x_attribute15 := p_attribute15;
      END IF;
--MLS for templates
      IF (p_translated_from_tmpl_id = G_MISS_NUM) THEN
        x_translated_from_tmpl_id := NULL;
       ELSIF (p_translated_from_tmpl_id IS NOT NULL) THEN
        x_translated_from_tmpl_id := p_translated_from_tmpl_id;
      END IF;
      IF (p_language = G_MISS_CHAR) THEN
        x_language := NULL;
       ELSIF (p_language IS NOT NULL) THEN
        x_language := p_language;
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
  -- Validate_Attributes for: OKC_TERMS_TEMPLATES_ALL --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

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
    p_xprt_clause_mandatory_flag IN VARCHAR2, -- Added for 11.5.10+ : Contract Expert Changes
    p_xprt_scn_code            IN VARCHAR2, -- Added for 11.5.10+ : Contract Expert Changes
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
    p_attribute_category      IN VARCHAR2,
    p_attribute1              IN VARCHAR2,
    p_attribute2              IN VARCHAR2,
    p_attribute3              IN VARCHAR2,
    p_attribute4              IN VARCHAR2,
    p_attribute5              IN VARCHAR2,
    p_attribute6              IN VARCHAR2,
    p_attribute7              IN VARCHAR2,
    p_attribute8              IN VARCHAR2,
    p_attribute9              IN VARCHAR2,
    p_attribute10             IN VARCHAR2,
    p_attribute11             IN VARCHAR2,
    p_attribute12             IN VARCHAR2,
    p_attribute13             IN VARCHAR2,
    p_attribute14             IN VARCHAR2,
    p_attribute15             IN VARCHAR2,
    p_translated_from_tmpl_id IN NUMBER,
    p_language		      IN VARCHAR2
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_attributes';
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
    TYPE layout_tmpl_csr IS REF CURSOR;
    l_layout_tmpl_csr LAYOUT_TMPL_CSR;
    l_sql_stmt VARCHAR2(4000);
    l_print_template_id NUMBER;
    l_apps_user VARCHAR2(150);
    l_layout_start_date DATE;
    l_layout_end_date DATE;
    l_eff_date DATE;
    l_tmpl_status okc_terms_templates_all.status_code%TYPE := 'ZZZ';
    l_validate_layout VARCHAR2(1) := 'Y';

    CURSOR l_apps_user_csr IS
      SELECT oracle_username
      FROM fnd_oracle_userid
      WHERE read_only_flag = 'U';

    CURSOR l_xdo_view_csr(pc_user VARCHAR2) IS
    SELECT 1
    FROM all_views
    WHERE view_name like 'XDO_TEMPLATES_VL'
    AND owner = pc_user;

    CURSOR l_parent_template_id_csr is
     SELECT '!'
      FROM okc_terms_templates_all
      WHERE TEMPLATE_ID = p_parent_template_id;

    /***************Commented out to remove XDO dependency
    CURSOR l_print_template_id_csr is
     SELECT '!'
      FROM xdo_templates_b
      WHERE TEMPLATE_ID = p_print_template_id;
    ***************/

    /************* Removed as Expert will validate and update templates
    CURSOR l_template_model_id_csr is
     SELECT '!'
      FROM cz_ps_nodes
      WHERE PS_NODE_ID = p_template_model_id;
    *****************************/

    CURSOR l_org_id_csr is
     SELECT '!'
      FROM hr_operating_units
      WHERE ORGANIZATION_ID = p_org_id;

    CURSOR l_tmpl_status_csr(pc_template_id NUMBER) IS
     SELECT status_code
     FROM OKC_TERMS_TEMPLATES_ALL
     WHERE template_id = pc_template_id;


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1200: Entered Validate_Attributes');
    END IF;

    IF p_validation_level > G_REQUIRED_VALUE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1300: required values validation');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1400: - attribute TEMPLATE_NAME ');
      END IF;
      IF ( p_template_name IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: - attribute TEMPLATE_NAME is invalid');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TEMPLATE_NAME');
        l_return_status := G_RET_STS_ERROR;
      END IF;


    END IF;

    IF p_validation_level > G_VALID_VALUE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: static values and range validation');
      END IF;

    END IF;

    IF p_validation_level > G_LOOKUP_CODE_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1900: lookup codes validation');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: - attribute STATUS_CODE ');
      END IF;
      IF p_status_code IS NOT NULL THEN
        l_return_status := Okc_Util.Check_Lookup_Code('OKC_TERMS_TMPL_STATUS',p_status_code);
        IF (l_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'STATUS_CODE');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF p_validation_level > G_FOREIGN_KEY_VALID_LEVEL THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2100: foreigh keys validation ');
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute TEMPLATE_ID ');
      END IF;
      /*
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
      */

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute PARENT_TEMPLATE_ID ');
      END IF;
      IF p_parent_template_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_parent_template_id_csr;
        FETCH l_parent_template_id_csr INTO l_dummy_var;
        CLOSE l_parent_template_id_csr;
        IF (l_dummy_var = '?') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: - attribute PARENT_TEMPLATE_ID is invalid');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PARENT_TEMPLATE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute PRINT_TEMPLATE_ID ');
      END IF;

      IF p_print_template_id IS NOT NULL THEN
        l_dummy_var := '?';
        /***********
        OPEN l_print_template_id_csr;
        FETCH l_print_template_id_csr INTO l_dummy_var;
        CLOSE l_print_template_id_csr;
        **************/

        OPEN l_apps_user_csr;
        FETCH l_apps_user_csr INTO l_apps_user;
        CLOSE l_apps_user_csr;

        OPEN l_xdo_view_csr(l_apps_user);
        FETCH l_xdo_view_csr INTO l_dummy_var;
        IF l_xdo_view_csr%FOUND THEN
          l_sql_stmt := 'SELECT template_id,start_date,end_date FROM xdo_templates_b WHERE template_id = :1';

          OPEN l_layout_tmpl_csr FOR l_sql_stmt USING p_print_template_id;
          FETCH l_layout_tmpl_csr INTO l_print_template_id,l_layout_start_date,l_layout_end_date;
          IF l_layout_tmpl_csr%FOUND THEN
            l_dummy_var := '!';
          END IF;
          CLOSE l_layout_tmpl_csr;
        END IF;
        CLOSE l_xdo_view_csr;

        IF (l_dummy_var = '?') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: - attribute PRINT_TEMPLATE_ID is invalid');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PRINT_TEMPLATE_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

     IF p_template_id IS NOT NULL THEN
       OPEN l_tmpl_status_csr(p_template_id);
       FETCH l_tmpl_status_csr INTO l_tmpl_status;
       CLOSE l_tmpl_status_csr;
     END IF;


     --Bug 3674152  Not checking layout template validity
     IF ((l_tmpl_status='APPROVED' AND p_status_code = 'ON_HOLD') OR
         (l_tmpl_status='ON_HOLD' AND p_status_code = 'APPROVED') OR
         (l_tmpl_status='PENDING_APPROVAL' AND p_status_code = 'APPROVED') OR
         (l_tmpl_status='PENDING_APPROVAL' AND p_status_code = 'REJECTED') OR
         (l_tmpl_status='ZZZ' AND p_status_code = 'REVISION') OR
         (p_status_code = 'PENDING_APPROVAL') ) THEN
         l_validate_layout := 'N';
     END IF;


     IF l_validate_layout <> 'N' THEN
      --Bug 3674152 Validate start_date and end_date of layout template against template effective date
      l_eff_date := sysdate;
      IF nvl(p_end_date,sysdate) < sysdate THEN
          l_eff_date := p_end_date;
      ELSIF p_start_date > sysdate THEN
              l_eff_date := p_start_date;
      END IF;


      IF l_layout_start_date > l_eff_date OR nvl(l_layout_end_date,l_eff_date) < l_eff_date THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - LAYOUT_TEMPLATE is invalid or end_dated');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME,'OKC_LAYOUT_TMPL_INVALID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
     END IF;

      /****************Removed as COntracts Expert will validate and update template
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute TEMPLATE_MODEL_ID ');
      END IF;
      IF p_template_model_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_template_model_id_csr;
        FETCH l_template_model_id_csr INTO l_dummy_var;
        CLOSE l_template_model_id_csr;
        IF (l_dummy_var = '?') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: - attribute TEMPLATE_MODEL_ID is invalid');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TEMPLATE_MODEL_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;
      *****************/


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: - attribute ORG_ID ');
      END IF;
      IF p_org_id IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN l_org_id_csr;
        FETCH l_org_id_csr INTO l_dummy_var;
        CLOSE l_org_id_csr;
        IF (l_dummy_var = '?') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: - attribute ORG_ID is invalid');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ORG_ID');
          l_return_status := G_RET_STS_ERROR;
        END IF;
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

/* ?? uncomment next part after you check and change this foreign key validation

      IF l_template_id_csr%ISOPEN THEN
        CLOSE l_template_id_csr;
      END IF;       */

      IF l_parent_template_id_csr%ISOPEN THEN
        CLOSE l_parent_template_id_csr;
      END IF;

      /****************
      IF l_print_template_id_csr%ISOPEN THEN
        CLOSE l_print_template_id_csr;
      END IF;
      ********************/

      /****************Removed as COntracts Expert will validate and update template
      IF l_template_model_id_csr%ISOPEN THEN
        CLOSE l_template_model_id_csr;
      END IF;
      ****************/

      IF l_org_id_csr%ISOPEN THEN
        CLOSE l_org_id_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR;

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  -- It calls Item Level Validations and then makes Record Level Validations
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_TERMS_TEMPLATES_ALL --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

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
    p_xprt_clause_mandatory_flag in VARCHAR2,
    p_xprt_scn_code           in VARCHAR2,
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
    p_attribute_category      IN VARCHAR2,
    p_attribute1              IN VARCHAR2,
    p_attribute2              IN VARCHAR2,
    p_attribute3              IN VARCHAR2,
    p_attribute4              IN VARCHAR2,
    p_attribute5              IN VARCHAR2,
    p_attribute6              IN VARCHAR2,
    p_attribute7              IN VARCHAR2,
    p_attribute8              IN VARCHAR2,
    p_attribute9              IN VARCHAR2,
    p_attribute10             IN VARCHAR2,
    p_attribute11             IN VARCHAR2,
    p_attribute12             IN VARCHAR2,
    p_attribute13             IN VARCHAR2,
    p_attribute14             IN VARCHAR2,
    p_attribute15             IN VARCHAR2,
    p_translated_from_tmpl_id IN NUMBER,
    p_language		      IN VARCHAR2
    ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_record';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_dummy_var     VARCHAR2(1) := '?';
    l_template_name     OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;

    CURSOR l_tmpl_name_csr is
     SELECT '!'
      FROM okc_terms_templates_all
      WHERE template_name = p_template_name
      AND nvl(working_copy_flag,'N') = nvl(p_working_copy_flag,'N')
      AND ((p_template_id IS NULL) OR (p_template_id <> template_id))
      AND  ORG_ID = mo_global.get_current_org_id();
--MLS for templates
    CURSOR l_primary_tmpl_csr IS
     SELECT '!'
     FROM okc_terms_templates_all
     WHERE translated_from_tmpl_id = p_template_id
     UNION ALL
     SELECT '!'
     FROM okc_terms_templates_all
     WHERE translated_from_tmpl_id = p_parent_template_id ;
--MLS for templates
    CURSOR l_tmpl_group1_csr IS
     SELECT '!', template_name
     FROM okc_terms_templates_all
     WHERE translated_from_tmpl_id= p_parent_template_id
     AND language = p_language;

--MLS for templates
    CURSOR l_tmpl_group2_csr IS
     SELECT '!', template_name
     FROM okc_terms_templates_all
     WHERE translated_from_tmpl_id= p_template_id
     AND language = p_language;

--MLS for templates
    CURSOR l_tmpl_group3_csr IS
     SELECT '!', tta.template_name
     FROM okc_terms_templates_all tta
     WHERE tta.template_id = p_translated_from_tmpl_id
     AND language = p_language
     UNION ALL
     SELECT '!', tta.template_name
     FROM okc_terms_templates_all tta
     WHERE tta.parent_template_id = p_translated_from_tmpl_id
     AND language = p_language
     UNION ALL
     SELECT '!', tta.template_name
     FROM okc_terms_templates_all tta
     WHERE tta.translated_from_tmpl_id = p_translated_from_tmpl_id
     AND tta.language = p_language
     AND tta.template_id <> p_template_id
     AND tta.template_id <> nvl(p_parent_template_id,0)
     AND not exists
               (SELECT 1
                FROM okc_terms_templates_all tta3
                WHERE tta3.template_id = tta.template_id
                AND tta3.parent_template_id = p_template_id) ;


  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2600: Entered Validate_Record');
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(
      p_validation_level   => p_validation_level,

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
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
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
      p_translated_from_tmpl_id => p_translated_from_tmpl_id ,
      p_language		=> p_language
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

    IF nvl(TRUNC(p_end_date),TRUNC(p_start_date)) < TRUNC(p_start_date) THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2810: Start Date > End Date');
      END IF;
       Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_SDATE_GREATER');
       l_return_status := G_RET_STS_ERROR;
    END IF;

    IF (nvl(p_working_copy_flag,'N') = 'Y' AND p_parent_template_id IS NULL) THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2820: Working Copy Flag is Y and Parent_Template_Id is Null');
      END IF;
       Okc_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PARENT_TEMPALTE_ID');
       l_return_status := G_RET_STS_ERROR;
    END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2830: - Validate Template Name Uniqueness ');
      END IF;
        l_dummy_var := '?';
        OPEN l_tmpl_name_csr;
        FETCH l_tmpl_name_csr INTO l_dummy_var;
        CLOSE l_tmpl_name_csr;
        IF (l_dummy_var = '!') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2840: - Template Name Not Unique in the Org');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_DUP_NAME');
          l_return_status := G_RET_STS_ERROR;
        END IF;
----MLS for templates

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2850: - Validate LANGUAGE ');
      END IF;
      IF (p_translated_from_tmpl_id IS NOT NULL) AND (p_language IS NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2860: - Error:Template Language is null when tft is specified');
        END IF;
        Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_LANG_REQUIRED');
        l_return_status := G_RET_STS_ERROR;
      END IF;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2865: - Validate primary template ');
      END IF;
      IF p_translated_from_tmpl_id IS NOT NULL AND p_language IS NOT NULL THEN
        l_dummy_var := '?';
        OPEN  l_primary_tmpl_csr;
        FETCH l_primary_tmpl_csr INTO l_dummy_var;
        CLOSE l_primary_tmpl_csr;
        IF (l_dummy_var = '!') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2868: - Error:User adding tft for a template which alreay has children pointing to it');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_ALREADY_TRANSLATED');
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2870: - Validate language on primary template ');
      END IF;
      IF p_language IS NULL AND p_translated_from_tmpl_id IS NULL THEN
        l_dummy_var := '?';
        OPEN  l_primary_tmpl_csr;
        FETCH l_primary_tmpl_csr INTO l_dummy_var;
        CLOSE l_primary_tmpl_csr;
        IF (l_dummy_var = '!') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2880: - Error:Template Language removed in a priamry template');
          END IF;
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_ALREADY_REFERENCED', 'TMPL1', p_template_name);
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;


      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2890: - Validate language in Template group ');
      END IF;
      l_dummy_var := '?';
      l_template_name := null;
      IF p_language IS NOT NULL AND l_return_status <> G_RET_STS_ERROR THEN
        IF p_translated_from_tmpl_id IS NULL THEN  -- primary template
           IF p_parent_template_id IS NOT NULL THEN   -- template has undergone revision
             OPEN  l_tmpl_group1_csr;
             FETCH l_tmpl_group1_csr INTO l_dummy_var, l_template_name;
             CLOSE l_tmpl_group1_csr;
           ELSE
             OPEN  l_tmpl_group2_csr;
             FETCH l_tmpl_group2_csr INTO l_dummy_var, l_template_name;
             CLOSE l_tmpl_group2_csr;
           END IF;
        ELSE
          OPEN  l_tmpl_group3_csr;
          FETCH l_tmpl_group3_csr INTO l_dummy_var, l_template_name;
          CLOSE l_tmpl_group3_csr;
        END IF;


        IF (l_dummy_var = '!') THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2900: - Error:Template with specified language already exists in the group');
          END IF;

/* Fix for te bug# 4646417. Removed TMPL2 parameter from the set_message call */
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_LANG_EXISTS','TMPL1' , p_template_name);
          l_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;




----MLS for templates

/*+++++++++++++start of hand code +++++++++++++++++++*/
-- ?? manual coding for Record Level Validations if required ??
/*+++++++++++++End of hand code +++++++++++++++++++*/
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2995: Leaving Validate_Record : '||sqlerrm);
    END IF;
    RETURN l_return_status ;

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3000: Leaving Validate_Record because of EXCEPTION: '||sqlerrm);
      END IF;

      IF l_tmpl_name_csr%ISOPEN THEN
        CLOSE l_tmpl_name_csr;
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
  -- validate_row for:OKC_TERMS_TEMPLATES_ALL --
  ---------------------------------------
  PROCEDURE validate_row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

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
    p_translated_from_tmpl_id IN NUMBER,
    p_language		      IN VARCHAR2,
    p_object_version_number   IN NUMBER
  ) IS
      l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
      l_template_name           OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
      l_working_copy_flag       OKC_TERMS_TEMPLATES_ALL.WORKING_COPY_FLAG%TYPE;
      l_intent                  OKC_TERMS_TEMPLATES_ALL.INTENT%TYPE;
      l_status_code             OKC_TERMS_TEMPLATES_ALL.STATUS_CODE%TYPE;
      l_start_date              OKC_TERMS_TEMPLATES_ALL.START_DATE%TYPE;
      l_end_date                OKC_TERMS_TEMPLATES_ALL.END_DATE%TYPE;
      l_global_flag             OKC_TERMS_TEMPLATES_ALL.GLOBAL_FLAG%TYPE;
      l_parent_template_id      OKC_TERMS_TEMPLATES_ALL.PARENT_TEMPLATE_ID%TYPE;
      l_print_template_id       OKC_TERMS_TEMPLATES_ALL.PRINT_TEMPLATE_ID%TYPE;
      l_contract_expert_enabled OKC_TERMS_TEMPLATES_ALL.CONTRACT_EXPERT_ENABLED%TYPE;
	 l_xprt_clause_mandatory_flag OKC_TERMS_TEMPLATES_ALL.XPRT_CLAUSE_MANDATORY_FLAG%TYPE;
	 l_xprt_scn_code           OKC_TERMS_TEMPLATES_ALL.XPRT_SCN_CODE%TYPE;
      l_template_model_id       OKC_TERMS_TEMPLATES_ALL.TEMPLATE_MODEL_ID%TYPE;
      l_instruction_text        OKC_TERMS_TEMPLATES_ALL.INSTRUCTION_TEXT%TYPE;
      l_tmpl_numbering_scheme   OKC_TERMS_TEMPLATES_ALL.TMPL_NUMBERING_SCHEME%TYPE;
      l_description             OKC_TERMS_TEMPLATES_ALL.DESCRIPTION%TYPE;
      l_approval_wf_key         OKC_TERMS_TEMPLATES_ALL.APPROVAL_WF_KEY%TYPE;
      l_cz_export_wf_key        OKC_TERMS_TEMPLATES_ALL.CZ_EXPORT_WF_KEY%TYPE;
      l_orig_system_reference_code OKC_TERMS_TEMPLATES_ALL.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
      l_orig_system_reference_id1 OKC_TERMS_TEMPLATES_ALL.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
      l_orig_system_reference_id2 OKC_TERMS_TEMPLATES_ALL.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
      l_org_id                  OKC_TERMS_TEMPLATES_ALL.ORG_ID%TYPE;
      l_attribute_category      OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE_CATEGORY%TYPE;
      l_attribute1              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE1%TYPE;
      l_attribute2              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE2%TYPE;
      l_attribute3              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE3%TYPE;
      l_attribute4              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE4%TYPE;
      l_attribute5              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE5%TYPE;
      l_attribute6              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE6%TYPE;
      l_attribute7              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE7%TYPE;
      l_attribute8              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE8%TYPE;
      l_attribute9              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE9%TYPE;
      l_attribute10             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE10%TYPE;
      l_attribute11             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE11%TYPE;
      l_attribute12             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE12%TYPE;
      l_attribute13             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE13%TYPE;
      l_attribute14             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE14%TYPE;
      l_attribute15             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE15%TYPE;
      l_object_version_number   OKC_TERMS_TEMPLATES_ALL.OBJECT_VERSION_NUMBER%TYPE;
      l_created_by              OKC_TERMS_TEMPLATES_ALL.CREATED_BY%TYPE;
      l_creation_date           OKC_TERMS_TEMPLATES_ALL.CREATION_DATE%TYPE;
      l_last_updated_by         OKC_TERMS_TEMPLATES_ALL.LAST_UPDATED_BY%TYPE;
      l_last_update_login       OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_LOGIN%TYPE;
      l_last_update_date        OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_DATE%TYPE;
      l_translated_from_tmpl_id OKC_TERMS_TEMPLATES_ALL.TRANSLATED_FROM_TMPL_ID%TYPE;
      l_language		OKC_TERMS_TEMPLATES_ALL.LANGUAGE%TYPE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3100: Entered validate_row');
    END IF;

    -- Setting attributes
    x_return_status := Set_Attributes(
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
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
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
      p_translated_from_tmpl_id => p_translated_from_tmpl_id ,
      p_language		=> p_language,
      p_object_version_number   => p_object_version_number,
      x_template_name           => l_template_name,
      x_working_copy_flag       => l_working_copy_flag,
      x_intent                  => l_intent,
      x_status_code             => l_status_code,
      x_start_date              => l_start_date,
      x_end_date                => l_end_date,
      x_global_flag             => l_global_flag,
      x_parent_template_id      => l_parent_template_id,
      x_print_template_id      => l_print_template_id,
      x_contract_expert_enabled => l_contract_expert_enabled,
	 x_xprt_clause_mandatory_flag => l_xprt_clause_mandatory_flag, -- Added for 11.5.10+ : Contract Expert Changes
	 x_xprt_scn_code              => l_xprt_scn_code, -- Added for 11.5.10+ : Contract Expert Changes
      x_template_model_id       => l_template_model_id,
      x_instruction_text        => l_instruction_text,
      x_tmpl_numbering_scheme   => l_tmpl_numbering_scheme,
      x_description             => l_description,
      x_approval_wf_key         => l_approval_wf_key,
      x_cz_export_wf_key        => l_cz_export_wf_key,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1 => l_orig_system_reference_id1,
      x_orig_system_reference_id2 => l_orig_system_reference_id2,

      x_org_id                  => l_org_id,
      x_attribute_category      => l_attribute_category,
      x_attribute1              => l_attribute1,
      x_attribute2              => l_attribute2,
      x_attribute3              => l_attribute3,
      x_attribute4              => l_attribute4,
      x_attribute5              => l_attribute5,
      x_attribute6              => l_attribute6,
      x_attribute7              => l_attribute7,
      x_attribute8              => l_attribute8,
      x_attribute9              => l_attribute9,
      x_attribute10             => l_attribute10,
      x_attribute11             => l_attribute11,
      x_attribute12             => l_attribute12,
      x_attribute13             => l_attribute13,
      x_attribute14             => l_attribute14,
      x_attribute15             => l_attribute15,
      x_translated_from_tmpl_id => l_translated_from_tmpl_id ,
      x_language		=> l_language
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate all non-missing attributes (Item Level Validation)
    x_return_status := Validate_Record(
      p_validation_level           => p_validation_level,
      p_template_id             => p_template_id,
      p_template_name           => l_template_name,
      p_working_copy_flag       => l_working_copy_flag,
      p_intent                  => l_intent,
      p_status_code             => l_status_code,
      p_start_date              => l_start_date,
      p_end_date                => l_end_date,
      p_global_flag             => l_global_flag,
      p_parent_template_id      => l_parent_template_id,
      p_print_template_id       => l_print_template_id,
      p_contract_expert_enabled => l_contract_expert_enabled,
	 p_xprt_clause_mandatory_flag => l_xprt_clause_mandatory_flag, -- Added for 11.5.10+: Contract Expert Changes
	 p_xprt_scn_code           => l_xprt_scn_code, -- Added for 11.5.10+: Contract Expert Changes
      p_template_model_id       => l_template_model_id,
      p_instruction_text        => l_instruction_text,
      p_tmpl_numbering_scheme   => l_tmpl_numbering_scheme,
      p_description             => l_description,
      p_approval_wf_key         => l_approval_wf_key,
      p_cz_export_wf_key        => l_cz_export_wf_key,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1 => l_orig_system_reference_id1,
      p_orig_system_reference_id2 => l_orig_system_reference_id2,

      p_org_id                  => l_org_id,
      p_attribute_category      => l_attribute_category,
      p_attribute1              => l_attribute1,
      p_attribute2              => l_attribute2,
      p_attribute3              => l_attribute3,
      p_attribute4              => l_attribute4,
      p_attribute5              => l_attribute5,
      p_attribute6              => l_attribute6,
      p_attribute7              => l_attribute7,
      p_attribute8              => l_attribute8,
      p_attribute9              => l_attribute9,
      p_attribute10             => l_attribute10,
      p_attribute11             => l_attribute11,
      p_attribute12             => l_attribute12,
      p_attribute13             => l_attribute13,
      p_attribute14             => l_attribute14,
      p_attribute15             => l_attribute15,
      p_translated_from_tmpl_id => l_translated_from_tmpl_id ,
      p_language		=> l_language
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
  -- Insert_Row for:OKC_TERMS_TEMPLATES_ALL --
  -------------------------------------
  FUNCTION Insert_Row(
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
    p_attribute_category      IN VARCHAR2,
    p_attribute1              IN VARCHAR2,
    p_attribute2              IN VARCHAR2,
    p_attribute3              IN VARCHAR2,
    p_attribute4              IN VARCHAR2,
    p_attribute5              IN VARCHAR2,
    p_attribute6              IN VARCHAR2,
    p_attribute7              IN VARCHAR2,
    p_attribute8              IN VARCHAR2,
    p_attribute9              IN VARCHAR2,
    p_attribute10             IN VARCHAR2,
    p_attribute11             IN VARCHAR2,
    p_attribute12             IN VARCHAR2,
    p_attribute13             IN VARCHAR2,
    p_attribute14             IN VARCHAR2,
    p_attribute15             IN VARCHAR2,
    p_object_version_number   IN NUMBER,
    p_created_by              IN NUMBER,
    p_creation_date           IN DATE,
    p_last_updated_by         IN NUMBER,
    p_last_update_login       IN NUMBER,
    p_last_update_date        IN DATE,
    p_translated_from_tmpl_id IN NUMBER,
    p_language		      IN VARCHAR2

  ) RETURN VARCHAR2 IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3600: Entered Insert_Row function');
    END IF;

    INSERT INTO OKC_TERMS_TEMPLATES_ALL(
        TEMPLATE_NAME,
        TEMPLATE_ID,
        WORKING_COPY_FLAG,
        INTENT,
        STATUS_CODE,
        START_DATE,
        END_DATE,
        GLOBAL_FLAG,
        PARENT_TEMPLATE_ID,
        PRINT_TEMPLATE_ID,
        CONTRACT_EXPERT_ENABLED,
	   XPRT_CLAUSE_MANDATORY_FLAG, -- Added for 11.5.10+: Contract Expert Changes
	   XPRT_SCN_CODE, -- Added for 11.5.10+: Contract Expert Changes
        TEMPLATE_MODEL_ID,
        INSTRUCTION_TEXT,
        TMPL_NUMBERING_SCHEME,
        DESCRIPTION,
        APPROVAL_WF_KEY,
        CZ_EXPORT_WF_KEY,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        ORG_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
--MLS for templates
	TRANSLATED_FROM_TMPL_ID,
        LANGUAGE )
      VALUES (
        p_template_name,
        p_template_id,
        nvl(p_working_copy_flag,'N'),
        p_intent,
        p_status_code,
        TRUNC(p_start_date),
        TRUNC(p_end_date),
        nvl(p_global_flag,'N'),
        p_parent_template_id,
        p_print_template_id,
        nvl(p_contract_expert_enabled,'N'),
	   nvl(p_xprt_clause_mandatory_flag,'N'), -- Added for 11.5.10+ : Contract Expert Changes
	   p_xprt_scn_code, -- Added for 11.5.10+: Contract Expert Changes
        p_template_model_id,
        p_instruction_text,
        p_tmpl_numbering_scheme,
        p_description,
        p_approval_wf_key,
        p_cz_export_wf_key,
        p_orig_system_reference_code,
        p_orig_system_reference_id1,
        p_orig_system_reference_id2,
        p_org_id,
        p_attribute_category,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15,
        p_object_version_number,
        p_created_by,
        p_creation_date,
        p_last_updated_by,
        p_last_update_login,
        p_last_update_date,
--MLS for templates
	p_translated_from_tmpl_id,
        p_language );

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
  -- Insert_Row for:OKC_TERMS_TEMPLATES_ALL --
  -------------------------------------
  PROCEDURE Insert_Row(
    p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY VARCHAR2,

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
    p_xprt_clause_mandatory_flag IN VARCHAR2, -- Added for 11.5.10+ : Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2, -- Added for 11.5.10+ : Contract Expert Changes
    p_template_model_id       IN NUMBER,
    p_instruction_text        IN VARCHAR2,
    p_tmpl_numbering_scheme   IN NUMBER,
    p_description             IN VARCHAR2,
    p_approval_wf_key         IN VARCHAR2 := NULL,
    p_cz_export_wf_key        IN VARCHAR2 := NULL,
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
    p_translated_from_tmpl_id IN NUMBER,
    p_language 		      IN VARCHAR2,
    x_template_id             OUT NOCOPY NUMBER

  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_object_version_number   OKC_TERMS_TEMPLATES_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by              OKC_TERMS_TEMPLATES_ALL.CREATED_BY%TYPE;
    l_creation_date           OKC_TERMS_TEMPLATES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by         OKC_TERMS_TEMPLATES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login       OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date        OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_DATE%TYPE;
  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4200: Entered Insert_Row');
    END IF;

    --- Setting item attributes
    -- Set primary key value
    IF( p_template_id IS NULL ) THEN
      x_return_status := Get_Seq_Id(
        p_template_id => p_template_id,
        x_template_id => x_template_id
      );
      --- If any errors happen abort API
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
      x_template_id := p_template_id;
    END IF;

    -- Set Internal columns
    l_object_version_number   := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;


    --- Validate all non-missing attributes
    x_return_status := Validate_Record(
      p_validation_level   => p_validation_level,
      p_template_id             => x_template_id,
      p_template_name           => p_template_name,
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
      p_approval_wf_key         => p_description,
      p_cz_export_wf_key        => p_description,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
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
      p_translated_from_tmpl_id => p_translated_from_tmpl_id,
      p_language 		=> p_language
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
      p_template_id             => x_template_id,
      p_template_name           => p_template_name,
      p_working_copy_flag       => p_working_copy_flag,
      p_intent                  => p_intent,
      p_status_code             => p_status_code,
      p_start_date              => p_start_date,
      p_end_date                => p_end_date,
      p_global_flag             => p_global_flag,
      p_parent_template_id      => p_parent_template_id,
      p_print_template_id       => p_print_template_id,
      p_contract_expert_enabled => p_contract_expert_enabled,
	 p_xprt_clause_mandatory_flag => p_xprt_clause_mandatory_flag, -- Added for 11.5.10+ : Changes
	 p_xprt_scn_code            => p_xprt_scn_code, -- Added for 11.5.10+ : Changes
      p_template_model_id       => p_template_model_id,
      p_instruction_text        => p_instruction_text,
      p_tmpl_numbering_scheme   => p_tmpl_numbering_scheme,
      p_description             => p_description,
      p_approval_wf_key         => p_approval_wf_key,
      p_cz_export_wf_key        => p_cz_export_wf_key,
      p_orig_system_reference_code => p_orig_system_reference_code,
      p_orig_system_reference_id1 => p_orig_system_reference_id1,
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
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
      p_object_version_number   => l_object_version_number,
      p_created_by              => l_created_by,
      p_creation_date           => l_creation_date,
      p_last_updated_by         => l_last_updated_by,
      p_last_update_login       => l_last_update_login,
      p_last_update_date        => l_last_update_date,
      p_translated_from_tmpl_id => p_translated_from_tmpl_id,
      p_language 		=> p_language
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
  -- Lock_Row for:OKC_TERMS_TEMPLATES_ALL --
  -----------------------------------
  FUNCTION Lock_Row(
    p_template_id             IN NUMBER,
    p_object_version_number   IN NUMBER
  ) RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (cp_template_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_TERMS_TEMPLATES_ALL
     WHERE TEMPLATE_ID = cp_template_id
       AND ( object_version_number = cp_object_version_number
             OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_template_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_TERMS_TEMPLATES_ALL
     WHERE TEMPLATE_ID = cp_template_id;

    l_return_status                VARCHAR2(1);

    l_object_version_number       OKC_TERMS_TEMPLATES_ALL.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'4900: Entered Lock_Row');
    END IF;


    BEGIN

      OPEN lock_csr( p_template_id, p_object_version_number );
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

      OPEN lchk_csr(p_template_id);
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
  -- Lock_Row for:OKC_TERMS_TEMPLATES_ALL --
  -----------------------------------
  PROCEDURE Lock_Row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_template_id             IN NUMBER,
    p_object_version_number   IN NUMBER
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
      p_template_id             => p_template_id,
      p_object_version_number   => p_object_version_number
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
  -- Update_Row for:OKC_TERMS_TEMPLATES_ALL --
  -------------------------------------
  FUNCTION Update_Row(
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
    p_attribute_category      IN VARCHAR2,
    p_attribute1              IN VARCHAR2,
    p_attribute2              IN VARCHAR2,
    p_attribute3              IN VARCHAR2,
    p_attribute4              IN VARCHAR2,
    p_attribute5              IN VARCHAR2,
    p_attribute6              IN VARCHAR2,
    p_attribute7              IN VARCHAR2,
    p_attribute8              IN VARCHAR2,
    p_attribute9              IN VARCHAR2,
    p_attribute10             IN VARCHAR2,
    p_attribute11             IN VARCHAR2,
    p_attribute12             IN VARCHAR2,
    p_attribute13             IN VARCHAR2,
    p_attribute14             IN VARCHAR2,
    p_attribute15             IN VARCHAR2,
    p_object_version_number   IN NUMBER,
    p_created_by              IN NUMBER,
    p_creation_date           IN DATE,
    p_last_updated_by         IN NUMBER,
    p_last_update_login       IN NUMBER,
    p_last_update_date        IN DATE,
    p_translated_from_tmpl_id IN NUMBER,
    p_language 		      IN VARCHAR2

   ) RETURN VARCHAR2 IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'6400: Entered Update_Row');
    END IF;

    UPDATE OKC_TERMS_TEMPLATES_ALL
     SET TEMPLATE_NAME           = p_template_name,
         WORKING_COPY_FLAG       = NVL(p_working_copy_flag,'N'),
         INTENT                  = p_intent,
         STATUS_CODE             = p_status_code,
         START_DATE              = TRUNC(p_start_date),
         END_DATE                = TRUNC(p_end_date),
         GLOBAL_FLAG             = NVL(p_global_flag,'N'),
         PARENT_TEMPLATE_ID      = p_parent_template_id,
         PRINT_TEMPLATE_ID       = p_print_template_id,
         CONTRACT_EXPERT_ENABLED = NVL(p_contract_expert_enabled,'N'),
	    XPRT_CLAUSE_MANDATORY_FLAG = NVL(p_xprt_clause_mandatory_flag,'N'), -- Added for 11.5.10+: Contract Expert Changes
	    XPRT_SCN_CODE           = p_xprt_scn_code, -- Added for 11.5.10+: Contract Expert Changes
         TEMPLATE_MODEL_ID       = p_template_model_id,
         INSTRUCTION_TEXT        = p_instruction_text,
         TMPL_NUMBERING_SCHEME   = p_tmpl_numbering_scheme,
         DESCRIPTION             = p_description,
         APPROVAL_WF_KEY         = p_approval_wf_key,
         CZ_EXPORT_WF_KEY        = p_cz_export_wf_key,
         ORIG_SYSTEM_REFERENCE_CODE = p_orig_system_reference_code,
         ORIG_SYSTEM_REFERENCE_ID1 = p_orig_system_reference_id1,
         ORIG_SYSTEM_REFERENCE_ID2 = p_orig_system_reference_id2,
         ORG_ID                  = p_org_id,
         ATTRIBUTE_CATEGORY      = p_attribute_category,
         ATTRIBUTE1              = p_attribute1,
         ATTRIBUTE2              = p_attribute2,
         ATTRIBUTE3              = p_attribute3,
         ATTRIBUTE4              = p_attribute4,
         ATTRIBUTE5              = p_attribute5,
         ATTRIBUTE6              = p_attribute6,
         ATTRIBUTE7              = p_attribute7,
         ATTRIBUTE8              = p_attribute8,
         ATTRIBUTE9              = p_attribute9,
         ATTRIBUTE10             = p_attribute10,
         ATTRIBUTE11             = p_attribute11,
         ATTRIBUTE12             = p_attribute12,
         ATTRIBUTE13             = p_attribute13,
         ATTRIBUTE14             = p_attribute14,
         ATTRIBUTE15             = p_attribute15,
         OBJECT_VERSION_NUMBER   = p_object_version_number,
         LAST_UPDATED_BY         = p_last_updated_by,
         LAST_UPDATE_LOGIN       = p_last_update_login,
         LAST_UPDATE_DATE        = p_last_update_date,
--MLS for templates
	 TRANSLATED_FROM_TMPL_ID = p_translated_from_tmpl_id,
         LANGUAGE 		 = p_language
WHERE TEMPLATE_ID             = p_template_id;

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
  -- Update_Row for:OKC_TERMS_TEMPLATES_ALL --
  -------------------------------------
  PROCEDURE Update_Row(
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

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
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,
    p_org_id                  IN NUMBER   := NULL,

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
    p_translated_from_tmpl_id IN NUMBER,
    p_language 		      IN VARCHAR2,

    p_object_version_number   IN NUMBER

   ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_template_name           OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
    l_working_copy_flag       OKC_TERMS_TEMPLATES_ALL.WORKING_COPY_FLAG%TYPE;
    l_intent                  OKC_TERMS_TEMPLATES_ALL.INTENT%TYPE;
    l_status_code             OKC_TERMS_TEMPLATES_ALL.STATUS_CODE%TYPE;
    l_start_date              OKC_TERMS_TEMPLATES_ALL.START_DATE%TYPE;
    l_end_date                OKC_TERMS_TEMPLATES_ALL.END_DATE%TYPE;
    l_global_flag             OKC_TERMS_TEMPLATES_ALL.GLOBAL_FLAG%TYPE;
    l_parent_template_id      OKC_TERMS_TEMPLATES_ALL.PARENT_TEMPLATE_ID%TYPE;
    l_print_template_id       OKC_TERMS_TEMPLATES_ALL.PRINT_TEMPLATE_ID%TYPE;
    l_contract_expert_enabled OKC_TERMS_TEMPLATES_ALL.CONTRACT_EXPERT_ENABLED%TYPE;
    l_xprt_clause_mandatory_flag OKC_TERMS_TEMPLATES_ALL.XPRT_CLAUSE_MANDATORY_FLAG%TYPE; -- Added for 11.5.10+:Contract Expert Changes
    l_xprt_scn_code           OKC_TERMS_TEMPLATES_ALL.XPRT_SCN_CODE%TYPE; -- Added for 11.5.10+: Contract Expert Changes
    l_template_model_id       OKC_TERMS_TEMPLATES_ALL.TEMPLATE_MODEL_ID%TYPE;
    l_instruction_text        OKC_TERMS_TEMPLATES_ALL.INSTRUCTION_TEXT%TYPE;
    l_tmpl_numbering_scheme   OKC_TERMS_TEMPLATES_ALL.TMPL_NUMBERING_SCHEME%TYPE;
    l_description             OKC_TERMS_TEMPLATES_ALL.DESCRIPTION%TYPE;
    l_approval_wf_key         OKC_TERMS_TEMPLATES_ALL.APPROVAL_WF_KEY%TYPE;
    l_cz_export_wf_key        OKC_TERMS_TEMPLATES_ALL.CZ_EXPORT_WF_KEY%TYPE;
    l_orig_system_reference_code OKC_TERMS_TEMPLATES_ALL.ORIG_SYSTEM_REFERENCE_CODE%TYPE;
    l_orig_system_reference_id1 OKC_TERMS_TEMPLATES_ALL.ORIG_SYSTEM_REFERENCE_ID1%TYPE;
    l_orig_system_reference_id2 OKC_TERMS_TEMPLATES_ALL.ORIG_SYSTEM_REFERENCE_ID2%TYPE;
    l_org_id                  OKC_TERMS_TEMPLATES_ALL.ORG_ID%TYPE;
    l_attribute_category      OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE_CATEGORY%TYPE;
    l_attribute1              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE1%TYPE;
    l_attribute2              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE2%TYPE;
    l_attribute3              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE3%TYPE;
    l_attribute4              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE4%TYPE;
    l_attribute5              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE5%TYPE;
    l_attribute6              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE6%TYPE;
    l_attribute7              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE7%TYPE;
    l_attribute8              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE8%TYPE;
    l_attribute9              OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE9%TYPE;
    l_attribute10             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE10%TYPE;
    l_attribute11             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE11%TYPE;
    l_attribute12             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE12%TYPE;
    l_attribute13             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE13%TYPE;
    l_attribute14             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE14%TYPE;
    l_attribute15             OKC_TERMS_TEMPLATES_ALL.ATTRIBUTE15%TYPE;
    l_object_version_number   OKC_TERMS_TEMPLATES_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by              OKC_TERMS_TEMPLATES_ALL.CREATED_BY%TYPE;
    l_creation_date           OKC_TERMS_TEMPLATES_ALL.CREATION_DATE%TYPE;
    l_last_updated_by         OKC_TERMS_TEMPLATES_ALL.LAST_UPDATED_BY%TYPE;
    l_last_update_login       OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date        OKC_TERMS_TEMPLATES_ALL.LAST_UPDATE_DATE%TYPE;
    l_translated_from_tmpl_id OKC_TERMS_TEMPLATES_ALL.TRANSLATED_FROM_TMPL_ID%TYPE;
    l_language 		      OKC_TERMS_TEMPLATES_ALL.LANGUAGE%TYPE;

    l_xprt_enabled_flag  OKC_TERMS_TEMPLATES_ALL.contract_expert_enabled%TYPE;
    CURSOR c_template_xprt_enabled_csr IS
    SELECT contract_expert_enabled
    FROM   OKC_TERMS_TEMPLATES_ALL
    WHERE  template_id = p_template_id;

    l_msg_data  VARCHAR2(1000);
    l_msg_count NUMBER;

  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7000: Entered Update_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7100: Locking _B row');
    END IF;

    x_return_status := Lock_row(
      p_template_id             => p_template_id,
      p_object_version_number   => p_object_version_number
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
      p_orig_system_reference_id2 => p_orig_system_reference_id2,
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
      p_translated_from_tmpl_id => p_translated_from_tmpl_id,
      p_language 		=> p_language,
      p_object_version_number   => p_object_version_number,
      x_template_name           => l_template_name,
      x_working_copy_flag       => l_working_copy_flag,
      x_intent                  => l_intent,
      x_status_code             => l_status_code,
      x_start_date              => l_start_date,
      x_end_date                => l_end_date,
      x_global_flag             => l_global_flag,
      x_parent_template_id      => l_parent_template_id,
      x_print_template_id       => l_print_template_id,
      x_contract_expert_enabled => l_contract_expert_enabled,
	 x_xprt_clause_mandatory_flag => l_xprt_clause_mandatory_flag, -- Added for 11.5.10+: Contract Expert Changes
	 x_xprt_scn_code           => l_xprt_scn_code, -- Added for 11.5.10+: Contract Expert Changes
      x_template_model_id       => l_template_model_id,
      x_instruction_text        => l_instruction_text,
      x_tmpl_numbering_scheme   => l_tmpl_numbering_scheme,
      x_description             => l_description,
      x_approval_wf_key         => l_approval_wf_key,
      x_cz_export_wf_key        => l_cz_export_wf_key,
      x_orig_system_reference_code => l_orig_system_reference_code,
      x_orig_system_reference_id1 => l_orig_system_reference_id1,
      x_orig_system_reference_id2 => l_orig_system_reference_id2,
      x_org_id                  => l_org_id,
      x_attribute_category      => l_attribute_category,
      x_attribute1              => l_attribute1,
      x_attribute2              => l_attribute2,
      x_attribute3              => l_attribute3,
      x_attribute4              => l_attribute4,
      x_attribute5              => l_attribute5,
      x_attribute6              => l_attribute6,
      x_attribute7              => l_attribute7,
      x_attribute8              => l_attribute8,
      x_attribute9              => l_attribute9,
      x_attribute10             => l_attribute10,
      x_attribute11             => l_attribute11,
      x_attribute12             => l_attribute12,
      x_attribute13             => l_attribute13,
      x_attribute14             => l_attribute14,
      x_attribute15             => l_attribute15,
      x_translated_from_tmpl_id => l_translated_from_tmpl_id,
      x_language 		=> l_language
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
      p_template_id             => p_template_id,
      p_template_name           => l_template_name,
      p_working_copy_flag       => l_working_copy_flag,
      p_intent                  => l_intent,
      p_status_code             => l_status_code,
      p_start_date              => l_start_date,
      p_end_date                => l_end_date,
      p_global_flag             => l_global_flag,
      p_parent_template_id      => l_parent_template_id,
      p_print_template_id       => l_print_template_id,
      p_contract_expert_enabled => l_contract_expert_enabled,
	 p_xprt_clause_mandatory_flag => l_xprt_clause_mandatory_flag, -- Added for 11.5.10+: Contract Expert Changes
	 p_xprt_scn_code           => l_xprt_scn_code, -- Added for 11.5.10+: Contract Expert Changes
      p_template_model_id       => l_template_model_id,
      p_instruction_text        => l_instruction_text,
      p_tmpl_numbering_scheme   => l_tmpl_numbering_scheme,
      p_description             => l_description,
      p_approval_wf_key         => l_approval_wf_key,
      p_cz_export_wf_key        => l_cz_export_wf_key,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1 => l_orig_system_reference_id1,
      p_orig_system_reference_id2 => l_orig_system_reference_id2,
      p_org_id                  => l_org_id,
      p_attribute_category      => l_attribute_category,
      p_attribute1              => l_attribute1,
      p_attribute2              => l_attribute2,
      p_attribute3              => l_attribute3,
      p_attribute4              => l_attribute4,
      p_attribute5              => l_attribute5,
      p_attribute6              => l_attribute6,
      p_attribute7              => l_attribute7,
      p_attribute8              => l_attribute8,
      p_attribute9              => l_attribute9,
      p_attribute10             => l_attribute10,
      p_attribute11             => l_attribute11,
      p_attribute12             => l_attribute12,
      p_attribute13             => l_attribute13,
      p_attribute14             => l_attribute14,
      p_attribute15             => l_attribute15,
      p_translated_from_tmpl_id => l_translated_from_tmpl_id,
      p_language 		=> l_language
    );
    --- If any errors happen abort API
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

--Bug 4106468
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7450: Deleting expert Rule association');
    END IF;

    OPEN c_template_xprt_enabled_csr;
    FETCH c_template_xprt_enabled_csr INTO l_xprt_enabled_flag;
    CLOSE c_template_xprt_enabled_csr;

    IF (l_xprt_enabled_flag = 'Y' AND p_contract_expert_enabled = 'N' ) THEN
        -- Setting expert flag to 'N' by user should remove template - rule associations
        OKC_XPRT_TMPL_RULE_ASSNS_PVT.delete_template_rule_assns
        (
          p_api_version    => 1.0,
          p_init_msg_list  => FND_API.G_FALSE,
          p_commit         => FND_API.G_FALSE,
          p_template_id    => p_template_id,
          x_return_status  => x_return_status,
          x_msg_data       => l_msg_data,
          x_msg_count      => l_msg_count
         ) ;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7450: Deleting expert Rule association return_status:'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
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
      l_object_version_number := Nvl(p_object_version_number, 0) + 1;
    END IF;

    --------------------------------------------
    -- Call the Update_Row for each child record
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'7600: Updating Row');
    END IF;

    x_return_status := Update_Row(
      p_template_id             => p_template_id,
      p_template_name           => l_template_name,
      p_working_copy_flag       => l_working_copy_flag,
      p_intent                  => l_intent,
      p_status_code             => l_status_code,
      p_start_date              => l_start_date,
      p_end_date                => l_end_date,
      p_global_flag             => l_global_flag,
      p_parent_template_id      => l_parent_template_id,
      p_print_template_id       => l_print_template_id,
      p_contract_expert_enabled => l_contract_expert_enabled,
	 p_xprt_clause_mandatory_flag => l_xprt_clause_mandatory_flag, -- Added for 11.5.10+: Contract Expert Changes
	 p_xprt_scn_code           => l_xprt_scn_code, -- Added for 11.5.10+: Contract Expert Changes
      p_template_model_id       => l_template_model_id,
      p_instruction_text        => l_instruction_text,
      p_tmpl_numbering_scheme   => l_tmpl_numbering_scheme,
      p_description             => l_description,
      p_approval_wf_key         => l_approval_wf_key,
      p_cz_export_wf_key        => l_cz_export_wf_key,
      p_orig_system_reference_code => l_orig_system_reference_code,
      p_orig_system_reference_id1 => l_orig_system_reference_id1,
      p_orig_system_reference_id2 => l_orig_system_reference_id2,
      p_org_id                  => l_org_id,
      p_attribute_category      => l_attribute_category,
      p_attribute1              => l_attribute1,
      p_attribute2              => l_attribute2,
      p_attribute3              => l_attribute3,
      p_attribute4              => l_attribute4,
      p_attribute5              => l_attribute5,
      p_attribute6              => l_attribute6,
      p_attribute7              => l_attribute7,
      p_attribute8              => l_attribute8,
      p_attribute9              => l_attribute9,
      p_attribute10             => l_attribute10,
      p_attribute11             => l_attribute11,
      p_attribute12             => l_attribute12,
      p_attribute13             => l_attribute13,
      p_attribute14             => l_attribute14,
      p_attribute15             => l_attribute15,
      p_object_version_number   => l_object_version_number,
      p_created_by              => l_created_by,
      p_creation_date           => l_creation_date,
      p_last_updated_by         => l_last_updated_by,
      p_last_update_login       => l_last_update_login,
      p_last_update_date        => l_last_update_date,
      p_translated_from_tmpl_id => l_translated_from_tmpl_id,
      p_language 		=> l_language
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
  -- Delete_Row for:OKC_TERMS_TEMPLATES_ALL --
  -------------------------------------
  FUNCTION Delete_Row(
    p_template_id             IN NUMBER
  ) RETURN VARCHAR2 IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8200: Entered Delete_Row');
    END IF;

    DELETE FROM OKC_TERMS_TEMPLATES_ALL WHERE TEMPLATE_ID = p_TEMPLATE_ID;

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
  -- Delete_Row for:OKC_TERMS_TEMPLATES_ALL --
  -------------------------------------
  PROCEDURE Delete_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_template_id             IN NUMBER,
    p_object_version_number   IN NUMBER,
    p_delete_parent_yn        IN VARCHAR2 := 'N'  --If set to 'Y', delete template without checking for translated templates.
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_Delete_Row';
    l_template_model_id       OKC_TERMS_TEMPLATES_ALL.template_model_id%TYPE;
    l_orig_sys_ref            okc_exprt_import_refs.orig_sys_ref%TYPE;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(4000);
    l_status_code                         VARCHAR2(30);
    l_dummy_var               VARCHAR2(1);
    l_template_name           OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;

    CURSOR c_chk_template_csr IS
    SELECT template_model_id, status_code
    FROM   OKC_TERMS_TEMPLATES_ALL
    WHERE  template_id = p_template_id;

    CURSOR csr_template_model_details IS
    SELECT orig_sys_ref
      FROM cz_src_devl_projects_v
     WHERE product_key='510:'||p_template_id ;

    CURSOR c_chk_template_trans IS
    SELECT '!' , parent.template_name
      FROM okc_terms_templates_all translated,
           okc_terms_templates_all parent
     WHERE translated.translated_from_tmpl_id = p_template_id
     AND   parent.template_id = translated.translated_from_tmpl_id;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8800: Entered Delete_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8900: Locking _B row');
    END IF;

    --------------------------------------------
    -- check if template has any translated dependents
    l_dummy_var := '?';
    OPEN c_chk_template_trans;
      FETCH c_chk_template_trans INTO l_dummy_var,l_template_name;
    CLOSE c_chk_template_trans;

    IF (l_dummy_var = '!' AND p_delete_parent_yn = 'N') THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'8910: - Error:Template has translated references and cannot be deleted');
      END IF;
      Okc_Api.Set_Message(G_APP_NAME, 'OKC_TMPL_REF_DEL','TMPL1' , l_template_name);
      x_return_status := G_RET_STS_ERROR;
      RETURN ;
    END IF;

    --------------------------------------------


    --------------------------------------------
    -- check if template has model and if so get model details
    OPEN c_chk_template_csr;
      FETCH c_chk_template_csr INTO l_template_model_id, l_status_code;
    CLOSE c_chk_template_csr;

    IF l_template_model_id IS NOT NULL THEN
       OPEN csr_template_model_details;
          FETCH csr_template_model_details INTO l_orig_sys_ref;
       CLOSE csr_template_model_details;
    END IF; -- l_template_model_id is not null

    --------------------------------------------


    x_return_status := Lock_row(
      p_template_id             => p_template_id,
      p_object_version_number   => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9100: Removing _B row');
    END IF;
    x_return_status := Delete_Row( p_template_id => p_template_id );

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --------------------------------------------
    -- if template was expert enabled then delete the model
    -- bug 3420123
    --------------------------------------------

    --------------------------------------------
    -- Additionally delete the model only if the status is in DRAFT
    -- bug 3441068
    --------------------------------------------
    IF (l_orig_sys_ref IS NOT NULL AND l_template_model_id IS NOT NULL AND l_status_code = 'DRAFT') THEN
             -- delete old import
--Modified 11.5.10+ CE
                /* OKC_XPRT_CZ_INT_PVT.delete_model
                (p_api_version  => 1.0,
                 p_model_id => l_template_model_id,
                 p_orig_sys_ref => l_orig_sys_ref,
                 x_return_status => x_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data  => l_msg_data); */


              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF; -- delete model successful

             -- delete record from okc_exprt_import_refs
            /*    DELETE FROM okc_exprt_import_refs
                WHERE object_type_code = 'TEMPLATEMODEL'
                  AND model_id = l_template_model_id ; */

    END IF; -- template_model_id is NOT NULL

    --------------------------------------------


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

PROCEDURE Update_Template_Id(
          x_return_status         OUT NOCOPY VARCHAR2,
          p_old_template_id       IN NUMBER,
          p_new_template_id       IN NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'Update_Template_Id';
   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9700: Entered Update_Template_Id');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9800: Locking Row');
    END IF;
    --------------------------------------------
    Lock_Row(
      x_return_status         => x_return_status,
      p_template_id           => p_old_template_id,
      p_object_version_number => NULL
    );
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9900: Updating Row');
    END IF;
    UPDATE OKC_TERMS_TEMPLATES_ALL
     SET TEMPLATE_ID = p_new_template_id,
         WORKING_COPY_FLAG = 'N',
         PARENT_TEMPLATE_ID = NULL,
         STATUS_CODE = 'APPROVED',
         OBJECT_VERSION_NUMBER   = OBJECT_VERSION_NUMBER+1,
         LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
         LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID,
         LAST_UPDATE_DATE        = Sysdate
     WHERE template_id= p_old_template_id;
    --------------------------------------------
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'9910: Leaving Update_Template_Id');
    END IF;
   EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'9920: Leaving Update_Template_Id: G_EXCEPTION_UNEXPECTED_ERROR Exception');

      END IF;
    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'9930: Leaving Update_Template_Id because of EXCEPTION: '||sqlerrm);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
  END Update_Template_Id;



END OKC_TERMS_TEMPLATES_PVT;

/

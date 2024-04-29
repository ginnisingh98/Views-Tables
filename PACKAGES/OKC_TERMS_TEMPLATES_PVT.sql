--------------------------------------------------------
--  DDL for Package OKC_TERMS_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_TEMPLATES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVTERMTMPLS.pls 120.1 2005/06/07 04:05:09 appldev  $ */

  ---------------------------------------------------------------------------
  -- Record Types
  ---------------------------------------------------------------------------

  TYPE template_rec_type IS RECORD (
    template_id             OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE,
    template_name           OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE,
    intent                  OKC_TERMS_TEMPLATES_ALL.INTENT%TYPE,
    status_code             OKC_TERMS_TEMPLATES_ALL.STATUS_CODE%TYPE,
    start_date              OKC_TERMS_TEMPLATES_ALL.START_DATE%TYPE,
    end_date                OKC_TERMS_TEMPLATES_ALL.END_DATE%TYPE,
    instruction_text        OKC_TERMS_TEMPLATES_ALL.INSTRUCTION_TEXT%TYPE,
    description             OKC_TERMS_TEMPLATES_ALL.DESCRIPTION%TYPE,
    working_copy_flag       OKC_TERMS_TEMPLATES_ALL.WORKING_COPY_FLAG%TYPE,
    parent_template_id      OKC_TERMS_TEMPLATES_ALL.PARENT_TEMPLATE_ID%TYPE,
    print_Template_Id       OKC_TERMS_TEMPLATES_ALL.print_Template_Id%TYPE,
    global_flag             OKC_TERMS_TEMPLATES_ALL.global_flag%TYPE,
    contract_expert_enabled OKC_TERMS_TEMPLATES_ALL.contract_expert_enabled%TYPE,
    tmpl_numbering_scheme   OKC_TERMS_TEMPLATES_ALL.tmpl_numbering_scheme%TYPE,
    xprt_clause_mandatory_flag OKC_TERMS_TEMPLATES_ALL.xprt_clause_mandatory_flag%TYPE,
    xprt_scn_code           OKC_TERMS_TEMPLATES_ALL.xprt_scn_code%TYPE,
    template_model_id       OKC_TERMS_TEMPLATES_ALL.template_model_id%TYPE,
    approval_wf_key         OKC_TERMS_TEMPLATES_ALL.approval_wf_key%TYPE,
    cz_export_wf_key        OKC_TERMS_TEMPLATES_ALL.cz_export_wf_key%TYPE,
    orig_system_reference_code OKC_TERMS_TEMPLATES_ALL.orig_system_reference_code%TYPE,
    orig_system_reference_id1 OKC_TERMS_TEMPLATES_ALL.orig_system_reference_id1%TYPE,
    orig_system_reference_id2 OKC_TERMS_TEMPLATES_ALL.orig_system_reference_id2%TYPE,
    org_id                  OKC_TERMS_TEMPLATES_ALL.org_id%TYPE,
    attribute_category      OKC_TERMS_TEMPLATES_ALL.attribute_category%TYPE,
    attribute1              OKC_TERMS_TEMPLATES_ALL.attribute1%TYPE,
    attribute2              OKC_TERMS_TEMPLATES_ALL.attribute2%TYPE,
    attribute3              OKC_TERMS_TEMPLATES_ALL.attribute3%TYPE,
    attribute4              OKC_TERMS_TEMPLATES_ALL.attribute4%TYPE,
    attribute5              OKC_TERMS_TEMPLATES_ALL.attribute5%TYPE,
    attribute6              OKC_TERMS_TEMPLATES_ALL.attribute6%TYPE,
    attribute7              OKC_TERMS_TEMPLATES_ALL.attribute7%TYPE,
    attribute8              OKC_TERMS_TEMPLATES_ALL.attribute8%TYPE,
    attribute9              OKC_TERMS_TEMPLATES_ALL.attribute9%TYPE,
    attribute10             OKC_TERMS_TEMPLATES_ALL.attribute10%TYPE,
    attribute11             OKC_TERMS_TEMPLATES_ALL.attribute11%TYPE,
    attribute12             OKC_TERMS_TEMPLATES_ALL.attribute12%TYPE,
    attribute13             OKC_TERMS_TEMPLATES_ALL.attribute13%TYPE,
    attribute14             OKC_TERMS_TEMPLATES_ALL.attribute14%TYPE,
    attribute15             OKC_TERMS_TEMPLATES_ALL.attribute15%TYPE,
    translated_from_tmpl_id OKC_TERMS_TEMPLATES_ALL.translated_from_tmpl_id%TYPE,
    language                OKC_TERMS_TEMPLATES_ALL.language%TYPE);
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
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
    p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL, -- Added for 11.5.10+: Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2 := NULL, -- Added for 11.5.10: Contract Expert Changes
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
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_template_id             IN NUMBER,

    p_object_version_number   IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
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
    p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL, -- Added for 11.5.10+ : Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2 := NULL, -- Added for 11.5.10: Contract Expert Changes
    p_template_model_id       IN NUMBER,
    p_instruction_text        IN VARCHAR2,
    p_tmpl_numbering_scheme   IN NUMBER,
    p_description             IN VARCHAR2,
    p_approval_wf_key         IN VARCHAR2 := NULL,
    p_cz_export_wf_key        IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,
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
    p_translated_from_tmpl_id IN NUMBER := NULL,
    p_language                IN VARCHAR2 := NULL,

    p_object_version_number   IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_template_id             IN NUMBER,

    p_object_version_number   IN NUMBER,
    p_delete_parent_yn        IN VARCHAR2 := 'N'
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
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
    p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL, -- Added for 11.5.10+ : Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2 := NULL, -- Added for 11.5.10: Contract Expert Changes
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
  );

  FUNCTION get_rec (
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
    x_xprt_clause_mandatory_flag OUT NOCOPY VARCHAR2, -- Added for 11.5.10+ : Contract Expert Changes
    x_xprt_scn_code           OUT NOCOPY VARCHAR2, -- Added for 11.5.10: Contract Expert Changes
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

  ) RETURN VARCHAR2;

PROCEDURE Update_Template_Id(
          x_return_status         OUT NOCOPY VARCHAR2,
          p_old_template_id       IN NUMBER,
          p_new_template_id       IN NUMBER
  );

END OKC_TERMS_TEMPLATES_PVT;

 

/

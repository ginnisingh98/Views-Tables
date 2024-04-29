--------------------------------------------------------
--  DDL for Package OKC_TERMS_TEMPLATES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_TEMPLATES_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGTERMTMPLS.pls 120.1.12010000.2 2011/12/09 13:39:10 serukull ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE create_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_name           IN VARCHAR2,
    p_template_id             IN NUMBER := NULL,
    p_working_copy_flag       IN VARCHAR2,
    p_intent                  IN VARCHAR2,
    p_status_code             IN VARCHAR2,
    p_start_date              IN DATE,
    p_end_date                IN DATE,
    p_global_flag             IN VARCHAR2,
    p_parent_template_id      IN NUMBER,
    p_print_template_id       IN NUMBER,
    p_contract_expert_enabled IN VARCHAR2,
    p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL,
    p_xprt_scn_code           IN VARCHAR2 := NULL,
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
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id             IN NUMBER,

    p_object_version_number   IN NUMBER

    );

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
    p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL, -- Added for 11.5.10+: Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2 := NULL, -- Added for 11.5.10+: Contract Expert Changes
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

  PROCEDURE delete_template(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id             IN NUMBER,

    p_object_version_number   IN NUMBER
    );

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
    p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL, -- Added for 11.5.10+: Contract Expert Changes
    p_xprt_scn_code           IN VARCHAR2 := NULL, -- Added for 11.5.10+: Contract Expert Changes
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

END OKC_TERMS_TEMPLATES_GRP;

/

--------------------------------------------------------
--  DDL for Package OKC_TEMPLATE_USAGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TEMPLATE_USAGES_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGTMPLUSGS.pls 120.1.12010000.3 2012/06/14 09:11:58 nbingi ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

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
    --Fix for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 := 'Y',

    x_document_type          OUT NOCOPY VARCHAR2,
    x_document_id            OUT NOCOPY NUMBER,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id       IN NUMBER := NULL,
    p_contract_expert_finish_flag IN VARCHAR2 := NULL

    );

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,

    p_object_version_number  IN NUMBER

    );

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

    p_approval_abstract_text IN CLOB := NULL,
    p_contract_source_code   IN VARCHAR2 := NULL,
    p_authoring_party_code   IN VARCHAR2 := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
   --Fix for bug# 3990983
       p_source_change_allowed_flag IN VARCHAR2 := NULL,
    p_object_version_number  IN NUMBER := NULL,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id       IN NUMBER := NULL
    );

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
    );

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
    );

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

    p_document_number              IN VARCHAR2 := NULL
    );


  PROCEDURE set_contract_source_details(
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

    p_document_number              IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL

    );
END OKC_TEMPLATE_USAGES_GRP;

/

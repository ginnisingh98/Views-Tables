--------------------------------------------------------
--  DDL for Package OKC_TEMPLATE_USAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TEMPLATE_USAGES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVTMPLUSGS.pls 120.1.12010000.3 2012/06/14 09:07:55 nbingi ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
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
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2 :=  NULL,  --default based on doc_type
    p_contract_source_code   IN VARCHAR2 := 'STRUCTURED',
    p_approval_abstract_text IN CLOB := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
--added for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 := 'Y',
    x_document_type          OUT NOCOPY VARCHAR2,
    x_document_id            OUT NOCOPY NUMBER,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id      IN NUMBER := NULL,
    p_contract_expert_finish_flag IN VARCHAR2 := NULL
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,

    p_object_version_number  IN NUMBER
  );

  PROCEDURE update_row(
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

    p_object_version_number  IN NUMBER := NULL,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2 := NULL,  -- default- not updated.
    p_contract_source_code   IN VARCHAR2 := NULL,
    p_approval_abstract_text IN CLOB := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
--added for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 := NULL ,
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id      IN NUMBER := NULL
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,

    p_object_version_number  IN NUMBER
    , p_retain_lock_xprt_yn  IN VARCHAR2 := 'N'
  );

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
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1 IN NUMBER := NULL,
    p_orig_system_reference_id2 IN NUMBER := NULL,

    p_object_version_number  IN NUMBER,

--added for 10+ word integration and deviations report
    p_authoring_party_code   IN VARCHAR2 :=  NULL,  --default based on doc_type
    p_contract_source_code   IN VARCHAR2 := 'STRUCTURED',
    p_approval_abstract_text IN CLOB := NULL,
    p_autogen_deviations_flag IN VARCHAR2 := NULL,
--added for bug# 3990983
    p_source_change_allowed_flag IN VARCHAR2 := 'Y',
    p_lock_terms_flag        IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_contract_admin_id      IN NUMBER := NULL,
    p_legal_contact_id       IN NUMBER := NULL,
    p_locked_by_user_id      IN NUMBER := NULL
  );

  FUNCTION get_rec (
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
    x_authoring_party_code   OUT NOCOPY VARCHAR2 ,
    x_contract_source_code   OUT NOCOPY VARCHAR2 ,
    x_approval_abstract_text OUT NOCOPY CLOB ,
    x_autogen_deviations_flag OUT NOCOPY VARCHAR2 ,
--added for bug# 3990983
    x_source_change_allowed_flag OUT NOCOPY VARCHAR2 ,
    x_lock_terms_flag        OUT NOCOPY VARCHAR2,
    x_enable_reporting_flag  OUT NOCOPY VARCHAR2,
    x_contract_admin_id      OUT NOCOPY NUMBER,
    x_legal_contact_id       OUT NOCOPY NUMBER,
    x_locked_by_user_id      OUT NOCOPY NUMBER
  ) RETURN VARCHAR2;


  FUNCTION Create_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2;

  FUNCTION Restore_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                NUMBER
  ) RETURN VARCHAR2;

--This Function is called from Versioning API OKC_VERSION_PVT
-- to delete template usages for specified version of document

  FUNCTION Delete_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2;

  PROCEDURE Update_Template_Id(
            x_return_status         OUT NOCOPY VARCHAR2,
            p_old_template_id       IN NUMBER,
            p_new_template_id       IN NUMBER
    );
    PROCEDURE Delete_Set(
            x_return_status         OUT NOCOPY VARCHAR2,
            p_template_id           IN NUMBER
    );
END OKC_TEMPLATE_USAGES_PVT;

/

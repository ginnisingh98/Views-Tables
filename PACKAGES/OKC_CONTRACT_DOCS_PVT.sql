--------------------------------------------------------
--  DDL for Package OKC_CONTRACT_DOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CONTRACT_DOCS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVCONTRACTDOCS.pls 120.1 2006/02/21 16:15:53 vamuru noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
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

    p_primary_contract_doc_flag IN VARCHAR2 := 'N',
    p_mergeable_doc_flag        IN VARCHAR2 := 'N',

    x_business_document_type    OUT NOCOPY VARCHAR2,
    x_business_document_id      OUT NOCOPY NUMBER,
    x_business_document_version OUT NOCOPY NUMBER,
    x_attached_document_id      OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,

    p_object_version_number     IN NUMBER
  );

  PROCEDURE update_row(
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

    p_primary_contract_doc_flag IN VARCHAR2 :=NULL,
    p_mergeable_doc_flag        IN VARCHAR2 :=NULL,

    p_object_version_number     IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_business_document_type    IN VARCHAR2,
    p_business_document_id      IN NUMBER,
    p_business_document_version IN NUMBER,
    p_attached_document_id      IN NUMBER,

    p_object_version_number     IN NUMBER
  );

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

    p_primary_contract_doc_flag IN VARCHAR2 := 'N',
    p_mergeable_doc_flag        IN VARCHAR2 := 'N',

    p_object_version_number     IN NUMBER
  );

  FUNCTION get_rec (
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

  ) RETURN VARCHAR2;



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
 ) RETURN VARCHAR2;



END OKC_CONTRACT_DOCS_PVT;

 

/

--------------------------------------------------------
--  DDL for Package OKC_K_ARTICLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ARTICLES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVCATS.pls 120.0.12010000.4 2011/12/09 13:44:28 serukull ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_cat_type                   IN VARCHAR2 := NULL,-- Bug 3341342
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER   := NULL,
    p_source_flag                IN VARCHAR2 :=NULL,
    p_mandatory_yn               IN VARCHAR2 :='N',
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2 := NULL,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_amendment_operation_code   IN VARCHAR2 := NULL,
    p_article_version_id         IN NUMBER   := NULL,
    p_change_nonstd_yn           IN VARCHAR2 := 'N',
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1  IN NUMBER   := NULL,
    p_orig_system_reference_id2  IN NUMBER   := NULL,
    p_display_sequence           IN NUMBER   := NULL,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := 'N',
    p_summary_amend_operation_code  IN VARCHAR2 := NULL,
    p_ref_article_id                IN NUMBER := NULL,
    p_ref_article_version_id        IN NUMBER := NULL,
    p_mandatory_rwa               IN VARCHAR2 :=NULL,
    x_id                         OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER   := NULL,
    p_document_type              IN VARCHAR2 := NULL,
    p_document_id                IN NUMBER   := NULL,
    p_cle_id                     IN NUMBER   := NULL,
    p_source_flag                IN VARCHAR2 :=NULL,
    p_mandatory_yn               IN VARCHAR2 :=NULL,
    p_mandatory_rwa              IN VARCHAR2 :=NULL,
    p_scn_id                     IN NUMBER   := NULL,
    p_label                      IN VARCHAR2 := NULL,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_amendment_operation_code   IN VARCHAR2 := NULL,
    p_article_version_id         IN NUMBER   := NULL,
    p_change_nonstd_yn           IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1  IN NUMBER   := NULL,
    p_orig_system_reference_id2  IN NUMBER   := NULL,
    p_display_sequence           IN NUMBER   := NULL,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := NULL,
    p_summary_amend_operation_code  IN VARCHAR2 := NULL,
    p_ref_article_id                IN NUMBER := NULL,
    p_ref_article_version_id        IN NUMBER := NULL,
    p_object_version_number      IN NUMBER,
    p_last_amended_by            IN NUMBER := NULL,
    p_last_amendment_date        IN DATE := NULL
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
  );

  PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_scn_id                 IN NUMBER
  );

  PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_doc_type               IN  VARCHAR2,
    p_doc_id                 IN  NUMBER
   ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER   := NULL,
    p_source_flag                IN VARCHAR2 :=NULL,
    p_mandatory_yn               IN VARCHAR2 :='N',
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2 := NULL,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_amendment_operation_code   IN VARCHAR2 := NULL,
    p_article_version_id         IN NUMBER   := NULL,
    p_change_nonstd_yn           IN VARCHAR2 := 'N',
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1  IN NUMBER   := NULL,
    p_orig_system_reference_id2  IN NUMBER   := NULL,
    p_display_sequence           IN NUMBER   := NULL,
    p_attribute_category         IN VARCHAR2 := NULL,
    p_attribute1                 IN VARCHAR2 := NULL,
    p_attribute2                 IN VARCHAR2 := NULL,
    p_attribute3                 IN VARCHAR2 := NULL,
    p_attribute4                 IN VARCHAR2 := NULL,
    p_attribute5                 IN VARCHAR2 := NULL,
    p_attribute6                 IN VARCHAR2 := NULL,
    p_attribute7                 IN VARCHAR2 := NULL,
    p_attribute8                 IN VARCHAR2 := NULL,
    p_attribute9                 IN VARCHAR2 := NULL,
    p_attribute10                IN VARCHAR2 := NULL,
    p_attribute11                IN VARCHAR2 := NULL,
    p_attribute12                IN VARCHAR2 := NULL,
    p_attribute13                IN VARCHAR2 := NULL,
    p_attribute14                IN VARCHAR2 := NULL,
    p_attribute15                IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := 'N',
    p_summary_amend_operation_code  IN VARCHAR2 := NULL,
    p_ref_article_id                IN NUMBER := NULL,
    p_ref_article_version_id        IN NUMBER := NULL,
    p_object_version_number      IN NUMBER,
    p_mandatory_rwa              IN VARCHAR2
  );

  FUNCTION get_rec (
    p_id                         IN NUMBER,
    p_major_version              IN NUMBER := NULL,
    x_sav_sae_id                 OUT NOCOPY NUMBER,
    x_document_type              OUT NOCOPY VARCHAR2,
    x_document_id                OUT NOCOPY NUMBER,
    x_cle_id                     OUT NOCOPY NUMBER,
    x_source_flag                OUT NOCOPY VARCHAR2,
    x_mandatory_yn               OUT NOCOPY VARCHAR2,
    x_scn_id                     OUT NOCOPY NUMBER,
    x_label                      OUT NOCOPY VARCHAR2,
    x_amendment_description      OUT NOCOPY VARCHAR2,
    x_amendment_operation_code   OUT NOCOPY VARCHAR2,
    x_article_version_id         OUT NOCOPY NUMBER,
    x_change_nonstd_yn           OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY NUMBER,
    x_orig_system_reference_id2  OUT NOCOPY NUMBER,
    x_display_sequence           OUT NOCOPY NUMBER,
    x_attribute_category         OUT NOCOPY VARCHAR2,
    x_attribute1                 OUT NOCOPY VARCHAR2,
    x_attribute2                 OUT NOCOPY VARCHAR2,
    x_attribute3                 OUT NOCOPY VARCHAR2,
    x_attribute4                 OUT NOCOPY VARCHAR2,
    x_attribute5                 OUT NOCOPY VARCHAR2,
    x_attribute6                 OUT NOCOPY VARCHAR2,
    x_attribute7                 OUT NOCOPY VARCHAR2,
    x_attribute8                 OUT NOCOPY VARCHAR2,
    x_attribute9                 OUT NOCOPY VARCHAR2,
    x_attribute10                OUT NOCOPY VARCHAR2,
    x_attribute11                OUT NOCOPY VARCHAR2,
    x_attribute12                OUT NOCOPY VARCHAR2,
    x_attribute13                OUT NOCOPY VARCHAR2,
    x_attribute14                OUT NOCOPY VARCHAR2,
    x_attribute15                OUT NOCOPY VARCHAR2,
    x_print_text_yn              OUT NOCOPY VARCHAR2,
    x_summary_amend_operation_code  OUT NOCOPY VARCHAR2,
    x_ref_article_id                OUT NOCOPY NUMBER,
    x_ref_article_version_id        OUT NOCOPY NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER,
    x_created_by                 OUT NOCOPY NUMBER,
    x_creation_date              OUT NOCOPY DATE,
    x_last_updated_by            OUT NOCOPY NUMBER,
    x_last_update_login          OUT NOCOPY NUMBER,
    x_last_update_date           OUT NOCOPY DATE,
    x_last_amended_by            OUT NOCOPY NUMBER,
    x_last_amendment_date        OUT NOCOPY DATE,
    x_mandatory_rwa               OUT NOCOPY VARCHAR2

  ) RETURN VARCHAR2;

--This Function is called from Versioning API OKC_VERSION_PVT
-- Location:Base Table API
  FUNCTION Create_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2;

--This Function is called from Versioning API OKC_VERSION_PVT
-- Location:Base Table API
  FUNCTION Restore_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                NUMBER
  ) RETURN VARCHAR2;

--This Function is called from Versioning API OKC_VERSION_PVT
-- to delete articles for specified version of document

  FUNCTION Delete_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2;

END OKC_K_ARTICLES_PVT;

/
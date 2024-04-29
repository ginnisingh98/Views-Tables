--------------------------------------------------------
--  DDL for Package OKC_K_ARTICLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ARTICLES_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGCATS.pls 120.0.12010000.5 2013/11/29 13:45:12 serukull ship $ */

TYPE id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   PROCEDURE create_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                         IN VARCHAR2 := 'NORMAL', -- Other value 'AMEND'

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_cat_type                   IN VARCHAR2  := NULL,--Bug 3341342
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER    := NULL,
    p_source_flag                IN VARCHAR2  := NULL,
    p_mandatory_yn               IN VARCHAR2  := 'N',
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2 := NULL,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_article_version_id         IN NUMBER   := NULL,
    p_change_nonstd_yn           IN VARCHAR2 :='N',
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
    p_ref_article_id               IN NUMBER := NULL,
    p_ref_article_version_id       IN NUMBER := NULL,
    p_mandatory_rwa               IN VARCHAR2  := NULL,
    x_id                         OUT NOCOPY NUMBER
    );

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER
    );

  PROCEDURE update_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2 := NULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                         IN VARCHAR2 := 'NORMAL', -- Other value 'AMEND'
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER    := NULL,
    p_document_type              IN VARCHAR2  := NULL,
    p_document_id                IN NUMBER    := NULL,
    p_cle_id                     IN NUMBER    := NULL,
    p_source_flag                IN VARCHAR2  := Null,
    p_mandatory_yn               IN VARCHAR2  := NULL,
    p_mandatory_rwa               IN VARCHAR2  := NULL,
    p_scn_id                     IN NUMBER    := NULL,
    p_label                      IN VARCHAR2  := Null,
    p_amendment_description      IN VARCHAR2  := Null,
    p_article_version_id         IN NUMBER    := NULL,
    p_change_nonstd_yn           IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 :=NULL,
    p_orig_system_reference_id1  IN NUMBER   :=NULL,
    p_orig_system_reference_id2  IN NUMBER   :=NULL,
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
    p_ref_article_id               IN NUMBER := NULL,
    p_ref_article_version_id       IN NUMBER := NULL,
    p_object_version_number      IN NUMBER,
    p_lock_terms_yn                IN VARCHAR2 := 'N'
    );

  PROCEDURE delete_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                         IN VARCHAR2 := 'NORMAL', -- Other value 'AMEND'
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_super_user_yn              IN VARCHAR2 :='N',
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := 'N',
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_mandatory_clause_delete    IN VARCHAR2 := 'N' ,
    p_lock_terms_yn                IN VARCHAR2 := 'N'
    );

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_sav_sae_id                 IN NUMBER,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_cle_id                     IN NUMBER    := NULL,
    p_source_flag                IN VARCHAR2 := NULL,
    p_mandatory_yn               IN VARCHAR2 := 'N',
    p_scn_id                     IN NUMBER,
    p_label                      IN VARCHAR2 := NULL,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_amendment_operation_code   IN VARCHAR2 := NULL,
    p_article_version_id         IN NUMBER,
    p_change_nonstd_yn           IN VARCHAR2 := 'N',
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1  IN NUMBER   := NULL,
    p_orig_system_reference_id2  IN NUMBER   := NULL,
    p_display_sequence           IN NUMBER,
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
    p_summary_amend_operation_code IN VARCHAR2 := NULL,
    p_ref_article_id               IN NUMBER := NULL,
    p_ref_article_version_id       IN NUMBER := NULL,

    p_object_version_number      IN NUMBER,
   p_mandatory_rwa               IN VARCHAR2 := NULL
    );


   PROCEDURE delete_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                         IN VARCHAR2 := 'NORMAL', -- Other value 'AMEND'
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_super_user_yn              IN VARCHAR2 :='N',
    p_amendment_description      IN VARCHAR2 := NULL,
    p_print_text_yn              IN VARCHAR2 := 'N',
    p_id_tbl                     IN id_tbl_type,
    p_object_version_number      IN id_tbl_type,
    p_mandatory_clause_delete    IN VARCHAR2 := 'N' ,
    p_lock_terms_yn                IN VARCHAR2 := 'N'
    );


END OKC_K_ARTICLES_GRP;

/

--------------------------------------------------------
--  DDL for Package OKC_ARTICLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLES_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGARTS.pls 120.2.12010000.6 2011/03/23 10:28:47 kkolukul ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  TYPE variable_rec_type IS RECORD (
    variable_code                OKC_BUS_VARIABLES_B.variable_code%TYPE
    );

  TYPE variable_code_tbl_type is table of OKC_ARTICLE_VARIABLES.VARIABLE_CODE%TYPE INDEX BY BINARY_INTEGER;

 PROCEDURE parse_n_replace_text(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_article_text                 IN OUT NOCOPY CLOB,
    p_dest_clob                    IN OUT NOCOPY CLOB,
    p_calling_mode                 IN VARCHAR2 ,
    p_batch_number                 IN VARCHAR2 DEFAULT NULL, -- Bug 4659659
    p_replace_text                 IN VARCHAR2 := 'N',
    p_article_intent               IN VARCHAR2,
    p_language                     IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_variables_tbl                OUT NOCOPY variable_code_tbl_type
   ) ;

-- This API will be used for autogenerating the article number
-- This API can be invoked in Information Only mode to check the
-- document sequence type based on the parameter p_seq_type_info_only
-- This will be useful from the UI to check if autonumbering is set up
-- otherwise open up the region for manual entry of articles.

  PROCEDURE GET_ARTICLE_SEQ_NUMBER
       (p_article_number      IN VARCHAR2 := NULL,
        p_seq_type_info_only  IN VARCHAR2 := 'N',
        p_org_id              IN NUMBER,
        x_article_number      OUT NOCOPY VARCHAR2,
        x_doc_sequence_type   OUT NOCOPY VARCHAR2,
        x_return_status       OUT NOCOPY VARCHAR2
        ) ;

  PROCEDURE create_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_article_title              IN VARCHAR2,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
    x_article_id                 OUT NOCOPY NUMBER,
    x_article_number             OUT NOCOPY VARCHAR2,
    -- Article Version Attributes
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE DEFAULT NULL,
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
    p_v_orig_system_reference_code IN VARCHAR2,
    p_v_orig_system_reference_id1  IN VARCHAR2,
    p_v_orig_system_reference_id2  IN VARCHAR2,
    p_global_article_version_id    IN NUMBER := NULL,
    --Clause Editing
    p_edited_in_word               IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word         IN BLOB DEFAULT NULL,
    --CLM
    p_variable_code                IN VARCHAR2 DEFAULT NULL,
    x_article_version_id         OUT NOCOPY NUMBER
    );

  PROCEDURE lock_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_version_id         IN NUMBER,
    p_object_version_number      IN NUMBER := NULL

    );

  PROCEDURE update_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_cz_transfer_status_flag    IN VARCHAR2,
    p_object_version_number      IN NUMBER := NULL,
    -- Article Version Attributes
    p_article_version_id         IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE DEFAULT NULL,
    p_v_orig_system_reference_code IN VARCHAR2,
    p_v_orig_system_reference_id1  IN VARCHAR2,
    p_v_orig_system_reference_id2  IN VARCHAR2,
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

    p_v_object_version_number      IN NUMBER := NULL,
    --Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,
    --CLM
    p_variable_code                IN VARCHAR2 DEFAULT NULL
    );

  PROCEDURE delete_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_version_id         IN NUMBER,
    p_object_version_number      IN NUMBER := NULL
    );

  PROCEDURE validate_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_earlier_adoption_type           OUT NOCOPY VARCHAR2,
    x_earlier_version_id           OUT NOCOPY NUMBER,
    x_earlier_version_number     OUT NOCOPY NUMBER,
    p_article_id                 IN NUMBER,
    p_article_title              IN VARCHAR2,
    p_org_id                     IN NUMBER,
    p_article_number             IN VARCHAR2,
    p_standard_yn                IN VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_type               IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    -- Article Version Attributes
    p_article_version_id         IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE DEFAULT NULL,
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
    --Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,
    --CLM
    p_variable_code                IN VARCHAR2 DEFAULT NULL
    );


  PROCEDURE create_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_article_intent               IN VARCHAR2 := NULL,
    p_standard_yn                  IN VARCHAR2 := 'Y',
    p_global_article_version_id  IN NUMBER := NULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2 := NULL,
    p_reference_source           IN VARCHAR2 := NULL,
    p_reference_text             IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1  IN VARCHAR2 := NULL,
    p_orig_system_reference_id2  IN VARCHAR2 := NULL,
    p_additional_instructions    IN VARCHAR2 := NULL,
    p_variation_description      IN VARCHAR2 := NULL,
    p_date_published             IN DATE      DEFAULT NULL,

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
    --Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,
    --clm
    p_variable_code              IN VARCHAR2 DEFAULT NULL,
    x_article_version_id         OUT NOCOPY NUMBER

    );

  PROCEDURE lock_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_article_version_id         IN NUMBER,

    p_object_version_number      IN NUMBER := NULL

    );

  PROCEDURE update_article_version(
    p_api_version                IN NUMBER,
    p_init_msg_list              IN VARCHAR2 ,
    p_validation_level	        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                     IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_article_intent             IN VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1  IN VARCHAR2 := NULL,
    p_orig_system_reference_id2  IN VARCHAR2 := NULL,
    p_additional_instructions    IN VARCHAR2 := NULL,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE DEFAULT NULL,
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
    p_object_version_number      IN NUMBER := NULL,
    --Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,
    --clm
     p_variable_code              IN VARCHAR2 DEFAULT NULL
    );

  PROCEDURE validate_article_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_earlier_version_id         OUT NOCOPY NUMBER,
    x_earlier_version_number         OUT NOCOPY NUMBER,
    x_earlier_adoption_type           OUT NOCOPY VARCHAR2,
    p_article_version_id         IN NUMBER,
    p_article_id                 IN NUMBER,
    p_article_version_number     IN NUMBER,
    p_article_text               IN CLOB,
    p_provision_yn               IN VARCHAR2,
    p_insert_by_reference        IN VARCHAR2,
    p_lock_text                  IN VARCHAR2,
    p_global_yn                  IN VARCHAR2,
    p_article_language           IN VARCHAR2,
    p_article_status             IN VARCHAR2,
    p_sav_release                IN VARCHAR2,
    p_start_date                 IN DATE,
    p_end_date                   IN DATE,
    p_std_article_version_id     IN NUMBER,
    p_display_name               IN VARCHAR2,
    p_translated_yn              IN VARCHAR2,
    p_article_description        IN VARCHAR2,
    p_date_approved              IN DATE,
    p_default_section            IN VARCHAR2,
    p_reference_source           IN VARCHAR2,
    p_reference_text             IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN VARCHAR2,
    p_orig_system_reference_id2  IN VARCHAR2,
    p_additional_instructions    IN VARCHAR2,
    p_variation_description      IN VARCHAR2,
    p_date_published             IN DATE DEFAULT NULL,
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
    --Clause Editing
    p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	  p_article_text_in_word       IN BLOB DEFAULT NULL,
    --clm
    p_variable_code              IN VARCHAR2 DEFAULT NULL
    );

  PROCEDURE copy_article(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    p_article_version_id           IN NUMBER,
    p_new_article_title            IN VARCHAR2 := NULL,
    p_new_article_number           IN VARCHAR2 := NULL,
    p_create_standard_yn                  IN VARCHAR2 := 'N',
    p_copy_relationship_yn           IN VARCHAR2 := 'N',
    p_copy_folder_assoc_yn           IN VARCHAR2 := 'N',

    x_article_version_id           OUT NOCOPY NUMBER,
    x_article_id                   OUT NOCOPY NUMBER,
    x_article_number               OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2

    );

  PROCEDURE create_article_relationship(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2
  ) ;

  PROCEDURE delete_article_relationship(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_object_version_number IN NUMBER := NULL
  );

  PROCEDURE update_article_variables (
    p_article_version_id IN NUMBER,
    p_variable_code_tbl IN variable_code_tbl_type,
    p_do_dml         IN VARCHAR2 := 'Y', -- parameter used for import.
    x_variables_to_insert_tbl OUT NOCOPY variable_code_tbl_type,
    x_variables_to_delete_tbl OUT NOCOPY variable_code_tbl_type,
    x_return_status  OUT NOCOPY VARCHAR2) ;

-- Bug#3722445: The following API will be used by the Update Article UI to check if future approved versions exist
-- in which case, the UI will prevent further update to end date.

  PROCEDURE later_approved_exists
   (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_article_id                   IN NUMBER,
    p_start_date                   IN DATE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_yes_no                       OUT NOCOPY VARCHAR2);

END OKC_ARTICLES_GRP;

/

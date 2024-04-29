--------------------------------------------------------
--  DDL for Package OKC_TERMS_SECTIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_SECTIONS_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGSCNS.pls 120.0.12010000.3 2013/11/29 13:46:39 serukull ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

     TYPE id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


  PROCEDURE create_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                       IN VARCHAR2 :='NORMAL', --'AMEND' or 'NORMAL'
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER   := NULL,
    p_label                      IN VARCHAR2 := NULL,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2 := NULL,
    p_orig_system_reference_code IN VARCHAR2 := NULL,
    p_orig_system_reference_id1  IN NUMBER   := NULL,
    p_orig_system_reference_id2  IN NUMBER   := NULL,
    p_print_yn                   IN VARCHAR2 := 'Y',
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
    x_id                         OUT NOCOPY NUMBER
    );

  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2 := NULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                       IN VARCHAR2 :='NORMAL',-- 'AMEND' or 'NORMAL'
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER :=NULL,
    p_label                      IN VARCHAR2 :=NULL,
    p_scn_id                     IN NUMBER :=NULL,
    p_heading                    IN VARCHAR2 :=NULL,
    p_description                IN VARCHAR2 :=NULL,
    p_document_type              IN VARCHAR2 :=NULL,
    p_document_id                IN NUMBER :=NULL,
    p_scn_code                   IN VARCHAR2 :=NULL,
    p_amendment_description      IN VARCHAR2 :=NULL,
    p_orig_system_reference_code IN VARCHAR2 :=NULL,
    p_orig_system_reference_id1  IN NUMBER :=NULL,
    p_orig_system_reference_id2  IN NUMBER :=NULL,
    p_print_yn                   IN VARCHAR2 :=NULL,
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
    p_object_version_number      IN NUMBER,
    p_lock_terms_yn              IN VARCHAR2  := 'N'
    );


  PROCEDURE add_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2 := NULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_mode                       IN VARCHAR2 := 'NORMAL', -- 'NORMAL' or 'AMEND'
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER := NULL,
    p_ref_scn_id                   IN NUMBER,  -- Section ID fo section which was
                                         -- selected in UI to create new section
    p_ref_point                    IN VARCHAR2 := 'A',  --Possible values
                                        -- 'A'=After,'B'=Before,'S' = Subsection
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_print_yn                   IN VARCHAR2 := 'Y',
    p_amendment_description      IN VARCHAR2 := NULL,
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


  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2 := NULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                       IN VARCHAR2 := 'NORMAL', -- 'NORMAL' or 'AMEND'
    p_super_user_yn              IN  VARCHAR2 :='N',
    p_amendment_description        IN VARCHAR2 := NULL,
    p_id                         IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_lock_terms_yn              IN VARCHAR2  := 'N'
    );

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id                         IN NUMBER,
    p_section_sequence           IN NUMBER,
    p_label                      IN VARCHAR2,
    p_scn_id                     IN NUMBER,
    p_heading                    IN VARCHAR2,
    p_description                IN VARCHAR2,
    p_document_type              IN VARCHAR2,
    p_document_id                IN NUMBER,
    p_scn_code                   IN VARCHAR2,
    p_amendment_description      IN VARCHAR2,
    p_amendment_operation_code   IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2,
    p_orig_system_reference_id1  IN NUMBER,
    p_orig_system_reference_id2  IN NUMBER,
    p_print_yn                   IN VARCHAR2,
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
    p_object_version_number      IN NUMBER
    );

   PROCEDURE delete_sections(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2 := NULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mode                       IN VARCHAR2 := 'NORMAL', -- 'NORMAL' or 'AMEND'
    p_super_user_yn              IN  VARCHAR2 :='N',
    p_amendment_description        IN VARCHAR2 := NULL,
    p_id_tbl                         IN id_tbl_type,
    p_obj_vers_number_tbl      IN id_tbl_type,
    p_lock_terms_yn              IN VARCHAR2  := 'N'
    );

END OKC_TERMS_SECTIONS_GRP;

/

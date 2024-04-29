--------------------------------------------------------
--  DDL for Package OKC_REVIEW_UPLD_TERMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REVIEW_UPLD_TERMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVRUTS.pls 120.4 2006/04/12 18:01 vnanjang noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER,

    x_REVIEW_UPLD_TERMS_id OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,

    p_object_version_number    IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,

    p_document_id              IN NUMBER := NULL,
    p_document_type            IN VARCHAR2 := NULL,
    p_object_id                IN NUMBER := NULL,
    p_object_type              IN VARCHAR2 := NULL,
    p_object_title             IN CLOB := NULL,
    p_object_text              IN CLOB := NULL,
    p_parent_object_type       IN VARCHAR2 := NULL,
    p_parent_id                IN NUMBER := NULL,
    p_article_id               IN NUMBER := NULL,
    p_article_version_id       IN NUMBER := NULL,
    p_label                    IN VARCHAR2 := NULL,
    p_display_seq              IN NUMBER := NULL,
    p_action                   IN VARCHAR2 := NULL,
    p_error_message_count      IN NUMBER := NULL,
    p_warning_message_count    IN NUMBER := NULL,
    p_new_parent_id            IN NUMBER := NULL,
    p_upload_level             IN NUMBER := NULL,
    p_object_version_number    IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,

    p_object_version_number    IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_UPLD_TERMS_id IN NUMBER,
    p_document_id              IN NUMBER,
    p_document_type            IN VARCHAR2,
    p_object_id                IN NUMBER,
    p_object_type              IN VARCHAR2,
    p_object_title             IN CLOB,
    p_object_text              IN CLOB,
    p_parent_object_type       IN VARCHAR2,
    p_parent_id                IN NUMBER,
    p_article_id               IN NUMBER,
    p_article_version_id       IN NUMBER,
    p_label                    IN VARCHAR2,
    p_display_seq              IN NUMBER,
    p_action                   IN VARCHAR2,
    p_error_message_count      IN NUMBER,
    p_warning_message_count    IN NUMBER,
    p_new_parent_id            IN NUMBER,
    p_upload_level             IN NUMBER,

    p_object_version_number    IN NUMBER
  );

  FUNCTION get_rec (
    p_REVIEW_UPLD_TERMS_id IN NUMBER,

    x_document_id              OUT NOCOPY NUMBER,
    x_document_type            OUT NOCOPY VARCHAR2,
    x_object_id                OUT NOCOPY NUMBER,
    x_object_type              OUT NOCOPY VARCHAR2,
    x_object_title             OUT NOCOPY CLOB,
    x_object_text              OUT NOCOPY CLOB,
    x_parent_object_type       OUT NOCOPY VARCHAR2,
    x_parent_id                OUT NOCOPY NUMBER,
    x_article_id               OUT NOCOPY NUMBER,
    x_article_version_id       OUT NOCOPY NUMBER,
    x_label                    OUT NOCOPY VARCHAR2,
    x_display_seq              OUT NOCOPY NUMBER,
    x_action                   OUT NOCOPY VARCHAR2,
    x_error_message_count      OUT NOCOPY NUMBER,
    x_warning_message_count    OUT NOCOPY NUMBER,
    x_object_version_number    OUT NOCOPY NUMBER,
    x_new_parent_id            OUT NOCOPY NUMBER,
    x_upload_level             OUT NOCOPY NUMBER,
    x_created_by               OUT NOCOPY NUMBER,
    x_creation_date            OUT NOCOPY DATE,
    x_last_updated_by          OUT NOCOPY NUMBER,
    x_last_update_login        OUT NOCOPY NUMBER,
    x_last_update_date         OUT NOCOPY DATE

  ) RETURN VARCHAR2;


  PROCEDURE Accept_Changes (
      p_api_version      IN  NUMBER,
	 p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_mode             IN  VARCHAR2 := 'NORMAL', --other value 'AMEND',

      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,
      p_validate_commit  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_string IN VARCHAR2 := NULL,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
);

  PROCEDURE Reject_Changes (
      p_api_version      IN  NUMBER,
	 p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
);

  PROCEDURE Delete_uploaded_terms (
      p_api_version      IN  NUMBER,
	 p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	 p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,

      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
);

  PROCEDURE Sync_Review_Tables (
      p_api_version      IN  NUMBER,
	p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
	p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
	p_commit           IN  VARCHAR2 :=  FND_API.G_FALSE,
      p_validation_string IN VARCHAR2 := NULL,
      p_document_type     IN  VARCHAR2,
      p_document_id       IN  NUMBER,

      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER
);

/*
    -- PROCEDURE Create_Unassigned_Section
    -- creating un-assigned sections in a document
    */
    PROCEDURE Create_Unassigned_Section (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,

        p_document_type          IN  VARCHAR2,
        p_document_id            IN  NUMBER,
        p_new_parent_id     IN  NUMBER,
        x_scn_id            OUT NOCOPY NUMBER );


END OKC_REVIEW_UPLD_TERMS_PVT;

 

/

--------------------------------------------------------
--  DDL for Package OKC_ARTICLES_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLES_ALL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVARTS.pls 120.0.12010000.3 2011/03/23 08:32:26 kkolukul ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER := NULL,
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
    p_cz_transfer_status_flag    IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,

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

    x_article_number             OUT NOCOPY VARCHAR2,
    x_article_id                 OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,

    p_object_version_number      IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_article_intent                OUT NOCOPY VARCHAR2,

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
    p_cz_transfer_status_flag    IN VARCHAR2,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,

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

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_article_id                 IN NUMBER,

    p_object_version_number      IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,
    x_return_status                OUT NOCOPY VARCHAR2,
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
    p_cz_transfer_status_flag    IN VARCHAR2 := NULL,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,
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

    p_object_version_number      IN NUMBER := NULL
  );

  FUNCTION get_rec (
    p_article_id                 IN NUMBER,

    x_article_title              OUT NOCOPY VARCHAR2,
    x_org_id                     OUT NOCOPY NUMBER,
    x_article_number             OUT NOCOPY VARCHAR2,
    x_standard_yn                OUT NOCOPY VARCHAR2,
    x_article_intent             OUT NOCOPY VARCHAR2,
    x_article_language           OUT NOCOPY VARCHAR2,
    x_article_type               OUT NOCOPY VARCHAR2,
    x_orig_system_reference_code OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id1  OUT NOCOPY VARCHAR2,
    x_orig_system_reference_id2  OUT NOCOPY VARCHAR2,
    x_cz_transfer_status_flag    OUT NOCOPY VARCHAR2,
    x_program_id                 OUT NOCOPY NUMBER,
    x_program_login_id           OUT NOCOPY NUMBER,
    x_program_application_id     OUT NOCOPY NUMBER,
    x_request_id                 OUT NOCOPY NUMBER,
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
    x_object_version_number      OUT NOCOPY NUMBER,
    x_created_by                 OUT NOCOPY NUMBER,
    x_creation_date              OUT NOCOPY DATE,
    x_last_updated_by            OUT NOCOPY NUMBER,
    x_last_update_login          OUT NOCOPY NUMBER,
    x_last_update_date           OUT NOCOPY DATE

  ) RETURN VARCHAR2;

-- The following is a direct call to Validate Record without going through
-- get_rec as in validate_row. This API will be used by import and migration
-- only. In this API the actual values are being passed i.e. NULL is NULL and
-- hence should not be called with G_MISS_XXX

  FUNCTION Validate_Record (
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_import_action              IN VARCHAR2 := NULL,
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
    p_cz_transfer_status_flag    IN VARCHAR2 := NULL,
    p_program_id                 IN NUMBER := NULL,
    p_program_login_id           IN NUMBER := NULL,
    p_program_application_id     IN NUMBER := NULL,
    p_request_id                 IN NUMBER := NULL,
    p_attribute_category         IN VARCHAR2,
    p_attribute1                 IN VARCHAR2,
    p_attribute2                 IN VARCHAR2,
    p_attribute3                 IN VARCHAR2,
    p_attribute4                 IN VARCHAR2,
    p_attribute5                 IN VARCHAR2,
    p_attribute6                 IN VARCHAR2,
    p_attribute7                 IN VARCHAR2,
    p_attribute8                 IN VARCHAR2,
    p_attribute9                 IN VARCHAR2,
    p_attribute10                IN VARCHAR2,
    p_attribute11                IN VARCHAR2,
    p_attribute12                IN VARCHAR2,
    p_attribute13                IN VARCHAR2,
    p_attribute14                IN VARCHAR2,
    p_attribute15                IN VARCHAR2
  ) RETURN VARCHAR2;


END OKC_ARTICLES_ALL_PVT;

/

--------------------------------------------------------
--  DDL for Package OKC_ALLOWED_TMPL_USAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ALLOWED_TMPL_USAGES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVALDTMPLUSGS.pls 120.0 2005/05/25 22:44:39 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER := NULL,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    x_allowed_tmpl_usages_id OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,

    p_object_version_number  IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,

    p_template_id            IN NUMBER := NULL,
    p_document_type          IN VARCHAR2 := NULL,
    p_default_yn             IN VARCHAR2 := NULL,
    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,

    p_object_version_number  IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER
  );

  FUNCTION get_rec (
    p_allowed_tmpl_usages_id IN NUMBER,

    x_template_id            OUT NOCOPY NUMBER,
    x_document_type          OUT NOCOPY VARCHAR2,
    x_default_yn             OUT NOCOPY VARCHAR2,
    x_attribute_category     OUT NOCOPY VARCHAR2,
    x_attribute1             OUT NOCOPY VARCHAR2,
    x_attribute2             OUT NOCOPY VARCHAR2,
    x_attribute3             OUT NOCOPY VARCHAR2,
    x_attribute4             OUT NOCOPY VARCHAR2,
    x_attribute5             OUT NOCOPY VARCHAR2,
    x_attribute6             OUT NOCOPY VARCHAR2,
    x_attribute7             OUT NOCOPY VARCHAR2,
    x_attribute8             OUT NOCOPY VARCHAR2,
    x_attribute9             OUT NOCOPY VARCHAR2,
    x_attribute10            OUT NOCOPY VARCHAR2,
    x_attribute11            OUT NOCOPY VARCHAR2,
    x_attribute12            OUT NOCOPY VARCHAR2,
    x_attribute13            OUT NOCOPY VARCHAR2,
    x_attribute14            OUT NOCOPY VARCHAR2,
    x_attribute15            OUT NOCOPY VARCHAR2,
    x_object_version_number  OUT NOCOPY NUMBER,
    x_created_by             OUT NOCOPY NUMBER,
    x_creation_date          OUT NOCOPY DATE,
    x_last_updated_by        OUT NOCOPY NUMBER,
    x_last_update_login      OUT NOCOPY NUMBER,
    x_last_update_date       OUT NOCOPY DATE

  ) RETURN VARCHAR2;


END OKC_ALLOWED_TMPL_USAGES_PVT;

 

/

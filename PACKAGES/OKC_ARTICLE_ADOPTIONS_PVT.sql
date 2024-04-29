--------------------------------------------------------
--  DDL for Package OKC_ARTICLE_ADOPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLE_ADOPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVADPS.pls 120.0 2005/05/25 18:47:25 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_global_article_version_id IN NUMBER,
    p_adoption_type             IN VARCHAR2,
    p_local_org_id              IN NUMBER,
    p_local_article_version_id  IN NUMBER,
    p_adoption_status           IN VARCHAR2,



    x_global_article_version_id OUT NOCOPY NUMBER,
    x_local_org_id              OUT NOCOPY NUMBER,
    x_local_article_version_id  OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_global_article_version_id IN NUMBER,
    p_local_org_id              IN NUMBER,
    p_local_article_version_id  IN NUMBER,

    p_object_version_number     IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_global_article_version_id IN NUMBER,
    p_adoption_type             IN VARCHAR2,
    p_local_org_id              IN NUMBER,
    p_orig_local_version_id  IN NUMBER,
    p_new_local_version_id  IN NUMBER,
    p_adoption_status           IN VARCHAR2,



    p_object_version_number     IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_global_article_version_id IN NUMBER,
    p_local_org_id              IN NUMBER,
    p_local_article_version_id  IN NUMBER,

    p_object_version_number     IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_global_article_version_id IN NUMBER,
    p_adoption_type             IN VARCHAR2,
    p_local_org_id              IN NUMBER,
    p_local_article_version_id  IN NUMBER,
    p_adoption_status           IN VARCHAR2,



    p_object_version_number     IN NUMBER
  );

  FUNCTION get_rec (
    p_global_article_version_id IN OUT NOCOPY NUMBER,
    p_local_org_id              IN NUMBER,
    p_local_article_version_id  IN NUMBER,

    x_adoption_type             OUT NOCOPY VARCHAR2,
    x_adoption_status           OUT NOCOPY VARCHAR2,
    x_object_version_number     OUT NOCOPY NUMBER,
    x_created_by                OUT NOCOPY NUMBER,
    x_creation_date             OUT NOCOPY DATE,
    x_last_updated_by           OUT NOCOPY NUMBER,
    x_last_update_login         OUT NOCOPY NUMBER,
    x_last_update_date          OUT NOCOPY DATE

  ) RETURN VARCHAR2;



END OKC_ARTICLE_ADOPTIONS_PVT;

 

/

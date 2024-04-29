--------------------------------------------------------
--  DDL for Package OKC_ARTICLE_RELATIONSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLE_RELATIONSHIPS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVARLS.pls 120.0 2005/05/25 22:41:15 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,



    x_source_article_id     OUT NOCOPY NUMBER,
    x_target_article_id     OUT NOCOPY NUMBER,
    x_org_id                OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,

    p_object_version_number IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,



    p_object_version_number IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,

    p_object_version_number IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,
    p_relationship_type     IN VARCHAR2,



    p_object_version_number IN NUMBER
  );

  FUNCTION get_rec (
    p_source_article_id     IN NUMBER,
    p_target_article_id     IN NUMBER,
    p_org_id                IN NUMBER,

    x_relationship_type     OUT NOCOPY VARCHAR2,
    x_object_version_number OUT NOCOPY NUMBER,
    x_created_by            OUT NOCOPY NUMBER,
    x_creation_date         OUT NOCOPY DATE,
    x_last_updated_by       OUT NOCOPY NUMBER,
    x_last_update_login     OUT NOCOPY NUMBER,
    x_last_update_date      OUT NOCOPY DATE

  ) RETURN VARCHAR2;



END OKC_ARTICLE_RELATIONSHIPS_PVT;

 

/

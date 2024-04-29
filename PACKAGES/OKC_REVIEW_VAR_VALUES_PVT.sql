--------------------------------------------------------
--  DDL for Package OKC_REVIEW_VAR_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REVIEW_VAR_VALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVRUVS.pls 120.2 2005/09/13 22:37 vnanjang noship $ */
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_review_upld_terms_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,

    p_attribute_value_set_id    IN NUMBER := NULL,

    x_review_upld_terms_id  OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_terms_id  IN NUMBER,

    p_object_version_number     IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_terms_id  IN NUMBER,

    p_REVIEW_VAR_VALUES_id IN NUMBER := NULL,
    p_variable_name             IN VARCHAR2 := NULL,
    p_variable_code             IN VARCHAR2 := NULL,
    p_variable_type             IN VARCHAR2 := NULL,
    p_variable_value_id         IN NUMBER := NULL,
    p_variable_value            IN VARCHAR2 := NULL,
    p_attribute_value_set_id    IN NUMBER := NULL,

    p_object_version_number     IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_terms_id  IN NUMBER,

    p_object_version_number     IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_REVIEW_VAR_VALUES_id IN NUMBER,
    p_review_upld_terms_id  IN NUMBER,
    p_variable_name             IN VARCHAR2,
    p_variable_code             IN VARCHAR2,
    p_variable_type             IN VARCHAR2,
    p_variable_value_id         IN NUMBER,
    p_variable_value            IN VARCHAR2,

    p_attribute_value_set_id    IN NUMBER := NULL,

    p_object_version_number     IN NUMBER
  );

  FUNCTION get_rec (
    p_review_upld_terms_id  IN NUMBER,

    x_REVIEW_VAR_VALUES_id OUT NOCOPY NUMBER,
    x_variable_name             OUT NOCOPY VARCHAR2,
    x_variable_code             OUT NOCOPY VARCHAR2,
    x_variable_type             OUT NOCOPY VARCHAR2,
    x_variable_value_id         OUT NOCOPY NUMBER,
    x_variable_value            OUT NOCOPY VARCHAR2,
    x_attribute_value_set_id    OUT NOCOPY NUMBER,
    x_object_version_number     OUT NOCOPY NUMBER,
    x_created_by                OUT NOCOPY NUMBER,
    x_creation_date             OUT NOCOPY DATE,
    x_last_updated_by           OUT NOCOPY NUMBER,
    x_last_update_login         OUT NOCOPY NUMBER,
    x_last_update_date          OUT NOCOPY DATE,
    x_language                  OUT NOCOPY VARCHAR2

  ) RETURN VARCHAR2;



END OKC_REVIEW_VAR_VALUES_PVT;


 

/

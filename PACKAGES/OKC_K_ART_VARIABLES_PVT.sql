--------------------------------------------------------
--  DDL for Package OKC_K_ART_VARIABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ART_VARIABLES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVVARS.pls 120.0.12010000.6 2011/12/09 13:54:08 serukull ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER := NULL,
    p_override_global_yn     IN VARCHAR2 :='N',
    p_global_variable_value  IN VARCHAR2 := NULL,
    p_global_var_value_id    IN NUMBER := NULL,
    x_cat_id                 OUT NOCOPY NUMBER,
    x_variable_code          OUT NOCOPY VARCHAR2
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_object_version_number  IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2 :=NULL,
    p_external_yn            IN VARCHAR2 := NULL,
    p_variable_value_id      IN VARCHAR2 := NULL,
    p_variable_value         IN VARCHAR2 := NULL,
    p_attribute_value_set_id IN NUMBER := NULL,
    p_override_global_yn       IN VARCHAR2 := NULL,
    p_object_version_number  IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_object_version_number  IN NUMBER
  );

  PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER
  );

  PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_scn_id                 IN NUMBER
  );

  PROCEDURE delete_set(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_doc_type               IN VARCHAR2,
    p_doc_id                 IN NUMBER
   ,p_retain_lock_terms_yn   IN VARCHAR2 := 'N'
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    p_variable_type          IN VARCHAR2,
    p_external_yn            IN VARCHAR2,
    p_variable_value_id      IN VARCHAR2,
    p_variable_value         IN VARCHAR2,
    p_attribute_value_set_id IN NUMBER ,
    p_override_global_yn       IN VARCHAR2,
    p_object_version_number  IN NUMBER
  );

  FUNCTION get_rec (
    p_cat_id                 IN NUMBER,
    p_variable_code          IN VARCHAR2,
    x_variable_type          OUT NOCOPY VARCHAR2,
    x_external_yn            OUT NOCOPY VARCHAR2,
    x_variable_value_id      OUT NOCOPY VARCHAR2,
    x_variable_value         OUT NOCOPY VARCHAR2,
    x_attribute_value_set_id OUT NOCOPY NUMBER,
    x_override_global_yn       OUT NOCOPY VARCHAR2,
    x_object_version_number  OUT NOCOPY NUMBER,
    x_created_by             OUT NOCOPY NUMBER,
    x_creation_date          OUT NOCOPY DATE,
    x_last_updated_by        OUT NOCOPY NUMBER,
    x_last_update_login      OUT NOCOPY NUMBER,
    x_last_update_date       OUT NOCOPY DATE

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
-- to delete variables for specified version of document

  FUNCTION Delete_Version(
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_major_version                IN NUMBER
  ) RETURN VARCHAR2;

  -- This Function is called from OKC_TERMS_COPY_PVT.copy_archived_doc and from this API
  PROCEDURE restore_mrv_uda_data_version(p_cat_id IN NUMBER,p_major_version IN NUMBER);

END OKC_K_ART_VARIABLES_PVT;

/

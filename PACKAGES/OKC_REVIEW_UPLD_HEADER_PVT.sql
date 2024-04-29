--------------------------------------------------------
--  DDL for Package OKC_REVIEW_UPLD_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REVIEW_UPLD_HEADER_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVRUHS.pls 120.0 2005/09/13 22:42 vnanjang noship $ */
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

 ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_header_id IN NUMBER,
    p_file_name              IN VARCHAR2,
    p_file_content_type      IN VARCHAR2,
    p_file_data              IN BLOB,
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_new_contract_source    IN VARCHAR2,
    p_enable_reporting_flag  IN VARCHAR2,
    p_file_description       IN VARCHAR2,



    x_review_upld_header_id OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_header_id IN NUMBER,

    p_object_version_number  IN NUMBER
  );

  PROCEDURE Update_Row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_header_id IN NUMBER,

    p_file_name              IN VARCHAR2 := NULL,
    p_file_content_type      IN VARCHAR2 := NULL,
    p_file_data              IN BLOB := NULL,
    p_document_type          IN VARCHAR2 := NULL,
    p_document_id            IN NUMBER := NULL,

    p_object_version_number  IN NUMBER,
    p_new_contract_source    IN VARCHAR2 := NULL,
    p_enable_reporting_flag  IN VARCHAR2 := NULL,
    p_file_description       IN VARCHAR2 := NULL
  );




  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_header_id IN NUMBER,

    p_object_version_number  IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_review_upld_header_id IN NUMBER,
    p_file_name              IN VARCHAR2,
    p_file_content_type      IN VARCHAR2,
    p_file_data              IN BLOB,
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_new_contract_source    IN VARCHAR2,
    p_enable_reporting_flag  IN VARCHAR2,
    p_file_description       IN VARCHAR2,


    p_object_version_number  IN NUMBER
  );

  FUNCTION get_rec (
    p_review_upld_header_id IN NUMBER,

    x_file_name              OUT NOCOPY VARCHAR2,
    x_file_content_type      OUT NOCOPY VARCHAR2,
    x_file_data              OUT NOCOPY BLOB,
    x_document_type          OUT NOCOPY VARCHAR2,
    x_document_id            OUT NOCOPY NUMBER,
    x_object_version_number  OUT NOCOPY NUMBER,
    x_created_by             OUT NOCOPY NUMBER,
    x_creation_date          OUT NOCOPY DATE,
    x_last_updated_by        OUT NOCOPY NUMBER,
    x_last_update_login      OUT NOCOPY NUMBER,
    x_last_update_date       OUT NOCOPY DATE,
    x_new_contract_source    OUT NOCOPY VARCHAR2,
    x_enable_reporting_flag  OUT NOCOPY VARCHAR2,
    x_file_description       OUT NOCOPY VARCHAR2

  ) RETURN VARCHAR2;




END OKC_REVIEW_UPLD_HEADER_PVT;


 

/

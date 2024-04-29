--------------------------------------------------------
--  DDL for Package OKC_DOC_QA_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DOC_QA_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVQALS.pls 120.0 2005/05/26 09:39:26 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,

    x_qa_code               OUT NOCOPY VARCHAR2,
    x_document_type         OUT NOCOPY VARCHAR2
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,

    p_object_version_number IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2 := NULL,
    p_enable_qa_yn          IN VARCHAR2 := NULL,

    p_object_version_number IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,

    p_object_version_number IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,

    p_object_version_number IN NUMBER
  );

  FUNCTION get_rec (
    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,

    x_severity_flag         OUT NOCOPY VARCHAR2,
    x_enable_qa_yn          OUT NOCOPY VARCHAR2,
    x_object_version_number OUT NOCOPY NUMBER,
    x_created_by            OUT NOCOPY NUMBER,
    x_creation_date         OUT NOCOPY DATE,
    x_last_updated_by       OUT NOCOPY NUMBER,
    x_last_update_login     OUT NOCOPY NUMBER,
    x_last_update_date      OUT NOCOPY DATE

  ) RETURN VARCHAR2;



END OKC_DOC_QA_LIST_PVT;

 

/

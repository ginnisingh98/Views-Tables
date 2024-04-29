--------------------------------------------------------
--  DDL for Package OKC_NUMBER_SCHEME_DTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_NUMBER_SCHEME_DTL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVNSDS.pls 120.0 2005/05/25 19:02:26 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    x_num_scheme_id         OUT NOCOPY NUMBER,
    x_num_sequence_code     OUT NOCOPY VARCHAR2,
    x_sequence_level        OUT NOCOPY NUMBER
  );

  PROCEDURE lock_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,

    p_object_version_number IN NUMBER
  );

  PROCEDURE update_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2 := NULL,
    p_end_character         IN VARCHAR2 := NULL,



    p_object_version_number IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,

    p_object_version_number IN NUMBER
  );

  PROCEDURE delete_set(
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER
  );

  PROCEDURE validate_row(
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    p_object_version_number IN NUMBER
  );

  FUNCTION get_rec (
    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,

    x_concatenation_yn      OUT NOCOPY VARCHAR2,
    x_end_character         OUT NOCOPY VARCHAR2,
    x_object_version_number OUT NOCOPY NUMBER,
    x_created_by            OUT NOCOPY NUMBER,
    x_creation_date         OUT NOCOPY DATE,
    x_last_updated_by       OUT NOCOPY NUMBER,
    x_last_update_login     OUT NOCOPY NUMBER,
    x_last_update_date      OUT NOCOPY DATE

  ) RETURN VARCHAR2;



END OKC_NUMBER_SCHEME_DTL_PVT;

 

/

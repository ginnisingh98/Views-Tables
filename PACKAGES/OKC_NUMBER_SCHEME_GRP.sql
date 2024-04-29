--------------------------------------------------------
--  DDL for Package OKC_NUMBER_SCHEME_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_NUMBER_SCHEME_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGNSMS.pls 120.2 2005/10/04 15:26:27 ausmani noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE generate_preview(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_out_string                   OUT NOCOPY VARCHAR2,
    p_update_db                    IN  VARCHAR2 := FND_API.G_FALSE,

    p_num_scheme_id         IN NUMBER
      );

  PROCEDURE apply_numbering_scheme(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_num_scheme_id                IN NUMBER
      );

  FUNCTION Ok_To_Delete(
    p_num_scheme_id         IN NUMBER
  ) RETURN VARCHAR2;

  PROCEDURE apply_num_scheme_4_Review(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_validate_commit              IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_string            IN VARCHAR2,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,
    p_doc_type                     IN VARCHAR2,
    p_doc_id                       IN NUMBER,
    p_num_scheme_id                IN NUMBER
      );
FUNCTION GETALPHABET(seq_number number,type varchar2) return varchar2;
END OKC_NUMBER_SCHEME_GRP;

 

/

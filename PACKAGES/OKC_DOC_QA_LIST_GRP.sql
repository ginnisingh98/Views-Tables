--------------------------------------------------------
--  DDL for Package OKC_DOC_QA_LIST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DOC_QA_LIST_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGQALS.pls 120.0 2005/05/26 09:56:02 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE Insert_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,



    x_qa_code               OUT NOCOPY VARCHAR2,
    x_document_type         OUT NOCOPY VARCHAR2

    );

  PROCEDURE Lock_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,

    p_object_version_number IN NUMBER

    );

  PROCEDURE Update_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,



    p_object_version_number IN NUMBER
    );

  PROCEDURE Delete_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,

    p_object_version_number IN NUMBER
    );

  PROCEDURE Validate_Doc_Qa_List(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_qa_code               IN VARCHAR2,
    p_document_type         IN VARCHAR2,
    p_severity_flag         IN VARCHAR2,
    p_enable_qa_yn          IN VARCHAR2,



    p_object_version_number IN NUMBER
    );

END OKC_DOC_QA_LIST_GRP;

 

/

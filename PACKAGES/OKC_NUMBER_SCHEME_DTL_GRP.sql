--------------------------------------------------------
--  DDL for Package OKC_NUMBER_SCHEME_DTL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_NUMBER_SCHEME_DTL_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGNSDS.pls 120.0 2005/05/26 09:36:11 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE Insert_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    x_num_scheme_id         OUT NOCOPY NUMBER,
    x_num_sequence_code     OUT NOCOPY VARCHAR2,
    x_sequence_level        OUT NOCOPY NUMBER

    );

  PROCEDURE Lock_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,

    p_object_version_number IN NUMBER

    );

  PROCEDURE Update_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    p_object_version_number IN NUMBER
    );

  PROCEDURE Delete_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,

    p_object_version_number IN NUMBER
    );

  PROCEDURE Validate_Number_Scheme_Dtl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_num_scheme_id         IN NUMBER,
    p_num_sequence_code     IN VARCHAR2,
    p_sequence_level        IN NUMBER,
    p_concatenation_yn      IN VARCHAR2,
    p_end_character         IN VARCHAR2,



    p_object_version_number IN NUMBER
    );

END OKC_NUMBER_SCHEME_DTL_GRP;

 

/

--------------------------------------------------------
--  DDL for Package OKC_PAA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PAA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSPAAS.pls 120.0 2005/05/26 09:34:55 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE paa_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    pat_id                         NUMBER := OKC_API.G_MISS_NUM,
    flex_title                     OKC_PRICE_ADJ_ATTRIBS.FLEX_TITLE%TYPE := OKC_API.G_MISS_CHAR,
    pricing_context                OKC_PRICE_ADJ_ATTRIBS.PRICING_CONTEXT%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute              OKC_PRICE_ADJ_ATTRIBS.PRICING_ATTRIBUTE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PRICE_ADJ_ATTRIBS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PRICE_ADJ_ATTRIBS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    pricing_attr_value_from        OKC_PRICE_ADJ_ATTRIBS.PRICING_ATTR_VALUE_FROM%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attr_value_to          OKC_PRICE_ADJ_ATTRIBS.PRICING_ATTR_VALUE_TO%TYPE := OKC_API.G_MISS_CHAR,
    comparison_operator            OKC_PRICE_ADJ_ATTRIBS.COMPARISON_OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    program_application_id        NUMBER := OKC_API.G_MISS_NUM,
    program_id                      NUMBER := OKC_API.G_MISS_NUM,
    program_update_date             OKC_PRICE_ADJ_ATTRIBS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    request_id                      NUMBER := OKC_API.G_MISS_NUM,
    object_version_number           NUMBER := OKC_API.G_MISS_NUM);
 g_miss_paa_rec                          paa_rec_type;
  TYPE paa_tbl_type IS TABLE OF paa_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE paav_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    pat_id                         NUMBER := OKC_API.G_MISS_NUM,
    flex_title                     OKC_PRICE_ADJ_ATTRIBS_V.FLEX_TITLE%TYPE := OKC_API.G_MISS_CHAR,
    pricing_context                OKC_PRICE_ADJ_ATTRIBS_V.PRICING_CONTEXT%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attribute              OKC_PRICE_ADJ_ATTRIBS_V.PRICING_ATTRIBUTE%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attr_value_from        OKC_PRICE_ADJ_ATTRIBS_V.PRICING_ATTR_VALUE_FROM%TYPE := OKC_API.G_MISS_CHAR,
    pricing_attr_value_to          OKC_PRICE_ADJ_ATTRIBS_V.PRICING_ATTR_VALUE_TO%TYPE := OKC_API.G_MISS_CHAR,
    comparison_operator            OKC_PRICE_ADJ_ATTRIBS_V.COMPARISON_OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PRICE_ADJ_ATTRIBS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PRICE_ADJ_ATTRIBS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
   program_application_id        NUMBER := OKC_API.G_MISS_NUM,
    program_id                      NUMBER := OKC_API.G_MISS_NUM,
    program_update_date             OKC_PRICE_ADJ_ATTRIBS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    request_id                      NUMBER := OKC_API.G_MISS_NUM,
    object_version_number           NUMBER := OKC_API.G_MISS_NUM);
 g_miss_paav_rec                         paav_rec_type;
  TYPE paav_tbl_type IS TABLE OF paav_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_FOREIGN_KEY_ERROR	 	CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_FK_ERROR';
  G_UNIQUE_KEY_ERROR	 	CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNIQUE_KEY_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_PAA_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type);

 FUNCTION create_version(
    p_chr_id                                    IN NUMBER,
    p_major_version                             IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id                                    IN NUMBER,
    p_major_version                             IN NUMBER) RETURN VARCHAR2;






END OKC_PAA_PVT;

 

/

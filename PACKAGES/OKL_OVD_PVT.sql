--------------------------------------------------------
--  DDL for Package OKL_OVD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OVD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSOVDS.pls 115.7 2002/02/05 12:18:19 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ovd_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    context_intent                 OKL_OPV_RULES.CONTEXT_INTENT%TYPE := OKC_API.G_MISS_CHAR,
    orl_id                         NUMBER := OKC_API.G_MISS_NUM,
    ove_id                         NUMBER := OKC_API.G_MISS_NUM,
    copy_or_enter_flag             OKL_OPV_RULES.COPY_OR_ENTER_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    context_inv_org                NUMBER := OKC_API.G_MISS_NUM,
    context_org                    NUMBER := OKC_API.G_MISS_NUM,
    context_asset_book             OKL_OPV_RULES.CONTEXT_ASSET_BOOK%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_OPV_RULES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_OPV_RULES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    individual_instructions        OKL_OPV_RULES.INDIVIDUAL_INSTRUCTIONS%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ovd_rec                          ovd_rec_type;
  TYPE ovd_tbl_type IS TABLE OF ovd_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE ovdv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    context_intent                 OKL_OPV_RULES_V.CONTEXT_INTENT%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    orl_id                         NUMBER := OKC_API.G_MISS_NUM,
    ove_id                         NUMBER := OKC_API.G_MISS_NUM,
    individual_instructions        OKL_OPV_RULES_V.INDIVIDUAL_INSTRUCTIONS%TYPE := OKC_API.G_MISS_CHAR,
    copy_or_enter_flag             OKL_OPV_RULES_V.COPY_OR_ENTER_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    context_org                    NUMBER := OKC_API.G_MISS_NUM,
    context_inv_org                NUMBER := OKC_API.G_MISS_NUM,
    context_asset_book             OKL_OPV_RULES_V.CONTEXT_ASSET_BOOK%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_OPV_RULES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_OPV_RULES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_ovdv_rec                         ovdv_rec_type;
  TYPE ovdv_tbl_type IS TABLE OF ovdv_rec_type
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

  -- RPOONUGA001: Add new global variables
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_TABLE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME';
  G_SQLERRM_TOKEN		    CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN		    CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_UNQS	                CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';

  -- RPOONUGA001: Add new exception
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  G_ITEM_NOT_FOUND_ERROR	   EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_OVD_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  -- RPOONUGA001: Add new global variables
  G_LOOKUP_TYPE			CONSTANT VARCHAR2(50)  := 'OKL_OPTION_VALUE_RULE_FLAG';
  G_INTENT_TYPE         CONSTANT VARCHAR2(50)  := 'OKL_INTENT_TYPE';
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
    p_ovdv_rec                     IN ovdv_rec_type,
    x_ovdv_rec                     OUT NOCOPY ovdv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type,
    x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type,
    x_ovdv_rec                     OUT NOCOPY ovdv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type,
    x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type);

END OKL_OVD_PVT;

 

/

--------------------------------------------------------
--  DDL for Package OKL_PIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PIT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPITS.pls 115.9 2002/06/14 17:01:46 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE pit_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    pdt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    template_name                  OKL_PRD_PRICE_TMPLS.TEMPLATE_NAME%TYPE := Okc_Api.G_MISS_CHAR,
    -- mvasudev, 05/13/2002
    template_path                  OKL_PRD_PRICE_TMPLS.TEMPLATE_PATH%TYPE := Okc_Api.G_MISS_CHAR,
    --
    version						   OKL_PRD_PRICE_TMPLS.VERSION%TYPE := Okc_Api.G_MISS_CHAR,
    start_date                     OKL_PRD_PRICE_TMPLS.START_DATE%TYPE := Okc_Api.G_MISS_DATE,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    end_date                       OKL_PRD_PRICE_TMPLS.END_DATE%TYPE := Okc_Api.G_MISS_DATE,
    description                    OKL_PRD_PRICE_TMPLS.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_PRD_PRICE_TMPLS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_PRD_PRICE_TMPLS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_pit_rec                          pit_rec_type;
  TYPE pit_tbl_type IS TABLE OF pit_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE pitv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    pdt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    template_name                  OKL_PRD_PRICE_TMPLS_V.TEMPLATE_NAME%TYPE := Okc_Api.G_MISS_CHAR,
    -- mvasudev, 05/13/2002
    template_path                  OKL_PRD_PRICE_TMPLS_V.TEMPLATE_PATH%TYPE := Okc_Api.G_MISS_CHAR,
    --
    version						   OKL_PRD_PRICE_TMPLS_V.VERSION%TYPE := Okc_Api.G_MISS_CHAR,
    start_date                     OKL_PRD_PRICE_TMPLS_V.START_DATE%TYPE := Okc_Api.G_MISS_DATE,
    end_date                       OKL_PRD_PRICE_TMPLS_V.END_DATE%TYPE := Okc_Api.G_MISS_DATE,
    description                    OKL_PRD_PRICE_TMPLS_V.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_PRD_PRICE_TMPLS_V.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_PRD_PRICE_TMPLS_V.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_pitv_rec                         pitv_rec_type;
  TYPE pitv_tbl_type IS TABLE OF pitv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_APP_NAME;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;

  -- START CHANGE : akjain -- 05/07/2001
  -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM','Unexpected Error'
  G_OKL_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_OKL_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_OKL_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_UNQS			CONSTANT VARCHAR2(200) := 'OKL_PIT_NOT_UNIQUE';

  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : akjain



  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_PIT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type,
    x_pitv_rec                     OUT NOCOPY pitv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type,
    x_pitv_tbl                     OUT NOCOPY pitv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type,
    x_pitv_rec                     OUT NOCOPY pitv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type,
    x_pitv_tbl                     OUT NOCOPY pitv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_rec                     IN pitv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pitv_tbl                     IN pitv_tbl_type);

END Okl_Pit_Pvt;

 

/

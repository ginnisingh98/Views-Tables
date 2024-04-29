--------------------------------------------------------
--  DDL for Package OKL_OPD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OPD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSOPDS.pls 120.2 2006/12/07 06:11:39 ssdeshpa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE opd_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_OPERANDS_B.NAME%TYPE := OKC_API.G_MISS_CHAR,
    fma_id                         NUMBER := OKC_API.G_MISS_NUM,
    dsf_id                         NUMBER := OKC_API.G_MISS_NUM,
    version                        OKL_OPERANDS_B.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    opd_type                       OKL_OPERANDS_B.OPD_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKL_OPERANDS_B.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    source                         OKL_OPERANDS_B.SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_OPERANDS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_OPERANDS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    end_date                       OKL_OPERANDS_B.END_DATE%TYPE := OKC_API.G_MISS_DATE);
  g_miss_opd_rec                          opd_rec_type;
  TYPE opd_tbl_type IS TABLE OF opd_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_operands_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_OPERANDS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_OPERANDS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_OPERANDS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_OPERANDS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_OPERANDS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_OPERANDS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okl_operands_tl_rec              okl_operands_tl_rec_type;
  TYPE okl_operands_tl_tbl_type IS TABLE OF okl_operands_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE opdv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_OPERANDS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    fma_id                         NUMBER := OKC_API.G_MISS_NUM,
    dsf_id                         NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_OPERANDS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_OPERANDS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_OPERANDS_V.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_OPERANDS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_OPERANDS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    source                         OKL_OPERANDS_V.SOURCE%TYPE := OKC_API.G_MISS_CHAR,
    opd_type                       OKL_OPERANDS_V.OPD_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_OPERANDS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_OPERANDS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_opdv_rec                         opdv_rec_type;
  TYPE opdv_tbl_type IS TABLE OF opdv_rec_type
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

  --RPOONUGA001: Added the following
  G_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN		  		    CONSTANT VARCHAR2(100) := 'OKL_TABLE_NAME';
  G_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UNQS			            CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';
  G_INVALID_KEY                 CONSTANT VARCHAR2(200) := 'OKL_INVALID_KEY';
  G_MISS_DATA		            CONSTANT VARCHAR2(200) := 'OKL_MISS_DATA';
  G_TO_DATE_ERROR	            CONSTANT VARCHAR2(200) := 'OKL_TO_DATE_ERROR';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_OPD_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  --RPOONUGA001: Added the following
  G_FORMULA_TYPE			  CONSTANT VARCHAR2(10) := 'FMLA';
  G_FUNCTION_TYPE			  CONSTANT VARCHAR2(10) := 'FCNT';
  G_CONSTANT_TYPE			  CONSTANT VARCHAR2(10) := 'CNST';

  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type,
    x_opdv_rec                     OUT NOCOPY opdv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type,
    x_opdv_tbl                     OUT NOCOPY opdv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type,
    x_opdv_rec                     OUT NOCOPY opdv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type,
    x_opdv_tbl                     OUT NOCOPY opdv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_rec                     IN opdv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_opdv_tbl                     IN opdv_tbl_type);

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode               IN VARCHAR2,
    p_okl_operand_id            IN VARCHAR2,
    p_name                      IN VARCHAR2,
    p_version                   IN VARCHAR2,
    p_fma_id                    IN VARCHAR2,
    p_dsf_id                    IN VARCHAR2,
    p_opd_type                  IN VARCHAR2,
    p_object_version_number     IN VARCHAR2,
    p_org_id                    IN VARCHAR2,
    p_start_date                IN VARCHAR2,
    p_end_date                  IN VARCHAR2,
    p_source                    IN VARCHAR2,
    p_last_update_date          IN VARCHAR2,
    p_owner                     IN VARCHAR2,
    p_description               IN VARCHAR2);

END OKL_OPD_PVT;

/

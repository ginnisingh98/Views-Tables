--------------------------------------------------------
--  DDL for Package OKL_FPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FPR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSFPRS.pls 120.2 2006/12/07 06:12:14 ssdeshpa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE fpr_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    dsf_id                         NUMBER := OKC_API.G_MISS_NUM,
    pmr_id                         NUMBER := OKC_API.G_MISS_NUM,
    fpr_type                       OKL_FNCTN_PRMTRS_B.FPR_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sequence_number                NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_FNCTN_PRMTRS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_FNCTN_PRMTRS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_fpr_rec                          fpr_rec_type;
  TYPE fpr_tbl_type IS TABLE OF fpr_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_fnctn_prmtrs_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_FNCTN_PRMTRS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_FNCTN_PRMTRS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_FNCTN_PRMTRS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    value                          OKL_FNCTN_PRMTRS_TL.VALUE%TYPE := OKC_API.G_MISS_CHAR,
    instructions                   OKL_FNCTN_PRMTRS_TL.INSTRUCTIONS%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_FNCTN_PRMTRS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_FNCTN_PRMTRS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okl_fnctn_prmtrs_tl_rec          okl_fnctn_prmtrs_tl_rec_type;
  TYPE okl_fnctn_prmtrs_tl_tbl_type IS TABLE OF okl_fnctn_prmtrs_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE fprv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_FNCTN_PRMTRS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    dsf_id                         NUMBER := OKC_API.G_MISS_NUM,
    pmr_id                         NUMBER := OKC_API.G_MISS_NUM,
    sequence_number                NUMBER := OKC_API.G_MISS_NUM,
    value                          OKL_FNCTN_PRMTRS_V.VALUE%TYPE := OKC_API.G_MISS_CHAR,
    instructions                   OKL_FNCTN_PRMTRS_V.INSTRUCTIONS%TYPE := OKC_API.G_MISS_CHAR,
    fpr_type                       OKL_FNCTN_PRMTRS_V.FPR_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_FNCTN_PRMTRS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_FNCTN_PRMTRS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_fprv_rec                         fprv_rec_type;
  TYPE fprv_tbl_type IS TABLE OF fprv_rec_type
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
  -- START CHANGE : mvasudev -- 05/02/2001
  -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM','Unexpected Error'
  G_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_TABLE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME';
  G_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_INVALID_KEY                 CONSTANT VARCHAR2(200) := 'OKL_INVALID_KEY';
  G_UNQS			            CONSTANT VARCHAR2(200) := 'OKL_NOT_UNIQUE';
  -- END CHANGE : mvasudev
  -- RPOONUGA001: message constants
  G_MISS_DATA	  	  		  CONSTANT VARCHAR2(200) := 'OKL_MISS_DATA';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_FPR_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  -- RPOONUGA001: global variables
  G_STATIC_TYPE	  	  		  CONSTANT VARCHAR2(200) := 'STATIC';
  G_CONTEXT_TYPE			  CONSTANT VARCHAR2(200) := 'CONTEXT';

  -- START change : mvasudev, 05/02/2001
  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : mvasudev

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
    p_fprv_rec                     IN fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type);

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode               IN VARCHAR2,
    p_fnctn_prmtr_id            IN VARCHAR2,
    p_dsf_id                    IN VARCHAR2,
    p_pmr_id                    IN VARCHAR2,
    p_fpr_type                  IN VARCHAR2,
    p_object_version_number     IN VARCHAR2,
    p_sequence_number           IN VARCHAR2,
    p_value                     IN VARCHAR2,
    p_instructions              IN VARCHAR2,
    p_owner                     IN VARCHAR2,
    p_last_update_date          IN VARCHAR2);

END OKL_FPR_PVT;

/

--------------------------------------------------------
--  DDL for Package OKC_UBL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_UBL_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCSUBLS.pls 120.0 2005/05/25 19:01:46 appldev noship $*/
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ubn_rec_type IS RECORD (
    id				   OKC_USER_BINS.ID%TYPE, --  := OKC_API.G_MISS_NUM,
    contract_id                    OKC_USER_BINS.CONTRACT_ID%TYPE, --  := OKC_API.G_MISS_NUM,
    contract_number                OKC_USER_BINS.CONTRACT_NUMBER%TYPE, --  := OKC_API.G_MISS_CHAR,
    bin_type                       OKC_USER_BINS.BIN_TYPE%TYPE, --  := OKC_API.G_MISS_CHAR,
    contract_type                  OKC_USER_BINS.CONTRACT_TYPE%TYPE, --  := OKC_API.G_MISS_CHAR,
    program_name                   OKC_USER_BINS.PROGRAM_NAME%TYPE, --  := OKC_API.G_MISS_CHAR,
    created_by                     OKC_USER_BINS.CREATED_BY%TYPE, --  := OKC_API.G_MISS_NUM,
    creation_date                  OKC_USER_BINS.CREATION_DATE%TYPE, --  := OKC_API.G_MISS_DATE,
    contract_number_modifier       OKC_USER_BINS.CONTRACT_NUMBER_MODIFIER%TYPE, --  := OKC_API.G_MISS_CHAR,
    short_description              OKC_USER_BINS.SHORT_DESCRIPTION%TYPE); --  := OKC_API.G_MISS_CHAR);

  g_miss_ubn_rec                   ubn_rec_type;

  TYPE ubn_tbl_type IS TABLE OF ubn_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE ubnv_rec_type IS RECORD (
    id				   OKC_USER_BINS_V.ID%TYPE, --  := OKC_API.G_MISS_NUM,
    contract_id                    OKC_USER_BINS_V.CONTRACT_ID%TYPE, --  := OKC_API.G_MISS_NUM,
    contract_number                OKC_USER_BINS_V.CONTRACT_NUMBER%TYPE, --  := OKC_API.G_MISS_CHAR,
    bin_type                       OKC_USER_BINS_V.BIN_TYPE%TYPE, --  := OKC_API.G_MISS_CHAR,
    contract_type                  OKC_USER_BINS_V.CONTRACT_TYPE%TYPE, --  := OKC_API.G_MISS_CHAR,
    program_name                   OKC_USER_BINS_V.PROGRAM_NAME%TYPE, --  := OKC_API.G_MISS_CHAR,
    created_by                     OKC_USER_BINS_V.CREATED_BY%TYPE, --  := OKC_API.G_MISS_NUM,
    creation_date                  OKC_USER_BINS_V.CREATION_DATE%TYPE, --  := OKC_API.G_MISS_DATE,
    contract_number_modifier       OKC_USER_BINS_V.CONTRACT_NUMBER_MODIFIER%TYPE, --  := OKC_API.G_MISS_CHAR,
    short_description              OKC_USER_BINS_V.SHORT_DESCRIPTION%TYPE); --  := OKC_API.G_MISS_CHAR);

  g_miss_ubnv_rec                         ubnv_rec_type;

  TYPE ubnv_tbl_type IS TABLE OF ubnv_rec_type
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
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_UBL_PVT';
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
    p_ubnv_rec                     IN ubnv_rec_type,
    x_ubnv_rec                     OUT NOCOPY ubnv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type,
    x_ubnv_tbl                     OUT NOCOPY ubnv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type,
    x_ubnv_rec                     OUT NOCOPY ubnv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type,
    x_ubnv_tbl                     OUT NOCOPY ubnv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type);

END OKC_UBL_PVT;

 

/

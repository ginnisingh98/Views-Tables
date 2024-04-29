--------------------------------------------------------
--  DDL for Package OKL_SIR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSIRS.pls 115.3 2002/02/21 16:02:36 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sir_rec_type IS RECORD (
    id                             NUMBER:= OKC_API.G_MISS_NUM,
    transaction_number             NUMBER := OKC_API.G_MISS_NUM,
    srt_code                       OKL_SIF_RETS.SRT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    effective_pre_tax_yield        NUMBER:= OKC_API.G_MISS_NUM,
    yield_name                     OKL_SIF_RETS.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    index_number                   NUMBER := OKC_API.G_MISS_NUM,
    effective_after_tax_yield      NUMBER := OKC_API.G_MISS_NUM,
    nominal_pre_tax_yield          NUMBER := OKC_API.G_MISS_NUM,
    nominal_after_tax_yield        NUMBER := OKC_API.G_MISS_NUM,
    stream_interface_attribute01   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_RETS.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          OKL_SIF_RETS.OBJECT_VERSION_NUMBER%TYPE := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_RETS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_RETS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    implicit_interest_rate         NUMBER := OKC_API.G_MISS_NUM,
    date_processed                 OKL_SIF_RETS.DATE_PROCESSED%TYPE := OKC_API.G_MISS_DATE,
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    REQUEST_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_APPLICATION_ID         NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE            OKL_SIF_RETS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    -- mvasudev -- 02/21/2002
    );
    g_miss_sir_rec                          sir_rec_type;

  TYPE sir_tbl_type IS TABLE OF sir_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE sirv_rec_type IS RECORD (
    id                             NUMBER:= OKC_API.G_MISS_NUM,
    transaction_number             NUMBER := OKC_API.G_MISS_NUM,
    srt_code                       OKL_SIF_RETS_V.SRT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    effective_pre_tax_yield        NUMBER:= OKC_API.G_MISS_NUM,
    yield_name                     OKL_SIF_RETS_V.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    index_number                   NUMBER := OKC_API.G_MISS_NUM,
    effective_after_tax_yield      NUMBER := OKC_API.G_MISS_NUM,
    nominal_pre_tax_yield          NUMBER := OKC_API.G_MISS_NUM,
    nominal_after_tax_yield        NUMBER := OKC_API.G_MISS_NUM,
    stream_interface_attribute01   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_RETS_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          OKL_SIF_RETS_V.OBJECT_VERSION_NUMBER%TYPE := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_RETS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_RETS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    implicit_interest_rate         NUMBER := OKC_API.G_MISS_NUM,
    date_processed                 OKL_SIF_RETS_V.DATE_PROCESSED%TYPE := OKC_API.G_MISS_DATE,
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    REQUEST_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_APPLICATION_ID         NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE            OKL_SIF_RETS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    -- mvasudev -- 02/21/2002
    );
  g_miss_sirv_rec                         sirv_rec_type;
  TYPE sirv_tbl_type IS TABLE OF sirv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(200) := OKC_API.G_APP_NAME;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;



  -- START CHANGE : akjain -- 09/05/2001
  -- Adding Message constants
  G_OKL_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) :='OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_OKL_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_OKL_UNQS                        CONSTANT VARCHAR2(200) := 'OKL_SIR_NOT_UNIQUE';

  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : akjain

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SIR_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;


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
    p_sirv_rec                     IN sirv_rec_type,
    x_sirv_rec                     OUT NOCOPY sirv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type,
    x_sirv_tbl                     OUT NOCOPY sirv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type,
    x_sirv_rec                     OUT NOCOPY sirv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type,
    x_sirv_tbl                     OUT NOCOPY sirv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type);

END OKL_SIR_PVT;

 

/

--------------------------------------------------------
--  DDL for Package OKL_STM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSTMS.pls 120.2 2005/05/30 12:31:52 kthiruva noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE stm_rec_type IS RECORD (
    id                             NUMBER ,
    sty_id                         NUMBER ,
    khr_id                         NUMBER ,
    kle_id                         NUMBER ,
    sgn_code                       OKL_STREAMS.SGN_CODE%TYPE ,
    say_code                       OKL_STREAMS.SAY_CODE%TYPE ,
    transaction_number             OKL_STREAMS.TRANSACTION_NUMBER%TYPE ,
    active_yn                      OKL_STREAMS.ACTIVE_YN%TYPE ,
    object_version_number          NUMBER ,
    created_by                     NUMBER ,
    creation_date                  OKL_STREAMS.CREATION_DATE%TYPE ,
    last_updated_by                NUMBER ,
    last_update_date               OKL_STREAMS.LAST_UPDATE_DATE%TYPE ,
    date_current                   OKL_STREAMS.DATE_CURRENT%TYPE ,
    date_working                   OKL_STREAMS.DATE_WORKING%TYPE ,
    date_history                   OKL_STREAMS.DATE_HISTORY%TYPE ,
    comments                       OKL_STREAMS.COMMENTS%TYPE ,
    program_id                     NUMBER ,
    request_id                     NUMBER ,
    program_application_id         NUMBER ,
    program_update_date            OKL_STREAMS.PROGRAM_UPDATE_DATE%TYPE ,
    last_update_login              NUMBER ,
    -- mvasudev, Bug#2650599
    purpose_code                   OKL_STREAMS.PURPOSE_CODE%TYPE ,
    --sty_code                       OKL_STREAMS.STY_CODE%TYPE := OKC_API.G_MISS_CHAR
    -- end, mvasudev, Bug#2650599
    --- Changed by Kjinger
    stm_id                         NUMBER ,
    -- Change Ends
    -- Added by Keerthi for Bug 3166890
    source_id                      NUMBER ,
    source_table                   OKL_STREAMS.SOURCE_TABLE%TYPE,
    -- Change Ends
    -- rgooty : Start
    trx_id                         NUMBER,
    link_hist_stream_id            NUMBER
    -- rgooty : End
    );
  g_miss_stm_rec                          stm_rec_type;
  TYPE stm_tbl_type IS TABLE OF stm_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE stmv_rec_type IS RECORD (
    id                             NUMBER ,
    sty_id                         NUMBER ,
    khr_id                         NUMBER ,
    kle_id                         NUMBER ,
    sgn_code                       OKL_STREAMS_V.SGN_CODE%TYPE ,
    say_code                       OKL_STREAMS_V.SAY_CODE%TYPE ,
    transaction_number             OKL_STREAMS_V.TRANSACTION_NUMBER%TYPE ,
    active_yn                      OKL_STREAMS_V.ACTIVE_YN%TYPE ,
    object_version_number          NUMBER ,
    created_by                     NUMBER ,
    creation_date                  OKL_STREAMS_V.CREATION_DATE%TYPE ,
    last_updated_by                NUMBER ,
    last_update_date               OKL_STREAMS_V.LAST_UPDATE_DATE%TYPE ,
    date_current                   OKL_STREAMS_V.DATE_CURRENT%TYPE ,
    date_working                   OKL_STREAMS_V.DATE_WORKING%TYPE ,
    date_history                   OKL_STREAMS_V.DATE_HISTORY%TYPE ,
    comments                       OKL_STREAMS_V.COMMENTS%TYPE ,
    program_id                     NUMBER ,
    request_id                     NUMBER ,
    program_application_id         NUMBER ,
    program_update_date            OKL_STREAMS_V.PROGRAM_UPDATE_DATE%TYPE ,
    last_update_login              NUMBER ,
    -- mvasudev, Bug#2650599
    purpose_code                   OKL_STREAMS_V.PURPOSE_CODE%TYPE ,
    --sty_code                       OKL_STREAMS_V.STY_CODE%TYPE := OKC_API.G_MISS_CHAR
    -- end, mvasudev, Bug#2650599
    --- Changed by Kjinger
    stm_id                         NUMBER ,
    --- Change Ends
    -- Added by Keerthi for Bug 3166890
    source_id                      NUMBER ,
    source_table                   OKL_STREAMS.SOURCE_TABLE%TYPE,
    -- rgooty : Start
    trx_id                         NUMBER,
    link_hist_stream_id            NUMBER
    -- rgooty : End
    );
  g_miss_stmv_rec                         stmv_rec_type;
  TYPE stmv_tbl_type IS TABLE OF stmv_rec_type
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

  G_OKL_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) :='OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_OKL_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_OKL_UNQS                        CONSTANT VARCHAR2(200) := 'OKL_STM_NOT_UNIQUE';
  G_OKL_STM_NO_PARENT_RECORD        CONSTANT VARCHAR2(200) := 'OKL_STM_NO_PARENT_RECORD';
  G_OKL_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_STM_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;


  ----------------------------------------------------------------------------
  -----------------  GLOBAL EXCEPTION
  --------------------------------------------------------

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

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
    p_stmv_rec                     IN stmv_rec_type,
    x_stmv_rec                     OUT NOCOPY stmv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type,
    x_stmv_tbl                     OUT NOCOPY stmv_tbl_type);

  --Added by kthiruva for Streams Performance Improvement
  --Bug 4346646- Start of Changes
  PROCEDURE insert_row_perf(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type,
    x_stmv_tbl                     OUT NOCOPY stmv_tbl_type);
  --Bug 4346646 - End of Changes

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type,
    x_stmv_rec                     OUT NOCOPY stmv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type,
    x_stmv_tbl                     OUT NOCOPY stmv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_rec                     IN stmv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stmv_tbl                     IN stmv_tbl_type);

END Okl_Stm_Pvt;

 

/

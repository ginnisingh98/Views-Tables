--------------------------------------------------------
--  DDL for Package OKL_AEH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AEH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAEHS.pls 120.2 2006/07/11 10:08:21 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE aeh_rec_type IS RECORD (
    ae_header_id                   NUMBER := Okc_Api.G_MISS_NUM,
    post_to_gl_flag                OKL_AE_HEADERS.POST_TO_GL_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    set_of_books_id                NUMBER := Okc_Api.G_MISS_NUM,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNTING_EVENT_ID            NUMBER := Okc_Api.G_MISS_NUM,
    ae_category                    OKL_AE_HEADERS.AE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    period_name                    OKL_AE_HEADERS.PERIOD_NAME%TYPE := Okc_Api.G_MISS_CHAR,
    accounting_date                OKL_AE_HEADERS.ACCOUNTING_DATE%TYPE := Okc_Api.G_MISS_DATE,
    cross_currency_flag            OKL_AE_HEADERS.CROSS_CURRENCY_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    gl_transfer_flag               OKL_AE_HEADERS.GL_TRANSFER_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    gl_transfer_run_id             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    sequence_id                    NUMBER := Okc_Api.G_MISS_NUM,
    sequence_value                 NUMBER := Okc_Api.G_MISS_NUM,
    description                    OKL_AE_HEADERS.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    accounting_error_code          OKL_AE_HEADERS.ACCOUNTING_ERROR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    gl_transfer_error_code         OKL_AE_HEADERS.GL_TRANSFER_ERROR_CODE%TYPE,
    gl_reversal_flag               OKL_AE_HEADERS.GL_REVERSAL_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_AE_HEADERS.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_AE_HEADERS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_AE_HEADERS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);

  g_miss_aeh_rec                          aeh_rec_type;
  TYPE aeh_tbl_type IS TABLE OF aeh_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE aehv_rec_type IS RECORD (
    post_to_gl_flag                OKL_AE_HEADERS.POST_TO_GL_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    ae_header_id                   NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNTING_EVENT_ID            NUMBER := Okc_Api.G_MISS_NUM,
    set_of_books_id                NUMBER := Okc_Api.G_MISS_NUM,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    AE_CATEGORY                    OKL_AE_HEADERS.AE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    sequence_id                    NUMBER := Okc_Api.G_MISS_NUM,
    sequence_value                 NUMBER := Okc_Api.G_MISS_NUM,
    period_name                    OKL_AE_HEADERS.PERIOD_NAME%TYPE := Okc_Api.G_MISS_CHAR,
    accounting_date                OKL_AE_HEADERS.ACCOUNTING_DATE%TYPE := Okc_Api.G_MISS_DATE,
    description                    OKL_AE_HEADERS.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    accounting_error_code          OKL_AE_HEADERS.ACCOUNTING_ERROR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    cross_currency_flag            OKL_AE_HEADERS.CROSS_CURRENCY_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    gl_transfer_flag               OKL_AE_HEADERS.GL_TRANSFER_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    gl_transfer_error_code         OKL_AE_HEADERS.GL_TRANSFER_ERROR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
	gl_transfer_run_id             NUMBER := Okc_Api.G_MISS_NUM,
    gl_reversal_flag               OKL_AE_HEADERS.GL_REVERSAL_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_AE_HEADERS.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_AE_HEADERS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_AE_HEADERS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);

  g_miss_aehv_rec                         aehv_rec_type;
  TYPE aehv_tbl_type IS TABLE OF aehv_rec_type
        INDEX BY BINARY_INTEGER;
   --gboomina bug#4648697..changes for perf start
     --Added column arrarys for bulk insert
     TYPE ae_header_id_typ IS TABLE OF okl_ae_headers.ae_header_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE post_to_gl_flag_typ IS TABLE OF okl_ae_headers.post_to_gl_flag%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE set_of_books_id_typ IS TABLE OF okl_ae_headers.set_of_books_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE accounting_event_id_typ IS TABLE OF okl_ae_headers.accounting_event_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE object_version_number_typ IS TABLE OF okl_ae_headers.object_version_number%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE ae_category_typ IS TABLE OF okl_ae_headers.ae_category%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE period_name_typ IS TABLE OF okl_ae_headers.period_name%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE accounting_date_typ IS TABLE OF okl_ae_headers.accounting_date%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE gl_transfer_run_id_typ IS TABLE OF okl_ae_headers.gl_transfer_run_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE cross_currency_flag_typ IS TABLE OF okl_ae_headers.cross_currency_flag%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE gl_transfer_flag_typ IS TABLE OF okl_ae_headers.gl_transfer_flag%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE sequence_id_typ IS TABLE OF okl_ae_headers.sequence_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE sequence_value_typ IS TABLE OF okl_ae_headers.sequence_value%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE description_typ IS TABLE OF okl_ae_headers.description%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE accounting_error_code_typ IS TABLE OF okl_ae_headers.accounting_error_code%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE gl_transfer_error_code_typ IS TABLE OF okl_ae_headers.gl_transfer_error_code%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE gl_reversal_flag_typ IS TABLE OF okl_ae_headers.gl_reversal_flag%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE org_id_typ IS TABLE OF okl_ae_headers.org_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE program_id_typ IS TABLE OF okl_ae_headers.program_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE program_application_id_typ IS TABLE OF okl_ae_headers.program_application_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE program_update_date_typ IS TABLE OF okl_ae_headers.program_update_date%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE request_id_typ IS TABLE OF okl_ae_headers.request_id%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE created_by_typ IS TABLE OF okl_ae_headers.created_by%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE creation_date_typ IS TABLE OF okl_ae_headers.creation_date%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE last_updated_by_typ IS TABLE OF okl_ae_headers.last_updated_by%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE last_update_date_typ IS TABLE OF okl_ae_headers.last_update_date%TYPE
       INDEX BY BINARY_INTEGER;
     TYPE last_update_login_typ IS TABLE OF okl_ae_headers.last_update_login%TYPE
       INDEX BY BINARY_INTEGER;
     --gboomina bug#4648697..changes for perf end

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED	CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKL_UNIQUE_KEY_VALIDATION_FAILED';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AEH_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

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
    p_aehv_rec                     IN aehv_rec_type,
    x_aehv_rec                     OUT NOCOPY aehv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type,
    x_aehv_tbl                     OUT NOCOPY aehv_tbl_type);

  --gboomina bug#4648697..changes for perf start
     --added new procedure for bulk insert
     PROCEDURE insert_row_perf(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_aehv_tbl                     IN aehv_tbl_type,
       x_aehv_tbl                     OUT NOCOPY aehv_tbl_type);
  --gboomina bug#4648697..changes for perf end

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type,
    x_aehv_rec                     OUT NOCOPY aehv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type,
    x_aehv_tbl                     OUT NOCOPY aehv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_rec                     IN aehv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aehv_tbl                     IN aehv_tbl_type);

END Okl_Aeh_Pvt;

/

--------------------------------------------------------
--  DDL for Package OKL_CFL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CFL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCFLS.pls 120.4 2006/02/10 07:50:44 asawanka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CASH_FLOW_LEVELS_V Record Spec
  TYPE cflv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,caf_id                         NUMBER := OKL_API.G_MISS_NUM
    ,amount                         NUMBER := OKL_API.G_MISS_NUM
    ,number_of_periods              NUMBER := OKL_API.G_MISS_NUM
    ,fqy_code                       OKL_CASH_FLOW_LEVELS_V.FQY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,level_sequence                 NUMBER := OKL_API.G_MISS_NUM
    ,stub_days                      NUMBER := OKC_API.G_MISS_NUM
    ,stub_amount                    NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKL_CASH_FLOW_LEVELS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate                           NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CASH_FLOW_LEVELS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CASH_FLOW_LEVELS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CASH_FLOW_LEVELS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,missing_pmt_flag               OKL_CASH_FLOW_LEVELS_V.missing_pmt_flag%TYPE := OKL_API.G_MISS_CHAR);
  G_MISS_cflv_rec                         cflv_rec_type;
  TYPE cflv_tbl_type IS TABLE OF cflv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CASH_FLOW_LEVELS Record Spec
  TYPE cfl_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,caf_id                         NUMBER := OKL_API.G_MISS_NUM
    ,amount                         NUMBER := OKL_API.G_MISS_NUM
    ,number_of_periods              NUMBER := OKL_API.G_MISS_NUM
    ,fqy_code                       OKL_CASH_FLOW_LEVELS.FQY_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,level_sequence                 NUMBER := OKL_API.G_MISS_NUM
    ,stub_days                      NUMBER := OKC_API.G_MISS_NUM
    ,stub_amount                    NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKL_CASH_FLOW_LEVELS.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,rate                           NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKL_CASH_FLOW_LEVELS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CASH_FLOW_LEVELS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CASH_FLOW_LEVELS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CASH_FLOW_LEVELS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CASH_FLOW_LEVELS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CASH_FLOW_LEVELS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CASH_FLOW_LEVELS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CASH_FLOW_LEVELS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CASH_FLOW_LEVELS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CASH_FLOW_LEVELS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,missing_pmt_flag               OKL_CASH_FLOW_LEVELS.missing_pmt_flag%TYPE := OKL_API.G_MISS_CHAR);
  G_MISS_cfl_rec                          cfl_rec_type;
  TYPE cfl_tbl_type IS TABLE OF cfl_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

   -- SECHAWLA Added
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CFL_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;

--Bug 4299668 PAGARG Included these types, to be used for bulk insert
--**START**--
  TYPE NumberTabTyp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
  TYPE Number9TabTyp IS TABLE OF NUMBER(9)
       INDEX BY BINARY_INTEGER;
  TYPE Var3TabTyp IS TABLE OF VARCHAR2(3)
       INDEX BY BINARY_INTEGER;
  TYPE Var30TabTyp IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;
  TYPE Var90TabTyp IS TABLE OF VARCHAR2(90)
       INDEX BY BINARY_INTEGER;
  TYPE Var450TabTyp IS TABLE OF VARCHAR2(450)
       INDEX BY BINARY_INTEGER;
  TYPE Number15TabTyp IS TABLE OF NUMBER(15)
       INDEX BY BINARY_INTEGER;
  TYPE DateTabTyp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;
--**END 4299668**--

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_rec                     IN cflv_rec_type,
    x_cflv_rec                     OUT NOCOPY cflv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    x_cflv_tbl                     OUT NOCOPY cflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    x_cflv_tbl                     OUT NOCOPY cflv_tbl_type);
--Bug 4299668 PAGARG new procedure to implement bulk insert
--**START**--
  PROCEDURE insert_row_bulk(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    x_cflv_tbl                     OUT NOCOPY cflv_tbl_type);
--**END 4299668**--
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_rec                     IN cflv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_rec                     IN cflv_rec_type,
    x_cflv_rec                     OUT NOCOPY cflv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    x_cflv_tbl                     OUT NOCOPY cflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    x_cflv_tbl                     OUT NOCOPY cflv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_rec                     IN cflv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_rec                     IN cflv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cflv_tbl                     IN cflv_tbl_type);
END OKL_CFL_PVT;

/

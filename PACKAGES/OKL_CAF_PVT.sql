--------------------------------------------------------
--  DDL for Package OKL_CAF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CAF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCAFS.pls 120.2 2005/10/30 04:40:20 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CASH_FLOWS_V Record Spec
  TYPE cafv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,cfo_id                         NUMBER := OKL_API.G_MISS_NUM
    ,sts_code                       OKL_CASH_FLOWS_V.STS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sty_id                         NUMBER := OKL_API.G_MISS_NUM
    ,cft_code                       OKL_CASH_FLOWS_V.CFT_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,due_arrears_yn                 OKL_CASH_FLOWS_V.DUE_ARREARS_YN%TYPE := OKL_API.G_MISS_CHAR
    ,start_date                     OKL_CASH_FLOWS_V.START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,number_of_advance_periods      NUMBER := OKL_API.G_MISS_NUM
    ,dnz_khr_id                     NUMBER := OKL_API.G_MISS_NUM
    ,dnz_qte_id                     NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_CASH_FLOWS_V.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CASH_FLOWS_V.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CASH_FLOWS_V.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CASH_FLOWS_V.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CASH_FLOWS_V.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CASH_FLOWS_V.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CASH_FLOWS_V.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CASH_FLOWS_V.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CASH_FLOWS_V.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CASH_FLOWS_V.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CASH_FLOWS_V.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CASH_FLOWS_V.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CASH_FLOWS_V.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CASH_FLOWS_V.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CASH_FLOWS_V.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CASH_FLOWS_V.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CASH_FLOWS_V.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CASH_FLOWS_V.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_cafv_rec                         cafv_rec_type;
  TYPE cafv_tbl_type IS TABLE OF cafv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CASH_FLOWS Record Spec
  TYPE caf_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,cfo_id                         NUMBER := OKL_API.G_MISS_NUM
    ,sts_code                       OKL_CASH_FLOWS.STS_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,sty_id                         NUMBER := OKL_API.G_MISS_NUM
    ,cft_code                       OKL_CASH_FLOWS.CFT_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,due_arrears_yn                 OKL_CASH_FLOWS.DUE_ARREARS_YN%TYPE := OKL_API.G_MISS_CHAR
    ,start_date                     OKL_CASH_FLOWS.START_DATE%TYPE := OKL_API.G_MISS_DATE
    ,number_of_advance_periods      NUMBER := OKL_API.G_MISS_NUM
    ,dnz_khr_id                     NUMBER := OKL_API.G_MISS_NUM
    ,dnz_qte_id                     NUMBER := OKL_API.G_MISS_NUM
    ,attribute_category             OKL_CASH_FLOWS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CASH_FLOWS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CASH_FLOWS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CASH_FLOWS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CASH_FLOWS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CASH_FLOWS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CASH_FLOWS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CASH_FLOWS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CASH_FLOWS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CASH_FLOWS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CASH_FLOWS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CASH_FLOWS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CASH_FLOWS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CASH_FLOWS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CASH_FLOWS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CASH_FLOWS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CASH_FLOWS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CASH_FLOWS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM);
  G_MISS_caf_rec                          caf_rec_type;
  TYPE caf_tbl_type IS TABLE OF caf_rec_type
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

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CAF_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;

  -- SECHAWLA Added
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';

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
    p_cafv_rec                     IN cafv_rec_type,
    x_cafv_rec                     OUT NOCOPY cafv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    x_cafv_tbl                     OUT NOCOPY cafv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    x_cafv_tbl                     OUT NOCOPY cafv_tbl_type);
--Bug 4299668 PAGARG new procedure to implement bulk insert
--**START**--
  PROCEDURE insert_row_bulk(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    x_cafv_tbl                     OUT NOCOPY cafv_tbl_type);
--**END 4299668**--
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_rec                     IN cafv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_rec                     IN cafv_rec_type,
    x_cafv_rec                     OUT NOCOPY cafv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    x_cafv_tbl                     OUT NOCOPY cafv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    x_cafv_tbl                     OUT NOCOPY cafv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_rec                     IN cafv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_rec                     IN cafv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cafv_tbl                     IN cafv_tbl_type);
END OKL_CAF_PVT;

 

/

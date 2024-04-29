--------------------------------------------------------
--  DDL for Package OKL_LDB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LDB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLDBS.pls 120.0 2005/11/30 17:18:03 stmathew noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_PARTY_PAYMENT_HDR_V Record Spec
  TYPE pphv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ppl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,passthru_start_date            OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,payout_basis                   OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,payout_basis_formula           OKL_PARTY_PAYMENT_HDR_V.PAYOUT_BASIS_FORMULA%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from                 OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,effective_to                   OKL_PARTY_PAYMENT_HDR_V.EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE
    ,passthru_term                  OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_TERM%TYPE := OKC_API.G_MISS_CHAR
    ,passthru_stream_type_id        OKL_PARTY_PAYMENT_HDR_V.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_PARTY_PAYMENT_HDR_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_PARTY_PAYMENT_HDR_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_pphv_rec                         pphv_rec_type;
  TYPE pphv_tbl_type IS TABLE OF pphv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_PARTY_PAYMENT_HDR Record Spec
  TYPE pph_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ppl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,passthru_start_date            OKL_PARTY_PAYMENT_HDR.PASSTHRU_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,payout_basis                   OKL_PARTY_PAYMENT_HDR.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,payout_basis_formula           OKL_PARTY_PAYMENT_HDR.PAYOUT_BASIS_FORMULA%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from                 OKL_PARTY_PAYMENT_HDR.EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,effective_to                   OKL_PARTY_PAYMENT_HDR.EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE
    ,passthru_term                  OKL_PARTY_PAYMENT_HDR.PASSTHRU_TERM%TYPE := OKC_API.G_MISS_CHAR
    ,passthru_stream_type_id        OKL_PARTY_PAYMENT_HDR.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_PARTY_PAYMENT_HDR.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_PARTY_PAYMENT_HDR.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_pph_rec                          pph_rec_type;
  TYPE pph_tbl_type IS TABLE OF pph_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_PARTY_PAYMENT_HDR_H Record Spec
  TYPE pphh_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,ppl_id                         NUMBER := OKC_API.G_MISS_NUM
    ,passthru_start_date            OKL_PARTY_PAYMENT_HDR.PASSTHRU_START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,payout_basis                   OKL_PARTY_PAYMENT_HDR.PAYOUT_BASIS%TYPE := OKC_API.G_MISS_CHAR
    ,payout_basis_formula           OKL_PARTY_PAYMENT_HDR.PAYOUT_BASIS_FORMULA%TYPE := OKC_API.G_MISS_CHAR
    ,effective_from                 OKL_PARTY_PAYMENT_HDR.EFFECTIVE_FROM%TYPE := OKC_API.G_MISS_DATE
    ,effective_to                   OKL_PARTY_PAYMENT_HDR.EFFECTIVE_TO%TYPE := OKC_API.G_MISS_DATE
    ,passthru_term                  OKL_PARTY_PAYMENT_HDR.PASSTHRU_TERM%TYPE := OKC_API.G_MISS_CHAR
    ,passthru_stream_type_id        OKL_PARTY_PAYMENT_HDR.PASSTHRU_STREAM_TYPE_ID%TYPE := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_PARTY_PAYMENT_HDR.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_PARTY_PAYMENT_HDR.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_pphh_rec                          pphh_rec_type;
  TYPE pphh_tbl_type IS TABLE OF pphh_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_LDB_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
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
    p_pphv_rec                     IN pphv_rec_type,
    x_pphv_rec                     OUT NOCOPY pphv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    x_pphv_tbl                     OUT NOCOPY pphv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    x_pphv_tbl                     OUT NOCOPY pphv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type,
    x_pphv_rec                     OUT NOCOPY pphv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    x_pphv_tbl                     OUT NOCOPY pphv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    x_pphv_tbl                     OUT NOCOPY pphv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_rec                     IN pphv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pphv_tbl                     IN pphv_tbl_type);

  FUNCTION create_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id					IN NUMBER,
    p_major_version				IN NUMBER) RETURN VARCHAR2;

END OKL_LDB_PVT;

 

/

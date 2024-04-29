--------------------------------------------------------
--  DDL for Package OKL_AGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AGN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAGNS.pls 120.2 2006/07/11 10:09:44 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE agn_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    line_number                    NUMBER := Okc_Api.G_MISS_NUM,
    version                        OKL_ACCRUAL_GNRTNS.VERSION%TYPE := Okc_Api.G_MISS_CHAR,
    aro_code                       OKL_ACCRUAL_GNRTNS.ARO_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    arlo_code                      OKL_ACCRUAL_GNRTNS.ARLO_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    acro_code                      OKL_ACCRUAL_GNRTNS.ACRO_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    right_operand_literal          OKL_ACCRUAL_GNRTNS.RIGHT_OPERAND_LITERAL%TYPE := Okc_Api.G_MISS_CHAR,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    left_parentheses               OKL_ACCRUAL_GNRTNS.LEFT_PARENTHESES%TYPE := Okc_Api.G_MISS_CHAR,
    right_parentheses              OKL_ACCRUAL_GNRTNS.RIGHT_PARENTHESES%TYPE := Okc_Api.G_MISS_CHAR,
    from_date                      OKL_ACCRUAL_GNRTNS.FROM_DATE%TYPE := Okc_Api.G_MISS_DATE,
    TO_DATE                        OKL_ACCRUAL_GNRTNS.TO_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_ACCRUAL_GNRTNS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_ACCRUAL_GNRTNS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_agn_rec                          agn_rec_type;
  TYPE agn_tbl_type IS TABLE OF agn_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE agnv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    aro_code                       OKL_ACCRUAL_GNRTNS.ARO_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    arlo_code                      OKL_ACCRUAL_GNRTNS.ARLO_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    acro_code                      OKL_ACCRUAL_GNRTNS.ACRO_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    line_number                    NUMBER := Okc_Api.G_MISS_NUM,
    version                        OKL_ACCRUAL_GNRTNS.VERSION%TYPE := Okc_Api.G_MISS_CHAR,
    left_parentheses               OKL_ACCRUAL_GNRTNS.LEFT_PARENTHESES%TYPE := Okc_Api.G_MISS_CHAR,
    right_operand_literal          OKL_ACCRUAL_GNRTNS.RIGHT_OPERAND_LITERAL%TYPE := Okc_Api.G_MISS_CHAR,
    right_parentheses              OKL_ACCRUAL_GNRTNS.RIGHT_PARENTHESES%TYPE := Okc_Api.G_MISS_CHAR,
    from_date                      OKL_ACCRUAL_GNRTNS.FROM_DATE%TYPE := Okc_Api.G_MISS_DATE,
    TO_DATE                        OKL_ACCRUAL_GNRTNS.TO_DATE%TYPE := Okc_Api.G_MISS_DATE,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_ACCRUAL_GNRTNS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_ACCRUAL_GNRTNS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_agnv_rec                         agnv_rec_type;
  TYPE agnv_tbl_type IS TABLE OF agnv_rec_type
        INDEX BY BINARY_INTEGER;
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
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNQS CONSTANT VARCHAR2(200) := 'OKL_AGN_ELEMENT_NOT_UNIQUE';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AGN_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  Procedure qc;
  Procedure change_version;
  Procedure api_copy;
  Procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type);

  Procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type);

  Procedure lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type);

  Procedure lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type);

  Procedure update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type);

  Procedure update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type);

  Procedure delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type);

  Procedure delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type);

  Procedure validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type);

  Procedure validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type);

END Okl_Agn_Pvt;

/

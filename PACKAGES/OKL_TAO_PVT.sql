--------------------------------------------------------
--  DDL for Package OKL_TAO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTAOS.pls 120.2 2006/07/11 10:29:39 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tao_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    try_id                         NUMBER := Okc_Api.G_MISS_NUM,
    rev_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    freight_ccid                   NUMBER := Okc_Api.G_MISS_NUM,
    rec_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    clearing_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    tax_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    unbilled_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    unearned_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKL_TRX_ACCT_OPTS.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_ACCT_OPTS.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_ACCT_OPTS.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_ACCT_OPTS.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_ACCT_OPTS.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_ACCT_OPTS.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_ACCT_OPTS.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_ACCT_OPTS.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_ACCT_OPTS.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_ACCT_OPTS.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_ACCT_OPTS.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_ACCT_OPTS.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_ACCT_OPTS.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_ACCT_OPTS.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_ACCT_OPTS.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_ACCT_OPTS.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_ACCT_OPTS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_ACCT_OPTS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
/* Changes Made by Kanti on 06/27/2001. This field is present in Table but was missing from here */
    post_to_gl_yn                  OKL_TRX_ACCT_OPTS.POST_TO_GL_YN%TYPE := Okc_Api.G_MISS_CHAR);
/* Changes Ends */

  g_miss_tao_rec                          tao_rec_type;
  TYPE tao_tbl_type IS TABLE OF tao_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE taov_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    try_id                         NUMBER := Okc_Api.G_MISS_NUM,
    unearned_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    rev_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    freight_ccid                   NUMBER := Okc_Api.G_MISS_NUM,
    rec_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    clearing_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    tax_ccid                       NUMBER := Okc_Api.G_MISS_NUM,
    unbilled_ccid                  NUMBER := Okc_Api.G_MISS_NUM,
    attribute_category             OKL_TRX_ACCT_OPTS.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_ACCT_OPTS.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_ACCT_OPTS.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_ACCT_OPTS.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_ACCT_OPTS.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_ACCT_OPTS.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_ACCT_OPTS.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_ACCT_OPTS.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_ACCT_OPTS.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_ACCT_OPTS.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_ACCT_OPTS.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_ACCT_OPTS.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_ACCT_OPTS.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_ACCT_OPTS.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_ACCT_OPTS.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_ACCT_OPTS.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_ACCT_OPTS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_ACCT_OPTS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
/* Changes Made by Kanti on 06/27/2001. This field is present in Table but was missing from here */
    post_to_gl_yn                  OKL_TRX_ACCT_OPTS.POST_TO_GL_YN%TYPE := Okc_Api.G_MISS_CHAR);
/* Changes Ends */


  g_miss_taov_rec                         taov_rec_type;
  TYPE taov_tbl_type IS TABLE OF taov_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  -- Added 04/27/2001 Robin Edwin for validate attribute

  G_SQLCODE_TOKEN 	CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';

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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TAO_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
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
    p_taov_rec                     IN taov_rec_type,
    x_taov_rec                     OUT NOCOPY taov_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type,
    x_taov_tbl                     OUT NOCOPY taov_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type,
    x_taov_rec                     OUT NOCOPY taov_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type,
    x_taov_tbl                     OUT NOCOPY taov_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_rec                     IN taov_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_taov_tbl                     IN taov_tbl_type);

END Okl_Tao_Pvt;

/

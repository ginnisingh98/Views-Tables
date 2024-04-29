--------------------------------------------------------
--  DDL for Package OKL_TAB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TAB_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTABS.pls 120.5 2007/04/19 12:41:39 nikshah noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tab_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    currency_conversion_type       OKL_TRNS_ACC_DSTRS.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    set_of_books_id                OKL_TRNS_ACC_DSTRS.SET_OF_BOOKS_ID%TYPE := OKC_API.G_MISS_NUM,
    cr_dr_flag                     OKL_TRNS_ACC_DSTRS.CR_DR_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    code_combination_id            NUMBER := OKC_API.G_MISS_NUM,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    currency_code                  OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    ae_line_type                   OKL_TRNS_ACC_DSTRS.AE_LINE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    template_id                    NUMBER := OKC_API.G_MISS_NUM,
    source_id                      NUMBER := OKC_API.G_MISS_NUM,
    source_table                   OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    accounted_amount               NUMBER := OKC_API.G_MISS_NUM,
    gl_date                        OKL_TRNS_ACC_DSTRS.GL_DATE%TYPE := OKC_API.G_MISS_DATE,
    percentage                     NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKL_TRNS_ACC_DSTRS.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    post_request_id                NUMBER := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TRNS_ACC_DSTRS.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
    currency_conversion_rate       NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TRNS_ACC_DSTRS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_TRNS_ACC_DSTRS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRNS_ACC_DSTRS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRNS_ACC_DSTRS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    aet_id                         NUMBER := OKC_API.G_MISS_NUM,
    posted_yn                      OKL_TRNS_ACC_DSTRS.POSTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    ae_creation_error              OKL_TRNS_ACC_DSTRS.AE_CREATION_ERROR%TYPE := OKC_API.G_MISS_CHAR,
    gl_reversal_flag               OKL_TRNS_ACC_DSTRS.GL_REVERSAL_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    reverse_event_flag             OKL_TRNS_ACC_DSTRS.REVERSE_EVENT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    draft_yn                       OKL_TRNS_ACC_DSTRS.DRAFT_YN%TYPE := OKC_API.G_MISS_CHAR,
    draft_version                  NUMBER := OKC_API.G_MISS_NUM,
    original_dist_id               NUMBER := OKC_API.G_MISS_NUM,
    accounting_event_id            NUMBER := OKC_API.G_MISS_NUM,
    post_to_gl                     OKL_TRNS_ACC_DSTRS.POST_TO_GL%TYPE := OKC_API.G_MISS_CHAR,
    accounting_template_name       OKL_TRNS_ACC_DSTRS.ACCOUNTING_TEMPLATE_NAME%TYPE := OKC_API.G_MISS_CHAR,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
    UPGRADE_STATUS_FLAG                    OKL_TRNS_ACC_DSTRS.UPGRADE_STATUS_FLAG%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_tab_rec                          tab_rec_type;
  TYPE tab_tbl_type IS TABLE OF tab_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tabv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    template_id                    NUMBER := OKC_API.G_MISS_NUM,
    cr_dr_flag                     OKL_TRNS_ACC_DSTRS.CR_DR_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    ae_line_type                   OKL_TRNS_ACC_DSTRS.AE_LINE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    set_of_books_id                NUMBER := OKC_API.G_MISS_NUM,
    code_combination_id            NUMBER := OKC_API.G_MISS_NUM,
    currency_code                  OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_TRNS_ACC_DSTRS.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    source_id                      NUMBER := OKC_API.G_MISS_NUM,
    source_table                   OKL_TRNS_ACC_DSTRS.SOURCE_TABLE%TYPE := OKC_API.G_MISS_CHAR,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    accounted_amount               NUMBER := OKC_API.G_MISS_NUM,
    gl_date                        OKL_TRNS_ACC_DSTRS.GL_DATE%TYPE := OKC_API.G_MISS_DATE,
    percentage                     NUMBER := OKC_API.G_MISS_NUM,
    comments                       OKL_TRNS_ACC_DSTRS.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    post_request_id                NUMBER := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TRNS_ACC_DSTRS.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
    currency_conversion_rate       NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKL_TRNS_ACC_DSTRS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TRNS_ACC_DSTRS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TRNS_ACC_DSTRS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TRNS_ACC_DSTRS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TRNS_ACC_DSTRS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TRNS_ACC_DSTRS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    aet_id                         NUMBER := OKC_API.G_MISS_NUM,
    posted_yn                      OKL_TRNS_ACC_DSTRS.POSTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    ae_creation_error              OKL_TRNS_ACC_DSTRS.AE_CREATION_ERROR%TYPE := OKC_API.G_MISS_CHAR,
    gl_reversal_flag               OKL_TRNS_ACC_DSTRS.GL_REVERSAL_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    reverse_event_flag             OKL_TRNS_ACC_DSTRS.REVERSE_EVENT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    draft_yn                       OKL_TRNS_ACC_DSTRS.draft_yn%TYPE := OKC_API.G_MISS_CHAR,
    draft_version                  NUMBER := OKC_API.G_MISS_NUM,
    original_dist_id               NUMBER := OKC_API.G_MISS_NUM,
    accounting_event_id            NUMBER := OKC_API.G_MISS_NUM,
    post_to_gl                     OKL_TRNS_ACC_DSTRS.POST_TO_GL%TYPE := OKC_API.G_MISS_CHAR,
    accounting_template_name       OKL_TRNS_ACC_DSTRS.ACCOUNTING_TEMPLATE_NAME%TYPE := OKC_API.G_MISS_CHAR,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
    UPGRADE_STATUS_FLAG            OKL_TRNS_ACC_DSTRS.UPGRADE_STATUS_FLAG%TYPE := OKC_API.G_MISS_CHAR);
-- Changes End
  g_miss_tabv_rec                         tabv_rec_type;
  TYPE tabv_tbl_type IS TABLE OF tabv_rec_type
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
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TAB_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
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
    p_tabv_rec                     IN tabv_rec_type,
    x_tabv_rec                     OUT NOCOPY tabv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type,
    x_tabv_tbl                     OUT NOCOPY tabv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type,
    x_tabv_rec                     OUT NOCOPY tabv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type,
    x_tabv_tbl                     OUT NOCOPY tabv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_rec                     IN tabv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tabv_tbl                     IN tabv_tbl_type);

END OKL_TAB_PVT;

/

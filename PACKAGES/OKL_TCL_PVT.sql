--------------------------------------------------------
--  DDL for Package OKL_TCL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TCL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTCLS.pls 120.6 2007/04/19 12:44:51 nikshah noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tcl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    before_transfer_yn             OKL_TXL_CNTRCT_LNS.BEFORE_TRANSFER_YN%TYPE := OKC_API.G_MISS_CHAR,
    tcn_id                         NUMBER := OKC_API.G_MISS_NUM,
    rct_id                         NUMBER := OKC_API.G_MISS_NUM,
    btc_id                         NUMBER := OKC_API.G_MISS_NUM,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    tcl_type                       OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_CNTRCT_LNS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_CNTRCT_LNS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    description                    OKL_TXL_CNTRCT_LNS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    gl_reversal_yn                 OKL_TXL_CNTRCT_LNS.GL_REVERSAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
-- redwin 07/20/2001 changed from currency to currency_code
    currency_code                  OKL_TXL_CNTRCT_LNS.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_CNTRCT_LNS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_TXL_CNTRCT_LNS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    avl_id              NUMBER := OKC_API.G_MISS_NUM,
    bkt_id              OKL_BUCKETS_V.ID%TYPE := OKC_API.G_MISS_NUM,
-- Added by Santonyr May 20th, 2002  Bug 2305542
    kle_id_new			   NUMBER := OKC_API.G_MISS_NUM,
    percentage			   NUMBER := OKC_API.G_MISS_NUM,
-- Added by Hkpatel Sep 17th, 2003
    accrual_rule_yn		   OKL_TXL_CNTRCT_LNS.ACCRUAL_RULE_YN%TYPE := OKC_API.G_MISS_CHAR,
-- Added by PAGARG 21-Oct-2004 Bug# 3964726
    source_column_1                OKL_TXL_CNTRCT_LNS.source_column_1%TYPE := OKC_API.G_MISS_CHAR,
    source_value_1                 OKL_TXL_CNTRCT_LNS.source_value_1%TYPE := OKC_API.G_MISS_NUM,
    source_column_2                OKL_TXL_CNTRCT_LNS.source_column_2%TYPE := OKC_API.G_MISS_CHAR,
    source_value_2                 OKL_TXL_CNTRCT_LNS.source_value_2%TYPE := OKC_API.G_MISS_NUM,
    source_column_3                OKL_TXL_CNTRCT_LNS.source_column_3%TYPE := OKC_API.G_MISS_CHAR,
    source_value_3                 OKL_TXL_CNTRCT_LNS.source_value_3%TYPE := OKC_API.G_MISS_NUM,
    canceled_date                  OKL_TXL_CNTRCT_LNS.canceled_date%TYPE := OKC_API.G_MISS_DATE,
-- Added by DJANASWA 02-Feb-2007 for SLA project
    tax_line_id                    OKL_TXL_CNTRCT_LNS.tax_line_id%TYPE :=  OKC_API.G_MISS_NUM,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
    stream_type_code               OKL_TXL_CNTRCT_LNS.stream_type_code%TYPE := OKC_API.G_MISS_CHAR,
    stream_type_purpose            OKL_TXL_CNTRCT_LNS.stream_type_purpose%TYPE := OKC_API.G_MISS_CHAR,
    asset_book_type_name           OKL_TXL_CNTRCT_LNS.asset_book_type_name%TYPE :=  OKC_API.G_MISS_CHAR,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
    UPGRADE_STATUS_FLAG                    OKL_TXL_CNTRCT_LNS.UPGRADE_STATUS_FLAG%TYPE := OKC_API.G_MISS_CHAR
    );

  g_miss_tcl_rec                          tcl_rec_type;

  TYPE tcl_tbl_type IS TABLE OF tcl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tclv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
    rct_id                         NUMBER := OKC_API.G_MISS_NUM,
    btc_id                         NUMBER := OKC_API.G_MISS_NUM,
    tcn_id                         NUMBER := OKC_API.G_MISS_NUM,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    before_transfer_yn             OKL_TXL_CNTRCT_LNS.BEFORE_TRANSFER_YN%TYPE := OKC_API.G_MISS_CHAR,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    description                    OKL_TXL_CNTRCT_LNS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
-- redwin 07/20/2001 changed from currency to currency_code
    currency_code                  OKL_TXL_CNTRCT_LNS.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    gl_reversal_yn                 OKL_TXL_CNTRCT_LNS.GL_REVERSAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_TXL_CNTRCT_LNS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_CNTRCT_LNS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_CNTRCT_LNS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    tcl_type                       OKL_TXL_CNTRCT_LNS.TCL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_CNTRCT_LNS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_CNTRCT_LNS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_CNTRCT_LNS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    avl_id              NUMBER := OKC_API.G_MISS_NUM,
    bkt_id              NUMBER := OKC_API.G_MISS_NUM,
-- Added by Santonyr May 20th, 2002  Bug 2305542
    kle_id_new                     NUMBER := OKC_API.G_MISS_NUM,
    percentage                     NUMBER := OKC_API.G_MISS_NUM,
-- Added by Hkpatel Sep 17th, 2003
    accrual_rule_yn		   OKL_TXL_CNTRCT_LNS.ACCRUAL_RULE_YN%TYPE := OKC_API.G_MISS_CHAR,
-- Added by PAGARG 21-Oct-2004 Bug# 3964726
    source_column_1                OKL_TXL_CNTRCT_LNS.source_column_1%TYPE := OKC_API.G_MISS_CHAR,
    source_value_1                 OKL_TXL_CNTRCT_LNS.source_value_1%TYPE := OKC_API.G_MISS_NUM,
    source_column_2                OKL_TXL_CNTRCT_LNS.source_column_2%TYPE := OKC_API.G_MISS_CHAR,
    source_value_2                 OKL_TXL_CNTRCT_LNS.source_value_2%TYPE := OKC_API.G_MISS_NUM,
    source_column_3                OKL_TXL_CNTRCT_LNS.source_column_3%TYPE := OKC_API.G_MISS_CHAR,
    source_value_3                 OKL_TXL_CNTRCT_LNS.source_value_3%TYPE := OKC_API.G_MISS_NUM,
    canceled_date                  OKL_TXL_CNTRCT_LNS.canceled_date%TYPE := OKC_API.G_MISS_DATE,
-- Added by DJANASWA 02-Feb-2007 for SLA project
    tax_line_id                    OKL_TXL_CNTRCT_LNS.tax_line_id%TYPE :=  OKC_API.G_MISS_NUM,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
    stream_type_code               OKL_TXL_CNTRCT_LNS.stream_type_code%TYPE := OKC_API.G_MISS_CHAR,
    stream_type_purpose            OKL_TXL_CNTRCT_LNS.stream_type_purpose%TYPE := OKC_API.G_MISS_CHAR,
    asset_book_type_name           OKL_TXL_CNTRCT_LNS.asset_book_type_name%TYPE :=  OKC_API.G_MISS_CHAR,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
    UPGRADE_STATUS_FLAG                    OKL_TXL_CNTRCT_LNS.UPGRADE_STATUS_FLAG%TYPE := OKC_API.G_MISS_CHAR
    );

  g_miss_tclv_rec                         tclv_rec_type;
  TYPE tclv_tbl_type IS TABLE OF tclv_rec_type
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
  G_UPPERCASE_REQUIRED	CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKL_UNIQUE_KEY_VALIDATION_FAILED';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TCL_PVT';
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
    p_tclv_rec                     IN tclv_rec_type,
    x_tclv_rec                     OUT NOCOPY tclv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type,
    x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type,
    x_tclv_rec                     OUT NOCOPY tclv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type,
    x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type);

END OKL_TCL_PVT;

/

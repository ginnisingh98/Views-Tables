--------------------------------------------------------
--  DDL for Package OKL_TQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TQL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTQLS.pls 120.3 2005/06/17 22:58:31 rmunjulu noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tql_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    qlt_code                       OKL_TXL_QUOTE_LINES_B.QLT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    qte_id                         NUMBER := OKC_API.G_MISS_NUM,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    modified_yn                    OKL_TXL_QUOTE_LINES_B.MODIFIED_YN%TYPE := OKC_API.G_MISS_CHAR,
    taxed_yn                       OKL_TXL_QUOTE_LINES_B.TAXED_YN%TYPE := OKC_API.G_MISS_CHAR,
    defaulted_yn                   OKL_TXL_QUOTE_LINES_B.DEFAULTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_QUOTE_LINES_B.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    attribute_category             OKL_TXL_QUOTE_LINES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_QUOTE_LINES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_QUOTE_LINES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_QUOTE_LINES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_QUOTE_LINES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_QUOTE_LINES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_QUOTE_LINES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_QUOTE_LINES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_QUOTE_LINES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_QUOTE_LINES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKL_TXL_QUOTE_LINES_B.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    period                         OKL_TXL_QUOTE_LINES_B.PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    number_of_periods              NUMBER := OKC_API.G_MISS_NUM,
    lock_level_step                OKL_TXL_QUOTE_LINES_B.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR,
    advance_or_arrears             OKL_TXL_QUOTE_LINES_B.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    yield_name                     OKL_TXL_QUOTE_LINES_B.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    yield_value                    NUMBER := OKC_API.G_MISS_NUM,
    implicit_interest_rate         NUMBER := OKC_API.G_MISS_NUM,
    asset_value                    NUMBER := OKC_API.G_MISS_NUM,
    residual_value                 NUMBER := OKC_API.G_MISS_NUM,
    unbilled_receivables           NUMBER := OKC_API.G_MISS_NUM,
    asset_quantity                 NUMBER := OKC_API.G_MISS_NUM,
    quote_quantity                 NUMBER := OKC_API.G_MISS_NUM,
    split_kle_id                   NUMBER := OKC_API.G_MISS_NUM,
    split_kle_name                 OKL_TXL_QUOTE_LINES_B.SPLIT_KLE_NAME%TYPE := OKC_API.G_MISS_CHAR, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
    currency_code                  OKL_TXL_QUOTE_LINES_B.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_TXL_QUOTE_LINES_B.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_TXL_QUOTE_LINES_B.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_TXL_QUOTE_LINES_B.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TXL_QUOTE_LINES_B.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
  -- BAKUCHIB 2667636 End
    -- PAGARG 15-Feb-05 Bug 4161133 Start
    -- Added new column DUE_DATE in OKL_TXL_QUOTE_LINES_B
    due_date                       OKL_TXL_QUOTE_LINES_B.DUE_DATE%TYPE := OKL_API.G_MISS_DATE,
    -- PAGARG 15-Feb-05 Bug 4161133 End
    --rmunjulu 23-May-05 Sales_Tax_Enhancements
    try_id                         OKL_TXL_QUOTE_LINES_B.TRY_ID%TYPE := OKL_API.G_MISS_NUM);
  g_miss_tql_rec                          tql_rec_type;
  TYPE tql_tbl_type IS TABLE OF tql_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE OklTxlQuoteLinesTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_TXL_QUOTE_LINES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_TXL_QUOTE_LINES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_TXL_QUOTE_LINES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_TXL_QUOTE_LINES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_QUOTE_LINES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_QUOTE_LINES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOklTxlQuoteLinesTlRec              OklTxlQuoteLinesTlRecType;
  TYPE OklTxlQuoteLinesTlTblType IS TABLE OF OklTxlQuoteLinesTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE tqlv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKL_TXL_QUOTE_LINES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    qlt_code                       OKL_TXL_QUOTE_LINES_V.QLT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    sty_id                         NUMBER := OKC_API.G_MISS_NUM,
    qte_id                         NUMBER := OKC_API.G_MISS_NUM,
    line_number                    NUMBER := OKC_API.G_MISS_NUM,
    description                    OKL_TXL_QUOTE_LINES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    modified_yn                    OKL_TXL_QUOTE_LINES_V.MODIFIED_YN%TYPE := OKC_API.G_MISS_CHAR,
    taxed_yn                       OKL_TXL_QUOTE_LINES_V.TAXED_YN%TYPE := OKC_API.G_MISS_CHAR,
    defaulted_yn                   OKL_TXL_QUOTE_LINES_V.DEFAULTED_YN%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKL_TXL_QUOTE_LINES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKL_TXL_QUOTE_LINES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKL_TXL_QUOTE_LINES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKL_TXL_QUOTE_LINES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKL_TXL_QUOTE_LINES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKL_TXL_QUOTE_LINES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKL_TXL_QUOTE_LINES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKL_TXL_QUOTE_LINES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    org_id                         NUMBER := OKC_API.G_MISS_NUM,
    request_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_application_id         NUMBER := OKC_API.G_MISS_NUM,
    program_id                     NUMBER := OKC_API.G_MISS_NUM,
    program_update_date            OKL_TXL_QUOTE_LINES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_TXL_QUOTE_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_TXL_QUOTE_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKL_TXL_QUOTE_LINES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    period                         OKL_TXL_QUOTE_LINES_V.PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    number_of_periods              NUMBER := OKC_API.G_MISS_NUM,
    lock_level_step                OKL_TXL_QUOTE_LINES_V.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR,
    advance_or_arrears             OKL_TXL_QUOTE_LINES_V.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    yield_name                     OKL_TXL_QUOTE_LINES_V.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
    yield_value                    NUMBER := OKC_API.G_MISS_NUM,
    implicit_interest_rate         NUMBER := OKC_API.G_MISS_NUM,
    asset_value                    NUMBER := OKC_API.G_MISS_NUM,
    residual_value                 NUMBER := OKC_API.G_MISS_NUM,
    unbilled_receivables           NUMBER := OKC_API.G_MISS_NUM,
    asset_quantity                 NUMBER := OKC_API.G_MISS_NUM,
    quote_quantity                 NUMBER := OKC_API.G_MISS_NUM,
    split_kle_id                   NUMBER := OKC_API.G_MISS_NUM,
    split_kle_name                 OKL_TXL_QUOTE_LINES_V.SPLIT_KLE_NAME%TYPE := OKC_API.G_MISS_CHAR, -- RMUNJULU 2757312
  -- BAKUCHIB 2667636 Start
    currency_code                  OKL_TXL_QUOTE_LINES_V.CURRENCY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_code       OKL_TXL_QUOTE_LINES_V.CURRENCY_CONVERSION_CODE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_type       OKL_TXL_QUOTE_LINES_V.CURRENCY_CONVERSION_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    currency_conversion_rate       OKL_TXL_QUOTE_LINES_V.CURRENCY_CONVERSION_RATE%TYPE := OKC_API.G_MISS_NUM,
    currency_conversion_date       OKL_TXL_QUOTE_LINES_V.CURRENCY_CONVERSION_DATE%TYPE := OKC_API.G_MISS_DATE,
  -- BAKUCHIB 2667636 End
    -- PAGARG 15-Feb-05 Bug 4161133 Start
    -- Added new column DUE_DATE in OKL_TXL_QUOTE_LINES_B
    due_date                       OKL_TXL_QUOTE_LINES_B.DUE_DATE%TYPE := OKL_API.G_MISS_DATE,
    -- PAGARG 15-Feb-05 Bug 4161133 End
    --rmunjulu 23-May-05 Sales_Tax_Enhancements
    try_id                         OKL_TXL_QUOTE_LINES_V.TRY_ID%TYPE := OKL_API.G_MISS_NUM);
  g_miss_tqlv_rec                         tqlv_rec_type;
  TYPE tqlv_tbl_type IS TABLE OF tqlv_rec_type
        INDEX BY BINARY_INTEGER;

  -- PAGARG Bug 4299668 Declare table of records to define arrays used in bulk insert
  -- **Start**
  TYPE NumberTabTyp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
  TYPE Number4TabTyp IS TABLE OF NUMBER(4)
       INDEX BY BINARY_INTEGER;
  TYPE Number9TabTyp IS TABLE OF NUMBER(9)
       INDEX BY BINARY_INTEGER;
  TYPE Number14p3TabTyp IS TABLE OF NUMBER(14,3)
       INDEX BY BINARY_INTEGER;
  TYPE Number15TabTyp IS TABLE OF NUMBER(15)
       INDEX BY BINARY_INTEGER;
  TYPE Number18p15TabTyp IS TABLE OF NUMBER(18,15)
       INDEX BY BINARY_INTEGER;
  TYPE DateTabTyp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;
  TYPE Var3TabTyp IS TABLE OF VARCHAR2(3)
       INDEX BY BINARY_INTEGER;
  TYPE Var10TabTyp IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;
  TYPE Var12TabTyp IS TABLE OF VARCHAR2(12)
       INDEX BY BINARY_INTEGER;
  TYPE Var15TabTyp IS TABLE OF VARCHAR2(15)
       INDEX BY BINARY_INTEGER;
  TYPE Var30TabTyp IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;
  TYPE Var90TabTyp IS TABLE OF VARCHAR2(90)
       INDEX BY BINARY_INTEGER;
  TYPE Var150TabTyp IS TABLE OF VARCHAR2(150)
       INDEX BY BINARY_INTEGER;
  TYPE Var450TabTyp IS TABLE OF VARCHAR2(450)
       INDEX BY BINARY_INTEGER;
  TYPE Var1995TabTyp IS TABLE OF VARCHAR2(1995)
       INDEX BY BINARY_INTEGER;
  -- PAGARG Bug 4299668 **End**

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_YES			        CONSTANT VARCHAR2(3)   :=  'Y';
  G_NO			        CONSTANT VARCHAR2(3)   :=  'N';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TQL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type,
    x_tqlv_rec                     OUT NOCOPY tqlv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type,
    x_tqlv_rec                     OUT NOCOPY tqlv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_rec                     IN tqlv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type);

  -- PAGARG Bug 4299668 New Procedure for bulk insert
  PROCEDURE insert_row_bulk(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tqlv_tbl                     IN tqlv_tbl_type,
    x_tqlv_tbl                     OUT NOCOPY tqlv_tbl_type);

END OKL_TQL_PVT;

 

/

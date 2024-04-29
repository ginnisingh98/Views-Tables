--------------------------------------------------------
--  DDL for Package OKS_CDT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CDT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRCDTS.pls 120.2 2005/07/21 04:39:05 parkumar noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE cdt_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cdt_type                       OKS_K_DEFAULTS.CDT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_K_DEFAULTS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_K_DEFAULTS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    segment_id1                    OKS_K_DEFAULTS.SEGMENT_ID1%TYPE := OKC_API.G_MISS_CHAR,
    segment_id2                    OKS_K_DEFAULTS.SEGMENT_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code               OKS_K_DEFAULTS.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    pdf_id                         NUMBER := OKC_API.G_MISS_NUM,
    qcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    cgp_new_id                     NUMBER := OKC_API.G_MISS_NUM,
    cgp_renew_id                   NUMBER := OKC_API.G_MISS_NUM,
    price_list_id1                 OKS_K_DEFAULTS.PRICE_LIST_ID1%TYPE := OKC_API.G_MISS_CHAR,
    price_list_id2                 OKS_K_DEFAULTS.PRICE_LIST_ID2%TYPE := OKC_API.G_MISS_CHAR,
    renewal_type                   OKS_K_DEFAULTS.RENEWAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    po_required_yn                 OKS_K_DEFAULTS.PO_REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR,
    renewal_pricing_type           OKS_K_DEFAULTS.RENEWAL_PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    markup_percent                 NUMBER := OKC_API.G_MISS_NUM,
    start_date                     OKS_K_DEFAULTS.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKS_K_DEFAULTS.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    --security_group_id              NUMBER := OKC_API.G_MISS_NUM,
    rle_code                       OKS_K_DEFAULTS.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    revenue_estimated_percent      NUMBER := OKC_API.G_MISS_NUM,
    revenue_estimated_duration     NUMBER := OKC_API.G_MISS_NUM,
    revenue_estimated_period       OKS_K_DEFAULTS.REVENUE_ESTIMATED_PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    template_set_id                NUMBER := OKC_API.G_MISS_NUM,
    THRESHOLD_CURRENCY             OKS_K_DEFAULTS.THRESHOLD_CURRENCY%TYPE := OKC_API.G_MISS_CHAR,
    THRESHOLD_AMOUNT               NUMBER := OKC_API.G_MISS_NUM,
    EMAIL_ADDRESS                  OKS_K_DEFAULTS.EMAIL_ADDRESS%TYPE := OKC_API.G_MISS_CHAR,
    BILLING_PROFILE_ID             NUMBER := OKC_API.G_MISS_NUM,
    USER_ID                        NUMBER := OKC_API.G_MISS_NUM,
    THRESHOLD_ENABLED_YN           OKS_K_DEFAULTS.THRESHOLD_ENABLED_YN%TYPE := OKC_API.G_MISS_CHAR,
    GRACE_PERIOD                   OKS_K_DEFAULTS.GRACE_PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    GRACE_DURATION                 NUMBER := OKC_API.G_MISS_NUM,
    PAYMENT_TERMS_ID1              OKS_K_DEFAULTS.PAYMENT_TERMS_ID1%TYPE := OKC_API.G_MISS_CHAR,
    PAYMENT_TERMS_ID2              OKS_K_DEFAULTS.PAYMENT_TERMS_ID2%TYPE := OKC_API.G_MISS_CHAR,
    EVERGREEN_THRESHOLD_CURR       OKS_K_DEFAULTS.EVERGREEN_THRESHOLD_CURR%TYPE := OKC_API.G_MISS_CHAR,
    EVERGREEN_THRESHOLD_AMT        NUMBER := OKC_API.G_MISS_NUM,
    PAYMENT_METHOD                 OKS_K_DEFAULTS.PAYMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    PAYMENT_THRESHOLD_CURR        OKS_K_DEFAULTS.PAYMENT_THRESHOLD_CURR%TYPE := OKC_API.G_MISS_CHAR,
    PAYMENT_THRESHOLD_AMT         NUMBER := OKC_API.G_MISS_NUM,
    INTERFACE_PRICE_BREAK         OKS_K_DEFAULTS.INTERFACE_PRICE_BREAK%TYPE := OKC_API.G_MISS_CHAR,
    CREDIT_AMOUNT                 OKS_K_DEFAULTS.CREDIT_AMOUNT%TYPE := OKC_API.G_MISS_CHAR,
-- R12 Data Model Changes 4485150 Start
    BASE_CURRENCY	          OKS_K_DEFAULTS.BASE_CURRENCY%TYPE  := OKC_API.G_MISS_CHAR,
    APPROVAL_TYPE	          OKS_K_DEFAULTS.APPROVAL_TYPE%TYPE  := OKC_API.G_MISS_CHAR,
    EVERGREEN_APPROVAL_TYPE	  OKS_K_DEFAULTS.EVERGREEN_APPROVAL_TYPE%TYPE  := OKC_API.G_MISS_CHAR,
    ONLINE_APPROVAL_TYPE	  OKS_K_DEFAULTS.ONLINE_APPROVAL_TYPE%TYPE      := OKC_API.G_MISS_CHAR,
    PURCHASE_ORDER_FLAG	          OKS_K_DEFAULTS.PURCHASE_ORDER_FLAG%TYPE      := OKC_API.G_MISS_CHAR,
    CREDIT_CARD_FLAG	          OKS_K_DEFAULTS.CREDIT_CARD_FLAG%TYPE         := OKC_API.G_MISS_CHAR,
    WIRE_FLAG	                  OKS_K_DEFAULTS.WIRE_FLAG%TYPE  := OKC_API.G_MISS_CHAR,
    COMMITMENT_NUMBER_FLAG	  OKS_K_DEFAULTS.COMMITMENT_NUMBER_FLAG%TYPE  := OKC_API.G_MISS_CHAR,
    CHECK_FLAG	                  OKS_K_DEFAULTS.CHECK_FLAG%TYPE  := OKC_API.G_MISS_CHAR,
    PERIOD_TYPE	                  OKS_K_DEFAULTS.PERIOD_TYPE%TYPE	  := OKC_API.G_MISS_CHAR,
    PERIOD_START	          OKS_K_DEFAULTS.PERIOD_START%TYPE  := OKC_API.G_MISS_CHAR,
    PRICE_UOM	                  OKS_K_DEFAULTS.PRICE_UOM%TYPE  := OKC_API.G_MISS_CHAR,
    TEMPLATE_LANGUAGE	          OKS_K_DEFAULTS.TEMPLATE_LANGUAGE%TYPE  := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
    );
  g_miss_cdt_rec                          cdt_rec_type;

  TYPE cdt_tbl_type IS TABLE OF cdt_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cdtv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cdt_type                       OKS_K_DEFAULTS_V.CDT_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKS_K_DEFAULTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKS_K_DEFAULTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    segment_id1                    OKS_K_DEFAULTS_V.SEGMENT_ID1%TYPE := OKC_API.G_MISS_CHAR,
    segment_id2                    OKS_K_DEFAULTS_V.SEGMENT_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code               OKS_K_DEFAULTS_V.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    pdf_id                         NUMBER := OKC_API.G_MISS_NUM,
    qcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    cgp_new_id                     NUMBER := OKC_API.G_MISS_NUM,
    cgp_renew_id                   NUMBER := OKC_API.G_MISS_NUM,
    price_list_id1                 OKS_K_DEFAULTS_V.PRICE_LIST_ID1%TYPE := OKC_API.G_MISS_CHAR,
    price_list_id2                 OKS_K_DEFAULTS_V.PRICE_LIST_ID2%TYPE := OKC_API.G_MISS_CHAR,
    renewal_type                   OKS_K_DEFAULTS_V.RENEWAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    po_required_yn                 OKS_K_DEFAULTS_V.PO_REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR,
    renewal_pricing_type           OKS_K_DEFAULTS_V.RENEWAL_PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    markup_percent                 NUMBER := OKC_API.G_MISS_NUM,
    rle_code                       OKS_K_DEFAULTS_V.RLE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKS_K_DEFAULTS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKS_K_DEFAULTS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    revenue_estimated_percent      NUMBER := OKC_API.G_MISS_NUM,
    revenue_estimated_duration     NUMBER := OKC_API.G_MISS_NUM,
    revenue_estimated_period       OKS_K_DEFAULTS_V.REVENUE_ESTIMATED_PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    template_set_id                NUMBER := OKC_API.G_MISS_NUM,
    THRESHOLD_CURRENCY             OKS_K_DEFAULTS.THRESHOLD_CURRENCY%TYPE := OKC_API.G_MISS_CHAR,
    THRESHOLD_AMOUNT               NUMBER := OKC_API.G_MISS_NUM,
    EMAIL_ADDRESS                  OKS_K_DEFAULTS.EMAIL_ADDRESS%TYPE := OKC_API.G_MISS_CHAR,
    BILLING_PROFILE_ID             NUMBER := OKC_API.G_MISS_NUM,
    USER_ID                        NUMBER := OKC_API.G_MISS_NUM,
    THRESHOLD_ENABLED_YN           OKS_K_DEFAULTS.THRESHOLD_ENABLED_YN%TYPE := OKC_API.G_MISS_CHAR,
    GRACE_PERIOD                   OKS_K_DEFAULTS.GRACE_PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    GRACE_DURATION                 NUMBER := OKC_API.G_MISS_NUM,
    PAYMENT_TERMS_ID1              OKS_K_DEFAULTS.PAYMENT_TERMS_ID1%TYPE := OKC_API.G_MISS_CHAR,
    PAYMENT_TERMS_ID2              OKS_K_DEFAULTS.PAYMENT_TERMS_ID2%TYPE := OKC_API.G_MISS_CHAR,
    EVERGREEN_THRESHOLD_CURR       OKS_K_DEFAULTS.EVERGREEN_THRESHOLD_CURR%TYPE := OKC_API.G_MISS_CHAR,
    EVERGREEN_THRESHOLD_AMT        NUMBER := OKC_API.G_MISS_NUM,
    PAYMENT_METHOD                 OKS_K_DEFAULTS.PAYMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    PAYMENT_THRESHOLD_CURR        OKS_K_DEFAULTS.PAYMENT_THRESHOLD_CURR%TYPE := OKC_API.G_MISS_CHAR,
    PAYMENT_THRESHOLD_AMT         NUMBER := OKC_API.G_MISS_NUM,
    INTERFACE_PRICE_BREAK         OKS_K_DEFAULTS.INTERFACE_PRICE_BREAK %TYPE := OKC_API.G_MISS_CHAR,
    CREDIT_AMOUNT                 OKS_K_DEFAULTS.CREDIT_AMOUNT %TYPE := OKC_API.G_MISS_CHAR,
-- R12 Data Model Changes 4485150 Start  /* mmadhavi 4485150 : add other columns */
    PERIOD_TYPE                   OKS_K_DEFAULTS.PERIOD_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    PERIOD_START                  OKS_K_DEFAULTS.PERIOD_START%TYPE := OKC_API.G_MISS_CHAR,
    PRICE_UOM                     OKS_K_DEFAULTS.PRICE_UOM%TYPE := OKC_API.G_MISS_CHAR,
    BASE_CURRENCY	          OKS_K_DEFAULTS.BASE_CURRENCY%TYPE  := OKC_API.G_MISS_CHAR,
    APPROVAL_TYPE	          OKS_K_DEFAULTS.APPROVAL_TYPE%TYPE  := OKC_API.G_MISS_CHAR,
    EVERGREEN_APPROVAL_TYPE	  OKS_K_DEFAULTS.EVERGREEN_APPROVAL_TYPE%TYPE  := OKC_API.G_MISS_CHAR,
    ONLINE_APPROVAL_TYPE	  OKS_K_DEFAULTS.ONLINE_APPROVAL_TYPE%TYPE      := OKC_API.G_MISS_CHAR,
    PURCHASE_ORDER_FLAG	          OKS_K_DEFAULTS.PURCHASE_ORDER_FLAG%TYPE      := OKC_API.G_MISS_CHAR,
    CREDIT_CARD_FLAG	          OKS_K_DEFAULTS.CREDIT_CARD_FLAG%TYPE         := OKC_API.G_MISS_CHAR,
    WIRE_FLAG	                  OKS_K_DEFAULTS.WIRE_FLAG%TYPE  := OKC_API.G_MISS_CHAR,
    COMMITMENT_NUMBER_FLAG	  OKS_K_DEFAULTS.COMMITMENT_NUMBER_FLAG%TYPE  := OKC_API.G_MISS_CHAR,
    CHECK_FLAG	                  OKS_K_DEFAULTS.CHECK_FLAG%TYPE  := OKC_API.G_MISS_CHAR,
    TEMPLATE_LANGUAGE	          OKS_K_DEFAULTS.TEMPLATE_LANGUAGE%TYPE  := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
    );
  g_miss_cdtv_rec                         cdtv_rec_type;
  TYPE cdtv_tbl_type IS TABLE OF cdtv_rec_type
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
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_DEFAULTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_CDT_PVT';
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
    p_cdtv_rec                     IN cdtv_rec_type,
    x_cdtv_rec                     OUT NOCOPY cdtv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type,
    x_cdtv_tbl                     OUT NOCOPY cdtv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type,
    x_cdtv_rec                     OUT NOCOPY cdtv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type,
    x_cdtv_tbl                     OUT NOCOPY cdtv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_rec                     IN cdtv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cdtv_tbl                     IN cdtv_tbl_type);

END OKS_CDT_PVT;

 

/

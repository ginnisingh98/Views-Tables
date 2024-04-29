--------------------------------------------------------
--  DDL for Package OKL_SIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSIFS.pls 115.5 2002/12/18 01:20:37 smahapat noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sif_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    fasb_acct_treatment_method     OKL_STREAM_INTERFACES.FASB_ACCT_TREATMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    date_payments_commencement     OKL_STREAM_INTERFACES.DATE_PAYMENTS_COMMENCEMENT%TYPE := OKC_API.G_MISS_DATE,
    country                        OKL_STREAM_INTERFACES.COUNTRY%TYPE := OKC_API.G_MISS_CHAR,
    security_deposit_amount        NUMBER := OKC_API.G_MISS_NUM,
    date_delivery                  OKL_STREAM_INTERFACES.DATE_DELIVERY%TYPE := OKC_API.G_MISS_DATE,
    irs_tax_treatment_method       OKL_STREAM_INTERFACES.IRS_TAX_TREATMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    sif_mode                       OKL_STREAM_INTERFACES.SIF_MODE%TYPE := OKC_API.G_MISS_CHAR,
    pricing_template_name          OKL_STREAM_INTERFACES.PRICING_TEMPLATE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    date_sec_deposit_collected     OKL_STREAM_INTERFACES.DATE_SEC_DEPOSIT_COLLECTED%TYPE := OKC_API.G_MISS_DATE,
    transaction_number             NUMBER := OKC_API.G_MISS_NUM,
    total_funding                  NUMBER := OKC_API.G_MISS_NUM,
    sis_code                       OKL_STREAM_INTERFACES.SIS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    adjust                         OKL_STREAM_INTERFACES.ADJUST%TYPE := OKC_API.G_MISS_CHAR,
    implicit_interest_rate	   NUMBER := OKC_API.G_MISS_NUM,
    adjustment_method              OKL_STREAM_INTERFACES.ADJUSTMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    date_processed                 OKL_STREAM_INTERFACES.DATE_PROCESSED%TYPE := OKC_API.G_MISS_DATE,
    orp_code                       OKL_STREAM_INTERFACES.ORP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    lending_rate		   NUMBER := OKC_API.G_MISS_NUM,
    rvi_yn						   OKL_STREAM_INTERFACES.RVI_YN%TYPE := OKC_API.G_MISS_CHAR,
    rvi_rate			   NUMBER := OKC_API.G_MISS_NUM,
    stream_interface_attribute01   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_STREAM_INTERFACES.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_STREAM_INTERFACES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_STREAM_INTERFACES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    REQUEST_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_APPLICATION_ID         NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE            OKL_STREAM_INTERFACES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    -- mvasudev -- 05/13/2002
    JTOT_OBJECT1_CODE              OKL_STREAM_INTERFACES.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    OBJECT1_ID1                    OKL_STREAM_INTERFACES.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    OBJECT1_ID2                    OKL_STREAM_INTERFACES.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    TERM                           NUMBER := OKC_API.G_MISS_NUM,
    STRUCTURE                      OKL_STREAM_INTERFACES.STRUCTURE%TYPE := OKC_API.G_MISS_CHAR,
    DEAL_TYPE                      OKL_STREAM_INTERFACES.DEAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    LOG_FILE                       OKL_STREAM_INTERFACES.LOG_FILE%TYPE := OKC_API.G_MISS_CHAR,
    FIRST_PAYMENT                  OKL_STREAM_INTERFACES.FIRST_PAYMENT%TYPE := OKC_API.G_MISS_CHAR,
    LAST_PAYMENT                   OKL_STREAM_INTERFACES.LAST_PAYMENT%TYPE := OKC_API.G_MISS_CHAR,
    -- mvasudev, Bug#2650599
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    purpose_code                   OKL_STREAM_INTERFACES.PURPOSE_CODE%TYPE := OKC_API.G_MISS_CHAR
    -- end, mvasudev, Bug#2650599
    );
  g_miss_sif_rec                          sif_rec_type;
  TYPE sif_tbl_type IS TABLE OF sif_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE sifv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    fasb_acct_treatment_method     OKL_STREAM_INTERFACES_V.FASB_ACCT_TREATMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    date_payments_commencement     OKL_STREAM_INTERFACES_V.DATE_PAYMENTS_COMMENCEMENT%TYPE := OKC_API.G_MISS_DATE,
    country                        OKL_STREAM_INTERFACES_V.COUNTRY%TYPE := OKC_API.G_MISS_CHAR,
    security_deposit_amount        NUMBER := OKC_API.G_MISS_NUM,
    date_delivery                  OKL_STREAM_INTERFACES_V.DATE_DELIVERY%TYPE := OKC_API.G_MISS_DATE,
    irs_tax_treatment_method       OKL_STREAM_INTERFACES_V.IRS_TAX_TREATMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    sif_mode                       OKL_STREAM_INTERFACES_V.SIF_MODE%TYPE := OKC_API.G_MISS_CHAR,
    pricing_template_name          OKL_STREAM_INTERFACES_V.PRICING_TEMPLATE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    date_sec_deposit_collected     OKL_STREAM_INTERFACES_V.DATE_SEC_DEPOSIT_COLLECTED%TYPE := OKC_API.G_MISS_DATE,
    transaction_number             NUMBER := OKC_API.G_MISS_NUM,
    total_funding                  NUMBER := OKC_API.G_MISS_NUM,
    sis_code                       OKL_STREAM_INTERFACES_V.SIS_CODE%TYPE := OKC_API.G_MISS_CHAR,
    khr_id                         NUMBER := OKC_API.G_MISS_NUM,
    adjust                         OKL_STREAM_INTERFACES_V.ADJUST%TYPE := OKC_API.G_MISS_CHAR,
    implicit_interest_rate	   NUMBER := OKC_API.G_MISS_NUM,
    adjustment_method              OKL_STREAM_INTERFACES_V.ADJUSTMENT_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    date_processed                 OKL_STREAM_INTERFACES_V.DATE_PROCESSED%TYPE := OKC_API.G_MISS_DATE,
    orp_code                       OKL_STREAM_INTERFACES_V.ORP_CODE%TYPE := OKC_API.G_MISS_CHAR,
    lending_rate		   NUMBER := OKC_API.G_MISS_NUM,
    rvi_yn						   OKL_STREAM_INTERFACES_V.RVI_YN%TYPE := OKC_API.G_MISS_CHAR,
    rvi_rate			   NUMBER := OKC_API.G_MISS_NUM,
    stream_interface_attribute01   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_STREAM_INTERFACES_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_STREAM_INTERFACES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_STREAM_INTERFACES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    REQUEST_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_APPLICATION_ID         NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_ID                     NUMBER := OKC_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE            OKL_STREAM_INTERFACES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    -- mvasudev -- 05/13/2002
    JTOT_OBJECT1_CODE              OKL_STREAM_INTERFACES_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    OBJECT1_ID1                    OKL_STREAM_INTERFACES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    OBJECT1_ID2                    OKL_STREAM_INTERFACES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    TERM                           NUMBER := OKC_API.G_MISS_NUM,
    STRUCTURE                      OKL_STREAM_INTERFACES_V.STRUCTURE%TYPE := OKC_API.G_MISS_CHAR,
    DEAL_TYPE                      OKL_STREAM_INTERFACES_V.DEAL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    LOG_FILE                       OKL_STREAM_INTERFACES_V.LOG_FILE%TYPE := OKC_API.G_MISS_CHAR,
    FIRST_PAYMENT                  OKL_STREAM_INTERFACES_V.FIRST_PAYMENT%TYPE := OKC_API.G_MISS_CHAR,
    LAST_PAYMENT                   OKL_STREAM_INTERFACES_V.LAST_PAYMENT%TYPE := OKC_API.G_MISS_CHAR,
    -- mvasudev, Bug#2650599
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    purpose_code                   OKL_STREAM_INTERFACES_V.PURPOSE_CODE%TYPE := OKC_API.G_MISS_CHAR
    -- end, mvasudev, Bug#2650599
    );
  g_miss_sifv_rec                         sifv_rec_type;
  TYPE sifv_tbl_type IS TABLE OF sifv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(200) := OKC_API.G_APP_NAME;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;

    -- START CHANGE : akjain -- 08/15/2001
    -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','OKL_SQLCODE', 'OKL_SQLERRM','Unexpected Error'
    G_OKL_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
    G_OKL_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
    G_OKL_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';

    -- Added Exception for Halt_validation
    --------------------------------------------------------------------------------
    -- ERRORS AND EXCEPTIONS
    --------------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
    -- END change : akjain

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SIF_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
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
    p_sifv_rec                     IN sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type);

END OKL_SIF_PVT;

 

/

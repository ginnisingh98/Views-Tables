--------------------------------------------------------
--  DDL for Package OKS_BPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BPE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBPES.pls 120.0 2005/05/25 18:36:18 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_BILLING_PROFILES_V Record Spec
  TYPE bpev_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,sfwt_flag                      OKS_BILLING_PROFILES_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,mda_code                       OKS_BILLING_PROFILES_V.MDA_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,owned_party_id1                OKS_BILLING_PROFILES_V.OWNED_PARTY_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,owned_party_id2                OKS_BILLING_PROFILES_V.OWNED_PARTY_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,dependent_cust_acct_id1        OKS_BILLING_PROFILES_V.DEPENDENT_CUST_ACCT_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,dependent_cust_acct_id2        OKS_BILLING_PROFILES_V.DEPENDENT_CUST_ACCT_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,bill_to_address_id1            OKS_BILLING_PROFILES_V.BILL_TO_ADDRESS_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,bill_to_address_id2            OKS_BILLING_PROFILES_V.BILL_TO_ADDRESS_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,uom_code_frequency             OKS_BILLING_PROFILES_V.UOM_CODE_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,tce_code_frequency             OKS_BILLING_PROFILES_V.TCE_CODE_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,uom_code_sec_offset            OKS_BILLING_PROFILES_V.UOM_CODE_SEC_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,tce_code_sec_offset            OKS_BILLING_PROFILES_V.TCE_CODE_SEC_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,uom_code_pri_offset            OKS_BILLING_PROFILES_V.UOM_CODE_PRI_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,tce_code_pri_offset            OKS_BILLING_PROFILES_V.TCE_CODE_PRI_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,profile_number                 OKS_BILLING_PROFILES_V.PROFILE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,summarised_yn                  OKS_BILLING_PROFILES_V.SUMMARISED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,reg_invoice_pri_offset         NUMBER := OKC_API.G_MISS_NUM
    ,reg_invoice_sec_offset         NUMBER := OKC_API.G_MISS_NUM
    ,first_billto_date              OKS_BILLING_PROFILES_V.FIRST_BILLTO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,first_invoice_date             OKS_BILLING_PROFILES_V.FIRST_INVOICE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,message                        OKS_BILLING_PROFILES_V.MESSAGE%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKS_BILLING_PROFILES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,instructions                   OKS_BILLING_PROFILES_V.INSTRUCTIONS%TYPE := OKC_API.G_MISS_CHAR
    ,attribute_category             OKS_BILLING_PROFILES_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKS_BILLING_PROFILES_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKS_BILLING_PROFILES_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKS_BILLING_PROFILES_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKS_BILLING_PROFILES_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKS_BILLING_PROFILES_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKS_BILLING_PROFILES_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKS_BILLING_PROFILES_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKS_BILLING_PROFILES_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKS_BILLING_PROFILES_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKS_BILLING_PROFILES_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKS_BILLING_PROFILES_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKS_BILLING_PROFILES_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKS_BILLING_PROFILES_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKS_BILLING_PROFILES_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKS_BILLING_PROFILES_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BILLING_PROFILES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BILLING_PROFILES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,invoice_object1_id1            OKS_BILLING_PROFILES_V.INVOICE_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_object1_id2            OKS_BILLING_PROFILES_V.INVOICE_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_jtot_object1_code      OKS_BILLING_PROFILES_V.INVOICE_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,account_object1_id1            OKS_BILLING_PROFILES_V.ACCOUNT_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,account_object1_id2            OKS_BILLING_PROFILES_V.ACCOUNT_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,account_jtot_object1_code      OKS_BILLING_PROFILES_V.ACCOUNT_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,billing_level                  OKS_BILLING_PROFILES_V.BILLING_LEVEL%TYPE := OKC_API.G_MISS_CHAR
    ,billing_type                   OKS_BILLING_PROFILES_V.BILLING_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,interval                       OKS_BILLING_PROFILES_V.INTERVAL%TYPE := OKC_API.G_MISS_CHAR
    ,interface_offset               NUMBER := OKC_API.G_MISS_NUM
    ,invoice_offset                 NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_bpev_rec                         bpev_rec_type;
  TYPE bpev_tbl_type IS TABLE OF bpev_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_BILLING_PROFILES_B Record Spec
  TYPE bpe_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,mda_code                       OKS_BILLING_PROFILES_B.MDA_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,owned_party_id1                OKS_BILLING_PROFILES_B.OWNED_PARTY_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,owned_party_id2                OKS_BILLING_PROFILES_B.OWNED_PARTY_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,dependent_cust_acct_id1        OKS_BILLING_PROFILES_B.DEPENDENT_CUST_ACCT_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,dependent_cust_acct_id2        OKS_BILLING_PROFILES_B.DEPENDENT_CUST_ACCT_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,bill_to_address_id1            OKS_BILLING_PROFILES_B.BILL_TO_ADDRESS_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,bill_to_address_id2            OKS_BILLING_PROFILES_B.BILL_TO_ADDRESS_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,uom_code_frequency             OKS_BILLING_PROFILES_B.UOM_CODE_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,tce_code_frequency             OKS_BILLING_PROFILES_B.TCE_CODE_FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,uom_code_sec_offset            OKS_BILLING_PROFILES_B.UOM_CODE_SEC_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,tce_code_sec_offset            OKS_BILLING_PROFILES_B.TCE_CODE_SEC_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,uom_code_pri_offset            OKS_BILLING_PROFILES_B.UOM_CODE_PRI_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,tce_code_pri_offset            OKS_BILLING_PROFILES_B.TCE_CODE_PRI_OFFSET%TYPE := OKC_API.G_MISS_CHAR
    ,profile_number                 OKS_BILLING_PROFILES_B.PROFILE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,summarised_yn                  OKS_BILLING_PROFILES_B.SUMMARISED_YN%TYPE := OKC_API.G_MISS_CHAR
    ,reg_invoice_pri_offset         NUMBER := OKC_API.G_MISS_NUM
    ,reg_invoice_sec_offset         NUMBER := OKC_API.G_MISS_NUM
    ,first_billto_date              OKS_BILLING_PROFILES_B.FIRST_BILLTO_DATE%TYPE := OKC_API.G_MISS_DATE
    ,first_invoice_date             OKS_BILLING_PROFILES_B.FIRST_INVOICE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BILLING_PROFILES_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BILLING_PROFILES_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,attribute_category             OKS_BILLING_PROFILES_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKS_BILLING_PROFILES_B.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKS_BILLING_PROFILES_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKS_BILLING_PROFILES_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKS_BILLING_PROFILES_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKS_BILLING_PROFILES_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKS_BILLING_PROFILES_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKS_BILLING_PROFILES_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKS_BILLING_PROFILES_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKS_BILLING_PROFILES_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKS_BILLING_PROFILES_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKS_BILLING_PROFILES_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKS_BILLING_PROFILES_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKS_BILLING_PROFILES_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKS_BILLING_PROFILES_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKS_BILLING_PROFILES_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_object1_id1            OKS_BILLING_PROFILES_B.INVOICE_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_object1_id2            OKS_BILLING_PROFILES_B.INVOICE_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,invoice_jtot_object1_code      OKS_BILLING_PROFILES_B.INVOICE_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,account_object1_id1            OKS_BILLING_PROFILES_B.ACCOUNT_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,account_object1_id2            OKS_BILLING_PROFILES_B.ACCOUNT_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,account_jtot_object1_code      OKS_BILLING_PROFILES_B.ACCOUNT_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,billing_level                  OKS_BILLING_PROFILES_B.BILLING_LEVEL%TYPE := OKC_API.G_MISS_CHAR
    ,billing_type                   OKS_BILLING_PROFILES_B.BILLING_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,interval                       OKS_BILLING_PROFILES_B.INTERVAL%TYPE := OKC_API.G_MISS_CHAR
    ,interface_offset               NUMBER := OKC_API.G_MISS_NUM
    ,invoice_offset                 NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_bpe_rec                          bpe_rec_type;
  TYPE bpe_tbl_type IS TABLE OF bpe_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_BILLING_PROFILES_TL Record Spec
  TYPE bpt_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,language                       OKS_BILLING_PROFILES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKS_BILLING_PROFILES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKS_BILLING_PROFILES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKS_BILLING_PROFILES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,instructions                   OKS_BILLING_PROFILES_TL.INSTRUCTIONS%TYPE := OKC_API.G_MISS_CHAR
    ,message                        OKS_BILLING_PROFILES_TL.MESSAGE%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BILLING_PROFILES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BILLING_PROFILES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_bpt_rec                          bpt_rec_type;
  TYPE bpt_tbl_type IS TABLE OF bpt_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_BPE_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
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
    p_bpev_rec                     IN bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type);
END OKS_BPE_PVT;

 

/

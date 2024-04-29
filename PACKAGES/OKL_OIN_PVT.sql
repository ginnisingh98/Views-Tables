--------------------------------------------------------
--  DDL for Package OKL_OIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_OIN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSOINS.pls 120.2 2006/07/11 10:23:47 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_OPEN_INT_V Record Spec
  TYPE oinv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,party_id                       NUMBER := OKC_API.G_MISS_NUM
    ,party_name                     OKL_OPEN_INT.PARTY_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,party_type                     OKL_OPEN_INT.PARTY_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,date_of_birth                  OKL_OPEN_INT.DATE_OF_BIRTH%TYPE := OKC_API.G_MISS_DATE
    ,place_of_birth                 OKL_OPEN_INT.PLACE_OF_BIRTH%TYPE := OKC_API.G_MISS_CHAR
    ,person_identifier              OKL_OPEN_INT.PERSON_IDENTIFIER%TYPE := OKC_API.G_MISS_CHAR
    ,person_iden_type               OKL_OPEN_INT.PERSON_IDEN_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,country                        OKL_OPEN_INT.COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,address1                       OKL_OPEN_INT.ADDRESS1%TYPE := OKC_API.G_MISS_CHAR
    ,address2                       OKL_OPEN_INT.ADDRESS2%TYPE := OKC_API.G_MISS_CHAR
    ,address3                       OKL_OPEN_INT.ADDRESS3%TYPE := OKC_API.G_MISS_CHAR
    ,address4                       OKL_OPEN_INT.ADDRESS4%TYPE := OKC_API.G_MISS_CHAR
    ,city                           OKL_OPEN_INT.CITY%TYPE := OKC_API.G_MISS_CHAR
    ,postal_code                    OKL_OPEN_INT.POSTAL_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,state                          OKL_OPEN_INT.STATE%TYPE := OKC_API.G_MISS_CHAR
    ,province                       OKL_OPEN_INT.PROVINCE%TYPE := OKC_API.G_MISS_CHAR
    ,county                         OKL_OPEN_INT.COUNTY%TYPE := OKC_API.G_MISS_CHAR
    ,po_box_number                  OKL_OPEN_INT.PO_BOX_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,house_number                   OKL_OPEN_INT.HOUSE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_suffix                  OKL_OPEN_INT.STREET_SUFFIX%TYPE := OKC_API.G_MISS_CHAR
    ,apartment_number               OKL_OPEN_INT.APARTMENT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street                         OKL_OPEN_INT.STREET%TYPE := OKC_API.G_MISS_CHAR
    ,rural_route_number             OKL_OPEN_INT.RURAL_ROUTE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_number                  OKL_OPEN_INT.STREET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,building                       OKL_OPEN_INT.BUILDING%TYPE := OKC_API.G_MISS_CHAR
    ,floor                          OKL_OPEN_INT.FLOOR%TYPE := OKC_API.G_MISS_CHAR
    ,suite                          OKL_OPEN_INT.SUITE%TYPE := OKC_API.G_MISS_CHAR
    ,room                           OKL_OPEN_INT.ROOM%TYPE := OKC_API.G_MISS_CHAR
    ,postal_plus4_code              OKL_OPEN_INT.POSTAL_PLUS4_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,cas_id                         NUMBER := OKC_API.G_MISS_NUM
    ,case_number                    OKL_OPEN_INT.CASE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contract_number                OKL_OPEN_INT.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_type                  OKL_OPEN_INT.CONTRACT_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,contract_status                OKL_OPEN_INT.CONTRACT_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,original_amount                NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKL_OPEN_INT.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,close_date                     OKL_OPEN_INT.CLOSE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,term_duration                  NUMBER := OKC_API.G_MISS_NUM
    ,monthly_payment_amount         NUMBER := OKC_API.G_MISS_NUM
    ,last_payment_date              OKL_OPEN_INT.LAST_PAYMENT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,delinquency_occurance_date     OKL_OPEN_INT.DELINQUENCY_OCCURANCE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,past_due_amount                NUMBER := OKC_API.G_MISS_NUM
    ,remaining_amount               NUMBER := OKC_API.G_MISS_NUM
    ,credit_indicator               OKL_OPEN_INT.CREDIT_INDICATOR%TYPE := OKC_API.G_MISS_CHAR
    ,notification_date              OKL_OPEN_INT.NOTIFICATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,credit_bureau_report_date      OKL_OPEN_INT.CREDIT_BUREAU_REPORT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,external_agency_transfer_date  OKL_OPEN_INT.EXTERNAL_AGENCY_TRANSFER_DATE%TYPE := OKC_API.G_MISS_DATE
    ,external_agency_recall_date    OKL_OPEN_INT.EXTERNAL_AGENCY_RECALL_DATE%TYPE := OKC_API.G_MISS_DATE
    ,referral_number                NUMBER := OKC_API.G_MISS_NUM
    ,contact_id                     NUMBER := OKC_API.G_MISS_NUM
    ,contact_name                   OKL_OPEN_INT.CONTACT_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,contact_phone                  OKL_OPEN_INT.CONTACT_PHONE%TYPE := OKC_API.G_MISS_CHAR
    ,contact_email                  OKL_OPEN_INT.CONTACT_EMAIL%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_OPEN_INT.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_OPEN_INT.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_OPEN_INT.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_OPEN_INT.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_OPEN_INT.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_OPEN_INT.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_OPEN_INT.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_OPEN_INT.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_OPEN_INT.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_OPEN_INT.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_OPEN_INT.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_OPEN_INT.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_OPEN_INT.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_OPEN_INT.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_OPEN_INT.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_OPEN_INT.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_OPEN_INT.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_OPEN_INT.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_OPEN_INT.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_oinv_rec                         oinv_rec_type;
  TYPE oinv_tbl_type IS TABLE OF oinv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_OPEN_INT Record Spec
  TYPE oin_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,party_id                       NUMBER := OKC_API.G_MISS_NUM
    ,party_name                     OKL_OPEN_INT.PARTY_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,party_type                     OKL_OPEN_INT.PARTY_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,date_of_birth                  OKL_OPEN_INT.DATE_OF_BIRTH%TYPE := OKC_API.G_MISS_DATE
    ,place_of_birth                 OKL_OPEN_INT.PLACE_OF_BIRTH%TYPE := OKC_API.G_MISS_CHAR
    ,person_identifier              OKL_OPEN_INT.PERSON_IDENTIFIER%TYPE := OKC_API.G_MISS_CHAR
    ,person_iden_type               OKL_OPEN_INT.PERSON_IDEN_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,country                        OKL_OPEN_INT.COUNTRY%TYPE := OKC_API.G_MISS_CHAR
    ,address1                       OKL_OPEN_INT.ADDRESS1%TYPE := OKC_API.G_MISS_CHAR
    ,address2                       OKL_OPEN_INT.ADDRESS2%TYPE := OKC_API.G_MISS_CHAR
    ,address3                       OKL_OPEN_INT.ADDRESS3%TYPE := OKC_API.G_MISS_CHAR
    ,address4                       OKL_OPEN_INT.ADDRESS4%TYPE := OKC_API.G_MISS_CHAR
    ,city                           OKL_OPEN_INT.CITY%TYPE := OKC_API.G_MISS_CHAR
    ,postal_code                    OKL_OPEN_INT.POSTAL_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,state                          OKL_OPEN_INT.STATE%TYPE := OKC_API.G_MISS_CHAR
    ,province                       OKL_OPEN_INT.PROVINCE%TYPE := OKC_API.G_MISS_CHAR
    ,county                         OKL_OPEN_INT.COUNTY%TYPE := OKC_API.G_MISS_CHAR
    ,po_box_number                  OKL_OPEN_INT.PO_BOX_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,house_number                   OKL_OPEN_INT.HOUSE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_suffix                  OKL_OPEN_INT.STREET_SUFFIX%TYPE := OKC_API.G_MISS_CHAR
    ,apartment_number               OKL_OPEN_INT.APARTMENT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street                         OKL_OPEN_INT.STREET%TYPE := OKC_API.G_MISS_CHAR
    ,rural_route_number             OKL_OPEN_INT.RURAL_ROUTE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,street_number                  OKL_OPEN_INT.STREET_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,building                       OKL_OPEN_INT.BUILDING%TYPE := OKC_API.G_MISS_CHAR
    ,floor                          OKL_OPEN_INT.FLOOR%TYPE := OKC_API.G_MISS_CHAR
    ,suite                          OKL_OPEN_INT.SUITE%TYPE := OKC_API.G_MISS_CHAR
    ,room                           OKL_OPEN_INT.ROOM%TYPE := OKC_API.G_MISS_CHAR
    ,postal_plus4_code              OKL_OPEN_INT.POSTAL_PLUS4_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,cas_id                         NUMBER := OKC_API.G_MISS_NUM
    ,case_number                    OKL_OPEN_INT.CASE_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,khr_id                         NUMBER := OKC_API.G_MISS_NUM
    ,contract_number                OKL_OPEN_INT.CONTRACT_NUMBER%TYPE := OKC_API.G_MISS_CHAR
    ,contract_type                  OKL_OPEN_INT.CONTRACT_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,contract_status                OKL_OPEN_INT.CONTRACT_STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,original_amount                NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKL_OPEN_INT.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,close_date                     OKL_OPEN_INT.CLOSE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,term_duration                  NUMBER := OKC_API.G_MISS_NUM
    ,monthly_payment_amount         NUMBER := OKC_API.G_MISS_NUM
    ,last_payment_date              OKL_OPEN_INT.LAST_PAYMENT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,delinquency_occurance_date     OKL_OPEN_INT.DELINQUENCY_OCCURANCE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,past_due_amount                NUMBER := OKC_API.G_MISS_NUM
    ,remaining_amount               NUMBER := OKC_API.G_MISS_NUM
    ,credit_indicator               OKL_OPEN_INT.CREDIT_INDICATOR%TYPE := OKC_API.G_MISS_CHAR
    ,notification_date              OKL_OPEN_INT.NOTIFICATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,credit_bureau_report_date      OKL_OPEN_INT.CREDIT_BUREAU_REPORT_DATE%TYPE := OKC_API.G_MISS_DATE
    ,external_agency_transfer_date  OKL_OPEN_INT.EXTERNAL_AGENCY_TRANSFER_DATE%TYPE := OKC_API.G_MISS_DATE
    ,external_agency_recall_date    OKL_OPEN_INT.EXTERNAL_AGENCY_RECALL_DATE%TYPE := OKC_API.G_MISS_DATE
    ,referral_number                NUMBER := OKC_API.G_MISS_NUM
    ,contact_id                     NUMBER := OKC_API.G_MISS_NUM
    ,contact_name                   OKL_OPEN_INT.CONTACT_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,contact_phone                  OKL_OPEN_INT.CONTACT_PHONE%TYPE := OKC_API.G_MISS_CHAR
    ,contact_email                  OKL_OPEN_INT.CONTACT_EMAIL%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,org_id                         NUMBER := OKC_API.G_MISS_NUM
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKL_OPEN_INT.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,attribute_category             OKL_OPEN_INT.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR
    ,attribute1                     OKL_OPEN_INT.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR
    ,attribute2                     OKL_OPEN_INT.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR
    ,attribute3                     OKL_OPEN_INT.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR
    ,attribute4                     OKL_OPEN_INT.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR
    ,attribute5                     OKL_OPEN_INT.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR
    ,attribute6                     OKL_OPEN_INT.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR
    ,attribute7                     OKL_OPEN_INT.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR
    ,attribute8                     OKL_OPEN_INT.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR
    ,attribute9                     OKL_OPEN_INT.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR
    ,attribute10                    OKL_OPEN_INT.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR
    ,attribute11                    OKL_OPEN_INT.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR
    ,attribute12                    OKL_OPEN_INT.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR
    ,attribute13                    OKL_OPEN_INT.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR
    ,attribute14                    OKL_OPEN_INT.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR
    ,attribute15                    OKL_OPEN_INT.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKL_OPEN_INT.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKL_OPEN_INT.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_oin_rec                          oin_rec_type;
  TYPE oin_tbl_type IS TABLE OF oin_rec_type
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
  --G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  --G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  --G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_OIN_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  -------------------------------------------------------------------------------
  --Post change to TAPI code
  -------------------------------------------------------------------------------
  --G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLCODE';
  g_no_parent_record            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------
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
    p_oinv_rec                     IN oinv_rec_type,
    x_oinv_rec                     OUT NOCOPY oinv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type,
    x_oinv_rec                     OUT NOCOPY oinv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    x_oinv_tbl                     OUT NOCOPY oinv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_rec                     IN oinv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oinv_tbl                     IN oinv_tbl_type);
END OKL_OIN_PVT;

/

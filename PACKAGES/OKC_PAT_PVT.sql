--------------------------------------------------------
--  DDL for Package OKC_PAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PAT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSPATS.pls 120.0 2005/05/25 18:04:36 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE pat_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    pat_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsl_id                         NUMBER := OKC_API.G_MISS_NUM,
    bcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PRICE_ADJUSTMENTS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PRICE_ADJUSTMENTS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    modified_from                  NUMBER := OKC_API.G_MISS_NUM,
    modified_to                    NUMBER := OKC_API.G_MISS_NUM,
    modifier_mechanism_type_code   OKC_PRICE_ADJUSTMENTS.MODIFIER_MECHANISM_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    operand                        NUMBER := OKC_API.G_MISS_NUM,
    arithmetic_operator            OKC_PRICE_ADJUSTMENTS.ARITHMETIC_OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    automatic_flag                 OKC_PRICE_ADJUSTMENTS.AUTOMATIC_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    update_allowed                 OKC_PRICE_ADJUSTMENTS.UPDATE_ALLOWED%TYPE := OKC_API.G_MISS_CHAR,
    updated_flag                   OKC_PRICE_ADJUSTMENTS.UPDATED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    applied_flag                   OKC_PRICE_ADJUSTMENTS.APPLIED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    on_invoice_flag                OKC_PRICE_ADJUSTMENTS.ON_INVOICE_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    pricing_phase_id               NUMBER := OKC_API.G_MISS_NUM,
    context                        OKC_PRICE_ADJUSTMENTS.CONTEXT%TYPE := OKC_API.G_MISS_CHAR,
   program_application_id           NUMBER := OKC_API.G_MISS_NUM,
   program_id                       NUMBER := OKC_API.G_MISS_NUM,
   program_update_date             OKC_PRICE_ADJUSTMENTS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
   request_id                      NUMBER := OKC_API.G_MISS_NUM,
   list_header_id                   NUMBER := OKC_API.G_MISS_NUM,
   list_line_id                      NUMBER := OKC_API.G_MISS_NUM,
   list_line_type_code              OKC_PRICE_ADJUSTMENTS.LIST_LINE_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR,
   change_reason_code                OKC_PRICE_ADJUSTMENTS.CHANGE_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR,
   change_reason_text               OKC_PRICE_ADJUSTMENTS.CHANGE_REASON_TEXT%TYPE := OKC_API.G_MISS_CHAR,
    estimated_flag                  OKC_PRICE_ADJUSTMENTS.ESTIMATED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    adjusted_amount                 NUMBER := OKC_API.G_MISS_NUM,
    charge_type_code                OKC_PRICE_ADJUSTMENTS.CHARGE_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    charge_subtype_code             OKC_PRICE_ADJUSTMENTS.CHARGE_SUBTYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
   range_break_quantity		     NUMBER := OKC_API.G_MISS_NUM,
   accrual_conversion_rate          NUMBER := OKC_API.G_MISS_NUM,
   pricing_group_sequence           NUMBER := OKC_API.G_MISS_NUM,
   accrual_flag                     OKC_PRICE_ADJUSTMENTS.ACCRUAL_FLAG%TYPE :=OKC_API.G_MISS_CHAR,
  list_line_no                      OKC_PRICE_ADJUSTMENTS.LIST_LINE_NO%TYPE  := OKC_API.G_MISS_CHAR,
   source_system_code              OKC_PRICE_ADJUSTMENTS.SOURCE_SYSTEM_CODE%TYPE :=OKC_API.G_MISS_CHAR,
  benefit_qty                        NUMBER := OKC_API.G_MISS_NUM,
  benefit_uom_code                OKC_PRICE_ADJUSTMENTS.BENEFIT_UOM_CODE%TYPE :=OKC_API.G_MISS_CHAR,
 expiration_date                   OKC_PRICE_ADJUSTMENTS.EXPIRATION_DATE%TYPE := OKC_API.G_MISS_DATE,
  modifier_level_code             OKC_PRICE_ADJUSTMENTS.MODIFIER_LEVEL_CODE%TYPE :=OKC_API.G_MISS_CHAR,
 price_break_type_code            OKC_PRICE_ADJUSTMENTS.PRICE_BREAK_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
  substitution_attribute          OKC_PRICE_ADJUSTMENTS.SUBSTITUTION_ATTRIBUTE%TYPE :=OKC_API.G_MISS_CHAR,
  proration_type_code             OKC_PRICE_ADJUSTMENTS.PRORATION_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
 include_on_returns_flag           OKC_PRICE_ADJUSTMENTS.INCLUDE_ON_RETURNS_FLAG%TYPE :=OKC_API.G_MISS_CHAR,
 object_version_number             NUMBER := OKC_API.G_MISS_NUM,
 attribute1                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_PRICE_ADJUSTMENTS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_PRICE_ADJUSTMENTS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_PRICE_ADJUSTMENTS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_PRICE_ADJUSTMENTS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_PRICE_ADJUSTMENTS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_PRICE_ADJUSTMENTS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_PRICE_ADJUSTMENTS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    rebate_transaction_type_code  OKC_PRICE_ADJUSTMENTS.REBATE_TRANSACTION_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR);
  g_miss_pat_rec                          pat_rec_type;
  TYPE pat_tbl_type IS TABLE OF pat_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE patv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    pat_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    bsl_id                         NUMBER := OKC_API.G_MISS_NUM,
    bcl_id                         NUMBER := OKC_API.G_MISS_NUM,
    modified_from                  NUMBER := OKC_API.G_MISS_NUM,
    modified_to                    NUMBER := OKC_API.G_MISS_NUM,
  modifier_mechanism_type_code   OKC_PRICE_ADJUSTMENTS_V.MODIFIER_MECHANISM_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR,
    operand                        NUMBER := OKC_API.G_MISS_NUM,
    arithmetic_operator            OKC_PRICE_ADJUSTMENTS_V.ARITHMETIC_OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    automatic_flag                 OKC_PRICE_ADJUSTMENTS_V.AUTOMATIC_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    update_allowed                 OKC_PRICE_ADJUSTMENTS_V.UPDATE_ALLOWED%TYPE := OKC_API.G_MISS_CHAR,
    updated_flag                   OKC_PRICE_ADJUSTMENTS_V.UPDATED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    applied_flag                   OKC_PRICE_ADJUSTMENTS_V.APPLIED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    on_invoice_flag                OKC_PRICE_ADJUSTMENTS_V.ON_INVOICE_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    pricing_phase_id               NUMBER := OKC_API.G_MISS_NUM,
    context                        OKC_PRICE_ADJUSTMENTS_V.CONTEXT%TYPE := OKC_API.G_MISS_CHAR,
   program_application_id           NUMBER := OKC_API.G_MISS_NUM,
   program_id                       NUMBER := OKC_API.G_MISS_NUM,
   program_update_date             OKC_PRICE_ADJUSTMENTS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
   request_id                      NUMBER := OKC_API.G_MISS_NUM,
   list_header_id                   NUMBER := OKC_API.G_MISS_NUM,
   list_line_id                      NUMBER := OKC_API.G_MISS_NUM,
   list_line_type_code              OKC_PRICE_ADJUSTMENTS_V.LIST_LINE_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR,
   change_reason_code                OKC_PRICE_ADJUSTMENTS_V.CHANGE_REASON_CODE%TYPE := OKC_API.G_MISS_CHAR,
   change_reason_text               OKC_PRICE_ADJUSTMENTS_V.CHANGE_REASON_TEXT%TYPE := OKC_API.G_MISS_CHAR,
    estimated_flag                  OKC_PRICE_ADJUSTMENTS_V.ESTIMATED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    adjusted_amount                 NUMBER := OKC_API.G_MISS_NUM,
    charge_type_code                OKC_PRICE_ADJUSTMENTS_V.CHARGE_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
    charge_subtype_code             OKC_PRICE_ADJUSTMENTS_V.CHARGE_SUBTYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
   range_break_quantity              NUMBER := OKC_API.G_MISS_NUM,
   accrual_conversion_rate          NUMBER := OKC_API.G_MISS_NUM,
   pricing_group_sequence           NUMBER := OKC_API.G_MISS_NUM,
   accrual_flag                     OKC_PRICE_ADJUSTMENTS_V.ACCRUAL_FLAG%TYPE :=OKC_API.G_MISS_CHAR,
  list_line_no                      OKC_PRICE_ADJUSTMENTS_V.LIST_LINE_NO%TYPE  := OKC_API.G_MISS_CHAR,
   source_system_code              OKC_PRICE_ADJUSTMENTS_V.SOURCE_SYSTEM_CODE%TYPE :=OKC_API.G_MISS_CHAR,
  benefit_qty                        NUMBER := OKC_API.G_MISS_NUM,
  benefit_uom_code                OKC_PRICE_ADJUSTMENTS_V.BENEFIT_UOM_CODE%TYPE :=OKC_API.G_MISS_CHAR,
  expiration_date                   OKC_PRICE_ADJUSTMENTS_V.EXPIRATION_DATE%TYPE := OKC_API.G_MISS_DATE,
  modifier_level_code             OKC_PRICE_ADJUSTMENTS_V.MODIFIER_LEVEL_CODE%TYPE :=OKC_API.G_MISS_CHAR,
  price_break_type_code            OKC_PRICE_ADJUSTMENTS_V.PRICE_BREAK_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
  substitution_attribute          OKC_PRICE_ADJUSTMENTS_V.SUBSTITUTION_ATTRIBUTE%TYPE :=OKC_API.G_MISS_CHAR,
  proration_type_code             OKC_PRICE_ADJUSTMENTS_V.PRORATION_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR,
  include_on_returns_flag           OKC_PRICE_ADJUSTMENTS_V.INCLUDE_ON_RETURNS_FLAG%TYPE :=OKC_API.G_MISS_CHAR,
  object_version_number             NUMBER := OKC_API.G_MISS_NUM,
  attribute1                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_PRICE_ADJUSTMENTS_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PRICE_ADJUSTMENTS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PRICE_ADJUSTMENTS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    rebate_transaction_type_code  OKC_PRICE_ADJUSTMENTS.REBATE_TRANSACTION_TYPE_CODE%TYPE :=OKC_API.G_MISS_CHAR);
  g_miss_patv_rec                         patv_rec_type;
  TYPE patv_tbl_type IS TABLE OF patv_rec_type
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
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_FOREIGN_KEY_ERROR	 	CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_FK_ERROR';
  G_UNIQUE_KEY_ERROR	 	CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNIQUE_KEY_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQD';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'PAT_PVT';
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
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type);

PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_patv_tbl patv_tbl_type);

  FUNCTION create_version(
    p_chr_id                                    IN NUMBER,
    p_major_version                             IN NUMBER) RETURN VARCHAR2;

  FUNCTION restore_version(
    p_chr_id                                    IN NUMBER,
    p_major_version                             IN NUMBER) RETURN VARCHAR2;

END OKC_PAT_PVT;

 

/

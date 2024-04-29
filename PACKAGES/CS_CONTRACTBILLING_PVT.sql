--------------------------------------------------------
--  DDL for Package CS_CONTRACTBILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTRACTBILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: csctcbps.pls 115.0 99/07/16 08:49:18 porting ship  $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ContractBilling_Rec_Type IS RECORD (
    contract_billing_id            NUMBER := NULL,
    header_id                      NUMBER := NULL,
    order_number                   NUMBER := NULL,
    line_id                        NUMBER := NULL,
    cp_service_id                  NUMBER := NULL,
    contract_id                    NUMBER := NULL,
    cust_trx_type_id               NUMBER := NULL,
    trx_date                       CS_CONTRACTS_BILLING.TRX_DATE%TYPE := NULL,
    trx_number                     NUMBER := NULL,
    trx_amount                     NUMBER := NULL,
    trx_class                      CS_CONTRACTS_BILLING.TRX_CLASS%TYPE := NULL,
    billed_until_date              CS_CONTRACTS_BILLING.BILLED_UNTIL_DATE%TYPE := NULL,
    currency_code                  CS_CONTRACTS_BILLING.CURRENCY_CODE%TYPE := NULL,
    last_update_date               CS_CONTRACTS_BILLING.LAST_UPDATE_DATE%TYPE := NULL,
    last_updated_by                NUMBER := NULL,
    creation_date                  CS_CONTRACTS_BILLING.CREATION_DATE%TYPE := NULL,
    created_by                     NUMBER := NULL,
    last_update_login              NUMBER := NULL,
    trx_pre_tax_amount             NUMBER := NULL,
    attribute1                     CS_CONTRACTS_BILLING.ATTRIBUTE1%TYPE := NULL,
    attribute2                     CS_CONTRACTS_BILLING.ATTRIBUTE2%TYPE := NULL,
    attribute3                     CS_CONTRACTS_BILLING.ATTRIBUTE3%TYPE := NULL,
    attribute4                     CS_CONTRACTS_BILLING.ATTRIBUTE4%TYPE := NULL,
    attribute5                     CS_CONTRACTS_BILLING.ATTRIBUTE5%TYPE := NULL,
    attribute6                     CS_CONTRACTS_BILLING.ATTRIBUTE6%TYPE := NULL,
    attribute7                     CS_CONTRACTS_BILLING.ATTRIBUTE7%TYPE := NULL,
    attribute8                     CS_CONTRACTS_BILLING.ATTRIBUTE8%TYPE := NULL,
    attribute9                     CS_CONTRACTS_BILLING.ATTRIBUTE9%TYPE := NULL,
    attribute10                    CS_CONTRACTS_BILLING.ATTRIBUTE10%TYPE := NULL,
    attribute11                    CS_CONTRACTS_BILLING.ATTRIBUTE11%TYPE := NULL,
    attribute12                    CS_CONTRACTS_BILLING.ATTRIBUTE12%TYPE := NULL,
    attribute13                    CS_CONTRACTS_BILLING.ATTRIBUTE13%TYPE := NULL,
    attribute14                    CS_CONTRACTS_BILLING.ATTRIBUTE14%TYPE := NULL,
    attribute15                    CS_CONTRACTS_BILLING.ATTRIBUTE15%TYPE := NULL,
    context                        CS_CONTRACTS_BILLING.CONTEXT%TYPE := NULL,
    object_version_number          NUMBER := NULL);
  G_MISS_contractbilling_rec              ContractBilling_Rec_Type;
  TYPE ContractBilling_Val_Rec_Type IS RECORD (
    contract_billing_id            NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    header_id                      NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    order_number                   NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    line_id                        NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    cp_service_id                  NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    contract_id                    NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    cust_trx_type_id               NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    trx_date                       CS_CONTRACTS_BILLING.TRX_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    trx_number                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    trx_amount                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    trx_class                      CS_CONTRACTS_BILLING.TRX_CLASS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    billed_until_date              CS_CONTRACTS_BILLING.BILLED_UNTIL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    currency_code                  CS_CONTRACTS_BILLING.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    last_update_date               CS_CONTRACTS_BILLING.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    last_updated_by                NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    creation_date                  CS_CONTRACTS_BILLING.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    created_by                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    last_update_login              NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    trx_pre_tax_amount             NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    attribute1                     CS_CONTRACTS_BILLING.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute2                     CS_CONTRACTS_BILLING.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute3                     CS_CONTRACTS_BILLING.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute4                     CS_CONTRACTS_BILLING.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute5                     CS_CONTRACTS_BILLING.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute6                     CS_CONTRACTS_BILLING.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute7                     CS_CONTRACTS_BILLING.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute8                     CS_CONTRACTS_BILLING.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute9                     CS_CONTRACTS_BILLING.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute10                    CS_CONTRACTS_BILLING.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute11                    CS_CONTRACTS_BILLING.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute12                    CS_CONTRACTS_BILLING.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute13                    CS_CONTRACTS_BILLING.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute14                    CS_CONTRACTS_BILLING.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute15                    CS_CONTRACTS_BILLING.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    context                        CS_CONTRACTS_BILLING.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    object_version_number          NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
  G_MISS_contractbilling_val_rec          ContractBilling_Val_Rec_Type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := TAPI_DEV_KIT.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'CS_CONTRACTBILLING_PVT';
  G_APP_NAME			CONSTANT 	VARCHAR2(3) :=  TAPI_DEV_KIT.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contractbilling_rec          IN ContractBilling_Rec_Type := G_MISS_CONTRACTBILLING_REC,
    x_contract_billing_id          OUT NUMBER,
    x_object_version_number        OUT NUMBER);
  PROCEDURE insert_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_header_id                    IN NUMBER := NULL,
    p_order_number                 IN NUMBER := NULL,
    p_line_id                      IN NUMBER := NULL,
    p_cp_service_id                IN NUMBER := NULL,
    p_contract_id                  IN NUMBER := NULL,
    p_cust_trx_type_id             IN NUMBER := NULL,
    p_trx_date                     IN CS_CONTRACTS_BILLING.TRX_DATE%TYPE := NULL,
    p_trx_number                   IN NUMBER := NULL,
    p_trx_amount                   IN NUMBER := NULL,
    p_trx_class                    IN CS_CONTRACTS_BILLING.TRX_CLASS%TYPE := NULL,
    p_billed_until_date            IN CS_CONTRACTS_BILLING.BILLED_UNTIL_DATE%TYPE := NULL,
    p_currency_code                IN CS_CONTRACTS_BILLING.CURRENCY_CODE%TYPE := NULL,
    p_last_update_date             IN CS_CONTRACTS_BILLING.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_CONTRACTS_BILLING.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_trx_pre_tax_amount           IN NUMBER := NULL,
    p_attribute1                   IN CS_CONTRACTS_BILLING.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_CONTRACTS_BILLING.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_CONTRACTS_BILLING.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_CONTRACTS_BILLING.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_CONTRACTS_BILLING.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_CONTRACTS_BILLING.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_CONTRACTS_BILLING.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_CONTRACTS_BILLING.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_CONTRACTS_BILLING.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_CONTRACTS_BILLING.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_CONTRACTS_BILLING.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_CONTRACTS_BILLING.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_CONTRACTS_BILLING.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_CONTRACTS_BILLING.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_CONTRACTS_BILLING.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_CONTRACTS_BILLING.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_contract_billing_id          OUT NUMBER,
    x_object_version_number        OUT NUMBER);
  Procedure lock_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_billing_id          IN NUMBER,
    p_object_version_number        IN NUMBER);
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contractbilling_val_rec      IN ContractBilling_Val_Rec_Type := G_MISS_CONTRACTBILLING_VAL_REC,
    x_object_version_number        OUT NUMBER);
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_billing_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_header_id                    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_order_number                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_line_id                      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cust_trx_type_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_date                     IN CS_CONTRACTS_BILLING.TRX_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_number                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_amount                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_class                    IN CS_CONTRACTS_BILLING.TRX_CLASS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_billed_until_date            IN CS_CONTRACTS_BILLING.BILLED_UNTIL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_currency_code                IN CS_CONTRACTS_BILLING.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_CONTRACTS_BILLING.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACTS_BILLING.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_pre_tax_amount           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_CONTRACTS_BILLING.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACTS_BILLING.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACTS_BILLING.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACTS_BILLING.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACTS_BILLING.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACTS_BILLING.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACTS_BILLING.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACTS_BILLING.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACTS_BILLING.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACTS_BILLING.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACTS_BILLING.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACTS_BILLING.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACTS_BILLING.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACTS_BILLING.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACTS_BILLING.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACTS_BILLING.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NUMBER);
  Procedure delete_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_billing_id          IN NUMBER);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contractbilling_val_rec      IN ContractBilling_Val_Rec_Type := G_MISS_CONTRACTBILLING_VAL_REC);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_billing_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_header_id                    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_order_number                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_line_id                      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cust_trx_type_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_date                     IN CS_CONTRACTS_BILLING.TRX_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_number                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_amount                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_class                    IN CS_CONTRACTS_BILLING.TRX_CLASS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_billed_until_date            IN CS_CONTRACTS_BILLING.BILLED_UNTIL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_currency_code                IN CS_CONTRACTS_BILLING.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_CONTRACTS_BILLING.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACTS_BILLING.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_trx_pre_tax_amount           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_CONTRACTS_BILLING.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACTS_BILLING.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACTS_BILLING.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACTS_BILLING.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACTS_BILLING.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACTS_BILLING.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACTS_BILLING.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACTS_BILLING.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACTS_BILLING.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACTS_BILLING.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACTS_BILLING.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACTS_BILLING.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACTS_BILLING.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACTS_BILLING.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACTS_BILLING.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACTS_BILLING.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
END CS_CONTRACTBILLING_PVT;

 

/

--------------------------------------------------------
--  DDL for Package CS_BILLINGTYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_BILLINGTYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: csctcbts.pls 115.0 99/07/16 08:49:38 porting ship  $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE BillingType_Rec_Type IS RECORD (
    coverage_billing_type_id       NUMBER := NULL,
    max_percent_per_use            NUMBER := NULL,
    max_amount_per_use             NUMBER := NULL,
    txn_billing_type_id            NUMBER := NULL,
    coverage_txn_group_id          NUMBER := NULL,
    last_update_date               CS_COV_BILLING_TYPES.LAST_UPDATE_DATE%TYPE := NULL,
    last_updated_by                NUMBER := NULL,
    creation_date                  CS_COV_BILLING_TYPES.CREATION_DATE%TYPE := NULL,
    created_by                     NUMBER := NULL,
    last_update_login              NUMBER := NULL,
    attribute1                     CS_COV_BILLING_TYPES.ATTRIBUTE1%TYPE := NULL,
    attribute2                     CS_COV_BILLING_TYPES.ATTRIBUTE2%TYPE := NULL,
    attribute3                     CS_COV_BILLING_TYPES.ATTRIBUTE3%TYPE := NULL,
    attribute4                     CS_COV_BILLING_TYPES.ATTRIBUTE4%TYPE := NULL,
    attribute5                     CS_COV_BILLING_TYPES.ATTRIBUTE5%TYPE := NULL,
    attribute6                     CS_COV_BILLING_TYPES.ATTRIBUTE6%TYPE := NULL,
    attribute7                     CS_COV_BILLING_TYPES.ATTRIBUTE7%TYPE := NULL,
    attribute8                     CS_COV_BILLING_TYPES.ATTRIBUTE8%TYPE := NULL,
    attribute9                     CS_COV_BILLING_TYPES.ATTRIBUTE9%TYPE := NULL,
    attribute10                    CS_COV_BILLING_TYPES.ATTRIBUTE10%TYPE := NULL,
    attribute11                    CS_COV_BILLING_TYPES.ATTRIBUTE11%TYPE := NULL,
    attribute12                    CS_COV_BILLING_TYPES.ATTRIBUTE12%TYPE := NULL,
    attribute13                    CS_COV_BILLING_TYPES.ATTRIBUTE13%TYPE := NULL,
    attribute14                    CS_COV_BILLING_TYPES.ATTRIBUTE14%TYPE := NULL,
    attribute15                    CS_COV_BILLING_TYPES.ATTRIBUTE15%TYPE := NULL,
    context                        CS_COV_BILLING_TYPES.CONTEXT%TYPE := NULL,
    object_version_number          NUMBER := NULL);
  G_MISS_billingtype_rec                  BillingType_Rec_Type;
  TYPE BillingType_Val_Rec_Type IS RECORD (
    coverage_billing_type_id       NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    max_percent_per_use            NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    max_amount_per_use             NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    txn_billing_type_id            NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    coverage_txn_group_id          NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    last_update_date               CS_COV_BILLING_TYPES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    last_updated_by                NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    creation_date                  CS_COV_BILLING_TYPES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    created_by                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    last_update_login              NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    attribute1                     CS_COV_BILLING_TYPES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute2                     CS_COV_BILLING_TYPES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute3                     CS_COV_BILLING_TYPES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute4                     CS_COV_BILLING_TYPES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute5                     CS_COV_BILLING_TYPES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute6                     CS_COV_BILLING_TYPES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute7                     CS_COV_BILLING_TYPES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute8                     CS_COV_BILLING_TYPES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute9                     CS_COV_BILLING_TYPES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute10                    CS_COV_BILLING_TYPES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute11                    CS_COV_BILLING_TYPES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute12                    CS_COV_BILLING_TYPES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute13                    CS_COV_BILLING_TYPES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute14                    CS_COV_BILLING_TYPES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute15                    CS_COV_BILLING_TYPES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    context                        CS_COV_BILLING_TYPES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    object_version_number          NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
  G_MISS_billingtype_val_rec              BillingType_Val_Rec_Type;
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
  G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'CS_BILLINGTYPE_PVT';
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
    p_billingtype_rec              IN BillingType_Rec_Type := G_MISS_BILLINGTYPE_REC,
    x_coverage_billing_type_id     OUT NUMBER,
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
    p_max_percent_per_use          IN NUMBER := NULL,
    p_max_amount_per_use           IN NUMBER := NULL,
    p_txn_billing_type_id          IN NUMBER := NULL,
    p_coverage_txn_group_id        IN NUMBER := NULL,
    p_last_update_date             IN CS_COV_BILLING_TYPES.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_COV_BILLING_TYPES.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_attribute1                   IN CS_COV_BILLING_TYPES.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_COV_BILLING_TYPES.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_COV_BILLING_TYPES.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_COV_BILLING_TYPES.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_COV_BILLING_TYPES.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_COV_BILLING_TYPES.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_COV_BILLING_TYPES.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_COV_BILLING_TYPES.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_COV_BILLING_TYPES.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_COV_BILLING_TYPES.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_COV_BILLING_TYPES.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_COV_BILLING_TYPES.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_COV_BILLING_TYPES.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_COV_BILLING_TYPES.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_COV_BILLING_TYPES.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_COV_BILLING_TYPES.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_coverage_billing_type_id     OUT NUMBER,
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
    p_coverage_billing_type_id     IN NUMBER,
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
    p_billingtype_val_rec          IN BillingType_Val_Rec_Type := G_MISS_BILLINGTYPE_VAL_REC,
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
    p_coverage_billing_type_id     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_percent_per_use          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_amount_per_use           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_txn_billing_type_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_coverage_txn_group_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_COV_BILLING_TYPES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COV_BILLING_TYPES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COV_BILLING_TYPES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COV_BILLING_TYPES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COV_BILLING_TYPES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COV_BILLING_TYPES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COV_BILLING_TYPES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COV_BILLING_TYPES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COV_BILLING_TYPES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COV_BILLING_TYPES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COV_BILLING_TYPES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COV_BILLING_TYPES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COV_BILLING_TYPES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COV_BILLING_TYPES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COV_BILLING_TYPES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COV_BILLING_TYPES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COV_BILLING_TYPES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COV_BILLING_TYPES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
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
    p_coverage_billing_type_id     IN NUMBER);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_billingtype_val_rec          IN BillingType_Val_Rec_Type := G_MISS_BILLINGTYPE_VAL_REC);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_coverage_billing_type_id     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_percent_per_use          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_amount_per_use           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_txn_billing_type_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_coverage_txn_group_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_COV_BILLING_TYPES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COV_BILLING_TYPES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COV_BILLING_TYPES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COV_BILLING_TYPES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COV_BILLING_TYPES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COV_BILLING_TYPES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COV_BILLING_TYPES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COV_BILLING_TYPES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COV_BILLING_TYPES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COV_BILLING_TYPES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COV_BILLING_TYPES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COV_BILLING_TYPES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COV_BILLING_TYPES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COV_BILLING_TYPES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COV_BILLING_TYPES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COV_BILLING_TYPES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COV_BILLING_TYPES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COV_BILLING_TYPES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
END CS_BILLINGTYPE_PVT;

 

/

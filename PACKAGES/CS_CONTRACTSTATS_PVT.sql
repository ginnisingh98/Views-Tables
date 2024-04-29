--------------------------------------------------------
--  DDL for Package CS_CONTRACTSTATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTRACTSTATS_PVT" AUTHID CURRENT_USER AS
/* $Header: csctcsts.pls 115.0 99/07/16 08:51:32 porting ship  $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ContractStats_Rec_Type IS RECORD (
    contract_status_id             NUMBER := NULL,
    name                           CS_CONTRACT_STATUSES.NAME%TYPE := NULL,
    description                    CS_CONTRACT_STATUSES.DESCRIPTION%TYPE := NULL,
    validate_contract              CS_CONTRACT_STATUSES.VALIDATE_CONTRACT%TYPE := NULL,
    status_level                   NUMBER := NULL,
    eligible_for_invoicing         CS_CONTRACT_STATUSES.ELIGIBLE_FOR_INVOICING%TYPE := NULL,
    update_allowed                 CS_CONTRACT_STATUSES.UPDATE_ALLOWED%TYPE := NULL,
    eligible_for_entitlements      CS_CONTRACT_STATUSES.ELIGIBLE_FOR_ENTITLEMENTS%TYPE := NULL,
    terminated_flag                CS_CONTRACT_STATUSES.TERMINATED_FLAG%TYPE := NULL,
    delete_allowed                 CS_CONTRACT_STATUSES.DELETE_ALLOWED%TYPE := NULL,
    last_update_date               CS_CONTRACT_STATUSES.LAST_UPDATE_DATE%TYPE := NULL,
    last_updated_by                NUMBER := NULL,
    creation_date                  CS_CONTRACT_STATUSES.CREATION_DATE%TYPE := NULL,
    created_by                     NUMBER := NULL,
    last_update_login              NUMBER := NULL,
    start_date_active              CS_CONTRACT_STATUSES.START_DATE_ACTIVE%TYPE := NULL,
    end_date_active                CS_CONTRACT_STATUSES.END_DATE_ACTIVE%TYPE := NULL,
    attribute1                     CS_CONTRACT_STATUSES.ATTRIBUTE1%TYPE := NULL,
    attribute2                     CS_CONTRACT_STATUSES.ATTRIBUTE2%TYPE := NULL,
    attribute3                     CS_CONTRACT_STATUSES.ATTRIBUTE3%TYPE := NULL,
    attribute4                     CS_CONTRACT_STATUSES.ATTRIBUTE4%TYPE := NULL,
    attribute5                     CS_CONTRACT_STATUSES.ATTRIBUTE5%TYPE := NULL,
    attribute6                     CS_CONTRACT_STATUSES.ATTRIBUTE6%TYPE := NULL,
    attribute7                     CS_CONTRACT_STATUSES.ATTRIBUTE7%TYPE := NULL,
    attribute8                     CS_CONTRACT_STATUSES.ATTRIBUTE8%TYPE := NULL,
    attribute9                     CS_CONTRACT_STATUSES.ATTRIBUTE9%TYPE := NULL,
    attribute10                    CS_CONTRACT_STATUSES.ATTRIBUTE10%TYPE := NULL,
    attribute11                    CS_CONTRACT_STATUSES.ATTRIBUTE11%TYPE := NULL,
    attribute12                    CS_CONTRACT_STATUSES.ATTRIBUTE12%TYPE := NULL,
    attribute13                    CS_CONTRACT_STATUSES.ATTRIBUTE13%TYPE := NULL,
    attribute14                    CS_CONTRACT_STATUSES.ATTRIBUTE14%TYPE := NULL,
    attribute15                    CS_CONTRACT_STATUSES.ATTRIBUTE15%TYPE := NULL,
    context                        CS_CONTRACT_STATUSES.CONTEXT%TYPE := NULL,
    object_version_number          NUMBER := NULL);
  G_MISS_contractstats_rec                ContractStats_Rec_Type;
  TYPE ContractStats_Val_Rec_Type IS RECORD (
    contract_status_id             NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    name                           CS_CONTRACT_STATUSES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    description                    CS_CONTRACT_STATUSES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    validate_contract              CS_CONTRACT_STATUSES.VALIDATE_CONTRACT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    status_level                   NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    eligible_for_invoicing         CS_CONTRACT_STATUSES.ELIGIBLE_FOR_INVOICING%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    update_allowed                 CS_CONTRACT_STATUSES.UPDATE_ALLOWED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    eligible_for_entitlements      CS_CONTRACT_STATUSES.ELIGIBLE_FOR_ENTITLEMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    terminated_flag                CS_CONTRACT_STATUSES.TERMINATED_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    delete_allowed                 CS_CONTRACT_STATUSES.DELETE_ALLOWED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    last_update_date               CS_CONTRACT_STATUSES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    last_updated_by                NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    creation_date                  CS_CONTRACT_STATUSES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    created_by                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    last_update_login              NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    start_date_active              CS_CONTRACT_STATUSES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    end_date_active                CS_CONTRACT_STATUSES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    attribute1                     CS_CONTRACT_STATUSES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute2                     CS_CONTRACT_STATUSES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute3                     CS_CONTRACT_STATUSES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute4                     CS_CONTRACT_STATUSES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute5                     CS_CONTRACT_STATUSES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute6                     CS_CONTRACT_STATUSES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute7                     CS_CONTRACT_STATUSES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute8                     CS_CONTRACT_STATUSES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute9                     CS_CONTRACT_STATUSES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute10                    CS_CONTRACT_STATUSES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute11                    CS_CONTRACT_STATUSES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute12                    CS_CONTRACT_STATUSES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute13                    CS_CONTRACT_STATUSES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute14                    CS_CONTRACT_STATUSES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute15                    CS_CONTRACT_STATUSES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    context                        CS_CONTRACT_STATUSES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    object_version_number          NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
  G_MISS_contractstats_val_rec            ContractStats_Val_Rec_Type;
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
  G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'CS_CONTRACTSTATS_PVT';
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
    p_contractstats_rec            IN ContractStats_Rec_Type := G_MISS_CONTRACTSTATS_REC,
    x_contract_status_id           OUT NUMBER,
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
    p_name                         IN CS_CONTRACT_STATUSES.NAME%TYPE := NULL,
    p_description                  IN CS_CONTRACT_STATUSES.DESCRIPTION%TYPE := NULL,
    p_validate_contract            IN CS_CONTRACT_STATUSES.VALIDATE_CONTRACT%TYPE := NULL,
    p_status_level                 IN NUMBER := NULL,
    p_eligible_for_invoicing       IN CS_CONTRACT_STATUSES.ELIGIBLE_FOR_INVOICING%TYPE := NULL,
    p_update_allowed               IN CS_CONTRACT_STATUSES.UPDATE_ALLOWED%TYPE := NULL,
    p_eligible_for_entitlements    IN CS_CONTRACT_STATUSES.ELIGIBLE_FOR_ENTITLEMENTS%TYPE := NULL,
    p_terminated_flag              IN CS_CONTRACT_STATUSES.TERMINATED_FLAG%TYPE := NULL,
    p_delete_allowed               IN CS_CONTRACT_STATUSES.DELETE_ALLOWED%TYPE := NULL,
    p_last_update_date             IN CS_CONTRACT_STATUSES.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_CONTRACT_STATUSES.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_start_date_active            IN CS_CONTRACT_STATUSES.START_DATE_ACTIVE%TYPE := NULL,
    p_end_date_active              IN CS_CONTRACT_STATUSES.END_DATE_ACTIVE%TYPE := NULL,
    p_attribute1                   IN CS_CONTRACT_STATUSES.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_CONTRACT_STATUSES.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_CONTRACT_STATUSES.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_CONTRACT_STATUSES.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_CONTRACT_STATUSES.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_CONTRACT_STATUSES.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_CONTRACT_STATUSES.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_CONTRACT_STATUSES.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_CONTRACT_STATUSES.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_CONTRACT_STATUSES.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_CONTRACT_STATUSES.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_CONTRACT_STATUSES.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_CONTRACT_STATUSES.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_CONTRACT_STATUSES.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_CONTRACT_STATUSES.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_CONTRACT_STATUSES.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_contract_status_id           OUT NUMBER,
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
    p_contract_status_id           IN NUMBER,
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
    p_contractstats_val_rec        IN ContractStats_Val_Rec_Type := G_MISS_CONTRACTSTATS_VAL_REC,
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
    p_contract_status_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_CONTRACT_STATUSES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_CONTRACT_STATUSES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_validate_contract            IN CS_CONTRACT_STATUSES.VALIDATE_CONTRACT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_status_level                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_eligible_for_invoicing       IN CS_CONTRACT_STATUSES.ELIGIBLE_FOR_INVOICING%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_update_allowed               IN CS_CONTRACT_STATUSES.UPDATE_ALLOWED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_eligible_for_entitlements    IN CS_CONTRACT_STATUSES.ELIGIBLE_FOR_ENTITLEMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_terminated_flag              IN CS_CONTRACT_STATUSES.TERMINATED_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_delete_allowed               IN CS_CONTRACT_STATUSES.DELETE_ALLOWED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_CONTRACT_STATUSES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACT_STATUSES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CONTRACT_STATUSES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CONTRACT_STATUSES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_CONTRACT_STATUSES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACT_STATUSES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACT_STATUSES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACT_STATUSES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACT_STATUSES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACT_STATUSES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACT_STATUSES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACT_STATUSES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACT_STATUSES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACT_STATUSES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACT_STATUSES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACT_STATUSES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACT_STATUSES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACT_STATUSES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACT_STATUSES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACT_STATUSES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
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
    p_contract_status_id           IN NUMBER);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contractstats_val_rec        IN ContractStats_Val_Rec_Type := G_MISS_CONTRACTSTATS_VAL_REC);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contract_status_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_CONTRACT_STATUSES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_CONTRACT_STATUSES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_validate_contract            IN CS_CONTRACT_STATUSES.VALIDATE_CONTRACT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_status_level                 IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_eligible_for_invoicing       IN CS_CONTRACT_STATUSES.ELIGIBLE_FOR_INVOICING%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_update_allowed               IN CS_CONTRACT_STATUSES.UPDATE_ALLOWED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_eligible_for_entitlements    IN CS_CONTRACT_STATUSES.ELIGIBLE_FOR_ENTITLEMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_terminated_flag              IN CS_CONTRACT_STATUSES.TERMINATED_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_delete_allowed               IN CS_CONTRACT_STATUSES.DELETE_ALLOWED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_CONTRACT_STATUSES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACT_STATUSES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CONTRACT_STATUSES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CONTRACT_STATUSES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_CONTRACT_STATUSES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACT_STATUSES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACT_STATUSES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACT_STATUSES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACT_STATUSES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACT_STATUSES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACT_STATUSES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACT_STATUSES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACT_STATUSES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACT_STATUSES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACT_STATUSES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACT_STATUSES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACT_STATUSES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACT_STATUSES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACT_STATUSES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACT_STATUSES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
END CS_CONTRACTSTATS_PVT;

 

/

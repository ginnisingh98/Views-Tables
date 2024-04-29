--------------------------------------------------------
--  DDL for Package CS_CONTINTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTINTF_PVT" AUTHID CURRENT_USER AS
/* $Header: csctcbis.pls 115.0 99/07/16 08:49:07 porting ship  $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ContIntf_Rec_Type IS RECORD (
    contracts_interface_id         NUMBER := NULL,
    cp_service_transaction_id      NUMBER := NULL,
    cp_service_id                  NUMBER := NULL,
    contract_id                    NUMBER := NULL,
    ar_trx_type                    CS_CONT_BILL_IFACE.AR_TRX_TYPE%TYPE := NULL,
    trx_start_date                 CS_CONT_BILL_IFACE.TRX_START_DATE%TYPE := NULL,
    trx_end_date                   CS_CONT_BILL_IFACE.TRX_END_DATE%TYPE := NULL,
    trx_date                       CS_CONT_BILL_IFACE.TRX_DATE%TYPE := NULL,
    trx_amount                     NUMBER := NULL,
    reason_code                    CS_CONT_BILL_IFACE.REASON_CODE%TYPE := NULL,
    reason_comments                CS_CONT_BILL_IFACE.REASON_COMMENTS%TYPE := NULL,
    contract_billing_id            NUMBER := NULL,
    cp_quantity                    NUMBER := NULL,
    concurrent_process_id          NUMBER := NULL,
    created_by                     NUMBER := NULL,
    creation_date                  CS_CONT_BILL_IFACE.CREATION_DATE%TYPE := NULL,
    object_version_number          NUMBER := NULL);
  G_MISS_contintf_rec                     ContIntf_Rec_Type;
  TYPE ContIntf_Val_Rec_Type IS RECORD (
    contracts_interface_id         NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    cp_service_transaction_id      NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    cp_service_id                  NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    contract_id                    NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    ar_trx_type                    CS_CONT_BILL_IFACE.AR_TRX_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    trx_start_date                 CS_CONT_BILL_IFACE.TRX_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    trx_end_date                   CS_CONT_BILL_IFACE.TRX_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    trx_date                       CS_CONT_BILL_IFACE.TRX_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    trx_amount                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    reason_code                    CS_CONT_BILL_IFACE.REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    reason_comments                CS_CONT_BILL_IFACE.REASON_COMMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    contract_billing_id            NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    cp_quantity                    NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    concurrent_process_id          NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    created_by                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    creation_date                  CS_CONT_BILL_IFACE.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    object_version_number          NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
  G_MISS_contintf_val_rec                 ContIntf_Val_Rec_Type;
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
  G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'CS_CONTINTF_PVT';
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
    p_contintf_rec                 IN ContIntf_Rec_Type := G_MISS_CONTINTF_REC,
    x_contracts_interface_id       OUT NUMBER,
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
    p_cp_service_transaction_id    IN NUMBER := NULL,
    p_cp_service_id                IN NUMBER := NULL,
    p_contract_id                  IN NUMBER := NULL,
    p_ar_trx_type                  IN CS_CONT_BILL_IFACE.AR_TRX_TYPE%TYPE := NULL,
    p_trx_start_date               IN CS_CONT_BILL_IFACE.TRX_START_DATE%TYPE := NULL,
    p_trx_end_date                 IN CS_CONT_BILL_IFACE.TRX_END_DATE%TYPE := NULL,
    p_trx_date                     IN CS_CONT_BILL_IFACE.TRX_DATE%TYPE := NULL,
    p_trx_amount                   IN NUMBER := NULL,
    p_reason_code                  IN CS_CONT_BILL_IFACE.REASON_CODE%TYPE := NULL,
    p_reason_comments              IN CS_CONT_BILL_IFACE.REASON_COMMENTS%TYPE := NULL,
    p_contract_billing_id          IN NUMBER := NULL,
    p_cp_quantity                  IN NUMBER := NULL,
    p_concurrent_process_id        IN NUMBER := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_creation_date                IN CS_CONT_BILL_IFACE.CREATION_DATE%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_contracts_interface_id       OUT NUMBER,
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
    p_contracts_interface_id       IN NUMBER,
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
    p_contintf_val_rec             IN ContIntf_Val_Rec_Type := G_MISS_CONTINTF_VAL_REC,
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
    p_contracts_interface_id       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_transaction_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_ar_trx_type                  IN CS_CONT_BILL_IFACE.AR_TRX_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_trx_start_date               IN CS_CONT_BILL_IFACE.TRX_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_end_date                 IN CS_CONT_BILL_IFACE.TRX_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_date                     IN CS_CONT_BILL_IFACE.TRX_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_amount                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reason_code                  IN CS_CONT_BILL_IFACE.REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_reason_comments              IN CS_CONT_BILL_IFACE.REASON_COMMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_billing_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_quantity                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_concurrent_process_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONT_BILL_IFACE.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
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
    p_contracts_interface_id       IN NUMBER);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contintf_val_rec             IN ContIntf_Val_Rec_Type := G_MISS_CONTINTF_VAL_REC);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contracts_interface_id       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_transaction_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_ar_trx_type                  IN CS_CONT_BILL_IFACE.AR_TRX_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_trx_start_date               IN CS_CONT_BILL_IFACE.TRX_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_end_date                 IN CS_CONT_BILL_IFACE.TRX_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_date                     IN CS_CONT_BILL_IFACE.TRX_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_trx_amount                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reason_code                  IN CS_CONT_BILL_IFACE.REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_reason_comments              IN CS_CONT_BILL_IFACE.REASON_COMMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_billing_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_quantity                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_concurrent_process_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONT_BILL_IFACE.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
END CS_CONTINTF_PVT;

 

/

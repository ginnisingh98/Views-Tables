--------------------------------------------------------
--  DDL for Package Body CS_CONTINTF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTINTF_PVT" AS
/* $Header: csctcbib.pls 115.1 99/07/16 08:49:03 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_CONT_BILL_IFACE_S.nextval FROM SYS.DUAL;
      l_seq_id                       NUMBER := 0;
  BEGIN
    OPEN get_seq_id_csr;
    FETCH get_seq_id_csr INTO l_seq_id;
    CLOSE get_seq_id_csr;
    RETURN(l_seq_id);
  END get_seq_id;


  -- Validation
  FUNCTION Validate_Item_Attributes
  (
    p_contintf_rec IN  ContIntf_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_contintf_rec.cp_service_transaction_id = TAPI_DEV_KIT.G_MISS_NUM OR
       p_contintf_rec.cp_service_transaction_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cp_service_transaction_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.cp_service_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contintf_rec.cp_service_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cp_service_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.contract_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contintf_rec.contract_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.ar_trx_type = TAPI_DEV_KIT.G_MISS_CHAR OR
          p_contintf_rec.ar_trx_type IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ar_trx_type');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.trx_start_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contintf_rec.trx_start_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'trx_start_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.trx_end_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contintf_rec.trx_end_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'trx_end_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.trx_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contintf_rec.trx_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'trx_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.trx_amount = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contintf_rec.trx_amount IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'trx_amount');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contintf_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contintf_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contintf_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_contintf_rec IN  ContIntf_Rec_Type,
    l_def_contintf_rec OUT  ContIntf_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_contintf_rec := p_contintf_rec;
    l_def_contintf_rec.OBJECT_VERSION_NUMBER := NVL(l_def_contintf_rec.OBJECT_VERSION_NUMBER, 0) + 1;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_contintf_rec IN ContIntf_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN ContIntf_Val_Rec_Type,
    p_to	OUT ContIntf_Rec_Type
  ) IS
  BEGIN
    p_to.contracts_interface_id := p_from.contracts_interface_id;
    p_to.cp_service_transaction_id := p_from.cp_service_transaction_id;
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.contract_id := p_from.contract_id;
    p_to.ar_trx_type := p_from.ar_trx_type;
    p_to.trx_start_date := p_from.trx_start_date;
    p_to.trx_end_date := p_from.trx_end_date;
    p_to.trx_date := p_from.trx_date;
    p_to.trx_amount := p_from.trx_amount;
    p_to.reason_code := p_from.reason_code;
    p_to.reason_comments := p_from.reason_comments;
    p_to.contract_billing_id := p_from.contract_billing_id;
    p_to.cp_quantity := p_from.cp_quantity;
    p_to.concurrent_process_id := p_from.concurrent_process_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ContIntf_Rec_Type,
    p_to	OUT ContIntf_Val_Rec_Type
  ) IS
  BEGIN
    p_to.contracts_interface_id := p_from.contracts_interface_id;
    p_to.cp_service_transaction_id := p_from.cp_service_transaction_id;
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.contract_id := p_from.contract_id;
    p_to.ar_trx_type := p_from.ar_trx_type;
    p_to.trx_start_date := p_from.trx_start_date;
    p_to.trx_end_date := p_from.trx_end_date;
    p_to.trx_date := p_from.trx_date;
    p_to.trx_amount := p_from.trx_amount;
    p_to.reason_code := p_from.reason_code;
    p_to.reason_comments := p_from.reason_comments;
    p_to.contract_billing_id := p_from.contract_billing_id;
    p_to.cp_quantity := p_from.cp_quantity;
    p_to.concurrent_process_id := p_from.concurrent_process_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
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
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contintf_rec                 ContIntf_Rec_Type;
    l_def_contintf_rec             ContIntf_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_contintf_rec := p_contintf_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_contintf_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_contintf_rec,    ---- IN
      l_def_contintf_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contintf_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_contintf_rec.contracts_interface_id := get_seq_id;
    INSERT INTO CS_CONT_BILL_IFACE(
        contracts_interface_id,
        cp_service_transaction_id,
        cp_service_id,
        contract_id,
        ar_trx_type,
        trx_start_date,
        trx_end_date,
        trx_date,
        trx_amount,
        reason_code,
        reason_comments,
        contract_billing_id,
        cp_quantity,
        concurrent_process_id,
        created_by,
        creation_date,
        object_version_number)
      VALUES (
        l_def_contintf_rec.contracts_interface_id,
        l_def_contintf_rec.cp_service_transaction_id,
        l_def_contintf_rec.cp_service_id,
        l_def_contintf_rec.contract_id,
        l_def_contintf_rec.ar_trx_type,
        l_def_contintf_rec.trx_start_date,
        l_def_contintf_rec.trx_end_date,
        l_def_contintf_rec.trx_date,
        l_def_contintf_rec.trx_amount,
        l_def_contintf_rec.reason_code,
        l_def_contintf_rec.reason_comments,
        l_def_contintf_rec.contract_billing_id,
        l_def_contintf_rec.cp_quantity,
        l_def_contintf_rec.concurrent_process_id,
        l_def_contintf_rec.created_by,
        l_def_contintf_rec.creation_date,
        l_def_contintf_rec.object_version_number);
    -- Set OUT values
    x_contracts_interface_id := l_def_contintf_rec.contracts_interface_id;
    x_object_version_number       := l_def_contintf_rec.OBJECT_VERSION_NUMBER;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_row;
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
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contintf_rec                 ContIntf_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_contintf_rec.CP_SERVICE_TRANSACTION_ID := p_cp_service_transaction_id;
    l_contintf_rec.CP_SERVICE_ID := p_cp_service_id;
    l_contintf_rec.CONTRACT_ID := p_contract_id;
    l_contintf_rec.AR_TRX_TYPE := p_ar_trx_type;
    l_contintf_rec.TRX_START_DATE := p_trx_start_date;
    l_contintf_rec.TRX_END_DATE := p_trx_end_date;
    l_contintf_rec.TRX_DATE := p_trx_date;
    l_contintf_rec.TRX_AMOUNT := p_trx_amount;
    l_contintf_rec.REASON_CODE := p_reason_code;
    l_contintf_rec.REASON_COMMENTS := p_reason_comments;
    l_contintf_rec.CONTRACT_BILLING_ID := p_contract_billing_id;
    l_contintf_rec.CP_QUANTITY := p_cp_quantity;
    l_contintf_rec.CONCURRENT_PROCESS_ID := p_concurrent_process_id;
    l_contintf_rec.CREATED_BY := p_created_by;
    l_contintf_rec.CREATION_DATE := p_creation_date;
    l_contintf_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contintf_rec,
      x_contracts_interface_id,
      x_object_version_number
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END insert_row;
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
    p_object_version_number        IN NUMBER) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_CONT_BILL_IFACE
    WHERE
      CONTRACTS_INTERFACE_ID = p_contracts_interface_id AND
      OBJECT_VERSION_NUMBER = p_object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_CONT_BILL_IFACE
    WHERE
      CONTRACTS_INTERFACE_ID = p_contracts_interface_id
      ;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_object_version_number       CS_CONT_BILL_IFACE.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      CS_CONT_BILL_IFACE.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr;
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr;
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number > p_object_version_number THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number <> p_object_version_number THEN
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE FND_API.G_EXC_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END lock_row;
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
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contintf_rec                 ContIntf_Rec_Type;
    l_def_contintf_rec             ContIntf_Rec_Type;
    FUNCTION populate_new_record (
      p_contintf_rec	IN ContIntf_Rec_Type,
      x_contintf_rec	OUT ContIntf_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR oco_26638_csr (p_contracts_interface_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Cont_Bill_Iface
       WHERE cs_cont_bill_iface.contracts_interface_id = p_contracts_interface_id;
      l_oco_26638                    oco_26638_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_contintf_rec := p_contintf_rec;
      -- Get current database values
      OPEN oco_26638_csr (p_contintf_rec.contracts_interface_id);
      FETCH oco_26638_csr INTO l_oco_26638;
      l_row_notfound := oco_26638_csr%NOTFOUND;
      CLOSE oco_26638_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_contintf_rec.contracts_interface_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.contracts_interface_id := l_oco_26638.contracts_interface_id;
      END IF;
      IF (x_contintf_rec.cp_service_transaction_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.cp_service_transaction_id := l_oco_26638.cp_service_transaction_id;
      END IF;
      IF (x_contintf_rec.cp_service_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.cp_service_id := l_oco_26638.cp_service_id;
      END IF;
      IF (x_contintf_rec.contract_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.contract_id := l_oco_26638.contract_id;
      END IF;
      IF (x_contintf_rec.ar_trx_type = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contintf_rec.ar_trx_type := l_oco_26638.ar_trx_type;
      END IF;
      IF (x_contintf_rec.trx_start_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contintf_rec.trx_start_date := l_oco_26638.trx_start_date;
      END IF;
      IF (x_contintf_rec.trx_end_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contintf_rec.trx_end_date := l_oco_26638.trx_end_date;
      END IF;
      IF (x_contintf_rec.trx_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contintf_rec.trx_date := l_oco_26638.trx_date;
      END IF;
      IF (x_contintf_rec.trx_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.trx_amount := l_oco_26638.trx_amount;
      END IF;
      IF (x_contintf_rec.reason_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contintf_rec.reason_code := l_oco_26638.reason_code;
      END IF;
      IF (x_contintf_rec.reason_comments = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contintf_rec.reason_comments := l_oco_26638.reason_comments;
      END IF;
      IF (x_contintf_rec.contract_billing_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.contract_billing_id := l_oco_26638.contract_billing_id;
      END IF;
      IF (x_contintf_rec.cp_quantity = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.cp_quantity := l_oco_26638.cp_quantity;
      END IF;
      IF (x_contintf_rec.concurrent_process_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.concurrent_process_id := l_oco_26638.concurrent_process_id;
      END IF;
      IF (x_contintf_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.created_by := l_oco_26638.created_by;
      END IF;
      IF (x_contintf_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contintf_rec.creation_date := l_oco_26638.creation_date;
      END IF;
      IF (x_contintf_rec.object_version_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contintf_rec.object_version_number := l_oco_26638.object_version_number;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    migrate(p_contintf_val_rec, l_contintf_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_contintf_rec,    ---- IN
      l_def_contintf_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_contintf_rec, l_def_contintf_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_contintf_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contintf_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_CONT_BILL_IFACE
    SET
        CONTRACTS_INTERFACE_ID = l_def_contintf_rec.contracts_interface_id ,
        CP_SERVICE_TRANSACTION_ID = l_def_contintf_rec.cp_service_transaction_id ,
        CP_SERVICE_ID = l_def_contintf_rec.cp_service_id ,
        CONTRACT_ID = l_def_contintf_rec.contract_id ,
        AR_TRX_TYPE = l_def_contintf_rec.ar_trx_type ,
        TRX_START_DATE = l_def_contintf_rec.trx_start_date ,
        TRX_END_DATE = l_def_contintf_rec.trx_end_date ,
        TRX_DATE = l_def_contintf_rec.trx_date ,
        TRX_AMOUNT = l_def_contintf_rec.trx_amount ,
        REASON_CODE = l_def_contintf_rec.reason_code ,
        REASON_COMMENTS = l_def_contintf_rec.reason_comments ,
        CONTRACT_BILLING_ID = l_def_contintf_rec.contract_billing_id ,
        CP_QUANTITY = l_def_contintf_rec.cp_quantity ,
        CONCURRENT_PROCESS_ID = l_def_contintf_rec.concurrent_process_id ,
        CREATED_BY = l_def_contintf_rec.created_by ,
        CREATION_DATE = l_def_contintf_rec.creation_date ,
        OBJECT_VERSION_NUMBER = l_def_contintf_rec.object_version_number
        WHERE
          CONTRACTS_INTERFACE_ID = l_def_contintf_rec.contracts_interface_id
          ;
    x_object_version_number := l_def_contintf_rec.OBJECT_VERSION_NUMBER;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END update_row;
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
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contintf_rec                 ContIntf_Val_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_contintf_rec.CONTRACTS_INTERFACE_ID := p_contracts_interface_id;
    l_contintf_rec.CP_SERVICE_TRANSACTION_ID := p_cp_service_transaction_id;
    l_contintf_rec.CP_SERVICE_ID := p_cp_service_id;
    l_contintf_rec.CONTRACT_ID := p_contract_id;
    l_contintf_rec.AR_TRX_TYPE := p_ar_trx_type;
    l_contintf_rec.TRX_START_DATE := p_trx_start_date;
    l_contintf_rec.TRX_END_DATE := p_trx_end_date;
    l_contintf_rec.TRX_DATE := p_trx_date;
    l_contintf_rec.TRX_AMOUNT := p_trx_amount;
    l_contintf_rec.REASON_CODE := p_reason_code;
    l_contintf_rec.REASON_COMMENTS := p_reason_comments;
    l_contintf_rec.CONTRACT_BILLING_ID := p_contract_billing_id;
    l_contintf_rec.CP_QUANTITY := p_cp_quantity;
    l_contintf_rec.CONCURRENT_PROCESS_ID := p_concurrent_process_id;
    l_contintf_rec.CREATED_BY := p_created_by;
    l_contintf_rec.CREATION_DATE := p_creation_date;
    l_contintf_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contintf_rec,
      x_object_version_number
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END update_row;
  Procedure delete_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contracts_interface_id       IN NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    DELETE  FROM CS_CONT_BILL_IFACE
    WHERE
      CONTRACTS_INTERFACE_ID = p_contracts_interface_id
      ;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END delete_row;
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_contintf_val_rec             IN ContIntf_Val_Rec_Type := G_MISS_CONTINTF_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contintf_rec                 ContIntf_Rec_Type;
    l_def_contintf_rec             ContIntf_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    migrate(p_contintf_val_rec, l_contintf_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_contintf_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contintf_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END validate_row;
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
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contintf_rec                 ContIntf_Val_Rec_Type;
  BEGIN
    l_return_status := TAPI_DEV_KIT.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              l_api_version,
                                              p_api_version,
                                              p_init_msg_list,
                                              '_Pvt',
                                              x_return_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_contintf_rec.CONTRACTS_INTERFACE_ID := p_contracts_interface_id;
    l_contintf_rec.CP_SERVICE_TRANSACTION_ID := p_cp_service_transaction_id;
    l_contintf_rec.CP_SERVICE_ID := p_cp_service_id;
    l_contintf_rec.CONTRACT_ID := p_contract_id;
    l_contintf_rec.AR_TRX_TYPE := p_ar_trx_type;
    l_contintf_rec.TRX_START_DATE := p_trx_start_date;
    l_contintf_rec.TRX_END_DATE := p_trx_end_date;
    l_contintf_rec.TRX_DATE := p_trx_date;
    l_contintf_rec.TRX_AMOUNT := p_trx_amount;
    l_contintf_rec.REASON_CODE := p_reason_code;
    l_contintf_rec.REASON_COMMENTS := p_reason_comments;
    l_contintf_rec.CONTRACT_BILLING_ID := p_contract_billing_id;
    l_contintf_rec.CP_QUANTITY := p_cp_quantity;
    l_contintf_rec.CONCURRENT_PROCESS_ID := p_concurrent_process_id;
    l_contintf_rec.CREATED_BY := p_created_by;
    l_contintf_rec.CREATION_DATE := p_creation_date;
    l_contintf_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contintf_rec
    );
    TAPI_DEV_KIT.END_ACTIVITY(p_commit, x_msg_count, x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'FND_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TAPI_DEV_KIT.G_EXC_DUP_VAL_ON_INDEX THEN
      x_return_status :=TAPI_DEV_KIT.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'TAPI_DEV_KIT.G_RET_STS_DUP_VAL_ON_INDEX',
        x_msg_count,
        x_msg_data,
        '_Pvt'
      );
    APP_EXCEPTION.RAISE_EXCEPTION;
  END validate_row;
END CS_CONTINTF_PVT;

/

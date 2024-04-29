--------------------------------------------------------
--  DDL for Package Body CS_CONTRACTBILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTRACTBILLING_PVT" AS
/* $Header: csctcbpb.pls 115.1 99/07/16 08:49:13 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_CONTRACTS_BILLING_S.nextval FROM SYS.DUAL;
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
    p_contractbilling_rec IN  ContractBilling_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_contractbilling_rec.cp_service_id = TAPI_DEV_KIT.G_MISS_NUM OR
       p_contractbilling_rec.cp_service_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cp_service_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contractbilling_rec.contract_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contractbilling_rec.contract_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contractbilling_rec.billed_until_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contractbilling_rec.billed_until_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'billed_until_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contractbilling_rec.currency_code = TAPI_DEV_KIT.G_MISS_CHAR OR
          p_contractbilling_rec.currency_code IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_code');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contractbilling_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contractbilling_rec.last_update_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contractbilling_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contractbilling_rec.last_updated_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contractbilling_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contractbilling_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contractbilling_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contractbilling_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_contractbilling_rec IN  ContractBilling_Rec_Type,
    l_def_contractbilling_rec OUT  ContractBilling_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_contractbilling_rec := p_contractbilling_rec;
    l_def_contractbilling_rec.OBJECT_VERSION_NUMBER := NVL(l_def_contractbilling_rec.OBJECT_VERSION_NUMBER, 0) + 1;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_contractbilling_rec IN ContractBilling_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    FUNCTION validate_foreign_keys (
      p_contractbilling_rec IN ContractBilling_Rec_Type
    )
    RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR cs_contracts_all_pk_csr (p_contract_id        IN NUMBER) IS
      SELECT *
        FROM Cs_Contracts_All
       WHERE cs_contracts_all.contract_id = p_contract_id;
      l_cs_contracts_all_pk          cs_contracts_all_pk_csr%ROWTYPE;
      CURSOR cs_cp_services_all_pk_csr (p_cp_service_id      IN NUMBER) IS
      SELECT *
        FROM Cs_Cp_Services_All
       WHERE cs_cp_services_all.cp_service_id = p_cp_service_id;
      l_cs_cp_services_all_pk        cs_cp_services_all_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_contractbilling_rec.CONTRACT_ID IS NOT NULL)
      THEN
        OPEN cs_contracts_all_pk_csr(p_contractbilling_rec.CONTRACT_ID);
        FETCH cs_contracts_all_pk_csr INTO l_cs_contracts_all_pk;
        l_row_notfound := cs_contracts_all_pk_csr%NOTFOUND;
        CLOSE cs_contracts_all_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTRACT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_contractbilling_rec.CP_SERVICE_ID IS NOT NULL)
      THEN
        OPEN cs_cp_services_all_pk_csr(p_contractbilling_rec.CP_SERVICE_ID);
        FETCH cs_cp_services_all_pk_csr INTO l_cs_cp_services_all_pk;
        l_row_notfound := cs_cp_services_all_pk_csr%NOTFOUND;
        CLOSE cs_cp_services_all_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CP_SERVICE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_contractbilling_rec);
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN ContractBilling_Val_Rec_Type,
    p_to	OUT ContractBilling_Rec_Type
  ) IS
  BEGIN
    p_to.contract_billing_id := p_from.contract_billing_id;
    p_to.header_id := p_from.header_id;
    p_to.order_number := p_from.order_number;
    p_to.line_id := p_from.line_id;
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.contract_id := p_from.contract_id;
    p_to.cust_trx_type_id := p_from.cust_trx_type_id;
    p_to.trx_date := p_from.trx_date;
    p_to.trx_number := p_from.trx_number;
    p_to.trx_amount := p_from.trx_amount;
    p_to.trx_class := p_from.trx_class;
    p_to.billed_until_date := p_from.billed_until_date;
    p_to.currency_code := p_from.currency_code;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.trx_pre_tax_amount := p_from.trx_pre_tax_amount;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.context := p_from.context;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ContractBilling_Rec_Type,
    p_to	OUT ContractBilling_Val_Rec_Type
  ) IS
  BEGIN
    p_to.contract_billing_id := p_from.contract_billing_id;
    p_to.header_id := p_from.header_id;
    p_to.order_number := p_from.order_number;
    p_to.line_id := p_from.line_id;
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.contract_id := p_from.contract_id;
    p_to.cust_trx_type_id := p_from.cust_trx_type_id;
    p_to.trx_date := p_from.trx_date;
    p_to.trx_number := p_from.trx_number;
    p_to.trx_amount := p_from.trx_amount;
    p_to.trx_class := p_from.trx_class;
    p_to.billed_until_date := p_from.billed_until_date;
    p_to.currency_code := p_from.currency_code;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.trx_pre_tax_amount := p_from.trx_pre_tax_amount;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.context := p_from.context;
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
    p_contractbilling_rec          IN ContractBilling_Rec_Type := G_MISS_CONTRACTBILLING_REC,
    x_contract_billing_id          OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contractbilling_rec          ContractBilling_Rec_Type;
    l_def_contractbilling_rec      ContractBilling_Rec_Type;
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
    l_contractbilling_rec := p_contractbilling_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_contractbilling_rec    ---- IN
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
      l_contractbilling_rec,    ---- IN
      l_def_contractbilling_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contractbilling_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_contractbilling_rec.contract_billing_id := get_seq_id;
    INSERT INTO CS_CONTRACTS_BILLING(
        contract_billing_id,
        header_id,
        order_number,
        line_id,
        cp_service_id,
        contract_id,
        cust_trx_type_id,
        trx_date,
        trx_number,
        trx_amount,
        trx_class,
        billed_until_date,
        currency_code,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        trx_pre_tax_amount,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        context,
        object_version_number)
      VALUES (
        l_def_contractbilling_rec.contract_billing_id,
        l_def_contractbilling_rec.header_id,
        l_def_contractbilling_rec.order_number,
        l_def_contractbilling_rec.line_id,
        l_def_contractbilling_rec.cp_service_id,
        l_def_contractbilling_rec.contract_id,
        l_def_contractbilling_rec.cust_trx_type_id,
        l_def_contractbilling_rec.trx_date,
        l_def_contractbilling_rec.trx_number,
        l_def_contractbilling_rec.trx_amount,
        l_def_contractbilling_rec.trx_class,
        l_def_contractbilling_rec.billed_until_date,
        l_def_contractbilling_rec.currency_code,
        l_def_contractbilling_rec.last_update_date,
        l_def_contractbilling_rec.last_updated_by,
        l_def_contractbilling_rec.creation_date,
        l_def_contractbilling_rec.created_by,
        l_def_contractbilling_rec.last_update_login,
        l_def_contractbilling_rec.trx_pre_tax_amount,
        l_def_contractbilling_rec.attribute1,
        l_def_contractbilling_rec.attribute2,
        l_def_contractbilling_rec.attribute3,
        l_def_contractbilling_rec.attribute4,
        l_def_contractbilling_rec.attribute5,
        l_def_contractbilling_rec.attribute6,
        l_def_contractbilling_rec.attribute7,
        l_def_contractbilling_rec.attribute8,
        l_def_contractbilling_rec.attribute9,
        l_def_contractbilling_rec.attribute10,
        l_def_contractbilling_rec.attribute11,
        l_def_contractbilling_rec.attribute12,
        l_def_contractbilling_rec.attribute13,
        l_def_contractbilling_rec.attribute14,
        l_def_contractbilling_rec.attribute15,
        l_def_contractbilling_rec.context,
        l_def_contractbilling_rec.object_version_number);
    -- Set OUT values
    x_contract_billing_id := l_def_contractbilling_rec.contract_billing_id;
    x_object_version_number       := l_def_contractbilling_rec.OBJECT_VERSION_NUMBER;
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
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contractbilling_rec          ContractBilling_Rec_Type;
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
    l_contractbilling_rec.HEADER_ID := p_header_id;
    l_contractbilling_rec.ORDER_NUMBER := p_order_number;
    l_contractbilling_rec.LINE_ID := p_line_id;
    l_contractbilling_rec.CP_SERVICE_ID := p_cp_service_id;
    l_contractbilling_rec.CONTRACT_ID := p_contract_id;
    l_contractbilling_rec.CUST_TRX_TYPE_ID := p_cust_trx_type_id;
    l_contractbilling_rec.TRX_DATE := p_trx_date;
    l_contractbilling_rec.TRX_NUMBER := p_trx_number;
    l_contractbilling_rec.TRX_AMOUNT := p_trx_amount;
    l_contractbilling_rec.TRX_CLASS := p_trx_class;
    l_contractbilling_rec.BILLED_UNTIL_DATE := p_billed_until_date;
    l_contractbilling_rec.CURRENCY_CODE := p_currency_code;
    l_contractbilling_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_contractbilling_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_contractbilling_rec.CREATION_DATE := p_creation_date;
    l_contractbilling_rec.CREATED_BY := p_created_by;
    l_contractbilling_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_contractbilling_rec.TRX_PRE_TAX_AMOUNT := p_trx_pre_tax_amount;
    l_contractbilling_rec.ATTRIBUTE1 := p_attribute1;
    l_contractbilling_rec.ATTRIBUTE2 := p_attribute2;
    l_contractbilling_rec.ATTRIBUTE3 := p_attribute3;
    l_contractbilling_rec.ATTRIBUTE4 := p_attribute4;
    l_contractbilling_rec.ATTRIBUTE5 := p_attribute5;
    l_contractbilling_rec.ATTRIBUTE6 := p_attribute6;
    l_contractbilling_rec.ATTRIBUTE7 := p_attribute7;
    l_contractbilling_rec.ATTRIBUTE8 := p_attribute8;
    l_contractbilling_rec.ATTRIBUTE9 := p_attribute9;
    l_contractbilling_rec.ATTRIBUTE10 := p_attribute10;
    l_contractbilling_rec.ATTRIBUTE11 := p_attribute11;
    l_contractbilling_rec.ATTRIBUTE12 := p_attribute12;
    l_contractbilling_rec.ATTRIBUTE13 := p_attribute13;
    l_contractbilling_rec.ATTRIBUTE14 := p_attribute14;
    l_contractbilling_rec.ATTRIBUTE15 := p_attribute15;
    l_contractbilling_rec.CONTEXT := p_context;
    l_contractbilling_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contractbilling_rec,
      x_contract_billing_id,
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
    p_contract_billing_id          IN NUMBER,
    p_object_version_number        IN NUMBER) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_CONTRACTS_BILLING
    WHERE
      CONTRACT_BILLING_ID = p_contract_billing_id AND
      OBJECT_VERSION_NUMBER = p_object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_CONTRACTS_BILLING
    WHERE
      CONTRACT_BILLING_ID = p_contract_billing_id
      ;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_object_version_number       CS_CONTRACTS_BILLING.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      CS_CONTRACTS_BILLING.OBJECT_VERSION_NUMBER%TYPE;
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
    p_contractbilling_val_rec      IN ContractBilling_Val_Rec_Type := G_MISS_CONTRACTBILLING_VAL_REC,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contractbilling_rec          ContractBilling_Rec_Type;
    l_def_contractbilling_rec      ContractBilling_Rec_Type;
    FUNCTION populate_new_record (
      p_contractbilling_rec	IN ContractBilling_Rec_Type,
      x_contractbilling_rec	OUT ContractBilling_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR cs_contracts_billing_pk_csr (p_contract_billing_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Contracts_Billing
       WHERE cs_contracts_billing.contract_billing_id = p_contract_billing_id;
      l_cs_contracts_billing_pk      cs_contracts_billing_pk_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_contractbilling_rec := p_contractbilling_rec;
      -- Get current database values
      OPEN cs_contracts_billing_pk_csr (p_contractbilling_rec.contract_billing_id);
      FETCH cs_contracts_billing_pk_csr INTO l_cs_contracts_billing_pk;
      l_row_notfound := cs_contracts_billing_pk_csr%NOTFOUND;
      CLOSE cs_contracts_billing_pk_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_contractbilling_rec.contract_billing_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.contract_billing_id := l_cs_contracts_billing_pk.contract_billing_id;
      END IF;
      IF (x_contractbilling_rec.header_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.header_id := l_cs_contracts_billing_pk.header_id;
      END IF;
      IF (x_contractbilling_rec.order_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.order_number := l_cs_contracts_billing_pk.order_number;
      END IF;
      IF (x_contractbilling_rec.line_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.line_id := l_cs_contracts_billing_pk.line_id;
      END IF;
      IF (x_contractbilling_rec.cp_service_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.cp_service_id := l_cs_contracts_billing_pk.cp_service_id;
      END IF;
      IF (x_contractbilling_rec.contract_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.contract_id := l_cs_contracts_billing_pk.contract_id;
      END IF;
      IF (x_contractbilling_rec.cust_trx_type_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.cust_trx_type_id := l_cs_contracts_billing_pk.cust_trx_type_id;
      END IF;
      IF (x_contractbilling_rec.trx_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contractbilling_rec.trx_date := l_cs_contracts_billing_pk.trx_date;
      END IF;
      IF (x_contractbilling_rec.trx_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.trx_number := l_cs_contracts_billing_pk.trx_number;
      END IF;
      IF (x_contractbilling_rec.trx_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.trx_amount := l_cs_contracts_billing_pk.trx_amount;
      END IF;
      IF (x_contractbilling_rec.trx_class = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.trx_class := l_cs_contracts_billing_pk.trx_class;
      END IF;
      IF (x_contractbilling_rec.billed_until_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contractbilling_rec.billed_until_date := l_cs_contracts_billing_pk.billed_until_date;
      END IF;
      IF (x_contractbilling_rec.currency_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.currency_code := l_cs_contracts_billing_pk.currency_code;
      END IF;
      IF (x_contractbilling_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contractbilling_rec.last_update_date := l_cs_contracts_billing_pk.last_update_date;
      END IF;
      IF (x_contractbilling_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.last_updated_by := l_cs_contracts_billing_pk.last_updated_by;
      END IF;
      IF (x_contractbilling_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contractbilling_rec.creation_date := l_cs_contracts_billing_pk.creation_date;
      END IF;
      IF (x_contractbilling_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.created_by := l_cs_contracts_billing_pk.created_by;
      END IF;
      IF (x_contractbilling_rec.last_update_login = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.last_update_login := l_cs_contracts_billing_pk.last_update_login;
      END IF;
      IF (x_contractbilling_rec.trx_pre_tax_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.trx_pre_tax_amount := l_cs_contracts_billing_pk.trx_pre_tax_amount;
      END IF;
      IF (x_contractbilling_rec.attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute1 := l_cs_contracts_billing_pk.attribute1;
      END IF;
      IF (x_contractbilling_rec.attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute2 := l_cs_contracts_billing_pk.attribute2;
      END IF;
      IF (x_contractbilling_rec.attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute3 := l_cs_contracts_billing_pk.attribute3;
      END IF;
      IF (x_contractbilling_rec.attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute4 := l_cs_contracts_billing_pk.attribute4;
      END IF;
      IF (x_contractbilling_rec.attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute5 := l_cs_contracts_billing_pk.attribute5;
      END IF;
      IF (x_contractbilling_rec.attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute6 := l_cs_contracts_billing_pk.attribute6;
      END IF;
      IF (x_contractbilling_rec.attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute7 := l_cs_contracts_billing_pk.attribute7;
      END IF;
      IF (x_contractbilling_rec.attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute8 := l_cs_contracts_billing_pk.attribute8;
      END IF;
      IF (x_contractbilling_rec.attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute9 := l_cs_contracts_billing_pk.attribute9;
      END IF;
      IF (x_contractbilling_rec.attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute10 := l_cs_contracts_billing_pk.attribute10;
      END IF;
      IF (x_contractbilling_rec.attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute11 := l_cs_contracts_billing_pk.attribute11;
      END IF;
      IF (x_contractbilling_rec.attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute12 := l_cs_contracts_billing_pk.attribute12;
      END IF;
      IF (x_contractbilling_rec.attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute13 := l_cs_contracts_billing_pk.attribute13;
      END IF;
      IF (x_contractbilling_rec.attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute14 := l_cs_contracts_billing_pk.attribute14;
      END IF;
      IF (x_contractbilling_rec.attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.attribute15 := l_cs_contracts_billing_pk.attribute15;
      END IF;
      IF (x_contractbilling_rec.context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contractbilling_rec.context := l_cs_contracts_billing_pk.context;
      END IF;
      IF (x_contractbilling_rec.object_version_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contractbilling_rec.object_version_number := l_cs_contracts_billing_pk.object_version_number;
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
    migrate(p_contractbilling_val_rec, l_contractbilling_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_contractbilling_rec,    ---- IN
      l_def_contractbilling_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_contractbilling_rec, l_def_contractbilling_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_contractbilling_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contractbilling_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_CONTRACTS_BILLING
    SET
        CONTRACT_BILLING_ID = l_def_contractbilling_rec.contract_billing_id ,
        HEADER_ID = l_def_contractbilling_rec.header_id ,
        ORDER_NUMBER = l_def_contractbilling_rec.order_number ,
        LINE_ID = l_def_contractbilling_rec.line_id ,
        CP_SERVICE_ID = l_def_contractbilling_rec.cp_service_id ,
        CONTRACT_ID = l_def_contractbilling_rec.contract_id ,
        CUST_TRX_TYPE_ID = l_def_contractbilling_rec.cust_trx_type_id ,
        TRX_DATE = l_def_contractbilling_rec.trx_date ,
        TRX_NUMBER = l_def_contractbilling_rec.trx_number ,
        TRX_AMOUNT = l_def_contractbilling_rec.trx_amount ,
        TRX_CLASS = l_def_contractbilling_rec.trx_class ,
        BILLED_UNTIL_DATE = l_def_contractbilling_rec.billed_until_date ,
        CURRENCY_CODE = l_def_contractbilling_rec.currency_code ,
        LAST_UPDATE_DATE = l_def_contractbilling_rec.last_update_date ,
        LAST_UPDATED_BY = l_def_contractbilling_rec.last_updated_by ,
        CREATION_DATE = l_def_contractbilling_rec.creation_date ,
        CREATED_BY = l_def_contractbilling_rec.created_by ,
        LAST_UPDATE_LOGIN = l_def_contractbilling_rec.last_update_login ,
        TRX_PRE_TAX_AMOUNT = l_def_contractbilling_rec.trx_pre_tax_amount ,
        ATTRIBUTE1 = l_def_contractbilling_rec.attribute1 ,
        ATTRIBUTE2 = l_def_contractbilling_rec.attribute2 ,
        ATTRIBUTE3 = l_def_contractbilling_rec.attribute3 ,
        ATTRIBUTE4 = l_def_contractbilling_rec.attribute4 ,
        ATTRIBUTE5 = l_def_contractbilling_rec.attribute5 ,
        ATTRIBUTE6 = l_def_contractbilling_rec.attribute6 ,
        ATTRIBUTE7 = l_def_contractbilling_rec.attribute7 ,
        ATTRIBUTE8 = l_def_contractbilling_rec.attribute8 ,
        ATTRIBUTE9 = l_def_contractbilling_rec.attribute9 ,
        ATTRIBUTE10 = l_def_contractbilling_rec.attribute10 ,
        ATTRIBUTE11 = l_def_contractbilling_rec.attribute11 ,
        ATTRIBUTE12 = l_def_contractbilling_rec.attribute12 ,
        ATTRIBUTE13 = l_def_contractbilling_rec.attribute13 ,
        ATTRIBUTE14 = l_def_contractbilling_rec.attribute14 ,
        ATTRIBUTE15 = l_def_contractbilling_rec.attribute15 ,
        CONTEXT = l_def_contractbilling_rec.context ,
        OBJECT_VERSION_NUMBER = l_def_contractbilling_rec.object_version_number
        WHERE
          CONTRACT_BILLING_ID = l_def_contractbilling_rec.contract_billing_id
          ;
    x_object_version_number := l_def_contractbilling_rec.OBJECT_VERSION_NUMBER;
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
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contractbilling_rec          ContractBilling_Val_Rec_Type;
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
    l_contractbilling_rec.CONTRACT_BILLING_ID := p_contract_billing_id;
    l_contractbilling_rec.HEADER_ID := p_header_id;
    l_contractbilling_rec.ORDER_NUMBER := p_order_number;
    l_contractbilling_rec.LINE_ID := p_line_id;
    l_contractbilling_rec.CP_SERVICE_ID := p_cp_service_id;
    l_contractbilling_rec.CONTRACT_ID := p_contract_id;
    l_contractbilling_rec.CUST_TRX_TYPE_ID := p_cust_trx_type_id;
    l_contractbilling_rec.TRX_DATE := p_trx_date;
    l_contractbilling_rec.TRX_NUMBER := p_trx_number;
    l_contractbilling_rec.TRX_AMOUNT := p_trx_amount;
    l_contractbilling_rec.TRX_CLASS := p_trx_class;
    l_contractbilling_rec.BILLED_UNTIL_DATE := p_billed_until_date;
    l_contractbilling_rec.CURRENCY_CODE := p_currency_code;
    l_contractbilling_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_contractbilling_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_contractbilling_rec.CREATION_DATE := p_creation_date;
    l_contractbilling_rec.CREATED_BY := p_created_by;
    l_contractbilling_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_contractbilling_rec.TRX_PRE_TAX_AMOUNT := p_trx_pre_tax_amount;
    l_contractbilling_rec.ATTRIBUTE1 := p_attribute1;
    l_contractbilling_rec.ATTRIBUTE2 := p_attribute2;
    l_contractbilling_rec.ATTRIBUTE3 := p_attribute3;
    l_contractbilling_rec.ATTRIBUTE4 := p_attribute4;
    l_contractbilling_rec.ATTRIBUTE5 := p_attribute5;
    l_contractbilling_rec.ATTRIBUTE6 := p_attribute6;
    l_contractbilling_rec.ATTRIBUTE7 := p_attribute7;
    l_contractbilling_rec.ATTRIBUTE8 := p_attribute8;
    l_contractbilling_rec.ATTRIBUTE9 := p_attribute9;
    l_contractbilling_rec.ATTRIBUTE10 := p_attribute10;
    l_contractbilling_rec.ATTRIBUTE11 := p_attribute11;
    l_contractbilling_rec.ATTRIBUTE12 := p_attribute12;
    l_contractbilling_rec.ATTRIBUTE13 := p_attribute13;
    l_contractbilling_rec.ATTRIBUTE14 := p_attribute14;
    l_contractbilling_rec.ATTRIBUTE15 := p_attribute15;
    l_contractbilling_rec.CONTEXT := p_context;
    l_contractbilling_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contractbilling_rec,
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
    p_contract_billing_id          IN NUMBER) IS
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
    DELETE  FROM CS_CONTRACTS_BILLING
    WHERE
      CONTRACT_BILLING_ID = p_contract_billing_id
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
    p_contractbilling_val_rec      IN ContractBilling_Val_Rec_Type := G_MISS_CONTRACTBILLING_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contractbilling_rec          ContractBilling_Rec_Type;
    l_def_contractbilling_rec      ContractBilling_Rec_Type;
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
    migrate(p_contractbilling_val_rec, l_contractbilling_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_contractbilling_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contractbilling_rec);
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
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contractbilling_rec          ContractBilling_Val_Rec_Type;
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
    l_contractbilling_rec.CONTRACT_BILLING_ID := p_contract_billing_id;
    l_contractbilling_rec.HEADER_ID := p_header_id;
    l_contractbilling_rec.ORDER_NUMBER := p_order_number;
    l_contractbilling_rec.LINE_ID := p_line_id;
    l_contractbilling_rec.CP_SERVICE_ID := p_cp_service_id;
    l_contractbilling_rec.CONTRACT_ID := p_contract_id;
    l_contractbilling_rec.CUST_TRX_TYPE_ID := p_cust_trx_type_id;
    l_contractbilling_rec.TRX_DATE := p_trx_date;
    l_contractbilling_rec.TRX_NUMBER := p_trx_number;
    l_contractbilling_rec.TRX_AMOUNT := p_trx_amount;
    l_contractbilling_rec.TRX_CLASS := p_trx_class;
    l_contractbilling_rec.BILLED_UNTIL_DATE := p_billed_until_date;
    l_contractbilling_rec.CURRENCY_CODE := p_currency_code;
    l_contractbilling_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_contractbilling_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_contractbilling_rec.CREATION_DATE := p_creation_date;
    l_contractbilling_rec.CREATED_BY := p_created_by;
    l_contractbilling_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_contractbilling_rec.TRX_PRE_TAX_AMOUNT := p_trx_pre_tax_amount;
    l_contractbilling_rec.ATTRIBUTE1 := p_attribute1;
    l_contractbilling_rec.ATTRIBUTE2 := p_attribute2;
    l_contractbilling_rec.ATTRIBUTE3 := p_attribute3;
    l_contractbilling_rec.ATTRIBUTE4 := p_attribute4;
    l_contractbilling_rec.ATTRIBUTE5 := p_attribute5;
    l_contractbilling_rec.ATTRIBUTE6 := p_attribute6;
    l_contractbilling_rec.ATTRIBUTE7 := p_attribute7;
    l_contractbilling_rec.ATTRIBUTE8 := p_attribute8;
    l_contractbilling_rec.ATTRIBUTE9 := p_attribute9;
    l_contractbilling_rec.ATTRIBUTE10 := p_attribute10;
    l_contractbilling_rec.ATTRIBUTE11 := p_attribute11;
    l_contractbilling_rec.ATTRIBUTE12 := p_attribute12;
    l_contractbilling_rec.ATTRIBUTE13 := p_attribute13;
    l_contractbilling_rec.ATTRIBUTE14 := p_attribute14;
    l_contractbilling_rec.ATTRIBUTE15 := p_attribute15;
    l_contractbilling_rec.CONTEXT := p_context;
    l_contractbilling_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contractbilling_rec
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
END CS_CONTRACTBILLING_PVT;

/

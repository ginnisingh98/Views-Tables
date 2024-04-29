--------------------------------------------------------
--  DDL for Package Body CS_SERVICETRAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICETRAN_PVT" AS
/* $Header: csctstrb.pls 115.1 99/07/16 08:54:31 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_CP_SERVICE_TRANSACTIONS_S.nextval FROM SYS.DUAL;
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
    p_servicetran_rec IN  ServiceTran_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_servicetran_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE OR
       p_servicetran_rec.last_update_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_servicetran_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_servicetran_rec.last_updated_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_servicetran_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_servicetran_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_servicetran_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_servicetran_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_servicetran_rec.cp_service_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_servicetran_rec.cp_service_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cp_service_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_servicetran_rec.transaction_type_code = TAPI_DEV_KIT.G_MISS_CHAR OR
          p_servicetran_rec.transaction_type_code IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'transaction_type_code');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_servicetran_rec.resulting_status_code = TAPI_DEV_KIT.G_MISS_CHAR OR
          p_servicetran_rec.resulting_status_code IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'resulting_status_code');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_servicetran_rec IN  ServiceTran_Rec_Type,
    l_def_servicetran_rec OUT  ServiceTran_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_servicetran_rec := p_servicetran_rec;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_servicetran_rec IN ServiceTran_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    FUNCTION validate_foreign_keys (
      p_servicetran_rec IN ServiceTran_Rec_Type
    )
    RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR cs_cp_services_all_pk_csr (p_cp_service_id      IN NUMBER) IS
      SELECT *
        FROM Cs_Cp_Services_All
       WHERE cs_cp_services_all.cp_service_id = p_cp_service_id;
      l_cs_cp_services_all_pk        cs_cp_services_all_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_servicetran_rec.CP_SERVICE_ID IS NOT NULL)
      THEN
        OPEN cs_cp_services_all_pk_csr(p_servicetran_rec.CP_SERVICE_ID);
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
    l_return_status := validate_foreign_keys (p_servicetran_rec);
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN ServiceTran_Val_Rec_Type,
    p_to	OUT ServiceTran_Rec_Type
  ) IS
  BEGIN
    p_to.cp_service_transaction_id := p_from.cp_service_transaction_id;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.transaction_type_code := p_from.transaction_type_code;
    p_to.resulting_status_code := p_from.resulting_status_code;
    p_to.effective_start_date := p_from.effective_start_date;
    p_to.effective_end_date := p_from.effective_end_date;
    p_to.current_end_date := p_from.current_end_date;
    p_to.terminated_transaction_id := p_from.terminated_transaction_id;
    p_to.reason_code := p_from.reason_code;
    p_to.reason_comments := p_from.reason_comments;
    p_to.service_selling_price := p_from.service_selling_price;
    p_to.currency_code := p_from.currency_code;
    p_to.conversion_type := p_from.conversion_type;
    p_to.conversion_rate := p_from.conversion_rate;
    p_to.conversion_date := p_from.conversion_date;
    p_to.invoicing_rule_id := p_from.invoicing_rule_id;
    p_to.accounting_rule_id := p_from.accounting_rule_id;
    p_to.payment_terms_id := p_from.payment_terms_id;
    p_to.service_order_line_id := p_from.service_order_line_id;
    p_to.service_order_number := p_from.service_order_number;
    p_to.service_order_date := p_from.service_order_date;
    p_to.service_order_type := p_from.service_order_type;
    p_to.invoice_flag := p_from.invoice_flag;
    p_to.coverage_schedule_id := p_from.coverage_schedule_id;
    p_to.duration_quantity := p_from.duration_quantity;
    p_to.unit_of_measure_code := p_from.unit_of_measure_code;
    p_to.starting_delay := p_from.starting_delay;
    p_to.bill_to_site_use_id := p_from.bill_to_site_use_id;
    p_to.bill_to_contact_id := p_from.bill_to_contact_id;
    p_to.prorate_flag := p_from.prorate_flag;
    p_to.ra_interface_status := p_from.ra_interface_status;
    p_to.invoice_count := p_from.invoice_count;
    p_to.price_list_id := p_from.price_list_id;
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
    p_to.pricing_attribute1 := p_from.pricing_attribute1;
    p_to.pricing_attribute2 := p_from.pricing_attribute2;
    p_to.pricing_attribute3 := p_from.pricing_attribute3;
    p_to.pricing_attribute4 := p_from.pricing_attribute4;
    p_to.pricing_attribute5 := p_from.pricing_attribute5;
    p_to.pricing_attribute6 := p_from.pricing_attribute6;
    p_to.pricing_attribute7 := p_from.pricing_attribute7;
    p_to.pricing_attribute8 := p_from.pricing_attribute8;
    p_to.pricing_attribute9 := p_from.pricing_attribute9;
    p_to.pricing_attribute10 := p_from.pricing_attribute10;
    p_to.pricing_attribute11 := p_from.pricing_attribute11;
    p_to.pricing_attribute12 := p_from.pricing_attribute12;
    p_to.pricing_attribute13 := p_from.pricing_attribute13;
    p_to.pricing_attribute14 := p_from.pricing_attribute14;
    p_to.pricing_attribute15 := p_from.pricing_attribute15;
    p_to.pricing_context := p_from.pricing_context;
    p_to.credit_amount := p_from.credit_amount;
    p_to.purchase_order_num := p_from.purchase_order_num;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ServiceTran_Rec_Type,
    p_to	OUT ServiceTran_Val_Rec_Type
  ) IS
  BEGIN
    p_to.cp_service_transaction_id := p_from.cp_service_transaction_id;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.transaction_type_code := p_from.transaction_type_code;
    p_to.resulting_status_code := p_from.resulting_status_code;
    p_to.effective_start_date := p_from.effective_start_date;
    p_to.effective_end_date := p_from.effective_end_date;
    p_to.current_end_date := p_from.current_end_date;
    p_to.terminated_transaction_id := p_from.terminated_transaction_id;
    p_to.reason_code := p_from.reason_code;
    p_to.reason_comments := p_from.reason_comments;
    p_to.service_selling_price := p_from.service_selling_price;
    p_to.currency_code := p_from.currency_code;
    p_to.conversion_type := p_from.conversion_type;
    p_to.conversion_rate := p_from.conversion_rate;
    p_to.conversion_date := p_from.conversion_date;
    p_to.invoicing_rule_id := p_from.invoicing_rule_id;
    p_to.accounting_rule_id := p_from.accounting_rule_id;
    p_to.payment_terms_id := p_from.payment_terms_id;
    p_to.service_order_line_id := p_from.service_order_line_id;
    p_to.service_order_number := p_from.service_order_number;
    p_to.service_order_date := p_from.service_order_date;
    p_to.service_order_type := p_from.service_order_type;
    p_to.invoice_flag := p_from.invoice_flag;
    p_to.coverage_schedule_id := p_from.coverage_schedule_id;
    p_to.duration_quantity := p_from.duration_quantity;
    p_to.unit_of_measure_code := p_from.unit_of_measure_code;
    p_to.starting_delay := p_from.starting_delay;
    p_to.bill_to_site_use_id := p_from.bill_to_site_use_id;
    p_to.bill_to_contact_id := p_from.bill_to_contact_id;
    p_to.prorate_flag := p_from.prorate_flag;
    p_to.ra_interface_status := p_from.ra_interface_status;
    p_to.invoice_count := p_from.invoice_count;
    p_to.price_list_id := p_from.price_list_id;
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
    p_to.pricing_attribute1 := p_from.pricing_attribute1;
    p_to.pricing_attribute2 := p_from.pricing_attribute2;
    p_to.pricing_attribute3 := p_from.pricing_attribute3;
    p_to.pricing_attribute4 := p_from.pricing_attribute4;
    p_to.pricing_attribute5 := p_from.pricing_attribute5;
    p_to.pricing_attribute6 := p_from.pricing_attribute6;
    p_to.pricing_attribute7 := p_from.pricing_attribute7;
    p_to.pricing_attribute8 := p_from.pricing_attribute8;
    p_to.pricing_attribute9 := p_from.pricing_attribute9;
    p_to.pricing_attribute10 := p_from.pricing_attribute10;
    p_to.pricing_attribute11 := p_from.pricing_attribute11;
    p_to.pricing_attribute12 := p_from.pricing_attribute12;
    p_to.pricing_attribute13 := p_from.pricing_attribute13;
    p_to.pricing_attribute14 := p_from.pricing_attribute14;
    p_to.pricing_attribute15 := p_from.pricing_attribute15;
    p_to.pricing_context := p_from.pricing_context;
    p_to.credit_amount := p_from.credit_amount;
    p_to.purchase_order_num := p_from.purchase_order_num;
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
    p_servicetran_rec              IN ServiceTran_Rec_Type := G_MISS_SERVICETRAN_REC,
    x_cp_service_transaction_id    OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_servicetran_rec              ServiceTran_Rec_Type;
    l_def_servicetran_rec          ServiceTran_Rec_Type;
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
    l_servicetran_rec := p_servicetran_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_servicetran_rec    ---- IN
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
      l_servicetran_rec,    ---- IN
      l_def_servicetran_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_servicetran_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_servicetran_rec.cp_service_transaction_id := get_seq_id;
    INSERT INTO CS_CP_SERVICE_TRANSACTIONS(
        cp_service_transaction_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        cp_service_id,
        transaction_type_code,
        resulting_status_code,
        effective_start_date,
        effective_end_date,
        current_end_date,
        terminated_transaction_id,
        reason_code,
        reason_comments,
        service_selling_price,
        currency_code,
        conversion_type,
        conversion_rate,
        conversion_date,
        invoicing_rule_id,
        accounting_rule_id,
        payment_terms_id,
        service_order_line_id,
        service_order_number,
        service_order_date,
        service_order_type,
        invoice_flag,
        coverage_schedule_id,
        duration_quantity,
        unit_of_measure_code,
        starting_delay,
        bill_to_site_use_id,
        bill_to_contact_id,
        prorate_flag,
        ra_interface_status,
        invoice_count,
        price_list_id,
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
        pricing_attribute1,
        pricing_attribute2,
        pricing_attribute3,
        pricing_attribute4,
        pricing_attribute5,
        pricing_attribute6,
        pricing_attribute7,
        pricing_attribute8,
        pricing_attribute9,
        pricing_attribute10,
        pricing_attribute11,
        pricing_attribute12,
        pricing_attribute13,
        pricing_attribute14,
        pricing_attribute15,
        pricing_context,
        credit_amount,
        purchase_order_num)
      VALUES (
        l_def_servicetran_rec.cp_service_transaction_id,
        l_def_servicetran_rec.last_update_date,
        l_def_servicetran_rec.last_updated_by,
        l_def_servicetran_rec.creation_date,
        l_def_servicetran_rec.created_by,
        l_def_servicetran_rec.last_update_login,
        l_def_servicetran_rec.cp_service_id,
        l_def_servicetran_rec.transaction_type_code,
        l_def_servicetran_rec.resulting_status_code,
        l_def_servicetran_rec.effective_start_date,
        l_def_servicetran_rec.effective_end_date,
        l_def_servicetran_rec.current_end_date,
        l_def_servicetran_rec.terminated_transaction_id,
        l_def_servicetran_rec.reason_code,
        l_def_servicetran_rec.reason_comments,
        l_def_servicetran_rec.service_selling_price,
        l_def_servicetran_rec.currency_code,
        l_def_servicetran_rec.conversion_type,
        l_def_servicetran_rec.conversion_rate,
        l_def_servicetran_rec.conversion_date,
        l_def_servicetran_rec.invoicing_rule_id,
        l_def_servicetran_rec.accounting_rule_id,
        l_def_servicetran_rec.payment_terms_id,
        l_def_servicetran_rec.service_order_line_id,
        l_def_servicetran_rec.service_order_number,
        l_def_servicetran_rec.service_order_date,
        l_def_servicetran_rec.service_order_type,
        l_def_servicetran_rec.invoice_flag,
        l_def_servicetran_rec.coverage_schedule_id,
        l_def_servicetran_rec.duration_quantity,
        l_def_servicetran_rec.unit_of_measure_code,
        l_def_servicetran_rec.starting_delay,
        l_def_servicetran_rec.bill_to_site_use_id,
        l_def_servicetran_rec.bill_to_contact_id,
        l_def_servicetran_rec.prorate_flag,
        l_def_servicetran_rec.ra_interface_status,
        l_def_servicetran_rec.invoice_count,
        l_def_servicetran_rec.price_list_id,
        l_def_servicetran_rec.attribute1,
        l_def_servicetran_rec.attribute2,
        l_def_servicetran_rec.attribute3,
        l_def_servicetran_rec.attribute4,
        l_def_servicetran_rec.attribute5,
        l_def_servicetran_rec.attribute6,
        l_def_servicetran_rec.attribute7,
        l_def_servicetran_rec.attribute8,
        l_def_servicetran_rec.attribute9,
        l_def_servicetran_rec.attribute10,
        l_def_servicetran_rec.attribute11,
        l_def_servicetran_rec.attribute12,
        l_def_servicetran_rec.attribute13,
        l_def_servicetran_rec.attribute14,
        l_def_servicetran_rec.attribute15,
        l_def_servicetran_rec.context,
        l_def_servicetran_rec.pricing_attribute1,
        l_def_servicetran_rec.pricing_attribute2,
        l_def_servicetran_rec.pricing_attribute3,
        l_def_servicetran_rec.pricing_attribute4,
        l_def_servicetran_rec.pricing_attribute5,
        l_def_servicetran_rec.pricing_attribute6,
        l_def_servicetran_rec.pricing_attribute7,
        l_def_servicetran_rec.pricing_attribute8,
        l_def_servicetran_rec.pricing_attribute9,
        l_def_servicetran_rec.pricing_attribute10,
        l_def_servicetran_rec.pricing_attribute11,
        l_def_servicetran_rec.pricing_attribute12,
        l_def_servicetran_rec.pricing_attribute13,
        l_def_servicetran_rec.pricing_attribute14,
        l_def_servicetran_rec.pricing_attribute15,
        l_def_servicetran_rec.pricing_context,
        l_def_servicetran_rec.credit_amount,
        l_def_servicetran_rec.purchase_order_num);
    -- Set OUT values
    x_cp_service_transaction_id := l_def_servicetran_rec.cp_service_transaction_id;
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
    p_last_update_date             IN CS_CP_SERVICE_TRANSACTIONS.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_CP_SERVICE_TRANSACTIONS.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_cp_service_id                IN NUMBER := NULL,
    p_transaction_type_code        IN CS_CP_SERVICE_TRANSACTIONS.TRANSACTION_TYPE_CODE%TYPE := NULL,
    p_resulting_status_code        IN CS_CP_SERVICE_TRANSACTIONS.RESULTING_STATUS_CODE%TYPE := NULL,
    p_effective_start_date         IN CS_CP_SERVICE_TRANSACTIONS.EFFECTIVE_START_DATE%TYPE := NULL,
    p_effective_end_date           IN CS_CP_SERVICE_TRANSACTIONS.EFFECTIVE_END_DATE%TYPE := NULL,
    p_current_end_date             IN CS_CP_SERVICE_TRANSACTIONS.CURRENT_END_DATE%TYPE := NULL,
    p_terminated_transaction_id    IN NUMBER := NULL,
    p_reason_code                  IN CS_CP_SERVICE_TRANSACTIONS.REASON_CODE%TYPE := NULL,
    p_reason_comments              IN CS_CP_SERVICE_TRANSACTIONS.REASON_COMMENTS%TYPE := NULL,
    p_service_selling_price        IN NUMBER := NULL,
    p_currency_code                IN CS_CP_SERVICE_TRANSACTIONS.CURRENCY_CODE%TYPE := NULL,
    p_conversion_type              IN CS_CP_SERVICE_TRANSACTIONS.CONVERSION_TYPE%TYPE := NULL,
    p_conversion_rate              IN NUMBER := NULL,
    p_conversion_date              IN CS_CP_SERVICE_TRANSACTIONS.CONVERSION_DATE%TYPE := NULL,
    p_invoicing_rule_id            IN NUMBER := NULL,
    p_accounting_rule_id           IN NUMBER := NULL,
    p_payment_terms_id             IN NUMBER := NULL,
    p_service_order_line_id        IN NUMBER := NULL,
    p_service_order_number         IN NUMBER := NULL,
    p_service_order_date           IN CS_CP_SERVICE_TRANSACTIONS.SERVICE_ORDER_DATE%TYPE := NULL,
    p_service_order_type           IN CS_CP_SERVICE_TRANSACTIONS.SERVICE_ORDER_TYPE%TYPE := NULL,
    p_invoice_flag                 IN CS_CP_SERVICE_TRANSACTIONS.INVOICE_FLAG%TYPE := NULL,
    p_coverage_schedule_id         IN NUMBER := NULL,
    p_duration_quantity            IN NUMBER := NULL,
    p_unit_of_measure_code         IN CS_CP_SERVICE_TRANSACTIONS.UNIT_OF_MEASURE_CODE%TYPE := NULL,
    p_starting_delay               IN NUMBER := NULL,
    p_bill_to_site_use_id          IN NUMBER := NULL,
    p_bill_to_contact_id           IN NUMBER := NULL,
    p_prorate_flag                 IN CS_CP_SERVICE_TRANSACTIONS.PRORATE_FLAG%TYPE := NULL,
    p_ra_interface_status          IN CS_CP_SERVICE_TRANSACTIONS.RA_INTERFACE_STATUS%TYPE := NULL,
    p_invoice_count                IN NUMBER := NULL,
    p_price_list_id                IN NUMBER := NULL,
    p_attribute1                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_CP_SERVICE_TRANSACTIONS.CONTEXT%TYPE := NULL,
    p_pricing_attribute1           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE1%TYPE := NULL,
    p_pricing_attribute2           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE2%TYPE := NULL,
    p_pricing_attribute3           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE3%TYPE := NULL,
    p_pricing_attribute4           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE4%TYPE := NULL,
    p_pricing_attribute5           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE5%TYPE := NULL,
    p_pricing_attribute6           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE6%TYPE := NULL,
    p_pricing_attribute7           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE7%TYPE := NULL,
    p_pricing_attribute8           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE8%TYPE := NULL,
    p_pricing_attribute9           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE9%TYPE := NULL,
    p_pricing_attribute10          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE10%TYPE := NULL,
    p_pricing_attribute11          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE11%TYPE := NULL,
    p_pricing_attribute12          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE12%TYPE := NULL,
    p_pricing_attribute13          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE13%TYPE := NULL,
    p_pricing_attribute14          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE14%TYPE := NULL,
    p_pricing_attribute15          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE15%TYPE := NULL,
    p_pricing_context              IN CS_CP_SERVICE_TRANSACTIONS.PRICING_CONTEXT%TYPE := NULL,
    p_credit_amount                IN NUMBER := NULL,
    p_purchase_order_num           IN CS_CP_SERVICE_TRANSACTIONS.PURCHASE_ORDER_NUM%TYPE := NULL,
    x_cp_service_transaction_id    OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_servicetran_rec              ServiceTran_Rec_Type;
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
    l_servicetran_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_servicetran_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_servicetran_rec.CREATION_DATE := p_creation_date;
    l_servicetran_rec.CREATED_BY := p_created_by;
    l_servicetran_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_servicetran_rec.CP_SERVICE_ID := p_cp_service_id;
    l_servicetran_rec.TRANSACTION_TYPE_CODE := p_transaction_type_code;
    l_servicetran_rec.RESULTING_STATUS_CODE := p_resulting_status_code;
    l_servicetran_rec.EFFECTIVE_START_DATE := p_effective_start_date;
    l_servicetran_rec.EFFECTIVE_END_DATE := p_effective_end_date;
    l_servicetran_rec.CURRENT_END_DATE := p_current_end_date;
    l_servicetran_rec.TERMINATED_TRANSACTION_ID := p_terminated_transaction_id;
    l_servicetran_rec.REASON_CODE := p_reason_code;
    l_servicetran_rec.REASON_COMMENTS := p_reason_comments;
    l_servicetran_rec.SERVICE_SELLING_PRICE := p_service_selling_price;
    l_servicetran_rec.CURRENCY_CODE := p_currency_code;
    l_servicetran_rec.CONVERSION_TYPE := p_conversion_type;
    l_servicetran_rec.CONVERSION_RATE := p_conversion_rate;
    l_servicetran_rec.CONVERSION_DATE := p_conversion_date;
    l_servicetran_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
    l_servicetran_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
    l_servicetran_rec.PAYMENT_TERMS_ID := p_payment_terms_id;
    l_servicetran_rec.SERVICE_ORDER_LINE_ID := p_service_order_line_id;
    l_servicetran_rec.SERVICE_ORDER_NUMBER := p_service_order_number;
    l_servicetran_rec.SERVICE_ORDER_DATE := p_service_order_date;
    l_servicetran_rec.SERVICE_ORDER_TYPE := p_service_order_type;
    l_servicetran_rec.INVOICE_FLAG := p_invoice_flag;
    l_servicetran_rec.COVERAGE_SCHEDULE_ID := p_coverage_schedule_id;
    l_servicetran_rec.DURATION_QUANTITY := p_duration_quantity;
    l_servicetran_rec.UNIT_OF_MEASURE_CODE := p_unit_of_measure_code;
    l_servicetran_rec.STARTING_DELAY := p_starting_delay;
    l_servicetran_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
    l_servicetran_rec.BILL_TO_CONTACT_ID := p_bill_to_contact_id;
    l_servicetran_rec.PRORATE_FLAG := p_prorate_flag;
    l_servicetran_rec.RA_INTERFACE_STATUS := p_ra_interface_status;
    l_servicetran_rec.INVOICE_COUNT := p_invoice_count;
    l_servicetran_rec.PRICE_LIST_ID := p_price_list_id;
    l_servicetran_rec.ATTRIBUTE1 := p_attribute1;
    l_servicetran_rec.ATTRIBUTE2 := p_attribute2;
    l_servicetran_rec.ATTRIBUTE3 := p_attribute3;
    l_servicetran_rec.ATTRIBUTE4 := p_attribute4;
    l_servicetran_rec.ATTRIBUTE5 := p_attribute5;
    l_servicetran_rec.ATTRIBUTE6 := p_attribute6;
    l_servicetran_rec.ATTRIBUTE7 := p_attribute7;
    l_servicetran_rec.ATTRIBUTE8 := p_attribute8;
    l_servicetran_rec.ATTRIBUTE9 := p_attribute9;
    l_servicetran_rec.ATTRIBUTE10 := p_attribute10;
    l_servicetran_rec.ATTRIBUTE11 := p_attribute11;
    l_servicetran_rec.ATTRIBUTE12 := p_attribute12;
    l_servicetran_rec.ATTRIBUTE13 := p_attribute13;
    l_servicetran_rec.ATTRIBUTE14 := p_attribute14;
    l_servicetran_rec.ATTRIBUTE15 := p_attribute15;
    l_servicetran_rec.CONTEXT := p_context;
    l_servicetran_rec.PRICING_ATTRIBUTE1 := p_pricing_attribute1;
    l_servicetran_rec.PRICING_ATTRIBUTE2 := p_pricing_attribute2;
    l_servicetran_rec.PRICING_ATTRIBUTE3 := p_pricing_attribute3;
    l_servicetran_rec.PRICING_ATTRIBUTE4 := p_pricing_attribute4;
    l_servicetran_rec.PRICING_ATTRIBUTE5 := p_pricing_attribute5;
    l_servicetran_rec.PRICING_ATTRIBUTE6 := p_pricing_attribute6;
    l_servicetran_rec.PRICING_ATTRIBUTE7 := p_pricing_attribute7;
    l_servicetran_rec.PRICING_ATTRIBUTE8 := p_pricing_attribute8;
    l_servicetran_rec.PRICING_ATTRIBUTE9 := p_pricing_attribute9;
    l_servicetran_rec.PRICING_ATTRIBUTE10 := p_pricing_attribute10;
    l_servicetran_rec.PRICING_ATTRIBUTE11 := p_pricing_attribute11;
    l_servicetran_rec.PRICING_ATTRIBUTE12 := p_pricing_attribute12;
    l_servicetran_rec.PRICING_ATTRIBUTE13 := p_pricing_attribute13;
    l_servicetran_rec.PRICING_ATTRIBUTE14 := p_pricing_attribute14;
    l_servicetran_rec.PRICING_ATTRIBUTE15 := p_pricing_attribute15;
    l_servicetran_rec.PRICING_CONTEXT := p_pricing_context;
    l_servicetran_rec.CREDIT_AMOUNT := p_credit_amount;
    l_servicetran_rec.PURCHASE_ORDER_NUM := p_purchase_order_num;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_servicetran_rec,
      x_cp_service_transaction_id
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
    p_cp_service_transaction_id    IN NUMBER,
    p_last_update_date             IN DATE,
    p_last_updated_by              IN NUMBER,
    p_creation_date                IN DATE,
    p_created_by                   IN NUMBER,
    p_last_update_login            IN NUMBER,
    p_cp_service_id                IN NUMBER,
    p_transaction_type_code        IN VARCHAR2,
    p_resulting_status_code        IN VARCHAR2,
    p_effective_start_date         IN DATE,
    p_effective_end_date           IN DATE,
    p_current_end_date             IN DATE,
    p_terminated_transaction_id    IN NUMBER,
    p_reason_code                  IN VARCHAR2,
    p_reason_comments              IN VARCHAR2,
    p_service_selling_price        IN NUMBER,
    p_currency_code                IN VARCHAR2,
    p_conversion_type              IN VARCHAR2,
    p_conversion_rate              IN NUMBER,
    p_conversion_date              IN DATE,
    p_invoicing_rule_id            IN NUMBER,
    p_accounting_rule_id           IN NUMBER,
    p_payment_terms_id             IN NUMBER,
    p_service_order_line_id        IN NUMBER,
    p_service_order_number         IN NUMBER,
    p_service_order_date           IN DATE,
    p_service_order_type           IN VARCHAR2,
    p_invoice_flag                 IN VARCHAR2,
    p_coverage_schedule_id         IN NUMBER,
    p_duration_quantity            IN NUMBER,
    p_unit_of_measure_code         IN VARCHAR2,
    p_starting_delay               IN NUMBER,
    p_bill_to_site_use_id          IN NUMBER,
    p_bill_to_contact_id           IN NUMBER,
    p_prorate_flag                 IN VARCHAR2,
    p_ra_interface_status          IN VARCHAR2,
    p_invoice_count                IN NUMBER,
    p_price_list_id                IN NUMBER,
    p_attribute1                   IN VARCHAR2,
    p_attribute2                   IN VARCHAR2,
    p_attribute3                   IN VARCHAR2,
    p_attribute4                   IN VARCHAR2,
    p_attribute5                   IN VARCHAR2,
    p_attribute6                   IN VARCHAR2,
    p_attribute7                   IN VARCHAR2,
    p_attribute8                   IN VARCHAR2,
    p_attribute9                   IN VARCHAR2,
    p_attribute10                  IN VARCHAR2,
    p_attribute11                  IN VARCHAR2,
    p_attribute12                  IN VARCHAR2,
    p_attribute13                  IN VARCHAR2,
    p_attribute14                  IN VARCHAR2,
    p_attribute15                  IN VARCHAR2,
    p_context                      IN VARCHAR2,
    p_pricing_attribute1           IN VARCHAR2,
    p_pricing_attribute2           IN VARCHAR2,
    p_pricing_attribute3           IN VARCHAR2,
    p_pricing_attribute4           IN VARCHAR2,
    p_pricing_attribute5           IN VARCHAR2,
    p_pricing_attribute6           IN VARCHAR2,
    p_pricing_attribute7           IN VARCHAR2,
    p_pricing_attribute8           IN VARCHAR2,
    p_pricing_attribute9           IN VARCHAR2,
    p_pricing_attribute10          IN VARCHAR2,
    p_pricing_attribute11          IN VARCHAR2,
    p_pricing_attribute12          IN VARCHAR2,
    p_pricing_attribute13          IN VARCHAR2,
    p_pricing_attribute14          IN VARCHAR2,
    p_pricing_attribute15          IN VARCHAR2,
    p_pricing_context              IN VARCHAR2,
    p_credit_amount                IN NUMBER,
    p_purchase_order_num           IN VARCHAR2) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT *
     FROM CS_CP_SERVICE_TRANSACTIONS
    WHERE
      CP_SERVICE_TRANSACTION_ID = p_cp_service_transaction_id
    FOR UPDATE NOWAIT;

    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_object_version_number       lock_csr%ROWTYPE;
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
      TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      IF (l_object_version_number.CP_SERVICE_TRANSACTION_ID <> p_cp_service_transaction_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.LAST_UPDATE_DATE <> p_last_update_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.LAST_UPDATED_BY <> p_last_updated_by) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CREATION_DATE <> p_creation_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CREATED_BY <> p_created_by) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.LAST_UPDATE_LOGIN <> p_last_update_login) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CP_SERVICE_ID <> p_cp_service_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.TRANSACTION_TYPE_CODE <> p_transaction_type_code) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.RESULTING_STATUS_CODE <> p_resulting_status_code) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.EFFECTIVE_START_DATE <> p_effective_start_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.EFFECTIVE_END_DATE <> p_effective_end_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CURRENT_END_DATE <> p_current_end_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.TERMINATED_TRANSACTION_ID <> p_terminated_transaction_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.REASON_CODE <> p_reason_code) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.REASON_COMMENTS <> p_reason_comments) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_SELLING_PRICE <> p_service_selling_price) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CURRENCY_CODE <> p_currency_code) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CONVERSION_TYPE <> p_conversion_type) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CONVERSION_RATE <> p_conversion_rate) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CONVERSION_DATE <> p_conversion_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.INVOICING_RULE_ID <> p_invoicing_rule_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ACCOUNTING_RULE_ID <> p_accounting_rule_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PAYMENT_TERMS_ID <> p_payment_terms_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_ORDER_LINE_ID <> p_service_order_line_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_ORDER_NUMBER <> p_service_order_number) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_ORDER_DATE <> p_service_order_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_ORDER_TYPE <> p_service_order_type) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.INVOICE_FLAG <> p_invoice_flag) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.COVERAGE_SCHEDULE_ID <> p_coverage_schedule_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.DURATION_QUANTITY <> p_duration_quantity) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.UNIT_OF_MEASURE_CODE <> p_unit_of_measure_code) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.STARTING_DELAY <> p_starting_delay) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.BILL_TO_SITE_USE_ID <> p_bill_to_site_use_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.BILL_TO_CONTACT_ID <> p_bill_to_contact_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRORATE_FLAG <> p_prorate_flag) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.RA_INTERFACE_STATUS <> p_ra_interface_status) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.INVOICE_COUNT <> p_invoice_count) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICE_LIST_ID <> p_price_list_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE1 <> p_attribute1) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE2 <> p_attribute2) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE3 <> p_attribute3) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE4 <> p_attribute4) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE5 <> p_attribute5) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE6 <> p_attribute6) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE7 <> p_attribute7) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE8 <> p_attribute8) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE9 <> p_attribute9) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE10 <> p_attribute10) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE11 <> p_attribute11) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE12 <> p_attribute12) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE13 <> p_attribute13) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE14 <> p_attribute14) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ATTRIBUTE15 <> p_attribute15) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CONTEXT <> p_context) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE1 <> p_pricing_attribute1) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE2 <> p_pricing_attribute2) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE3 <> p_pricing_attribute3) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE4 <> p_pricing_attribute4) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE5 <> p_pricing_attribute5) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE6 <> p_pricing_attribute6) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE7 <> p_pricing_attribute7) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE8 <> p_pricing_attribute8) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE9 <> p_pricing_attribute9) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE10 <> p_pricing_attribute10) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE11 <> p_pricing_attribute11) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE12 <> p_pricing_attribute12) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE13 <> p_pricing_attribute13) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE14 <> p_pricing_attribute14) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_ATTRIBUTE15 <> p_pricing_attribute15) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICING_CONTEXT <> p_pricing_context) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CREDIT_AMOUNT <> p_credit_amount) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PURCHASE_ORDER_NUM <> p_purchase_order_num) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
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
    p_servicetran_val_rec          IN ServiceTran_Val_Rec_Type := G_MISS_SERVICETRAN_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_servicetran_rec              ServiceTran_Rec_Type;
    l_def_servicetran_rec          ServiceTran_Rec_Type;
    FUNCTION populate_new_record (
      p_servicetran_rec	IN ServiceTran_Rec_Type,
      x_servicetran_rec	OUT ServiceTran_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR cs_cp_service_transa1_csr (p_cp_service_transaction_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Cp_Service_Transactions
       WHERE cs_cp_service_transactions.cp_service_transaction_id = p_cp_service_transaction_id;
      l_cs_cp_service_transa1        cs_cp_service_transa1_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_servicetran_rec := p_servicetran_rec;
      -- Get current database values
      OPEN cs_cp_service_transa1_csr (p_servicetran_rec.cp_service_transaction_id);
      FETCH cs_cp_service_transa1_csr INTO l_cs_cp_service_transa1;
      l_row_notfound := cs_cp_service_transa1_csr%NOTFOUND;
      CLOSE cs_cp_service_transa1_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_servicetran_rec.cp_service_transaction_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.cp_service_transaction_id := l_cs_cp_service_transa1.cp_service_transaction_id;
      END IF;
      IF (x_servicetran_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_servicetran_rec.last_update_date := l_cs_cp_service_transa1.last_update_date;
      END IF;
      IF (x_servicetran_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.last_updated_by := l_cs_cp_service_transa1.last_updated_by;
      END IF;
      IF (x_servicetran_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_servicetran_rec.creation_date := l_cs_cp_service_transa1.creation_date;
      END IF;
      IF (x_servicetran_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.created_by := l_cs_cp_service_transa1.created_by;
      END IF;
      IF (x_servicetran_rec.last_update_login = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.last_update_login := l_cs_cp_service_transa1.last_update_login;
      END IF;
      IF (x_servicetran_rec.cp_service_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.cp_service_id := l_cs_cp_service_transa1.cp_service_id;
      END IF;
      IF (x_servicetran_rec.transaction_type_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.transaction_type_code := l_cs_cp_service_transa1.transaction_type_code;
      END IF;
      IF (x_servicetran_rec.resulting_status_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.resulting_status_code := l_cs_cp_service_transa1.resulting_status_code;
      END IF;
      IF (x_servicetran_rec.effective_start_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_servicetran_rec.effective_start_date := l_cs_cp_service_transa1.effective_start_date;
      END IF;
      IF (x_servicetran_rec.effective_end_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_servicetran_rec.effective_end_date := l_cs_cp_service_transa1.effective_end_date;
      END IF;
      IF (x_servicetran_rec.current_end_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_servicetran_rec.current_end_date := l_cs_cp_service_transa1.current_end_date;
      END IF;
      IF (x_servicetran_rec.terminated_transaction_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.terminated_transaction_id := l_cs_cp_service_transa1.terminated_transaction_id;
      END IF;
      IF (x_servicetran_rec.reason_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.reason_code := l_cs_cp_service_transa1.reason_code;
      END IF;
      IF (x_servicetran_rec.reason_comments = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.reason_comments := l_cs_cp_service_transa1.reason_comments;
      END IF;
      IF (x_servicetran_rec.service_selling_price = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.service_selling_price := l_cs_cp_service_transa1.service_selling_price;
      END IF;
      IF (x_servicetran_rec.currency_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.currency_code := l_cs_cp_service_transa1.currency_code;
      END IF;
      IF (x_servicetran_rec.conversion_type = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.conversion_type := l_cs_cp_service_transa1.conversion_type;
      END IF;
      IF (x_servicetran_rec.conversion_rate = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.conversion_rate := l_cs_cp_service_transa1.conversion_rate;
      END IF;
      IF (x_servicetran_rec.conversion_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_servicetran_rec.conversion_date := l_cs_cp_service_transa1.conversion_date;
      END IF;
      IF (x_servicetran_rec.invoicing_rule_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.invoicing_rule_id := l_cs_cp_service_transa1.invoicing_rule_id;
      END IF;
      IF (x_servicetran_rec.accounting_rule_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.accounting_rule_id := l_cs_cp_service_transa1.accounting_rule_id;
      END IF;
      IF (x_servicetran_rec.payment_terms_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.payment_terms_id := l_cs_cp_service_transa1.payment_terms_id;
      END IF;
      IF (x_servicetran_rec.service_order_line_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.service_order_line_id := l_cs_cp_service_transa1.service_order_line_id;
      END IF;
      IF (x_servicetran_rec.service_order_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.service_order_number := l_cs_cp_service_transa1.service_order_number;
      END IF;
      IF (x_servicetran_rec.service_order_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_servicetran_rec.service_order_date := l_cs_cp_service_transa1.service_order_date;
      END IF;
      IF (x_servicetran_rec.service_order_type = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.service_order_type := l_cs_cp_service_transa1.service_order_type;
      END IF;
      IF (x_servicetran_rec.invoice_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.invoice_flag := l_cs_cp_service_transa1.invoice_flag;
      END IF;
      IF (x_servicetran_rec.coverage_schedule_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.coverage_schedule_id := l_cs_cp_service_transa1.coverage_schedule_id;
      END IF;
      IF (x_servicetran_rec.duration_quantity = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.duration_quantity := l_cs_cp_service_transa1.duration_quantity;
      END IF;
      IF (x_servicetran_rec.unit_of_measure_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.unit_of_measure_code := l_cs_cp_service_transa1.unit_of_measure_code;
      END IF;
      IF (x_servicetran_rec.starting_delay = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.starting_delay := l_cs_cp_service_transa1.starting_delay;
      END IF;
      IF (x_servicetran_rec.bill_to_site_use_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.bill_to_site_use_id := l_cs_cp_service_transa1.bill_to_site_use_id;
      END IF;
      IF (x_servicetran_rec.bill_to_contact_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.bill_to_contact_id := l_cs_cp_service_transa1.bill_to_contact_id;
      END IF;
      IF (x_servicetran_rec.prorate_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.prorate_flag := l_cs_cp_service_transa1.prorate_flag;
      END IF;
      IF (x_servicetran_rec.ra_interface_status = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.ra_interface_status := l_cs_cp_service_transa1.ra_interface_status;
      END IF;
      IF (x_servicetran_rec.invoice_count = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.invoice_count := l_cs_cp_service_transa1.invoice_count;
      END IF;
      IF (x_servicetran_rec.price_list_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.price_list_id := l_cs_cp_service_transa1.price_list_id;
      END IF;
      IF (x_servicetran_rec.attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute1 := l_cs_cp_service_transa1.attribute1;
      END IF;
      IF (x_servicetran_rec.attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute2 := l_cs_cp_service_transa1.attribute2;
      END IF;
      IF (x_servicetran_rec.attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute3 := l_cs_cp_service_transa1.attribute3;
      END IF;
      IF (x_servicetran_rec.attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute4 := l_cs_cp_service_transa1.attribute4;
      END IF;
      IF (x_servicetran_rec.attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute5 := l_cs_cp_service_transa1.attribute5;
      END IF;
      IF (x_servicetran_rec.attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute6 := l_cs_cp_service_transa1.attribute6;
      END IF;
      IF (x_servicetran_rec.attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute7 := l_cs_cp_service_transa1.attribute7;
      END IF;
      IF (x_servicetran_rec.attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute8 := l_cs_cp_service_transa1.attribute8;
      END IF;
      IF (x_servicetran_rec.attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute9 := l_cs_cp_service_transa1.attribute9;
      END IF;
      IF (x_servicetran_rec.attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute10 := l_cs_cp_service_transa1.attribute10;
      END IF;
      IF (x_servicetran_rec.attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute11 := l_cs_cp_service_transa1.attribute11;
      END IF;
      IF (x_servicetran_rec.attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute12 := l_cs_cp_service_transa1.attribute12;
      END IF;
      IF (x_servicetran_rec.attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute13 := l_cs_cp_service_transa1.attribute13;
      END IF;
      IF (x_servicetran_rec.attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute14 := l_cs_cp_service_transa1.attribute14;
      END IF;
      IF (x_servicetran_rec.attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.attribute15 := l_cs_cp_service_transa1.attribute15;
      END IF;
      IF (x_servicetran_rec.context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.context := l_cs_cp_service_transa1.context;
      END IF;
      IF (x_servicetran_rec.pricing_attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute1 := l_cs_cp_service_transa1.pricing_attribute1;
      END IF;
      IF (x_servicetran_rec.pricing_attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute2 := l_cs_cp_service_transa1.pricing_attribute2;
      END IF;
      IF (x_servicetran_rec.pricing_attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute3 := l_cs_cp_service_transa1.pricing_attribute3;
      END IF;
      IF (x_servicetran_rec.pricing_attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute4 := l_cs_cp_service_transa1.pricing_attribute4;
      END IF;
      IF (x_servicetran_rec.pricing_attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute5 := l_cs_cp_service_transa1.pricing_attribute5;
      END IF;
      IF (x_servicetran_rec.pricing_attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute6 := l_cs_cp_service_transa1.pricing_attribute6;
      END IF;
      IF (x_servicetran_rec.pricing_attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute7 := l_cs_cp_service_transa1.pricing_attribute7;
      END IF;
      IF (x_servicetran_rec.pricing_attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute8 := l_cs_cp_service_transa1.pricing_attribute8;
      END IF;
      IF (x_servicetran_rec.pricing_attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute9 := l_cs_cp_service_transa1.pricing_attribute9;
      END IF;
      IF (x_servicetran_rec.pricing_attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute10 := l_cs_cp_service_transa1.pricing_attribute10;
      END IF;
      IF (x_servicetran_rec.pricing_attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute11 := l_cs_cp_service_transa1.pricing_attribute11;
      END IF;
      IF (x_servicetran_rec.pricing_attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute12 := l_cs_cp_service_transa1.pricing_attribute12;
      END IF;
      IF (x_servicetran_rec.pricing_attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute13 := l_cs_cp_service_transa1.pricing_attribute13;
      END IF;
      IF (x_servicetran_rec.pricing_attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute14 := l_cs_cp_service_transa1.pricing_attribute14;
      END IF;
      IF (x_servicetran_rec.pricing_attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_attribute15 := l_cs_cp_service_transa1.pricing_attribute15;
      END IF;
      IF (x_servicetran_rec.pricing_context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.pricing_context := l_cs_cp_service_transa1.pricing_context;
      END IF;
      IF (x_servicetran_rec.credit_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_servicetran_rec.credit_amount := l_cs_cp_service_transa1.credit_amount;
      END IF;
      IF (x_servicetran_rec.purchase_order_num = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_servicetran_rec.purchase_order_num := l_cs_cp_service_transa1.purchase_order_num;
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
    migrate(p_servicetran_val_rec, l_servicetran_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_servicetran_rec,    ---- IN
      l_def_servicetran_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_servicetran_rec, l_def_servicetran_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_servicetran_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_servicetran_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_CP_SERVICE_TRANSACTIONS
    SET
        CP_SERVICE_TRANSACTION_ID = l_def_servicetran_rec.cp_service_transaction_id ,
        LAST_UPDATE_DATE = l_def_servicetran_rec.last_update_date ,
        LAST_UPDATED_BY = l_def_servicetran_rec.last_updated_by ,
        CREATION_DATE = l_def_servicetran_rec.creation_date ,
        CREATED_BY = l_def_servicetran_rec.created_by ,
        LAST_UPDATE_LOGIN = l_def_servicetran_rec.last_update_login ,
        CP_SERVICE_ID = l_def_servicetran_rec.cp_service_id ,
        TRANSACTION_TYPE_CODE = l_def_servicetran_rec.transaction_type_code ,
        RESULTING_STATUS_CODE = l_def_servicetran_rec.resulting_status_code ,
        EFFECTIVE_START_DATE = l_def_servicetran_rec.effective_start_date ,
        EFFECTIVE_END_DATE = l_def_servicetran_rec.effective_end_date ,
        CURRENT_END_DATE = l_def_servicetran_rec.current_end_date ,
        TERMINATED_TRANSACTION_ID = l_def_servicetran_rec.terminated_transaction_id ,
        REASON_CODE = l_def_servicetran_rec.reason_code ,
        REASON_COMMENTS = l_def_servicetran_rec.reason_comments ,
        SERVICE_SELLING_PRICE = l_def_servicetran_rec.service_selling_price ,
        CURRENCY_CODE = l_def_servicetran_rec.currency_code ,
        CONVERSION_TYPE = l_def_servicetran_rec.conversion_type ,
        CONVERSION_RATE = l_def_servicetran_rec.conversion_rate ,
        CONVERSION_DATE = l_def_servicetran_rec.conversion_date ,
        INVOICING_RULE_ID = l_def_servicetran_rec.invoicing_rule_id ,
        ACCOUNTING_RULE_ID = l_def_servicetran_rec.accounting_rule_id ,
        PAYMENT_TERMS_ID = l_def_servicetran_rec.payment_terms_id ,
        SERVICE_ORDER_LINE_ID = l_def_servicetran_rec.service_order_line_id ,
        SERVICE_ORDER_NUMBER = l_def_servicetran_rec.service_order_number ,
        SERVICE_ORDER_DATE = l_def_servicetran_rec.service_order_date ,
        SERVICE_ORDER_TYPE = l_def_servicetran_rec.service_order_type ,
        INVOICE_FLAG = l_def_servicetran_rec.invoice_flag ,
        COVERAGE_SCHEDULE_ID = l_def_servicetran_rec.coverage_schedule_id ,
        DURATION_QUANTITY = l_def_servicetran_rec.duration_quantity ,
        UNIT_OF_MEASURE_CODE = l_def_servicetran_rec.unit_of_measure_code ,
        STARTING_DELAY = l_def_servicetran_rec.starting_delay ,
        BILL_TO_SITE_USE_ID = l_def_servicetran_rec.bill_to_site_use_id ,
        BILL_TO_CONTACT_ID = l_def_servicetran_rec.bill_to_contact_id ,
        PRORATE_FLAG = l_def_servicetran_rec.prorate_flag ,
        RA_INTERFACE_STATUS = l_def_servicetran_rec.ra_interface_status ,
        INVOICE_COUNT = l_def_servicetran_rec.invoice_count ,
        PRICE_LIST_ID = l_def_servicetran_rec.price_list_id ,
        ATTRIBUTE1 = l_def_servicetran_rec.attribute1 ,
        ATTRIBUTE2 = l_def_servicetran_rec.attribute2 ,
        ATTRIBUTE3 = l_def_servicetran_rec.attribute3 ,
        ATTRIBUTE4 = l_def_servicetran_rec.attribute4 ,
        ATTRIBUTE5 = l_def_servicetran_rec.attribute5 ,
        ATTRIBUTE6 = l_def_servicetran_rec.attribute6 ,
        ATTRIBUTE7 = l_def_servicetran_rec.attribute7 ,
        ATTRIBUTE8 = l_def_servicetran_rec.attribute8 ,
        ATTRIBUTE9 = l_def_servicetran_rec.attribute9 ,
        ATTRIBUTE10 = l_def_servicetran_rec.attribute10 ,
        ATTRIBUTE11 = l_def_servicetran_rec.attribute11 ,
        ATTRIBUTE12 = l_def_servicetran_rec.attribute12 ,
        ATTRIBUTE13 = l_def_servicetran_rec.attribute13 ,
        ATTRIBUTE14 = l_def_servicetran_rec.attribute14 ,
        ATTRIBUTE15 = l_def_servicetran_rec.attribute15 ,
        CONTEXT = l_def_servicetran_rec.context ,
        PRICING_ATTRIBUTE1 = l_def_servicetran_rec.pricing_attribute1 ,
        PRICING_ATTRIBUTE2 = l_def_servicetran_rec.pricing_attribute2 ,
        PRICING_ATTRIBUTE3 = l_def_servicetran_rec.pricing_attribute3 ,
        PRICING_ATTRIBUTE4 = l_def_servicetran_rec.pricing_attribute4 ,
        PRICING_ATTRIBUTE5 = l_def_servicetran_rec.pricing_attribute5 ,
        PRICING_ATTRIBUTE6 = l_def_servicetran_rec.pricing_attribute6 ,
        PRICING_ATTRIBUTE7 = l_def_servicetran_rec.pricing_attribute7 ,
        PRICING_ATTRIBUTE8 = l_def_servicetran_rec.pricing_attribute8 ,
        PRICING_ATTRIBUTE9 = l_def_servicetran_rec.pricing_attribute9 ,
        PRICING_ATTRIBUTE10 = l_def_servicetran_rec.pricing_attribute10 ,
        PRICING_ATTRIBUTE11 = l_def_servicetran_rec.pricing_attribute11 ,
        PRICING_ATTRIBUTE12 = l_def_servicetran_rec.pricing_attribute12 ,
        PRICING_ATTRIBUTE13 = l_def_servicetran_rec.pricing_attribute13 ,
        PRICING_ATTRIBUTE14 = l_def_servicetran_rec.pricing_attribute14 ,
        PRICING_ATTRIBUTE15 = l_def_servicetran_rec.pricing_attribute15 ,
        PRICING_CONTEXT = l_def_servicetran_rec.pricing_context ,
        CREDIT_AMOUNT = l_def_servicetran_rec.credit_amount ,
        PURCHASE_ORDER_NUM = l_def_servicetran_rec.purchase_order_num
        WHERE
          CP_SERVICE_TRANSACTION_ID = l_def_servicetran_rec.cp_service_transaction_id
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
    p_cp_service_transaction_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_CP_SERVICE_TRANSACTIONS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CP_SERVICE_TRANSACTIONS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_transaction_type_code        IN CS_CP_SERVICE_TRANSACTIONS.TRANSACTION_TYPE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_resulting_status_code        IN CS_CP_SERVICE_TRANSACTIONS.RESULTING_STATUS_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_effective_start_date         IN CS_CP_SERVICE_TRANSACTIONS.EFFECTIVE_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_effective_end_date           IN CS_CP_SERVICE_TRANSACTIONS.EFFECTIVE_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_current_end_date             IN CS_CP_SERVICE_TRANSACTIONS.CURRENT_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_terminated_transaction_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reason_code                  IN CS_CP_SERVICE_TRANSACTIONS.REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_reason_comments              IN CS_CP_SERVICE_TRANSACTIONS.REASON_COMMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_service_selling_price        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CP_SERVICE_TRANSACTIONS.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type              IN CS_CP_SERVICE_TRANSACTIONS.CONVERSION_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CP_SERVICE_TRANSACTIONS.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_invoicing_rule_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_accounting_rule_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_payment_terms_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_line_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_number         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_date           IN CS_CP_SERVICE_TRANSACTIONS.SERVICE_ORDER_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_service_order_type           IN CS_CP_SERVICE_TRANSACTIONS.SERVICE_ORDER_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_invoice_flag                 IN CS_CP_SERVICE_TRANSACTIONS.INVOICE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_schedule_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_duration_quantity            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_unit_of_measure_code         IN CS_CP_SERVICE_TRANSACTIONS.UNIT_OF_MEASURE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_starting_delay               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_contact_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_prorate_flag                 IN CS_CP_SERVICE_TRANSACTIONS.PRORATE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_ra_interface_status          IN CS_CP_SERVICE_TRANSACTIONS.RA_INTERFACE_STATUS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_invoice_count                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CP_SERVICE_TRANSACTIONS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute1           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute2           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute3           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute4           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute5           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute6           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute7           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute8           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute9           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute10          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute11          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute12          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute13          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute14          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute15          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_context              IN CS_CP_SERVICE_TRANSACTIONS.PRICING_CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_credit_amount                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_purchase_order_num           IN CS_CP_SERVICE_TRANSACTIONS.PURCHASE_ORDER_NUM%TYPE := TAPI_DEV_KIT.G_MISS_CHAR) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_servicetran_rec              ServiceTran_Val_Rec_Type;
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
    l_servicetran_rec.CP_SERVICE_TRANSACTION_ID := p_cp_service_transaction_id;
    l_servicetran_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_servicetran_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_servicetran_rec.CREATION_DATE := p_creation_date;
    l_servicetran_rec.CREATED_BY := p_created_by;
    l_servicetran_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_servicetran_rec.CP_SERVICE_ID := p_cp_service_id;
    l_servicetran_rec.TRANSACTION_TYPE_CODE := p_transaction_type_code;
    l_servicetran_rec.RESULTING_STATUS_CODE := p_resulting_status_code;
    l_servicetran_rec.EFFECTIVE_START_DATE := p_effective_start_date;
    l_servicetran_rec.EFFECTIVE_END_DATE := p_effective_end_date;
    l_servicetran_rec.CURRENT_END_DATE := p_current_end_date;
    l_servicetran_rec.TERMINATED_TRANSACTION_ID := p_terminated_transaction_id;
    l_servicetran_rec.REASON_CODE := p_reason_code;
    l_servicetran_rec.REASON_COMMENTS := p_reason_comments;
    l_servicetran_rec.SERVICE_SELLING_PRICE := p_service_selling_price;
    l_servicetran_rec.CURRENCY_CODE := p_currency_code;
    l_servicetran_rec.CONVERSION_TYPE := p_conversion_type;
    l_servicetran_rec.CONVERSION_RATE := p_conversion_rate;
    l_servicetran_rec.CONVERSION_DATE := p_conversion_date;
    l_servicetran_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
    l_servicetran_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
    l_servicetran_rec.PAYMENT_TERMS_ID := p_payment_terms_id;
    l_servicetran_rec.SERVICE_ORDER_LINE_ID := p_service_order_line_id;
    l_servicetran_rec.SERVICE_ORDER_NUMBER := p_service_order_number;
    l_servicetran_rec.SERVICE_ORDER_DATE := p_service_order_date;
    l_servicetran_rec.SERVICE_ORDER_TYPE := p_service_order_type;
    l_servicetran_rec.INVOICE_FLAG := p_invoice_flag;
    l_servicetran_rec.COVERAGE_SCHEDULE_ID := p_coverage_schedule_id;
    l_servicetran_rec.DURATION_QUANTITY := p_duration_quantity;
    l_servicetran_rec.UNIT_OF_MEASURE_CODE := p_unit_of_measure_code;
    l_servicetran_rec.STARTING_DELAY := p_starting_delay;
    l_servicetran_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
    l_servicetran_rec.BILL_TO_CONTACT_ID := p_bill_to_contact_id;
    l_servicetran_rec.PRORATE_FLAG := p_prorate_flag;
    l_servicetran_rec.RA_INTERFACE_STATUS := p_ra_interface_status;
    l_servicetran_rec.INVOICE_COUNT := p_invoice_count;
    l_servicetran_rec.PRICE_LIST_ID := p_price_list_id;
    l_servicetran_rec.ATTRIBUTE1 := p_attribute1;
    l_servicetran_rec.ATTRIBUTE2 := p_attribute2;
    l_servicetran_rec.ATTRIBUTE3 := p_attribute3;
    l_servicetran_rec.ATTRIBUTE4 := p_attribute4;
    l_servicetran_rec.ATTRIBUTE5 := p_attribute5;
    l_servicetran_rec.ATTRIBUTE6 := p_attribute6;
    l_servicetran_rec.ATTRIBUTE7 := p_attribute7;
    l_servicetran_rec.ATTRIBUTE8 := p_attribute8;
    l_servicetran_rec.ATTRIBUTE9 := p_attribute9;
    l_servicetran_rec.ATTRIBUTE10 := p_attribute10;
    l_servicetran_rec.ATTRIBUTE11 := p_attribute11;
    l_servicetran_rec.ATTRIBUTE12 := p_attribute12;
    l_servicetran_rec.ATTRIBUTE13 := p_attribute13;
    l_servicetran_rec.ATTRIBUTE14 := p_attribute14;
    l_servicetran_rec.ATTRIBUTE15 := p_attribute15;
    l_servicetran_rec.CONTEXT := p_context;
    l_servicetran_rec.PRICING_ATTRIBUTE1 := p_pricing_attribute1;
    l_servicetran_rec.PRICING_ATTRIBUTE2 := p_pricing_attribute2;
    l_servicetran_rec.PRICING_ATTRIBUTE3 := p_pricing_attribute3;
    l_servicetran_rec.PRICING_ATTRIBUTE4 := p_pricing_attribute4;
    l_servicetran_rec.PRICING_ATTRIBUTE5 := p_pricing_attribute5;
    l_servicetran_rec.PRICING_ATTRIBUTE6 := p_pricing_attribute6;
    l_servicetran_rec.PRICING_ATTRIBUTE7 := p_pricing_attribute7;
    l_servicetran_rec.PRICING_ATTRIBUTE8 := p_pricing_attribute8;
    l_servicetran_rec.PRICING_ATTRIBUTE9 := p_pricing_attribute9;
    l_servicetran_rec.PRICING_ATTRIBUTE10 := p_pricing_attribute10;
    l_servicetran_rec.PRICING_ATTRIBUTE11 := p_pricing_attribute11;
    l_servicetran_rec.PRICING_ATTRIBUTE12 := p_pricing_attribute12;
    l_servicetran_rec.PRICING_ATTRIBUTE13 := p_pricing_attribute13;
    l_servicetran_rec.PRICING_ATTRIBUTE14 := p_pricing_attribute14;
    l_servicetran_rec.PRICING_ATTRIBUTE15 := p_pricing_attribute15;
    l_servicetran_rec.PRICING_CONTEXT := p_pricing_context;
    l_servicetran_rec.CREDIT_AMOUNT := p_credit_amount;
    l_servicetran_rec.PURCHASE_ORDER_NUM := p_purchase_order_num;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_servicetran_rec
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
    p_cp_service_transaction_id    IN NUMBER) IS
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
    DELETE  FROM CS_CP_SERVICE_TRANSACTIONS
    WHERE
      CP_SERVICE_TRANSACTION_ID = p_cp_service_transaction_id
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
    p_servicetran_val_rec          IN ServiceTran_Val_Rec_Type := G_MISS_SERVICETRAN_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_servicetran_rec              ServiceTran_Rec_Type;
    l_def_servicetran_rec          ServiceTran_Rec_Type;
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
    migrate(p_servicetran_val_rec, l_servicetran_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_servicetran_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_servicetran_rec);
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
    p_cp_service_transaction_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_CP_SERVICE_TRANSACTIONS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CP_SERVICE_TRANSACTIONS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_transaction_type_code        IN CS_CP_SERVICE_TRANSACTIONS.TRANSACTION_TYPE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_resulting_status_code        IN CS_CP_SERVICE_TRANSACTIONS.RESULTING_STATUS_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_effective_start_date         IN CS_CP_SERVICE_TRANSACTIONS.EFFECTIVE_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_effective_end_date           IN CS_CP_SERVICE_TRANSACTIONS.EFFECTIVE_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_current_end_date             IN CS_CP_SERVICE_TRANSACTIONS.CURRENT_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_terminated_transaction_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reason_code                  IN CS_CP_SERVICE_TRANSACTIONS.REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_reason_comments              IN CS_CP_SERVICE_TRANSACTIONS.REASON_COMMENTS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_service_selling_price        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CP_SERVICE_TRANSACTIONS.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type              IN CS_CP_SERVICE_TRANSACTIONS.CONVERSION_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CP_SERVICE_TRANSACTIONS.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_invoicing_rule_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_accounting_rule_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_payment_terms_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_line_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_number         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_date           IN CS_CP_SERVICE_TRANSACTIONS.SERVICE_ORDER_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_service_order_type           IN CS_CP_SERVICE_TRANSACTIONS.SERVICE_ORDER_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_invoice_flag                 IN CS_CP_SERVICE_TRANSACTIONS.INVOICE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_schedule_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_duration_quantity            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_unit_of_measure_code         IN CS_CP_SERVICE_TRANSACTIONS.UNIT_OF_MEASURE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_starting_delay               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_contact_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_prorate_flag                 IN CS_CP_SERVICE_TRANSACTIONS.PRORATE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_ra_interface_status          IN CS_CP_SERVICE_TRANSACTIONS.RA_INTERFACE_STATUS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_invoice_count                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CP_SERVICE_TRANSACTIONS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CP_SERVICE_TRANSACTIONS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute1           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute2           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute3           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute4           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute5           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute6           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute7           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute8           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute9           IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute10          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute11          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute12          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute13          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute14          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute15          IN CS_CP_SERVICE_TRANSACTIONS.PRICING_ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_context              IN CS_CP_SERVICE_TRANSACTIONS.PRICING_CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_credit_amount                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_purchase_order_num           IN CS_CP_SERVICE_TRANSACTIONS.PURCHASE_ORDER_NUM%TYPE := TAPI_DEV_KIT.G_MISS_CHAR) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_servicetran_rec              ServiceTran_Val_Rec_Type;
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
    l_servicetran_rec.CP_SERVICE_TRANSACTION_ID := p_cp_service_transaction_id;
    l_servicetran_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_servicetran_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_servicetran_rec.CREATION_DATE := p_creation_date;
    l_servicetran_rec.CREATED_BY := p_created_by;
    l_servicetran_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_servicetran_rec.CP_SERVICE_ID := p_cp_service_id;
    l_servicetran_rec.TRANSACTION_TYPE_CODE := p_transaction_type_code;
    l_servicetran_rec.RESULTING_STATUS_CODE := p_resulting_status_code;
    l_servicetran_rec.EFFECTIVE_START_DATE := p_effective_start_date;
    l_servicetran_rec.EFFECTIVE_END_DATE := p_effective_end_date;
    l_servicetran_rec.CURRENT_END_DATE := p_current_end_date;
    l_servicetran_rec.TERMINATED_TRANSACTION_ID := p_terminated_transaction_id;
    l_servicetran_rec.REASON_CODE := p_reason_code;
    l_servicetran_rec.REASON_COMMENTS := p_reason_comments;
    l_servicetran_rec.SERVICE_SELLING_PRICE := p_service_selling_price;
    l_servicetran_rec.CURRENCY_CODE := p_currency_code;
    l_servicetran_rec.CONVERSION_TYPE := p_conversion_type;
    l_servicetran_rec.CONVERSION_RATE := p_conversion_rate;
    l_servicetran_rec.CONVERSION_DATE := p_conversion_date;
    l_servicetran_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
    l_servicetran_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
    l_servicetran_rec.PAYMENT_TERMS_ID := p_payment_terms_id;
    l_servicetran_rec.SERVICE_ORDER_LINE_ID := p_service_order_line_id;
    l_servicetran_rec.SERVICE_ORDER_NUMBER := p_service_order_number;
    l_servicetran_rec.SERVICE_ORDER_DATE := p_service_order_date;
    l_servicetran_rec.SERVICE_ORDER_TYPE := p_service_order_type;
    l_servicetran_rec.INVOICE_FLAG := p_invoice_flag;
    l_servicetran_rec.COVERAGE_SCHEDULE_ID := p_coverage_schedule_id;
    l_servicetran_rec.DURATION_QUANTITY := p_duration_quantity;
    l_servicetran_rec.UNIT_OF_MEASURE_CODE := p_unit_of_measure_code;
    l_servicetran_rec.STARTING_DELAY := p_starting_delay;
    l_servicetran_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
    l_servicetran_rec.BILL_TO_CONTACT_ID := p_bill_to_contact_id;
    l_servicetran_rec.PRORATE_FLAG := p_prorate_flag;
    l_servicetran_rec.RA_INTERFACE_STATUS := p_ra_interface_status;
    l_servicetran_rec.INVOICE_COUNT := p_invoice_count;
    l_servicetran_rec.PRICE_LIST_ID := p_price_list_id;
    l_servicetran_rec.ATTRIBUTE1 := p_attribute1;
    l_servicetran_rec.ATTRIBUTE2 := p_attribute2;
    l_servicetran_rec.ATTRIBUTE3 := p_attribute3;
    l_servicetran_rec.ATTRIBUTE4 := p_attribute4;
    l_servicetran_rec.ATTRIBUTE5 := p_attribute5;
    l_servicetran_rec.ATTRIBUTE6 := p_attribute6;
    l_servicetran_rec.ATTRIBUTE7 := p_attribute7;
    l_servicetran_rec.ATTRIBUTE8 := p_attribute8;
    l_servicetran_rec.ATTRIBUTE9 := p_attribute9;
    l_servicetran_rec.ATTRIBUTE10 := p_attribute10;
    l_servicetran_rec.ATTRIBUTE11 := p_attribute11;
    l_servicetran_rec.ATTRIBUTE12 := p_attribute12;
    l_servicetran_rec.ATTRIBUTE13 := p_attribute13;
    l_servicetran_rec.ATTRIBUTE14 := p_attribute14;
    l_servicetran_rec.ATTRIBUTE15 := p_attribute15;
    l_servicetran_rec.CONTEXT := p_context;
    l_servicetran_rec.PRICING_ATTRIBUTE1 := p_pricing_attribute1;
    l_servicetran_rec.PRICING_ATTRIBUTE2 := p_pricing_attribute2;
    l_servicetran_rec.PRICING_ATTRIBUTE3 := p_pricing_attribute3;
    l_servicetran_rec.PRICING_ATTRIBUTE4 := p_pricing_attribute4;
    l_servicetran_rec.PRICING_ATTRIBUTE5 := p_pricing_attribute5;
    l_servicetran_rec.PRICING_ATTRIBUTE6 := p_pricing_attribute6;
    l_servicetran_rec.PRICING_ATTRIBUTE7 := p_pricing_attribute7;
    l_servicetran_rec.PRICING_ATTRIBUTE8 := p_pricing_attribute8;
    l_servicetran_rec.PRICING_ATTRIBUTE9 := p_pricing_attribute9;
    l_servicetran_rec.PRICING_ATTRIBUTE10 := p_pricing_attribute10;
    l_servicetran_rec.PRICING_ATTRIBUTE11 := p_pricing_attribute11;
    l_servicetran_rec.PRICING_ATTRIBUTE12 := p_pricing_attribute12;
    l_servicetran_rec.PRICING_ATTRIBUTE13 := p_pricing_attribute13;
    l_servicetran_rec.PRICING_ATTRIBUTE14 := p_pricing_attribute14;
    l_servicetran_rec.PRICING_ATTRIBUTE15 := p_pricing_attribute15;
    l_servicetran_rec.PRICING_CONTEXT := p_pricing_context;
    l_servicetran_rec.CREDIT_AMOUNT := p_credit_amount;
    l_servicetran_rec.PURCHASE_ORDER_NUM := p_purchase_order_num;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_servicetran_rec
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
END CS_SERVICETRAN_PVT;

/

--------------------------------------------------------
--  DDL for Package Body CS_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICE_PVT" AS
/* $Header: csctserb.pls 115.2 99/07/16 08:54:18 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_CP_SERVICES_S.nextval FROM SYS.DUAL;
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
    p_service_rec IN  Service_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_service_rec.contract_line_status_id = TAPI_DEV_KIT.G_MISS_NUM OR
       p_service_rec.contract_line_status_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_line_status_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_service_rec.service_inventory_item_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_service_rec.service_inventory_item_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'service_inventory_item_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_service_rec.service_manufacturing_org_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_service_rec.service_manufacturing_org_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'service_manufacturing_org_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_service_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_service_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_service_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_service_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_service_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_service_rec.last_update_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_service_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_service_rec.last_updated_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_service_rec IN  Service_Rec_Type,
    l_def_service_rec OUT  Service_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_service_rec := p_service_rec;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_service_rec IN Service_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    FUNCTION validate_foreign_keys (
      p_service_rec IN Service_Rec_Type
    )
    RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR cs_contracts_statuses_pk_csr (p_contract_status_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Contract_Statuses
       WHERE cs_contract_statuses.contract_status_id = p_contract_status_id;
      l_cs_contracts_statuses_pk     cs_contracts_statuses_pk_csr%ROWTYPE;
      CURSOR cs_contract_line_tem1_csr (p_contract_line_template_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Contract_Line_Tplts
       WHERE cs_contract_line_tplts.contract_line_template_id = p_contract_line_template_id;
      l_cs_contract_line_tem1        cs_contract_line_tem1_csr%ROWTYPE;
      CURSOR ccpall_pk_csr (p_customer_product_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Customer_Products
       WHERE cs_customer_products.customer_product_id = p_customer_product_id;
      l_ccpall_pk                    ccpall_pk_csr%ROWTYPE;
      CURSOR cs_contracts_all_pk_csr (p_contract_id        IN NUMBER) IS
      SELECT *
        FROM Cs_Contracts_All
       WHERE cs_contracts_all.contract_id = p_contract_id;
      l_cs_contracts_all_pk          cs_contracts_all_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_service_rec.CONTRACT_LINE_STATUS_ID IS NOT NULL)
      THEN
        OPEN cs_contracts_statuses_pk_csr(p_service_rec.CONTRACT_LINE_STATUS_ID);
        FETCH cs_contracts_statuses_pk_csr INTO l_cs_contracts_statuses_pk;
        l_row_notfound := cs_contracts_statuses_pk_csr%NOTFOUND;
        CLOSE cs_contracts_statuses_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTRACT_LINE_STATUS_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_service_rec.CONTRACT_LINE_TEMPLATE_ID IS NOT NULL)
      THEN
        OPEN cs_contract_line_tem1_csr(p_service_rec.CONTRACT_LINE_TEMPLATE_ID);
        FETCH cs_contract_line_tem1_csr INTO l_cs_contract_line_tem1;
        l_row_notfound := cs_contract_line_tem1_csr%NOTFOUND;
        CLOSE cs_contract_line_tem1_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTRACT_LINE_TEMPLATE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_service_rec.CUSTOMER_PRODUCT_ID IS NOT NULL)
      THEN
        OPEN ccpall_pk_csr(p_service_rec.CUSTOMER_PRODUCT_ID);
        FETCH ccpall_pk_csr INTO l_ccpall_pk;
        l_row_notfound := ccpall_pk_csr%NOTFOUND;
        CLOSE ccpall_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CUSTOMER_PRODUCT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_service_rec.CONTRACT_ID IS NOT NULL)
      THEN
        OPEN cs_contracts_all_pk_csr(p_service_rec.CONTRACT_ID);
        FETCH cs_contracts_all_pk_csr INTO l_cs_contracts_all_pk;
        l_row_notfound := cs_contracts_all_pk_csr%NOTFOUND;
        CLOSE cs_contracts_all_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTRACT_ID');
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
    l_return_status := validate_foreign_keys (p_service_rec);
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN Service_Val_Rec_Type,
    p_to	OUT Service_Rec_Type
  ) IS
  BEGIN
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.customer_product_id := p_from.customer_product_id;
    p_to.contract_line_status_id := p_from.contract_line_status_id;
    p_to.contract_line_template_id := p_from.contract_line_template_id;
    p_to.contract_id := p_from.contract_id;
    p_to.service_inventory_item_id := p_from.service_inventory_item_id;
    p_to.service_manufacturing_org_id := p_from.service_manufacturing_org_id;
    p_to.status_code := p_from.status_code;
    p_to.last_cp_service_transaction_id := p_from.last_cp_service_transaction_id;
    p_to.invoice_flag := p_from.invoice_flag;
    p_to.coverage_schedule_id := p_from.coverage_schedule_id;
    p_to.prorate_flag := p_from.prorate_flag;
    p_to.duration_quantity := p_from.duration_quantity;
    p_to.unit_of_measure_code := p_from.unit_of_measure_code;
    p_to.starting_delay := p_from.starting_delay;
    p_to.bill_to_site_use_id := p_from.bill_to_site_use_id;
    p_to.bill_to_contact_id := p_from.bill_to_contact_id;
    p_to.service_txn_availability_code := p_from.service_txn_availability_code;
    p_to.next_pm_visit_date := p_from.next_pm_visit_date;
    p_to.pm_visits_completed := p_from.pm_visits_completed;
    p_to.last_pm_visit_date := p_from.last_pm_visit_date;
    p_to.pm_schedule_id := p_from.pm_schedule_id;
    p_to.pm_schedule_flag := p_from.pm_schedule_flag;
    p_to.current_max_schedule_date := p_from.current_max_schedule_date;
    p_to.price_list_id := p_from.price_list_id;
    p_to.service_order_type := p_from.service_order_type;
    p_to.invoice_count := p_from.invoice_count;
    p_to.currency_code := p_from.currency_code;
    p_to.conversion_type := p_from.conversion_type;
    p_to.conversion_rate := p_from.conversion_rate;
    p_to.conversion_date := p_from.conversion_date;
    p_to.original_service_line_id := p_from.original_service_line_id;
    p_to.warranty_flag := p_from.warranty_flag;
    p_to.original_start_date := p_from.original_start_date;
    p_to.original_end_date := p_from.original_end_date;
    p_to.service_date_change := p_from.service_date_change;
    p_to.workflow := p_from.workflow;
    p_to.ship_to_site_use_id := p_from.ship_to_site_use_id;
    p_to.original_system_line_reference := p_from.original_system_line_reference;
    p_to.extended_price := p_from.extended_price;
    p_to.discount_id := p_from.discount_id;
    p_to.tax_code := p_from.tax_code;
    p_to.billing_frequency_period := p_from.billing_frequency_period;
    p_to.first_bill_date := p_from.first_bill_date;
    p_to.next_bill_date := p_from.next_bill_date;
    p_to.creation_date := p_from.creation_date;
    p_to.bill_on := p_from.bill_on;
    p_to.created_by := p_from.created_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
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
    p_to.list_price := p_from.list_price;
    p_to.org_id := p_from.org_id;
    p_to.price_percent := p_from.price_percent;
  END migrate;
  PROCEDURE migrate (
    p_from	IN Service_Rec_Type,
    p_to	OUT Service_Val_Rec_Type
  ) IS
  BEGIN
    p_to.cp_service_id := p_from.cp_service_id;
    p_to.customer_product_id := p_from.customer_product_id;
    p_to.contract_line_status_id := p_from.contract_line_status_id;
    p_to.contract_line_template_id := p_from.contract_line_template_id;
    p_to.contract_id := p_from.contract_id;
    p_to.service_inventory_item_id := p_from.service_inventory_item_id;
    p_to.service_manufacturing_org_id := p_from.service_manufacturing_org_id;
    p_to.status_code := p_from.status_code;
    p_to.last_cp_service_transaction_id := p_from.last_cp_service_transaction_id;
    p_to.invoice_flag := p_from.invoice_flag;
    p_to.coverage_schedule_id := p_from.coverage_schedule_id;
    p_to.prorate_flag := p_from.prorate_flag;
    p_to.duration_quantity := p_from.duration_quantity;
    p_to.unit_of_measure_code := p_from.unit_of_measure_code;
    p_to.starting_delay := p_from.starting_delay;
    p_to.bill_to_site_use_id := p_from.bill_to_site_use_id;
    p_to.bill_to_contact_id := p_from.bill_to_contact_id;
    p_to.service_txn_availability_code := p_from.service_txn_availability_code;
    p_to.next_pm_visit_date := p_from.next_pm_visit_date;
    p_to.pm_visits_completed := p_from.pm_visits_completed;
    p_to.last_pm_visit_date := p_from.last_pm_visit_date;
    p_to.pm_schedule_id := p_from.pm_schedule_id;
    p_to.pm_schedule_flag := p_from.pm_schedule_flag;
    p_to.current_max_schedule_date := p_from.current_max_schedule_date;
    p_to.price_list_id := p_from.price_list_id;
    p_to.service_order_type := p_from.service_order_type;
    p_to.invoice_count := p_from.invoice_count;
    p_to.currency_code := p_from.currency_code;
    p_to.conversion_type := p_from.conversion_type;
    p_to.conversion_rate := p_from.conversion_rate;
    p_to.conversion_date := p_from.conversion_date;
    p_to.original_service_line_id := p_from.original_service_line_id;
    p_to.warranty_flag := p_from.warranty_flag;
    p_to.original_start_date := p_from.original_start_date;
    p_to.original_end_date := p_from.original_end_date;
    p_to.service_date_change := p_from.service_date_change;
    p_to.workflow := p_from.workflow;
    p_to.ship_to_site_use_id := p_from.ship_to_site_use_id;
    p_to.original_system_line_reference := p_from.original_system_line_reference;
    p_to.extended_price := p_from.extended_price;
    p_to.discount_id := p_from.discount_id;
    p_to.tax_code := p_from.tax_code;
    p_to.billing_frequency_period := p_from.billing_frequency_period;
    p_to.first_bill_date := p_from.first_bill_date;
    p_to.next_bill_date := p_from.next_bill_date;
    p_to.creation_date := p_from.creation_date;
    p_to.bill_on := p_from.bill_on;
    p_to.created_by := p_from.created_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
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
    p_to.list_price := p_from.list_price;
    p_to.org_id := p_from.org_id;
    p_to.price_percent := p_from.price_percent;
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
    p_service_rec                  IN Service_Rec_Type := G_MISS_SERVICE_REC,
    x_cp_service_id                OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_service_rec                  Service_Rec_Type;
    l_def_service_rec              Service_Rec_Type;
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
    l_service_rec := p_service_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_service_rec    ---- IN
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
      l_service_rec,    ---- IN
      l_def_service_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_service_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_service_rec.cp_service_id := get_seq_id;
    INSERT INTO CS_CP_SERVICES(
        cp_service_id,
        customer_product_id,
        contract_line_status_id,
        contract_line_template_id,
        contract_id,
        service_inventory_item_id,
        service_manufacturing_org_id,
        status_code,
        last_cp_service_transaction_id,
        invoice_flag,
        coverage_schedule_id,
        prorate_flag,
        duration_quantity,
        unit_of_measure_code,
        starting_delay,
        bill_to_site_use_id,
        bill_to_contact_id,
        service_txn_availability_code,
        next_pm_visit_date,
        pm_visits_completed,
        last_pm_visit_date,
        pm_schedule_id,
        pm_schedule_flag,
        current_max_schedule_date,
        price_list_id,
        service_order_type,
        invoice_count,
        currency_code,
        conversion_type,
        conversion_rate,
        conversion_date,
        original_service_line_id,
        warranty_flag,
        original_start_date,
        original_end_date,
        service_date_change,
        workflow,
        ship_to_site_use_id,
        original_system_line_reference,
        extended_price,
        discount_id,
        tax_code,
        billing_frequency_period,
        first_bill_date,
        next_bill_date,
        creation_date,
        bill_on,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        start_date_active,
        end_date_active,
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
        list_price,
        org_id,
        price_percent)
      VALUES (
        l_def_service_rec.cp_service_id,
        l_def_service_rec.customer_product_id,
        l_def_service_rec.contract_line_status_id,
        l_def_service_rec.contract_line_template_id,
        l_def_service_rec.contract_id,
        l_def_service_rec.service_inventory_item_id,
        l_def_service_rec.service_manufacturing_org_id,
        l_def_service_rec.status_code,
        l_def_service_rec.last_cp_service_transaction_id,
        l_def_service_rec.invoice_flag,
        l_def_service_rec.coverage_schedule_id,
        l_def_service_rec.prorate_flag,
        l_def_service_rec.duration_quantity,
        l_def_service_rec.unit_of_measure_code,
        l_def_service_rec.starting_delay,
        l_def_service_rec.bill_to_site_use_id,
        l_def_service_rec.bill_to_contact_id,
        l_def_service_rec.service_txn_availability_code,
        l_def_service_rec.next_pm_visit_date,
        l_def_service_rec.pm_visits_completed,
        l_def_service_rec.last_pm_visit_date,
        l_def_service_rec.pm_schedule_id,
        l_def_service_rec.pm_schedule_flag,
        l_def_service_rec.current_max_schedule_date,
        l_def_service_rec.price_list_id,
        l_def_service_rec.service_order_type,
        l_def_service_rec.invoice_count,
        l_def_service_rec.currency_code,
        l_def_service_rec.conversion_type,
        l_def_service_rec.conversion_rate,
        l_def_service_rec.conversion_date,
        l_def_service_rec.original_service_line_id,
        l_def_service_rec.warranty_flag,
        l_def_service_rec.original_start_date,
        l_def_service_rec.original_end_date,
        l_def_service_rec.service_date_change,
        l_def_service_rec.workflow,
        l_def_service_rec.ship_to_site_use_id,
        l_def_service_rec.original_system_line_reference,
        l_def_service_rec.extended_price,
        l_def_service_rec.discount_id,
        l_def_service_rec.tax_code,
        l_def_service_rec.billing_frequency_period,
        l_def_service_rec.first_bill_date,
        l_def_service_rec.next_bill_date,
        l_def_service_rec.creation_date,
        l_def_service_rec.bill_on,
        l_def_service_rec.created_by,
        l_def_service_rec.last_update_date,
        l_def_service_rec.last_updated_by,
        l_def_service_rec.last_update_login,
        l_def_service_rec.start_date_active,
        l_def_service_rec.end_date_active,
        l_def_service_rec.pricing_attribute1,
        l_def_service_rec.pricing_attribute2,
        l_def_service_rec.pricing_attribute3,
        l_def_service_rec.pricing_attribute4,
        l_def_service_rec.pricing_attribute5,
        l_def_service_rec.pricing_attribute6,
        l_def_service_rec.pricing_attribute7,
        l_def_service_rec.pricing_attribute8,
        l_def_service_rec.pricing_attribute9,
        l_def_service_rec.pricing_attribute10,
        l_def_service_rec.pricing_attribute11,
        l_def_service_rec.pricing_attribute12,
        l_def_service_rec.pricing_attribute13,
        l_def_service_rec.pricing_attribute14,
        l_def_service_rec.pricing_attribute15,
        l_def_service_rec.pricing_context,
        l_def_service_rec.attribute1,
        l_def_service_rec.attribute2,
        l_def_service_rec.attribute3,
        l_def_service_rec.attribute4,
        l_def_service_rec.attribute5,
        l_def_service_rec.attribute6,
        l_def_service_rec.attribute7,
        l_def_service_rec.attribute8,
        l_def_service_rec.attribute9,
        l_def_service_rec.attribute10,
        l_def_service_rec.attribute11,
        l_def_service_rec.attribute12,
        l_def_service_rec.attribute13,
        l_def_service_rec.attribute14,
        l_def_service_rec.attribute15,
        l_def_service_rec.context,
        l_def_service_rec.list_price,
        l_def_service_rec.org_id,
        l_def_service_rec.price_percent);
    -- Set OUT values
    x_cp_service_id := l_def_service_rec.cp_service_id;
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
    p_customer_product_id          IN NUMBER := NULL,
    p_contract_line_status_id      IN NUMBER := NULL,
    p_contract_line_template_id    IN NUMBER := NULL,
    p_contract_id                  IN NUMBER := NULL,
    p_service_inventory_item_id    IN NUMBER := NULL,
    p_service_manufacturing_org_id  IN NUMBER := NULL,
    p_status_code                  IN CS_CP_SERVICES.STATUS_CODE%TYPE := NULL,
    p_lst_cp_srvic_trnsctin_id     IN NUMBER := NULL,
    p_invoice_flag                 IN CS_CP_SERVICES.INVOICE_FLAG%TYPE := NULL,
    p_coverage_schedule_id         IN NUMBER := NULL,
    p_prorate_flag                 IN CS_CP_SERVICES.PRORATE_FLAG%TYPE := NULL,
    p_duration_quantity            IN NUMBER := NULL,
    p_unit_of_measure_code         IN CS_CP_SERVICES.UNIT_OF_MEASURE_CODE%TYPE := NULL,
    p_starting_delay               IN NUMBER := NULL,
    p_bill_to_site_use_id          IN NUMBER := NULL,
    p_bill_to_contact_id           IN NUMBER := NULL,
    p_srvic_txn_vilbility_cd       IN CS_CP_SERVICES.SERVICE_TXN_AVAILABILITY_CODE%TYPE := NULL,
    p_next_pm_visit_date           IN CS_CP_SERVICES.NEXT_PM_VISIT_DATE%TYPE := NULL,
    p_pm_visits_completed          IN NUMBER := NULL,
    p_last_pm_visit_date           IN CS_CP_SERVICES.LAST_PM_VISIT_DATE%TYPE := NULL,
    p_pm_schedule_id               IN NUMBER := NULL,
    p_pm_schedule_flag             IN CS_CP_SERVICES.PM_SCHEDULE_FLAG%TYPE := NULL,
    p_current_max_schedule_date    IN CS_CP_SERVICES.CURRENT_MAX_SCHEDULE_DATE%TYPE := NULL,
    p_price_list_id                IN NUMBER := NULL,
    p_service_order_type           IN CS_CP_SERVICES.SERVICE_ORDER_TYPE%TYPE := NULL,
    p_invoice_count                IN NUMBER := NULL,
    p_currency_code                IN CS_CP_SERVICES.CURRENCY_CODE%TYPE := NULL,
    p_conversion_type              IN CS_CP_SERVICES.CONVERSION_TYPE%TYPE := NULL,
    p_conversion_rate              IN NUMBER := NULL,
    p_conversion_date              IN CS_CP_SERVICES.CONVERSION_DATE%TYPE := NULL,
    p_original_service_line_id     IN NUMBER := NULL,
    p_warranty_flag                IN CS_CP_SERVICES.WARRANTY_FLAG%TYPE := NULL,
    p_original_start_date          IN CS_CP_SERVICES.ORIGINAL_START_DATE%TYPE := NULL,
    p_original_end_date            IN CS_CP_SERVICES.ORIGINAL_END_DATE%TYPE := NULL,
    p_service_date_change          IN CS_CP_SERVICES.SERVICE_DATE_CHANGE%TYPE := NULL,
    p_workflow                     IN CS_CP_SERVICES.WORKFLOW%TYPE := NULL,
    p_ship_to_site_use_id          IN NUMBER := NULL,
    p_riginl_systm_lin_rfrnc       IN CS_CP_SERVICES.ORIGINAL_SYSTEM_LINE_REFERENCE%TYPE := NULL,
    p_extended_price               IN NUMBER := NULL,
    p_discount_id                  IN NUMBER := NULL,
    p_tax_code                     IN CS_CP_SERVICES.TAX_CODE%TYPE := NULL,
    p_billing_frequency_period     IN CS_CP_SERVICES.BILLING_FREQUENCY_PERIOD%TYPE := NULL,
    p_first_bill_date              IN CS_CP_SERVICES.FIRST_BILL_DATE%TYPE := NULL,
    p_next_bill_date               IN CS_CP_SERVICES.NEXT_BILL_DATE%TYPE := NULL,
    p_creation_date                IN CS_CP_SERVICES.CREATION_DATE%TYPE := NULL,
    p_bill_on                      IN NUMBER := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_date             IN CS_CP_SERVICES.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_start_date_active            IN CS_CP_SERVICES.START_DATE_ACTIVE%TYPE := NULL,
    p_end_date_active              IN CS_CP_SERVICES.END_DATE_ACTIVE%TYPE := NULL,
    p_pricing_attribute1           IN CS_CP_SERVICES.PRICING_ATTRIBUTE1%TYPE := NULL,
    p_pricing_attribute2           IN CS_CP_SERVICES.PRICING_ATTRIBUTE2%TYPE := NULL,
    p_pricing_attribute3           IN CS_CP_SERVICES.PRICING_ATTRIBUTE3%TYPE := NULL,
    p_pricing_attribute4           IN CS_CP_SERVICES.PRICING_ATTRIBUTE4%TYPE := NULL,
    p_pricing_attribute5           IN CS_CP_SERVICES.PRICING_ATTRIBUTE5%TYPE := NULL,
    p_pricing_attribute6           IN CS_CP_SERVICES.PRICING_ATTRIBUTE6%TYPE := NULL,
    p_pricing_attribute7           IN CS_CP_SERVICES.PRICING_ATTRIBUTE7%TYPE := NULL,
    p_pricing_attribute8           IN CS_CP_SERVICES.PRICING_ATTRIBUTE8%TYPE := NULL,
    p_pricing_attribute9           IN CS_CP_SERVICES.PRICING_ATTRIBUTE9%TYPE := NULL,
    p_pricing_attribute10          IN CS_CP_SERVICES.PRICING_ATTRIBUTE10%TYPE := NULL,
    p_pricing_attribute11          IN CS_CP_SERVICES.PRICING_ATTRIBUTE11%TYPE := NULL,
    p_pricing_attribute12          IN CS_CP_SERVICES.PRICING_ATTRIBUTE12%TYPE := NULL,
    p_pricing_attribute13          IN CS_CP_SERVICES.PRICING_ATTRIBUTE13%TYPE := NULL,
    p_pricing_attribute14          IN CS_CP_SERVICES.PRICING_ATTRIBUTE14%TYPE := NULL,
    p_pricing_attribute15          IN CS_CP_SERVICES.PRICING_ATTRIBUTE15%TYPE := NULL,
    p_pricing_context              IN CS_CP_SERVICES.PRICING_CONTEXT%TYPE := NULL,
    p_attribute1                   IN CS_CP_SERVICES.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_CP_SERVICES.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_CP_SERVICES.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_CP_SERVICES.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_CP_SERVICES.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_CP_SERVICES.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_CP_SERVICES.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_CP_SERVICES.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_CP_SERVICES.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_CP_SERVICES.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_CP_SERVICES.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_CP_SERVICES.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_CP_SERVICES.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_CP_SERVICES.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_CP_SERVICES.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_CP_SERVICES.CONTEXT%TYPE := NULL,
    p_list_price                   IN NUMBER := NULL,
    p_org_id                       IN NUMBER := NULL,
    p_price_percent                IN NUMBER := NULL,
    x_cp_service_id                OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_service_rec                  Service_Rec_Type;
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
    l_service_rec.CUSTOMER_PRODUCT_ID := p_customer_product_id;
    l_service_rec.CONTRACT_LINE_STATUS_ID := p_contract_line_status_id;
    l_service_rec.CONTRACT_LINE_TEMPLATE_ID := p_contract_line_template_id;
    l_service_rec.CONTRACT_ID := p_contract_id;
    l_service_rec.SERVICE_INVENTORY_ITEM_ID := p_service_inventory_item_id;
    l_service_rec.SERVICE_MANUFACTURING_ORG_ID := p_service_manufacturing_org_id;
    l_service_rec.STATUS_CODE := p_status_code;
    l_service_rec.LAST_CP_SERVICE_TRANSACTION_ID := p_lst_cp_srvic_trnsctin_id;
    l_service_rec.INVOICE_FLAG := p_invoice_flag;
    l_service_rec.COVERAGE_SCHEDULE_ID := p_coverage_schedule_id;
    l_service_rec.PRORATE_FLAG := p_prorate_flag;
    l_service_rec.DURATION_QUANTITY := p_duration_quantity;
    l_service_rec.UNIT_OF_MEASURE_CODE := p_unit_of_measure_code;
    l_service_rec.STARTING_DELAY := p_starting_delay;
    l_service_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
    l_service_rec.BILL_TO_CONTACT_ID := p_bill_to_contact_id;
    l_service_rec.SERVICE_TXN_AVAILABILITY_CODE := p_srvic_txn_vilbility_cd;
    l_service_rec.NEXT_PM_VISIT_DATE := p_next_pm_visit_date;
    l_service_rec.PM_VISITS_COMPLETED := p_pm_visits_completed;
    l_service_rec.LAST_PM_VISIT_DATE := p_last_pm_visit_date;
    l_service_rec.PM_SCHEDULE_ID := p_pm_schedule_id;
    l_service_rec.PM_SCHEDULE_FLAG := p_pm_schedule_flag;
    l_service_rec.CURRENT_MAX_SCHEDULE_DATE := p_current_max_schedule_date;
    l_service_rec.PRICE_LIST_ID := p_price_list_id;
    l_service_rec.SERVICE_ORDER_TYPE := p_service_order_type;
    l_service_rec.INVOICE_COUNT := p_invoice_count;
    l_service_rec.CURRENCY_CODE := p_currency_code;
    l_service_rec.CONVERSION_TYPE := p_conversion_type;
    l_service_rec.CONVERSION_RATE := p_conversion_rate;
    l_service_rec.CONVERSION_DATE := p_conversion_date;
    l_service_rec.ORIGINAL_SERVICE_LINE_ID := p_original_service_line_id;
    l_service_rec.WARRANTY_FLAG := p_warranty_flag;
    l_service_rec.ORIGINAL_START_DATE := p_original_start_date;
    l_service_rec.ORIGINAL_END_DATE := p_original_end_date;
    l_service_rec.SERVICE_DATE_CHANGE := p_service_date_change;
    l_service_rec.WORKFLOW := p_workflow;
    l_service_rec.SHIP_TO_SITE_USE_ID := p_ship_to_site_use_id;
    l_service_rec.ORIGINAL_SYSTEM_LINE_REFERENCE := p_riginl_systm_lin_rfrnc;
    l_service_rec.EXTENDED_PRICE := p_extended_price;
    l_service_rec.DISCOUNT_ID := p_discount_id;
    l_service_rec.TAX_CODE := p_tax_code;
    l_service_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
    l_service_rec.FIRST_BILL_DATE := p_first_bill_date;
    l_service_rec.NEXT_BILL_DATE := p_next_bill_date;
    l_service_rec.CREATION_DATE := p_creation_date;
    l_service_rec.BILL_ON := p_bill_on;
    l_service_rec.CREATED_BY := p_created_by;
    l_service_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_service_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_service_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_service_rec.START_DATE_ACTIVE := p_start_date_active;
    l_service_rec.END_DATE_ACTIVE := p_end_date_active;
    l_service_rec.PRICING_ATTRIBUTE1 := p_pricing_attribute1;
    l_service_rec.PRICING_ATTRIBUTE2 := p_pricing_attribute2;
    l_service_rec.PRICING_ATTRIBUTE3 := p_pricing_attribute3;
    l_service_rec.PRICING_ATTRIBUTE4 := p_pricing_attribute4;
    l_service_rec.PRICING_ATTRIBUTE5 := p_pricing_attribute5;
    l_service_rec.PRICING_ATTRIBUTE6 := p_pricing_attribute6;
    l_service_rec.PRICING_ATTRIBUTE7 := p_pricing_attribute7;
    l_service_rec.PRICING_ATTRIBUTE8 := p_pricing_attribute8;
    l_service_rec.PRICING_ATTRIBUTE9 := p_pricing_attribute9;
    l_service_rec.PRICING_ATTRIBUTE10 := p_pricing_attribute10;
    l_service_rec.PRICING_ATTRIBUTE11 := p_pricing_attribute11;
    l_service_rec.PRICING_ATTRIBUTE12 := p_pricing_attribute12;
    l_service_rec.PRICING_ATTRIBUTE13 := p_pricing_attribute13;
    l_service_rec.PRICING_ATTRIBUTE14 := p_pricing_attribute14;
    l_service_rec.PRICING_ATTRIBUTE15 := p_pricing_attribute15;
    l_service_rec.PRICING_CONTEXT := p_pricing_context;
    l_service_rec.ATTRIBUTE1 := p_attribute1;
    l_service_rec.ATTRIBUTE2 := p_attribute2;
    l_service_rec.ATTRIBUTE3 := p_attribute3;
    l_service_rec.ATTRIBUTE4 := p_attribute4;
    l_service_rec.ATTRIBUTE5 := p_attribute5;
    l_service_rec.ATTRIBUTE6 := p_attribute6;
    l_service_rec.ATTRIBUTE7 := p_attribute7;
    l_service_rec.ATTRIBUTE8 := p_attribute8;
    l_service_rec.ATTRIBUTE9 := p_attribute9;
    l_service_rec.ATTRIBUTE10 := p_attribute10;
    l_service_rec.ATTRIBUTE11 := p_attribute11;
    l_service_rec.ATTRIBUTE12 := p_attribute12;
    l_service_rec.ATTRIBUTE13 := p_attribute13;
    l_service_rec.ATTRIBUTE14 := p_attribute14;
    l_service_rec.ATTRIBUTE15 := p_attribute15;
    l_service_rec.CONTEXT := p_context;
    l_service_rec.LIST_PRICE := p_list_price;
    l_service_rec.ORG_ID := p_org_id;
    l_service_rec.PRICE_PERCENT := p_price_percent;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_service_rec,
      x_cp_service_id
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
    p_cp_service_id                IN NUMBER,
    p_customer_product_id          IN NUMBER,
    p_contract_line_status_id      IN NUMBER,
    p_contract_line_template_id    IN NUMBER,
    p_contract_id                  IN NUMBER,
    p_service_inventory_item_id    IN NUMBER,
    p_service_manufacturing_org_id  IN NUMBER,
    p_status_code                  IN VARCHAR2,
    p_lst_cp_srvic_trnsctin_id     IN NUMBER,
    p_invoice_flag                 IN VARCHAR2,
    p_coverage_schedule_id         IN NUMBER,
    p_prorate_flag                 IN VARCHAR2,
    p_duration_quantity            IN NUMBER,
    p_unit_of_measure_code         IN VARCHAR2,
    p_starting_delay               IN NUMBER,
    p_bill_to_site_use_id          IN NUMBER,
    p_bill_to_contact_id           IN NUMBER,
    p_srvic_txn_vilbility_cd       IN VARCHAR2,
    p_next_pm_visit_date           IN DATE,
    p_pm_visits_completed          IN NUMBER,
    p_last_pm_visit_date           IN DATE,
    p_pm_schedule_id               IN NUMBER,
    p_pm_schedule_flag             IN VARCHAR2,
    p_current_max_schedule_date    IN DATE,
    p_price_list_id                IN NUMBER,
    p_service_order_type           IN VARCHAR2,
    p_invoice_count                IN NUMBER,
    p_currency_code                IN VARCHAR2,
    p_conversion_type              IN VARCHAR2,
    p_conversion_rate              IN NUMBER,
    p_conversion_date              IN DATE,
    p_original_service_line_id     IN NUMBER,
    p_warranty_flag                IN VARCHAR2,
    p_original_start_date          IN DATE,
    p_original_end_date            IN DATE,
    p_service_date_change          IN VARCHAR2,
    p_workflow                     IN VARCHAR2,
    p_ship_to_site_use_id          IN NUMBER,
    p_riginl_systm_lin_rfrnc       IN VARCHAR2,
    p_extended_price               IN NUMBER,
    p_discount_id                  IN NUMBER,
    p_tax_code                     IN VARCHAR2,
    p_billing_frequency_period     IN VARCHAR2,
    p_first_bill_date              IN DATE,
    p_next_bill_date               IN DATE,
    p_creation_date                IN DATE,
    p_bill_on                      IN NUMBER,
    p_created_by                   IN NUMBER,
    p_last_update_date             IN DATE,
    p_last_updated_by              IN NUMBER,
    p_last_update_login            IN NUMBER,
    p_start_date_active            IN DATE,
    p_end_date_active              IN DATE,
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
    p_list_price                   IN NUMBER,
    p_org_id                       IN NUMBER,
    p_price_percent                IN NUMBER) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT *
     FROM CS_CP_SERVICES
    WHERE
      CP_SERVICE_ID = p_cp_service_id
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
      IF (l_object_version_number.CP_SERVICE_ID <> p_cp_service_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CUSTOMER_PRODUCT_ID <> p_customer_product_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CONTRACT_LINE_STATUS_ID <> p_contract_line_status_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CONTRACT_LINE_TEMPLATE_ID <> p_contract_line_template_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CONTRACT_ID <> p_contract_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_INVENTORY_ITEM_ID <> p_service_inventory_item_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_MANUFACTURING_ORG_ID <> p_service_manufacturing_org_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.STATUS_CODE <> p_status_code) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.LAST_CP_SERVICE_TRANSACTION_ID <> p_lst_cp_srvic_trnsctin_id) THEN
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
      IF (l_object_version_number.PRORATE_FLAG <> p_prorate_flag) THEN
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
      IF (l_object_version_number.SERVICE_TXN_AVAILABILITY_CODE <> p_srvic_txn_vilbility_cd) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.NEXT_PM_VISIT_DATE <> p_next_pm_visit_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PM_VISITS_COMPLETED <> p_pm_visits_completed) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.LAST_PM_VISIT_DATE <> p_last_pm_visit_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PM_SCHEDULE_ID <> p_pm_schedule_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PM_SCHEDULE_FLAG <> p_pm_schedule_flag) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CURRENT_MAX_SCHEDULE_DATE <> p_current_max_schedule_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICE_LIST_ID <> p_price_list_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_ORDER_TYPE <> p_service_order_type) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.INVOICE_COUNT <> p_invoice_count) THEN
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
      IF (l_object_version_number.ORIGINAL_SERVICE_LINE_ID <> p_original_service_line_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.WARRANTY_FLAG <> p_warranty_flag) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ORIGINAL_START_DATE <> p_original_start_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ORIGINAL_END_DATE <> p_original_end_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SERVICE_DATE_CHANGE <> p_service_date_change) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.WORKFLOW <> p_workflow) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.SHIP_TO_SITE_USE_ID <> p_ship_to_site_use_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ORIGINAL_SYSTEM_LINE_REFERENCE <> p_riginl_systm_lin_rfrnc) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.EXTENDED_PRICE <> p_extended_price) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.DISCOUNT_ID <> p_discount_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.TAX_CODE <> p_tax_code) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.BILLING_FREQUENCY_PERIOD <> p_billing_frequency_period) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.FIRST_BILL_DATE <> p_first_bill_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.NEXT_BILL_DATE <> p_next_bill_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CREATION_DATE <> p_creation_date) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.BILL_ON <> p_bill_on) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.CREATED_BY <> p_created_by) THEN
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
      IF (l_object_version_number.LAST_UPDATE_LOGIN <> p_last_update_login) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.START_DATE_ACTIVE <> p_start_date_active) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.END_DATE_ACTIVE <> p_end_date_active) THEN
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
      IF (l_object_version_number.LIST_PRICE <> p_list_price) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.ORG_ID <> p_org_id) THEN
        TAPI_DEV_KIT.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_object_version_number.PRICE_PERCENT <> p_price_percent) THEN
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
    p_service_val_rec              IN Service_Val_Rec_Type := G_MISS_SERVICE_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_service_rec                  Service_Rec_Type;
    l_def_service_rec              Service_Rec_Type;
    FUNCTION populate_new_record (
      p_service_rec	IN Service_Rec_Type,
      x_service_rec	OUT Service_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR cs_cp_services_pk_csr (p_cp_service_id      IN NUMBER) IS
      SELECT *
        FROM Cs_Cp_Services
       WHERE cs_cp_services.cp_service_id = p_cp_service_id;
      l_cs_cp_services_pk            cs_cp_services_pk_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_service_rec := p_service_rec;
      -- Get current database values
      OPEN cs_cp_services_pk_csr (p_service_rec.cp_service_id);
      FETCH cs_cp_services_pk_csr INTO l_cs_cp_services_pk;
      l_row_notfound := cs_cp_services_pk_csr%NOTFOUND;
      CLOSE cs_cp_services_pk_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_service_rec.cp_service_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.cp_service_id := l_cs_cp_services_pk.cp_service_id;
      END IF;
      IF (x_service_rec.customer_product_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.customer_product_id := l_cs_cp_services_pk.customer_product_id;
      END IF;
      IF (x_service_rec.contract_line_status_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.contract_line_status_id := l_cs_cp_services_pk.contract_line_status_id;
      END IF;
      IF (x_service_rec.contract_line_template_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.contract_line_template_id := l_cs_cp_services_pk.contract_line_template_id;
      END IF;
      IF (x_service_rec.contract_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.contract_id := l_cs_cp_services_pk.contract_id;
      END IF;
      IF (x_service_rec.service_inventory_item_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.service_inventory_item_id := l_cs_cp_services_pk.service_inventory_item_id;
      END IF;
      IF (x_service_rec.service_manufacturing_org_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.service_manufacturing_org_id := l_cs_cp_services_pk.service_manufacturing_org_id;
      END IF;
      IF (x_service_rec.status_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.status_code := l_cs_cp_services_pk.status_code;
      END IF;
      IF (x_service_rec.last_cp_service_transaction_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.last_cp_service_transaction_id := l_cs_cp_services_pk.last_cp_service_transaction_id;
      END IF;
      IF (x_service_rec.invoice_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.invoice_flag := l_cs_cp_services_pk.invoice_flag;
      END IF;
      IF (x_service_rec.coverage_schedule_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.coverage_schedule_id := l_cs_cp_services_pk.coverage_schedule_id;
      END IF;
      IF (x_service_rec.prorate_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.prorate_flag := l_cs_cp_services_pk.prorate_flag;
      END IF;
      IF (x_service_rec.duration_quantity = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.duration_quantity := l_cs_cp_services_pk.duration_quantity;
      END IF;
      IF (x_service_rec.unit_of_measure_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.unit_of_measure_code := l_cs_cp_services_pk.unit_of_measure_code;
      END IF;
      IF (x_service_rec.starting_delay = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.starting_delay := l_cs_cp_services_pk.starting_delay;
      END IF;
      IF (x_service_rec.bill_to_site_use_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.bill_to_site_use_id := l_cs_cp_services_pk.bill_to_site_use_id;
      END IF;
      IF (x_service_rec.bill_to_contact_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.bill_to_contact_id := l_cs_cp_services_pk.bill_to_contact_id;
      END IF;
      IF (x_service_rec.service_txn_availability_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.service_txn_availability_code := l_cs_cp_services_pk.service_txn_availability_code;
      END IF;
      IF (x_service_rec.next_pm_visit_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.next_pm_visit_date := l_cs_cp_services_pk.next_pm_visit_date;
      END IF;
      IF (x_service_rec.pm_visits_completed = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.pm_visits_completed := l_cs_cp_services_pk.pm_visits_completed;
      END IF;
      IF (x_service_rec.last_pm_visit_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.last_pm_visit_date := l_cs_cp_services_pk.last_pm_visit_date;
      END IF;
      IF (x_service_rec.pm_schedule_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.pm_schedule_id := l_cs_cp_services_pk.pm_schedule_id;
      END IF;
      IF (x_service_rec.pm_schedule_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pm_schedule_flag := l_cs_cp_services_pk.pm_schedule_flag;
      END IF;
      IF (x_service_rec.current_max_schedule_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.current_max_schedule_date := l_cs_cp_services_pk.current_max_schedule_date;
      END IF;
      IF (x_service_rec.price_list_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.price_list_id := l_cs_cp_services_pk.price_list_id;
      END IF;
      IF (x_service_rec.service_order_type = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.service_order_type := l_cs_cp_services_pk.service_order_type;
      END IF;
      IF (x_service_rec.invoice_count = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.invoice_count := l_cs_cp_services_pk.invoice_count;
      END IF;
      IF (x_service_rec.currency_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.currency_code := l_cs_cp_services_pk.currency_code;
      END IF;
      IF (x_service_rec.conversion_type = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.conversion_type := l_cs_cp_services_pk.conversion_type;
      END IF;
      IF (x_service_rec.conversion_rate = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.conversion_rate := l_cs_cp_services_pk.conversion_rate;
      END IF;
      IF (x_service_rec.conversion_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.conversion_date := l_cs_cp_services_pk.conversion_date;
      END IF;
      IF (x_service_rec.original_service_line_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.original_service_line_id := l_cs_cp_services_pk.original_service_line_id;
      END IF;
      IF (x_service_rec.warranty_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.warranty_flag := l_cs_cp_services_pk.warranty_flag;
      END IF;
      IF (x_service_rec.original_start_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.original_start_date := l_cs_cp_services_pk.original_start_date;
      END IF;
      IF (x_service_rec.original_end_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.original_end_date := l_cs_cp_services_pk.original_end_date;
      END IF;
      IF (x_service_rec.service_date_change = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.service_date_change := l_cs_cp_services_pk.service_date_change;
      END IF;
      IF (x_service_rec.workflow = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.workflow := l_cs_cp_services_pk.workflow;
      END IF;
      IF (x_service_rec.ship_to_site_use_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.ship_to_site_use_id := l_cs_cp_services_pk.ship_to_site_use_id;
      END IF;
      IF (x_service_rec.original_system_line_reference = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.original_system_line_reference := l_cs_cp_services_pk.original_system_line_reference;
      END IF;
      IF (x_service_rec.extended_price = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.extended_price := l_cs_cp_services_pk.extended_price;
      END IF;
      IF (x_service_rec.discount_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.discount_id := l_cs_cp_services_pk.discount_id;
      END IF;
      IF (x_service_rec.tax_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.tax_code := l_cs_cp_services_pk.tax_code;
      END IF;
      IF (x_service_rec.billing_frequency_period = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.billing_frequency_period := l_cs_cp_services_pk.billing_frequency_period;
      END IF;
      IF (x_service_rec.first_bill_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.first_bill_date := l_cs_cp_services_pk.first_bill_date;
      END IF;
      IF (x_service_rec.next_bill_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.next_bill_date := l_cs_cp_services_pk.next_bill_date;
      END IF;
      IF (x_service_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.creation_date := l_cs_cp_services_pk.creation_date;
      END IF;
      IF (x_service_rec.bill_on = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.bill_on := l_cs_cp_services_pk.bill_on;
      END IF;
      IF (x_service_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.created_by := l_cs_cp_services_pk.created_by;
      END IF;
      IF (x_service_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.last_update_date := l_cs_cp_services_pk.last_update_date;
      END IF;
      IF (x_service_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.last_updated_by := l_cs_cp_services_pk.last_updated_by;
      END IF;
      IF (x_service_rec.last_update_login = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.last_update_login := l_cs_cp_services_pk.last_update_login;
      END IF;
      IF (x_service_rec.start_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.start_date_active := l_cs_cp_services_pk.start_date_active;
      END IF;
      IF (x_service_rec.end_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_service_rec.end_date_active := l_cs_cp_services_pk.end_date_active;
      END IF;
      IF (x_service_rec.pricing_attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute1 := l_cs_cp_services_pk.pricing_attribute1;
      END IF;
      IF (x_service_rec.pricing_attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute2 := l_cs_cp_services_pk.pricing_attribute2;
      END IF;
      IF (x_service_rec.pricing_attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute3 := l_cs_cp_services_pk.pricing_attribute3;
      END IF;
      IF (x_service_rec.pricing_attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute4 := l_cs_cp_services_pk.pricing_attribute4;
      END IF;
      IF (x_service_rec.pricing_attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute5 := l_cs_cp_services_pk.pricing_attribute5;
      END IF;
      IF (x_service_rec.pricing_attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute6 := l_cs_cp_services_pk.pricing_attribute6;
      END IF;
      IF (x_service_rec.pricing_attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute7 := l_cs_cp_services_pk.pricing_attribute7;
      END IF;
      IF (x_service_rec.pricing_attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute8 := l_cs_cp_services_pk.pricing_attribute8;
      END IF;
      IF (x_service_rec.pricing_attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute9 := l_cs_cp_services_pk.pricing_attribute9;
      END IF;
      IF (x_service_rec.pricing_attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute10 := l_cs_cp_services_pk.pricing_attribute10;
      END IF;
      IF (x_service_rec.pricing_attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute11 := l_cs_cp_services_pk.pricing_attribute11;
      END IF;
      IF (x_service_rec.pricing_attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute12 := l_cs_cp_services_pk.pricing_attribute12;
      END IF;
      IF (x_service_rec.pricing_attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute13 := l_cs_cp_services_pk.pricing_attribute13;
      END IF;
      IF (x_service_rec.pricing_attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute14 := l_cs_cp_services_pk.pricing_attribute14;
      END IF;
      IF (x_service_rec.pricing_attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_attribute15 := l_cs_cp_services_pk.pricing_attribute15;
      END IF;
      IF (x_service_rec.pricing_context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.pricing_context := l_cs_cp_services_pk.pricing_context;
      END IF;
      IF (x_service_rec.attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute1 := l_cs_cp_services_pk.attribute1;
      END IF;
      IF (x_service_rec.attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute2 := l_cs_cp_services_pk.attribute2;
      END IF;
      IF (x_service_rec.attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute3 := l_cs_cp_services_pk.attribute3;
      END IF;
      IF (x_service_rec.attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute4 := l_cs_cp_services_pk.attribute4;
      END IF;
      IF (x_service_rec.attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute5 := l_cs_cp_services_pk.attribute5;
      END IF;
      IF (x_service_rec.attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute6 := l_cs_cp_services_pk.attribute6;
      END IF;
      IF (x_service_rec.attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute7 := l_cs_cp_services_pk.attribute7;
      END IF;
      IF (x_service_rec.attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute8 := l_cs_cp_services_pk.attribute8;
      END IF;
      IF (x_service_rec.attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute9 := l_cs_cp_services_pk.attribute9;
      END IF;
      IF (x_service_rec.attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute10 := l_cs_cp_services_pk.attribute10;
      END IF;
      IF (x_service_rec.attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute11 := l_cs_cp_services_pk.attribute11;
      END IF;
      IF (x_service_rec.attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute12 := l_cs_cp_services_pk.attribute12;
      END IF;
      IF (x_service_rec.attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute13 := l_cs_cp_services_pk.attribute13;
      END IF;
      IF (x_service_rec.attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute14 := l_cs_cp_services_pk.attribute14;
      END IF;
      IF (x_service_rec.attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.attribute15 := l_cs_cp_services_pk.attribute15;
      END IF;
      IF (x_service_rec.context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_service_rec.context := l_cs_cp_services_pk.context;
      END IF;
      IF (x_service_rec.list_price = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.list_price := l_cs_cp_services_pk.list_price;
      END IF;
      IF (x_service_rec.org_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.org_id := l_cs_cp_services_pk.org_id;
      END IF;
      IF (x_service_rec.price_percent = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_service_rec.price_percent := l_cs_cp_services_pk.price_percent;
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
    migrate(p_service_val_rec, l_service_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_service_rec,    ---- IN
      l_def_service_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_service_rec, l_def_service_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_service_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_service_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_CP_SERVICES
    SET
        CP_SERVICE_ID = l_def_service_rec.cp_service_id ,
        CUSTOMER_PRODUCT_ID = l_def_service_rec.customer_product_id ,
        CONTRACT_LINE_STATUS_ID = l_def_service_rec.contract_line_status_id ,
        CONTRACT_LINE_TEMPLATE_ID = l_def_service_rec.contract_line_template_id ,
        CONTRACT_ID = l_def_service_rec.contract_id ,
        SERVICE_INVENTORY_ITEM_ID = l_def_service_rec.service_inventory_item_id ,
        SERVICE_MANUFACTURING_ORG_ID = l_def_service_rec.service_manufacturing_org_id ,
        STATUS_CODE = l_def_service_rec.status_code ,
        LAST_CP_SERVICE_TRANSACTION_ID = l_def_service_rec.last_cp_service_transaction_id ,
        INVOICE_FLAG = l_def_service_rec.invoice_flag ,
        COVERAGE_SCHEDULE_ID = l_def_service_rec.coverage_schedule_id ,
        PRORATE_FLAG = l_def_service_rec.prorate_flag ,
        DURATION_QUANTITY = l_def_service_rec.duration_quantity ,
        UNIT_OF_MEASURE_CODE = l_def_service_rec.unit_of_measure_code ,
        STARTING_DELAY = l_def_service_rec.starting_delay ,
        BILL_TO_SITE_USE_ID = l_def_service_rec.bill_to_site_use_id ,
        BILL_TO_CONTACT_ID = l_def_service_rec.bill_to_contact_id ,
        SERVICE_TXN_AVAILABILITY_CODE = l_def_service_rec.service_txn_availability_code ,
        NEXT_PM_VISIT_DATE = l_def_service_rec.next_pm_visit_date ,
        PM_VISITS_COMPLETED = l_def_service_rec.pm_visits_completed ,
        LAST_PM_VISIT_DATE = l_def_service_rec.last_pm_visit_date ,
        PM_SCHEDULE_ID = l_def_service_rec.pm_schedule_id ,
        PM_SCHEDULE_FLAG = l_def_service_rec.pm_schedule_flag ,
        CURRENT_MAX_SCHEDULE_DATE = l_def_service_rec.current_max_schedule_date ,
        PRICE_LIST_ID = l_def_service_rec.price_list_id ,
        SERVICE_ORDER_TYPE = l_def_service_rec.service_order_type ,
        INVOICE_COUNT = l_def_service_rec.invoice_count ,
        CURRENCY_CODE = l_def_service_rec.currency_code ,
        CONVERSION_TYPE = l_def_service_rec.conversion_type ,
        CONVERSION_RATE = l_def_service_rec.conversion_rate ,
        CONVERSION_DATE = l_def_service_rec.conversion_date ,
        ORIGINAL_SERVICE_LINE_ID = l_def_service_rec.original_service_line_id ,
        WARRANTY_FLAG = l_def_service_rec.warranty_flag ,
        ORIGINAL_START_DATE = l_def_service_rec.original_start_date ,
        ORIGINAL_END_DATE = l_def_service_rec.original_end_date ,
        SERVICE_DATE_CHANGE = l_def_service_rec.service_date_change ,
        WORKFLOW = l_def_service_rec.workflow ,
        SHIP_TO_SITE_USE_ID = l_def_service_rec.ship_to_site_use_id ,
        ORIGINAL_SYSTEM_LINE_REFERENCE = l_def_service_rec.original_system_line_reference ,
        EXTENDED_PRICE = l_def_service_rec.extended_price ,
        DISCOUNT_ID = l_def_service_rec.discount_id ,
        TAX_CODE = l_def_service_rec.tax_code ,
        BILLING_FREQUENCY_PERIOD = l_def_service_rec.billing_frequency_period ,
        FIRST_BILL_DATE = l_def_service_rec.first_bill_date ,
        NEXT_BILL_DATE = l_def_service_rec.next_bill_date ,
        CREATION_DATE = l_def_service_rec.creation_date ,
        BILL_ON = l_def_service_rec.bill_on ,
        CREATED_BY = l_def_service_rec.created_by ,
        LAST_UPDATE_DATE = l_def_service_rec.last_update_date ,
        LAST_UPDATED_BY = l_def_service_rec.last_updated_by ,
        LAST_UPDATE_LOGIN = l_def_service_rec.last_update_login ,
        START_DATE_ACTIVE = l_def_service_rec.start_date_active ,
        END_DATE_ACTIVE = l_def_service_rec.end_date_active ,
        PRICING_ATTRIBUTE1 = l_def_service_rec.pricing_attribute1 ,
        PRICING_ATTRIBUTE2 = l_def_service_rec.pricing_attribute2 ,
        PRICING_ATTRIBUTE3 = l_def_service_rec.pricing_attribute3 ,
        PRICING_ATTRIBUTE4 = l_def_service_rec.pricing_attribute4 ,
        PRICING_ATTRIBUTE5 = l_def_service_rec.pricing_attribute5 ,
        PRICING_ATTRIBUTE6 = l_def_service_rec.pricing_attribute6 ,
        PRICING_ATTRIBUTE7 = l_def_service_rec.pricing_attribute7 ,
        PRICING_ATTRIBUTE8 = l_def_service_rec.pricing_attribute8 ,
        PRICING_ATTRIBUTE9 = l_def_service_rec.pricing_attribute9 ,
        PRICING_ATTRIBUTE10 = l_def_service_rec.pricing_attribute10 ,
        PRICING_ATTRIBUTE11 = l_def_service_rec.pricing_attribute11 ,
        PRICING_ATTRIBUTE12 = l_def_service_rec.pricing_attribute12 ,
        PRICING_ATTRIBUTE13 = l_def_service_rec.pricing_attribute13 ,
        PRICING_ATTRIBUTE14 = l_def_service_rec.pricing_attribute14 ,
        PRICING_ATTRIBUTE15 = l_def_service_rec.pricing_attribute15 ,
        PRICING_CONTEXT = l_def_service_rec.pricing_context ,
        ATTRIBUTE1 = l_def_service_rec.attribute1 ,
        ATTRIBUTE2 = l_def_service_rec.attribute2 ,
        ATTRIBUTE3 = l_def_service_rec.attribute3 ,
        ATTRIBUTE4 = l_def_service_rec.attribute4 ,
        ATTRIBUTE5 = l_def_service_rec.attribute5 ,
        ATTRIBUTE6 = l_def_service_rec.attribute6 ,
        ATTRIBUTE7 = l_def_service_rec.attribute7 ,
        ATTRIBUTE8 = l_def_service_rec.attribute8 ,
        ATTRIBUTE9 = l_def_service_rec.attribute9 ,
        ATTRIBUTE10 = l_def_service_rec.attribute10 ,
        ATTRIBUTE11 = l_def_service_rec.attribute11 ,
        ATTRIBUTE12 = l_def_service_rec.attribute12 ,
        ATTRIBUTE13 = l_def_service_rec.attribute13 ,
        ATTRIBUTE14 = l_def_service_rec.attribute14 ,
        ATTRIBUTE15 = l_def_service_rec.attribute15 ,
        CONTEXT = l_def_service_rec.context ,
        LIST_PRICE = l_def_service_rec.list_price ,
        ORG_ID = l_def_service_rec.org_id ,
        PRICE_PERCENT = l_def_service_rec.price_percent
        WHERE
          CP_SERVICE_ID = l_def_service_rec.cp_service_id
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
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_customer_product_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_line_status_id      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_line_template_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_inventory_item_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_manufacturing_org_id  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_status_code                  IN CS_CP_SERVICES.STATUS_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_lst_cp_srvic_trnsctin_id     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_invoice_flag                 IN CS_CP_SERVICES.INVOICE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_schedule_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_prorate_flag                 IN CS_CP_SERVICES.PRORATE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_duration_quantity            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_unit_of_measure_code         IN CS_CP_SERVICES.UNIT_OF_MEASURE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_starting_delay               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_contact_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_srvic_txn_vilbility_cd       IN CS_CP_SERVICES.SERVICE_TXN_AVAILABILITY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_next_pm_visit_date           IN CS_CP_SERVICES.NEXT_PM_VISIT_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_pm_visits_completed          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_pm_visit_date           IN CS_CP_SERVICES.LAST_PM_VISIT_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_pm_schedule_id               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_pm_schedule_flag             IN CS_CP_SERVICES.PM_SCHEDULE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_current_max_schedule_date    IN CS_CP_SERVICES.CURRENT_MAX_SCHEDULE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_type           IN CS_CP_SERVICES.SERVICE_ORDER_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_invoice_count                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CP_SERVICES.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type              IN CS_CP_SERVICES.CONVERSION_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CP_SERVICES.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_original_service_line_id     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_warranty_flag                IN CS_CP_SERVICES.WARRANTY_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_original_start_date          IN CS_CP_SERVICES.ORIGINAL_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_original_end_date            IN CS_CP_SERVICES.ORIGINAL_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_service_date_change          IN CS_CP_SERVICES.SERVICE_DATE_CHANGE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow                     IN CS_CP_SERVICES.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_ship_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_riginl_systm_lin_rfrnc       IN CS_CP_SERVICES.ORIGINAL_SYSTEM_LINE_REFERENCE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_extended_price               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_tax_code                     IN CS_CP_SERVICES.TAX_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_billing_frequency_period     IN CS_CP_SERVICES.BILLING_FREQUENCY_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_first_bill_date              IN CS_CP_SERVICES.FIRST_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_next_bill_date               IN CS_CP_SERVICES.NEXT_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_creation_date                IN CS_CP_SERVICES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_bill_on                      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_CP_SERVICES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CP_SERVICES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CP_SERVICES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_pricing_attribute1           IN CS_CP_SERVICES.PRICING_ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute2           IN CS_CP_SERVICES.PRICING_ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute3           IN CS_CP_SERVICES.PRICING_ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute4           IN CS_CP_SERVICES.PRICING_ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute5           IN CS_CP_SERVICES.PRICING_ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute6           IN CS_CP_SERVICES.PRICING_ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute7           IN CS_CP_SERVICES.PRICING_ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute8           IN CS_CP_SERVICES.PRICING_ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute9           IN CS_CP_SERVICES.PRICING_ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute10          IN CS_CP_SERVICES.PRICING_ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute11          IN CS_CP_SERVICES.PRICING_ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute12          IN CS_CP_SERVICES.PRICING_ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute13          IN CS_CP_SERVICES.PRICING_ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute14          IN CS_CP_SERVICES.PRICING_ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute15          IN CS_CP_SERVICES.PRICING_ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_context              IN CS_CP_SERVICES.PRICING_CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute1                   IN CS_CP_SERVICES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CP_SERVICES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CP_SERVICES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CP_SERVICES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CP_SERVICES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CP_SERVICES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CP_SERVICES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CP_SERVICES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CP_SERVICES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CP_SERVICES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CP_SERVICES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CP_SERVICES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CP_SERVICES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CP_SERVICES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CP_SERVICES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CP_SERVICES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_list_price                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_org_id                       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_price_percent                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_service_rec                  Service_Val_Rec_Type;
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
    l_service_rec.CP_SERVICE_ID := p_cp_service_id;
    l_service_rec.CUSTOMER_PRODUCT_ID := p_customer_product_id;
    l_service_rec.CONTRACT_LINE_STATUS_ID := p_contract_line_status_id;
    l_service_rec.CONTRACT_LINE_TEMPLATE_ID := p_contract_line_template_id;
    l_service_rec.CONTRACT_ID := p_contract_id;
    l_service_rec.SERVICE_INVENTORY_ITEM_ID := p_service_inventory_item_id;
    l_service_rec.SERVICE_MANUFACTURING_ORG_ID := p_service_manufacturing_org_id;
    l_service_rec.STATUS_CODE := p_status_code;
    l_service_rec.LAST_CP_SERVICE_TRANSACTION_ID := p_lst_cp_srvic_trnsctin_id;
    l_service_rec.INVOICE_FLAG := p_invoice_flag;
    l_service_rec.COVERAGE_SCHEDULE_ID := p_coverage_schedule_id;
    l_service_rec.PRORATE_FLAG := p_prorate_flag;
    l_service_rec.DURATION_QUANTITY := p_duration_quantity;
    l_service_rec.UNIT_OF_MEASURE_CODE := p_unit_of_measure_code;
    l_service_rec.STARTING_DELAY := p_starting_delay;
    l_service_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
    l_service_rec.BILL_TO_CONTACT_ID := p_bill_to_contact_id;
    l_service_rec.SERVICE_TXN_AVAILABILITY_CODE := p_srvic_txn_vilbility_cd;
    l_service_rec.NEXT_PM_VISIT_DATE := p_next_pm_visit_date;
    l_service_rec.PM_VISITS_COMPLETED := p_pm_visits_completed;
    l_service_rec.LAST_PM_VISIT_DATE := p_last_pm_visit_date;
    l_service_rec.PM_SCHEDULE_ID := p_pm_schedule_id;
    l_service_rec.PM_SCHEDULE_FLAG := p_pm_schedule_flag;
    l_service_rec.CURRENT_MAX_SCHEDULE_DATE := p_current_max_schedule_date;
    l_service_rec.PRICE_LIST_ID := p_price_list_id;
    l_service_rec.SERVICE_ORDER_TYPE := p_service_order_type;
    l_service_rec.INVOICE_COUNT := p_invoice_count;
    l_service_rec.CURRENCY_CODE := p_currency_code;
    l_service_rec.CONVERSION_TYPE := p_conversion_type;
    l_service_rec.CONVERSION_RATE := p_conversion_rate;
    l_service_rec.CONVERSION_DATE := p_conversion_date;
    l_service_rec.ORIGINAL_SERVICE_LINE_ID := p_original_service_line_id;
    l_service_rec.WARRANTY_FLAG := p_warranty_flag;
    l_service_rec.ORIGINAL_START_DATE := p_original_start_date;
    l_service_rec.ORIGINAL_END_DATE := p_original_end_date;
    l_service_rec.SERVICE_DATE_CHANGE := p_service_date_change;
    l_service_rec.WORKFLOW := p_workflow;
    l_service_rec.SHIP_TO_SITE_USE_ID := p_ship_to_site_use_id;
    l_service_rec.ORIGINAL_SYSTEM_LINE_REFERENCE := p_riginl_systm_lin_rfrnc;
    l_service_rec.EXTENDED_PRICE := p_extended_price;
    l_service_rec.DISCOUNT_ID := p_discount_id;
    l_service_rec.TAX_CODE := p_tax_code;
    l_service_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
    l_service_rec.FIRST_BILL_DATE := p_first_bill_date;
    l_service_rec.NEXT_BILL_DATE := p_next_bill_date;
    l_service_rec.CREATION_DATE := p_creation_date;
    l_service_rec.BILL_ON := p_bill_on;
    l_service_rec.CREATED_BY := p_created_by;
    l_service_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_service_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_service_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_service_rec.START_DATE_ACTIVE := p_start_date_active;
    l_service_rec.END_DATE_ACTIVE := p_end_date_active;
    l_service_rec.PRICING_ATTRIBUTE1 := p_pricing_attribute1;
    l_service_rec.PRICING_ATTRIBUTE2 := p_pricing_attribute2;
    l_service_rec.PRICING_ATTRIBUTE3 := p_pricing_attribute3;
    l_service_rec.PRICING_ATTRIBUTE4 := p_pricing_attribute4;
    l_service_rec.PRICING_ATTRIBUTE5 := p_pricing_attribute5;
    l_service_rec.PRICING_ATTRIBUTE6 := p_pricing_attribute6;
    l_service_rec.PRICING_ATTRIBUTE7 := p_pricing_attribute7;
    l_service_rec.PRICING_ATTRIBUTE8 := p_pricing_attribute8;
    l_service_rec.PRICING_ATTRIBUTE9 := p_pricing_attribute9;
    l_service_rec.PRICING_ATTRIBUTE10 := p_pricing_attribute10;
    l_service_rec.PRICING_ATTRIBUTE11 := p_pricing_attribute11;
    l_service_rec.PRICING_ATTRIBUTE12 := p_pricing_attribute12;
    l_service_rec.PRICING_ATTRIBUTE13 := p_pricing_attribute13;
    l_service_rec.PRICING_ATTRIBUTE14 := p_pricing_attribute14;
    l_service_rec.PRICING_ATTRIBUTE15 := p_pricing_attribute15;
    l_service_rec.PRICING_CONTEXT := p_pricing_context;
    l_service_rec.ATTRIBUTE1 := p_attribute1;
    l_service_rec.ATTRIBUTE2 := p_attribute2;
    l_service_rec.ATTRIBUTE3 := p_attribute3;
    l_service_rec.ATTRIBUTE4 := p_attribute4;
    l_service_rec.ATTRIBUTE5 := p_attribute5;
    l_service_rec.ATTRIBUTE6 := p_attribute6;
    l_service_rec.ATTRIBUTE7 := p_attribute7;
    l_service_rec.ATTRIBUTE8 := p_attribute8;
    l_service_rec.ATTRIBUTE9 := p_attribute9;
    l_service_rec.ATTRIBUTE10 := p_attribute10;
    l_service_rec.ATTRIBUTE11 := p_attribute11;
    l_service_rec.ATTRIBUTE12 := p_attribute12;
    l_service_rec.ATTRIBUTE13 := p_attribute13;
    l_service_rec.ATTRIBUTE14 := p_attribute14;
    l_service_rec.ATTRIBUTE15 := p_attribute15;
    l_service_rec.CONTEXT := p_context;
    l_service_rec.LIST_PRICE := p_list_price;
    l_service_rec.ORG_ID := p_org_id;
    l_service_rec.PRICE_PERCENT := p_price_percent;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_service_rec
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
    p_cp_service_id                IN NUMBER) IS
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
    DELETE  FROM CS_CP_SERVICES
    WHERE
      CP_SERVICE_ID = p_cp_service_id
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
    p_service_val_rec              IN Service_Val_Rec_Type := G_MISS_SERVICE_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_service_rec                  Service_Rec_Type;
    l_def_service_rec              Service_Rec_Type;
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
    migrate(p_service_val_rec, l_service_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_service_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_service_rec);
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
    p_cp_service_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_customer_product_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_line_status_id      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_line_template_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_contract_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_inventory_item_id    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_manufacturing_org_id  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_status_code                  IN CS_CP_SERVICES.STATUS_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_lst_cp_srvic_trnsctin_id     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_invoice_flag                 IN CS_CP_SERVICES.INVOICE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_schedule_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_prorate_flag                 IN CS_CP_SERVICES.PRORATE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_duration_quantity            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_unit_of_measure_code         IN CS_CP_SERVICES.UNIT_OF_MEASURE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_starting_delay               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_bill_to_contact_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_srvic_txn_vilbility_cd       IN CS_CP_SERVICES.SERVICE_TXN_AVAILABILITY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_next_pm_visit_date           IN CS_CP_SERVICES.NEXT_PM_VISIT_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_pm_visits_completed          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_pm_visit_date           IN CS_CP_SERVICES.LAST_PM_VISIT_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_pm_schedule_id               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_pm_schedule_flag             IN CS_CP_SERVICES.PM_SCHEDULE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_current_max_schedule_date    IN CS_CP_SERVICES.CURRENT_MAX_SCHEDULE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_service_order_type           IN CS_CP_SERVICES.SERVICE_ORDER_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_invoice_count                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CP_SERVICES.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type              IN CS_CP_SERVICES.CONVERSION_TYPE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CP_SERVICES.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_original_service_line_id     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_warranty_flag                IN CS_CP_SERVICES.WARRANTY_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_original_start_date          IN CS_CP_SERVICES.ORIGINAL_START_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_original_end_date            IN CS_CP_SERVICES.ORIGINAL_END_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_service_date_change          IN CS_CP_SERVICES.SERVICE_DATE_CHANGE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow                     IN CS_CP_SERVICES.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_ship_to_site_use_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_riginl_systm_lin_rfrnc       IN CS_CP_SERVICES.ORIGINAL_SYSTEM_LINE_REFERENCE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_extended_price               IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_tax_code                     IN CS_CP_SERVICES.TAX_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_billing_frequency_period     IN CS_CP_SERVICES.BILLING_FREQUENCY_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_first_bill_date              IN CS_CP_SERVICES.FIRST_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_next_bill_date               IN CS_CP_SERVICES.NEXT_BILL_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_creation_date                IN CS_CP_SERVICES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_bill_on                      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_CP_SERVICES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CP_SERVICES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CP_SERVICES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_pricing_attribute1           IN CS_CP_SERVICES.PRICING_ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute2           IN CS_CP_SERVICES.PRICING_ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute3           IN CS_CP_SERVICES.PRICING_ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute4           IN CS_CP_SERVICES.PRICING_ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute5           IN CS_CP_SERVICES.PRICING_ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute6           IN CS_CP_SERVICES.PRICING_ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute7           IN CS_CP_SERVICES.PRICING_ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute8           IN CS_CP_SERVICES.PRICING_ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute9           IN CS_CP_SERVICES.PRICING_ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute10          IN CS_CP_SERVICES.PRICING_ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute11          IN CS_CP_SERVICES.PRICING_ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute12          IN CS_CP_SERVICES.PRICING_ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute13          IN CS_CP_SERVICES.PRICING_ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute14          IN CS_CP_SERVICES.PRICING_ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_attribute15          IN CS_CP_SERVICES.PRICING_ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_pricing_context              IN CS_CP_SERVICES.PRICING_CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute1                   IN CS_CP_SERVICES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CP_SERVICES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CP_SERVICES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CP_SERVICES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CP_SERVICES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CP_SERVICES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CP_SERVICES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CP_SERVICES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CP_SERVICES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CP_SERVICES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CP_SERVICES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CP_SERVICES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CP_SERVICES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CP_SERVICES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CP_SERVICES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CP_SERVICES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_list_price                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_org_id                       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_price_percent                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_service_rec                  Service_Val_Rec_Type;
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
    l_service_rec.CP_SERVICE_ID := p_cp_service_id;
    l_service_rec.CUSTOMER_PRODUCT_ID := p_customer_product_id;
    l_service_rec.CONTRACT_LINE_STATUS_ID := p_contract_line_status_id;
    l_service_rec.CONTRACT_LINE_TEMPLATE_ID := p_contract_line_template_id;
    l_service_rec.CONTRACT_ID := p_contract_id;
    l_service_rec.SERVICE_INVENTORY_ITEM_ID := p_service_inventory_item_id;
    l_service_rec.SERVICE_MANUFACTURING_ORG_ID := p_service_manufacturing_org_id;
    l_service_rec.STATUS_CODE := p_status_code;
    l_service_rec.LAST_CP_SERVICE_TRANSACTION_ID := p_lst_cp_srvic_trnsctin_id;
    l_service_rec.INVOICE_FLAG := p_invoice_flag;
    l_service_rec.COVERAGE_SCHEDULE_ID := p_coverage_schedule_id;
    l_service_rec.PRORATE_FLAG := p_prorate_flag;
    l_service_rec.DURATION_QUANTITY := p_duration_quantity;
    l_service_rec.UNIT_OF_MEASURE_CODE := p_unit_of_measure_code;
    l_service_rec.STARTING_DELAY := p_starting_delay;
    l_service_rec.BILL_TO_SITE_USE_ID := p_bill_to_site_use_id;
    l_service_rec.BILL_TO_CONTACT_ID := p_bill_to_contact_id;
    l_service_rec.SERVICE_TXN_AVAILABILITY_CODE := p_srvic_txn_vilbility_cd;
    l_service_rec.NEXT_PM_VISIT_DATE := p_next_pm_visit_date;
    l_service_rec.PM_VISITS_COMPLETED := p_pm_visits_completed;
    l_service_rec.LAST_PM_VISIT_DATE := p_last_pm_visit_date;
    l_service_rec.PM_SCHEDULE_ID := p_pm_schedule_id;
    l_service_rec.PM_SCHEDULE_FLAG := p_pm_schedule_flag;
    l_service_rec.CURRENT_MAX_SCHEDULE_DATE := p_current_max_schedule_date;
    l_service_rec.PRICE_LIST_ID := p_price_list_id;
    l_service_rec.SERVICE_ORDER_TYPE := p_service_order_type;
    l_service_rec.INVOICE_COUNT := p_invoice_count;
    l_service_rec.CURRENCY_CODE := p_currency_code;
    l_service_rec.CONVERSION_TYPE := p_conversion_type;
    l_service_rec.CONVERSION_RATE := p_conversion_rate;
    l_service_rec.CONVERSION_DATE := p_conversion_date;
    l_service_rec.ORIGINAL_SERVICE_LINE_ID := p_original_service_line_id;
    l_service_rec.WARRANTY_FLAG := p_warranty_flag;
    l_service_rec.ORIGINAL_START_DATE := p_original_start_date;
    l_service_rec.ORIGINAL_END_DATE := p_original_end_date;
    l_service_rec.SERVICE_DATE_CHANGE := p_service_date_change;
    l_service_rec.WORKFLOW := p_workflow;
    l_service_rec.SHIP_TO_SITE_USE_ID := p_ship_to_site_use_id;
    l_service_rec.ORIGINAL_SYSTEM_LINE_REFERENCE := p_riginl_systm_lin_rfrnc;
    l_service_rec.EXTENDED_PRICE := p_extended_price;
    l_service_rec.DISCOUNT_ID := p_discount_id;
    l_service_rec.TAX_CODE := p_tax_code;
    l_service_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
    l_service_rec.FIRST_BILL_DATE := p_first_bill_date;
    l_service_rec.NEXT_BILL_DATE := p_next_bill_date;
    l_service_rec.CREATION_DATE := p_creation_date;
    l_service_rec.BILL_ON := p_bill_on;
    l_service_rec.CREATED_BY := p_created_by;
    l_service_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_service_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_service_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_service_rec.START_DATE_ACTIVE := p_start_date_active;
    l_service_rec.END_DATE_ACTIVE := p_end_date_active;
    l_service_rec.PRICING_ATTRIBUTE1 := p_pricing_attribute1;
    l_service_rec.PRICING_ATTRIBUTE2 := p_pricing_attribute2;
    l_service_rec.PRICING_ATTRIBUTE3 := p_pricing_attribute3;
    l_service_rec.PRICING_ATTRIBUTE4 := p_pricing_attribute4;
    l_service_rec.PRICING_ATTRIBUTE5 := p_pricing_attribute5;
    l_service_rec.PRICING_ATTRIBUTE6 := p_pricing_attribute6;
    l_service_rec.PRICING_ATTRIBUTE7 := p_pricing_attribute7;
    l_service_rec.PRICING_ATTRIBUTE8 := p_pricing_attribute8;
    l_service_rec.PRICING_ATTRIBUTE9 := p_pricing_attribute9;
    l_service_rec.PRICING_ATTRIBUTE10 := p_pricing_attribute10;
    l_service_rec.PRICING_ATTRIBUTE11 := p_pricing_attribute11;
    l_service_rec.PRICING_ATTRIBUTE12 := p_pricing_attribute12;
    l_service_rec.PRICING_ATTRIBUTE13 := p_pricing_attribute13;
    l_service_rec.PRICING_ATTRIBUTE14 := p_pricing_attribute14;
    l_service_rec.PRICING_ATTRIBUTE15 := p_pricing_attribute15;
    l_service_rec.PRICING_CONTEXT := p_pricing_context;
    l_service_rec.ATTRIBUTE1 := p_attribute1;
    l_service_rec.ATTRIBUTE2 := p_attribute2;
    l_service_rec.ATTRIBUTE3 := p_attribute3;
    l_service_rec.ATTRIBUTE4 := p_attribute4;
    l_service_rec.ATTRIBUTE5 := p_attribute5;
    l_service_rec.ATTRIBUTE6 := p_attribute6;
    l_service_rec.ATTRIBUTE7 := p_attribute7;
    l_service_rec.ATTRIBUTE8 := p_attribute8;
    l_service_rec.ATTRIBUTE9 := p_attribute9;
    l_service_rec.ATTRIBUTE10 := p_attribute10;
    l_service_rec.ATTRIBUTE11 := p_attribute11;
    l_service_rec.ATTRIBUTE12 := p_attribute12;
    l_service_rec.ATTRIBUTE13 := p_attribute13;
    l_service_rec.ATTRIBUTE14 := p_attribute14;
    l_service_rec.ATTRIBUTE15 := p_attribute15;
    l_service_rec.CONTEXT := p_context;
    l_service_rec.LIST_PRICE := p_list_price;
    l_service_rec.ORG_ID := p_org_id;
    l_service_rec.PRICE_PERCENT := p_price_percent;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_service_rec
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
END CS_SERVICE_PVT;

/

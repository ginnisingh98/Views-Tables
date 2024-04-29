--------------------------------------------------------
--  DDL for Package Body CS_CONTRACTTMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONTRACTTMPL_PVT" AS
/* $Header: csctcteb.pls 115.1 99/07/16 08:51:38 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_CONTRACT_TEMPLATES_S.nextval FROM SYS.DUAL;
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
    p_contracttmpl_rec IN  ContractTmpl_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_contracttmpl_rec.name = TAPI_DEV_KIT.G_MISS_CHAR OR
       p_contracttmpl_rec.name IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.contract_type_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contracttmpl_rec.contract_type_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_type_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.duration = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contracttmpl_rec.duration IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'duration');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.period_code = TAPI_DEV_KIT.G_MISS_CHAR OR
          p_contracttmpl_rec.period_code IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'period_code');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.price_list_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contracttmpl_rec.price_list_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'price_list_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.currency_code = TAPI_DEV_KIT.G_MISS_CHAR OR
          p_contracttmpl_rec.currency_code IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_code');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.terms_id = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contracttmpl_rec.terms_id IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'terms_id');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contracttmpl_rec.last_update_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contracttmpl_rec.last_updated_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contracttmpl_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_contracttmpl_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.start_date_active = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contracttmpl_rec.start_date_active IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date_active');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_contracttmpl_rec.end_date_active = TAPI_DEV_KIT.G_MISS_DATE OR
          p_contracttmpl_rec.end_date_active IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'end_date_active');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_contracttmpl_rec IN  ContractTmpl_Rec_Type,
    l_def_contracttmpl_rec OUT  ContractTmpl_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_contracttmpl_rec := p_contracttmpl_rec;
    l_def_contracttmpl_rec.OBJECT_VERSION_NUMBER := NVL(l_def_contracttmpl_rec.OBJECT_VERSION_NUMBER, 0) + 1;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_contracttmpl_rec IN ContractTmpl_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    FUNCTION validate_foreign_keys (
      p_contracttmpl_rec IN ContractTmpl_Rec_Type
    )
    RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR cs_contract_types_pk_csr (p_contract_type_id   IN NUMBER) IS
      SELECT *
        FROM Cs_Contract_Types
       WHERE cs_contract_types.contract_type_id = p_contract_type_id;
      l_cs_contract_types_pk         cs_contract_types_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_contracttmpl_rec.CONTRACT_TYPE_ID IS NOT NULL)
      THEN
        OPEN cs_contract_types_pk_csr(p_contracttmpl_rec.CONTRACT_TYPE_ID);
        FETCH cs_contract_types_pk_csr INTO l_cs_contract_types_pk;
        l_row_notfound := cs_contract_types_pk_csr%NOTFOUND;
        CLOSE cs_contract_types_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTRACT_TYPE_ID');
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
    l_return_status := validate_foreign_keys (p_contracttmpl_rec);
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN ContractTmpl_Val_Rec_Type,
    p_to	OUT ContractTmpl_Rec_Type
  ) IS
  BEGIN
    p_to.contract_template_id := p_from.contract_template_id;
    p_to.name := p_from.name;
    p_to.contract_type_id := p_from.contract_type_id;
    p_to.duration := p_from.duration;
    p_to.period_code := p_from.period_code;
    p_to.workflow := p_from.workflow;
    p_to.price_list_id := p_from.price_list_id;
    p_to.currency_code := p_from.currency_code;
    p_to.conversion_type_code := p_from.conversion_type_code;
    p_to.conversion_rate := p_from.conversion_rate;
    p_to.conversion_date := p_from.conversion_date;
    p_to.invoicing_rule_id := p_from.invoicing_rule_id;
    p_to.accounting_rule_id := p_from.accounting_rule_id;
    p_to.billing_frequency_period := p_from.billing_frequency_period;
    p_to.create_sales_order := p_from.create_sales_order;
    p_to.renewal_rule := p_from.renewal_rule;
    p_to.termination_rule := p_from.termination_rule;
    p_to.terms_id := p_from.terms_id;
    p_to.tax_handling := p_from.tax_handling;
    p_to.tax_exempt_num := p_from.tax_exempt_num;
    p_to.tax_exempt_reason_code := p_from.tax_exempt_reason_code;
    p_to.contract_amount := p_from.contract_amount;
    p_to.discount_id := p_from.discount_id;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.auto_renewal_flag := p_from.auto_renewal_flag;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
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
    p_from	IN ContractTmpl_Rec_Type,
    p_to	OUT ContractTmpl_Val_Rec_Type
  ) IS
  BEGIN
    p_to.contract_template_id := p_from.contract_template_id;
    p_to.name := p_from.name;
    p_to.contract_type_id := p_from.contract_type_id;
    p_to.duration := p_from.duration;
    p_to.period_code := p_from.period_code;
    p_to.workflow := p_from.workflow;
    p_to.price_list_id := p_from.price_list_id;
    p_to.currency_code := p_from.currency_code;
    p_to.conversion_type_code := p_from.conversion_type_code;
    p_to.conversion_rate := p_from.conversion_rate;
    p_to.conversion_date := p_from.conversion_date;
    p_to.invoicing_rule_id := p_from.invoicing_rule_id;
    p_to.accounting_rule_id := p_from.accounting_rule_id;
    p_to.billing_frequency_period := p_from.billing_frequency_period;
    p_to.create_sales_order := p_from.create_sales_order;
    p_to.renewal_rule := p_from.renewal_rule;
    p_to.termination_rule := p_from.termination_rule;
    p_to.terms_id := p_from.terms_id;
    p_to.tax_handling := p_from.tax_handling;
    p_to.tax_exempt_num := p_from.tax_exempt_num;
    p_to.tax_exempt_reason_code := p_from.tax_exempt_reason_code;
    p_to.contract_amount := p_from.contract_amount;
    p_to.discount_id := p_from.discount_id;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.created_by := p_from.created_by;
    p_to.auto_renewal_flag := p_from.auto_renewal_flag;
    p_to.last_update_login := p_from.last_update_login;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
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
    p_contracttmpl_rec             IN ContractTmpl_Rec_Type := G_MISS_CONTRACTTMPL_REC,
    x_contract_template_id         OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contracttmpl_rec             ContractTmpl_Rec_Type;
    l_def_contracttmpl_rec         ContractTmpl_Rec_Type;
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
    l_contracttmpl_rec := p_contracttmpl_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_contracttmpl_rec    ---- IN
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
      l_contracttmpl_rec,    ---- IN
      l_def_contracttmpl_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contracttmpl_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_contracttmpl_rec.contract_template_id := get_seq_id;
    INSERT INTO CS_CONTRACT_TEMPLATES(
        contract_template_id,
        name,
        contract_type_id,
        duration,
        period_code,
        workflow,
        price_list_id,
        currency_code,
        conversion_type_code,
        conversion_rate,
        conversion_date,
        invoicing_rule_id,
        accounting_rule_id,
        billing_frequency_period,
        create_sales_order,
        renewal_rule,
        termination_rule,
        terms_id,
        tax_handling,
        tax_exempt_num,
        tax_exempt_reason_code,
        contract_amount,
        discount_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        auto_renewal_flag,
        last_update_login,
        start_date_active,
        end_date_active,
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
        l_def_contracttmpl_rec.contract_template_id,
        l_def_contracttmpl_rec.name,
        l_def_contracttmpl_rec.contract_type_id,
        l_def_contracttmpl_rec.duration,
        l_def_contracttmpl_rec.period_code,
        l_def_contracttmpl_rec.workflow,
        l_def_contracttmpl_rec.price_list_id,
        l_def_contracttmpl_rec.currency_code,
        l_def_contracttmpl_rec.conversion_type_code,
        l_def_contracttmpl_rec.conversion_rate,
        l_def_contracttmpl_rec.conversion_date,
        l_def_contracttmpl_rec.invoicing_rule_id,
        l_def_contracttmpl_rec.accounting_rule_id,
        l_def_contracttmpl_rec.billing_frequency_period,
        l_def_contracttmpl_rec.create_sales_order,
        l_def_contracttmpl_rec.renewal_rule,
        l_def_contracttmpl_rec.termination_rule,
        l_def_contracttmpl_rec.terms_id,
        l_def_contracttmpl_rec.tax_handling,
        l_def_contracttmpl_rec.tax_exempt_num,
        l_def_contracttmpl_rec.tax_exempt_reason_code,
        l_def_contracttmpl_rec.contract_amount,
        l_def_contracttmpl_rec.discount_id,
        l_def_contracttmpl_rec.last_update_date,
        l_def_contracttmpl_rec.last_updated_by,
        l_def_contracttmpl_rec.creation_date,
        l_def_contracttmpl_rec.created_by,
        l_def_contracttmpl_rec.auto_renewal_flag,
        l_def_contracttmpl_rec.last_update_login,
        l_def_contracttmpl_rec.start_date_active,
        l_def_contracttmpl_rec.end_date_active,
        l_def_contracttmpl_rec.attribute1,
        l_def_contracttmpl_rec.attribute2,
        l_def_contracttmpl_rec.attribute3,
        l_def_contracttmpl_rec.attribute4,
        l_def_contracttmpl_rec.attribute5,
        l_def_contracttmpl_rec.attribute6,
        l_def_contracttmpl_rec.attribute7,
        l_def_contracttmpl_rec.attribute8,
        l_def_contracttmpl_rec.attribute9,
        l_def_contracttmpl_rec.attribute10,
        l_def_contracttmpl_rec.attribute11,
        l_def_contracttmpl_rec.attribute12,
        l_def_contracttmpl_rec.attribute13,
        l_def_contracttmpl_rec.attribute14,
        l_def_contracttmpl_rec.attribute15,
        l_def_contracttmpl_rec.context,
        l_def_contracttmpl_rec.object_version_number);
    -- Set OUT values
    x_contract_template_id := l_def_contracttmpl_rec.contract_template_id;
    x_object_version_number       := l_def_contracttmpl_rec.OBJECT_VERSION_NUMBER;
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
    p_name                         IN CS_CONTRACT_TEMPLATES.NAME%TYPE := NULL,
    p_contract_type_id             IN NUMBER := NULL,
    p_duration                     IN NUMBER := NULL,
    p_period_code                  IN CS_CONTRACT_TEMPLATES.PERIOD_CODE%TYPE := NULL,
    p_workflow                     IN CS_CONTRACT_TEMPLATES.WORKFLOW%TYPE := NULL,
    p_price_list_id                IN NUMBER := NULL,
    p_currency_code                IN CS_CONTRACT_TEMPLATES.CURRENCY_CODE%TYPE := NULL,
    p_conversion_type_code         IN CS_CONTRACT_TEMPLATES.CONVERSION_TYPE_CODE%TYPE := NULL,
    p_conversion_rate              IN NUMBER := NULL,
    p_conversion_date              IN CS_CONTRACT_TEMPLATES.CONVERSION_DATE%TYPE := NULL,
    p_invoicing_rule_id            IN NUMBER := NULL,
    p_accounting_rule_id           IN NUMBER := NULL,
    p_billing_frequency_period     IN CS_CONTRACT_TEMPLATES.BILLING_FREQUENCY_PERIOD%TYPE := NULL,
    p_create_sales_order           IN CS_CONTRACT_TEMPLATES.CREATE_SALES_ORDER%TYPE := NULL,
    p_renewal_rule                 IN CS_CONTRACT_TEMPLATES.RENEWAL_RULE%TYPE := NULL,
    p_termination_rule             IN CS_CONTRACT_TEMPLATES.TERMINATION_RULE%TYPE := NULL,
    p_terms_id                     IN NUMBER := NULL,
    p_tax_handling                 IN CS_CONTRACT_TEMPLATES.TAX_HANDLING%TYPE := NULL,
    p_tax_exempt_num               IN CS_CONTRACT_TEMPLATES.TAX_EXEMPT_NUM%TYPE := NULL,
    p_tax_exempt_reason_code       IN CS_CONTRACT_TEMPLATES.TAX_EXEMPT_REASON_CODE%TYPE := NULL,
    p_contract_amount              IN NUMBER := NULL,
    p_discount_id                  IN NUMBER := NULL,
    p_last_update_date             IN CS_CONTRACT_TEMPLATES.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_CONTRACT_TEMPLATES.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_auto_renewal_flag            IN CS_CONTRACT_TEMPLATES.AUTO_RENEWAL_FLAG%TYPE := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_start_date_active            IN CS_CONTRACT_TEMPLATES.START_DATE_ACTIVE%TYPE := NULL,
    p_end_date_active              IN CS_CONTRACT_TEMPLATES.END_DATE_ACTIVE%TYPE := NULL,
    p_attribute1                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_CONTRACT_TEMPLATES.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_contract_template_id         OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contracttmpl_rec             ContractTmpl_Rec_Type;
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
    l_contracttmpl_rec.NAME := p_name;
    l_contracttmpl_rec.CONTRACT_TYPE_ID := p_contract_type_id;
    l_contracttmpl_rec.DURATION := p_duration;
    l_contracttmpl_rec.PERIOD_CODE := p_period_code;
    l_contracttmpl_rec.WORKFLOW := p_workflow;
    l_contracttmpl_rec.PRICE_LIST_ID := p_price_list_id;
    l_contracttmpl_rec.CURRENCY_CODE := p_currency_code;
    l_contracttmpl_rec.CONVERSION_TYPE_CODE := p_conversion_type_code;
    l_contracttmpl_rec.CONVERSION_RATE := p_conversion_rate;
    l_contracttmpl_rec.CONVERSION_DATE := p_conversion_date;
    l_contracttmpl_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
    l_contracttmpl_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
    l_contracttmpl_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
    l_contracttmpl_rec.CREATE_SALES_ORDER := p_create_sales_order;
    l_contracttmpl_rec.RENEWAL_RULE := p_renewal_rule;
    l_contracttmpl_rec.TERMINATION_RULE := p_termination_rule;
    l_contracttmpl_rec.TERMS_ID := p_terms_id;
    l_contracttmpl_rec.TAX_HANDLING := p_tax_handling;
    l_contracttmpl_rec.TAX_EXEMPT_NUM := p_tax_exempt_num;
    l_contracttmpl_rec.TAX_EXEMPT_REASON_CODE := p_tax_exempt_reason_code;
    l_contracttmpl_rec.CONTRACT_AMOUNT := p_contract_amount;
    l_contracttmpl_rec.DISCOUNT_ID := p_discount_id;
    l_contracttmpl_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_contracttmpl_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_contracttmpl_rec.CREATION_DATE := p_creation_date;
    l_contracttmpl_rec.CREATED_BY := p_created_by;
    l_contracttmpl_rec.AUTO_RENEWAL_FLAG := p_auto_renewal_flag;
    l_contracttmpl_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_contracttmpl_rec.START_DATE_ACTIVE := p_start_date_active;
    l_contracttmpl_rec.END_DATE_ACTIVE := p_end_date_active;
    l_contracttmpl_rec.ATTRIBUTE1 := p_attribute1;
    l_contracttmpl_rec.ATTRIBUTE2 := p_attribute2;
    l_contracttmpl_rec.ATTRIBUTE3 := p_attribute3;
    l_contracttmpl_rec.ATTRIBUTE4 := p_attribute4;
    l_contracttmpl_rec.ATTRIBUTE5 := p_attribute5;
    l_contracttmpl_rec.ATTRIBUTE6 := p_attribute6;
    l_contracttmpl_rec.ATTRIBUTE7 := p_attribute7;
    l_contracttmpl_rec.ATTRIBUTE8 := p_attribute8;
    l_contracttmpl_rec.ATTRIBUTE9 := p_attribute9;
    l_contracttmpl_rec.ATTRIBUTE10 := p_attribute10;
    l_contracttmpl_rec.ATTRIBUTE11 := p_attribute11;
    l_contracttmpl_rec.ATTRIBUTE12 := p_attribute12;
    l_contracttmpl_rec.ATTRIBUTE13 := p_attribute13;
    l_contracttmpl_rec.ATTRIBUTE14 := p_attribute14;
    l_contracttmpl_rec.ATTRIBUTE15 := p_attribute15;
    l_contracttmpl_rec.CONTEXT := p_context;
    l_contracttmpl_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contracttmpl_rec,
      x_contract_template_id,
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
    p_contract_template_id         IN NUMBER,
    p_object_version_number        IN NUMBER) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_CONTRACT_TEMPLATES
    WHERE
      CONTRACT_TEMPLATE_ID = p_contract_template_id AND
      OBJECT_VERSION_NUMBER = p_object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_CONTRACT_TEMPLATES
    WHERE
      CONTRACT_TEMPLATE_ID = p_contract_template_id
      ;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_object_version_number       CS_CONTRACT_TEMPLATES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      CS_CONTRACT_TEMPLATES.OBJECT_VERSION_NUMBER%TYPE;
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
    p_contracttmpl_val_rec         IN ContractTmpl_Val_Rec_Type := G_MISS_CONTRACTTMPL_VAL_REC,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contracttmpl_rec             ContractTmpl_Rec_Type;
    l_def_contracttmpl_rec         ContractTmpl_Rec_Type;
    FUNCTION populate_new_record (
      p_contracttmpl_rec	IN ContractTmpl_Rec_Type,
      x_contracttmpl_rec	OUT ContractTmpl_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR cs_contract_templates_pk_csr (p_contract_template_id  IN NUMBER) IS
      SELECT *
        FROM Cs_Contract_Templates
       WHERE cs_contract_templates.contract_template_id = p_contract_template_id;
      l_cs_contract_templates_pk     cs_contract_templates_pk_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_contracttmpl_rec := p_contracttmpl_rec;
      -- Get current database values
      OPEN cs_contract_templates_pk_csr (p_contracttmpl_rec.contract_template_id);
      FETCH cs_contract_templates_pk_csr INTO l_cs_contract_templates_pk;
      l_row_notfound := cs_contract_templates_pk_csr%NOTFOUND;
      CLOSE cs_contract_templates_pk_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_contracttmpl_rec.contract_template_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.contract_template_id := l_cs_contract_templates_pk.contract_template_id;
      END IF;
      IF (x_contracttmpl_rec.name = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.name := l_cs_contract_templates_pk.name;
      END IF;
      IF (x_contracttmpl_rec.contract_type_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.contract_type_id := l_cs_contract_templates_pk.contract_type_id;
      END IF;
      IF (x_contracttmpl_rec.duration = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.duration := l_cs_contract_templates_pk.duration;
      END IF;
      IF (x_contracttmpl_rec.period_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.period_code := l_cs_contract_templates_pk.period_code;
      END IF;
      IF (x_contracttmpl_rec.workflow = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.workflow := l_cs_contract_templates_pk.workflow;
      END IF;
      IF (x_contracttmpl_rec.price_list_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.price_list_id := l_cs_contract_templates_pk.price_list_id;
      END IF;
      IF (x_contracttmpl_rec.currency_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.currency_code := l_cs_contract_templates_pk.currency_code;
      END IF;
      IF (x_contracttmpl_rec.conversion_type_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.conversion_type_code := l_cs_contract_templates_pk.conversion_type_code;
      END IF;
      IF (x_contracttmpl_rec.conversion_rate = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.conversion_rate := l_cs_contract_templates_pk.conversion_rate;
      END IF;
      IF (x_contracttmpl_rec.conversion_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contracttmpl_rec.conversion_date := l_cs_contract_templates_pk.conversion_date;
      END IF;
      IF (x_contracttmpl_rec.invoicing_rule_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.invoicing_rule_id := l_cs_contract_templates_pk.invoicing_rule_id;
      END IF;
      IF (x_contracttmpl_rec.accounting_rule_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.accounting_rule_id := l_cs_contract_templates_pk.accounting_rule_id;
      END IF;
      IF (x_contracttmpl_rec.billing_frequency_period = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.billing_frequency_period := l_cs_contract_templates_pk.billing_frequency_period;
      END IF;
      IF (x_contracttmpl_rec.create_sales_order = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.create_sales_order := l_cs_contract_templates_pk.create_sales_order;
      END IF;
      IF (x_contracttmpl_rec.renewal_rule = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.renewal_rule := l_cs_contract_templates_pk.renewal_rule;
      END IF;
      IF (x_contracttmpl_rec.termination_rule = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.termination_rule := l_cs_contract_templates_pk.termination_rule;
      END IF;
      IF (x_contracttmpl_rec.terms_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.terms_id := l_cs_contract_templates_pk.terms_id;
      END IF;
      IF (x_contracttmpl_rec.tax_handling = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.tax_handling := l_cs_contract_templates_pk.tax_handling;
      END IF;
      IF (x_contracttmpl_rec.tax_exempt_num = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.tax_exempt_num := l_cs_contract_templates_pk.tax_exempt_num;
      END IF;
      IF (x_contracttmpl_rec.tax_exempt_reason_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.tax_exempt_reason_code := l_cs_contract_templates_pk.tax_exempt_reason_code;
      END IF;
      IF (x_contracttmpl_rec.contract_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.contract_amount := l_cs_contract_templates_pk.contract_amount;
      END IF;
      IF (x_contracttmpl_rec.discount_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.discount_id := l_cs_contract_templates_pk.discount_id;
      END IF;
      IF (x_contracttmpl_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contracttmpl_rec.last_update_date := l_cs_contract_templates_pk.last_update_date;
      END IF;
      IF (x_contracttmpl_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.last_updated_by := l_cs_contract_templates_pk.last_updated_by;
      END IF;
      IF (x_contracttmpl_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contracttmpl_rec.creation_date := l_cs_contract_templates_pk.creation_date;
      END IF;
      IF (x_contracttmpl_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.created_by := l_cs_contract_templates_pk.created_by;
      END IF;
      IF (x_contracttmpl_rec.auto_renewal_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.auto_renewal_flag := l_cs_contract_templates_pk.auto_renewal_flag;
      END IF;
      IF (x_contracttmpl_rec.last_update_login = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.last_update_login := l_cs_contract_templates_pk.last_update_login;
      END IF;
      IF (x_contracttmpl_rec.start_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contracttmpl_rec.start_date_active := l_cs_contract_templates_pk.start_date_active;
      END IF;
      IF (x_contracttmpl_rec.end_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_contracttmpl_rec.end_date_active := l_cs_contract_templates_pk.end_date_active;
      END IF;
      IF (x_contracttmpl_rec.attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute1 := l_cs_contract_templates_pk.attribute1;
      END IF;
      IF (x_contracttmpl_rec.attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute2 := l_cs_contract_templates_pk.attribute2;
      END IF;
      IF (x_contracttmpl_rec.attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute3 := l_cs_contract_templates_pk.attribute3;
      END IF;
      IF (x_contracttmpl_rec.attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute4 := l_cs_contract_templates_pk.attribute4;
      END IF;
      IF (x_contracttmpl_rec.attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute5 := l_cs_contract_templates_pk.attribute5;
      END IF;
      IF (x_contracttmpl_rec.attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute6 := l_cs_contract_templates_pk.attribute6;
      END IF;
      IF (x_contracttmpl_rec.attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute7 := l_cs_contract_templates_pk.attribute7;
      END IF;
      IF (x_contracttmpl_rec.attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute8 := l_cs_contract_templates_pk.attribute8;
      END IF;
      IF (x_contracttmpl_rec.attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute9 := l_cs_contract_templates_pk.attribute9;
      END IF;
      IF (x_contracttmpl_rec.attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute10 := l_cs_contract_templates_pk.attribute10;
      END IF;
      IF (x_contracttmpl_rec.attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute11 := l_cs_contract_templates_pk.attribute11;
      END IF;
      IF (x_contracttmpl_rec.attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute12 := l_cs_contract_templates_pk.attribute12;
      END IF;
      IF (x_contracttmpl_rec.attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute13 := l_cs_contract_templates_pk.attribute13;
      END IF;
      IF (x_contracttmpl_rec.attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute14 := l_cs_contract_templates_pk.attribute14;
      END IF;
      IF (x_contracttmpl_rec.attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.attribute15 := l_cs_contract_templates_pk.attribute15;
      END IF;
      IF (x_contracttmpl_rec.context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_contracttmpl_rec.context := l_cs_contract_templates_pk.context;
      END IF;
      IF (x_contracttmpl_rec.object_version_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_contracttmpl_rec.object_version_number := l_cs_contract_templates_pk.object_version_number;
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
    migrate(p_contracttmpl_val_rec, l_contracttmpl_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_contracttmpl_rec,    ---- IN
      l_def_contracttmpl_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_contracttmpl_rec, l_def_contracttmpl_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_contracttmpl_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contracttmpl_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_CONTRACT_TEMPLATES
    SET
        CONTRACT_TEMPLATE_ID = l_def_contracttmpl_rec.contract_template_id ,
        NAME = l_def_contracttmpl_rec.name ,
        CONTRACT_TYPE_ID = l_def_contracttmpl_rec.contract_type_id ,
        DURATION = l_def_contracttmpl_rec.duration ,
        PERIOD_CODE = l_def_contracttmpl_rec.period_code ,
        WORKFLOW = l_def_contracttmpl_rec.workflow ,
        PRICE_LIST_ID = l_def_contracttmpl_rec.price_list_id ,
        CURRENCY_CODE = l_def_contracttmpl_rec.currency_code ,
        CONVERSION_TYPE_CODE = l_def_contracttmpl_rec.conversion_type_code ,
        CONVERSION_RATE = l_def_contracttmpl_rec.conversion_rate ,
        CONVERSION_DATE = l_def_contracttmpl_rec.conversion_date ,
        INVOICING_RULE_ID = l_def_contracttmpl_rec.invoicing_rule_id ,
        ACCOUNTING_RULE_ID = l_def_contracttmpl_rec.accounting_rule_id ,
        BILLING_FREQUENCY_PERIOD = l_def_contracttmpl_rec.billing_frequency_period ,
        CREATE_SALES_ORDER = l_def_contracttmpl_rec.create_sales_order ,
        RENEWAL_RULE = l_def_contracttmpl_rec.renewal_rule ,
        TERMINATION_RULE = l_def_contracttmpl_rec.termination_rule ,
        TERMS_ID = l_def_contracttmpl_rec.terms_id ,
        TAX_HANDLING = l_def_contracttmpl_rec.tax_handling ,
        TAX_EXEMPT_NUM = l_def_contracttmpl_rec.tax_exempt_num ,
        TAX_EXEMPT_REASON_CODE = l_def_contracttmpl_rec.tax_exempt_reason_code ,
        CONTRACT_AMOUNT = l_def_contracttmpl_rec.contract_amount ,
        DISCOUNT_ID = l_def_contracttmpl_rec.discount_id ,
        LAST_UPDATE_DATE = l_def_contracttmpl_rec.last_update_date ,
        LAST_UPDATED_BY = l_def_contracttmpl_rec.last_updated_by ,
        CREATION_DATE = l_def_contracttmpl_rec.creation_date ,
        CREATED_BY = l_def_contracttmpl_rec.created_by ,
        AUTO_RENEWAL_FLAG = l_def_contracttmpl_rec.auto_renewal_flag ,
        LAST_UPDATE_LOGIN = l_def_contracttmpl_rec.last_update_login ,
        START_DATE_ACTIVE = l_def_contracttmpl_rec.start_date_active ,
        END_DATE_ACTIVE = l_def_contracttmpl_rec.end_date_active ,
        ATTRIBUTE1 = l_def_contracttmpl_rec.attribute1 ,
        ATTRIBUTE2 = l_def_contracttmpl_rec.attribute2 ,
        ATTRIBUTE3 = l_def_contracttmpl_rec.attribute3 ,
        ATTRIBUTE4 = l_def_contracttmpl_rec.attribute4 ,
        ATTRIBUTE5 = l_def_contracttmpl_rec.attribute5 ,
        ATTRIBUTE6 = l_def_contracttmpl_rec.attribute6 ,
        ATTRIBUTE7 = l_def_contracttmpl_rec.attribute7 ,
        ATTRIBUTE8 = l_def_contracttmpl_rec.attribute8 ,
        ATTRIBUTE9 = l_def_contracttmpl_rec.attribute9 ,
        ATTRIBUTE10 = l_def_contracttmpl_rec.attribute10 ,
        ATTRIBUTE11 = l_def_contracttmpl_rec.attribute11 ,
        ATTRIBUTE12 = l_def_contracttmpl_rec.attribute12 ,
        ATTRIBUTE13 = l_def_contracttmpl_rec.attribute13 ,
        ATTRIBUTE14 = l_def_contracttmpl_rec.attribute14 ,
        ATTRIBUTE15 = l_def_contracttmpl_rec.attribute15 ,
        CONTEXT = l_def_contracttmpl_rec.context ,
        OBJECT_VERSION_NUMBER = l_def_contracttmpl_rec.object_version_number
        WHERE
          CONTRACT_TEMPLATE_ID = l_def_contracttmpl_rec.contract_template_id
          ;
    x_object_version_number := l_def_contracttmpl_rec.OBJECT_VERSION_NUMBER;
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
    p_contract_template_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_CONTRACT_TEMPLATES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_type_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_duration                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_period_code                  IN CS_CONTRACT_TEMPLATES.PERIOD_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow                     IN CS_CONTRACT_TEMPLATES.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CONTRACT_TEMPLATES.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type_code         IN CS_CONTRACT_TEMPLATES.CONVERSION_TYPE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CONTRACT_TEMPLATES.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_invoicing_rule_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_accounting_rule_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_billing_frequency_period     IN CS_CONTRACT_TEMPLATES.BILLING_FREQUENCY_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_create_sales_order           IN CS_CONTRACT_TEMPLATES.CREATE_SALES_ORDER%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_renewal_rule                 IN CS_CONTRACT_TEMPLATES.RENEWAL_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_termination_rule             IN CS_CONTRACT_TEMPLATES.TERMINATION_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_terms_id                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_tax_handling                 IN CS_CONTRACT_TEMPLATES.TAX_HANDLING%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_num               IN CS_CONTRACT_TEMPLATES.TAX_EXEMPT_NUM%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_reason_code       IN CS_CONTRACT_TEMPLATES.TAX_EXEMPT_REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_amount              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_CONTRACT_TEMPLATES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACT_TEMPLATES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_auto_renewal_flag            IN CS_CONTRACT_TEMPLATES.AUTO_RENEWAL_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CONTRACT_TEMPLATES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CONTRACT_TEMPLATES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACT_TEMPLATES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contracttmpl_rec             ContractTmpl_Val_Rec_Type;
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
    l_contracttmpl_rec.CONTRACT_TEMPLATE_ID := p_contract_template_id;
    l_contracttmpl_rec.NAME := p_name;
    l_contracttmpl_rec.CONTRACT_TYPE_ID := p_contract_type_id;
    l_contracttmpl_rec.DURATION := p_duration;
    l_contracttmpl_rec.PERIOD_CODE := p_period_code;
    l_contracttmpl_rec.WORKFLOW := p_workflow;
    l_contracttmpl_rec.PRICE_LIST_ID := p_price_list_id;
    l_contracttmpl_rec.CURRENCY_CODE := p_currency_code;
    l_contracttmpl_rec.CONVERSION_TYPE_CODE := p_conversion_type_code;
    l_contracttmpl_rec.CONVERSION_RATE := p_conversion_rate;
    l_contracttmpl_rec.CONVERSION_DATE := p_conversion_date;
    l_contracttmpl_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
    l_contracttmpl_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
    l_contracttmpl_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
    l_contracttmpl_rec.CREATE_SALES_ORDER := p_create_sales_order;
    l_contracttmpl_rec.RENEWAL_RULE := p_renewal_rule;
    l_contracttmpl_rec.TERMINATION_RULE := p_termination_rule;
    l_contracttmpl_rec.TERMS_ID := p_terms_id;
    l_contracttmpl_rec.TAX_HANDLING := p_tax_handling;
    l_contracttmpl_rec.TAX_EXEMPT_NUM := p_tax_exempt_num;
    l_contracttmpl_rec.TAX_EXEMPT_REASON_CODE := p_tax_exempt_reason_code;
    l_contracttmpl_rec.CONTRACT_AMOUNT := p_contract_amount;
    l_contracttmpl_rec.DISCOUNT_ID := p_discount_id;
    l_contracttmpl_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_contracttmpl_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_contracttmpl_rec.CREATION_DATE := p_creation_date;
    l_contracttmpl_rec.CREATED_BY := p_created_by;
    l_contracttmpl_rec.AUTO_RENEWAL_FLAG := p_auto_renewal_flag;
    l_contracttmpl_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_contracttmpl_rec.START_DATE_ACTIVE := p_start_date_active;
    l_contracttmpl_rec.END_DATE_ACTIVE := p_end_date_active;
    l_contracttmpl_rec.ATTRIBUTE1 := p_attribute1;
    l_contracttmpl_rec.ATTRIBUTE2 := p_attribute2;
    l_contracttmpl_rec.ATTRIBUTE3 := p_attribute3;
    l_contracttmpl_rec.ATTRIBUTE4 := p_attribute4;
    l_contracttmpl_rec.ATTRIBUTE5 := p_attribute5;
    l_contracttmpl_rec.ATTRIBUTE6 := p_attribute6;
    l_contracttmpl_rec.ATTRIBUTE7 := p_attribute7;
    l_contracttmpl_rec.ATTRIBUTE8 := p_attribute8;
    l_contracttmpl_rec.ATTRIBUTE9 := p_attribute9;
    l_contracttmpl_rec.ATTRIBUTE10 := p_attribute10;
    l_contracttmpl_rec.ATTRIBUTE11 := p_attribute11;
    l_contracttmpl_rec.ATTRIBUTE12 := p_attribute12;
    l_contracttmpl_rec.ATTRIBUTE13 := p_attribute13;
    l_contracttmpl_rec.ATTRIBUTE14 := p_attribute14;
    l_contracttmpl_rec.ATTRIBUTE15 := p_attribute15;
    l_contracttmpl_rec.CONTEXT := p_context;
    l_contracttmpl_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contracttmpl_rec,
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
    p_contract_template_id         IN NUMBER) IS
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
    DELETE  FROM CS_CONTRACT_TEMPLATES
    WHERE
      CONTRACT_TEMPLATE_ID = p_contract_template_id
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
    p_contracttmpl_val_rec         IN ContractTmpl_Val_Rec_Type := G_MISS_CONTRACTTMPL_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contracttmpl_rec             ContractTmpl_Rec_Type;
    l_def_contracttmpl_rec         ContractTmpl_Rec_Type;
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
    migrate(p_contracttmpl_val_rec, l_contracttmpl_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_contracttmpl_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_contracttmpl_rec);
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
    p_contract_template_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_CONTRACT_TEMPLATES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_type_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_duration                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_period_code                  IN CS_CONTRACT_TEMPLATES.PERIOD_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow                     IN CS_CONTRACT_TEMPLATES.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_price_list_id                IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_currency_code                IN CS_CONTRACT_TEMPLATES.CURRENCY_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_type_code         IN CS_CONTRACT_TEMPLATES.CONVERSION_TYPE_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_conversion_rate              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_conversion_date              IN CS_CONTRACT_TEMPLATES.CONVERSION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_invoicing_rule_id            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_accounting_rule_id           IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_billing_frequency_period     IN CS_CONTRACT_TEMPLATES.BILLING_FREQUENCY_PERIOD%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_create_sales_order           IN CS_CONTRACT_TEMPLATES.CREATE_SALES_ORDER%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_renewal_rule                 IN CS_CONTRACT_TEMPLATES.RENEWAL_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_termination_rule             IN CS_CONTRACT_TEMPLATES.TERMINATION_RULE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_terms_id                     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_tax_handling                 IN CS_CONTRACT_TEMPLATES.TAX_HANDLING%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_num               IN CS_CONTRACT_TEMPLATES.TAX_EXEMPT_NUM%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_tax_exempt_reason_code       IN CS_CONTRACT_TEMPLATES.TAX_EXEMPT_REASON_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_contract_amount              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_discount_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_date             IN CS_CONTRACT_TEMPLATES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_CONTRACT_TEMPLATES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_auto_renewal_flag            IN CS_CONTRACT_TEMPLATES.AUTO_RENEWAL_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_start_date_active            IN CS_CONTRACT_TEMPLATES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_CONTRACT_TEMPLATES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_attribute1                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_CONTRACT_TEMPLATES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_CONTRACT_TEMPLATES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_CONTRACT_TEMPLATES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_contracttmpl_rec             ContractTmpl_Val_Rec_Type;
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
    l_contracttmpl_rec.CONTRACT_TEMPLATE_ID := p_contract_template_id;
    l_contracttmpl_rec.NAME := p_name;
    l_contracttmpl_rec.CONTRACT_TYPE_ID := p_contract_type_id;
    l_contracttmpl_rec.DURATION := p_duration;
    l_contracttmpl_rec.PERIOD_CODE := p_period_code;
    l_contracttmpl_rec.WORKFLOW := p_workflow;
    l_contracttmpl_rec.PRICE_LIST_ID := p_price_list_id;
    l_contracttmpl_rec.CURRENCY_CODE := p_currency_code;
    l_contracttmpl_rec.CONVERSION_TYPE_CODE := p_conversion_type_code;
    l_contracttmpl_rec.CONVERSION_RATE := p_conversion_rate;
    l_contracttmpl_rec.CONVERSION_DATE := p_conversion_date;
    l_contracttmpl_rec.INVOICING_RULE_ID := p_invoicing_rule_id;
    l_contracttmpl_rec.ACCOUNTING_RULE_ID := p_accounting_rule_id;
    l_contracttmpl_rec.BILLING_FREQUENCY_PERIOD := p_billing_frequency_period;
    l_contracttmpl_rec.CREATE_SALES_ORDER := p_create_sales_order;
    l_contracttmpl_rec.RENEWAL_RULE := p_renewal_rule;
    l_contracttmpl_rec.TERMINATION_RULE := p_termination_rule;
    l_contracttmpl_rec.TERMS_ID := p_terms_id;
    l_contracttmpl_rec.TAX_HANDLING := p_tax_handling;
    l_contracttmpl_rec.TAX_EXEMPT_NUM := p_tax_exempt_num;
    l_contracttmpl_rec.TAX_EXEMPT_REASON_CODE := p_tax_exempt_reason_code;
    l_contracttmpl_rec.CONTRACT_AMOUNT := p_contract_amount;
    l_contracttmpl_rec.DISCOUNT_ID := p_discount_id;
    l_contracttmpl_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_contracttmpl_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_contracttmpl_rec.CREATION_DATE := p_creation_date;
    l_contracttmpl_rec.CREATED_BY := p_created_by;
    l_contracttmpl_rec.AUTO_RENEWAL_FLAG := p_auto_renewal_flag;
    l_contracttmpl_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_contracttmpl_rec.START_DATE_ACTIVE := p_start_date_active;
    l_contracttmpl_rec.END_DATE_ACTIVE := p_end_date_active;
    l_contracttmpl_rec.ATTRIBUTE1 := p_attribute1;
    l_contracttmpl_rec.ATTRIBUTE2 := p_attribute2;
    l_contracttmpl_rec.ATTRIBUTE3 := p_attribute3;
    l_contracttmpl_rec.ATTRIBUTE4 := p_attribute4;
    l_contracttmpl_rec.ATTRIBUTE5 := p_attribute5;
    l_contracttmpl_rec.ATTRIBUTE6 := p_attribute6;
    l_contracttmpl_rec.ATTRIBUTE7 := p_attribute7;
    l_contracttmpl_rec.ATTRIBUTE8 := p_attribute8;
    l_contracttmpl_rec.ATTRIBUTE9 := p_attribute9;
    l_contracttmpl_rec.ATTRIBUTE10 := p_attribute10;
    l_contracttmpl_rec.ATTRIBUTE11 := p_attribute11;
    l_contracttmpl_rec.ATTRIBUTE12 := p_attribute12;
    l_contracttmpl_rec.ATTRIBUTE13 := p_attribute13;
    l_contracttmpl_rec.ATTRIBUTE14 := p_attribute14;
    l_contracttmpl_rec.ATTRIBUTE15 := p_attribute15;
    l_contracttmpl_rec.CONTEXT := p_context;
    l_contracttmpl_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_contracttmpl_rec
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
END CS_CONTRACTTMPL_PVT;

/

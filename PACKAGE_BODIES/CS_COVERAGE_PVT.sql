--------------------------------------------------------
--  DDL for Package Body CS_COVERAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_COVERAGE_PVT" AS
/* $Header: csctcovb.pls 115.1 99/07/16 08:50:27 porting ship $ */
  FUNCTION get_seq_id RETURN NUMBER IS
    CURSOR get_seq_id_csr IS
      SELECT CS_COVERAGES_S.nextval FROM SYS.DUAL;
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
    p_coverage_rec IN  Coverage_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_coverage_rec.name = TAPI_DEV_KIT.G_MISS_CHAR OR
       p_coverage_rec.name IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_coverage_rec.template_flag = TAPI_DEV_KIT.G_MISS_CHAR OR
          p_coverage_rec.template_flag IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'template_flag');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_coverage_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_coverage_rec.created_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_coverage_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_coverage_rec.creation_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_coverage_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE OR
          p_coverage_rec.last_update_date IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
      l_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF p_coverage_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM OR
          p_coverage_rec.last_updated_by IS NULL
    THEN
      TAPI_DEV_KIT.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Item_Attributes;


  ----- Default
  FUNCTION Default_Item_Attributes
  (
    p_coverage_rec IN  Coverage_Rec_Type,
    l_def_coverage_rec OUT  Coverage_Rec_Type
  )
  RETURN VARCHAR2
  IS
    l_return_status 	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    l_def_coverage_rec := p_coverage_rec;
    l_def_coverage_rec.OBJECT_VERSION_NUMBER := NVL(l_def_coverage_rec.OBJECT_VERSION_NUMBER, 0) + 1;
    RETURN(l_return_status);
  End Default_Item_attributes;


  FUNCTION Validate_Item_Record (
    p_coverage_rec IN Coverage_Rec_Type
  )
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    FUNCTION validate_foreign_keys (
      p_coverage_rec IN Coverage_Rec_Type
    )
    RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR cc_pk_csr (p_coverage_id        IN NUMBER) IS
      SELECT *
        FROM Cs_Coverages
       WHERE cs_coverages.coverage_id = p_coverage_id;
      l_cc_pk                        cc_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_coverage_rec.COVERAGE_TEMPLATE_ID IS NOT NULL)
      THEN
        OPEN cc_pk_csr(p_coverage_rec.COVERAGE_TEMPLATE_ID);
        FETCH cc_pk_csr INTO l_cc_pk;
        l_row_notfound := cc_pk_csr%NOTFOUND;
        CLOSE cc_pk_csr;
        IF (l_row_notfound) THEN
          TAPI_DEV_KIT.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'COVERAGE_TEMPLATE_ID');
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
    l_return_status := validate_foreign_keys (p_coverage_rec);
    RETURN (l_return_status);
  END Validate_Item_Record;


  PROCEDURE migrate (
    p_from	IN Coverage_Val_Rec_Type,
    p_to	OUT Coverage_Rec_Type
  ) IS
  BEGIN
    p_to.coverage_id := p_from.coverage_id;
    p_to.coverage_template_id := p_from.coverage_template_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.template_flag := p_from.template_flag;
    p_to.renewal_terms := p_from.renewal_terms;
    p_to.termination_terms := p_from.termination_terms;
    p_to.max_support_coverage_amt := p_from.max_support_coverage_amt;
    p_to.exception_coverage_id := p_from.exception_coverage_id;
    p_to.time_billable_percent := p_from.time_billable_percent;
    p_to.max_time_billable_amount := p_from.max_time_billable_amount;
    p_to.material_billable_percent := p_from.material_billable_percent;
    p_to.max_material_billable_amount := p_from.max_material_billable_amount;
    p_to.expense_billable_percent := p_from.expense_billable_percent;
    p_to.max_expense_billable_amount := p_from.max_expense_billable_amount;
    p_to.max_coverage_amount := p_from.max_coverage_amount;
    p_to.response_time_period_code := p_from.response_time_period_code;
    p_to.response_time_value := p_from.response_time_value;
    p_to.sunday_start_time := p_from.sunday_start_time;
    p_to.sunday_end_time := p_from.sunday_end_time;
    p_to.monday_start_time := p_from.monday_start_time;
    p_to.monday_end_time := p_from.monday_end_time;
    p_to.start_date_active := p_from.start_date_active;
    p_to.tuesday_start_time := p_from.tuesday_start_time;
    p_to.tuesday_end_time := p_from.tuesday_end_time;
    p_to.end_date_active := p_from.end_date_active;
    p_to.wednesday_start_time := p_from.wednesday_start_time;
    p_to.wednesday_end_time := p_from.wednesday_end_time;
    p_to.thursday_start_time := p_from.thursday_start_time;
    p_to.thursday_end_time := p_from.thursday_end_time;
    p_to.friday_start_time := p_from.friday_start_time;
    p_to.friday_end_time := p_from.friday_end_time;
    p_to.saturday_start_time := p_from.saturday_start_time;
    p_to.saturday_end_time := p_from.saturday_end_time;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
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
    p_from	IN Coverage_Rec_Type,
    p_to	OUT Coverage_Val_Rec_Type
  ) IS
  BEGIN
    p_to.coverage_id := p_from.coverage_id;
    p_to.coverage_template_id := p_from.coverage_template_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.template_flag := p_from.template_flag;
    p_to.renewal_terms := p_from.renewal_terms;
    p_to.termination_terms := p_from.termination_terms;
    p_to.max_support_coverage_amt := p_from.max_support_coverage_amt;
    p_to.exception_coverage_id := p_from.exception_coverage_id;
    p_to.time_billable_percent := p_from.time_billable_percent;
    p_to.max_time_billable_amount := p_from.max_time_billable_amount;
    p_to.material_billable_percent := p_from.material_billable_percent;
    p_to.max_material_billable_amount := p_from.max_material_billable_amount;
    p_to.expense_billable_percent := p_from.expense_billable_percent;
    p_to.max_expense_billable_amount := p_from.max_expense_billable_amount;
    p_to.max_coverage_amount := p_from.max_coverage_amount;
    p_to.response_time_period_code := p_from.response_time_period_code;
    p_to.response_time_value := p_from.response_time_value;
    p_to.sunday_start_time := p_from.sunday_start_time;
    p_to.sunday_end_time := p_from.sunday_end_time;
    p_to.monday_start_time := p_from.monday_start_time;
    p_to.monday_end_time := p_from.monday_end_time;
    p_to.start_date_active := p_from.start_date_active;
    p_to.tuesday_start_time := p_from.tuesday_start_time;
    p_to.tuesday_end_time := p_from.tuesday_end_time;
    p_to.end_date_active := p_from.end_date_active;
    p_to.wednesday_start_time := p_from.wednesday_start_time;
    p_to.wednesday_end_time := p_from.wednesday_end_time;
    p_to.thursday_start_time := p_from.thursday_start_time;
    p_to.thursday_end_time := p_from.thursday_end_time;
    p_to.friday_start_time := p_from.friday_start_time;
    p_to.friday_end_time := p_from.friday_end_time;
    p_to.saturday_start_time := p_from.saturday_start_time;
    p_to.saturday_end_time := p_from.saturday_end_time;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
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
    p_coverage_rec                 IN Coverage_Rec_Type := G_MISS_COVERAGE_REC,
    x_coverage_id                  OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_coverage_rec                 Coverage_Rec_Type;
    l_def_coverage_rec             Coverage_Rec_Type;
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
    l_coverage_rec := p_coverage_rec;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_coverage_rec    ---- IN
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
      l_coverage_rec,    ---- IN
      l_def_coverage_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_coverage_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- Set primary key value
    l_def_coverage_rec.coverage_id := get_seq_id;
    INSERT INTO CS_COVERAGES(
        coverage_id,
        coverage_template_id,
        name,
        description,
        template_flag,
        renewal_terms,
        termination_terms,
        max_support_coverage_amt,
        exception_coverage_id,
        time_billable_percent,
        max_time_billable_amount,
        material_billable_percent,
        max_material_billable_amount,
        expense_billable_percent,
        max_expense_billable_amount,
        max_coverage_amount,
        response_time_period_code,
        response_time_value,
        sunday_start_time,
        sunday_end_time,
        monday_start_time,
        monday_end_time,
        start_date_active,
        tuesday_start_time,
        tuesday_end_time,
        end_date_active,
        wednesday_start_time,
        wednesday_end_time,
        thursday_start_time,
        thursday_end_time,
        friday_start_time,
        friday_end_time,
        saturday_start_time,
        saturday_end_time,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        attribute3,
        attribute1,
        attribute2,
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
        l_def_coverage_rec.coverage_id,
        l_def_coverage_rec.coverage_template_id,
        l_def_coverage_rec.name,
        l_def_coverage_rec.description,
        l_def_coverage_rec.template_flag,
        l_def_coverage_rec.renewal_terms,
        l_def_coverage_rec.termination_terms,
        l_def_coverage_rec.max_support_coverage_amt,
        l_def_coverage_rec.exception_coverage_id,
        l_def_coverage_rec.time_billable_percent,
        l_def_coverage_rec.max_time_billable_amount,
        l_def_coverage_rec.material_billable_percent,
        l_def_coverage_rec.max_material_billable_amount,
        l_def_coverage_rec.expense_billable_percent,
        l_def_coverage_rec.max_expense_billable_amount,
        l_def_coverage_rec.max_coverage_amount,
        l_def_coverage_rec.response_time_period_code,
        l_def_coverage_rec.response_time_value,
        l_def_coverage_rec.sunday_start_time,
        l_def_coverage_rec.sunday_end_time,
        l_def_coverage_rec.monday_start_time,
        l_def_coverage_rec.monday_end_time,
        l_def_coverage_rec.start_date_active,
        l_def_coverage_rec.tuesday_start_time,
        l_def_coverage_rec.tuesday_end_time,
        l_def_coverage_rec.end_date_active,
        l_def_coverage_rec.wednesday_start_time,
        l_def_coverage_rec.wednesday_end_time,
        l_def_coverage_rec.thursday_start_time,
        l_def_coverage_rec.thursday_end_time,
        l_def_coverage_rec.friday_start_time,
        l_def_coverage_rec.friday_end_time,
        l_def_coverage_rec.saturday_start_time,
        l_def_coverage_rec.saturday_end_time,
        l_def_coverage_rec.created_by,
        l_def_coverage_rec.creation_date,
        l_def_coverage_rec.last_update_date,
        l_def_coverage_rec.last_updated_by,
        l_def_coverage_rec.last_update_login,
        l_def_coverage_rec.attribute3,
        l_def_coverage_rec.attribute1,
        l_def_coverage_rec.attribute2,
        l_def_coverage_rec.attribute4,
        l_def_coverage_rec.attribute5,
        l_def_coverage_rec.attribute6,
        l_def_coverage_rec.attribute7,
        l_def_coverage_rec.attribute8,
        l_def_coverage_rec.attribute9,
        l_def_coverage_rec.attribute10,
        l_def_coverage_rec.attribute11,
        l_def_coverage_rec.attribute12,
        l_def_coverage_rec.attribute13,
        l_def_coverage_rec.attribute14,
        l_def_coverage_rec.attribute15,
        l_def_coverage_rec.context,
        l_def_coverage_rec.object_version_number);
    -- Set OUT values
    x_coverage_id := l_def_coverage_rec.coverage_id;
    x_object_version_number       := l_def_coverage_rec.OBJECT_VERSION_NUMBER;
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
    p_coverage_template_id         IN NUMBER := NULL,
    p_name                         IN CS_COVERAGES.NAME%TYPE := NULL,
    p_description                  IN CS_COVERAGES.DESCRIPTION%TYPE := NULL,
    p_template_flag                IN CS_COVERAGES.TEMPLATE_FLAG%TYPE := NULL,
    p_renewal_terms                IN CS_COVERAGES.RENEWAL_TERMS%TYPE := NULL,
    p_termination_terms            IN CS_COVERAGES.TERMINATION_TERMS%TYPE := NULL,
    p_max_support_coverage_amt     IN NUMBER := NULL,
    p_exception_coverage_id        IN NUMBER := NULL,
    p_time_billable_percent        IN NUMBER := NULL,
    p_max_time_billable_amount     IN NUMBER := NULL,
    p_material_billable_percent    IN NUMBER := NULL,
    p_max_material_billable_amount  IN NUMBER := NULL,
    p_expense_billable_percent     IN NUMBER := NULL,
    p_max_expense_billable_amount  IN NUMBER := NULL,
    p_max_coverage_amount          IN NUMBER := NULL,
    p_response_time_period_code    IN CS_COVERAGES.RESPONSE_TIME_PERIOD_CODE%TYPE := NULL,
    p_response_time_value          IN NUMBER := NULL,
    p_sunday_start_time            IN CS_COVERAGES.SUNDAY_START_TIME%TYPE := NULL,
    p_sunday_end_time              IN CS_COVERAGES.SUNDAY_END_TIME%TYPE := NULL,
    p_monday_start_time            IN CS_COVERAGES.MONDAY_START_TIME%TYPE := NULL,
    p_monday_end_time              IN CS_COVERAGES.MONDAY_END_TIME%TYPE := NULL,
    p_start_date_active            IN CS_COVERAGES.START_DATE_ACTIVE%TYPE := NULL,
    p_tuesday_start_time           IN CS_COVERAGES.TUESDAY_START_TIME%TYPE := NULL,
    p_tuesday_end_time             IN CS_COVERAGES.TUESDAY_END_TIME%TYPE := NULL,
    p_end_date_active              IN CS_COVERAGES.END_DATE_ACTIVE%TYPE := NULL,
    p_wednesday_start_time         IN CS_COVERAGES.WEDNESDAY_START_TIME%TYPE := NULL,
    p_wednesday_end_time           IN CS_COVERAGES.WEDNESDAY_END_TIME%TYPE := NULL,
    p_thursday_start_time          IN CS_COVERAGES.THURSDAY_START_TIME%TYPE := NULL,
    p_thursday_end_time            IN CS_COVERAGES.THURSDAY_END_TIME%TYPE := NULL,
    p_friday_start_time            IN CS_COVERAGES.FRIDAY_START_TIME%TYPE := NULL,
    p_friday_end_time              IN CS_COVERAGES.FRIDAY_END_TIME%TYPE := NULL,
    p_saturday_start_time          IN CS_COVERAGES.SATURDAY_START_TIME%TYPE := NULL,
    p_saturday_end_time            IN CS_COVERAGES.SATURDAY_END_TIME%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_creation_date                IN CS_COVERAGES.CREATION_DATE%TYPE := NULL,
    p_last_update_date             IN CS_COVERAGES.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_attribute3                   IN CS_COVERAGES.ATTRIBUTE3%TYPE := NULL,
    p_attribute1                   IN CS_COVERAGES.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_COVERAGES.ATTRIBUTE2%TYPE := NULL,
    p_attribute4                   IN CS_COVERAGES.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_COVERAGES.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_COVERAGES.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_COVERAGES.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_COVERAGES.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_COVERAGES.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_COVERAGES.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_COVERAGES.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_COVERAGES.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_COVERAGES.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_COVERAGES.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_COVERAGES.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_COVERAGES.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_coverage_id                  OUT NUMBER,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_coverage_rec                 Coverage_Rec_Type;
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
    l_coverage_rec.COVERAGE_TEMPLATE_ID := p_coverage_template_id;
    l_coverage_rec.NAME := p_name;
    l_coverage_rec.DESCRIPTION := p_description;
    l_coverage_rec.TEMPLATE_FLAG := p_template_flag;
    l_coverage_rec.RENEWAL_TERMS := p_renewal_terms;
    l_coverage_rec.TERMINATION_TERMS := p_termination_terms;
    l_coverage_rec.MAX_SUPPORT_COVERAGE_AMT := p_max_support_coverage_amt;
    l_coverage_rec.EXCEPTION_COVERAGE_ID := p_exception_coverage_id;
    l_coverage_rec.TIME_BILLABLE_PERCENT := p_time_billable_percent;
    l_coverage_rec.MAX_TIME_BILLABLE_AMOUNT := p_max_time_billable_amount;
    l_coverage_rec.MATERIAL_BILLABLE_PERCENT := p_material_billable_percent;
    l_coverage_rec.MAX_MATERIAL_BILLABLE_AMOUNT := p_max_material_billable_amount;
    l_coverage_rec.EXPENSE_BILLABLE_PERCENT := p_expense_billable_percent;
    l_coverage_rec.MAX_EXPENSE_BILLABLE_AMOUNT := p_max_expense_billable_amount;
    l_coverage_rec.MAX_COVERAGE_AMOUNT := p_max_coverage_amount;
    l_coverage_rec.RESPONSE_TIME_PERIOD_CODE := p_response_time_period_code;
    l_coverage_rec.RESPONSE_TIME_VALUE := p_response_time_value;
    l_coverage_rec.SUNDAY_START_TIME := p_sunday_start_time;
    l_coverage_rec.SUNDAY_END_TIME := p_sunday_end_time;
    l_coverage_rec.MONDAY_START_TIME := p_monday_start_time;
    l_coverage_rec.MONDAY_END_TIME := p_monday_end_time;
    l_coverage_rec.START_DATE_ACTIVE := p_start_date_active;
    l_coverage_rec.TUESDAY_START_TIME := p_tuesday_start_time;
    l_coverage_rec.TUESDAY_END_TIME := p_tuesday_end_time;
    l_coverage_rec.END_DATE_ACTIVE := p_end_date_active;
    l_coverage_rec.WEDNESDAY_START_TIME := p_wednesday_start_time;
    l_coverage_rec.WEDNESDAY_END_TIME := p_wednesday_end_time;
    l_coverage_rec.THURSDAY_START_TIME := p_thursday_start_time;
    l_coverage_rec.THURSDAY_END_TIME := p_thursday_end_time;
    l_coverage_rec.FRIDAY_START_TIME := p_friday_start_time;
    l_coverage_rec.FRIDAY_END_TIME := p_friday_end_time;
    l_coverage_rec.SATURDAY_START_TIME := p_saturday_start_time;
    l_coverage_rec.SATURDAY_END_TIME := p_saturday_end_time;
    l_coverage_rec.CREATED_BY := p_created_by;
    l_coverage_rec.CREATION_DATE := p_creation_date;
    l_coverage_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_coverage_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_coverage_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_coverage_rec.ATTRIBUTE3 := p_attribute3;
    l_coverage_rec.ATTRIBUTE1 := p_attribute1;
    l_coverage_rec.ATTRIBUTE2 := p_attribute2;
    l_coverage_rec.ATTRIBUTE4 := p_attribute4;
    l_coverage_rec.ATTRIBUTE5 := p_attribute5;
    l_coverage_rec.ATTRIBUTE6 := p_attribute6;
    l_coverage_rec.ATTRIBUTE7 := p_attribute7;
    l_coverage_rec.ATTRIBUTE8 := p_attribute8;
    l_coverage_rec.ATTRIBUTE9 := p_attribute9;
    l_coverage_rec.ATTRIBUTE10 := p_attribute10;
    l_coverage_rec.ATTRIBUTE11 := p_attribute11;
    l_coverage_rec.ATTRIBUTE12 := p_attribute12;
    l_coverage_rec.ATTRIBUTE13 := p_attribute13;
    l_coverage_rec.ATTRIBUTE14 := p_attribute14;
    l_coverage_rec.ATTRIBUTE15 := p_attribute15;
    l_coverage_rec.CONTEXT := p_context;
    l_coverage_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    insert_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_coverage_rec,
      x_coverage_id,
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
    p_coverage_id                  IN NUMBER,
    p_object_version_number        IN NUMBER) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_COVERAGES
    WHERE
      COVERAGE_ID = p_coverage_id AND
      OBJECT_VERSION_NUMBER = p_object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
     FROM CS_COVERAGES
    WHERE
      COVERAGE_ID = p_coverage_id
      ;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_object_version_number       CS_COVERAGES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      CS_COVERAGES.OBJECT_VERSION_NUMBER%TYPE;
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
    p_coverage_val_rec             IN Coverage_Val_Rec_Type := G_MISS_COVERAGE_VAL_REC,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_coverage_rec                 Coverage_Rec_Type;
    l_def_coverage_rec             Coverage_Rec_Type;
    FUNCTION populate_new_record (
      p_coverage_rec	IN Coverage_Rec_Type,
      x_coverage_rec	OUT Coverage_Rec_Type
    ) RETURN VARCHAR2 IS
      CURSOR cc_pk_csr (p_coverage_id        IN NUMBER) IS
      SELECT *
        FROM Cs_Coverages
       WHERE cs_coverages.coverage_id = p_coverage_id;
      l_cc_pk                        cc_pk_csr%ROWTYPE;
      l_row_notfound		BOOLEAN := TRUE;
      l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      x_coverage_rec := p_coverage_rec;
      -- Get current database values
      OPEN cc_pk_csr (p_coverage_rec.coverage_id);
      FETCH cc_pk_csr INTO l_cc_pk;
      l_row_notfound := cc_pk_csr%NOTFOUND;
      CLOSE cc_pk_csr;
      IF (l_row_notfound) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      IF (x_coverage_rec.coverage_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.coverage_id := l_cc_pk.coverage_id;
      END IF;
      IF (x_coverage_rec.coverage_template_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.coverage_template_id := l_cc_pk.coverage_template_id;
      END IF;
      IF (x_coverage_rec.name = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.name := l_cc_pk.name;
      END IF;
      IF (x_coverage_rec.description = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.description := l_cc_pk.description;
      END IF;
      IF (x_coverage_rec.template_flag = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.template_flag := l_cc_pk.template_flag;
      END IF;
      IF (x_coverage_rec.renewal_terms = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.renewal_terms := l_cc_pk.renewal_terms;
      END IF;
      IF (x_coverage_rec.termination_terms = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.termination_terms := l_cc_pk.termination_terms;
      END IF;
      IF (x_coverage_rec.max_support_coverage_amt = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.max_support_coverage_amt := l_cc_pk.max_support_coverage_amt;
      END IF;
      IF (x_coverage_rec.exception_coverage_id = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.exception_coverage_id := l_cc_pk.exception_coverage_id;
      END IF;
      IF (x_coverage_rec.time_billable_percent = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.time_billable_percent := l_cc_pk.time_billable_percent;
      END IF;
      IF (x_coverage_rec.max_time_billable_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.max_time_billable_amount := l_cc_pk.max_time_billable_amount;
      END IF;
      IF (x_coverage_rec.material_billable_percent = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.material_billable_percent := l_cc_pk.material_billable_percent;
      END IF;
      IF (x_coverage_rec.max_material_billable_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.max_material_billable_amount := l_cc_pk.max_material_billable_amount;
      END IF;
      IF (x_coverage_rec.expense_billable_percent = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.expense_billable_percent := l_cc_pk.expense_billable_percent;
      END IF;
      IF (x_coverage_rec.max_expense_billable_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.max_expense_billable_amount := l_cc_pk.max_expense_billable_amount;
      END IF;
      IF (x_coverage_rec.max_coverage_amount = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.max_coverage_amount := l_cc_pk.max_coverage_amount;
      END IF;
      IF (x_coverage_rec.response_time_period_code = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.response_time_period_code := l_cc_pk.response_time_period_code;
      END IF;
      IF (x_coverage_rec.response_time_value = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.response_time_value := l_cc_pk.response_time_value;
      END IF;
      IF (x_coverage_rec.sunday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.sunday_start_time := l_cc_pk.sunday_start_time;
      END IF;
      IF (x_coverage_rec.sunday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.sunday_end_time := l_cc_pk.sunday_end_time;
      END IF;
      IF (x_coverage_rec.monday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.monday_start_time := l_cc_pk.monday_start_time;
      END IF;
      IF (x_coverage_rec.monday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.monday_end_time := l_cc_pk.monday_end_time;
      END IF;
      IF (x_coverage_rec.start_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.start_date_active := l_cc_pk.start_date_active;
      END IF;
      IF (x_coverage_rec.tuesday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.tuesday_start_time := l_cc_pk.tuesday_start_time;
      END IF;
      IF (x_coverage_rec.tuesday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.tuesday_end_time := l_cc_pk.tuesday_end_time;
      END IF;
      IF (x_coverage_rec.end_date_active = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.end_date_active := l_cc_pk.end_date_active;
      END IF;
      IF (x_coverage_rec.wednesday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.wednesday_start_time := l_cc_pk.wednesday_start_time;
      END IF;
      IF (x_coverage_rec.wednesday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.wednesday_end_time := l_cc_pk.wednesday_end_time;
      END IF;
      IF (x_coverage_rec.thursday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.thursday_start_time := l_cc_pk.thursday_start_time;
      END IF;
      IF (x_coverage_rec.thursday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.thursday_end_time := l_cc_pk.thursday_end_time;
      END IF;
      IF (x_coverage_rec.friday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.friday_start_time := l_cc_pk.friday_start_time;
      END IF;
      IF (x_coverage_rec.friday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.friday_end_time := l_cc_pk.friday_end_time;
      END IF;
      IF (x_coverage_rec.saturday_start_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.saturday_start_time := l_cc_pk.saturday_start_time;
      END IF;
      IF (x_coverage_rec.saturday_end_time = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.saturday_end_time := l_cc_pk.saturday_end_time;
      END IF;
      IF (x_coverage_rec.created_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.created_by := l_cc_pk.created_by;
      END IF;
      IF (x_coverage_rec.creation_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.creation_date := l_cc_pk.creation_date;
      END IF;
      IF (x_coverage_rec.last_update_date = TAPI_DEV_KIT.G_MISS_DATE)
      THEN
        x_coverage_rec.last_update_date := l_cc_pk.last_update_date;
      END IF;
      IF (x_coverage_rec.last_updated_by = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.last_updated_by := l_cc_pk.last_updated_by;
      END IF;
      IF (x_coverage_rec.last_update_login = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.last_update_login := l_cc_pk.last_update_login;
      END IF;
      IF (x_coverage_rec.attribute3 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute3 := l_cc_pk.attribute3;
      END IF;
      IF (x_coverage_rec.attribute1 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute1 := l_cc_pk.attribute1;
      END IF;
      IF (x_coverage_rec.attribute2 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute2 := l_cc_pk.attribute2;
      END IF;
      IF (x_coverage_rec.attribute4 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute4 := l_cc_pk.attribute4;
      END IF;
      IF (x_coverage_rec.attribute5 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute5 := l_cc_pk.attribute5;
      END IF;
      IF (x_coverage_rec.attribute6 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute6 := l_cc_pk.attribute6;
      END IF;
      IF (x_coverage_rec.attribute7 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute7 := l_cc_pk.attribute7;
      END IF;
      IF (x_coverage_rec.attribute8 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute8 := l_cc_pk.attribute8;
      END IF;
      IF (x_coverage_rec.attribute9 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute9 := l_cc_pk.attribute9;
      END IF;
      IF (x_coverage_rec.attribute10 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute10 := l_cc_pk.attribute10;
      END IF;
      IF (x_coverage_rec.attribute11 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute11 := l_cc_pk.attribute11;
      END IF;
      IF (x_coverage_rec.attribute12 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute12 := l_cc_pk.attribute12;
      END IF;
      IF (x_coverage_rec.attribute13 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute13 := l_cc_pk.attribute13;
      END IF;
      IF (x_coverage_rec.attribute14 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute14 := l_cc_pk.attribute14;
      END IF;
      IF (x_coverage_rec.attribute15 = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.attribute15 := l_cc_pk.attribute15;
      END IF;
      IF (x_coverage_rec.context = TAPI_DEV_KIT.G_MISS_CHAR)
      THEN
        x_coverage_rec.context := l_cc_pk.context;
      END IF;
      IF (x_coverage_rec.object_version_number = TAPI_DEV_KIT.G_MISS_NUM)
      THEN
        x_coverage_rec.object_version_number := l_cc_pk.object_version_number;
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
    migrate(p_coverage_val_rec, l_coverage_rec);
    --- Defaulting item attributes
    l_return_status := Default_Item_Attributes
    (
      l_coverage_rec,    ---- IN
      l_def_coverage_rec
    );
    --- If any errors happen abort API
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_return_status := populate_new_record(l_def_coverage_rec, l_def_coverage_rec);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_def_coverage_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_coverage_rec);
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    UPDATE  CS_COVERAGES
    SET
        COVERAGE_ID = l_def_coverage_rec.coverage_id ,
        COVERAGE_TEMPLATE_ID = l_def_coverage_rec.coverage_template_id ,
        NAME = l_def_coverage_rec.name ,
        DESCRIPTION = l_def_coverage_rec.description ,
        TEMPLATE_FLAG = l_def_coverage_rec.template_flag ,
        RENEWAL_TERMS = l_def_coverage_rec.renewal_terms ,
        TERMINATION_TERMS = l_def_coverage_rec.termination_terms ,
        MAX_SUPPORT_COVERAGE_AMT = l_def_coverage_rec.max_support_coverage_amt ,
        EXCEPTION_COVERAGE_ID = l_def_coverage_rec.exception_coverage_id ,
        TIME_BILLABLE_PERCENT = l_def_coverage_rec.time_billable_percent ,
        MAX_TIME_BILLABLE_AMOUNT = l_def_coverage_rec.max_time_billable_amount ,
        MATERIAL_BILLABLE_PERCENT = l_def_coverage_rec.material_billable_percent ,
        MAX_MATERIAL_BILLABLE_AMOUNT = l_def_coverage_rec.max_material_billable_amount ,
        EXPENSE_BILLABLE_PERCENT = l_def_coverage_rec.expense_billable_percent ,
        MAX_EXPENSE_BILLABLE_AMOUNT = l_def_coverage_rec.max_expense_billable_amount ,
        MAX_COVERAGE_AMOUNT = l_def_coverage_rec.max_coverage_amount ,
        RESPONSE_TIME_PERIOD_CODE = l_def_coverage_rec.response_time_period_code ,
        RESPONSE_TIME_VALUE = l_def_coverage_rec.response_time_value ,
        SUNDAY_START_TIME = l_def_coverage_rec.sunday_start_time ,
        SUNDAY_END_TIME = l_def_coverage_rec.sunday_end_time ,
        MONDAY_START_TIME = l_def_coverage_rec.monday_start_time ,
        MONDAY_END_TIME = l_def_coverage_rec.monday_end_time ,
        START_DATE_ACTIVE = l_def_coverage_rec.start_date_active ,
        TUESDAY_START_TIME = l_def_coverage_rec.tuesday_start_time ,
        TUESDAY_END_TIME = l_def_coverage_rec.tuesday_end_time ,
        END_DATE_ACTIVE = l_def_coverage_rec.end_date_active ,
        WEDNESDAY_START_TIME = l_def_coverage_rec.wednesday_start_time ,
        WEDNESDAY_END_TIME = l_def_coverage_rec.wednesday_end_time ,
        THURSDAY_START_TIME = l_def_coverage_rec.thursday_start_time ,
        THURSDAY_END_TIME = l_def_coverage_rec.thursday_end_time ,
        FRIDAY_START_TIME = l_def_coverage_rec.friday_start_time ,
        FRIDAY_END_TIME = l_def_coverage_rec.friday_end_time ,
        SATURDAY_START_TIME = l_def_coverage_rec.saturday_start_time ,
        SATURDAY_END_TIME = l_def_coverage_rec.saturday_end_time ,
        CREATED_BY = l_def_coverage_rec.created_by ,
        CREATION_DATE = l_def_coverage_rec.creation_date ,
        LAST_UPDATE_DATE = l_def_coverage_rec.last_update_date ,
        LAST_UPDATED_BY = l_def_coverage_rec.last_updated_by ,
        LAST_UPDATE_LOGIN = l_def_coverage_rec.last_update_login ,
        ATTRIBUTE3 = l_def_coverage_rec.attribute3 ,
        ATTRIBUTE1 = l_def_coverage_rec.attribute1 ,
        ATTRIBUTE2 = l_def_coverage_rec.attribute2 ,
        ATTRIBUTE4 = l_def_coverage_rec.attribute4 ,
        ATTRIBUTE5 = l_def_coverage_rec.attribute5 ,
        ATTRIBUTE6 = l_def_coverage_rec.attribute6 ,
        ATTRIBUTE7 = l_def_coverage_rec.attribute7 ,
        ATTRIBUTE8 = l_def_coverage_rec.attribute8 ,
        ATTRIBUTE9 = l_def_coverage_rec.attribute9 ,
        ATTRIBUTE10 = l_def_coverage_rec.attribute10 ,
        ATTRIBUTE11 = l_def_coverage_rec.attribute11 ,
        ATTRIBUTE12 = l_def_coverage_rec.attribute12 ,
        ATTRIBUTE13 = l_def_coverage_rec.attribute13 ,
        ATTRIBUTE14 = l_def_coverage_rec.attribute14 ,
        ATTRIBUTE15 = l_def_coverage_rec.attribute15 ,
        CONTEXT = l_def_coverage_rec.context ,
        OBJECT_VERSION_NUMBER = l_def_coverage_rec.object_version_number
        WHERE
          COVERAGE_ID = l_def_coverage_rec.coverage_id
          ;
    x_object_version_number := l_def_coverage_rec.OBJECT_VERSION_NUMBER;
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
    p_coverage_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_coverage_template_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_COVERAGES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_COVERAGES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_template_flag                IN CS_COVERAGES.TEMPLATE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_renewal_terms                IN CS_COVERAGES.RENEWAL_TERMS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_termination_terms            IN CS_COVERAGES.TERMINATION_TERMS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_max_support_coverage_amt     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_exception_coverage_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_time_billable_percent        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_time_billable_amount     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_material_billable_percent    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_material_billable_amount  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_expense_billable_percent     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_expense_billable_amount  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_coverage_amount          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_response_time_period_code    IN CS_COVERAGES.RESPONSE_TIME_PERIOD_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_response_time_value          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_sunday_start_time            IN CS_COVERAGES.SUNDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_sunday_end_time              IN CS_COVERAGES.SUNDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_start_time            IN CS_COVERAGES.MONDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_end_time              IN CS_COVERAGES.MONDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_start_date_active            IN CS_COVERAGES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_start_time           IN CS_COVERAGES.TUESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_end_time             IN CS_COVERAGES.TUESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_COVERAGES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_start_time         IN CS_COVERAGES.WEDNESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_end_time           IN CS_COVERAGES.WEDNESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_start_time          IN CS_COVERAGES.THURSDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_end_time            IN CS_COVERAGES.THURSDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_start_time            IN CS_COVERAGES.FRIDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_end_time              IN CS_COVERAGES.FRIDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_start_time          IN CS_COVERAGES.SATURDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_end_time            IN CS_COVERAGES.SATURDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COVERAGES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_update_date             IN CS_COVERAGES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute3                   IN CS_COVERAGES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute1                   IN CS_COVERAGES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COVERAGES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COVERAGES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COVERAGES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COVERAGES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COVERAGES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COVERAGES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COVERAGES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COVERAGES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COVERAGES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COVERAGES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COVERAGES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COVERAGES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COVERAGES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COVERAGES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NUMBER) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_coverage_rec                 Coverage_Val_Rec_Type;
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
    l_coverage_rec.COVERAGE_ID := p_coverage_id;
    l_coverage_rec.COVERAGE_TEMPLATE_ID := p_coverage_template_id;
    l_coverage_rec.NAME := p_name;
    l_coverage_rec.DESCRIPTION := p_description;
    l_coverage_rec.TEMPLATE_FLAG := p_template_flag;
    l_coverage_rec.RENEWAL_TERMS := p_renewal_terms;
    l_coverage_rec.TERMINATION_TERMS := p_termination_terms;
    l_coverage_rec.MAX_SUPPORT_COVERAGE_AMT := p_max_support_coverage_amt;
    l_coverage_rec.EXCEPTION_COVERAGE_ID := p_exception_coverage_id;
    l_coverage_rec.TIME_BILLABLE_PERCENT := p_time_billable_percent;
    l_coverage_rec.MAX_TIME_BILLABLE_AMOUNT := p_max_time_billable_amount;
    l_coverage_rec.MATERIAL_BILLABLE_PERCENT := p_material_billable_percent;
    l_coverage_rec.MAX_MATERIAL_BILLABLE_AMOUNT := p_max_material_billable_amount;
    l_coverage_rec.EXPENSE_BILLABLE_PERCENT := p_expense_billable_percent;
    l_coverage_rec.MAX_EXPENSE_BILLABLE_AMOUNT := p_max_expense_billable_amount;
    l_coverage_rec.MAX_COVERAGE_AMOUNT := p_max_coverage_amount;
    l_coverage_rec.RESPONSE_TIME_PERIOD_CODE := p_response_time_period_code;
    l_coverage_rec.RESPONSE_TIME_VALUE := p_response_time_value;
    l_coverage_rec.SUNDAY_START_TIME := p_sunday_start_time;
    l_coverage_rec.SUNDAY_END_TIME := p_sunday_end_time;
    l_coverage_rec.MONDAY_START_TIME := p_monday_start_time;
    l_coverage_rec.MONDAY_END_TIME := p_monday_end_time;
    l_coverage_rec.START_DATE_ACTIVE := p_start_date_active;
    l_coverage_rec.TUESDAY_START_TIME := p_tuesday_start_time;
    l_coverage_rec.TUESDAY_END_TIME := p_tuesday_end_time;
    l_coverage_rec.END_DATE_ACTIVE := p_end_date_active;
    l_coverage_rec.WEDNESDAY_START_TIME := p_wednesday_start_time;
    l_coverage_rec.WEDNESDAY_END_TIME := p_wednesday_end_time;
    l_coverage_rec.THURSDAY_START_TIME := p_thursday_start_time;
    l_coverage_rec.THURSDAY_END_TIME := p_thursday_end_time;
    l_coverage_rec.FRIDAY_START_TIME := p_friday_start_time;
    l_coverage_rec.FRIDAY_END_TIME := p_friday_end_time;
    l_coverage_rec.SATURDAY_START_TIME := p_saturday_start_time;
    l_coverage_rec.SATURDAY_END_TIME := p_saturday_end_time;
    l_coverage_rec.CREATED_BY := p_created_by;
    l_coverage_rec.CREATION_DATE := p_creation_date;
    l_coverage_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_coverage_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_coverage_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_coverage_rec.ATTRIBUTE3 := p_attribute3;
    l_coverage_rec.ATTRIBUTE1 := p_attribute1;
    l_coverage_rec.ATTRIBUTE2 := p_attribute2;
    l_coverage_rec.ATTRIBUTE4 := p_attribute4;
    l_coverage_rec.ATTRIBUTE5 := p_attribute5;
    l_coverage_rec.ATTRIBUTE6 := p_attribute6;
    l_coverage_rec.ATTRIBUTE7 := p_attribute7;
    l_coverage_rec.ATTRIBUTE8 := p_attribute8;
    l_coverage_rec.ATTRIBUTE9 := p_attribute9;
    l_coverage_rec.ATTRIBUTE10 := p_attribute10;
    l_coverage_rec.ATTRIBUTE11 := p_attribute11;
    l_coverage_rec.ATTRIBUTE12 := p_attribute12;
    l_coverage_rec.ATTRIBUTE13 := p_attribute13;
    l_coverage_rec.ATTRIBUTE14 := p_attribute14;
    l_coverage_rec.ATTRIBUTE15 := p_attribute15;
    l_coverage_rec.CONTEXT := p_context;
    l_coverage_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    update_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_coverage_rec,
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
    p_coverage_id                  IN NUMBER) IS
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
    DELETE  FROM CS_COVERAGES
    WHERE
      COVERAGE_ID = p_coverage_id
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
    p_coverage_val_rec             IN Coverage_Val_Rec_Type := G_MISS_COVERAGE_VAL_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_coverage_rec                 Coverage_Rec_Type;
    l_def_coverage_rec             Coverage_Rec_Type;
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
    migrate(p_coverage_val_rec, l_coverage_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    IF p_validation_level >= FND_API.G_VALID_LEVEL_FULL THEN
      l_return_status := Validate_Item_Attributes
      (
        l_coverage_rec    ---- IN
      );
      --- If any errors happen abort API
      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      l_return_status := Validate_Item_Record(l_def_coverage_rec);
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
    p_coverage_id                  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_coverage_template_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_COVERAGES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_COVERAGES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_template_flag                IN CS_COVERAGES.TEMPLATE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_renewal_terms                IN CS_COVERAGES.RENEWAL_TERMS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_termination_terms            IN CS_COVERAGES.TERMINATION_TERMS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_max_support_coverage_amt     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_exception_coverage_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_time_billable_percent        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_time_billable_amount     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_material_billable_percent    IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_material_billable_amount  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_expense_billable_percent     IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_expense_billable_amount  IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_max_coverage_amount          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_response_time_period_code    IN CS_COVERAGES.RESPONSE_TIME_PERIOD_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_response_time_value          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_sunday_start_time            IN CS_COVERAGES.SUNDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_sunday_end_time              IN CS_COVERAGES.SUNDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_start_time            IN CS_COVERAGES.MONDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_monday_end_time              IN CS_COVERAGES.MONDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_start_date_active            IN CS_COVERAGES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_start_time           IN CS_COVERAGES.TUESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_tuesday_end_time             IN CS_COVERAGES.TUESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_end_date_active              IN CS_COVERAGES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_start_time         IN CS_COVERAGES.WEDNESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_wednesday_end_time           IN CS_COVERAGES.WEDNESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_start_time          IN CS_COVERAGES.THURSDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_thursday_end_time            IN CS_COVERAGES.THURSDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_start_time            IN CS_COVERAGES.FRIDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_friday_end_time              IN CS_COVERAGES.FRIDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_start_time          IN CS_COVERAGES.SATURDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_saturday_end_time            IN CS_COVERAGES.SATURDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COVERAGES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_update_date             IN CS_COVERAGES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute3                   IN CS_COVERAGES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute1                   IN CS_COVERAGES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COVERAGES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COVERAGES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COVERAGES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COVERAGES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COVERAGES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COVERAGES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COVERAGES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COVERAGES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COVERAGES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COVERAGES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COVERAGES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COVERAGES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COVERAGES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COVERAGES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row';
    l_api_version                  CONSTANT NUMBER := 1;
    l_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_coverage_rec                 Coverage_Val_Rec_Type;
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
    l_coverage_rec.COVERAGE_ID := p_coverage_id;
    l_coverage_rec.COVERAGE_TEMPLATE_ID := p_coverage_template_id;
    l_coverage_rec.NAME := p_name;
    l_coverage_rec.DESCRIPTION := p_description;
    l_coverage_rec.TEMPLATE_FLAG := p_template_flag;
    l_coverage_rec.RENEWAL_TERMS := p_renewal_terms;
    l_coverage_rec.TERMINATION_TERMS := p_termination_terms;
    l_coverage_rec.MAX_SUPPORT_COVERAGE_AMT := p_max_support_coverage_amt;
    l_coverage_rec.EXCEPTION_COVERAGE_ID := p_exception_coverage_id;
    l_coverage_rec.TIME_BILLABLE_PERCENT := p_time_billable_percent;
    l_coverage_rec.MAX_TIME_BILLABLE_AMOUNT := p_max_time_billable_amount;
    l_coverage_rec.MATERIAL_BILLABLE_PERCENT := p_material_billable_percent;
    l_coverage_rec.MAX_MATERIAL_BILLABLE_AMOUNT := p_max_material_billable_amount;
    l_coverage_rec.EXPENSE_BILLABLE_PERCENT := p_expense_billable_percent;
    l_coverage_rec.MAX_EXPENSE_BILLABLE_AMOUNT := p_max_expense_billable_amount;
    l_coverage_rec.MAX_COVERAGE_AMOUNT := p_max_coverage_amount;
    l_coverage_rec.RESPONSE_TIME_PERIOD_CODE := p_response_time_period_code;
    l_coverage_rec.RESPONSE_TIME_VALUE := p_response_time_value;
    l_coverage_rec.SUNDAY_START_TIME := p_sunday_start_time;
    l_coverage_rec.SUNDAY_END_TIME := p_sunday_end_time;
    l_coverage_rec.MONDAY_START_TIME := p_monday_start_time;
    l_coverage_rec.MONDAY_END_TIME := p_monday_end_time;
    l_coverage_rec.START_DATE_ACTIVE := p_start_date_active;
    l_coverage_rec.TUESDAY_START_TIME := p_tuesday_start_time;
    l_coverage_rec.TUESDAY_END_TIME := p_tuesday_end_time;
    l_coverage_rec.END_DATE_ACTIVE := p_end_date_active;
    l_coverage_rec.WEDNESDAY_START_TIME := p_wednesday_start_time;
    l_coverage_rec.WEDNESDAY_END_TIME := p_wednesday_end_time;
    l_coverage_rec.THURSDAY_START_TIME := p_thursday_start_time;
    l_coverage_rec.THURSDAY_END_TIME := p_thursday_end_time;
    l_coverage_rec.FRIDAY_START_TIME := p_friday_start_time;
    l_coverage_rec.FRIDAY_END_TIME := p_friday_end_time;
    l_coverage_rec.SATURDAY_START_TIME := p_saturday_start_time;
    l_coverage_rec.SATURDAY_END_TIME := p_saturday_end_time;
    l_coverage_rec.CREATED_BY := p_created_by;
    l_coverage_rec.CREATION_DATE := p_creation_date;
    l_coverage_rec.LAST_UPDATE_DATE := p_last_update_date;
    l_coverage_rec.LAST_UPDATED_BY := p_last_updated_by;
    l_coverage_rec.LAST_UPDATE_LOGIN := p_last_update_login;
    l_coverage_rec.ATTRIBUTE3 := p_attribute3;
    l_coverage_rec.ATTRIBUTE1 := p_attribute1;
    l_coverage_rec.ATTRIBUTE2 := p_attribute2;
    l_coverage_rec.ATTRIBUTE4 := p_attribute4;
    l_coverage_rec.ATTRIBUTE5 := p_attribute5;
    l_coverage_rec.ATTRIBUTE6 := p_attribute6;
    l_coverage_rec.ATTRIBUTE7 := p_attribute7;
    l_coverage_rec.ATTRIBUTE8 := p_attribute8;
    l_coverage_rec.ATTRIBUTE9 := p_attribute9;
    l_coverage_rec.ATTRIBUTE10 := p_attribute10;
    l_coverage_rec.ATTRIBUTE11 := p_attribute11;
    l_coverage_rec.ATTRIBUTE12 := p_attribute12;
    l_coverage_rec.ATTRIBUTE13 := p_attribute13;
    l_coverage_rec.ATTRIBUTE14 := p_attribute14;
    l_coverage_rec.ATTRIBUTE15 := p_attribute15;
    l_coverage_rec.CONTEXT := p_context;
    l_coverage_rec.OBJECT_VERSION_NUMBER := p_object_version_number;
    validate_row(
      p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_coverage_rec
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
END CS_COVERAGE_PVT;

/

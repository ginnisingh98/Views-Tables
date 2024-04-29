--------------------------------------------------------
--  DDL for Package CS_COVERAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COVERAGE_PVT" AUTHID CURRENT_USER AS
/* $Header: csctcovs.pls 115.0 99/07/16 08:50:33 porting ship  $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE Coverage_Rec_Type IS RECORD (
    coverage_id                    NUMBER := NULL,
    coverage_template_id           NUMBER := NULL,
    name                           CS_COVERAGES.NAME%TYPE := NULL,
    description                    CS_COVERAGES.DESCRIPTION%TYPE := NULL,
    template_flag                  CS_COVERAGES.TEMPLATE_FLAG%TYPE := NULL,
    renewal_terms                  CS_COVERAGES.RENEWAL_TERMS%TYPE := NULL,
    termination_terms              CS_COVERAGES.TERMINATION_TERMS%TYPE := NULL,
    max_support_coverage_amt       NUMBER := NULL,
    exception_coverage_id          NUMBER := NULL,
    time_billable_percent          NUMBER := NULL,
    max_time_billable_amount       NUMBER := NULL,
    material_billable_percent      NUMBER := NULL,
    max_material_billable_amount   NUMBER := NULL,
    expense_billable_percent       NUMBER := NULL,
    max_expense_billable_amount    NUMBER := NULL,
    max_coverage_amount            NUMBER := NULL,
    response_time_period_code      CS_COVERAGES.RESPONSE_TIME_PERIOD_CODE%TYPE := NULL,
    response_time_value            NUMBER := NULL,
    sunday_start_time              CS_COVERAGES.SUNDAY_START_TIME%TYPE := NULL,
    sunday_end_time                CS_COVERAGES.SUNDAY_END_TIME%TYPE := NULL,
    monday_start_time              CS_COVERAGES.MONDAY_START_TIME%TYPE := NULL,
    monday_end_time                CS_COVERAGES.MONDAY_END_TIME%TYPE := NULL,
    start_date_active              CS_COVERAGES.START_DATE_ACTIVE%TYPE := NULL,
    tuesday_start_time             CS_COVERAGES.TUESDAY_START_TIME%TYPE := NULL,
    tuesday_end_time               CS_COVERAGES.TUESDAY_END_TIME%TYPE := NULL,
    end_date_active                CS_COVERAGES.END_DATE_ACTIVE%TYPE := NULL,
    wednesday_start_time           CS_COVERAGES.WEDNESDAY_START_TIME%TYPE := NULL,
    wednesday_end_time             CS_COVERAGES.WEDNESDAY_END_TIME%TYPE := NULL,
    thursday_start_time            CS_COVERAGES.THURSDAY_START_TIME%TYPE := NULL,
    thursday_end_time              CS_COVERAGES.THURSDAY_END_TIME%TYPE := NULL,
    friday_start_time              CS_COVERAGES.FRIDAY_START_TIME%TYPE := NULL,
    friday_end_time                CS_COVERAGES.FRIDAY_END_TIME%TYPE := NULL,
    saturday_start_time            CS_COVERAGES.SATURDAY_START_TIME%TYPE := NULL,
    saturday_end_time              CS_COVERAGES.SATURDAY_END_TIME%TYPE := NULL,
    created_by                     NUMBER := NULL,
    creation_date                  CS_COVERAGES.CREATION_DATE%TYPE := NULL,
    last_update_date               CS_COVERAGES.LAST_UPDATE_DATE%TYPE := NULL,
    last_updated_by                NUMBER := NULL,
    last_update_login              NUMBER := NULL,
    attribute3                     CS_COVERAGES.ATTRIBUTE3%TYPE := NULL,
    attribute1                     CS_COVERAGES.ATTRIBUTE1%TYPE := NULL,
    attribute2                     CS_COVERAGES.ATTRIBUTE2%TYPE := NULL,
    attribute4                     CS_COVERAGES.ATTRIBUTE4%TYPE := NULL,
    attribute5                     CS_COVERAGES.ATTRIBUTE5%TYPE := NULL,
    attribute6                     CS_COVERAGES.ATTRIBUTE6%TYPE := NULL,
    attribute7                     CS_COVERAGES.ATTRIBUTE7%TYPE := NULL,
    attribute8                     CS_COVERAGES.ATTRIBUTE8%TYPE := NULL,
    attribute9                     CS_COVERAGES.ATTRIBUTE9%TYPE := NULL,
    attribute10                    CS_COVERAGES.ATTRIBUTE10%TYPE := NULL,
    attribute11                    CS_COVERAGES.ATTRIBUTE11%TYPE := NULL,
    attribute12                    CS_COVERAGES.ATTRIBUTE12%TYPE := NULL,
    attribute13                    CS_COVERAGES.ATTRIBUTE13%TYPE := NULL,
    attribute14                    CS_COVERAGES.ATTRIBUTE14%TYPE := NULL,
    attribute15                    CS_COVERAGES.ATTRIBUTE15%TYPE := NULL,
    context                        CS_COVERAGES.CONTEXT%TYPE := NULL,
    object_version_number          NUMBER := NULL);
  G_MISS_coverage_rec                     Coverage_Rec_Type;
  TYPE Coverage_Val_Rec_Type IS RECORD (
    coverage_id                    NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    coverage_template_id           NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    name                           CS_COVERAGES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    description                    CS_COVERAGES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    template_flag                  CS_COVERAGES.TEMPLATE_FLAG%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    renewal_terms                  CS_COVERAGES.RENEWAL_TERMS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    termination_terms              CS_COVERAGES.TERMINATION_TERMS%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    max_support_coverage_amt       NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    exception_coverage_id          NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    time_billable_percent          NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    max_time_billable_amount       NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    material_billable_percent      NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    max_material_billable_amount   NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    expense_billable_percent       NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    max_expense_billable_amount    NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    max_coverage_amount            NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    response_time_period_code      CS_COVERAGES.RESPONSE_TIME_PERIOD_CODE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    response_time_value            NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    sunday_start_time              CS_COVERAGES.SUNDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    sunday_end_time                CS_COVERAGES.SUNDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    monday_start_time              CS_COVERAGES.MONDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    monday_end_time                CS_COVERAGES.MONDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    start_date_active              CS_COVERAGES.START_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    tuesday_start_time             CS_COVERAGES.TUESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    tuesday_end_time               CS_COVERAGES.TUESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    end_date_active                CS_COVERAGES.END_DATE_ACTIVE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    wednesday_start_time           CS_COVERAGES.WEDNESDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    wednesday_end_time             CS_COVERAGES.WEDNESDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    thursday_start_time            CS_COVERAGES.THURSDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    thursday_end_time              CS_COVERAGES.THURSDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    friday_start_time              CS_COVERAGES.FRIDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    friday_end_time                CS_COVERAGES.FRIDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    saturday_start_time            CS_COVERAGES.SATURDAY_START_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    saturday_end_time              CS_COVERAGES.SATURDAY_END_TIME%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    created_by                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    creation_date                  CS_COVERAGES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    last_update_date               CS_COVERAGES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    last_updated_by                NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    last_update_login              NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    attribute3                     CS_COVERAGES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute1                     CS_COVERAGES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute2                     CS_COVERAGES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute4                     CS_COVERAGES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute5                     CS_COVERAGES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute6                     CS_COVERAGES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute7                     CS_COVERAGES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute8                     CS_COVERAGES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute9                     CS_COVERAGES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute10                    CS_COVERAGES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute11                    CS_COVERAGES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute12                    CS_COVERAGES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute13                    CS_COVERAGES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute14                    CS_COVERAGES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute15                    CS_COVERAGES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    context                        CS_COVERAGES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    object_version_number          NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
  G_MISS_coverage_val_rec                 Coverage_Val_Rec_Type;
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
  G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'CS_COVERAGE_PVT';
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
    p_coverage_rec                 IN Coverage_Rec_Type := G_MISS_COVERAGE_REC,
    x_coverage_id                  OUT NUMBER,
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
    p_coverage_id                  IN NUMBER,
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
    p_coverage_val_rec             IN Coverage_Val_Rec_Type := G_MISS_COVERAGE_VAL_REC,
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
    p_coverage_id                  IN NUMBER);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_coverage_val_rec             IN Coverage_Val_Rec_Type := G_MISS_COVERAGE_VAL_REC);
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
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
END CS_COVERAGE_PVT;

 

/

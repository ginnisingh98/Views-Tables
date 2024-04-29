--------------------------------------------------------
--  DDL for Package CS_REACTTIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_REACTTIME_PVT" AUTHID CURRENT_USER AS
/* $Header: csctcrts.pls 115.0 99/07/16 08:51:08 porting ship  $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ReactTime_Rec_Type IS RECORD (
    reaction_time_id               NUMBER := NULL,
    name                           CS_COV_REACTION_TIMES.NAME%TYPE := NULL,
    description                    CS_COV_REACTION_TIMES.DESCRIPTION%TYPE := NULL,
    reaction_time_sunday           NUMBER := NULL,
    reaction_time_monday           NUMBER := NULL,
    reaction_time_tuesday          NUMBER := NULL,
    reaction_time_wednesday        NUMBER := NULL,
    reaction_time_thursday         NUMBER := NULL,
    reaction_time_friday           NUMBER := NULL,
    reaction_time_saturday         NUMBER := NULL,
    incident_severity_id           NUMBER := NULL,
    always_covered                 CS_COV_REACTION_TIMES.ALWAYS_COVERED%TYPE := NULL,
    workflow                       CS_COV_REACTION_TIMES.WORKFLOW%TYPE := NULL,
    coverage_txn_group_id          NUMBER := NULL,
    use_for_sr_date_calc           CS_COV_REACTION_TIMES.USE_FOR_SR_DATE_CALC%TYPE := NULL,
    last_update_date               CS_COV_REACTION_TIMES.LAST_UPDATE_DATE%TYPE := NULL,
    last_updated_by                NUMBER := NULL,
    creation_date                  CS_COV_REACTION_TIMES.CREATION_DATE%TYPE := NULL,
    created_by                     NUMBER := NULL,
    last_update_login              NUMBER := NULL,
    attribute1                     CS_COV_REACTION_TIMES.ATTRIBUTE1%TYPE := NULL,
    attribute2                     CS_COV_REACTION_TIMES.ATTRIBUTE2%TYPE := NULL,
    attribute3                     CS_COV_REACTION_TIMES.ATTRIBUTE3%TYPE := NULL,
    attribute4                     CS_COV_REACTION_TIMES.ATTRIBUTE4%TYPE := NULL,
    attribute5                     CS_COV_REACTION_TIMES.ATTRIBUTE5%TYPE := NULL,
    attribute6                     CS_COV_REACTION_TIMES.ATTRIBUTE6%TYPE := NULL,
    attribute7                     CS_COV_REACTION_TIMES.ATTRIBUTE7%TYPE := NULL,
    attribute8                     CS_COV_REACTION_TIMES.ATTRIBUTE8%TYPE := NULL,
    attribute9                     CS_COV_REACTION_TIMES.ATTRIBUTE9%TYPE := NULL,
    attribute10                    CS_COV_REACTION_TIMES.ATTRIBUTE10%TYPE := NULL,
    attribute11                    CS_COV_REACTION_TIMES.ATTRIBUTE11%TYPE := NULL,
    attribute12                    CS_COV_REACTION_TIMES.ATTRIBUTE12%TYPE := NULL,
    attribute13                    CS_COV_REACTION_TIMES.ATTRIBUTE13%TYPE := NULL,
    attribute14                    CS_COV_REACTION_TIMES.ATTRIBUTE14%TYPE := NULL,
    attribute15                    CS_COV_REACTION_TIMES.ATTRIBUTE15%TYPE := NULL,
    context                        CS_COV_REACTION_TIMES.CONTEXT%TYPE := NULL,
    object_version_number          NUMBER := NULL);
  G_MISS_reacttime_rec                    ReactTime_Rec_Type;
  TYPE ReactTime_Val_Rec_Type IS RECORD (
    reaction_time_id               NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    name                           CS_COV_REACTION_TIMES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    description                    CS_COV_REACTION_TIMES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    reaction_time_sunday           NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    reaction_time_monday           NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    reaction_time_tuesday          NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    reaction_time_wednesday        NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    reaction_time_thursday         NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    reaction_time_friday           NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    reaction_time_saturday         NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    incident_severity_id           NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    always_covered                 CS_COV_REACTION_TIMES.ALWAYS_COVERED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    workflow                       CS_COV_REACTION_TIMES.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    coverage_txn_group_id          NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    use_for_sr_date_calc           CS_COV_REACTION_TIMES.USE_FOR_SR_DATE_CALC%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    last_update_date               CS_COV_REACTION_TIMES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    last_updated_by                NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    creation_date                  CS_COV_REACTION_TIMES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    created_by                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    last_update_login              NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    attribute1                     CS_COV_REACTION_TIMES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute2                     CS_COV_REACTION_TIMES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute3                     CS_COV_REACTION_TIMES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute4                     CS_COV_REACTION_TIMES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute5                     CS_COV_REACTION_TIMES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute6                     CS_COV_REACTION_TIMES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute7                     CS_COV_REACTION_TIMES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute8                     CS_COV_REACTION_TIMES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute9                     CS_COV_REACTION_TIMES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute10                    CS_COV_REACTION_TIMES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute11                    CS_COV_REACTION_TIMES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute12                    CS_COV_REACTION_TIMES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute13                    CS_COV_REACTION_TIMES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute14                    CS_COV_REACTION_TIMES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute15                    CS_COV_REACTION_TIMES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    context                        CS_COV_REACTION_TIMES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    object_version_number          NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
  G_MISS_reacttime_val_rec                ReactTime_Val_Rec_Type;
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
  G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'CS_REACTTIME_PVT';
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
    p_reacttime_rec                IN ReactTime_Rec_Type := G_MISS_REACTTIME_REC,
    x_reaction_time_id             OUT NUMBER,
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
    p_name                         IN CS_COV_REACTION_TIMES.NAME%TYPE := NULL,
    p_description                  IN CS_COV_REACTION_TIMES.DESCRIPTION%TYPE := NULL,
    p_reaction_time_sunday         IN NUMBER := NULL,
    p_reaction_time_monday         IN NUMBER := NULL,
    p_reaction_time_tuesday        IN NUMBER := NULL,
    p_reaction_time_wednesday      IN NUMBER := NULL,
    p_reaction_time_thursday       IN NUMBER := NULL,
    p_reaction_time_friday         IN NUMBER := NULL,
    p_reaction_time_saturday       IN NUMBER := NULL,
    p_incident_severity_id         IN NUMBER := NULL,
    p_always_covered               IN CS_COV_REACTION_TIMES.ALWAYS_COVERED%TYPE := NULL,
    p_workflow                     IN CS_COV_REACTION_TIMES.WORKFLOW%TYPE := NULL,
    p_coverage_txn_group_id        IN NUMBER := NULL,
    p_use_for_sr_date_calc         IN CS_COV_REACTION_TIMES.USE_FOR_SR_DATE_CALC%TYPE := NULL,
    p_last_update_date             IN CS_COV_REACTION_TIMES.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_COV_REACTION_TIMES.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_attribute1                   IN CS_COV_REACTION_TIMES.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_COV_REACTION_TIMES.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_COV_REACTION_TIMES.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_COV_REACTION_TIMES.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_COV_REACTION_TIMES.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_COV_REACTION_TIMES.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_COV_REACTION_TIMES.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_COV_REACTION_TIMES.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_COV_REACTION_TIMES.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_COV_REACTION_TIMES.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_COV_REACTION_TIMES.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_COV_REACTION_TIMES.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_COV_REACTION_TIMES.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_COV_REACTION_TIMES.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_COV_REACTION_TIMES.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_COV_REACTION_TIMES.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_reaction_time_id             OUT NUMBER,
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
    p_reaction_time_id             IN NUMBER,
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
    p_reacttime_val_rec            IN ReactTime_Val_Rec_Type := G_MISS_REACTTIME_VAL_REC,
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
    p_reaction_time_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_COV_REACTION_TIMES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_COV_REACTION_TIMES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_reaction_time_sunday         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_monday         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_tuesday        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_wednesday      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_thursday       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_friday         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_saturday       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_incident_severity_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_always_covered               IN CS_COV_REACTION_TIMES.ALWAYS_COVERED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow                     IN CS_COV_REACTION_TIMES.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_txn_group_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_use_for_sr_date_calc         IN CS_COV_REACTION_TIMES.USE_FOR_SR_DATE_CALC%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_COV_REACTION_TIMES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COV_REACTION_TIMES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COV_REACTION_TIMES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COV_REACTION_TIMES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COV_REACTION_TIMES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COV_REACTION_TIMES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COV_REACTION_TIMES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COV_REACTION_TIMES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COV_REACTION_TIMES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COV_REACTION_TIMES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COV_REACTION_TIMES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COV_REACTION_TIMES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COV_REACTION_TIMES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COV_REACTION_TIMES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COV_REACTION_TIMES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COV_REACTION_TIMES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COV_REACTION_TIMES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COV_REACTION_TIMES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
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
    p_reaction_time_id             IN NUMBER);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_reacttime_val_rec            IN ReactTime_Val_Rec_Type := G_MISS_REACTTIME_VAL_REC);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT VARCHAR2,
    x_msg_count                    OUT NUMBER,
    x_msg_data                     OUT VARCHAR2,
    p_reaction_time_id             IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_name                         IN CS_COV_REACTION_TIMES.NAME%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_description                  IN CS_COV_REACTION_TIMES.DESCRIPTION%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_reaction_time_sunday         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_monday         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_tuesday        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_wednesday      IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_thursday       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_friday         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_reaction_time_saturday       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_incident_severity_id         IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_always_covered               IN CS_COV_REACTION_TIMES.ALWAYS_COVERED%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_workflow                     IN CS_COV_REACTION_TIMES.WORKFLOW%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_coverage_txn_group_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_use_for_sr_date_calc         IN CS_COV_REACTION_TIMES.USE_FOR_SR_DATE_CALC%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_COV_REACTION_TIMES.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COV_REACTION_TIMES.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COV_REACTION_TIMES.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COV_REACTION_TIMES.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COV_REACTION_TIMES.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COV_REACTION_TIMES.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COV_REACTION_TIMES.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COV_REACTION_TIMES.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COV_REACTION_TIMES.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COV_REACTION_TIMES.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COV_REACTION_TIMES.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COV_REACTION_TIMES.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COV_REACTION_TIMES.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COV_REACTION_TIMES.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COV_REACTION_TIMES.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COV_REACTION_TIMES.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COV_REACTION_TIMES.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COV_REACTION_TIMES.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
END CS_REACTTIME_PVT;

 

/

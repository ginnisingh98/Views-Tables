--------------------------------------------------------
--  DDL for Package CS_COUNTERFILTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COUNTERFILTER_PVT" AUTHID CURRENT_USER AS
/* $Header: csctdfls.pls 115.7 2002/11/18 21:57:14 mkommuri ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE CounterFilter_Rec_Type IS RECORD (
    counter_der_filter_id          NUMBER := NULL,
    counter_id                     NUMBER := NULL,
    seq_no                         NUMBER := NULL,
    left_paren                     CS_COUNTER_DER_FILTERS.LEFT_PAREN%TYPE := NULL,
    counter_property_id            NUMBER := NULL,
    relational_operator            CS_COUNTER_DER_FILTERS.RELATIONAL_OPERATOR%TYPE := NULL,
    right_paren                    CS_COUNTER_DER_FILTERS.RIGHT_PAREN%TYPE := NULL,
    right_value                    CS_COUNTER_DER_FILTERS.RIGHT_VALUE%TYPE := NULL,
    logical_operator               CS_COUNTER_DER_FILTERS.LOGICAL_OPERATOR%TYPE := NULL,
    last_update_date               CS_COUNTER_DER_FILTERS.LAST_UPDATE_DATE%TYPE := NULL,
    last_updated_by                NUMBER := NULL,
    creation_date                  CS_COUNTER_DER_FILTERS.CREATION_DATE%TYPE := NULL,
    created_by                     NUMBER := NULL,
    last_update_login              NUMBER := NULL,
    attribute1                     CS_COUNTER_DER_FILTERS.ATTRIBUTE1%TYPE := NULL,
    attribute2                     CS_COUNTER_DER_FILTERS.ATTRIBUTE2%TYPE := NULL,
    attribute3                     CS_COUNTER_DER_FILTERS.ATTRIBUTE3%TYPE := NULL,
    attribute4                     CS_COUNTER_DER_FILTERS.ATTRIBUTE4%TYPE := NULL,
    attribute5                     CS_COUNTER_DER_FILTERS.ATTRIBUTE5%TYPE := NULL,
    attribute6                     CS_COUNTER_DER_FILTERS.ATTRIBUTE6%TYPE := NULL,
    attribute7                     CS_COUNTER_DER_FILTERS.ATTRIBUTE7%TYPE := NULL,
    attribute8                     CS_COUNTER_DER_FILTERS.ATTRIBUTE8%TYPE := NULL,
    attribute9                     CS_COUNTER_DER_FILTERS.ATTRIBUTE9%TYPE := NULL,
    attribute10                    CS_COUNTER_DER_FILTERS.ATTRIBUTE10%TYPE := NULL,
    attribute11                    CS_COUNTER_DER_FILTERS.ATTRIBUTE11%TYPE := NULL,
    attribute12                    CS_COUNTER_DER_FILTERS.ATTRIBUTE12%TYPE := NULL,
    attribute13                    CS_COUNTER_DER_FILTERS.ATTRIBUTE13%TYPE := NULL,
    attribute14                    CS_COUNTER_DER_FILTERS.ATTRIBUTE14%TYPE := NULL,
    attribute15                    CS_COUNTER_DER_FILTERS.ATTRIBUTE15%TYPE := NULL,
    context                        CS_COUNTER_DER_FILTERS.CONTEXT%TYPE := NULL,
    object_version_number          NUMBER := NULL);
  G_MISS_counterfilter_rec                CounterFilter_Rec_Type;
  TYPE CounterFilter_Val_Rec_Type IS RECORD (
    counter_der_filter_id          NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    counter_id                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    seq_no                         NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    left_paren                     CS_COUNTER_DER_FILTERS.LEFT_PAREN%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    counter_property_id            NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    relational_operator            CS_COUNTER_DER_FILTERS.RELATIONAL_OPERATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    right_paren                    CS_COUNTER_DER_FILTERS.RIGHT_PAREN%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    right_value                    CS_COUNTER_DER_FILTERS.RIGHT_VALUE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    logical_operator               CS_COUNTER_DER_FILTERS.LOGICAL_OPERATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    last_update_date               CS_COUNTER_DER_FILTERS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    last_updated_by                NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    creation_date                  CS_COUNTER_DER_FILTERS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    created_by                     NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    last_update_login              NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    attribute1                     CS_COUNTER_DER_FILTERS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute2                     CS_COUNTER_DER_FILTERS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute3                     CS_COUNTER_DER_FILTERS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute4                     CS_COUNTER_DER_FILTERS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute5                     CS_COUNTER_DER_FILTERS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute6                     CS_COUNTER_DER_FILTERS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute7                     CS_COUNTER_DER_FILTERS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute8                     CS_COUNTER_DER_FILTERS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute9                     CS_COUNTER_DER_FILTERS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute10                    CS_COUNTER_DER_FILTERS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute11                    CS_COUNTER_DER_FILTERS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute12                    CS_COUNTER_DER_FILTERS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute13                    CS_COUNTER_DER_FILTERS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute14                    CS_COUNTER_DER_FILTERS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    attribute15                    CS_COUNTER_DER_FILTERS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    context                        CS_COUNTER_DER_FILTERS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    object_version_number          NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
  G_MISS_counterfilter_val_rec            CounterFilter_Val_Rec_Type;
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
  G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'CS_COUNTERFILTER_PVT';
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
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counterfilter_rec            IN CounterFilter_Rec_Type := G_MISS_COUNTERFILTER_REC,
    x_counter_der_filter_id        OUT NOCOPY NUMBER,
    x_object_version_number        OUT NOCOPY NUMBER);

  PROCEDURE insert_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counter_id                   IN NUMBER := NULL,
    p_seq_no                       IN NUMBER := NULL,
    p_left_paren                   IN CS_COUNTER_DER_FILTERS.LEFT_PAREN%TYPE := NULL,
    p_counter_property_id          IN NUMBER := NULL,
    p_relational_operator          IN CS_COUNTER_DER_FILTERS.RELATIONAL_OPERATOR%TYPE := NULL,
    p_right_paren                  IN CS_COUNTER_DER_FILTERS.RIGHT_PAREN%TYPE := NULL,
    p_right_value                  IN CS_COUNTER_DER_FILTERS.RIGHT_VALUE%TYPE := NULL,
    p_logical_operator             IN CS_COUNTER_DER_FILTERS.LOGICAL_OPERATOR%TYPE := NULL,
    p_last_update_date             IN CS_COUNTER_DER_FILTERS.LAST_UPDATE_DATE%TYPE := NULL,
    p_last_updated_by              IN NUMBER := NULL,
    p_creation_date                IN CS_COUNTER_DER_FILTERS.CREATION_DATE%TYPE := NULL,
    p_created_by                   IN NUMBER := NULL,
    p_last_update_login            IN NUMBER := NULL,
    p_attribute1                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE1%TYPE := NULL,
    p_attribute2                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE2%TYPE := NULL,
    p_attribute3                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE3%TYPE := NULL,
    p_attribute4                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE4%TYPE := NULL,
    p_attribute5                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE5%TYPE := NULL,
    p_attribute6                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE6%TYPE := NULL,
    p_attribute7                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE7%TYPE := NULL,
    p_attribute8                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE8%TYPE := NULL,
    p_attribute9                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE9%TYPE := NULL,
    p_attribute10                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE10%TYPE := NULL,
    p_attribute11                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE11%TYPE := NULL,
    p_attribute12                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE12%TYPE := NULL,
    p_attribute13                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE13%TYPE := NULL,
    p_attribute14                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE14%TYPE := NULL,
    p_attribute15                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE15%TYPE := NULL,
    p_context                      IN CS_COUNTER_DER_FILTERS.CONTEXT%TYPE := NULL,
    p_object_version_number        IN NUMBER := NULL,
    x_counter_der_filter_id        OUT NOCOPY NUMBER,
    x_object_version_number        OUT NOCOPY NUMBER);
  Procedure lock_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counter_der_filter_id        IN NUMBER,
    p_object_version_number        IN NUMBER);
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counterfilter_val_rec        IN CounterFilter_Val_Rec_Type := G_MISS_COUNTERFILTER_VAL_REC,
    x_object_version_number        OUT NOCOPY NUMBER);
  Procedure update_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counter_der_filter_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_counter_id                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_seq_no                       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_left_paren                   IN CS_COUNTER_DER_FILTERS.LEFT_PAREN%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_counter_property_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_relational_operator          IN CS_COUNTER_DER_FILTERS.RELATIONAL_OPERATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_right_paren                  IN CS_COUNTER_DER_FILTERS.RIGHT_PAREN%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_right_value                  IN CS_COUNTER_DER_FILTERS.RIGHT_VALUE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_logical_operator             IN CS_COUNTER_DER_FILTERS.LOGICAL_OPERATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_COUNTER_DER_FILTERS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COUNTER_DER_FILTERS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COUNTER_DER_FILTERS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    x_object_version_number        OUT NOCOPY NUMBER);
  Procedure delete_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counter_der_filter_id        IN NUMBER);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counterfilter_val_rec        IN CounterFilter_Val_Rec_Type := G_MISS_COUNTERFILTER_VAL_REC);
  PROCEDURE validate_row
  (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    p_validation_level             IN NUMBER,
    p_commit                       IN VARCHAR2 := TAPI_DEV_KIT.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_counter_der_filter_id        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_counter_id                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_seq_no                       IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_left_paren                   IN CS_COUNTER_DER_FILTERS.LEFT_PAREN%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_counter_property_id          IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_relational_operator          IN CS_COUNTER_DER_FILTERS.RELATIONAL_OPERATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_right_paren                  IN CS_COUNTER_DER_FILTERS.RIGHT_PAREN%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_right_value                  IN CS_COUNTER_DER_FILTERS.RIGHT_VALUE%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_logical_operator             IN CS_COUNTER_DER_FILTERS.LOGICAL_OPERATOR%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_last_update_date             IN CS_COUNTER_DER_FILTERS.LAST_UPDATE_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_last_updated_by              IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_creation_date                IN CS_COUNTER_DER_FILTERS.CREATION_DATE%TYPE := TAPI_DEV_KIT.G_MISS_DATE,
    p_created_by                   IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_last_update_login            IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM,
    p_attribute1                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE1%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute2                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE2%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute3                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE3%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute4                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE4%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute5                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE5%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute6                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE6%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute7                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE7%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute8                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE8%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute9                   IN CS_COUNTER_DER_FILTERS.ATTRIBUTE9%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute10                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE10%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute11                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE11%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute12                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE12%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute13                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE13%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute14                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE14%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_attribute15                  IN CS_COUNTER_DER_FILTERS.ATTRIBUTE15%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_context                      IN CS_COUNTER_DER_FILTERS.CONTEXT%TYPE := TAPI_DEV_KIT.G_MISS_CHAR,
    p_object_version_number        IN NUMBER := TAPI_DEV_KIT.G_MISS_NUM);
END CS_COUNTERFILTER_PVT;

 

/

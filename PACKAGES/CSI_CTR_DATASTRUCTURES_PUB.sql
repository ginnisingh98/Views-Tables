--------------------------------------------------------
--  DDL for Package CSI_CTR_DATASTRUCTURES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_DATASTRUCTURES_PUB" AUTHID CURRENT_USER as
/* $Header: csitcdds.pls 120.8 2008/04/01 21:26:21 devijay ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_CTR_DATASTRUCTURES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitctds.pls';

TYPE dff_rec_Type IS RECORD
(attribute_category		VARCHAR2(30)
 ,attribute1			VARCHAR2(150)
 ,attribute2			VARCHAR2(150)
 ,attribute3			VARCHAR2(150)
 ,attribute4			VARCHAR2(150)
 ,attribute5			VARCHAR2(150)
 ,attribute6			VARCHAR2(150)
 ,attribute7			VARCHAR2(150)
 ,attribute8			VARCHAR2(150)
 ,attribute9			VARCHAR2(150)
 ,attribute10			VARCHAR2(150)
 ,attribute11			VARCHAR2(150)
 ,attribute12			VARCHAR2(150)
 ,attribute13			VARCHAR2(150)
 ,attribute14			VARCHAR2(150)
 ,attribute15			VARCHAR2(150)
 ,attribute16			VARCHAR2(150)
 ,attribute17			VARCHAR2(150)
 ,attribute18			VARCHAR2(150)
 ,attribute19			VARCHAR2(150)
 ,attribute20			VARCHAR2(150)
 ,attribute21			VARCHAR2(150)
 ,attribute22			VARCHAR2(150)
 ,attribute23			VARCHAR2(150)
 ,attribute24			VARCHAR2(150)
 ,attribute25			VARCHAR2(150)
 ,attribute26			VARCHAR2(150)
 ,attribute27			VARCHAR2(150)
 ,attribute28			VARCHAR2(150)
 ,attribute29			VARCHAR2(150)
 ,attribute30			VARCHAR2(150)
);

TYPE counter_groups_rec IS RECORD
(COUNTER_GROUP_ID                     NUMBER
 ,NAME                                VARCHAR2(100)
 ,DESCRIPTION                         VARCHAR2(240)
 ,TEMPLATE_FLAG                       VARCHAR2(1)
 -- ,CP_SERVICE_ID                       NUMBER(15)
 -- ,CUSTOMER_PRODUCT_ID                 NUMBER(15)
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,START_DATE_ACTIVE                   DATE
 ,END_DATE_ACTIVE                     DATE
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,CONTEXT                             VARCHAR2(150)
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,CREATED_FROM_CTR_GRP_TMPL_ID        NUMBER
 ,ASSOCIATION_TYPE                    VARCHAR2(30)
 ,SOURCE_OBJECT_CODE                  VARCHAR2(30)
 ,SOURCE_OBJECT_ID                    NUMBER
 ,SOURCE_COUNTER_GROUP_ID             NUMBER
 ,SECURITY_GROUP_ID                   NUMBER
 ,UPGRADED_STATUS_FLAG                VARCHAR2(1)
);
TYPE counter_groups_tbl IS TABLE OF counter_groups_rec INDEX BY BINARY_INTEGER;

TYPE counter_template_rec IS RECORD
(COUNTER_ID                           NUMBER
 ,GROUP_ID                             NUMBER
 ,COUNTER_TYPE                         VARCHAR2(30)
 ,INITIAL_READING                      NUMBER
 ,INITIAL_READING_DATE                 DATE
 ,TOLERANCE_PLUS                       NUMBER
 ,TOLERANCE_MINUS                      NUMBER
 ,UOM_CODE                             VARCHAR2(3)
 ,DERIVE_COUNTER_ID                    NUMBER
 ,DERIVE_FUNCTION                      VARCHAR2(30)
 ,DERIVE_PROPERTY_ID                   NUMBER
 ,VALID_FLAG                           VARCHAR2(1)
 ,FORMULA_INCOMPLETE_FLAG              VARCHAR2(1)
 ,FORMULA_TEXT                         VARCHAR2(1996)
 ,ROLLOVER_LAST_READING                NUMBER
 ,ROLLOVER_FIRST_READING               NUMBER
 ,USAGE_ITEM_ID                        NUMBER
 ,CTR_VAL_MAX_SEQ_NO                   NUMBER
 ,START_DATE_ACTIVE                    DATE
 ,END_DATE_ACTIVE                      DATE
 ,OBJECT_VERSION_NUMBER                NUMBER
 ,LAST_UPDATE_DATE                     DATE
 ,LAST_UPDATED_BY                      NUMBER
 ,CREATION_DATE                        DATE
 ,CREATED_BY                           NUMBER
 ,LAST_UPDATE_LOGIN                    NUMBER
 ,ATTRIBUTE1                           VARCHAR2(150)
 ,ATTRIBUTE2                           VARCHAR2(150)
 ,ATTRIBUTE3                           VARCHAR2(150)
 ,ATTRIBUTE4                           VARCHAR2(150)
 ,ATTRIBUTE5                           VARCHAR2(150)
 ,ATTRIBUTE6                           VARCHAR2(150)
 ,ATTRIBUTE7                           VARCHAR2(150)
 ,ATTRIBUTE8                           VARCHAR2(150)
 ,ATTRIBUTE9                           VARCHAR2(150)
 ,ATTRIBUTE10                          VARCHAR2(150)
 ,ATTRIBUTE11                          VARCHAR2(150)
 ,ATTRIBUTE12                          VARCHAR2(150)
 ,ATTRIBUTE13                          VARCHAR2(150)
 ,ATTRIBUTE14                          VARCHAR2(150)
 ,ATTRIBUTE15                          VARCHAR2(150)
 ,ATTRIBUTE16                          VARCHAR2(150)
 ,ATTRIBUTE17                          VARCHAR2(150)
 ,ATTRIBUTE18                          VARCHAR2(150)
 ,ATTRIBUTE19                          VARCHAR2(150)
 ,ATTRIBUTE20                          VARCHAR2(150)
 ,ATTRIBUTE21                          VARCHAR2(150)
 ,ATTRIBUTE22                          VARCHAR2(150)
 ,ATTRIBUTE23                          VARCHAR2(150)
 ,ATTRIBUTE24                          VARCHAR2(150)
 ,ATTRIBUTE25                          VARCHAR2(150)
 ,ATTRIBUTE26                          VARCHAR2(150)
 ,ATTRIBUTE27                          VARCHAR2(150)
 ,ATTRIBUTE28                          VARCHAR2(150)
 ,ATTRIBUTE29                          VARCHAR2(150)
 ,ATTRIBUTE30                          VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                   VARCHAR2(30)
 ,MIGRATED_FLAG                        VARCHAR2(1)
 ,CUSTOMER_VIEW                        VARCHAR2(1)
 ,DIRECTION                            VARCHAR2(1)
 ,FILTER_TYPE                          VARCHAR2(30)
 ,FILTER_READING_COUNT                 NUMBER
 ,FILTER_TIME_UOM                      VARCHAR2(30)
 ,ESTIMATION_ID                        NUMBER
 ,READING_TYPE                         NUMBER
 ,AUTOMATIC_ROLLOVER                   VARCHAR2(1)
 ,DEFAULT_USAGE_RATE                   NUMBER
 ,USE_PAST_READING                     NUMBER
 ,USED_IN_SCHEDULING                   VARCHAR2(1)
 ,DEFAULTED_GROUP_ID                   NUMBER
 ,SECURITY_GROUP_ID                    NUMBER
 ,NAME                                 VARCHAR2(50)
 ,DESCRIPTION                          VARCHAR2(240)
 ,COMMENTS                             VARCHAR2(1996)
 ,ASSOCIATION_TYPE                     VARCHAR2(30)
 ,STEP_VALUE                           NUMBER
 ,TIME_BASED_MANUAL_ENTRY              VARCHAR2(1)
 ,EAM_REQUIRED_FLAG                    VARCHAR2(1)
);
TYPE counter_template_tbl IS TABLE OF counter_template_rec INDEX BY BINARY_INTEGER;

TYPE ctr_item_associations_rec IS RECORD
(CTR_ASSOCIATION_ID                   NUMBER
 ,GROUP_ID                            NUMBER
 ,INVENTORY_ITEM_ID                   NUMBER
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,SECURITY_GROUP_ID                   NUMBER
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,COUNTER_ID                          NUMBER
 ,START_DATE_ACTIVE                   DATE
 ,END_DATE_ACTIVE                     DATE
 ,USAGE_RATE                          NUMBER
 ,USE_PAST_READING                    NUMBER
 ,ASSOCIATED_TO_GROUP                 VARCHAR2(1)
 ,MAINT_ORGANIZATION_ID               NUMBER
 ,PRIMARY_FAILURE_FLAG                VARCHAR2(1)
);
TYPE ctr_item_associations_tbl IS TABLE OF ctr_item_associations_rec INDEX BY BINARY_INTEGER;

TYPE counter_relationships_rec IS RECORD
(RELATIONSHIP_ID                      NUMBER
 ,CTR_ASSOCIATION_ID                  NUMBER
 ,RELATIONSHIP_TYPE_CODE              VARCHAR2(30)
 ,SOURCE_COUNTER_ID                   NUMBER
 ,OBJECT_COUNTER_ID                   NUMBER
 ,ACTIVE_START_DATE                   DATE
 ,ACTIVE_END_DATE                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,SECURITY_GROUP_ID                   NUMBER
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,BIND_VARIABLE_NAME                  VARCHAR2(30)
 ,FACTOR                              NUMBER
);
TYPE counter_relationships_tbl IS TABLE OF counter_relationships_rec INDEX BY BINARY_INTEGER;

TYPE ctr_property_template_rec IS RECORD
(COUNTER_PROPERTY_ID                  NUMBER
 ,COUNTER_ID                          NUMBER
 ,PROPERTY_DATA_TYPE                  VARCHAR2(30)
 ,IS_NULLABLE                         VARCHAR2(1)
 ,DEFAULT_VALUE                       VARCHAR2(240)
 ,MINIMUM_VALUE                       VARCHAR2(240)
 ,MAXIMUM_VALUE                       VARCHAR2(240)
 ,UOM_CODE                            VARCHAR2(3)
 ,START_DATE_ACTIVE                   DATE
 ,END_DATE_ACTIVE                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,PROPERTY_LOV_TYPE                   VARCHAR2(30)
 ,SECURITY_GROUP_ID                   NUMBER
 ,NAME                                VARCHAR2(50)
 ,DESCRIPTION                         VARCHAR2(240)
);
TYPE ctr_property_template_tbl IS TABLE OF ctr_property_template_rec INDEX BY BINARY_INTEGER;

TYPE ctr_estimation_methods_rec IS RECORD
(ESTIMATION_ID                        NUMBER
 ,ESTIMATION_TYPE                     VARCHAR2(10)
 ,FIXED_VALUE                         NUMBER
 ,USAGE_MARKUP                        NUMBER
 ,DEFAULT_VALUE                       NUMBER
 ,ESTIMATION_AVG_TYPE                 VARCHAR2(10)
 ,START_DATE_ACTIVE                   DATE
 ,END_DATE_ACTIVE                     DATE
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,NAME                                VARCHAR2(50)
 ,DESCRIPTION                         VARCHAR2(240)
);
TYPE ctr_estimation_methods_tbl IS TABLE OF ctr_estimation_methods_rec INDEX BY BINARY_INTEGER;

TYPE ctr_derived_filters_rec IS RECORD
(COUNTER_DERIVED_FILTER_ID            NUMBER
 ,COUNTER_ID                          NUMBER
 ,SEQ_NO                              NUMBER
 ,LEFT_PARENT                         VARCHAR2(30)
 ,COUNTER_PROPERTY_ID                 NUMBER
 ,RELATIONAL_OPERATOR                 VARCHAR2(30)
 ,RIGHT_VALUE                         VARCHAR2(240)
 ,RIGHT_PARENT                        VARCHAR2(30)
 ,LOGICAL_OPERATOR                    VARCHAR2(30)
 ,START_DATE_ACTIVE                   DATE
 ,END_DATE_ACTIVE                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,SECURITY_GROUP_ID                   NUMBER
 ,MIGRATED_FLAG                       VARCHAR2(1)
);
TYPE ctr_derived_filters_tbl IS TABLE OF ctr_derived_filters_rec INDEX BY BINARY_INTEGER;


TYPE counter_instance_rec IS RECORD
(COUNTER_ID                            NUMBER
 ,GROUP_ID                             NUMBER
 ,COUNTER_TYPE                         VARCHAR2(30)
 ,INITIAL_READING                      NUMBER
 ,INITIAL_READING_DATE                 DATE
 ,CREATED_FROM_COUNTER_TMPL_ID         NUMBER
 ,TOLERANCE_PLUS                       NUMBER
 ,TOLERANCE_MINUS                      NUMBER
 ,UOM_CODE                             VARCHAR2(3)
 ,DERIVE_COUNTER_ID                    NUMBER
 ,DERIVE_FUNCTION                      VARCHAR2(30)
 ,DERIVE_PROPERTY_ID                   NUMBER
 ,VALID_FLAG                           VARCHAR2(1)
 ,FORMULA_INCOMPLETE_FLAG              VARCHAR2(1)
 ,FORMULA_TEXT                         VARCHAR2(1996)
 ,ROLLOVER_LAST_READING                NUMBER
 ,ROLLOVER_FIRST_READING               NUMBER
 ,USAGE_ITEM_ID                        NUMBER
 ,CTR_VAL_MAX_SEQ_NO                   NUMBER
 ,START_DATE_ACTIVE                    DATE
 ,END_DATE_ACTIVE                      DATE
 ,OBJECT_VERSION_NUMBER                NUMBER
 ,LAST_UPDATE_DATE                     DATE
 ,LAST_UPDATED_BY                      NUMBER
 ,CREATION_DATE                        DATE
 ,CREATED_BY                           NUMBER
 ,LAST_UPDATE_LOGIN                    NUMBER
 ,ATTRIBUTE1                           VARCHAR2(150)
 ,ATTRIBUTE2                           VARCHAR2(150)
 ,ATTRIBUTE3                           VARCHAR2(150)
 ,ATTRIBUTE4                           VARCHAR2(150)
 ,ATTRIBUTE5                           VARCHAR2(150)
 ,ATTRIBUTE6                           VARCHAR2(150)
 ,ATTRIBUTE7                           VARCHAR2(150)
 ,ATTRIBUTE8                           VARCHAR2(150)
 ,ATTRIBUTE9                           VARCHAR2(150)
 ,ATTRIBUTE10                          VARCHAR2(150)
 ,ATTRIBUTE11                          VARCHAR2(150)
 ,ATTRIBUTE12                          VARCHAR2(150)
 ,ATTRIBUTE13                          VARCHAR2(150)
 ,ATTRIBUTE14                          VARCHAR2(150)
 ,ATTRIBUTE15                          VARCHAR2(150)
 ,ATTRIBUTE16                          VARCHAR2(150)
 ,ATTRIBUTE17                          VARCHAR2(150)
 ,ATTRIBUTE18                          VARCHAR2(150)
 ,ATTRIBUTE19                          VARCHAR2(150)
 ,ATTRIBUTE20                          VARCHAR2(150)
 ,ATTRIBUTE21                          VARCHAR2(150)
 ,ATTRIBUTE22                          VARCHAR2(150)
 ,ATTRIBUTE23                          VARCHAR2(150)
 ,ATTRIBUTE24                          VARCHAR2(150)
 ,ATTRIBUTE25                          VARCHAR2(150)
 ,ATTRIBUTE26                          VARCHAR2(150)
 ,ATTRIBUTE27                          VARCHAR2(150)
 ,ATTRIBUTE28                          VARCHAR2(150)
 ,ATTRIBUTE29                          VARCHAR2(150)
 ,ATTRIBUTE30                          VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                   VARCHAR2(30)
 ,MIGRATED_FLAG                        VARCHAR2(1)
 ,CUSTOMER_VIEW                        VARCHAR2(1)
 ,DIRECTION                            VARCHAR2(1)
 ,FILTER_TYPE                          VARCHAR2(30)
 ,FILTER_READING_COUNT                 NUMBER
 ,FILTER_TIME_UOM                      VARCHAR2(30)
 ,ESTIMATION_ID                        NUMBER
 ,READING_TYPE                         NUMBER
 ,AUTOMATIC_ROLLOVER                   VARCHAR2(1)
 ,DEFAULT_USAGE_RATE                   NUMBER
 ,USE_PAST_READING                     NUMBER
 ,USED_IN_SCHEDULING                   VARCHAR2(1)
 ,DEFAULTED_GROUP_ID                   NUMBER
 ,SECURITY_GROUP_ID                    NUMBER
 ,NAME                                 VARCHAR2(50)
 ,DESCRIPTION                          VARCHAR2(240)
 ,COMMENTS                             VARCHAR2(1996)
 ,STEP_VALUE                           NUMBER
 ,TIME_BASED_MANUAL_ENTRY              VARCHAR2(1)
 ,EAM_REQUIRED_FLAG                    VARCHAR2(1)
);
TYPE counter_instance_tbl IS TABLE OF counter_instance_rec INDEX BY BINARY_INTEGER;


TYPE ctr_properties_rec IS RECORD
(COUNTER_PROPERTY_ID                  NUMBER
 ,COUNTER_ID                          NUMBER
 ,PROPERTY_DATA_TYPE                  VARCHAR2(30)
 ,IS_NULLABLE                         VARCHAR2(1)
 ,DEFAULT_VALUE                       VARCHAR2(240)
 ,MINIMUM_VALUE                       VARCHAR2(240)
 ,MAXIMUM_VALUE                       VARCHAR2(240)
 ,UOM_CODE                            VARCHAR2(3)
 ,START_DATE_ACTIVE                   DATE
 ,END_DATE_ACTIVE                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,PROPERTY_LOV_TYPE                   VARCHAR2(30)
 ,CREATED_FROM_CTR_PROP_TMPL_ID       NUMBER
 ,SECURITY_GROUP_ID                   NUMBER
 ,NAME                                VARCHAR2(50)
 ,DESCRIPTION                         VARCHAR2(240)
);
TYPE ctr_properties_tbl IS TABLE OF ctr_properties_rec INDEX BY BINARY_INTEGER;

TYPE counter_associations_rec IS RECORD
(INSTANCE_ASSOCIATION_ID              NUMBER
 ,SOURCE_OBJECT_CODE                  VARCHAR2(30)
 ,SOURCE_OBJECT_ID                    NUMBER
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,SECURITY_GROUP_ID                   NUMBER
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,COUNTER_ID                          NUMBER
 ,START_DATE_ACTIVE                   DATE
 ,END_DATE_ACTIVE                     DATE
 ,MAINT_ORGANIZATION_ID               NUMBER
 ,PRIMARY_FAILURE_FLAG                VARCHAR2(1)
);
TYPE counter_associations_tbl IS TABLE OF counter_associations_rec INDEX BY BINARY_INTEGER;

TYPE counter_readings_rec IS RECORD
(COUNTER_VALUE_ID                     NUMBER
 ,COUNTER_ID                          NUMBER
 ,VALUE_TIMESTAMP                     DATE
 ,COUNTER_READING                     NUMBER
 ,RESET_MODE                          VARCHAR2(30)
 ,RESET_REASON                        VARCHAR2(255)
 ,ADJUSTMENT_TYPE                     VARCHAR2(30)
 ,ADJUSTMENT_READING                  NUMBER
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE16                         VARCHAR2(150)
 ,ATTRIBUTE17                         VARCHAR2(150)
 ,ATTRIBUTE18                         VARCHAR2(150)
 ,ATTRIBUTE19                         VARCHAR2(150)
 ,ATTRIBUTE20                         VARCHAR2(150)
 ,ATTRIBUTE21                         VARCHAR2(150)
 ,ATTRIBUTE22                         VARCHAR2(150)
 ,ATTRIBUTE23                         VARCHAR2(150)
 ,ATTRIBUTE24                         VARCHAR2(150)
 ,ATTRIBUTE25                         VARCHAR2(150)
 ,ATTRIBUTE26                         VARCHAR2(150)
 ,ATTRIBUTE27                         VARCHAR2(150)
 ,ATTRIBUTE28                         VARCHAR2(150)
 ,ATTRIBUTE29                         VARCHAR2(150)
 ,ATTRIBUTE30                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,COMMENTS                            VARCHAR2(2000)
 ,LIFE_TO_DATE_READING                NUMBER
 ,TRANSACTION_ID                      NUMBER
 ,AUTOMATIC_ROLLOVER_FLAG             VARCHAR2(1)
 ,INCLUDE_TARGET_RESETS               VARCHAR2(1)
 ,SOURCE_COUNTER_VALUE_ID             NUMBER
 ,RESET_COUNTER_READING               NUMBER
 ,NET_READING                         NUMBER
 ,DISABLED_FLAG                       VARCHAR2(1)
 ,SOURCE_CODE                         VARCHAR2(30)
 ,SOURCE_LINE_ID                      NUMBER
 ,SECURITY_GROUP_ID                   NUMBER
 ,PARENT_TBL_INDEX                    NUMBER
 ,INITIAL_READING_FLAG                VARCHAR2(1)
);
TYPE counter_readings_tbl IS TABLE OF counter_readings_rec INDEX BY BINARY_INTEGER;

TYPE ctr_property_readings_rec IS RECORD
(COUNTER_PROP_VALUE_ID                NUMBER
 ,COUNTER_VALUE_ID                    NUMBER
 ,COUNTER_PROPERTY_ID                 NUMBER
 ,PROPERTY_VALUE                      VARCHAR2(240)
 ,VALUE_TIMESTAMP                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,MIGRATED_FLAG                       VARCHAR2(1)
 ,SECURITY_GROUP_ID                   NUMBER
 ,PARENT_TBL_INDEX                    NUMBER
);
TYPE ctr_property_readings_tbl IS TABLE OF ctr_property_readings_rec INDEX BY BINARY_INTEGER;


TYPE ctr_usage_forecast_rec IS RECORD
(INSTANCE_FORECAST_ID                 NUMBER
 ,COUNTER_ID                          NUMBER
 ,USAGE_RATE                          NUMBER
 ,USE_PAST_READING                    NUMBER
 ,ACTIVE_START_DATE                   DATE
 ,ACTIVE_END_DATE                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
);
TYPE ctr_usage_forecast_tbl IS TABLE OF ctr_usage_forecast_rec INDEX BY BINARY_INTEGER;

TYPE ctr_reading_lock_rec IS RECORD
(READING_LOCK_ID                      NUMBER
 ,COUNTER_ID                          NUMBER
 ,READING_LOCK_DATE                   DATE
 ,ACTIVE_START_DATE                   DATE
 ,ACTIVE_END_DATE                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,SOURCE_GROUP_REF_ID                 NUMBER
 ,SOURCE_GROUP_REF                    VARCHAR2(50)
 ,SOURCE_HEADER_REF_ID                NUMBER
 ,SOURCE_HEADER_REF                   VARCHAR2(50)
 ,SOURCE_LINE_REF_ID                  NUMBER
 ,SOURCE_LINE_REF                     VARCHAR2(50)
 ,SOURCE_DIST_REF_ID1                 NUMBER
 ,SOURCE_DIST_REF_ID2                 NUMBER
);


TYPE ctr_reading_lock_tbl IS TABLE OF ctr_reading_lock_rec INDEX BY BINARY_INTEGER;

TYPE ctr_estimated_readings_rec IS RECORD
(ESTIMATED_READING_ID                 NUMBER
 ,COUNTER_ID                          NUMBER
 ,ESTIMATION_ID                       NUMBER
 ,VALUE_TIMESTAMP                     DATE
 ,ESTIMATED_METER_READING             NUMBER
 ,NUM_OF_READINGS                     NUMBER
 ,PERIOD_START_DATE                   DATE
 ,PERIOD_END_DATE                     DATE
 ,AVG_CALCULATION_START_DATE          DATE
 ,ESTIMATED_USAGE                     NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,OBJECT_VERSION_NUMBER               VARCHAR2(240)
 ,MIGRATED_FLAG                       VARCHAR2(1)
);
TYPE ctr_estimated_readings_tbl IS TABLE OF ctr_estimated_readings_rec INDEX BY BINARY_INTEGER;

TYPE ctr_readings_interface_rec IS RECORD
(COUNTER_INTERFACE_ID                 NUMBER
 ,PARALLEL_WORKER_ID                  NUMBER
 ,BATCH_NAME                          VARCHAR2(30)
 ,SOURCE_TRANSACTION_DATE             DATE
 ,PROCESS_STATUS                      VARCHAR2(1)
 ,ERROR_TEXT                          VARCHAR2(240)
 ,COUNTER_VALUE_ID                    NUMBER
 ,COUNTER_ID                          NUMBER
 ,VALUE_TIMESTAMP                     DATE
 ,COUNTER_READING                     NUMBER
 ,RESET_MODE                          VARCHAR2(30)
 ,RESET_REASON                        VARCHAR2(255)
 ,ADJUSTMENT_TYPE                     VARCHAR2(30)
 ,ADJUSTMENT_READING                  NUMBER
 ,NET_READING                         NUMBER
 ,LIFE_TO_DATE_READING                NUMBER
 ,AUTOMATIC_ROLLOVER_FLAG             VARCHAR2(1)
 ,INCLUDE_TARGET_RESETS               VARCHAR2(1)
 ,SOURCE_COUNTER_VALUE_ID             NUMBER
 ,DISABLED_FLAG                       VARCHAR2(1)
 ,COMMENTS                            VARCHAR2(2000)
 ,SECURITY_GROUP_ID                   NUMBER
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE16                         VARCHAR2(150)
 ,ATTRIBUTE17                         VARCHAR2(150)
 ,ATTRIBUTE18                         VARCHAR2(150)
 ,ATTRIBUTE19                         VARCHAR2(150)
 ,ATTRIBUTE20                         VARCHAR2(150)
 ,ATTRIBUTE21                         VARCHAR2(150)
 ,ATTRIBUTE22                         VARCHAR2(150)
 ,ATTRIBUTE23                         VARCHAR2(150)
 ,ATTRIBUTE24                         VARCHAR2(150)
 ,ATTRIBUTE25                         VARCHAR2(150)
 ,ATTRIBUTE26                         VARCHAR2(150)
 ,ATTRIBUTE27                         VARCHAR2(150)
 ,ATTRIBUTE28                         VARCHAR2(150)
 ,ATTRIBUTE29                         VARCHAR2(150)
 ,ATTRIBUTE30                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 ,SOURCE_TRANSACTION_TYPE_ID          NUMBER
 ,SOURCE_TRANSACTION_ID               NUMBER
 ,SOURCE_CODE                         VARCHAR2(30)
 ,SOURCE_LINE_ID                      NUMBER
 ,RESET_COUNTER_READING               NUMBER
 ,COUNTER_NAME                        VARCHAR2(30)
);
TYPE ctr_readings_interface_tbl IS TABLE OF ctr_readings_interface_rec INDEX BY BINARY_INTEGER;

TYPE ctr_read_prop_interface_rec IS RECORD
(COUNTER_INTERFACE_ID                 NUMBER
 ,PARALLEL_WORKER_ID                  NUMBER
 ,ERROR_TEXT                          VARCHAR2(240)
 ,COUNTER_PROP_VALUE_ID               NUMBER
 ,COUNTER_VALUE_ID                    NUMBER
 ,COUNTER_PROPERTY_ID                 NUMBER
 ,PROPERTY_VALUE                      VARCHAR2(240)
 ,VALUE_TIMESTAMP                     DATE
 ,OBJECT_VERSION_NUMBER               NUMBER
 ,LAST_UPDATE_DATE                    DATE
 ,LAST_UPDATED_BY                     NUMBER
 ,CREATION_DATE                       DATE
 ,CREATED_BY                          NUMBER
 ,LAST_UPDATE_LOGIN                   NUMBER
 ,ATTRIBUTE1                          VARCHAR2(150)
 ,ATTRIBUTE2                          VARCHAR2(150)
 ,ATTRIBUTE3                          VARCHAR2(150)
 ,ATTRIBUTE4                          VARCHAR2(150)
 ,ATTRIBUTE5                          VARCHAR2(150)
 ,ATTRIBUTE6                          VARCHAR2(150)
 ,ATTRIBUTE7                          VARCHAR2(150)
 ,ATTRIBUTE8                          VARCHAR2(150)
 ,ATTRIBUTE9                          VARCHAR2(150)
 ,ATTRIBUTE10                         VARCHAR2(150)
 ,ATTRIBUTE11                         VARCHAR2(150)
 ,ATTRIBUTE12                         VARCHAR2(150)
 ,ATTRIBUTE13                         VARCHAR2(150)
 ,ATTRIBUTE14                         VARCHAR2(150)
 ,ATTRIBUTE15                         VARCHAR2(150)
 ,ATTRIBUTE_CATEGORY                  VARCHAR2(30)
);
TYPE ctr_read_prop_interface_tbl IS TABLE OF ctr_read_prop_interface_rec INDEX BY BINARY_INTEGER;

TYPE Ctr_Rec_Type IS RECORD
(
   ctr_tbl_index                NUMBER
   ,counter_group_id		NUMBER
   ,name			VARCHAR2(30)
   ,description			VARCHAR2(240)
   ,type			VARCHAR2(30)
   ,step_value			NUMBER
   ,initial_reading		NUMBER
   ,rollover_last_reading	NUMBER
   ,rollover_first_reading	NUMBER
   ,uom_code			VARCHAR2(3)
   ,tolerance_plus		NUMBER
   ,tolerance_minus		NUMBER
   ,derive_function		VARCHAR2(30)
   ,derive_counter_id		NUMBER
   ,derive_property_id		NUMBER
   ,formula_text		VARCHAR2(1996)
   ,comments			VARCHAR2(1996)
   ,usage_item_id		NUMBER
   ,start_date_active		DATE
   ,end_date_active		DATE
   ,desc_flex			DFF_Rec_Type
   ,customer_view               VARCHAR2(1)
   ,direction                   VARCHAR2(1)
   ,filter_reading_count        NUMBER
   ,filter_type			VARCHAR2(30)
   ,filter_time_uom		VARCHAR2(30)
   ,estimation_id		NUMBER
);

TYPE Ctr_Prop_Rec_Type IS RECORD
(
   ctr_tbl_index           	NUMBER
   ,counter_id			NUMBER
   ,name		 	VARCHAR2(30)
   ,description			VARCHAR2(240)
   ,property_data_type		VARCHAR2(30)
   ,is_nullable			VARCHAR2(1)
   ,default_value		VARCHAR2(240)
   ,minimum_value		VARCHAR2(240)
   ,maximum_value		VARCHAR2(240)
   ,uom_code			VARCHAR2(3)
   ,start_date_active		DATE
   ,end_date_active		DATE
   ,desc_flex			DFF_Rec_Type
   ,property_lov_type       	VARCHAR2(30)
);

End CSI_CTR_DATASTRUCTURES_PUB;

/

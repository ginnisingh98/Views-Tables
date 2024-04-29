--------------------------------------------------------
--  DDL for Package CSI_COUNTER_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_TEMPLATE_PKG" AUTHID CURRENT_USER as
/* $Header: csitctts.pls 120.2 2006/02/06 12:55:25 epajaril noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_COUNTER_TEMPLATE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitctts.pls';

PROCEDURE Insert_Row(
 	 px_COUNTER_ID	                IN OUT NOCOPY NUMBER
	,p_GROUP_ID                     NUMBER
	,p_COUNTER_TYPE                 VARCHAR2
	,p_INITIAL_READING              NUMBER
	,p_INITIAL_READING_DATE         DATE
	,p_TOLERANCE_PLUS               NUMBER
	,p_TOLERANCE_MINUS              NUMBER
	,p_UOM_CODE                     VARCHAR2
	,p_DERIVE_COUNTER_ID            NUMBER
	,p_DERIVE_FUNCTION              VARCHAR2
	,p_DERIVE_PROPERTY_ID           NUMBER
	,p_VALID_FLAG                   VARCHAR2
	,p_FORMULA_INCOMPLETE_FLAG      VARCHAR2
	,p_FORMULA_TEXT                 VARCHAR2
	,p_ROLLOVER_LAST_READING        NUMBER
	,p_ROLLOVER_FIRST_READING	NUMBER
	,p_USAGE_ITEM_ID                NUMBER
	,p_CTR_VAL_MAX_SEQ_NO           NUMBER
	,p_START_DATE_ACTIVE            DATE
	,p_END_DATE_ACTIVE              DATE
	,p_OBJECT_VERSION_NUMBER        NUMBER
	,p_SECURITY_GROUP_ID            NUMBER
	,p_LAST_UPDATE_DATE             DATE
	,p_LAST_UPDATED_BY              NUMBER
	,p_CREATION_DATE                DATE
	,p_CREATED_BY                   NUMBER
	,p_LAST_UPDATE_LOGIN            NUMBER
	,p_ATTRIBUTE1                   VARCHAR2
	,p_ATTRIBUTE2                   VARCHAR2
	,p_ATTRIBUTE3                   VARCHAR2
	,p_ATTRIBUTE4                   VARCHAR2
	,p_ATTRIBUTE5                   VARCHAR2
	,p_ATTRIBUTE6                   VARCHAR2
	,p_ATTRIBUTE7                   VARCHAR2
	,p_ATTRIBUTE8                   VARCHAR2
	,p_ATTRIBUTE9                   VARCHAR2
	,p_ATTRIBUTE10                  VARCHAR2
	,p_ATTRIBUTE11                  VARCHAR2
	,p_ATTRIBUTE12                  VARCHAR2
	,p_ATTRIBUTE13                  VARCHAR2
	,p_ATTRIBUTE14                  VARCHAR2
	,p_ATTRIBUTE15                  VARCHAR2
	,p_ATTRIBUTE16                  VARCHAR2
	,p_ATTRIBUTE17                  VARCHAR2
	,p_ATTRIBUTE18                  VARCHAR2
	,p_ATTRIBUTE19                  VARCHAR2
	,p_ATTRIBUTE20                  VARCHAR2
	,p_ATTRIBUTE21                  VARCHAR2
	,p_ATTRIBUTE22                  VARCHAR2
	,p_ATTRIBUTE23                  VARCHAR2
	,p_ATTRIBUTE24                  VARCHAR2
	,p_ATTRIBUTE25                  VARCHAR2
	,p_ATTRIBUTE26                  VARCHAR2
	,p_ATTRIBUTE27                  VARCHAR2
	,p_ATTRIBUTE28                  VARCHAR2
	,p_ATTRIBUTE29                  VARCHAR2
	,p_ATTRIBUTE30                  VARCHAR2
	,p_ATTRIBUTE_CATEGORY           VARCHAR2
	,p_MIGRATED_FLAG                VARCHAR2
	,p_CUSTOMER_VIEW                VARCHAR2
	,p_DIRECTION                    VARCHAR2
	,p_FILTER_TYPE                  VARCHAR2
	,p_FILTER_READING_COUNT         NUMBER
	,p_FILTER_TIME_UOM              VARCHAR2
	,p_ESTIMATION_ID                NUMBER
	,p_ASSOCIATION_TYPE             VARCHAR2
	,p_READING_TYPE                 NUMBER
	,p_AUTOMATIC_ROLLOVER           VARCHAR2
	,p_DEFAULT_USAGE_RATE           NUMBER
	,p_USE_PAST_READING             NUMBER
	,p_USED_IN_SCHEDULING           VARCHAR2
	,p_DEFAULTED_GROUP_ID           NUMBER
        ,p_STEP_VALUE                   NUMBER
        ,p_NAME	                        VARCHAR2
        ,p_DESCRIPTION                  VARCHAR2
        ,p_TIME_BASED_MANUAL_ENTRY      VARCHAR2
        ,p_EAM_REQUIRED_FLAG            VARCHAR2
        );

PROCEDURE Update_Row(
 	 p_COUNTER_ID	                NUMBER
	,p_GROUP_ID                     NUMBER
	,p_COUNTER_TYPE                 VARCHAR2
	,p_INITIAL_READING              NUMBER
        ,p_INITIAL_READING_DATE         DATE
	,p_TOLERANCE_PLUS               NUMBER
	,p_TOLERANCE_MINUS              NUMBER
	,p_UOM_CODE                     VARCHAR2
	,p_DERIVE_COUNTER_ID            NUMBER
	,p_DERIVE_FUNCTION              VARCHAR2
	,p_DERIVE_PROPERTY_ID           NUMBER
	,p_VALID_FLAG                   VARCHAR2
	,p_FORMULA_INCOMPLETE_FLAG      VARCHAR2
	,p_FORMULA_TEXT                 VARCHAR2
	,p_ROLLOVER_LAST_READING        NUMBER
	,p_ROLLOVER_FIRST_READING	NUMBER
	,p_USAGE_ITEM_ID                NUMBER
	,p_CTR_VAL_MAX_SEQ_NO           NUMBER
	,p_START_DATE_ACTIVE            DATE
	,p_END_DATE_ACTIVE              DATE
	,p_OBJECT_VERSION_NUMBER        NUMBER
	,p_SECURITY_GROUP_ID            NUMBER
	,p_LAST_UPDATE_DATE             DATE
	,p_LAST_UPDATED_BY              NUMBER
	,p_CREATION_DATE                DATE
	,p_CREATED_BY                   NUMBER
	,p_LAST_UPDATE_LOGIN            NUMBER
	,p_ATTRIBUTE1                   VARCHAR2
	,p_ATTRIBUTE2                   VARCHAR2
	,p_ATTRIBUTE3                   VARCHAR2
	,p_ATTRIBUTE4                   VARCHAR2
	,p_ATTRIBUTE5                   VARCHAR2
	,p_ATTRIBUTE6                   VARCHAR2
	,p_ATTRIBUTE7                   VARCHAR2
	,p_ATTRIBUTE8                   VARCHAR2
	,p_ATTRIBUTE9                   VARCHAR2
	,p_ATTRIBUTE10                  VARCHAR2
	,p_ATTRIBUTE11                  VARCHAR2
	,p_ATTRIBUTE12                  VARCHAR2
	,p_ATTRIBUTE13                  VARCHAR2
	,p_ATTRIBUTE14                  VARCHAR2
	,p_ATTRIBUTE15                  VARCHAR2
	,p_ATTRIBUTE16                  VARCHAR2
	,p_ATTRIBUTE17                  VARCHAR2
	,p_ATTRIBUTE18                  VARCHAR2
	,p_ATTRIBUTE19                  VARCHAR2
	,p_ATTRIBUTE20                  VARCHAR2
	,p_ATTRIBUTE21                  VARCHAR2
	,p_ATTRIBUTE22                  VARCHAR2
	,p_ATTRIBUTE23                  VARCHAR2
	,p_ATTRIBUTE24                  VARCHAR2
	,p_ATTRIBUTE25                  VARCHAR2
	,p_ATTRIBUTE26                  VARCHAR2
	,p_ATTRIBUTE27                  VARCHAR2
	,p_ATTRIBUTE28                  VARCHAR2
	,p_ATTRIBUTE29                  VARCHAR2
	,p_ATTRIBUTE30                  VARCHAR2
	,p_ATTRIBUTE_CATEGORY           VARCHAR2
	,p_MIGRATED_FLAG                VARCHAR2
	,p_CUSTOMER_VIEW                VARCHAR2
	,p_DIRECTION                    VARCHAR2
	,p_FILTER_TYPE                  VARCHAR2
	,p_FILTER_READING_COUNT         NUMBER
	,p_FILTER_TIME_UOM              VARCHAR2
	,p_ESTIMATION_ID                NUMBER
	,p_ASSOCIATION_TYPE             VARCHAR2
	,p_READING_TYPE                 NUMBER
	,p_AUTOMATIC_ROLLOVER           VARCHAR2
	,p_DEFAULT_USAGE_RATE           NUMBER
	,p_USE_PAST_READING             NUMBER
	,p_USED_IN_SCHEDULING           VARCHAR2
	,p_DEFAULTED_GROUP_ID           NUMBER
        ,p_STEP_VALUE                   NUMBER
        ,p_NAME	                        VARCHAR2
        ,p_DESCRIPTION                  VARCHAR2
        ,p_TIME_BASED_MANUAL_ENTRY      VARCHAR2
        ,p_EAM_REQUIRED_FLAG            VARCHAR2
        );

PROCEDURE Lock_Row(
 	 p_COUNTER_ID	                NUMBER
	,p_GROUP_ID                     NUMBER
	,p_COUNTER_TYPE                 VARCHAR2
	,p_INITIAL_READING              NUMBER
        ,p_INITIAL_READING_DATE         DATE
	,p_TOLERANCE_PLUS               NUMBER
	,p_TOLERANCE_MINUS              NUMBER
	,p_UOM_CODE                     VARCHAR2
	,p_DERIVE_COUNTER_ID            NUMBER
	,p_DERIVE_FUNCTION              VARCHAR2
	,p_DERIVE_PROPERTY_ID           NUMBER
	,p_VALID_FLAG                   VARCHAR2
	,p_FORMULA_INCOMPLETE_FLAG      VARCHAR2
	,p_FORMULA_TEXT                 VARCHAR2
	,p_ROLLOVER_LAST_READING        NUMBER
	,p_ROLLOVER_FIRST_READING	NUMBER
	,p_USAGE_ITEM_ID                NUMBER
	,p_CTR_VAL_MAX_SEQ_NO           NUMBER
	,p_START_DATE_ACTIVE            DATE
	,p_END_DATE_ACTIVE              DATE
	,p_OBJECT_VERSION_NUMBER        NUMBER
	,p_SECURITY_GROUP_ID            NUMBER
	,p_LAST_UPDATE_DATE             DATE
	,p_LAST_UPDATED_BY              NUMBER
	,p_CREATION_DATE                DATE
	,p_CREATED_BY                   NUMBER
	,p_LAST_UPDATE_LOGIN            NUMBER
	,p_ATTRIBUTE1                   VARCHAR2
	,p_ATTRIBUTE2                   VARCHAR2
	,p_ATTRIBUTE3                   VARCHAR2
	,p_ATTRIBUTE4                   VARCHAR2
	,p_ATTRIBUTE5                   VARCHAR2
	,p_ATTRIBUTE6                   VARCHAR2
	,p_ATTRIBUTE7                   VARCHAR2
	,p_ATTRIBUTE8                   VARCHAR2
	,p_ATTRIBUTE9                   VARCHAR2
	,p_ATTRIBUTE10                  VARCHAR2
	,p_ATTRIBUTE11                  VARCHAR2
	,p_ATTRIBUTE12                  VARCHAR2
	,p_ATTRIBUTE13                  VARCHAR2
	,p_ATTRIBUTE14                  VARCHAR2
	,p_ATTRIBUTE15                  VARCHAR2
	,p_ATTRIBUTE16                  VARCHAR2
	,p_ATTRIBUTE17                  VARCHAR2
	,p_ATTRIBUTE18                  VARCHAR2
	,p_ATTRIBUTE19                  VARCHAR2
	,p_ATTRIBUTE20                  VARCHAR2
	,p_ATTRIBUTE21                  VARCHAR2
	,p_ATTRIBUTE22                  VARCHAR2
	,p_ATTRIBUTE23                  VARCHAR2
	,p_ATTRIBUTE24                  VARCHAR2
	,p_ATTRIBUTE25                  VARCHAR2
	,p_ATTRIBUTE26                  VARCHAR2
	,p_ATTRIBUTE27                  VARCHAR2
	,p_ATTRIBUTE28                  VARCHAR2
	,p_ATTRIBUTE29                  VARCHAR2
	,p_ATTRIBUTE30                  VARCHAR2
	,p_ATTRIBUTE_CATEGORY           VARCHAR2
	,p_MIGRATED_FLAG                VARCHAR2
	,p_CUSTOMER_VIEW                VARCHAR2
	,p_DIRECTION                    VARCHAR2
	,p_FILTER_TYPE                  VARCHAR2
	,p_FILTER_READING_COUNT         NUMBER
	,p_FILTER_TIME_UOM              VARCHAR2
	,p_ESTIMATION_ID                NUMBER
	,p_ASSOCIATION_TYPE             VARCHAR2
	,p_READING_TYPE                 NUMBER
	,p_AUTOMATIC_ROLLOVER           VARCHAR2
	,p_DEFAULT_USAGE_RATE           NUMBER
	,p_USE_PAST_READING             NUMBER
	,p_USED_IN_SCHEDULING           VARCHAR2
	,p_DEFAULTED_GROUP_ID           NUMBER
        ,p_STEP_VALUE                   NUMBER
        ,p_NAME	                        VARCHAR2
        ,p_DESCRIPTION                  VARCHAR2
        ,p_TIME_BASED_MANUAL_ENTRY      VARCHAR2
        ,p_EAM_REQUIRED_FLAG            VARCHAR2
        );

PROCEDURE Delete_Row(
       p_COUNTER_ID		NUMBER
       );

PROCEDURE add_language;

PROCEDURE translate_row (
          p_counter_id        NUMBER
          ,p_name              VARCHAR2
          ,p_description       VARCHAR2
          ,p_owner             VARCHAR2);

End CSI_COUNTER_TEMPLATE_PKG;

 

/
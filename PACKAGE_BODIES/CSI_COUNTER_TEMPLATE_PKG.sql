--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_TEMPLATE_PKG" as
/* $Header: csitcttb.pls 120.3 2008/04/02 22:00:06 devijay ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_COUNTER_TEMPLATE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcttb.pls';

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
      )  IS

   CURSOR C1 IS
   SELECT CSI_COUNTERS_B_S.nextval
   FROM   dual;
BEGIN
   IF (px_COUNTER_ID IS NULL) OR (px_COUNTER_ID = FND_API.G_MISS_NUM) then
      OPEN C1;
      FETCH C1 INTO px_COUNTER_ID;
      CLOSE C1;
   END IF;

   INSERT INTO CSI_COUNTER_TEMPLATE_B(
 	 COUNTER_ID
	,GROUP_ID
	,COUNTER_TYPE
	,INITIAL_READING
	,INITIAL_READING_DATE
	,TOLERANCE_PLUS
	,TOLERANCE_MINUS
	,UOM_CODE
	,DERIVE_COUNTER_ID
	,DERIVE_FUNCTION
	,DERIVE_PROPERTY_ID
	,VALID_FLAG
	,FORMULA_INCOMPLETE_FLAG
	,FORMULA_TEXT
	,ROLLOVER_LAST_READING
	,ROLLOVER_FIRST_READING
	,USAGE_ITEM_ID
	,CTR_VAL_MAX_SEQ_NO
	,START_DATE_ACTIVE
	,END_DATE_ACTIVE
	,OBJECT_VERSION_NUMBER
	,SECURITY_GROUP_ID
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_LOGIN
	,ATTRIBUTE1
	,ATTRIBUTE2
	,ATTRIBUTE3
	,ATTRIBUTE4
	,ATTRIBUTE5
	,ATTRIBUTE6
	,ATTRIBUTE7
	,ATTRIBUTE8
	,ATTRIBUTE9
	,ATTRIBUTE10
	,ATTRIBUTE11
	,ATTRIBUTE12
	,ATTRIBUTE13
	,ATTRIBUTE14
	,ATTRIBUTE15
        ,ATTRIBUTE16
        ,ATTRIBUTE17
        ,ATTRIBUTE18
        ,ATTRIBUTE19
        ,ATTRIBUTE20
        ,ATTRIBUTE21
        ,ATTRIBUTE22
        ,ATTRIBUTE23
        ,ATTRIBUTE24
        ,ATTRIBUTE25
        ,ATTRIBUTE26
        ,ATTRIBUTE27
        ,ATTRIBUTE28
        ,ATTRIBUTE29
        ,ATTRIBUTE30
	,ATTRIBUTE_CATEGORY
	,MIGRATED_FLAG
	,CUSTOMER_VIEW
	,DIRECTION
	,FILTER_TYPE
	,FILTER_READING_COUNT
	,FILTER_TIME_UOM
	,ESTIMATION_ID
	,ASSOCIATION_TYPE
	,READING_TYPE
	,AUTOMATIC_ROLLOVER
	,DEFAULT_USAGE_RATE
	,USE_PAST_READING
	,USED_IN_SCHEDULING
	,DEFAULTED_GROUP_ID
	,STEP_VALUE
	,TIME_BASED_MANUAL_ENTRY
	,EAM_REQUIRED_FLAG
      )
   VALUES(
	 px_COUNTER_ID
	,decode(p_GROUP_ID, FND_API.G_MISS_NUM, NULL,p_GROUP_ID)
	,decode(p_COUNTER_TYPE, FND_API.G_MISS_CHAR, NULL,p_COUNTER_TYPE)
	,decode(p_INITIAL_READING, FND_API.G_MISS_NUM, NULL,p_INITIAL_READING)
	,decode(p_INITIAL_READING_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_INITIAL_READING_DATE)
	,decode(p_TOLERANCE_PLUS, FND_API.G_MISS_NUM, NULL,p_TOLERANCE_PLUS)
	,decode(p_TOLERANCE_MINUS, FND_API.G_MISS_NUM, NULL,p_TOLERANCE_MINUS)
	,decode(p_UOM_CODE, FND_API.G_MISS_CHAR, NULL,p_UOM_CODE)
	,decode(p_DERIVE_COUNTER_ID, FND_API.G_MISS_NUM, NULL,p_DERIVE_COUNTER_ID)
	,decode(p_DERIVE_FUNCTION, FND_API.G_MISS_CHAR, NULL,p_DERIVE_FUNCTION)
	,decode(p_DERIVE_PROPERTY_ID, FND_API.G_MISS_NUM, NULL,p_DERIVE_PROPERTY_ID)
	,decode(p_VALID_FLAG, FND_API.G_MISS_CHAR, NULL,p_VALID_FLAG)
	,decode(p_FORMULA_INCOMPLETE_FLAG, FND_API.G_MISS_CHAR, NULL,p_FORMULA_INCOMPLETE_FLAG)
	,decode(p_FORMULA_TEXT, FND_API.G_MISS_CHAR, NULL,p_FORMULA_TEXT)
	,decode(p_ROLLOVER_LAST_READING, FND_API.G_MISS_NUM, NULL,p_ROLLOVER_LAST_READING)
	,decode(p_ROLLOVER_FIRST_READING, FND_API.G_MISS_NUM, NULL,p_ROLLOVER_FIRST_READING)
	,decode(p_USAGE_ITEM_ID, FND_API.G_MISS_NUM, NULL,p_USAGE_ITEM_ID)
	,decode(p_CTR_VAL_MAX_SEQ_NO, FND_API.G_MISS_NUM, NULL,p_CTR_VAL_MAX_SEQ_NO)
	,decode(p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_START_DATE_ACTIVE)
	,decode(p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_END_DATE_ACTIVE)
	,decode(p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL,p_OBJECT_VERSION_NUMBER)
	,decode(p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL,p_SECURITY_GROUP_ID)
	,decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_LAST_UPDATE_DATE)
	,decode(p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,p_LAST_UPDATED_BY)
	,decode(p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),p_CREATION_DATE)
	,decode(p_CREATED_BY, FND_API.G_MISS_NUM, NULL,p_CREATED_BY)
	,decode(p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,p_LAST_UPDATE_LOGIN)
	,decode(p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE1)
	,decode(p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE2)
	,decode(p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE3)
	,decode(p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE4)
	,decode(p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE5)
	,decode(p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE6)
	,decode(p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE7)
	,decode(p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE8)
	,decode(p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE9)
	,decode(p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE10)
	,decode(p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE11)
	,decode(p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE12)
	,decode(p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE13)
	,decode(p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE14)
	,decode(p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE15)
	,decode(p_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE16)
	,decode(p_ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE17)
	,decode(p_ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE18)
	,decode(p_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE19)
	,decode(p_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE20)
	,decode(p_ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE21)
	,decode(p_ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE22)
	,decode(p_ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE23)
	,decode(p_ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE24)
	,decode(p_ATTRIBUTE25, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE25)
	,decode(p_ATTRIBUTE26, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE26)
	,decode(p_ATTRIBUTE27, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE27)
	,decode(p_ATTRIBUTE28, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE28)
	,decode(p_ATTRIBUTE29, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE29)
	,decode(p_ATTRIBUTE30, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE30)
	,decode(p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,p_ATTRIBUTE_CATEGORY)
	,decode(p_MIGRATED_FLAG, FND_API.G_MISS_CHAR, NULL,p_MIGRATED_FLAG)
	,decode(p_CUSTOMER_VIEW, FND_API.G_MISS_CHAR, NULL,p_CUSTOMER_VIEW)
	,decode(p_DIRECTION, FND_API.G_MISS_CHAR, NULL,p_DIRECTION)
	,decode(p_FILTER_TYPE, FND_API.G_MISS_CHAR, NULL,p_FILTER_TYPE)
	,decode(p_FILTER_READING_COUNT, FND_API.G_MISS_NUM, NULL,p_FILTER_READING_COUNT)
	,decode(p_FILTER_TIME_UOM, FND_API.G_MISS_CHAR, NULL,p_FILTER_TIME_UOM)
	,decode(p_ESTIMATION_ID, FND_API.G_MISS_NUM, NULL,p_ESTIMATION_ID)
	,decode(p_ASSOCIATION_TYPE, FND_API.G_MISS_CHAR, NULL,p_ASSOCIATION_TYPE)
	,decode(p_READING_TYPE, FND_API.G_MISS_NUM, NULL,p_READING_TYPE)
	,decode(p_AUTOMATIC_ROLLOVER, FND_API.G_MISS_CHAR, NULL,p_AUTOMATIC_ROLLOVER)
	,decode(p_DEFAULT_USAGE_RATE, FND_API.G_MISS_NUM, NULL,p_DEFAULT_USAGE_RATE)
	,decode(p_USE_PAST_READING, FND_API.G_MISS_NUM, NULL,p_USE_PAST_READING)
	,decode(p_USED_IN_SCHEDULING, FND_API.G_MISS_CHAR, NULL,p_USED_IN_SCHEDULING)
	,decode(p_DEFAULTED_GROUP_ID, FND_API.G_MISS_NUM, NULL,p_DEFAULTED_GROUP_ID)
	,decode(p_STEP_VALUE, FND_API.G_MISS_NUM, NULL,p_STEP_VALUE)
	,decode(p_TIME_BASED_MANUAL_ENTRY, FND_API.G_MISS_CHAR, NULL,p_TIME_BASED_MANUAL_ENTRY)
	,decode(p_EAM_REQUIRED_FLAG, FND_API.G_MISS_CHAR, NULL,p_EAM_REQUIRED_FLAG)
    );

    INSERT INTO CSI_COUNTER_TEMPLATE_TL(
	 COUNTER_ID
	,NAME
	,DESCRIPTION
	,LANGUAGE
	,SOURCE_LANG
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATE_LOGIN
	)
      SELECT  px_counter_id
              ,decode(p_name, fnd_api.g_miss_char, NULL, p_name)
              ,decode(p_description, fnd_api.g_miss_char, NULL, p_description)
              ,l.language_code
              ,userenv('LANG')
              ,decode(p_created_by, fnd_api.g_miss_num, NULL, p_created_by)
              ,decode(p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date)
              ,decode(p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by)
              ,decode(p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date)
              ,decode(p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login)
      FROM   fnd_languages l
      WHERE  l.installed_flag IN ('I','B')
      AND    NOT EXISTS (SELECT 'x'
                         FROM   csi_counter_template_tl cct
                         WHERE  cct.counter_id = px_counter_id
                         AND    cct.language = l.language_code);
End Insert_Row;

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
        ,p_EAM_REQUIRED_FLAG        VARCHAR2) IS
 BEGIN
    UPDATE CSI_COUNTER_TEMPLATE_B
    SET    GROUP_ID = decode(p_GROUP_ID, NULL, GROUP_ID, FND_API.G_MISS_NUM, NULL, p_GROUP_ID)
	   ,COUNTER_TYPE = decode(p_COUNTER_TYPE, NULL, COUNTER_TYPE, FND_API.G_MISS_CHAR, NULL,  p_COUNTER_TYPE)
	   ,INITIAL_READING = decode(p_INITIAL_READING, NULL, INITIAL_READING, FND_API.G_MISS_NUM, NULL, p_INITIAL_READING)
  	   ,INITIAL_READING_DATE = decode(p_INITIAL_READING_DATE, NULL, INITIAL_READING_DATE, FND_API.G_MISS_DATE, NULL, p_INITIAL_READING_DATE)
	   ,TOLERANCE_PLUS = decode(p_TOLERANCE_PLUS, NULL, TOLERANCE_PLUS, FND_API.G_MISS_NUM, NULL, p_TOLERANCE_PLUS)
	   ,TOLERANCE_MINUS = decode(p_TOLERANCE_MINUS, NULL, TOLERANCE_MINUS, FND_API.G_MISS_NUM, NULL, p_TOLERANCE_MINUS)
	   ,UOM_CODE = decode(p_UOM_CODE, NULL, UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_UOM_CODE)
	   ,DERIVE_COUNTER_ID = decode(p_DERIVE_COUNTER_ID, NULL, DERIVE_COUNTER_ID, FND_API.G_MISS_NUM, NULL,  p_DERIVE_COUNTER_ID)
	   ,DERIVE_FUNCTION = decode(p_DERIVE_FUNCTION, NULL, DERIVE_FUNCTION, FND_API.G_MISS_CHAR, NULL, p_DERIVE_FUNCTION)
	   ,DERIVE_PROPERTY_ID = decode(p_DERIVE_PROPERTY_ID, NULL, DERIVE_PROPERTY_ID, FND_API.G_MISS_NUM, NULL,  p_DERIVE_PROPERTY_ID)
	   ,VALID_FLAG = decode(p_VALID_FLAG, NULL, VALID_FLAG, FND_API.G_MISS_CHAR, NULL, p_VALID_FLAG)
	   ,FORMULA_INCOMPLETE_FLAG = decode(p_FORMULA_INCOMPLETE_FLAG, NULL, FORMULA_INCOMPLETE_FLAG, FND_API.G_MISS_CHAR, NULL, p_FORMULA_INCOMPLETE_FLAG)
	   ,FORMULA_TEXT = decode(p_FORMULA_TEXT, NULL, FORMULA_TEXT, FND_API.G_MISS_CHAR, NULL, p_FORMULA_TEXT)
	   ,ROLLOVER_LAST_READING = decode(p_ROLLOVER_LAST_READING, NULL, ROLLOVER_LAST_READING, FND_API.G_MISS_NUM, NULL,  p_ROLLOVER_LAST_READING)
	   ,ROLLOVER_FIRST_READING = decode(p_ROLLOVER_FIRST_READING, NULL, ROLLOVER_FIRST_READING, FND_API.G_MISS_NUM, NULL, p_ROLLOVER_FIRST_READING)
	   ,USAGE_ITEM_ID = decode(p_USAGE_ITEM_ID, NULL, USAGE_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_USAGE_ITEM_ID)
   	   ,CTR_VAL_MAX_SEQ_NO = decode(p_CTR_VAL_MAX_SEQ_NO, NULL, CTR_VAL_MAX_SEQ_NO, FND_API.G_MISS_NUM, CTR_VAL_MAX_SEQ_NO,  p_CTR_VAL_MAX_SEQ_NO)
 	   ,START_DATE_ACTIVE = decode(p_START_DATE_ACTIVE, NULL, START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, p_START_DATE_ACTIVE)
  	   ,END_DATE_ACTIVE = decode(p_END_DATE_ACTIVE, NULL, END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,p_END_DATE_ACTIVE)
	   ,OBJECT_VERSION_NUMBER = decode(p_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
           ,SECURITY_GROUP_ID     = decode(p_SECURITY_GROUP_ID, NULL, SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID)
  	   ,LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE, NULL, LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL,p_LAST_UPDATE_DATE)
	   ,LAST_UPDATED_BY = decode(p_LAST_UPDATED_BY, NULL,LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,p_LAST_UPDATED_BY)
   	    ,CREATION_DATE = decode(p_CREATION_DATE, NULL, CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
	   ,CREATED_BY = decode(p_CREATED_BY, NULL, CREATED_BY, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_CREATED_BY)
	   ,LAST_UPDATE_LOGIN = decode(p_LAST_UPDATE_LOGIN, NULL,LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
	   ,ATTRIBUTE1 = decode(p_ATTRIBUTE1, NULL, ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
	   ,ATTRIBUTE2 = decode(p_ATTRIBUTE2, NULL, ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
	   ,ATTRIBUTE3 = decode(p_ATTRIBUTE3, NULL, ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
	   ,ATTRIBUTE4 = decode(p_ATTRIBUTE4, NULL, ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
	   ,ATTRIBUTE5 = decode(p_ATTRIBUTE5, NULL, ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
	   ,ATTRIBUTE6 = decode(p_ATTRIBUTE6, NULL, ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
	   ,ATTRIBUTE7 = decode(p_ATTRIBUTE7, NULL, ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
	   ,ATTRIBUTE8 = decode(p_ATTRIBUTE8, NULL, ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
	   ,ATTRIBUTE9 = decode(p_ATTRIBUTE9, NULL, ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
	   ,ATTRIBUTE10 = decode(p_ATTRIBUTE10, NULL, ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
	   ,ATTRIBUTE11 = decode(p_ATTRIBUTE11, NULL, ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
	   ,ATTRIBUTE12 = decode(p_ATTRIBUTE12, NULL, ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
	   ,ATTRIBUTE13 = decode(p_ATTRIBUTE13, NULL, ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
	   ,ATTRIBUTE14 = decode(p_ATTRIBUTE14, NULL, ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
	   ,ATTRIBUTE15 = decode(p_ATTRIBUTE15, NULL, ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
	   ,ATTRIBUTE16 = decode(p_ATTRIBUTE16, NULL, ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE16)
           ,ATTRIBUTE17 = decode(p_ATTRIBUTE17, NULL, ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE17)
           ,ATTRIBUTE18 = decode(p_ATTRIBUTE18, NULL, ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE18)
           ,ATTRIBUTE19 = decode(p_ATTRIBUTE19, NULL, ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE19)
           ,ATTRIBUTE20 = decode(p_ATTRIBUTE20, NULL, ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE20)
           ,ATTRIBUTE21 = decode(p_ATTRIBUTE21, NULL, ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE21)
           ,ATTRIBUTE22 = decode(p_ATTRIBUTE22, NULL, ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE22)
           ,ATTRIBUTE23 = decode(p_ATTRIBUTE23, NULL, ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE23)
           ,ATTRIBUTE24 = decode(p_ATTRIBUTE24, NULL, ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE24)
           ,ATTRIBUTE25 = decode(p_ATTRIBUTE25, NULL, ATTRIBUTE25, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE25)
           ,ATTRIBUTE26 = decode(p_ATTRIBUTE26, NULL, ATTRIBUTE26, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE26)
           ,ATTRIBUTE27 = decode(p_ATTRIBUTE27, NULL, ATTRIBUTE27, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE27)
           ,ATTRIBUTE28 = decode(p_ATTRIBUTE28, NULL, ATTRIBUTE28, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE28)
           ,ATTRIBUTE29 = decode(p_ATTRIBUTE29, NULL, ATTRIBUTE29, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE29)
           ,ATTRIBUTE30 = decode(p_ATTRIBUTE30, NULL, ATTRIBUTE30, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE30)
	   ,ATTRIBUTE_CATEGORY = decode(p_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
	   ,MIGRATED_FLAG = decode(p_MIGRATED_FLAG, NULL, MIGRATED_FLAG, FND_API.G_MISS_CHAR, NULL, p_MIGRATED_FLAG)
  	   ,CUSTOMER_VIEW = decode(p_CUSTOMER_VIEW, NULL, CUSTOMER_VIEW, FND_API.G_MISS_CHAR,NULL,  p_CUSTOMER_VIEW)
	   ,DIRECTION = decode(p_DIRECTION, NULL, DIRECTION, FND_API.G_MISS_CHAR, NULL,  p_DIRECTION)
	   ,FILTER_TYPE = decode(p_FILTER_TYPE, NULL, FILTER_TYPE, FND_API.G_MISS_CHAR, NULL, p_FILTER_TYPE)
	   ,FILTER_READING_COUNT = decode(p_FILTER_READING_COUNT, NULL, FILTER_READING_COUNT, FND_API.G_MISS_NUM,NULL,  p_FILTER_READING_COUNT)
	   ,FILTER_TIME_UOM = decode(p_FILTER_TIME_UOM, NULL, FILTER_TIME_UOM, FND_API.G_MISS_CHAR, NULL,  p_FILTER_TIME_UOM)
	   ,ESTIMATION_ID = decode(p_ESTIMATION_ID, NULL, ESTIMATION_ID, FND_API.G_MISS_NUM, NULL, p_ESTIMATION_ID)
	   ,ASSOCIATION_TYPE = decode(p_ASSOCIATION_TYPE, NULL, ASSOCIATION_TYPE, FND_API.G_MISS_CHAR, NULL,  p_ASSOCIATION_TYPE)
	   ,READING_TYPE = decode(p_READING_TYPE, NULL, READING_TYPE, FND_API.G_MISS_NUM, NULL,  p_READING_TYPE)
	   ,AUTOMATIC_ROLLOVER = decode(p_AUTOMATIC_ROLLOVER, NULL, AUTOMATIC_ROLLOVER, FND_API.G_MISS_CHAR,NULL,  p_AUTOMATIC_ROLLOVER)
	   ,DEFAULT_USAGE_RATE = decode(p_DEFAULT_USAGE_RATE, NULL, DEFAULT_USAGE_RATE, FND_API.G_MISS_NUM,NULL,  p_DEFAULT_USAGE_RATE)
	   ,USE_PAST_READING = decode(p_USE_PAST_READING, NULL, USE_PAST_READING, FND_API.G_MISS_NUM, NULL,  p_USE_PAST_READING)
	   ,USED_IN_SCHEDULING = decode(p_USED_IN_SCHEDULING, NULL, USED_IN_SCHEDULING, FND_API.G_MISS_CHAR,NULL, p_USED_IN_SCHEDULING)
	   ,DEFAULTED_GROUP_ID = decode(p_DEFAULTED_GROUP_ID, NULL, DEFAULTED_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_DEFAULTED_GROUP_ID)
	   ,STEP_VALUE = decode(p_STEP_VALUE, NULL, STEP_VALUE, FND_API.G_MISS_NUM, NULL, p_STEP_VALUE)
	   ,TIME_BASED_MANUAL_ENTRY  = decode(p_TIME_BASED_MANUAL_ENTRY, NULL, TIME_BASED_MANUAL_ENTRY, FND_API.G_MISS_CHAR, NULL, p_TIME_BASED_MANUAL_ENTRY)
	   ,EAM_REQUIRED_FLAG    = decode(p_EAM_REQUIRED_FLAG, NULL, EAM_REQUIRED_FLAG, FND_API.G_MISS_CHAR, NULL, p_EAM_REQUIRED_FLAG)
    WHERE  COUNTER_ID = p_COUNTER_ID;

    UPDATE csi_counter_template_tl
    SET    source_lang        = userenv('LANG'),
           name               = decode( p_name, NULL, name, fnd_api.g_miss_char, NULL, p_name),
           description        = decode( p_description, NULL, description, fnd_api.g_miss_char, NULL, p_description),
           created_by         = decode( p_created_by, NULL, created_by, fnd_api.g_miss_num, created_by, p_created_by),
           creation_date      = decode( p_creation_date, NULL, creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
           last_updated_by    = decode( p_last_updated_by, NULL, last_updated_by, fnd_api.g_miss_num, FND_GLOBAL.USER_ID, p_last_updated_by),
           last_update_date   = decode( p_last_update_date, NULL, last_update_date, fnd_api.g_miss_date, NULL,  p_last_update_date),
           last_update_login  = decode( p_last_update_login, NULL, last_update_login, fnd_api.g_miss_num, FND_GLOBAL.USER_ID, p_last_update_login)
    WHERE counter_id = p_counter_id
    AND   userenv('LANG') IN (LANGUAGE,SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

PROCEDURE delete_row(p_COUNTER_ID  NUMBER)  IS
BEGIN
   DELETE FROM CSI_COUNTER_TEMPLATE_B
   WHERE  COUNTER_ID = p_COUNTER_ID;
   IF (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   END IF;
END delete_row;

PROCEDURE lock_row(
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
        ,p_EAM_REQUIRED_FLAG        VARCHAR2) IS

   CURSOR C1 IS
   SELECT *
   FROM   CSI_COUNTER_TEMPLATE_B
   WHERE  COUNTER_ID = p_COUNTER_ID
   FOR UPDATE of COUNTER_ID NOWAIT;
   Recinfo C1%ROWTYPE;

   CURSOR c2 IS
   SELECT name,
          description,
          decode(language, userenv('LANG'), 'Y', 'N') baselang
   FROM   csi_counter_template_tl
   WHERE  counter_id = p_counter_id
   AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
   FOR UPDATE OF counter_id NOWAIT;
BEGIN
   OPEN c1;
   FETCH c1 INTO recinfo;
   IF (c1%notfound) THEN
      CLOSE c1;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE c1;


    IF  (recinfo.object_version_number=p_object_version_number)
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

   FOR tlinfo IN c2 LOOP
    IF (tlinfo.baselang = 'Y') THEN
       IF (    (tlinfo.name = p_name)
          AND ((tlinfo.description = p_description)
               OR ((tlinfo.description IS NULL) AND (p_description IS NULL)))
       ) THEN
        NULL;
       ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
       END IF;
    END IF;
   END LOOP;
  RETURN;
END lock_row;

PROCEDURE add_language IS
BEGIN
   DELETE FROM csi_counter_template_tl t
   WHERE NOT EXISTS (SELECT NULL
                     FROM   csi_counter_template_b b
                     WHERE  b.counter_id = t.counter_id);

   UPDATE csi_counter_template_tl t
   SET    (name,description) = (SELECT b.name,
                                       b.description
                                FROM   csi_counter_template_tl b
                                WHERE  b.counter_id = t.counter_id
                                AND    b.language  = t.source_lang)
   WHERE (t.counter_id,t.language) IN  (SELECT  subt.counter_id,
                                               subt.language
                                       FROM    csi_counter_template_tl subb, csi_counter_template_tl subt
                                       WHERE   subb.counter_id = subt.counter_id
                                       AND     subb.language  = subt.source_lang
                                       AND    (subb.name <> subt.name
                                               OR subb.description <> subt.description
                                               OR (subb.description IS NULL AND subt.description IS NOT NULL)
                                               OR (subb.description iS NOT NULL AND subt.description IS NULL)
                                               )
                                        );

   INSERT INTO csi_counter_template_tl(
	counter_id,
        name,
        description,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        language,
        source_lang
        )
   SELECT  b.counter_id,
           b.name,
           b.description,
           b.last_update_date,
           b.last_updated_by,
           b.creation_date,
           b.created_by,
           b.last_update_login,
           l.language_code,
           b.source_lang
   FROM  csi_counter_template_tl b, fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND   b.language = userenv('LANG')
   AND   NOT EXISTS (SELECT NULL
                     FROM   csi_counter_template_tl t
                     WHERE  t.counter_id = b.counter_id
                     AND    t.language  = l.language_code);
END add_language;

PROCEDURE translate_row (
   p_counter_id   IN     NUMBER,
   p_name         IN     VARCHAR2,
   p_description  IN     VARCHAR2,
   p_owner        IN     VARCHAR2) IS
BEGIN
  UPDATE csi_counter_template_tl
  SET   name              = p_name,
        description       = p_description,
        last_update_date  = sysdate,
        last_updated_by   = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0,
        source_lang       = userenv('LANG')
  WHERE counter_id = p_counter_id
  AND   userenv('LANG') IN (language, source_lang);
END translate_row;

End CSI_COUNTER_TEMPLATE_PKG;

/

--------------------------------------------------------
--  DDL for Package CSI_CTR_PROPERTY_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_PROPERTY_TEMPLATE_PKG" AUTHID CURRENT_USER as
/* $Header: csitcpts.pls 120.0.12010000.1 2008/07/25 08:13:23 appldev ship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_CTR_PROPERTY_TEMPLATE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcpts.pls';

PROCEDURE Insert_Row(
 	 px_COUNTER_PROPERTY_ID        IN OUT NOCOPY NUMBER
	,p_COUNTER_ID                 NUMBER
	,p_PROPERTY_DATA_TYPE          VARCHAR2
	,p_IS_NULLABLE                 VARCHAR2
	,p_DEFAULT_VALUE               VARCHAR2
	,p_MINIMUM_VALUE               VARCHAR2
	,p_MAXIMUM_VALUE               VARCHAR2
	,p_UOM_CODE                    VARCHAR2
	,p_START_DATE_ACTIVE           DATE
	,p_END_DATE_ACTIVE             DATE
	,p_OBJECT_VERSION_NUMBER       NUMBER
	,p_LAST_UPDATE_DATE            DATE
	,p_LAST_UPDATED_BY             NUMBER
	,p_CREATION_DATE               DATE
	,p_CREATED_BY                  NUMBER
	,p_LAST_UPDATE_LOGIN           NUMBER
	,p_ATTRIBUTE1                  VARCHAR2
	,p_ATTRIBUTE2                  VARCHAR2
	,p_ATTRIBUTE3                  VARCHAR2
	,p_ATTRIBUTE4                  VARCHAR2
	,p_ATTRIBUTE5                  VARCHAR2
	,p_ATTRIBUTE6                  VARCHAR2
	,p_ATTRIBUTE7                  VARCHAR2
	,p_ATTRIBUTE8                  VARCHAR2
	,p_ATTRIBUTE9                  VARCHAR2
	,p_ATTRIBUTE10                 VARCHAR2
	,p_ATTRIBUTE11                 VARCHAR2
	,p_ATTRIBUTE12                 VARCHAR2
	,p_ATTRIBUTE13                 VARCHAR2
	,p_ATTRIBUTE14                 VARCHAR2
	,p_ATTRIBUTE15                 VARCHAR2
	,p_ATTRIBUTE_CATEGORY          VARCHAR2
	,p_MIGRATED_FLAG               VARCHAR2
	,p_PROPERTY_LOV_TYPE           VARCHAR2
        ,p_SECURITY_GROUP_ID           NUMBER
        ,p_NAME	                       VARCHAR2
        ,p_DESCRIPTION                 VARCHAR2
        );

PROCEDURE update_row(
  	 p_COUNTER_PROPERTY_ID        NUMBER
	,p_COUNTER_ID                 NUMBER
	,p_PROPERTY_DATA_TYPE          VARCHAR2
	,p_IS_NULLABLE                 VARCHAR2
	,p_DEFAULT_VALUE               VARCHAR2
	,p_MINIMUM_VALUE               VARCHAR2
	,p_MAXIMUM_VALUE               VARCHAR2
	,p_UOM_CODE                    VARCHAR2
	,p_START_DATE_ACTIVE           DATE
	,p_END_DATE_ACTIVE             DATE
	,p_OBJECT_VERSION_NUMBER       NUMBER
	,p_LAST_UPDATE_DATE            DATE
	,p_LAST_UPDATED_BY             NUMBER
	,p_CREATION_DATE               DATE
	,p_CREATED_BY                  NUMBER
	,p_LAST_UPDATE_LOGIN           NUMBER
	,p_ATTRIBUTE1                  VARCHAR2
	,p_ATTRIBUTE2                  VARCHAR2
	,p_ATTRIBUTE3                  VARCHAR2
	,p_ATTRIBUTE4                  VARCHAR2
	,p_ATTRIBUTE5                  VARCHAR2
	,p_ATTRIBUTE6                  VARCHAR2
	,p_ATTRIBUTE7                  VARCHAR2
	,p_ATTRIBUTE8                  VARCHAR2
	,p_ATTRIBUTE9                  VARCHAR2
	,p_ATTRIBUTE10                 VARCHAR2
	,p_ATTRIBUTE11                 VARCHAR2
	,p_ATTRIBUTE12                 VARCHAR2
	,p_ATTRIBUTE13                 VARCHAR2
	,p_ATTRIBUTE14                 VARCHAR2
	,p_ATTRIBUTE15                 VARCHAR2
	,p_ATTRIBUTE_CATEGORY          VARCHAR2
	,p_MIGRATED_FLAG               VARCHAR2
	,p_PROPERTY_LOV_TYPE           VARCHAR2
        ,p_SECURITY_GROUP_ID           NUMBER
        ,p_NAME	                       VARCHAR2
        ,p_DESCRIPTION                 VARCHAR2
        );

PROCEDURE lock_row(
  	 p_COUNTER_PROPERTY_ID        NUMBER
	,p_COUNTER_ID                 NUMBER
	,p_PROPERTY_DATA_TYPE          VARCHAR2
	,p_IS_NULLABLE                 VARCHAR2
	,p_DEFAULT_VALUE               VARCHAR2
	,p_MINIMUM_VALUE               VARCHAR2
	,p_MAXIMUM_VALUE               VARCHAR2
	,p_UOM_CODE                    VARCHAR2
	,p_START_DATE_ACTIVE           DATE
	,p_END_DATE_ACTIVE             DATE
	,p_OBJECT_VERSION_NUMBER       NUMBER
	,p_LAST_UPDATE_DATE            DATE
	,p_LAST_UPDATED_BY             NUMBER
	,p_CREATION_DATE               DATE
	,p_CREATED_BY                  NUMBER
	,p_LAST_UPDATE_LOGIN           NUMBER
	,p_ATTRIBUTE1                  VARCHAR2
	,p_ATTRIBUTE2                  VARCHAR2
	,p_ATTRIBUTE3                  VARCHAR2
	,p_ATTRIBUTE4                  VARCHAR2
	,p_ATTRIBUTE5                  VARCHAR2
	,p_ATTRIBUTE6                  VARCHAR2
	,p_ATTRIBUTE7                  VARCHAR2
	,p_ATTRIBUTE8                  VARCHAR2
	,p_ATTRIBUTE9                  VARCHAR2
	,p_ATTRIBUTE10                 VARCHAR2
	,p_ATTRIBUTE11                 VARCHAR2
	,p_ATTRIBUTE12                 VARCHAR2
	,p_ATTRIBUTE13                 VARCHAR2
	,p_ATTRIBUTE14                 VARCHAR2
	,p_ATTRIBUTE15                 VARCHAR2
	,p_ATTRIBUTE_CATEGORY          VARCHAR2
	,p_MIGRATED_FLAG               VARCHAR2
	,p_PROPERTY_LOV_TYPE           VARCHAR2
        ,p_SECURITY_GROUP_ID           NUMBER
        ,p_NAME	                       VARCHAR2
        ,p_DESCRIPTION                 VARCHAR2
        );

PROCEDURE delete_row(
       p_COUNTER_PROPERTY_ID	       NUMBER
       );

PROCEDURE add_language;

PROCEDURE translate_row(
       p_counter_property_id NUMBER
       ,p_name               VARCHAR2
       ,p_description        VARCHAR2
       ,p_owner              VARCHAR2
        );

End CSI_CTR_PROPERTY_TEMPLATE_PKG;

/

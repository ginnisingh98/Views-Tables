--------------------------------------------------------
--  DDL for Package CSI_COUNTER_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_ASSOCIATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: csitciis.pls 120.2 2006/02/06 13:00:29 epajaril noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_COUNTER_ASSOCIATIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitciis.pls';

PROCEDURE Insert_Row(
         px_INSTANCE_ASSOCIATION_ID     IN OUT NOCOPY NUMBER
         ,p_SOURCE_OBJECT_CODE          VARCHAR2
         ,p_SOURCE_OBJECT_ID            NUMBER
	 ,p_OBJECT_VERSION_NUMBER       NUMBER
	 ,p_LAST_UPDATE_DATE            DATE
	 ,p_LAST_UPDATED_BY             NUMBER
	 ,p_LAST_UPDATE_LOGIN           NUMBER
	 ,p_CREATION_DATE               DATE
	 ,p_CREATED_BY                  NUMBER
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
	 ,p_SECURITY_GROUP_ID           NUMBER
	 ,p_MIGRATED_FLAG               VARCHAR2
	 ,p_COUNTER_ID                  NUMBER
	 ,p_START_DATE_ACTIVE           DATE
	 ,p_END_DATE_ACTIVE             DATE
	 ,p_MAINT_ORGANIZATION_ID       NUMBER
	 ,p_PRIMARY_FAILURE_FLAG        VARCHAR2
);

PROCEDURE Update_Row(
         p_INSTANCE_ASSOCIATION_ID      NUMBER
         ,p_SOURCE_OBJECT_CODE          VARCHAR2
         ,p_SOURCE_OBJECT_ID            NUMBER
	 ,p_OBJECT_VERSION_NUMBER       NUMBER
	 ,p_LAST_UPDATE_DATE            DATE
	 ,p_LAST_UPDATED_BY             NUMBER
	 ,p_LAST_UPDATE_LOGIN           NUMBER
	 ,p_CREATION_DATE               DATE
	 ,p_CREATED_BY                  NUMBER
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
	 ,p_SECURITY_GROUP_ID           NUMBER
	 ,p_MIGRATED_FLAG               VARCHAR2
	 ,p_COUNTER_ID                  NUMBER
	 ,p_START_DATE_ACTIVE           DATE
	 ,p_END_DATE_ACTIVE             DATE
	 ,p_MAINT_ORGANIZATION_ID       NUMBER
	 ,p_PRIMARY_FAILURE_FLAG        VARCHAR2
        );

PROCEDURE Lock_Row(
         p_INSTANCE_ASSOCIATION_ID      NUMBER
         ,p_SOURCE_OBJECT_CODE          VARCHAR2
         ,p_SOURCE_OBJECT_ID            NUMBER
	 ,p_OBJECT_VERSION_NUMBER       NUMBER
	 ,p_LAST_UPDATE_DATE            DATE
	 ,p_LAST_UPDATED_BY             NUMBER
	 ,p_LAST_UPDATE_LOGIN           NUMBER
	 ,p_CREATION_DATE               DATE
	 ,p_CREATED_BY                  NUMBER
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
	 ,p_SECURITY_GROUP_ID           NUMBER
	 ,p_MIGRATED_FLAG               VARCHAR2
	 ,p_COUNTER_ID                  NUMBER
	 ,p_START_DATE_ACTIVE           DATE
	 ,p_END_DATE_ACTIVE             DATE
	 ,p_MAINT_ORGANIZATION_ID       NUMBER
	 ,p_PRIMARY_FAILURE_FLAG        VARCHAR2
        );

PROCEDURE Delete_Row(
       p_INSTANCE_ASSOCIATION_ID      NUMBER
       );

End CSI_COUNTER_ASSOCIATIONS_PKG;

 

/

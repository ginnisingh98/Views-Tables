--------------------------------------------------------
--  DDL for Package CSI_COUNTER_RELATIONSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_RELATIONSHIP_PKG" AUTHID CURRENT_USER as
/* $Header: csitcrcs.pls 120.0 2005/06/10 14:08:31 rktow noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_RELATIONSHIP_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcrcs.pls';

PROCEDURE Insert_Row(
	px_RELATIONSHIP_ID                 IN OUT NOCOPY NUMBER
  	,p_CTR_ASSOCIATION_ID              NUMBER
  	,p_RELATIONSHIP_TYPE_CODE          VARCHAR2
  	,p_SOURCE_COUNTER_ID               NUMBER
  	,p_OBJECT_COUNTER_ID               NUMBER
  	,p_ACTIVE_START_DATE               DATE
  	,p_ACTIVE_END_DATE                 DATE
  	,p_OBJECT_VERSION_NUMBER           NUMBER
  	,p_LAST_UPDATE_DATE                DATE
  	,p_LAST_UPDATED_BY                 NUMBER
  	,p_CREATION_DATE                   DATE
  	,p_CREATED_BY                      NUMBER
  	,p_LAST_UPDATE_LOGIN               NUMBER
  	,p_ATTRIBUTE_CATEGORY              VARCHAR2
  	,p_ATTRIBUTE1                      VARCHAR2
  	,p_ATTRIBUTE2                      VARCHAR2
  	,p_ATTRIBUTE3                      VARCHAR2
  	,p_ATTRIBUTE4                      VARCHAR2
  	,p_ATTRIBUTE5                      VARCHAR2
  	,p_ATTRIBUTE6                      VARCHAR2
  	,p_ATTRIBUTE7                      VARCHAR2
  	,p_ATTRIBUTE8                      VARCHAR2
  	,p_ATTRIBUTE9                      VARCHAR2
  	,p_ATTRIBUTE10                     VARCHAR2
  	,p_ATTRIBUTE11                     VARCHAR2
  	,p_ATTRIBUTE12                     VARCHAR2
  	,p_ATTRIBUTE13                     VARCHAR2
  	,p_ATTRIBUTE14                     VARCHAR2
  	,p_ATTRIBUTE15                     VARCHAR2
  	,p_SECURITY_GROUP_ID               NUMBER
  	,p_MIGRATED_FLAG                   VARCHAR2
  	,p_BIND_VARIABLE_NAME              VARCHAR2
  	,p_FACTOR                          NUMBER
		);

PROCEDURE Update_Row(
	p_RELATIONSHIP_ID                  NUMBER
  	,p_CTR_ASSOCIATION_ID              NUMBER
  	,p_RELATIONSHIP_TYPE_CODE          VARCHAR2
  	,p_SOURCE_COUNTER_ID               NUMBER
  	,p_OBJECT_COUNTER_ID               NUMBER
  	,p_ACTIVE_START_DATE               DATE
  	,p_ACTIVE_END_DATE                 DATE
  	,p_OBJECT_VERSION_NUMBER           NUMBER
  	,p_LAST_UPDATE_DATE                DATE
  	,p_LAST_UPDATED_BY                 NUMBER
  	,p_CREATION_DATE                   DATE
  	,p_CREATED_BY                      NUMBER
  	,p_LAST_UPDATE_LOGIN               NUMBER
  	,p_ATTRIBUTE_CATEGORY              VARCHAR2
  	,p_ATTRIBUTE1                      VARCHAR2
  	,p_ATTRIBUTE2                      VARCHAR2
  	,p_ATTRIBUTE3                      VARCHAR2
  	,p_ATTRIBUTE4                      VARCHAR2
  	,p_ATTRIBUTE5                      VARCHAR2
  	,p_ATTRIBUTE6                      VARCHAR2
  	,p_ATTRIBUTE7                      VARCHAR2
  	,p_ATTRIBUTE8                      VARCHAR2
  	,p_ATTRIBUTE9                      VARCHAR2
  	,p_ATTRIBUTE10                     VARCHAR2
  	,p_ATTRIBUTE11                     VARCHAR2
  	,p_ATTRIBUTE12                     VARCHAR2
  	,p_ATTRIBUTE13                     VARCHAR2
  	,p_ATTRIBUTE14                     VARCHAR2
  	,p_ATTRIBUTE15                     VARCHAR2
  	,p_SECURITY_GROUP_ID               NUMBER
  	,p_MIGRATED_FLAG                   VARCHAR2
  	,p_BIND_VARIABLE_NAME              VARCHAR2
  	,p_FACTOR                          NUMBER
        );

PROCEDURE Lock_Row(
	p_RELATIONSHIP_ID                  NUMBER
  	,p_CTR_ASSOCIATION_ID              NUMBER
  	,p_RELATIONSHIP_TYPE_CODE          VARCHAR2
  	,p_SOURCE_COUNTER_ID               NUMBER
  	,p_OBJECT_COUNTER_ID               NUMBER
  	,p_ACTIVE_START_DATE               DATE
  	,p_ACTIVE_END_DATE                 DATE
  	,p_OBJECT_VERSION_NUMBER           NUMBER
  	,p_LAST_UPDATE_DATE                DATE
  	,p_LAST_UPDATED_BY                 NUMBER
  	,p_CREATION_DATE                   DATE
  	,p_CREATED_BY                      NUMBER
  	,p_LAST_UPDATE_LOGIN               NUMBER
  	,p_ATTRIBUTE_CATEGORY              VARCHAR2
  	,p_ATTRIBUTE1                      VARCHAR2
  	,p_ATTRIBUTE2                      VARCHAR2
  	,p_ATTRIBUTE3                      VARCHAR2
  	,p_ATTRIBUTE4                      VARCHAR2
  	,p_ATTRIBUTE5                      VARCHAR2
  	,p_ATTRIBUTE6                      VARCHAR2
  	,p_ATTRIBUTE7                      VARCHAR2
  	,p_ATTRIBUTE8                      VARCHAR2
  	,p_ATTRIBUTE9                      VARCHAR2
  	,p_ATTRIBUTE10                     VARCHAR2
  	,p_ATTRIBUTE11                     VARCHAR2
  	,p_ATTRIBUTE12                     VARCHAR2
  	,p_ATTRIBUTE13                     VARCHAR2
  	,p_ATTRIBUTE14                     VARCHAR2
  	,p_ATTRIBUTE15                     VARCHAR2
  	,p_SECURITY_GROUP_ID               NUMBER
  	,p_MIGRATED_FLAG                   VARCHAR2
  	,p_BIND_VARIABLE_NAME              VARCHAR2
  	,p_FACTOR                          NUMBER
        );

PROCEDURE Delete_Row(
	p_RELATIONSHIP_ID                  NUMBER
	);

End CSI_COUNTER_RELATIONSHIP_PKG;

 

/

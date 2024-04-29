--------------------------------------------------------
--  DDL for Package CSI_CTR_PROPERTY_READING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_PROPERTY_READING_PKG" AUTHID CURRENT_USER as
/* $Header: csitrdps.pls 120.0 2005/06/10 14:18:32 rktow noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_CTR_PROPERTY_READING_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitrdps.pls';

PROCEDURE Insert_Row(
	px_COUNTER_PROP_VALUE_ID           IN OUT NOCOPY NUMBER
	,p_COUNTER_VALUE_ID                NUMBER
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_PROPERTY_VALUE                  VARCHAR2
 	,p_VALUE_TIMESTAMP                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
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
 	,p_ATTRIBUTE_CATEGORY              VARCHAR2
 	,p_MIGRATED_FLAG                   VARCHAR2
		);

PROCEDURE Update_Row(
	p_COUNTER_PROP_VALUE_ID           NUMBER
	,p_COUNTER_VALUE_ID                NUMBER
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_PROPERTY_VALUE                  VARCHAR2
 	,p_VALUE_TIMESTAMP                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
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
 	,p_ATTRIBUTE_CATEGORY              VARCHAR2
 	,p_MIGRATED_FLAG                   VARCHAR2
        );

PROCEDURE Lock_Row(
	p_COUNTER_PROP_VALUE_ID           NUMBER
	,p_COUNTER_VALUE_ID                NUMBER
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_PROPERTY_VALUE                  VARCHAR2
 	,p_VALUE_TIMESTAMP                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                  NUMBER
 	,p_CREATION_DATE                   DATE
 	,p_CREATED_BY                      NUMBER
 	,p_LAST_UPDATE_LOGIN               NUMBER
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
 	,p_ATTRIBUTE_CATEGORY              VARCHAR2
 	,p_MIGRATED_FLAG                   VARCHAR2
        );

PROCEDURE Delete_Row(
	p_COUNTER_PROP_VALUE_ID           NUMBER
	);

End CSI_CTR_PROPERTY_READING_PKG;

 

/

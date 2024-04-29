--------------------------------------------------------
--  DDL for Package CSI_CTR_DERIVED_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CTR_DERIVED_FILTERS_PKG" AUTHID CURRENT_USER as
/* $Header: csitcdfs.pls 120.0 2005/06/10 14:00:54 rktow noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_CTR_DERIVED_FILTERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitcdfs.pls';

PROCEDURE Insert_Row(
	px_COUNTER_DERIVED_FILTER_ID       IN OUT NOCOPY NUMBER
 	,p_COUNTER_ID                      NUMBER
 	,p_SEQ_NO                          NUMBER
 	,p_LEFT_PARENT                     VARCHAR2
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_RELATIONAL_OPERATOR             VARCHAR2
 	,p_RIGHT_VALUE                     VARCHAR2
 	,p_RIGHT_PARENT                    VARCHAR2
 	,p_LOGICAL_OPERATOR                VARCHAR2
 	,p_START_DATE_ACTIVE               DATE
 	,p_END_DATE_ACTIVE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                 NUMBER
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
 	,p_SECURITY_GROUP_ID               NUMBER
 	,p_MIGRATED_FLAG                   VARCHAR2
		);

PROCEDURE Update_Row(
	p_COUNTER_DERIVED_FILTER_ID        NUMBER
 	,p_COUNTER_ID                      NUMBER
 	,p_SEQ_NO                          NUMBER
 	,p_LEFT_PARENT                     VARCHAR2
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_RELATIONAL_OPERATOR             VARCHAR2
 	,p_RIGHT_VALUE                     VARCHAR2
 	,p_RIGHT_PARENT                    VARCHAR2
 	,p_LOGICAL_OPERATOR                VARCHAR2
 	,p_START_DATE_ACTIVE               DATE
 	,p_END_DATE_ACTIVE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                 NUMBER
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
 	,p_SECURITY_GROUP_ID               NUMBER
 	,p_MIGRATED_FLAG                   VARCHAR2
        );

PROCEDURE Lock_Row(
	p_COUNTER_DERIVED_FILTER_ID        NUMBER
 	,p_COUNTER_ID                      NUMBER
 	,p_SEQ_NO                          NUMBER
 	,p_LEFT_PARENT                     VARCHAR2
 	,p_COUNTER_PROPERTY_ID             NUMBER
 	,p_RELATIONAL_OPERATOR             VARCHAR2
 	,p_RIGHT_VALUE                     VARCHAR2
 	,p_RIGHT_PARENT                    VARCHAR2
 	,p_LOGICAL_OPERATOR                VARCHAR2
 	,p_START_DATE_ACTIVE               DATE
 	,p_END_DATE_ACTIVE                 DATE
 	,p_OBJECT_VERSION_NUMBER           NUMBER
 	,p_LAST_UPDATE_DATE                DATE
 	,p_LAST_UPDATED_BY                 NUMBER
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
 	,p_SECURITY_GROUP_ID               NUMBER
 	,p_MIGRATED_FLAG                   VARCHAR2
        );

PROCEDURE Delete_Row(
	p_COUNTER_DERIVED_FILTER_ID        NUMBER
	);

End CSI_CTR_DERIVED_FILTERS_PKG;

 

/

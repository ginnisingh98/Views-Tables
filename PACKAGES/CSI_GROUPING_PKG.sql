--------------------------------------------------------
--  DDL for Package CSI_GROUPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_GROUPING_PKG" AUTHID CURRENT_USER as
/* $Header: csitgrps.pls 120.1 2006/03/23 15:09:33 epajaril noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSI_GROUPING_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitgrps.pls';

PROCEDURE Insert_Row(
        px_COUNTER_GROUP_ID 		IN OUT NOCOPY NUMBER
	,p_NAME                         VARCHAR2
	,p_DESCRIPTION                  VARCHAR2
	,p_TEMPLATE_FLAG                VARCHAR2
	,p_CP_SERVICE_ID                NUMBER
	,p_CUSTOMER_PRODUCT_ID          NUMBER
	,p_LAST_UPDATE_DATE             DATE
	,p_LAST_UPDATED_BY              NUMBER
	,p_CREATION_DATE                DATE
	,p_CREATED_BY                   NUMBER
	,p_LAST_UPDATE_LOGIN            NUMBER
	,p_START_DATE_ACTIVE            DATE
	,p_END_DATE_ACTIVE              DATE
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
	,p_CONTEXT                      VARCHAR2
	,p_OBJECT_VERSION_NUMBER        NUMBER
	,p_CREATED_FROM_CTR_GRP_TMPL_ID NUMBER
	,p_ASSOCIATION_TYPE             VARCHAR2
	,p_SOURCE_OBJECT_CODE           VARCHAR2
	,p_SOURCE_OBJECT_ID             NUMBER
	,p_SOURCE_COUNTER_GROUP_ID      NUMBER
	,p_SECURITY_GROUP_ID            NUMBER
        );

PROCEDURE Update_Row(
        p_COUNTER_GROUP_ID 		NUMBER
	,p_NAME                         VARCHAR2
	,p_DESCRIPTION                  VARCHAR2
	,p_TEMPLATE_FLAG                VARCHAR2
	,p_CP_SERVICE_ID                NUMBER
	,p_CUSTOMER_PRODUCT_ID          NUMBER
	,p_LAST_UPDATE_DATE             DATE
	,p_LAST_UPDATED_BY              NUMBER
	,p_CREATION_DATE                DATE
	,p_CREATED_BY                   NUMBER
	,p_LAST_UPDATE_LOGIN            NUMBER
	,p_START_DATE_ACTIVE            DATE
	,p_END_DATE_ACTIVE              DATE
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
	,p_CONTEXT                      VARCHAR2
	,p_OBJECT_VERSION_NUMBER        NUMBER
	,p_CREATED_FROM_CTR_GRP_TMPL_ID NUMBER
	,p_ASSOCIATION_TYPE             VARCHAR2
	,p_SOURCE_OBJECT_CODE           VARCHAR2
	,p_SOURCE_OBJECT_ID             NUMBER
	,p_SOURCE_COUNTER_GROUP_ID      NUMBER
	,p_SECURITY_GROUP_ID            NUMBER
        );

PROCEDURE Lock_Row(
        p_COUNTER_GROUP_ID 		NUMBER
	,p_NAME                         VARCHAR2
	,p_DESCRIPTION                  VARCHAR2
	,p_TEMPLATE_FLAG                VARCHAR2
	,p_CP_SERVICE_ID                NUMBER
	,p_CUSTOMER_PRODUCT_ID          NUMBER
	,p_LAST_UPDATE_DATE             DATE
	,p_LAST_UPDATED_BY              NUMBER
	,p_CREATION_DATE                DATE
	,p_CREATED_BY                   NUMBER
	,p_LAST_UPDATE_LOGIN            NUMBER
	,p_START_DATE_ACTIVE            DATE
	,p_END_DATE_ACTIVE              DATE
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
	,p_CONTEXT                      VARCHAR2
	,p_OBJECT_VERSION_NUMBER        NUMBER
	,p_CREATED_FROM_CTR_GRP_TMPL_ID NUMBER
	,p_ASSOCIATION_TYPE             VARCHAR2
	,p_SOURCE_OBJECT_CODE           VARCHAR2
	,p_SOURCE_OBJECT_ID             NUMBER
	,p_SOURCE_COUNTER_GROUP_ID      NUMBER
	,p_SECURITY_GROUP_ID            NUMBER
        );

PROCEDURE Delete_Row(
       p_COUNTER_GROUP_ID		NUMBER);
End CSI_GROUPING_PKG;

 

/

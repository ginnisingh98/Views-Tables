--------------------------------------------------------
--  DDL for Package CSP_EXCESS_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_EXCESS_LISTS_PKG" AUTHID CURRENT_USER as
/* $Header: csptexcs.pls 120.0.12010000.2 2009/05/14 13:12:32 htank ship $ */
-- Start of Comments
-- Package name     : CSP_EXCESS_LISTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- added by htank for Reverse Logistic project
TYPE EXCESS_RECORD_TYPE IS RECORD
(
    EXCESS_LINE_ID                 NUMBER    := FND_API.G_MISS_NUM,
    ORGANIZATION_ID                NUMBER    := FND_API.G_MISS_NUM,
    INVENTORY_ITEM_ID              NUMBER    := FND_API.G_MISS_NUM,
    EXCESS_QUANTITY                NUMBER    := FND_API.G_MISS_NUM,
    CONDITION_CODE                 VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    CREATED_BY                     NUMBER    := FND_API.G_MISS_NUM,
    CREATION_DATE                  DATE          := FND_API.G_MISS_DATE,
    LAST_UPDATED_BY                NUMBER    := FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE               DATE          := FND_API.G_MISS_DATE,
    LAST_UPDATE_LOGIN              NUMBER    := FND_API.G_MISS_NUM,
    SUBINVENTORY_CODE              VARCHAR2(10)  := FND_API.G_MISS_CHAR,
    RETURNED_QUANTITY              NUMBER    := FND_API.G_MISS_NUM,
    CURRENT_RETURN_QTY             NUMBER    := FND_API.G_MISS_NUM,
    REQUISITION_LINE_ID            NUMBER    := FND_API.G_MISS_NUM,
    EXCESS_STATUS                  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    ATTRIBUTE_CATEGORY             VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    ATTRIBUTE1                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE2                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE3                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE4                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE5                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE6                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE7                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE8                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE9                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE10                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE11                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE12                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE13                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE14                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
    ATTRIBUTE15                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
    SECURITY_GROUP_ID              NUMBER    := FND_API.G_MISS_NUM,
    REASON_CODE                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
    RETURN_ORGANIZATION_ID         NUMBER    := FND_API.G_MISS_NUM,
    RETURN_SUBINVENTORY_NAME       VARCHAR2(10)  := FND_API.G_MISS_CHAR
);
G_MISS_EXCESS_REC   EXCESS_RECORD_TYPE;

TYPE EXCESS_TBL_TYPE IS TABLE OF EXCESS_RECORD_TYPE INDEX BY BINARY_INTEGER;
G_MISS_EXCESS_TBL   EXCESS_TBL_TYPE;
-- end of addition

PROCEDURE Insert_Row(
          px_EXCESS_LINE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_CONDITION_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_EXCESS_QUANTITY    NUMBER,
          p_REQUISITION_LINE_ID    NUMBER,
          p_RETURNED_QUANTITY    NUMBER,
          p_CURRENT_RETURN_QTY    NUMBER,
          p_EXCESS_STATUS   VARCHAR2,
          p_RETURN_ORG_ID NUMBER  :=  FND_API.G_MISS_NUM,
          p_RETURN_SUB_INV  VARCHAR2  :=  FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2);
PROCEDURE Update_Row(
          p_EXCESS_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_CONDITION_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_EXCESS_QUANTITY    NUMBER,
          p_REQUISITION_LINE_ID    NUMBER,
          p_RETURNED_QUANTITY    NUMBER,
          p_CURRENT_RETURN_QTY    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2);
PROCEDURE Lock_Row(
          p_EXCESS_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_CONDITION_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_EXCESS_QUANTITY    NUMBER,
          p_REQUISITION_LINE_ID    NUMBER,
          p_RETURNED_QUANTITY    NUMBER,
          p_CURRENT_RETURN_QTY    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2);
PROCEDURE Delete_Row(
    p_EXCESS_LINE_ID  NUMBER);
End CSP_EXCESS_LISTS_PKG;

/

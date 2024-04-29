--------------------------------------------------------
--  DDL for Package CSD_REPAIRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIRS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtdras.pls 120.9.12010000.3 2010/05/06 01:32:02 takwong ship $ */
-- Start of Comments
-- Package name     : CSD_REPAIRS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_REPAIR_LINE_ID   IN OUT NOCOPY NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE  DATE
         ,p_CREATED_BY           NUMBER
         ,p_CREATION_DATE        DATE
         ,p_LAST_UPDATED_BY      NUMBER
         ,p_LAST_UPDATE_DATE     DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_REPAIR_NUMBER        VARCHAR2
         ,p_INCIDENT_ID          NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CUSTOMER_PRODUCT_ID  NUMBER
         ,p_UNIT_OF_MEASURE    VARCHAR2
         ,p_REPAIR_TYPE_ID     NUMBER
-- RESOURCE_GROUP Added by Vijay 10/28/2004
         ,p_RESOURCE_GROUP     NUMBER
         ,p_RESOURCE_ID        NUMBER
         ,p_INSTANCE_ID        NUMBER
         ,p_PROJECT_ID         NUMBER
         ,p_TASK_ID            NUMBER
         ,p_UNIT_NUMBER        VARCHAR2 -- rfieldma, for pj integration
         ,p_CONTRACT_LINE_ID   NUMBER
         ,p_QUANTITY           NUMBER
         ,p_STATUS             VARCHAR2
         ,p_APPROVAL_REQUIRED_FLAG    VARCHAR2
         ,p_DATE_CLOSED         DATE
         ,p_QUANTITY_IN_WIP     NUMBER
         ,p_APPROVAL_STATUS     VARCHAR2
         ,p_QUANTITY_RCVD       NUMBER
         ,p_QUANTITY_SHIPPED    NUMBER
         ,p_CURRENCY_CODE       VARCHAR2
         ,p_DEFAULT_PO_NUM      VARCHAR2 := NULL
         ,p_SERIAL_NUMBER       VARCHAR2
         ,p_PROMISE_DATE        DATE
         ,p_ATTRIBUTE_CATEGORY  VARCHAR2
         ,p_ATTRIBUTE1     VARCHAR2
         ,p_ATTRIBUTE2     VARCHAR2
         ,p_ATTRIBUTE3     VARCHAR2
         ,p_ATTRIBUTE4     VARCHAR2
         ,p_ATTRIBUTE5     VARCHAR2
         ,p_ATTRIBUTE6     VARCHAR2
         ,p_ATTRIBUTE7     VARCHAR2
         ,p_ATTRIBUTE8     VARCHAR2
         ,p_ATTRIBUTE9     VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
      --bug#7497907, 12.1 FP, subhat
         ,p_ATTRIBUTE16     VARCHAR2
         ,p_ATTRIBUTE17     VARCHAR2
         ,p_ATTRIBUTE18     VARCHAR2
         ,p_ATTRIBUTE19     VARCHAR2
         ,p_ATTRIBUTE20     VARCHAR2
         ,p_ATTRIBUTE21     VARCHAR2
         ,p_ATTRIBUTE22     VARCHAR2
         ,p_ATTRIBUTE23     VARCHAR2
         ,p_ATTRIBUTE24     VARCHAR2
         ,p_ATTRIBUTE25     VARCHAR2
         ,p_ATTRIBUTE26     VARCHAR2
         ,p_ATTRIBUTE27     VARCHAR2
         ,p_ATTRIBUTE28     VARCHAR2
         ,p_ATTRIBUTE29     VARCHAR2
         ,p_ATTRIBUTE30     VARCHAR2
         ,p_ORDER_LINE_ID    NUMBER
         ,p_ORIGINAL_SOURCE_REFERENCE VARCHAR2
         ,p_STATUS_REASON_CODE        VARCHAR2
         ,p_OBJECT_VERSION_NUMBER     NUMBER
         ,p_AUTO_PROCESS_RMA          VARCHAR2
         ,p_REPAIR_MODE               VARCHAR2
         ,p_ITEM_REVISION             VARCHAR2
         ,p_REPAIR_GROUP_ID           NUMBER
         ,p_RO_TXN_STATUS             VARCHAR2
    ,p_ORIGINAL_SOURCE_HEADER_ID NUMBER
    ,p_ORIGINAL_SOURCE_LINE_ID   NUMBER
    ,p_PRICE_LIST_HEADER_ID      NUMBER
    ,P_Supercession_Inv_Item_Id  Number
    ,p_flow_status_Id            Number
    ,p_Inventory_Org_Id          Number
    ,p_PROBLEM_DESCRIPTION       VARCHAR2   -- swai: bug 4666344
    ,p_RO_PRIORITY_CODE          VARCHAR2   -- swai: R12
    ,p_RESOLVE_BY_DATE           DATE       -- rfieldma: 5355051
    ,p_BULLETIN_CHECK_DATE       DATE --:= FND_API.G_MISS_DATE
    ,p_ESCALATION_CODE           VARCHAR2 --:= FND_API.G_MISS_CHAR
    ,p_RO_WARRANTY_STATUS_CODE   VARCHAR2 := FND_API.G_MISS_CHAR
    ,p_REPAIR_YIELD_QUANTITY      NUMBER  := FND_API.G_MISS_NUM  --bug#6692459
        );

PROCEDURE Update_Row(
          p_REPAIR_LINE_ID          NUMBER
         ,p_REQUEST_ID              NUMBER
         ,p_PROGRAM_ID              NUMBER
         ,p_PROGRAM_APPLICATION_ID  NUMBER
         ,p_PROGRAM_UPDATE_DATE     DATE
         ,p_CREATED_BY              NUMBER
         ,p_CREATION_DATE           DATE
         ,p_LAST_UPDATED_BY         NUMBER
         ,p_LAST_UPDATE_DATE        DATE
         ,p_LAST_UPDATE_LOGIN       NUMBER
         ,p_REPAIR_NUMBER           VARCHAR2
         ,p_INCIDENT_ID             NUMBER
         ,p_INVENTORY_ITEM_ID       NUMBER
         ,p_CUSTOMER_PRODUCT_ID     NUMBER
         ,p_UNIT_OF_MEASURE         VARCHAR2
         ,p_REPAIR_TYPE_ID          NUMBER
-- RESOURCE_GROUP Added by Vijay 10/28/2004
         ,p_RESOURCE_GROUP          NUMBER
         ,p_RESOURCE_ID             NUMBER
         ,p_INSTANCE_ID             NUMBER
         ,p_PROJECT_ID              NUMBER
         ,p_TASK_ID                 NUMBER
         ,p_UNIT_NUMBER             VARCHAR2 -- rfieldma, for pj integration
         ,p_CONTRACT_LINE_ID        NUMBER
         ,p_QUANTITY                NUMBER
         ,p_STATUS                  VARCHAR2
         ,p_APPROVAL_REQUIRED_FLAG  VARCHAR2
         ,p_DATE_CLOSED             DATE
         ,p_QUANTITY_IN_WIP         NUMBER
         ,p_APPROVAL_STATUS         VARCHAR2
         ,p_QUANTITY_RCVD           NUMBER
         ,p_QUANTITY_SHIPPED        NUMBER
         ,p_CURRENCY_CODE           VARCHAR2
         ,p_DEFAULT_PO_NUM          VARCHAR2 := NULL
         ,p_SERIAL_NUMBER           VARCHAR2
         ,p_PROMISE_DATE            DATE
         ,p_ATTRIBUTE_CATEGORY      VARCHAR2
         ,p_ATTRIBUTE1     VARCHAR2
         ,p_ATTRIBUTE2     VARCHAR2
         ,p_ATTRIBUTE3     VARCHAR2
         ,p_ATTRIBUTE4     VARCHAR2
         ,p_ATTRIBUTE5     VARCHAR2
         ,p_ATTRIBUTE6     VARCHAR2
         ,p_ATTRIBUTE7     VARCHAR2
         ,p_ATTRIBUTE8     VARCHAR2
         ,p_ATTRIBUTE9     VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
      --bug#7497907, 12.1 FP, subhat
         ,p_ATTRIBUTE16     VARCHAR2
         ,p_ATTRIBUTE17     VARCHAR2
         ,p_ATTRIBUTE18     VARCHAR2
         ,p_ATTRIBUTE19     VARCHAR2
         ,p_ATTRIBUTE20     VARCHAR2
         ,p_ATTRIBUTE21     VARCHAR2
         ,p_ATTRIBUTE22     VARCHAR2
         ,p_ATTRIBUTE23     VARCHAR2
         ,p_ATTRIBUTE24     VARCHAR2
         ,p_ATTRIBUTE25     VARCHAR2
         ,p_ATTRIBUTE26     VARCHAR2
         ,p_ATTRIBUTE27     VARCHAR2
         ,p_ATTRIBUTE28     VARCHAR2
         ,p_ATTRIBUTE29     VARCHAR2
         ,p_ATTRIBUTE30     VARCHAR2
         ,p_ORDER_LINE_ID  NUMBER
         ,p_ORIGINAL_SOURCE_REFERENCE VARCHAR2
         ,p_STATUS_REASON_CODE        VARCHAR2
         ,p_OBJECT_VERSION_NUMBER     NUMBER
         ,p_AUTO_PROCESS_RMA          VARCHAR2
         ,p_REPAIR_MODE               VARCHAR2
         ,p_ITEM_REVISION             VARCHAR2
         ,p_REPAIR_GROUP_ID           NUMBER
         ,p_RO_TXN_STATUS             VARCHAR2
       ,p_ORIGINAL_SOURCE_HEADER_ID NUMBER
       ,p_ORIGINAL_SOURCE_LINE_ID   NUMBER
       ,p_PRICE_LIST_HEADER_ID      NUMBER
       ,p_PROBLEM_DESCRIPTION       VARCHAR2   -- swai: bug 4666344
       ,p_RO_PRIORITY_CODE          VARCHAR2   -- swai: R12
	  ,p_RESOLVE_BY_DATE           DATE       -- rfieldma: 5355051
        ,p_BULLETIN_CHECK_DATE       DATE --:= FND_API.G_MISS_DATE
        ,p_ESCALATION_CODE           VARCHAR2 --:= FND_API.G_MISS_CHAR
        ,p_RO_WARRANTY_STATUS_CODE   VARCHAR2 := FND_API.G_MISS_CHAR
       );

PROCEDURE Lock_Row(
          p_REPAIR_LINE_ID           NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_REPAIR_LINE_ID  NUMBER);

End CSD_REPAIRS_PKG;

/

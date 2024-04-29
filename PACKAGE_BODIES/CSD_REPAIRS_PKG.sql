--------------------------------------------------------
--  DDL for Package Body CSD_REPAIRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIRS_PKG" as
/* $Header: csdtdrab.pls 120.10.12010000.4 2010/05/06 01:30:31 takwong ship $ */
-- Start of Comments
-- Package name     : CSD_REPAIRS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_REPAIRS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtdrab.pls';
l_debug        NUMBER ;

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
         ,p_UNIT_OF_MEASURE      VARCHAR2
         ,p_REPAIR_TYPE_ID       NUMBER
-- RESOURCE_GROUP Added by Vijay 10/28/2004
         ,p_RESOURCE_GROUP       NUMBER
         ,p_RESOURCE_ID          NUMBER
         ,p_INSTANCE_ID          NUMBER
         ,p_PROJECT_ID           NUMBER
         ,p_TASK_ID              NUMBER
         ,p_UNIT_NUMBER          VARCHAR2 -- rfieldma, project integration
         ,p_CONTRACT_LINE_ID     NUMBER
         ,p_QUANTITY             NUMBER
         ,p_STATUS               VARCHAR2
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
         ,p_ATTRIBUTE1       VARCHAR2
         ,p_ATTRIBUTE2       VARCHAR2
         ,p_ATTRIBUTE3       VARCHAR2
         ,p_ATTRIBUTE4       VARCHAR2
         ,p_ATTRIBUTE5       VARCHAR2
         ,p_ATTRIBUTE6       VARCHAR2
         ,p_ATTRIBUTE7       VARCHAR2
         ,p_ATTRIBUTE8       VARCHAR2
         ,p_ATTRIBUTE9       VARCHAR2
         ,p_ATTRIBUTE10      VARCHAR2
         ,p_ATTRIBUTE11      VARCHAR2
         ,p_ATTRIBUTE12      VARCHAR2
         ,p_ATTRIBUTE13      VARCHAR2
         ,p_ATTRIBUTE14      VARCHAR2
         ,p_ATTRIBUTE15      VARCHAR2
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
         ,p_ORIGINAL_SOURCE_REFERENCE    VARCHAR2
         ,p_STATUS_REASON_CODE         VARCHAR2
         ,p_OBJECT_VERSION_NUMBER      NUMBER
         ,p_AUTO_PROCESS_RMA           VARCHAR2
         ,p_REPAIR_MODE                VARCHAR2
         ,p_ITEM_REVISION              VARCHAR2
         ,p_REPAIR_GROUP_ID            NUMBER
         ,p_RO_TXN_STATUS              VARCHAR2
    ,p_ORIGINAL_SOURCE_HEADER_ID  NUMBER
    ,p_ORIGINAL_SOURCE_LINE_ID    NUMBER
    ,p_PRICE_LIST_HEADER_ID       NUMBER
    ,p_Supercession_inv_item_id   Number
    ,p_flow_status_Id             Number
    ,p_Inventory_Org_Id           Number
    ,p_PROBLEM_DESCRIPTION        VARCHAR2  -- swai: bug 4666344
    ,p_RO_PRIORITY_CODE           VARCHAR2  -- swai: R12
    ,p_RESOLVE_BY_DATE            DATE      -- rfieldma: 5355051
    ,p_BULLETIN_CHECK_DATE       DATE   --- := FND_API.G_MISS_DATE
    ,p_ESCALATION_CODE           VARCHAR2 --:= FND_API.G_MISS_CHAR
    ,p_RO_WARRANTY_STATUS_CODE   VARCHAR2
    ,p_REPAIR_YIELD_QUANTITY      NUMBER    --bug#6692459
       )

 IS
   CURSOR C2 IS SELECT CSD_REPAIRS_S1.nextval FROM sys.dual;
BEGIN
   If (px_REPAIR_LINE_ID IS NULL) OR (px_REPAIR_LINE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_REPAIR_LINE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSD_REPAIRS(
           REPAIR_LINE_ID
          ,REQUEST_ID
          ,PROGRAM_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_UPDATE_DATE
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,REPAIR_NUMBER
          ,INCIDENT_ID
          ,INVENTORY_ITEM_ID
          ,CUSTOMER_PRODUCT_ID
          ,UNIT_OF_MEASURE
          ,REPAIR_TYPE_ID
-- RESOURCE_GROUP Added by Vijay 10/28/2004
          ,OWNING_ORGANIZATION_ID
          ,RESOURCE_ID
          ,INSTANCE_ID
          ,PROJECT_ID
          ,TASK_ID
          ,CONTRACT_LINE_ID
          ,QUANTITY
          ,STATUS
          ,APPROVAL_REQUIRED_FLAG
          ,DATE_CLOSED
          ,QUANTITY_IN_WIP
          ,APPROVAL_STATUS
          ,QUANTITY_RCVD
          ,QUANTITY_SHIPPED
          ,CURRENCY_CODE
      ,DEFAULT_PO_NUM
          ,SERIAL_NUMBER
          ,PROMISE_DATE
          ,ATTRIBUTE_CATEGORY
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
          ,ORDER_LINE_ID
          ,ORIGINAL_SOURCE_REFERENCE
          ,STATUS_REASON_CODE
          ,OBJECT_VERSION_NUMBER
          ,AUTO_PROCESS_RMA
          ,REPAIR_MODE
          ,ITEM_REVISION
          ,REPAIR_GROUP_ID
          ,RO_TXN_STATUS
     ,ORIGINAL_SOURCE_HEADER_ID
     ,ORIGINAL_SOURCE_LINE_ID
          ,PRICE_LIST_HEADER_ID
          ,Supercession_Inv_Item_Id
          ,flow_status_Id
          ,Inventory_Org_Id
          ,PROBLEM_DESCRIPTION   -- swai: bug 4666344
          ,UNIT_NUMBER -- rfieldma, project integration
          ,RO_PRIORITY_CODE   -- swai: R12
 		  ,RESOLVE_BY_DATE -- rfieldma: 5355051
          ,BULLETIN_CHECK_DATE
          ,ESCALATION_CODE
          ,RO_WARRANTY_STATUS_CODE
          ,REPAIR_YIELD_QUANTITY  --bug#6692459
          --bug#7497907, 12.1 FP, subhat
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
          ) VALUES (
           px_REPAIR_LINE_ID
          ,decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID)
          ,decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID)
          ,decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID)
          ,decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          ,decode( p_REPAIR_NUMBER, FND_API.G_MISS_CHAR, NULL, p_REPAIR_NUMBER)
          ,decode( p_INCIDENT_ID, FND_API.G_MISS_NUM, NULL, p_INCIDENT_ID)
          ,decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID)
          ,decode( p_CUSTOMER_PRODUCT_ID, FND_API.G_MISS_NUM, NULL, p_CUSTOMER_PRODUCT_ID)
          ,decode( p_UNIT_OF_MEASURE, FND_API.G_MISS_CHAR, NULL, p_UNIT_OF_MEASURE)
          ,decode( p_REPAIR_TYPE_ID, FND_API.G_MISS_NUM, NULL, p_REPAIR_TYPE_ID)
-- RESOURCE_GROUP Added by Vijay 10/28/2004
          ,decode( p_RESOURCE_GROUP, FND_API.G_MISS_NUM, NULL, p_RESOURCE_GROUP)
          ,decode( p_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, p_RESOURCE_ID)
          ,decode( p_INSTANCE_ID, FND_API.G_MISS_NUM, NULL, p_INSTANCE_ID)
          ,decode( p_PROJECT_ID, FND_API.G_MISS_NUM, NULL, p_PROJECT_ID)
          ,decode( p_TASK_ID, FND_API.G_MISS_NUM, NULL, p_TASK_ID)
          ,decode( p_CONTRACT_LINE_ID, FND_API.G_MISS_NUM, NULL, p_CONTRACT_LINE_ID)
          ,decode( p_QUANTITY, FND_API.G_MISS_NUM, NULL, p_QUANTITY)
          ,decode( p_STATUS, FND_API.G_MISS_CHAR, NULL, p_STATUS)
          ,decode( p_APPROVAL_REQUIRED_FLAG, FND_API.G_MISS_CHAR, NULL, p_APPROVAL_REQUIRED_FLAG)
          ,decode( p_DATE_CLOSED, FND_API.G_MISS_DATE, TO_DATE(NULL), p_DATE_CLOSED)
          ,decode( p_QUANTITY_IN_WIP, FND_API.G_MISS_NUM, NULL, p_QUANTITY_IN_WIP)
          ,decode( p_APPROVAL_STATUS, FND_API.G_MISS_CHAR, NULL, p_APPROVAL_STATUS)
          ,decode( p_QUANTITY_RCVD, FND_API.G_MISS_NUM, NULL, p_QUANTITY_RCVD)
          ,decode( p_QUANTITY_SHIPPED, FND_API.G_MISS_NUM, NULL, p_QUANTITY_SHIPPED)
          ,decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_CURRENCY_CODE)
          ,decode( p_DEFAULT_PO_NUM, FND_API.G_MISS_CHAR, NULL, p_DEFAULT_PO_NUM)
          ,decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, p_SERIAL_NUMBER)
          ,decode( p_PROMISE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROMISE_DATE)
          ,decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
          ,decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
          ,decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
          ,decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
          ,decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
          ,decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
          ,decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
          ,decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
          ,decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
          ,decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
          ,decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
          ,decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
          ,decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
          ,decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
          ,decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
          ,decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
          ,decode( p_ORDER_LINE_ID, FND_API.G_MISS_NUM, NULL, p_ORDER_LINE_ID)
          ,decode( p_ORIGINAL_SOURCE_REFERENCE, FND_API.G_MISS_CHAR, NULL, p_ORIGINAL_SOURCE_REFERENCE)
          ,decode( p_STATUS_REASON_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_REASON_CODE)
          ,decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
          ,decode( p_AUTO_PROCESS_RMA, FND_API.G_MISS_CHAR, NULL, p_AUTO_PROCESS_RMA)
          ,decode( p_REPAIR_MODE, FND_API.G_MISS_CHAR, NULL, p_REPAIR_MODE)
          ,decode( p_ITEM_REVISION, FND_API.G_MISS_CHAR, NULL, p_ITEM_REVISION)
          ,decode( p_REPAIR_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_REPAIR_GROUP_ID)
          ,decode( p_RO_TXN_STATUS, FND_API.G_MISS_CHAR, NULL, p_RO_TXN_STATUS)
          ,decode( p_ORIGINAL_SOURCE_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_ORIGINAL_SOURCE_HEADER_ID)
          ,decode( p_ORIGINAL_SOURCE_LINE_ID, FND_API.G_MISS_NUM, NULL, p_ORIGINAL_SOURCE_LINE_ID)
          ,decode( p_PRICE_LIST_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_PRICE_LIST_HEADER_ID)
          ,decode( p_Supercession_Inv_Item_ID, FND_API.G_MISS_NUM, NULL, p_Supercession_Inv_Item_ID)
          ,decode( p_flow_status_Id, FND_API.G_MISS_NUM, NULL, p_flow_status_Id)
          ,decode( p_Inventory_Org_Id, FND_API.G_MISS_NUM, NULL, p_Inventory_Org_Id)
          ,decode( p_PROBLEM_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_PROBLEM_DESCRIPTION)    -- swai: bug 4666344
          ,decode( p_UNIT_NUMBER, FND_API.G_MISS_CHAR, NULL, p_UNIT_NUMBER)   -- rfieldma, project integration
          ,decode( p_RO_PRIORITY_CODE, FND_API.G_MISS_CHAR, NULL, p_RO_PRIORITY_CODE)    -- swai: R12
		  ,decode( p_RESOLVE_BY_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_RESOLVE_BY_DATE)
		  ,decode( p_BULLETIN_CHECK_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_BULLETIN_CHECK_DATE)
          ,decode( p_ESCALATION_CODE, FND_API.G_MISS_CHAR, NULL, p_ESCALATION_CODE)
          ,decode( p_RO_WARRANTY_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_RO_WARRANTY_STATUS_CODE)
          ,decode( p_REPAIR_YIELD_QUANTITY, FND_API.G_MISS_NUM, NULL, p_REPAIR_YIELD_QUANTITY)  --bug#6692459
        --bug#7497907, 12.1 FP, subhat
          ,decode( p_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE16)
          ,decode( p_ATTRIBUTE17, FND_API.G_MISS_CHAR,  NULL, p_ATTRIBUTE17)
          ,decode( p_ATTRIBUTE18, FND_API.G_MISS_CHAR,  NULL, p_ATTRIBUTE18)
          ,decode( p_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE19)
          ,decode( p_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE20)
          ,decode( p_ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE21)
          ,decode( p_ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE22)
          ,decode( p_ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE23)
          ,decode( p_ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE24)
          ,decode( p_ATTRIBUTE25, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE25)
          ,decode( p_ATTRIBUTE26, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE26)
          ,decode( p_ATTRIBUTE27, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE27)
          ,decode( p_ATTRIBUTE28, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE28)
          ,decode( p_ATTRIBUTE29, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE29)
          ,decode( p_ATTRIBUTE30, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE30)
          );
End Insert_Row;


/*
Name: Update_Row
Description: Procedure to update a row in the CSD_REPAIRS table,which stores RO information
Code Change History:
-- 3/21/2010 nnadig 120.10.12010000.3 : Bug fix 9291206, Removed code that updated created_by
   when updating an RO
*/
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
         ,p_UNIT_NUMBER             VARCHAR2 -- rfieldma, project integration
         ,p_CONTRACT_LINE_ID        NUMBER
         ,p_QUANTITY                NUMBER
         ,p_STATUS                  VARCHAR2
         ,p_APPROVAL_REQUIRED_FLAG  VARCHAR2
         ,p_DATE_CLOSED          DATE
         ,p_QUANTITY_IN_WIP      NUMBER
         ,p_APPROVAL_STATUS      VARCHAR2
         ,p_QUANTITY_RCVD        NUMBER
         ,p_QUANTITY_SHIPPED     NUMBER
         ,p_CURRENCY_CODE        VARCHAR2
         ,p_DEFAULT_PO_NUM       VARCHAR2 := NULL
         ,p_SERIAL_NUMBER        VARCHAR2
         ,p_PROMISE_DATE         DATE
         ,p_ATTRIBUTE_CATEGORY   VARCHAR2
         ,p_ATTRIBUTE1       VARCHAR2
         ,p_ATTRIBUTE2       VARCHAR2
         ,p_ATTRIBUTE3       VARCHAR2
         ,p_ATTRIBUTE4       VARCHAR2
         ,p_ATTRIBUTE5       VARCHAR2
         ,p_ATTRIBUTE6       VARCHAR2
         ,p_ATTRIBUTE7       VARCHAR2
         ,p_ATTRIBUTE8       VARCHAR2
         ,p_ATTRIBUTE9       VARCHAR2
         ,p_ATTRIBUTE10      VARCHAR2
         ,p_ATTRIBUTE11      VARCHAR2
         ,p_ATTRIBUTE12      VARCHAR2
         ,p_ATTRIBUTE13      VARCHAR2
         ,p_ATTRIBUTE14      VARCHAR2
         ,p_ATTRIBUTE15      VARCHAR2
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
         ,p_ORIGINAL_SOURCE_REFERENCE  VARCHAR2
         ,p_STATUS_REASON_CODE         VARCHAR2
         ,p_OBJECT_VERSION_NUMBER      NUMBER
         ,p_AUTO_PROCESS_RMA           VARCHAR2
         ,p_REPAIR_MODE                VARCHAR2
         ,p_ITEM_REVISION              VARCHAR2
         ,p_REPAIR_GROUP_ID            NUMBER
         ,p_RO_TXN_STATUS              VARCHAR2
       ,p_ORIGINAL_SOURCE_HEADER_ID NUMBER
       ,p_ORIGINAL_SOURCE_LINE_ID   NUMBER
         ,p_PRICE_LIST_HEADER_ID      NUMBER
         ,p_PROBLEM_DESCRIPTION       VARCHAR2  -- swai: bug 4666344
         ,p_RO_PRIORITY_CODE          VARCHAR2  -- swai: R12
	    ,p_RESOLVE_BY_DATE           DATE      -- rfieldma: 5355051
        ,p_BULLETIN_CHECK_DATE       DATE  --:= FND_API.G_MISS_DATE
        ,p_ESCALATION_CODE           VARCHAR2 --:= FND_API.G_MISS_CHAR
        ,p_RO_WARRANTY_STATUS_CODE   VARCHAR2
       )

IS
BEGIN
    Update CSD_REPAIRS
    SET
        REQUEST_ID   = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID)
       ,PROGRAM_ID   = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID)
       ,PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID)
       ,PROGRAM_UPDATE_DATE    = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE)
       ,CREATION_DATE          = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
       ,LAST_UPDATED_BY        = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,LAST_UPDATE_DATE       = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATE_LOGIN      = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
       ,REPAIR_NUMBER          = decode( p_REPAIR_NUMBER, FND_API.G_MISS_CHAR, REPAIR_NUMBER, p_REPAIR_NUMBER)
       ,INCIDENT_ID            = decode( p_INCIDENT_ID, FND_API.G_MISS_NUM, INCIDENT_ID, p_INCIDENT_ID)
       ,INVENTORY_ITEM_ID      = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID)
       ,CUSTOMER_PRODUCT_ID    = decode( p_CUSTOMER_PRODUCT_ID, FND_API.G_MISS_NUM, CUSTOMER_PRODUCT_ID, p_CUSTOMER_PRODUCT_ID)
       ,UNIT_OF_MEASURE        = decode( p_UNIT_OF_MEASURE, FND_API.G_MISS_CHAR, UNIT_OF_MEASURE, p_UNIT_OF_MEASURE)
       ,REPAIR_TYPE_ID         = decode( p_REPAIR_TYPE_ID, FND_API.G_MISS_NUM, REPAIR_TYPE_ID, p_REPAIR_TYPE_ID)
-- RESOURCE_GROUP Added by Vijay 10/28/2004
       ,OWNING_ORGANIZATION_ID = decode( p_RESOURCE_GROUP, FND_API.G_MISS_NUM, OWNING_ORGANIZATION_ID , p_RESOURCE_GROUP)
       ,RESOURCE_ID            = decode( p_RESOURCE_ID, FND_API.G_MISS_NUM, RESOURCE_ID, p_RESOURCE_ID)
       ,INSTANCE_ID            = decode( p_INSTANCE_ID, FND_API.G_MISS_NUM, INSTANCE_ID, p_INSTANCE_ID)
       ,PROJECT_ID             = decode( p_PROJECT_ID, FND_API.G_MISS_NUM, PROJECT_ID, p_PROJECT_ID)
       ,TASK_ID                = decode( p_TASK_ID, FND_API.G_MISS_NUM, TASK_ID, p_TASK_ID)
       ,CONTRACT_LINE_ID       = decode( p_CONTRACT_LINE_ID, FND_API.G_MISS_NUM, CONTRACT_LINE_ID, p_CONTRACT_LINE_ID)
       ,QUANTITY               = decode( p_QUANTITY, FND_API.G_MISS_NUM, QUANTITY, p_QUANTITY)
       -- For R12 Flex Flow, We can no more update status via Update_Repair_Order API.
       -- ,STATUS                 = decode( p_STATUS, FND_API.G_MISS_CHAR, STATUS, p_STATUS)
       ,APPROVAL_REQUIRED_FLAG = decode( p_APPROVAL_REQUIRED_FLAG, FND_API.G_MISS_CHAR, APPROVAL_REQUIRED_FLAG, p_APPROVAL_REQUIRED_FLAG)
       ,DATE_CLOSED      = decode( p_DATE_CLOSED, FND_API.G_MISS_DATE, DATE_CLOSED, p_DATE_CLOSED)
       ,QUANTITY_IN_WIP  = decode( p_QUANTITY_IN_WIP, FND_API.G_MISS_NUM, QUANTITY_IN_WIP, p_QUANTITY_IN_WIP)
       ,APPROVAL_STATUS  = decode( p_APPROVAL_STATUS, FND_API.G_MISS_CHAR, APPROVAL_STATUS, p_APPROVAL_STATUS)
       ,QUANTITY_RCVD    = decode( p_QUANTITY_RCVD, FND_API.G_MISS_NUM, QUANTITY_RCVD, p_QUANTITY_RCVD)
       ,QUANTITY_SHIPPED = decode( p_QUANTITY_SHIPPED, FND_API.G_MISS_NUM, QUANTITY_SHIPPED, p_QUANTITY_SHIPPED)
       ,CURRENCY_CODE    = decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, CURRENCY_CODE, p_CURRENCY_CODE)
       ,DEFAULT_PO_NUM   = decode( p_DEFAULT_PO_NUM, FND_API.G_MISS_CHAR, DEFAULT_PO_NUM, p_DEFAULT_PO_NUM)
       ,SERIAL_NUMBER    = decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, SERIAL_NUMBER, p_SERIAL_NUMBER)
       ,PROMISE_DATE     = decode( p_PROMISE_DATE, FND_API.G_MISS_DATE, PROMISE_DATE, p_PROMISE_DATE)
       ,ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY)
       ,ATTRIBUTE1  = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1)
       ,ATTRIBUTE2  = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2)
       ,ATTRIBUTE3  = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3)
       ,ATTRIBUTE4  = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4)
       ,ATTRIBUTE5  = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5)
       ,ATTRIBUTE6  = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6)
       ,ATTRIBUTE7  = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7)
       ,ATTRIBUTE8  = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8)
       ,ATTRIBUTE9  = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9)
       ,ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10)
       ,ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11)
       ,ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12)
       ,ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13)
       ,ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14)
       ,ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
       ,ORDER_LINE_ID = decode( p_ORDER_LINE_ID, FND_API.G_MISS_NUM, ORDER_LINE_ID, p_ORDER_LINE_ID)
       ,ORIGINAL_SOURCE_REFERENCE = decode( p_ORIGINAL_SOURCE_REFERENCE, FND_API.G_MISS_CHAR, ORIGINAL_SOURCE_REFERENCE, p_ORIGINAL_SOURCE_REFERENCE)
       ,STATUS_REASON_CODE    = decode( p_STATUS_REASON_CODE, FND_API.G_MISS_CHAR, STATUS_REASON_CODE, p_STATUS_REASON_CODE)
       ,OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
       ,AUTO_PROCESS_RMA      = decode( p_AUTO_PROCESS_RMA, FND_API.G_MISS_CHAR, AUTO_PROCESS_RMA, p_AUTO_PROCESS_RMA)
       ,REPAIR_MODE     = decode( p_REPAIR_MODE, FND_API.G_MISS_CHAR, REPAIR_MODE, p_REPAIR_MODE)
       ,ITEM_REVISION   = decode( p_ITEM_REVISION, FND_API.G_MISS_CHAR, ITEM_REVISION, p_ITEM_REVISION)
       ,REPAIR_GROUP_ID = decode( p_REPAIR_GROUP_ID, FND_API.G_MISS_NUM, REPAIR_GROUP_ID, p_REPAIR_GROUP_ID)
       ,RO_TXN_STATUS   = decode( p_RO_TXN_STATUS, FND_API.G_MISS_CHAR, RO_TXN_STATUS, p_RO_TXN_STATUS)
       ,ORIGINAL_SOURCE_HEADER_ID = decode( p_ORIGINAL_SOURCE_HEADER_ID , FND_API.G_MISS_NUM, ORIGINAL_SOURCE_HEADER_ID, p_ORIGINAL_SOURCE_HEADER_ID)
       ,ORIGINAL_SOURCE_LINE_ID   = decode( p_ORIGINAL_SOURCE_LINE_ID , FND_API.G_MISS_NUM, ORIGINAL_SOURCE_LINE_ID, p_ORIGINAL_SOURCE_LINE_ID)
       ,PRICE_LIST_HEADER_ID   = decode( p_PRICE_LIST_HEADER_ID , FND_API.G_MISS_NUM, PRICE_LIST_HEADER_ID, p_PRICE_LIST_HEADER_ID)
       ,PROBLEM_DESCRIPTION   = decode( p_PROBLEM_DESCRIPTION , FND_API.G_MISS_CHAR, PROBLEM_DESCRIPTION, p_PROBLEM_DESCRIPTION) -- swai: bug 4666344
       ,UNIT_NUMBER = decode( p_UNIT_NUMBER, FND_API.G_MISS_CHAR, UNIT_NUMBER, p_UNIT_NUMBER) -- rfieldma, project integration
       ,RO_PRIORITY_CODE   = decode( p_RO_PRIORITY_CODE , FND_API.G_MISS_CHAR, RO_PRIORITY_CODE, p_RO_PRIORITY_CODE) -- swai: R12
	   ,RESOLVE_BY_DATE     = decode( p_RESOLVE_BY_DATE, FND_API.G_MISS_DATE, RESOLVE_BY_DATE, p_RESOLVE_BY_DATE) -- rfieldma: 5355051
       ,BULLETIN_CHECK_DATE = decode( p_BULLETIN_CHECK_DATE, FND_API.G_MISS_DATE, BULLETIN_CHECK_DATE, p_BULLETIN_CHECK_DATE)
       ,ESCALATION_CODE = decode( p_ESCALATION_CODE , FND_API.G_MISS_CHAR, ESCALATION_CODE, p_ESCALATION_CODE)
       ,RO_WARRANTY_STATUS_CODE = decode( p_RO_WARRANTY_STATUS_CODE , FND_API.G_MISS_CHAR, RO_WARRANTY_STATUS_CODE, p_RO_WARRANTY_STATUS_CODE)
     --bug#7497907, 12.1 FP, subhat
      ,ATTRIBUTE16 = decode( p_ATTRIBUTE16, FND_API.G_MISS_CHAR, ATTRIBUTE16, p_ATTRIBUTE16)
  	  ,ATTRIBUTE17 = decode( p_ATTRIBUTE17, FND_API.G_MISS_CHAR, ATTRIBUTE17, p_ATTRIBUTE17)
  	  ,ATTRIBUTE18 = decode( p_ATTRIBUTE18, FND_API.G_MISS_CHAR, ATTRIBUTE18, p_ATTRIBUTE18)
  	  ,ATTRIBUTE19 = decode( p_ATTRIBUTE19, FND_API.G_MISS_CHAR, ATTRIBUTE19, p_ATTRIBUTE19)
  	  ,ATTRIBUTE20 = decode( p_ATTRIBUTE20, FND_API.G_MISS_CHAR, ATTRIBUTE20, p_ATTRIBUTE20)
  	  ,ATTRIBUTE21 = decode( p_ATTRIBUTE21, FND_API.G_MISS_CHAR, ATTRIBUTE21, p_ATTRIBUTE21)
  	  ,ATTRIBUTE22 = decode( p_ATTRIBUTE22, FND_API.G_MISS_CHAR, ATTRIBUTE22, p_ATTRIBUTE22)
  	  ,ATTRIBUTE23 = decode( p_ATTRIBUTE23, FND_API.G_MISS_CHAR, ATTRIBUTE23, p_ATTRIBUTE23)
  	  ,ATTRIBUTE24 = decode( p_ATTRIBUTE24, FND_API.G_MISS_CHAR, ATTRIBUTE24, p_ATTRIBUTE24)
  	  ,ATTRIBUTE25 = decode( p_ATTRIBUTE25, FND_API.G_MISS_CHAR, ATTRIBUTE25, p_ATTRIBUTE25)
  	  ,ATTRIBUTE26 = decode( p_ATTRIBUTE26, FND_API.G_MISS_CHAR, ATTRIBUTE26, p_ATTRIBUTE26)
  	  ,ATTRIBUTE27 = decode( p_ATTRIBUTE27, FND_API.G_MISS_CHAR, ATTRIBUTE27, p_ATTRIBUTE27)
  	  ,ATTRIBUTE28 = decode( p_ATTRIBUTE28, FND_API.G_MISS_CHAR, ATTRIBUTE28, p_ATTRIBUTE28)
  	  ,ATTRIBUTE29 = decode( p_ATTRIBUTE29, FND_API.G_MISS_CHAR, ATTRIBUTE29, p_ATTRIBUTE29)
  	  ,ATTRIBUTE30 = decode( p_ATTRIBUTE30, FND_API.G_MISS_CHAR, ATTRIBUTE30, p_ATTRIBUTE30)
    where REPAIR_LINE_ID = p_REPAIR_LINE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_REPAIR_LINE_ID  NUMBER)
IS
BEGIN
    DELETE FROM CSD_REPAIRS
    WHERE REPAIR_LINE_ID = p_REPAIR_LINE_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

PROCEDURE Lock_Row
(
   p_REPAIR_LINE_ID    NUMBER
  ,p_OBJECT_VERSION_NUMBER    NUMBER
  )

 IS
   CURSOR C IS
       SELECT *
       FROM CSD_REPAIRS
       WHERE REPAIR_LINE_ID =  p_REPAIR_LINE_ID
       FOR UPDATE of REPAIR_LINE_ID NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;

    l_debug := csd_gen_utility_pvt.g_debug_level;
    IF l_debug > 0 THEN
        csd_gen_utility_pvt.add('CSD_REPAIRS_PKG Recinfo.OBJECT_VERSION_NUMBER : '||Recinfo.OBJECT_VERSION_NUMBER);
        csd_gen_utility_pvt.add('CSD_REPAIRS_PKG p_OBJECT_VERSION_NUMBER : '||p_OBJECT_VERSION_NUMBER);
    END IF;

    If ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;

 END Lock_Row;

End CSD_REPAIRS_PKG;

/
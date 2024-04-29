--------------------------------------------------------
--  DDL for Package Body CSD_WIP_TRANSACTION_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_WIP_TRANSACTION_DTLS_PKG" as
/* $Header: csdtwtdb.pls 120.7.12010000.2 2008/10/15 20:29:08 swai ship $ */
-- Start of Comments
-- Package name     : CSD_WIP_TRANSACTION_DTLS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_WIP_TRANSACTION_DTLS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtdwdb.pls';
l_debug        NUMBER ;

PROCEDURE Insert_Row(
          px_WIP_TRANSACTION_DETAIL_ID IN OUT NOCOPY NUMBER
         ,p_CREATED_BY           IN NUMBER
         ,p_CREATION_DATE        IN DATE
         ,p_LAST_UPDATED_BY      IN NUMBER
         ,p_LAST_UPDATE_DATE     IN DATE
         ,p_LAST_UPDATE_LOGIN    IN NUMBER
         ,p_INVENTORY_ITEM_ID    IN NUMBER
         ,p_WIP_ENTITY_ID        IN NUMBER
         ,p_OPERATION_SEQ_NUM    IN NUMBER
         ,p_RESOURCE_SEQ_NUM     IN NUMBER
         ,p_employee_id          IN NUMBER
         ,p_TRANSACTION_QUANTITY IN NUMBER
         ,p_TRANSACTION_UOM      IN VARCHAR2
         ,p_SERIAL_NUMBER        IN VARCHAR2
         ,p_REVISION             IN VARCHAR2 -- swai: bug 7182047 (FP of 6995498)
         -- swai bug 6841113: added material txn reason code
         ,p_REASON_ID      IN NUMBER
         -- swai: added code for operations
         ,p_BACKFLUSH_FLAG             IN NUMBER
         ,p_COUNT_POINT_TYPE           IN NUMBER
         ,p_DEPARTMENT_ID              IN NUMBER
         ,p_DESCRIPTION                IN VARCHAR2
         ,p_FIRST_UNIT_COMPLETION_DATE IN DATE
         ,p_FIRST_UNIT_START_DATE      IN DATE
         ,p_LAST_UNIT_COMPLETION_DATE  IN DATE
         ,p_LAST_UNIT_START_DATE       IN DATE
         ,p_MINIMUM_TRANSFER_QUANTITY  IN NUMBER
         ,p_STANDARD_OPERATION_ID      IN NUMBER
         )

 IS
   CURSOR C2 IS SELECT CSD_WIP_TRANSACTION_DETAILS_S1.nextval FROM sys.dual;
   l_object_version_number NUMBER := 1;
BEGIN
   If (px_WIP_TRANSACTION_DETAIL_ID IS NULL) OR (px_WIP_TRANSACTION_DETAIL_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_WIP_TRANSACTION_DETAIL_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSD_WIP_TRANSACTION_DETAILS(
          WIP_TRANSACTION_DETAIL_ID
          ,CREATED_BY
         ,CREATION_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,INVENTORY_ITEM_ID
         ,WIP_ENTITY_ID
         ,OPERATION_SEQ_NUM
         ,RESOURCE_SEQ_NUM
         ,employee_id
         ,TRANSACTION_QUANTITY
         ,TRANSACTION_UOM
         ,SERIAL_NUMBER
         ,REVISION         -- swai: bug 7182047 (FP of 6995498)
         , REASON_ID         -- swai bug 6841113: added material txn reason code
         -- swai: added code for operations
         ,BACKFLUSH_FLAG
         ,COUNT_POINT_TYPE
         ,DEPARTMENT_ID
         ,DESCRIPTION
         ,FIRST_UNIT_COMPLETION_DATE
         ,FIRST_UNIT_START_DATE
         ,LAST_UNIT_COMPLETION_DATE
         ,LAST_UNIT_START_DATE
         ,MINIMUM_TRANSFER_QUANTITY
         ,STANDARD_OPERATION_ID
         -- end swai: added code for operations
         ,OBJECT_VERSION_NUMBER
          ) VALUES (
           px_WIP_TRANSACTION_DETAIL_ID
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          ,decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID)
          ,decode( p_WIP_ENTITY_ID, FND_API.G_MISS_NUM, NULL, p_WIP_ENTITY_ID)
          ,decode( p_OPERATION_SEQ_NUM, FND_API.G_MISS_NUM, NULL, p_OPERATION_SEQ_NUM)
          ,decode( p_RESOURCE_SEQ_NUM, FND_API.G_MISS_NUM, NULL, p_RESOURCE_SEQ_NUM)
          ,decode( p_employee_id, FND_API.G_MISS_NUM, NULL, p_employee_id)
          ,decode( p_TRANSACTION_QUANTITY, FND_API.G_MISS_NUM, NULL, p_TRANSACTION_QUANTITY)
          ,decode( p_TRANSACTION_UOM, FND_API.G_MISS_CHAR, NULL, p_TRANSACTION_UOM)
          ,decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, p_SERIAL_NUMBER)
          -- swai: bug 7182047 (FP of 6995498) added item revision
          ,decode( p_REVISION, FND_API.G_MISS_CHAR, NULL, p_REVISION)
          -- end swai: bug 7182047 (FP of 6995498) added item revision
          -- swai bug 6841113: added material txn reason code
          ,decode( p_REASON_ID, FND_API.G_MISS_NUM, NULL, p_REASON_ID)
          -- end swai bug 6841113: added material txn reason code
          -- swai: added code for operations
          ,decode( p_BACKFLUSH_FLAG, FND_API.G_MISS_NUM, NULL, p_BACKFLUSH_FLAG)
          ,decode( p_COUNT_POINT_TYPE, FND_API.G_MISS_NUM, NULL, p_COUNT_POINT_TYPE)
          ,decode( p_DEPARTMENT_ID, FND_API.G_MISS_NUM, NULL, p_DEPARTMENT_ID)
          ,decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION)
          ,decode( p_FIRST_UNIT_COMPLETION_DATE, FND_API.G_MISS_DATE, NULL, p_FIRST_UNIT_COMPLETION_DATE)
          ,decode( p_FIRST_UNIT_START_DATE, FND_API.G_MISS_DATE, NULL, p_FIRST_UNIT_START_DATE)
          ,decode( p_LAST_UNIT_COMPLETION_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UNIT_COMPLETION_DATE)
          ,decode( p_LAST_UNIT_START_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UNIT_START_DATE)
          ,decode( p_MINIMUM_TRANSFER_QUANTITY, FND_API.G_MISS_NUM, NULL, p_MINIMUM_TRANSFER_QUANTITY)
          ,decode( p_STANDARD_OPERATION_ID, FND_API.G_MISS_NUM, NULL, p_STANDARD_OPERATION_ID)
          -- end swai:  added code for operations
          ,l_object_version_number
            );
End Insert_Row;

PROCEDURE Update_Row(
          p_WIP_TRANSACTION_DETAIL_ID IN NUMBER
         ,p_CREATED_BY           IN NUMBER
         ,p_CREATION_DATE        IN DATE
         ,p_LAST_UPDATED_BY      IN NUMBER
         ,p_LAST_UPDATE_DATE     IN DATE
         ,p_LAST_UPDATE_LOGIN    IN NUMBER
         ,p_INVENTORY_ITEM_ID    IN NUMBER
         ,p_WIP_ENTITY_ID        IN NUMBER
         ,p_OPERATION_SEQ_NUM    IN NUMBER
         ,p_RESOURCE_SEQ_NUM     IN NUMBER
         ,p_employee_id          IN NUMBER
         ,p_TRANSACTION_QUANTITY IN NUMBER
         ,p_TRANSACTION_UOM      IN VARCHAR2
         ,p_SERIAL_NUMBER        IN VARCHAR2
         ,p_REVISION             IN VARCHAR2 -- swai: bug 7182047 (FP of 6995498)
         -- swai bug 6841113: added material txn reason code
         ,p_REASON_ID            IN NUMBER
         -- swai: added code for operations
         ,p_BACKFLUSH_FLAG             IN NUMBER
         ,p_COUNT_POINT_TYPE           IN NUMBER
         ,p_DEPARTMENT_ID              IN NUMBER
         ,p_DESCRIPTION                IN VARCHAR2
         ,p_FIRST_UNIT_COMPLETION_DATE IN DATE
         ,p_FIRST_UNIT_START_DATE      IN DATE
         ,p_LAST_UNIT_COMPLETION_DATE  IN DATE
         ,p_LAST_UNIT_START_DATE       IN DATE
         ,p_MINIMUM_TRANSFER_QUANTITY  IN NUMBER
         ,p_STANDARD_OPERATION_ID      IN NUMBER
         ,p_OBJECT_VERSION_NUMBER IN NUMBER
 )

IS
BEGIN
    Update CSD_WIP_TRANSACTION_DETAILS
    SET
       CREATED_BY             = decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, p_CREATED_BY)
       ,CREATION_DATE          = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, p_CREATION_DATE)
       ,LAST_UPDATED_BY        = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,LAST_UPDATE_DATE       = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATE_LOGIN      = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
       ,INVENTORY_ITEM_ID      = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, NULL, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID)
       ,WIP_ENTITY_ID          = decode( p_WIP_ENTITY_ID, FND_API.G_MISS_NUM, NULL, NULL, WIP_ENTITY_ID, p_WIP_ENTITY_ID)
       ,OPERATION_SEQ_NUM        = decode( p_OPERATION_SEQ_NUM, FND_API.G_MISS_NUM, NULL, NULL, OPERATION_SEQ_NUM, p_OPERATION_SEQ_NUM)
       ,RESOURCE_SEQ_NUM         = decode( p_RESOURCE_SEQ_NUM, FND_API.G_MISS_NUM, NULL, NULL, RESOURCE_SEQ_NUM, p_RESOURCE_SEQ_NUM)
       ,employee_id = decode( p_employee_id, FND_API.G_MISS_NUM, NULL, NULL, employee_id , p_employee_id)
       ,TRANSACTION_QUANTITY            = decode( p_TRANSACTION_QUANTITY, FND_API.G_MISS_NUM, NULL, NULL, TRANSACTION_QUANTITY, p_TRANSACTION_QUANTITY)
       ,TRANSACTION_UOM            = decode( p_TRANSACTION_UOM, FND_API.G_MISS_CHAR, NULL, NULL, TRANSACTION_UOM, p_TRANSACTION_UOM)
       ,SERIAL_NUMBER             = decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, NULL, SERIAL_NUMBER, p_SERIAL_NUMBER)
       -- swai: bug 7182047 (FP of 6995498) added item revision
       ,REVISION                  = decode( p_REVISION, FND_API.G_MISS_CHAR, NULL, NULL, REVISION, p_REVISION)
       -- end swai: bug 7182047 (FP of 6995498) added item revision
       -- swai bug 6841113: added material txn reason code
       ,REASON_ID      = decode( p_REASON_ID, FND_API.G_MISS_NUM, NULL, NULL, REASON_ID, p_REASON_ID)
       -- end swai bug 6841113: added material txn reason code
       -- swai: added code for operations
       ,BACKFLUSH_FLAG             = decode( p_BACKFLUSH_FLAG, FND_API.G_MISS_NUM, NULL, NULL, BACKFLUSH_FLAG, p_BACKFLUSH_FLAG)
       ,COUNT_POINT_TYPE           = decode( p_COUNT_POINT_TYPE, FND_API.G_MISS_NUM, NULL, NULL, COUNT_POINT_TYPE, p_COUNT_POINT_TYPE)
       ,DEPARTMENT_ID              = decode( p_DEPARTMENT_ID, FND_API.G_MISS_NUM, NULL, NULL, DEPARTMENT_ID, p_DEPARTMENT_ID)
       ,DESCRIPTION                = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, NULL, DESCRIPTION, p_DESCRIPTION)
       ,FIRST_UNIT_COMPLETION_DATE = decode( p_FIRST_UNIT_COMPLETION_DATE, FND_API.G_MISS_DATE, NULL, NULL, FIRST_UNIT_COMPLETION_DATE, p_FIRST_UNIT_COMPLETION_DATE)
       ,FIRST_UNIT_START_DATE      = decode( p_FIRST_UNIT_START_DATE, FND_API.G_MISS_DATE, NULL, NULL, FIRST_UNIT_START_DATE, p_FIRST_UNIT_START_DATE)
       ,LAST_UNIT_COMPLETION_DATE  = decode( p_LAST_UNIT_COMPLETION_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UNIT_COMPLETION_DATE, p_LAST_UNIT_COMPLETION_DATE)
       ,LAST_UNIT_START_DATE       = decode( p_LAST_UNIT_START_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UNIT_START_DATE, p_LAST_UNIT_START_DATE)
       ,MINIMUM_TRANSFER_QUANTITY  = decode( p_MINIMUM_TRANSFER_QUANTITY, FND_API.G_MISS_NUM, NULL, NULL, MINIMUM_TRANSFER_QUANTITY, p_MINIMUM_TRANSFER_QUANTITY)
       ,STANDARD_OPERATION_ID      = decode( p_STANDARD_OPERATION_ID, FND_API.G_MISS_NUM, NULL, NULL, STANDARD_OPERATION_ID, p_STANDARD_OPERATION_ID)
       -- end swai:  added code for operations
       ,OBJECT_VERSION_NUMBER                = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, NULL, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
    where WIP_TRANSACTION_DETAIL_ID = p_WIP_TRANSACTION_DETAIL_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_WIP_TRANSACTION_DETAIL_ID  NUMBER)
IS
BEGIN
    DELETE FROM CSD_WIP_TRANSACTION_DETAILS
    WHERE WIP_TRANSACTION_DETAIL_ID = p_WIP_TRANSACTION_DETAIL_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;



End CSD_WIP_TRANSACTION_DTLS_PKG;

/

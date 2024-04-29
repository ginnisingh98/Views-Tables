--------------------------------------------------------
--  DDL for Package CSD_WIP_TRANSACTION_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_WIP_TRANSACTION_DTLS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtwtds.pls 120.7.12010000.2 2008/10/15 20:27:24 swai ship $ */
-- Start of Comments
-- Package name     : CSD_WIP_TRANSACTION_DTLS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

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
         );


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
         ,p_OBJECT_VERSION_NUMBER IN NUMBER
         );


PROCEDURE Delete_Row(
    p_WIP_TRANSACTION_DETAIL_ID  NUMBER);

End CSD_WIP_TRANSACTION_DTLS_PKG;

/

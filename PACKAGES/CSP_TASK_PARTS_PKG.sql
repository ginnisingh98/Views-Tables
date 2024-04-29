--------------------------------------------------------
--  DDL for Package CSP_TASK_PARTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_TASK_PARTS_PKG" AUTHID CURRENT_USER as
/* $Header: cspttaps.pls 115.2 2002/11/26 07:42:56 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_TASK_PARTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
PROCEDURE Insert_Row(
          px_TASK_PART_ID   IN OUT NOCOPY NUMBER,
          p_PRODUCT_TASK_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_MANUAL_QUANTITY    NUMBER,
          p_MANUAL_PERCENTAGE    NUMBER,
          p_QUANTITY_USED    NUMBER,
          p_ACTUAL_TIMES_USED    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2,
          p_PRIMARY_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          P_ROLLUP_QUANTITY_USED NUMBER,
          P_ROLLUP_TIMES_USED NUMBER,
          P_SUBSTITUTE_ITEM NUMBER);
PROCEDURE Update_Row(
          p_TASK_PART_ID    NUMBER,
          p_PRODUCT_TASK_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_MANUAL_QUANTITY    NUMBER,
          p_MANUAL_PERCENTAGE    NUMBER,
          p_QUANTITY_USED    NUMBER,
          p_ACTUAL_TIMES_USED    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2,
          p_PRIMARY_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          P_ROLLUP_QUANTITY_USED NUMBER,
          P_ROLLUP_TIMES_USED NUMBER,
          P_SUBSTITUTE_ITEM NUMBER);

PROCEDURE Lock_Row(
          p_TASK_PART_ID    NUMBER,
          p_PRODUCT_TASK_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_MANUAL_QUANTITY    NUMBER,
          p_MANUAL_PERCENTAGE    NUMBER,
          p_QUANTITY_USED    NUMBER,
          p_ACTUAL_TIMES_USED    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2,
          p_PRIMARY_UOM_CODE    VARCHAR2,
          p_REVISION    VARCHAR2,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          P_ROLLUP_QUANTITY_USED NUMBER,
          P_ROLLUP_TIMES_USED NUMBER,
          P_SUBSTITUTE_ITEM   NUMBER   );
PROCEDURE Delete_Row(
    p_TASK_PART_ID  NUMBER);
End CSP_TASK_PARTS_PKG;

 

/

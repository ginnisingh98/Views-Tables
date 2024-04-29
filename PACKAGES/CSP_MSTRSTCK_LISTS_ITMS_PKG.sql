--------------------------------------------------------
--  DDL for Package CSP_MSTRSTCK_LISTS_ITMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_MSTRSTCK_LISTS_ITMS_PKG" AUTHID CURRENT_USER as
/* $Header: csptpsts.pls 115.2 2002/11/26 06:27:25 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_MSTRSTCK_LISTS_ITMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_MSL_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_LOGIN    NUMBER,
          p_PARTS_LOOPS_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_TOTAL_LOOP_QUANTITY    NUMBER,
          p_TOTAL_LOOP_MIN_GOOD_QUANTITY    NUMBER,
          p_PLANNING_TYPE_CODE    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_REVISION    VARCHAR2,
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
          p_MSL_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_LOGIN    NUMBER,
          p_PARTS_LOOPS_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_TOTAL_LOOP_QUANTITY    NUMBER,
          p_TOTAL_LOOP_MIN_GOOD_QUANTITY    NUMBER,
          p_PLANNING_TYPE_CODE    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_REVISION    VARCHAR2,
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
          p_MSL_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_LOGIN    NUMBER,
          p_PARTS_LOOPS_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_TOTAL_LOOP_QUANTITY    NUMBER,
          p_TOTAL_LOOP_MIN_GOOD_QUANTITY    NUMBER,
          p_PLANNING_TYPE_CODE    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_REVISION    VARCHAR2,
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
    p_MSL_ID  NUMBER);
End CSP_MSTRSTCK_LISTS_ITMS_PKG;

 

/

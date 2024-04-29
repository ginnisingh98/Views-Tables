--------------------------------------------------------
--  DDL for Package Body CSP_CURR_SUP_DEM_SUMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_CURR_SUP_DEM_SUMS_PKG" as
/* $Header: csptpsdb.pls 115.6 2002/11/26 07:32:16 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_CURR_SUP_DEM_SUMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_CURR_SUP_DEM_SUMS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptpsdb.pls';


PROCEDURE Insert_Row(
          px_SUPPLY_DEMAND_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
		  p_planning_parameters_id		number,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_ONHAND_BAD    NUMBER,
          p_ONHAND_GOOD    NUMBER,
          p_INTRANSIT_MOVE_ORDERS    NUMBER,
          p_OPEN_INTERORG_TRANSF_IN    NUMBER,
          p_OPEN_INTERORG_TRANSF_OUT    NUMBER,
          p_OPEN_SALES_ORDERS    NUMBER,
          p_OPEN_MOVE_ORDERS_IN    NUMBER,
          p_OPEN_MOVE_ORDERS_OUT    NUMBER,
          p_OPEN_REQUISITIONS    NUMBER,
          p_OPEN_PURCHASE_ORDERS    NUMBER,
          p_OPEN_WORK_ORDERS    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSP_CURR_SUP_DEM_SUMS_S1.nextval FROM sys.dual;
BEGIN
   If (px_SUPPLY_DEMAND_ID IS NULL) OR (px_SUPPLY_DEMAND_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_SUPPLY_DEMAND_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_CURR_SUP_DEM_SUMS(
           SUPPLY_DEMAND_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           PARTS_LOOP_ID,
           HIERARCHY_NODE_ID,
		   planning_parameters_id,
           SUBINVENTORY_CODE,
           ONHAND_BAD,
           ONHAND_GOOD,
           INTRANSIT_MOVE_ORDERS,
           OPEN_INTERORG_TRANSF_IN,
           OPEN_INTERORG_TRANSF_OUT,
           OPEN_SALES_ORDERS,
           OPEN_MOVE_ORDERS_IN,
           OPEN_MOVE_ORDERS_OUT,
           OPEN_REQUISITIONS,
           OPEN_PURCHASE_ORDERS,
           OPEN_WORK_ORDERS,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
          ) VALUES (
           px_SUPPLY_DEMAND_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, to_date(null), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(null), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(null), p_PROGRAM_UPDATE_DATE),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_PARTS_LOOP_ID, FND_API.G_MISS_NUM, NULL, p_PARTS_LOOP_ID),
           decode( p_HIERARCHY_NODE_ID, FND_API.G_MISS_NUM, NULL, p_HIERARCHY_NODE_ID),
		   decode( p_planning_parameters_id,fnd_api.g_miss_num,null,p_planning_parameters_id),
           decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, NULL, p_SUBINVENTORY_CODE),
           decode( p_ONHAND_BAD, FND_API.G_MISS_NUM, NULL, p_ONHAND_BAD),
           decode( p_ONHAND_GOOD, FND_API.G_MISS_NUM, NULL, p_ONHAND_GOOD),
           decode( p_INTRANSIT_MOVE_ORDERS, FND_API.G_MISS_NUM, NULL, p_INTRANSIT_MOVE_ORDERS),
           decode( p_OPEN_INTERORG_TRANSF_IN, FND_API.G_MISS_NUM, NULL, p_OPEN_INTERORG_TRANSF_IN),
           decode( p_OPEN_INTERORG_TRANSF_OUT, FND_API.G_MISS_NUM, NULL, p_OPEN_INTERORG_TRANSF_OUT),
           decode( p_OPEN_SALES_ORDERS, FND_API.G_MISS_NUM, NULL, p_OPEN_SALES_ORDERS),
           decode( p_OPEN_MOVE_ORDERS_IN, FND_API.G_MISS_NUM, NULL, p_OPEN_MOVE_ORDERS_IN),
           decode( p_OPEN_MOVE_ORDERS_OUT, FND_API.G_MISS_NUM, NULL, p_OPEN_MOVE_ORDERS_OUT),
           decode( p_OPEN_REQUISITIONS, FND_API.G_MISS_NUM, NULL, p_OPEN_REQUISITIONS),
           decode( p_OPEN_PURCHASE_ORDERS, FND_API.G_MISS_NUM, NULL, p_OPEN_PURCHASE_ORDERS),
           decode( p_OPEN_WORK_ORDERS, FND_API.G_MISS_NUM, NULL, p_OPEN_WORK_ORDERS),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15));
End Insert_Row;

PROCEDURE Update_Row(
          p_SUPPLY_DEMAND_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
		  p_planning_parameters_id		number,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_ONHAND_BAD    NUMBER,
          p_ONHAND_GOOD    NUMBER,
          p_INTRANSIT_MOVE_ORDERS    NUMBER,
          p_OPEN_INTERORG_TRANSF_IN    NUMBER,
          p_OPEN_INTERORG_TRANSF_OUT    NUMBER,
          p_OPEN_SALES_ORDERS    NUMBER,
          p_OPEN_MOVE_ORDERS_IN    NUMBER,
          p_OPEN_MOVE_ORDERS_OUT    NUMBER,
          p_OPEN_REQUISITIONS    NUMBER,
          p_OPEN_PURCHASE_ORDERS    NUMBER,
          p_OPEN_WORK_ORDERS    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)

 IS
 BEGIN
    Update CSP_CURR_SUP_DEM_SUMS
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              PARTS_LOOP_ID = decode( p_PARTS_LOOP_ID, FND_API.G_MISS_NUM, PARTS_LOOP_ID, p_PARTS_LOOP_ID),
              HIERARCHY_NODE_ID = decode( p_HIERARCHY_NODE_ID, FND_API.G_MISS_NUM, HIERARCHY_NODE_ID, p_HIERARCHY_NODE_ID),
			  planning_parameters_id = decode(p_planning_parameters_id,fnd_api.g_miss_num,planning_parameters_id,p_planning_parameters_id),
              SUBINVENTORY_CODE = decode( p_SUBINVENTORY_CODE, FND_API.G_MISS_CHAR, SUBINVENTORY_CODE, p_SUBINVENTORY_CODE),
              ONHAND_BAD = decode( p_ONHAND_BAD, FND_API.G_MISS_NUM, ONHAND_BAD, p_ONHAND_BAD),
              ONHAND_GOOD = decode( p_ONHAND_GOOD, FND_API.G_MISS_NUM, ONHAND_GOOD, p_ONHAND_GOOD),
              INTRANSIT_MOVE_ORDERS = decode( p_INTRANSIT_MOVE_ORDERS, FND_API.G_MISS_NUM, INTRANSIT_MOVE_ORDERS, p_INTRANSIT_MOVE_ORDERS),
              OPEN_INTERORG_TRANSF_IN = decode( p_OPEN_INTERORG_TRANSF_IN, FND_API.G_MISS_NUM, OPEN_INTERORG_TRANSF_IN, p_OPEN_INTERORG_TRANSF_IN),
              OPEN_INTERORG_TRANSF_OUT = decode( p_OPEN_INTERORG_TRANSF_OUT, FND_API.G_MISS_NUM, OPEN_INTERORG_TRANSF_OUT, p_OPEN_INTERORG_TRANSF_OUT),
              OPEN_SALES_ORDERS = decode( p_OPEN_SALES_ORDERS, FND_API.G_MISS_NUM, OPEN_SALES_ORDERS, p_OPEN_SALES_ORDERS),
              OPEN_MOVE_ORDERS_IN = decode( p_OPEN_MOVE_ORDERS_IN, FND_API.G_MISS_NUM, OPEN_MOVE_ORDERS_IN, p_OPEN_MOVE_ORDERS_IN),
              OPEN_MOVE_ORDERS_OUT = decode( p_OPEN_MOVE_ORDERS_OUT, FND_API.G_MISS_NUM, OPEN_MOVE_ORDERS_OUT, p_OPEN_MOVE_ORDERS_OUT),
              OPEN_REQUISITIONS = decode( p_OPEN_REQUISITIONS, FND_API.G_MISS_NUM, OPEN_REQUISITIONS, p_OPEN_REQUISITIONS),
              OPEN_PURCHASE_ORDERS = decode( p_OPEN_PURCHASE_ORDERS, FND_API.G_MISS_NUM, OPEN_PURCHASE_ORDERS, p_OPEN_PURCHASE_ORDERS),
              OPEN_WORK_ORDERS = decode( p_OPEN_WORK_ORDERS, FND_API.G_MISS_NUM, OPEN_WORK_ORDERS, p_OPEN_WORK_ORDERS),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
    where SUPPLY_DEMAND_ID = p_SUPPLY_DEMAND_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_SUPPLY_DEMAND_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_CURR_SUP_DEM_SUMS
    WHERE SUPPLY_DEMAND_ID = p_SUPPLY_DEMAND_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_SUPPLY_DEMAND_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
		  p_planning_parameters_id		number,
          p_SUBINVENTORY_CODE    VARCHAR2,
          p_ONHAND_BAD    NUMBER,
          p_ONHAND_GOOD    NUMBER,
          p_INTRANSIT_MOVE_ORDERS    NUMBER,
          p_OPEN_INTERORG_TRANSF_IN    NUMBER,
          p_OPEN_INTERORG_TRANSF_OUT    NUMBER,
          p_OPEN_SALES_ORDERS    NUMBER,
          p_OPEN_MOVE_ORDERS_IN    NUMBER,
          p_OPEN_MOVE_ORDERS_OUT    NUMBER,
          p_OPEN_REQUISITIONS    NUMBER,
          p_OPEN_PURCHASE_ORDERS    NUMBER,
          p_OPEN_WORK_ORDERS    NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_CURR_SUP_DEM_SUMS
        WHERE SUPPLY_DEMAND_ID =  p_SUPPLY_DEMAND_ID
        FOR UPDATE of SUPPLY_DEMAND_ID NOWAIT;
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
    if (
           (      Recinfo.SUPPLY_DEMAND_ID = p_SUPPLY_DEMAND_ID)
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.PARTS_LOOP_ID = p_PARTS_LOOP_ID)
            OR (    ( Recinfo.PARTS_LOOP_ID IS NULL )
                AND (  p_PARTS_LOOP_ID IS NULL )))
       AND (    ( Recinfo.HIERARCHY_NODE_ID = p_HIERARCHY_NODE_ID)
            OR (    ( Recinfo.HIERARCHY_NODE_ID IS NULL )
                AND (  p_HIERARCHY_NODE_ID IS NULL )))
       AND (    ( Recinfo.planning_parameters_id = p_planning_parameters_id)
            OR (    ( Recinfo.planning_parameters_id IS NULL )
                AND (  p_planning_parameters_id IS NULL )))
       AND (    ( Recinfo.SUBINVENTORY_CODE = p_SUBINVENTORY_CODE)
            OR (    ( Recinfo.SUBINVENTORY_CODE IS NULL )
                AND (  p_SUBINVENTORY_CODE IS NULL )))
       AND (    ( Recinfo.ONHAND_BAD = p_ONHAND_BAD)
            OR (    ( Recinfo.ONHAND_BAD IS NULL )
                AND (  p_ONHAND_BAD IS NULL )))
       AND (    ( Recinfo.ONHAND_GOOD = p_ONHAND_GOOD)
            OR (    ( Recinfo.ONHAND_GOOD IS NULL )
                AND (  p_ONHAND_GOOD IS NULL )))
       AND (    ( Recinfo.INTRANSIT_MOVE_ORDERS = p_INTRANSIT_MOVE_ORDERS)
            OR (    ( Recinfo.INTRANSIT_MOVE_ORDERS IS NULL )
                AND (  p_INTRANSIT_MOVE_ORDERS IS NULL )))
       AND (    ( Recinfo.OPEN_INTERORG_TRANSF_IN = p_OPEN_INTERORG_TRANSF_IN)
            OR (    ( Recinfo.OPEN_INTERORG_TRANSF_IN IS NULL )
                AND (  p_OPEN_INTERORG_TRANSF_IN IS NULL )))
       AND (    ( Recinfo.OPEN_INTERORG_TRANSF_OUT = p_OPEN_INTERORG_TRANSF_OUT)
            OR (    ( Recinfo.OPEN_INTERORG_TRANSF_OUT IS NULL )
                AND (  p_OPEN_INTERORG_TRANSF_OUT IS NULL )))
       AND (    ( Recinfo.OPEN_SALES_ORDERS = p_OPEN_SALES_ORDERS)
            OR (    ( Recinfo.OPEN_SALES_ORDERS IS NULL )
                AND (  p_OPEN_SALES_ORDERS IS NULL )))
       AND (    ( Recinfo.OPEN_MOVE_ORDERS_IN = p_OPEN_MOVE_ORDERS_IN)
            OR (    ( Recinfo.OPEN_MOVE_ORDERS_IN IS NULL )
                AND (  p_OPEN_MOVE_ORDERS_IN IS NULL )))
       AND (    ( Recinfo.OPEN_MOVE_ORDERS_OUT = p_OPEN_MOVE_ORDERS_OUT)
            OR (    ( Recinfo.OPEN_MOVE_ORDERS_OUT IS NULL )
                AND (  p_OPEN_MOVE_ORDERS_OUT IS NULL )))
       AND (    ( Recinfo.OPEN_REQUISITIONS = p_OPEN_REQUISITIONS)
            OR (    ( Recinfo.OPEN_REQUISITIONS IS NULL )
                AND (  p_OPEN_REQUISITIONS IS NULL )))
       AND (    ( Recinfo.OPEN_PURCHASE_ORDERS = p_OPEN_PURCHASE_ORDERS)
            OR (    ( Recinfo.OPEN_PURCHASE_ORDERS IS NULL )
                AND (  p_OPEN_PURCHASE_ORDERS IS NULL )))
       AND (    ( Recinfo.OPEN_WORK_ORDERS = p_OPEN_WORK_ORDERS)
            OR (    ( Recinfo.OPEN_WORK_ORDERS IS NULL )
                AND (  p_OPEN_WORK_ORDERS IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;


End CSP_CURR_SUP_DEM_SUMS_PKG;

/

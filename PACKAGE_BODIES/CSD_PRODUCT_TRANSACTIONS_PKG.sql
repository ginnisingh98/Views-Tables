--------------------------------------------------------
--  DDL for Package Body CSD_PRODUCT_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_PRODUCT_TRANSACTIONS_PKG" as
/* $Header: csdtptxb.pls 120.3.12010000.2 2008/09/18 18:46:31 nnadig ship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_PRODUCT_TRANSACTIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtptxb.pls';
l_debug        NUMBER := csd_gen_utility_pvt.g_debug_level;

PROCEDURE Insert_Row(
          px_PRODUCT_TRANSACTION_ID   IN OUT NOCOPY NUMBER,
          p_REPAIR_LINE_ID           NUMBER,
          p_ESTIMATE_DETAIL_ID       NUMBER,
          p_ACTION_TYPE              VARCHAR2,
          p_ACTION_CODE              VARCHAR2,
          p_LOT_NUMBER               VARCHAR2,
          p_SUB_INVENTORY            VARCHAR2,
          p_INTERFACE_TO_OM_FLAG     VARCHAR2,
          p_BOOK_SALES_ORDER_FLAG    VARCHAR2,
          p_RELEASE_SALES_ORDER_FLAG VARCHAR2,
          p_SHIP_SALES_ORDER_FLAG    VARCHAR2,
          p_PROD_TXN_STATUS          VARCHAR2,
          p_PROD_TXN_CODE            VARCHAR2,
          p_LAST_UPDATE_DATE         DATE,
          p_CREATION_DATE            DATE,
          p_LAST_UPDATED_BY          NUMBER,
          p_CREATED_BY               NUMBER,
          p_LAST_UPDATE_LOGIN        NUMBER,
          p_ATTRIBUTE1               VARCHAR2,
          p_ATTRIBUTE2               VARCHAR2,
          p_ATTRIBUTE3               VARCHAR2,
          p_ATTRIBUTE4               VARCHAR2,
          p_ATTRIBUTE5               VARCHAR2,
          p_ATTRIBUTE6               VARCHAR2,
          p_ATTRIBUTE7               VARCHAR2,
          p_ATTRIBUTE8               VARCHAR2,
          p_ATTRIBUTE9               VARCHAR2,
          p_ATTRIBUTE10              VARCHAR2,
          p_ATTRIBUTE11              VARCHAR2,
          p_ATTRIBUTE12              VARCHAR2,
          p_ATTRIBUTE13              VARCHAR2,
          p_ATTRIBUTE14              VARCHAR2,
          p_ATTRIBUTE15              VARCHAR2,
          p_CONTEXT                  VARCHAR2,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          P_REQ_HEADER_ID            NUMBER,
          P_REQ_LINE_ID              NUMBER,
          P_ORDER_HEADER_ID          NUMBER,
          P_ORDER_LINE_ID            NUMBER,
          P_PRD_TXN_QTY_RECEIVED     NUMBER,
          P_PRD_TXN_QTY_SHIPPED      NUMBER,
          P_SOURCE_SERIAL_NUMBER     VARCHAR2,
          P_SOURCE_INSTANCE_ID       NUMBER,
          P_NON_SOURCE_SERIAL_NUMBER VARCHAR2,
          P_NON_SOURCE_INSTANCE_ID   NUMBER,
          P_LOCATOR_ID               NUMBER,
          P_SUB_INVENTORY_RCVD       VARCHAR2,
          P_LOT_NUMBER_RCVD          VARCHAR2,
          P_PICKING_RULE_ID          NUMBER,      -- R12 development change
          P_PROJECT_ID               NUMBER,
          P_TASK_ID                  NUMBER,
          P_UNIT_NUMBER              VARCHAR2,
          P_INTERNAL_PO_HEADER_ID    NUMBER    -- swai: bug 6148019
      )

 IS
   CURSOR C2 IS SELECT CSD_PRODUCT_TRANSACTIONS_S1.nextval FROM sys.dual;
BEGIN
   -- Since Product transaction id is a primary key, it is good if value is always
   -- generated from a sequence. This is to fix bug 3215153 saupadhy
   -- If (px_PRODUCT_TRANSACTION_ID IS NULL) OR (px_PRODUCT_TRANSACTION_ID = FND_API.G_MISS_NUM) then
   OPEN C2;
   FETCH C2 INTO px_PRODUCT_TRANSACTION_ID;
   CLOSE C2;
   -- End If;
   INSERT INTO CSD_PRODUCT_TRANSACTIONS(
           PRODUCT_TRANSACTION_ID,
           REPAIR_LINE_ID,
           ESTIMATE_DETAIL_ID,
           ACTION_TYPE,
           ACTION_CODE,
           LOT_NUMBER,
           SUB_INVENTORY,
           INTERFACE_TO_OM_FLAG,
           BOOK_SALES_ORDER_FLAG,
           RELEASE_SALES_ORDER_FLAG,
           SHIP_SALES_ORDER_FLAG,
           PROD_TXN_STATUS,
           PROD_TXN_CODE,
           LAST_UPDATE_DATE,
           CREATION_DATE,
           LAST_UPDATED_BY,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
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
           ATTRIBUTE15,
           CONTEXT,
           OBJECT_VERSION_NUMBER,
		 REQ_HEADER_ID            ,
		 REQ_LINE_ID              ,
		 ORDER_HEADER_ID          ,
		 ORDER_LINE_ID            ,
		 QUANTITY_RECEIVED        ,
		 QUANTITY_SHIPPED         ,
		 SOURCE_SERIAL_NUMBER     ,
		 SOURCE_INSTANCE_ID   ,
		 NON_SOURCE_SERIAL_NUMBER ,
		 NON_SOURCE_INSTANCE_ID ,
           LOCATOR_ID               ,
		 SUB_INVENTORY_RCVD       ,
		 LOT_NUMBER_RCVD          ,
		 PICKING_RULE_ID,
       PROJECT_ID,
       TASK_ID,
       UNIT_NUMBER,
         INTERNAL_PO_HEADER_ID
       )
           VALUES (
           px_PRODUCT_TRANSACTION_ID,
           p_REPAIR_LINE_ID,
           decode( p_ESTIMATE_DETAIL_ID, FND_API.G_MISS_NUM, NULL, p_ESTIMATE_DETAIL_ID),
           decode( p_ACTION_TYPE, FND_API.G_MISS_CHAR, NULL, p_ACTION_TYPE),
           decode( p_ACTION_CODE, FND_API.G_MISS_CHAR, NULL, p_ACTION_CODE),
           decode( p_LOT_NUMBER, FND_API.G_MISS_CHAR, NULL, p_LOT_NUMBER),
           decode( p_SUB_INVENTORY, FND_API.G_MISS_CHAR, NULL, p_SUB_INVENTORY),
           decode( p_INTERFACE_TO_OM_FLAG, FND_API.G_MISS_CHAR, NULL, p_INTERFACE_TO_OM_FLAG),
           decode( p_BOOK_SALES_ORDER_FLAG, FND_API.G_MISS_CHAR, NULL, p_BOOK_SALES_ORDER_FLAG),
           decode( p_RELEASE_SALES_ORDER_FLAG, FND_API.G_MISS_CHAR, NULL, p_RELEASE_SALES_ORDER_FLAG),
           decode( p_SHIP_SALES_ORDER_FLAG, FND_API.G_MISS_CHAR, NULL, p_SHIP_SALES_ORDER_FLAG),
           decode( p_PROD_TXN_STATUS, FND_API.G_MISS_CHAR, NULL, p_PROD_TXN_STATUS),
           decode( p_PROD_TXN_CODE, FND_API.G_MISS_CHAR, NULL, p_PROD_TXN_CODE),
           p_LAST_UPDATE_DATE,
           p_CREATION_DATE,
           p_LAST_UPDATED_BY,
           p_CREATED_BY,
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
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
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
           decode( p_CONTEXT, FND_API.G_MISS_CHAR, NULL, p_CONTEXT),
           p_OBJECT_VERSION_NUMBER,
		 decode(p_Req_Header_Id,Fnd_API.G_MISS_NUM,NULL,p_Req_Header_Id),
		 decode(p_Req_Line_Id,Fnd_API.G_MISS_NUM,NULL,p_Req_Line_Id),
		 decode(p_Order_Header_Id,Fnd_API.G_MISS_NUM,NULL,p_Order_Header_Id),
		 decode(p_Order_Line_Id,Fnd_API.G_MISS_NUM,NULL,p_Order_Line_Id),
		 decode(p_Prd_Txn_Qty_Received,Fnd_API.G_MISS_NUM,NULL,p_Prd_Txn_Qty_Received),
		 decode(p_Prd_Txn_Qty_Shipped,Fnd_API.G_MISS_NUM,NULL,p_Prd_Txn_Qty_Shipped),
		 decode(p_Source_Serial_Number,Fnd_API.G_MISS_CHAR,NULL,p_Source_Serial_Number) ,
		 decode(p_Source_Instance_ID,Fnd_API.G_MISS_NUM,NULL,p_Source_Instance_Id) ,
		 decode(p_Non_Source_Serial_Number,Fnd_API.G_MISS_CHAR,NULL,p_Non_Source_Serial_Number) ,
		 decode(p_Non_Source_Instance_ID,Fnd_API.G_MISS_NUM,NULL,p_Non_Source_Instance_ID) ,
           decode(p_Locator_Id , Fnd_API.G_MISS_NUM,NULL,p_Locator_Id),
		 decode(p_Sub_Inventory_Rcvd,Fnd_API.G_MISS_CHAR,NULL,p_Sub_Inventory_Rcvd),
		 decode(p_Lot_Number_Rcvd,Fnd_API.G_MISS_CHAR,NULL,p_Lot_Number_rcvd),
		 decode(p_picking_rule_id,Fnd_API.G_MISS_CHAR,NULL,p_picking_rule_id),
       decode(P_PROJECT_ID,Fnd_API.G_MISS_NUM,NULL,P_PROJECT_ID),
       decode(P_TASK_ID,Fnd_API.G_MISS_NUM,NULL,P_TASK_ID),
       decode(P_UNIT_NUMBER,Fnd_API.G_MISS_CHAR,NULL,P_UNIT_NUMBER),
       --taklam
       -- swai: bug 6148019
       decode(P_INTERNAL_PO_HEADER_ID,Fnd_API.G_MISS_NUM,NULL,P_INTERNAL_PO_HEADER_ID));

End Insert_Row;

PROCEDURE Update_Row(
          p_PRODUCT_TRANSACTION_ID      NUMBER,
          p_REPAIR_LINE_ID              NUMBER,
          p_ESTIMATE_DETAIL_ID          NUMBER,
          p_ACTION_TYPE                 VARCHAR2,
          p_ACTION_CODE                 VARCHAR2,
          p_LOT_NUMBER                  VARCHAR2,
          p_SUB_INVENTORY               VARCHAR2,
          p_INTERFACE_TO_OM_FLAG        VARCHAR2,
          p_BOOK_SALES_ORDER_FLAG       VARCHAR2,
          p_RELEASE_SALES_ORDER_FLAG    VARCHAR2,
          p_SHIP_SALES_ORDER_FLAG       VARCHAR2,
          p_PROD_TXN_STATUS             VARCHAR2,
          p_PROD_TXN_CODE               VARCHAR2,
          p_LAST_UPDATE_DATE            DATE,
          p_CREATION_DATE               DATE,
          p_LAST_UPDATED_BY             NUMBER,
          p_CREATED_BY                  NUMBER,
          p_LAST_UPDATE_LOGIN           NUMBER,
          p_ATTRIBUTE1                  VARCHAR2,
          p_ATTRIBUTE2                  VARCHAR2,
          p_ATTRIBUTE3                  VARCHAR2,
          p_ATTRIBUTE4                  VARCHAR2,
          p_ATTRIBUTE5                  VARCHAR2,
          p_ATTRIBUTE6                  VARCHAR2,
          p_ATTRIBUTE7                  VARCHAR2,
          p_ATTRIBUTE8                  VARCHAR2,
          p_ATTRIBUTE9                  VARCHAR2,
          p_ATTRIBUTE10                 VARCHAR2,
          p_ATTRIBUTE11                 VARCHAR2,
          p_ATTRIBUTE12                 VARCHAR2,
          p_ATTRIBUTE13                 VARCHAR2,
          p_ATTRIBUTE14                 VARCHAR2,
          p_ATTRIBUTE15                 VARCHAR2,
          p_CONTEXT                     VARCHAR2,
          p_OBJECT_VERSION_NUMBER       NUMBER,
          P_REQ_HEADER_ID               NUMBER,
          P_REQ_LINE_ID                 NUMBER,
          P_ORDER_HEADER_ID             NUMBER,
          P_ORDER_LINE_ID               NUMBER,
          P_PRD_TXN_QTY_RECEIVED        NUMBER,
          P_PRD_TXN_QTY_SHIPPED         NUMBER,
          P_SOURCE_SERIAL_NUMBER        VARCHAR2,
          P_SOURCE_INSTANCE_ID          NUMBER,
          P_NON_SOURCE_SERIAL_NUMBER    VARCHAR2,
          P_NON_SOURCE_INSTANCE_ID      NUMBER,
          P_LOCATOR_ID                  NUMBER,
          P_SUB_INVENTORY_RCVD          VARCHAR2,
          P_LOT_NUMBER_RCVD             VARCHAR2,
          P_PICKING_RULE_ID             NUMBER,    -- R12 addition
          P_PROJECT_ID                  NUMBER,
          P_TASK_ID                     NUMBER,
          P_UNIT_NUMBER                 VARCHAR2,
          P_INTERNAL_PO_HEADER_ID       NUMBER     -- swai: bug 6148019
      )
 IS
 BEGIN
    NULL ;
    Update CSD_PRODUCT_TRANSACTIONS
    SET
       REPAIR_LINE_ID = decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, REPAIR_LINE_ID, p_REPAIR_LINE_ID),
       ESTIMATE_DETAIL_ID = decode( p_ESTIMATE_DETAIL_ID, FND_API.G_MISS_NUM, ESTIMATE_DETAIL_ID, p_ESTIMATE_DETAIL_ID),
       ACTION_TYPE = decode( p_ACTION_TYPE, FND_API.G_MISS_CHAR, ACTION_TYPE, p_ACTION_TYPE),
       ACTION_CODE = decode( p_ACTION_CODE, FND_API.G_MISS_CHAR, ACTION_CODE, p_ACTION_CODE),
       LOT_NUMBER = decode( p_LOT_NUMBER, FND_API.G_MISS_CHAR, LOT_NUMBER, p_LOT_NUMBER),
       SUB_INVENTORY = decode( p_SUB_INVENTORY, FND_API.G_MISS_CHAR, SUB_INVENTORY, p_SUB_INVENTORY),
       INTERFACE_TO_OM_FLAG = decode( p_INTERFACE_TO_OM_FLAG, FND_API.G_MISS_CHAR, INTERFACE_TO_OM_FLAG, p_INTERFACE_TO_OM_FLAG),
       BOOK_SALES_ORDER_FLAG = decode( p_BOOK_SALES_ORDER_FLAG, FND_API.G_MISS_CHAR, BOOK_SALES_ORDER_FLAG, p_BOOK_SALES_ORDER_FLAG),
       RELEASE_SALES_ORDER_FLAG = decode( p_RELEASE_SALES_ORDER_FLAG, FND_API.G_MISS_CHAR, RELEASE_SALES_ORDER_FLAG, p_RELEASE_SALES_ORDER_FLAG),
       SHIP_SALES_ORDER_FLAG = decode( p_SHIP_SALES_ORDER_FLAG, FND_API.G_MISS_CHAR, SHIP_SALES_ORDER_FLAG, p_SHIP_SALES_ORDER_FLAG),
       PROD_TXN_STATUS = decode( p_PROD_TXN_STATUS, FND_API.G_MISS_CHAR, PROD_TXN_STATUS, p_PROD_TXN_STATUS),
       PROD_TXN_CODE = decode( p_PROD_TXN_CODE, FND_API.G_MISS_CHAR, PROD_TXN_CODE, p_PROD_TXN_CODE),
       LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
       -- CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
       LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
       -- CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
       LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
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
       ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
       CONTEXT = decode( p_CONTEXT, FND_API.G_MISS_CHAR, CONTEXT, p_CONTEXT),
       OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
	Req_Header_Id = decode(p_Req_Header_Id,Fnd_API.G_MISS_NUM,Req_Header_Id,p_Req_Header_Id),
	Req_Line_Id = decode(p_Req_Line_Id,Fnd_API.G_MISS_NUM,Req_Line_Id,p_Req_Line_Id),
	Order_Header_Id = decode(p_Order_Header_Id,Fnd_API.G_MISS_NUM,Order_Header_Id,p_Order_Header_Id),
	Order_Line_Id = decode(p_Order_Line_Id,Fnd_API.G_MISS_NUM,Order_Line_Id,p_Order_Line_Id),
	Quantity_Received = decode(p_Prd_Txn_Qty_Received,Fnd_API.G_MISS_NUM,Quantity_Received,p_Prd_Txn_Qty_Received),
	Quantity_Shipped = decode(p_Prd_Txn_Qty_Shipped,Fnd_API.G_MISS_NUM,Quantity_Shipped,p_Prd_Txn_Qty_Shipped),
     Source_Serial_Number = decode(p_Source_Serial_Number,Fnd_API.G_MISS_CHAR,Source_Serial_Number,p_Source_Serial_Number)     ,
     Source_Instance_ID = decode(p_Source_Instance_ID,Fnd_API.G_MISS_NUM,Source_Instance_ID,p_Source_Instance_Id)     ,
     Non_Source_Serial_Number = decode(p_Non_Source_Serial_Number,Fnd_API.G_MISS_CHAR,Non_Source_Serial_Number,p_Non_Source_Serial_Number)     ,
     Non_Source_Instance_ID = decode(p_Non_Source_Instance_Id,Fnd_API.G_MISS_NUM,Non_Source_Instance_ID,p_Non_Source_Instance_ID)     ,
    Locator_id = decode(p_Locator_Id , Fnd_API.G_MISS_NUM,Locator_Id,p_Locator_Id),
    Sub_Inventory_rcvd = decode(p_Sub_Inventory_Rcvd,Fnd_API.G_MISS_CHAR,Sub_Inventory_Rcvd,p_Sub_Inventory_Rcvd),
    Lot_Number_Rcvd = decode(p_Lot_Number_Rcvd,Fnd_API.G_MISS_CHAR,Lot_Number_Rcvd,p_Lot_Number_rcvd),
    Picking_rule_id = decode(p_Picking_rule_id,Fnd_API.G_MISS_CHAR,Picking_rule_id,p_Picking_rule_id),
    PROJECT_ID = decode(P_PROJECT_ID,Fnd_API.G_MISS_NUM,PROJECT_ID,P_PROJECT_ID),
    TASK_ID = decode(P_TASK_ID,Fnd_API.G_MISS_NUM,TASK_ID,P_TASK_ID),
    UNIT_NUMBER = decode(P_UNIT_NUMBER,Fnd_API.G_MISS_CHAR,UNIT_NUMBER,P_UNIT_NUMBER),
     -- swai: bug 6148019
    INTERNAL_PO_HEADER_ID = decode(P_INTERNAL_PO_HEADER_ID,Fnd_API.G_MISS_NUM,INTERNAL_PO_HEADER_ID,P_INTERNAL_PO_HEADER_ID)
    where PRODUCT_TRANSACTION_ID = p_PRODUCT_TRANSACTION_ID
    And Object_Version_Number = p_Object_Version_Number;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PRODUCT_TRANSACTION_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSD_PRODUCT_TRANSACTIONS
    WHERE PRODUCT_TRANSACTION_ID = p_PRODUCT_TRANSACTION_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
        p_PRODUCT_TRANSACTION_ID    NUMBER,
        p_OBJECT_VERSION_NUMBER    NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM CSD_PRODUCT_TRANSACTIONS
        WHERE PRODUCT_TRANSACTION_ID =  p_PRODUCT_TRANSACTION_ID
        FOR UPDATE of PRODUCT_TRANSACTION_ID NOWAIT;
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

    IF l_debug > 0 THEN
        csd_gen_utility_pvt.add('CSD_PRODUCT_TRANSACTIONS_PKG Recinfo.OBJECT_VERSION_NUMBER : '||Recinfo.OBJECT_VERSION_NUMBER);
        csd_gen_utility_pvt.add('CSD_PRODUCT_TRANSACTIONS_PKG p_OBJECT_VERSION_NUMBER : '||p_OBJECT_VERSION_NUMBER);
    END IF;

    If ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) then
          return;
    else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;

End CSD_PRODUCT_TRANSACTIONS_PKG;

/

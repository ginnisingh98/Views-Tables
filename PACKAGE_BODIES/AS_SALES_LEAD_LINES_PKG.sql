--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_LINES_PKG" as
/* $Header: asxtsllb.pls 115.9 2004/04/14 20:39:39 chchandr ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_LINES_PKG
-- Purpose          : Sales lead lines table handlers
-- NOTE             :
-- History          : 04/09/2001 FFANG   Created
--
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_SALES_LEAD_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtsllb.pls';


AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Sales_Lead_Line_Insert_Row(
          px_SALES_LEAD_LINE_ID  IN OUT NOCOPY   NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_LEAD_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,

          -- 11.5.10 rivendell product category changes

          --p_INTEREST_TYPE_ID    NUMBER,
          --p_PRIMARY_INTEREST_CODE_ID    NUMBER,
          --p_SECONDARY_INTEREST_CODE_ID    NUMBER,

          p_CATEGORY_ID		NUMBER,
	  p_CATEGORY_SET_ID	NUMBER,

          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_BUDGET_AMOUNT    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
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
          p_OFFER_ID    NUMBER)
--        p_SECURITY_GROUP_ID  NUMBER)

 IS
   CURSOR C2 IS SELECT AS_SALES_LEAD_LINES_S.nextval FROM sys.dual;
BEGIN
   If (px_sales_lead_line_id IS NULL)
	  OR (px_SALES_LEAD_LINE_ID = FND_API.G_MISS_NUM)
   Then
       OPEN C2;
       FETCH C2 INTO px_sales_lead_line_id;
       CLOSE C2;
   End If;
   INSERT INTO AS_SALES_LEAD_LINES(
       SALES_LEAD_LINE_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       SALES_LEAD_ID,
       STATUS_CODE,
       INTEREST_TYPE_ID,
       PRIMARY_INTEREST_CODE_ID,
       SECONDARY_INTEREST_CODE_ID,
       CATEGORY_ID,
       CATEGORY_SET_ID,
       INVENTORY_ITEM_ID,
       ORGANIZATION_ID,
       UOM_CODE,
       QUANTITY,
       BUDGET_AMOUNT,
       SOURCE_PROMOTION_ID,
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
       ATTRIBUTE15,
       OFFER_ID)
--     SECURITY_GROUP_ID)
   VALUES (
       px_SALES_LEAD_LINE_ID,
       decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,TO_DATE(NULL),p_LAST_UPDATE_DATE),
       decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
       decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
       decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
       decode( p_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,NULL,p_LAST_UPDATE_LOGIN),
       decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
       decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,
               p_PROGRAM_APPLICATION_ID),
       decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
       decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),
               p_PROGRAM_UPDATE_DATE),
       decode( p_SALES_LEAD_ID, FND_API.G_MISS_NUM, NULL, p_SALES_LEAD_ID),

       decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE),

       -- 11.5.10 rivendell product category changes

       --decode( p_INTEREST_TYPE_ID, FND_API.G_MISS_NUM,NULL, p_INTEREST_TYPE_ID),
       --decode( p_PRIMARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL,
       --        p_PRIMARY_INTEREST_CODE_ID),
       --decode( p_SECONDARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL,
       --        p_SECONDARY_INTEREST_CODE_ID),
       NULL,
       NULL,
       NULL,

       decode(p_CATEGORY_ID, FND_API.G_MISS_NUM, NULL, p_CATEGORY_ID),
       decode(p_CATEGORY_SET_ID, FND_API.G_MISS_NUM, NULL, p_CATEGORY_SET_ID),


       decode( p_INVENTORY_ITEM_ID,FND_API.G_MISS_NUM,NULL,p_INVENTORY_ITEM_ID),
       decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
       decode( p_UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_UOM_CODE),
       decode( p_QUANTITY, FND_API.G_MISS_NUM, NULL, p_QUANTITY),
       decode( p_BUDGET_AMOUNT, FND_API.G_MISS_NUM, NULL, p_BUDGET_AMOUNT),
       decode( p_SOURCE_PROMOTION_ID, FND_API.G_MISS_NUM, NULL,
               p_SOURCE_PROMOTION_ID),
       decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
               p_ATTRIBUTE_CATEGORY),
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
       decode( p_OFFER_ID, FND_API.G_MISS_NUM, NULL, p_OFFER_ID));
--     decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL,
--             p_SECURITY_GROUP_ID));
End Sales_Lead_Line_Insert_Row;

PROCEDURE Sales_Lead_Line_Update_Row(
          p_SALES_LEAD_LINE_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_LEAD_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,

          -- 11.5.10 rivendell product category changes
--          p_INTEREST_TYPE_ID    NUMBER,
--          p_PRIMARY_INTEREST_CODE_ID    NUMBER,
--          p_SECONDARY_INTEREST_CODE_ID    NUMBER,

	  p_CATEGORY_ID		NUMBER,
	  p_CATEGORY_SET_ID	NUMBER,

          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_BUDGET_AMOUNT    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
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
          p_OFFER_ID    NUMBER)
--        p_SECURITY_GROUP_ID  NUMBER)

 IS
  /*l_obj_verno         number;

 cursor  c_obj_verno is
  select object_version_number
  from    AS_SALES_LEAD_LINES
  where  SALES_LEAD_LINE_ID =  p_SALES_LEAD_LINE_ID;
*/
BEGIN
    Update AS_SALES_LEAD_LINES
    SET
       SALES_LEAD_LINE_ID = decode( p_SALES_LEAD_LINE_ID, FND_API.G_MISS_NUM,
                                    SALES_LEAD_LINE_ID, p_SALES_LEAD_LINE_ID),
       LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,
                                  LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
       LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM,
                                 LAST_UPDATED_BY, p_LAST_UPDATED_BY),
       CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE,
                               CREATION_DATE, p_CREATION_DATE),
       CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY,
					   p_CREATED_BY),
       LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,
                                   LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
       REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID,
                            p_REQUEST_ID),
       PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID,
                                        FND_API.G_MISS_NUM,
                                        PROGRAM_APPLICATION_ID,
                                        p_PROGRAM_APPLICATION_ID),
       PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID,
                            p_PROGRAM_ID),
       PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,
                                     PROGRAM_UPDATE_DATE,p_PROGRAM_UPDATE_DATE),
       SALES_LEAD_ID = decode( p_SALES_LEAD_ID, FND_API.G_MISS_NUM,
                               SALES_LEAD_ID, p_SALES_LEAD_ID),
       STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE,
                             p_STATUS_CODE),

       -- 11.5.10 rivendell product category

       --INTEREST_TYPE_ID = decode( p_INTEREST_TYPE_ID, FND_API.G_MISS_NUM,
       --                           INTEREST_TYPE_ID, p_INTEREST_TYPE_ID),
       --PRIMARY_INTEREST_CODE_ID = decode( p_PRIMARY_INTEREST_CODE_ID,
       --                                   FND_API.G_MISS_NUM,
       --                                   PRIMARY_INTEREST_CODE_ID,
       --                                   p_PRIMARY_INTEREST_CODE_ID),
       --SECONDARY_INTEREST_CODE_ID = decode( p_SECONDARY_INTEREST_CODE_ID,
       --                                     FND_API.G_MISS_NUM,
       --                                     SECONDARY_INTEREST_CODE_ID,
       --                                     p_SECONDARY_INTEREST_CODE_ID),

       CATEGORY_ID = decode( p_CATEGORY_ID,
                                                   FND_API.G_MISS_NUM,
                                                   CATEGORY_ID,
                                                   p_CATEGORY_ID),

       CATEGORY_SET_ID = decode( p_CATEGORY_SET_ID,
                                               FND_API.G_MISS_NUM,
                                               CATEGORY_SET_ID,
                                               p_CATEGORY_SET_ID),


       INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM,
                                   INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
       ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM,
                                 ORGANIZATION_ID, p_ORGANIZATION_ID),
       UOM_CODE = decode( p_UOM_CODE, FND_API.G_MISS_CHAR, UOM_CODE,p_UOM_CODE),
       QUANTITY = decode( p_QUANTITY, FND_API.G_MISS_NUM, QUANTITY, p_QUANTITY),
       BUDGET_AMOUNT = decode( p_BUDGET_AMOUNT, FND_API.G_MISS_NUM,
                               BUDGET_AMOUNT, p_BUDGET_AMOUNT),
       SOURCE_PROMOTION_ID = decode( p_SOURCE_PROMOTION_ID, FND_API.G_MISS_NUM,
                                     SOURCE_PROMOTION_ID,
                                     p_SOURCE_PROMOTION_ID),
       ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,
                                    ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
       ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1,
                            p_ATTRIBUTE1),
       ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2,
                            p_ATTRIBUTE2),
       ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3,
                            p_ATTRIBUTE3),
       ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4,
                            p_ATTRIBUTE4),
       ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5,
                            p_ATTRIBUTE5),
       ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6,
                            p_ATTRIBUTE6),
       ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7,
                            p_ATTRIBUTE7),
       ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8,
                            p_ATTRIBUTE8),
       ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9,
                            p_ATTRIBUTE9),
       ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10,
                             p_ATTRIBUTE10),
       ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11,
                             p_ATTRIBUTE11),
       ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12,
                             p_ATTRIBUTE12),
       ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13,
                             p_ATTRIBUTE13),
       ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14,
                             p_ATTRIBUTE14),
       ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15,
                             p_ATTRIBUTE15),
       OFFER_ID = decode( p_OFFER_ID, FND_API.G_MISS_NUM, OFFER_ID, p_OFFER_ID),
       object_version_number = decode(object_version_number, null, 1, object_version_number+1)
--     SECURITY_GROUP_ID = decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM,
--                                 SECURITY_GROUP_ID, p_SECURITY_GROUP_ID)
    WHERE sales_lead_line_id = p_sales_lead_line_id;
/*
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;

   update as_sales_lead_lines
    set object_version_number = decode(l_obj_verno, null, 1, l_obj_verno+1)
    where sales_lead_line_id = p_sales_lead_line_id;
*/
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Sales_Lead_Line_Update_Row;


PROCEDURE Sales_Lead_Line_Delete_Row( p_sales_lead_line_id  NUMBER)
 IS
BEGIN
   DELETE FROM AS_SALES_LEAD_LINES
   WHERE sales_lead_line_id = p_sales_lead_line_id;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Sales_Lead_Line_Delete_Row;


PROCEDURE Sales_Lead_Line_Lock_Row(
          p_SALES_LEAD_LINE_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_SALES_LEAD_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,

          -- 11.5.10 rivendell product category changes

          --p_INTEREST_TYPE_ID    NUMBER,
          --p_PRIMARY_INTEREST_CODE_ID    NUMBER,
          --p_SECONDARY_INTEREST_CODE_ID    NUMBER,

          p_CATEGORY_ID NUMBER,
          p_CATEGORY_SET_ID NUMBER,

          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_UOM_CODE    VARCHAR2,
          p_QUANTITY    NUMBER,
          p_BUDGET_AMOUNT    NUMBER,
          p_SOURCE_PROMOTION_ID    NUMBER,
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
          p_OFFER_ID    NUMBER)
--        p_SECURITY_GROUP_ID  NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AS_SALES_LEAD_LINES
        WHERE sales_lead_line_id =  p_sales_lead_line_id
        FOR UPDATE of sales_lead_line_id NOWAIT;
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
           (      Recinfo.SALES_LEAD_LINE_ID = p_SALES_LEAD_LINE_ID)
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
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
       AND (    ( Recinfo.SALES_LEAD_ID = p_SALES_LEAD_ID)
            OR (    ( Recinfo.SALES_LEAD_ID IS NULL )
                AND (  p_SALES_LEAD_ID IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))

       -- 11.5.10 rivendell product category changes

       --AND (    ( Recinfo.INTEREST_TYPE_ID = p_INTEREST_TYPE_ID)
       --     OR (    ( Recinfo.INTEREST_TYPE_ID IS NULL )
       --         AND (  p_INTEREST_TYPE_ID IS NULL )))
       --AND (    ( Recinfo.PRIMARY_INTEREST_CODE_ID = p_PRIMARY_INTEREST_CODE_ID)
       --     OR (    ( Recinfo.PRIMARY_INTEREST_CODE_ID IS NULL )
       --         AND (  p_PRIMARY_INTEREST_CODE_ID IS NULL )))
       --AND (    ( Recinfo.SECONDARY_INTEREST_CODE_ID =
       --                            p_SECONDARY_INTEREST_CODE_ID)
       --     OR (    ( Recinfo.SECONDARY_INTEREST_CODE_ID IS NULL )
       --                AND (  p_SECONDARY_INTEREST_CODE_ID IS NULL )))



       AND (    ( Recinfo.CATEGORY_ID = p_CATEGORY_ID)
                   OR (    ( Recinfo.CATEGORY_ID IS NULL )
                       AND (  p_CATEGORY_ID IS NULL )))
       AND (    ( Recinfo.CATEGORY_SET_ID =
                                          p_CATEGORY_SET_ID)
                   OR (    ( Recinfo.CATEGORY_SET_ID IS NULL )
                   AND (  p_CATEGORY_SET_ID IS NULL )))



       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.UOM_CODE = p_UOM_CODE)
            OR (    ( Recinfo.UOM_CODE IS NULL )
                AND (  p_UOM_CODE IS NULL )))
       AND (    ( Recinfo.QUANTITY = p_QUANTITY)
            OR (    ( Recinfo.QUANTITY IS NULL )
                AND (  p_QUANTITY IS NULL )))
       AND (    ( Recinfo.BUDGET_AMOUNT = p_BUDGET_AMOUNT)
            OR (    ( Recinfo.BUDGET_AMOUNT IS NULL )
                AND (  p_BUDGET_AMOUNT IS NULL )))
       AND (    ( Recinfo.SOURCE_PROMOTION_ID = p_SOURCE_PROMOTION_ID)
            OR (    ( Recinfo.SOURCE_PROMOTION_ID IS NULL )
                AND (  p_SOURCE_PROMOTION_ID IS NULL )))
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
       AND (    ( Recinfo.OFFER_ID = p_OFFER_ID)
            OR (    ( Recinfo.OFFER_ID IS NULL )
                AND (  p_OFFER_ID IS NULL )))
--     AND (    ( Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
--          OR (    ( Recinfo.SECURITY_GROUP_ID IS NULL )
--              AND (  p_SECURITY_GROUP_ID IS NULL )))
   ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Sales_Lead_Line_Lock_Row;


End AS_SALES_LEAD_LINES_PKG;

/

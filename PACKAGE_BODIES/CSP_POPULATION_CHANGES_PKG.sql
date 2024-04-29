--------------------------------------------------------
--  DDL for Package Body CSP_POPULATION_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_POPULATION_CHANGES_PKG" as
/* $Header: csptppcb.pls 120.2 2005/12/16 10:36:39 phegde noship $ */
-- Start of Comments
-- Package name     : CSP_POPULATION_CHANGES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_POPULATION_CHANGES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptppcb.pls';

PROCEDURE Insert_Row(
          px_POPULATION_CHANGES_ID  IN OUT NOCOPY NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          --p_INVENTORY_ITEM_ID       NUMBER,
          p_START_DATE              DATE,
          p_END_DATE                DATE,
          p_POPULATION_CHANGE       NUMBER,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_PRODUCT_ID              NUMBER )

 IS
   CURSOR C2 IS SELECT CSP_POPULATION_CHANGES_S1.nextval FROM sys.dual;
BEGIN
   If (px_POPULATION_CHANGES_ID IS NULL) OR (px_POPULATION_CHANGES_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_POPULATION_CHANGES_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_POPULATION_CHANGES(
           POPULATION_CHANGES_ID,
           ORGANIZATION_ID,
           --INVENTORY_ITEM_ID,
           START_DATE,
           END_DATE,
           POPULATION_CHANGE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           PRODUCT_ID
          ) VALUES (
           px_POPULATION_CHANGES_ID,
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           --decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode(p_START_DATE, fnd_api.g_miss_date,to_date(null),p_START_DATE),
           decode(p_END_DATE, fnd_api.g_miss_date,to_date(null),p_end_date),
           decode( p_POPULATION_CHANGE, FND_API.G_MISS_NUM, NULL, p_POPULATION_CHANGE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode(p_CREATION_DATE, fnd_api.g_miss_date,to_date(null),p_creation_date),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode(p_LAST_UPDATE_DATE, fnd_api.g_miss_date,to_date(null),p_last_update_date),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_PRODUCT_ID, FND_API.G_MISS_NUM, NULL, p_PRODUCT_ID));
End Insert_Row;

PROCEDURE Update_Row(
          p_POPULATION_CHANGES_ID   NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          --p_INVENTORY_ITEM_ID       NUMBER,
          p_START_DATE              DATE,
          p_END_DATE                DATE,
          p_POPULATION_CHANGE       NUMBER,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_PRODUCT_ID              NUMBER )

 IS
 BEGIN
    Update CSP_POPULATION_CHANGES
    SET
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              --INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              START_DATE = decode(p_START_DATE, fnd_api.g_miss_date,start_date,p_start_date),
              END_DATE = decode(p_END_DATE, fnd_api.g_miss_date,end_date,p_end_date),
              POPULATION_CHANGE = decode( p_POPULATION_CHANGE, FND_API.G_MISS_NUM, POPULATION_CHANGE, p_POPULATION_CHANGE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_CREATION_DATE, fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              PRODUCT_ID = decode( p_PRODUCT_ID, FND_API.G_MISS_NUM, PRODUCT_ID, p_PRODUCT_ID)
    where POPULATION_CHANGES_ID = p_POPULATION_CHANGES_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_POPULATION_CHANGES_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_POPULATION_CHANGES
    WHERE POPULATION_CHANGES_ID = p_POPULATION_CHANGES_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_POPULATION_CHANGES_ID   NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          --p_INVENTORY_ITEM_ID       NUMBER,
          p_START_DATE              DATE,
          p_END_DATE                DATE,
          p_POPULATION_CHANGE       NUMBER,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_PRODUCT_ID              NUMBER )

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_POPULATION_CHANGES
        WHERE POPULATION_CHANGES_ID =  p_POPULATION_CHANGES_ID
        FOR UPDATE of POPULATION_CHANGES_ID NOWAIT;
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
           (      Recinfo.POPULATION_CHANGES_ID = p_POPULATION_CHANGES_ID)
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
   /*    AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL ))) */
       AND (    ( Recinfo.START_DATE = p_START_DATE)
            OR (    ( Recinfo.START_DATE IS NULL )
                AND (  p_START_DATE IS NULL )))
       AND (    ( Recinfo.END_DATE = p_END_DATE)
            OR (    ( Recinfo.END_DATE IS NULL )
                AND (  p_END_DATE IS NULL )))
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
       AND (    ( Recinfo.POPULATION_CHANGE = p_POPULATION_CHANGE)
            OR (    ( Recinfo.POPULATION_CHANGE IS NULL )
                AND (  p_POPULATION_CHANGE IS NULL )))
       AND (    ( Recinfo.PRODUCT_ID = p_PRODUCT_ID)
            OR (    ( Recinfo.PRODUCT_ID IS NULL )
                AND (  p_PRODUCT_ID IS NULL )))
      ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_POPULATION_CHANGES_PKG;

/

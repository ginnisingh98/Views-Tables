--------------------------------------------------------
--  DDL for Package Body CSP_USG_TRANSACTION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_USG_TRANSACTION_TYPES_PKG" as
/* $Header: csptuttb.pls 115.1 2003/10/03 19:03:28 sunarasi noship $ */
-- Start of Comments
-- Package name     : CSP_USG_TRANSACTION_TYPES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_USG_TRANSACTION_TYPES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptbrub.pls';

PROCEDURE Insert_Row(
          px_USG_TRANSACTION_TYPE_ID IN OUT NOCOPY NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
	 ,p_FORECAST_RULE_ID NUMBER
	 ,p_TRANSACTION_TYPE_ID NUMBER)
 IS
   CURSOR C2 IS SELECT CSP_USG_TRANSACTION_TYPES_S1.nextval FROM sys.dual;
BEGIN
   If px_USG_TRANSACTION_TYPE_ID IS NULL Then
       OPEN C2;
       FETCH C2 INTO px_USG_TRANSACTION_TYPE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_USG_TRANSACTION_TYPES(
           USG_TRANSACTION_TYPE_ID
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
	  ,FORECAST_RULE_ID
	  ,TRANSACTION_TYPE_ID
          ) VALUES (
           px_USG_TRANSACTION_TYPE_ID
          ,p_LAST_UPDATE_DATE
          ,p_LAST_UPDATED_BY
          ,p_CREATION_DATE
          ,p_CREATED_BY
          ,p_LAST_UPDATE_LOGIN
	  ,p_FORECAST_RULE_ID
	  ,p_TRANSACTION_TYPE_ID);
END Insert_Row;

Procedure Update_Row(
	  p_USG_TRANSACTION_TYPE_ID NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
	 ,p_FORECAST_RULE_ID NUMBER
	 ,p_TRANSACTION_TYPE_ID NUMBER)
IS
BEGIN
    Update CSP_USG_TRANSACTION_TYPES
    SET
        LAST_UPDATE_DATE = p_LAST_UPDATE_DATE
       ,LAST_UPDATED_BY = p_LAST_UPDATED_BY
       ,CREATION_DATE = p_CREATION_DATE
       ,CREATED_BY =  p_CREATED_BY
       ,LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
       ,FORECAST_RULE_ID = p_FORECAST_RULE_ID
       ,TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID
    where USG_TRANSACTION_TYPE_ID = p_USG_TRANSACTION_TYPE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_USG_TRANSACTION_TYPE_ID  NUMBER)
IS
BEGIN
    DELETE FROM CSP_USG_TRANSACTION_TYPES
    WHERE USG_TRANSACTION_TYPE_ID = p_USG_TRANSACTION_TYPE_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

Procedure Lock_Row(
	  p_USG_TRANSACTION_TYPE_ID NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
	 ,p_FORECAST_RULE_ID NUMBER
	 ,p_TRANSACTION_TYPE_ID NUMBER)
IS
   CURSOR C IS
       SELECT *
       FROM CSP_USG_TRANSACTION_TYPES
       WHERE USG_TRANSACTION_TYPE_ID =  p_USG_TRANSACTION_TYPE_ID
       FOR UPDATE of USG_TRANSACTION_TYPE_ID NOWAIT;
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
           (      Recinfo.USG_TRANSACTION_TYPE_ID = p_USG_TRANSACTION_TYPE_ID)
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
       AND (    ( Recinfo.FORECAST_RULE_ID = p_FORECAST_RULE_ID)
            OR (    ( Recinfo.FORECAST_RULE_ID IS NULL )
                AND (  p_FORECAST_RULE_ID IS NULL )))
       AND (    ( Recinfo.TRANSACTION_TYPE_ID = p_TRANSACTION_TYPE_ID)
            OR (    ( Recinfo.TRANSACTION_TYPE_ID IS NULL )
                AND (  p_TRANSACTION_TYPE_ID IS NULL )))
        ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;

End CSP_USG_TRANSACTION_TYPES_PKG;

/

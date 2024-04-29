--------------------------------------------------------
--  DDL for Package Body AMS_DM_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_SOURCE_PKG" as
/* $Header: amstdsrb.pls 115.9 2003/09/03 19:26:46 nyostos ship $ */
-- Start of Comments
-- Package name     : AMS_DM_SOURCE_PKG
-- Purpose          :
-- History          :
-- 26-Jan-2001 choang   Removed object ver num increment and update criteria.
-- 30-jan-2001 choang   Changed p_tree_node to p_rule_id.
-- 07-Jan-2002 choang   Removed security group id
-- 28-Jul-2003 nyostos  Added PERCENTILE column.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DM_SOURCE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdsrb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_SOURCE_ID        IN OUT NOCOPY NUMBER,
          p_LAST_UPDATE_DATE  DATE,
          p_LAST_UPDATED_BY   NUMBER,
          p_CREATION_DATE     DATE,
          p_CREATED_BY        NUMBER,
          p_LAST_UPDATE_LOGIN NUMBER,
          px_OBJECT_VERSION_NUMBER  IN OUT NOCOPY NUMBER,
          p_MODEL_TYPE        VARCHAR2,
          p_ARC_USED_FOR_OBJECT     VARCHAR2,
          p_USED_FOR_OBJECT_ID      NUMBER,
          p_PARTY_ID          NUMBER,
          p_SCORE_RESULT      VARCHAR2,
          p_TARGET_VALUE      VARCHAR2,
          p_CONFIDENCE        NUMBER,
          p_CONTINUOUS_SCORE     NUMBER,
          p_decile               NUMBER,
          p_PERCENTILE           NUMBER)
 IS
   X_ROWID    VARCHAR2(30);

   CURSOR C IS SELECT rowid FROM AMS_DM_SOURCE
            WHERE SOURCE_ID = px_SOURCE_ID;

BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_DM_SOURCE(
           SOURCE_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           MODEL_TYPE,
           ARC_USED_FOR_OBJECT,
           USED_FOR_OBJECT_ID,
           PARTY_ID,
           SCORE_RESULT,
           TARGET_VALUE,
           CONFIDENCE,
           CONTINUOUS_SCORE,
           decile,
           PERCENTILE
   ) VALUES (
           decode( px_SOURCE_ID, FND_API.g_miss_num, NULL, px_SOURCE_ID),
           decode( p_LAST_UPDATE_DATE, FND_API.g_miss_date, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.g_miss_num, NULL, p_LAST_UPDATED_BY),
           decode( p_CREATION_DATE, FND_API.g_miss_date, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.g_miss_num, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_LOGIN, FND_API.g_miss_num, NULL, p_LAST_UPDATE_LOGIN),
           decode( px_OBJECT_VERSION_NUMBER, FND_API.g_miss_num, NULL, px_OBJECT_VERSION_NUMBER),
           decode( p_MODEL_TYPE, FND_API.g_miss_char, NULL, p_MODEL_TYPE),
           decode( p_ARC_USED_FOR_OBJECT, FND_API.g_miss_char, NULL, p_ARC_USED_FOR_OBJECT),
           decode( p_USED_FOR_OBJECT_ID, FND_API.g_miss_num, NULL, p_USED_FOR_OBJECT_ID),
           decode( p_PARTY_ID, FND_API.g_miss_num, NULL, p_PARTY_ID),
           decode( p_SCORE_RESULT, FND_API.g_miss_char, NULL, p_SCORE_RESULT),
           decode( p_TARGET_VALUE, FND_API.g_miss_char, NULL, p_TARGET_VALUE),
           decode( p_CONFIDENCE, FND_API.g_miss_num, NULL, p_CONFIDENCE),
           decode( p_CONTINUOUS_SCORE, FND_API.g_miss_num, NULL, p_CONTINUOUS_SCORE),
           decode( p_decile, FND_API.g_miss_char, NULL, p_decile),
           decode( p_PERCENTILE, FND_API.g_miss_char, NULL, p_PERCENTILE));
   OPEN C;
   FETCH C INTO x_rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;

PROCEDURE Update_Row(
          p_SOURCE_ID            NUMBER,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER   NUMBER,
          p_MODEL_TYPE           VARCHAR2,
          p_ARC_USED_FOR_OBJECT  VARCHAR2,
          p_USED_FOR_OBJECT_ID   NUMBER,
          p_PARTY_ID             NUMBER,
          p_SCORE_RESULT         VARCHAR2,
          p_TARGET_VALUE         VARCHAR2,
          p_CONFIDENCE           NUMBER,
          p_CONTINUOUS_SCORE     NUMBER,
          p_decile               NUMBER,
          p_PERCENTILE           NUMBER)
 IS
 BEGIN
    Update AMS_DM_SOURCE
    SET
              SOURCE_ID = decode( p_SOURCE_ID, FND_API.g_miss_num, SOURCE_ID, p_SOURCE_ID),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.g_miss_date, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.g_miss_num, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.g_miss_num, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.g_miss_num, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              MODEL_TYPE = decode( p_MODEL_TYPE, FND_API.g_miss_char, MODEL_TYPE, p_MODEL_TYPE),
              ARC_USED_FOR_OBJECT = decode( p_ARC_USED_FOR_OBJECT, FND_API.g_miss_char, ARC_USED_FOR_OBJECT, p_ARC_USED_FOR_OBJECT),
              USED_FOR_OBJECT_ID = decode( p_USED_FOR_OBJECT_ID, FND_API.g_miss_num, USED_FOR_OBJECT_ID, p_USED_FOR_OBJECT_ID),
              PARTY_ID = decode( p_PARTY_ID, FND_API.g_miss_num, PARTY_ID, p_PARTY_ID),
              SCORE_RESULT = decode( p_SCORE_RESULT, FND_API.g_miss_char, SCORE_RESULT, p_SCORE_RESULT),
              TARGET_VALUE = decode( p_TARGET_VALUE, FND_API.g_miss_char, TARGET_VALUE, p_TARGET_VALUE),
              CONFIDENCE = decode( p_CONFIDENCE, FND_API.g_miss_num, CONFIDENCE, p_CONFIDENCE),
              CONTINUOUS_SCORE = decode( p_CONTINUOUS_SCORE, FND_API.g_miss_num, CONTINUOUS_SCORE, p_CONTINUOUS_SCORE),
              decile = decode( p_decile, FND_API.g_miss_char, decile, p_decile),
              PERCENTILE = decode( p_PERCENTILE, FND_API.g_miss_char, PERCENTILE, p_PERCENTILE)
   WHERE SOURCE_ID = p_SOURCE_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_SOURCE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DM_SOURCE
    WHERE SOURCE_ID = p_SOURCE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_SOURCE_ID            NUMBER,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_CREATION_DATE        DATE,
          p_CREATED_BY           NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER   NUMBER,
          p_MODEL_TYPE           VARCHAR2,
          p_ARC_USED_FOR_OBJECT  VARCHAR2,
          p_USED_FOR_OBJECT_ID   NUMBER,
          p_PARTY_ID             NUMBER,
          p_SCORE_RESULT         VARCHAR2,
          p_TARGET_VALUE         VARCHAR2,
          p_CONFIDENCE           NUMBER,
          p_CONTINUOUS_SCORE     NUMBER,
          p_decile               NUMBER,
          p_PERCENTILE           NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM AMS_DM_SOURCE
        WHERE SOURCE_ID =  p_SOURCE_ID
        FOR UPDATE of SOURCE_ID NOWAIT;
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
           (      Recinfo.SOURCE_ID = p_SOURCE_ID)
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
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.MODEL_TYPE = p_MODEL_TYPE)
            OR (    ( Recinfo.MODEL_TYPE IS NULL )
                AND (  p_MODEL_TYPE IS NULL )))
       AND (    ( Recinfo.ARC_USED_FOR_OBJECT = p_ARC_USED_FOR_OBJECT)
            OR (    ( Recinfo.ARC_USED_FOR_OBJECT IS NULL )
                AND (  p_ARC_USED_FOR_OBJECT IS NULL )))
       AND (    ( Recinfo.USED_FOR_OBJECT_ID = p_USED_FOR_OBJECT_ID)
            OR (    ( Recinfo.USED_FOR_OBJECT_ID IS NULL )
                AND (  p_USED_FOR_OBJECT_ID IS NULL )))
       AND (    ( Recinfo.PARTY_ID = p_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID IS NULL )
                AND (  p_PARTY_ID IS NULL )))
       AND (    ( Recinfo.SCORE_RESULT = p_SCORE_RESULT)
            OR (    ( Recinfo.SCORE_RESULT IS NULL )
                AND (  p_SCORE_RESULT IS NULL )))
       AND (    ( Recinfo.TARGET_VALUE = p_TARGET_VALUE)
            OR (    ( Recinfo.TARGET_VALUE IS NULL )
                AND (  p_TARGET_VALUE IS NULL )))
       AND (    ( Recinfo.CONFIDENCE = p_CONFIDENCE)
            OR (    ( Recinfo.CONFIDENCE IS NULL )
                AND (  p_CONFIDENCE IS NULL )))
       AND (    ( Recinfo.CONTINUOUS_SCORE = p_CONTINUOUS_SCORE)
            OR (    ( Recinfo.CONTINUOUS_SCORE IS NULL )
                AND (  p_CONTINUOUS_SCORE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End AMS_DM_SOURCE_PKG;

/

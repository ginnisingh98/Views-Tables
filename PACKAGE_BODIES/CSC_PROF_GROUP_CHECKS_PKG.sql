--------------------------------------------------------
--  DDL for Package Body CSC_PROF_GROUP_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_GROUP_CHECKS_PKG" as
/* $Header: csctpgcb.pls 120.1 2005/08/03 22:58:08 mmadhavi noship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CHECKS_PKG
-- Purpose          :
-- History          :
-- 07 Nov 02   jamose Upgrade table handler changes
-- 27 Nov 02   jamose For Fnd_Api_G_Miss* and NOCOPY changes
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_GROUP_CHECKS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctugcb.pls';

G_MISS_CHAR VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_NUM NUMBER := FND_API.G_MISS_NUM;
G_MISS_DATE DATE := FND_API.G_MISS_DATE;

PROCEDURE Insert_Row(
          p_GROUP_ID    NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_SEQUENCE  NUMBER,
          p_END_DATE_ACTIVE    DATE,
          p_START_DATE_ACTIVE    DATE,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_THRESHOLD_FLAG    VARCHAR2,
	  p_CRITICAL_FLAG     VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
   CURSOR C2 IS SELECT MAX(nvl(check_sequence,0)) + 1
		    FROM CSC_PROF_GROUP_CHECKS
		    WHERE check_id = p_CHECK_ID;
   l_check_Sequence Number;
   ps_SEEDED_FLAG    Varchar2(3);

BEGIN

   /* Added This If Condition for Bug 1944040*/
      If p_Created_by=1 then
           ps_seeded_flag:='Y';
      Else
           ps_seeded_flag:=p_seeded_flag;
      End If;

-- If (p_GROUP_ID IS NULL) OR (p_GROUP_ID = CSC_CORE_UTILS_PVT.G_MISS_NUM) then
  --     OPEN C2;
  --     FETCH C2 INTO px_check_sequence;
  --     CLOSE C2;
  -- End If;
   INSERT INTO CSC_PROF_GROUP_CHECKS(
           GROUP_ID,
           CHECK_ID,
           CHECK_SEQUENCE,
           END_DATE_ACTIVE,
           START_DATE_ACTIVE,
           CATEGORY_CODE,
           CATEGORY_SEQUENCE,
           THRESHOLD_FLAG,
	   CRITICAL_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG
          ) VALUES (
           p_GROUP_ID,
           decode( p_CHECK_ID, G_MISS_NUM, NULL, p_CHECK_ID),
           decode(p_CHECK_SEQUENCE,G_MISS_NUM,NULL,P_CHECK_SEQUENCE),
           decode( p_END_DATE_ACTIVE, G_MISS_DATE, NULL, p_END_DATE_ACTIVE),
           decode( p_START_DATE_ACTIVE, G_MISS_DATE, NULL, p_START_DATE_ACTIVE),
           decode( p_CATEGORY_CODE, G_MISS_CHAR, NULL, p_CATEGORY_CODE),
           decode( p_CATEGORY_SEQUENCE,G_MISS_NUM, NULL, p_CATEGORY_SEQUENCE),
           decode( p_THRESHOLD_FLAG, G_MISS_CHAR, NULL, p_THRESHOLD_FLAG),
	   decode( p_CRITICAL_FLAG, G_MISS_CHAR, NULL, p_CRITICAL_FLAG),
           decode( p_CREATED_BY, G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE,G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE,G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN,G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_SEEDED_FLAG, G_MISS_CHAR, NULL, ps_SEEDED_FLAG) );
End Insert_Row;

PROCEDURE Update_Row(
          p_GROUP_ID    NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_SEQUENCE    NUMBER,
          p_END_DATE_ACTIVE    DATE,
          p_START_DATE_ACTIVE    DATE,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_THRESHOLD_FLAG    VARCHAR2,
	  p_CRITICAL_FLAG     VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
 BEGIN
    Update CSC_PROF_GROUP_CHECKS
    SET
              CHECK_SEQUENCE = p_CHECK_SEQUENCE,
              END_DATE_ACTIVE = p_END_DATE_ACTIVE,
              START_DATE_ACTIVE = p_START_DATE_ACTIVE,
              CATEGORY_CODE = p_CATEGORY_CODE,
              CATEGORY_SEQUENCE = p_CATEGORY_SEQUENCE,
              THRESHOLD_FLAG = p_THRESHOLD_FLAG,
	      CRITICAL_FLAG = p_CRITICAL_FLAG,
              SEEDED_FLAG = p_SEEDED_FLAG,
              LAST_UPDATED_BY = p_LAST_UPDATED_BY,
              LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
    where GROUP_ID = p_GROUP_ID
    and check_id = p_check_id;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;


PROCEDURE Lock_Row(
          p_GROUP_ID    NUMBER,
          p_CHECK_ID    NUMBER,
          p_CHECK_SEQUENCE    NUMBER,
          p_END_DATE_ACTIVE    DATE,
          p_START_DATE_ACTIVE    DATE,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_THRESHOLD_FLAG    VARCHAR2,
	  p_CRITICAL_FLAG    VARCHAR2,
          p_SEEDED_FLAG       VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSC_PROF_GROUP_CHECKS
        WHERE GROUP_ID =  p_GROUP_ID
	   AND CHECK_ID = P_CHECK_ID
        FOR UPDATE of GROUP_ID NOWAIT;
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
           (      Recinfo.GROUP_ID = p_GROUP_ID)
       AND (    ( Recinfo.CHECK_ID = p_CHECK_ID)
            OR (    ( Recinfo.CHECK_ID IS NULL )
                AND (  p_CHECK_ID IS NULL )))
       AND (    ( Recinfo.CHECK_SEQUENCE = p_CHECK_SEQUENCE)
            OR (    ( Recinfo.CHECK_SEQUENCE IS NULL )
                AND (  p_CHECK_SEQUENCE IS NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = p_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE IS NULL )
                AND (  p_END_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = p_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE IS NULL )
                AND (  p_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.CATEGORY_CODE = p_CATEGORY_CODE)
            OR (    ( Recinfo.CATEGORY_CODE IS NULL )
                AND (  p_CATEGORY_CODE IS NULL )))
       AND (    ( Recinfo.CATEGORY_SEQUENCE = p_CATEGORY_SEQUENCE)
            OR (    ( Recinfo.CATEGORY_SEQUENCE IS NULL )
                AND (  p_CATEGORY_SEQUENCE IS NULL )))
       AND (    ( Recinfo.THRESHOLD_FLAG = p_THRESHOLD_FLAG)
            OR (    ( Recinfo.THRESHOLD_FLAG IS NULL )
                AND (  p_THRESHOLD_FLAG IS NULL )))
       AND (    ( Recinfo.CRITICAL_FLAG = p_CRITICAL_FLAG)
            OR (    ( Recinfo.CRITICAL_FLAG IS NULL )
                AND (  p_CRITICAL_FLAG IS NULL )))
       AND (    ( Recinfo.SEEDED_FLAG = p_SEEDED_FLAG)
            OR (    ( Recinfo.SEEDED_FLAG IS NULL )
                AND (  p_SEEDED_FLAG IS NULL )))
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
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;


PROCEDURE Delete_Row(
    p_GROUP_ID  NUMBER,
    p_CHECK_ID  NUMBER,
    p_CHECK_SEQUENCE  NUMBER)
 IS
 BEGIN
   DELETE FROM CSC_PROF_GROUP_CHECKS
    WHERE GROUP_ID = p_GROUP_ID
     AND CHECK_ID = p_CHECK_ID
     AND CHECK_SEQUENCE = p_CHECK_SEQUENCE;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


End CSC_PROF_GROUP_CHECKS_PKG;

/

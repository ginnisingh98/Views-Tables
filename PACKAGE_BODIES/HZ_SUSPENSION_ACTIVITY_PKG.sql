--------------------------------------------------------
--  DDL for Package Body HZ_SUSPENSION_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_SUSPENSION_ACTIVITY_PKG" as
/* $Header: ARHSATTB.pls 120.2 2005/10/30 03:54:56 appldev ship $*/
-- Start of Comments
-- Package name     : HZ_SUSPENSION_ACTIVITY_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



PROCEDURE Insert_Row(
          p_SUSPENSION_ACTIVITY_ID   NUMBER,
          p_ACTION_EFFECTIVE_ON_DATE    DATE,
          p_ACTION_REASON    VARCHAR2,
          p_ACTION_TYPE    VARCHAR2,
          p_SITE_USE_ID    NUMBER,
          p_CUST_ACCOUNT_ID    NUMBER,
          p_NOTICE_METHOD    VARCHAR2,
          p_NOTICE_RECEIVED_CONFIRMATION    VARCHAR2,
          p_NOTICE_SENT_DATE    DATE,
          p_NOTICE_TYPE    VARCHAR2,
          p_BEGIN_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_WH_UPDATE_DATE    DATE)

 IS
BEGIN
   INSERT INTO HZ_SUSPENSION_ACTIVITY(
           SUSPENSION_ACTIVITY_ID,
           ACTION_EFFECTIVE_ON_DATE,
           ACTION_REASON,
           ACTION_TYPE,
           SITE_USE_ID,
           CUST_ACCOUNT_ID,
           NOTICE_METHOD,
           NOTICE_RECEIVED_CONFIRMATION,
           NOTICE_SENT_DATE,
           NOTICE_TYPE,
           BEGIN_DATE,
           END_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           WH_UPDATE_DATE
          ) VALUES (
           p_SUSPENSION_ACTIVITY_ID,
           decode( p_ACTION_EFFECTIVE_ON_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTION_EFFECTIVE_ON_DATE),
           decode( p_ACTION_REASON, FND_API.G_MISS_CHAR, NULL, p_ACTION_REASON),
           decode( p_ACTION_TYPE, FND_API.G_MISS_CHAR, NULL, p_ACTION_TYPE),
           decode( p_SITE_USE_ID, FND_API.G_MISS_NUM, NULL, p_SITE_USE_ID),
           decode( p_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, p_CUST_ACCOUNT_ID),
           decode( p_NOTICE_METHOD, FND_API.G_MISS_CHAR, NULL, p_NOTICE_METHOD),
           decode( p_NOTICE_RECEIVED_CONFIRMATION, FND_API.G_MISS_CHAR, 'N', NULL, 'N', p_NOTICE_RECEIVED_CONFIRMATION),
           decode( p_NOTICE_SENT_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_NOTICE_SENT_DATE),
           decode( p_NOTICE_TYPE, FND_API.G_MISS_CHAR, NULL, p_NOTICE_TYPE),
           decode( p_BEGIN_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_BEGIN_DATE),
           decode( p_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE),
           decode( p_WH_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_WH_UPDATE_DATE));
End Insert_Row;

PROCEDURE Update_Row(
          p_SUSPENSION_ACTIVITY_ID    NUMBER,
          p_ACTION_EFFECTIVE_ON_DATE    DATE,
          p_ACTION_REASON    VARCHAR2,
          p_ACTION_TYPE    VARCHAR2,
          p_SITE_USE_ID    NUMBER,
          p_CUST_ACCOUNT_ID    NUMBER,
          p_NOTICE_METHOD    VARCHAR2,
          p_NOTICE_RECEIVED_CONFIRMATION    VARCHAR2,
          p_NOTICE_SENT_DATE    DATE,
          p_NOTICE_TYPE    VARCHAR2,
          p_BEGIN_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_WH_UPDATE_DATE    DATE)

 IS
 BEGIN
    Update HZ_SUSPENSION_ACTIVITY
    SET
              ACTION_EFFECTIVE_ON_DATE = decode( p_ACTION_EFFECTIVE_ON_DATE, FND_API.G_MISS_DATE, ACTION_EFFECTIVE_ON_DATE, p_ACTION_EFFECTIVE_ON_DATE),
              ACTION_REASON = decode( p_ACTION_REASON, FND_API.G_MISS_CHAR, ACTION_REASON, p_ACTION_REASON),
              ACTION_TYPE = decode( p_ACTION_TYPE, FND_API.G_MISS_CHAR, ACTION_TYPE, p_ACTION_TYPE),
              SITE_USE_ID = decode( p_SITE_USE_ID, FND_API.G_MISS_NUM, SITE_USE_ID, p_SITE_USE_ID),
              CUST_ACCOUNT_ID = decode( p_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, CUST_ACCOUNT_ID, p_CUST_ACCOUNT_ID),
              NOTICE_METHOD = decode( p_NOTICE_METHOD, FND_API.G_MISS_CHAR, NOTICE_METHOD, p_NOTICE_METHOD),
              NOTICE_RECEIVED_CONFIRMATION = decode( p_NOTICE_RECEIVED_CONFIRMATION, FND_API.G_MISS_CHAR, NOTICE_RECEIVED_CONFIRMATION, p_NOTICE_RECEIVED_CONFIRMATION),
              NOTICE_SENT_DATE = decode( p_NOTICE_SENT_DATE, FND_API.G_MISS_DATE, NOTICE_SENT_DATE, p_NOTICE_SENT_DATE),
              NOTICE_TYPE = decode( p_NOTICE_TYPE, FND_API.G_MISS_CHAR, NOTICE_TYPE, p_NOTICE_TYPE),
              BEGIN_DATE = decode( p_BEGIN_DATE, FND_API.G_MISS_DATE, BEGIN_DATE, p_BEGIN_DATE),
              END_DATE = decode( p_END_DATE, FND_API.G_MISS_DATE, END_DATE, p_END_DATE),
              -- Bug 3032780
              /*
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              */
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              WH_UPDATE_DATE = decode( p_WH_UPDATE_DATE, FND_API.G_MISS_DATE, WH_UPDATE_DATE, p_WH_UPDATE_DATE)
    where SUSPENSION_ACTIVITY_ID = p_SUSPENSION_ACTIVITY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_SUSPENSION_ACTIVITY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM HZ_SUSPENSION_ACTIVITY
    WHERE SUSPENSION_ACTIVITY_ID = p_SUSPENSION_ACTIVITY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_SUSPENSION_ACTIVITY_ID    NUMBER,
          p_ACTION_EFFECTIVE_ON_DATE    DATE,
          p_ACTION_REASON    VARCHAR2,
          p_ACTION_TYPE    VARCHAR2,
          p_SITE_USE_ID    NUMBER,
          p_CUST_ACCOUNT_ID    NUMBER,
          p_NOTICE_METHOD    VARCHAR2,
          p_NOTICE_RECEIVED_CONFIRMATION    VARCHAR2,
          p_NOTICE_SENT_DATE    DATE,
          p_NOTICE_TYPE    VARCHAR2,
          p_BEGIN_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_WH_UPDATE_DATE    DATE)

 IS
   CURSOR C IS
        SELECT *
         FROM HZ_SUSPENSION_ACTIVITY
        WHERE SUSPENSION_ACTIVITY_ID =  p_SUSPENSION_ACTIVITY_ID
        FOR UPDATE of SUSPENSION_ACTIVITY_ID NOWAIT;
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
           (      Recinfo.SUSPENSION_ACTIVITY_ID = p_SUSPENSION_ACTIVITY_ID)
       AND (    ( Recinfo.ACTION_EFFECTIVE_ON_DATE = p_ACTION_EFFECTIVE_ON_DATE)
            OR (    ( Recinfo.ACTION_EFFECTIVE_ON_DATE IS NULL )
                AND (  p_ACTION_EFFECTIVE_ON_DATE IS NULL )))
       AND (    ( Recinfo.ACTION_REASON = p_ACTION_REASON)
            OR (    ( Recinfo.ACTION_REASON IS NULL )
                AND (  p_ACTION_REASON IS NULL )))
       AND (    ( Recinfo.ACTION_TYPE = p_ACTION_TYPE)
            OR (    ( Recinfo.ACTION_TYPE IS NULL )
                AND (  p_ACTION_TYPE IS NULL )))
       AND (    ( Recinfo.SITE_USE_ID = p_SITE_USE_ID)
            OR (    ( Recinfo.SITE_USE_ID IS NULL )
                AND (  p_SITE_USE_ID IS NULL )))
       AND (    ( Recinfo.CUST_ACCOUNT_ID = p_CUST_ACCOUNT_ID)
            OR (    ( Recinfo.CUST_ACCOUNT_ID IS NULL )
                AND (  p_CUST_ACCOUNT_ID IS NULL )))
       AND (    ( Recinfo.NOTICE_METHOD = p_NOTICE_METHOD)
            OR (    ( Recinfo.NOTICE_METHOD IS NULL )
                AND (  p_NOTICE_METHOD IS NULL )))
       AND (    ( Recinfo.NOTICE_RECEIVED_CONFIRMATION = p_NOTICE_RECEIVED_CONFIRMATION)
            OR (    ( Recinfo.NOTICE_RECEIVED_CONFIRMATION IS NULL )
                AND (  p_NOTICE_RECEIVED_CONFIRMATION IS NULL )))
       AND (    ( Recinfo.NOTICE_SENT_DATE = p_NOTICE_SENT_DATE)
            OR (    ( Recinfo.NOTICE_SENT_DATE IS NULL )
                AND (  p_NOTICE_SENT_DATE IS NULL )))
       AND (    ( Recinfo.NOTICE_TYPE = p_NOTICE_TYPE)
            OR (    ( Recinfo.NOTICE_TYPE IS NULL )
                AND (  p_NOTICE_TYPE IS NULL )))
       AND (    ( Recinfo.BEGIN_DATE = p_BEGIN_DATE)
            OR (    ( Recinfo.BEGIN_DATE IS NULL )
                AND (  p_BEGIN_DATE IS NULL )))
       AND (    ( Recinfo.END_DATE = p_END_DATE)
            OR (    ( Recinfo.END_DATE IS NULL )
                AND (  p_END_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
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
       AND (    ( Recinfo.WH_UPDATE_DATE = p_WH_UPDATE_DATE)
            OR (    ( Recinfo.WH_UPDATE_DATE IS NULL )
                AND (  p_WH_UPDATE_DATE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End HZ_SUSPENSION_ACTIVITY_PKG;

/

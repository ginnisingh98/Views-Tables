--------------------------------------------------------
--  DDL for Package Body CSC_CUST_PLANS_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CUST_PLANS_AUDIT_PKG" as
/* $Header: csctcpab.pls 120.0 2005/05/30 15:46:47 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_CUST_PLANS_AUDIT_PKG
-- Purpose          : Table handler package to perform inserts into
--                    CSC_CUST_PLANS_AUDIT table. This table maintains an audit
--                    log of the operations performed on the CSC_CUST_PLANS table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-29-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
-- 10-23-2000    dejoseph      Changed the IN OUT NOCOPY parameter px_plan_audit_id to an
--                             OUT NOCOPY parameter x_plan_audit_id. Fix to bug # 1467071
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 12-03-2002	 bhroy		Added check-in comments WHENEVER OSERROR EXIT FAILURE ROLLBACK
--
-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_CUST_PLANS_AUDIT_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctcpab.pls';

PROCEDURE Insert_Row(
          --px_PLAN_AUDIT_ID           IN OUT  NOCOPY NUMBER,
          p_PLAN_ID                  IN      NUMBER,
          p_PARTY_ID                 IN      NUMBER,
          p_CUST_ACCOUNT_ID          IN      NUMBER,
          --p_CUST_ACCOUNT_ORG         IN      NUMBER,
          p_PLAN_STATUS_CODE         IN      VARCHAR2,
          p_REQUEST_ID               IN      NUMBER,
          p_PROGRAM_APPLICATION_ID   IN      NUMBER,
          p_PROGRAM_ID               IN      NUMBER,
          p_PROGRAM_UPDATE_DATE      IN      DATE,
          p_CREATION_DATE            IN      DATE,
          p_LAST_UPDATE_DATE         IN      DATE,
          p_CREATED_BY               IN      NUMBER,
          p_LAST_UPDATED_BY          IN      NUMBER,
          p_LAST_UPDATE_LOGIN        IN      NUMBER,
          p_ATTRIBUTE1               IN      VARCHAR2,
          p_ATTRIBUTE2               IN      VARCHAR2,
          p_ATTRIBUTE3               IN      VARCHAR2,
          p_ATTRIBUTE4               IN      VARCHAR2,
          p_ATTRIBUTE5               IN      VARCHAR2,
          p_ATTRIBUTE6               IN      VARCHAR2,
          p_ATTRIBUTE7               IN      VARCHAR2,
          p_ATTRIBUTE8               IN      VARCHAR2,
          p_ATTRIBUTE9               IN      VARCHAR2,
          p_ATTRIBUTE10              IN      VARCHAR2,
          p_ATTRIBUTE11              IN      VARCHAR2,
          p_ATTRIBUTE12              IN      VARCHAR2,
          p_ATTRIBUTE13              IN      VARCHAR2,
          p_ATTRIBUTE14              IN      VARCHAR2,
          p_ATTRIBUTE15              IN      VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN      VARCHAR2,
		x_plan_audit_id            OUT NOCOPY    NUMBER)
IS
   CURSOR C2 IS
	 SELECT CSC_CUST_PLANS_AUDIT_S.nextval
	 FROM sys.dual;
BEGIN
   OPEN C2;
   FETCH C2 INTO x_PLAN_AUDIT_ID;
   CLOSE C2;

   INSERT INTO CSC_CUST_PLANS_AUDIT(
           PLAN_AUDIT_ID,
           PLAN_ID,
           PARTY_ID,
           CUST_ACCOUNT_ID,
           --CUST_ACCOUNT_ORG,
           PLAN_STATUS_CODE,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           CREATION_DATE,
           LAST_UPDATE_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
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
           ATTRIBUTE_CATEGORY,
           OBJECT_VERSION_NUMBER
          ) VALUES (
           x_PLAN_AUDIT_ID,
           decode( p_PLAN_ID, FND_API.G_MISS_NUM, NULL, p_PLAN_ID),
           decode( p_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_ID),
           decode( p_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, p_CUST_ACCOUNT_ID),
           --decode( p_CUST_ACCOUNT_ORG, FND_API.G_MISS_NUM, NULL, p_CUST_ACCOUNT_ORG),
           decode( p_PLAN_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_PLAN_STATUS_CODE),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_PROGRAM_UPDATE_DATE),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
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
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           1 );  -- the first time a record is created, the object_version_number = 1

End Insert_Row;


PROCEDURE Update_Row(
          p_PLAN_AUDIT_ID            IN   NUMBER,
          p_PLAN_ID                  IN   NUMBER,
          p_PARTY_ID                 IN   NUMBER,
          p_CUST_ACCOUNT_ID          IN   NUMBER,
          --p_CUST_ACCOUNT_ORG         IN   NUMBER,
          p_PLAN_STATUS_CODE         IN   VARCHAR2,
          p_REQUEST_ID               IN   NUMBER,
          p_PROGRAM_APPLICATION_ID   IN   NUMBER,
          p_PROGRAM_ID               IN   NUMBER,
          p_PROGRAM_UPDATE_DATE      IN   DATE,
          p_LAST_UPDATE_DATE         IN   DATE,
          p_LAST_UPDATED_BY          IN   NUMBER,
          p_LAST_UPDATE_LOGIN        IN   NUMBER,
          p_ATTRIBUTE1               IN   VARCHAR2,
          p_ATTRIBUTE2               IN   VARCHAR2,
          p_ATTRIBUTE3               IN   VARCHAR2,
          p_ATTRIBUTE4               IN   VARCHAR2,
          p_ATTRIBUTE5               IN   VARCHAR2,
          p_ATTRIBUTE6               IN   VARCHAR2,
          p_ATTRIBUTE7               IN   VARCHAR2,
          p_ATTRIBUTE8               IN   VARCHAR2,
          p_ATTRIBUTE9               IN   VARCHAR2,
          p_ATTRIBUTE10              IN   VARCHAR2,
          p_ATTRIBUTE11              IN   VARCHAR2,
          p_ATTRIBUTE12              IN   VARCHAR2,
          p_ATTRIBUTE13              IN   VARCHAR2,
          p_ATTRIBUTE14              IN   VARCHAR2,
          p_ATTRIBUTE15              IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN   VARCHAR2 )
IS
BEGIN
    Update CSC_CUST_PLANS_AUDIT
    SET
      PLAN_ID = decode( p_PLAN_ID, FND_API.G_MISS_NUM, PLAN_ID, p_PLAN_ID),
      PARTY_ID = decode( p_PARTY_ID, FND_API.G_MISS_NUM, PARTY_ID, p_PARTY_ID),
      CUST_ACCOUNT_ID = decode( p_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, CUST_ACCOUNT_ID, p_CUST_ACCOUNT_ID),
      --CUST_ACCOUNT_ORG = decode( p_CUST_ACCOUNT_ORG, FND_API.G_MISS_NUM, CUST_ACCOUNT_ORG, p_CUST_ACCOUNT_ORG),
      PLAN_STATUS_CODE = decode( p_PLAN_STATUS_CODE, FND_API.G_MISS_CHAR, PLAN_STATUS_CODE, p_PLAN_STATUS_CODE),
      REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
      PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
      PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
      PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
      LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
      LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
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
      ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
      OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    where PLAN_AUDIT_ID = p_PLAN_AUDIT_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
          p_PLAN_AUDIT_ID           IN   NUMBER)
 IS
 BEGIN
   DELETE FROM CSC_CUST_PLANS_AUDIT
    WHERE PLAN_AUDIT_ID = p_PLAN_AUDIT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_PLAN_AUDIT_ID           IN   NUMBER,
          p_PLAN_ID                 IN   NUMBER,
          p_PARTY_ID                IN   NUMBER,
          p_CUST_ACCOUNT_ID         IN   NUMBER,
          --p_CUST_ACCOUNT_ORG        IN   NUMBER,
          p_PLAN_STATUS_CODE        IN   VARCHAR2,
          p_REQUEST_ID              IN   NUMBER,
          p_PROGRAM_APPLICATION_ID  IN   NUMBER,
          p_PROGRAM_ID              IN   NUMBER,
          p_PROGRAM_UPDATE_DATE     IN   DATE,
          p_CREATION_DATE           IN   DATE,
          p_LAST_UPDATE_DATE        IN   DATE,
          p_CREATED_BY              IN   NUMBER,
          p_LAST_UPDATED_BY         IN   NUMBER,
          p_LAST_UPDATE_LOGIN       IN   NUMBER,
          p_ATTRIBUTE1              IN   VARCHAR2,
          p_ATTRIBUTE2              IN   VARCHAR2,
          p_ATTRIBUTE3              IN   VARCHAR2,
          p_ATTRIBUTE4              IN   VARCHAR2,
          p_ATTRIBUTE5              IN   VARCHAR2,
          p_ATTRIBUTE6              IN   VARCHAR2,
          p_ATTRIBUTE7              IN   VARCHAR2,
          p_ATTRIBUTE8              IN   VARCHAR2,
          p_ATTRIBUTE9              IN   VARCHAR2,
          p_ATTRIBUTE10             IN   VARCHAR2,
          p_ATTRIBUTE11             IN   VARCHAR2,
          p_ATTRIBUTE12             IN   VARCHAR2,
          p_ATTRIBUTE13             IN   VARCHAR2,
          p_ATTRIBUTE14             IN   VARCHAR2,
          p_ATTRIBUTE15             IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY      IN   VARCHAR2,
          p_OBJECT_VERSION_NUMBER   IN   NUMBER )
IS
   CURSOR C IS
        SELECT *
        FROM   CSC_CUST_PLANS_AUDIT
        WHERE  PLAN_AUDIT_ID =  p_PLAN_AUDIT_ID
        FOR UPDATE of PLAN_AUDIT_ID NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        --APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.PLAN_AUDIT_ID = p_PLAN_AUDIT_ID)
       AND (    ( Recinfo.PLAN_ID = p_PLAN_ID)
            OR (    ( Recinfo.PLAN_ID IS NULL )
                AND (  p_PLAN_ID IS NULL )))
       AND (    ( Recinfo.PARTY_ID = p_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID IS NULL )
                AND (  p_PARTY_ID IS NULL )))
       AND (    ( Recinfo.CUST_ACCOUNT_ID = p_CUST_ACCOUNT_ID)
            OR (    ( Recinfo.CUST_ACCOUNT_ID IS NULL )
                AND (  p_CUST_ACCOUNT_ID IS NULL )))
       --AND (    ( Recinfo.CUST_ACCOUNT_ORG = p_CUST_ACCOUNT_ORG)
            --OR (    ( Recinfo.CUST_ACCOUNT_ORG IS NULL )
                --AND (  p_CUST_ACCOUNT_ORG IS NULL )))
       AND (    ( Recinfo.PLAN_STATUS_CODE = p_PLAN_STATUS_CODE)
            OR (    ( Recinfo.PLAN_STATUS_CODE IS NULL )
                AND (  p_PLAN_STATUS_CODE IS NULL )))
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
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
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
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       --APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSC_CUST_PLANS_AUDIT_PKG;

/

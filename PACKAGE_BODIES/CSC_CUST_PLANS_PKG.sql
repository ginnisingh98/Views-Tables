--------------------------------------------------------
--  DDL for Package Body CSC_CUST_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CUST_PLANS_PKG" as
/* $Header: csctctpb.pls 115.15 2002/12/04 16:16:28 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CUST_PLANS_PKG
-- Purpose          : Table handler package to perform inserts, update, deletes and lock
--                    row operations on CSC_CUST_PLANS table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-28-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 03-28-2000    dejoseph      Removed references to CUST_ACCOUNT_ID from all
--                             'where' clauses. ie. and   nvl(cust_account_org,0) =
--                             nvl(p_cust_account_org, nvl(cust_account_org,0) )
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
-- 04-10-2000    dejoseph      Added logic to insert SYSDATE when start_date_active is not
--                             specified. When plans with NULL start_date_active are assigned
--                             to customers, the customer-plan association's start_date_active
--                             in CSC_CUST_PLANS will have to default to SYSDATE, which provides
--                             a method to keep track of when this plan was assigned to customers.


-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_CUST_PLANS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctctpb.pls';

PROCEDURE Insert_Row(
          px_CUST_PLAN_ID          IN OUT NOCOPY NUMBER,
          p_PLAN_ID                IN     NUMBER,
          p_PARTY_ID               IN     NUMBER,
          p_CUST_ACCOUNT_ID        IN     NUMBER,
          --p_CUST_ACCOUNT_ORG       IN     NUMBER,
          p_START_DATE_ACTIVE      IN     DATE,
          p_END_DATE_ACTIVE        IN     DATE,
          p_MANUAL_FLAG            IN     VARCHAR2,
          p_PLAN_STATUS_CODE       IN     VARCHAR2,
          p_REQUEST_ID             IN     NUMBER,
          p_PROGRAM_APPLICATION_ID IN     NUMBER,
          p_PROGRAM_ID             IN     NUMBER,
          p_PROGRAM_UPDATE_DATE    IN     DATE,
          p_CREATION_DATE          IN     DATE,
          p_LAST_UPDATE_DATE       IN     DATE,
          p_CREATED_BY             IN     NUMBER,
          p_LAST_UPDATED_BY        IN     NUMBER,
          p_LAST_UPDATE_LOGIN      IN     NUMBER,
          p_ATTRIBUTE1             IN     VARCHAR2,
          p_ATTRIBUTE2             IN     VARCHAR2,
          p_ATTRIBUTE3             IN     VARCHAR2,
          p_ATTRIBUTE4             IN     VARCHAR2,
          p_ATTRIBUTE5             IN     VARCHAR2,
          p_ATTRIBUTE6             IN     VARCHAR2,
          p_ATTRIBUTE7             IN     VARCHAR2,
          p_ATTRIBUTE8             IN     VARCHAR2,
          p_ATTRIBUTE9             IN     VARCHAR2,
          p_ATTRIBUTE10            IN     VARCHAR2,
          p_ATTRIBUTE11            IN     VARCHAR2,
          p_ATTRIBUTE12            IN     VARCHAR2,
          p_ATTRIBUTE13            IN     VARCHAR2,
          p_ATTRIBUTE14            IN     VARCHAR2,
          p_ATTRIBUTE15            IN     VARCHAR2,
          p_ATTRIBUTE_CATEGORY     IN     VARCHAR2,
          X_OBJECT_VERSION_NUMBER  OUT    NOCOPY NUMBER)
IS
   CURSOR C2 IS
	 SELECT CSC_CUST_PLANS_S.nextval
	 FROM sys.dual;
BEGIN
   If (px_CUST_PLAN_ID IS NULL) OR (px_CUST_PLAN_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_CUST_PLAN_ID;
       CLOSE C2;
   End If;

   INSERT INTO CSC_CUST_PLANS(
           CUST_PLAN_ID,
           PLAN_ID,
           PARTY_ID,
           CUST_ACCOUNT_ID,
           --CUST_ACCOUNT_ORG,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           MANUAL_FLAG,
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
           px_CUST_PLAN_ID,
           decode( p_PLAN_ID, FND_API.G_MISS_NUM, NULL, p_PLAN_ID),
           decode( p_PARTY_ID, FND_API.G_MISS_NUM, NULL, p_PARTY_ID),
           decode( p_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, p_CUST_ACCOUNT_ID),
           --decode( p_CUST_ACCOUNT_ORG, FND_API.G_MISS_NUM, NULL, p_CUST_ACCOUNT_ORG),
           decode( p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, SYSDATE,
								NULL, SYSDATE, p_START_DATE_ACTIVE),
           decode( p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL, p_END_DATE_ACTIVE),
           decode( p_MANUAL_FLAG, FND_API.G_MISS_CHAR, NULL, p_MANUAL_FLAG),
           decode( p_PLAN_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_PLAN_STATUS_CODE),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_PROGRAM_UPDATE_DATE),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
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

   x_object_version_number := 1;
End Insert_Row;


PROCEDURE Update_Row(
          p_CUST_PLAN_ID            IN  NUMBER,
          p_PLAN_ID                 IN  NUMBER,
          p_PARTY_ID                IN  NUMBER,
          p_CUST_ACCOUNT_ID         IN  NUMBER,
          --p_CUST_ACCOUNT_ORG        IN  NUMBER,
          p_START_DATE_ACTIVE       IN  DATE,
          p_END_DATE_ACTIVE         IN  DATE,
          p_MANUAL_FLAG             IN  VARCHAR2,
          p_PLAN_STATUS_CODE        IN  VARCHAR2,
          p_REQUEST_ID              IN  NUMBER,
          p_PROGRAM_APPLICATION_ID  IN  NUMBER,
          p_PROGRAM_ID              IN  NUMBER,
          p_PROGRAM_UPDATE_DATE     IN  DATE,
          p_LAST_UPDATE_DATE        IN  DATE,
          p_LAST_UPDATED_BY         IN  NUMBER,
          p_LAST_UPDATE_LOGIN       IN  NUMBER,
          p_ATTRIBUTE1              IN  VARCHAR2,
          p_ATTRIBUTE2              IN  VARCHAR2,
          p_ATTRIBUTE3              IN  VARCHAR2,
          p_ATTRIBUTE4              IN  VARCHAR2,
          p_ATTRIBUTE5              IN  VARCHAR2,
          p_ATTRIBUTE6              IN  VARCHAR2,
          p_ATTRIBUTE7              IN  VARCHAR2,
          p_ATTRIBUTE8              IN  VARCHAR2,
          p_ATTRIBUTE9              IN  VARCHAR2,
          p_ATTRIBUTE10             IN  VARCHAR2,
          p_ATTRIBUTE11             IN  VARCHAR2,
          p_ATTRIBUTE12             IN  VARCHAR2,
          p_ATTRIBUTE13             IN  VARCHAR2,
          p_ATTRIBUTE14             IN  VARCHAR2,
          p_ATTRIBUTE15             IN  VARCHAR2,
          p_ATTRIBUTE_CATEGORY      IN  VARCHAR2,
          X_OBJECT_VERSION_NUMBER   OUT NOCOPY NUMBER)
IS
BEGIN

    Update CSC_CUST_PLANS
    SET
      PLAN_ID = nvl(p_PLAN_ID, plan_id),
      PARTY_ID = nvl(p_PARTY_ID, party_id),
      CUST_ACCOUNT_ID = p_CUST_ACCOUNT_ID,
      --CUST_ACCOUNT_ORG = p_CUST_ACCOUNT_ORG,
      START_DATE_ACTIVE = p_START_DATE_ACTIVE,
      END_DATE_ACTIVE = p_END_DATE_ACTIVE,
      MANUAL_FLAG = p_MANUAL_FLAG,
      PLAN_STATUS_CODE = p_PLAN_STATUS_CODE,
      REQUEST_ID = p_REQUEST_ID,
      PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID,
      PROGRAM_ID = p_PROGRAM_ID,
      PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE,
      LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = p_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
      ATTRIBUTE1 = p_ATTRIBUTE1,
      ATTRIBUTE2 = p_ATTRIBUTE2,
      ATTRIBUTE3 = p_ATTRIBUTE3,
      ATTRIBUTE4 = p_ATTRIBUTE4,
      ATTRIBUTE5 = p_ATTRIBUTE5,
      ATTRIBUTE6 = p_ATTRIBUTE6,
      ATTRIBUTE7 = p_ATTRIBUTE7,
      ATTRIBUTE8 = p_ATTRIBUTE8,
      ATTRIBUTE9 = p_ATTRIBUTE9,
      ATTRIBUTE10 = p_ATTRIBUTE10,
      ATTRIBUTE11 = p_ATTRIBUTE11,
      ATTRIBUTE12 = p_ATTRIBUTE12,
      ATTRIBUTE13 = p_ATTRIBUTE13,
      ATTRIBUTE14 = p_ATTRIBUTE14,
      ATTRIBUTE15 = p_ATTRIBUTE15,
      ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY,
      OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    where CUST_PLAN_ID            = nvl(p_CUST_PLAN_ID,     cust_plan_id)
    and   plan_id                 = nvl(p_plan_id,          plan_id)
    and   party_id                = nvl(p_party_id,         party_id)
    and   nvl(cust_account_id,0)  = nvl(p_cust_account_id,  nvl(cust_account_id,0) )
    RETURNING object_version_number INTO x_object_version_number;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

PROCEDURE Delete_Row(
    p_CUST_PLAN_ID  IN  NUMBER := NULL,
    p_PLAN_ID       IN  NUMBER := NULL,
    p_PARTY_ID      IN  NUMBER := NULL)
IS
BEGIN
   DELETE FROM CSC_CUST_PLANS
   WHERE  CUST_PLAN_ID = nvl(p_CUST_PLAN_ID, CUST_PLAN_ID)
   AND    PLAN_ID      = nvl(p_PLAN_ID,      PLAN_ID)
   AND    PARTY_ID     = nvl(p_PARTY_ID,     PARTY_ID);

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

END Delete_Row;


PROCEDURE Lock_Row(
          p_CUST_PLAN_ID            IN  NUMBER := NULL,
          p_PLAN_ID                 IN  NUMBER := NULL,
          p_PARTY_ID                IN  NUMBER := NULL,
		P_CUST_ACCOUNT_ID         IN  NUMBER := NULL,
		--P_CUST_ACCOUNT_ORG        IN  NUMBER := NULL,
          p_OBJECT_VERSION_NUMBER   IN  NUMBER)
IS
   CURSOR C IS
        SELECT *
        FROM   CSC_CUST_PLANS
        WHERE  CUST_PLAN_ID              =  nvl(p_CUST_PLAN_ID, CUST_PLAN_ID)
	   AND    PLAN_ID                   =  nvl(P_PLAN_ID, PLAN_ID)
	   AND    PARTY_ID                  =  nvl(P_PARTY_ID, PARTY_ID)
	   AND    nvl(CUST_ACCOUNT_ID,  0)  =  nvl(P_CUST_ACCOUNT_ID,  nvl(CUST_ACCOUNT_ID,  0) )
	   -- AND    nvl(CUST_ACCOUNT_ORG, 0)  =  nvl(P_CUST_ACCOUNT_ORG, nvl(CUST_ACCOUNT_ORG, 0) )
	   AND    OBJECT_VERSION_NUMBER     =  P_OBJECT_VERSION_NUMBER
        FOR    UPDATE NOWAIT;

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

END Lock_Row;

End CSC_CUST_PLANS_PKG;

/

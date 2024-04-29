--------------------------------------------------------
--  DDL for Package Body CSC_PLAN_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PLAN_LINES_PKG" as
/* $Header: csctplnb.pls 120.3 2005/09/18 23:57:09 vshastry noship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_LINES_PKG
-- Purpose          : Table handler package to performs Inserts, Updates, Deletes and
--                    row operations on the CSC_PLAN_LINES table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-21-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
--
-- 08-17-2001    dejoseph      Made the following changes for 11.5.6 to cater to the seeding
--                             of Relationship Plans. Ref Bug # 1895567.
--                             - Added proc load_row to be called for the .lct file (cscpllns.lct)
--                             - added parameter p_application_id to procedure insert_row and
--                               update_row.
--                             - added check if user_id = 1, ie SEED, then seeded_flag='Y' in
--                               procedure insert_row and update_row
-- 08-24-2001   dejoseph      Added check to insert NULL into application_id if no values was
--                            passed in for this parameter.
-- 11-12-2002	bhroy		NOCOPY changes made
-- 11-25-2002	bhroy		FND_API defaults removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- 19-aug-2005  tpalaniv        Deriving l_user_id in load_row API using fnd_load_util as part of
--                              R12 ATG Project
-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_PLAN_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctplnb.pls';

PROCEDURE Insert_Row(
          px_LINE_ID               IN OUT NOCOPY NUMBER,
          p_PLAN_ID                IN   NUMBER,
          p_CONDITION_ID           IN   NUMBER,
          p_CREATION_DATE          IN   DATE,
          p_LAST_UPDATE_DATE       IN   DATE,
          p_CREATED_BY             IN   NUMBER,
          p_LAST_UPDATED_BY        IN   NUMBER,
          p_LAST_UPDATE_LOGIN      IN   NUMBER,
          p_ATTRIBUTE1             IN   VARCHAR2,
          p_ATTRIBUTE2             IN   VARCHAR2,
          p_ATTRIBUTE3             IN   VARCHAR2,
          p_ATTRIBUTE4             IN   VARCHAR2,
          p_ATTRIBUTE5             IN   VARCHAR2,
          p_ATTRIBUTE6             IN   VARCHAR2,
          p_ATTRIBUTE7             IN   VARCHAR2,
          p_ATTRIBUTE8             IN   VARCHAR2,
          p_ATTRIBUTE9             IN   VARCHAR2,
          p_ATTRIBUTE10            IN   VARCHAR2,
          p_ATTRIBUTE11            IN   VARCHAR2,
          p_ATTRIBUTE12            IN   VARCHAR2,
          p_ATTRIBUTE13            IN   VARCHAR2,
          p_ATTRIBUTE14            IN   VARCHAR2,
          p_ATTRIBUTE15            IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY     IN   VARCHAR2,
	  p_APPLICATION_ID         IN   NUMBER,
          X_OBJECT_VERSION_NUMBER  OUT NOCOPY  NUMBER)
IS
   CURSOR C2 IS
   SELECT CSC_PLAN_LINES_S.nextval
   FROM sys.dual;

   l_seeded_flag         VARCHAR2(3);

BEGIN
   If (px_LINE_ID IS NULL) OR (px_LINE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_LINE_ID;
       CLOSE C2;
   End If;

   /* added 120 for bug 4596220 */
   if ( p_created_by IN (1, 120) ) then
      l_seeded_flag := 'Y';
   else
      l_seeded_flag := 'N';
   end if;

   INSERT INTO CSC_PLAN_LINES(
       LINE_ID,
       PLAN_ID,
       CONDITION_ID,
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
       ATTRIBUTE_CATEGORY,
       APPLICATION_ID,
       SEEDED_FLAG,
       OBJECT_VERSION_NUMBER
          )
   VALUES (
       px_LINE_ID,
       decode( p_PLAN_ID, FND_API.G_MISS_NUM, NULL, p_PLAN_ID),
       decode( p_CONDITION_ID, FND_API.G_MISS_NUM, NULL, p_CONDITION_ID),
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
       decode( p_application_id, FND_API.G_MISS_NUM, NULL, p_application_id),
       l_seeded_flag,
       1 );  -- the first time a record is created, the object_version_number = 1

   x_object_version_number := 1;
End Insert_Row;

PROCEDURE Update_Row(
          p_LINE_ID                IN  NUMBER,
          p_PLAN_ID                IN  NUMBER,
          p_CONDITION_ID           IN  NUMBER,
          p_CREATION_DATE          IN  DATE,
          p_LAST_UPDATE_DATE       IN  DATE,
          p_CREATED_BY             IN  NUMBER,
          p_LAST_UPDATED_BY        IN  NUMBER,
          p_LAST_UPDATE_LOGIN      IN  NUMBER,
          p_ATTRIBUTE1             IN  VARCHAR2,
          p_ATTRIBUTE2             IN  VARCHAR2,
          p_ATTRIBUTE3             IN  VARCHAR2,
          p_ATTRIBUTE4             IN  VARCHAR2,
          p_ATTRIBUTE5             IN  VARCHAR2,
          p_ATTRIBUTE6             IN  VARCHAR2,
          p_ATTRIBUTE7             IN  VARCHAR2,
          p_ATTRIBUTE8             IN  VARCHAR2,
          p_ATTRIBUTE9             IN  VARCHAR2,
          p_ATTRIBUTE10            IN  VARCHAR2,
          p_ATTRIBUTE11            IN  VARCHAR2,
          p_ATTRIBUTE12            IN  VARCHAR2,
          p_ATTRIBUTE13            IN  VARCHAR2,
          p_ATTRIBUTE14            IN  VARCHAR2,
          p_ATTRIBUTE15            IN  VARCHAR2,
          p_ATTRIBUTE_CATEGORY     IN  VARCHAR2,
	  p_APPLICATION_ID         IN  NUMBER ,
          X_OBJECT_VERSION_NUMBER  OUT NOCOPY NUMBER)
IS
   l_seeded_flag       VARCHAR2(3);
BEGIN
   /* added 120 for bug 4596220 */
    if ( p_last_updated_by IN (1, 120) ) then
       l_seeded_flag := 'Y';
    else
       l_seeded_flag := 'N';
    end if;

    Update CSC_PLAN_LINES
    SET
       PLAN_ID = decode( p_PLAN_ID, FND_API.G_MISS_NUM, PLAN_ID, p_PLAN_ID),
       CONDITION_ID = decode( p_CONDITION_ID, FND_API.G_MISS_NUM,
                                              CONDITION_ID, p_CONDITION_ID),
       LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,
                                              LAST_UPDATE_DATE, p_last_update_date),
       LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM,
                                              LAST_UPDATED_BY, p_LAST_UPDATED_BY),
       LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,
                                              LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
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
       ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,
                                              ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
       APPLICATION_ID = decode(P_APPLICATION_ID, FND_API.G_MISS_NUM, APPLICATION_ID, P_APPLICATION_ID),
       SEEDED_FLAG    = L_SEEDED_FLAG,
       OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    where LINE_ID   = p_LINE_ID
    and   PLAN_ID   = p_PLAN_ID
    RETURNING object_version_number INTO x_object_version_number;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

PROCEDURE Delete_Row(
    P_LINE_ID   IN  NUMBER,
    P_PLAN_ID   IN  NUMBER)
IS
BEGIN
   DELETE FROM CSC_PLAN_LINES
   WHERE  LINE_ID = nvl(p_line_id, LINE_ID)
   and    PLAN_ID = nvl(p_plan_id, PLAN_ID);

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

END Delete_Row;

PROCEDURE Lock_Row(
          p_LINE_ID                IN   NUMBER,
          p_PLAN_ID                IN   NUMBER,
          p_CONDITION_ID           IN   NUMBER,
          p_CREATION_DATE          IN   DATE,
          p_LAST_UPDATE_DATE       IN   DATE,
          p_CREATED_BY             IN   NUMBER,
          p_LAST_UPDATED_BY        IN   NUMBER,
          p_LAST_UPDATE_LOGIN      IN   NUMBER,
          p_ATTRIBUTE1             IN   VARCHAR2,
          p_ATTRIBUTE2             IN   VARCHAR2,
          p_ATTRIBUTE3             IN   VARCHAR2,
          p_ATTRIBUTE4             IN   VARCHAR2,
          p_ATTRIBUTE5             IN   VARCHAR2,
          p_ATTRIBUTE6             IN   VARCHAR2,
          p_ATTRIBUTE7             IN   VARCHAR2,
          p_ATTRIBUTE8             IN   VARCHAR2,
          p_ATTRIBUTE9             IN   VARCHAR2,
          p_ATTRIBUTE10            IN   VARCHAR2,
          p_ATTRIBUTE11            IN   VARCHAR2,
          p_ATTRIBUTE12            IN   VARCHAR2,
          p_ATTRIBUTE13            IN   VARCHAR2,
          p_ATTRIBUTE14            IN   VARCHAR2,
          p_ATTRIBUTE15            IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY     IN   VARCHAR2,
          p_OBJECT_VERSION_NUMBER  IN   NUMBER)
IS
   CURSOR C IS
        SELECT *
        FROM   CSC_PLAN_LINES
        WHERE  LINE_ID =  p_LINE_ID
        FOR    UPDATE of LINE_ID NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        -- APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.LINE_ID = p_LINE_ID)
       AND (    ( Recinfo.PLAN_ID = p_PLAN_ID)
            OR (    ( Recinfo.PLAN_ID IS NULL )
                AND (  p_PLAN_ID IS NULL )))
       AND (    ( Recinfo.CONDITION_ID = p_CONDITION_ID)
            OR (    ( Recinfo.CONDITION_ID IS NULL )
                AND (  p_CONDITION_ID IS NULL )))
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
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE7)
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
       RETURN;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       -- APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE LOAD_ROW (
   P_LINE_ID                IN   NUMBER,
   P_PLAN_ID                IN   NUMBER,
   P_CONDITION_ID           IN   NUMBER,
   P_LAST_UPDATE_DATE       IN   DATE,
   P_LAST_UPDATED_BY        IN   NUMBER,
   P_CREATED_BY             IN   NUMBER,
   P_LAST_UPDATE_LOGIN      IN   NUMBER,
   P_ATTRIBUTE1             IN   VARCHAR2,
   P_ATTRIBUTE2             IN   VARCHAR2,
   P_ATTRIBUTE3             IN   VARCHAR2,
   P_ATTRIBUTE4             IN   VARCHAR2,
   P_ATTRIBUTE5             IN   VARCHAR2,
   P_ATTRIBUTE6             IN   VARCHAR2,
   P_ATTRIBUTE7             IN   VARCHAR2,
   P_ATTRIBUTE8             IN   VARCHAR2,
   P_ATTRIBUTE9             IN   VARCHAR2,
   P_ATTRIBUTE10            IN   VARCHAR2,
   P_ATTRIBUTE11            IN   VARCHAR2,
   P_ATTRIBUTE12            IN   VARCHAR2,
   P_ATTRIBUTE13            IN   VARCHAR2,
   P_ATTRIBUTE14            IN   VARCHAR2,
   P_ATTRIBUTE15            IN   VARCHAR2,
   P_ATTRIBUTE_CATEGORY     IN   VARCHAR2,
   P_OBJECT_VERSION_NUMBER  OUT NOCOPY  NUMBER,
   P_APPLICATION_ID         IN   NUMBER,
   P_OWNER                  IN   VARCHAR2 )
IS
   l_user_id                NUMBER := 0;
   l_line_id                NUMBER := CSC_CORE_UTILS_PVT.G_MISS_NUM;
   l_object_version_number  NUMBER := 0;

BEGIN

   l_line_id := p_line_id;

   update_row(
      p_LINE_ID                =>  l_line_id,
      p_PLAN_ID                =>  p_plan_id,
      p_CONDITION_ID           =>  p_condition_id,
      p_CREATION_DATE          =>  p_last_update_date,
      p_LAST_UPDATE_DATE       =>  p_last_update_date,
      p_CREATED_BY             =>  p_created_by,
      p_LAST_UPDATED_BY        =>  p_last_updated_by,
      p_LAST_UPDATE_LOGIN      =>  0,
      p_ATTRIBUTE1             =>  p_attribute1,
      p_ATTRIBUTE2             =>  p_attribute2,
      p_ATTRIBUTE3             =>  p_attribute3,
      p_ATTRIBUTE4             =>  p_attribute4,
      p_ATTRIBUTE5             =>  p_attribute5,
      p_ATTRIBUTE6             =>  p_attribute6,
      p_ATTRIBUTE7             =>  p_attribute7,
      p_ATTRIBUTE8             =>  p_attribute8,
      p_ATTRIBUTE9             =>  p_attribute9,
      p_ATTRIBUTE10            =>  p_attribute10,
      p_ATTRIBUTE11            =>  p_attribute11,
      p_ATTRIBUTE12            =>  p_attribute12,
      p_ATTRIBUTE13            =>  p_attribute13,
      p_ATTRIBUTE14            =>  p_attribute14,
      p_ATTRIBUTE15            =>  p_attribute15,
      p_ATTRIBUTE_CATEGORY     =>  p_attribute_category,
      p_APPLICATION_ID         =>  p_application_id,
      X_OBJECT_VERSION_NUMBER  =>  l_object_version_number);

EXCEPTION
   when no_data_found then
      insert_row(
         px_LINE_ID               =>  l_line_id,
         p_PLAN_ID                =>  p_plan_id,
         p_CONDITION_ID           =>  p_condition_id,
	 p_CREATION_DATE          =>  p_last_update_date,
         p_LAST_UPDATE_DATE       =>  p_last_update_date,
         p_CREATED_BY             =>  p_created_by,
         p_LAST_UPDATED_BY        =>  p_last_updated_by,
         p_LAST_UPDATE_LOGIN      =>  0,
         p_ATTRIBUTE1             =>  p_attribute1,
         p_ATTRIBUTE2             =>  p_attribute2,
         p_ATTRIBUTE3             =>  p_attribute3,
         p_ATTRIBUTE4             =>  p_attribute4,
         p_ATTRIBUTE5             =>  p_attribute5,
         p_ATTRIBUTE6             =>  p_attribute6,
         p_ATTRIBUTE7             =>  p_attribute7,
         p_ATTRIBUTE8             =>  p_attribute8,
         p_ATTRIBUTE9             =>  p_attribute9,
         p_ATTRIBUTE10            =>  p_attribute10,
         p_ATTRIBUTE11            =>  p_attribute11,
         p_ATTRIBUTE12            =>  p_attribute12,
         p_ATTRIBUTE13            =>  p_attribute13,
         p_ATTRIBUTE14            =>  p_attribute14,
         p_ATTRIBUTE15            =>  p_attribute15,
         p_ATTRIBUTE_CATEGORY     =>  p_attribute_category,
         p_APPLICATION_ID         =>  p_application_id,
         X_OBJECT_VERSION_NUMBER  =>  l_object_version_number);

END LOAD_ROW;

End CSC_PLAN_LINES_PKG;

/

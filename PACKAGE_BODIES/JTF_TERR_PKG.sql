--------------------------------------------------------
--  DDL for Package Body JTF_TERR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_PKG" AS
/* $Header: jtfvtryb.pls 120.0.12010000.2 2009/09/07 06:32:43 vpalle ship $ */

-- 01/25/00  vnedunga chnaging lock_row to use terr_id
-- 02/24/00  vnedunga fixing decode for date fields
-- 02/29/00  jdochert changing tank from varchar2(30) to number
-- 09/17/00  jdochert adding num_winners column
--

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_ID                        IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_REQUEST_ID                     IN     NUMBER,
                  x_PROGRAM_APPLICATION_ID         IN     NUMBER,
                  x_PROGRAM_ID                     IN     NUMBER,
                  x_PROGRAM_UPDATE_DATE            IN     DATE,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_NAME                           IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_PLANNED_FLAG                   IN     VARCHAR2,
                  x_PARENT_TERRITORY_ID            IN     NUMBER,
                  x_TERRITORY_TYPE_ID              IN     NUMBER,
                  x_TEMPLATE_TERRITORY_ID          IN     NUMBER,
                  x_TEMPLATE_FLAG                  IN     VARCHAR2,
                  x_ESCALATION_TERRITORY_ID        IN     NUMBER,
                  x_ESCALATION_TERRITORY_FLAG      IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_RANK                           IN     NUMBER,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_UPDATE_FLAG                    IN     VARCHAR2,
                  x_AUTO_ASSIGN_RESOURCES_FLAG     IN     VARCHAR2,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER,
                  x_NUM_WINNERS                    IN     NUMBER,
                  x_NUM_QUAL                       IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_ALL
            WHERE TERR_ID = x_TERR_ID;
   CURSOR C2 IS SELECT JTF_TERR_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_ALL(
           TERR_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           APPLICATION_SHORT_NAME,
           NAME,
           ENABLED_FLAG,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           PLANNED_FLAG,
           PARENT_TERRITORY_ID,
           TERRITORY_TYPE_ID,
           TEMPLATE_TERRITORY_ID,
           TEMPLATE_FLAG,
           ESCALATION_TERRITORY_ID,
           ESCALATION_TERRITORY_FLAG,
           OVERLAP_ALLOWED_FLAG,
           RANK,
           DESCRIPTION,
           UPDATE_FLAG,
           AUTO_ASSIGN_RESOURCES_FLAG,
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
           ORG_ID,
           NUM_WINNERS,
           NUM_QUAL
          ) VALUES (
          x_TERR_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL,x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL,x_PROGRAM_UPDATE_DATE),
           decode( x_APPLICATION_SHORT_NAME, FND_API.G_MISS_CHAR, NULL,x_APPLICATION_SHORT_NAME),
           decode( x_NAME, FND_API.G_MISS_CHAR, NULL,x_NAME),
           decode( x_ENABLED_FLAG, FND_API.G_MISS_CHAR, 'Y',x_ENABLED_FLAG),
           decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_START_DATE_ACTIVE),
           decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE_ACTIVE),
           decode( x_PLANNED_FLAG, FND_API.G_MISS_CHAR, NULL,x_PLANNED_FLAG),
           decode( x_PARENT_TERRITORY_ID, FND_API.G_MISS_NUM, NULL,x_PARENT_TERRITORY_ID),
           decode( x_TERRITORY_TYPE_ID, FND_API.G_MISS_NUM, NULL,x_TERRITORY_TYPE_ID),
           decode( x_TEMPLATE_TERRITORY_ID, FND_API.G_MISS_NUM, NULL,x_TEMPLATE_TERRITORY_ID),
           decode( x_TEMPLATE_FLAG, FND_API.G_MISS_CHAR, NULL,x_TEMPLATE_FLAG),
           decode( x_ESCALATION_TERRITORY_ID, FND_API.G_MISS_NUM, NULL,x_ESCALATION_TERRITORY_ID),
           decode( x_ESCALATION_TERRITORY_FLAG, FND_API.G_MISS_CHAR, NULL,x_ESCALATION_TERRITORY_FLAG),
           decode( x_OVERLAP_ALLOWED_FLAG, FND_API.G_MISS_CHAR, NULL,x_OVERLAP_ALLOWED_FLAG),
           decode( x_RANK, FND_API.G_MISS_NUM, NULL,x_RANK),
           decode( x_DESCRIPTION, FND_API.G_MISS_CHAR, NULL,x_DESCRIPTION),
           decode( x_UPDATE_FLAG, FND_API.G_MISS_CHAR, NULL,x_UPDATE_FLAG),
           decode( x_AUTO_ASSIGN_RESOURCES_FLAG, FND_API.G_MISS_CHAR, NULL,x_AUTO_ASSIGN_RESOURCES_FLAG),
           decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_CATEGORY),
           decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE1),
           decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE2),
           decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE3),
           decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE4),
           decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE5),
           decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE6),
           decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE7),
           decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE8),
           decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE9),
           decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE10),
           decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE11),
           decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE12),
           decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE13),
           decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE14),
           decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE15),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID),
           decode( x_NUM_WINNERS, FND_API.G_MISS_NUM, NULL,x_NUM_WINNERS),
           decode( x_NUM_QUAL, FND_API.G_MISS_NUM, NULL,x_NUM_QUAL)            );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_TERR_ID                        IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_ALL
    WHERE TERR_ID = x_TERR_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_ID                        IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_REQUEST_ID                     IN     NUMBER,
                  x_PROGRAM_APPLICATION_ID         IN     NUMBER,
                  x_PROGRAM_ID                     IN     NUMBER,
                  x_PROGRAM_UPDATE_DATE            IN     DATE,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_NAME                           IN     VARCHAR2,
                  -- x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_PLANNED_FLAG                   IN     VARCHAR2,
                  x_PARENT_TERRITORY_ID            IN     NUMBER,
                  -- x_TERRITORY_TYPE_ID              IN     NUMBER,
                  x_TEMPLATE_TERRITORY_ID          IN     NUMBER,
                  x_TEMPLATE_FLAG                  IN     VARCHAR2,
                  x_ESCALATION_TERRITORY_ID        IN     NUMBER,
                  x_ESCALATION_TERRITORY_FLAG      IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_RANK                           IN     NUMBER,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_UPDATE_FLAG                    IN     VARCHAR2,
                  x_AUTO_ASSIGN_RESOURCES_FLAG     IN     VARCHAR2,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER,
                  x_NUM_WINNERS                    IN     NUMBER,
                  x_NUM_QUAL                       IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TERR_ALL
    SET
             TERR_ID = decode( x_TERR_ID, FND_API.G_MISS_NUM,TERR_ID,x_TERR_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM,REQUEST_ID,x_REQUEST_ID),
             PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM,PROGRAM_APPLICATION_ID,x_PROGRAM_APPLICATION_ID),
             PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM,PROGRAM_ID,x_PROGRAM_ID),
             PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,PROGRAM_UPDATE_DATE,x_PROGRAM_UPDATE_DATE),
             APPLICATION_SHORT_NAME = decode( x_APPLICATION_SHORT_NAME, FND_API.G_MISS_CHAR,APPLICATION_SHORT_NAME,x_APPLICATION_SHORT_NAME),
             NAME = decode( x_NAME, FND_API.G_MISS_CHAR,NAME,x_NAME),
             --ENABLED_FLAG = decode( x_ENABLED_FLAG,FND_API.G_MISS_CHAR,ENABLED_FLAG,x_ENABLED_FLAG),
             START_DATE_ACTIVE = decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE,START_DATE_ACTIVE,x_START_DATE_ACTIVE),
             END_DATE_ACTIVE = decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE,END_DATE_ACTIVE,x_END_DATE_ACTIVE),
             PLANNED_FLAG = decode( x_PLANNED_FLAG, FND_API.G_MISS_CHAR,PLANNED_FLAG,x_PLANNED_FLAG),
             PARENT_TERRITORY_ID = decode( x_PARENT_TERRITORY_ID, FND_API.G_MISS_NUM,PARENT_TERRITORY_ID,x_PARENT_TERRITORY_ID),
             -- TERRITORY_TYPE_ID = decode( x_TERRITORY_TYPE_ID, FND_API.G_MISS_NUM,TERRITORY_TYPE_ID,x_TERRITORY_TYPE_ID),
             TEMPLATE_TERRITORY_ID = decode( x_TEMPLATE_TERRITORY_ID, FND_API.G_MISS_NUM,TEMPLATE_TERRITORY_ID,x_TEMPLATE_TERRITORY_ID),
             TEMPLATE_FLAG = decode( x_TEMPLATE_FLAG, FND_API.G_MISS_CHAR,TEMPLATE_FLAG,x_TEMPLATE_FLAG),
             ESCALATION_TERRITORY_ID = decode( x_ESCALATION_TERRITORY_ID, FND_API.G_MISS_NUM,ESCALATION_TERRITORY_ID,x_ESCALATION_TERRITORY_ID),
             ESCALATION_TERRITORY_FLAG = decode( x_ESCALATION_TERRITORY_FLAG, FND_API.G_MISS_CHAR,ESCALATION_TERRITORY_FLAG,x_ESCALATION_TERRITORY_FLAG),
             OVERLAP_ALLOWED_FLAG = decode( x_OVERLAP_ALLOWED_FLAG, FND_API.G_MISS_CHAR,OVERLAP_ALLOWED_FLAG,x_OVERLAP_ALLOWED_FLAG),
             RANK = decode( x_RANK, FND_API.G_MISS_NUM,RANK,x_RANK),
             DESCRIPTION = decode( x_DESCRIPTION, FND_API.G_MISS_CHAR,DESCRIPTION,x_DESCRIPTION),
             UPDATE_FLAG = decode( x_UPDATE_FLAG, FND_API.G_MISS_CHAR,UPDATE_FLAG,x_UPDATE_FLAG),
             AUTO_ASSIGN_RESOURCES_FLAG = decode( x_AUTO_ASSIGN_RESOURCES_FLAG, FND_API.G_MISS_CHAR,AUTO_ASSIGN_RESOURCES_FLAG,x_AUTO_ASSIGN_RESOURCES_FLAG),
             ATTRIBUTE_CATEGORY = decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,ATTRIBUTE_CATEGORY,x_ATTRIBUTE_CATEGORY),
             ATTRIBUTE1 = decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE1,x_ATTRIBUTE1),
             ATTRIBUTE2 = decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR,ATTRIBUTE2,x_ATTRIBUTE2),
             ATTRIBUTE3 = decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR,ATTRIBUTE3,x_ATTRIBUTE3),
             ATTRIBUTE4 = decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR,ATTRIBUTE4,x_ATTRIBUTE4),
             ATTRIBUTE5 = decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR,ATTRIBUTE5,x_ATTRIBUTE5),
             ATTRIBUTE6 = decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR,ATTRIBUTE6,x_ATTRIBUTE6),
             ATTRIBUTE7 = decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR,ATTRIBUTE7,x_ATTRIBUTE7),
             ATTRIBUTE8 = decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR,ATTRIBUTE8,x_ATTRIBUTE8),
             ATTRIBUTE9 = decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR,ATTRIBUTE9,x_ATTRIBUTE9),
             ATTRIBUTE10 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR,ATTRIBUTE10,x_ATTRIBUTE10),
             ATTRIBUTE11 = decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR,ATTRIBUTE11,x_ATTRIBUTE11),
             ATTRIBUTE12 = decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR,ATTRIBUTE12,x_ATTRIBUTE12),
             ATTRIBUTE13 = decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR,ATTRIBUTE13,x_ATTRIBUTE13),
             ATTRIBUTE14 = decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR,ATTRIBUTE14,x_ATTRIBUTE14),
             ATTRIBUTE15 = decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR,ATTRIBUTE15,x_ATTRIBUTE15),
             ORG_ID      = decode( x_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, x_ORG_ID),
             NUM_WINNERS      = decode( x_NUM_WINNERS, FND_API.G_MISS_NUM, NUM_WINNERS, x_NUM_WINNERS),
             NUM_QUAL      = decode( x_NUM_QUAL, FND_API.G_MISS_NUM, NUM_QUAL, x_NUM_QUAL)
     where terr_id = X_Terr_Id;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_ID                        IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_REQUEST_ID                     IN     NUMBER,
                  x_PROGRAM_APPLICATION_ID         IN     NUMBER,
                  x_PROGRAM_ID                     IN     NUMBER,
                  x_PROGRAM_UPDATE_DATE            IN     DATE,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_NAME                           IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_PLANNED_FLAG                   IN     VARCHAR2,
                  x_PARENT_TERRITORY_ID            IN     NUMBER,
                  x_TERRITORY_TYPE_ID              IN     NUMBER,
                  x_TEMPLATE_TERRITORY_ID          IN     NUMBER,
                  x_TEMPLATE_FLAG                  IN     VARCHAR2,
                  x_ESCALATION_TERRITORY_ID        IN     NUMBER,
                  x_ESCALATION_TERRITORY_FLAG      IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_RANK                           IN     NUMBER,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_UPDATE_FLAG                    IN     VARCHAR2,
                  x_AUTO_ASSIGN_RESOURCES_FLAG     IN     VARCHAR2,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2,
                  X_ORG_ID                         IN     NUMBER,
                  x_NUM_WINNERS                    IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_ALL
         WHERE TERR_ID = x_TERR_ID
         FOR UPDATE of TERR_ID NOWAIT;
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
           (    ( Recinfo.TERR_ID = x_TERR_ID)
            OR (    ( Recinfo.TERR_ID is NULL )
                AND (  x_TERR_ID is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE is NULL )
                AND (  x_LAST_UPDATE_DATE is NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY is NULL )
                AND (  x_LAST_UPDATED_BY is NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE is NULL )
                AND (  x_CREATION_DATE is NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY is NULL )
                AND (  x_CREATED_BY is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN is NULL )
                AND (  x_LAST_UPDATE_LOGIN is NULL )))
       AND (    ( Recinfo.REQUEST_ID = x_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID is NULL )
                AND (  x_REQUEST_ID is NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = x_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID is NULL )
                AND (  x_PROGRAM_APPLICATION_ID is NULL )))
       AND (    ( Recinfo.PROGRAM_ID = x_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID is NULL )
                AND (  x_PROGRAM_ID is NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = x_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE is NULL )
                AND (  x_PROGRAM_UPDATE_DATE is NULL )))
       AND (    ( Recinfo.APPLICATION_SHORT_NAME = x_APPLICATION_SHORT_NAME)
            OR (    ( Recinfo.APPLICATION_SHORT_NAME is NULL )
                AND (  x_APPLICATION_SHORT_NAME is NULL )))
       AND (    ( Recinfo.NAME = x_NAME)
            OR (    ( Recinfo.NAME is NULL )
                AND (  x_NAME is NULL )))
       AND (    ( Recinfo.ENABLED_FLAG = x_ENABLED_FLAG)
            OR (    ( Recinfo.ENABLED_FLAG is NULL )
                AND (  x_ENABLED_FLAG is NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = x_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE is NULL )
                AND (  x_START_DATE_ACTIVE is NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = x_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE is NULL )
                AND (  x_END_DATE_ACTIVE is NULL )))
       AND (    ( Recinfo.PLANNED_FLAG = x_PLANNED_FLAG)
            OR (    ( Recinfo.PLANNED_FLAG is NULL )
                AND (  x_PLANNED_FLAG is NULL )))
       AND (    ( Recinfo.PARENT_TERRITORY_ID = x_PARENT_TERRITORY_ID)
            OR (    ( Recinfo.PARENT_TERRITORY_ID is NULL )
                AND (  x_PARENT_TERRITORY_ID is NULL )))
       AND (    ( Recinfo.TERRITORY_TYPE_ID = x_TERRITORY_TYPE_ID)
            OR (    ( Recinfo.TERRITORY_TYPE_ID is NULL )
                AND (  x_TERRITORY_TYPE_ID is NULL )))
       AND (    ( Recinfo.TEMPLATE_TERRITORY_ID = x_TEMPLATE_TERRITORY_ID)
            OR (    ( Recinfo.TEMPLATE_TERRITORY_ID is NULL )
                AND (  x_TEMPLATE_TERRITORY_ID is NULL )))
       AND (    ( Recinfo.TEMPLATE_FLAG = x_TEMPLATE_FLAG)
            OR (    ( Recinfo.TEMPLATE_FLAG is NULL )
                AND (  x_TEMPLATE_FLAG is NULL )))
       AND (    ( Recinfo.ESCALATION_TERRITORY_ID = x_ESCALATION_TERRITORY_ID)
            OR (    ( Recinfo.ESCALATION_TERRITORY_ID is NULL )
                AND (  x_ESCALATION_TERRITORY_ID is NULL )))
       AND (    ( Recinfo.ESCALATION_TERRITORY_FLAG = x_ESCALATION_TERRITORY_FLAG)
            OR (    ( Recinfo.ESCALATION_TERRITORY_FLAG is NULL )
                AND (  x_ESCALATION_TERRITORY_FLAG is NULL )))
       AND (    ( Recinfo.OVERLAP_ALLOWED_FLAG = x_OVERLAP_ALLOWED_FLAG)
            OR (    ( Recinfo.OVERLAP_ALLOWED_FLAG is NULL )
                AND (  x_OVERLAP_ALLOWED_FLAG is NULL )))
       AND (    ( Recinfo.RANK = x_RANK)
            OR (    ( Recinfo.RANK is NULL )
                AND (  x_RANK is NULL )))
       AND (    ( Recinfo.DESCRIPTION = x_DESCRIPTION)
            OR (    ( Recinfo.DESCRIPTION is NULL )
                AND (  x_DESCRIPTION is NULL )))
       AND (    ( Recinfo.UPDATE_FLAG = x_UPDATE_FLAG)
            OR (    ( Recinfo.UPDATE_FLAG is NULL )
                AND (  x_UPDATE_FLAG is NULL )))
       AND (    ( Recinfo.AUTO_ASSIGN_RESOURCES_FLAG = x_AUTO_ASSIGN_RESOURCES_FLAG)
            OR (    ( Recinfo.AUTO_ASSIGN_RESOURCES_FLAG is NULL )
                AND (  x_AUTO_ASSIGN_RESOURCES_FLAG is NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = x_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY is NULL )
                AND (  x_ATTRIBUTE_CATEGORY is NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = x_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 is NULL )
                AND (  x_ATTRIBUTE1 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = x_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 is NULL )
                AND (  x_ATTRIBUTE2 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = x_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 is NULL )
                AND (  x_ATTRIBUTE3 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = x_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 is NULL )
                AND (  x_ATTRIBUTE4 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = x_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 is NULL )
                AND (  x_ATTRIBUTE5 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = x_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 is NULL )
                AND (  x_ATTRIBUTE6 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = x_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 is NULL )
                AND (  x_ATTRIBUTE7 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = x_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 is NULL )
                AND (  x_ATTRIBUTE8 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = x_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 is NULL )
                AND (  x_ATTRIBUTE9 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = x_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 is NULL )
                AND (  x_ATTRIBUTE10 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = x_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 is NULL )
                AND (  x_ATTRIBUTE11 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = x_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 is NULL )
                AND (  x_ATTRIBUTE12 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = x_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 is NULL )
                AND (  x_ATTRIBUTE13 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = x_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 is NULL )
                AND (  x_ATTRIBUTE14 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = x_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 is NULL )
                AND (  x_ATTRIBUTE15 is NULL )))
       AND (    ( Recinfo.ORG_ID = x_ORG_ID)
            OR (    ( Recinfo.ORG_ID is NULL )
                AND (  x_ORG_ID is NULL )))
       AND (    ( Recinfo.NUM_WINNERS = x_NUM_WINNERS)
            OR (    ( Recinfo.NUM_WINNERS is NULL )
                AND (  x_NUM_WINNERS is NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END JTF_TERR_PKG;


/

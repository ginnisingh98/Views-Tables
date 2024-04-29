--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_HISTORY_PKG" as
/* $Header: csdtdrhb.pls 120.1 2006/02/24 17:05:28 mshirkol noship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_HISTORY_PKG
-- Purpose          :
-- History          :
-- 02/05/02   travi  Added Object Version Number Column
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_REPAIR_HISTORY_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtrehb.pls';
l_debug        NUMBER := csd_gen_utility_pvt.g_debug_level;

    -- travi 020502 obj ver num
PROCEDURE Insert_Row(
          px_REPAIR_HISTORY_ID   IN OUT NOCOPY NUMBER,
          p_OBJECT_VERSION_NUMBER NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_REPAIR_LINE_ID    NUMBER,
          p_EVENT_CODE    VARCHAR2,
          p_EVENT_DATE    DATE,
          p_QUANTITY    NUMBER,
          p_PARAMN1    NUMBER,
          p_PARAMN2    NUMBER,
          p_PARAMN3    NUMBER,
          p_PARAMN4    NUMBER,
          p_PARAMN5    NUMBER,
          p_PARAMN6    NUMBER,
          p_PARAMN7    NUMBER,
          p_PARAMN8    NUMBER,
          p_PARAMN9    NUMBER,
          p_PARAMN10    NUMBER,
          p_PARAMC1    VARCHAR2,
          p_PARAMC2    VARCHAR2,
          p_PARAMC3    VARCHAR2,
          p_PARAMC4    VARCHAR2,
          p_PARAMC5    VARCHAR2,
          p_PARAMC6    VARCHAR2,
          p_PARAMC7    VARCHAR2,
          p_PARAMC8    VARCHAR2,
          p_PARAMC9    VARCHAR2,
          p_PARAMC10    VARCHAR2,
          p_PARAMD1    DATE,
          p_PARAMD2    DATE,
          p_PARAMD3    DATE,
          p_PARAMD4    DATE,
          p_PARAMD5    DATE,
          p_PARAMD6    DATE,
          p_PARAMD7    DATE,
          p_PARAMD8    DATE,
          p_PARAMD9    DATE,
          p_PARAMD10    DATE,
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
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
   CURSOR C2 IS SELECT CSD_REPAIR_HISTORY_S1.nextval FROM sys.dual;
BEGIN
   If (px_REPAIR_HISTORY_ID IS NULL) OR (px_REPAIR_HISTORY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_REPAIR_HISTORY_ID;
       CLOSE C2;
   End If;
    -- travi 020502 obj ver num
   IF l_debug > 0 THEN
       csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PKG.Insert_Row before inserting');
   END IF;

   INSERT INTO CSD_REPAIR_HISTORY(
           REPAIR_HISTORY_ID,
           OBJECT_VERSION_NUMBER,
           REQUEST_ID,
           PROGRAM_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           REPAIR_LINE_ID,
           EVENT_CODE,
           EVENT_DATE,
           QUANTITY,
           PARAMN1,
           PARAMN2,
           PARAMN3,
           PARAMN4,
           PARAMN5,
           PARAMN6,
           PARAMN7,
           PARAMN8,
           PARAMN9,
           PARAMN10,
           PARAMC1,
           PARAMC2,
           PARAMC3,
           PARAMC4,
           PARAMC5,
           PARAMC6,
           PARAMC7,
           PARAMC8,
           PARAMC9,
           PARAMC10,
           PARAMD1,
           PARAMD2,
           PARAMD3,
           PARAMD4,
           PARAMD5,
           PARAMD6,
           PARAMD7,
           PARAMD8,
           PARAMD9,
           PARAMD10,
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
           LAST_UPDATE_LOGIN
          ) VALUES (
           px_REPAIR_HISTORY_ID,
           -- 4423818 : For insert p_OBJECT_VERSION_NUMBER should be 1
           1,
           -- decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(NULL), p_PROGRAM_UPDATE_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, to_date(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(NULL), p_LAST_UPDATE_DATE),
           decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, NULL, p_REPAIR_LINE_ID),
           decode( p_EVENT_CODE, FND_API.G_MISS_CHAR, NULL, p_EVENT_CODE),
           decode( p_EVENT_DATE, FND_API.G_MISS_DATE, to_date(NULL), p_EVENT_DATE),
           decode( p_QUANTITY, FND_API.G_MISS_NUM, NULL, p_QUANTITY),
           decode( p_PARAMN1, FND_API.G_MISS_NUM, NULL, p_PARAMN1),
           decode( p_PARAMN2, FND_API.G_MISS_NUM, NULL, p_PARAMN2),
           decode( p_PARAMN3, FND_API.G_MISS_NUM, NULL, p_PARAMN3),
           decode( p_PARAMN4, FND_API.G_MISS_NUM, NULL, p_PARAMN4),
           decode( p_PARAMN5, FND_API.G_MISS_NUM, NULL, p_PARAMN5),
           decode( p_PARAMN6, FND_API.G_MISS_NUM, NULL, p_PARAMN6),
           decode( p_PARAMN7, FND_API.G_MISS_NUM, NULL, p_PARAMN7),
           decode( p_PARAMN8, FND_API.G_MISS_NUM, NULL, p_PARAMN8),
           decode( p_PARAMN9, FND_API.G_MISS_NUM, NULL, p_PARAMN9),
           decode( p_PARAMN10, FND_API.G_MISS_NUM, NULL, p_PARAMN10),
           decode( p_PARAMC1, FND_API.G_MISS_CHAR, NULL, p_PARAMC1),
           decode( p_PARAMC2, FND_API.G_MISS_CHAR, NULL, p_PARAMC2),
           decode( p_PARAMC3, FND_API.G_MISS_CHAR, NULL, p_PARAMC3),
           decode( p_PARAMC4, FND_API.G_MISS_CHAR, NULL, p_PARAMC4),
           decode( p_PARAMC5, FND_API.G_MISS_CHAR, NULL, p_PARAMC5),
           decode( p_PARAMC6, FND_API.G_MISS_CHAR, NULL, p_PARAMC6),
           decode( p_PARAMC7, FND_API.G_MISS_CHAR, NULL, p_PARAMC7),
           decode( p_PARAMC8, FND_API.G_MISS_CHAR, NULL, p_PARAMC8),
           decode( p_PARAMC9, FND_API.G_MISS_CHAR, NULL, p_PARAMC9),
           decode( p_PARAMC10, FND_API.G_MISS_CHAR, NULL, p_PARAMC10),
           decode( p_PARAMD1, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD1),
           decode( p_PARAMD2, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD2),
           decode( p_PARAMD3, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD3),
           decode( p_PARAMD4, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD4),
           decode( p_PARAMD5, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD5),
           decode( p_PARAMD6, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD6),
           decode( p_PARAMD7, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD7),
           decode( p_PARAMD8, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD8),
           decode( p_PARAMD9, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD9),
           decode( p_PARAMD10, FND_API.G_MISS_DATE, to_date(NULL), p_PARAMD10),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
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
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN));
   IF l_debug > 0 THEN
       csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PKG.Insert_Row after inserting');
   END IF;

End Insert_Row;

    -- travi 020502 obj ver num
PROCEDURE Update_Row(
          p_REPAIR_HISTORY_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_REPAIR_LINE_ID    NUMBER,
          p_EVENT_CODE    VARCHAR2,
          p_EVENT_DATE    DATE,
          p_QUANTITY    NUMBER,
          p_PARAMN1    NUMBER,
          p_PARAMN2    NUMBER,
          p_PARAMN3    NUMBER,
          p_PARAMN4    NUMBER,
          p_PARAMN5    NUMBER,
          p_PARAMN6    NUMBER,
          p_PARAMN7    NUMBER,
          p_PARAMN8    NUMBER,
          p_PARAMN9    NUMBER,
          p_PARAMN10    NUMBER,
          p_PARAMC1    VARCHAR2,
          p_PARAMC2    VARCHAR2,
          p_PARAMC3    VARCHAR2,
          p_PARAMC4    VARCHAR2,
          p_PARAMC5    VARCHAR2,
          p_PARAMC6    VARCHAR2,
          p_PARAMC7    VARCHAR2,
          p_PARAMC8    VARCHAR2,
          p_PARAMC9    VARCHAR2,
          p_PARAMC10    VARCHAR2,
          p_PARAMD1    DATE,
          p_PARAMD2    DATE,
          p_PARAMD3    DATE,
          p_PARAMD4    DATE,
          p_PARAMD5    DATE,
          p_PARAMD6    DATE,
          p_PARAMD7    DATE,
          p_PARAMD8    DATE,
          p_PARAMD9    DATE,
          p_PARAMD10    DATE,
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
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
 BEGIN
    -- travi 020502 obj ver num
    IF l_debug = 'Y' THEN
        csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PKG.Update_Row before update');
    END IF;

    Update CSD_REPAIR_HISTORY
    SET
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              REPAIR_LINE_ID = decode( p_REPAIR_LINE_ID, FND_API.G_MISS_NUM, REPAIR_LINE_ID, p_REPAIR_LINE_ID),
              EVENT_CODE = decode( p_EVENT_CODE, FND_API.G_MISS_CHAR, EVENT_CODE, p_EVENT_CODE),
              EVENT_DATE = decode( p_EVENT_DATE, FND_API.G_MISS_DATE, EVENT_DATE, p_EVENT_DATE),
              QUANTITY = decode( p_QUANTITY, FND_API.G_MISS_NUM, QUANTITY, p_QUANTITY),
              PARAMN1 = decode( p_PARAMN1, FND_API.G_MISS_NUM, PARAMN1, p_PARAMN1),
              PARAMN2 = decode( p_PARAMN2, FND_API.G_MISS_NUM, PARAMN2, p_PARAMN2),
              PARAMN3 = decode( p_PARAMN3, FND_API.G_MISS_NUM, PARAMN3, p_PARAMN3),
              PARAMN4 = decode( p_PARAMN4, FND_API.G_MISS_NUM, PARAMN4, p_PARAMN4),
              PARAMN5 = decode( p_PARAMN5, FND_API.G_MISS_NUM, PARAMN5, p_PARAMN5),
              PARAMN6 = decode( p_PARAMN6, FND_API.G_MISS_NUM, PARAMN6, p_PARAMN6),
              PARAMN7 = decode( p_PARAMN7, FND_API.G_MISS_NUM, PARAMN7, p_PARAMN7),
              PARAMN8 = decode( p_PARAMN8, FND_API.G_MISS_NUM, PARAMN8, p_PARAMN8),
              PARAMN9 = decode( p_PARAMN9, FND_API.G_MISS_NUM, PARAMN9, p_PARAMN9),
              PARAMN10 = decode( p_PARAMN10, FND_API.G_MISS_NUM, PARAMN10, p_PARAMN10),
              PARAMC1 = decode( p_PARAMC1, FND_API.G_MISS_CHAR, PARAMC1, p_PARAMC1),
              PARAMC2 = decode( p_PARAMC2, FND_API.G_MISS_CHAR, PARAMC2, p_PARAMC2),
              PARAMC3 = decode( p_PARAMC3, FND_API.G_MISS_CHAR, PARAMC3, p_PARAMC3),
              PARAMC4 = decode( p_PARAMC4, FND_API.G_MISS_CHAR, PARAMC4, p_PARAMC4),
              PARAMC5 = decode( p_PARAMC5, FND_API.G_MISS_CHAR, PARAMC5, p_PARAMC5),
              PARAMC6 = decode( p_PARAMC6, FND_API.G_MISS_CHAR, PARAMC6, p_PARAMC6),
              PARAMC7 = decode( p_PARAMC7, FND_API.G_MISS_CHAR, PARAMC7, p_PARAMC7),
              PARAMC8 = decode( p_PARAMC8, FND_API.G_MISS_CHAR, PARAMC8, p_PARAMC8),
              PARAMC9 = decode( p_PARAMC9, FND_API.G_MISS_CHAR, PARAMC9, p_PARAMC9),
              PARAMC10 = decode( p_PARAMC10, FND_API.G_MISS_CHAR, PARAMC10, p_PARAMC10),
              PARAMD1 = decode( p_PARAMD1, FND_API.G_MISS_DATE, PARAMD1, p_PARAMD1),
              PARAMD2 = decode( p_PARAMD2, FND_API.G_MISS_DATE, PARAMD2, p_PARAMD2),
              PARAMD3 = decode( p_PARAMD3, FND_API.G_MISS_DATE, PARAMD3, p_PARAMD3),
              PARAMD4 = decode( p_PARAMD4, FND_API.G_MISS_DATE, PARAMD4, p_PARAMD4),
              PARAMD5 = decode( p_PARAMD5, FND_API.G_MISS_DATE, PARAMD5, p_PARAMD5),
              PARAMD6 = decode( p_PARAMD6, FND_API.G_MISS_DATE, PARAMD6, p_PARAMD6),
              PARAMD7 = decode( p_PARAMD7, FND_API.G_MISS_DATE, PARAMD7, p_PARAMD7),
              PARAMD8 = decode( p_PARAMD8, FND_API.G_MISS_DATE, PARAMD8, p_PARAMD8),
              PARAMD9 = decode( p_PARAMD9, FND_API.G_MISS_DATE, PARAMD9, p_PARAMD9),
              PARAMD10 = decode( p_PARAMD10, FND_API.G_MISS_DATE, PARAMD10, p_PARAMD10),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
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
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
    where REPAIR_HISTORY_ID = p_REPAIR_HISTORY_ID;

    IF l_debug = 'Y' THEN
        csd_gen_utility_pvt.add('CSD_REPAIR_HISTORY_PKG.Update_Row after update ');
    END IF;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_REPAIR_HISTORY_ID  NUMBER,
    p_OBJECT_VERSION_NUMBER NUMBER)
 IS
 BEGIN
   DELETE FROM CSD_REPAIR_HISTORY
    WHERE REPAIR_HISTORY_ID = p_REPAIR_HISTORY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

    -- travi 020502 obj ver num
PROCEDURE Lock_Row(
          p_REPAIR_HISTORY_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_REPAIR_LINE_ID    NUMBER,
          p_EVENT_CODE    VARCHAR2,
          p_EVENT_DATE    DATE,
          p_QUANTITY    NUMBER,
          p_PARAMN1    NUMBER,
          p_PARAMN2    NUMBER,
          p_PARAMN3    NUMBER,
          p_PARAMN4    NUMBER,
          p_PARAMN5    NUMBER,
          p_PARAMN6    NUMBER,
          p_PARAMN7    NUMBER,
          p_PARAMN8    NUMBER,
          p_PARAMN9    NUMBER,
          p_PARAMN10    NUMBER,
          p_PARAMC1    VARCHAR2,
          p_PARAMC2    VARCHAR2,
          p_PARAMC3    VARCHAR2,
          p_PARAMC4    VARCHAR2,
          p_PARAMC5    VARCHAR2,
          p_PARAMC6    VARCHAR2,
          p_PARAMC7    VARCHAR2,
          p_PARAMC8    VARCHAR2,
          p_PARAMC9    VARCHAR2,
          p_PARAMC10    VARCHAR2,
          p_PARAMD1    DATE,
          p_PARAMD2    DATE,
          p_PARAMD3    DATE,
          p_PARAMD4    DATE,
          p_PARAMD5    DATE,
          p_PARAMD6    DATE,
          p_PARAMD7    DATE,
          p_PARAMD8    DATE,
          p_PARAMD9    DATE,
          p_PARAMD10    DATE,
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
          p_LAST_UPDATE_LOGIN    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSD_REPAIR_HISTORY
        WHERE REPAIR_HISTORY_ID =  p_REPAIR_HISTORY_ID
        FOR UPDATE of REPAIR_HISTORY_ID NOWAIT;
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

    -- travi 020502 obj ver num
    if (
           (      Recinfo.REPAIR_HISTORY_ID = p_REPAIR_HISTORY_ID)
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
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
       AND (    ( Recinfo.REPAIR_LINE_ID = p_REPAIR_LINE_ID)
            OR (    ( Recinfo.REPAIR_LINE_ID IS NULL )
                AND (  p_REPAIR_LINE_ID IS NULL )))
       AND (    ( Recinfo.EVENT_CODE = p_EVENT_CODE)
            OR (    ( Recinfo.EVENT_CODE IS NULL )
                AND (  p_EVENT_CODE IS NULL )))
       AND (    ( Recinfo.EVENT_DATE = p_EVENT_DATE)
            OR (    ( Recinfo.EVENT_DATE IS NULL )
                AND (  p_EVENT_DATE IS NULL )))
       AND (    ( Recinfo.QUANTITY = p_QUANTITY)
            OR (    ( Recinfo.QUANTITY IS NULL )
                AND (  p_QUANTITY IS NULL )))
       AND (    ( Recinfo.PARAMN1 = p_PARAMN1)
            OR (    ( Recinfo.PARAMN1 IS NULL )
                AND (  p_PARAMN1 IS NULL )))
       AND (    ( Recinfo.PARAMN2 = p_PARAMN2)
            OR (    ( Recinfo.PARAMN2 IS NULL )
                AND (  p_PARAMN2 IS NULL )))
       AND (    ( Recinfo.PARAMN3 = p_PARAMN3)
            OR (    ( Recinfo.PARAMN3 IS NULL )
                AND (  p_PARAMN3 IS NULL )))
       AND (    ( Recinfo.PARAMN4 = p_PARAMN4)
            OR (    ( Recinfo.PARAMN4 IS NULL )
                AND (  p_PARAMN4 IS NULL )))
       AND (    ( Recinfo.PARAMN5 = p_PARAMN5)
            OR (    ( Recinfo.PARAMN5 IS NULL )
                AND (  p_PARAMN5 IS NULL )))
       AND (    ( Recinfo.PARAMN6 = p_PARAMN6)
            OR (    ( Recinfo.PARAMN6 IS NULL )
                AND (  p_PARAMN6 IS NULL )))
       AND (    ( Recinfo.PARAMN7 = p_PARAMN7)
            OR (    ( Recinfo.PARAMN7 IS NULL )
                AND (  p_PARAMN7 IS NULL )))
       AND (    ( Recinfo.PARAMN8 = p_PARAMN8)
            OR (    ( Recinfo.PARAMN8 IS NULL )
                AND (  p_PARAMN8 IS NULL )))
       AND (    ( Recinfo.PARAMN9 = p_PARAMN9)
            OR (    ( Recinfo.PARAMN9 IS NULL )
                AND (  p_PARAMN9 IS NULL )))
       AND (    ( Recinfo.PARAMN10 = p_PARAMN10)
            OR (    ( Recinfo.PARAMN10 IS NULL )
                AND (  p_PARAMN10 IS NULL )))
       AND (    ( Recinfo.PARAMC1 = p_PARAMC1)
            OR (    ( Recinfo.PARAMC1 IS NULL )
                AND (  p_PARAMC1 IS NULL )))
       AND (    ( Recinfo.PARAMC2 = p_PARAMC2)
            OR (    ( Recinfo.PARAMC2 IS NULL )
                AND (  p_PARAMC2 IS NULL )))
       AND (    ( Recinfo.PARAMC3 = p_PARAMC3)
            OR (    ( Recinfo.PARAMC3 IS NULL )
                AND (  p_PARAMC3 IS NULL )))
       AND (    ( Recinfo.PARAMC4 = p_PARAMC4)
            OR (    ( Recinfo.PARAMC4 IS NULL )
                AND (  p_PARAMC4 IS NULL )))
       AND (    ( Recinfo.PARAMC5 = p_PARAMC5)
            OR (    ( Recinfo.PARAMC5 IS NULL )
                AND (  p_PARAMC5 IS NULL )))
       AND (    ( Recinfo.PARAMC6 = p_PARAMC6)
            OR (    ( Recinfo.PARAMC6 IS NULL )
                AND (  p_PARAMC6 IS NULL )))
       AND (    ( Recinfo.PARAMC7 = p_PARAMC7)
            OR (    ( Recinfo.PARAMC7 IS NULL )
                AND (  p_PARAMC7 IS NULL )))
       AND (    ( Recinfo.PARAMC8 = p_PARAMC8)
            OR (    ( Recinfo.PARAMC8 IS NULL )
                AND (  p_PARAMC8 IS NULL )))
       AND (    ( Recinfo.PARAMC9 = p_PARAMC9)
            OR (    ( Recinfo.PARAMC9 IS NULL )
                AND (  p_PARAMC9 IS NULL )))
       AND (    ( Recinfo.PARAMC10 = p_PARAMC10)
            OR (    ( Recinfo.PARAMC10 IS NULL )
                AND (  p_PARAMC10 IS NULL )))
       AND (    ( Recinfo.PARAMD1 = p_PARAMD1)
            OR (    ( Recinfo.PARAMD1 IS NULL )
                AND (  p_PARAMD1 IS NULL )))
       AND (    ( Recinfo.PARAMD2 = p_PARAMD2)
            OR (    ( Recinfo.PARAMD2 IS NULL )
                AND (  p_PARAMD2 IS NULL )))
       AND (    ( Recinfo.PARAMD3 = p_PARAMD3)
            OR (    ( Recinfo.PARAMD3 IS NULL )
                AND (  p_PARAMD3 IS NULL )))
       AND (    ( Recinfo.PARAMD4 = p_PARAMD4)
            OR (    ( Recinfo.PARAMD4 IS NULL )
                AND (  p_PARAMD4 IS NULL )))
       AND (    ( Recinfo.PARAMD5 = p_PARAMD5)
            OR (    ( Recinfo.PARAMD5 IS NULL )
                AND (  p_PARAMD5 IS NULL )))
       AND (    ( Recinfo.PARAMD6 = p_PARAMD6)
            OR (    ( Recinfo.PARAMD6 IS NULL )
                AND (  p_PARAMD6 IS NULL )))
       AND (    ( Recinfo.PARAMD7 = p_PARAMD7)
            OR (    ( Recinfo.PARAMD7 IS NULL )
                AND (  p_PARAMD7 IS NULL )))
       AND (    ( Recinfo.PARAMD8 = p_PARAMD8)
            OR (    ( Recinfo.PARAMD8 IS NULL )
                AND (  p_PARAMD8 IS NULL )))
       AND (    ( Recinfo.PARAMD9 = p_PARAMD9)
            OR (    ( Recinfo.PARAMD9 IS NULL )
                AND (  p_PARAMD9 IS NULL )))
       AND (    ( Recinfo.PARAMD10 = p_PARAMD10)
            OR (    ( Recinfo.PARAMD10 IS NULL )
                AND (  p_PARAMD10 IS NULL )))
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

End CSD_REPAIR_HISTORY_PKG;

/

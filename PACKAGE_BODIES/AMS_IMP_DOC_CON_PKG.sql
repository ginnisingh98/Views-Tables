--------------------------------------------------------
--  DDL for Package Body AMS_IMP_DOC_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_DOC_CON_PKG" as
 /* $Header: amstidcb.pls 115.4 2002/11/14 21:59:18 jieli noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          AMS_IMP_DOC_CON_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- This Api is generated with Latest version of
 -- Rosetta, where g_miss indicates NULL and
 -- NULL indicates missing value. Rosetta Version 1.55
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IMP_DOC_CON_PKG';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstidcb.pls';




 --  ========================================================
 --
 --  NAME
 --  Insert_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
 --
 --  ========================================================
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
           px_imp_doc_content_id   IN OUT NOCOPY NUMBER,
           p_last_updated_by    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_last_update_date    DATE,
           p_creation_date    DATE,
           p_import_list_header_id    NUMBER,
           p_file_id NUMBER,
           p_file_name VARCHAR2
 )

  IS
    x_rowid    VARCHAR2(30);


 BEGIN


    px_object_version_number := nvl(px_object_version_number, 1);


    INSERT INTO ams_imp_doc_content (
            imp_doc_content_id,
            last_updated_by,
            object_version_number,
            created_by,
            last_update_login,
            last_update_date,
            creation_date,
            import_list_header_id,
				file_id,
				file_name
    ) VALUES (
            DECODE( px_imp_doc_content_id, FND_API.G_MISS_NUM, NULL, px_imp_doc_content_id),
            DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
            DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
            DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
            DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
            DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
            DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
            DECODE( p_import_list_header_id, FND_API.G_MISS_NUM, NULL, p_import_list_header_id),
            DECODE( p_file_id, FND_API.g_miss_num, NULL, p_file_id),
            DECODE( p_file_name, FND_API.G_MISS_CHAR, NULL, p_file_name));

 END Insert_Row;




 --  ========================================================
 --
 --  NAME
 --  Update_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
 --
 --  ========================================================
 PROCEDURE Update_Row(
           p_imp_doc_content_id    NUMBER,
           p_last_updated_by    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_last_update_login    NUMBER,
           p_last_update_date    DATE,
           p_import_list_header_id    NUMBER,
           p_file_id NUMBER,
           p_file_name VARCHAR2
 )

  IS
  BEGIN
     Update ams_imp_doc_content
     SET
               imp_doc_content_id = DECODE( p_imp_doc_content_id, null, imp_doc_content_id, FND_API.G_MISS_NUM, null, p_imp_doc_content_id),
               last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
               last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
               last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
               import_list_header_id = DECODE( p_import_list_header_id, null, import_list_header_id, FND_API.G_MISS_NUM, null, p_import_list_header_id),
               file_id = DECODE( p_file_id, null, file_id, FND_API.g_miss_num, null, p_file_id),
               file_name = DECODE( p_file_name, null, file_name, FND_API.G_MISS_CHAR, null, p_file_name)
    WHERE imp_doc_content_id = p_imp_doc_content_id
    AND   object_version_number = px_object_version_number;


    IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    px_object_version_number := nvl(px_object_version_number,0) + 1;

 END Update_Row;




 --  ========================================================
 --
 --  NAME
 --  Delete_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
 --
 --  ========================================================
 PROCEDURE Delete_Row(
     p_imp_doc_content_id  NUMBER,
     p_object_version_number  NUMBER)
  IS
  BEGIN
    DELETE FROM ams_imp_doc_content
     WHERE imp_doc_content_id = p_imp_doc_content_id
     AND object_version_number = p_object_version_number;
    If (SQL%NOTFOUND) then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;
  END Delete_Row ;





 --  ========================================================
 --
 --  NAME
 --  Lock_Row
 --
 --  PURPOSE
 --
 --  NOTES
 --
 --  HISTORY
 --
 --  ========================================================
 PROCEDURE Lock_Row(
     p_imp_doc_content_id  NUMBER)
  IS
    CURSOR C IS
         SELECT *
          FROM ams_imp_doc_content
         WHERE imp_doc_content_id =  p_imp_doc_content_id
         FOR UPDATE OF imp_doc_content_id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
     OPEN c;
     FETCH c INTO Recinfo;
     IF (c%NOTFOUND) THEN
         CLOSE c;
         FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
     CLOSE C;
 END Lock_Row;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------




END AMS_IMP_DOC_CON_PKG;

/

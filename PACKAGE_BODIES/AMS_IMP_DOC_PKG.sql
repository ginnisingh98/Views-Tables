--------------------------------------------------------
--  DDL for Package Body AMS_IMP_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_DOC_PKG" as
 /* $Header: amstidob.pls 115.4 2002/11/14 21:59:26 jieli noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          AMS_Imp_Doc_PKG
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


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Imp_Doc_PKG';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstidob.pls';




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
           px_imp_document_id   IN OUT NOCOPY NUMBER,
           p_last_updated_by    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_last_update_date    DATE,
           p_creation_date    DATE,
           p_import_list_header_id    NUMBER,
           p_content_text    CLOB := NULL,
           p_dtd_text    CLOB := NULL,
           p_file_type    VARCHAR2,
           p_filter_content_text    CLOB := NULL,
           p_file_size    NUMBER
 )

  IS
    x_rowid    VARCHAR2(30);


 BEGIN


    px_object_version_number := nvl(px_object_version_number, 1);


    INSERT INTO ams_imp_documents(
            imp_document_id,
            last_updated_by,
            object_version_number,
            --last_update_by,
            created_by,
            --creation_date,
            last_update_login,
            --created_by,
            last_update_date,
            --last_update_login,
            creation_date,
            --object_version_number,
            import_list_header_id,
            --import_list_header_id,
            --content_text,
            --content_text,
            --dtd_text,
            --dtd_text,
            file_type,
            --filter_content_text,
            --filter_content_text,
            --file_type,
            --file_size,
            file_size
            --last_updated_by
    ) VALUES (
            DECODE( px_imp_document_id, FND_API.G_MISS_NUM, NULL, px_imp_document_id),
            DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
            DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
            --DECODE( p_last_update_by, FND_API.G_MISS_NUM, NULL, p_last_update_by),
            DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
            --DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
            DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
            --DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
            DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
            --DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
            DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
            --DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
            --DECODE( p_import_list_header_id, FND_API.G_MISS_NUM, NULL, p_import_list_header_id),
            DECODE( p_import_list_header_id, FND_API.G_MISS_NUM, NULL, p_import_list_header_id),
            --DECODE( p_content_text, FND_API.g_miss_char, NULL, p_content_text),
            --DECODE( p_content_text, FND_API.g_miss_char, NULL, p_content_text),
            --DECODE( p_dtd_text, FND_API.g_miss_char, NULL, p_dtd_text),
            --DECODE( p_dtd_text, FND_API.g_miss_char, NULL, p_dtd_text),
            DECODE( p_file_type, FND_API.g_miss_char, NULL, p_file_type),
            --DECODE( p_filter_content_text, FND_API.g_miss_char, NULL, p_filter_content_text),
            --DECODE( p_filter_content_text, FND_API.g_miss_char, NULL, p_filter_content_text),
            --DECODE( p_file_type, FND_API.g_miss_char, NULL, p_file_type),
            --DECODE( p_file_size, FND_API.G_MISS_NUM, NULL, p_file_size),
            DECODE( p_file_size, FND_API.G_MISS_NUM, NULL, p_file_size));
            --DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by));

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
           p_imp_document_id    NUMBER,
           p_last_updated_by    NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER,
           p_last_update_login    NUMBER,
           p_last_update_date    DATE,
           p_import_list_header_id    NUMBER,
           p_content_text    CLOB := NULL,
           p_dtd_text    CLOB := NULL,
           p_file_type    VARCHAR2,
           p_filter_content_text    CLOB := NULL,
           p_file_size    NUMBER
 )

  IS
  BEGIN
     Update ams_imp_documents
     SET
               imp_document_id = DECODE( p_imp_document_id, null, imp_document_id, FND_API.G_MISS_NUM, null, p_imp_document_id),
               --imp_document_id = DECODE( p_imp_document_id, null, imp_document_id, FND_API.G_MISS_NUM, null, p_imp_document_id),
               last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
               --last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
 --            object_version_number = DECODE( px_object_version_number, null , nvl(object_version_number,1), FND_API.G_MISS_NUM, 1, p_object_version_number),
               --last_update_by = DECODE( p_last_update_by, null, last_update_by, FND_API.G_MISS_NUM, null, p_last_update_by),
 --            created_by = DECODE( p_created_by, null, created_by, FND_API.G_MISS_NUM, null, p_created_by),
 --            creation_date = DECODE( p_creation_date, null, creation_date, FND_API.G_MISS_DATE, null, p_creation_date),
               last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
 --            created_by = DECODE( p_created_by, null, created_by, FND_API.G_MISS_NUM, null, p_created_by),
               last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
               --last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
 --            creation_date = DECODE( p_creation_date, null, creation_date, FND_API.G_MISS_DATE, null, p_creation_date),
 --            object_version_number = DECODE( px_object_version_number, null , nvl(object_version_number,1), FND_API.G_MISS_NUM, 1, p_object_version_number),
               --import_list_header_id = DECODE( p_import_list_header_id, null, import_list_header_id, FND_API.G_MISS_NUM, null, p_import_list_header_id),
               import_list_header_id = DECODE( p_import_list_header_id, null, import_list_header_id, FND_API.G_MISS_NUM, null, p_import_list_header_id),
               --content_text = DECODE( p_content_text, null, content_text, FND_API.g_miss_char, null, p_content_text),
               --content_text = DECODE( p_content_text, null, content_text, FND_API.g_miss_char, null, p_content_text),
               --dtd_text = DECODE( p_dtd_text, null, dtd_text, FND_API.g_miss_char, null, p_dtd_text),
               --dtd_text = DECODE( p_dtd_text, null, dtd_text, FND_API.g_miss_char, null, p_dtd_text),
               file_type = DECODE( p_file_type, null, file_type, FND_API.g_miss_char, null, p_file_type),
               --filter_content_text = DECODE( p_filter_content_text, null, filter_content_text, FND_API.g_miss_char, null, p_filter_content_text),
               --filter_content_text = DECODE( p_filter_content_text, null, filter_content_text, FND_API.g_miss_char, null, p_filter_content_text),
               --file_type = DECODE( p_file_type, null, file_type, FND_API.g_miss_char, null, p_file_type),
               --file_size = DECODE( p_file_size, null, file_size, FND_API.G_MISS_NUM, null, p_file_size),
               file_size = DECODE( p_file_size, null, file_size, FND_API.G_MISS_NUM, null, p_file_size)
               --last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by)
    WHERE imp_document_id = p_imp_document_id
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
     p_imp_document_id  NUMBER,
     p_object_version_number  NUMBER)
  IS
  BEGIN
    DELETE FROM ams_imp_documents
     WHERE imp_document_id = p_imp_document_id
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
     p_imp_document_id  NUMBER)
  IS
    CURSOR C IS
         SELECT *
          FROM ams_imp_documents
         WHERE imp_document_id =  p_imp_document_id
         FOR UPDATE OF imp_document_id NOWAIT;
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




END AMS_IMP_DOC_PKG;

/

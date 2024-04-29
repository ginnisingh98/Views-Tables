--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_BATCH_LINE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_BATCH_LINE_MAPS_PKG" as
/* $Header: ozftrblb.pls 120.1.12000000.2 2007/05/28 10:29:44 ateotia ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_BATCH_LINE_MAPS_PKG
-- Purpose
--
-- History
-- Anuj Teotia              28/05/2007       bug # 5997978 fixed
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_RESALE_BATCH_LINE_MAPS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftrblb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_resale_batch_line_map_id   IN OUT NOCOPY NUMBER,
          p_resale_batch_id    NUMBER,
          p_resale_line_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          px_org_id   IN OUT  NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);
   l_batch_org_id NUMBER; -- bug # 5997978 fixed

BEGIN

   -- Start: bug # 5997978 fixed
   IF px_org_id IS NULL THEN
      OPEN OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr(p_resale_batch_id);
      FETCH OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr INTO l_batch_org_id;
      CLOSE OZF_RESALE_COMMON_PVT.g_resale_batch_org_id_csr;
      px_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);
      IF (l_batch_org_id IS NULL OR px_org_id IS NULL) THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      /*IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
      SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
      INTO px_org_id
      FROM DUAL; */
   END IF;
   -- End: bug # 5997978 fixed

   px_object_version_number := 1;


   INSERT INTO OZF_RESALE_BATCH_LINE_MAPS_ALL(
           resale_batch_line_map_id,
           resale_batch_id,
           resale_line_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           request_id,
           created_by,
           created_from,
           last_update_login,
           program_application_id,
           program_update_date,
           program_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           org_id
   ) VALUES (
           px_resale_batch_line_map_id,
           p_resale_batch_id,
           p_resale_line_id,
           px_object_version_number,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_request_id,
           p_created_by,
           p_created_from,
           p_last_update_login,
           p_program_application_id,
           p_program_update_date,
           p_program_id,
           p_attribute_category,
           p_attribute1,
           p_attribute2,
           p_attribute3,
           p_attribute4,
           p_attribute5,
           p_attribute6,
           p_attribute7,
           p_attribute8,
           p_attribute9,
           p_attribute10,
           p_attribute11,
           p_attribute12,
           p_attribute13,
           p_attribute14,
           p_attribute15,
           px_org_id);
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_resale_batch_line_map_id    NUMBER,
          p_resale_batch_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_request_id    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER)

 IS
 BEGIN
    Update OZF_RESALE_BATCH_LINE_MAPS_ALL
    SET
              resale_batch_line_map_id = p_resale_batch_line_map_id,
              resale_batch_id = p_resale_batch_id,
              resale_line_id = p_resale_line_id,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              request_id = p_request_id,
              created_from = p_created_from,
              last_update_login = p_last_update_login,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              attribute_category = p_attribute_category,
              attribute1 = p_attribute1,
              attribute2 = p_attribute2,
              attribute3 = p_attribute3,
              attribute4 = p_attribute4,
              attribute5 = p_attribute5,
              attribute6 = p_attribute6,
              attribute7 = p_attribute7,
              attribute8 = p_attribute8,
              attribute9 = p_attribute9,
              attribute10 = p_attribute10,
              attribute11 = p_attribute11,
              attribute12 = p_attribute12,
              attribute13 = p_attribute13,
              attribute14 = p_attribute14,
              attribute15 = p_attribute15,
              org_id = p_org_id
   WHERE RESALE_BATCH_LINE_MAP_ID = p_RESALE_BATCH_LINE_MAP_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_RESALE_BATCH_LINE_MAP_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_RESALE_BATCH_LINE_MAPS_ALL
    WHERE RESALE_BATCH_LINE_MAP_ID = p_RESALE_BATCH_LINE_MAP_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_resale_batch_line_map_id    NUMBER,
          p_resale_batch_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_RESALE_BATCH_LINE_MAPS_ALL
        WHERE RESALE_BATCH_LINE_MAP_ID =  p_RESALE_BATCH_LINE_MAP_ID
        FOR UPDATE of RESALE_BATCH_LINE_MAP_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.resale_batch_line_map_id = p_resale_batch_line_map_id)
       AND (    ( Recinfo.resale_batch_id = p_resale_batch_id)
            OR (    ( Recinfo.resale_batch_id IS NULL )
                AND (  p_resale_batch_id IS NULL )))
       AND (    ( Recinfo.resale_line_id = p_resale_line_id)
            OR (    ( Recinfo.resale_line_id IS NULL )
                AND (  p_resale_line_id IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_RESALE_BATCH_LINE_MAPS_PKG;

/

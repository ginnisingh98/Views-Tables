--------------------------------------------------------
--  DDL for Package Body AMS_IMP_XML_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_XML_ELEMENTS_PKG" as
/* $Header: amslxelb.pls 115.6 2002/11/14 21:56:56 jieli noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IMP_XML_ELEMENTS_PKG
-- Purpose
--    Manage XML Elements.
--
-- History
--    05/13/2002 DMVINCEN  Created.
--    05/21/2002 DMVINCEN  Removed created_by and creation_date from update.
--    05/21/2002 DMVINCEN  Alway increment object version number on update.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IMP_XML_ELEMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amslxelb.pls';


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
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_imp_xml_element_id   IN OUT NOCOPY NUMBER,
          p_last_updated_by    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_last_update_date    DATE,
          p_creation_date    DATE,
          p_imp_xml_document_id    NUMBER,
          p_order_initial    NUMBER,
          p_order_final    NUMBER,
          p_column_name    VARCHAR2,
          p_data    VARCHAR2,
          p_num_attr    NUMBER,
          p_data_type    VARCHAR2,
          p_load_status    VARCHAR2,
          p_error_text    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_IMP_XML_ELEMENTS(
           imp_xml_element_id,
           last_updated_by,
           object_version_number,
           created_by,
           last_update_login,
           last_update_date,
           creation_date,
           imp_xml_document_id,
           order_initial,
           order_final,
           column_name,
           data,
           num_attr,
           data_type,
           load_status,
           error_text
   ) VALUES (
           DECODE( px_imp_xml_element_id, FND_API.g_miss_num, NULL, px_imp_xml_element_id),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_imp_xml_document_id, FND_API.g_miss_num, NULL, p_imp_xml_document_id),
           DECODE( p_order_initial, FND_API.g_miss_num, NULL, p_order_initial),
           DECODE( p_order_final, FND_API.g_miss_num, NULL, p_order_final),
           DECODE( p_column_name, FND_API.g_miss_char, NULL, p_column_name),
           DECODE( p_data, FND_API.g_miss_char, NULL, p_data),
           DECODE( p_num_attr, FND_API.g_miss_num, NULL, p_num_attr),
           DECODE( p_data_type, FND_API.g_miss_char, NULL, p_data_type),
           DECODE( p_load_status, FND_API.g_miss_char, NULL, p_load_status),
           DECODE( p_error_text, FND_API.g_miss_char, NULL, p_error_text));
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
          p_imp_xml_element_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER,
--          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_last_update_date    DATE,
--          p_creation_date    DATE,
          p_imp_xml_document_id    NUMBER,
          p_order_initial    NUMBER,
          p_order_final    NUMBER,
          p_column_name    VARCHAR2,
          p_data    VARCHAR2,
          p_num_attr    NUMBER,
          p_data_type    VARCHAR2,
          p_load_status    VARCHAR2,
          p_error_text    VARCHAR2)

 IS
 BEGIN
    Update AMS_IMP_XML_ELEMENTS
    SET
              imp_xml_element_id = DECODE( p_imp_xml_element_id, FND_API.g_miss_num, imp_xml_element_id, p_imp_xml_element_id),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              object_version_number = object_version_number + 1, --DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
--              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
--              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              imp_xml_document_id = DECODE( p_imp_xml_document_id, FND_API.g_miss_num, imp_xml_document_id, p_imp_xml_document_id),
              order_initial = DECODE( p_order_initial, FND_API.g_miss_num, order_initial, p_order_initial),
              order_final = DECODE( p_order_final, FND_API.g_miss_num, order_final, p_order_final),
              column_name = DECODE( p_column_name, FND_API.g_miss_char, column_name, p_column_name),
              data = DECODE( p_data, FND_API.g_miss_char, data, p_data),
              num_attr = DECODE( p_num_attr, FND_API.g_miss_num, num_attr, p_num_attr),
              data_type = DECODE( p_data_type, FND_API.g_miss_char, data_type, p_data_type),
              load_status = DECODE( p_load_status, FND_API.g_miss_char, load_status, p_load_status),
              error_text = DECODE( p_error_text, FND_API.g_miss_char, error_text, p_error_text)
   WHERE IMP_XML_ELEMENT_ID = p_IMP_XML_ELEMENT_ID
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
    p_IMP_XML_ELEMENT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IMP_XML_ELEMENTS
    WHERE IMP_XML_ELEMENT_ID = p_IMP_XML_ELEMENT_ID;
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
          p_imp_xml_element_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_last_update_date    DATE,
          p_creation_date    DATE,
          p_imp_xml_document_id    NUMBER,
          p_order_initial    NUMBER,
          p_order_final    NUMBER,
          p_column_name    VARCHAR2,
          p_data    VARCHAR2,
          p_num_attr    NUMBER,
          p_data_type    VARCHAR2,
          p_load_status    VARCHAR2,
          p_error_text    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IMP_XML_ELEMENTS
        WHERE IMP_XML_ELEMENT_ID =  p_IMP_XML_ELEMENT_ID
        FOR UPDATE of IMP_XML_ELEMENT_ID NOWAIT;
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
           (      Recinfo.imp_xml_element_id = p_imp_xml_element_id)
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.imp_xml_document_id = p_imp_xml_document_id)
            OR (    ( Recinfo.imp_xml_document_id IS NULL )
                AND (  p_imp_xml_document_id IS NULL )))
       AND (    ( Recinfo.order_initial = p_order_initial)
            OR (    ( Recinfo.order_initial IS NULL )
                AND (  p_order_initial IS NULL )))
       AND (    ( Recinfo.order_final = p_order_final)
            OR (    ( Recinfo.order_final IS NULL )
                AND (  p_order_final IS NULL )))
       AND (    ( Recinfo.column_name = p_column_name)
            OR (    ( Recinfo.column_name IS NULL )
                AND (  p_column_name IS NULL )))
       AND (    ( Recinfo.data = p_data)
            OR (    ( Recinfo.data IS NULL )
                AND (  p_data IS NULL )))
       AND (    ( Recinfo.num_attr = p_num_attr)
            OR (    ( Recinfo.num_attr IS NULL )
                AND (  p_num_attr IS NULL )))
       AND (    ( Recinfo.data_type = p_data_type)
            OR (    ( Recinfo.data_type IS NULL )
                AND (  p_data_type IS NULL )))
       AND (    ( Recinfo.load_status = p_load_status)
            OR (    ( Recinfo.load_status IS NULL )
                AND (  p_load_status IS NULL )))
       AND (    ( Recinfo.error_text = p_error_text)
            OR (    ( Recinfo.error_text IS NULL )
                AND (  p_error_text IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_IMP_XML_ELEMENTS_PKG;

/

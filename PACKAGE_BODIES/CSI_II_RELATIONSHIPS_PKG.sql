--------------------------------------------------------
--  DDL for Package Body CSI_II_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_II_RELATIONSHIPS_PKG" AS
/* $Header: csitiirb.pls 115.13 2003/09/04 00:18:58 sguthiva ship $ */
-- start of comments
-- package name     : csi_ii_relationships_pkg
-- purpose          :
-- history          :
-- note             :
-- end of comments


g_pkg_name CONSTANT VARCHAR2(30):= 'csi_ii_relationships_pkg';
g_file_name CONSTANT VARCHAR2(12) := 'csitiirb.pls';

PROCEDURE insert_row(
          px_relationship_id   IN OUT NOCOPY NUMBER,
          p_relationship_type_code    VARCHAR2,
          p_object_id                 NUMBER,
          p_subject_id                NUMBER,
          p_position_reference        VARCHAR2,
          p_active_start_date         DATE,
          p_active_end_date           DATE,
          p_display_order             NUMBER,
          p_mandatory_flag            VARCHAR2,
          p_context                   VARCHAR2,
          p_attribute1                VARCHAR2,
          p_attribute2                VARCHAR2,
          p_attribute3                VARCHAR2,
          p_attribute4                VARCHAR2,
          p_attribute5                VARCHAR2,
          p_attribute6                VARCHAR2,
          p_attribute7                VARCHAR2,
          p_attribute8                VARCHAR2,
          p_attribute9                VARCHAR2,
          p_attribute10               VARCHAR2,
          p_attribute11               VARCHAR2,
          p_attribute12               VARCHAR2,
          p_attribute13               VARCHAR2,
          p_attribute14               VARCHAR2,
          p_attribute15               VARCHAR2,
          p_created_by                NUMBER,
          p_creation_date             DATE,
          p_last_updated_by           NUMBER,
          p_last_update_date          DATE,
          p_last_update_login         NUMBER,
          p_object_version_number     NUMBER)

 IS
CURSOR c2 IS SELECT csi_ii_relationships_s.NEXTVAL FROM sys.dual;
BEGIN
   IF (px_relationship_id IS NULL) OR (px_relationship_id = fnd_api.g_miss_num) THEN
       OPEN c2;
       FETCH c2 INTO px_relationship_id;
       CLOSE c2;
   END IF;
   --dbms_output.put_line('relationship_id'||px_relationship_id);
   INSERT INTO csi_ii_relationships(
           relationship_id,
           relationship_type_code,
           object_id,
           subject_id,
           position_reference,
           active_start_date,
           active_end_date,
           display_order,
           mandatory_flag,
           context,
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
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
          ) VALUES (
           px_relationship_id,
           decode( p_relationship_type_code, fnd_api.g_miss_char, NULL, p_relationship_type_code),
           decode( p_object_id, fnd_api.g_miss_num, NULL, p_object_id),
           decode( p_subject_id, fnd_api.g_miss_num, NULL, p_subject_id),
           decode( p_position_reference, fnd_api.g_miss_char, NULL, p_position_reference),
           decode( p_active_start_date, fnd_api.g_miss_date, to_date(NULL), p_active_start_date),
           decode( p_active_end_date, fnd_api.g_miss_date, to_date(NULL), p_active_end_date),
           decode( p_display_order, fnd_api.g_miss_num, NULL, p_display_order),
           decode( p_mandatory_flag, fnd_api.g_miss_char, NULL, p_mandatory_flag),
           decode( p_context, fnd_api.g_miss_char, NULL, p_context),
           decode( p_attribute1, fnd_api.g_miss_char, NULL, p_attribute1),
           decode( p_attribute2, fnd_api.g_miss_char, NULL, p_attribute2),
           decode( p_attribute3, fnd_api.g_miss_char, NULL, p_attribute3),
           decode( p_attribute4, fnd_api.g_miss_char, NULL, p_attribute4),
           decode( p_attribute5, fnd_api.g_miss_char, NULL, p_attribute5),
           decode( p_attribute6, fnd_api.g_miss_char, NULL, p_attribute6),
           decode( p_attribute7, fnd_api.g_miss_char, NULL, p_attribute7),
           decode( p_attribute8, fnd_api.g_miss_char, NULL, p_attribute8),
           decode( p_attribute9, fnd_api.g_miss_char, NULL, p_attribute9),
           decode( p_attribute10, fnd_api.g_miss_char, NULL, p_attribute10),
           decode( p_attribute11, fnd_api.g_miss_char, NULL, p_attribute11),
           decode( p_attribute12, fnd_api.g_miss_char, NULL, p_attribute12),
           decode( p_attribute13, fnd_api.g_miss_char, NULL, p_attribute13),
           decode( p_attribute14, fnd_api.g_miss_char, NULL, p_attribute14),
           decode( p_attribute15, fnd_api.g_miss_char, NULL, p_attribute15),
           decode( p_created_by, fnd_api.g_miss_num, NULL, p_created_by),
           decode( p_creation_date, fnd_api.g_miss_date, to_date(NULL), p_creation_date),
           decode( p_last_updated_by, fnd_api.g_miss_num, NULL, p_last_updated_by),
           decode( p_last_update_date, fnd_api.g_miss_date, to_date(NULL), p_last_update_date),
           decode( p_last_update_login, fnd_api.g_miss_num, NULL, p_last_update_login),
           decode( p_object_version_number, fnd_api.g_miss_num, NULL, p_object_version_number));
           --px_relationship_id:=NULL;
           --dbms_output.put_line('after insert');
           --commit;
END insert_row;

PROCEDURE update_row(
          p_relationship_id             NUMBER,
          p_relationship_type_code      VARCHAR2,
          p_object_id                   NUMBER,
          p_subject_id                  NUMBER,
          p_position_reference          VARCHAR2,
          p_active_start_date           DATE,
          p_active_end_date             DATE,
          p_display_order               NUMBER,
          p_mandatory_flag              VARCHAR2,
          p_context                     VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_created_by                  NUMBER,
          p_creation_date               DATE,
          p_last_updated_by             NUMBER,
          p_last_update_date            DATE,
          p_last_update_login           NUMBER,
          p_object_version_number       NUMBER)

 IS
 BEGIN
    update csi_ii_relationships
    set
              relationship_type_code = decode( p_relationship_type_code, fnd_api.g_miss_char, relationship_type_code, p_relationship_type_code),
              object_id = decode( p_object_id, fnd_api.g_miss_num, object_id, p_object_id),
              subject_id = decode( p_subject_id, fnd_api.g_miss_num, subject_id, p_subject_id),
              position_reference = decode( p_position_reference, fnd_api.g_miss_char, position_reference, p_position_reference),
              active_start_date = decode( p_active_start_date, fnd_api.g_miss_date, active_start_date, p_active_start_date),
              active_end_date = decode( p_active_end_date, fnd_api.g_miss_date, active_end_date, p_active_end_date),
              display_order = decode( p_display_order, fnd_api.g_miss_num, display_order, p_display_order),
              mandatory_flag = decode( p_mandatory_flag, fnd_api.g_miss_char, mandatory_flag, p_mandatory_flag),
              context = decode( p_context, fnd_api.g_miss_char, context, p_context),
              attribute1 = decode( p_attribute1, fnd_api.g_miss_char, attribute1, p_attribute1),
              attribute2 = decode( p_attribute2, fnd_api.g_miss_char, attribute2, p_attribute2),
              attribute3 = decode( p_attribute3, fnd_api.g_miss_char, attribute3, p_attribute3),
              attribute4 = decode( p_attribute4, fnd_api.g_miss_char, attribute4, p_attribute4),
              attribute5 = decode( p_attribute5, fnd_api.g_miss_char, attribute5, p_attribute5),
              attribute6 = decode( p_attribute6, fnd_api.g_miss_char, attribute6, p_attribute6),
              attribute7 = decode( p_attribute7, fnd_api.g_miss_char, attribute7, p_attribute7),
              attribute8 = decode( p_attribute8, fnd_api.g_miss_char, attribute8, p_attribute8),
              attribute9 = decode( p_attribute9, fnd_api.g_miss_char, attribute9, p_attribute9),
              attribute10 = decode( p_attribute10, fnd_api.g_miss_char, attribute10, p_attribute10),
              attribute11 = decode( p_attribute11, fnd_api.g_miss_char, attribute11, p_attribute11),
              attribute12 = decode( p_attribute12, fnd_api.g_miss_char, attribute12, p_attribute12),
              attribute13 = decode( p_attribute13, fnd_api.g_miss_char, attribute13, p_attribute13),
              attribute14 = decode( p_attribute14, fnd_api.g_miss_char, attribute14, p_attribute14),
              attribute15 = decode( p_attribute15, fnd_api.g_miss_char, attribute15, p_attribute15),
              created_by = decode( p_created_by, fnd_api.g_miss_num, created_by, p_created_by),
              creation_date = decode( p_creation_date, fnd_api.g_miss_date, creation_date, p_creation_date),
              last_updated_by = decode( p_last_updated_by, fnd_api.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = decode( p_last_update_date, fnd_api.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = decode( p_last_update_login, fnd_api.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = object_version_number+1
              --object_version_number = decode( p_object_version_number, fnd_api.g_miss_num, object_version_number, p_object_version_number)
    WHERE relationship_id = p_relationship_id;

    IF (SQL%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;
END update_row;

PROCEDURE delete_row(
    p_relationship_id  NUMBER)
 IS
 BEGIN
   DELETE FROM csi_ii_relationships
    WHERE relationship_id = p_relationship_id;
   IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
   END IF;
 END delete_row;

PROCEDURE lock_row(
          p_relationship_id             NUMBER,
          p_relationship_type_code      VARCHAR2,
          p_object_id                   NUMBER,
          p_subject_id                  NUMBER,
          p_position_reference          VARCHAR2,
          p_active_start_date           DATE,
          p_active_end_date             DATE,
          p_display_order               NUMBER,
          p_mandatory_flag              VARCHAR2,
          p_context                     VARCHAR2,
          p_attribute1                  VARCHAR2,
          p_attribute2                  VARCHAR2,
          p_attribute3                  VARCHAR2,
          p_attribute4                  VARCHAR2,
          p_attribute5                  VARCHAR2,
          p_attribute6                  VARCHAR2,
          p_attribute7                  VARCHAR2,
          p_attribute8                  VARCHAR2,
          p_attribute9                  VARCHAR2,
          p_attribute10                 VARCHAR2,
          p_attribute11                 VARCHAR2,
          p_attribute12                 VARCHAR2,
          p_attribute13                 VARCHAR2,
          p_attribute14                 VARCHAR2,
          p_attribute15                 VARCHAR2,
          p_created_by                  NUMBER,
          p_creation_date               DATE,
          p_last_updated_by             NUMBER,
          p_last_update_date            DATE,
          p_last_update_login           NUMBER,
          p_object_version_number       NUMBER)

 IS
   CURSOR c IS
        SELECT *
         FROM csi_ii_relationships
        WHERE relationship_id =  p_relationship_id
        FOR UPDATE OF relationship_id NOWAIT;
   recinfo c%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO recinfo;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        fnd_message.set_name('fnd', 'form_record_deleted');
        app_exception.raise_exception;
    END IF;
    CLOSE c;
    IF (
           (      recinfo.relationship_id = p_relationship_id)
       AND (    ( recinfo.relationship_type_code = p_relationship_type_code)
            OR (    ( recinfo.relationship_type_code IS NULL )
                AND (  p_relationship_type_code IS NULL )))
       AND (    ( recinfo.object_id = p_object_id)
            OR (    ( recinfo.object_id IS NULL )
                AND (  p_object_id IS NULL )))
       AND (    ( recinfo.subject_id = p_subject_id)
            OR (    ( recinfo.subject_id IS NULL )
                AND (  p_subject_id IS NULL )))
       AND (    ( recinfo.position_reference = p_position_reference)
            OR (    ( recinfo.position_reference IS NULL )
                AND (  p_position_reference IS NULL )))
       AND (    ( recinfo.active_start_date = p_active_start_date)
            OR (    ( recinfo.active_start_date IS NULL )
                AND (  p_active_start_date IS NULL )))
       AND (    ( recinfo.active_end_date = p_active_end_date)
            OR (    ( recinfo.active_end_date IS NULL )
                AND (  p_active_end_date IS NULL )))
       AND (    ( recinfo.display_order = p_display_order)
            OR (    ( recinfo.display_order IS NULL )
                AND (  p_display_order IS NULL )))
       AND (    ( recinfo.mandatory_flag = p_mandatory_flag)
            OR (    ( recinfo.mandatory_flag IS NULL )
                AND (  p_mandatory_flag IS NULL )))
       AND (    ( recinfo.context = p_context)
            OR (    ( recinfo.context IS NULL )
                AND (  p_context IS NULL )))
       AND (    ( recinfo.attribute1 = p_attribute1)
            OR (    ( recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( recinfo.attribute2 = p_attribute2)
            OR (    ( recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( recinfo.attribute3 = p_attribute3)
            OR (    ( recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( recinfo.attribute4 = p_attribute4)
            OR (    ( recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( recinfo.attribute5 = p_attribute5)
            OR (    ( recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( recinfo.attribute6 = p_attribute6)
            OR (    ( recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( recinfo.attribute7 = p_attribute7)
            OR (    ( recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( recinfo.attribute8 = p_attribute8)
            OR (    ( recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( recinfo.attribute9 = p_attribute9)
            OR (    ( recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( recinfo.attribute10 = p_attribute10)
            OR (    ( recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( recinfo.attribute11 = p_attribute11)
            OR (    ( recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( recinfo.attribute12 = p_attribute12)
            OR (    ( recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( recinfo.attribute13 = p_attribute13)
            OR (    ( recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( recinfo.attribute14 = p_attribute14)
            OR (    ( recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( recinfo.attribute15 = p_attribute15)
            OR (    ( recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( recinfo.created_by = p_created_by)
            OR (    ( recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( recinfo.creation_date = p_creation_date)
            OR (    ( recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( recinfo.last_updated_by = p_last_updated_by)
            OR (    ( recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( recinfo.last_update_date = p_last_update_date)
            OR (    ( recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( recinfo.last_update_login = p_last_update_login)
            OR (    ( recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( recinfo.object_version_number = p_object_version_number)
            OR (    ( recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       ) THEN
       return;
   ELSE
       fnd_message.set_name('fnd', 'form_record_changed');
       app_exception.raise_exception;
   END IF;
END lock_row;

END csi_ii_relationships_pkg;

/

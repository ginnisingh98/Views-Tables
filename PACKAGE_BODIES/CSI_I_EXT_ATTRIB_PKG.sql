--------------------------------------------------------
--  DDL for Package Body CSI_I_EXT_ATTRIB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_I_EXT_ATTRIB_PKG" AS
/* $Header: csitieab.pls 115.4 2003/09/04 00:18:12 sguthiva ship $ */
-- Start of Comments
-- Package name     : CSI_I_EXT_ATTRIB_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_I_EXTENDED_ATTRIBS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitieab.pls';

PROCEDURE Insert_Row(
          px_attribute_id           IN OUT NOCOPY  NUMBER  ,
          p_attribute_level                 VARCHAR2,
          p_master_organization_id          NUMBER  ,
          p_inventory_item_id               NUMBER  ,
          p_item_category_id                NUMBER  ,
          p_instance_id                     NUMBER  ,
          p_attribute_code                  VARCHAR2,
          p_attribute_name                  VARCHAR2,
          p_attribute_category              VARCHAR2,
          p_description                     VARCHAR2,
          p_active_start_date               DATE    ,
          p_active_end_date                 DATE    ,
          p_context                         VARCHAR2,
          p_attribute1                      VARCHAR2,
          p_attribute2                      VARCHAR2,
          p_attribute3                      VARCHAR2,
          p_attribute4                      VARCHAR2,
          p_attribute5                      VARCHAR2,
          p_attribute6                      VARCHAR2,
          p_attribute7                      VARCHAR2,
          p_attribute8                      VARCHAR2,
          p_attribute9                      VARCHAR2,
          p_attribute10                     VARCHAR2,
          p_attribute11                     VARCHAR2,
          p_attribute12                     VARCHAR2,
          p_attribute13                     VARCHAR2,
          p_attribute14                     VARCHAR2,
          p_attribute15                     VARCHAR2,
          p_created_by                      NUMBER  ,
          p_creation_date                   DATE    ,
          p_last_updated_by                 NUMBER  ,
          p_last_update_date                DATE    ,
          p_last_update_login               NUMBER  ,
          p_object_version_number           NUMBER)

 IS
   CURSOR c2 IS SELECT csi_i_extended_attribs_s.NEXTVAL FROM sys.dual;
BEGIN
   IF (px_attribute_id IS NULL) OR (px_attribute_id = fnd_api.g_miss_num) THEN
       OPEN c2;
       FETCH c2 into px_attribute_id;
       CLOSE c2;
   END IF;
   INSERT INTO csi_i_extended_attribs(
           attribute_id,
           attribute_level,
           master_organization_id,
           inventory_item_id,
           item_category_id,
           instance_id,
           attribute_code,
           attribute_name,
           attribute_category,
           description,
           active_start_date,
           active_end_date,
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
           px_attribute_id,
           decode( p_attribute_level, fnd_api.g_miss_char, NULL, p_attribute_level),
           decode( p_master_organization_id, fnd_api.g_miss_num, NULL, p_master_organization_id),
           decode( p_inventory_item_id, fnd_api.g_miss_num, NULL, p_inventory_item_id),
           decode( p_item_category_id, fnd_api.g_miss_num, NULL, p_item_category_id),
           decode( p_instance_id, fnd_api.g_miss_num, NULL, p_instance_id),
           decode( p_attribute_code, fnd_api.g_miss_char, NULL, p_attribute_code),
           decode( p_attribute_name, fnd_api.g_miss_char, NULL, p_attribute_name),
           decode( p_attribute_category, fnd_api.g_miss_char, NULL, p_attribute_category),
           decode( p_description, fnd_api.g_miss_char, NULL, p_description),
           decode( p_active_start_date, fnd_api.g_miss_date, to_date(NULL), p_active_start_date),
           decode( p_active_end_date, fnd_api.g_miss_date, to_date(NULL), p_active_end_date),
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
END insert_row;

PROCEDURE update_row(
          p_attribute_id                    NUMBER  ,
          p_attribute_level                 VARCHAR2,
          p_master_organization_id          NUMBER  ,
          p_inventory_item_id               NUMBER  ,
          p_item_category_id                NUMBER  ,
          p_instance_id                     NUMBER  ,
          p_attribute_code                  VARCHAR2,
          p_attribute_name                  VARCHAR2,
          p_attribute_category              VARCHAR2,
          p_description                     VARCHAR2,
          p_active_start_date               DATE    ,
          p_active_end_date                 DATE    ,
          p_context                         VARCHAR2,
          p_attribute1                      VARCHAR2,
          p_attribute2                      VARCHAR2,
          p_attribute3                      VARCHAR2,
          p_attribute4                      VARCHAR2,
          p_attribute5                      VARCHAR2,
          p_attribute6                      VARCHAR2,
          p_attribute7                      VARCHAR2,
          p_attribute8                      VARCHAR2,
          p_attribute9                      VARCHAR2,
          p_attribute10                     VARCHAR2,
          p_attribute11                     VARCHAR2,
          p_attribute12                     VARCHAR2,
          p_attribute13                     VARCHAR2,
          p_attribute14                     VARCHAR2,
          p_attribute15                     VARCHAR2,
          p_created_by                      NUMBER  ,
          p_creation_date                   DATE    ,
          p_last_updated_by                 NUMBER  ,
          p_last_update_date                DATE    ,
          p_last_update_login               NUMBER  ,
          p_object_version_number           NUMBER)

 IS
 BEGIN
    UPDATE csi_i_extended_attribs
    SET
              attribute_level = decode( p_attribute_level, fnd_api.g_miss_char, attribute_level, p_attribute_level),
              master_organization_id = decode( p_master_organization_id, fnd_api.g_miss_num, master_organization_id, p_master_organization_id),
              inventory_item_id = decode( p_inventory_item_id, fnd_api.g_miss_num, inventory_item_id, p_inventory_item_id),
              item_category_id = decode( p_item_category_id, fnd_api.g_miss_num, item_category_id, p_item_category_id),
              instance_id = decode( p_instance_id, fnd_api.g_miss_num, instance_id, p_instance_id),
              attribute_code = decode( p_attribute_code, fnd_api.g_miss_char, attribute_code, p_attribute_code),
              attribute_name = decode( p_attribute_name, fnd_api.g_miss_char, attribute_name, p_attribute_name),
              attribute_category = decode( p_attribute_category, fnd_api.g_miss_char, attribute_category, p_attribute_category),
              description = decode( p_description, fnd_api.g_miss_char, description, p_description),
              active_start_date = decode( p_active_start_date, fnd_api.g_miss_date, active_start_date, p_active_start_date),
              active_end_date = decode( p_active_end_date, fnd_api.g_miss_date, active_end_date, p_active_end_date),
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
              object_version_number = decode( p_object_version_number, fnd_api.g_miss_num, object_version_number, p_object_version_number)
    WHERE attribute_id = p_attribute_id;

    IF (SQL%NOTFOUND) THEN
        RAISE no_data_found;
    END IF;
END update_row;

PROCEDURE delete_row(
    p_attribute_id  NUMBER)
 IS
 BEGIN
   DELETE FROM csi_i_extended_attribs
    WHERE attribute_id = p_attribute_id;
   IF (SQL%NOTFOUND) THEN
       RAISE no_data_found;
   END IF;
 END delete_row;


END csi_i_ext_attrib_pkg;

/

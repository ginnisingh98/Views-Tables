--------------------------------------------------------
--  DDL for Package Body AMS_DLG_IDENTIFY_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DLG_IDENTIFY_ITEMS_PKG" as
/* $Header: amstdiib.pls 115.0 2002/04/28 20:28:13 pkm ship        $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DLG_IDENTIFY_ITEMS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DLG_IDENTIFY_ITEMS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdiib.pls';

--  ========================================================
PROCEDURE Insert_Row(
          px_item_id   IN OUT NUMBER,
          p_list_source_type_id    NUMBER,
          p_list_source_field_id    NUMBER,
          p_source_type_code    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NUMBER,
          p_rule_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_DLG_IDENTIFY_ITEMS(
           item_id,
           list_source_type_id,
           list_source_field_id,
           source_type_code,
           source_column_name,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number,
           rule_id
   ) VALUES (
           DECODE( px_item_id, FND_API.g_miss_num, NULL, px_item_id),
           DECODE( p_list_source_type_id, FND_API.g_miss_num, NULL, p_list_source_type_id),
           DECODE( p_list_source_field_id, FND_API.g_miss_num, NULL, p_list_source_field_id),
           DECODE( p_source_type_code, FND_API.g_miss_char, NULL, p_source_type_code),
           DECODE( p_source_column_name, FND_API.g_miss_char, NULL, p_source_column_name),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_rule_id, FND_API.g_miss_num, NULL, p_rule_id));
END Insert_Row;

--  ========================================================
PROCEDURE Update_Row(
          p_item_id    NUMBER,
          p_list_source_type_id    NUMBER,
          p_list_source_field_id    NUMBER,
          p_source_type_code    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_rule_id    NUMBER)

 IS
 BEGIN
    Update AMS_DLG_IDENTIFY_ITEMS
    SET
              item_id = DECODE( p_item_id, FND_API.g_miss_num, item_id, p_item_id),
              list_source_type_id = DECODE( p_list_source_type_id, FND_API.g_miss_num, list_source_type_id, p_list_source_type_id),
              list_source_field_id = DECODE( p_list_source_field_id, FND_API.g_miss_num, list_source_field_id, p_list_source_field_id),
              source_type_code = DECODE( p_source_type_code, FND_API.g_miss_char, source_type_code, p_source_type_code),
              source_column_name = DECODE( p_source_column_name, FND_API.g_miss_char, source_column_name, p_source_column_name),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              rule_id = DECODE( p_rule_id, FND_API.g_miss_num, rule_id, p_rule_id)
   WHERE ITEM_ID = p_ITEM_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;

--  ========================================================
PROCEDURE Delete_Row(
    p_ITEM_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DLG_IDENTIFY_ITEMS
    WHERE ITEM_ID = p_ITEM_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;
--  ========================================================
 PROCEDURE load_row (
	p_item_id    NUMBER,
	p_list_source_type_id    NUMBER,
	p_list_source_field_id    NUMBER,
	p_source_type_code    VARCHAR2,
	p_source_column_name    VARCHAR2,
	p_rule_id               NUMBER,
        p_owner                 VARCHAR2
  )
  IS
   l_user_id      number := 0;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_item_id      number;

   cursor  c_obj_verno is
     select object_version_number
     from  ams_dlg_identify_items
     where  item_id = p_item_id;

   cursor c_chk_identify_item_exists is
     select 'x'
     from  ams_dlg_identify_items
     where item_id = p_item_id;

BEGIN

   if p_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

      l_obj_verno := 1;
      l_item_id := p_item_id;

   open c_chk_identify_item_exists;
   fetch c_chk_identify_item_exists into l_dummy_char;

   if (c_chk_identify_item_exists%notfound ) then

      AMS_DLG_IDENTIFY_ITEMS_PKG.Insert_Row(
          px_item_id => l_item_id,
	  p_list_source_type_id => p_list_source_type_id,
	  p_list_source_field_id => p_list_source_field_id,
          p_source_type_code => p_source_type_code,
	  p_source_column_name => p_source_column_name,
          p_creation_date => sysdate,
          p_created_by => l_user_id,
          p_last_update_date => sysdate,
          p_last_updated_by => l_user_id,
          p_last_update_login => l_user_id,
          px_object_version_number => l_obj_verno,
	  p_rule_id => p_rule_id
      );

   else
      open c_obj_verno;
      fetch c_obj_verno into l_obj_verno;
      close c_obj_verno;

      AMS_DLG_IDENTIFY_ITEMS_PKG.Update_Row(
          p_item_id => p_item_id,
	  p_list_source_type_id => p_list_source_type_id,
	  p_list_source_field_id => p_list_source_field_id,
          p_source_type_code => p_source_type_code,
	  p_source_column_name => p_source_column_name,
          p_last_update_date => sysdate,
          p_last_updated_by => l_user_id,
          p_last_update_login => l_user_id,
          p_object_version_number => l_obj_verno,
          p_rule_id => p_rule_id
      );
   end if;
   close c_chk_identify_item_exists;

  END load_row;

--  ========================================================

END AMS_DLG_IDENTIFY_ITEMS_PKG;

/

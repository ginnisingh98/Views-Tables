--------------------------------------------------------
--  DDL for Package Body JTF_DCF_AKWRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DCF_AKWRAPPER" AS
/* $Header: jtfbakwb.pls 115.4 2002/05/01 18:04:58 apandian ship $ */

  ------------------------------------------------------------------------
  --Created by  : Hyun-Sik
  --Date created: 20-NOV-2001
  --
  --Purpose:
  --  This is a wrapper for ak apis
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History: (who, when, what: NO CREATION RECORDS HERE!)
  --Who    When    What
  ------------------------------------------------------------------------

   PROCEDURE DCF_CREATE_REGION_ITEM (
      p_region_application_id IN ak_region_items.region_application_id%TYPE,
      p_region_code           IN ak_region_items.region_code%TYPE,
      p_attribute_code        IN ak_region_items.attribute_code%TYPE,
      p_display_sequence      IN ak_region_items.display_sequence%TYPE,
      p_node_display_flag     IN
         ak_region_items.node_display_flag%TYPE DEFAULT 'Y',
      p_flex_segment_list     IN ak_region_items.flex_segment_list%TYPE
   )  IS

      CURSOR Check_Portaldata_Exist_C IS
         SELECT 'Y'
           FROM Ak_Region_Items
          WHERE region_code = p_region_code
            AND region_application_id = p_region_application_id
            AND attribute_code = p_attribute_code
            AND attribute_application_id = 690;

      l_rowid                    VARCHAR2(200);
      l_attribute_application_id ak_region_items.attribute_application_id%TYPE
                                 := 690;
      l_node_query_flag          ak_region_items.node_query_flag%TYPE := 'N';
      l_attribute_label_length   ak_region_items.attribute_label_length%TYPE :=
                                 0;
      l_bold                     ak_region_items.bold%TYPE := 'N';
      l_italic                   ak_region_items.italic%TYPE := 'N';
      l_vertical_alignment       ak_region_items.vertical_alignment%TYPE :=
                                 'TOP';
      l_horizontal_alignment     ak_region_items.horizontal_alignment%TYPE :=
                                 'LEFT';
      l_item_style               ak_region_items.item_style%TYPE := 'TEXT';
      l_object_attribute_flag    ak_region_items.object_attribute_flag%TYPE :=
                                 'N';
      l_update_flag              ak_region_items.update_flag%TYPE := 'N';
      l_required_flag            ak_region_items.required_flag%TYPE := 'N';
      l_display_value_length     ak_region_items.display_value_length%TYPE :=
                                 0;
      l_submit                   ak_region_items.submit%TYPE := 'N';
      l_encrypt                  ak_region_items.encrypt%TYPE := 'N';
      l_admin_customizable       ak_region_items.admin_customizable%TYPE :=
                                 'Y';
      l_creation_date            ak_region_items.creation_date%TYPE := SYSDATE;
      l_created_by               ak_region_items.created_by%TYPE :=
                                 FND_GLOBAL.USER_ID;
      l_last_update_date         ak_region_items.last_update_date%TYPE :=
                                 SYSDATE;
      l_last_updated_by          ak_region_items.last_updated_by%TYPE :=
                                 FND_GLOBAL.USER_ID;
      l_last_update_login        ak_region_items.last_update_login%TYPE :=
                                 FND_GLOBAL.CONC_LOGIN_ID;
      l_attribute_category       ak_region_items.attribute_category%TYPE :=
                                 'PORTLET_ELEMENT';
      l_attribute1               ak_region_items.attribute1%TYPE := 'CONSTANT';
      l_attribute6               ak_region_items.attribute6%TYPE := 'N';

      l_record_exist             VARCHAR2(1) := 'N';

   BEGIN

      OPEN Check_Portaldata_Exist_C;
      FETCH Check_Portaldata_Exist_C INTO l_record_exist;
      CLOSE Check_Portaldata_Exist_C;

      IF (l_record_exist = 'N') THEN
         AK_REGION_ITEMS_PKG.INSERT_ROW(
            x_rowid                        =>   l_rowid,
            x_region_application_id        =>   p_region_application_id,
            x_region_code                  =>   p_region_code,
            x_attribute_application_id     =>   l_attribute_application_id,
            x_attribute_code               =>   p_attribute_code,
            x_display_sequence             =>   p_display_sequence,
            x_node_display_flag            =>   p_node_display_flag,
            x_node_query_flag              =>   l_node_query_flag,
            x_attribute_label_length       =>   l_attribute_label_length,
            x_bold                         =>   l_bold,  -- 10
            x_italic                       =>   l_italic,
            x_vertical_alignment           =>   l_vertical_alignment,
            x_horizontal_alignment         =>   l_horizontal_alignment,
            x_item_style                   =>   l_item_style,
            x_object_attribute_flag        =>   l_object_attribute_flag,
            x_attribute_label_long         =>   NULL,
            x_description                  =>   NULL,
            x_security_code                =>   NULL,
            x_update_flag                  =>   l_update_flag,
            x_required_flag                =>   l_required_flag,  -- 20
            x_display_value_length         =>   l_display_value_length,
            x_lov_region_application_id    =>   NULL,
            x_lov_region_code              =>   NULL,
            x_lov_foreign_key_name         =>   NULL,
            x_lov_attribute_application_id =>   NULL,
            x_lov_attribute_code           =>   NULL,
            x_lov_default_flag             =>   NULL,
            x_region_defaulting_api_pkg    =>   NULL,
            x_region_defaulting_api_proc   =>   NULL,
            x_region_validation_api_pkg    =>   NULL,  -- 30
            x_region_validation_api_proc   =>   NULL,
            x_order_sequence               =>   NULL,
            x_order_direction              =>   NULL,
            x_default_value_varchar2       =>   NULL,
            x_default_value_number         =>   NULL,
            x_default_value_date           =>   NULL,
            x_item_name                    =>   NULL,
            x_display_height               =>   NULL,
            x_submit                       =>   l_submit,
            x_encrypt                      =>   l_encrypt,  -- 40
            x_view_usage_name              =>   NULL,
            x_view_attribute_name          =>   NULL,
            x_css_class_name               =>   NULL,
            x_css_label_class_name         =>   NULL,
            x_url                          =>   NULL,
            x_poplist_viewobject           =>   NULL,
            x_poplist_display_attribute    =>   NULL,
            x_poplist_value_attribute      =>   NULL,
            x_image_file_name              =>   NULL,
            x_nested_region_code           =>   NULL,  -- 50
            x_nested_region_appl_id        =>   NULL,
            x_menu_name                    =>   NULL,
            x_flexfield_name               =>   NULL,
            x_flexfield_application_id     =>   NULL,
            x_tabular_function_code        =>   NULL,
            x_tip_type                     =>   NULL,
            x_tip_message_name             =>   NULL,
            x_tip_message_application_id   =>   NULL,
            x_flex_segment_list            =>   p_flex_segment_list,
            x_entity_id                    =>   NULL,  -- 60
            x_anchor                       =>   NULL,
            x_poplist_view_usage_name      =>   NULL,
            x_user_customizable            =>   NULL,
            x_admin_customizable           =>   l_admin_customizable,
            x_invoke_function_name         =>   NULL,
            x_attribute_label_short        =>   NULL,
            x_expansion                    =>   NULL,
            x_als_max_length               =>   NULL,
            x_sortby_view_attribute_name   =>   NULL,
            x_icx_custom_call              =>   NULL,  -- 70
            x_initial_sort_sequence        =>   NULL,
            x_creation_date                =>   l_creation_date,
            x_created_by                   =>   l_created_by,
            x_last_update_date             =>   l_last_update_date,
            x_last_updated_by              =>   l_last_updated_by,
            x_last_update_login            =>   l_last_update_login,
            x_attribute_category           =>   l_attribute_category,
            x_attribute1                   =>   l_attribute1,
            x_attribute2                   =>   NULL,
            x_attribute3                   =>   NULL,
            x_attribute4                   =>   NULL,
            x_attribute5                   =>   NULL,
            x_attribute6                   =>   l_attribute6,
            x_attribute7                   =>   NULL,
            x_attribute8                   =>   NULL,
            x_attribute9                   =>   NULL,
            x_attribute10                  =>   NULL,
            x_attribute11                  =>   NULL,
            x_attribute12                  =>   NULL,
            x_attribute13                  =>   NULL,
            x_attribute14                  =>   NULL,
            x_attribute15                  =>   NULL);
      END IF;

   END DCF_CREATE_REGION_ITEM;
--
--
END jtf_dcf_akwrapper;

/

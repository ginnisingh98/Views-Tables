--------------------------------------------------------
--  DDL for Package CUG_SR_TYPE_ATTR_MAPS_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_SR_TYPE_ATTR_MAPS_PKG_W" AUTHID CURRENT_USER as
  /* $Header: CUGSRTYS.pls 115.6 2004/03/29 21:43:56 aneemuch ship $ */
  procedure insert_row(x_rowid in out nocopy  VARCHAR2
    , x_sr_type_attr_map_id  NUMBER
    , x_sr_type_attr_seq_num  NUMBER
    , x_object_version_number  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_security_group_id  NUMBER
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_attr_default_value  VARCHAR2
    , x_creation_date  date
    , x_created_by  NUMBER
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
  );
  procedure lock_row(x_sr_type_attr_map_id  NUMBER
    , x_sr_type_attr_seq_num  NUMBER
    , x_object_version_number  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_security_group_id  NUMBER
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_attr_default_value  VARCHAR2
  );
  procedure update_row(x_sr_type_attr_map_id  NUMBER
    , x_sr_type_attr_seq_num  NUMBER
    , x_object_version_number  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_attribute1  VARCHAR2
    , x_attribute2  VARCHAR2
    , x_attribute3  VARCHAR2
    , x_attribute4  VARCHAR2
    , x_attribute5  VARCHAR2
    , x_attribute6  VARCHAR2
    , x_attribute7  VARCHAR2
    , x_attribute8  VARCHAR2
    , x_attribute9  VARCHAR2
    , x_attribute10  VARCHAR2
    , x_attribute11  VARCHAR2
    , x_attribute12  VARCHAR2
    , x_attribute13  VARCHAR2
    , x_attribute14  VARCHAR2
    , x_attribute15  VARCHAR2
    , x_attribute_category  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_security_group_id  NUMBER
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_attr_default_value  VARCHAR2
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
  );
  procedure load_row(x_sr_type_attr_map_id  NUMBER
    , x_incident_type_id  NUMBER
    , x_sr_attribute_code  VARCHAR2
    , x_sr_attr_mandatory_flag  VARCHAR2
    , x_sr_attr_displayed_flag  VARCHAR2
    , x_sr_attr_dup_check_flag  VARCHAR2
    , x_sr_attribute_list_name  VARCHAR2
    , x_start_date_active  date
    , x_end_date_active  date
    , x_sr_attr_default_value  VARCHAR2
    , x_template_id  NUMBER
    , x_reqd_for_close_flag  VARCHAR2
    , x_show_on_update_flag  VARCHAR2
    , x_update_allowed_flag  VARCHAR2
    , x_sr_type_attr_seq_num  NUMBER
    , x_security_group_id  NUMBER
    , x_creation_date  VARCHAR2
    , x_created_by  NUMBER
    , x_last_update_date  VARCHAR2
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_owner  VARCHAR2
  );
end cug_sr_type_attr_maps_pkg_w;

 

/

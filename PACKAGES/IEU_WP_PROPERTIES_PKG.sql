--------------------------------------------------------
--  DDL for Package IEU_WP_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_PROPERTIES_PKG" AUTHID CURRENT_USER as
/* $Header: IEUVPROS.pls 120.1 2005/06/20 01:18:12 appldev ship $ */

procedure insert_row(
x_rowid in out nocopy Varchar2,
p_property_id in number,
p_object_version_number in number,
p_created_by in number,
p_creation_date in date,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2
);

procedure lock_row(
p_property_id in number,
p_object_version_number in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2
);

procedure update_row(
p_property_id in number,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2
);

procedure delete_row(
p_property_id in number
);

procedure add_language;

procedure load_row(
p_property_id in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2,
p_owner in varchar2
);

procedure translate_row(
p_property_id in number,
p_property_label in varchar2,
p_property_description in varchar2,
p_owner in varchar2
);

procedure load_seed_row(
p_upload_mode in varchar2,
p_property_id in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2,
p_owner in varchar2
);


END IEU_WP_PROPERTIES_PKG;

 

/

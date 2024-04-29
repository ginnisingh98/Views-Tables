--------------------------------------------------------
--  DDL for Package IEU_WP_UI_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_UI_COMPONENTS_PKG" AUTHID CURRENT_USER as
/* $Header: IEUVCOMS.pls 120.1 2005/06/20 01:09:08 appldev ship $ */

procedure insert_row(
x_rowid in out nocopy Varchar2,
p_ui_comp_id in number,
p_object_version_number in number,
p_created_by in number,
p_creation_date in date,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_ui_comp_catg_code in varchar2,
p_form_comp_code in varchar2,
p_form_comp_avail_no in number,
p_property_class in varchar2,
p_ui_comp_label in varchar2,
p_ui_comp_desc in varchar2
);

procedure lock_row(
p_ui_comp_id in number,
p_object_version_number in number,
p_ui_comp_catg_code in varchar2,
p_form_comp_code in varchar2,
p_form_comp_avail_no in number,
p_property_class in varchar2,
p_ui_comp_label in varchar2,
p_ui_comp_desc in varchar2
);

procedure update_row(
p_ui_comp_id in number,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_ui_comp_catg_code in varchar2,
p_form_comp_code in varchar2,
p_form_comp_avail_no in number,
p_property_class in varchar2,
p_ui_comp_label in varchar2,
p_ui_comp_desc in varchar2
);

procedure delete_row(
p_ui_comp_id in number
);

procedure add_language;

procedure load_row(
p_ui_comp_id in number,
p_ui_comp_catg_code in varchar2,
p_form_comp_code in varchar2,
p_form_comp_avail_no in number,
p_property_class in varchar2,
p_ui_comp_label in varchar2,
p_ui_comp_desc in varchar2,
p_owner in varchar2
);

procedure translate_row(
p_ui_comp_id in number,
p_ui_comp_label in varchar2,
p_ui_comp_desc in varchar2,
p_owner in varchar2
);

procedure load_seed_row(
p_upload_mode in varchar2,
p_ui_comp_id in number,
p_ui_comp_catg_code in varchar2,
p_form_comp_code in varchar2,
p_form_comp_avail_no in number,
p_property_class in varchar2,
p_ui_comp_label in varchar2,
p_ui_comp_desc in varchar2,
p_owner in varchar2
);


END IEU_WP_UI_COMPONENTS_PKG;

 

/

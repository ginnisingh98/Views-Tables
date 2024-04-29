--------------------------------------------------------
--  DDL for Package IEU_WP_UI_COMP_DATATYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_UI_COMP_DATATYPES_PKG" AUTHID CURRENT_USER as
/* $Header: IEUVCDTS.pls 120.1 2005/06/20 01:07:42 appldev ship $ */

procedure insert_row(
x_rowid in out nocopy Varchar2,
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_object_version_number in number,
p_created_by in number,
p_creation_date in date,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_data_type in varchar2
);

procedure lock_row(
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_object_version_number in number,
p_data_type in varchar2
);

procedure update_row(
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_data_type in varchar2
);

procedure delete_row(
p_ui_comp_datatype_map_id in number
);

procedure load_row(
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_data_type in varchar2,
p_owner in varchar2
);

procedure load_seed_row(
p_upload_mode in varchar2,
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_data_type in varchar2,
p_owner in varchar2
);

END IEU_WP_UI_COMP_DATATYPES_PKG;

 

/

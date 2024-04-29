--------------------------------------------------------
--  DDL for Package JTF_GRID_LCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_GRID_LCT_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFGCLSS.pls 120.0 2005/09/24 17:45:21 applrt noship $ */
procedure LOAD_SEED_DATASOURCES(
 x_upload_mode            in varchar2,
 x_custom_mode            in varchar2,
 x_last_update_date       in varchar2,
 x_grid_datasource_name   in varchar2,
 x_title_text             in varchar2,
 x_owner                  in varchar2,
 x_db_view_name           in varchar2,
 x_application_short_name in varchar2,
 x_default_row_height     in varchar2,
 x_max_queried_rows       in varchar2,
 x_where_clause           in varchar2,
 x_alt_color_code         in varchar2,
 x_alt_color_interval     in varchar2,
 x_fetch_size             in varchar2
 );


procedure LOAD_SEED_COLS(
   x_upload_mode                   in varchar2,
   x_custom_mode                   in varchar2,
   x_last_update_date              in varchar2,
   x_grid_datasource_name          in varchar2,
   x_grid_col_alias                in varchar2,
   x_label_text                    in varchar2,
   x_owner                         in varchar2,
   x_db_col_name                   in varchar2,
   x_data_type_code                in varchar2,
   x_query_seq                     in varchar2,
   x_sortable_flag                 in varchar2,
   x_sort_asc_by_default_flag      in varchar2,
   x_visible_flag                  in varchar2,
   x_freeze_visible_flag           in varchar2,
   x_display_seq                   in varchar2,
   x_display_type_code             in varchar2,
   x_display_hsize                 in varchar2,
   x_header_alignment_code         in varchar2,
   x_cell_alignment_code           in varchar2,
   x_display_format_type_code      in varchar2,
   x_display_format_mask           in varchar2,
   x_checkbox_checked_value        in varchar2,
   x_checkbox_unchecked_value      in varchar2,
   x_checkbox_other_values         in varchar2,
   x_db_currency_code_col          in varchar2,
   x_query_allowed_flag            in varchar2,
   x_validation_object_code        in varchar2,
   x_query_display_seq             in varchar2,
   x_db_sort_column                in varchar2,
   x_fire_post_query_flag          in varchar2,
   x_image_description_col         in varchar2
);






procedure LOAD_SEED_SORT_COLS(
    x_last_update_date     in varchar2,
    x_upload_mode          in varchar2,
    x_owner                in varchar2,
    x_grid_datasource_name in varchar2,
    x_grid_sort_col_alias1 in varchar2,
    x_grid_sort_col_alias2 in varchar2,
    x_grid_sort_col_alias3 in varchar2,
    x_custom_mode          in varchar2
);


END JTF_GRID_LCT_PKG;

 

/

--------------------------------------------------------
--  DDL for Package Body JTF_GRID_LCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_GRID_LCT_PKG" as
/* $Header: JTFGCLSB.pls 120.2 2006/10/27 14:25:43 snellepa noship $ */
procedure LOAD_SEED_DATASOURCES(
    x_upload_mode in varchar2,
    x_custom_mode in varchar2,
    x_last_update_date in varchar2,
    x_grid_datasource_name in varchar2,
    x_title_text in varchar2,
    x_owner in varchar2,
    x_db_view_name in varchar2,
    x_application_short_name in varchar2,
    x_default_row_height in varchar2,
    x_max_queried_rows in varchar2,
    x_where_clause in varchar2,
    x_alt_color_code in varchar2,
    x_alt_color_interval in varchar2,
    x_fetch_size in varchar2)
is
  l_custom_mode varchar2(20) := x_custom_mode;
begin
       if x_last_update_date is null then
          l_custom_mode := 'FORCE';
       end if;

       if (x_upload_mode = 'NLS') then
         JTF_GRID_DATASOURCES_PKG.TRANSLATE_ROW(
            x_grid_datasource_name => x_grid_datasource_name
           ,x_title_text =>           x_title_text
           ,x_owner =>                x_owner
           ,x_custom_mode => l_custom_mode
           ,x_last_update_date => x_last_update_date);
       else
         JTF_GRID_DATASOURCES_PKG.LOAD_ROW(
             x_grid_datasource_name =>   x_grid_datasource_name
            ,x_db_view_name =>           x_db_view_name
            ,x_application_short_name => x_application_short_name
            ,x_default_row_height => to_number(x_default_row_height)
            ,x_max_queried_rows => to_number(x_max_queried_rows)
            ,x_where_clause =>   x_where_clause
            ,x_alt_color_code => x_alt_color_code
            ,x_alt_color_interval => to_number(x_alt_color_interval)
            ,x_title_text => x_title_text
            ,x_owner => x_owner
            ,x_fetch_size => to_number(x_fetch_size)
            ,x_custom_mode => l_custom_mode
            ,x_last_update_date => x_last_update_date);
      end if;
     end LOAD_SEED_DATASOURCES;





procedure LOAD_SEED_COLS(
   x_upload_mode in varchar2,
   x_custom_mode in varchar2,
   x_last_update_date in varchar2,
   x_grid_datasource_name in varchar2,
   x_grid_col_alias     in varchar2,
   x_label_text           in varchar2,
   x_owner      in varchar2,
   x_db_col_name     in varchar2,
   x_data_type_code  in varchar2,
   x_query_seq in varchar2,
   x_sortable_flag         in varchar2,
   x_sort_asc_by_default_flag  in varchar2,
   x_visible_flag             in varchar2,
   x_freeze_visible_flag      in varchar2,
   x_display_seq in varchar2,
   x_display_type_code in varchar2,
   x_display_hsize in varchar2,
   x_header_alignment_code   in varchar2,
   x_cell_alignment_code     in varchar2,
   x_display_format_type_code         in varchar2,
   x_display_format_mask              in varchar2,
   x_checkbox_checked_value          in varchar2,
   x_checkbox_unchecked_value        in varchar2,
   x_checkbox_other_values   in varchar2,
   x_db_currency_code_col    in varchar2,
   x_query_allowed_flag  in varchar2,
   x_validation_object_code  in varchar2,
   x_query_display_seq  in varchar2,
   x_db_sort_column          in varchar2,
   x_fire_post_query_flag     in varchar2,
   x_image_description_col in varchar2 )
is
       l_custom_mode varchar2(20) := x_custom_mode;
begin
       if x_last_update_date is null then
          l_custom_mode := 'FORCE';
       end if;

       if (x_upload_mode = 'NLS') then
         jtf_grid_cols_pkg.TRANSLATE_ROW(
            x_grid_datasource_name => x_grid_datasource_name
           ,x_grid_col_alias =>       x_grid_col_alias
           ,x_label_text =>           x_label_text
           ,x_owner =>                x_owner
           ,x_custom_mode => l_custom_mode
           ,x_last_update_date => x_last_update_date);
       else
           JTF_GRID_COLS_PKG.LOAD_ROW(
              x_grid_datasource_name => x_grid_datasource_name
             ,x_grid_col_alias =>    x_grid_col_alias
             ,x_db_col_name =>     x_db_col_name
             ,x_data_type_code =>  x_data_type_code
             ,x_query_seq => to_number(x_query_seq)
             ,x_sortable_flag =>            x_sortable_flag
             ,x_sort_asc_by_default_flag => x_sort_asc_by_default_flag
             ,x_visible_flag =>             x_visible_flag
             ,x_freeze_visible_flag =>      x_freeze_visible_flag
             ,x_display_seq => to_number(x_display_seq)
             ,x_display_type_code => x_display_type_code
             ,x_display_hsize => to_number(x_display_hsize)
             ,x_header_alignment_code => x_header_alignment_code
             ,x_cell_alignment_code =>   x_cell_alignment_code
             ,x_display_format_type_code => x_display_format_type_code
             ,x_display_format_mask =>      x_display_format_mask
             ,x_checkbox_checked_value =>   x_checkbox_checked_value
             ,x_checkbox_unchecked_value => x_checkbox_unchecked_value
             ,x_checkbox_other_values => x_checkbox_other_values
             ,x_db_currency_code_col =>  x_db_currency_code_col
             ,x_label_text => x_label_text
             ,x_owner =>      x_owner
             ,X_QUERY_ALLOWED_FLAG => nvl(x_query_allowed_flag,'F')
             ,X_VALIDATION_OBJECT_CODE =>   x_validation_object_code
             ,X_QUERY_DISPLAY_SEQ =>       to_number(x_query_display_SEQ)
             ,X_DB_SORT_COLUMN =>         x_db_sort_column
             ,X_FIRE_POST_QUERY_FLAG =>   x_fire_post_query_flag
             ,X_IMAGE_DESCRIPTION_COL =>  x_image_description_col
             ,x_custom_mode => l_custom_mode
             ,x_last_update_date =>       x_last_update_date);
       end if;
end LOAD_SEED_COLS;


procedure LOAD_SEED_SORT_COLS(
   x_last_update_date in varchar2,
   x_upload_mode in varchar2,
   x_owner in varchar2,
   x_grid_datasource_name in varchar2,
   x_grid_sort_col_alias1 in varchar2,
   x_grid_sort_col_alias2 in varchar2,
   x_grid_sort_col_alias3 in varchar2,
   x_custom_mode in varchar2)
is
        l_last_updated_by    number;
        l_custom_mode varchar2(20) := x_custom_mode;
        f_luby    number;  -- entity owner in file
        f_ludate  date;    -- entity update date in file
        db_luby   number;  -- entity owner in db
        db_ludate date;    -- entity update date in db
        dummy varchar2(2);
begin

       if x_last_update_date is null then
          l_custom_mode := 'FORCE';
       end if;

       if (x_upload_mode = 'NLS') then
          null;
       else
              -- Translate owner to file_last_updated_by
              f_luby := fnd_load_util.owner_id(x_owner);

              -- Translate char last_update_date to date
              f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);



              begin

		select LAST_UPDATED_BY, LAST_UPDATE_DATE
                into db_luby, db_ludate
                from JTF_GRID_sort_cols
                where GRID_DATASOURCE_NAME = x_grid_datasource_name;



		  -- Test for customization and version
                  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, L_CUSTOM_MODE)) then
                        update JTF_GRID_SORT_COLS
                        set GRID_SORT_COL_ALIAS1 = x_grid_sort_col_alias1
                           ,GRID_SORT_COL_ALIAS2 = x_grid_sort_col_alias2
                           ,GRID_SORT_COL_ALIAS3 = x_grid_sort_col_alias3
                           ,LAST_UPDATED_BY = f_luby
                           ,LAST_UPDATE_DATE = f_ludate
                           ,LAST_UPDATE_LOGIN = 0
                        where GRID_DATASOURCE_NAME = x_grid_datasource_name;

                        if sql%notfound then
                          raise no_data_found;
                        end if;
                    end if;
             exception
                    when no_data_found then
                          insert into JTF_GRID_SORT_COLS
                             (GRID_DATASOURCE_NAME
                              ,GRID_SORT_COL_ALIAS1
                              ,GRID_SORT_COL_ALIAS2
                              ,GRID_SORT_COL_ALIAS3
                              ,CREATED_BY
                              ,CREATION_DATE
                              ,LAST_UPDATED_BY
                              ,LAST_UPDATE_DATE
                              ,LAST_UPDATE_LOGIN)
                            values
                              (x_grid_datasource_name
                              ,x_grid_sort_col_alias1
                              ,x_grid_sort_col_alias2
                              ,x_grid_sort_col_alias3
	                      ,f_luby
	                      ,f_ludate
			      ,f_luby
                              ,f_ludate
                              ,0);
             end;
      end if;
 end LOAD_SEED_SORT_COLS;

 end jtf_grid_lct_pkg;

/

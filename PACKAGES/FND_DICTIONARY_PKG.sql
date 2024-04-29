--------------------------------------------------------
--  DDL for Package FND_DICTIONARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DICTIONARY_PKG" AUTHID CURRENT_USER as
/* $Header: AFDICTS.pls 120.2 2005/07/11 08:37:07 stadepal ship $ */


type NameArrayTyp is table of varchar2(100) index by binary_integer;
type NumberArrayTyp is table of number index by binary_integer;
type Text2000ArrayTyp is table of varchar2(2000) index by binary_integer;

--
-- UploadTable (PUBLIC))
--   Public procedure for afdict.lct to call when uploading tables using
--   using afdict.lct. It calls InsertTable() when needed.
--
procedure UploadTable (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_user_table_name              in varchar2,
  x_table_type                   in varchar2,
  x_description                  in varchar2,
  x_auto_size                    in varchar2,
  x_initial_extent               in varchar2,
  x_next_extent                  in varchar2,
  x_min_extents                  in varchar2,
  x_max_extents                  in varchar2,
  x_ini_trans                    in varchar2,
  x_max_trans                    in varchar2,
  x_pct_free                     in varchar2,
  x_pct_increase                 in varchar2,
  x_pct_used                     in varchar2,
  x_hosted_support_style         in varchar2,
  x_user_id                      in varchar2);


--
-- UploadColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading columns using
--   using afdict.lct. It calls InsertColumn() when needed.
--

procedure UploadColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_column_name                  in varchar2,
  x_user_column_name             in varchar2,
  x_column_sequence              in varchar2,
  x_column_type                  in varchar2,
  x_width                        in varchar2,
  x_null_allowed_flag            in varchar2,
  x_description                  in varchar2,
  x_default_value                in varchar2,
  x_translate_flag               in varchar2,
  x_precision                    in varchar2,
  x_scale                        in varchar2,
  x_flexfield_usage_code         in varchar2,
  x_flexfield_application_id     in varchar2,
  x_flexfield_name               in varchar2,
  x_flex_value_set_app_id        in varchar2,
  x_flex_value_set_id            in varchar2,
  x_user_id                      in varchar2);


--
-- UploadHistColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading hist columns using
--   using afdict.lct. It calls InsertHistColumn() when needed.
--

procedure UploadHistColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_column_name                  in varchar2,
  x_partition                    in varchar2,
  x_hsize                        in varchar2,
  x_user_id                      in varchar2);

--
-- UploadIndex (PUBLIC))
--   Public procedure for afdict.lct to call when uploading indexes using
--   using afdict.lct. It calls InsertIndex() when needed.
--
procedure UploadIndex (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_index_name                   in varchar2,
  x_uniqueness                   in varchar2,
  x_auto_size                    in varchar2,
  x_description                  in varchar2,
  x_initial_extent               in varchar2,
  x_next_extent                  in varchar2,
  x_min_extents                  in varchar2,
  x_max_extents                  in varchar2,
  x_ini_trans                    in varchar2,
  x_max_trans                    in varchar2,
  x_pct_free                     in varchar2,
  x_pct_increase                 in varchar2,
  x_user_id                      in varchar2);

--
-- UploadIndexColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading index columns using
--   using afdict.lct.
--
procedure UploadIndexColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_index_name                   in varchar2,
  x_index_column_name            in varchar2,
  x_index_column_sequence        in varchar2,
  x_user_id                      in varchar2);

--
-- UploadPrimaryKey (PUBLIC))
--   Public procedure for afdict.lct to call when uploading primary key using
--   using afdict.lct.  It calls InsertPrimary() when needed.
--
procedure UploadPrimaryKey (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2,
  x_primary_key_type             in varchar2,
  x_audit_key_flag               in varchar2,
  x_description                  in varchar2,
  x_enabled_flag                 in varchar2,
  x_user_id                      in varchar2);

--
-- UploadPrimaryKeyColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading primary key column
--   using afdict.lct.
--
procedure UploadPrimaryKeyColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2,
  x_primary_key_column_name      in varchar2,
  x_primary_key_column_sequence  in varchar2,
  x_user_id                      in varchar2);

--
-- UploadForeignKey (PUBLIC))
--   Public procedure for afdict.lct to call when uploading foreign key using
--   using afdict.lct.  It calls InsertForeign() when needed.
--
procedure UploadForeignKey (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_foreign_key_name             in varchar2,
  x_primary_key_application_name in varchar2,
  x_primary_key_table_name       in varchar2,
  x_primary_key_name             in varchar2,
  x_description                  in varchar2,
  x_cascade_behavior             in varchar2,
  x_foreign_key_relation         in varchar2,
  x_condition                    in varchar2,
  x_enabled_flag                 in varchar2,
  x_user_id                      in varchar2);

--
-- UploadForeignKeyColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading foreign key column
--   using afdict.lct.
--
procedure UploadForeignKeyColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_foreign_key_name             in varchar2,
  x_foreign_key_column_name      in varchar2,
  x_foreign_key_column_sequence  in varchar2,
  x_cascade_value                in varchar2,
  x_user_id                      in varchar2);

--
-- UploadSequence (PUBLIC))
--   Public procedure for afdict.lct to call when uploading sequence
--   using afdict.lct. It calls InsertSequence when needed.
--
procedure UploadSequence (
  x_application_short_name       in varchar2,
  x_sequence_name                in varchar2,
  x_start_value                  in varchar2,
  x_description                  in varchar2,
  x_increment_by                 in varchar2,
  x_min_value                    in varchar2,
  x_max_value                    in varchar2,
  x_cache_size                   in varchar2,
  x_cycle_flag                   in varchar2,
  x_order_flag                   in varchar2,
  x_user_id                      in varchar2);

--
-- UploadView (PUBLIC))
--   Public procedure for afdict.lct to call when uploading view
--   using afdict.lct. It calls InsertView when needed.
--
procedure UploadView (
  x_application_short_name       in varchar2,
  x_view_name                    in varchar2,
  x_text                         in varchar2,
  x_description                  in varchar2,
  x_user_id                      in varchar2);

--
-- UploadViewColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading view column
--   using afdict.lct.
--
procedure UploadViewColumn (
  x_application_short_name       in varchar2,
  x_view_name                    in varchar2,
  x_view_column_name             in varchar2,
  x_view_column_sequence         in varchar2,
  x_user_id                      in varchar2);

--
-- ViewTextLength (PUBLIC)
--   Return the view text length.
--   This is a helper function as length() function can not be used
--   directly in sql but is ok to used on a variable in PL/SQL.
--
function ViewTextLength (
  x_application_id               in number,
  x_view_name                    in varchar2) return number;
pragma restrict_references(ViewTextLength, WNDS);

--
-- RemoveColumn (PUBLIC)
--   Remove column from FND_COLUMNS table.
--   Before removing this column, make sure that there is no index,
--   primary key or foreign key is using this column
--
procedure RemoveColumn(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_column_name                  in varchar2);

--
-- RemoveIndex (PUBLIC)
--   Remove index from FND_INDEXES and FND_INDEX_COLUMNS table.
--
procedure RemoveIndex(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_index_name                   in varchar2);

--
-- RemovePrimaryKey (PUBLIC)
--   Remove primary key from FND_PRIMARY_KEYS and FND_PRIMARY_KEY_COLUMNS table.
--   Before deleting primary key, make sure that there is no foreign key
--   pointing to this primary key
--
procedure RemovePrimaryKey(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2);

--
-- RemoveForeignKey (PUBLIC)
--   Remove foreign key from FND_FOREIGN_KEYS and FND_FOREIGN_KEY_COLUMNS table.
--
procedure RemoveForeignKey(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_foreign_key_name             in varchar2);

--
-- RemoveSequence (PUBLIC)
--   Remove sequence from FND_SEQUENCES table.
--
procedure RemoveSequence(
  x_application_short_name       in varchar2,
  x_sequence_name                in varchar2);

--
-- RemoveView (PUBLIC)
--   Remove view from FND_VIEWS and FND_VIEW_COLUMNS table.
--
procedure RemoveView(
  x_application_short_name       in varchar2,
  x_view_name                    in varchar2);

--
-- RemoveTable (PUBLIC)
--   Remove table from FND_TABLES and all its columns, indexes, primary
--   keys and foreign keys.
--
procedure RemoveTable(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2);

--
-- UploadTable (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading tables using
--   using afdict.lct. It calls InsertTable() when needed.
--
procedure UploadTable (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_user_table_name              in varchar2,
  x_table_type                   in varchar2,
  x_description                  in varchar2,
  x_auto_size                    in varchar2,
  x_initial_extent               in varchar2,
  x_next_extent                  in varchar2,
  x_min_extents                  in varchar2,
  x_max_extents                  in varchar2,
  x_ini_trans                    in varchar2,
  x_max_trans                    in varchar2,
  x_pct_free                     in varchar2,
  x_pct_increase                 in varchar2,
  x_pct_used                     in varchar2,
  x_hosted_support_style         in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UploadColumn (PUBLIC))- Overloaded
--   Public procedure for afdict.lct to call when uploading columns using
--   using afdict.lct. It calls InsertColumn() when needed.
--

procedure UploadColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_column_name                  in varchar2,
  x_user_column_name             in varchar2,
  x_column_sequence              in varchar2,
  x_column_type                  in varchar2,
  x_width                        in varchar2,
  x_null_allowed_flag            in varchar2,
  x_description                  in varchar2,
  x_default_value                in varchar2,
  x_translate_flag               in varchar2,
  x_precision                    in varchar2,
  x_scale                        in varchar2,
  x_flexfield_usage_code         in varchar2,
  x_flexfield_application_id     in varchar2,
  x_flexfield_name               in varchar2,
  x_flex_value_set_app_id        in varchar2,
  x_flex_value_set_id            in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UploadHistColumn (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading hist columns using
--   using afdict.lct. It calls InsertHistColumn() when needed.
--

procedure UploadHistColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_column_name                  in varchar2,
  x_partition                    in varchar2,
  x_hsize                        in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UploadIndex (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading indexes using
--   using afdict.lct. It calls InsertIndex() when needed.
--
procedure UploadIndex (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_index_name                   in varchar2,
  x_uniqueness                   in varchar2,
  x_auto_size                    in varchar2,
  x_description                  in varchar2,
  x_initial_extent               in varchar2,
  x_next_extent                  in varchar2,
  x_min_extents                  in varchar2,
  x_max_extents                  in varchar2,
  x_ini_trans                    in varchar2,
  x_max_trans                    in varchar2,
  x_pct_free                     in varchar2,
  x_pct_increase                 in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 		 in varchar2,
  x_last_update_date 		 in varchar2,
  x_phase_mode                   in varchar2);

--
-- UploadIndexColumn (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading index columns using
--   using afdict.lct.
--
procedure UploadIndexColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_index_name                   in varchar2,
  x_index_column_name            in varchar2,
  x_index_column_sequence        in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UploadPrimaryKey (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading primary key using
--   using afdict.lct.  It calls InsertPrimary() when needed.
--
procedure UploadPrimaryKey (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2,
  x_primary_key_type             in varchar2,
  x_audit_key_flag               in varchar2,
  x_description                  in varchar2,
  x_enabled_flag                 in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2,
  x_phase_mode			 in varchar2);

--
-- UploadPrimaryKeyColumn (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading primary key column
--   using afdict.lct.
--
procedure UploadPrimaryKeyColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2,
  x_primary_key_column_name      in varchar2,
  x_primary_key_column_sequence  in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UploadForeignKey (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading foreign key using
--   using afdict.lct.  It calls InsertForeign() when needed.
--
procedure UploadForeignKey (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_foreign_key_name             in varchar2,
  x_primary_key_application_name in varchar2,
  x_primary_key_table_name       in varchar2,
  x_primary_key_name             in varchar2,
  x_description                  in varchar2,
  x_cascade_behavior             in varchar2,
  x_foreign_key_relation         in varchar2,
  x_condition                    in varchar2,
  x_enabled_flag                 in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2,
  x_phase_mode			 in varchar2);

--
-- UploadForeignKeyColumn (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading foreign key column
--   using afdict.lct.
--
procedure UploadForeignKeyColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_foreign_key_name             in varchar2,
  x_foreign_key_column_name      in varchar2,
  x_foreign_key_column_sequence  in varchar2,
  x_cascade_value                in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UploadSequence (PUBLIC)) - Overloaded
--   Public procedure for afdict.lct to call when uploading sequence
--   using afdict.lct. It calls InsertSequence when needed.
--
procedure UploadSequence (
  x_application_short_name       in varchar2,
  x_sequence_name                in varchar2,
  x_start_value                  in varchar2,
  x_description                  in varchar2,
  x_increment_by                 in varchar2,
  x_min_value                    in varchar2,
  x_max_value                    in varchar2,
  x_cache_size                   in varchar2,
  x_cycle_flag                   in varchar2,
  x_order_flag                   in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UploadView (PUBLIC))- Overloaded
--   Public procedure for afdict.lct to call when uploading view
--   using afdict.lct. It calls InsertView when needed.
--
procedure UploadView (
  x_application_short_name       in varchar2,
  x_view_name                    in varchar2,
  x_text                         in varchar2,
  x_description                  in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2,
  x_phase_mode			 in varchar2);

--
-- UploadViewColumn (PUBLIC))- Overloaded
--   Public procedure for afdict.lct to call when uploading view column
--   using afdict.lct.
--
procedure UploadViewColumn (
  x_application_short_name       in varchar2,
  x_view_name                    in varchar2,
  x_view_column_name             in varchar2,
  x_view_column_sequence         in varchar2,
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2);

--
-- UpdatePKColumns (Public)
--
-- Description
--   For a given table(x_application_short_name and x_primary_table_name)
--   and column names array, find all pk/uk that contains all the columns
--   in the x_primary_key_col_names. For each of these pk/uk, call
--   UpdateChildren() to find their children table and do a recursive update.
--
-- Input
--   x_application_short_name:
--     application_short_name
--   x_primary_table_name:
--     table that contains the column name array
--   x_primary_key_col_names:
--     column name array
--   x_primary_key_col_value_old:
--     columns's existing value in array
--   x_primary_key_col_value_new:
--     columns's new value in array
--
-- Output
--   True: Succeed
--   False: Something went wrong, please check the logging info
function UpdatePKColumns(x_application_short_name     in varchar2,
                          x_primary_table_name         in varchar2,
                          x_primary_key_col_names      in NameArrayTyp,
                          x_primary_key_col_value_old  in NameArrayTyp,
                          x_primary_key_col_value_new  in NameArrayTyp)
return boolean;

-- CheckPKColumns (Public)
--
-- Description
--   For a given table(x_application_short_name and x_primary_table_name)
--   and column names array, find all pk/uk that contains all the columns
--   in the x_primary_key_col_names. For each of these pk/uk, call
--   UpdateOrCheckChildren() to see if there is any foreign key children has
--   the same value as the value inside x_primary_key_col_old.
--   If there is, return TRUE otherwise return FALSE.
--
-- Input
--   x_application_short_name:
--     application_short_name
--   x_primary_table_name:
--     table that contains the column name array
--   x_primary_key_col_names:
--     column name array
--   x_primary_key_col_value_old:
--     columns's existing value in array
--
-- Output
--   True: There is foreign key child with the same value.
--   False: No foreign key child has the same value.
function CheckPKColumns(x_application_short_name     in varchar2,
                        x_primary_table_name         in varchar2,
                        x_primary_key_col_names      in NameArrayTyp,
                        x_primary_key_col_value_old  in NameArrayTyp)
return boolean;
end Fnd_Dictionary_Pkg;

 

/

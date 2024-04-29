--------------------------------------------------------
--  DDL for Package Body FND_DICTIONARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DICTIONARY_PKG" as
/* $Header: AFDICTB.pls 120.5 2005/11/22 11:30:03 rsheh ship $ */

c_log_head CONSTANT varchar2(40) := 'fnd.plsql.fnd_dictionary_pkg.';
visited_tables fnd_dictionary_pkg.NameArrayTyp;
visited_table_count number := 0;
checking_log boolean := FALSE;

--
-- MultipleDeveloperKeys (PRIVATE))
--   Check if there are more than one Developer key for this table
--
function MultipleDeveloperKeys (
  x_application_id               in number,
  x_table_id                     in number,
  x_primary_key_name             in varchar2) return boolean
is
  l_tmp  number;
begin
   select count(*)
   into   l_tmp
   from   FND_PRIMARY_KEYS
   where  APPLICATION_ID = x_application_id
   and    TABLE_ID       = x_table_id
   and    PRIMARY_KEY_NAME  <> upper(x_primary_key_name)
   and    PRIMARY_KEY_TYPE = 'D';

   if (l_tmp > 0) then
      return(TRUE);
   else
      return(FALSE);
   end if;
end MultipleDeveloperKeys;

--
-- ValidatePrimaryKey (PRIVATE))
--   Check if this primary key is already exist
--
procedure ValidatePrimaryKey (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2,
  x_pk_application_id            in out nocopy number,
  x_pk_table_id                  in out nocopy number,
  x_pk_id                        in out nocopy number)
is
begin
   begin
     select P.APPLICATION_ID, P.TABLE_ID, P.PRIMARY_KEY_ID
     into   x_pk_application_id, x_pk_table_id, x_pk_id
     from   FND_PRIMARY_KEYS P,
            FND_TABLES T,
            FND_APPLICATION A
     where  A.APPLICATION_SHORT_NAME = x_application_short_name
     and    A.APPLICATION_ID = T.APPLICATION_ID
     and    T.TABLE_NAME = x_table_name
     and    T.TABLE_ID = P.TABLE_ID
     and    T.APPLICATION_ID = P.APPLICATION_ID
     and    P.PRIMARY_KEY_NAME  = upper(x_primary_key_name);
   exception
     when no_data_found then
       x_pk_id := -1;
   end;

end ValidatePrimaryKey;


--
-- ResolveConflictColumn (PRIVATE))
--   If there is a column has the same USER_COLUMN_NAME or COLUMN_SEQUENCE
--   bump it away by prepend '@' for USER_COLUMN_NAME and big number for
--   COLUMN_SEQUENCE.
--
procedure ResolveConflictColumn (
  x_application_id               in number,
  x_table_id                     in number,
  x_column_name                  in varchar2,
  x_user_column_name             in varchar2,
  x_column_sequence              in varchar2
) is
  maxseq number;
begin

  -- If there is no row updated, no exception will be raise.
  update FND_COLUMNS
  set USER_COLUMN_NAME = '@'||USER_COLUMN_NAME
  where APPLICATION_ID = x_application_id
  and 	TABLE_ID = x_table_id
  and   COLUMN_NAME <> x_column_name
  and   USER_COLUMN_NAME = x_user_column_name;

  select max(column_sequence)
  into maxseq
  from FND_COLUMNS
  where APPLICATION_ID = x_application_id
  and   TABLE_ID = x_table_id;

  update FND_COLUMNS
  set COLUMN_SEQUENCE = to_number('200001') + maxseq
  where APPLICATION_ID = x_application_id
  and 	TABLE_ID = x_table_id
  and   COLUMN_NAME <> x_column_name
  and   COLUMN_SEQUENCE = to_number(x_column_sequence);

end ResolveConflictColumn;

--
-- InsertTable (PRIVATE))
--   Add a new table into FND_TABLES. This is only called after checking
--   there is no such table exists in UploadTable().
--
procedure InsertTable (
  x_application_id               in number,
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
  x_creation_date                in date,
  x_created_by                   in number,
  x_last_update_date             in date,
  x_last_updated_by              in number,
  x_last_update_login            in number
) is
begin
  insert into FND_TABLES (
    APPLICATION_ID,
    TABLE_ID,
    TABLE_NAME,
    USER_TABLE_NAME,
    TABLE_TYPE,
    DESCRIPTION,
    AUTO_SIZE,
    INITIAL_EXTENT,
    NEXT_EXTENT,
    MIN_EXTENTS,
    MAX_EXTENTS,
    INI_TRANS,
    MAX_TRANS,
    PCT_FREE,
    PCT_INCREASE,
    PCT_USED,
    HOSTED_SUPPORT_STYLE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY)
    values (
    x_application_id,
    FND_TABLES_S.NEXTVAL,
    x_table_name,
    x_user_table_name,
    x_table_type,
    x_description,
    x_auto_size,
    x_initial_extent,
    x_next_extent,
    x_min_extents,
    x_max_extents,
    x_ini_trans,
    x_max_trans,
    x_pct_free,
    x_pct_increase,
    x_pct_used,
    x_hosted_support_style,
    x_last_updated_by,
    x_last_update_date,
    x_last_update_login,
    x_last_update_date,
    x_last_updated_by);

end InsertTable;

--
-- InsertColumn (PRIVATE))
--   Add a new column into FND_COLUMNS. This is only called after checking
--   there is no such column exists in UploadColumn().
--
procedure InsertColumn (
  x_application_id               in number,
  x_table_id                     in number,
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
  x_creation_date                in date,
  x_created_by                   in number,
  x_last_update_date             in date,
  x_last_updated_by              in number,
  x_last_update_login            in number
) is

begin

  insert into FND_COLUMNS (
      APPLICATION_ID,
      TABLE_ID,
      COLUMN_ID,
      COLUMN_NAME,
      USER_COLUMN_NAME,
      COLUMN_SEQUENCE,
      COLUMN_TYPE,
      WIDTH,
      NULL_ALLOWED_FLAG,
      DESCRIPTION,
      DEFAULT_VALUE,
      TRANSLATE_FLAG,
      PRECISION,
      SCALE,
      FLEXFIELD_USAGE_CODE,
      FLEXFIELD_APPLICATION_ID,
      FLEXFIELD_NAME,
      FLEX_VALUE_SET_APPLICATION_ID,
      FLEX_VALUE_SET_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN)
      values (
      x_application_id,
      x_table_id,
      FND_COLUMNS_S.NEXTVAL,
      x_column_name,
      x_user_column_name,
      x_column_sequence,
      x_column_type,
      x_width,
      x_null_allowed_flag,
      x_description,
      x_default_value,
      x_translate_flag,
      x_precision,
      x_scale,
      x_flexfield_usage_code,
      x_flexfield_application_id,
      x_flexfield_name,
      x_flex_value_set_app_id,
      x_flex_value_set_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_updated_by,
      x_last_update_date,
      x_last_update_login);

end InsertColumn;

--
-- InsertIndex (PRIVATE))
--   Add a new index into FND_INDEXES. This is only called after checking
--   there is no such index exists in UploadIndex().
--
procedure InsertIndex (
  x_application_id               in number,
  x_table_id                     in number,
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
  x_creation_date                in date,
  x_created_by                   in number,
  x_last_update_date             in date,
  x_last_updated_by              in number,
  x_last_update_login            in number

) is

begin

  insert into FND_INDEXES (
      APPLICATION_ID,
      TABLE_ID,
      INDEX_ID,
      INDEX_NAME,
      UNIQUENESS,
      AUTO_SIZE,
      DESCRIPTION,
      INITIAL_EXTENT,
      NEXT_EXTENT,
      MIN_EXTENTS,
      MAX_EXTENTS,
      INI_TRANS,
      MAX_TRANS,
      PCT_FREE,
      PCT_INCREASE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values (
      x_application_id,
      x_table_id,
      FND_INDEXES_S.NEXTVAL,
      x_index_name,
      x_uniqueness,
      x_auto_size,
      x_description,
      x_initial_extent,
      x_next_extent,
      x_min_extents,
      x_max_extents,
      x_ini_trans,
      x_max_trans,
      x_pct_free,
      x_pct_increase,
      x_last_updated_by,
      x_last_update_date,
      x_last_update_login,
      x_last_update_date,
      x_last_updated_by);
end InsertIndex;

--
-- InsertPrimaryKey (PRIVATE))
--   Add a new primary key into FND_PRIMARY_KEYS.
--   This is only called after checking
--   there is no such primary key exists in UploadPrimaryKey().
--
procedure InsertPrimaryKey(
  x_application_id               in number,
  x_table_id                     in number,
  x_primary_key_name             in varchar2,
  x_primary_key_type             in varchar2,
  x_audit_key_flag               in varchar2,
  x_enabled_flag                 in varchar2,
  x_description                  in varchar2,
  x_creation_date                in date,
  x_created_by                   in number,
  x_last_update_date             in date,
  x_last_updated_by              in number,
  x_last_update_login            in number
) is

begin

  insert into FND_PRIMARY_KEYS(
      APPLICATION_ID,
      TABLE_ID,
      PRIMARY_KEY_NAME,
      PRIMARY_KEY_ID,
      PRIMARY_KEY_TYPE,
      AUDIT_KEY_FLAG,
      ENABLED_FLAG,
      DESCRIPTION,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values (
      x_application_id,
      x_table_id,
      x_primary_key_name,
      FND_PRIMARY_KEYS_S.NEXTVAL,
      x_primary_key_type,
      x_audit_key_flag,
      x_enabled_flag,
      x_description,
      x_last_updated_by,
      x_last_update_date,
      x_last_update_login,
      x_last_update_date,
      x_last_updated_by);
end InsertPrimaryKey;

--
-- InsertForeignKey (PRIVATE))
--   Add a new foreign key into FND_FOREIGN_KEYS.
--   This is only called after checking
--   there is no such foreign key exists in UploadForeignKey().
--
procedure InsertForeignKey(
  x_application_id               in number,
  x_table_id                     in number,
  x_foreign_key_name             in varchar2,
  x_primary_key_application_id   in number,
  x_primary_key_table_id         in number,
  x_primary_key_id               in number,
  x_description                  in varchar2,
  x_cascade_behavior             in varchar2,
  x_foreign_key_relation         in varchar2,
  x_condition                    in varchar2,
  x_enabled_flag                 in varchar2,
  x_creation_date                in date,
  x_created_by                   in number,
  x_last_update_date             in date,
  x_last_updated_by              in number,
  x_last_update_login            in number
) is

begin

  insert into FND_FOREIGN_KEYS(
      APPLICATION_ID,
      TABLE_ID,
      FOREIGN_KEY_ID,
      FOREIGN_KEY_NAME,
      PRIMARY_KEY_APPLICATION_ID,
      PRIMARY_KEY_TABLE_ID,
      PRIMARY_KEY_ID,
      DESCRIPTION,
      CASCADE_BEHAVIOR,
      FOREIGN_KEY_RELATION,
      CONDITION,
      ENABLED_FLAG,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values (
      x_application_id,
      x_table_id,
      FND_FOREIGN_KEYS_S.NEXTVAL,
      x_foreign_key_name,
      x_primary_key_application_id,
      x_primary_key_table_id,
      x_primary_key_id,
      x_description,
      x_cascade_behavior,
      x_foreign_key_relation,
      x_condition,
      x_enabled_flag,
      x_last_updated_by,
      x_last_update_date,
      x_last_update_login,
      x_last_update_date,
      x_last_updated_by);
end InsertForeignKey;

--
-- InsertSequence (PRIVATE))
--   Add a new sequence into FND_SEQUENCES. This is only called after checking
--   there is no such sequence exists in UploadSequence().
--
procedure InsertSequence (
  x_application_id               in number,
  x_sequence_name                in varchar2,
  x_start_value                  in varchar2,
  x_description                  in varchar2,
  x_increment_by                 in varchar2,
  x_min_value                    in varchar2,
  x_max_value                    in varchar2,
  x_cache_size                   in varchar2,
  x_cycle_flag                   in varchar2,
  x_order_flag                   in varchar2,
  x_creation_date                in date,
  x_created_by                   in number,
  x_last_update_date             in date,
  x_last_updated_by              in number,
  x_last_update_login            in number
) is
begin
  insert into FND_SEQUENCES (
    APPLICATION_ID,
    SEQUENCE_ID,
    SEQUENCE_NAME,
    START_VALUE,
    DESCRIPTION,
    INCREMENT_BY,
    MIN_VALUE,
    MAX_VALUE,
    CACHE_SIZE,
    CYCLE_FLAG,
    ORDER_FLAG,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY)
    values (
    x_application_id,
    FND_SEQUENCES_S.NEXTVAL,
    x_sequence_name,
    x_start_value,
    x_description,
    x_increment_by,
    x_min_value,
    x_max_value,
    x_cache_size,
    x_cycle_flag,
    x_order_flag,
    x_last_updated_by,
    x_last_update_date,
    x_last_update_login,
    x_last_update_date,
    x_last_updated_by);

end InsertSequence;

--
-- InsertView (PRIVATE))
--   Add a new view into FND_VIEWS. This is only called after checking
--   there is no such view key exists in UploadView().
--
procedure InsertView (
  x_application_id               in number,
  x_view_name                    in varchar2,
  x_text                         in varchar2,
  x_description                  in varchar2,
  x_creation_date                in date,
  x_created_by                   in number,
  x_last_update_date             in date,
  x_last_updated_by              in number,
  x_last_update_login            in number
) is
begin
  insert into FND_VIEWS (
    APPLICATION_ID,
    VIEW_ID,
    VIEW_NAME,
    TEXT,
    DESCRIPTION,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY)
    values (
    x_application_id,
    FND_VIEWS_S.NEXTVAL,
    x_view_name,
    x_text,
    x_description,
    x_last_updated_by,
    x_last_update_date,
    x_last_update_login,
    x_last_update_date,
    x_last_updated_by);

end InsertView;

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
  x_user_id                      in varchar2
) is
begin

UploadTable (
  x_application_short_name => x_application_short_name,
  x_table_name => 		x_table_name,
  x_user_table_name =>       	x_user_table_name,
  x_table_type => 		x_table_type,
  x_description =>		x_description,
  x_auto_size =>              x_auto_size,
  x_initial_extent=>   		x_initial_extent,
  x_next_extent =>            x_next_extent,
  x_min_extents =>            x_min_extents,
  x_max_extents =>            x_max_extents,
  x_ini_trans  =>             x_ini_trans,
  x_max_trans =>              x_max_trans,
  x_pct_free =>               x_pct_free,
  x_pct_increase =>           x_pct_increase,
  x_pct_used =>               x_pct_used,
  x_hosted_support_style =>   x_hosted_support_style,
  x_user_id =>                x_user_id,
  x_custom_mode =>		null,
  x_last_update_date =>		null);

end UploadTable;

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
  x_user_id                      in varchar2
) is
begin

UploadColumn (
  x_application_short_name =>    x_application_short_name,
  x_table_name =>                x_table_name,
  x_column_name =>               x_column_name,
  x_user_column_name =>          x_user_column_name,
  x_column_sequence =>           x_column_sequence,
  x_column_type =>               x_column_type,
  x_width =>                     x_width,
  x_null_allowed_flag =>         x_null_allowed_flag,
  x_description =>               x_description,
  x_default_value =>             x_default_value,
  x_translate_flag =>            x_translate_flag,
  x_precision =>                 x_precision,
  x_scale =>                     x_scale,
  x_flexfield_usage_code =>      x_flexfield_usage_code,
  x_flexfield_application_id =>  x_flexfield_application_id,
  x_flexfield_name =>            x_flexfield_name,
  x_flex_value_set_app_id =>     x_flex_value_set_app_id,
  x_flex_value_set_id =>         x_flex_value_set_id,
  x_user_id =>                   x_user_id,
  x_custom_mode =>		   null,
  x_last_update_date =>		   null);

end UploadColumn;

--
-- UploadHistColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading columns using
--   using afdict.lct. It calls InsertHistColumn() when needed.
--
procedure UploadHistColumn (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_column_name                  in varchar2,
  x_partition                    in varchar2,
  x_hsize                        in varchar2,
  x_user_id                      in varchar2
) is
begin
UploadHistColumn (
  x_application_short_name => x_application_short_name,
  x_table_name =>       	x_table_name,
  x_column_name =>     		x_column_name,
  x_partition =>         	x_partition,
  x_hsize  =>        		x_hsize,
  x_user_id =>        		x_user_id,
  x_custom_mode =>    		null,
  x_last_update_date => 	null);
end UploadHistColumn;



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
  x_user_id                      in varchar2
) is
begin

UploadIndex (
  x_application_short_name =>	x_application_short_name,
  x_table_name => 		x_table_name,
  x_index_name =>		x_index_name,
  x_uniqueness =>   		x_uniqueness,
  x_auto_size =>  		x_auto_size,
  x_description =>		x_description,
  x_initial_extent => 		x_initial_extent,
  x_next_extent => 		x_next_extent,
  x_min_extents =>  		x_min_extents,
  x_max_extents => 		x_max_extents,
  x_ini_trans => 		x_ini_trans,
  x_max_trans =>		x_max_trans,
  x_pct_free =>			x_pct_free,
  x_pct_increase =>  		x_pct_increase,
  x_user_id  =>  		x_user_id,
  x_custom_mode => 		null,
  x_last_update_date => 	null,
  x_phase_mode =>		'BEGIN');


UploadIndex (
  x_application_short_name =>   x_application_short_name,
  x_table_name =>               x_table_name,
  x_index_name =>               x_index_name,
  x_uniqueness =>               x_uniqueness,
  x_auto_size =>                x_auto_size,
  x_description =>              x_description,
  x_initial_extent =>           x_initial_extent,
  x_next_extent =>              x_next_extent,
  x_min_extents =>              x_min_extents,
  x_max_extents =>              x_max_extents,
  x_ini_trans =>                x_ini_trans,
  x_max_trans =>                x_max_trans,
  x_pct_free =>                 x_pct_free,
  x_pct_increase =>             x_pct_increase,
  x_user_id  =>                 x_user_id,
  x_custom_mode =>              null,
  x_last_update_date =>         null,
  x_phase_mode =>               'END');

end UploadIndex;


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
  x_user_id                      in varchar2
) is
begin

UploadIndexColumn (
  x_application_short_name =>	x_application_short_name,
  x_table_name => 		x_table_name,
  x_index_name => 		x_index_name,
  x_index_column_name => 	x_index_column_name,
  x_index_column_sequence =>	x_index_column_sequence,
  x_user_id  => 			x_user_id,
  x_custom_mode => 		null,
  x_last_update_date => 	null);
end UploadIndexColumn;

--
-- UploadPrimaryKey (PUBLIC))
--   Public procedure for afdict.lct to call when uploading primary key using
--   using afdict.lct. It calls InsertPrimary() when needed.
--
procedure UploadPrimaryKey (
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2,
  x_primary_key_type             in varchar2,
  x_audit_key_flag               in varchar2,
  x_description                  in varchar2,
  x_enabled_flag                 in varchar2,
  x_user_id                      in varchar2
) is
begin

UploadPrimaryKey (
  x_application_short_name =>	x_application_short_name,
  x_table_name => 		x_table_name,
  x_primary_key_name => 	x_primary_key_name,
  x_primary_key_type =>		x_primary_key_type,
  x_audit_key_flag => 		x_audit_key_flag,
  x_description=> 		x_description,
  x_enabled_flag =>		x_enabled_flag,
  x_user_id =>			x_user_id,
  x_custom_mode => 		null,
  x_last_update_date => 	null,
  x_phase_mode =>		'BEGIN');

UploadPrimaryKey (
  x_application_short_name =>   x_application_short_name,
  x_table_name =>               x_table_name,
  x_primary_key_name =>         x_primary_key_name,
  x_primary_key_type =>         x_primary_key_type,
  x_audit_key_flag =>           x_audit_key_flag,
  x_description=>               x_description,
  x_enabled_flag =>             x_enabled_flag,
  x_user_id =>                  x_user_id,
  x_custom_mode =>              null,
  x_last_update_date =>         null,
  x_phase_mode =>               'END');

end UploadPrimaryKey;

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
  x_user_id                      in varchar2
) is
begin

UploadPrimaryKeyColumn (
  x_application_short_name =>	x_application_short_name,
  x_table_name => 		x_table_name,
  x_primary_key_name => 	x_primary_key_name,
  x_primary_key_column_name =>x_primary_key_column_name,
  x_primary_key_column_sequence =>x_primary_key_column_sequence,
  x_user_id  => 			x_user_id,
  x_custom_mode =>		null,
  x_last_update_date =>		null);

end UploadPrimaryKeyColumn;

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
  x_user_id                      in varchar2
) is
begin

 UploadForeignKey (
  x_application_short_name =>	x_application_short_name,
  x_table_name  =>     		x_table_name,
  x_foreign_key_name =>     	x_foreign_key_name,
  x_primary_key_application_name => x_primary_key_application_name,
  x_primary_key_table_name =>   x_primary_key_table_name,
  x_primary_key_name =>        	x_primary_key_name,
  x_description =>       	x_description,
  x_cascade_behavior =>       	x_cascade_behavior,
  x_foreign_key_relation =>    	x_foreign_key_relation,
  x_condition =>     		x_condition,
  x_enabled_flag =>     	x_enabled_flag,
  x_user_id =>      		x_user_id,
  x_custom_mode =>              null,
  x_last_update_date =>         null,
  x_phase_mode =>		'BEGIN');

 UploadForeignKey (
  x_application_short_name =>   x_application_short_name,
  x_table_name  =>              x_table_name,
  x_foreign_key_name =>         x_foreign_key_name,
  x_primary_key_application_name => x_primary_key_application_name,
  x_primary_key_table_name =>   x_primary_key_table_name,
  x_primary_key_name =>         x_primary_key_name,
  x_description =>              x_description,
  x_cascade_behavior =>         x_cascade_behavior,
  x_foreign_key_relation =>     x_foreign_key_relation,
  x_condition =>                x_condition,
  x_enabled_flag =>             x_enabled_flag,
  x_user_id =>                  x_user_id,
  x_custom_mode =>              null,
  x_last_update_date =>         null,
  x_phase_mode =>               'END');


end UploadForeignKey;

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
  x_user_id                      in varchar2
) is
begin
 UploadForeignKeyColumn (
  x_application_short_name =>	x_application_short_name,
  x_table_name => 		x_table_name,
  x_foreign_key_name => 	x_foreign_key_name,
  x_foreign_key_column_name =>  x_foreign_key_column_name,
  x_foreign_key_column_sequence => x_foreign_key_column_sequence,
  x_cascade_value => 		x_cascade_value,
  x_user_id =>			x_user_id,
  x_custom_mode => 		null,
  x_last_update_date =>		null);

end UploadForeignKeyColumn;


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
  x_user_id                      in varchar2
) is
begin
 UploadSequence (
  x_application_short_name => 	x_application_short_name,
  x_sequence_name => 		x_sequence_name,
  x_start_value => 		x_start_value,
  x_description => 		x_description,
  x_increment_by => 		x_increment_by,
  x_min_value => 		x_min_value,
  x_max_value => 		x_max_value,
  x_cache_size => 		x_cache_size,
  x_cycle_flag => 		x_cycle_flag,
  x_order_flag => 		x_order_flag,
  x_user_id => 			x_user_id,
  x_custom_mode =>  		null,
  x_last_update_date => 	null);

end UploadSequence;

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
  x_user_id                      in varchar2
) is
begin
 UploadView (
  x_application_short_name => 	x_application_short_name,
  x_view_name => 		x_view_name,
  x_text => 			x_text,
  x_description => 		x_description,
  x_user_id => 			x_user_id,
  x_custom_mode => 		null,
  x_last_update_date => 	null,
  x_phase_mode =>		'BEGIN');

 UploadView (
  x_application_short_name =>   x_application_short_name,
  x_view_name =>                x_view_name,
  x_text =>                     x_text,
  x_description =>              x_description,
  x_user_id =>                  x_user_id,
  x_custom_mode =>              null,
  x_last_update_date =>         null,
  x_phase_mode =>               'END');


end UploadView;

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
  x_user_id                      in varchar2
) is
begin
UploadViewColumn (
  x_application_short_name =>	x_application_short_name,
  x_view_name => 		x_view_name,
  x_view_column_name => 	x_view_column_name,
  x_view_column_sequence => 	x_view_column_sequence,
  x_user_id => 			x_user_id,
  x_custom_mode => 		null,
  x_last_update_date => 	null);

end UploadViewColumn;

--
-- ViewTextLength (PUBLIC)
--   Return the view text length.
--   This is a helper function as length() function can not be used
--   directly in sql but is ok to used on a variable in PL/SQL.
--
/*
function ViewTextLength (
  x_application_id               in number,
  x_view_name                    in varchar2) return number
is
  len  number;
begin
   for r in (select text from fnd_views
             where application_id = x_application_id
             and   view_name = x_view_name) loop
     len := length(r.text);

   end loop;

   return(len);
end ViewTextLength;
*/
-- There is no way we can figure out the lenght of a LONG column, so
-- just have to trap that ORA-1406.
function ViewTextLength (
  x_application_id               in number,
  x_view_name                    in varchar2) return number
is
  len  number;
  vtext varchar2(32000);
begin
   begin
     select text
     into vtext
     from fnd_views
     where application_id = x_application_id
     and   view_name = x_view_name;
     len := 200;
     return(len);
   exception
     when others then
       if (SQLCODE = -1406) then
         len := 33000;
       end if;
       return(len);
   end;

end ViewTextLength;

--
-- RemoveColumn (PUBLIC)
--   Remove column from FND_COLUMNS table.
--   Before removing this column, make sure that there is no index,
--   primary key or foreign key is using this column
--
procedure RemoveColumn(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_column_name                  in varchar2) is
  appl_id number;
  tab_id number;
  col_id number;
  cnt number;
begin
  begin
    select application_id
    into appl_id
    from fnd_application
    where application_short_name = upper(x_application_short_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_application_short_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select table_id
    into tab_id
    from fnd_tables
    where application_id = appl_id
    and table_name = upper(x_table_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_TABLES');
      fnd_message.set_token('COLUMN', 'TABLE_NAME');
      fnd_message.set_token('VALUE', x_table_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select column_id
    into col_id
    from fnd_columns
    where application_id = appl_id
    and table_id = tab_id
    and column_name = upper(x_column_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_COLUMNS');
      fnd_message.set_token('COLUMN', 'COLUMN_NAME');
      fnd_message.set_token('VALUE', x_column_name);
      app_exception.raise_exception;
      return;
  end;

  -- Before removing this column, make sure that there is no index,
  -- primary key or foreign key is using this column

  -- Check index column
  cnt := 0;
  select count(*) into cnt
  from fnd_index_columns
  where application_id = appl_id
  and table_id = tab_id
  and column_id = col_id;
  if (cnt > 0) then
    fnd_message.set_name('FND', 'FND-CHILD EXISTS');
    fnd_message.set_token('APPLICATION', x_application_short_name);
    fnd_message.set_token('TABLE', x_table_name);
    fnd_message.set_token('COLUMN', x_column_name);
    fnd_message.set_token('CHILD', 'INDEX COLUMN');
    app_exception.raise_exception;
    return;
  end if;

  -- Check primary key column
  cnt := 0;
  select count(*) into cnt
  from fnd_primary_key_columns
  where application_id = appl_id
  and table_id = tab_id
  and column_id = col_id;
  if (cnt > 0) then
    fnd_message.set_name('FND', 'FND-CHILD EXISTS');
    fnd_message.set_token('APPLICATION', x_application_short_name);
    fnd_message.set_token('TABLE', x_table_name);
    fnd_message.set_token('COLUMN', x_column_name);
    fnd_message.set_token('CHILD', 'PRIMARY KEY COLUMN');
    app_exception.raise_exception;
    return;
  end if;

  -- Check foreign key column
  cnt := 0;
  select count(*) into cnt
  from fnd_foreign_key_columns
  where application_id = appl_id
  and table_id = tab_id
  and column_id = col_id;
  if (cnt > 0) then
    fnd_message.set_name('FND', 'FND-CHILD EXISTS');
    fnd_message.set_token('APPLICATION', x_application_short_name);
    fnd_message.set_token('TABLE', x_table_name);
    fnd_message.set_token('COLUMN', x_column_name);
    fnd_message.set_token('CHILD', 'FOREIGN KEY COLUMN');
    app_exception.raise_exception;
    return;
  end if;

  delete from fnd_columns
  where application_id = appl_id
  and table_id = tab_id
  and column_id = col_id;

end RemoveColumn;

--
-- RemoveIndex (PUBLIC)
--   Remove index from FND_INDEXES and FND_INDEX_COLUMNS table.
--
procedure RemoveIndex(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_index_name                   in varchar2) is
  appl_id number;
  tab_id number;
  ind_id number;
begin
  begin
    select application_id
    into appl_id
    from fnd_application
    where application_short_name = upper(x_application_short_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_application_short_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select table_id
    into tab_id
    from fnd_tables
    where application_id = appl_id
    and table_name = upper(x_table_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_TABLES');
      fnd_message.set_token('COLUMN', 'TABLE_NAME');
      fnd_message.set_token('VALUE', x_table_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select index_id
    into ind_id
    from fnd_indexes
    where application_id = appl_id
    and table_id = tab_id
    and index_name = upper(x_index_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_INDEXES');
      fnd_message.set_token('COLUMN', 'INDEX_NAME');
      fnd_message.set_token('VALUE', x_index_name);
      app_exception.raise_exception;
      return;
  end;

  -- Delete index columns
  delete from fnd_index_columns
  where application_id = appl_id
  and table_id = tab_id
  and index_id = ind_id;

  delete from fnd_indexes
  where application_id = appl_id
  and table_id = tab_id
  and index_id = ind_id;

end RemoveIndex;

--
-- RemovePrimaryKey (PUBLIC)
--   Remove primary key from FND_PRIMARY_KEYS and FND_PRIMARY_KEY_COLUMNS table.
--   Before deleting primary key, make sure that there is no foreign key
--   pointing to this primary key
--
procedure RemovePrimaryKey(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_primary_key_name             in varchar2) is
  appl_id number;
  tab_id number;
  pk_id number;
  cnt number;
begin
  begin
    select application_id
    into appl_id
    from fnd_application
    where application_short_name = upper(x_application_short_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_application_short_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select table_id
    into tab_id
    from fnd_tables
    where application_id = appl_id
    and table_name = upper(x_table_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_TABLES');
      fnd_message.set_token('COLUMN', 'TABLE_NAME');
      fnd_message.set_token('VALUE', x_table_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select primary_key_id
    into pk_id
    from fnd_primary_keys
    where application_id = appl_id
    and table_id = tab_id
    and primary_key_name = upper(x_primary_key_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_PRIMARY_KEYS');
      fnd_message.set_token('COLUMN', 'PRIMARY_KEY_NAME');
      fnd_message.set_token('VALUE', x_primary_key_name);
      app_exception.raise_exception;
      return;
  end;

  -- Before deleting primary key, make sure that there is no foreign key
  -- pointing to this primary key

  cnt := 0;
  select count(*) into cnt
  from fnd_foreign_keys
  where primary_key_application_id = appl_id
  and primary_key_table_id = tab_id
  and primary_key_id = pk_id;

  if (cnt = 0) then
    delete from fnd_primary_key_columns
    where application_id = appl_id
    and table_id = tab_id
    and primary_key_id = pk_id;

    delete from fnd_primary_keys
    where application_id = appl_id
    and table_id = tab_id
    and primary_key_id = pk_id;

  else
    -- There are foreign keys pointing to this primary key.
    -- Removing the foreign key before removing this primary key
    fnd_message.set_name('FND', 'FND-FOREIGN KEY EXISTS');
    fnd_message.set_token('PRIMARY_KEY', x_primary_key_name);
    app_exception.raise_exception;
    return;
  end if;

end RemovePrimaryKey;

--
-- RemoveForeignKey (PUBLIC)
--   Remove foreign key from FND_FOREIGN_KEYS and FND_FOREIGN_KEY_COLUMNS table.
--
procedure RemoveForeignKey(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2,
  x_foreign_key_name             in varchar2) is
  appl_id number;
  tab_id number;
  fk_id number;
begin
  begin
    select application_id
    into appl_id
    from fnd_application
    where application_short_name = upper(x_application_short_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_application_short_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select table_id
    into tab_id
    from fnd_tables
    where application_id = appl_id
    and table_name = upper(x_table_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_TABLES');
      fnd_message.set_token('COLUMN', 'TABLE_NAME');
      fnd_message.set_token('VALUE', x_table_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select foreign_key_id
    into fk_id
    from fnd_foreign_keys
    where application_id = appl_id
    and table_id = tab_id
    and foreign_key_name = upper(x_foreign_key_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_FOREIGN_KEYS');
      fnd_message.set_token('COLUMN', 'FOREIGN_KEY_NAME');
      fnd_message.set_token('VALUE', x_foreign_key_name);
      app_exception.raise_exception;
      return;
  end;

  -- Nothing pointing to foreign key so is safe to delete
  delete from fnd_foreign_key_columns
  where application_id = appl_id
  and table_id = tab_id
  and foreign_key_id = fk_id;

  delete from fnd_foreign_keys
  where application_id = appl_id
  and table_id = tab_id
  and foreign_key_id = fk_id;

end RemoveForeignKey;

--
-- RemoveSequence (PUBLIC)
--   Remove sequence from FND_SEQUENCES table.
--
procedure RemoveSequence(
  x_application_short_name       in varchar2,
  x_sequence_name                in varchar2) is
  appl_id number;
begin
  begin
    select application_id
    into appl_id
    from fnd_application
    where application_short_name = upper(x_application_short_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_application_short_name);
      app_exception.raise_exception;
      return;
  end;

  delete from fnd_sequences
  where application_id = appl_id
  and sequence_name = upper(x_sequence_name);
  if (SQL%ROWCOUNT = 0) then
    fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
    fnd_message.set_token('TABLE', 'FND_SEQUENCES');
    fnd_message.set_token('COLUMN', 'SEQUENCE_NAME');
    fnd_message.set_token('VALUE', x_sequence_name);
    app_exception.raise_exception;
    return;
  end if;

end RemoveSequence;

--
-- RemoveView (PUBLIC)
--   Remove view from FND_VIEWS and FND_VIEW_COLUMNS table.
--
procedure RemoveView(
  x_application_short_name       in varchar2,
  x_view_name                    in varchar2) is
  appl_id number;
  vw_id number;
begin
  begin
    select application_id
    into appl_id
    from fnd_application
    where application_short_name = upper(x_application_short_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_application_short_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select view_id into vw_id
    from fnd_views
    where application_id = appl_id
    and view_name = upper(x_view_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_VIEWS');
      fnd_message.set_token('COLUMN', 'VIEW_NAME');
      fnd_message.set_token('VALUE', x_view_name);
      app_exception.raise_exception;
      return;
  end;

  -- Nothing pointing to view, so is safe to delete
  delete from fnd_view_columns
  where application_id = appl_id
  and view_id = vw_id;

  delete from fnd_views
  where application_id = appl_id
  and view_id = vw_id;

end RemoveView;

--
-- RemoveTable (PUBLIC)
--   Remove table from FND_TABLES and all its columns, indexes, primary
--   keys and foreign keys.
--
procedure RemoveTable(
  x_application_short_name       in varchar2,
  x_table_name                   in varchar2) is
  appl_id number;
  tab_id number;

  cursor ind is
  select index_name
  from fnd_indexes
  where application_id = appl_id
  and table_id = tab_id;

  cursor fk is
  select foreign_key_name
  from fnd_foreign_keys
  where application_id = appl_id
  and table_id = tab_id;

  cursor pk is
  select primary_key_name
  from fnd_primary_keys
  where application_id = appl_id
  and table_id = tab_id;

begin

  begin
    select application_id
    into appl_id
    from fnd_application
    where application_short_name = upper(x_application_short_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_application_short_name);
      app_exception.raise_exception;
      return;
  end;

  begin
    select table_id
    into tab_id
    from fnd_tables
    where application_id = appl_id
    and table_name = upper(x_table_name);
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_TABLES');
      fnd_message.set_token('COLUMN', 'TABLE_NAME');
      fnd_message.set_token('VALUE', x_table_name);
      app_exception.raise_exception;
      return;
  end;

  -- Before removing this table, remove all the children.

  -- Remove indexes
  for c_ind in ind loop
    RemoveIndex(x_application_short_name, x_table_name, c_ind.index_name);
  end loop;

  -- Remove foreign keys
  for c_fk in fk loop
    RemoveForeignKey(x_application_short_name, x_table_name,
                     c_fk.foreign_key_name);
  end loop;

  -- Remove primary keys
  for c_pk in pk loop
    RemovePrimaryKey(x_application_short_name, x_table_name,
                     c_pk.primary_key_name);
  end loop;

  -- Remove columns
  delete from fnd_columns
  where application_id = appl_id
  and table_id = tab_id;

  -- Remove table itself
  delete from fnd_tables
  where application_id = appl_id
  and table_id = tab_id;

end RemoveTable;

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
  x_last_update_date 		   in varchar2
) is
  appl_id number;
  dummy varchar2(1);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

  -- Validate application
  begin
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-APPLICATION NAME');
      fnd_message.set_token('APPLICATION_NAME', x_application_short_name);
      app_exception.raise_exception;
  end;

  -- Validate hosted support style
  begin
    if (x_hosted_support_style <> 'LOCAL') then
      select 'X' into dummy
        from fnd_lookups
       where lookup_type = 'HOSTED_SUPPORT_STYLE'
         and lookup_code = x_hosted_support_style;
    end if;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-HOSTED SUPPORT STYLE');
      fnd_message.set_token('HOSTED_SUPPORT_STYLE', x_hosted_support_style);
      app_exception.raise_exception;
  end;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_TABLES
    where APPLICATION_ID = appl_id
    and TABLE_NAME = x_table_name;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

-- Resolve USER_TABLE_NAME by pre-pending '@'
  update FND_TABLES
  set USER_TABLE_NAME = '@'||USER_TABLE_NAME
  where APPLICATION_ID = appl_id
  and 	TABLE_NAME <> x_table_name
  and   USER_TABLE_NAME = x_user_table_name;

  update FND_TABLES set
      USER_TABLE_NAME = x_user_table_name,
      TABLE_TYPE = x_table_type,
      DESCRIPTION = x_description,
      AUTO_SIZE = x_auto_size,
      INITIAL_EXTENT = x_initial_extent,
      NEXT_EXTENT = x_next_extent,
      MIN_EXTENTS = x_min_extents,
      MAX_EXTENTS = x_max_extents,
      INI_TRANS = x_ini_trans,
      MAX_TRANS = x_max_trans,
      PCT_FREE = x_pct_free,
      PCT_INCREASE = x_pct_increase,
      PCT_USED = x_pct_used,
      HOSTED_SUPPORT_STYLE = x_hosted_support_style,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATE_LOGIN = f_luby
  where APPLICATION_ID = appl_id
  and   TABLE_NAME = x_table_name;
 end if;
exception
 when no_data_found then
    Fnd_Dictionary_Pkg.InsertTable(
        appl_id,
        x_table_name,
        x_user_table_name,
        x_table_type,
        x_description,
        x_auto_size,
        x_initial_extent,
        x_next_extent,
        x_min_extents,
        x_max_extents,
        x_ini_trans,
        x_max_trans,
        x_pct_free,
        x_pct_increase,
        x_pct_used,
        x_hosted_support_style,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
end;
end UploadTable;

--
-- UploadColumn (PUBLIC)) - Overloaded
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
  x_last_update_date 		   in varchar2
) is
  tab_id number;
  appl_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

  -- Because Column is in the same entity as Table, no need to validate
  -- Application and Table again.
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select T.TABLE_ID into tab_id from FND_TABLES T
  where T.APPLICATION_ID = appl_id
  and T.TABLE_NAME = x_table_name;

  ResolveConflictColumn(appl_id, tab_id, x_column_name, x_user_column_name,
                       x_column_sequence);

    -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_COLUMNS
    where APPLICATION_ID = appl_id
    and TABLE_ID = tab_id
    and COLUMN_NAME = x_column_name;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

      update FND_COLUMNS set
      USER_COLUMN_NAME = x_user_column_name,
      COLUMN_SEQUENCE = x_column_sequence,
      COLUMN_TYPE = x_column_type,
      WIDTH = x_width,
      NULL_ALLOWED_FLAG = x_null_allowed_flag,
      DESCRIPTION = x_description,
      DEFAULT_VALUE = x_default_value,
      TRANSLATE_FLAG = x_translate_flag,
      PRECISION = x_precision,
      SCALE = x_scale,
      FLEXFIELD_USAGE_CODE = x_flexfield_usage_code,
      FLEXFIELD_APPLICATION_ID = x_flexfield_application_id,
      FLEXFIELD_NAME = x_flexfield_name,
      FLEX_VALUE_SET_APPLICATION_ID = x_flex_value_set_app_id,
      FLEX_VALUE_SET_ID = x_flex_value_set_id,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATE_LOGIN = f_luby
  where APPLICATION_ID = appl_id
  and   TABLE_ID = tab_id
  and   COLUMN_NAME = x_column_name;
 end if;
exception
 when no_data_found then
    Fnd_Dictionary_Pkg.InsertColumn(
        appl_id,
        tab_id,
        x_column_name,
        x_user_column_name,
        x_column_sequence,
        x_column_type,
        x_width,
        x_null_allowed_flag,
        x_description,
        x_default_value,
        x_translate_flag,
        x_precision,
        x_scale,
        x_flexfield_usage_code,
        x_flexfield_application_id,
        x_flexfield_name,
        x_flex_value_set_app_id,
        x_flex_value_set_id,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
end;
end UploadColumn;

--
-- UploadHistColumn (PUBLIC))
--   Public procedure for afdict.lct to call when uploading columns using
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
  x_last_update_date 		   in varchar2
) is
  appl_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

  -- Because Column is in the same entity as Table, no need to validate
  -- Application and Table again.
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_HISTOGRAM_COLS
    where APPLICATION_ID = appl_id
    and TABLE_NAME = x_table_name
    and COLUMN_NAME = x_column_name;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

  update FND_HISTOGRAM_COLS set
      PARTITION = x_partition,
      HSIZE = x_hsize,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATE_LOGIN = f_luby
  where APPLICATION_ID = appl_id
  and   TABLE_NAME = x_table_name
  and   COLUMN_NAME = x_column_name;
 end if;
 exception
   when no_data_found then
    insert into FND_HISTOGRAM_COLS (
      APPLICATION_ID,
      TABLE_NAME,
      COLUMN_NAME,
      PARTITION,
      HSIZE,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN)
      values (
      appl_id,
      x_table_name,
      x_column_name,
      x_partition,
      x_hsize,
      f_ludate,
      f_luby,
      f_luby,
      f_ludate,
      f_luby);
end;
end UploadHistColumn;



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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2,
  x_phase_mode			   in varchar2
) is
  tab_id number;
  appl_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
                     -- Bug2631776 new variables to handle update.
  child_file_ludate date;   -- child entity update date in file
  child_file_luby   number; -- child owner in file
  child_db_ludate   date;   -- child update date in db
  child_db_luby     number; -- child owner in db
  ind_id	number;

begin

  -- Because Index is in the same entity as Table, no need to validate
  -- Application and Table again.

  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select T.TABLE_ID into tab_id from FND_TABLES T
  where T.APPLICATION_ID = appl_id
  and T.TABLE_NAME = x_table_name;

  -- Bug2631776 In this section handle the parent entity
  -- and update the child entity so that constraints do not occur.

  if (x_phase_mode = 'BEGIN') then

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_user_id);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

   begin

     select INDEX_ID
     into ind_id
      from FND_INDEXES
     where APPLICATION_ID = appl_id
     and TABLE_ID = tab_id
     and INDEX_NAME = x_index_name;

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_INDEXES
    where APPLICATION_ID = appl_id
    and TABLE_ID = tab_id
    and INDEX_NAME = x_index_name;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

     update FND_INDEXES set
      UNIQUENESS = x_uniqueness,
      AUTO_SIZE = x_auto_size,
      DESCRIPTION = x_description,
      INITIAL_EXTENT = x_initial_extent,
      NEXT_EXTENT = x_next_extent,
      MIN_EXTENTS = x_min_extents,
      MAX_EXTENTS = x_max_extents,
      INI_TRANS = x_ini_trans,
      MAX_TRANS = x_max_trans,
      PCT_FREE = x_pct_free,
      PCT_INCREASE = x_pct_increase,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATE_LOGIN = f_luby
     where APPLICATION_ID = appl_id
     and   TABLE_ID = tab_id
     and   INDEX_NAME = x_index_name;

    end if;

      -- Bug3230044 Delete any child records with a negative
      -- value for COLUMN_ID.

      delete from FND_INDEX_COLUMNS
       where APPLICATION_ID = appl_id
       and TABLE_ID = tab_id
       and INDEX_ID = ind_id
       and COLUMN_ID < 0;

      -- BUG2631776 rename the child record's COLUMN_SEQUENCE
      -- and COLUMN_ID values to a negative value in order to
      -- prevent unique constraints while processing the
      -- PARENT/CHILD entity.

     update FND_INDEX_COLUMNS
      set COLUMN_SEQUENCE = -1 * COLUMN_SEQUENCE,
          COLUMN_ID = -1 * COLUMN_ID
     where APPLICATION_ID = appl_id
     and   TABLE_ID = tab_id
     and   INDEX_ID = ind_id;

      /*Bug2773876 - Handle special case where COLUMN_SEQUENCE = 0 */

     update FND_INDEX_COLUMNS
      set COLUMN_SEQUENCE = -1000
     where APPLICATION_ID = appl_id
     and   TABLE_ID = tab_id
     and   INDEX_ID = ind_id
     and COLUMN_SEQUENCE = 0;

    exception
      when no_data_found then
       Fnd_Dictionary_Pkg.InsertIndex(
        appl_id,
        tab_id,
        x_index_name,
        x_uniqueness,
        x_auto_size,
        x_description,
        x_initial_extent,
        x_next_extent,
        x_min_extents,
        x_max_extents,
        x_ini_trans,
        x_max_trans,
        x_pct_free,
        x_pct_increase,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
   end;

 else -- phase_mode = 'END'

     select INDEX_ID
     into ind_id
      from FND_INDEXES
     where APPLICATION_ID = appl_id
     and TABLE_ID = tab_id
     and INDEX_NAME = x_index_name;

  -- Bug2631776 get the latest value for the last update for the db entity
  -- and the file entity.

  select max(last_update_date)
    into child_db_ludate
    from fnd_index_columns
    where application_id = appl_id
    and table_id = tab_id
    and index_id = ind_id
    and column_sequence < 0
    and column_id < 0;

  -- Bug3139883 changed select to also include value if column_sequence =0

  select max(last_update_date)
    into child_file_ludate
    from fnd_index_columns
    where application_id = appl_id
    and table_id = tab_id
    and index_id = ind_id
    and column_sequence >= 0
    and column_id > 0;

   -- If no value which means there were no existing child records
   -- in the database therefore  skip to the end  since the new child
   -- records have been updated.

   if (child_db_ludate IS NULL) or (child_file_ludate IS NULL) then
      GOTO done_label;
   end if;

   -- Continue on to check the owner value since both have columns.

   -- Bug2631776 get the maximum value for the userid that made the
   -- last update for the db entity and the file entity.

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_db_luby
       from fnd_index_columns
         where application_id = appl_id
         and table_id = tab_id
         and index_id = ind_id
         and column_sequence < 0
         and column_id < 0
         and last_updated_by not in (0,1,2);

       if child_db_luby IS NULL then
         child_db_luby := 2;  -- All rows are seed data, set seed data owner
       end if;

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_file_luby
       from fnd_index_columns
         where application_id = appl_id
         and table_id = tab_id
         and index_id = ind_id
         and column_sequence > 0
         and column_id > 0
         and last_updated_by not in (0,1,2);

       if child_file_luby IS NULL then
         child_file_luby := 2;  -- All rows are seed data, set seed data owner
       end if;

   -- Bug2631776 perform check to see if update occurs or not.

   if (fnd_load_util.upload_test(child_file_luby, child_file_ludate, child_db_luby, child_db_ludate, x_custom_mode)) then

      -- The new child entity rows from the data file are  kept so
      -- delete the existing db child entity rows.

         delete from fnd_index_columns
            where application_id = appl_id
            and table_id = tab_id
            and index_id = ind_id
            and column_sequence < 0
            and column_id < 0;

     else

      -- The existing db child entity rows are kept so delete the new child
      -- entity rows from the data file
      -- Bug3139883 - Modified delete to include the value column_sequence = 0

            delete from fnd_index_columns
            where application_id = appl_id
            and table_id = tab_id
            and index_id = ind_id
            and column_sequence >= 0
            and column_id > 0;

	-- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

         update FND_INDEX_COLUMNS
             set COLUMN_SEQUENCE = -1 * COLUMN_SEQUENCE,
                  COLUMN_ID = -1 * COLUMN_ID
    		where APPLICATION_ID = appl_id
    		and   TABLE_ID = tab_id
    		and   INDEX_ID = ind_id;

        /*Bug2773876 - Handle special case where COLUMN_SEQUENCE = 0 */

         update FND_INDEX_COLUMNS
             set COLUMN_SEQUENCE = 0
                where APPLICATION_ID = appl_id
                and   TABLE_ID = tab_id
                and   INDEX_ID = ind_id
                and COLUMN_SEQUENCE = 1000;

     end if;
    <<done_label>>

     -- check if the file has no child entries to clean up database.

     if (child_file_ludate IS NULL) then

        if (child_db_ludate IS NOT NULL) then

	  -- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

         update FND_INDEX_COLUMNS
             set COLUMN_SEQUENCE = -1 * COLUMN_SEQUENCE,
                  COLUMN_ID = -1 * COLUMN_ID
    		where APPLICATION_ID = appl_id
    		and   TABLE_ID = tab_id
    		and   INDEX_ID = ind_id;

       /*Bug2773876 - Handle special case where COLUMN_SEQUENCE = 0 */

         update FND_INDEX_COLUMNS
             set COLUMN_SEQUENCE = 0
                where APPLICATION_ID = appl_id
                and   TABLE_ID = tab_id
                and   INDEX_ID = ind_id
                and COLUMN_SEQUENCE = 1000;

	 end if;
    end if;
  end if;
end UploadIndex;

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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2
) is
  tab_id number;
  appl_id number;
  idx_id number;
  col_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
begin

  -- Because Index Column is in the same entity as Table and Index,
  -- no need to validate them again.
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select T.TABLE_ID into tab_id from FND_TABLES T
  where T.APPLICATION_ID = appl_id
  and T.TABLE_NAME = x_table_name;

  select I.INDEX_ID into idx_id from FND_INDEXES I
  where I.APPLICATION_ID = appl_id
  and   I.TABLE_ID = tab_id
  and   I.INDEX_NAME = x_index_name;

  begin
    select C.COLUMN_ID into col_id from FND_COLUMNS C
    where C.APPLICATION_ID = appl_id
    and   C.TABLE_ID = tab_id
    and   C.COLUMN_NAME = x_index_column_name;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-COLUMN NAME');
      fnd_message.set_token('COLUMN_NAME', x_index_column_name);
      fnd_message.set_token('OBJECT_TYPE', 'Index');
      fnd_message.set_token('OBJECT_NAME', x_index_name);
      app_exception.raise_exception;
  end;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  -- NOTE: no "UPDATE" case as we have renamed all the existing
  -- index columns so that they can be compared against the new
  -- index columns from the data file to determine which will be
  -- updated into the database based on the date and custom factirs.

     begin
     insert into FND_INDEX_COLUMNS(
      APPLICATION_ID,
      TABLE_ID,
      INDEX_ID,
      COLUMN_ID,
      COLUMN_SEQUENCE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values (
      appl_id,
      tab_id,
      idx_id,
      col_id,
      x_index_column_sequence,
      f_luby,
      f_ludate,
      f_luby,
      f_ludate,
      f_luby);

     exception
      when dup_val_on_index then
        fnd_message.set_name('FND', 'FND-DUPLICATE COLUMN SEQUENCE');
        fnd_message.set_token('COLUMN_SEQUENCE', x_index_column_sequence);
        fnd_message.set_token('OBJECT_NAME', x_index_name);
        app_exception.raise_exception;
     end;

end UploadIndexColumn;

--
-- UploadPrimaryKey (PUBLIC))
--   Public procedure for afdict.lct to call when uploading primary key using
--   using afdict.lct. It calls InsertPrimary() when needed.
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
  x_phase_mode			   in varchar2
) is
  tab_id number;
  appl_id number;
  pk_id number;
  tmpid number;
  pkmode varchar2(10);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

                     -- Bug2631776 new variables to handle update.
  child_file_ludate date;   -- child entity update date in file
  child_file_luby   number; -- child owner in file
  child_db_ludate   date;   -- child update date in db
  child_db_luby     number; -- child owner in db

begin

  -- Because Primary Key is in the same entity as Table, no need to validate
  -- Application and Table again.
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select T.TABLE_ID into tab_id from FND_TABLES T
  where T.APPLICATION_ID = appl_id
  and T.TABLE_NAME = x_table_name;

  -- Validation on primary_key_type, audit_flag and enabled_flag

  pk_id := -1;
  ValidatePrimaryKey(x_application_short_name,
                     x_table_name, x_primary_key_name, tmpid, tmpid, pk_id);
  if (pk_id = -1) then
    pkmode := 'INSERT';
  else
    pkmode := 'UPDATE';
  end if;

  if ((pkmode = 'INSERT' and x_primary_key_type not in ('S', 'D')) or
      (pkmode = 'UPDATE' and nvl(x_primary_key_type, 'S') not in ('S', 'D'))) then
      fnd_message.set_name('FND', 'FND-INVALID PRIMARY KEY ATTR');
      fnd_message.set_token('ATTRIBUTE_NAME', 'Type');
      fnd_message.set_token('ATTRIBUTE_VALUE', x_primary_key_type);
      fnd_message.set_token('PRIMARY_KEY', x_primary_key_name);
      app_exception.raise_exception;
  end if;

  if ((pkmode = 'INSERT' and x_audit_key_flag not in ('Y', 'N')) or
      (pkmode = 'UPDATE' and nvl(x_audit_key_flag, 'Y') not in ('Y', 'N'))) then
      fnd_message.set_name('FND', 'FND-INVALID PRIMARY KEY ATTR');
      fnd_message.set_token('ATTRIBUTE_NAME', 'Audit Key');
      fnd_message.set_token('ATTRIBUTE_VALUE', x_audit_key_flag);
      fnd_message.set_token('PRIMARY_KEY', x_primary_key_name);
      app_exception.raise_exception;
  end if;

  if ((pkmode = 'INSERT' and x_enabled_flag not in ('Y', 'N')) or
      (pkmode = 'UPDATE' and nvl(x_enabled_flag, 'Y') not in ('Y', 'N'))) then
      fnd_message.set_name('FND', 'FND-INVALID PRIMARY KEY ATTR');
      fnd_message.set_token('ATTRIBUTE_NAME', 'Enabled Flag');
      fnd_message.set_token('ATTRIBUTE_VALUE', x_enabled_flag);
      fnd_message.set_token('PRIMARY_KEY', x_primary_key_name);
      app_exception.raise_exception;
  end if;

  if (x_primary_key_type = 'D' and
      MultipleDeveloperKeys(appl_id, tab_id, x_primary_key_name)) then
      fnd_message.set_name('FND', 'FND-MULTIPLE DEVELOPER PK');
      fnd_message.set_token('TABLE_NAME', x_table_name);
      app_exception.raise_exception;
  end if;

  -- Bug2631776 In this section handle the parent entity
  -- and update the child entity so that constraints do not occur.

if (x_phase_mode = 'BEGIN') then

    -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_PRIMARY_KEYS
    where APPLICATION_ID = appl_id
    and TABLE_ID = tab_id
    and PRIMARY_KEY_NAME = x_primary_key_name;

  if (pkmode = 'UPDATE') then

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
    update FND_PRIMARY_KEYS set
      PRIMARY_KEY_TYPE = x_primary_key_type,
      AUDIT_KEY_FLAG = x_audit_key_flag,
      ENABLED_FLAG = x_enabled_flag,
      DESCRIPTION = x_description,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATE_LOGIN = f_luby
    where APPLICATION_ID = appl_id
    and   TABLE_ID = tab_id
    and   PRIMARY_KEY_NAME = x_primary_key_name;
  end if;

     -- Bug3230044 Delete any child records with a negative
      -- value for COLUMN_ID.

      delete from FND_PRIMARY_KEY_COLUMNS
       where APPLICATION_ID = appl_id
       and TABLE_ID = tab_id
       and PRIMARY_KEY_ID = pk_id
       and COLUMN_ID < 0;


      -- BUG2631776 rename the child record's PRIMARY_KEY_SEQUENCE
      -- and COLUMN_ID values to a negative value in order to
      -- prevent unique constraints while processing the
      -- PARENT/CHILD entity.

     update FND_PRIMARY_KEY_COLUMNS
      set PRIMARY_KEY_SEQUENCE = -1 * PRIMARY_KEY_SEQUENCE,
          COLUMN_ID = -1 * COLUMN_ID
     where APPLICATION_ID = appl_id
     and   TABLE_ID = tab_id
     and   PRIMARY_KEY_ID = pk_id;

    /*Bug3139883 - Handle special case where PRIMARY_KEY_SEQUENCE = 0 */

     update FND_PRIMARY_KEY_COLUMNS
      set PRIMARY_KEY_SEQUENCE = -1000
     where APPLICATION_ID = appl_id
     and   TABLE_ID = tab_id
     and   PRIMARY_KEY_ID = pk_id
     and PRIMARY_KEY_SEQUENCE = 0;

  else
    Fnd_Dictionary_Pkg.InsertPrimaryKey(
        appl_id,
        tab_id,
        x_primary_key_name,
        x_primary_key_type,
        x_audit_key_flag,
        x_enabled_flag,
        x_description,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
  end if;

exception
  when no_data_found then
       Fnd_Dictionary_Pkg.InsertPrimaryKey(
        appl_id,
        tab_id,
        x_primary_key_name,
        x_primary_key_type,
        x_audit_key_flag,
        x_enabled_flag,
        x_description,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);

end;

else -- phase_mode = 'END'

  -- Bug2631776 get the latest value for the last update for the db entity
  -- and the file entity.

  select max(last_update_date)
    into child_db_ludate
    from fnd_primary_key_columns
    where application_id = appl_id
    and table_id = tab_id
    and primary_key_id = pk_id
    and primary_key_sequence < 0
    and column_id < 0;

 -- Bug3139883 changed select to also include value if primary_key_sequence =0

  select max(last_update_date)
    into child_file_ludate
    from fnd_primary_key_columns
    where application_id = appl_id
    and table_id = tab_id
    and primary_key_id = pk_id
    and PRIMARY_KEY_SEQUENCE >= 0
    and column_id > 0;

   -- If no value which means there were no existing child records
   -- in the database therefore  skip to the end  since the new child
   -- records have been updated.

   if (child_db_ludate IS NULL) or (child_file_ludate IS NULL) then
      GOTO done_label;
   end if;

   -- Continue on to check the owner value since both have columns.

   -- Bug2631776 get the maximum value for the userid that made the
   -- last update for the db entity and the file entity.

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_db_luby
       from fnd_primary_key_columns
         where application_id = appl_id
         and table_id = tab_id
         and primary_key_id = pk_id
         and PRIMARY_KEY_SEQUENCE < 0
         and column_id < 0
         and last_updated_by not in (0,1,2);

       if child_db_luby IS NULL then
         child_db_luby := 2;  -- All rows are seed data, set seed data owner
       end if;

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_file_luby
       from fnd_primary_key_columns
	 where application_id = appl_id
         and table_id = tab_id
         and primary_key_id = pk_id
         and PRIMARY_KEY_SEQUENCE > 0
         and column_id > 0
        and last_updated_by not in (0,1,2);

      if child_file_luby IS NULL then
         child_file_luby := 2;  -- All rows are seed data, set seed data owner
      end if;

   -- Bug2631776 perform check to see if update occurs or not.

   if (fnd_load_util.upload_test(child_file_luby, child_file_ludate, child_db_luby, child_db_ludate, x_custom_mode)) then

      -- The new child entity rows from the data file are  kept so
      -- delete the existing db child entity rows.

         delete from fnd_primary_key_columns
    		where application_id = appl_id
    		and table_id = tab_id
    		and primary_key_id = pk_id
            and PRIMARY_KEY_SEQUENCE < 0
            and column_id < 0;

     else

      -- The existing db child entity rows are kept so delete the new child
      -- entity rows from the data file
      -- Bug3139883 - Modified delete to include the value column_sequence = 0

         delete from fnd_primary_key_columns
	    	where application_id = appl_id
    		and table_id = tab_id
    		and primary_key_id = pk_id
            and PRIMARY_KEY_SEQUENCE >= 0
            and column_id > 0;

	-- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

         update FND_PRIMARY_KEY_COLUMNS
             set PRIMARY_KEY_SEQUENCE = -1 * PRIMARY_KEY_SEQUENCE,
                  COLUMN_ID = -1 * COLUMN_ID
    		where APPLICATION_ID = appl_id
    		and   TABLE_ID = tab_id
    		and   PRIMARY_KEY_ID = pk_id;

        /*Bug3139883 - Handle special case where PRIMARY_KEY_SEQUENCE = 0 */

         update FND_PRIMARY_KEY_COLUMNS
             set PRIMARY_KEY_SEQUENCE = 0
                where APPLICATION_ID = appl_id
                and   TABLE_ID = tab_id
                and   PRIMARY_KEY_ID = pk_id
                and PRIMARY_KEY_SEQUENCE = 1000;

     end if;
    <<done_label>>

     -- check if the file has no child entries to clean up database.

     if (child_file_ludate IS NULL) then

        if (child_db_ludate IS NOT NULL) then

	  -- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

         update FND_PRIMARY_KEY_COLUMNS
             set PRIMARY_KEY_SEQUENCE = -1 * PRIMARY_KEY_SEQUENCE,
                  COLUMN_ID = -1 * COLUMN_ID
    		where APPLICATION_ID = appl_id
    		and   TABLE_ID = tab_id
    		and   PRIMARY_KEY_ID = pk_id;

       /*Bug3139883 - Handle special case where PRIMARY_KEY_SEQUENCE = 0 */

         update FND_PRIMARY_KEY_COLUMNS
             set PRIMARY_KEY_SEQUENCE = 0
                where APPLICATION_ID = appl_id
                and   TABLE_ID = tab_id
                and   PRIMARY_KEY_ID = pk_id
                and PRIMARY_KEY_SEQUENCE = 1000;

	 end if;
    end if;
  end if;

end UploadPrimaryKey;

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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2
) is
  tab_id number;
  appl_id number;
  pk_id number;
  col_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file

begin

  -- No need to validate/check Application, Table or Primary Key.
  -- Within the same entity.
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select T.TABLE_ID into tab_id from FND_TABLES T
  where T.APPLICATION_ID = appl_id
  and T.TABLE_NAME = x_table_name;

  select P.PRIMARY_KEY_ID into pk_id from FND_PRIMARY_KEYS P
  where P.APPLICATION_ID = appl_id
  and   P.TABLE_ID = tab_id
  and   P.PRIMARY_KEY_NAME = x_primary_key_name;

  begin
    select C.COLUMN_ID into col_id from FND_COLUMNS C
    where C.APPLICATION_ID = appl_id
    and   C.TABLE_ID = tab_id
    and   C.COLUMN_NAME = x_primary_key_column_name;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-COLUMN NAME');
      fnd_message.set_token('COLUMN_NAME', x_primary_key_column_name);
      fnd_message.set_token('OBJECT_TYPE', 'Primary Key');
      fnd_message.set_token('OBJECT_NAME', x_primary_key_name);
      app_exception.raise_exception;
  end;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  -- NOTE: no "UPDATE" case as we have renamed all the existing
  -- primary key columns so that they can be compared against the new
  -- primary key columns from the data file to determine which will be
  -- updated into the database based on the date and custom factirs.

    begin
     insert into FND_PRIMARY_KEY_COLUMNS(
      APPLICATION_ID,
      TABLE_ID,
      PRIMARY_KEY_ID,
      COLUMN_ID,
      PRIMARY_KEY_SEQUENCE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values (
      appl_id,
      tab_id,
      pk_id,
      col_id,
      x_primary_key_column_sequence,
      f_luby,
      f_ludate,
      f_luby,
      f_ludate,
      f_luby);
     exception
      when dup_val_on_index then
       fnd_message.set_name('FND', 'FND-DUPLICATE COLUMN SEQUENCE');
       fnd_message.set_token('COLUMN_SEQUENCE', x_primary_key_column_sequence);
       fnd_message.set_token('OBJECT_NAME', x_primary_key_name);
       app_exception.raise_exception;
     end;

end UploadPrimaryKeyColumn;

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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2,
  x_phase_mode			 in varchar2
) is
  tab_id number;
  appl_id number;
  pk_appl_id number;
  pk_tab_id number;
  pk_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

                     -- Bug2631776 new variables to handle update.
  child_file_ludate date;   -- child entity update date in file
  child_file_luby   number; -- child owner in file
  child_db_ludate   date;   -- child update date in db
  child_db_luby     number; -- child owner in db
  fk_id	number;

begin

  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select T.TABLE_ID into tab_id from FND_TABLES T
  where T.APPLICATION_ID = appl_id
  and T.TABLE_NAME = x_table_name;

  -- Validate if primary key exists

  pk_id := -1;

  ValidatePrimaryKey(x_primary_key_application_name,
                    x_primary_key_table_name,
                    x_primary_key_name, pk_appl_id, pk_tab_id, pk_id);

  if (pk_id = -1) then
/*
      fnd_message.set_name('FND', 'INVALID_PRIMARY_KEY');
      fnd_message.set_token('PRIMARY_KEY', x_primary_key_name);
      fnd_message.set_token('TABLE_NAME', x_primary_key_table_name);
      fnd_message.set_token('APPLICATION_NAME', x_primary_key_application_name);
      fnd_message.set_token('FOREIGN_KEY', x_foreign_key_name);
      app_exception.raise_exception;
*/
    pk_appl_id := -1;
    pk_tab_id := -1;

  end if;

if (x_phase_mode = 'BEGIN') then


  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin

    select FOREIGN_KEY_ID
    into fk_id
    from FND_FOREIGN_KEYS
    where APPLICATION_ID = appl_id
    and TABLE_ID = tab_id
    and FOREIGN_KEY_NAME = x_foreign_key_name;

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_FOREIGN_KEYS
    where APPLICATION_ID = appl_id
    and TABLE_ID = tab_id
    and FOREIGN_KEY_NAME = x_foreign_key_name;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

  update FND_FOREIGN_KEYS set
      PRIMARY_KEY_APPLICATION_ID = pk_appl_id,
      PRIMARY_KEY_TABLE_ID = pk_tab_id,
      PRIMARY_KEY_ID = pk_id,
      CASCADE_BEHAVIOR = x_cascade_behavior,
      FOREIGN_KEY_RELATION = x_foreign_key_relation,
      DESCRIPTION = x_description,
      CONDITION = x_condition,
      ENABLED_FLAG = x_enabled_flag,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATE_LOGIN = f_luby
  where APPLICATION_ID = appl_id
  and   TABLE_ID = tab_id
  and   FOREIGN_KEY_NAME = x_foreign_key_name;

 end if;

     -- Bug3230044 Delete any child records with a negative
     -- value for COLUMN_ID.

      delete from FND_FOREIGN_KEY_COLUMNS
       where APPLICATION_ID = appl_id
       and TABLE_ID = tab_id
       and FOREIGN_KEY_ID = fk_id
       and COLUMN_ID < 0;


      -- BUG2631776 rename the child record's FOREIGN_KEY_SEQUENCE
      -- and COLUMN_ID values to a negative value in order to
      -- prevent unique constraints while processing the
      -- PARENT/CHILD entity.

     update FND_FOREIGN_KEY_COLUMNS
      set FOREIGN_KEY_SEQUENCE = -1 * FOREIGN_KEY_SEQUENCE,
          COLUMN_ID = -1 * COLUMN_ID
     where APPLICATION_ID = appl_id
     and   TABLE_ID = tab_id
     and   FOREIGN_KEY_ID = fk_id;

      /*Bug3139883 - Handle special case where FOREIGN_KEY_SEQUENCE = 0 */

     update FND_FOREIGN_KEY_COLUMNS
      set FOREIGN_KEY_SEQUENCE = -1000
     where APPLICATION_ID = appl_id
     and   TABLE_ID = tab_id
     and   FOREIGN_KEY_ID = fk_id
     and FOREIGN_KEY_SEQUENCE = 0;

 exception
   when no_data_found then
    Fnd_Dictionary_Pkg.InsertForeignKey(
        appl_id,
        tab_id,
        x_foreign_key_name,
        pk_appl_id,
        pk_tab_id,
        pk_id,
        x_description,
        x_cascade_behavior,
        x_foreign_key_relation,
        x_condition,
        x_enabled_flag,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
 end;

 else -- phase_mode = 'END'

    select FOREIGN_KEY_ID
    into fk_id
    from FND_FOREIGN_KEYS
    where APPLICATION_ID = appl_id
    and TABLE_ID = tab_id
    and FOREIGN_KEY_NAME = x_foreign_key_name;


  -- Bug2631776 get the latest value for the last update for the db entity
  -- and the file entity.

  select max(last_update_date)
    into child_db_ludate
    from fnd_foreign_key_columns
    where application_id = appl_id
    and table_id = tab_id
    and foreign_key_id = fk_id
    and foreign_key_sequence < 0
    and column_id < 0;

  -- Bug3139883 changed select to also include value if foreign_key_sequence =0

  select max(last_update_date)
    into child_file_ludate
    from fnd_foreign_key_columns
    where application_id = appl_id
    and table_id = tab_id
    and foreign_key_id = fk_id
    and foreign_key_sequence >= 0
    and column_id > 0;

   -- If no value which means there were no existing child records
   -- in the database therefore  skip to the end  since the new child
   -- records have been updated.

   if (child_db_ludate IS NULL) or (child_file_ludate IS NULL) then
      GOTO done_label;
   end if;

   -- Continue on to check the owner value since both have columns.

   -- Bug2631776 get the maximum value for the userid that made the
   -- last update for the db entity and the file entity.

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_db_luby
       from fnd_foreign_key_columns
          where application_id = appl_id
          and table_id = tab_id
          and foreign_key_id = fk_id
          and foreign_key_sequence < 0
          and column_id < 0
         and last_updated_by not in (0,1,2);

      if child_db_luby IS NULL then
         child_db_luby := 2;  -- All rows are seed data, set seed data owner
      end if;

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_file_luby
       from fnd_foreign_key_columns
         where application_id = appl_id
         and table_id = tab_id
         and foreign_key_id = fk_id
         and foreign_key_sequence > 0
         and column_id > 0
         and last_updated_by not in (0,1,2);

       if child_file_luby IS NULL then
         child_file_luby := 2;  -- All rows are seed data, set seed data owner
       end if;

   -- Bug2631776 perform check to see if update occurs or not.

   if (fnd_load_util.upload_test(child_file_luby, child_file_ludate, child_db_luby, child_db_ludate, x_custom_mode)) then

      -- The new child entity rows from the data file are  kept so
      -- delete the existing db child entity rows.

     delete from fnd_foreign_key_columns
     where application_id = appl_id
     and table_id = tab_id
     and foreign_key_id = fk_id
     and foreign_key_sequence < 0
     and column_id < 0;

    else

      -- The existing db child entity rows are kept so delete the new child
      -- entity rows from the data file
      -- Bug3139883 - Modified delete to include the value column_sequence = 0

     delete from fnd_foreign_key_columns
     where application_id = appl_id
     and table_id = tab_id
     and foreign_key_id = fk_id
     and foreign_key_sequence >= 0
     and column_id > 0;

	-- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

         update FND_FOREIGN_KEY_COLUMNS
             set FOREIGN_KEY_SEQUENCE = -1 * FOREIGN_KEY_SEQUENCE,
                  COLUMN_ID = -1 * COLUMN_ID
    		where APPLICATION_ID = appl_id
    		and   TABLE_ID = tab_id
    		and   FOREIGN_KEY_ID = fk_id;

        /*Bug3139883 - Handle special case where FOREIGN_KEY_SEQUENCE = 0 */

         update FND_FOREIGN_KEY_COLUMNS
             set FOREIGN_KEY_SEQUENCE = 0
                where APPLICATION_ID = appl_id
                and   TABLE_ID = tab_id
                and   FOREIGN_KEY_ID = fk_id
                and FOREIGN_KEY_SEQUENCE = 1000;

     end if;
    <<done_label>>

     -- check if the file has no child entries to clean up database.

     if (child_file_ludate IS NULL) then

        if (child_db_ludate IS NOT NULL) then

	  -- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

         update FND_FOREIGN_KEY_COLUMNS
             set FOREIGN_KEY_SEQUENCE = -1 * FOREIGN_KEY_SEQUENCE,
                  COLUMN_ID = -1 * COLUMN_ID
    		where APPLICATION_ID = appl_id
    		and   TABLE_ID = tab_id
    		and   FOREIGN_KEY_ID = fk_id;

       /*Bug3139883 - Handle special case where FOREIGN_KEY_SEQUENCE = 0 */

         update FND_FOREIGN_KEY_COLUMNS
             set FOREIGN_KEY_SEQUENCE = 0
                where APPLICATION_ID = appl_id
                and   TABLE_ID = tab_id
                and   FOREIGN_KEY_ID = fk_id
                and FOREIGN_KEY_SEQUENCE = 1000;

	 end if;
    end if;
  end if;
end UploadForeignKey;

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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2
) is
  tab_id number;
  appl_id number;
  fk_id number;
  col_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file

begin

  -- No need to validate/check Application, Table or Foreign Key.
  -- Within the same entity.
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select T.TABLE_ID into tab_id from FND_TABLES T
  where T.APPLICATION_ID = appl_id
  and T.TABLE_NAME = x_table_name;

  select F.FOREIGN_KEY_ID into fk_id from FND_FOREIGN_KEYS F
  where F.APPLICATION_ID = appl_id
  and   F.TABLE_ID = tab_id
  and   F.FOREIGN_KEY_NAME = x_foreign_key_name;

  begin
    select C.COLUMN_ID into col_id from FND_COLUMNS C
    where C.APPLICATION_ID = appl_id
    and   C.TABLE_ID = tab_id
    and   C.COLUMN_NAME = x_foreign_key_column_name;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-COLUMN NAME');
      fnd_message.set_token('COLUMN_NAME', x_foreign_key_column_name);
      fnd_message.set_token('OBJECT_TYPE', 'Foreign Key');
      fnd_message.set_token('OBJECT_NAME', x_foreign_key_name);
      app_exception.raise_exception;
  end;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  -- NOTE: no "UPDATE" case as we have renamed all the existing
  -- foreign key columns so that they can be compared against the new
  -- foreign key columns from the data file to determine which will be
  -- updated into the database based on the date and custom factirs.


    begin
     insert into FND_FOREIGN_KEY_COLUMNS(
      APPLICATION_ID,
      TABLE_ID,
      FOREIGN_KEY_ID,
      COLUMN_ID,
      FOREIGN_KEY_SEQUENCE,
      CASCADE_VALUE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values (
      appl_id,
      tab_id,
      fk_id,
      col_id,
      x_foreign_key_column_sequence,
      x_cascade_value,
      f_luby,
      f_ludate,
      f_luby,
      f_ludate,
      f_luby);
     exception
      when dup_val_on_index then
       fnd_message.set_name('FND', 'FND-DUPLICATE COLUMN SEQUENCE');
       fnd_message.set_token('COLUMN_SEQUENCE', x_foreign_key_column_sequence);
       fnd_message.set_token('OBJECT_NAME', x_foreign_key_name);
       app_exception.raise_exception;
     end;
end UploadForeignKeyColumn;


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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2
) is
  appl_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  -- Validate Application.
  begin
    select A.APPLICATION_ID
    into appl_id
    from FND_APPLICATION A
    where A.APPLICATION_SHORT_NAME = x_application_short_name;

  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-APPLICATION NAME');
      fnd_message.set_token('APPLICATION_NAME', x_application_short_name);
      app_exception.raise_exception;
  end;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

 begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_SEQUENCES
    where APPLICATION_ID = appl_id
    and SEQUENCE_NAME = x_sequence_name;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then


  -- Check if this is a new table or old table
  update FND_SEQUENCES set
      START_VALUE = x_start_value,
      DESCRIPTION = x_description,
      INCREMENT_BY = x_increment_by,
      MIN_VALUE = x_min_value,
      MAX_VALUE = x_max_value,
      CACHE_SIZE = x_cache_size,
      CYCLE_FLAG = x_cycle_flag,
      ORDER_FLAG = x_order_flag,
      LAST_UPDATED_BY = f_luby,
      LAST_UPDATE_DATE = f_ludate,
      LAST_UPDATE_LOGIN = f_luby
  where APPLICATION_ID = appl_id
  and   SEQUENCE_NAME = x_sequence_name;
 end if;
 exception
 when no_data_found then
    Fnd_Dictionary_Pkg.InsertSequence(
        appl_id,
        x_sequence_name,
        x_start_value,
        x_description,
        x_increment_by,
        x_min_value,
        x_max_value,
        x_cache_size,
        x_cycle_flag,
        x_order_flag,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
 end;
end UploadSequence;

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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2,
  x_phase_mode			 in varchar2
) is
  appl_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
                     -- Bug2631776 new variables to handle update.
  child_file_ludate date;   -- child entity update date in file
  child_file_luby   number; -- child owner in file
  child_db_ludate   date;   -- child update date in db
  child_db_luby     number; -- child owner in db
  vw_id	number;
  first_char varchar2(1); -- first character in column_name

begin
  -- Validate Application
  begin
    select A.APPLICATION_ID
    into appl_id
    from FND_APPLICATION A
    where A.APPLICATION_SHORT_NAME = x_application_short_name;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FND-APPLICATION NAME');
      fnd_message.set_token('APPLICATION_NAME', x_application_short_name);
      app_exception.raise_exception;
  end;

  if (x_phase_mode = 'BEGIN') then

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin

    select VIEW_ID
    into vw_id
    from fnd_views
    where application_id = appl_id
    and VIEW_NAME = x_view_name;

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_VIEWS
    where APPLICATION_ID = appl_id
    and VIEW_NAME = x_view_name;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

       update FND_VIEWS set
         TEXT = x_text,
         DESCRIPTION = x_description,
         LAST_UPDATED_BY = f_luby,
         LAST_UPDATE_DATE = f_ludate,
         LAST_UPDATE_LOGIN = f_luby
      where APPLICATION_ID = appl_id
       and   VIEW_NAME = x_view_name;
    end if;

  -- BUG2631776 rename the child record's COLUMN_SEQUENCE
  -- and COLUMN_NAME to in order to prevent unique
  -- constraints while processing the PARENT/CHILD entity.

     update FND_VIEW_COLUMNS
      set COLUMN_SEQUENCE = -1 * COLUMN_SEQUENCE,
          COLUMN_NAME = decode(instr(COLUMN_NAME,'_'),0,concat('#',COLUMN_NAME),
                                                 replace(COLUMN_NAME, '_','#'))
     where APPLICATION_ID = appl_id
     and   VIEW_ID = vw_id;

 exception
  when no_data_found then
    Fnd_Dictionary_Pkg.InsertView(
        appl_id,
        x_view_name,
        x_text,
        x_description,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
 end;

 else -- phase_mode = 'END'

    select VIEW_ID
    into vw_id
    from fnd_views
    where application_id = appl_id
    and VIEW_NAME = x_view_name;

  -- Bug2631776 get the latest value for the last update for the db entity
  -- and the file entity.

  select max(last_update_date)
    into child_db_ludate
    from fnd_view_columns
    where application_id = appl_id
    and VIEW_ID = vw_id
    and column_sequence < 0;

  select max(last_update_date)
    into child_file_ludate
    from fnd_view_columns
    where application_id = appl_id
    and VIEW_ID = vw_id
    and column_sequence > 0;

   -- If no value which means there were no existing child records
   -- in the database therefore  skip to the end  since the new child
   -- records have been updated.

   if (child_db_ludate IS NULL) or (child_file_ludate IS NULL) then
      GOTO done_label;
   end if;

   -- Continue on to check the owner value since both have columns.

   -- Bug2631776 get the maximum value for the userid that made the
   -- last update for the db entity and the file entity.

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_db_luby
       from fnd_view_columns
         where application_id = appl_id
         and VIEW_ID = vw_id
         and column_sequence < 0
         and last_updated_by not in (0,1,2);

       if child_db_luby IS NULL then
         child_db_luby := 2;  -- All rows are seed data, set seed data owner
       end if;

       -- If any non-seed owners, set owner to user
       select max(-1)
       into child_file_luby
       from fnd_view_columns
          where application_id = appl_id
          and VIEW_ID = vw_id
          and column_sequence > 0
         and last_updated_by not in (0,1,2);

       if child_file_luby IS NULL then
         child_file_luby := 2;  -- All rows are seed data, set seed data owner
       end if;

   -- Bug2631776 perform check to see if update occurs or not.

   if (fnd_load_util.upload_test(child_file_luby, child_file_ludate, child_db_luby, child_db_ludate, x_custom_mode)) then

      -- The new child entity rows from the data file are  kept so
      -- delete the existing db child entity rows.

         delete from fnd_view_columns
         where application_id = appl_id
         and VIEW_ID = vw_id
         and column_sequence < 0;

     else

      -- The existing db child entity rows are kept so delete the new child
      -- entity rows from the data file

         delete from fnd_view_columns
         where application_id = appl_id
         and VIEW_ID = vw_id
         and column_sequence > 0;

	-- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

        update FND_VIEW_COLUMNS
        set COLUMN_SEQUENCE = -1 * COLUMN_SEQUENCE,
         COLUMN_NAME = decode(instr(COLUMN_NAME, '#'),1,ltrim(COLUMN_NAME, '#'),
                                                  replace(COLUMN_NAME, '#','_'))
         where APPLICATION_ID = appl_id
    	 and   VIEW_ID = vw_id;

     end if;
    <<done_label>>

     -- check if the file has no child entries to clean up database.

     if (child_file_ludate IS NULL) then

        if (child_db_ludate IS NOT NULL) then

	-- Rename the existing db entity rows back to normal since
        -- it was not replaced by the new child entity rows
        -- from the data file.

         update FND_VIEW_COLUMNS
         set COLUMN_SEQUENCE = -1 * COLUMN_SEQUENCE,
         COLUMN_NAME = decode(instr(COLUMN_NAME, '#'),1,ltrim(COLUMN_NAME, '#'),
                                                  replace(COLUMN_NAME, '#','_'))
    	 where APPLICATION_ID = appl_id
    	 and   VIEW_ID = vw_id;
	end if;
    end if;
  end if;
end UploadView;

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
  x_user_id                      in varchar2,
  x_custom_mode 			   in varchar2,
  x_last_update_date 		   in varchar2
) is
  appl_id number;
  vw_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
begin

  -- No need to validate/check Application and View.
  -- Within the same entity.
  select A.APPLICATION_ID
  into appl_id
  from FND_APPLICATION A
  where A.APPLICATION_SHORT_NAME = x_application_short_name;

  select V.VIEW_ID into vw_id from FND_VIEWS V
  where V.APPLICATION_ID = appl_id
  and V.VIEW_NAME = x_view_name;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_user_id);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  -- NOTE: no "UPDATE" case as we have renamed all the existing
  -- view columns so that they can be compared against the new
  -- view columns from the data file to determine which will be
  -- updated into the database based on the date and custom factirs.

   begin
    insert into FND_VIEW_COLUMNS(
      APPLICATION_ID,
      VIEW_ID,
      COLUMN_SEQUENCE,
      COLUMN_NAME,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY)
      values (
      appl_id,
      vw_id,
      x_view_column_sequence,
      x_view_column_name,
      f_luby,
      f_ludate,
      f_luby,
      f_ludate,
      f_luby);
   exception
    when dup_val_on_index then
      fnd_message.set_name('FND', 'FND-DUPLICATE COLUMN SEQUENCE');
      fnd_message.set_token('COLUMN_SEQUENCE', x_view_column_sequence);
      fnd_message.set_token('OBJECT_NAME', x_view_name);
      app_exception.raise_exception;
  end;
end UploadViewColumn;


--PRIVATE
--Checking table who had been visited by UpdateChildren().
function visited(x_table_name in varchar2) return boolean is
i number;
begin

  i := 0;
  while ((i < visited_table_count) and (visited_tables(i) is not null)) loop
    if (visited_tables(i) = x_table_name) then
      return TRUE;
    else
      i := i+1;
    end if;
  end loop;

  return FALSE;
end visited;


-- UpdateOrCheckChildren (PRIVATE) is called from UpdatePKColumns
--
-- Description
--   For a given primary key, find all the foreign key children
--   and update their column(s) to the new value.
--   For each foreign key child and the associate foreign key table info,
--   recursive call UpdatePKColumns() to update its foreign key children.
--   The recursive call is to take care of cascade foreign keys.
-- Description(2) : Added for bug 1496010
--   Added support for checking whether any foreign key child contain the
--   the same value as its pk value.
-- Input
--   x_application_id:
--     primary key application_id
--   x_primary_table_id:
--     primary key table_id
--   x_primary_key_id:
--     primary key id
--   x_col_sequences:
--     this array store number like (0, 1) or (1, 2) and so on.
--     (0, 1) means the first and second columns inside the primary key.
--     (0, 2) means the first and third columns inside the primary key.
--     This is for handling partial columns update inside a primary key.
--   x_primary_key_col_value_old:
--     columns's existing value
--   x_primary_key_col_value_new:
--     columns's new value
--     If x_primary_key_col_value_new(0) = '', then this is the case for
--     checking not performing any update. Described in Description(2).
function UpdateOrCheckChildren(x_application_id           in number,
                        x_primary_table_id           in number,
                        x_primary_key_id             in number,
                        x_col_sequences              in NumberArrayTyp,
                        x_primary_key_col_value_old  in NameArrayTyp,
                        x_primary_key_col_value_new  in NameArrayTyp)
return boolean is
  cursor fks is
  select a.application_id, a.application_short_name, ft.table_name,
         ft.table_id, f.foreign_key_id,
         f.foreign_key_name, f.condition
  from   fnd_tables ft, fnd_foreign_keys f, fnd_application a
  where  f.primary_key_application_id = x_application_id
  and    f.primary_key_table_id = x_primary_table_id
  and    f.primary_key_id = x_primary_key_id
  and    ft.table_id = f.table_id
  and    ft.application_id = f.application_id
  and    ft.application_id = a.application_id;

  cursor fkcols(fkapplid number, fktabid number, fkid number) is
  select fc.column_name
  from   fnd_columns fc, fnd_foreign_key_columns fcc
  where fcc.foreign_key_id = fkid
  and   fcc.table_id       = fktabid
  and   fcc.application_id = fkapplid
  and   fcc.column_id      = fc.column_id
  and   fcc.table_id       = fc.table_id
  and   fcc.application_id = fc.application_id
  order by fcc.foreign_key_sequence;

  updbuf varchar2(2000);
  selbuf varchar2(2000);
  colnames NameArrayTyp;
  pknames  NameArrayTyp;
  i number;
  j number;
  tmpbuf varchar2(2000); -- for error message logging purpose
  ret boolean;

  table_doesnot_exist exception;
  pragma exception_init (table_doesnot_exist, -942);

  column_doesnot_exist exception;
  pragma exception_init (column_doesnot_exist, -904);

  duplicate_column_name exception;
  pragma exception_init (duplicate_column_name, -957);

  unique_constraint exception;
  pragma exception_init (unique_constraint, -00001);

  l_api_name CONSTANT varchar2(30) := 'UpdateChildren';

  curs integer;
  row_processed number;

  l_exists_flag varchar2(1) := 'N';

begin

  -- for every foreign key child, we need to update the
  -- foreign key child columns. (only the one in the x_col_sequences)
  -- this is because we support partial primary key columns update.
  for fk in fks loop
  if (not(visited(fk.table_name))) then
    -- We should make sure that this foreign key table is not a view.
    -- Sometimes, people might register the wrong info inside our
    -- dictionary.
    -- We should probably select from user_tables and make sure that
    -- it is a real table.

    -- find which column need to be updated by matching the
    -- sequence in x_col_sequences
    i := 0;
    j := 0; -- controls x_col_sequences
    for fkcol in fkcols(fk.application_id, fk.table_id, fk.foreign_key_id) loop
      if (i = x_col_sequences(j)) then
        colnames(j) := fkcol.column_name;
        j := j + 1;
      end if;
      i := i+1;
    end loop;
    colnames(j) := '';

    -- After the above loop, colnames() contains foreign key columns name
    -- that needed to be updated or checked.
    -- and j is the number of how many columns in colnames().


    -- Bug 1496010: This is the case for checking only.
    -- Therefore, construct select stmt.
    if (x_primary_key_col_value_new(0) is null) then
      selbuf := 'select ''Y'' from dual where exists (select 1 from '||
                fk.table_name||' where ';
      i := 0;
      while (i < j) loop
        if (i > 0) then
          selbuf := selbuf||' and ';
        end if;
        selbuf := selbuf||colnames(i)||' = :C'||i;
        i := i + 1;
      end loop;
    -- End checking case. Bug 1496010.
    else

      updbuf := 'update '||fk.table_name||' set ';
      i := 0;
      while (i <  j) loop
        if (i = j-1) then
          updbuf := updbuf||colnames(i)||'= :B'||i;
        else
          updbuf := updbuf||colnames(i)||'= :B'||i||',';
        end if;
        i := i + 1;
      end loop;

      -- Comment out who columns because there is no right value to pick
      -- Plus, some tables have no who columns and it causes trouble.
      -- add the who columns;
      -- updbuf := updbuf || 'last_update_date = sysdate, last_updated_by = 1 ';

      i := 0;
      updbuf := updbuf ||' where ';
      while (i < j) loop
        updbuf := updbuf||colnames(i)||'= :S'||i ;
        if (j > (i+1)) then
          updbuf := updbuf||' and ';
        else
          updbuf := updbuf||' ';
        end if;
        i := i + 1;
      end loop;

      if (fk.condition is not null) then
          updbuf := updbuf || ' and '||fk.condition;
      end if;

    end if;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      if (x_primary_key_col_value_new(0) is null) then
      -- Bug 1496010: This is the case for checking so print out selbuf.
      fnd_log.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name || '.',
                   selbuf);
      else
      fnd_log.string(FND_LOG.LEVEL_STATEMENT, c_log_head || l_api_name || '.',
                   updbuf);
      end if;
    end if;

    begin
      -- Bug 1496010: This is the case for checking only.
      if (x_primary_key_col_value_new(0) is null) then
        curs := dbms_sql.open_cursor;
        dbms_sql.parse(curs, selbuf||')', dbms_sql.v7);

        dbms_sql.define_column(curs, 1, l_exists_flag, 1);

        i := 0;
        while (i < j) loop
          dbms_sql.bind_variable(curs, ':C'||i, x_primary_key_col_value_old(i));
          i := i+1;
        end loop;
        row_processed := dbms_sql.execute_and_fetch(curs);
        dbms_sql.column_value(curs,1,l_exists_flag);

      -- End Bug 1496010
      else
        curs := dbms_sql.open_cursor;
        dbms_sql.parse(curs, updbuf, dbms_sql.v7);

        i := 0;
        while (i < j) loop
          dbms_sql.bind_variable(curs, ':B'||i, x_primary_key_col_value_new(i));
          i := i+1;
        end loop;
        i := 0;
        while (i < j) loop
          dbms_sql.bind_variable(curs, ':S'||i, x_primary_key_col_value_old(i));
          i := i+1;
        end loop;
        row_processed := dbms_sql.execute(curs);
      end if;


      -- Add table name into our global list to prevent infinite loop
      visited_tables(visited_table_count) := fk.table_name;
      visited_table_count := visited_table_count + 1;

    exception
        when unique_constraint then
          fnd_message.set_name('FND', 'FK_COLUMN_VALUE_DUPLICATE');
          fnd_message.set_token('FK_TABLE', fk.table_name);
          fnd_message.set_token('UPDATE_STATEMENT', updbuf);
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
          fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                         c_log_head || l_api_name || '.update_failed', FALSE);
          end if;
          checking_log := TRUE;
          -- Probably no need to raise error
          -- Just skip this table and continue.
          -- continue;

        when table_doesnot_exist then
          -- ORA 942
          fnd_message.set_name('FND', 'FK_TABLE_NOT_FOUND');
          fnd_message.set_token('FK_TABLE', fk.table_name);
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
          fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                         c_log_head || l_api_name || '.update_failed', FALSE);
          end if;
          checking_log := TRUE;
          -- Probably no need to raise error
          -- Just skip this table and continue.
          -- continue;

        when column_doesnot_exist then
          -- ORA 904
          fnd_message.set_name('FND', 'FK_COLUMN_NOT_FOUND');
          j := 0;
          tmpbuf := '';
          while (j < i or j = i) loop
            tmpbuf := tmpbuf || colnames(j)||',';
            j := j + 1;
          end loop;
          fnd_message.set_token('FK_COLUMN',
                      tmpbuf||' or LAST_UPDATED_BY or LAST_UPDATE_DATE' );
          fnd_message.set_token('FK_TABLE', fk.table_name);
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
          fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                         c_log_head || l_api_name || '.update_failed', FALSE);
          end if;
          checking_log := TRUE;
          -- Probably no need to raise error
          -- Try again. Update it WITHOUT the who column

        when duplicate_column_name then
          -- ORA 957
          fnd_message.set_name('FND', 'FK_DUPLICATE_COLUMN_UPDATE');
          fnd_message.set_token('SQL_STATEMENT', updbuf);
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
          fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                         c_log_head || l_api_name || '.update_failed', FALSE);
          end if;
          checking_log := TRUE;
          -- Probably no need to raise error
        when others then
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'UpdateChildren');
          fnd_message.set_token('ERRNO', to_char(sqlcode));
          fnd_message.set_token('REASON', sqlerrm);
          if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
          fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                         c_log_head || l_api_name || '.update_failed', FALSE);
          end if;
          checking_log := TRUE;
    end; -- end execute updbuf and selbuf;

    -- Close cursor
    dbms_sql.close_cursor(curs);

    -- Bug 1496010. If any child contain same value, we can return TRUE
    -- and forget about the rest of the loop.
    if (x_primary_key_col_value_new(0) is null) then
      if (l_exists_flag = 'Y') then
        -- put a message on the stack regarding which foreign key child
        fnd_message.set_name('FND', 'FK_FOUND_NO_DELETE_PK');
        fnd_message.set_token('FK_TABLE', fk.table_name);
        fnd_message.set_token('FK_KEY', fk.foreign_key_name);
        return(TRUE);
      end if;
    -- End 1496010
    else

    -- This foreign key child itself might be a primary key, so we
    -- need to recursively do the same thing.

    -- Right now, colnames array only contains the columns needed to
    -- be updated.
    -- Using our example will be (APPLICATION_ID, PROFILE_OPTION_ID)

    ret := UpdatePKColumns(fk.application_short_name,
                           fk.table_name,
                           colnames,
                           x_primary_key_col_value_old,
                           x_primary_key_col_value_new);

    end if;
  end if; -- there is no "continue" command to use so I have to use if.
  end loop; -- end for each foreign key child

  -- Bug 1496160
  -- If we got here, and is the checking case, that means no foreign key
  -- value found
  if (x_primary_key_col_value_new(0) is null) then
    -- just simply return FALSE because nothing found
    return (FALSE);
  -- End Bug 1496160
  else
    return(checking_log);
  end if;


end UpdateOrCheckChildren;


-- UpdatePKCols (Private)
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
function UpdatePKCols(x_application_short_name     in varchar2,
                      x_primary_table_name         in varchar2,
                      x_primary_key_col_names      in NameArrayTyp,
                      x_primary_key_col_value_old  in NameArrayTyp,
                      x_primary_key_col_value_new  in NameArrayTyp)
return boolean is
appl_id number;
tab_id number;
colnames NameArrayTyp;
i number;
j number;
colseqs NumberArrayTyp;
numofcols number;
l_api_name CONSTANT varchar2(30) := 'UpdatePKColumns';
tmpbuf varchar2(2000); -- For logging statement buffer

-- Validate primary key column name
cursor pkcols(aid number, tid number, pid number) is
select c.column_name
from fnd_columns c, fnd_primary_key_columns pc
where pc.application_id = aid
and   pc.table_id = tid
and   pc.primary_key_id = pid
and   pc.column_id = c.column_id
and   c.application_id = aid
and   c.table_id = tid
order by pc.primary_key_sequence;

-- Fetch all primary keys in this table
cursor pks(aid number, tid number) is
select p.primary_key_id, p.primary_key_name
from fnd_primary_keys p
where p.application_id = aid
and   p.table_id = tid;

hasChild boolean := FALSE;
ret boolean;

begin

  -- Fetch general info
  begin
  select a.application_id, t.table_id
  into appl_id, tab_id
  from fnd_application a, fnd_tables t
  where a.application_short_name = x_application_short_name
  and   a.application_id = t.application_id
  and   t.table_name = x_primary_table_name;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'FK_INVALID_TABLE');
      fnd_message.set_token('APPS', x_application_short_name);
      fnd_message.set_token('TABLE', x_primary_table_name);
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.fetch_info', FALSE);
      end if;
      return(FALSE);
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'UpdatePKColumns');
      fnd_message.set_token('ERRNO', to_char(sqlcode));
      fnd_message.set_token('REASON', sqlerrm);
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
      fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.fetch_info', FALSE);
      end if;
      return(FALSE);
  end;

  -- Find out how many columns we are talking about.
  -- Because we need to use this info later.
  numofcols := 0;
  i := 0;
  while (x_primary_key_col_names(i) is not null) loop
    numofcols := numofcols + 1;
    i := i + 1;
  end loop;

  tmpbuf := 'Checking table '||x_primary_table_name;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
  fnd_log.string(FND_LOG.LEVEL_STATEMENT, c_log_head||l_api_name, tmpbuf);
  end if;


  for pk in pks(appl_id, tab_id) loop
    tmpbuf := 'Checking '||pk.primary_key_name;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
    fnd_log.string(FND_LOG.LEVEL_STATEMENT, c_log_head||l_api_name, tmpbuf);
    end if;

    -- Figure out which columns are the one user wants to update.
    -- UpdatePKColumns allows you to pass all pk columns or partial columns.
    -- Therefore, when this following loop finishes, the colseqs() array
    -- stores the column sequence number. The number has been resequence to
    -- the format of 0, 1, 2, 3.. instead of 10, 20, 30 or 2,4,6 in case
    -- some weird sequence number in the database.
    -- And inside UpdateChildren(), it will use the format of 0, 1, 2, 3 to
    -- do comparison.
    i := 0;
    j := 0;
    for pkcol in pkcols(appl_id, tab_id, pk.primary_key_id) loop
      if (pkcol.column_name = x_primary_key_col_names(j)) then
        colseqs(j) := i;
        j := j + 1;
      end if;
      i := i+1;
    end loop;
    colseqs(j) := '';

    -- After the above for loop, colseqs array contains the sequences of the
    -- used pk columns

    -- The pk/uk has to contains the actual columns that user passes in.
    -- The pk/uk could be a three columns key and the user wants to update
    -- two columns.

    if (j = numofcols) then
      -- Bug 1496010
      -- Sneak in support for checking whether a pk/uk has foreign key
      -- children contain the same value.
      -- This case will come from function CheckPKColumn()
      -- which pass null value inside x_primary_key_col_value_new
      if( x_primary_key_col_value_new(0) is null) then
        hasChild := UpdateOrCheckChildren(appl_id, tab_id, pk.primary_key_id,
            colseqs, x_primary_key_col_value_old, x_primary_key_col_value_new);
        if (hasChild) then
          -- Don't have to finish the whole loop as long as there is one
          -- child has the same value as one pk/uk, return TRUE.
          return(TRUE);
        end if;
      -- End Bug 1496010
      else
      -- Call the actual update routine which takes care of cascading update
      ret := UpdateOrCheckChildren(appl_id, tab_id, pk.primary_key_id, colseqs,
                      x_primary_key_col_value_old,
                      x_primary_key_col_value_new);
      -- The above UpdateChildren means for a given primary key, I would like to
      -- update its first and third columns.(colseqs = (0, 2)). And the first
      -- and third columns old value are inside the value_old array and their
      -- new values are inside the value_new array.
      end  if;
    end if;

  end loop; -- end loop for each possible pk/uk in the same table.


  -- Bug 1496010
  -- this is the checking pk children case and none of the pk/uk
  -- has any children with the same value, that is why we finished
  -- the loop and came here. (Therefore, return FALSE)
  if (x_primary_key_col_value_new(0) is null) then
    return(FALSE);
  -- End Bug 1496010
  else
    -- this is the update pk column case. (Logic remains the same)
    return(not(checking_log));
  end if;

end UpdatePKCols;

-- UpdatePKColumns (Public)
--
-- Description
--   The real job is done inside UpdatePKCols(). I have to create this one
--   because I need a place to reset all global variables. I cannot do it
--   inside UpdatePKCols() because of the natural of the recursive calls.
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
function UpdatePKColumns(x_application_short_name     in varchar2,
                         x_primary_table_name         in varchar2,
                         x_primary_key_col_names      in NameArrayTyp,
                         x_primary_key_col_value_old  in NameArrayTyp,
                         x_primary_key_col_value_new  in NameArrayTyp)
return boolean is
  ret boolean;
begin
  ret := UpdatePKCols(x_application_short_name,
                      x_primary_table_name,
                      x_primary_key_col_names,
                      x_primary_key_col_value_old,
                      x_primary_key_col_value_new);
  -- Clear the global variables
  visited_tables(0) := '';
  visited_table_count := 0;
  checking_log := FALSE;

  return(ret);

end UpdatePKColumns;


-- CheckPKColumns (Public)
--
-- Description
--   For a given table(x_application_short_name and x_primary_table_name)
--   and column names array, find all pk/uk that contains all the columns
--   in the x_primary_key_col_names. For each of these pk/uk, call
--   UpdateOrCheckChildren() to see if there is any foreign key children has
--   the same value as the value inside x_primary_key_col_value_old.
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
function CheckPKColumns(x_application_short_name     in varchar2,
                        x_primary_table_name         in varchar2,
                        x_primary_key_col_names      in NameArrayTyp,
                        x_primary_key_col_value_old  in NameArrayTyp)
return boolean is
  nullarray NameArrayTyp;
  ret boolean;
begin

  nullarray(0) := '';
  -- Passing null array in the last argument to UpdatePKColumns() means
  -- we want to perform checking not updating.
  ret := UpdatePKCols(x_application_short_name, x_primary_table_name,
                  x_primary_key_col_names, x_primary_key_col_value_old,
                  nullarray);
  -- Clear the global variables
  visited_tables(0) := '';
  visited_table_count := 0;
  checking_log := FALSE;

  return(ret);

end CheckPKColumns;



end Fnd_Dictionary_Pkg;

/

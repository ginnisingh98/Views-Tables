--------------------------------------------------------
--  DDL for Package Body BIV_DBI_COLLECTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_COLLECTION_UTIL" as
/* $Header: bivsrvcutlb.pls 120.0 2005/05/24 18:25:19 appldev noship $ */

  g_user_id number := fnd_global.user_id;
  g_login_id number := fnd_global.login_id;

function correct_bad_audit
( x_error_message out nocopy varchar2 )
return number as

begin

  return 0;

exception
  when others then
    x_error_message  := sqlerrm;
    return -1;
end correct_bad_audit;

function get_schema_name
( x_schema_name   out nocopy varchar2
, x_error_message out nocopy varchar2 )
return number as

  l_biv_schema   varchar2(30);
  l_status       varchar2(30);
  l_industry     varchar2(30);

begin

  if fnd_installation.get_app_info('BIV', l_status, l_industry, l_biv_schema) then
    x_schema_name := l_biv_schema;
  else
    x_error_message := 'FIND_INSTALLATION.GET_APP_INFO returned false';
    return -1;
  end if;

  return 0;

exception
  when others then
    x_error_message := 'Error in function get_schema_name : ' || sqlerrm;
    return -1;

end get_schema_name;

function truncate_table
( p_biv_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2 )
return number as

begin

  execute immediate 'truncate table ' || p_biv_schema || '.' || p_table_name;

  return 0;

exception
  when others then
    x_error_message  := 'Error in function truncate_table : ' || sqlerrm;
    return -1;

end truncate_table;

function gather_statistics
( p_biv_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2)
return number as

begin

  fnd_stats.gather_table_stats( ownname => p_biv_schema
                              , tabname => p_table_name
                              );

  return 0;

exception
  when others then
    x_error_message  := 'Error in function gather_statistics : ' || sqlerrm;
    return -1;

end gather_statistics;

procedure set_log_error
( p_rowid             in rowid
, p_staging_error     in varchar2 default null
, p_activity_error    in varchar2 default null
, p_closed_error      in varchar2 default null
, p_backlog_error     in varchar2 default null
, p_resolution_error  in varchar2 default null
) as
begin
  update biv_dbi_collection_log
  set staging_error_message = decode(p_staging_error, null, staging_error_message
                                                      , p_staging_error)
    , activity_error_message = decode(p_activity_error, null, activity_error_message
                                                      , p_activity_error)
    , closed_error_message = decode(p_closed_error, null, closed_error_message
                                                    , p_closed_error)
    , backlog_error_message = decode(p_backlog_error, null, backlog_error_message
                                                    , p_backlog_error)
    , resolution_error_message = decode(p_resolution_error, null, resolution_error_message
                                                    , p_resolution_error)
    , last_update_date = sysdate
    , last_updated_by = g_user_id
    , last_update_login = g_login_id
  where rowid = p_rowid;

exception
  when others then
    bis_collection_utilities.log('Unable to update biv_dbi_collection_log with error:');
    bis_collection_utilities.log(sqlerrm,1);

end set_log_error;

procedure get_last_log
( x_rowid             out nocopy rowid
, x_process_type      out nocopy varchar2
, x_collect_from_date out nocopy date
, x_collect_to_date   out nocopy date
, x_success_flag      out nocopy varchar2
, x_staging_flag      out nocopy varchar2
, x_activity_flag     out nocopy varchar2
, x_closed_flag       out nocopy varchar2
, x_backlog_flag      out nocopy varchar2
, x_resolution_flag   out nocopy varchar2
) as

  cursor c_log is
    select
      rowid
    , process_type
    , collect_from_date
    , collect_to_date
    , success_flag
    , staging_table_flag
    , activity_flag
    , closed_flag
    , backlog_flag
    , resolution_flag
    from
      biv_dbi_collection_log
    where
        last_collection_flag = 'Y';

begin

  open c_log;
  fetch c_log into x_rowid
                 , x_process_type
                 , x_collect_from_date
                 , x_collect_to_date
                 , x_success_flag
                 , x_staging_flag
                 , x_activity_flag
                 , x_closed_flag
                 , x_backlog_flag
                 , x_resolution_flag;
  close c_log;

end get_last_log;

function get_missing_owner_group_id
return number
is
begin
  return -1;
end get_missing_owner_group_id;

function get_missing_inventory_item_id
return number
is
begin
  return -1;
end get_missing_inventory_item_id;

function get_missing_organization_id
return number
is
begin
  return -99;
end get_missing_organization_id;

end biv_dbi_collection_util;

/

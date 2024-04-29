--------------------------------------------------------
--  DDL for Package BIV_DBI_COLLECTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_COLLECTION_UTIL" AUTHID CURRENT_USER as
/* $Header: bivsrvcutls.pls 120.0 2005/05/30 05:32:37 appldev noship $ */

function correct_bad_audit
( x_error_message out nocopy varchar2 )
return number;

function get_schema_name
( x_schema_name   out nocopy varchar2
, x_error_message out nocopy varchar2 )
return number;

function truncate_table
( p_biv_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2 )
return number;

function gather_statistics
( p_biv_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2)
return number;

procedure set_log_error
( p_rowid             in rowid
, p_staging_error     in varchar2 default null
, p_activity_error    in varchar2 default null
, p_closed_error      in varchar2 default null
, p_backlog_error     in varchar2 default null
, p_resolution_error  in varchar2 default null
);

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
);

function get_missing_owner_group_id
return number;

function get_missing_inventory_item_id
return number;

function get_missing_organization_id
return number;

end biv_dbi_collection_util;

 

/

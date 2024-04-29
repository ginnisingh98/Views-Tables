--------------------------------------------------------
--  DDL for Package EDW_METADATA_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_METADATA_REFRESH" AUTHID CURRENT_USER as
/* $Header: EDWMDRFS.pls 115.4 2003/06/19 12:06:41 smulye noship $*/
g_status_message  varchar2(1000);
G_BIS_OWNER varchar2(200);
g_owb_schema varchar2(200);
g_op_table_space  varchar2(200);
procedure refresh_metadata_tables(Errbuf out nocopy varchar2, Retcode out nocopy varchar2);

function get_db_user(p_product varchar2) return varchar2;
procedure log(p_message varchar2) ;
function get_time return varchar2 ;
procedure drop_table(p_table varchar2) ;
function populate_pvt_tables return boolean ;
procedure analyze_all ;
function truncate_all return boolean ;
procedure open_log_file ;
function refresh_owb_mv return boolean;
END edw_metadata_refresh;


 

/

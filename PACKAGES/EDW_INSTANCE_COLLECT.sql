--------------------------------------------------------
--  DDL for Package EDW_INSTANCE_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_INSTANCE_COLLECT" AUTHID CURRENT_USER AS
/*$Header: EDWCINSS.pls 115.7 2002/11/23 00:09:01 vsurendr ship $*/

g_status boolean;
g_dim_name varchar2(400);
g_insert_stmt varchar2(30000);
g_update_stmt varchar2(30000);
g_collection_start_date date;
g_collection_end_date date;
g_conc_program_id number;
G_CONC_PROGRAM_NAME varchar2(500);
g_object_type varchar2(200);
g_number_rows_processed number;
g_debug boolean;
g_status_message varchar2(10000);

PROCEDURE COLLECT_DIMENSION(errbuf out NOCOPY varchar2, retcode out NOCOPY varchar2, p_dim_name varchar2);
procedure Init_all;
procedure make_insert_stmt ;
procedure execute_insert_stmt;
procedure return_with_success;
procedure return_with_error;
procedure call_main_collection(errbuf out NOCOPY varchar2, retcode out NOCOPY varchar2);
procedure write_to_push_log(p_flag boolean);
procedure write_to_log_file(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2) ;
function get_time return varchar2 ;

END EDW_INSTANCE_COLLECT;

 

/

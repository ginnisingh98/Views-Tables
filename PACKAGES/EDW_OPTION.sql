--------------------------------------------------------
--  DDL for Package EDW_OPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OPTION" AUTHID CURRENT_USER as
/* $Header: EDWCFIGS.pls 115.2 2002/12/05 02:38:38 jwen noship $  */

g_status_message varchar2(2000);
g_debug boolean;


function get_warehouse_option(p_object_name varchar2, p_object_id number, p_option_code varchar2,
p_option_value out nocopy varchar2) return boolean;

function get_option_columns(p_object_name varchar2, p_object_id number, p_option_code varchar2,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_option_cols out nocopy number) return boolean;
function get_time return varchar2;
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure set_debug(p_debug boolean) ;
FUNCTION get_object_type (p_object_id IN NUMBER) RETURN varchar2;
function get_fk_dangling_load(p_object_id number,p_option_fk_key number,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_option_cols out nocopy number)
return boolean ;
function get_level_skip_update(p_object_id number,p_option_fk_key number,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_option_cols out nocopy number)
return boolean ;

function get_level_skip_delete(p_object_id number,p_option_fk_key number,
p_option_cols out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_option_cols out nocopy number)
return boolean ;


end;

 

/

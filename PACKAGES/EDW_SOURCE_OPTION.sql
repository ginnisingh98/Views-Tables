--------------------------------------------------------
--  DDL for Package EDW_SOURCE_OPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SOURCE_OPTION" AUTHID CURRENT_USER as
/* $Header: EDWSRCFS.pls 115.2 2002/12/05 02:49:33 jwen noship $  */

g_status_message varchar2(2000);
g_debug boolean;

function get_source_option(p_object_name varchar2,p_object_id number, p_option_code varchar2, p_option_value out nocopy varchar2) return boolean;

function get_db_user(p_product varchar2) return varchar2;

end;

 

/

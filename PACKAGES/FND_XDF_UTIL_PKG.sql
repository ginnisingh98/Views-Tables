--------------------------------------------------------
--  DDL for Package FND_XDF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_XDF_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: fndpxuts.pls 120.2 2006/01/26 11:36:57 bhthiaga noship $ */


function get_hashcode_table( p_tablename in varchar2,
                             p_owner in varchar2,
                             p_columns_list out NOCOPY FND_XDF_TABLE_OF_VARCHAR2_30,
                             table_hash_val out NOCOPY number)
    return FND_XDF_TABLE_OF_NUMBER;

function get_hashcode_qtable( p_qtablename in varchar2,
                              p_owner in varchar2)
    return number;

function get_hashcode_queue(p_queuename in varchar2,
                            p_owner in varchar2)
    return number;

function get_hashcode_index(p_indexname in varchar2,
                            p_owner in varchar2)
    return number;

function get_hashcode_index(p_indexList in FND_XDF_TABLE_OF_VARCHAR2_30,
                            p_owner in varchar2)
    return FND_XDF_TABLE_OF_NUMBER;

function depends( p_name  in varchar2,
                      p_type  in varchar2,
                      p_owner in varchar2,
                      p_lvl   in number default 1 )
   return  fnd_xdf_deptype_tab_info;

end fnd_xdf_util_pkg;

 

/

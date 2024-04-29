--------------------------------------------------------
--  DDL for Package AMS_LIST_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvluts.pls 115.5 2002/11/22 08:56:08 jieli ship $*/
PROCEDURE get_supp_sql_string(
                      p_list_header_id in NUMBER,
                      p_table_alias in varchar2,
                      p_object_type in varchar2 default null,
                      p_object_id in number default null,
                      p_media_type in number default 'EMAIL',
                      p_where_clause  OUT NOCOPY varchar2
                     ) ;
PROCEDURE  get_supp_sql_string(
p_object_type in VARCHAR2,
p_object_id   in NUMBER,
x_where_clause OUT NOCOPY VARCHAR2,
x_status OUT NOCOPY VARCHAR2
);
END AMS_LIST_UTIL_PKG ;

 

/

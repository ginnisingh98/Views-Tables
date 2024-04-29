--------------------------------------------------------
--  DDL for Package POR_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_LOV_PKG" AUTHID CURRENT_USER AS
            /* $Header: PORLOVS.pls 115.2 2002/11/19 00:43:34 jjessup ship $ */

PROCEDURE REMOVE_QUERY_RESULT(
	p_session_id IN NUMBER
);


PROCEDURE EXEC_AK_QUERY(
        p_session_id IN NUMBER,
        p_region_app_id IN NUMBER,
        p_region_code IN VARCHAR2,
        p_attribute_app_id IN NUMBER,
        p_attribute_code IN VARCHAR2,
        p_query_column IN VARCHAR2 default null,
        p_query_text IN VARCHAR2 default null,
        c_1 in varchar2 default 'DSTART',
        p_where_clause IN VARCHAR2 default null,
	p_js_where_clause IN VARCHAR2 default null,
        p_start_row in number default 1,
        p_end_row in number default null,
        p_case_sensitive IN VARCHAR2 default 'off',
        p_display_column OUT NOCOPY NUMBER,
	p_value_column OUT NOCOPY NUMBER,
        p_total_row OUT NOCOPY NUMBER
);


END POR_LOV_PKG;

 

/

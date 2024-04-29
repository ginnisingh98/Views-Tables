--------------------------------------------------------
--  DDL for Package JTF_AK_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AK_QUERY" AUTHID CURRENT_USER as
  --$Header: jtfakqs.pls 120.1 2005/07/02 02:30:49 appldev ship $
  FUNCTION execute_query (
    p_max_rows		IN NUMBER default NULL,
    p_range_low 	IN NUMBER default 0,
    p_range_high	IN NUMBER default NULL,
    p_appl_id		IN NUMBER default fnd_global.resp_appl_id,
    p_flow_name		IN VARCHAR2,
    p_parent_page_name	IN VARCHAR2,
    p_primary_key_name	IN VARCHAR2,
    p_key_value1	IN VARCHAR2,
    p_key_value2	IN VARCHAR2 default NULL,
    p_key_value3	IN VARCHAR2 default NULL,
    p_key_value4	IN VARCHAR2 default NULL,
    p_key_value5	IN VARCHAR2 default NULL,
    p_key_value6	IN VARCHAR2 default NULL,
    p_key_value7	IN VARCHAR2 default NULL,
    p_key_value8	IN VARCHAR2 default NULL,
    p_key_value9	IN VARCHAR2 default NULL,
    p_key_value10	IN VARCHAR2 default NULL,
    p_where_clause	IN VARCHAR2 default NULL,
    p_where_binds	IN ak_query_pkg.bind_tab)
    RETURN ak_query_pkg.results_table_type ;
END;

 

/

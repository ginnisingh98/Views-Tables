--------------------------------------------------------
--  DDL for Package Body JTF_AK_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AK_QUERY" as
  --$Header: jtfakqb.pls 120.1 2005/07/02 02:30:45 appldev ship $
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
    RETURN ak_query_pkg.results_table_type IS
    --
    -- Static CRM Navigator Variables
    --
    C_APPLICATION_ID	     NUMBER	:= fnd_global.resp_appl_id;
    C_RESP_ID		   NUMBER	:= fnd_global.resp_id;
    C_USER_ID		   NUMBER	:= fnd_global.user_id;

    l_flow_code 	   VARCHAR2(30);
    l_page_application_id  NUMBER(15);
    l_page_code 	   VARCHAR2(30);
    l_parent_region_appl_id NUMBER(15);
    l_parent_region_code   VARCHAR2(30);
    l_database_object_name VARCHAR2(30);
    l_pk_exists 	   NUMBER(15);
  BEGIN

    -- ====================================================================
    -- Assumption : Developer needs to supply the following thru JTF tables
    --	 (APPLICATION ID is derived from FND_GLOBAL.RESP_APPL_ID)
    --	 FLOW NAME,
    --	 PARENT PAGE NAME,
    --	 PK NAME,
    --	 PK VALUE
    -- for procedure to derive remaining AK query parameters.
    -- ====================================================================
/*
    here we commented out where we try to grab the flow code from the flow
    name...  we aren't dealing with names...only codes.  i don't know why
    the flow was referenced by the name, but the parent page and primary
    key were referenced by the code.  sounds a bit confused...

    -- get flow id
    select flow_code into   l_flow_code
    from   ak_flows_vl
    where  flow_application_id = p_appl_id
    and    name = p_flow_name;*/
    l_flow_code := p_flow_name;

    -- get page info
SELECT fpr.page_application_id, fpr.page_code,
       fpr.region_application_id, fpr.region_code,
       fpr.database_object_name
  INTO l_page_application_id, l_page_code,
       l_parent_region_appl_id, l_parent_region_code,
       l_database_object_name
  FROM ak_flow_pages_vl fp,
       ak_flow_page_regions_v fpr
 WHERE fp.flow_application_id = p_appl_id
   AND fp.flow_application_id = fpr.flow_application_id
   AND fp.flow_code = l_flow_code
   AND fp.flow_code = fpr.flow_code
   AND fp.page_application_id = p_appl_id
   AND fp.page_application_id = fpr.page_application_id
   AND fp.page_code = p_parent_page_name
   AND fp.page_code = fpr.page_code
   AND fp.primary_region_code = fpr.region_code
   AND fp.primary_region_appl_id = fpr.region_application_id;

    -- check primary key name
    -- and not checking primary key value
    select 1 into l_pk_exists
    from   ak_unique_keys
    where  database_object_name = l_database_object_name
    and    unique_key_name = p_primary_key_name;

    -- call ak_query_pkg.exec_query
    ak_query_pkg.exec_query(
      p_flow_appl_id		=> p_appl_id,
      p_flow_code		    => l_flow_code,
      p_parent_page_appl_id	    => l_page_application_id,
      p_parent_page_code	=> l_page_code,
      p_parent_region_appl_id	=> l_parent_region_appl_id,
      p_parent_region_code	=> l_parent_region_code,
      p_parent_primary_key_name => p_primary_key_name,
      p_parent_key_value1   	=> p_key_value1,
      p_parent_key_value2   	=> p_key_value2,
      p_parent_key_value3   	=> p_key_value3,
      p_parent_key_value4   	=> p_key_value4,
      p_parent_key_value5   	=> p_key_value5,
      p_parent_key_value6   	=> p_key_value6,
      p_parent_key_value7   	=> p_key_value7,
      p_parent_key_value8   	=> p_key_value8,
      p_parent_key_value9   	=> p_key_value9,
      p_parent_key_value10  	=> p_key_value10,
      p_where_clause			=> p_where_clause,
      p_responsibility_id	=> FND_GLOBAL.RESP_ID,
      p_user_id 		=> FND_GLOBAL.USER_ID,
      p_return_parents		=> 'F',
      p_return_children 	=> 'T',
      p_return_node_display_only=> 'F',
      p_set_trace		=> 'F',
      p_range_low		=> p_range_low,
      p_range_high		=> p_range_high,
      p_where_binds		=> p_where_binds,
      p_max_rows		=> p_max_rows
      );

    RETURN ak_query_pkg.g_results_table;

  END execute_query;
END jtf_ak_query;

/

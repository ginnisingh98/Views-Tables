--------------------------------------------------------
--  DDL for Package GCS_XML_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_XML_UTILITY_PKG" AUTHID CURRENT_USER AS
 
--API Name
  g_api		VARCHAR2(50) :=	'gcs.plsql.GCS_XML_UTILITY_PKG';
  g_nl		VARCHAR2(1) :=	'
';
 
  -- Action types for writing module information to the log file. Used for
  -- the procedure log_file_module_write.
  g_module_enter    VARCHAR2(2) := '>>';
  g_module_success  VARCHAR2(2) := '<<';
  g_module_failure  VARCHAR2(2) := '<x';
 
-- Beginning of private procedures 
 
  g_gcs_dims_select_list VARCHAR2(2000) := 
	'  '; 
 
  g_gcs_dims_table_list VARCHAR2(2000) := 
	'  '; 
 
  g_gcs_dims_where_clause VARCHAR2(10000) := 
	'  '; 
 
  g_gcs_dims_xml_elem VARCHAR2(2000) := 
	'  '; 
 
  g_gcs_vsmp_xml_elem VARCHAR2(10000) := 
	'  '; 
 
  g_fem_dims_select_list_dsload VARCHAR2(2000) := 
	'  '; 
 
  g_fem_dims_select_list_dstb VARCHAR2(2000) := 
	'  '; 
 
 
  g_fem_dims_table_list_dstb VARCHAR2(2000) := 
	'  '; 
 
  g_fem_dims_dstb_where_clause VARCHAR2(2000) := 
	'  '; 
 
 
  g_fem_dims_xml_elem VARCHAR2(2000) := 
	'  '; 
  g_group_by_stmnt VARCHAR2(1000) := 
	'  '; 
 
  g_fem_nonposted_select_stmnt VARCHAR2(5000) := 
	'  '; 
 
  g_fem_nonposted_group_stmnt VARCHAR2(5000) := 
	'  '; 
 
  g_fem_dims_dsload_order_clause VARCHAR2(1000) := 
	'  '; 
 
END GCS_XML_UTILITY_PKG;

/

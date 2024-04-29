--------------------------------------------------------
--  DDL for Package ICX_ITEM_DIAG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ITEM_DIAG_PVT" AUTHID CURRENT_USER AS
/* $Header: ICX_ITEM_DIAG_PVT.pls 120.0.12010000.3 2012/03/20 07:41:25 rojain noship $*/

  g_pkg_name CONSTANT VARCHAR2(30):='ICX_ITEM_DIAG_PVT';
  g_file_tbl DBMS_SQL.VARCHAR2_TABLE;
  g_file_versions_tbl DBMS_SQL.VARCHAR2_TABLE;
  g_instance_versions_tbl DBMS_SQL.VARCHAR2_TABLE;
  g_file_key   VARCHAR2(100) := 'ITEM_DIAG_FILE_VERSIONS' ;
  g_error_key   VARCHAR2(100) := 'ITEM_DIAG_ERRORS' ;
  g_id_values_key   VARCHAR2(100) := 'ITEM_ID_SETUP_VALUES' ;


  g_file_count NUMBER        := 30;
	g_org_id number;
	g_source_type varchar2(100);
	g_source_type_values  DBMS_SQL.VARCHAR2_TABLE;
  g_auto_map_category VARCHAR2(1);

  g_category_key DBMS_SQL.VARCHAR2_TABLE;
	g_source_ids  DBMS_SQL.NUMBER_TABLE;
	g_organization_id number;
	g_master_organization_id number;
	g_category_set_id number;
	g_request_id NUMBER := fnd_global.conc_request_id;

  g_table_names DBMS_SQL.VARCHAR2_TABLE;
	g_error_code  DBMS_SQL.VARCHAR2_TABLE;
PROCEDURE file_versions
  (
    status IN VARCHAR2);
  FUNCTION update_num
    (
      p_version IN VARCHAR2)
    RETURN NUMBER;

procedure get_setup_values ( p_table_name in VARCHAR2 ,
 														 p_col_val out NOCOPY DBMS_SQL.VARCHAR2_TABLE,
														 p_row_val  out NOCOPY ICX_ITEM_DIAG_GRP.VARCHAR_TABLE);

procedure get_IDs_values ( p_table_name in VARCHAR2
												 , p_col_num OUT NOCOPY NUMBER
    								     , p_row_num OUT NOCOPY NUMBER
 												 , p_col_val OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE
												 , p_row_val  OUT NOCOPY ICX_ITEM_DIAG_GRP.VARCHAR_TABLE);

procedure validate_values ( p_table_name in VARCHAR2
												 , p_col_num OUT NOCOPY NUMBER
    								     , p_row_num OUT NOCOPY NUMBER
 												 , p_col_val OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE
												 , p_row_val  OUT NOCOPY ICX_ITEM_DIAG_GRP.VARCHAR_TABLE);


procedure sync_sources(p_org_id  in number,
											 p_source_type in varchar2,
											x_return_status OUT NOCOPY varchar2	);

PROCEDURE logStatement
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
);

procedure PO_ATTRIBUTE_VALUES_DATA_FIX ;

END ICX_ITEM_DIAG_PVT;

/

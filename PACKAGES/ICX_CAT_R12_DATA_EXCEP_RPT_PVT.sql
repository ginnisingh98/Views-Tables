--------------------------------------------------------
--  DDL for Package ICX_CAT_R12_DATA_EXCEP_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_R12_DATA_EXCEP_RPT_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVDERS.pls 120.4 2006/03/03 03:10 mkohale noship $*/

/**
 ** Table containing the translatable and non-translatable
 ** interface tables key and stored column details.
 ** This is used as columns list in the XML Query.
 **/
TYPE descriptors_list_tbl IS TABLE OF
               VARCHAR2(18000) INDEX BY BINARY_INTEGER;
g_descriptors_list descriptors_list_tbl;

TYPE territories_list_rec is RECORD(iso_language varchar2(2),
				    iso_territory varchar2(2),
                                    nls_language varchar2(30),
                                    nls_territory varchar2(30));

TYPE territories_list IS TABLE OF territories_list_rec
                          INDEX BY VARCHAR2(4);
g_territories territories_list;

/**
 ** Record that contains the Name and Value pair of the
 ** bind parameters used in the XML Query
 **/
TYPE xml_bind_param_rec IS RECORD (name VARCHAR2(50),
                                   value VARCHAR2(250));

-- Array of the Bind Parameters record
TYPE xml_bind_params IS VARRAY(5) OF xml_bind_param_rec;

/**
 ** Procedure : populate_catalog_files
 ** Synopsis  : Populates the catalog file in XML Format for the errored
 **             lines
 **
 ** Parameter:
 **/
PROCEDURE populate_catalog_files(p_interface_header_id_tbl IN DBMS_SQL.NUMBER_TABLE,
                                 p_vendor_id_tbl IN DBMS_SQL.NUMBER_TABLE,
                                 p_vendor_site_id_tbl IN DBMS_SQL.NUMBER_TABLE,
                                 p_org_id_tbl IN DBMS_SQL.NUMBER_TABLE,
                                 p_currency_code_tbl IN DBMS_SQL.VARCHAR2_TABLE,
                                 p_contract_num_tbl IN DBMS_SQL.NUMBER_TABLE,
                                 p_language_tbl IN DBMS_SQL.VARCHAR2_TABLE);

/**
 ** Procedure : process_data_exceptions_report
 ** Synopsis  : Populate the icx_cat_r12_upg_excep_files and icx_cat_r12_upg_error_msgs
 **             tables with the errored lines during data migration.
 **
 ** Parameter:
 **      IN    p_interface_header_id--Interface_header_id of the Erroneous Line
*/
PROCEDURE process_data_exceptions_report(p_batch_id IN po_headers_interface.batch_id%TYPE);

/*
 ** Procedure : replace_clob
 ** Synopsis  : Replaces the substring of the CLOB with
 **             given string
 **
 ** Parameter:
 **     IN     p_replace_str  -- String to be replaced
 **            p_replace_with -- String to replace with
 **     IN OUT p_src_clob     -- source object
 **/
PROCEDURE replace_clob(p_replace_str IN VARCHAR2,
                       p_replace_with IN CLOB,
		       p_src_clob IN OUT NOCOPY CLOB,
		       p_replace_mutliple_occurances IN BOOLEAN default true);

/**
 ** Procedure : get_xml
 ** Synopsis  : To create an XML
 **
 ** Parameter:
 **     IN     l_qryString     -- Query String
 **            p_bind_params -- Bind Parameters for the XML Query
 **            p_row_tag     -- Row Tag to set, default NULL
 **            p_row_settag  -- Row SetTag to set, default NULL
 ** Retruns    XML object.
 **/
FUNCTION get_xml(p_qryString IN VARCHAR2,
 	         p_bind_params IN xml_bind_params,
                 p_row_tag IN VARCHAR2 default NULL,
                 p_row_settag IN VARCHAR2 default NULL)
  RETURN CLOB;

END ICX_CAT_R12_DATA_EXCEP_RPT_PVT;

 

/

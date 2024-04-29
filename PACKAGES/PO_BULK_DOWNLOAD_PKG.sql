--------------------------------------------------------
--  DDL for Package PO_BULK_DOWNLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_BULK_DOWNLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: POBLKDWNS.pls 120.0.12010000.3 2014/06/16 03:22:49 puppulur noship $ */


PROCEDURE download_lines_with_descrip(errbuf            OUT NOCOPY VARCHAR2,
                         retcode           OUT NOCOPY VARCHAR2,
                         p_po_header_id        IN   NUMBER);

FUNCTION get_attr_data_select RETURN VARCHAR2;
FUNCTION get_query_from_clause RETURN VARCHAR2;
FUNCTION get_query_where_clause(l_po_header_id NUMBER ,l_selected_cat_id NUMBER ,l_lang VARCHAR2) RETURN VARCHAR2;
FUNCTION get_ddl_to_create_temp_table(l_temp_table_name VARCHAR2) RETURN VARCHAR2;
FUNCTION get_data_insert_clause(l_temp_table_name VARCHAR2) RETURN VARCHAR2;
FUNCTION getItemNumber(itemId NUMBER,orgId NUMBER) RETURN VARCHAR2;
FUNCTION get_fixed_columns RETURN VARCHAR2;
FUNCTION get_shipment_columns RETURN VARCHAR2;



END po_bulk_download_pkg;

/

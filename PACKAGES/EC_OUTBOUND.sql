--------------------------------------------------------
--  DDL for Package EC_OUTBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_OUTBOUND" AUTHID CURRENT_USER as
-- $Header: ECOUBS.pls 120.2 2005/09/29 11:11:42 arsriniv ship $

/**
Global Variables for Outbound Transaction.
**/
g_key_column_pos	pls_integer;
g_tp_code_pos		pls_integer;

/**
Main procedure call for Processing Outbound Documents.
**/
procedure process_outbound_documents
        	(
        	i_transaction_type      IN      varchar2,
        	i_map_id                IN      pls_integer,
		i_run_id		OUT  NOCOPY	pls_integer
        	);

/**
This file will delete all records in a staging table without using the
expense parsing of dbms_sql package.  The RUN_ID parameter is the only required parameter.
The DOCUMENT_ID parameter can be optionally used to delete one document from the staging table
at a time.
**/
procedure delete_stage_data
	(
	i_run_id		IN	number,
	i_document_id		IN	number DEFAULT NULL
	);

end ec_outbound;

 

/

--------------------------------------------------------
--  DDL for Package ECE_INBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_INBOUND" AUTHID CURRENT_USER as
-- $Header: ECEINBS.pls 120.3 2005/09/28 11:24:57 arsriniv ship $
/*#
 * This package contains routines to process data in the staging tables and
 * populates the open interface tables.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Process Data from Staging Tables to Open Interface Tables
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY EC_INBOUND
 */

	-- Global variables --
	m_file_tbl_empty		ec_utils.mapping_tbl;
	g_previous_map_id		ece_stage.map_id%TYPE := -99;

Type col_rule_viol_rec is Record
(
stage_id        ece_rule_violations.stage_id%type,
rule_id         ece_rule_violations.rule_id%type,
interface_col_id ece_rule_violations.interface_column_id%type
);

TYPE col_rule_viol_tbl is table of col_rule_viol_rec index by BINARY_INTEGER;

g_col_rule_viol_tbl       col_rule_viol_tbl;


procedure process_inbound_documents
        (
        i_transaction_type      IN      VARCHAR2,
	i_document_id		IN	NUMBER
        );

procedure process_inbound_documents
        (
        i_transaction_type      IN      VARCHAR2,
	i_run_id		IN	NUMBER
        );
/*#
 * This program process the data in the staging tables and populates the open interface tables.
 * Data is processed according to the seeded map provided for the transaction and run id
 * obtained as output of the ece_inbound_stage.load_data program.
 * @param i_transaction_type Transaction Type
 * @param i_run_id Run Id Obtained as Output of Staging Process.
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Process Data from Staging Tables to Open Interface Tables
 * @rep:compatibility S
 */

procedure process_run_inbound
        (
        i_transaction_type      IN      VARCHAR2,
	i_run_id		IN	NUMBER
        );

procedure process_inbound_documents
        (
        i_transaction_type      IN      VARCHAR2,
	i_status		IN	varchar2
        );

procedure process_inbound_documents
        (
        i_transaction_type      IN      VARCHAR2
        );

procedure process_inbound_documents
        (
        i_transaction_type      IN      VARCHAR2,
	i_tp_code		IN	varchar2,
	i_status		IN	varchar2
        );

procedure run_inbound
	(
	i_document_id		IN	number,
	i_transaction_type	IN	varchar2,
	i_select_cursor		IN	INTEGER
	);

procedure update_document_status;

procedure initialize_inbound
	(
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number
	);

procedure close_inbound;

procedure insert_into_violations
	(
	i_document_id		IN	number
	);

procedure process_for_reqid
        (
        errbuf                  OUT NOCOPY     varchar2,
        retcode                 OUT NOCOPY     varchar2,
        i_transaction_type      IN      varchar2,
        i_reqid                 IN      number,
	i_debug_mode		IN	number
        );

procedure process_for_document_id
        (
        errbuf                  OUT NOCOPY     varchar2,
        retcode                 OUT NOCOPY     varchar2,
        i_transaction_type      IN      varchar2,
        i_document_id           IN      number,
	i_debug_mode		IN	number
        );

procedure process_for_status
        (
        errbuf                  OUT NOCOPY     varchar2,
        retcode                 OUT NOCOPY    varchar2,
        i_transaction_type      IN      varchar2,
        i_status                IN      varchar2,
	i_debug_mode		IN	number
        );

procedure process_for_transaction
        (
        errbuf                  OUT NOCOPY     varchar2,
        retcode                 OUT NOCOPY     varchar2,
        i_transaction_type      IN      varchar2,
	i_debug_mode		IN	number
        );

procedure process_for_tpstatus
        (
        errbuf                  OUT NOCOPY     varchar2,
        retcode                 OUT NOCOPY     varchar2,
        i_transaction_type      IN      varchar2,
        i_tp_code      		IN      varchar2,
        i_status                IN      varchar2,
	i_debug_mode		IN	number
        );

procedure process_documents
	(
	i_document_id		IN	number,
	i_transaction_type	IN	varchar2,
	i_select_cursor		IN	integer
	);

procedure select_stage
        (
        i_select_cursor         OUT NOCOPY    integer
        );

function insert_into_prod_interface
        (
        i_Insert_cursor         IN OUT NOCOPY  INTEGER,
        i_level                 IN      NUMBER
        )
return boolean;

end ece_inbound;

 

/

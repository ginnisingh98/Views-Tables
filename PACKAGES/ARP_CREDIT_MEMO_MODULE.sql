--------------------------------------------------------
--  DDL for Package ARP_CREDIT_MEMO_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CREDIT_MEMO_MODULE" AUTHID CURRENT_USER AS
/* $Header: ARTECMMS.pls 120.7.12010000.1 2008/07/24 16:55:38 appldev ship $ */

--
-- global error buffer
--
g_error_buffer			VARCHAR2(1000);

--
-- Public user-defined exceptions
--
no_ccid				EXCEPTION;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  credit_transactions
--
-- DECSRIPTION:
--   Server-side entry point for the CM module.
--
-- ARGUMENTS:
--      IN:
--        customer_trx_id
--        customer_trx_line_id
--        prev_customer_trx_id
--        prev_cust_trx_line_id
--        request_id
--	  process_mode 		(I)nsert or (U)pdate
--
--      IN/OUT:
--        failure_count
--
--      OUT:
--
-- NOTES:
--   Raises the exception arp_credit_memo_module.no_ccid if autoaccounting
--   could not derive a valid code combination.  The public variable
--   g_error_buffer is populated for more information.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE credit_transactions(
	p_customer_trx_id 		IN NUMBER,
        p_customer_trx_line_id 		IN NUMBER,
        p_prev_customer_trx_id 		IN NUMBER,
        p_prev_cust_trx_line_id 	IN NUMBER,
        p_request_id 			IN NUMBER,
        p_failure_count	 		IN OUT NOCOPY NUMBER,
	p_process_mode			IN VARCHAR2 DEFAULT 'I'
 );


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  credit_transactions
--
-- DECSRIPTION:
--   Server-side entry point for the CM module.
--
-- ARGUMENTS:
--      IN:
--        customer_trx_id
--        customer_trx_line_id
--        prev_customer_trx_id
--        prev_cust_trx_line_id
--        request_id
--	  process_mode 		(I)nsert or (U)pdate
--
--      IN/OUT:
--        failure_count
--	  rule_start_date
--	  accounting_rule_duration
--
--      OUT:
--
-- NOTES:
--   Raises the exception arp_credit_memo_module.no_ccid if autoaccounting
--   could not derive a valid code combination.  The public variable
--   g_error_buffer is populated for more information.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE credit_transactions(
	p_customer_trx_id 		IN NUMBER,
        p_customer_trx_line_id 		IN NUMBER,
        p_prev_customer_trx_id 		IN NUMBER,
        p_prev_cust_trx_line_id 	IN NUMBER,
        p_request_id 			IN NUMBER,
        p_failure_count	 		IN OUT NOCOPY NUMBER,
        p_rule_start_date 		IN OUT NOCOPY DATE,
        p_accounting_rule_duration	IN OUT NOCOPY NUMBER,
	p_process_mode			IN VARCHAR2 DEFAULT 'I',
        p_run_autoaccounting_flag       IN BOOLEAN DEFAULT TRUE
 );


PROCEDURE test_build_update_mode_sql;
PROCEDURE test_build_nonrule_sql;
PROCEDURE test_build_rule_sql;
PROCEDURE test_build_net_revenue_sql;
PROCEDURE test_load_net_revenue( p_prev_ctlid NUMBER );
PROCEDURE test_credit_nonrule_trxs(
	p_customer_trx_id 	NUMBER,
	p_customer_trx_line_id 	NUMBER,
	p_request_id 		NUMBER );

PROCEDURE test_credit_rule_trxs(
	p_customer_trx_id 	NUMBER,
        p_prev_customer_trx_id	NUMBER,
	p_customer_trx_line_id 	NUMBER,
        p_prev_cust_trx_line_id NUMBER,
	p_request_id 		NUMBER );

/* 6129294 - added to support date overrides on RAM'd transactions */
FUNCTION get_valid_date(
        p_gl_date IN DATE,
        p_inv_rule_id IN NUMBER,
        p_set_of_books_id IN NUMBER)
RETURN DATE;

PROCEDURE init;

END arp_credit_memo_module;

/

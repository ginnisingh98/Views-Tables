--------------------------------------------------------
--  DDL for Package ARP_AUTO_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_AUTO_ACCOUNTING" AUTHID CURRENT_USER AS
/* $Header: ARTEAACS.pls 120.7 2004/10/26 13:13:43 mraymond ship $ */

--
-- global error buffer
--
g_errorbuf			VARCHAR2(1000);
g_error_buffer			VARCHAR2(1000);

-- Public user-defined exceptions
--
no_ccid				EXCEPTION;
g_deposit_flag      varchar2(1);

-- global variable
-- This variable is introduced to keep track from auto auccounting is getting
-- called. At present this variable is use to call mrc engine or not depending
-- on the value.
g_called_from		VARCHAR2(30) := 'FORMS';

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  do_autoaccounting
--
-- DECSRIPTION:
--   Server-side entry point for autoaccounting.
--
-- ARGUMENTS:
--      IN:
--        mode:  May be I(nsert), U(pdate), D(elete), or (G)et
--        account_class:  REC, REV, FREIGHT, TAX, UNBILL, UNEARN, SUSPENSE,
--                        CHARGES
--        customer_trx_id:  NULL if not applicable
--        customer_trx_line_id:  NULL if not applicable (G)
--        cust_trx_line_salesrep_id:  NULL if not applicable
--        request_id:  NULL if not applicable
--        gl_date:  GL date of the account assignment
--        original_gl_date:  Original GL date
--        total_trx_amount:  For Receivable account only
--        passed_ccid:  Code comination ID to use if supplied
--        force_account_set_no:
--        cust_trx_type_id (G)
--        primary_salesrep_id (G)
--        inventory_item_id (G)
--        memo_line_id (G)
--
--      IN/OUT:
--        ccid
--        concat_segments
--        failure_count
--
--      OUT:
--
-- NOTES:
--   If mode is not (G)et, raises the exception
--   arp_auto_accounting.no_ccid if autoaccounting could not derive a
--   valid code combination.  The public variable g_error_buffer is
--   populated for more information.  In (G)et mode, check the value
--   assigned to p_ccid.  If it is -1, then no ccid was found.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
-- HISTORY:
--
--
PROCEDURE do_autoaccounting( p_mode IN VARCHAR2,
                            p_account_class IN VARCHAR2,
                            p_customer_trx_id IN NUMBER,
                            p_customer_trx_line_id IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id IN NUMBER,
                            p_gl_date IN DATE,
                            p_original_gl_date IN DATE,
                            p_total_trx_amount IN NUMBER,
                            p_passed_ccid IN NUMBER,
                            p_force_account_set_no IN VARCHAR2,
                            p_cust_trx_type_id IN NUMBER,
                            p_primary_salesrep_id IN NUMBER,
                            p_inventory_item_id IN NUMBER,
                            p_memo_line_id IN NUMBER,
                            p_ccid IN OUT NOCOPY NUMBER,
                            p_concat_segments IN OUT NOCOPY VARCHAR2,
                            p_failure_count IN OUT NOCOPY NUMBER );
--
-- PROCEDURE NAME:  do_autoaccounting
--
-- DECSRIPTION:
--   Overloaded procedure when autoaccounting is called in G or Get mode
--   as warehouse id is required to be passed in and bill_to_site_use_id
--   is implicitly derived.
--
-- ARGUMENTS:
--      IN:
--        mode:  May be (G)et only as the routine is written for the same
--        account_class:  REC, REV, FREIGHT, TAX, UNBILL, UNEARN, SUSPENSE,
--                        CHARGES
--        customer_trx_id:  NULL if not applicable
--        customer_trx_line_id:  NULL if not applicable (G)
--        cust_trx_line_salesrep_id:  NULL if not applicable
--        request_id:  NULL if not applicable
--        gl_date:  GL date of the account assignment
--        original_gl_date:  Original GL date
--        total_trx_amount:  For Receivable account only
--        passed_ccid:  Code comination ID to use if supplied
--        force_account_set_no:
--        cust_trx_type_id (G)
--        primary_salesrep_id (G)
--        inventory_item_id (G)
--        memo_line_id (G)
--        warehouse_id (G)
--
--      IN/OUT:
--        ccid
--        concat_segments
--        failure_count
--
--      OUT:
--
-- NOTES:
--   If mode is not (G)et, raises the exception
--   arp_auto_accounting.no_ccid if autoaccounting could not derive a
--   valid code combination.  The public variable g_error_buffer is
--   populated for more information.  In (G)et mode, check the value
--   assigned to p_ccid.  If it is -1, then no ccid was found.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--   Never call this routine for ALL classes as this was specifically
--   written to work in Get mode, but will also work in other modes
--   provided the account class is not ALL
-- HISTORY:
--
--
PROCEDURE do_autoaccounting( p_mode                     IN VARCHAR2,
                            p_account_class             IN VARCHAR2,
                            p_customer_trx_id           IN NUMBER,
                            p_customer_trx_line_id      IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id                IN NUMBER,
                            p_gl_date                   IN DATE,
                            p_original_gl_date          IN DATE,
                            p_total_trx_amount          IN NUMBER,
                            p_passed_ccid               IN NUMBER,
                            p_force_account_set_no      IN VARCHAR2,
                            p_cust_trx_type_id          IN NUMBER,
                            p_primary_salesrep_id       IN NUMBER,
                            p_inventory_item_id         IN NUMBER,
                            p_memo_line_id              IN NUMBER,
                            p_warehouse_id              IN NUMBER,
                            p_ccid                      IN OUT NOCOPY NUMBER,
                            p_concat_segments           IN OUT NOCOPY VARCHAR2,
                            p_failure_count             IN OUT NOCOPY NUMBER );

--
-- Old version:
--

--
--
-- FUNCTION NAME:  do_autoaccounting
--
-- DECSRIPTION:
--   Server-side entry point for autoaccounting.
--   This is a cover function which calls the procedure do_autoaccounting
--   and exists for backward compatibility.  New programs should use
--   the procedure instead of the function.
--
-- ARGUMENTS:
--      IN:
--        mode:  May be I(nsert), U(pdate), D(elete), or (G)et
--        account_class:  REC, REV, FREIGHT, TAX, UNBILL, UNEARN, SUSPENSE,
--                        CHARGES
--        customer_trx_id:  NULL if not applicable
--        customer_trx_line_id:  NULL if not applicable
--        cust_trx_line_salesrep_id:  NULL if not applicable
--        request_id:  NULL if not applicable
--        gl_date:  GL date of the account assignment
--        original_gl_date:  Original GL date
--        total_trx_amount:  For Receivable account only
--        passed_ccid:  Code comination ID to use if supplied
--        force_account_set_no:
--        cust_trx_type_id:
--        primary_salesrep_id
--        inventory_item_id
--        memo_line_id
--        msg_level
--
--      IN/OUT:
--        ccid
--        concat_segments
--        num_dist_rows_failed
--        errorbuf
--
--      OUT:
--
-- RETURNS:
--   1 if no errors in deriving ccids and creating distributions,
--   0 if one or more rows where ccid could not be found,
--   Exception raised if SQL error or other fatal error.
--
-- NOTES:
--
-- HISTORY:
--
FUNCTION do_autoaccounting( p_mode IN VARCHAR2,
                            p_account_class IN VARCHAR2,
                            p_customer_trx_id IN NUMBER,
                            p_customer_trx_line_id IN NUMBER,
                            p_cust_trx_line_salesrep_id IN NUMBER,
                            p_request_id IN NUMBER,
                            p_gl_date IN DATE,
                            p_original_gl_date IN DATE,
                            p_total_trx_amount IN NUMBER,
                            p_passed_ccid IN NUMBER,
                            p_force_account_set_no IN VARCHAR2,
                            p_cust_trx_type_id IN NUMBER,
                            p_primary_salesrep_id IN NUMBER,
                            p_inventory_item_id IN NUMBER,
                            p_memo_line_id IN NUMBER,
                            p_ccid IN OUT NOCOPY NUMBER,
                            p_concat_segments IN OUT NOCOPY VARCHAR2,
                            p_num_failed_dist_rows IN OUT NOCOPY NUMBER,
                            p_errorbuf IN OUT NOCOPY VARCHAR2,
                            p_msg_level IN NUMBER default null)
  RETURN NUMBER;


FUNCTION query_autoacc_def( p_account_class IN VARCHAR2,
                            p_table_name IN VARCHAR2 )
    RETURN BOOLEAN;

FUNCTION search_glcc_for_ccid( p_system_info 	IN
                                 arp_trx_global.system_info_rec_type,
                               p_segment_table  IN fnd_flex_ext.SegmentArray,
                               p_segment_cnt 	IN BINARY_INTEGER )
  RETURN BINARY_INTEGER  ;

FUNCTION search_glcc_for_ccid( p_system_info 	 IN
                                 arp_trx_global.system_info_rec_type,
                               p_segment_table   IN fnd_flex_ext.SegmentArray,
                               p_segment_cnt  	 IN BINARY_INTEGER,
                               p_account_class   IN
                                 ra_cust_trx_line_gl_dist.account_class%type,
                               p_concat_segments IN VARCHAR2 )
          RETURN BINARY_INTEGER;

PROCEDURE test_harness;
PROCEDURE test_wes;

PROCEDURE test_load;
PROCEDURE test_query( p_account_class IN VARCHAR2,
                      p_table_name IN VARCHAR2 );
PROCEDURE test_find( p_trx_type_id  IN NUMBER,
                     p_salesrep_id  IN NUMBER,
                     p_inv_item_id  IN NUMBER,
                     p_memo_line_id IN NUMBER);

PROCEDURE test_assembly;
PROCEDURE test_build_sql;
PROCEDURE test_do_autoacc;
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
PROCEDURE init;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
--end anuj

END ARP_AUTO_ACCOUNTING;

 

/

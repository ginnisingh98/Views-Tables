--------------------------------------------------------
--  DDL for Package ARP_AUTO_ACCOUNTING_BR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_AUTO_ACCOUNTING_BR" AUTHID CURRENT_USER AS
/* $Header: ARTEAABS.pls 120.2 2004/11/03 23:25:07 anukumar ship $ */

/* =======================================================================
 | PUBLIC Data Types
 * ======================================================================*/
SUBTYPE ae_sys_rec_type   IS ARP_ACCT_MAIN.ae_sys_rec_type;

--
-- global error buffer
--
g_errorbuf			VARCHAR2(1000);
g_error_buffer			VARCHAR2(1000);

-- Public user-defined exceptions
--
no_ccid				EXCEPTION;


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
--        account_class:  REC, UNPAIDREC, FACTOR, REMITTANCE
--        customer_trx_id:  NULL if not applicable
--        request_id:  NULL if not applicable
--        passed_ccid:  Code comination ID to use if supplied
--        cust_trx_type_id (G)
--        receipt_method_id   (G)
--        bank_account_id (G)
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
PROCEDURE do_autoaccounting   ( p_mode IN VARCHAR2,
                                p_account_class IN VARCHAR2,
                                p_customer_trx_id IN NUMBER,
                                p_receivable_application_id IN NUMBER,
                                p_br_unpaid_ccid IN NUMBER,
                                p_cust_trx_type_id IN NUMBER,
                                p_site_use_id IN NUMBER,
                                p_receipt_method_id IN NUMBER,
                                p_bank_account_id IN NUMBER,
                                p_ccid IN OUT NOCOPY NUMBER,
                                p_concat_segments IN OUT NOCOPY VARCHAR2,
                                p_failure_count IN OUT NOCOPY NUMBER );

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

PROCEDURE test_build_sql;
PROCEDURE init;

END ARP_AUTO_ACCOUNTING_BR;

 

/

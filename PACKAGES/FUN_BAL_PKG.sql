--------------------------------------------------------
--  DDL for Package FUN_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_BAL_PKG" AUTHID CURRENT_USER AS
/* $Header: funbalpkgs.pls 120.8 2006/09/22 14:43:28 bsilveir noship $ */
/*
Please read the following before calling this API.  This API is used for balancing unbalanced
journals.  The current release support both General Ledger and SubLedger Accounting.
The only public call is journal_balancing procedure.

Notes:
1.  The balancing type column in FUN_BAL_RESULT_GT table is used for distinguish between
     whether a line is being generated using the intercompany balancing rules or intracompany
     balancing rules.  A line is generated using Intercompany balancing rules with type 'E',
     and it is generated using Intracompany balancing rules with type 'R''.  After calling the
     balancing API, the calling program should retrieve the generated lines and labelled these
     lines in the correct context when inserting these lines back to the base tables.

2.  The global temporary tables used for balancing are transaction specific, so that this API can
     be called multiple times within one single session as long as commit/rollback call occurs before
     the next time this API is called.  However, please be aware that balancing data would be lost
     during commit/rollback, and hence must be retrieived before such calls.

Assumptions of the Balancing API when being called:
1.  Each journal itself MUST be balanced by both the entered amounts and accounted amounts
at the header level
2.  Other then the normal required columns, the headers inserted into FUN_BAL_HEADERS_GT table
     must have a status of 'OK' in order for the balancing API to process the header.
3.  The lines inserted into FUN_BAL_LINES_GT table must have the generated column set to 'N'.
4.  The calling program would have to display the errors found in FUN_BAL_ERRORS_GT to the user
     using their own FND_MESSAGES, as the message details and the context to be displayed to the
     user are different for different calling programs.  The calling probrams can use the
     FUN_BAL_HEADERS_GT table to figure out which journals contain an error.  A journal ended
     in error would have its status set to 'ERROR'.
5.  The balancing API is currently using FND logging framework to log any other error, warning
     or debug messages into FND log.  Please note that the standard API parameter x_msg_data
     from the journal_balancing procedure call does not return any values since it is duplicating
     with the FND logging.
6.  If a journal belongs to an ALC ledger, callers of the Balancing API MUST provide the Balancing
     API with the primary ledger instead of the ALC ledger, and Balancing API would use the
     primary ledger information to balance the journal.  If the ALC ledger is passed in accidentally,
    unexpected exceptions could happen.  Setup data would be derived from the primary ledger.


Possible error codes to be found in fun_bal_errors_gt table are:
-------------------------------------------------------------------------
Generic
=====
1.  FUN_BSV_INVALID
     Values populated:  error_code, group_id, bal_seg_val
     Description:  BSV given in the journal is not assigned to a ledger nor to any LEs.

Intercompany
=========
Note:  To_le_id would return NULL for many-to-many intercompany mode
1. FUN_INTER_BSV_NOT_ASSIGNED
    Values populated: error_code, group_id, bal_seg_val
2. FUN_INTER_REC_NOT_ASSIGNED
    Values populated: error_code, group_id, from_le_id, to_le_id, ccid, acct_type
2. FUN_INTER_REC_NO_DEFAULT
    Values populated: error_code, group_id, from_le_id, to_le_id, ccid, acct_type
4. FUN_INTER_REC_NOT_VALID
    Values populated: error_code, group_id, from_le_id, to_le_id, ccid, acct_type, ccid_concat_disp
5. FUN_INTER_PAY_NOT_ASSIGNED
    Values populated: error_code, group_id, from_le_id, to_le_id, ccid, acct_type
2. FUN_INTER_PAY_NO_DEFAULT
    Values populated: error_code, group_id, from_le_id, to_le_id, ccid, acct_type
6. FUN_INTER_PAY_NOT_VALID
    Values populated: error_code, group_id, from_le_id, to_le_id, ccid, acct_type, ccid_concat_disp

Intracompany
=========
1.  FUN_INTRA_RULE_NOT_ASSIGNED
    Values populated: error_code, group_id, template_id, le_id
2.  FUN_INTRA_NO_CLEARING_BSV
    Values populated: error_code, group_id, template_id, le_id
3.  FUN_INTRA_CC_NOT_VALID
     FUN_INTRA_CC_NOT_CREATED
     FUN_INTRA_CC_NOT_ACTIVE'
    Values populated: error_code, group_id, template_id, le_id, dr_bsv, cr_bsv, acct_type,
                               ccid_concat_display
     If dr_bsv and cr_bsv are the same, it essentially means either default rule or
     clearing bsv (clearing bsv happens to be the same as the bsv of the line to be balanced)
     is being used
4.  FUN_INTRA_OVERRIDE_BSV_ERROR
     Values poplulated: group_id, clearing_bsv
        For JPMC, the API follows these rules:
        If a journal crosses LEs and an Override Clearing Company is provided,
       the API will fail and that particular journal will not post.
        If all journal lines are within one LE and an Override Clearing Company
      that is outside the LE is entered, the API will fail and that particular journal
      will not post.
        If all journal lines are within one LE and an Override Clearing Company that
      is within the same LE is entered, the API will balance the journal using the
      appropriate Balancing Rules.
        If all journal lines have BSVs that are not attached to an LE and an Override
      Clearing Company that is not attached to an LE is entered, the API will
      balance the journal using the appropriate Balancing Rules.


Temporary Tables for debugging purposes
============================
FUN_BAL_LOG_T -- Obsoleted
FUN_BAL_HEADERS_T
FUN_BAL_LINES_T
FUN_BAL_RESULTS_T
FUN_BAL_ERRORS_T
FUN_BAL_INTER_BSV_MAP_T
FUN_BAL_INTRA_BSV_MAP_T
FUN_BAL_INTER_LINES_T
FUN_BAL_INTRA_LINES_T

If the debug flag is FND_API.TRUE, the balancing API would commit so that debug data can be
saved into temporary tables for debugging purposes.

Notes:
          The balancing API does not deal with M-M algorithm due to currency balancing issues
      For 1-Many and Many-1, all information related to currency would use the detail ones,
        not the driving balancing segment.  These are the only situations where the currency
        information does not inherit directly from the parent line.


*/

TYPE headers_tab_type IS TABLE OF fun_bal_headers_gt%rowtype;
TYPE lines_tab_type IS TABLE OF fun_bal_lines_gt%rowtype;
TYPE results_tab_type IS TABLE OF fun_bal_results_gt%rowtype;
TYPE errors_tab_type IS TABLE OF fun_bal_errors_gt%rowtype;
TYPE inter_le_bsv_map_tab_type IS TABLE OF fun_bal_inter_bsv_map_t%rowtype;
TYPE intra_le_bsv_map_tab_type IS TABLE OF fun_bal_intra_bsv_map_t%rowtype;
--TYPE le_bsv_map_tab_type IS TABLE OF fun_bal_le_bsv_map_gt%rowtype;
TYPE inter_int_tab_type IS TABLE OF fun_bal_inter_int_gt%rowtype;
TYPE intra_int_tab_type IS TABLE OF fun_bal_intra_int_gt%rowtype;

PROCEDURE journal_balancing
( p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 default null ,
  p_validation_level IN NUMBER default null ,
  p_debug IN VARCHAR2 default null ,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_product_code IN VARCHAR2 -- Valid values are GL and SLA for this release
);

FUNCTION get_ccid
( ccid IN NUMBER,
  chart_of_accounts_id IN NUMBER,
  bal_seg_val IN VARCHAR2,
  intercompany_seg_val IN VARCHAR2,
  bal_seg_column_number IN NUMBER,
  intercompany_column_number IN NUMBER,
  gl_date IN DATE) RETURN NUMBER;


FUNCTION get_ccid_concat_disp
( ccid IN NUMBER,
  chart_of_accounts_id IN NUMBER,
  bal_seg_val IN VARCHAR2,
  intercompany_seg_val IN VARCHAR2,
  bal_seg_column_number IN NUMBER,
  intercompany_column_number IN NUMBER) RETURN VARCHAR2;

FUNCTION get_segment_index (p_chart_of_accounts_id IN NUMBER,
                            p_segment_type         VARCHAR2)
         RETURN NUMBER;

/*
PROCEDURE debug
( p_message IN VARCHAR2
);
PROCEDURE update_inter_seg_val;
PROCEDURE truncate_tables;
*/
/* Not implemented
FUNCTION do_curr_bal RETURN VARCHAR2;
FUNCTION do_inter_bal_m_to_m RETURN VARCHAR2;
FUNCTION do_intra_bal_m_to_m RETURN VARCHAR2;
FUNCTION do_curr_bal_m_to_m RETURN VARCHAR2;
*/

/* Obsoleted
FUNCTION get_inter_seg_val
( bal_seg_col_name IN VARCHAR2, ccid IN NUMBER) RETURN VARCHAR2;
  */

/*  Another possible method to perform inserting and commit.  This method is currently
     not preferred because bulk loading can not be utilized.  There would be 32 times processing
     overhead in performing the loop shown below.  It might be possible to use the cursor as
     a table and perform the insertion, but it is not clear what kind of performance we would
     get out of it.
TYPE headers_tab_type IS REF CURSOR RETURN fun_bal_headers_gt%rowtype;
TYPE lines_tab_type IS REF CURSOR RETURN fun_bal_lines_gt%rowtype;
TYPE results_tab_type IS REF CURSOR RETURN fun_bal_results_gt%rowtype;
TYPE errors_tab_type IS REF CURSOR RETURN fun_bal_errors_gt%rowtype;
TYPE le_bsv_map_tab_type IS REF CURSOR RETURN fun_bal_le_bsv_map_gt%rowtype;
TYPE inter_int_tab_type IS REF CURSOR RETURN fun_bal_inter_int_gt%rowtype;
TYPE intra_int_tab_type IS REF CURSOR RETURN fun_bal_intra_int_gt%rowtype;
PROCEDURE auto_test1(test_csr IN test_csr_type1) IS
  test_csr_rec fun_bal_headers_gt%rowtype;
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  LOOP
    FETCH test_csr into test_csr_rec;
    EXIT WHEN test_csr%NOTFOUND;
    INSERT INTO fun_bal_headers_gt values test_csr_rec;
  END LOOP;
  --INSERT INTO fun_bal_headers_gt SELECT * FROM test_csr;
  COMMIT;
  RETURN;
END auto_test1;

*/

/*
Reference:
GLISTBKB.pls -- File for get_ccid function
GLUGST.lpc -- File for getting product schema name and gathering statistics
Try selecting the ccid first before creating ccid
*/
/* Additional performance consideratioins
1. Create index, statistics
2. Problem here: Dynamic SQL for validating ccid
3. Problem here: Bind variables/decode for getting templates, accounts, etc.
*/
/*  Additional API considerations
1.  Check whether clearing BSV is valid or not.

*/

END fun_bal_pkg;

 

/

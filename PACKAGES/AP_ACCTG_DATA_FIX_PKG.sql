--------------------------------------------------------
--  DDL for Package AP_ACCTG_DATA_FIX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ACCTG_DATA_FIX_PKG" AUTHID CURRENT_USER AS
/* $Header: apgdfals.pls 120.1.12010000.6 2010/01/12 09:36:45 kpasikan ship $ */

TYPE Event_ID
IS TABLE OF
AP_ACCOUNTING_EVENTS_ALL.accounting_event_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE Source_ID
IS TABLE OF
AP_ACCOUNTING_EVENTS_ALL.Source_id%TYPE
INDEX BY BINARY_INTEGER;
--Bug5073523
TYPE Accounting_date
is TABLE OF
AP_ACCOUNTING_EVENTS_ALL.Accounting_date%TYPE
INDEX BY BINARY_INTEGER;

TYPE SOB_ID
is  TABLE OF
AP_INVOICE_DISTRIBUTIONS_ALL.set_of_books_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE Source_Table
IS TABLE OF
AP_ACCOUNTING_EVENTS_ALL.Source_Table%TYPE
INDEX BY BINARY_INTEGER;

TYPE Org_ID
IS TABLE OF
AP_ACCOUNTING_EVENTS_ALL.org_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE Period_Name
IS TABLE OF
VARCHAR2(15)
INDEX BY BINARY_INTEGER;

TYPE Header_ID
IS TABLE OF
NUMBER(15)
INDEX BY BINARY_INTEGER;

TYPE Group_ID
IS TABLE OF
NUMBER(15)
INDEX BY BINARY_INTEGER;

TYPE Vendor_Name
IS TABLE OF
PO_VENDORS.vendor_name%TYPE
INDEX BY BINARY_INTEGER;

TYPE Rejection_List_Tab_Typ
IS TABLE OF
VARCHAR2(1000)
INDEX BY BINARY_INTEGER;

  TYPE Pay_Dist_Rec IS RECORD
    (payment_hist_dist_id                   AP_PAYMENT_HIST_DISTS.PAYMENT_HIST_DIST_ID%TYPE,
     accounting_event_id                    AP_PAYMENT_HIST_DISTS.ACCOUNTING_EVENT_ID%TYPE,
     pay_dist_lookup_code                   AP_PAYMENT_HIST_DISTS.PAY_DIST_LOOKUP_CODE%TYPE,
     invoice_distribution_id                AP_PAYMENT_HIST_DISTS.INVOICE_DISTRIBUTION_ID%TYPE,
     amount                                 AP_PAYMENT_HIST_DISTS.AMOUNT%TYPE,
     payment_history_id                     AP_PAYMENT_HIST_DISTS.PAYMENT_HISTORY_ID%TYPE,
     invoice_payment_id                     AP_PAYMENT_HIST_DISTS.INVOICE_PAYMENT_ID%TYPE,
     bank_curr_amount                       AP_PAYMENT_HIST_DISTS.BANK_CURR_AMOUNT%TYPE,
     cleared_base_amount                    AP_PAYMENT_HIST_DISTS.CLEARED_BASE_AMOUNT%TYPE,
     historical_flag                        AP_PAYMENT_HIST_DISTS.HISTORICAL_FLAG%TYPE,
     invoice_dist_amount                    AP_PAYMENT_HIST_DISTS.INVOICE_DIST_AMOUNT%TYPE,
     invoice_dist_base_amount               AP_PAYMENT_HIST_DISTS.INVOICE_DIST_BASE_AMOUNT%TYPE,
     invoice_adjustment_event_id            AP_PAYMENT_HIST_DISTS.INVOICE_ADJUSTMENT_EVENT_ID%TYPE,
     matured_base_amount                    AP_PAYMENT_HIST_DISTS.MATURED_BASE_AMOUNT%TYPE,
     paid_base_amount                       AP_PAYMENT_HIST_DISTS.PAID_BASE_AMOUNT%TYPE,
     rounding_amt                           AP_PAYMENT_HIST_DISTS.ROUNDING_AMT%TYPE,
     reversal_flag                          AP_PAYMENT_HIST_DISTS.REVERSAL_FLAG%TYPE,
     reversed_pay_hist_dist_id              AP_PAYMENT_HIST_DISTS.REVERSED_PAY_HIST_DIST_ID%TYPE,
     created_by                             AP_PAYMENT_HIST_DISTS.CREATED_BY%TYPE,
     creation_date                          AP_PAYMENT_HIST_DISTS.CREATION_DATE%TYPE,
     last_update_date                       AP_PAYMENT_HIST_DISTS.LAST_UPDATE_DATE%TYPE,
     last_updated_by                        AP_PAYMENT_HIST_DISTS.LAST_UPDATED_BY%TYPE,
     last_update_login                      AP_PAYMENT_HIST_DISTS.LAST_UPDATE_LOGIN%TYPE,
     program_application_id                 AP_PAYMENT_HIST_DISTS.PROGRAM_APPLICATION_ID%TYPE,
     program_id                             AP_PAYMENT_HIST_DISTS.PROGRAM_ID%TYPE,
     program_login_id                       AP_PAYMENT_HIST_DISTS.PROGRAM_LOGIN_ID%TYPE,
     program_update_date                    AP_PAYMENT_HIST_DISTS.PROGRAM_UPDATE_DATE%TYPE,
     request_id                             AP_PAYMENT_HIST_DISTS.REQUEST_ID%TYPE,
     awt_related_id                         AP_PAYMENT_HIST_DISTS.AWT_RELATED_ID%TYPE,
     release_inv_dist_derived_from          AP_PAYMENT_HIST_DISTS.RELEASE_INV_DIST_DERIVED_FROM%TYPE,
     pa_addition_flag                       AP_PAYMENT_HIST_DISTS.PA_ADDITION_FLAG%TYPE,
     amount_variance                        AP_PAYMENT_HIST_DISTS.AMOUNT_VARIANCE%TYPE,
     invoice_base_amt_variance              AP_PAYMENT_HIST_DISTS.INVOICE_BASE_AMT_VARIANCE%TYPE,
     quantity_variance                      AP_PAYMENT_HIST_DISTS.QUANTITY_VARIANCE%TYPE,
     invoice_base_qty_variance              AP_PAYMENT_HIST_DISTS.INVOICE_BASE_QTY_VARIANCE%TYPE,
     write_off_code_combination             GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE);


  TYPE Pay_Dist_Tab_Typ IS TABLE OF Pay_Dist_Rec INDEX BY BINARY_INTEGER;

  TYPE Prepay_Dist_Rec IS RECORD
    (prepay_app_dist_id                       AP_PREPAY_APP_DISTS.PREPAY_APP_DIST_ID%TYPE,
     prepay_dist_lookup_code                  AP_PREPAY_APP_DISTS.PREPAY_DIST_LOOKUP_CODE%TYPE,
     invoice_distribution_id                  AP_PREPAY_APP_DISTS.INVOICE_DISTRIBUTION_ID%TYPE,
     prepay_app_distribution_id               AP_PREPAY_APP_DISTS.PREPAY_APP_DISTRIBUTION_ID%TYPE,
     accounting_event_id                      AP_PREPAY_APP_DISTS.ACCOUNTING_EVENT_ID%TYPE,
     prepay_history_id                        AP_PREPAY_APP_DISTS.PREPAY_HISTORY_ID%TYPE,
     prepay_exchange_date                     AP_PREPAY_APP_DISTS.PREPAY_EXCHANGE_DATE%TYPE,
     prepay_pay_exchange_date                 AP_PREPAY_APP_DISTS.PREPAY_PAY_EXCHANGE_DATE%TYPE,
     prepay_clr_exchange_date                 AP_PREPAY_APP_DISTS.PREPAY_CLR_EXCHANGE_DATE%TYPE,
     prepay_exchange_rate                     AP_PREPAY_APP_DISTS.PREPAY_EXCHANGE_RATE%TYPE,
     prepay_pay_exchange_rate                 AP_PREPAY_APP_DISTS.PREPAY_PAY_EXCHANGE_RATE%TYPE,
     prepay_clr_exchange_rate                 AP_PREPAY_APP_DISTS.PREPAY_CLR_EXCHANGE_RATE%TYPE,
     prepay_exchange_rate_type                AP_PREPAY_APP_DISTS.PREPAY_EXCHANGE_RATE_TYPE%TYPE,
     prepay_pay_exchange_rate_type            AP_PREPAY_APP_DISTS.PREPAY_PAY_EXCHANGE_RATE_TYPE%TYPE,
     prepay_clr_exchange_rate_type            AP_PREPAY_APP_DISTS.PREPAY_CLR_EXCHANGE_RATE_TYPE%TYPE,
     reversed_prepay_app_dist_id              AP_PREPAY_APP_DISTS.REVERSED_PREPAY_APP_DIST_ID%TYPE,
     amount                                   AP_PREPAY_APP_DISTS.AMOUNT%TYPE,
     base_amt_at_prepay_xrate                 AP_PREPAY_APP_DISTS.BASE_AMT_AT_PREPAY_XRATE%TYPE,
     base_amt_at_prepay_pay_xrate             AP_PREPAY_APP_DISTS.BASE_AMT_AT_PREPAY_PAY_XRATE%TYPE,
     base_amount                              AP_PREPAY_APP_DISTS.BASE_AMOUNT%TYPE,
     base_amt_at_prepay_clr_xrate             AP_PREPAY_APP_DISTS.BASE_AMT_AT_PREPAY_CLR_XRATE%TYPE,
     rounding_amt                             AP_PREPAY_APP_DISTS.ROUNDING_AMT%TYPE,
     round_amt_at_prepay_xrate                AP_PREPAY_APP_DISTS.ROUND_AMT_AT_PREPAY_XRATE%TYPE,
     round_amt_at_prepay_pay_xrate            AP_PREPAY_APP_DISTS.ROUND_AMT_AT_PREPAY_PAY_XRATE%TYPE,
     round_amt_at_prepay_clr_xrate            AP_PREPAY_APP_DISTS.ROUND_AMT_AT_PREPAY_CLR_XRATE%TYPE,
     last_updated_by                          AP_PREPAY_APP_DISTS.LAST_UPDATED_BY%TYPE,
     last_update_date                         AP_PREPAY_APP_DISTS.LAST_UPDATE_DATE%TYPE,
     last_update_login                        AP_PREPAY_APP_DISTS.LAST_UPDATE_LOGIN%TYPE,
     created_by                               AP_PREPAY_APP_DISTS.CREATED_BY%TYPE,
     creation_date                            AP_PREPAY_APP_DISTS.CREATION_DATE%TYPE,
     program_application_id                   AP_PREPAY_APP_DISTS.PROGRAM_APPLICATION_ID%TYPE,
     program_id                               AP_PREPAY_APP_DISTS.PROGRAM_ID%TYPE,
     program_update_date                      AP_PREPAY_APP_DISTS.PROGRAM_UPDATE_DATE%TYPE,
     request_id                               AP_PREPAY_APP_DISTS.REQUEST_ID%TYPE,
     awt_related_id                           AP_PREPAY_APP_DISTS.AWT_RELATED_ID%TYPE,
     release_inv_dist_derived_from            AP_PREPAY_APP_DISTS.RELEASE_INV_DIST_DERIVED_FROM%TYPE,
     pa_addition_flag                         AP_PREPAY_APP_DISTS.PA_ADDITION_FLAG%TYPE,
     bc_event_id                              AP_PREPAY_APP_DISTS.BC_EVENT_ID%TYPE,
     amount_variance                          AP_PREPAY_APP_DISTS.AMOUNT_VARIANCE%TYPE,
     invoice_base_amt_variance                AP_PREPAY_APP_DISTS.INVOICE_BASE_AMT_VARIANCE%TYPE,
     quantity_variance                        AP_PREPAY_APP_DISTS.QUANTITY_VARIANCE%TYPE,
     invoice_base_qty_variance                AP_PREPAY_APP_DISTS.INVOICE_BASE_QTY_VARIANCE%TYPE,
     write_off_code_combination               GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE);

  TYPE Prepay_Dist_Tab_Typ IS TABLE OF Prepay_Dist_Rec INDEX BY BINARY_INTEGER;


G_Group_ID Group_ID;

G_Bug_Number NUMBER;
NAMES_FILE UTL_FILE.FILE_TYPE ;

  /* Procedure to open the log files on the instance where the datafix
     script is being run. The log file contains the log messages
     and the report outputs written by the data fix scripts.
     The file location is the environment's 'utl_file_dir' parameter. */
  PROCEDURE Open_Log_Out_Files
       (p_bug_number             IN      VARCHAR2,
        p_file_location          OUT NOCOPY VARCHAR2);


  /* Procedure to close the log files on the instance once all the log
     messages are written to it. */
  PROCEDURE Close_Log_Out_Files;


  /* Procedure to create temproary backup tables for the accounting */
  PROCEDURE Create_Temp_Acctg_Tables
       (p_bug_number             IN      NUMBER);


  /* Procedure to get all the columns for a particular table.
     This procedure gets called from Back_Up_Acctg procedure. */
  PROCEDURE get_cols
       (tab_name                 IN     VARCHAR2,
        ret_str                 OUT NOCOPY VARCHAR2);

  /* Overload get_cols to handle the case where a schema needs to
     be designated because the table exists in more than one schema. */
  PROCEDURE get_cols
       (tab_name                 IN     VARCHAR2,
        schema_name              IN     VARCHAR2,
        ret_str                 OUT NOCOPY VARCHAR2);

  /* Procedure to get the backup of all the Accounting (XLA) tables. */
  PROCEDURE Back_Up_Acctg
       (p_bug_number             IN      NUMBER,
        P_Driver_Table           in VARCHAR2 DEFAULT NULL,
        P_Calling_Sequence       in VARCHAR2 DEFAULT NULL
       );


  /* Procedure to print messages in the Log file */
  PROCEDURE Print
       (p_message                 IN       VARCHAR2,
        p_calling_sequence        IN       VARCHAR2 DEFAULT NULL);


  /* Procedure to print the values in the table and column list
     passed as parameters, in HTML table format, into the Log file. */
  PROCEDURE Print_Html_Table
       (p_select_list       IN VARCHAR2,
        p_table_in          IN VARCHAR2,
        p_where_in          IN VARCHAR2 DEFAULT NULL,
        p_calling_sequence  IN VARCHAR2 DEFAULT NULL);


  /* Procedure to backup the data from the source table to destination
     table. It also takes in as input SELECT LIST which determine
     the list of columns which will be backed up. The additional
     WHERE caluse can also be passed in as input. */
  PROCEDURE Backup_data
      (p_source_table      IN VARCHAR2,
       p_destination_table IN VARCHAR2,
       p_select_list       IN VARCHAR2,
       p_where_clause      IN VARCHAR2,
       p_calling_sequence  IN VARCHAR2 DEFAULT NULL);

 PROCEDURE apps_initialize
      (p_user_name          IN           FND_USER.USER_NAME%TYPE,
       p_resp_name          IN           FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE,
       p_calling_sequence   IN           VARCHAR2);

 PROCEDURE check_period
      (p_bug_no                      IN          NUMBER,
       p_driver_table                IN          VARCHAR2,
       p_check_event_date            IN          VARCHAR2 DEFAULT 'Y',
       p_check_sysdate               IN          VARCHAR2 DEFAULT 'N',
       p_chk_proposed_undo_date      IN          VARCHAR2 DEFAULT 'N',
       p_update_process_flag         IN          VARCHAR2,
       P_calc_undo_date              IN          VARCHAR2,
       p_commit_flag                 IN          VARCHAR2 DEFAULT 'N',
       p_calling_sequence            IN          VARCHAR2);

 PROCEDURE check_ccid
      (p_bug_no                       IN          NUMBER,
       p_driver_table                 IN          VARCHAR2,
       p_update_process_flag          IN          VARCHAR2,
       p_commit_flag                  IN          VARCHAR2 DEFAULT 'N',
       p_calling_sequence             IN          VARCHAR2);


  /* Procedure to undo Accounting for an invoice or payment
     Parameters : p_source_table      - Value is either AP_INVOICES or
                                        AP_PAYMENTS
                  p_source_id         - For AP_INVOICES it is invoice_id
                                        for AP_PAYMENTS it is check_id
                  p_Event_id          - It is a non-mandatory field
                                        and is accounting event id
                  p_calling_sequence  - Name of the package that
                                        Calls Undo accounting
                  p_bug_id            - Bug Id
  */
 PROCEDURE Undo_Accounting
     (p_Source_Table      IN VARCHAR2,
      p_Source_Id         IN NUMBER,
      p_Event_Id          IN NUMBER DEFAULT NULL,
      p_skip_date_calc    IN VARCHAR2 DEFAULT 'N',
      p_undo_date         IN DATE,
      p_undo_period       IN VARCHAR2,
      p_bug_id            IN NUMBER DEFAULT NULL,
      p_Gl_Date           IN DATE DEFAULT NULL, --Bug#8471406
      p_rev_event_id      OUT NOCOPY NUMBER,
      p_new_event_id      OUT NOCOPY NUMBER,
      p_return_code       OUT NOCOPY VARCHAR2,
      p_calling_sequence  IN VARCHAR2);


  /* Procedure to undo Accounting for an invoice or payment
     Parameters : p_source_table      - Value is either AP_INVOICES or
                                        AP_PAYMENTS
                  p_source_id         - For AP_INVOICES it is invoice_id
                                        for AP_PAYMENTS it is check_id
                  p_Event_id          - It is a non-mandatory field
                                        and is accounting event id
                  p_calling_sequence  - Name of the package that
                                        Calls Undo accounting
                  p_bug_id            - Bug Id
  */
  PROCEDURE Undo_Accounting
      (p_source_table      IN VARCHAR2,
       p_source_id         IN NUMBER,
       p_Event_id          IN NUMBER DEFAULT NULL,
       p_calling_sequence  IN VARCHAR2 DEFAULT NULL,
       p_bug_id            IN NUMBER DEFAULT NULL,
       p_GL_Date           IN DATE DEFAULT NULL --Bug#8471406
       );

 PROCEDURE Del_Nonfinal_xla_entries
     (p_event_id           IN           NUMBER,
      p_delete_event       IN           VARCHAR2,
      p_commit_flag        IN           VARCHAR2,
      p_calling_sequence   IN           VARCHAR2);

 PROCEDURE undo_acctg_entries
      (p_bug_no             IN          NUMBER,
       p_driver_table       IN          VARCHAR2,
       p_calling_sequence   IN          VARCHAR2);

 PROCEDURE push_error(p_error_code     IN VARCHAR2,
                      p_error_stack    IN OUT NOCOPY Rejection_List_Tab_Typ);

PROCEDURE final_pay_round_dfix
  (p_invoice_id                 IN              NUMBER,
   p_op_event_id                OUT     NOCOPY  NUMBER,
   p_op_event_type              OUT     NOCOPY  VARCHAR2,
   p_return_status              OUT     NOCOPY  BOOLEAN,
   p_rejection_tab              OUT     NOCOPY  Rejection_List_Tab_Typ,
   p_rej_count                  OUT     NOCOPY  NUMBER,
   p_error_msg                  OUT     NOCOPY  VARCHAR2,
   p_pay_dist_tab               OUT     NOCOPY  Pay_Dist_Tab_Typ,
   p_prepay_dist_tab            OUT     NOCOPY  Prepay_Dist_Tab_Typ,
   p_commit_flag                IN              VARCHAR2,
   p_calling_sequence           IN              VARCHAR2);


Function Is_period_open(P_Date IN date,
                        P_Org_Id IN number default mo_global.get_current_org_id) return varchar2;


Function get_open_period_start_date(P_Org_Id IN number) return date;

FUNCTION delete_cascade_adjustments
  (p_source_type      IN VARCHAR2,
   p_source_id        IN NUMBER,
   p_related_event_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;

END AP_Acctg_Data_Fix_PKG;

/

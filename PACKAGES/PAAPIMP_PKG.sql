--------------------------------------------------------
--  DDL for Package PAAPIMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAAPIMP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAAPIMPS.pls 120.45.12010000.2 2008/08/27 12:28:22 prabsing ship $ */

        /* Main Procedure */

PROCEDURE PAAPIMP ( errbuf                  OUT NOCOPY VARCHAR2,
                    retcode                 OUT NOCOPY VARCHAR2,
                    invoice_type            IN  VARCHAR2   DEFAULT NULL,
                    project_id              IN  NUMBER     DEFAULT NULL,
                    batch_name              IN  VARCHAR2,
                    gl_date_arg             IN  VARCHAR2   DEFAULT NULL,
                    transaction_date_arg    IN  VARCHAR2   DEFAULT NULL,
                    debug_mode              IN  VARCHAR2   DEFAULT 'FALSE',
                    process_invoices        IN  VARCHAR2   DEFAULT 'Y',
                    process_receipts        IN  VARCHAR2   DEFAULT 'N',
                    process_discounts       IN  VARCHAR2   DEFAULT 'N',
                    output_type             IN  NUMBER     DEFAULT 3
                    );


/* Init Phase --------------------------------------------------*/
PROCEDURE Initialize_Global (   p_project_id       IN   NUMBER,
                   p_batch_name       IN   VARCHAR2,
                   p_gl_date         IN   DATE,
                   p_transaction_date     IN   DATE,
                   p_debug_mode       IN   VARCHAR2,
                   p_output         IN   NUMBER,
                   p_invoice_source1     IN   ap_invoices.source%TYPE   DEFAULT NULL,
                   p_invoice_source2     IN   ap_invoices.source%TYPE   DEFAULT NULL,
                   p_invoice_source3     IN   ap_invoices.source%TYPE   DEFAULT NULL,
                   p_invoice_type       IN   ap_invoices.invoice_type_lookup_code%TYPE,
                   p_system_linkage     IN   pa_transaction_interface.system_linkage%TYPE,
                   p_process_receipts     IN   VARCHAR2           DEFAULT 'N');

PROCEDURE fetch_pf_var(p_process_receipts IN VARCHAR2 DEFAULT 'N');

FUNCTION create_new_batch_name
RETURN pa_transaction_interface.batch_name%TYPE;

PROCEDURE write_validate_param_log;

PROCEDURE write_log (   p_message_type   IN NUMBER,
                        p_message     IN VARCHAR2);


-- Global Record and Table Definitions

TYPE rsob IS RECORD (  rsob_id        gl_alc_ledger_rships_v.ledger_id%TYPE,
                       rcurrency_code gl_alc_ledger_rships_v.currency_code%TYPE);


-- Variables to record set of books ID for AP and PA

  G_PA_SOB                  NUMBER;
  G_AP_SOB                  NUMBER;
  G_PO_SOB                  NUMBER;


-- Global variable to indicate whether to call ins_mc_txn_interface_all

--  G_DO_MRC_FLAG                VARCHAR2(2);

-- Global variables for the parameters

  G_PROJECT_ID                NUMBER;
  G_GL_DATE                   DATE;
  G_TRANSACTION_DATE          DATE;
  G_DEBUG_MODE                VARCHAR2(10);

-- Global profile variables

  G_ACCTNG_METHOD             VARCHAR2(1);
  G_USER_ID                   NUMBER;
  G_REQUEST_ID                NUMBER;
  G_PROG_APPL_ID              NUMBER;
  G_PROG_ID                   NUMBER;
  G_LOGIN_ID                  NUMBER;
  G_COMMIT_SIZE               NUMBER;
  G_TRANS_DFF_AP              VARCHAR2(10);

   /* Count variables */
  G_NUM_BATCHES_PROCESSED               NUMBER;
  G_NUM_INVOICES_PROCESSED              NUMBER;
  G_NUM_DISTRIBUTIONS_PROCESSED         NUMBER;
  G_DISTRIBUTIONS_MARKED                NUMBER;
  G_PAY_DISTRIBUTIONS_MARKED            NUMBER;
  G_DISC_DISTRIBUTIONS_MARKED           NUMBER;
   -- Count variables for AP Discounts
   G_NUM_DISCOUNTS_PROCESSED            NUMBER;

  G_PROFILE_NAME                   VARCHAR2(128);
  G_LOCK_NAME                      VARCHAR2(128);
  G_LOCKHNDL VARCHAR2(128);
  G_TRANSACTION_SOURCE             pa_transaction_interface.transaction_source%TYPE;
  G_USER_TRANSACTION_SOURCE        pa_transaction_interface.user_transaction_source%TYPE;
  G_NRT_TRANSACTION_SOURCE         pa_transaction_interface.transaction_source%TYPE;
  G_NRT_USER_TRANSACTION_SOURCE    pa_transaction_interface.user_transaction_source%TYPE;
  G_INVOICE_SOURCE1                ap_invoices.source%TYPE;
  G_INVOICE_SOURCE2                ap_invoices.source%TYPE;
  G_INVOICE_SOURCE3                ap_invoices.source%TYPE;
  G_INVOICE_TYPE                   ap_invoices.invoice_type_lookup_code%TYPE;
  G_BATCH_NAME                     pa_transaction_interface.batch_name%TYPE;
  G_NRT_BATCH_NAME                 pa_transaction_interface.batch_name%TYPE;
  G_INTERFACE_ID                   NUMBER;
  G_NRT_INTERFACE_ID               NUMBER;
  G_SYSTEM_LINKAGE                 pa_transaction_interface.system_linkage%TYPE;
  G_OUTPUT NUMBER;   /* Indicate what kind of output procedure to use: dbms_output or PA_DEBUG */
  G_TRANSACTION_STATUS_CODE        pa_transaction_interface.transaction_status_code%TYPE;
  G_TRANSACTION_REJECTION_CODE     pa_transaction_interface.transaction_rejection_code%TYPE;

   --AP Discounts
  G_Discount_Method                       VARCHAR2(10);
  G_DISC_TRANSACTION_SOURCE               pa_transaction_interface.transaction_source%TYPE;
  G_DISC_USER_TRANSACTION_SOURCE          pa_transaction_interface.user_transaction_source%TYPE;
  G_DISC_BATCH_NAME                       pa_transaction_interface.batch_name%TYPE;
  G_DISC_INTERFACE_ID                     NUMBER;
  G_Profile_Discount_Start_date           DATE;

   -- Receipt Accruals
  G_RCV_TRANSACTIONS_MARKED_O            NUMBER;
  G_RCV_TRANSACTIONS_MARKED_J            NUMBER;
  G_RCV_TRANSACTIONS_MARKED_NULL         NUMBER;
  G_RCV_TRANSACTIONS_MARKED_G            NUMBER;
  G_NUM_RCV_TXN_PROCESSED                NUMBER;
  G_NUM_RCVTAX_PROCESSED                 NUMBER;
  G_RCV_BATCH_NAME                       pa_transaction_interface.batch_name%TYPE;
  G_RCVTAX_BATCH_NAME                    pa_transaction_interface.batch_name%TYPE;
  G_RCV_INTERFACE_ID                     NUMBER;
  G_RCVNRT_INTERFACE_ID                  NUMBER;
  G_RCV_TRANSACTION_SOURCE               pa_transaction_interface.transaction_source%TYPE;
  G_RCVTAX_TRANSACTION_SOURCE            pa_transaction_interface.transaction_source%TYPE;
  G_RCV_USER_TRANSACTION_SOURCE          pa_transaction_interface.user_transaction_source%TYPE;
  G_RCVTAX_USER_TRX_SOURCE               pa_transaction_interface.user_transaction_source%TYPE;

-- pricing changes
  G_RCV_PRC_ADJ_TRX_SRC                 pa_transaction_interface.transaction_source%TYPE;
  G_RCV_PRC_ADJ_USER_TRX_SRC            pa_transaction_interface.user_transaction_source%TYPE;
  G_RCVTAX_PRC_ADJ_TRX_SRC              pa_transaction_interface.transaction_source%TYPE;
  G_RCVTAX_PRC_ADJ_USER_TRX_SRC         pa_transaction_interface.user_transaction_source%TYPE;

  G_TRANS_DFF_PO                          VARCHAR2(10);
  l_cdl_system_reference4                 pa_transaction_interface.cdl_system_reference4%TYPE :=NULL;

   --AP VARIANCE
   G_AP_VAR_BATCH_NAME                     pa_transaction_interface.batch_name%TYPE;
   G_AP_VAR_INTERFACE_ID                   NUMBER;
   G_AP_VAR_USER_TXN_SOURCE                pa_transaction_interface.user_transaction_source%TYPE;
   G_AP_VAR_TRANSACTION_SOURCE             pa_transaction_interface.user_transaction_source%TYPE;
   G_NUM_AP_VARIANCE_MARKED_W              NUMBER;
   G_NUM_AP_VARIANCE_PROCESSED             NUMBER;

   --AP ERV
   G_AP_ERV_BATCH_NAME                     pa_transaction_interface.batch_name%TYPE;
   G_AP_ERV_INTERFACE_ID                   NUMBER;
   G_AP_ERV_USER_TXN_SOURCE                pa_transaction_interface.user_transaction_source%TYPE;
   G_AP_ERV_TRANSACTION_SOURCE             pa_transaction_interface.user_transaction_source%TYPE;

   -- AP Freight and Misc
   G_AP_FRT_BATCH_NAME                     pa_transaction_interface.batch_name%TYPE; --NEW
   G_AP_FRT_INTERFACE_ID                   NUMBER; --NEW

   --Prepayment
   G_PREPAY_BATCH_NAME                     pa_transaction_interface.batch_name%TYPE; --NEW
   G_PREPAY_INTERFACE_ID                   NUMBER; --NEW

   G_UNIQUE_ID                             NUMBER;
   G_err_stack                             VARCHAR2(630);
   G_err_stage                             VARCHAR2(630);
   G_err_code                              NUMBER;
   G_err_stage_num                         NUMBER;

   /* MC Upgrade variables */
   G_ACCT_CURRENCY_CODE             VARCHAR(15);
   G_ORG_ID                         NUMBER;
   E_DIFFERENT_SOB                  EXCEPTION;
   L_pay_code_combination_id        ap_invoices.accts_pay_code_combination_id%TYPE := NULL;

   /* Used during insertion into pa_transaction_interface, this variable is set
      to the weekending date of the maximum expenditure item date of an invoice */

   G_EXPENDITURE_ENDING_DATE           pa_transaction_interface.expenditure_ending_date%TYPE;
   G_PER_BUS_GRP_ID                    pa_transaction_interface.person_business_group_id%TYPE;

   /* Added for performance improvement*/
   G_Assets_Addition_flag               ap_invoice_distributions.Assets_Addition_Flag%TYPE;

   /* Added to create pl/sql table columns in the same cursor*/
   l_pay_cc_id                      pa_transaction_interface.dr_code_combination_id%TYPE;
   l_quantity                       pa_transaction_interface.quantity%TYPE;
   l_denom_raw_cost                 pa_transaction_interface.denom_raw_cost%TYPE;
   l_acct_raw_cost                  pa_transaction_interface.acct_raw_cost%TYPE;
   l_denom_cur_code                 pa_transaction_interface.denom_currency_code%TYPE;
   l_acct_rate_date                 pa_transaction_interface.acct_rate_date%TYPE;
   l_acct_rate_type                 pa_transaction_interface.acct_rate_type%TYPE;
   l_acct_exch_rate                 pa_transaction_interface.acct_exchange_rate%TYPE;
   l_txn_src                        pa_transaction_interface.transaction_source%TYPE;
   l_user_txn_src                   pa_transaction_interface.user_transaction_source%TYPE;
   l_batch_name                     pa_transaction_interface.batch_name%TYPE;
   l_interface_id                   pa_transaction_interface.interface_id%TYPE;
   l_exp_end_date                   pa_transaction_interface.EXPENDITURE_ENDING_DATE%TYPE;
   l_txn_status_code                pa_transaction_interface.transaction_status_code%TYPE;
   l_txn_rej_code                   pa_transaction_interface.transaction_rejection_code%TYPE;
   l_bus_grp_id                     pa_transaction_interface.person_business_group_id%TYPE;
   l_record_type                    VARCHAR2(20);
   l_insert_flag                    VARCHAR2(1);
   l_cancel_flag                    VARCHAR2(1) := 'N';
   l_sc_xfer_code                   VARCHAR2(1) := 'V';
   l_net_zero_flag                  VARCHAR2(1):='N';
   l_denom_amt_var                  NUMBER;
   l_acct_amt_var                   NUMBER;
   l_adj_exp_item_id                NUMBER; --NEW
   l_prev_cr_ccid                   NUMBER;
   l_prev_dr_ccid                   NUMBER;
   l_prev_exp_item_id               NUMBER:=0;
   l_rev_index                      NUMBER:=0;
   l_pay_hist_id                    NUMBER;
   l_prepay_dist_id                 NUMBER;


   -- Initialize all PLSQL tables

   --l_dist_line_num_tbl            PA_PLSQL_DATATYPES.NumTabTyp;
   l_accounted_cr_tbl              PA_PLSQL_DATATYPES.NumTabTyp;
   l_accounted_dr_tbl              PA_PLSQL_DATATYPES.NumTabTyp;
   l_accounted_nr_tax_tbl          PA_PLSQL_DATATYPES.NumTabTyp;
   l_acct_exch_rate_tbl            PA_PLSQL_DATATYPES.NumTabTyp;
   l_acct_pay_cc_id_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
   l_acct_rate_date_tbl            PA_PLSQL_DATATYPES.DateTabTyp;
   l_acct_rate_type_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
   l_acct_raw_cost_tbl             PA_PLSQL_DATATYPES.NumTabTyp;
   l_adj_exp_item_id_tbl           PA_PLSQL_DATATYPES.IdTabTyp;--NEW
   l_amount_tbl                    PA_PLSQL_DATATYPES.NumTabTyp;
   l_attribute10_tbl               PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute1_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute2_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute3_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute4_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute5_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute6_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute7_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute8_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute9_tbl                PA_PLSQL_DATATYPES.Char150TabTyp;
   l_attribute_cat_tbl             PA_PLSQL_DATATYPES.Char150TabTyp;
   l_batch_name_tbl                PA_PLSQL_DATATYPES.Char50TabTyp;
   l_bus_grp_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_cancel_flag_tbl               PA_PLSQL_DATATYPES.CHAR1TabTyp;--NEW
   l_cc_id_tbl                     PA_PLSQL_DATATYPES.IdTabTyp;
   l_cdl_sys_ref4_tbl              PA_PLSQL_DATATYPES.Char15TabTyp;
   l_cdl_sys_ref3_tbl              PA_PLSQL_DATATYPES.Char15TabTyp;
   l_created_by_tbl                PA_PLSQL_DATATYPES.NumTabTyp;
   l_cur_conv_date_tbl             PA_PLSQL_DATATYPES.DateTabTyp;
   l_cur_conv_rate_tbl             PA_PLSQL_DATATYPES.NumTabTyp;
   l_cur_conv_type_tbl             PA_PLSQL_DATATYPES.CHAR30TabTyp;
   l_denom_cur_code_tbl            PA_PLSQL_DATATYPES.CHAR15TabTyp;
   l_denom_raw_cost_tbl            PA_PLSQL_DATATYPES.NumTabTyp;
   l_description_tbl               PA_PLSQL_DATATYPES.Char240TabTyp;
   l_dest_typ_code_tbl             PA_PLSQL_DATATYPES.Char25TabTyp;
   l_dist_cc_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_ei_date_tbl                   PA_PLSQL_DATATYPES.DateTabTyp;
   l_employee_id_tbl               PA_PLSQL_DATATYPES.IdTabTyp;
   l_entered_cr_tbl                PA_PLSQL_DATATYPES.NumTabTyp;
   l_entered_dr_tbl                PA_PLSQL_DATATYPES.NumTabTyp;
   l_entered_nr_tax_tbl            PA_PLSQL_DATATYPES.NumTabTyp;
   l_exp_end_date_tbl              PA_PLSQL_DATATYPES.DateTabTyp;
   l_exp_org_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_exp_type_tbl                  PA_PLSQL_DATATYPES.Char30TabTyp;
   l_fc_document_type_tbl          PA_PLSQL_DATATYPES.CHAR15TabTyp;--NEW
   l_fc_enabled_tbl                PA_PLSQL_DATATYPES.CHAR1TabTyp;--NEW
   l_gl_date_tbl                   PA_PLSQL_DATATYPES.DateTabTyp;
   l_insert_flag_tbl               PA_PLSQL_DATATYPES.CHAR1TabTyp;
   l_interface_id_tbl              PA_PLSQL_DATATYPES.IdTabTyp;
   l_inv_pay_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
--   l_inv_typ_code_tbl            PA_PLSQL_DATATYPES.Char25TabTyp;
   l_inv_type_code_tbl             PA_PLSQL_DATATYPES.Char25TabTyp;
   l_invoice_dist_id               PA_PLSQL_DATATYPES.IdTabTyp; --NEw
   l_invoice_dist_id_tbl           PA_PLSQL_DATATYPES.IdTabTyp;
   l_invoice_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_invoice_num_tbl               PA_PLSQL_DATATYPES.Char50TabTyp;
   l_job_id_tbl                    PA_PLSQL_DATATYPES.IdTabTyp;
   l_justification_tbl             PA_PLSQL_DATATYPES.Char240TabTyp;
   l_ln_type_lookup_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
   l_org_id_tbl                    PA_PLSQL_DATATYPES.IdTabTyp;
   l_pa_add_flag_tbl               PA_PLSQL_DATATYPES.Char1TabTyp;
   l_paid_emp_id_tbl               PA_PLSQL_DATATYPES.IdTabTyp;
   l_parent_pmt_id_tbl             PA_PLSQL_DATATYPES.IdTabTyp; --NEW
   l_parent_rcv_id_tbl             PA_PLSQL_DATATYPES.IdTabTyp; -- NEW --added for full return reversal logic
   l_rcv_amount_tbl                PA_PLSQL_DATATYPES.NumTabTyp; -- NEW --added for full return reversal logic
   l_parent_rev_id_tbl             PA_PLSQL_DATATYPES.IdTabTyp;--NEW
   l_pay_cc_id_tbl                 PA_PLSQL_DATATYPES.IdTabTyp;
   l_po_dist_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_po_head_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_po_num_tbl                    PA_PLSQL_DATATYPES.Char20TabTyp;
   l_proj_id_tbl                   PA_PLSQL_DATATYPES.IdTabTyp;
   l_project_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_quantity_tbl                  PA_PLSQL_DATATYPES.NumTabTyp;
   l_rcv_acct_evt_id_tbl           PA_PLSQL_DATATYPES.IdTabTyp; -- pricing changes
   l_rcv_acct_evt_typ_tbl          PA_PLSQL_DATATYPES.Char30TabTyp; -- pricing changes
   l_rcv_acct_rec_tax_tbl          PA_PLSQL_DATATYPES.NumTabTyp; -- pricing changes
   l_rcv_ent_rec_tax_tbl           PA_PLSQL_DATATYPES.NumTabTyp; -- pricing changes
   l_rcv_txn_id_tbl                PA_PLSQL_DATATYPES.IdTabTyp;
   l_rec_conv_rate_tbl             PA_PLSQL_DATATYPES.NumTabTyp;
   l_rec_cur_amt_tbl               PA_PLSQL_DATATYPES.NumTabTyp;
   l_rec_cur_code_tbl              PA_PLSQL_DATATYPES.Char15TabTyp;
   l_record_type_tbl               PA_PLSQL_DATATYPES.CHAR20TabTyp;
   l_reversal_flag_tbl             PA_PLSQL_DATATYPES.CHAR1TabTyp; --NEW
   l_sort_var_tbl                  PA_PLSQL_DATATYPES.NumTabTyp;
   l_source_tbl                    PA_PLSQL_DATATYPES.Char25TabTyp;
   l_task_id_tbl                   PA_PLSQL_DATATYPES.IdTabTyp;
   l_trx_type_tbl                  PA_PLSQL_DATATYPES.Char25TabTyp;
   l_txn_rej_code_tbl              PA_PLSQL_DATATYPES.Char30TabTyp;
   l_txn_src_tbl                   PA_PLSQL_DATATYPES.Char30TabTyp;
   l_txn_status_code_tbl           PA_PLSQL_DATATYPES.Char2TabTyp;
   l_user_txn_src_tbl              PA_PLSQL_DATATYPES.Char80TabTyp;
   l_vendor_id_tbl                 PA_PLSQL_DATATYPES.IdTabTyp;
   l_si_assts_add_flg_tbl          PA_PLSQL_DATATYPES.Char2TabTyp;
   l_mrc_exchange_date_tbl         PA_PLSQL_DATATYPES.DateTabTyp;
   l_payment_status_flag_tbl       PA_PLSQL_DATATYPES.Char30TabTyp;
   l_net_zero_flag_tbl             PA_PLSQL_DATATYPES.CHAR1TabTyp;--NEW
   l_sc_xfer_code_tbl              PA_PLSQL_DATATYPES.CHAR1TabTyp;--NEW
   l_rcv_sub_ledger_id_tbl         PA_PLSQL_DATATYPES.IdTabTyp;
   l_rev_parent_dist_id_tbl        PA_PLSQL_DATATYPES.IdTabTyp;
   l_rev_child_dist_id_tbl         PA_PLSQL_DATATYPES.IdTabTyp;
   l_rev_parent_dist_ind_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
   l_hist_flag_tbl                 PA_PLSQL_DATATYPES.Char2TabTyp;
   l_prepay_dist_id_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
   l_pay_hist_id_tbl               PA_PLSQL_DATATYPES.IdTabTyp;
   l_exp_cst_rt_flg_tbl            PA_PLSQL_DATATYPES.CHAR1TabTyp;--NEW
   l_po_tax_qty_tbl                PA_PLSQL_DATATYPES.NumTabTyp;
/*  Fixed value global variables */
   G_OUTPUT_SQLPLUS                NUMBER := 1;
   G_OUTPUT_PADEBUG                NUMBER := 2;
   G_OUTPUT_FND                    NUMBER := 3;

   /* Type of message */
   LOG                      NUMBER := 1;
   DEBUG                    NUMBER := 2;

   /*================================================================================*/
   /* Procedure Declarations*/

   /* Cleanup Phase -------------------------------------------------*/
   PROCEDURE cleanup;

   /* Net Zero Adjustment Phase -------------------------------------*/
   PROCEDURE net_zero_adjustment;

   /* Mark Distributions Phase --------------------------*/
   PROCEDURE mark_PAflag_O;

   /* Populate Transaction Interface Phase --------------------------*/
   FUNCTION Create_New_Org_Transref ( p_batch_name                IN  pa_transaction_interface.batch_name%TYPE,
                                      p_invoice_id                IN  ap_invoices.invoice_id%TYPE,
                                      p_invoice_distribution_id   IN  ap_invoice_distributions.invoice_distribution_id %TYPE)
            RETURN pa_transaction_interface.orig_transaction_reference%TYPE;

   PRAGMA RESTRICT_REFERENCES(create_new_org_transref, WNDS);

   PROCEDURE print_stat_and_submit_report;

   /* MRC Functions --------------------------------------------------*/

   FUNCTION get_mrc_flag RETURN VARCHAR2;

   /* Transaction Import Phase ---------------------------------------*/

   PROCEDURE Trans_Import (  p_transaction_source  IN  pa_transaction_interface.transaction_source%TYPE,
                             p_batch_name          IN  pa_transaction_interface.batch_name%TYPE,
                             p_interface_id        IN  pa_transaction_interface.interface_id%TYPE,
                             p_user_id             IN  NUMBER);

   /*===================================*/
   /*Declarations for invoice processing*/
   /*===================================*/

   CURSOR Invoice_Cur IS
    SELECT /*+ leading(DIST) */  INV.Invoice_id invoice_id,
      INV.created_by created_by,
      DIST.Invoice_distribution_id Invoice_distribution_id, --NEW
      DIST.Invoice_Line_Number Invoice_Line_Number, --NEW
      DIST.Project_id project_id,
      DIST.Task_id task_id,
      DIST.line_type_lookup_code,
      DIST.Expenditure_type expenditure_type,
      to_char(DIST.Expenditure_Item_Date, 'DD-MON-RR') expenditure_item_date,
      nvl(DIST.base_amount,DIST.amount) amount,
      DIST.description description,
      INVL.justification,				/* Modified for Bug 6659770 */
      DIST.dist_code_combination_id dist_code_combination_id,
      DIST.expenditure_organization_id expenditure_organization_id,
      decode(DIST.line_type_lookup_code,'ERV',null,
                                        'IPV',null,
               nvl(nvl(DECODE(TYPE.Cost_Rate_Flag,'Y', DIST.PA_Quantity,NVL(DIST.Amount,DIST.Base_Amount)),
                                            nvl( DIST.amount,DIST.base_amount )),0)) quantity,
      L_pay_code_combination_id  accts_pay_code_combination_id,
      DIST.accounting_date gl_date,
      DIST.attribute_category,
      DIST.attribute1,
      DIST.attribute2,
      DIST.attribute3,
      DIST.attribute4,
      DIST.attribute5,
      DIST.attribute6,
      DIST.attribute7,
      DIST.attribute8,
      DIST.attribute9,
      DIST.attribute10, /* MC Upgrade */
      DIST.receipt_currency_amount,
      DIST.receipt_currency_code,
      DIST.receipt_conversion_rate,
      DIST.amount  denom_raw_cost,
      INV.invoice_currency_code denom_currency_code,
      INV.exchange_date acct_rate_date,
      INV.exchange_rate_type acct_rate_type,
      INV.exchange_rate acct_exchange_rate,
      Decode(nvl(VEND.employee_id, 0),0,NULL,
               PA_UTILS.GetEmpJobId( VEND.employee_id,DIST.Expenditure_Item_Date)) Job_id,
      VEND.employee_id employee_id,
      VEND.vendor_id vendor_id,
      INV.invoice_type_lookup_code,
      INV.source,
      INV.org_id ,
      INV.invoice_num invoice_number ,
      l_cdl_system_reference4 cdl_system_reference4 ,
      DIST.po_distribution_id po_distribution_id /*added the following dummy columns for pl/sql table upgrade*/ ,
      l_txn_src        ,
      l_user_txn_src ,
      l_batch_name  ,
      l_interface_id  ,
      l_exp_end_date ,
      l_txn_status_code ,
      l_txn_rej_code ,
      l_bus_grp_id ,
      inv.paid_on_behalf_employee_id,
      DECODE(INV.source, 'Inter-Project Invoices', 1, 'Projects Intercompany Invoices',2, 3) sort_c ,
      nvl(DIST.reversal_flag,'N') reversal_flag          --NEW ,
     ,nvl(DIST.cancellation_flag,'N') cancellation_flag --NEW
     ,DIST.parent_reversal_id parent_reversal_id  --NEW
     ,l_net_zero_flag
     ,l_sc_xfer_code
     ,l_adj_exp_item_id
     ,Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(DIST.project_id, 'STD') fc_enabled
     ,nvl(DIST.exchange_date, INV.invoice_date) mrc_exchange_date
      --R12 AP lines uptake : PO matched Prepayment commitments are not fundschecked
     ,DECODE (inv.invoice_type_lookup_code,'PREPAYMENT',DECODE(DIST.po_distribution_id ,NULL,'ALL','ACT'),'ALL') fc_document_type
     ,'Y' si_assets_addition_flag
     ,'Y' insert_flag
     ,DIST.historical_flag historical_flag
     ,DIST.PRepay_distribution_id PRepay_distribution_id
      FROM PO_Vendors VEND,
           AP_Invoices INV,
           AP_Invoice_Lines INVL,
           PA_Transfer_AP_Invoices_View DIST,
           PA_EXPENDITURE_TYPES TYPE
     WHERE DIST.Invoice_Id = INV.Invoice_Id
       AND INVL.Invoice_id = INV.Invoice_Id
       AND INVL.Line_Number = DIST.Invoice_Line_Number
       AND INVL.Invoice_Id = DIST.Invoice_Id
       AND DIST.Pa_Addition_Flag = 'O'
       AND INV.Vendor_Id = VEND.Vendor_Id
       AND DIST.request_id = G_REQUEST_ID
       AND DIST.expenditure_type = TYPE.expenditure_type
     ORDER BY sort_c, INV.invoice_id,DIST.Invoice_distribution_id;

   PROCEDURE transfer_inv_to_pa;

   /*Tieback to AP Phase --------------------------------------------*/
   PROCEDURE tieback_AP_ER (
      p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
      p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
      p_interface_id IN pa_transaction_interface.interface_id%TYPE);


   PROCEDURE lock_rcv_txn (p_po_distribution_id IN ap_invoice_distributions.po_distribution_id%TYPE);

   PROCEDURE tieback_locked_rcvtxn;

   /*=====================================*/
   /*Declarations for Discount Processing */
   /*=====================================*/

--Begin Cursor for discounts

CURSOR DISCOUNT_Cur IS
SELECT pay.invoice_payment_id,
  INV.Invoice_id invoice_id,
  DIST.Invoice_distribution_id,
  DIST.Invoice_Line_Number Invoice_Line_Number,
  DIST.Project_id project_id,
  DIST.Task_id task_id,
  VEND.employee_id employee_id,
  DIST.Expenditure_type expenditure_type,
  PA_AP_INTEGRATION.get_si_cost_exp_item_date(
                                              chk.check_date,
                                              pay.accounting_date,
                                              dist.expenditure_item_date,
                                              pay.creation_date,
                                              NULL,
                                             'DISCOUNT'
                                             ) expenditure_item_date,
  VEND.vendor_id vendor_id,
  INV.created_by created_by,
  DIST.expenditure_organization_id expenditure_organization_id,
  l_quantity,
  Decode( nvl(VEND.employee_id, 0),0,NULL,
  PA_UTILS.GetEmpJobId(VEND.employee_id,DIST.Expenditure_Item_Date)) Job_id,
  DIST.description description,
  DIST.dist_code_combination_id dist_code_combination_id,
  l_pay_cc_id,
  pay.accounting_date gl_date,
  DIST.attribute_category,
  DIST.attribute1,
  DIST.attribute2,
  DIST.attribute3,
  DIST.attribute4,
  DIST.attribute5,
  DIST.attribute6,
  DIST.attribute7,
  DIST.attribute8,
  DIST.attribute9,
  DIST.attribute10,
  INV.invoice_type_lookup_code,
  INV.org_id,
  INV.invoice_num invoice_number,
  DIST.line_type_lookup_code
  ,INV.source
  ,nvl(PAYDIST.amount,0)  amount
  ,nvl(PAYDIST.paid_base_amount,nvl(PAYDIST.amount,0)) base_amount
  ,inv.payment_currency_code --new
  ,pay.exchange_date --new
  ,pay.exchange_rate_type  --new
  ,pay.exchange_rate --new
  ,l_cdl_system_reference4
  ,l_txn_src
  ,l_user_txn_src
  ,l_batch_name
  ,l_interface_id
  ,l_exp_end_date
  ,l_txn_status_code
  ,l_txn_rej_code
  ,l_bus_grp_id
--  ,nvl(pay.reversal_flag,'N') reversal_flag     --NEW
  ,DECODE(nvl(PAY.reversal_flag,'N'),'N',decode(nvl(DIST.reversal_flag,'N'),'Y','R','N'),PAY.reversal_flag) reversal_flag --Bug5408748
  ,l_cancel_flag cancel_flag
 -- ,pay.reversal_inv_pmt_id reversal_inv_pmt_id  --NEW
  ,DECODE(PAY.REVERSAL_INV_PMT_ID,null,decode(nvl(PAY.reversal_flag,'N'),'N',DIST.parent_reversal_id),PAY.REVERSAL_INV_PMT_ID) REVERSAL_INV_PMT_ID
  ,l_net_zero_flag
  ,l_sc_xfer_code
  ,l_adj_exp_item_id
  ,Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(DIST.project_id, 'STD') fc_enabled
  ,nvl(DIST.exchange_date, INV.invoice_date) mrc_exchange_date
  ,'ACT' fc_document_type
  ,'Y' si_assets_addition_flag
  ,'Y' insert_flag
  , paydist.payment_hist_dist_id
  ,dist.pa_addition_flag pa_addition_flag --Bug# 5516855
from AP_Invoice_Payments_all pay,
     po_vendors vend,
     ap_invoices inv,
     ap_payment_hist_dists paydist,
     PA_Transfer_AP_Invoices_View DIST,
     ap_checks chk
where pay.posted_flag='Y'
  AND pay.invoice_payment_id = paydist.invoice_payment_id
  AND pay.check_id = chk.check_id
  AND paydist.pay_dist_lookup_code = 'DISCOUNT'
  AND dist.line_type_lookup_code <> 'TAX'        /*bug-6326262*/
  AND DIST.invoice_id=pay.invoice_id
  AND INV.vendor_id = VEND.vendor_id
  AND DIST.invoice_distribution_id = paydist.invoice_distribution_id
  AND dist.invoice_id=inv.invoice_id
  AND paydist.pa_addition_flag = 'O'
  AND PAYDIST.request_id = G_REQUEST_ID
  ORDER BY INV.invoice_id, DIST.Invoice_Distribution_Id, PAY.invoice_payment_id;

--END cursor for discounts

   -- Check profile set-up of cut-off date of Discounts to be pulled
   FUNCTION return_profile_discount_date RETURN VARCHAR2;

   -- Processing discounts phase
   PROCEDURE mark_PA_Disc_flag_O;

   PROCEDURE transfer_disc_to_pa;


   /*===========================================*/
   /*Declarations for receipt Accrual processing*/
   /*===========================================*/

--The following cursors and procedures are added for Receipt Accrual processing
CURSOR Rcv_Receipts_Cur IS
SELECT rcv_txn.transaction_id           rcv_transaction_id,
  po_dist.po_distribution_id            po_distribution_id,
  po_dist.po_header_id                  po_header_id,
  po_head.segment1                      po_num,
  nvl(rcv_txn.quantity,0)                       quantity,  /* bug 3496492 */
  nvl(rcv_txn.quantity,0)                       quantity,  /* bug 5465098 */
  nvl(rcv_sub.ENTERED_DR,0)             entered_dr,
  nvl(rcv_sub.entered_cr,0)             entered_cr,
  nvl(rcv_sub.ACCOUNTED_DR,0)           accounted_dr,
  nvl(rcv_sub.accounted_cr,0)           accounted_cr,
  nvl(rcv_sub.ENTERED_NR_TAX,0)         ENTERED_NR_TAX,
  nvl(rcv_sub.ACCOUNTED_NR_TAX,0)       ACCOUNTED_NR_TAX,
  l_denom_raw_cost                      denom_raw_cost,
  l_acct_raw_cost                       acct_raw_cost,
  l_record_type                         record_type,
  rcv_sub.code_combination_id           dr_cc_id,
  rcv_txn.CURRENCY_CODE                 denom_currency_code ,
  rcv_txn.CURRENCY_CONVERSION_DATE      ,
  rcv_txn.CURRENCY_CONVERSION_TYPE      ,
  rcv_txn.CURRENCY_CONVERSION_RATE      ,
  trunc(rcv_txn.TRANSACTION_DATE)              GL_Date,
  rcv_txn.DESTINATION_TYPE_CODE         ,
  rcv_sub.pa_addition_flag              ,
  rcv_txn.transaction_type              trx_type,
  nvl(rcv_txn.project_id , po_dist.project_id) project_id,   /* Bug 6989609 : Added NVL */
  nvl(rcv_txn.task_id , po_dist.task_id) task_id,            /* Bug 6989609 : Added NVL */
  VEND.employee_id                   employee_id, /* Removed NVL for 3297771 */
  po_dist.expenditure_type,
  PA_AP_INTEGRATION.get_si_cost_exp_item_date(
                                               rcv_txn.transaction_date,
                                               rcv_sub.accounting_date,
					       po_dist.expenditure_item_date,
                                               rcv_txn.creation_date,
                                               NULL,
                                              'RECEIPT'
                                             ) expenditure_item_date,
  VEND.vendor_id                        vendor_id,
  po_dist.EXPENDITURE_ORGANIZATION_ID   expenditure_organization_id,
  Decode( nvl(VEND.employee_id, 0),0,NULL, PA_UTILS.GetEmpJobId(VEND.employee_id,po_DIST.Expenditure_Item_Date))                Job_id,
  po_line.ITEM_DESCRIPTION            description,
  po_dist.attribute_category,
  po_dist.attribute1,
  po_dist.attribute2,
  po_dist.attribute3,
  po_dist.attribute4,
  po_dist.attribute5,
  po_dist.attribute6,
  po_dist.attribute7,
  po_dist.attribute8,
  po_dist.attribute9,
  po_dist.attribute10,
  po_dist.ORG_ID
  ,l_cdl_system_reference4
  ,l_txn_src
  ,l_user_txn_src
  ,l_batch_name
  ,l_interface_id
  ,l_exp_end_date
  ,l_txn_status_code
  ,l_txn_rej_code
  ,l_bus_grp_id
  ,l_insert_flag
  ,rcv_sub.accounting_event_id acct_evt_id                       -- pricing changes
  ,rcv_sub.accounted_rec_tax
  ,rcv_sub.entered_rec_tax
  ,rcv_txn.parent_transaction_id --NEW --added for the full retrn logic
  ,l_net_zero_flag
  ,l_sc_xfer_code
  ,rcv_txn.amount  --NEW --added for the full retrn logic
  ,l_adj_exp_item_id
  ,Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(nvl(rcv_txn.project_id , po_dist.project_id), 'STD') fc_enabled   /* Bug 6989609 : Added NVL */
  , nvl(rcv_txn.currency_conversion_date, rcv_txn.transaction_date)
  ,'ALL' fc_document_type
  ,'Y' si_assets_addition_flag
  ,'Y' insert_flag
  ,rcv_sub.rcv_sub_ledger_id
  ,type.cost_rate_flag
from rcv_transactions rcv_txn,
     rcv_receiving_sub_ledger rcv_sub,
     po_headers_all  po_head,
     po_lines_all po_line,
     po_distributions_all po_dist,
     po_vendors vend,
     pa_expenditure_types type
   where ((rcv_txn.destination_type_code ='EXPENSE' )  OR
          (rcv_txn.destination_type_code='RECEIVING' AND
           (rcv_txn.transaction_type IN ('RETURN TO VENDOR','RETURN TO RECEIVING'))
          )
         )
     AND po_dist.CODE_COMBINATION_ID   =rcv_sub.CODE_COMBINATION_ID
     AND rcv_sub.ACTUAL_FLAG           = 'A'
     AND rcv_sub.pa_addition_flag IN ('O','J')                   -- pricing changes
     AND nvl(po_dist.distribution_type,'XXX') <> 'PREPAYMENT'    -- bug 7192304
     AND rcv_sub.request_id=G_REQUEST_ID
     AND po_dist.project_ID IS NOT NULL
     AND po_dist.accrue_on_receipt_flag= 'Y'
     AND rcv_txn.transaction_id=rcv_sub.rcv_transaction_id
     AND rcv_txn.po_header_id=po_head.PO_HEADER_ID
     AND po_head.po_header_id=po_line.po_header_id
     AND po_line.po_line_id=po_dist.po_line_id
     AND rcv_txn.PO_DISTRIBUTION_ID=po_dist.po_distribution_id
     AND po_head.org_id=G_ORG_ID
     AND po_head.vendor_id=VEND.Vendor_Id
     AND po_dist.expenditure_type = type.expenditure_type
     AND (pa_nl_installed.is_nl_installed = 'N'
     OR ( pa_nl_installed.is_nl_installed = 'Y'
          AND  NOT EXISTS (SELECT 'X'
                           FROM  mtl_system_items si,
                                 po_lines_all pol
                           WHERE po_line.po_line_id = pol.po_line_id
                           AND   si.inventory_item_id = pol.item_id
                           AND   si.comms_nl_trackable_flag = 'Y')
        ) )
     order by rcv_txn.po_distribution_id;

   PROCEDURE mark_RCV_PAflag;

   PROCEDURE transfer_receipts_to_pa;

   PROCEDURE tieback_rcv_Txn (
      p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
      p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
      p_interface_id IN pa_transaction_interface.interface_id%TYPE);

   PROCEDURE check_failed_receipts (
      p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
      p_interface_id IN pa_transaction_interface.interface_id%TYPE);

   PROCEDURE lock_ap_invoice (p_po_distribution_id IN ap_invoice_distributions.po_distribution_id%TYPE);

   PROCEDURE tieback_locked_invoice;

   /*==========================================================*/
   /*Declarations for Invoice Variance processing*/
   /* This cursor is opened only for amount based variances */
   /*==========================================================*/

   CURSOR Invoice_Variance_Cur IS
    SELECT INV.Invoice_id invoice_id,
           DIST.Invoice_distribution_id,
           DIST.Invoice_Line_Number Invoice_Line_Number,
           DIST.Project_id project_id,
           DIST.Task_id task_id,
           DIST.line_type_lookup_code,
           DIST.Expenditure_type expenditure_type,
           to_char(DIST.Expenditure_Item_Date, 'DD-MON-RR') expenditure_item_date,
           nvl(DIST.base_amount_variance,DIST.amount_variance) amount,
           DIST.description description,
           DIST.dist_code_combination_id dist_code_combination_id,
           DIST.expenditure_organization_id expenditure_organization_id,
           DIST.amount_variance quantity,
    --       L_pay_code_combination_id  accts_pay_code_combination_id,
           DIST.accounting_date gl_date,
           DIST.attribute_category,
           DIST.attribute1,
           DIST.attribute2,
           DIST.attribute3,
           DIST.attribute4,
           DIST.attribute5,
           DIST.attribute6,
           DIST.attribute7,
           DIST.attribute8,
           DIST.attribute9,
           DIST.attribute10,
           DIST.amount_variance denom_raw_cost,
           INV.invoice_currency_code denom_currency_code,
           INV.exchange_date acct_rate_date,
           INV.exchange_rate_type acct_rate_type,
           INV.exchange_rate acct_exchange_rate,
           Decode(nvl(VEND.employee_id, 0),0,NULL,
                  PA_UTILS.GetEmpJobId( VEND.employee_id,DIST.Expenditure_Item_Date)) Job_id,
           VEND.employee_id employee_id,
           VEND.vendor_id vendor_id,
           INV.invoice_type_lookup_code,
           INV.source,
           INV.org_id,
           INV.invoice_num invoice_number,
           'IPV'                              cdl_system_reference4
--           'IPV'
           ,l_txn_src
           ,l_user_txn_src
           ,l_batch_name
           ,l_interface_id
           ,l_exp_end_date
           ,l_txn_status_code
           ,l_txn_rej_code
           ,l_bus_grp_id
           --,l_insert_flag
           ,nvl(DIST.reversal_flag,'N') reversal_flag          --NEW
           ,nvl(DIST.cancellation_flag,'N') cancellation_flag --NEW
           ,DIST.parent_reversal_id parent_reversal_id  --NEW
           ,l_net_zero_flag
           ,l_sc_xfer_code
           ,l_adj_exp_item_id
           ,Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(DIST.project_id, 'STD') fc_enabled
           ,nvl(DIST.exchange_date, INV.invoice_date) mrc_exchange_date
           ,'CMT' fc_document_type
           ,'Y' si_assets_addition_flag
           ,'Y' insert_flag
      FROM PO_Vendors VEND,
           AP_Invoices_all INV,
           PA_Transfer_AP_Invoices_View DIST
     WHERE DIST.Invoice_Id = INV.Invoice_Id
       AND DIST.Pa_Addition_Flag = 'W'
       AND INV.Vendor_Id = VEND.Vendor_Id
       AND DIST.request_id = G_REQUEST_ID
     ORDER BY INV.invoice_id
               ,DIST.invoice_distribution_id
     ;

   PROCEDURE mark_inv_var_paflag;

   PROCEDURE transfer_inv_var_to_pa;

   PROCEDURE tieback_invoice_variances (
      p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
      p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
      p_interface_id IN pa_transaction_interface.interface_id%TYPE);

   /* Added for Bug#3193740 */
   FUNCTION increment_W_count(W_flag IN VARCHAR2)
   RETURN VARCHAR2 ;

--    FUNCTION get_inv_amt_var(p_invoice_id in NUMBER,p_inv_dist_line_num in NUMBER)
--    RETURN NUMBER;

   FUNCTION get_cdl_ccid(p_expenditure_item_id NUMBER, ccid_flag varchar2)
   RETURN NUMBER;


   /*===================================*/
   /*Declarations for payment processing*/
   /*===================================*/

   CURSOR Payments_Cur IS
    SELECT Pay.Invoice_Payment_Id,
           INV.Invoice_id invoice_id,
           INV.created_by created_by,
           DIST.Invoice_distribution_id Invoice_distribution_id, --NEW
           DIST.Invoice_Line_Number Invoice_Line_Number,
           DIST.Project_id project_id,
           DIST.Task_id task_id,
           DIST.line_type_lookup_code,
           DIST.Expenditure_type expenditure_type,
           CASE WHEN inv.invoice_type_lookup_code = 'EXPENSE REPORT' THEN
           DIST.Expenditure_Item_Date
           ELSE
           PA_AP_INTEGRATION.get_si_cost_exp_item_date(
                                                      chk.check_date,
                                                      pay.accounting_date,
						      dist.expenditure_item_date,
                                                      pay.creation_date,
                                                      NULL,
                                                     'PAYMENT'
                                                      )
           END expenditure_item_date,
           nvl(paydist.paid_base_amount,payDIST.amount) amount,
           DIST.description description,
           DIST.justification,
           DIST.dist_code_combination_id dist_code_combination_id,
           DIST.expenditure_organization_id expenditure_organization_id,
           decode(DIST.line_type_lookup_code,'ERV',null,'IPV',null,
                  nvl(nvl(DECODE(TYPE.Cost_Rate_Flag, 'Y', (DIST.PA_Quantity * (PAYDIST.Paid_base_amount/PAYDIST.invoice_dist_base_amount)),
                  PAYDIST.Amount), PAYDIST.amount),0)) quantity,
           L_pay_code_combination_id  accts_pay_code_combination_id,
           PAY.accounting_date gl_date,
           DIST.attribute_category,
           DIST.attribute1,
           DIST.attribute2,
           DIST.attribute3,
           DIST.attribute4,
           DIST.attribute5,
           DIST.attribute6,
           DIST.attribute7,
           DIST.attribute8,
           DIST.attribute9,
           DIST.attribute10,
           /* MC Upgrade */
           DIST.receipt_currency_amount,
           DIST.receipt_currency_code,
           DIST.receipt_conversion_rate,
           PAYDIST.amount denom_raw_cost,
           INV.payment_currency_code denom_currency_code,
           pay.exchange_date acct_rate_date,
           pay.exchange_rate_type acct_rate_type,
           pay.exchange_rate acct_exchange_rate,
           Decode(nvl(VEND.employee_id, 0),0,NULL,
                  PA_UTILS.GetEmpJobId( VEND.employee_id,DIST.Expenditure_Item_Date)) Job_id,
           VEND.employee_id employee_id,
           VEND.vendor_id vendor_id,
           /*DFF: Upgrade to call client extension*/
           INV.invoice_type_lookup_code,
           INV.source,
           INV.org_id
           ,INV.invoice_num invoice_number
           ,l_cdl_system_reference4            cdl_system_reference4
           ,DIST.po_distribution_id            po_distribution_id
           /*added the following dummy columns for pl/sql table upgrade*/
           ,l_txn_src
           ,l_user_txn_src
           ,l_batch_name
           ,l_interface_id
           ,l_exp_end_date
           ,l_txn_status_code
           ,l_txn_rej_code
           ,l_bus_grp_id
           ,inv.paid_on_behalf_employee_id
           /* IC Upgrade: Create a column which is used to group transactions
              by their invoice sources */
           ,DECODE(INV.source, 'Inter-Project Invoices', 1,
                  'Projects Intercompany Invoices',2, 3) sort_c
           --,nvl(PAY.reversal_flag,'N') reversal_flag          --NEW
           ,DECODE(nvl(PAY.reversal_flag,'N'),'N',decode(nvl(DIST.reversal_flag,'N'),'Y','R','N'),PAY.reversal_flag) reversal_flag --Bug5408748
           ,l_cancel_flag cancel_flag
           --,PAY.REVERSAL_INV_PMT_ID REVERSAL_INV_PMT_ID  --NEW
           ,DECODE(PAY.REVERSAL_INV_PMT_ID,null,decode(nvl(PAY.reversal_flag,'N'),'N',DIST.parent_reversal_id),PAY.REVERSAL_INV_PMT_ID) REVERSAL_INV_PMT_ID  --NEW
           ,l_net_zero_flag
           ,l_sc_xfer_code
           ,l_adj_exp_item_id
           ,Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(DIST.project_id, 'STD') fc_enabled
           ,nvl(DIST.exchange_date, INV.invoice_date) mrc_exchange_date
           ,'ALL' fc_document_type
           ,inv.PAYMENT_STATUS_FLAG
           ,'Y' si_assets_addition_flag
           ,'Y' insert_flag
           , paydist.payment_hist_dist_id
           , l_PRepay_dist_id
      FROM AP_Invoice_Payments Pay,
           ap_payment_hist_dists Paydist,
           PO_Vendors VEND,
           AP_Invoices INV,
           Ap_Invoice_Distributions DIST,
           PA_EXPENDITURE_TYPES TYPE,
           ap_checks chk
     WHERE DIST.Invoice_Id = INV.Invoice_Id
     AND   Pay.Invoice_Payment_Id = Paydist.Invoice_payment_id
     AND   Pay.check_id  = chk.check_id
     AND   paydist.pay_dist_lookup_code = 'CASH'
     AND   Paydist.invoice_distribution_id = DIST.invoice_distribution_id
     AND   PayDIST.Pa_Addition_Flag = 'O'
     AND   INV.Vendor_Id = VEND.Vendor_Id
     AND   PAYDIST.request_id = G_REQUEST_ID
     AND   DIST.expenditure_type = TYPE.expenditure_type
     ORDER BY INV.invoice_id, DIST.Invoice_Distribution_Id, PAY.invoice_payment_id;



   /*==================================================================*/
   /* Cursor for Prepayment Application Processing for Cash Basis Acctn*/
   /*==================================================================*/

    CURSOR  prepay_cur IS
    SELECT  INV.Invoice_id invoice_id,
      INV.created_by created_by,
      PDIST.Invoice_distribution_id Invoice_distribution_id, --NEW
      DIST1.Invoice_Line_Number Invoice_Line_Number,
      DIST1.Project_id project_id,
      DIST1.Task_id task_id,
      decode(DIST1.line_type_lookup_code,'ITEM','PREPAY','ACCRUAL','PREPAY', DIST1.line_type_lookup_code) line_type_lookup_code,
      --changed the source of line-type-lookup-code to process dta prorated for rec tax
     -- DIST2.line_type_lookup_code, --PREPAY
      DIST1.Expenditure_type expenditure_type,
      to_char(DIST1.Expenditure_Item_Date, 'DD-MON-RR') expenditure_item_date,
      (nvl(PDIST.base_amount,PDIST.amount) * -1)  amount,
      DIST2.description description,
      DIST2.justification,
      DIST1.dist_code_combination_id dist_code_combination_id,
      DIST1.expenditure_organization_id expenditure_organization_id,
      decode(DIST1.line_type_lookup_code,'ERV',null,'IPV',null,
      nvl(nvl(DECODE(TYPE.Cost_Rate_Flag,'Y', (DIST1.PA_Quantity * (nvl(PDIST.amount,0)/nvl(DIST1.amount,0))),NVL(PDIST.Amount,PDIST.Base_Amount) * -1),
                                            nvl( PDIST.amount,PDIST.base_amount ) * -1),0)) quantity, --removed the  negitive amount for bug 5514129
      L_pay_code_combination_id  accts_pay_code_combination_id,
      DIST2.accounting_date gl_date,
      DIST1.attribute_category,
      DIST1.attribute1,
      DIST1.attribute2,
      DIST1.attribute3,
      DIST1.attribute4,
      DIST1.attribute5,
      DIST1.attribute6,
      DIST1.attribute7,
      DIST1.attribute8,
      DIST1.attribute9,
      DIST1.attribute10, /* MC Upgrade */
      DIST1.receipt_currency_amount,
      DIST1.receipt_currency_code,
      DIST1.receipt_conversion_rate,
      (nvl(PDIST.amount,0) * -1) denom_raw_cost,
      INV.invoice_currency_code denom_currency_code,
      INV.exchange_date acct_rate_date,
      INV.exchange_rate_type acct_rate_type,
      INV.exchange_rate acct_exchange_rate,
      Decode(nvl(VEND.employee_id, 0),0,NULL,
               PA_UTILS.GetEmpJobId( VEND.employee_id,DIST1.Expenditure_Item_Date)) Job_id,
      VEND.employee_id employee_id,
      VEND.vendor_id vendor_id,
      INV.invoice_type_lookup_code,
      INV.source,
      INV.org_id ,
      INV.invoice_num invoice_number ,
      PDIST.prepay_app_dist_id cdl_system_reference4 ,
      DIST1.po_distribution_id po_distribution_id /*added the following dummy columns for pl/sql table upgrade*/ ,
      l_txn_src        ,
      l_user_txn_src ,
      l_batch_name  ,
      l_interface_id  ,
      l_exp_end_date ,
      l_txn_status_code ,
      l_txn_rej_code ,
      l_bus_grp_id ,
      inv.paid_on_behalf_employee_id,
      DECODE(INV.source, 'Inter-Project Invoices', 1, 'Projects Intercompany Invoices',2, 3) sort_c ,
      nvl(DIST2.reversal_flag,'N') reversal_flag
      ,nvl(DIST2.cancellation_flag,'N') cancellation_flag --NEW  ??
      ,PDIST.reversed_prepay_app_dist_id  parent_reversal_id  --NEW
      ,l_net_zero_flag
      ,l_sc_xfer_code
      ,l_adj_exp_item_id
      ,Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(DIST1.project_id, 'STD') fc_enabled
      ,nvl(DIST2.exchange_date, INV.invoice_date) mrc_exchange_date
      ,'ALL' fc_document_type
      ,'Y' si_assets_addition_flag
      ,'Y' insert_flag
      ,l_pay_hist_id
      ,DIST2.PRepay_distribution_id PRepay_distribution_id
      FROM PO_Vendors VEND,
           AP_Invoices INV,
           AP_Prepay_APP_Dists PDIST,
           AP_INVOICE_DISTRIBUTIONS DIST1,
           AP_INVOICE_DISTRIBUTIONS DIST2,
           -- changed from view to table to process the rec tax part of prorated prepay appl for bug#5514129
           --PA_Transfer_AP_Invoices_View DIST1,
          -- PA_Transfer_AP_Invoices_View DIST2,
           PA_EXPENDITURE_TYPES TYPE
     WHERE DIST1.Invoice_Id = INV.Invoice_Id
       AND DIST1.invoice_distribution_id = PDIST.invoice_distribution_id  -- Std inv line to which Prepay is applied
       AND DIST2.invoice_id = DIST1.invoice_id
       AND DIST2.invoice_distribution_id =  PDIST.prepay_app_distribution_id --Prepay appl line
       --AND DIST2.line_type_lookup_code in ( 'PREPAY','NONREC_TAX')
       AND DIST1.line_type_lookup_code <> 'REC_TAX' --bug#5514129
       AND PDIST.Pa_Addition_Flag = 'O'
       AND INV.Vendor_Id = VEND.Vendor_Id
       AND PDIST.request_id = G_REQUEST_ID
       AND DIST1.expenditure_type = TYPE.expenditure_type
     ORDER BY sort_c, INV.invoice_id,DIST1.Invoice_distribution_id;


   PROCEDURE mark_PA_Pay_flag_O;


   PROCEDURE net_zero_pay_adjustment;

   PROCEDURE transfer_pay_to_pa;

   PROCEDURE tieback_payment_AP_ER (
      p_transaction_source IN pa_transaction_interface.transaction_source%TYPE,
      p_batch_name  IN pa_transaction_interface.batch_name%TYPE,
      p_batch_type IN Varchar2,
      p_interface_id IN pa_transaction_interface.interface_id%TYPE);

   FUNCTION check_prepay_fully_applied(p_prepay_dist_id in NUMBER)
   RETURN VARCHAR2;

   PROCEDURE process_adjustments (p_record_type                 IN Varchar2,
                                  p_document_header_id          IN number, /*Added this for 6945767 */
                                  p_document_distribution_id    IN number,
                                  p_document_payment_id         IN number DEFAULT NULL,
                                  p_current_index               IN number,
                                  p_last_index                  IN OUT NOCOPY number) ;

   -- Check discount method
   FUNCTION return_discount_method RETURN VARCHAR2;

END PAAPIMP_PKG;

/

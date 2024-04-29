--------------------------------------------------------
--  DDL for Package Body PA_TRX_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TRX_IMPORT" AS
/* $Header: PAXTTRXB.pls 120.78.12010000.22 2010/03/12 05:36:55 abjacob ship $ */

  last_empno       VARCHAR2(30)  DEFAULT NULL;
  last_proj        VARCHAR2(25)  DEFAULT NULL;
  last_task        VARCHAR2(25)  DEFAULT NULL;
  last_etype       VARCHAR2(30)  DEFAULT NULL;
  current_expend   VARCHAR2(2000) DEFAULT NULL;
  current_expend2  VARCHAR2(2000) DEFAULT NULL;
  current_period   DATE		 DEFAULT NULL;


  current_system_linkage   VARCHAR2(30) DEFAULT NULL;

  G_trx_source     VARCHAR2(30)  DEFAULT NULL;
  G_eclass         VARCHAR2(30)  DEFAULT NULL;
  G_trx_link       VARCHAR2(30)  DEFAULT NULL;
  G_trx_costed     VARCHAR2(1)   DEFAULT NULL;
  G_trx_start      DATE          DEFAULT NULL;
  G_trx_end        DATE          DEFAULT NULL;
  G_emp_org_oride  VARCHAR2(1)   DEFAULT NULL;

  G_trx_predef_flag     VARCHAR2(1)   DEFAULT NULL;
  G_allow_adj_flag      VARCHAR2(1)   DEFAULT NULL;
  G_gl_accted_flag      VARCHAR2(1)   DEFAULT NULL;
  G_allow_dup_flag      VARCHAR2(1)   DEFAULT NULL;
  /* G_skip_tc_flag        VARCHAR2(1)   DEFAULT NULL;
     Removed for bug 1299909 as this has been moved to sepcs of this package. */
  G_burdened_flag       VARCHAR2(1)   DEFAULT NULL;

  G_etype_link     VARCHAR2(30)  DEFAULT NULL;
  G_etype_start    DATE          DEFAULT NULL;
  G_etype_end      DATE          DEFAULT NULL;
  G_etype_cr	    NUMBER(22,5)  DEFAULT 1;
  G_etype_cost_rate_flag VARCHAR2(1) DEFAULT NULL;

  G_etype_active   BOOLEAN       DEFAULT FALSE ;
  G_etec_start     DATE          DEFAULT NULL  ;
  G_etec_end       DATE          DEFAULT NULL  ;
  G_etype_labor_flag  VARCHAR2(1)   DEFAULT NULL;

  G_person_id      NUMBER(15)    DEFAULT NULL;
  G_org_id         NUMBER(15)    DEFAULT NULL;
  G_job_id         NUMBER(15)    DEFAULT NULL;
  G_task_id        NUMBER(15)    DEFAULT NULL;
  G_project_id     NUMBER(15)    DEFAULT NULL;
  G_adj_item_id    NUMBER(15)    DEFAULT NULL;
  G_user           NUMBER(15)    DEFAULT NULL;

  G_Proj_bcost_flag  VARCHAR2(1) DEFAULT NULL ;

  G_nlro_id        NUMBER(15)    DEFAULT NULL;
  G_nlr_etype      VARCHAR2(30)  DEFAULT NULL;
  G_nlr_start      DATE          DEFAULT NULL;
  G_nlr_end        DATE          DEFAULT NULL;
  G_nlro_start     DATE          DEFAULT NULL;
  G_nlro_end       DATE          DEFAULT NULL;

  G_lcm            VARCHAR2(20)  DEFAULT NULL;
  G_burden_compile_set_id  	    NUMBER DEFAULT NULL;
  G_compiled_multiplier             NUMBER := 0;

  -- 5235363   R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
  --
  g_paapimp_validate_dt    varchar2(1) := 'Y' ;

  -- MC Changes
  G_accounting_currency_code VARCHAR2(15) DEFAULT NULL;
  G_allow_acct_user_rate  VARCHAR2(1) DEFAULT NULL;
  G_allow_foreign_curr_txn VARCHAR2(1) DEFAULT NULL;
  G_allow_proj_user_rate  VARCHAR2(1) DEFAULT NULL;
  G_allow_copy_acct_cost_flag    VARCHAR2(1) DEFAULT NULL;
  G_project_currency_code	 VARCHAR2(15) DEFAULT NULL;
  G_default_rate_type VARCHAR2(30)  DEFAULT NULL;
  G_proj_rate_date DATE		 DEFAULT NULL;
  G_project_rate_type gl_daily_conversion_types.conversion_type%TYPE
                          DEFAULT NULL;
  G_acct_rate_type gl_daily_conversion_types.conversion_type%TYPE DEFAULT NULL;
  G_raw_cost       NUMBER        DEFAULT NULL;

  /* Trx_Import Enhancement */
  G_override_to_org_id  NUMBER   DEFAULT NULL;
  /*G_orig_exp_txn_reference1 VARCHAR2(30) DEFAULT NULL;
  G_orig_user_exp_txn_reference VARCHAR2(30) DEFAULT NULL;  */
  /* Size of the two variables commented above have been modified to varchar2(60) as fix for bug 1504289*/
  G_orig_exp_txn_reference1 VARCHAR2(60) DEFAULT NULL;
  G_orig_user_exp_txn_reference VARCHAR2(60) DEFAULT NULL;
  G_vendor_id		NUMBER DEFAULT NULL;
  G_Vendor_Site_id  NUMBER DEFAULT NULL;
  G_previous_vendor_number VARCHAR2(30) DEFAULT NULL;
  G_orig_exp_txn_reference2 VARCHAR2(60) DEFAULT NULL;
  G_orig_exp_txn_reference3 VARCHAR2(60) DEFAULT NULL;
  /* End of Enhancment      */

  X_ei_id          NUMBER(15)    DEFAULT NULL;

  G_CDL_SYSTEM_REFERENCE2      NUMBER;
  G_CDL_SYSTEM_REFERENCE3      NUMBER;
  G_CDL_SYSTEM_REFERENCE4      pa_transaction_interface_all.cdl_system_reference4%TYPE; --2339216-apdisc; Commented for bug 4281765
  /* REL12-AP Lines uptake
  ** Support for cdl_system_reference5
  ** cdl_system_reference5 to store invoice distribution ID
  */
  G_CDL_SYSTEM_REFERENCE5      NUMBER;
  G_MOAC_ORG_ID                NUMBER ;


  -- SST changes: New global variables
  G_pre_processing_extn    pa_transaction_sources.pre_processing_extension%TYPE
                            DEFAULT NULL;
  G_post_processing_extn   pa_transaction_sources.post_processing_extension%TYPE
                            DEFAULT NULL;

  G_reversed_orig_txn_reference PA_TRANSACTION_INTERFACE_ALL.reversed_orig_txn_reference%TYPE;

  /* Bug 4107560 */
  G_prev_ORIG_TRAN_REF	PA_TRANSACTION_INTERFACE_ALL.ORIG_TRANSACTION_REFERENCE%TYPE;
  G_WIP_RESOURCE_ID					PA_TRANSACTION_INTERFACE_ALL.WIP_RESOURCE_ID%TYPE;


  G_project_type_class     PA_PROJECT_TYPES_ALL.PROJECT_TYPE_CLASS_CODE%TYPE;
  /* added for the bug# 1428216, starts here */
  G_burden_amt_display_method     PA_PROJECT_TYPES_ALL.BURDEN_AMT_DISPLAY_METHOD%TYPE;
  /* added for the bug# 1428216, ends here */
  -- End SST Changes

  -- IC Changes
  G_CrossChargeType      pa_expenditure_items_all.cc_cross_charge_type%TYPE;
  G_CrossChargeCode      pa_expenditure_items_all.cc_cross_charge_code%TYPE;
  G_PrvdrOrganizationId  hr_organization_units.organization_id%TYPE;
  G_RecvrOrganizationId  hr_organization_units.organization_id%TYPE;
  G_RecvrOrgId           hr_organization_units.organization_id%TYPE;
  G_BrowLentDistCode     pa_expenditure_items_all.cc_bl_distributed_code%TYPE;
  G_IcProcessed_Code     pa_expenditure_items_all.cc_ic_processed_code%TYPE;
  -- END IC Changes
  current_etype_classcode    VARCHAR2(100) DEFAULT NULL;

  -- Oct 2001 Enhanced Period Processing
  -- Start EPP Changes
  G_PaDate              pa_cost_distribution_lines_all.pa_date%TYPE;
  G_PaPeriodName        pa_cost_distribution_lines_all.pa_period_name%TYPE;
  G_RecvrPaDate         pa_cost_distribution_lines_all.recvr_pa_date%TYPE;
  G_RecvrPaPeriodName   pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE;
  G_GlPeriodName        pa_cost_distribution_lines_all.gl_period_name%TYPE;
  G_RecvrGlDate         pa_cost_distribution_lines_all.recvr_gl_date%TYPE;
  G_RecvrGlPeriodName   pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE;
  G_SobId               pa_implementations_all.set_of_books_id%TYPE;
  G_RecvrSobId          pa_implementations_all.set_of_books_id%TYPE;
 -- G_FSIO_ENABLED        varchar2(1);  --FSIO Changes

  Prev_SobId      NUMBER;
  Prev_OrgID      NUMBER;
  Prev_RecvrSobId NUMBER;
  Prev_RecvrOrgID NUMBER;
  -- End EPP Changes

  --Start PA-I Changes
  G_projfunc_cost_rate_type gl_daily_conversion_types.conversion_type%TYPE  DEFAULT NULL;
  G_Assignment_Id NUMBER;
  G_Work_Type_Id  NUMBER;
  G_Tp_Amt_Type_Code VARCHAR2(30);
  --End PA-I Changes

  --Start PA-J Period-End Accrual Changes
  G_GlDate           DATE;
  G_AccDate          DATE;
  G_RecvrAccDate     DATE;
  G_RevAccDate       DATE;
  G_RevRecvrAccDate  DATE;
  G_RevPaDate        pa_cost_distribution_lines_all.pa_date%TYPE;
  G_RevPaPeriodName  pa_cost_distribution_lines_all.pa_period_name%TYPE;
  G_RevGlDate        pa_cost_distribution_lines_all.gl_date%TYPE;
  G_RevGlPeriodName  pa_cost_distribution_lines_all.gl_period_name%TYPE;
  G_RevRecvrPaDate   pa_cost_distribution_lines_all.recvr_pa_date%TYPE;
  G_RevRecvrPaPdName pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE;
  G_RevRecvrGlDate   pa_cost_distribution_lines_all.recvr_gl_date%TYPE;
  G_RevRecvrGlPdName pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE;
  --End PA-J Period-End Accrual Changes

  --Start PA-K Changes
  G_Process_Funds_Flag  VARCHAR2(1);
  l_Expend1             VARCHAR2(2000) DEFAULT NULL;
  l_Expend2             VARCHAR2(2000) DEFAULT NULL;
  G_Group_Name          VARCHAR2(240); /* Bug#2373198 Increased size from 80 to 240 */

  G_MOrg                VARCHAR2(1);
  G_PrjInfoPrjId        NUMBER;
  G_PrjInfoBCostFlag    VARCHAR2(1);
  G_PrjInfoTypeClass    PA_PROJECT_TYPES_ALL.PROJECT_TYPE_CLASS_CODE%TYPE;
  G_PrjInfoBdDisplay    PA_PROJECT_TYPES_ALL.BURDEN_AMT_DISPLAY_METHOD%TYPE;
  G_PrjInfoTotBdFlag    PA_PROJECT_TYPES_ALL.TOTAL_BURDEN_FLAG%TYPE;
  G_NewTxnPrjId         NUMBER;
  --G_NewTxnsAllowed      VARCHAR2(1);
  G_EClassInfoEtype     VARCHAR2(30);
  /* bug #3134359 changed the size of G_EClassInfoSysLink to 30 from 3
     as this is the size allowed in the base table pa_system_linkages.function,
     size 30 is allowed in the front end also,ideally this should work with 3
     if the values are from lookup */
  --G_EClassInfoSysLink   VARCHAR2(3);
  G_EClassInfoSysLink   VARCHAR2(30);
  G_ETypeInfoEtype      VARCHAR2(30);
  G_ETypeInfoDate       DATE;
  G_NlrInfoNlr          VARCHAR2(20);
  G_NlrInfoNlroId       NUMBER;
  G_CurrInfoPrjCurrCode  VARCHAR2(15);
  G_CurrInfoPrjRtType    VARCHAR2(30);
  G_CurrInfoPrjFCurrCode VARCHAR2(15);
  G_CurrInfoPrjFRtType   VARCHAR2(30);
  G_CurrInfoTaskId       NUMBER;
  G_OrgNameEmpNum        VARCHAR2(30);
  G_OrgNameDate          DATE;
  G_OrgNameOrgName       hr_all_organization_units.name%TYPE;
  G_OrgNameBGName        hr_all_organization_units.name%TYPE;
  G_OrgNameBGId          NUMBER;
  G_PrevCCID             NUMBER;
  G_PrevRetVal           NUMBER;
  G_Total_Burden_Flag    VARCHAR2(1);

  G_Debug_Mode           VARCHAR2(1) ;

  --added variable for cost blue-print project
  G_gl_posted_flag VARCHAR2(1)   DEFAULT NULL;

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  P_BTC_SRC_RESRC varchar2(1) := NVL(FND_PROFILE.value('PA_RPT_BTC_SRC_RESRC'), 'N'); -- 4057874

-- R12 funds management uptake : Below global variables stores adjusting expenditures data
-- which will be accessed by fundscheck autonomous API's

g_xface_project_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;
g_xface_task_id_tbl             PA_PLSQL_DATATYPES.IdTabTyp;
g_xface_exp_type_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
g_xface_ei_date_tbl             PA_PLSQL_DATATYPES.DateTabTyp;
g_xface_exp_org_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;
g_xface_bud_ver_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;
g_xface_Entered_Cr_tbl          PA_PLSQL_DATATYPES.NumTabTyp;
g_xface_Entered_Dr_tbl          PA_PLSQL_DATATYPES.NumTabTyp;
g_xface_acct_Cr_tbl             PA_PLSQL_DATATYPES.NumTabTyp;
g_xface_acct_Dr_tbl             PA_PLSQL_DATATYPES.NumTabTyp;
g_xface_Txn_Ccid_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
g_xface_org_id_tbl              PA_PLSQL_DATATYPES.IdTabTyp;
g_xface_Txn_interface_tbl       PA_PLSQL_DATATYPES.IdTabTyp;


g_sob_Id_tbl              PA_PLSQL_DATATYPES.IdTabTyp;
g_Period_Year_tbl         PA_PLSQL_DATATYPES.NumTabTyp;
g_project_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;
g_task_id_tbl             PA_PLSQL_DATATYPES.IdTabTyp;
g_exp_type_tbl            PA_PLSQL_DATATYPES.Char30TabTyp;
g_ei_date_tbl             PA_PLSQL_DATATYPES.DateTabTyp;
g_exp_org_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;
g_bud_ver_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;
g_budget_line_id_tbl      PA_PLSQL_DATATYPES.IdTabTyp;  -- R12 Funds Management uptake
g_Document_Type_tbl       PA_PLSQL_DATATYPES.Char10TabTyp;
g_Doc_Header_Id_tbl       PA_PLSQL_DATATYPES.IdTabTyp;
g_Doc_dist_Id_tbl         PA_PLSQL_DATATYPES.IdTabTyp;
g_Entered_Cr_tbl          PA_PLSQL_DATATYPES.NumTabTyp;
g_Entered_Dr_tbl          PA_PLSQL_DATATYPES.NumTabTyp;
g_acct_Cr_tbl             PA_PLSQL_DATATYPES.NumTabTyp;
g_acct_Dr_tbl             PA_PLSQL_DATATYPES.NumTabTyp;
g_Actual_Flag_tbl         PA_PLSQL_DATATYPES.Char1TabTyp;
g_Txn_Ccid_tbl            PA_PLSQL_DATATYPES.IdTabTyp;
g_Je_Catg_Name_tbl        PA_PLSQL_DATATYPES.Char30TabTyp;
g_Je_sorce_Name_tbl       PA_PLSQL_DATATYPES.Char30TabTyp;
g_org_id_tbl              PA_PLSQL_DATATYPES.IdTabTyp;
g_Pa_Date_tbl             PA_PLSQL_DATATYPES.DateTabTyp;
g_packet_id_tbl           PA_PLSQL_DATATYPES.IdTabTyp;
g_bc_packet_id_tbl        PA_PLSQL_DATATYPES.IdTabTyp;
g_bc_parent_pkt_id_tbl    PA_PLSQL_DATATYPES.IdTabTyp;
g_enc_type_id_tbl         PA_PLSQL_DATATYPES.IdTabTyp;
g_doc_hdr_id_2_tbl        PA_PLSQL_DATATYPES.IdTabTyp;
g_doc_dist_type_tbl       PA_PLSQL_DATATYPES.Char30TabTyp;
g_bc_comt_id_tbl          PA_PLSQL_DATATYPES.IdTabTyp;


-- R12 funds management uptake : End

PROCEDURE log_message(p_message in VARCHAR2, p_mode in NUMBER DEFAULT 0);

  --End PA-K Changes

  --Bug 2905892
  G_FC_Gl_Date      DATE;
  G_FC_Period_Name  pa_bc_packets.period_name%Type;
  G_FC_Period_Year  pa_bc_packets.period_year%type; --REL12
  G_PrevFCGLDate    DATE;
  G_PrevFCPdName    pa_bc_packets.period_name%Type;

  PROCEDURE tr_import_funds_check (p_pa_date               IN  DATE,
                                   p_txn_source            IN VARCHAR2,
                                   p_acct_raw_cost         IN NUMBER,
				   p_adj_exp_item_id       IN NUMBER,
				   p_txn_interface_id      IN NUMBER,
				   p_fc_document_type      IN VARCHAR2,
                                   x_packet_id            OUT NOCOPY NUMBER ,
                                   x_error_message_code   OUT NOCOPY VARCHAR2 ,
                                   x_error_stage          OUT NOCOPY VARCHAR2 ,
                                   x_return_status        OUT NOCOPY VARCHAR2);

  PROCEDURE tieback_fc_records ( x_return_status   OUT NOCOPY VARCHAR2,
                                 p_calling_mode     IN VARCHAR2) ;

  --PA-J Receipt Accrual Changes
  --Added the below new procedures for funds check
  PROCEDURE ap_funds_check (
          p_txn_source            IN VARCHAR2,
          p_acct_raw_cost         IN NUMBER,
          p_packet_id             IN NUMBER,
          p_sys_ref2              IN NUMBER,
          p_sys_ref3              IN NUMBER,
	  p_sys_ref5              IN NUMBER,        --REL12
	  p_adj_exp_item_id       IN NUMBER,        --REL12
	  p_txn_interface_id      IN NUMBER,        --REL12
	  p_fc_document_type      IN VARCHAR2,      --REL12
          x_error_message_code    OUT NOCOPY VARCHAR2,
          x_error_stage           OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY VARCHAR2) ;

  PROCEDURE ap_po_funds_check (
             p_txn_source            IN VARCHAR2,
             p_acct_raw_cost         IN NUMBER,
             p_packet_id             IN NUMBER,
             p_po_hdr_id             IN NUMBER,
             p_po_dist_id            IN NUMBER,
             p_inv_id                IN NUMBER,
	     p_inv_dist_id           IN NUMBER, --REL12
             p_dist_line             IN NUMBER,
	     p_adj_exp_item_id       IN NUMBER,        --REL12
	     p_txn_interface_id      IN NUMBER,        --REL12
	     p_fc_document_type      IN VARCHAR2,      --REL12
             p_base_qty_var_amt      IN NUMBER,
             p_base_amt_var_amt      IN NUMBER,
             x_error_message_code    OUT NOCOPY VARCHAR2,
             x_error_stage           OUT NOCOPY VARCHAR2,
             x_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE po_funds_check (
             p_txn_source            IN VARCHAR2,
             p_acct_raw_cost         IN NUMBER,
             p_packet_id             IN NUMBER,
             p_sys_ref2              IN NUMBER,
             p_sys_ref3              IN NUMBER,
	     p_sys_ref4              IN NUMBER,        -- Bug 5530897 : Added the parameter p_sys_ref4.
	     p_adj_exp_item_id       IN NUMBER,        --REL12
	     p_txn_interface_id      IN NUMBER,        --REL12
	     p_fc_document_type      IN VARCHAR2,      --REL12
             x_error_message_code    OUT NOCOPY VARCHAR2,
             x_error_stage           OUT NOCOPY VARCHAR2,
             x_return_status         OUT NOCOPY VARCHAR2);

  --2339216-apdisc
  PROCEDURE ap_disc_funds_check (
          p_txn_source            IN VARCHAR2,
          p_acct_raw_cost         IN NUMBER,
          p_packet_id             IN NUMBER,
          p_sys_ref2              IN NUMBER,
          p_sys_ref3              IN NUMBER,
	  p_sys_ref4              IN VARCHAR2, --REL12
 	  p_sys_ref5              IN NUMBER, --REL12
	  p_adj_exp_item_id       IN NUMBER,        --REL12
	  p_txn_interface_id      IN NUMBER,        --REL12
	  p_fc_document_type      IN VARCHAR2,      --REL12
          x_error_message_code    OUT NOCOPY VARCHAR2,
          x_error_stage           OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY VARCHAR2) ;
  PROCEDURE ap_cash_based_funds_check (
          p_txn_source            IN VARCHAR2,
          p_acct_raw_cost         IN NUMBER,
          p_packet_id             IN NUMBER,
          p_sys_ref2              IN NUMBER,        --REL12
          p_sys_ref4              IN VARCHAR2,        --REL12
	  p_sys_ref5              IN NUMBER,        --REL12
	  p_adj_exp_item_id       IN NUMBER,        --REL12
	  p_txn_interface_id      IN NUMBER,        --REL12
	  p_fc_document_type      IN VARCHAR2,      --REL12
          x_error_message_code    OUT NOCOPY VARCHAR2,
          x_error_stage           OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE insert_ap_bc_packets(p_packet_id             IN NUMBER,
                            p_sys_ref2              IN NUMBER,
			    p_sys_ref4              IN VARCHAR2,
                            p_sys_ref5              IN NUMBER,
                            p_acct_raw_cost         IN NUMBER,
                            p_acct_bur_cost         IN NUMBER,
                            p_fc_document_type      IN VARCHAR2,
                            p_txn_source            IN VARCHAR2,
                            p_adj_exp_item_id       IN NUMBER,
			    p_txn_interface_id      IN NUMBER);

PROCEDURE insert_ap_bc_pkt_autonomous
                           (p_packet_id             IN NUMBER,
                            p_sys_ref2              IN NUMBER,
			    p_sys_ref4              IN VARCHAR2,
                            p_sys_ref5              IN NUMBER,
                            p_acct_raw_cost         IN NUMBER,
                            p_acct_bur_cost         IN NUMBER,
                            p_fc_document_type      IN VARCHAR2,
                            p_txn_source            IN VARCHAR2,
                            p_adj_exp_item_id       IN NUMBER,
			    p_txn_interface_id      IN NUMBER,
			    p_comm_fc_req           IN VARCHAR2,
                            p_act_fc_req            IN VARCHAR2,
                            p_adj_act_fc_req        IN VARCHAR2);

PROCEDURE insert_cash_ap_bc_packets(p_packet_id             IN NUMBER,
                                    p_sys_ref2              IN NUMBER,
                                    p_sys_ref5              IN NUMBER,
                                    p_acct_raw_cost         IN NUMBER,
                                    p_fc_document_type      IN VARCHAR2,
                                    p_txn_source            IN VARCHAR2,
                                    p_adj_exp_item_id       IN NUMBER,
			            p_txn_interface_id      IN NUMBER,
            			    p_cash_pay_to_relieve   IN NUMBER DEFAULT 0);

PROCEDURE insert_cash_ap_bc_pkt_auto
                                   (p_packet_id             IN NUMBER,
                                    p_sys_ref2              IN NUMBER,
                                    p_sys_ref5              IN NUMBER,
                                    p_acct_raw_cost         IN NUMBER,
                                    p_fc_document_type      IN VARCHAR2,
                                    p_txn_source            IN VARCHAR2,
                                    p_adj_exp_item_id       IN NUMBER,
			            p_txn_interface_id      IN NUMBER,
			            p_cash_pay_to_relieve   IN NUMBER DEFAULT 0,
            			    p_comm_fc_req           IN VARCHAR2,
                                    p_act_fc_req            IN VARCHAR2,
                                    p_adj_act_fc_req        IN VARCHAR2);

PROCEDURE insert_po_bc_packets(p_packet_id             IN NUMBER,
                            p_sys_ref2              IN NUMBER,
			    p_sys_ref4              IN NUMBER,
                            p_sys_ref3              IN NUMBER,
                            p_acct_raw_cost         IN NUMBER,
			    p_cmt_raw_cost          IN NUMBER,
                            p_fc_document_type      IN VARCHAR2,
                            p_txn_source            IN VARCHAR2,
                            p_adj_exp_item_id       IN NUMBER,
			    p_txn_interface_id      IN NUMBER);

 /* Bug 5396719 : Modified the parameters p_comm_fc_req,p_act_fc_req and p_adj_act_fc_req
    of the PROCEDURE insert_po_bc_packets_auto to be of VARCHAR2 datatype. */

PROCEDURE insert_po_bc_packets_auto
                           (p_packet_id             IN NUMBER,
                            p_sys_ref2              IN NUMBER,
                            p_sys_ref4              IN NUMBER,
			    p_sys_ref3              IN NUMBER,
                            p_acct_raw_cost         IN NUMBER,
			    p_cmt_raw_cost          IN NUMBER,
                            p_fc_document_type      IN VARCHAR2,
                            p_txn_source            IN VARCHAR2,
                            p_adj_exp_item_id       IN NUMBER,
			    p_txn_interface_id      IN NUMBER,
			    p_comm_fc_req           IN VARCHAR2,
                            p_act_fc_req            IN VARCHAR2,
                            p_adj_act_fc_req        IN VARCHAR2);


  -- Log messages changes
  --l_debug_mode           VARCHAR2(20) := 'N';

  RESOURCE_BUSY     EXCEPTION;
  PRAGMA EXCEPTION_INIT( RESOURCE_BUSY, -0054 );

  i       BINARY_INTEGER DEFAULT 0;

  PROCEDURE init_xface_plsql_tables IS
  BEGIN
    g_xface_project_id_tbl.delete;
    g_xface_task_id_tbl.delete;
    g_xface_exp_type_tbl.delete;
    g_xface_ei_date_tbl.delete;
    g_xface_exp_org_id_tbl.delete;
    g_xface_bud_ver_id_tbl.delete;
    g_xface_Entered_Cr_tbl.delete;
    g_xface_Entered_Dr_tbl.delete;
    g_xface_acct_Cr_tbl.delete;
    g_xface_acct_Dr_tbl.delete;
    g_xface_Txn_Ccid_tbl.delete;
    g_xface_org_id_tbl.delete;
    g_xface_Txn_interface_tbl.delete;
  END init_xface_plsql_tables;

  /* Deleting plsql tables  */

PROCEDURE clear_plsql_tables IS
   BEGIN

     g_sob_Id_tbl.delete;
     g_Period_Year_tbl.delete;
     g_project_id_tbl.delete;
     g_task_id_tbl.delete;
     g_exp_type_tbl.delete;
     g_ei_date_tbl.delete;
     g_exp_org_id_tbl.delete;
     g_bud_ver_id_tbl.delete;
     g_budget_line_id_tbl.delete; -- R12 Funds Management uptake
     g_Document_Type_tbl.delete;
     g_Doc_Header_Id_tbl.delete;
     g_Doc_dist_Id_tbl.delete;
     g_Entered_Cr_tbl.delete;
     g_Entered_Dr_tbl.delete;
     g_acct_Cr_tbl.delete;
     g_acct_Dr_tbl.delete;
     g_Actual_Flag_tbl.delete;
     g_Txn_Ccid_tbl.delete;
     g_Je_Catg_Name_tbl.delete;
     g_Je_sorce_Name_tbl.delete;
     g_org_id_tbl.delete;
     g_Pa_Date_tbl.delete;
     g_bc_packet_id_tbl.delete;
     g_packet_id_tbl.delete;
     g_bc_parent_pkt_id_tbl.delete;
     g_enc_type_id_tbl.delete;
     g_doc_hdr_id_2_tbl.delete;
     g_doc_dist_type_tbl.delete;
     g_bc_comt_id_tbl.delete;

END clear_plsql_tables;

  PROCEDURE  GetTrxSrcInfo ( X_trx_src  IN VARCHAR2 )
  IS
  BEGIN

    pa_cc_utils.set_curr_function('GetTrxSrcInfo');

    -- Modifying this query to check for transaction_source rather than
    -- user transaction source
    -- 697638 Bug fix
    --
    -- Removed cost_burdened_flag, this flag is obsolete for 11.5, the
    -- functionality is replaced by allow_burden_flag

    SELECT  ts.transaction_source
    ,       ts.system_linkage_function
    ,       DECODE( ts.system_linkage_function,
                'ST',   'PT',
                'ER', 'PE',
                'VI','VI','PU' )/* Added for bug 2041741*/
    ,       ts.costed_flag
    ,       ts.start_date_active
    ,       ts.end_date_active
    ,       predefined_flag
    ,       allow_adjustments_flag
    ,       gl_accounted_flag
    ,       nvl(posted_flag, 'N') -- get posted_flag
    ,       allow_duplicate_reference_flag
    ,       skip_tc_validation_flag
    ,       allow_emp_org_override_flag
    ,       allow_burden_flag
    ,       pre_processing_extension  -- SST change
    ,       post_processing_extension -- SST change
    ,       nvl(batch_size,0)
    ,       nvl(process_funds_check,'N')
      INTO
            G_trx_source
    ,       G_trx_link
    ,       G_eclass
    ,       G_trx_costed
    ,       G_trx_start
    ,       G_trx_end
    ,       G_trx_predef_flag
    ,       G_allow_adj_flag
    ,       G_gl_accted_flag
    ,       G_gl_posted_flag
    ,       G_allow_dup_flag
    ,       G_skip_tc_flag
    ,       G_emp_org_oride
    ,       G_burdened_flag
    ,       G_pre_processing_extn
    ,       G_post_processing_extn
    ,       G_Batch_Size
    ,       G_Process_Funds_Flag
      FROM
            pa_transaction_sources ts
     WHERE
            ts.transaction_source = X_trx_src;

    pa_cc_utils.reset_curr_function;
  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      G_trx_link := NULL;
      pa_cc_utils.reset_curr_function;
  END  GetTrxSrcInfo;

  -- Get implementation currency information
  --
  PROCEDURE GetImpCurrInfo
  IS
  BEGIN
     pa_cc_utils.set_curr_function('GetImpCurrInfo');
     IF PG_DEBUG = 'Y' THEN
     pa_debug.G_err_Stage := 'call to pa_multi_currency.init';
        log_message('log_message: ' || pa_debug.G_err_Stage);
     END IF;

     pa_multi_currency.init;

     IF PG_DEBUG = 'Y' THEN
     pa_debug.G_err_stage := 'Assigning currency code and rate type to local variables';
        log_message('log_message: ' || pa_debug.G_err_Stage);
     END IF;
     G_accounting_currency_code := pa_multi_currency.G_accounting_currency_code;
     G_default_rate_type := pa_multi_currency.G_rate_type;

     pa_cc_utils.reset_curr_function;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     G_default_rate_type := NULL;
     G_accounting_currency_code := NULL;
     pa_cc_utils.reset_curr_function;
  END GetImpCurrInfo;

  --
  -- Get project/task currency information
  --
  PROCEDURE GetProjCurrInfo( X_task_id    IN NUMBER,
			X_project_currency_code IN OUT NOCOPY VARCHAR2,
			X_project_rate_type IN OUT NOCOPY VARCHAR2,
                        -- PA-I Changes :  Added proj func attr
                        X_projfunc_currency_code IN OUT NOCOPY VARCHAR2,
                        X_projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    pa_cc_utils.set_curr_function('GetProjCurrInfo');
    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling get_project_rate_type';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    If (G_CurrInfoTaskId = X_task_id) Then

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Using Cached Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        X_project_currency_code   := G_CurrInfoPrjCurrCode;
        X_project_rate_type       := G_CurrInfoPrjRtType;
        X_projfunc_currency_code  := G_CurrInfoPrjFCurrCode;
        X_projfunc_cost_rate_type := G_CurrInfoPrjFRtType;

        G_CurrInfoTaskId := X_task_id;

    Else

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Selecting Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        -- PA-I Changes : The API get_project_rate_type has been renamed to get_proj_rate_type
        pa_multi_currency_txn.get_proj_rate_type(P_task_id => X_task_id,
						P_project_currency_code => X_project_currency_code,
						P_project_rate_type => X_project_rate_type);

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling get_projfunc_rate_type';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        -- PA-I Changes :  Calling API to get Proj Functional Currency Code only
        pa_multi_currency_txn.get_projfunc_cost_rate_type(P_task_id => X_task_id,
						P_projfunc_currency_code => X_projfunc_currency_code,
						P_projfunc_cost_rate_type => X_projfunc_cost_rate_type);

        G_CurrInfoPrjCurrCode  := X_project_currency_code;
        G_CurrInfoPrjRtType    := X_project_rate_type;
        G_CurrInfoPrjFCurrCode := X_projfunc_currency_code;
        G_CurrInfoPrjFRtType   := X_projfunc_cost_rate_type;

        G_CurrInfoTaskId := X_task_id;


    End If;

    pa_cc_utils.reset_curr_function;

  END GetProjCurrInfo;

  --
  -- default functional and project currency conversion attributes
  --
  PROCEDURE DefaultCurrAttributes(X_acct_currency_code IN VARCHAR2,
                                 X_project_currency_code IN VARCHAR2,
                                 X_acct_rate_date        IN OUT NOCOPY DATE,
                                 X_acct_rate_type  IN OUT NOCOPY VARCHAR2,
                                 X_acct_exchange_rate IN OUT NOCOPY NUMBER,
                                 X_project_rate_date IN OUT NOCOPY DATE,
                                 X_project_rate_type IN OUT NOCOPY VARCHAR2,
                                 X_project_exchange_rate IN OUT NOCOPY NUMBER )
  IS

  BEGIN

      pa_cc_utils.set_curr_function('DefaultCurrAttributes');

      IF ( X_acct_currency_code = X_project_currency_code) THEN

           X_acct_rate_type := nvl(X_project_rate_type,X_acct_rate_type);
           X_acct_rate_date := nvl(X_project_rate_date,X_acct_rate_date);
           X_acct_exchange_rate := nvl(X_project_exchange_rate, X_acct_exchange_rate);

           X_project_rate_type := nvl(X_project_rate_type,X_acct_rate_type);
           X_project_rate_date := nvl(X_project_rate_date,X_acct_rate_date);
           X_project_exchange_rate := nvl(X_project_exchange_rate, X_acct_exchange_rate) ;


      END IF;
      pa_cc_utils.reset_curr_function;

  END DefaultCurrAttributes;

  /*  PA-I Changes
    For un-accounted transactions we need not call DefaultCurrAttributes.
    This is because the checks that are being performed here will be anyway
    performed during costing in pa_multi_currency_txn. To avoid redundant code
    we are not performing these checks in PA_TRX_IMPORT.
    Please see prior versions for the changed DefaultCurrAttributes if needed.
  */

  PROCEDURE GetVendorId(P_vendor_number IN VARCHAR2)
  IS
  BEGIN

      pa_cc_utils.set_curr_function('GetVendorId');

      SELECT vendor_ID INTO G_vendor_id
      FROM po_vendors
      WHERE segment1 = p_vendor_number;

      pa_cc_utils.reset_curr_function;

  EXCEPTION WHEN others THEN
    G_vendor_id := NULL;
    pa_cc_utils.reset_curr_function;
  END GetVendorId;

  --
  --BUG : 4696351 PJ.R12:DI4:APLINES: VENDOR INFORMATION NOT IMPORTED DURING TRANSACTION IMPORT
  --
  PROCEDURE GetVendorID ( p_person_id IN NUMBER )
  IS
  BEGIN

     pa_cc_utils.set_curr_function('GetVendorId for an employee (person_id):'||p_person_id);

	 select vendor_id
	   into g_vendor_id
	   from po_vendors
	  where employee_id = p_person_id
	    and vendor_type_lookup_code = 'EMPLOYEE' ;

      pa_cc_utils.reset_curr_function;

  EXCEPTION WHEN others THEN
    G_vendor_id := NULL;
    pa_cc_utils.reset_curr_function;
  END GetVendorId ;

  PROCEDURE  GetEtypeInfo( X_etype  IN VARCHAR2
                         , X_date   IN DATE )
  IS
  BEGIN

    pa_cc_utils.set_curr_function('GetEtypeInfo');

    If (G_ETypeInfoEtype = X_etype AND trunc(G_ETypeInfoDate) = trunc(X_date)) Then

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Cached Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

       G_ETypeInfoEtype := X_etype;
       G_ETypeInfoDate  := X_date;

    Else
        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Selecting Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        SELECT
         /* et.system_linkage_function  */ /* Commented for Bug#2726242 */
            et.start_date_active
    ,       et.end_date_active
    ,       NVL(ecr.cost_rate, 1)
    ,       et.cost_rate_flag
         INTO
         /* G_etype_link */ /* Commented for Bug#2726242 */
            G_etype_start
    ,       G_etype_end
    ,       G_etype_cr
    ,       G_etype_cost_rate_flag
         FROM
            pa_expenditure_cost_rates ecr
    ,       pa_expenditure_types et
        WHERE
               et.expenditure_type = ecr.expenditure_type (+)
          AND  X_date BETWEEN ecr.start_date_active (+)
                       AND nvl(ecr.end_date_active (+), X_date)
          AND et.expenditure_type = X_etype;

       G_etype_active := TRUE ;

       G_ETypeInfoEtype := X_etype;
       G_ETypeInfoDate  := X_date;

    End If;

    pa_cc_utils.reset_curr_function;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      /* G_etype_link  := NULL; */ /* Commented for Bug#2726242 */
      G_etype_start := NULL;
      G_etype_end   := NULL;
      G_etype_cr    := NULL;
      G_etype_active := FALSE ;

      G_ETypeInfoEtype := X_etype;
      G_ETypeInfoDate  := X_date;

      pa_cc_utils.reset_curr_function;

  END GetEtypeInfo;

  PROCEDURE  GetEtypeEclassInfo( X_etype  IN VARCHAR2
                               , X_system_linkage IN VARCHAR2 )
  IS
  BEGIN

    pa_cc_utils.set_curr_function('GetEtypeEclassInfo');

    If (G_EClassInfoEtype = X_etype AND G_EClassInfoSysLink = X_system_linkage) then

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Cached Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        G_EClassInfoEtype := X_etype;
        G_EClassInfoSysLink := X_system_linkage;

    Else

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Selecting Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

       SELECT
               ets.system_linkage_function
	      ,st.labor_non_labor_flag
              ,ets.start_date_active
              ,ets.end_date_active
         INTO
               G_etype_link
       ,       G_etype_labor_flag
       ,       G_etec_start
       ,       G_etec_end
         FROM  pa_system_linkages st,
	       pa_expend_typ_sys_links ets
        WHERE  st.function = ets.system_linkage_function
          AND  ets.system_linkage_function = X_system_linkage
          AND  ets.expenditure_type        = X_etype ;

        G_etype_active := TRUE ;

        G_EClassInfoEtype := X_etype;
        G_EClassInfoSysLink := X_system_linkage;

    End If;

    pa_cc_utils.reset_curr_function;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      G_etype_link  := NULL;
      G_etec_start := NULL;
      G_etec_end   := NULL;
      G_etype_active := FALSE ;
      G_EClassInfoEtype := X_etype;
      G_EClassInfoSysLink := X_system_linkage;

      pa_cc_utils.reset_curr_function;

  END GetEtypeEclassInfo;

  PROCEDURE  GetNlrInfo( X_nlr      IN VARCHAR2
                       , X_nlro_id  IN NUMBER )
  IS
  BEGIN

    pa_cc_utils.set_curr_function('GetNlrInfo');
    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_Stage := 'select from pa_non_labor_resources';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    If (G_NlrInfoNlr = X_nlr) Then

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Cached Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        G_NlrInfoNlr := X_nlr;

    Else

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Selecting Values';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        SELECT
            nlr.expenditure_type
    ,       nlr.start_date_active
    ,       nlr.end_date_active
          INTO
            G_nlr_etype
    ,       G_nlr_start
    ,       G_nlr_end
          FROM
            pa_non_labor_resources nlr
         WHERE
            nlr.non_labor_resource = X_nlr;

      G_NlrInfoNlr := X_nlr;

    End If;

    BEGIN
      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'select from pa_non_labor_resource_orgs';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      If (G_NlrInfoNlr = X_nlr and G_NlrInfoNlroId = X_nlro_id) Then

          G_NlrInfoNlroId := X_nlro_id;

      Else

          SELECT
              nlro.start_date_active
      ,       nlro.end_date_active
            INTO
              G_nlro_start
      ,       G_nlro_end
            FROM
              pa_non_labor_resource_orgs nlro
           WHERE
              nlro.organization_id = X_nlro_id
             AND  nlro.non_labor_resource = X_nlr;

          G_NlrInfoNlroId := X_nlro_id;

      End If;

    EXCEPTION
      WHEN  NO_DATA_FOUND  THEN
        G_nlro_start := NULL;
        G_nlro_end   := NULL;
        G_NlrInfoNlroId := X_nlro_id;
        G_NlrInfoNlr := X_nlr;
    END;

    pa_cc_utils.reset_curr_function;
  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      G_nlr_start  := NULL;
      G_nlr_end    := NULL;
      G_nlr_etype  := NULL;
      G_nlro_start := NULL;
      G_nlro_end   := NULL;
      pa_cc_utils.reset_curr_function;

  END GetNlrInfo;

  PROCEDURE  CheckDupItem( X_trx_source  IN VARCHAR2
                         , X_trx_ref     IN VARCHAR2
                         , X_status      OUT NOCOPY VARCHAR2 )
  IS
    dummy     NUMBER;
  BEGIN

    pa_cc_utils.set_curr_function('CheckDupItem');
    BEGIN
      SELECT
              1
        INTO
              dummy
        FROM
              sys.dual
       WHERE EXISTS
            ( SELECT  1
                FROM  pa_expenditure_items ei
               WHERE  ei.orig_transaction_reference = X_trx_ref
                 AND  ei.transaction_source = X_trx_source );

    EXCEPTION
      WHEN  NO_DATA_FOUND  THEN
        NULL;
    END;

    IF ( dummy = 1 ) THEN
      X_status := 'DUPLICATE_ITEM';
      pa_cc_utils.reset_curr_function;
      RETURN;

    ELSIF ( i > 0 ) THEN

      FOR  j  IN 1..i  LOOP
        IF ( pa_transactions.TrxRefTab(j) = X_trx_ref ) THEN
          X_status := 'DUPLICATE_ITEM';
          pa_cc_utils.reset_curr_function;
          RETURN;
        END IF;
      END LOOP;

    ELSE
      X_status := NULL;

    END IF;
    pa_cc_utils.reset_curr_function;

  END  CheckDupItem;

  PROCEDURE  CheckDupAdjItem( X_adj_item_id IN NUMBER
                         , X_status      OUT NOCOPY VARCHAR2 )
  IS
  BEGIN

    pa_cc_utils.set_curr_function('CheckDupAdjItem');
    IF ( i > 0 ) THEN

      FOR  j  IN 1..i  LOOP
        IF ( pa_transactions.AdjEiTab(j) = X_adj_item_id) THEN
          X_status := 'DUPLICATE_ADJUST_ITEM';
          pa_cc_utils.reset_curr_function;
          RETURN;
        END IF;
      END LOOP;

    ELSE
      X_status := NULL;

    END IF;
    pa_cc_utils.reset_curr_function;
  END  CheckDupAdjItem;

  -- SST Change: changed procedure from getprojbcostflag
  -- to getprojtypeinfo because we're not only retrieving
  -- burden cost flag, we're also retrieving project type
  -- class code
  -- PA-K Changes: Selecting burden_amt_display_method
  -- Bug 2634812 : Selecting total_burden_flag
  PROCEDURE GetProjTypeInfo( X_Project_id IN NUMBER,
                             X_Proj_bcost_flag OUT NOCOPY VARCHAR2,
                             X_proj_type_class OUT NOCOPY VARCHAR2,
                             X_burden_amt_display_method OUT NOCOPY VARCHAR2,
                             X_Total_Burden_Flag OUT NOCOPY VARCHAR2)

  IS
  BEGIN
     pa_cc_utils.set_curr_function('GetProjTypeInfo');

     If (X_Project_id = G_PrjInfoPrjId) Then

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Inside GetProjTypeInfo, using cached values';
           log_message('log_message: ' || pa_debug.G_err_stage);
        END IF;

        X_Proj_bcost_flag := G_PrjInfoBCostFlag;
        X_proj_type_class := G_PrjInfoTypeClass;
        X_burden_amt_display_method := G_PrjInfoBdDisplay;
        X_Total_Burden_Flag := G_PrjInfoTotBdFlag;

     Else

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Inside GetProjTypeInfo, selecting values';
           log_message('log_message: ' || pa_debug.G_err_stage);
        END IF;

        -- SST changes, added project_type_class to select statement
        SELECT burden_cost_flag, project_type_class_code, burden_amt_display_method,
               total_burden_flag
        INTO   X_proj_bcost_flag, X_proj_type_class, X_burden_amt_display_method,
               X_Total_Burden_Flag
        FROM   pa_projects_all proj,
               pa_project_types_all ptype
        WHERE  proj.project_type = ptype.project_type
	  -- MOAC Changes
          AND  proj.org_id  = ptype.org_id
          AND  project_id = X_Project_id ;

         G_PrjInfoPrjId := X_Project_id;
         G_PrjInfoBCostFlag := X_proj_bcost_flag;
         G_PrjInfoTypeClass := X_proj_type_class;
         G_PrjInfoBdDisplay := X_burden_amt_display_method;
         G_PrjInfoTotBdFlag := X_Total_Burden_Flag;

     End If;

     pa_cc_utils.reset_curr_function;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           X_Proj_bcost_flag := NULL ;
           X_proj_type_class := NULL;
           X_burden_amt_display_method := NULL;
           X_Total_Burden_Flag := NULL;
           G_PrjInfoPrjId := X_Project_id;
           G_PrjInfoBCostFlag := X_proj_bcost_flag;
           G_PrjInfoTypeClass := X_proj_type_class;
           G_PrjInfoBdDisplay := X_burden_amt_display_method;
           G_PrjInfoTotBdFlag := X_Total_Burden_Flag;

           pa_cc_utils.reset_curr_function;
  END GetProjTypeInfo ;

  FUNCTION CheckCCID ( ccid number ) RETURN NUMBER
  IS
   X_ccid  number(15) ;
  BEGIN
    -- pa_cc_utils.set_curr_function('CheckCCID');
    -- not setting error stack because this procedure
    -- will be violating its associated pragma.

    If ccid is null Then
       G_PrevCCID := ccid;
       G_PrevRetVal := NULL;
       return(NULL);
    End If;

    If G_PrevCCID = ccid Then

       X_ccid := G_PrevRetVal;

    Else

       select code_combination_id
         into X_ccid
         from gl_code_combinations
        where code_combination_id = ccid ;

       G_PrevCCID    := ccid;
       G_PrevRetVal  := 1;

    End If;

     --pa_cc_utils.reset_curr_function;
     return(X_ccid) ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       G_PrevRetVal := NULL;
       G_PrevCCID   := ccid;
       --pa_cc_utils.reset_curr_function;
       RETURN (NULL) ;
  END CheckCCID ;

  -- =============================================================
  -- Bugs: 1063562 and 1069585
  -- New Procedure Validate_VI to do the following validations for Vendor Invoices:
  --         1. Transaction Source needs to be GL accounted.
  --         2. Vendor Number needs to be provided

  PROCEDURE Validate_VI (
            X_vendor_number IN VARCHAR2,
            X_employee_number IN VARCHAR2,
            X_result OUT NOCOPY NUMBER,
            X_status OUT NOCOPY VARCHAR2) AS

  BEGIN
	IF G_gl_accted_flag <> 'Y' THEN
		X_status := 'PA_VI_TRX_SRC_NOT_GL_ACCTED';
		X_result := 1;
		RETURN;
	ELSIF X_vendor_number IS NULL THEN
		X_status := 'PA_VI_VEND_NUM_IS_NULL';
		X_result := 1;
		RETURN;
	END IF;
  END;
--
-- 5235363 R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
--
PROCEDURE validate_exp_date ( p_project_id    IN NUMBER,
                             p_task_id       In NUMBER,
                             p_award_id      in NUMBER,
                             p_incurred_by_org_id    in number,
                             p_vendor_id     in NUMBER,
                             p_person_id     in number,
                             p_exp_item_date in date,
                             p_exp_type      in varchar2,
                             p_system_linkage   in varchar2,
                             p_txn_source    in varchar2,
                             p_calling_modle in varchar2,
                             x_err_msg_cd    in out nocopy varchar2,
                             x_status        out nocopy varchar2   )is
Cursor c_dates is
       select nvl(p.start_date, p_exp_item_date)           proj_start_date,
              nvl(p.completion_date, p_exp_item_date)       proj_end_date,
              nvl(t.start_date, p_exp_item_date)            task_start_date,
              nvl(t.completion_date, p_exp_item_date)       task_completion_date,
              nvl(et.start_date_active, p_exp_item_date)    et_start_date,
              nvl(et.end_date_active, p_exp_item_date)      et_end_date,
              nvl(sl.start_date_active, p_exp_item_date)    sl_start_date,
              nvl(sl.end_date_active, p_exp_item_date)      sl_end_date
         from pa_projects_all p,
              pa_tasks        t,
              pa_expenditure_types et,
              pa_expend_typ_sys_links sl
        where p.project_id         = p_project_id
          and t.project_id         = p_project_id
          and t.task_id            = p_task_id
          and et.expenditure_type  = p_exp_type
          and sl.system_linkage_function = p_system_linkage
          and sl.expenditure_type  = p_exp_type ;

CURSOR GET_VALID_AWARDS IS
       Select 	Allowable_Schedule_Id,
		nvl(Preaward_Date,START_DATE_ACTIVE) preaward_date,
		End_Date_Active                      end_date,
		Close_Date                           close_date,
		Status
	from 	GMS_AWARDS
	where 	award_id =  P_award_id;

  c_dates_rec  c_dates%rowtype ;
  c_award_rec  GET_VALID_AWARDS%Rowtype ;

FUNCTION check_active_employee (p_vendor_id   Number ,p_person_id   Number ,p_Ei_Date     Date ) Return varchar2 IS

        l_return_string  varchar2(10) := 'Y';
        l_return_number  Number := NULL;
        l_emp_number     Number := Null;

          CURSOR cur_emp  IS
                  SELECT vend.employee_id
                  FROM  po_vendors vend
                  WHERE  vend.vendor_id = p_vendor_id
                  AND   p_ei_date BETWEEN nvl(vend.start_date_active,p_ei_date) AND
                           nvl( vend.end_date_active, trunc(sysdate) ) ;

 BEGIN
           If nvl(p_person_id,0) = 0  then
                OPEN cur_emp;
                FETCH cur_emp INTO l_emp_number;
                CLOSE cur_emp;
           Else
                l_emp_number := p_person_id;
           End If;

	   If l_emp_number is NOT NULL then

           	l_return_number := pa_utils.GetEmpOrgId( l_emp_number, p_ei_date );
           	If l_return_number is NULL then
                	l_return_string :=  'N';
           	End If;
	   End If;
           Return l_return_string;

 END check_active_employee;

BEGIN

  pa_cc_utils.set_curr_function('validate_exp_date');

  IF x_err_msg_cd is not NULL THEN
     x_status      := FND_API.G_RET_STS_ERROR ;
     RETURN ;
  END IF ;

  x_status  := FND_API.G_RET_STS_SUCCESS;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: fetching project dates  ' );
  END IF;

  open c_dates ;
  fetch c_dates into c_dates_rec ;
  close c_dates ;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: Validating exp dates now' );
  END IF;


  IF p_award_id is not null then
     IF PG_DEBUG = 'Y' THEN
        log_message('log_message: award passed is :'||p_award_id ) ;
     END IF;

     open get_valid_awards ;
     fetch get_valid_awards into c_award_rec ;
     close get_valid_awards ;

     IF p_exp_item_date <  TRUNC(c_award_rec.preaward_date) THEN
        x_err_msg_cd := 'GMS_EXP_ITEM_DT_BEFORE_AWD_ST' ;
        x_status      := FND_API.G_RET_STS_ERROR ;
        RETURN ;
     END IF ;

     IF p_exp_item_date >  TRUNC(c_award_rec.end_date) THEN
        x_err_msg_cd := 'GMS_EXP_ITEM_DT_AFTER_AWD_END' ;
        x_status      := FND_API.G_RET_STS_ERROR ;
        RETURN ;
     END IF ;

     IF c_award_rec.close_date < TRUNC(SYSDATE) THEN
        x_err_msg_cd := 'GMS_AWARD_IS_CLOSED' ;
        x_status      := FND_API.G_RET_STS_ERROR ;
        RETURN ;
     END IF ;
  END IF ;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: Validating exp dates -> exp types' );
  END IF;
  IF p_exp_item_date not between  c_dates_rec.et_start_date  and c_dates_rec.et_end_date then
     x_err_msg_cd := 'EXP_TYPE_INACTIVE' ;
     x_status      := FND_API.G_RET_STS_ERROR ;
     RETURN ;
  END IF ;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: Validating exp dates -> System Linkage Function' );
  END IF;
  IF p_exp_item_date not between c_dates_rec.sl_start_date and c_dates_rec.sl_end_date THEN
     x_err_msg_cd := 'ETYPE_SLINK_INACTIVE' ;
     x_status      := FND_API.G_RET_STS_ERROR ;
     RETURN ;
  END IF ;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: Validating exp dates -> Project Level' );
  END IF;
  IF p_exp_item_date NOT between c_dates_rec.proj_start_date and c_dates_rec.proj_end_date THEN
     x_err_msg_cd := 'PA_EX_PROJECT_DATE' ;
     x_status      := FND_API.G_RET_STS_ERROR ;
     RETURN ;
  END IF ;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: Validating exp dates -> Task Level' );
  END IF;
  IF p_exp_item_date NOT between c_dates_rec.task_start_date and c_dates_rec.task_completion_date THEN
     x_err_msg_cd := 'PA_EXP_TASK_EFF' ;
     x_status      := FND_API.G_RET_STS_ERROR ;
     RETURN ;
  END IF ;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: Validating exp dates -> Exp Org Level' );
  END IF;
  IF pa_utils2.CheckExporg(p_incurred_by_org_id,p_exp_item_date) = 'N' then
      x_err_msg_cd := 'PA_EXP_ORG_NOT_ACTIVE' ;
      x_status      := FND_API.G_RET_STS_ERROR ;
      RETURN ;
  END IF;

  IF PG_DEBUG = 'Y' THEN
     log_message('log_message: Validating exp dates -> Employee Level' );
  END IF;
  IF nvl(check_active_employee (p_vendor_id => p_vendor_id ,p_person_id => p_person_id ,p_ei_date   => p_exp_item_date),'N') = 'N' then
     x_err_msg_cd := 'NO_ASSIGNMENT' ;
     x_status  := FND_API.G_RET_STS_ERROR ;
     RETURN ;
  End if;

  pa_cc_utils.reset_curr_function;


END VALIDATE_EXP_DATE ;



  PROCEDURE ValidateItem(
               X_trx_src      IN VARCHAR2
            ,  X_enum         IN VARCHAR2
            ,  X_oname        IN VARCHAR2
            ,  X_end_date     IN DATE
            ,  X_ei_date      IN DATE
            ,  X_etype        IN VARCHAR2
            ,  X_pnum         IN VARCHAR2
            ,  X_tnum         IN VARCHAR2
            ,  X_nlr          IN VARCHAR2
            ,  X_nlro_name    IN VARCHAR2
            ,  X_qty          IN NUMBER
            ,  X_denom_raw_cost     IN NUMBER
            ,  X_module       IN VARCHAR2
            ,  X_trx_ref      IN VARCHAR2
            ,  X_match_flag   IN VARCHAR2
            ,  X_entered_by   IN NUMBER
            ,  X_att_cat      IN VARCHAR2
            ,  X_att1         IN OUT NOCOPY VARCHAR2 --DFF Upgrade:
            ,  X_att2         IN OUT NOCOPY VARCHAR2 --Change from IN to
            ,  X_att3         IN OUT NOCOPY VARCHAR2 --IN OUT
            ,  X_att4         IN OUT NOCOPY VARCHAR2
            ,  X_att5         IN OUT NOCOPY VARCHAR2
            ,  X_att6         IN OUT NOCOPY VARCHAR2
            ,  X_att7         IN OUT NOCOPY VARCHAR2
            ,  X_att8         IN OUT NOCOPY VARCHAR2
            ,  X_att9         IN OUT NOCOPY VARCHAR2
            ,  X_att10        IN OUT NOCOPY VARCHAR2
            ,  X_drccid       IN NUMBER
            ,  X_crccid       IN NUMBER
            ,  X_gl_date      IN OUT NOCOPY DATE -- Change from IN to IN OUT, bug 3357936
            ,  X_denom_burdened_cost IN OUT  NOCOPY NUMBER
            ,  X_system_linkage IN VARCHAR2
            ,  X_status       OUT NOCOPY VARCHAR2
            ,  X_bill_flag    OUT NOCOPY VARCHAR2
	   , X_receipt_currency_amount IN NUMBER
	   , X_receipt_currency_code   IN VARCHAR2
	   , X_receipt_exchange_rate   IN OUT NOCOPY NUMBER
	   , X_denom_currency_code     IN OUT NOCOPY VARCHAR2
	   , X_acct_rate_date  	       IN OUT NOCOPY DATE
	   , X_acct_rate_type          IN OUT NOCOPY VARCHAR2
	   , X_acct_exchange_rate      IN OUT NOCOPY NUMBER
	   , X_acct_raw_cost           IN NUMBER
	   , X_acct_burdened_cost      IN OUT NOCOPY NUMBER
	   , X_acct_exchange_rounding_limit IN NUMBER
	   , X_project_currency_code   IN OUT NOCOPY VARCHAR2
	   , X_project_rate_date       IN OUT NOCOPY DATE
	   , X_project_rate_type       IN OUT NOCOPY VARCHAR2
	   , X_project_exchange_rate   IN OUT NOCOPY NUMBER
	   , X_project_raw_cost        IN OUT NOCOPY NUMBER
	   , X_project_burdened_cost   IN OUT NOCOPY NUMBER
           -- Trx_import enhancement: New parameter
           , X_override_to_oname       IN VARCHAR2
           , X_vendor_number           IN VARCHAR2
           , X_org_id                  IN NUMBER
           , X_Business_Group_Name     IN VARCHAR2
           -- PA-I Changes : Added Proj Func Currency Attr
           , X_Projfunc_currency_code  IN OUT NOCOPY VARCHAR2
           , X_Projfunc_cost_rate_date      IN OUT NOCOPY DATE
           , X_Projfunc_cost_rate_type      IN OUT NOCOPY VARCHAR2
           , X_Projfunc_cost_exchange_rate  IN OUT NOCOPY NUMBER
           , X_actual_project_raw_cost  IN OUT NOCOPY NUMBER
           , X_actual_project_burdened_cost  IN OUT NOCOPY NUMBER
           -- PA-I Changes : Added Assignment and Work Type Name
           , X_Assignment_Name           IN OUT NOCOPY VARCHAR2
           , X_Work_Type_Name            IN OUT NOCOPY VARCHAR2
           -- PA-J Period-End Accrual Changes : Added accrual_flag
           , X_accrual_flag              IN VARCHAR2
           --PA-K Changes
           ,  P_project_id                IN NUMBER
           ,  P_task_id                   IN NUMBER
           ,  P_person_id                 IN NUMBER
           ,  P_organization_id           IN NUMBER
           ,  P_NLR_Org_Id                IN NUMBER
           ,  P_Vendor_Id                 IN NUMBER
           ,  P_Override_Organization_Id  IN NUMBER
           ,  P_Person_business_Group_Id  IN NUMBER
           ,  P_assignment_id             IN NUMBER
           ,  P_work_type_id              IN NUMBER
           ,  P_Emp_Org_Id                IN NUMBER
           ,  P_Emp_Job_Id                IN NUMBER
/* Added parameter X_txn_interface_id for bug 2563364 */
           ,  X_txn_interface_id        IN NUMBER
           ,  P_po_number     IN VARCHAR2             /* cwk */
	   ,  P_po_header_id       IN OUT NOCOPY NUMBER
	   ,  P_po_line_num        IN NUMBER
	   ,  P_po_line_id       IN OUT NOCOPY NUMBER
	   ,  P_person_type        IN VARCHAR2
	   ,  P_po_price_type        IN VARCHAR2
	   /* REL12-AP Lines uptake */
           ,  p_adj_exp_item_id        IN NUMBER default NULL
	   ,  p_fc_document_type       IN varchar2 default NULL)
          -- ,  p_agreement_id           IN OUT NOCOPY NUMBER   --FSIO Changes
         --  ,  p_agreement_number       IN OUT NOCOPY varchar2)
  IS
    temp_status      VARCHAR2(30) DEFAULT NULL;
    temp_bill_flag   VARCHAR2(1)  DEFAULT NULL;
    temp_msg_application VARCHAR2(50) := 'PA';
    temp_msg_type 	VARCHAR2(1) := 'E';
    temp_msg_token1  VARCHAR2(2000) := '';
    temp_msg_token2	VARCHAR2(2000) :='';
    temp_msg_token3	VARCHAR2(2000) :='';
    temp_msg_count	NUMBER :=1;
    temp_dff_msg     VARCHAR(2000) :='';

    dummy            NUMBER       DEFAULT NULL;
    l_dummy          Varchar2(1)  DEFAULT NULL;

    l_converted_amount NUMBER     DEFAULT NULL;
    l_denominator      NUMBER     DEFAULT NULL;
    l_numerator        NUMBER     DEFAULT NULL;
    l_rate             NUMBER     DEFAULT NULL;
    l_status           VARCHAR2(80) DEFAULT NULL;
    l_api_status       varchar2(1) ;
    l_status_num       NUMBER     DEFAULT NULL;
    l_stage            NUMBER     DEFAULT NULL;
    l_validate_user_rate_type VARCHAR2(1) DEFAULT 'Y';
    l_handel_exception_flag VARCHAR2(1) DEFAULT 'Y';
    l_denom_cost_ratio            NUMBER := 1;
    l_project_rate_type  VARCHAR2(30) := NULL;
    l_acct_rate_date       DATE;
    l_acct_rate_type     VARCHAR2(30);
    l_acct_exchange_rate NUMBER;
    l_acct_raw_cost  	 NUMBER;

    l_Raw_Bc_Packet_Id    NUMBER;
    l_Packet_Id           NUMBER;
    l_fc_return_status    VARCHAR2(30);
    l_fc_error_stage      VARCHAR2(30);
    l_fc_error_msg        VARCHAR2(30);

    -- Start PA-I Changes
    l_projfunc_cost_rate_type VARCHAR2(30) := NULL;
    l_asgn_work_ret_sts       VARCHAR2(1);
    l_asgn_work_err_msg       VARCHAR2(1000);
    -- End PA-I Changes

    -- PA-J Period-End Accrual Changes
    l_period_end_txn      VARCHAR2(1) := 'N';
    l_ret_sts             VARCHAR2(1);
    x_err_stage           VARCHAR2(100);

    --Bug 3010848
    L_Org_RetSts  Varchar2(50);

    l_SobId     pa_implementations_all.set_of_books_id%TYPE; -- bug 3357936
    l_appl_id  NUMBER(15) := PA_PERIOD_PROCESS_PKG.Application_Id; -- bug 3357936

    -- Start of Changes for  Bug 5743708
    x_cp_structure        VARCHAR2(30);
    x_cost_base           VARCHAR2(30);
    -- End of Changes for  Bug 5743708

 /* cwk */
    l_po_rate NUMBER := 0;
    l_Calc_Amt NUMBER := 0;
    l_processed_cost NUMBER := 0;
    l_costed NUMBER := 0;
    l_uncosted NUMBER := 0;
    l_retrn_val   NUMBER := -1;
    l_cwk_amt_updated VARCHAR2(1) := 'N';

    Cursor c_check_fail(c_packet_id  NUMBER) is
                   Select 'X'
                     from Dual
                   Where exists (select 'Y' from pa_bc_packets
                                  Where packet_id = c_packet_id
                                    and substr(nvl(result_code, 'P'),1,1) = 'F');


    pa_date          DATE         DEFAULT NULL ;
    recvr_pa_date    DATE         DEFAULT NULL ; /* Bug # 1653831 */
    v_result         NUMBER := 0;

    x_return_status NUMBER;
    x_error_code    VARCHAR2(100);
    x_error_stage   NUMBER;

   --l_NewTxnsAllowed  VARCHAR2(1);

/***** CWK CHANGES - This function will check existance of record of a
combination of po_line_id and task_id in PLSQL table *****/

Function Is_Po_Line_Task_Processed (
									P_Po_Line_Id  IN NUMBER,
									P_Task_Id     IN NUMBER
								   ) Return Boolean
Is
	l_Line_Task_str   VARCHAR2(150)  := NULL;
Begin

	l_Line_Task_str   := P_Po_Line_Id ||'.'||P_Task_Id;

	IF PoLineTaskTab.COUNT > 0 THEN
		FOR i IN PoLineTaskTab.FIRST..PoLineTaskTab.LAST
		LOOP
			  IF (l_Line_Task_str = PoLineTaskTab(i)) THEN
					Return True;
			  End If;
		END LOOP;
	End If;

	Return False;

End Is_Po_Line_Task_Processed;

/***** CWK CHANGES - This Procedure will update PL/SQL Tables to reflect *****/
/***** Processed Amount for the given Po_Line_ID. That will be used to   *****/
/***** do the Po Funds check and validate the transaction record.        *****/

PROCEDURE po_processed_amt_chk(P_Po_Line_Id  IN NUMBER
                              ,P_Task_Id   IN   NUMBER
                              ,P_Calc_Amt IN NUMBER
                              ,X_Processed_Amt OUT NOCOPY NUMBER
                              ,X_status OUT NOCOPY VARCHAR2
			     ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_counter         BINARY_INTEGER := 0 ;
l_Line_Task_str   VARCHAR2(150)  := NULL;
l_lock_status     NUMBER         := -1;
l_costed_amt	  NUMBER := 0;
l_uncosted_amt	  NUMBER := 0;


BEGIN

l_Line_Task_str   := P_Po_Line_Id ||'.'||P_Task_Id;

IF PoLineTaskTab.COUNT > 0 THEN

BEGIN

FOR i IN PoLineTaskTab.FIRST..PoLineTaskTab.LAST
LOOP

  IF (l_Line_Task_str = PoLineTaskTab(i)) THEN

      PoAmtTab(i) := PoAmtTab(i) + P_Calc_Amt;
      X_Processed_Amt := PoAmtTab(i);

      x_status := null;
      RETURN;

  END IF;

END LOOP;

EXCEPTION
WHEN OTHERS THEN

  IF PG_DEBUG = 'Y' THEN
     pa_debug.G_err_stage := 'PO_PROCESSED_AMT_CHK : Search of Records : ' ||SQLERRM;
     log_message('log_message: ' || pa_debug.G_err_stage,1);
  END IF;

END ;

END IF ;

-- Now Acquire the lock for Po Line Id and Task Id combination String.

l_lock_status :=  Pa_Debug.Acquire_User_Lock(l_Line_Task_str);

IF (l_lock_status = 0) THEN

   l_counter := PoLineTaskTab.COUNT;
   l_counter := l_counter + 1;

   PoLineTaskTab(l_counter) := l_Line_Task_str;
   PoAmtTab (l_counter)     := P_Calc_Amt ;
   X_Processed_Amt := P_Calc_Amt ;
   x_status := null;
   return;

ELSE

  IF PG_DEBUG = 'Y' THEN
     pa_debug.G_err_stage := 'PO_PROCESSED_AMT_CHK : Failed To Aquire Lock for : '||l_Line_Task_str;
     log_message('log_message: ' || pa_debug.G_err_stage,1);
  END IF;

  x_status := 'PO_LINE_TASK_LOCKED';
  RETURN;

END IF;

EXCEPTION
WHEN OTHERS THEN

  IF PG_DEBUG = 'Y' THEN
     pa_debug.G_err_stage := 'PO_PROCESSED_AMT_CHK : Insertion of Records : ' ||SQLERRM;
     log_message('log_message: ' || pa_debug.G_err_stage,1);
  END IF;

END po_processed_amt_chk;

PROCEDURE undo_processed_amt_chk(P_Po_Line_Id NUMBER
                               ,P_Task_Id    NUMBER
                               ,P_Calc_Amt NUMBER
			        )  IS

l_Line_Task_str   VARCHAR2(150)  := NULL;

BEGIN

l_Line_Task_str   := P_Po_Line_Id ||'.'||P_Task_Id;

  FOR i IN PoLineTaskTab.FIRST..PoLineTaskTab.LAST
  LOOP

    IF (l_Line_Task_str = PoLineTaskTab(i)) THEN

      PoAmtTab(i) := PoAmtTab(i) - P_Calc_Amt;

    END IF;

  END LOOP;

EXCEPTION
WHEN OTHERS THEN

  IF PG_DEBUG = 'Y' THEN
     pa_debug.G_err_stage := 'UNDO_PROCESSED_AMT_CHK : While Undoing Processed Amt Check : ' ||SQLERRM;
     log_message('log_message: ' || pa_debug.G_err_stage,1);
  END IF;

END undo_processed_amt_chk;

  /** *
  *** Validate Items Main processing begins here
  **/
  BEGIN
    pa_cc_utils.set_curr_function('ValidateItem');

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Inside ValidateItem';
       log_message('log_message: ' || pa_debug.G_err_stage);
    END IF;

    G_adj_item_id := NULL;
    G_job_id := NULL;

    X_status := NULL;

    IF (G_accounting_currency_code IS NULL) THEN
       GetImpCurrInfo;
    END IF;

    --PA-K Changes: For PAAPIMP we can skip the following validations and
    --use the ID attributes provided.

     /*Bug 	8208577  Begin*/
     log_message('Checking for negative accrual transaction ' );
		 IF (SIGN(x_denom_raw_cost)=-1 and X_accrual_flag='Y') THEN
		   pa_debug.G_err_Stage := 'Negative Accrual Transaction';
              log_message('log_message: ' || pa_debug.G_err_Stage);
			  X_status := 'NEG_ACCRUAL_TRANS';
           pa_cc_utils.reset_curr_function;
           RETURN;
		 END IF;
		/*Bug 8208577  End*/

    IF (nvl(X_module, 'EXTERNAL') <> 'PAAPIMP') THEN ---{

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling module not PAAPIMP';
          log_message('log_message: ' || pa_debug.G_err_stage);
       END IF;

       --
       -- Changes for CBGA
       --
       -- The following change was to get the business group id if a business group
       -- name is provided.
       --
       --PA-K Changes: If predefined source and ID provided then use it else derive.
       /** Bug#3026218 If Person Business Group Id is not null then use it and
           do not derive **/
       IF P_Person_Business_Group_Id IS NOT NULL THEN
          G_Business_Group_Id := P_Person_Business_Group_Id;
       ELSE

          IF X_Business_Group_Name IS NULL THEN

           G_Business_Group_Id := NULL ;

          ELSIF G_Prev_Business_Group_Name = X_Business_Group_Name THEN

           G_Business_Group_Id := G_Prev_Business_Group_Id ;
          ELSE
           G_Business_Group_Id := pa_utils2.GetBusinessGroupId(X_Business_Group_Name);

           IF G_Business_Group_Id is NULL THEN

            X_status := 'PA_INVALID_BUSINESS_GROUP';

            G_Prev_Business_Group_Name := NULL ;
            G_Prev_Business_Group_Id   := NULL ;

           ELSE

            G_Prev_Business_Group_Name := X_Business_Group_Name ;
            G_Prev_Business_Group_Id :=  G_Business_Group_Id ;
           END IF; /* G_Business_Group_Id is NULL */
          END IF; /* X_Business_Group_Name IS NULL */
       END IF; /* P_Person_Business_Group_Id IS NOT NULL */

       -- ===========================================================================
       --   Perform TRANSACTION SOURCE validation:
       --     * TRANSACTION SOURCE exists
       --     * If TRANSACTION SOURCE is defined as costed, then RAW_COST must be
       --            provided
       --     * TRANSACTION SORUCE must be active as of the transaction date

       last_empno := NULL;
       last_proj  := NULL;
       last_task  := NULL;
       last_etype := NULL;

       IF ( nvl( X_module, 'EXTERNAL' ) <> 'PAXTRTRX' ) THEN

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_Stage := 'G_trx_link = ' || G_trx_link;
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          IF (G_trx_link is null OR X_trx_src <> G_trx_source) Then --3567234
             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_Stage := 'Calling GetTrxSrcInfo';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;
             GetTrxSrcInfo( X_trx_src );
          End If;

         IF ( G_trx_link IS NULL ) THEN
           IF PG_DEBUG = 'Y' THEN
           pa_debug.G_err_Stage := 'Invalid Trx Source';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;
           X_status := 'INVALID_TRX_SOURCE';
           pa_cc_utils.reset_curr_function;
           RETURN;
         END IF;

       END IF;

       -- ==========================================================================
       -- Bugs: 1063562 and 1069585
       -- Calls procedure Validate_VI to do the following validations for Vendor Invoices:
       --         1. Transaction Source needs to be GL accounted.
       --         2. Vendor Number needs to be provided
       IF (X_system_linkage = 'VI') THEN
       	Validate_VI (
       	    X_vendor_number => X_vendor_number,
            X_employee_number => X_enum,
            X_result => v_result,
            X_status => X_status);
        IF (v_result <> 0) THEN
                pa_cc_utils.reset_curr_function;
		RETURN;
        END IF;
       END IF;

       -- Validation for non zero raw cost is moved from here to the else clause of the
       -- Burden Transaction validation.... Selva 03/07/97
       --
       IF ( trunc(X_ei_date) NOT BETWEEN trunc(G_trx_start)
                              AND nvl(trunc(G_trx_end), trunc(X_ei_date))) THEN
         X_status := 'TRX_SOURCE_INACTIVE';
         pa_cc_utils.reset_curr_function;
         RETURN;

       END IF;

       -- ==========================================================================
       -- Added 'VI' in the following IF condition.
       -- A supplier invoice does not need to have
       -- employee number and organization name
       IF ( X_system_linkage NOT IN  ('ST', 'OT','ER', 'VI') ) THEN
         if ( X_enum IS NULL  AND X_ONAME is NULL ) THEN
            X_status := 'EMP_OR_ORG_MAND' ;
            pa_cc_utils.reset_curr_function;
            RETURN ;
         end if ;
       END IF ;

       -- REL12 AP Lines uptake.
       -- Unaccounted Expense report transactions are not allowed.
       IF ( X_system_linkage = 'ER' and NVL(g_gl_accted_flag,'N')  = 'N' ) then
          X_status := 'PA_ER_NOT_ACCOUNTED' ;
          pa_cc_utils.reset_curr_function;
	  RETURN ;
       END IF ;

       -- ===========================================================================
       --   Verify that the expenditure ending date is a valid expenditure week
       --   ending date
       --
       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling pa_utils.GetWeekEnding';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;
       IF (trunc( X_end_date) <> trunc(pa_utils.NewGetWeekEnding( X_end_date )) ) THEN
        X_status := 'INVALID_END_DATE';
        pa_cc_utils.reset_curr_function;
        RETURN;

        -- ===========================================================================
        --   Verify that the transaction item date is on or before the week ending
        --   date
        --
       ELSIF ( trunc(X_ei_date) > trunc(X_end_date) ) THEN   /* Bug 4284192 */
        X_status := 'EI_DATE_AFTER_END_DATE';
        pa_cc_utils.reset_curr_function;
        RETURN;
       END IF;  --PA-K Changes: Added 'EndIf' separating the date checks
                --from the person and org checks

       --PA-K Changes: Use the ID if provided for predefined transaction sources.
       /** Bug#3026218. If Person Id and Organization Id are provided, then use them **/
       IF P_Person_Id is not null and P_Organization_Id is not null Then
          G_Person_Id := P_Person_Id;
          G_Org_Id := P_Organization_Id;

	  /* Bug 6519602: Base Bug 6519570 - Changes start */
	  IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling pa_utils.GetEmpJobId';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          G_job_id := pa_utils.GetEmpJobId(
                             X_person_id => G_person_id,
                             X_date      => X_ei_date ,
                             X_po_number => p_po_number,
                             X_po_line_num => p_po_line_num);

	  IF ( G_job_id IS NULL ) THEN
	     X_status := 'NO_ASSIGNMENT';
	     pa_cc_utils.reset_curr_function;
	     RETURN;
	  END IF;

	  IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := ' G_Job_Id = ' ||  G_Job_Id;
             log_message('log_message: ' || pa_debug.G_err_stage);
          END IF;
         /* Bug 6519602: Base Bug 6519570 - Changes end */

       ELSE
          -- Bug: 1063552
          -- For third party transaction sources transferring supplier invoices,
          -- we will not transfer the employee number
          -- We will transfer the organization info if the following requirements are met:
          --         1. Transaction source is defined with employee organization override
          --         2. User provided a valid organization name for the override.
          IF ((X_enum is NOT NULL) AND
             (G_trx_predef_flag = 'N') AND
             (X_system_linkage = 'VI')) THEN

            G_person_id := NULL;

            IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_Stage := 'Calling pa_utils.GetOrgnId';
               log_message('log_message: ' || pa_debug.G_err_Stage);
            END IF;

            IF ( X_oname IS NOT NULL ) THEN

		    --Start of changes for bug 3010848
		    --G_org_id := pa_utils.GetOrgId(X_oname);
		    pa_utils.GetOrgnId(X_org_name => X_oname,
				       X_bg_id    => G_Business_Group_Id,
				       X_Orgn_Id  => G_org_id,
				       X_Return_Status => L_Org_RetSts);

		    If L_Org_RetSts is Not Null Then
		       X_status := L_Org_RetSts;
		       RETURN;
		    End If;
		    --End of changes for bug 3010848


                IF (G_org_id IS NULL) THEN
                  X_status := 'PA_EXP_ORG_INVALID';
                  pa_cc_utils.reset_curr_function;
                  RETURN;
                END IF;

                /* PA-K Changes: Commenting the CheckExporg, moved the check to one place below*/

            ELSE
               G_org_id := NULL;
            END IF;  /* IF X_oname IS NOT NULL*/

          -- ===========================================================================
          --   Get the person ID for the employee number given
          ELSIF ( X_enum IS NOT NULL ) THEN

            IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_stage := 'Calling pa_utils.GetEmpId, G_business_Group_id = ' || G_business_Group_id;
               log_message('log_message: ' || pa_debug.G_err_Stage);
            END IF;
            -- Fixed Bug 1534973, 1581184
            -- Passing X_Ei_Date parameter to GetEmpId

            pa_utils2.GetEmpId( G_business_Group_id,
                            X_enum,
                            G_person_id,
			    P_person_type, /* cwk */
                            X_Ei_Date );

            IF ( pa_utils2.G_return_status IS NOT NULL ) THEN
              X_status := pa_utils2.G_return_status ;
              pa_cc_utils.reset_curr_function;
              RETURN;
            ELSE
              last_empno := X_enum;

              -- ==============================================
              -- Enhancement for Oracle Labor Distribution
              -- Don't fetch the employee's org ID if the flag
              -- allow_emp_org_override_flag is set to 'Y'

              IF nvl(G_emp_org_oride,'N') = 'Y' THEN

/*Bug 2655157, Commented this code see below for actual code
                IF ( X_oname IS NULL ) THEN
                   X_status := 'PA_EXP_ORG_MANDATORY';
                   pa_cc_utils.reset_curr_function;
                   RETURN;
                END IF;

                IF PG_DEBUG = 'Y' THEN
                pa_debug.G_err_Stage := 'Calling pa_utils.GetOrgId';
                   log_message('log_message: ' || pa_debug.G_err_Stage);
                END IF;

                G_org_id := pa_utils.GetOrgId(X_oname);

                IF (G_org_id IS NULL) THEN
                  X_status := 'PA_EXP_ORG_INVALID';
                  pa_cc_utils.reset_curr_function;
                  RETURN;
                END IF;
*/
                -- Bug 2655157 : Below code added for the error being raised in
                -- Review Transactions form
                IF ( X_oname IS NULL ) THEN
                   IF PG_DEBUG = 'Y' THEN
                      pa_debug.G_err_Stage := 'Calling pa_utils.GetEmpOrgId';
                      log_message('log_message: ' || pa_debug.G_err_Stage);
                   END IF;

                   G_org_id  := pa_utils.GetEmpOrgId(G_person_id, X_Ei_Date);

                   IF ( G_org_id IS NULL ) THEN
                      X_status := 'PA_EXP_ORG_MANDATORY';
                      pa_cc_utils.reset_curr_function;
                      RETURN;
                   END IF;

                ELSE

                   IF PG_DEBUG = 'Y' THEN
                      pa_debug.G_err_Stage := 'Calling pa_utils.GetOrgnId';
                      log_message('log_message: ' || pa_debug.G_err_Stage);
                   END IF;

		    --Start of changes for Bug 3010848
		    --G_org_id := pa_utils.GetOrgId(X_oname);
		    pa_utils.GetOrgnId(X_org_name => X_oname,
				       X_bg_id    => G_Business_Group_Id,
				       X_Orgn_Id  => G_org_id,
				       X_Return_Status => L_Org_RetSts);


		    If L_Org_RetSts is Not Null Then
		       X_status := L_Org_RetSts;
		       RETURN;
		    End If;
		    --End of changes for Bug 3010848


                   IF (G_org_id IS NULL) THEN
                      X_status := 'PA_EXP_ORG_INVALID';
                      pa_cc_utils.reset_curr_function;
                      RETURN;
                   END IF;

                END IF;
                --End of fix for Bug 2655157

                -- ============================================
                --   Get the job ID of the employee's job
                --   assignment as of the item date

                IF PG_DEBUG = 'Y' THEN
                pa_debug.G_err_stage := 'Calling pa_utils.GetEmpJobId';
                   log_message('log_message: ' || pa_debug.G_err_Stage);
                END IF;

                G_job_id := pa_utils.GetEmpJobId(
                             X_person_id => G_person_id,
                             X_date      => X_ei_date ,
                             X_po_number => p_po_number,
                             X_po_line_num => p_po_line_num);

                  -- Added PO params for bug 4044057
                  -- Need to validate the assigment for the entered PO

                IF ( G_job_id IS NULL ) THEN

                    -- Commented for bug 4531168
                    -- IF p_po_number is null THEN
                    --   X_status := 'NO_ASSIGNMENT';
                    -- ELSE
                    --   X_status := 'NO_PO_ASSIGNMENT';
                    -- END IF;
                    -- pa_cc_utils.reset_curr_function;
                    -- RETURN;

                    /*Begin for bug 4531168*/
                    IF X_trx_src in ('OLD', 'GOLD', 'GOLDE') and p_po_number is null THEN
                         begin
                               select paa.job_id
                               into G_job_id
                               from PER_ALL_ASSIGNMENTS_F paa,
                                    psp_summary_lines psl
                               where paa.assignment_id        =  psl.assignment_id
                               and psl.effective_date       between paa.effective_start_date and paa.effective_end_date
                               and psl.SUMMARY_LINE_ID      =  X_trx_ref;
                         exception
                               when OTHERS then
                                    X_status := 'NO_ASSIGNMENT';
                                    pa_cc_utils.reset_curr_function;
                                    RETURN;
                         end;
                     ELSIF p_po_number is null then
                         X_status := 'NO_ASSIGNMENT';
                         pa_cc_utils.reset_curr_function;
                         RETURN;
                     ELSE
                         X_status := 'NO_PO_ASSIGNMENT';
                         pa_cc_utils.reset_curr_function;
                         RETURN;
                     END IF;
                     /* End for bug 4531168 */

                END IF;

              ELSE

                -- =============================================
                --   Get the organization ID of the employee's
                --   organization assignment as of the item date

                /* Pa.K Changes: For Performance, combined org and job id derivation */

                G_org_id := P_Emp_Org_Id;
                G_Job_Id := P_Emp_Job_Id;

                If G_org_id is NULL or G_Job_Id is NULL Then
                   IF PG_DEBUG = 'Y' THEN
                   pa_debug.G_err_stage := 'Calling pa_utils.GetEmpOrgJobId';
                      log_message('log_message: ' || pa_debug.G_err_Stage);
                   END IF;
                   pa_utils.GetEmpOrgJobId( G_person_id, X_ei_date, G_Org_Id, G_Job_Id ,p_po_number, p_po_line_num);
                  -- Added PO params for bug 4044057
                  -- Need to validate the assigment for the entered PO

                End If;


                IF ( G_org_id IS NULL or G_Job_Id IS NULL ) THEN

                     -- Commented for bug 4531168
                     -- IF p_po_number is null THEN
                     --     X_status := 'NO_ASSIGNMENT';
                     -- ELSE
                     --     X_status := 'NO_PO_ASSIGNMENT';
                     -- END IF;
                     -- pa_cc_utils.reset_curr_function;
                     -- RETURN;

                     /*Begin for bug 4531168*/
                     IF X_trx_src in ('OLD', 'GOLD', 'GOLDE') and p_po_number is null THEN
                          begin
                               select paa.job_id
                               into G_job_id
                               from PER_ALL_ASSIGNMENTS_F paa,
                                    psp_summary_lines psl
                               where paa.assignment_id        =  psl.assignment_id
                               and psl.effective_date       between paa.effective_start_date and paa.effective_end_date
                               and psl.SUMMARY_LINE_ID      =  X_trx_ref;
                          exception
                               when OTHERS then
                                    X_status := 'NO_ASSIGNMENT';
                                    pa_cc_utils.reset_curr_function;
                                    RETURN;
                          end;
                     ELSIF p_po_number is null then
                          X_status := 'NO_ASSIGNMENT';
                          pa_cc_utils.reset_curr_function;
                          RETURN;
                     ELSE
                          X_status := 'NO_PO_ASSIGNMENT';
                          pa_cc_utils.reset_curr_function;
                          RETURN;
                     END IF;
                     /* End for bug 4531168 */

                END IF;

              END IF;  /* IF nvl(G_emp_org_oride,'N') = 'Y' */

              /* PA-K Changes: Commenting the CheckExporg, moved the check to one place below */

              /* PA-K Changes: For Performance, combined org and job id derivation */

            END IF; /* IF ( G_person_id IS NULL ) */

          -- ===========================================================================
          --   Get the organization ID for the incurred by organization name given
          ELSIF (  X_enum IS NULL   AND   X_oname IS NOT NULL ) THEN

            IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_Stage := 'Calling pa_utils.GetOrgnId';
               log_message('log_message: ' || pa_debug.G_err_Stage);
            END IF;

            G_person_id := NULL;
	      --Start of changes for 3010848
	      --G_org_id    := pa_utils.GetOrgId( X_oname );
	      pa_utils.GetOrgnId(X_org_name => X_oname,
				 X_bg_id    => G_Business_Group_Id,
				 X_Orgn_Id  => G_org_id,
				 X_Return_Status => L_Org_RetSts);

	      If L_Org_RetSts is Not Null Then
		 X_status := L_Org_RetSts;
		 RETURN;
	      End If;
	      --End of changes for 3010848


            IF ( G_org_id IS NULL ) THEN
              X_status := 'INVALID_ORGANIZATION';
              pa_cc_utils.reset_curr_function;
              RETURN;
            END IF;

            /* PA-K Changes: Commenting the CheckExporg, moved the check to one place below */

          --  =============================================================================
          --  Trx_import enhancement:
          --  X_enum and X_oname are both NULL.  This can happen when transferring invoices
          --  with supplier not being an employee
          ELSE
	        G_person_id := NULL;
	        G_org_id    := NULL;
          END IF;  /*IF ( X_end_date <> trunc(pa_utils.GetWeekEnding( X_end_date )) ) */

      END IF; --Predefined source check for person and organization id

      -- PA-K Changes: Moved CheckExporg to below one place
      IF G_org_id is not NULL THEN
       IF pa_trx_import.g_skip_tc_flag <> 'Y' and PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date = 'Y' then /* Added for Bug # 2170237 */
	          -- Modified the above condition for BUG6931833
          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Calling pa_utils2.CheckExporg';
             log_message('log_message: ' || pa_debug.G_err_Stage);
             log_message('log_message: ' || 'G_org_id = ' || G_org_id);
          END IF;
          IF pa_utils2.CheckExporg(G_org_id,X_ei_date) = 'N' then
             X_status := 'PA_EXP_ORG_NOT_ACTIVE';
             pa_cc_utils.reset_curr_function;
             RETURN;
          END IF;
       END IF;
      END IF;  /* Added for Bug # 2170237 */

      -- =============================================================================
      -- Trx_import enhancement:
      -- Get override-to organization ID if override_to_organization_name is provided
      --
      --PA-K Changes: Use the ID if provided for predefined transaction sources.
      /** Bug#3026218. Use ID if provided for any transaction source **/
      IF P_override_organization_id IS NOT NULL THEN
         G_override_to_org_id := P_override_organization_id;
      ELSE
         IF (X_override_to_oname IS NOT NULL) THEN

           IF PG_DEBUG = 'Y' THEN
           pa_debug.G_err_stage := 'Calling pa_utils.GetOrgnId for override org';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;

        --Start of changes for bug 3010848
        --G_override_to_org_id := pa_utils.GetOrgId(X_override_to_oname);

        pa_cc_utils.log_message('X_override_to_oname = ' || X_override_to_oname
                                || ' G_Business_Group_Id = ' || G_Business_Group_Id);


        pa_utils.GetOrgnId(X_org_name => X_override_to_oname,
                           X_bg_id    => G_Business_Group_Id,
                           X_Orgn_Id  => G_override_to_org_id,
                           X_Return_Status => L_Org_RetSts);

        If L_Org_RetSts is Not Null Then
           X_status := L_Org_RetSts;
           RETURN;
        End If;
        --End of changes for bug 3010848

	   IF (G_override_to_org_id IS NULL) THEN
		X_status := 'PA_OVERRIDE_ORG_INVALID';
                pa_cc_utils.reset_curr_function;
		RETURN;
           ELSIF pa_trx_import.g_skip_tc_flag <> 'Y' and PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date = 'Y' THEN /* Added for Bug # 2170237 */
		   --Modified above condition for bug6931833
             IF pa_utils2.CheckExporg(G_override_to_org_id, X_ei_date) = 'N' THEN
                X_status := 'PA_OVERRIDE_ORG_NOT_ACTIVE';
                pa_cc_utils.reset_curr_function;
                RETURN;
  	     END IF;
           END IF; /* Added for Bug # 2170237 */
         ELSE
           -- Bug: 927655
           -- Reset G_override_to_org_id to NULL, so that the next transaction within
           -- the same expenditure does not get the same override to org.
           G_override_to_org_id := NULL;
	   -- X_override_to_oname IS NULL, check if G_org_id IS NULL.
           -- If G_org_id is also NULL, then return error
	   IF (G_org_id IS NULL) THEN
		X_status := 'PA_EXP_ORG_NOT_SPECIFIED';
                pa_cc_utils.reset_curr_function;
		RETURN;
	   END IF;
         END IF;
      END IF;

      -- =============================================================================
      -- Trx_import enhancement:
      -- Check the vendor number only if the current vendor number is different from
      -- the previous vendor number
      --PA-K Changes: Use the ID if provided for predefined transaction sources.
      /** Bug#3026218 Use Vendor Id if provided for any tyep of transaction source **/
      IF P_Vendor_Id is not NULL THEN
         G_vendor_id := P_Vendor_Id;
      ELSIF
          ( X_vendor_number IS NOT NULL AND
           (G_previous_vendor_number <> X_vendor_number OR
            G_previous_vendor_number IS NULL ) ) THEN

          GetVendorId(P_vendor_number => X_vendor_number);

          IF (G_vendor_id IS NULL) THEN
		X_status := 'PA_SUPPLIER_NUM_INVALID';
                pa_cc_utils.reset_curr_function;
		RETURN;
          END IF;

          G_previous_vendor_number := X_vendor_number;
      ELSIF (X_vendor_number IS NULL) THEN --added for 8205209
          G_vendor_id := NULL;
		  G_previous_vendor_number := NULL; -- added for 9466254

      END IF;

      -- ===========================================================================
      --   Get the project and task IDs associated with the project and task
      --   numbers given
      --
      --  IF ( last_proj IS NULL   OR    X_pnum <> last_proj ) THEN

      --PA-K Changes: Use the ID if provided for predefined transaction sources.
      /** Bug#3026218. Use Project Id, if provided for any type of transaction source **/
      IF P_Project_Id is not null THEN
         G_project_id := P_Project_Id;
      ELSE
         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling pa_utils.GetProjId';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

         G_project_id := pa_utils.GetProjId( X_pnum );
      END IF;

      --PA-K Changes:
      --IF (G_Task_Id IS NULL) THEN
      --PA-K Changes: Use the ID if provided for predefined transaction sources.
      /** Bug#3026218 Use Task Id, if provided for any type of transaction source **/
      IF P_Task_Id is not NULL THEN
         G_task_id := P_Task_Id;
      ELSE
         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling  pa_utils.GetTaskId';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

         G_task_id := pa_utils.GetTaskId( G_project_id, X_tnum );
      END IF;

      -- ===========================================================================
      --   EXPENDITURE TYPE validation
      --      * Expenditure type given exists
      --      * Expenditure type has same system linkage as transaction source
      --      07/15/97- selva:   This above condition is not valid after project Manuf. changes.
      --      * Expenditure type is active as of the transaction item date
      --    IF ( last_etype IS NULL   OR   x_etype <> last_etype ) THEN
      --   Check pa_expend_typ_sys_links table for for existence and activeness of
      --   the given  exp_type/sys_link combination

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling GetEtypeEclassInfo';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
      GetEtypeEclassInfo(X_etype, X_system_linkage) ;

      IF  ( G_etype_link is NULL ) then
       X_status := 'INVALID_ETYPE_SYSLINK' ;
       pa_cc_utils.reset_curr_function;
       RETURN ;
      END IF ;

      IF  ( X_ei_date NOT BETWEEN G_etec_start
           AND nvl( G_etec_end, X_ei_date ) ) THEN
      X_status := 'ETYPE_SLINK_INACTIVE';
      pa_cc_utils.reset_curr_function;
      RETURN;
      END IF;

      --   Check pa_expenditure_types table for for existence and activeness of
      --   the given  exp_type combination
      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling GetEtypeInfo';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
      GetEtypeInfo( X_etype, X_ei_date );

      IF ( NOT G_etype_active ) THEN
        X_status := 'INVALID_EXP_TYPE';
        pa_cc_utils.reset_curr_function;
        RETURN;
      ELSE
        last_etype := x_etype;
      END IF;

      --  Based on project journal design a transaction source can have more than one system_linkage
      --  So the validation of system_linkage of source with expenditure type is no more valid.
      --  The validation should be between the system_linkage of the record and the system_linkage of
      --  expenditure type of the same record. At present the system linkage is in pa_expenditure_types
      --  table. But once the new table for expenditure type and system_linkage is created, the given
      --  record's system linkage should be checked for existence in the new table.
      --  Selva 03/07/97

      IF  ( X_ei_date NOT BETWEEN G_etype_start
           AND nvl( G_etype_end, X_ei_date ) ) THEN
        X_status := 'EXP_TYPE_INACTIVE';
        pa_cc_utils.reset_curr_function;
        RETURN;
      END IF;

    ELSE  --Calling module = PAAPIMP

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling module is PAAPIMP';
         log_message('log_message: ' || pa_debug.G_err_stage);
      END IF;

      G_project_id := P_Project_Id;
      G_task_id    := P_Task_Id;
      G_Vendor_Id  := P_Vendor_Id;
      G_Person_Id  := P_Person_Id;
      G_override_to_org_id := P_Override_Organization_Id ;

       --
       -- 5235363 R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
       -- Expenditure item related date validations are not relevant for Expense Reports.
       --
       IF PG_DEBUG = 'Y' THEN
	  log_message('log_message: validate_exp_date x_module ='||x_module) ;
	  log_message('log_message: validate_exp_date g_paapimp_validate_dt ='||g_paapimp_validate_dt) ;
	  log_message('log_message: validate_exp_date x_system_linkage ='||x_system_linkage) ;
	  log_message('log_message: validate_exp_date x_status ='||x_status) ;
       END IF ;

       IF (nvl(X_module, 'EXTERNAL') = 'PAAPIMP' and
          g_paapimp_validate_dt      = 'Y'       and
	  x_system_linkage           = 'VI'      and
	  x_status                  is NULL )   THEN

          IF PG_DEBUG = 'Y' THEN
	     log_message('log_message: validate_exp_date p_project_id ='||p_project_id) ;
	     log_message('log_message: validate_exp_date p_task_id ='||p_task_id) ;
	     log_message('log_message: validate_exp_date p_organization_id ='||p_organization_id) ;
	     log_message('log_message: validate_exp_date p_override_organization_id ='||p_override_organization_id) ;
	     log_message('log_message: validate_exp_date p_vendor_id ='||p_vendor_id) ;
	     log_message('log_message: validate_exp_date p_person_id ='||p_person_id) ;
	     log_message('log_message: validate_exp_date x_system_linkage ='||x_system_linkage) ;
	     log_message('log_message: validate_exp_date x_trx_source ='||x_trx_src) ;
	  END IF ;

	  -- ===================================================
          -- 5235363   R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
	  -- Following are not validated....
	  -- PA adjustments for supplier invoice transactions
	  -- Reversals
	  -- Funds check adjustments
	  -- Expenditure item adjustments
	  -- Net ZERO Transactions for reversals
	  -- ====================================================

          validate_exp_date( p_project_id,
	                     p_task_id,
			     NULL,
			     p_override_organization_id, /*Bug 6146558 */
			     p_vendor_id,
			     p_person_id,
			     x_ei_date,
			     x_etype,
			     x_system_linkage,
			     x_trx_src,
			     x_module,
			     x_status,
			     l_api_status) ;

          IF X_status is not null and l_api_status = fnd_api.g_ret_sts_error then

             --
	     -- Bug:5502147 R12.PJ:XB9:QA:APL: ISSUES IN EI DATE VALIDATION IN PROJECTS
	     -- Following is done to support Query by project number or task number in the transaction review form.
	     --
             update pa_transaction_interface_all
                Set project_number = ( select segment1
                                         from pa_projects_all
                                         where project_id = P_project_id ),
                     task_number   = ( select task_number from pa_tasks
                                       where  task_id = P_task_id)
               where txn_interface_id = X_txn_interface_id ;

	     return ;
	  END IF ;
       END IF ;


      --Bug 2719674: For AP EXPENSE, G_Org_Id equivalent to
      --pa_expenditures_all.incurred_by_organization_id and G_Job_Id should be populated
      --Since these values are derived while forming the grouping attributes,
      --just reuse the values.
      /* Bug 6498029: Base Bug 6339005: added OR ( X_trx_src= 'AP NRTAX' and X_system_linkage = 'ER' ) condition for populating G_Job_id if transaction source is 'Non-Recoverable Tax From Payables' */
      If ( X_trx_src= 'AP EXPENSE' OR ( X_trx_src= 'AP NRTAX' and X_system_linkage = 'ER' ))  Then
         -- Modified the following line to assign P_Organization_Id to  G_Org_id for
	     -- bug#4689402 (forward port for 4614046)
         /* Begin bug 5400719:  See reasoning in 11i bug 5381025*/
         -- G_Org_Id := P_Organization_Id; --P_Emp_Org_Id;
         G_Org_Id := NVL(P_Override_Organization_Id, P_Organization_Id); /* added for bug 5381025 */ /*Bug 7343687*/
         /* End bug 5400719 */
         G_Job_Id := P_Emp_Job_Id;

         IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_stage := 'AP EXPENSE, G_Org_Id, G_Job_Id = ' || G_Org_Id || ',' || G_Job_Id;
            log_message('log_message: ' || pa_debug.G_err_stage);
         END IF;

         If (G_Org_Id is NULL or G_Job_Id is NULL) Then
             X_status := 'NO_ASSIGNMENT';
             pa_cc_utils.reset_curr_function;
             RETURN;
         End If;

      End If;

    END IF;  ---}

    IF ( G_project_id IS NULL ) THEN
        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Project Id is null';
           log_message('log_message: ' || pa_debug.G_err_stage);
        END IF;
        X_status := 'INVALID_PROJECT';
        pa_cc_utils.reset_curr_function;
        RETURN;
    ELSE
        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling GetProjTypeInfo';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        -- Bug 2634812 : Deriving total_burden_flag
        GetProjTypeInfo( G_project_id,
                         G_Proj_bcost_flag,
                         G_project_type_class,
			 G_burden_amt_display_method,
                         G_Total_Burden_Flag ) ;

        IF G_proj_bcost_flag IS NULL THEN
           IF PG_DEBUG = 'Y' THEN
           pa_debug.G_err_stage := 'Project Type is invalid';
              log_message('log_message: ' || pa_debug.G_err_stage);
           END IF;

           X_status := 'INVALID_PROJ_TYPE' ;
           pa_cc_utils.reset_curr_function;
           RETURN ;
        END IF ;

        /* PA-K Changes: Moved G_burden_amt_display_method to GetProjTypeInfo */

        last_proj := X_pnum;

        /* Bug 2726763: Remove reduntant call to pa_project_utils.check_project_action_allowed
                        This check is already present in PATC.

        -- ===========================================================================
        -- Check if new transactions are allowed against this project

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling pa_project_utils.check_project_action_allowed';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        -- PA-K Changes: Using Caching for performance

        If (G_NewTxnPrjId = G_project_id) Then

            l_NewTxnsAllowed := G_NewTxnsAllowed;

        Else

            l_NewTxnsAllowed := pa_project_utils.check_project_action_allowed(
                                             X_project_id  => G_project_id,
                                             X_action_code => 'NEW_TXNS');
            G_NewTxnsAllowed := l_NewTxnsAllowed;
            G_NewTxnPrjId    := G_project_id;

        End If;

        IF l_NewTxnsAllowed = 'N'
        THEN
            IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_stage := 'Project does not allow new txns';
               log_message('log_message: ' || pa_debug.G_err_stage);
            END IF;

            X_status := 'PA_NEW_TXNS_NOT_ALLOWED';
            pa_cc_utils.reset_curr_function;
            RETURN;
        END IF;
        */

        -- ===========================================================================
        --   Check if the cross charging is allowed for this project

        --Bug 2726763: Add skip_tc_flag check for checking if project is chargeable.
        If pa_trx_import.g_skip_tc_flag <> 'Y' and PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date = 'Y' then
		        --Modified above condition for BUG6931833

           IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'Calling pa_utils.IsCrossChargeable';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;

           If not pa_utils.IsCrossChargeable(G_Project_Id) then
              X_Status := 'PA_PROJECT_NOT_VALID' ;
              pa_cc_utils.reset_curr_function;
              return ;
           End If ;

        End If ;

        --  ELSIF ( last_task IS NULL   OR   X_tnum <> last_task ) THEN

        IF ( G_task_id IS NULL ) THEN
          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Task Id is null';
             log_message('log_message: ' || pa_debug.G_err_stage);
          END IF;

          X_status := 'INVALID_TASK';
          pa_cc_utils.reset_curr_function;
          RETURN;
        ELSE
          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Calling pa_utils2.GetLaborCostMultiplier';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
          G_lcm  := pa_utils2.GetLaborCostMultiplier(G_Task_id);
          last_task := X_tnum;
        END IF;

    END IF;

    --FSIO Changes Starts
    --Populate Agreement_Number and ID if FSIO is enabled.
  /*  IF G_project_type_class = 'CONTRACT' AND G_FSIO_ENABLED = 'Y' THEN
      declare
        l_agreement_number pa_agreements.agreement_num%type;
        l_agreement_id number(15);
      begin
        PA_agreements_clnt_extn.get_agreement (
                                 p_project_id,
                                 p_task_id,
                                 x_ei_date,
                                 x_etype,
                                 NVL(p_organization_id, p_override_organization_id),
                                 p_vendor_id,
                                 p_person_id,
                                 x_system_linkage,
                                 l_agreement_number,
                                 l_agreement_id,
                                 x_trx_src,
                                 x_status,
                                 l_api_status);
        IF l_agreement_number IS NOT NULL AND l_agreement_id IS NOT NULL then
          declare
            l_dummy1 varchar2(1);
          begin
            SELECT 'Y'
            INTO l_dummy1
            FROM pa_agreements
            WHERE agreement_id  = l_agreement_id
              AND agreement_num = l_agreement_number;
          exception
            WHEN NO_DATA_FOUND then
            X_status := 'INVALID_AGREEMENT_FR_CLNT_EXTN';
            pa_cc_utils.reset_curr_function;
            RETURN;
          end;
          p_agreement_number := l_agreement_number;
          p_agreement_id     := l_agreement_id;
        END if;
      end;
      IF p_agreement_id IS NOT NULL or p_agreement_number IS NOT NULL then
        begin
          IF p_agreement_id IS NOT NULL then
            SELECT agreement_num
            INTO p_agreement_number
            FROM pa_agreements
            WHERE agreement_id = p_agreement_id;
          ELSIF p_agreement_number IS NOT NULL then
            SELECT agreement_id
            INTO p_agreement_id
            FROM pa_agreements
            WHERE agreement_num = p_agreement_number;
          END if;
        exception
          WHEN NO_DATA_FOUND then
            X_status := 'INVALID_AGREEMENT';
            pa_cc_utils.reset_curr_function;
            RETURN;
        end;
        IF p_agreement_id IS NULL or p_agreement_number IS NULL then
          X_status := 'INVALID_AGREEMENT';
          pa_cc_utils.reset_curr_function;
          RETURN;
        END if;
      else
        --Call default agreement derivation logic
        pa_billing.get_agreement_id (p_project_id,
                                     p_task_id,
                                     x_ei_date,
                                     p_agreement_id,
                                     p_agreement_number);
      END if;
    ELSE --IF G_project_type_class = 'CONTRACT' AND G_FSIO_ENABLED = 'Y' THEN
      p_agreement_id := NULL;
      p_agreement_number := NULL;
    END IF;
    --FSIO Changes Ends */

    -- ===================================================================
    -- Validation specific to Multi Currency Transactions
    --    * Check if user rate type is allowed for converting to
    --      functional currency
    --    * for acct_rate_type='User' check if exchange rate is populated
    --    * for acct_rate_type<> 'User' check if the rate type is valid
    --    * Check if user rate type is allowed for converting to
    --      project currency
    --    * for project_rate_type='User' check if exchange rate is populated
    --    * for project_rate_type<> 'User' check if the rate type is valid
    --    * check if denom currency code is populated.
    --    * check if transaction currency code is valid.

    -- Multi Currency validation common to uncosted,costed and accounted txns
    --
    /*-----------------------------------------------------------------------------
    -- Transaction currency should be always be available.
    -- if it is not availabe, then default it to functional currency code
    ------------------------------------------------------------------------------*/
    IF ( X_denom_currency_code IS NULL ) THEN

      X_denom_currency_code := G_accounting_currency_code;

    ELSE -- X_denom_currency_code IS NOT NULL

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling pa_multi_currency.validate_currency_code';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
	IF (pa_multi_currency.validate_currency_code(
                     P_currency_code =>X_denom_currency_code,
                     P_ei_date       =>X_ei_date)= 'N')
	THEN

		X_status :='PA_INVALID_DENOM_CURRENCY';
                pa_cc_utils.reset_curr_function;
		RETURN;

	END IF; -- end invalid denom currency validation

    END IF; -- End X_denom_currency_code IS NULL

    /*------------------------------------------------------------------------
    -- Get the project currency code, which is required for validation of project
    -- currency attributes. Get project currency information
    -------------------------------------------------------------------------*/

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling GetProjCurrInfo';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    -- PA-I Changes: Get Proj Functional currency code
    GetProjCurrInfo(G_task_id,
		X_project_currency_code,
		l_project_rate_type,
                X_projfunc_currency_code,
                l_projfunc_cost_rate_type);

    --
    -- if project currency is null return null
    --
    IF ( X_project_currency_code IS NULL ) THEN

    	X_status := 'PA_MISSING_PROJ_CURR';
        pa_cc_utils.reset_curr_function;
    	RETURN;

    END IF;

    -- Start PA-I Changes
    -- if project functional currency is null return error
    --
    IF ( X_projfunc_currency_code IS NULL ) THEN

        X_status := 'PA_MISSING_PRJFUNC_CURR';
        pa_cc_utils.reset_curr_function;
        RETURN;

    END IF;
    -- End PA-I Changes

    /*-----------------------------------------------------------------------
    --  check if the functional rate type provided is valid.
    ------------------------------------------------------------------------*/
    IF  ( X_acct_rate_type IS NOT NULL ) THEN

      --Corrected Fix for Bug 2489534
      If (nvl(X_module, 'EXTERNAL') = 'PAAPIMP' OR
         -- S.N. Bug 3570261
           ((P_po_number IS NOT NULL OR P_Po_Line_Num IS NOT NULL OR
            P_Po_Header_Id IS NOT NULL OR P_Po_Line_Id IS NOT NULL) AND
            x_system_linkage in ('ST','OT'))
         -- E.N. Bug 3570261
         ) Then

	 G_acct_rate_type := X_acct_rate_type;

      Else

         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling pa_multi_currency.get_conversion_type';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;
         G_acct_rate_type := pa_multi_currency.get_conversion_type(
                               P_user_rate_type => X_acct_rate_type);

      End If;

      IF ( G_acct_rate_type IS NULL ) THEN

         --Conversion rate type is invalid. Reject the txn

         X_status :=  'PA_INVALID_ACCT_RATE_TYPE';
         pa_cc_utils.reset_curr_function;
         RETURN;
      END IF; --G_acct_rate_type is null

    ELSE -- X_acct_rate_type is null

      G_acct_rate_type := NULL;

    END IF; -- X_acct_rate_type is not null

    /*-----------------------------------------------------------------------
    --  check if the project rate type provided is valid.
    ------------------------------------------------------------------------*/
    IF  ( X_project_rate_type IS NOT NULL ) THEN

      --Corrected Fix for Bug 2489534
      If (nvl(X_module, 'EXTERNAL') <> 'PAAPIMP') Then
         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling pa_multi_currency.get_conversion_type';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;
         G_project_rate_type := pa_multi_currency.get_conversion_type(
                               P_user_rate_type => X_project_rate_type);
      Else
         G_project_rate_type := X_project_rate_type;
      End If;

      IF ( G_project_rate_type IS NULL ) THEN

         --Conversion rate type is invalid. Reject the txn
         X_status :=  'PA_INVALID_PROJ_RATE_TYPE';
         pa_cc_utils.reset_curr_function;
         RETURN;

      END IF; --G_project_rate_type is null

    ELSE -- i.e. X_project_rate_type is null

     G_project_rate_type := NULL;
    END IF; -- X_project_rate_type is not null

    -- Start PA-I Changes
    /*-----------------------------------------------------------------------
    --  check if the project functional rate type provided is valid.
    ------------------------------------------------------------------------*/
    IF  ( X_projfunc_cost_rate_type IS NOT NULL ) THEN

      --Corrected Fix for Bug 2489534
      If (nvl(X_module, 'EXTERNAL') <> 'PAAPIMP') Then
         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling pa_multi_currency.get_conversion_type';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;
         G_projfunc_cost_rate_type := pa_multi_currency.get_conversion_type(
                               P_user_rate_type => X_projfunc_cost_rate_type);
      Else
         G_projfunc_cost_rate_type := X_projfunc_cost_rate_type;
      End If;

      IF ( G_projfunc_cost_rate_type IS NULL ) THEN

         --Conversion rate type is invalid. Reject the txn

         X_status :=  'PA_INVALID_PRJFUNC_CST_RT_TYP';
         pa_cc_utils.reset_curr_function;
         RETURN;
      END IF; --G_projfunc_cost_rate_type is null

    ELSE -- X_projfunc_cost_rate_type is null

      G_projfunc_cost_rate_type := NULL;

    END IF; -- X_projfunc_cost_rate_type is not null
    -- End PA-I Changes

    IF ( G_acct_rate_type = 'User' ) THEN

      -- check if rate type 'User' is allowed
      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling pa_multi_currency.is_user_rate_type_allowed';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
      IF ( pa_multi_currency.is_user_rate_type_allowed(
         P_from_currency => X_denom_currency_code,
         P_to_currency => G_accounting_currency_code,
         P_conversion_date => nvl(X_acct_rate_date,sysdate))='N')
      THEN

      	-- If rate type 'User' is not allowed, reject the txn.
			X_status := 'PA_NO_ACCT_USER_RATE_TYPE';
                        pa_cc_utils.reset_curr_function;
	 		RETURN;

      ELSE -- Conversion Rate type 'User' is allowed

      -- If rate type 'User' is allowed then the exchange rate should
      -- be provided.

         IF ( X_acct_exchange_rate IS NULL ) THEN
            X_status := 'PA_ACCT_USER_RATE_NOT_DEFINED';
            pa_cc_utils.reset_curr_function;
            RETURN;
         END IF;-- end X_acct_exchange_rate IS NULL

      END IF;-- End is_user_rate_type_allowed ='N'

    END IF; -- End X_acct_rate_tye ='User'

    -- Perform the same validation for project conversion rate type

    IF ( G_project_rate_type = 'User' ) THEN

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling pa_multi_currency.is_user_rate_type_allowed';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;
        IF ( pa_multi_currency.is_user_rate_type_allowed(
			P_from_currency => X_denom_currency_code,
			P_to_currency => X_project_currency_code,
			P_conversion_date => nvl(X_project_rate_date,sysdate))='N')
	THEN
		X_status := 'PA_NO_PROJ_USER_RATE_TYPE';
                pa_cc_utils.reset_curr_function;
		RETURN;

	ELSE  --conversion rate type 'User' is allowed

		IF ( X_project_exchange_rate IS NULL ) THEN
			X_status := 'PA_PROJ_USER_RATE_NOT_DEFINED';
                        pa_cc_utils.reset_curr_function;
			RETURN;
		END IF;-- End X_project_exchange_rate IS NULL

	END IF;--End is_user_rate_type_allowed ='N'

    END IF;-- End G_project_rate_type = 'User'

    -- Start PA-I Changes
    -- Perform the same validation for project functional conversion rate type

    IF ( G_projfunc_cost_rate_type = 'User' ) THEN

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling pa_multi_currency.is_user_rate_type_allowed';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
       IF ( pa_multi_currency.is_user_rate_type_allowed(
                        P_from_currency => X_denom_currency_code,
                        P_to_currency => X_projfunc_currency_code,
                        P_conversion_date => nvl(X_projfunc_cost_rate_date,sysdate))='N')
       THEN
            X_status := 'PA_NO_PRJFUNC_CST_USER_RT_TYP';
            pa_cc_utils.reset_curr_function;
            RETURN;

       ELSE  --conversion rate type 'User' is allowed

            IF ( X_projfunc_cost_exchange_rate IS NULL ) THEN
                 X_status := 'PA_PRJFUNC_CST_USER_RATE_NULL';
                 pa_cc_utils.reset_curr_function;
                 RETURN;
            END IF;-- End X_project_exchange_rate IS NULL

       END IF;--End is_user_rate_type_allowed ='N'

    END IF;-- End G_projfunc_cost_rate_type = 'User'
    -- End PA-I Changes

    /*---------------------------------------------------------------------------
    --  END MULTI CURRENCY VALIDATION COMMON TO UNCOSTED,COSTED, ACCOUNTED TXNS
    ----------------------------------------------------------------------------*/
    --
    -- Multi currency validation for uncosted txns
    --
    -- if the txn is uncosted then
    -- * if expenditure types with cost rate flag = 'Y'
    --   and labor related system linkages, the denom_currency_code should be same
    --   as acct_currency_code because Oracle Projects maintains cost rates
    --   and employee compensations in functional currency only
    -- * for ER with receipt currency different
    --   from denom currency, the receipt amount should be populated.
    -- * for ER check if receipt currency code is valid

    IF ( nvl(G_trx_costed,'N') = 'N' ) THEN

       /* ----------------------------------------------------------------------------
       -- Prior to PA-K:
       -- Labor cost rates are entered in functional currency only hence the
       -- Transaction and Functional currencies should be same for labor transactions.
       -- Similarly transactions that require cost rate should have same transaction
       -- and functional currencies.
       -- With and Beyond PA-K:
       -- Labor Costing Enhancements, If Etype Labor Flag = Y, the denom and acct
          curreny could differ.
       ------------------------------------------------------------------------------*/

	IF  nvl(G_etype_cost_rate_flag,'N') = 'Y'
           --OR nvl(G_etype_labor_flag,'N') = 'Y' )
	THEN

		IF ( X_denom_currency_code <> G_accounting_currency_code ) THEN

			X_status := 'PA_DENOM_ACCT_CURR_DIFF';
                        pa_cc_utils.reset_curr_function;
			RETURN;

		END IF;

	END IF;

        /*-----------------------------------------------------------------------------
        -- For Expense reports Users can enter the receipt currency information.  The
        -- following section validates if the user entered receipt currency is a valid
        -- currency in Oracle Applications.
        ------------------------------------------------------------------------------*/

        IF ( X_system_linkage = 'ER' ) THEN

           IF ( X_receipt_currency_code IS NOT NULL ) THEN

                    IF PG_DEBUG = 'Y' THEN
                    pa_debug.G_err_stage := 'Calling pa_multi_currency.validate_currency_code';
                       log_message('log_message: ' || pa_debug.G_err_Stage);
                    END IF;
                    IF (pa_multi_currency.validate_currency_code(
					P_currency_code =>X_receipt_currency_code,
                                        P_ei_date => X_ei_date)= 'N')
	    	    THEN

			X_status :='PA_INVALID_RECEIPT_CURRENCY';
                        pa_cc_utils.reset_curr_function;
			RETURN;

		    END IF; -- end invalid receipt currency validation

                    /*----------------------------------------------------------------------------
                    -- If all the receipt currency is different from transaction currency, the user
                    -- should provide the receipt amount which will be used later to calculate the
                    -- receipt exchange rate.  If the amount is not provided, the transaction will
                    -- be rejected
                    -----------------------------------------------------------------------------*/

		    IF ( nvl(X_receipt_currency_code,X_denom_currency_code) <> X_denom_currency_code ) THEN

			IF ( nvl(X_receipt_currency_amount,0) = 0 ) THEN

				X_status := 'PA_MISSING_RECEIPT_AMOUNT';
                                pa_cc_utils.reset_curr_function;
				RETURN;

			ELSE -- receipt amount is not zero

				-- derive the receipt exchange rate from the ratio of quantity
				-- to receipt amount

                                IF PG_DEBUG = 'Y' THEN
                                pa_debug.G_err_stage := 'Calling pa_currency.round_trans_currency_amt';
                                   log_message('log_message: ' || pa_debug.G_err_Stage);
                                END IF;
				X_receipt_exchange_rate := (X_qty/
                                       pa_currency.round_trans_currency_amt1(
                                       X_receipt_currency_amount,
                                       nvl(X_receipt_currency_code,X_denom_currency_code)));


			END IF; -- end receipt currency info validation

		    END IF; -- end receipt curr code <> denom curr code

	   END IF; -- end receipt curr code not null

        END IF; --end system linkage = ER

    END IF; -- end G_trx_costed ='N'

    /*-----------------------------------------------------------------------------
    --  END MULTI CURRENCY VALIDATION FOR UNCOSTED TXNS
    -----------------------------------------------------------------------------*/

    /*-----------------------------------------------------------------------------
    --  START MULTI CURRENCY VALIDATION FOR COSTED/UNCOSTED UNACCOUNTED TXNS
    -----------------------------------------------------------------------------*/
    /*  PA-I Changes
    For un-accounted transactions we need not call DefaultCurrAttributes.
    This is because the checks that are being performed here will be anyway
    performed during costing in pa_multi_currency_txn. To avoid redundant code
    we are not performing these checks in PA_TRX_IMPORT.
    */

    /*-----------------------------------------------------------------------------
    --  END MULTI CURRENCY VALIDATION FOR COSTED/UNCOSTED UNACCOUNTED TXNS
    -----------------------------------------------------------------------------*/

    --
    -- Multi currency validation for accounted transactions
    --
    -- If the transaction is accounted then
    -- * Currency information to convert from transaction to functional currency
    --   should be provided if transaction and functional currencies are different
    -- * The acct_raw_cost should be populated
    -- * validate if the user provided functional raw cost is with in the
    --   tolerance
    -- * if functional and transaction currencies are same the corresponding
    --   raw costs should be equal.
    -- * calculate project raw cost
    --

    IF ( nvl(G_gl_accted_flag,'N') = 'Y' ) THEN

	-- Functional raw cost should be provided for accounted transactions
        /*Bug# 2168903:Replaced the check of nvl(X_acct_raw_cost,0) = 0 with
           x_acct_raw_cost is NULL ,in the IF condition below */

	IF ( X_acct_raw_cost IS NULL AND  X_system_linkage <>'BTC' ) THEN

		X_status := 'PA_NO_ACCT_COST';
                pa_cc_utils.reset_curr_function;
		RETURN;

	END IF; -- acct_raw_cost is null

	IF ( nvl(X_denom_currency_code,G_accounting_currency_code) <> G_accounting_currency_code) THEN

                /* --------------------------------------------------------------------
		-- If Transaction and Functional currencies are not same the user should
		-- provide conversion attributes(i.e X_acct_rate_date,X_acct_rate_type,
		-- X_acct_exchange_rate).
                ---------------------------------------------------------------------*/
		IF ( X_acct_rate_date IS NULL ) THEN

			X_status := 'PA_NO_ACCT_CURR_RATE_DATE';
                        pa_cc_utils.reset_curr_function;
			RETURN;

		END IF; -- End X_acct_rate_date is NULL

		IF (G_acct_rate_type IS NULL) THEN

			X_status := 'PA_NO_ACCT_CURR_RATE_TYPE';
                        pa_cc_utils.reset_curr_function;
			RETURN;

		END IF; -- End G_acct_rate_type IS NULL

            /* Starts - Commented for bug# 5890661
		IF ( X_acct_exchange_rate IS NULL) THEN

			X_status := 'PA_NO_ACCT_CURR_RATE';
                        pa_cc_utils.reset_curr_function;
			RETURN;

		END IF; -- End X_acct_exchange_rate IS NULL
	Ends - commented for bug# 5890661 */

                /*-------------------------------------------------------------------
		-- Validate if the user provided Functional raw cost is with in the
		-- tolerance( tolerance is identified by acct_round_limit column).
                -- This is done by calculating the functional raw cost from the
                -- conversion attributes provided by the user, the calculated
                -- functional raw cost is then compared with the fucntional cost
                -- provided by the user. If acct_round_limit is NULL then it will be
                -- assumed that the acct_round_limit is Zero(0).
		--------------------------------------------------------------------*/

               l_acct_rate_date := X_acct_rate_date;
               l_acct_rate_type := G_acct_rate_type;
   	       l_acct_exchange_rate := X_acct_exchange_rate;
	       l_acct_raw_cost := X_acct_raw_cost;

               IF PG_DEBUG = 'Y' THEN
               pa_debug.G_err_stage := 'Calling pa_multi_currency.convert_amount';
                  log_message('log_message: ' || pa_debug.G_err_Stage);
               END IF;

	       pa_multi_currency.convert_amount(
                                P_from_currency         => X_denom_currency_code,
				P_to_currency           => G_accounting_currency_code,
				P_conversion_date       => l_acct_rate_date,
				P_conversion_type       => l_acct_rate_type,
				P_amount                => X_denom_raw_cost,
                   	        P_user_validate_flag    => l_validate_user_rate_type,
	  			P_handle_exception_flag => l_handel_exception_flag,
				P_converted_amount      => l_converted_amount,
				P_denominator           => l_denominator,
				P_numerator             => l_numerator,
				P_rate                  => X_acct_exchange_rate,
			        X_status                => l_status);

		IF ( l_status IS NOT NULL ) THEN

			X_status := l_status;
                        pa_cc_utils.reset_curr_function;
			RETURN;

		END IF; -- End l_status IS NOT NULL


		-- Check if the calculated functional raw cost is with in the
		-- tolerance

                -- Bug 1603841
                -- If transaction_source is any of the following then
                -- do not check for the rounding limit.

                IF X_trx_src not in ('AP INVOICE' ,'AP EXPENSE','AP NRTAX', 'AP DISCOUNTS', 'AP ERV',
                                     --PA-J Receipt Accrual changes
                                 'AP VARIANCE', 'PO RECEIPT', 'PO RECEIPT NRTAX',
				 'Inventory','Inventory Misc','Work In Process', /*Bug4202839*/
				  'CSE_INV_ISSUE','CSE_INV_ISSUE_DEPR', /*Bug4202839*/
				  'PJM_CSTBP_INV_NO_ACCOUNTS','PJM_CSTBP_WIP_NO_ACCOUNTS', /*Bug4202839*/
				  'PJM_CSTBP_WIP_ACCOUNTS','PJM_CSTBP_INV_ACCOUNTS',
				  'PJM_CSTBP_ST_ACCOUNTS','PJM_NON_CSTBP_ST_ACCOUNTS','PJM_CSTBP_ST_NO_ACCOUNTS',/*Bug4202839*/
				 'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ',
                         'INTERPROJECT_AP_INVOICES','INTERCOMPANY_AP_INVOICES') THEN /* Added the 2 transaction sources for bug 3461993 */
				-- pricing changes

			IF abs(l_converted_amount - X_acct_raw_cost) >
				abs(nvl(X_acct_exchange_rounding_limit,0)) THEN

				X_status := 'PA_EXCEED_ROUND_LIMIT';
                                pa_cc_utils.reset_curr_function;
				RETURN;

			END IF; -- end functional amount tolerance check
                ELSE
                -- Bug 4038568
                -- If source is AP/PO, copy the exchange rate from the source system instead of rederiving from GL

                        X_acct_exchange_rate := nvl(l_acct_exchange_rate,X_acct_exchange_rate);

                END IF;

	ELSE -- denom currency_ = accounting currency

		--
		-- If functional and transaction currencies are same the the
		-- corresponding amounts should also be equal
		--
                IF PG_DEBUG = 'Y' THEN
                pa_debug.G_err_stage := 'Calling pa_multi_currency.round_trans_currency_amt';
                   log_message('log_message: ' || pa_debug.G_err_Stage);
                END IF;

	/* Added the call to round off X_acct_raw_cost for bug 2871273 */
	      	IF ( pa_currency.round_trans_currency_amt1(X_acct_raw_cost, G_accounting_currency_code) <>
                     pa_currency.round_trans_currency_amt1(X_denom_raw_cost,
                     X_denom_currency_code )) THEN

			X_status := 'PA_INVALID_ACCT_DENOM_COST';
                        pa_cc_utils.reset_curr_function;
			RETURN;

		END IF; -- end acct raw cost <> denom raw cost

	END IF; -- denom <> acct curr

     	--
     	-- call get_currency_amounts to derive project currency amount
     	-- for accounted transactions.  For accounted transactions
     	-- the EI's are created with cost_distributed_flag='Y', so
     	-- the the costing program cannot pick up these records
     	-- to calculate the project currency costs. Here we are passing
     	-- the G_gl_accted_flag to pa_multi_currency_txn package, the
     	-- package will calculate the project cost if the gl_accted_flag
     	-- is 'Y'.
     	--
        -- initilize the local variables before passing them to
        -- get_currency_amounts

        l_acct_rate_date := X_acct_rate_date;
    	l_acct_rate_type := G_acct_rate_type;
	l_acct_exchange_rate := X_acct_exchange_rate;
	l_acct_raw_cost := X_acct_raw_cost;

     	BEGIN

                IF PG_DEBUG = 'Y' THEN
                pa_debug.G_err_stage := 'Calling pa_multi_currency_txn.get_currency_amounts';
                   log_message('log_message: ' || pa_debug.G_err_Stage);
                END IF;
     		pa_multi_currency_txn.get_currency_amounts(
				P_task_id          => G_task_id,
				P_ei_date          => X_ei_date,
				P_denom_raw_cost   => X_denom_raw_cost,
				P_denom_curr_code  => X_denom_currency_code,
				P_acct_curr_code   => G_accounting_currency_code,
				P_accounted_flag   => G_gl_accted_flag,
				P_acct_rate_date   => l_acct_rate_date,
				P_acct_rate_type   => l_acct_rate_type,
				P_acct_exch_rate   => l_acct_exchange_rate,
                                P_acct_raw_cost    => l_acct_raw_cost,
				P_project_curr_code => X_project_currency_code,
				P_project_rate_type => G_project_rate_type,
				P_project_rate_date => X_project_rate_date,
				P_project_exch_rate => X_project_exchange_rate,
			       --P_project_raw_cost => X_project_raw_cost,
                               --PA-I Changes : Proj Func raw cost is calculated in P_raw_cost
			       --P_raw_cost          => X_project_raw_cost,
			        P_projfunc_raw_cost          => X_project_raw_cost,
				P_status            => l_status,
				P_stage             => l_stage,
                               --PA-I Changes : Added Proj Func Attributes and Project raw cost
                                P_projfunc_curr_code => X_projfunc_currency_code,
                                P_projfunc_cost_rate_type => G_projfunc_cost_rate_type,
                                P_projfunc_cost_rate_date => X_projfunc_cost_rate_date,
                                P_projfunc_cost_exch_rate => X_projfunc_cost_exchange_rate,
                                P_project_raw_cost   => X_actual_project_raw_cost);

              X_actual_project_raw_cost := pa_currency.round_trans_currency_amt1(X_actual_project_raw_cost,X_project_currency_code);  -- Bug 8621083 / 8595274

    	/***************PA-I changes************************
         Commenting the exception section as the exceptions are already handled in
         the pa_multi_currency_txn pkg.
        ****************************************************/

    	END; -- end calculate project raw cost


	IF ( l_status IS NOT NULL ) THEN
		X_status := l_status;
                pa_cc_utils.reset_curr_function;
        	RETURN;

	END IF; -- end l_status IS NOT NULL

    END IF; -- end gl_accounted_flag =Y

    -- ===========================================================================
    --   Validation specific to STRAIGHT_TIME transactions
    --     * Transaction item date must be within the expenditure week ending
    --       on the ending date given
    --     * Employee must be specified
    --
    -- Bug 1000221, added OT to the in clause

    IF ( X_system_linkage in ( 'ST', 'OT' )) THEN

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling pa_utils.DateInExpWeek';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      IF ( NOT pa_utils.DateInExpWeek( X_ei_date , X_end_date  ) ) THEN
          X_status := 'ITEM_NOT_IN_WEEK';
          pa_cc_utils.reset_curr_function;
          RETURN;
      ELSIF ( X_enum IS NULL ) THEN
          X_status := 'EMP_MAND_FOR_TIME';
          pa_cc_utils.reset_curr_function;
          RETURN;
      END IF;

    -- ===========================================================================
    --   Validation specific to EXPENSE_REPORTS transactions
    --     * Employee must be specified
    --

    ELSIF ( X_system_linkage = 'ER' ) THEN
      IF ( X_enum IS NULL and X_trx_src NOT IN  ('AP EXPENSE', 'AP NRTAX') ) THEN
                           /* Bug2780387. Added 'AP NRTAX' to the NOT IN list */
          X_status := 'EMP_MAND_FOR_ER';
          pa_cc_utils.reset_curr_function;
          RETURN;
      END IF;

    -- ===========================================================================
    --   Validation specific to USAGES items
    --     * Employee OR organization must be given
    --     * Non-labor resource and non-labor resource owning organization must
    --       be given
    --     * Non-labor resource and non-labor resource owning organization are
    --       both valid
    --     * Non-labor resource is active as of the transaction item date
    --     * Non-labor resource is owned by the given non-labor resource org as of
    --       the transaction item date
    --     * Expenditure type of the non-labor resource matches that of the
    --       transaction
    --

    ELSIF ( X_system_linkage = 'USG' ) THEN
      IF ( X_enum IS NULL    AND    X_oname IS NULL ) THEN
          X_status := 'EMP_OR_ORG_MAND_FOR_USAGES';
          pa_cc_utils.reset_curr_function;
          RETURN;
      ELSIF ( X_nlr IS NULL ) THEN
          X_status := 'NL_RSRC_MAND_FOR_USAGES';
          pa_cc_utils.reset_curr_function;
          RETURN;
      ELSIF ( X_nlro_name IS NULL ) THEN
          X_status := 'NL_RSRC_ORG_MAND_FOR_USAGES';
          pa_cc_utils.reset_curr_function;
          RETURN;
      END IF;

      --PA-K Changes: Use the ID if provided for predefined transaction sources.
      /** Bug#3026218 Use ID, if provided for any type of transaction source **/
      IF P_NLR_Org_Id is not null Then
         G_nlro_id := P_NLR_Org_Id;
      ELSE
         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling pa_utils.GetOrgnId';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;
      --Start of changes for Bug 3010848

      --G_nlro_id := pa_utils.GetOrgId( X_nlro_name );
      pa_utils.GetOrgnId(X_org_name => X_nlro_name,
                         X_bg_id    => G_Business_Group_Id,
                         X_Orgn_Id  => G_nlro_id,
                         X_Return_Status => L_Org_RetSts);

      If L_Org_RetSts is Not Null Then
         X_status := L_Org_RetSts;
         RETURN;
      End If;
      --End of changes for Bug 3010848

      END IF;

      IF ( G_nlro_id IS NULL ) THEN
          X_status := 'INVALID_NL_RSRC_ORG';
          pa_cc_utils.reset_curr_function;
          RETURN;
      END IF;

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling GetNlrInfo(X_nlr,G_nlro_id) ';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
      GetNlrInfo( X_nlr, G_nlro_id );

      IF ( G_nlr_etype IS NULL ) THEN
          X_status := 'INVALID_NL_RSRC';
          pa_cc_utils.reset_curr_function;
          RETURN;
      ELSIF ( X_ei_date NOT BETWEEN  G_nlr_start
                         AND  nvl( G_nlr_end, X_ei_date ) ) THEN
          X_status := 'NL_RSRC_INACTIVE';
          pa_cc_utils.reset_curr_function;
          RETURN;
      ELSIF ( G_nlro_start IS NULL ) THEN
          X_status := 'ORG_NOT_OWNER_OF_NL_RSRC';
          pa_cc_utils.reset_curr_function;
          RETURN;
      ELSIF ( X_ei_date NOT BETWEEN  G_nlro_start
               AND  nvl( G_nlro_end, X_ei_date ) ) THEN
          X_status := 'ORG_NOT_OWNER_OF_NL_RSRC';
          pa_cc_utils.reset_curr_function;
          RETURN;
      ELSIF ( G_nlr_etype <> X_etype ) THEN
          X_status := 'NL_EXP_TYPE_DIFF';
          pa_cc_utils.reset_curr_function;
          RETURN;
      END IF;
    END IF;

    -- ===========================================================================
    --  Validation specific to BURDEN TRANSACTIONS
    --  If transactionsource.cost_burden_flag = 'N' then don't allow burden trans.
    --  If ProjectType.burden_cost_flag = 'N' then don't allow burden trans.
    --  If both qty and raw cost are non zero  then don't allow burden trans.
    --  If burdened cost is zero  then don't allow burden trans.

    IF   X_system_linkage = 'BTC' THEN

        /* Bug# 2063667 - If the transaction source is not Burdened but
           system linkage is BTC , then reject the transaction */
       /* Bug 2844973 Added g_trx_source <> 'ALLOCATIONS' condition */

      IF nvl(G_burdened_flag,'N') = 'N'  and g_trx_source <> 'ALLOCATIONS' THEN
         X_status := 'TRXSRC_NOTALLOW_BURDEN' ;
         pa_cc_utils.reset_curr_function;
         RETURN ;
      END IF ;

      --      IF G_proj_bcost_flag = 'N' THEN
      --         X_status := 'PROJ_NOTALLOW_BURDEN' ;
      --         RETURN ;
      --      END IF ;
      -- Multi-Currency changes. Changed raw_cost to denom_raw_cost
      --
      IF nvl(X_qty,0) <> 0  OR nvl(X_denom_raw_cost,0) <> 0 THEN
        X_status := 'INVALID_BURDEN_TRANS' ;
        pa_cc_utils.reset_curr_function;
        RETURN ;
      END IF ;

      --
      -- Multi-Currency Changes. Changes burdened_cost to denom_burdened-cost
      --
      IF X_denom_burdened_cost IS NULL THEN
         X_status := 'INVALID_BURDEN_AMOUNT' ;
         pa_cc_utils.reset_curr_function;
         RETURN ;
      END IF ;

    ELSE --  X_system_linkage <> 'BTC'

      IF ( G_trx_costed = 'Y' AND X_denom_raw_cost is NULL  ) THEN
          X_status := 'NO_RAW_COST';
          pa_cc_utils.reset_curr_function;
          RETURN;
      END IF ;

      -- Get compiled multiplier and compile set id for transaction sources
      -- that have allow_burden_flag set to N and gl_accounted_flag set to Y
      -- Bug: 979112: Get compiled multiplier only if the project type is
      --      defined with a burden schedule

      -- All the below logic is commented for 2798971 has been
      -- handled while calculating the Burdened cost.
      -- After this change Burden Cost is calculated by calling
      -- pa_cost_plus1.get_indirect_cost_import procedure.
      -- instead of compiled multiplier since this was leading to
      -- a penny difference in Burden cost and Accrued revenue.
/* --Commented code for Bug 2798971
      IF ( nvl(G_burdened_flag,'N') = 'N' ) AND
         ( nvl( G_gl_accted_flag,'N' ) = 'Y') AND
         ( nvl(G_proj_bcost_flag, 'N') = 'Y') THEN

         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling pa_cost_plus1.get_compile_set_info';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;
	 pa_cost_plus1.get_compile_set_info(
                        task_id             => G_task_id,
                        p_txn_interface_id  => X_txn_interface_id, -- added for bug 2563364
	                effective_date      => X_ei_date,
		 	expenditure_type    => X_etype,
			organization_id     => nvl(G_override_to_org_id, G_org_id),
			schedule_type       => 'C',
			Compiled_multiplier => G_compiled_multiplier,
			compiled_set_id     => G_burden_compile_set_id,
			status              => l_status_num,
			stage               => l_stage,
            x_cp_structure      => x_cp_structure -- Added for Bug 5743708,
            x_cost_base         => x_cost_base-- Added for Bug 5743708 );


         --   Bug: 925488 and 956683: get_compile_set_info calls get_cost_base. Get_cost_base
         --       returns status = 100 when a expenditure type is not defined with a
         --       cost base.  We should not return error when this happens.  Instead,
         --       we'll set compiled multiplier to 0 so when we calculate burdened cost,
         --       burdened_cost = raw_cost * (1 + compiled_multipler), burdened_cost
         --       will equal to raw_cost
         IF ( l_status_num <> 0 ) THEN
	   IF (l_status_num = 100) THEN
               G_compiled_multiplier := 0;
               G_burden_compile_set_id := to_number(NULL);
           ELSE
	       X_status := 'PA_ERR_IN_COST_PLUS';
               pa_cc_utils.reset_curr_function;
     	       RETURN;
           END IF;
         END IF;

        -- code added for the Bug #1428216 starts here
             IF (NVL(G_burden_amt_display_method,'S') = 'D' ) THEN
                     G_compiled_multiplier := 0;
             END IF;
        -- code added for the Bug #1428216 endss here

        --    Bug: 979112: If the project type is not defined with burden schedule,
        --                 then set compiled_multiplier equal to 0 because the
        --                 formula is burden_cost = raw_cost * (1 + multipler)
      ELSE
	 G_compiled_multiplier := 0;
         G_burden_compile_set_id := to_number(NULL);

      END IF;	-- End G_burdened_flag = N and G_gl_accted_flag =Y

 --Commented code for Bug 2798971 ends */

      -- If the transaction is burdened and does not have a burdened amount
      --        then reject the transaction

      IF nvl(G_burdened_flag,'N') = 'Y' AND
/*		nvl( X_denom_burdened_cost ,0 ) = 0  THEN       Commented for bug3144614       */
                X_denom_burdened_cost is NULL        THEN      /* Added for bug3144614 */
          X_status := 'INVALID_BURDEN_AMOUNT' ;
          pa_cc_utils.reset_curr_function;
          RETURN ;
      END IF; -- End

      /* Bug# 2063667 - If the transaction source is not Burdened and
      not externally gl accounted but burden amount is not null,
      then reject the transaction */

      IF (nvl(G_burdened_flag,'N') = 'N' AND
            nvl(G_gl_accted_flag,'N') = 'N' AND
                        X_denom_burdened_cost is NOT NULL) THEN
          X_status := 'TRXSRC_NOTALLOW_BURDEN';
          pa_cc_utils.reset_curr_function;
          RETURN ;
      END IF ;

      /* Bug# 2063667 - If the project type is not Burdened but burden
      amount is not null, then reject the transaction */

      /*Bug# 2448543 -If the project type is not burdened (which implies
        the defaulted burden amount should be equal to raw amount )but the
        burden amount is not equal to raw amount then reject the txn.*/

      /* Bug#2529120 - Added Check for Source Accounted Over fix done for 2448543
         For a Non Burdend Project, reject the transaction for the following conditions
         A. If Source is GL Unaccounted and denom burdened cost is not null
         B. If Source is GL accounted and denom burdened cost <> denom raw cost
      */
      /* Bug#2529120  -- Comment Code - Start
      IF (nvl(G_proj_bcost_flag,'N') = 'N' AND
            X_denom_burdened_cost <> X_denom_raw_cost) THEN           * 2448543*
         * X_denom_burdened_cost is NOT NULL) THEN -Commented for Bug# 2448543*
       Comment Code -- End -- Bug#2529120 */

      /* commented for Bug 3593432
      IF nvl(G_proj_bcost_flag,'N') = 'N' THEN
        IF ((nvl(G_gl_accted_flag,'N') = 'Y' AND X_denom_burdened_cost <> X_denom_raw_cost)
            OR (nvl(G_gl_accted_flag,'N') = 'N' AND X_denom_burdened_cost is NOT NULL)) THEN
                X_status := 'PROJ_NOTALLOW_BURDEN' ;
                pa_cc_utils.reset_curr_function;
                RETURN ;
        END IF; * Accted Flag IF *
      END IF ;
       commented for Bug 3593432 End */

      /* Added for Bug 3593432   */
      IF nvl(G_proj_bcost_flag,'N') = 'N' AND X_denom_burdened_cost <> X_denom_raw_cost THEN
                X_status := 'PROJ_NOTALLOW_BURDEN' ;
                pa_cc_utils.reset_curr_function;
                RETURN ;
      END IF ;
      /* Added for Bug 3593432  End  */


    END IF; -- End system_linkage <> BTC

    -- ============================================================================
    -- --------------------------------------------------------------------------
    -- Multi-Currency changes. calculating burden cost for accounted
    -- transactions.
    --
    -- Example: denom raw cost      acct_raw_cost   		proj_raw_cost
    --          ----------------     ------------------   -------------
    -- 	    	100 USD					120 BPL					120 BPL(derived)
    -- if acct_burdened_cost is null and denom_burdened_cost is 120 USD
    -- the acct_burdened_cost is derived by multiplying acct_raw_cost with the
    -- ratio of denom_burdened_cost and denom_raw_cost( for non BTC txns )
    -- for BTC txns since the denom_raw_cost will be zero(0), the func and proj
    -- Bcost are derrived by directly converting the denom_burden_cost using the
    -- project and functional currency conversion attributes.
    --
    -- For non BTC txns
    -- i.e acct_burdened_cost = (denom_burdened_cost/denom_raw_cost) * acct_raw_cost
    --     proj_burdened_cost = (denom_burdened_cost/denom_raw_cost) * proj_raw_cost
    --
    -- For BTC txns ( transaction raw cost = 0 )
    -- acct_burdened_cost = (transaction to functional curr conversion rate) *
    --                       transaction burdened cost
    -- project_burdened-cost = (transaction to project curr conversion rate)*
    --                       transaction burdened cost
    --
    -- if acct_burdened_cost is not null then
    -- derive proj_burdened_cost by multiplying project_raw_cost with the ratio
    -- of denom_burdened_cost and denom_raw_cost.
    --
    -- If allow_burden_flag is 'N' then the burden amounts
    -- are calculated by orcale projects(only for non BTC txns)

    -----------------------------------------------------------------------------

    IF ( nvl(G_gl_accted_flag,'N') = 'Y') THEN
       IF ( nvl(G_burdened_flag,'N') = 'N' ) THEN

          -- calculate the burden amount using the compiled multiplier derived
          -- from PA burden schedule for transactions accounted externally, txns
          -- that are not accounted externally, Oracle Projects costing programs
          -- will calculate the burdened costs.
          --

      /* --Commented code for Bug 2798971
          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Calling pa_currency.round_trans_currency_amt';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
          X_denom_burdened_cost := pa_currency.round_trans_currency_amt1(
          X_denom_raw_cost * (1 + G_compiled_multiplier ),X_denom_currency_code);

          X_acct_burdened_cost := pa_currency.round_currency_amt1(
                              X_acct_raw_cost * (1 + G_compiled_multiplier));

          X_project_burdened_cost := pa_currency.round_trans_currency_amt1(
                              X_project_raw_cost * (1 + g_compiled_multiplier),
                              X_projfunc_currency_code);

          X_actual_project_burdened_cost := pa_currency.round_trans_currency_amt1(
                              X_actual_project_raw_cost * (1 + g_compiled_multiplier),
                              X_project_currency_code);
	 --Commented code for Bug 2798971 ends*/

/* Added code for 2798971 */
	IF (nvl(G_proj_bcost_flag, 'N') = 'Y') THEN
          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Calling pa_cost_plus1.get_indirect_cost_import';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
	      pa_cost_plus1.get_indirect_cost_import (
				task_id		           => G_task_id,
                                p_txn_interface_id         => X_txn_interface_id, -- added for bug 3246794
				effective_date	           => X_ei_date,
				expenditure_type           => X_etype,
				organization_id            => nvl(G_override_to_org_id, G_org_id),
				schedule_type              => 'C',
				direct_cost                => X_actual_project_raw_cost,
				direct_cost_denom          => X_denom_raw_cost,
				direct_cost_acct           => X_acct_raw_cost,
				direct_cost_project        => X_project_raw_cost,
				indirect_cost_sum          => X_actual_project_burdened_cost,
				indirect_cost_denom_sum    => X_denom_burdened_cost,
				indirect_cost_acct_sum	   => X_acct_burdened_cost,
				indirect_cost_project_sum  => X_project_burdened_cost,
				l_projfunc_currency_code   => X_projfunc_currency_code,
				l_project_currency_code    => X_project_currency_code,
				l_acct_currency_code       => null,
				l_denom_currency_code      => X_denom_currency_code,
				Compiled_set_id		   => G_burden_compile_set_id,
				status                     => l_status_num,
				stage                      => l_stage);
--   Bug: 925488 and 956683: get_indirect_cost_import calls get_cost_base. Get_cost_base
--       returns status = 100 when a expenditure type is not defined with a
--       cost base.  We should not return error when this happens.  Instead,
--       burdened_cost = raw_cost , burdened_cost will equal to raw_cost

/* Error checking modified and added below. The checks are based on the
different values of status and stage returned by get_indirect_cost_import
		bug2837165 starts */

		IF ( l_status_num <> 0 ) THEN
		   IF (l_status_num = 100 AND l_stage = 300) THEN
		      G_compiled_multiplier := 0;
		      G_burden_compile_set_id := to_number(NULL);
		   elsif (l_status_num = 100) then
			if( l_stage = 100)then
			  X_status := 'NO_IND_RATE_SCH_REVISION';
		          pa_cc_utils.reset_curr_function;
		          RETURN;
			elsif (l_stage = 200) then
			 X_status := 'NO_COST_PLUS_STRUCTURE';
		         pa_cc_utils.reset_curr_function;
		         RETURN;
			elsif (l_stage = 400) then
			 X_status := 'NO_ACTIVE_COMPILED_SET';
		         pa_cc_utils.reset_curr_function;
		         RETURN;
			end if;
		   ELSE
		      X_status := 'PA_ERR_IN_COST_PLUS';
		      pa_cc_utils.reset_curr_function;
		      RETURN;
		   END IF;
		END IF;
/* bug2837165 ends */
	/* code added for the Bug #1428216 starts here*/
	/* If project is burdened on a different EI we are stamping the compile_set_id
	   but burden cost will be equal to raw costs. */
		IF (NVL(G_burden_amt_display_method,'S') = 'D' ) THEN
			G_compiled_multiplier := 0;
			X_denom_burdened_cost := X_denom_raw_cost;
			X_acct_burdened_cost := X_acct_raw_cost;
			X_project_burdened_cost := X_project_raw_cost;
			X_actual_project_burdened_cost := X_actual_project_raw_cost;
		ELSE
			/* code added for the Bug #1428216 ends here*/
			/* Code modified for 2798971. Added an ELSE condition */
			X_denom_burdened_cost := X_denom_burdened_cost + X_denom_raw_cost;
			X_acct_burdened_cost := X_acct_burdened_cost + X_acct_raw_cost;
			X_project_burdened_cost := X_project_burdened_cost + X_project_raw_cost;
			X_actual_project_burdened_cost := X_actual_project_burdened_cost + X_actual_project_raw_cost;
		END IF; -- IF (NVL(G_burden_amt_display_method,'S') = 'D' )
	ELSE
		G_compiled_multiplier := 0;
		G_burden_compile_set_id := to_number(NULL);
		X_denom_burdened_cost := X_denom_raw_cost;
		X_acct_burdened_cost := X_acct_raw_cost;
		X_project_burdened_cost := X_project_raw_cost;
		X_actual_project_burdened_cost := X_actual_project_raw_cost;
	END IF; -- IF (nvl(G_proj_bcost_flag, 'N') = 'Y') THEN
/* Added code for 2798971 ends */

       ELSIF ( nvl(G_burdened_flag,'N') = 'Y' ) THEN
          IF ( nvl(X_denom_raw_cost,0) = 0) THEN

             -- if the transaction raw cost is zero then calculate the
             -- functional and project BCost by using the conversion attributes.

             IF ( nvl(X_acct_burdened_cost,0) = 0 ) THEN

                -- initilize l_status
                l_status := NULL;

                IF PG_DEBUG = 'Y' THEN
                pa_debug.G_err_stage := 'Calling pa_multi_currency.convert_amount for functional currency';
                   log_message('log_message: ' || pa_debug.G_err_Stage);
                END IF;
	        pa_multi_currency.convert_amount(
                                P_from_currency         => X_denom_currency_code,
				P_to_currency           => G_accounting_currency_code,
				P_conversion_date       => X_acct_rate_date,
				P_conversion_type       => G_acct_rate_type,
				P_amount                => X_denom_burdened_cost,
		                P_user_validate_flag    => l_validate_user_rate_type,
	  			P_handle_exception_flag => l_handel_exception_flag,
				P_converted_amount      => X_acct_burdened_cost,
				P_denominator           => l_denominator,
				P_numerator             => l_numerator,
				P_rate                  => X_acct_exchange_rate,
	      		        X_status                => l_status);

	        IF ( l_status IS NOT NULL ) THEN
                     X_status := l_status;
                     pa_cc_utils.reset_curr_function;
                     RETURN;
	        END IF; -- End l_status IS NOT NULL

             END IF;-- End X_acct_burdened_cost = 0

             -- calculate the project Bcost using the project conversion attributes
             -- before calling convert_amount initilize l_status

             l_status := NULL;

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling pa_multi_currency.convert_amount for project currency';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;
	     pa_multi_currency.convert_amount(
                                P_from_currency         => X_denom_currency_code,
				P_to_currency           => X_project_currency_code,
				P_conversion_date       => X_project_rate_date,
				P_conversion_type       => G_project_rate_type,
				P_amount                => X_denom_burdened_cost,
		                P_user_validate_flag    => l_validate_user_rate_type,
	  			P_handle_exception_flag => l_handel_exception_flag,
			      --P_converted_amount      => X_project_burdened_cost,
                              --PA-I Changes : Project costs are calculated in x_actual_project.._cost
				P_converted_amount      => X_actual_project_burdened_cost,
				P_denominator           => l_denominator,
				P_numerator             => l_numerator,
				P_rate                  => X_project_exchange_rate,
			        X_status                => l_status);

	     IF ( l_status IS NOT NULL ) THEN
			X_status := l_status;
                        pa_cc_utils.reset_curr_function;
			RETURN;
	     END IF; -- End l_status IS NOT NULL

             -- PA-I Changes : Added below for Project Functional Burdened cost calculation
             -- calculate the project functional Bcost using the project functional conversion attributes
             -- before calling convert_amount initilize l_status

             l_status := NULL;

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling pa_multi_currency.convert_amount for project functional currency';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;
             pa_multi_currency.convert_amount(
                                P_from_currency         => X_denom_currency_code,
                                P_to_currency           => X_projfunc_currency_code,
                                P_conversion_date       => X_projfunc_cost_rate_date,
                                P_conversion_type       => G_projfunc_cost_rate_type,
                                P_amount                => X_denom_burdened_cost,
                                P_user_validate_flag    => l_validate_user_rate_type,
                                P_handle_exception_flag => l_handel_exception_flag,
                                P_converted_amount      => X_project_burdened_cost,
                                P_denominator           => l_denominator,
                                P_numerator             => l_numerator,
                                P_rate                  => X_projfunc_cost_exchange_rate,
                                X_status                => l_status);

             IF ( l_status IS NOT NULL ) THEN
                   X_status := l_status;
                   pa_cc_utils.reset_curr_function;
                   RETURN;
             END IF; -- End l_status IS NOT NULL

          ELSE -- i.e denom_raw_cost <> 0

             -- Multi-Currency changes.
             -- If the Trx Source indicates that the transaction is burdened then
             -- for accounted transactions, if the acct_burdened_cost is null or 0 then
             -- acct_burdened_cost is derived by multiplying the acct_raw_cost with
             -- denom_cost_ratio.

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling pa_currency.round_trans_currency_amt';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

             X_project_burdened_cost := pa_currency.round_trans_currency_amt1(
                              X_project_raw_cost *
                              (X_denom_burdened_cost/X_denom_raw_cost),
                              X_projfunc_currency_code);

             X_actual_project_burdened_cost := pa_currency.round_trans_currency_amt1(
                              X_actual_project_raw_cost *
                              (X_denom_burdened_cost/X_denom_raw_cost),
                              X_project_currency_code);

             IF ( nvl( X_acct_burdened_cost ,0 ) = 0  ) THEN
                 X_acct_burdened_cost := pa_currency.round_currency_amt1(
                                         X_acct_raw_cost * (X_denom_burdened_cost/X_denom_raw_cost));
             END IF; -- end acct_burdened_cost = 0
          END IF; -- End denom_raw_cost = 0
       END IF; -- end G_burdened_flag = N
    END IF; -- end G_gl_accted_flag = Y

    -- ===========================================================================
    --  If gl_accounted_flag = 'Y' then for each transaction we should have
    --   Valid dr_ccid, cr_ccid , gl_date.
    IF G_gl_accted_flag = 'Y' THEN

       IF (nvl(X_module, 'EXTERNAL') <> 'PAAPIMP') THEN
            --PA-J Receipt Accrual Changes : Added AP VARIANCE and PO RECEIPT transaction sources
            --PA-I Changes : Added Discounts for AP Discounts project

           IF Checkccid(X_drccid) IS NULL THEN
           pa_debug.G_err_stage := 'Calling Checkccid'; log_message(pa_debug.G_err_Stage);
              X_status := 'INVALID_DR_CCID' ;
              pa_cc_utils.reset_curr_function;
              RETURN ;
           END IF ;
           IF Checkccid(X_crccid) IS NULL THEN
              X_status := 'INVALID_CR_CCID' ;
              pa_cc_utils.reset_curr_function;
              RETURN ;
           END IF ;

           --
           --BUG : 4696351 PJ.R12:DI4:APLINES: VENDOR INFORMATION NOT IMPORTED DURING TRANSACTION IMPORT
           --
	       IF x_system_linkage = 'ER' and
		      g_vendor_id is NULL THEN

			  getvendorId(g_person_id) ;

			  IF g_vendor_id is NULL then
			     x_status := 'PA_INVALID_SUPPLIER_INFO';
                 pa_cc_utils.reset_curr_function;
		         RETURN;
			  END IF ;

		   END IF ;
       END IF;                                            -- Added for bug 1428539.

/* -- Commented for bug 3357936
          IF  G_gl_posted_flag = 'N' AND X_gl_date IS NULL THEN

                select set_of_books_id
                into l_SobId
                from pa_implementations_all
                where nvl(org_id,-99) = nvl(X_org_id,-99);

		X_gl_date := pa_utils2.get_prvdr_gl_date( X_ei_date, l_appl_id , l_SobId) ;

         END IF;
*/

       IF X_gl_date IS NULL THEN
         X_status := 'INVALID_GL_DATE' ;
           pa_cc_utils.reset_curr_function;
         RETURN ;
       END IF ;

       /*********EPP Changes. This code is commented, is moved after IC check*********
       --   Added the pa_date validation  fix  bug 572196. The for accounted items
       --   there should be a valid open/future pa_period
       --   Added the following function call calculate pa_date to Resolve Bug 1103257 base bug 967390
       *******************************************************************************/



    END IF ;

    -- ===========================================================================
    --   Verify that the transaction has not already been loaded into PA (no
    --   other expenditure items exist having the same TRANSACTION SOURCE and
    --   ORIG TRANSACTION REFERENCE)
    --

    IF G_allow_dup_flag <>  'Y' THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling CheckDupItem';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;
       CheckDupItem ( X_trx_src, X_trx_ref, temp_status );
       IF ( temp_status IS NOT NULL ) THEN
         X_status := temp_status;
         pa_cc_utils.reset_curr_function;
         RETURN;
       END IF;

    END IF ;

    -- ===========================================================================
    --   If the transaction is an adjustment (negative quantity) of a specific
    --   expenditure item (UNMATCHED_NEGATIVE_TXN_FLAG is 'N'), then verify that
    --   a matching expenditure item exists
    --
    --  Oracle Time and Labor(OTL)requires the ability to reverse an ei with a quantity = 0
    --  so only for OTL that option has been added.
    --  (X_match_flag = 'N' and nvl(X_module, 'EXTERNAL') =  'PAAPIMP' )
    --
    IF  ( ( X_qty < 0           and X_match_flag = 'N' ) OR
          ( X_match_flag = 'N'  and X_trx_src = 'ORACLE TIME AND LABOR' ) OR
          ( nvl(p_adj_exp_item_id,0) > 0  and nvl(X_module, 'EXTERNAL') =  'PAAPIMP') ) THEN

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling pa_adjustments.VerifyOrigItem';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

	  /* REL12 AP Lines Uptake */
	  IF ( p_adj_exp_item_id is not NULL and
	       nvl(X_module, 'EXTERNAL') =  'PAAPIMP' ) THEN
	       G_adj_item_id := p_adj_exp_item_id ;
	  ELSE

      G_adj_item_id := pa_adjustments.VerifyOrigItem(
                X_person_id => G_person_id
              , X_org_id => G_org_id
              , X_item_date => X_ei_date
              , X_task_id => G_task_id
              , X_exp_type => X_etype
              , X_system_linkage_function => X_system_linkage
              , X_nl_org_id => G_nlro_id
              , X_nl_resource => X_nlr
              , X_quantity => X_qty
              , X_denom_raw_cost => X_denom_raw_cost
              , X_trx_source => X_trx_src
              , X_denom_currency_code => X_denom_currency_code
              , X_acct_raw_cost => X_acct_raw_cost
              , X_reversed_orig_txn_reference => G_reversed_orig_txn_reference);
	  END IF ;

      IF ( G_adj_item_id IS NULL ) THEN

        X_status := 'NO_MATCHING_ITEM';
        pa_cc_utils.reset_curr_function;
        RETURN;

      ELSIF ( G_adj_item_id IS NOT NULL)  AND
	    ( X_module = 'PAXTRTRX'  OR X_module =  'PAAPIMP') THEN


        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling pa_adjustments.ExpAdjItemTab';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;
        pa_adjustments.ExpAdjItemTab(G_adj_item_id) := G_adj_item_id;

        -- Commenting out the following procedure because verifyorigitem
        -- already checks for adjusted ei's that are not yet inserted into
        -- database table( EI Table). Bug 752915

        -- CheckDupAdjItem( G_adj_item_id, temp_status );

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Locking adjusting item:'||to_char(G_adj_item_id);
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        BEGIN

          SELECT
                  expenditure_item_id
            INTO
                  dummy
            FROM
                  pa_expenditure_items
           WHERE
                  expenditure_item_id = G_adj_item_id
          FOR UPDATE NOWAIT;

        EXCEPTION
          WHEN  RESOURCE_BUSY  THEN
            temp_status := 'CANNOT_LOCK_ORIG_ITEM';
        END;
      END IF;

      IF ( temp_status IS NOT NULL ) THEN
        X_status := temp_status;
        pa_cc_utils.reset_curr_function;
        RETURN;
      END IF;

    END IF;

    -- ===========================================================================
    -- IC Changes
    --
    -- CAll Cross Charge identification API.  This API determines
    -- Provider Organization
    -- Receiver Organization,
    -- Cross charge code: Valid values are (B, I, N, X )
    --      B = Borrow and Lent , I = Inter Company, N= Not Cross charged
    --      X = Never Cross Charged
    --      The value of Cross charge code will be used to derive
    --      CC_BL_DISTRIBUTED_CODE and CC_IC_PROCESSED_CODE.
    --
    -- Receiver operating uint,
    -- Cross charge type: VAlid values are ( IU, IC, IO )
    --      IU = Cross Charge across operating units within one legal entity
    --      IC = Cross Charge across operating units across legal entities
    --      IO = Cross charge with in one Operating unit( Borrow and lent )
    --
    -- The cross charge identification is usually done by costing progarm
    -- However for accounted txns are not picked up by costing programs, hence
    -- transaction import should identify cross charge txns.

    --       Initilize the package body global variables before calling the
    --       CC Identification API.

    G_CrossChargeType := 'NO';
    G_CrossChargeCode := 'P';
    G_PrvdrOrganizationId := NULL;
    G_RecvrOrganizationId := NULL;
    G_RecvrOrgId := NULL;
    G_BrowLentDistCode := 'X';
    G_IcProcessed_Code := 'X';

    /* Added g_trx_costed in if condition for bug 1897348*/
    IF (( nvl(G_gl_accted_flag,'N') = 'Y') OR
	      (nvl(G_trx_costed,'N') = 'Y')) THEN

          <<Cc_Identification_Api>>
          BEGIN

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Calling PA_CC_IDENT.PA_CC_IDENTIFY_TXN_ADJ';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          PA_CC_IDENT.PA_CC_IDENTIFY_TXN_ADJ(
          -- Changed the follwing NVL as the G_override_to_org_id should always
		  -- take precedence over G_org_id bug #4689402 (forward port for 4614046)
          P_ExpOrganizationId     => NVL(G_override_to_org_id, G_org_id), --For 1612483
          P_ExpOrgid              => X_org_id , -- bug 1612483
          P_ProjectId             => G_project_id,
          P_TaskId                => G_task_id,
          P_ExpItemDate           => X_ei_date,
	  /* Passing TXN_INTERFACE_ID instead of null for 3234973
	  and calling_module as 'TRANSACTION_IMPORT' */
          /* P_ExpItemId             => NULL, */
	  P_ExpItemId             => X_txn_interface_id,
          P_ExpType               => X_etype,
          P_PersonId              => G_person_id ,
          P_SysLink               => X_system_linkage,
          P_PrjOrganizationId     => NULL,
          P_PrjOrgId              => NULL,
          P_TransSource           => X_trx_src,
          P_NLROrganizationId     => G_nlro_id,
          P_PrvdrLEId             => NULL,
          P_RecvrLEId             => NULL,
          X_Status                => X_Status,
          X_CrossChargeType       => G_CrossChargeType,
          X_CrossChargeCode       => G_CrossChargeCode,
          X_PrvdrOrganizationId   => G_PrvdrOrganizationId,
          X_RecvrOrganizationId   => G_RecvrOrganizationId,
          X_RecvrOrgId            => G_RecvrOrgId,
          X_Error_Stage           => temp_dff_msg,
          X_Error_Code            => temp_status,
 	  /* Added calling module for 3234973, so that client extention can function correctly. */
	  X_Calling_Module        => 'TRANSACTION_IMPORT');

          EXCEPTION WHEN others THEN
             IF PG_DEBUG = 'Y' THEN
                log_message('log_message: ' || pa_debug.G_err_stack,1);
                log_message('log_message: ' || SQLERRM,1);
                log_message('log_message: ' || pa_debug.G_err_stage,1);
             END IF;
             X_Status := 'PA_ERR_IN_CC_IDENT_API';
             pa_cc_utils.reset_curr_function;
             RETURN;
          END Cc_Identification_Api;

          --   if an error has occured in CC identification API, the
          --   X_Status variable will be populated with the error code.
         IF ( X_Status IS NOT NULL ) THEN
            pa_cc_utils.reset_curr_function;
            RETURN;
         ELSE -- i.e. successful completion

            IF ( G_CrossChargeCode = 'B' ) THEN

               -- Brrowed and lent processing
               -- The EI will be marked for
               -- borrow and lent processing

               G_BrowLentDistCode     := 'N';
               G_IcProcessed_Code     := 'X';

            ELSIF ( G_CrossChargeCode = 'I' ) THEN

               -- Inter company processing
               -- the Ei will be marked for IC processing

               G_BrowLentDistCode     := 'X';
               G_IcProcessed_Code     := 'N';

            ELSE
               -- No Cross Charge processing

               G_BrowLentDistCode     := 'X';
               G_IcProcessed_Code     := 'X';

            END IF; -- end G_CrossChargeCode = 'B'
         END IF; -- End X_status is not null

         --   Added the following function call calculate recvr_pa_date to Resolve Bug # 1653831

         /*  EPP Changes: Moved recvr_pa_date derivation after this section */

         --   End of code for Bug # 1653831
         /* IC Change: we need to get receiver org ID regarldess
            of accounted or unaccounted transaction.  For accounted
            case, we call PA_CC_IDENT.pa_cc_identify_txn_adj to
            get receiver org ID along with other info.  For
            unaccounted case, we call PA_UTILS2.GetPrjOrgId to get
            only the reciever org id info.  */
    ELSE
  	/* IC Changes: Get receiver organization ID */
        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling PA_UTILS2.GetPrjOrgId';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;
        G_RecvrOrgId := PA_UTILS2.GetPrjOrgId(p_project_id => G_project_id,
                                              p_task_id    => NULL);
    END IF; -- End gl_accted_flag = Y
    -- ==========================================================================

    /***********Start EPP CHANGES. Added call to get period information*************/

    G_PaDate            := NULL;
    G_PaPeriodName      := NULL;
    G_RecvrPaDate       := NULL;
    G_RecvrPaPeriodName := NULL;
    G_GlPeriodName      := NULL;
    G_RecvrGlDate       := NULL;
    G_RecvrGlPeriodName := NULL;
    G_SobId             := NULL;
    G_RecvrSobId        := NULL;

    /*  PA-J Period-End Accrual Changes :
                   Need to retrieve set_of_books information for provider
                   and receiver orgs when gl_accted_flag is Y and also
                   for unaccounted period-end accrual transactions.
                   A miscellaneous transaction (system_linkage = PJ) with the
                   accrual_flag set to Y is a period-end accrual transaction.
                   For period-end accrual transaction the period information
                   is retrieved from a new API get_accrual_period_information.
    */

    G_GlDate          := NULL;
    G_AccDate         := NULL;
    G_RecvrAccDate    := NULL;
    G_RevAccDate      := NULL;
    G_RevRecvrAccDate := NULL;
    G_RevPaDate       := NULL;
    G_RevPaPeriodName := NULL;
    G_RevGlDate       := NULL;
    G_RevGlPeriodName := NULL;
    G_RevRecvrPaDate  := NULL;
    G_RevRecvrPaPdName:= NULL;
    G_RevRecvrGlDate  := NULL;
    G_RevRecvrGlPdName:= NULL;
    l_period_end_txn  := 'N';

    --Identify if the transaction is a period-end accrual transaction
    IF (x_system_linkage = 'PJ' and x_accrual_flag = 'Y') THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'This is a Period-End Accrual transaction';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       l_period_end_txn := 'Y';

    END IF;

    --If transaction is accounted then derive the provider and receiver set of books information.
    IF ( nvl(G_gl_accted_flag,'N') = 'Y' or l_period_end_txn = 'Y') THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Retrieve provider and receiver set_of_books';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       log_message('log_message: x_org_id= ' || X_org_id || ' Prev = '|| Prev_OrgId); -- For bug 3590027
       if (nvl(X_org_id,-101) <> nvl(Prev_OrgId,-99)) then   -- Added nvl to X_org_id for bug 3590027

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Diff org_id';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          select set_of_books_id
          into G_SobId
          from pa_implementations_all
          where org_id = X_org_id;

          Prev_SobId := G_SobId;
          Prev_OrgID := X_Org_Id;
       else

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Same org_id';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          G_SobId := Prev_SobId;
       end if;

       --IF (nvl(Prev_SobId,-101) <> nvl(G_SobId,-99)) THEN
       --  SELECT NVL(sla_ledger_cash_basis_flag,'N')
       --    INTO G_cash_based_accounting
       --    FROM gl_sets_of_books
       --   WHERE set_of_books_id = G_SobId;
       --
       --END IF;

   log_message('log_message: G_RecvrOrgId= ' || G_RecvrOrgId || ' Prev = '|| Prev_RecvrOrgId);--Bug 3590027
       if (nvl(G_RecvrOrgId,-101) <> nvl(Prev_RecvrOrgId,-99)) then -- Added nvl to G_RecvrOrgId for 3590027

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Diff recvr_org_id';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          select set_of_books_id
          into G_RecvrSobId
          from pa_implementations_all
          where org_id = nvl(G_RecvrOrgId,-99);

          Prev_RecvrSobId := G_RecvrSobId;
          Prev_RecvrOrgID := G_RecvrOrgId;
       else

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Same recvr_org_id';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          G_RecvrSobId := Prev_RecvrSobId;
       end if;

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'Prvdr Sob ID = ' || G_SobId);
          log_message('log_message: ' || 'Recvr Sob ID = ' || G_RecvrSobId);
       END IF;
    END IF;

    --If transaction is an accounted, non-period end accrual transaction then call
    --pa_integration.get_period_information to derive the period information.
    IF ( (nvl(G_gl_accted_flag,'N') = 'Y') and (l_period_end_txn = 'N')) THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Start PA_Date and Recvr_PA_Date Checks for non-period-end accrual txns';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling pa_integration.get_period_information';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       pa_integration.get_period_information(
                 p_expenditure_item_date  => X_ei_date
                ,p_prvdr_gl_date          => X_gl_date
                ,x_recvr_gl_date          => G_RecvrGlDate
                ,p_line_type              => 'R'
                ,p_prvdr_org_id           => X_org_id
                ,p_recvr_org_id           => G_RecvrOrgId
                ,p_prvdr_sob_id           => G_SobId
                ,p_recvr_sob_id           => G_RecvrSobId
                ,x_prvdr_pa_date          => G_PaDate
                ,x_prvdr_pa_period_name   => G_PaPeriodName
                ,x_prvdr_gl_period_name   => G_GlPeriodName
                ,x_recvr_pa_date          => G_RecvrPaDate
                ,x_recvr_pa_period_name   => G_RecvrPaPeriodName
                ,x_recvr_gl_period_name   => G_RecvrGlPeriodName
                ,x_return_status          => x_return_status
                ,x_error_code             => x_error_code
                ,x_error_stage            => x_error_stage);

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'G_OrgID = '|| X_org_id || ' G_RecvrOrgId = '|| G_RecvrOrgId || ' X_ei_date = '|| X_ei_date);
         log_message('log_message: ' || 'G_PaDate = '|| G_PaDate || ' G_PaPeriodName = '|| G_PaPeriodName);
         log_message('log_message: ' || 'G_GlDate = '|| X_gl_date || ' G_GlPeriodName = '|| G_GlPeriodName);
         log_message('log_message: ' || 'G_RecvrPaDate = '|| G_RecvrPaDate || ' G_RecvrPeriodName = '|| G_RecvrPaPeriodName);
         log_message('log_message: ' || 'G_RecvrGlDate = '|| G_RecvrGlDate || ' G_RecvrGlPeriodName = '|| G_RecvrGlPeriodName);
      END IF;

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'After pa_integration.get_period_information';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      --Pa_date check being done here
      IF G_PaDate is NULL then

         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'PA_Date is null';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

         X_status := 'INVALID_PA_DATE' ;
         pa_cc_utils.reset_curr_function;
         RETURN ;

      END IF ;

      IF   nvl(X_org_id,-999) <> nvl(G_RecvrOrgId,-999) THEN ----------------------{

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Before Check for the Receiver Date';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       IF G_RecvrPaDate is NULL then

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Recvr_PA_Date is null';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          X_status := 'INVALID_RECVR_PA_DATE' ;
          pa_cc_utils.reset_curr_function;
          RETURN ;

       END IF ;

       IF G_RecvrGlDate is NULL then

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Recvr_GL_Date is null';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          X_status := 'INVALID_RECVR_GL_DATE' ;
          pa_cc_utils.reset_curr_function;
          RETURN ;

       END IF ;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'After Check for the Receiver Date';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

      END IF ;                                  ----------------------------------}

    END IF;  --Accted = Y and Period_End = N

    --If transaction is accounted or unaccounted, period end accrual transaction then call
    --pa_utils2.get_period_information to derive the accrual period information for the original
    --and reversing line.
    IF ( l_period_end_txn = 'Y' ) THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Start PA_Date and Recvr_PA_Date Checks for period-end accrual txns';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling pa_utils2.get_accrual_period_information';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       G_GlDate  := X_gl_date;

       --Call get_accrual_period_information API for the original line
       pa_utils2.get_accrual_period_information (
                p_expenditure_item_date   => X_ei_date                 --in
               ,x_prvdr_accrual_date      => G_AccDate                 --in/out. For original item this is passed OUT
               ,x_recvr_accrual_date      => G_RecvrAccDate            --in/out. For original item this is passed OUT
               ,p_prvdr_org_id            => X_org_id                  --in
               ,p_recvr_org_id            => G_RecvrOrgId              --in
               ,p_prvdr_sob_id            => G_SobId                   --in
               ,p_recvr_sob_id            => G_RecvrSobId              --in
               ,p_calling_module          => 'TRXIMPORT'               --in
               ,x_prvdr_pa_date           => G_PaDate                  --out
               ,x_prvdr_pa_period_name    => G_PaPeriodName            --out
               ,x_prvdr_gl_date           => G_GlDate                  --in/out. This is passed IN if accounted. Unaccounted, it will be null
               ,x_prvdr_gl_period_name    => G_GlPeriodName            --out
               ,x_recvr_pa_date           => G_RecvrPaDate             --out
               ,x_recvr_pa_period_name    => G_RecvrPaPeriodName       --out
               ,x_recvr_gl_date           => G_RecvrGlDate             --out
               ,x_recvr_gl_period_name    => G_RecvrGlPeriodName       --out
               ,p_adj_ei_id               => null                      --in
               ,p_acct_flag               => nvl(G_gl_accted_flag,'N') --in
               ,x_return_status           => l_ret_sts                 --out
               ,x_error_code              => x_error_code              --out
               ,x_error_stage             => x_err_stage               --out
               );

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'Prvdr Acc Date = ' || G_AccDate || ' Recvr Acc Date = ' || G_RecvrAccDate);
       END IF;

       if (nvl(G_gl_accted_flag,'N') = 'Y') then
          IF PG_DEBUG = 'Y' THEN
             log_message('log_message: ' || 'Prvdr Gl Date = ' || G_GlDate || ' Prvdr Gl Pd Name = ' || G_GlPeriodName);
             log_message('log_message: ' || 'Recvr Gl Date = ' || G_RecvrGlDate || ' Recvr Gl Pd Name = ' || G_RecvrGlPeriodName);
             log_message('log_message: ' || 'Prvdr PA Date = ' || G_PaDate || ' Prvdr PA Pd Name = ' || G_PaPeriodName);
             log_message('log_message: ' || 'Recvr PA Date = ' || G_RecvrPaDate || ' Recvr PA Pd Name = ' || G_RecvrPaPeriodName);
          END IF;
       end if;

       if (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) then
          x_status := x_error_code;
          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Error returned for accrual date derivation = '||x_status;
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
          pa_cc_utils.reset_curr_function;
          RETURN;
       end if;

       --We copy the original item's accrual date for provider and
       --receiver to the reversing item variables.
       --For reversing item the original item's accrual date is passed
       --in and the reversing item's accrual date is passed out.
       G_RevAccDate      := G_AccDate;
       G_RevRecvrAccDate := G_RecvrAccDate;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling pa_utils2.get_accrual_period_information for the reversing line';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;


       --Call get_accrual_period_information API for the reversing line
       pa_utils2.get_accrual_period_information (
                p_expenditure_item_date   => X_ei_date
               ,x_prvdr_accrual_date      => G_RevAccDate              --in/out (both)
               ,x_recvr_accrual_date      => G_RevRecvrAccDate         --in/out (both)
               ,p_prvdr_org_id            => X_org_id
               ,p_recvr_org_id            => G_RecvrOrgId
               ,p_prvdr_sob_id            => G_SobId
               ,p_recvr_sob_id            => G_RecvrSobId
               ,p_calling_module          => 'TRXIMPORT'
               ,x_prvdr_pa_date           => G_RevPaDate
               ,x_prvdr_pa_period_name    => G_RevPaPeriodName
               ,x_prvdr_gl_date           => G_RevGlDate               --in/out (passed OUT for reversing item)
               ,x_prvdr_gl_period_name    => G_RevGlPeriodName
               ,x_recvr_pa_date           => G_RevRecvrPaDate
               ,x_recvr_pa_period_name    => G_RevRecvrPaPdName
               ,x_recvr_gl_date           => G_RevRecvrGlDate
               ,x_recvr_gl_period_name    => G_RevRecvrGLPdName
               ,p_adj_ei_id               => 99                        --dummy value to be passed
               ,p_acct_flag               => nvl(G_gl_accted_flag,'N')
               ,x_return_status           => l_ret_sts
               ,x_error_code              => x_error_code
               ,x_error_stage             => x_err_stage
               );

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'Prvdr Acc Date = ' || G_RevAccDate || ' Recvr Acc Date = ' || G_RevRecvrAccDate);
       END IF;

       if (nvl(G_gl_accted_flag,'N') = 'Y') then
          IF PG_DEBUG = 'Y' THEN
             log_message('log_message: ' || 'Prvdr Gl Date = ' || G_RevGlDate || ' Prvdr Gl Pd Name = ' || G_RevGlPeriodName);
             log_message('log_message: ' || 'Recvr Gl Date = ' || G_RevRecvrGlDate || ' Recvr Gl Pd Name = ' || G_RevRecvrGlPdName);
             log_message('log_message: ' || 'Prvdr PA Date = ' || G_RevPaDate || ' Prvdr PA Pd Name = ' || G_RevPaPeriodName);
             log_message('log_message: ' || 'Recvr PA Date = ' || G_RevRecvrPaDate || ' Recvr PA Pd Name = ' || G_RevRecvrPaPdName);
          END IF;
       end if;

       IF (l_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN
          x_status := x_error_code;
          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Error returned for reversal line accrual date derivation = '||x_status;
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
          pa_cc_utils.reset_curr_function;
          RETURN;
       END IF;

    END IF;      -- Period_End = Y accrual txn period derivation

    /***********End EPP CHANGES. Added call to get period information*************/

    /*=========Start Assignment_Id, Work_Type_Id Checks========================*/

    -- PA-I Changes
    -- Assignment_Id and Work_Type_Id derivation/validation checks

    -- PA-J Txn Ctrl Changes
    -- Assignment Id will now be derived for Expense Reports (system_linkage of ER)
    -- The derivation of assignment id for ER is done in pa_utils4.

    -- PA-K Changes: For pre-defined sources the values in assignment_name and
    -- work_type_name will be ignored. If ids are given they will used else it will be derived.
    -- For user defined sources ids will be ignored and the names if given will be validated

    If (G_trx_predef_flag = 'Y') Then

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Get Assignment and work type for predefined';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       If (x_system_linkage in ('ST', 'OT', 'ER')) Then

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Sys Link is ST OT ER';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          If (P_Assignment_Id is not null) Then

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'P_Assignment_id is not null';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

             G_Assignment_Id := P_Assignment_Id;

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'G_Assignment_Id = ' || G_Assignment_Id;
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

          Else

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'P_Assignment_id is null';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

             G_Assignment_Id := pa_utils4.get_assignment_id(
                                  p_person_id   => G_Person_Id
                                 ,p_project_id  => G_Project_Id
                                 ,p_task_id     => G_Task_Id
                                 ,p_ei_date     => X_Ei_Date);

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'G_Assignment_Id = ' || G_Assignment_Id;
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

          End If;

       Else

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Sys Link is not ST OT ER';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          G_Assignment_Id := NULL;

       End If;

       /*Bug# 2737538:Added check of profile option value for deriving work type */
/*       If (nvl(pa_utils4.is_exp_work_type_enabled,'N') = 'Y') Then ** moved condition below bug 3104004 */

          If (P_Work_Type_Id is not null) Then

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'P_Work_Type_Id is not null';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

             G_Work_Type_Id := P_Work_Type_Id;

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'G_Work_Type_Id = ' || G_Work_Type_Id;
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

          Else

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'P_Work_Type_Id is null';
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

             G_Work_Type_Id := pa_utils4.get_work_type_id(
                                 p_project_id     => G_Project_Id
                                 ,p_task_id        => G_Task_Id
                                 ,p_assignment_id  => nvl(G_Assignment_Id,0));

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'G_Work_Type_Id = ' || G_Work_Type_Id;
                log_message('log_message: ' || pa_debug.G_err_Stage);
             END IF;

             If (G_Work_Type_Id is NULL and nvl(pa_utils4.is_exp_work_type_enabled,'N') = 'Y') Then
                                                        /*** added and condition bug 3104004 */
                X_Status := 'INVALID_WORK_TYPE';
                pa_cc_utils.reset_curr_function;
                Return;
             End If;

          End If;

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Get Tp Amt Type';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          G_Tp_Amt_Type_Code := pa_utils4.get_tp_amt_type_code(
                                  p_work_type_id => G_Work_Type_Id);

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'G_Tp_Amt_Type_Code = ' || G_Tp_Amt_Type_Code;
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

       /**End If;** commented bug 3104004 */ /*Bug# 2737538 wrapped tp_amt_type_code and work_type related calls if work type profile is enabled*/

    Else

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling API to derive/validate assignment and work type info';
          log_message('log_message: ' || pa_debug.G_err_Stage);
          log_message('log_message: ' || 'Assignment Name = ' || X_Assignment_Name || ' Work Type Name = ' || X_Work_Type_Name);
       END IF;

       pa_utils4.get_work_assignment(
	 p_person_id          => G_Person_Id
       , p_project_id         => G_Project_Id
       , p_task_id            => G_Task_Id
       , p_ei_date            => X_Ei_Date
       , p_system_linkage     => x_system_linkage
       , x_assignment_id      => G_Assignment_Id
       , x_assignment_name    => X_Assignment_Name
       , x_work_type_id       => G_Work_Type_Id
       , x_work_type_name     => X_Work_Type_Name
       , x_tp_amt_type_code   => G_Tp_Amt_Type_Code
       , x_return_status      => l_asgn_work_ret_sts
       , x_error_message_code => l_asgn_work_err_msg);

       --PA-J Txn Ctrl changes: Added ER to the below check.
       if (x_system_linkage not in ('ST', 'OT', 'ER')) then
          G_Assignment_Id := null;
       end if;

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'Assignment Id = ' || G_Assignment_Id || ' Work Type Id = ' || G_Work_Type_Id ||
                            ' Tp Amt Type = ' || G_Tp_Amt_Type_Code);
       END IF;

       IF (l_asgn_work_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Get Work Type and Assignment API failed';
             log_message('log_message: ' || pa_debug.G_err_Stage);
             log_message('log_message: ' || 'Ret Sts = ' || l_asgn_work_ret_sts || ' Error = ' || l_asgn_work_err_msg);
          END IF;

          X_Status := l_asgn_work_err_msg;
          pa_cc_utils.reset_curr_function;
          RETURN;

       END IF;

    End If;

    /*=========End Assignment_Id, Work_Type_Id Checks==========================*/

    --PA-K Changes + bug 2634812
    --Bug 2688926: Reverted 2634812, removed  the check on total_burden_flag project type option
    --For transactions that are externally burdened or externally accounted
    --If project is burdened then set the compiled_set_id to -1 if it is null
    --Also see PAXTRANB.pls 115.41, where cost_burden_distributed_flag is
    --based on the value of compiled_set_id
    If (nvl(G_burdened_flag,'N') = 'Y') OR (nvl(G_gl_accted_flag,'N') = 'Y') Then

       If nvl(G_Proj_bcost_flag,'N') = 'Y' Then

          If G_burden_compile_set_id is NULL Then

             G_burden_compile_set_id := -1;

          End If;

       End If;

    End If;

 -- ==========================================================================
    -- The following section of the code performs valdiations specific to contingent worker timecards
    --  with purchase order integration for cwk. This is being placed before validate_transaction call since
    -- we need to pass po_header_id and po_line_id to validate_transaction and if not provided, these
    -- will be derived by the PO api validate_temp_labor_po

  IF nvl(P_Person_Type,'EMP') IN ('EMP','CWK') THEN
          null;
  ELSE
   	      X_status := 'INVALID_PERSON_TYPE';
          pa_cc_utils.reset_curr_function;
          RETURN;
  END IF;

  IF ((P_po_number is not null OR P_Po_Line_Num is not null OR
         P_Po_Header_Id is not null OR P_Po_Line_Id is not null) AND
          x_system_linkage in ('ST','OT'))
  THEN


	   IF PG_DEBUG = 'Y' THEN
		  pa_debug.G_err_stage := 'If any of the PO attributes are not null';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

               IF Pa_Pjc_CWk_Utils.Is_CWK_TC_Xface_Allowed(G_Project_Id) <> 'Y' THEN
                    X_Status := 'PA_CWK_TC_NOT_ALLOWED';
                    pa_cc_utils.reset_curr_function;
                    RETURN;
    		    ELSIF (( nvl(G_gl_accted_flag,'N') = 'Y') OR (nvl(G_trx_costed,'N') = 'Y')) THEN
                    X_status := 'PA_CWK_PO_COSTED_NOTSUP';
                    pa_cc_utils.reset_curr_function;
                    RETURN;
              ELSIF nvl(p_person_type,'EMP') = 'EMP' THEN
                    X_status := 'PA_EMP_PO_NOTSUP';
                    pa_cc_utils.reset_curr_function;
                    RETURN;
              END IF;

       IF PG_DEBUG = 'Y' THEN
		  pa_debug.G_err_stage := 'Calling PO Validation api';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

	   PO_PA_INTEGRATION_GRP.validate_temp_labor_po (
				P_Api_Version => 1.0,
				P_Project_Id => G_project_id,
				P_Task_Id => G_task_id,
				P_Po_Number => P_po_number,
				P_Po_Line_Num => P_Po_Line_Num,
				P_Price_Type => P_po_price_type,
				P_Org_Id => X_org_id,
				P_Person_Id => G_person_id,
                                P_effective_date => X_EI_date, -- added for bug 4155220
				P_Po_Header_Id => P_Po_Header_Id,
				P_Po_Line_Id => P_Po_Line_Id,
				X_Po_Line_Amt	=> G_Po_Line_Amt,
				X_Po_Rate => l_po_rate,
				X_Currency_Code => X_denom_currency_code,
				X_Curr_Rate_Type => X_acct_rate_type,
				X_Curr_Rate_Date => X_acct_rate_date,
				X_Currency_Rate => X_acct_exchange_rate,
				X_Vendor_Id =>   G_vendor_id,
				X_Return_StatuS => temp_msg_type,
				X_Message_Code => temp_status);

	   G_acct_rate_type := X_acct_rate_type; -- Bug: 3570261


	   IF PG_DEBUG = 'Y' THEN
		pa_debug.G_err_stage := 'After PO_PA_INTEGRATION_GRP.validate_temp_labor_po ';
        log_message('log_message: ' || pa_debug.G_err_Stage);
	   END IF;

	   IF temp_status IS NOT NULL  THEN
         IF PG_DEBUG = 'Y' THEN
			  pa_debug.G_err_stage := 'validate_temp_labor_po has failed';
			  log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

         X_status := temp_status;
         pa_cc_utils.reset_curr_function;
         RETURN;
	   END IF;

  /* po amount check */

       IF nvl(l_po_rate,0) = 0 THEN
         X_status := 'INVALID_PO_RATE';
         pa_cc_utils.reset_curr_function;
         RETURN;
       END IF;

       l_Calc_Amt := X_qty * l_po_rate;




		/* Bug 4098920
		select sum(denom_raw_cost)
		into l_costed
		from pa_expenditure_items ei, pa_expenditures exp
		where ei.cost_distributed_flag = 'Y'
		and ei.project_id = G_project_id
		and ei.task_id = G_task_id
		and ei.po_line_id = P_Po_Line_Id
		and ei.system_linkage_function in ('ST','OT')
		and ei.expenditure_id = exp.expenditure_id
		and exp.person_type = 'CWK';
		*/


		/*
		select sum(quantity)*l_po_rate
		into l_uncosted
		from pa_expenditure_items ei, pa_expenditures exp
		where ei.cost_distributed_flag = 'N'
		and ei.project_id = G_project_id
		and ei.task_id = G_task_id
		and ei.po_line_id = P_Po_Line_Id
		and ei.system_linkage_function in ('ST','OT')
		and ei.expenditure_id = exp.expenditure_id
		and exp.person_type = 'CWK';
		*/

		/* Bug 4098920
		Select Sum ( Quantity * PA_TRX_IMPORT.GET_PO_PRICE_TYPE_RATE (Project_id , Task_Id , P_Po_Line_Id , po_price_type ) )
		into l_uncosted
		From
		(
		select ei.project_id , ei.task_id , ei.po_price_type , sum(quantity)  Quantity
		from pa_expenditure_items ei, pa_expenditures exp
		where ei.cost_distributed_flag = 'N'
		and ei.project_id = G_project_id
		and ei.task_id = G_task_id
		and ei.po_line_id = P_Po_Line_Id
		and ei.system_linkage_function in ('ST','OT')
		and ei.expenditure_id = exp.expenditure_id
		and exp.person_type = 'CWK'
		Group By ei.project_id , ei.task_id , ei.po_price_type
		);
		*/


		/* Bug 4098920 : Combined the SQLs for Costed and Uncosted EI */
		If  Is_Po_Line_Task_Processed ( P_Po_Line_Id, G_task_id ) = False Then
				Select Sum (
						Decode ( cost_distributed_flag,
									'N', Quantity * PA_TRX_IMPORT.GET_PO_PRICE_TYPE_RATE (G_project_id , G_task_id  , P_Po_Line_Id , po_price_type ), 0

								)
						) ,
						Sum (
						Decode ( cost_distributed_flag,
									'Y', denom_raw_cost, 0
								)
						)
				Into l_uncosted, l_costed
				From
				(
				select ei.po_price_type ,  ei.cost_distributed_flag,
										   Sum(Decode(ei.cost_distributed_flag, 'N', ei.quantity,0))  Quantity,
										   Sum(Decode(ei.cost_distributed_flag, 'Y', ei.denom_raw_cost,0))  denom_raw_cost
				from pa_expenditure_items ei, pa_expenditures exp
				where  ei.project_id = G_project_id
				and ei.task_id = G_task_id
				and ei.po_line_id = P_Po_Line_Id
				and ei.system_linkage_function in ('ST','OT')
				and ei.expenditure_id = exp.expenditure_id
				and exp.person_type = 'CWK'
				Group By ei.po_price_type , ei.cost_distributed_flag
				);

		Else
			l_uncosted := 0;
			l_costed := 0;
		End If;

		IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Get the Processed Amount for Line ID : '||P_Po_Line_Id || ' and Task ID '||G_task_id;
          log_message('log_message: ' || pa_debug.G_err_stage,1);
        END IF;

	    po_processed_amt_chk(P_Po_Line_Id   => P_Po_Line_Id
                           ,P_Task_Id      => G_task_id
                           ,P_Calc_Amt     => l_Calc_Amt + nvl(l_uncosted,0) + nvl(l_costed,0)
                           ,X_processed_amt => l_processed_cost
                           ,X_status => temp_status);

        IF temp_status IS NOT NULL  THEN
          IF PG_DEBUG = 'Y' THEN
			  pa_debug.G_err_stage := 'po_processed_amt_chk unable to get a lock';
			  log_message('log_message: ' || pa_debug.G_err_Stage);
		  END IF;
          X_status := temp_status;
          pa_cc_utils.reset_curr_function;
          RETURN;
	    END IF;

		IF 0 <= (nvl(G_Po_Line_Amt,0) - nvl(l_processed_cost,0)) then /* Bug 4098920 */
			l_cwk_amt_updated := 'Y' ;
	    else
			x_status := 'INSUFFICIENT_PO_AMOUNT';

         /* Undo changes that are done by po_processed_amt_chk ***/
	       undo_processed_amt_chk(P_Po_Line_Id
                              ,G_Task_Id    /* Bug # 3609926 : Changed to G_TASK_ID from P_TASK_ID */
                              ,l_Calc_Amt ) ;
		    pa_cc_utils.reset_curr_function;
			RETURN;
	    END IF;

		/* po amount check */

    END IF; /* po attributes are not null */

    /* Bug # 3639470 : Vendor ID is not populated in case of UnAccounted/Uncosted ERs */

	If x_system_linkage =  'ER' And NVL(P_Person_Type,'EMP') = 'CWK'  AND
	( NVL(G_trx_costed,'N') <> 'Y' OR NVL(G_gl_accted_flag,'N') <> 'Y' ) Then

		hr_po_info.get_vendor_for_primary_asg (
											p_person_id      =>  G_person_id ,
											p_effective_date =>  Trunc(X_ei_date) , --Bug 3891559
										    p_vendor_id      =>  G_Vendor_id,
										    p_vendor_site_id =>  G_Vendor_Site_id
											  );

		If (G_Vendor_id Is Null or G_Vendor_Site_id Is Null ) Then
			x_status := 'PA_INVALID_SUPPLIER_INFO';
			pa_cc_utils.reset_curr_function;
			Return;
		End If;

	End If;







    -- ==========================================================================
    --   Verify that transaction does not violate any transaction controls,
    --   including transaction control extensions
    --
    --   DFF Upgrade:
    --   Calls pa_transactions_pub.validate_dff
    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling pa_transactions_pub.validate_dff';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    pa_transactions_pub.validate_dff(
	       p_dff_name    => 'PA_EXPENDITURE_ITEMS_DESC_FLEX',
               p_attribute_category => X_att_cat,
               p_attribute1 => X_att1,
               p_attribute2 => X_att2,
               p_attribute3 => X_att3,
               p_attribute4 => X_att4,
               p_attribute5 => X_att5,
               p_attribute6 => X_att6,
               p_attribute7 => X_att7,
               p_attribute8 => X_att8,
               p_attribute9 => X_att9,
               p_attribute10 => x_att10,
               x_status_code => temp_status,
	       x_error_message => temp_dff_msg);

    IF (temp_status IS NOT NULL) THEN
         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || temp_dff_msg,1);
            log_message('log_message: ' || temp_status,1);
         END IF;
			X_status := 'PA_DFF_VALIDATION_FAILED';


         /*** CWK Changes : Now Undo changes that are done by po_processed_amt_chk ***/
     IF l_cwk_amt_updated = 'Y' THEN
	     undo_processed_amt_chk(P_Po_Line_Id
                                              ,P_Task_Id
                                              ,l_Calc_Amt
		                              );
     END IF;
         pa_cc_utils.reset_curr_function;
         RETURN;
    END IF;

    IF PG_DEBUG = 'Y' THEN
	    pa_debug.G_err_stage := 'Calling pa_transactions_pub.validate_transaction';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

	If PA_TRX_IMPORT.Get_GVal_ProjTskEi_Date = 'Y' then -- Added for BUG6931833

    pa_transactions_pub.validate_transaction(
               X_project_id => G_project_id
            ,  X_task_id => G_task_id
            ,  X_ei_date => X_ei_date
            ,  X_expenditure_type  => X_etype
            ,  X_non_labor_resource => X_nlr
            ,  X_person_id  => G_person_id
            ,  X_quantity => X_qty
            ,  X_denom_currency_code => X_denom_currency_code
            ,  X_acct_currency_code => G_accounting_currency_code
            ,  X_denom_raw_cost  => X_denom_raw_cost
            ,  X_acct_raw_cost => X_acct_raw_cost
            ,  X_acct_rate_type => G_acct_rate_type
            ,  X_acct_rate_date => X_acct_rate_date
            ,  X_acct_exchange_rate => X_acct_exchange_rate
            ,  X_transfer_ei => NULL
            -- Trx_import enhancement: If G_verride_to_org_id is not NULL,
            -- then that means we will check override to organization
            ,  X_incurred_by_org_id => nvl(G_override_to_org_id, G_org_id)
            ,  X_nl_resource_org_id => G_nlro_id
            ,  X_transaction_source => X_trx_src
            -- Bug 987539: Used to be hard code to 'PAXTRTRX'
            -- changing it to use the parameter validate_item was called
            ,  X_calling_module => X_module
       	    ,  X_vendor_id => NULL
            ,  X_entered_by_user_id => G_user
            ,  X_attribute_category => X_att_cat
 	    ,  X_attribute1 => X_att1
            ,  X_attribute2 => X_att2
            ,  X_attribute3 => X_att3
            ,  X_attribute4 => X_att4
            ,  X_attribute5 => X_att5
            ,  X_attribute6 => X_att6
            ,  X_attribute7 => X_att7
            ,  X_attribute8 => X_att8
            ,  X_attribute9 => X_att9
            ,  X_attribute10 => X_att10
       	    ,  X_attribute11 => NULL
            ,  X_attribute12 => NULL
            ,  X_attribute13 => NULL
            ,  X_attribute14 => NULL
            ,  X_attribute15 => NULL
            ,  X_msg_application => temp_msg_application
            ,  X_msg_type => temp_msg_type
            ,  X_msg_token1 => temp_msg_token1
            ,  X_msg_token2 => temp_msg_token2
            ,  X_msg_token3 => temp_msg_token3
            ,  X_msg_count => temp_msg_count
            ,  X_msg_data => temp_status
            ,  X_billable_flag=> temp_bill_flag
            -- PA-I Changes
            -- Added Assignment_Id and Work_Type_Id
            ,  p_projfunc_currency_code   => X_Projfunc_Currency_Code
            ,  p_projfunc_cost_rate_type  => G_projfunc_cost_rate_type
            ,  p_projfunc_cost_rate_date  => X_Projfunc_Cost_Rate_Date
            ,  p_projfunc_cost_exchg_rate => X_projfunc_cost_exchange_rate
            ,  P_Assignment_Id => G_Assignment_Id
            ,  P_Work_Type_Id  => G_Work_Type_Id
            -- PA-J Txn Ctrl Changes
            ,  P_SYS_LINK_FUNCTION => x_system_linkage
	    ,  P_Po_Header_Id  =>  P_Po_Header_Id /* cwk */
	    , P_Po_Line_Id => P_Po_Line_Id
	    , P_Person_Type => P_Person_Type
	    , P_Po_Price_Type => P_Po_Price_Type );

    END IF;

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'After pa_transactions_pub.validate_transaction';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    -- IF G_skip_tc_flag <> 'Y' THEN  /* commented for Bug # 2108456 */

    IF ( temp_msg_type = 'E' AND temp_status IS NOT NULL ) THEN

		 IF PG_DEBUG = 'Y' THEN
			pa_debug.G_err_stage := 'Validate_transaction has failed' ;
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

         X_status := temp_status;

	 /*** CWK Changes : Now Undo changes that are done by po_processed_amt_chk ***/
     IF l_cwk_amt_updated = 'Y' THEN
      undo_processed_amt_chk(P_Po_Line_Id
                                              ,P_Task_Id
                                              ,l_Calc_Amt );
	 END IF;

	 pa_cc_utils.reset_curr_function;
     RETURN;

    END IF;

    -- END IF ; /* commented for Bug # 2108456 */
    X_bill_flag := temp_bill_flag; /*added for bug 6509828*/
      --
    -- The following section of the code has been written
    -- for funds check related changes
    --
    --PA-J Receipt Accrual Changes: Added AP VARIANCE and PO RECEIPT
    IF G_Process_Funds_Flag = 'Y' AND   ---{
       --Pa-K Changes: Using the process_funds_check attributes of the source to perform funds checking
       --X_trx_src in ('AP INVOICE', 'AP VARIANCE', 'PO RECEIPT', 'AP NRTAX', 'PO RECEIPT NRTAX') AND
       X_acct_raw_cost <> 0 AND
       nvl(G_gl_accted_flag,'N') = 'Y' AND
       G_SobId = G_RecvrSobId AND
       --Pa_Funds_Control_Utils.Get_Fnd_Reqd_Flag(G_project_id, 'STD') = 'Y'
       -- REL12 AP Lines Uptake
	   NVL(p_fc_document_type, 'NOT' )  <> 'NOT' THEN

         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Before calling tr_import_funds_check';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

         --Bug 2905892
         --Assign txn gl_Date for insert of the reversing and EXP lines into pa_bc_packets
         G_FC_Gl_Date := X_Gl_Date;

         tr_import_funds_check (p_pa_date              => pa_date,
                                p_txn_source           => X_trx_src,
                                p_acct_raw_cost        => X_acct_raw_cost,
				p_adj_exp_item_id      => p_adj_exp_item_id,
				p_txn_interface_id     => x_txn_interface_id,
				p_fc_document_type     => p_fc_document_type,
                                x_packet_id            => l_packet_id,
                                x_error_message_code   => l_fc_error_msg,
                                x_error_stage          => l_fc_error_stage,
                                x_return_status        => l_fc_return_status);

         IF l_fc_return_status <>  FND_API.G_RET_STS_SUCCESS then

              IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'Call to tr_import_funds_check did not succeed';
                 log_message('log_message: ' || pa_debug.G_err_Stage);
              END IF;

              x_status := l_fc_error_msg ;
              pa_cc_utils.reset_curr_function;
              return;
         END IF;

         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Call to internal funds check packet insert success';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

         IF Pa_Funds_Control_Pkg.pa_funds_check(p_calling_module  => 'TRXIMPORT',
                                                p_conc_flag       => 'Y',
                                                p_set_of_book_id  => 1,
                                                p_packet_id       => l_packet_id,
                                                p_mode            => 'R',
                                                p_partial_flag    => 'N',
                                                x_return_status   => l_fc_return_status,
                                                x_error_stage     => l_fc_error_stage,
                                                x_error_msg       => l_fc_error_msg) THEN

              IF l_fc_return_status <>  FND_API.G_RET_STS_SUCCESS then

                 IF PG_DEBUG = 'Y' THEN
                 pa_debug.G_err_stage := 'Call to funds check not success';
                    log_message('log_message: ' || pa_debug.G_err_Stage);
                 END IF;

                 --x_status := l_fc_return_status ;
                 x_status := 'PA_FC_ERROR' ;
                 pa_cc_utils.reset_curr_function;
                 return;
              END IF;

              IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'Check if there are any failed records';
              END IF;
                 log_message('log_message: ' || pa_debug.G_err_Stage);

              Open c_check_fail(l_packet_id);
              Fetch c_check_fail
               into l_dummy ;

              close c_check_fail ;

              IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'After select to check for funds check failed records';
                 log_message('log_message: ' || pa_debug.G_err_Stage);
              END IF;
              IF l_dummy = 'X' Then

                 IF PG_DEBUG = 'Y' THEN
                 pa_debug.G_err_stage := 'This transaction failed funds check';
                    log_message('log_message: ' || pa_debug.G_err_Stage);
                 END IF;

                 x_status := 'PA_FC_ERROR' ;

                 pa_cc_utils.reset_curr_function;
                 return;
              ELSE
                 IF PG_DEBUG = 'Y' THEN
                 pa_debug.G_err_stage := 'This transaction passed funds check';
                    log_message('log_message: ' || pa_debug.G_err_Stage);
                 END IF;

                 NULL;

              END IF;
         ELSE

              IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'Error during funds check';
                 log_message('log_message: ' || pa_debug.G_err_Stage);
              END IF;

              x_status := 'PA_FC_UNEXP_ERROR' ;
              pa_cc_utils.reset_curr_function;
              return;
         END IF;
         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Done with funds check';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;
    END IF;   --- }

   /* X_bill_flag := temp_bill_flag; commented for bug 6509828*/

    --PA-J Txn Ctrl Changes
    --Assignment_Id is overwritten by the User in PATC/PATCX.
    --Since p_assignment_id in PATC cannot be changed to IN/OUT, we are using the
    --the global variable set in PATC.
    --Thus assign PATC.global variable to G_Assignment_Id here for sys links ER,ST,OT.
    if (x_system_linkage in ('ST', 'OT', 'ER')) then
        pa_debug.G_err_stage := 'Override Assignment Id';
        G_Assignment_Id := PATC.G_OVERIDE_ASSIGNMENT_ID;

        /* Start of bug 2648550 */
        G_Work_Type_Id := PATC.G_OVERIDE_WORK_TYPE_ID;
        G_Tp_Amt_Type_Code := PATC.G_OVERIDE_TP_AMT_TYPE_CODE;
        X_Assignment_Name :=  PATC.G_OVERIDE_ASSIGNMENT_NAME ;
        X_Work_Type_Name := PATC.G_OVERIDE_WORK_TYPE_NAME;
        /* End of bug 2648550 */

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'Overriding Assignment Id = ' || G_Assignment_Id);
        END IF;
    end if;

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Done with Validate Item';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;
    pa_cc_utils.reset_curr_function; /* bug 2181553 */

-- S.N. CWK changes -> hkulkarn ---> If called from form, release the locks.

    IF (X_module = 'EXTERNAL') THEN
       release_po_line_task_lock;
	   init_po_amt_chk; /* Bug # 3609926 : To free the PL/SQL tables if called from the form */
    END IF;

-- E.N. CWK changes

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'In OTHERS of ValidateItem');
          log_message('log_message: ' || pa_debug.G_err_Stack,1);
          log_message('log_message: ' || SQLERRM,1);
          log_message('log_message: ' || pa_debug.G_err_stage,1);
       END IF;

       release_po_line_task_lock; -- bug 3512984

       pa_cc_utils.reset_curr_function; /* bug 2181553 */

       RAISE ;
  END  ValidateItem;

  PROCEDURE  ValidateOrgId (
                X_org_id       IN NUMBER
             ,  X_status       OUT NOCOPY VARCHAR2 )
  IS
  BEGIN
    pa_cc_utils.set_curr_function('ValidateOrgId');

    --PA.K Changes: For Performance moved the Multi-Org check to init procedure.
    --IF pa_utils.pa_morg_implemented = 'Y' THEN

     /* Added for bug 3590027 */
     IF PG_DEBUG = 'Y' THEN
           log_message('Before call, G_Morg: ' || G_Morg);
     END IF;

     If G_Morg is Null Then
        G_Morg := pa_utils.pa_morg_implemented;
     End If;

     IF PG_DEBUG = 'Y' THEN
           log_message('After call, G_Morg: ' || G_Morg);
     END IF;
     /* Added for bug 3590027 End */

    IF G_Morg = 'Y' THEN
       IF X_org_id IS NULL THEN
          X_status := 'MISSING_ORG_ID';
           pa_cc_utils.reset_curr_function;
          RETURN;
       END IF;
    END IF;

    pa_cc_utils.reset_curr_function;
  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || pa_debug.G_err_Stack,1);
          log_message('log_message: ' || pa_debug.G_err_Stage,1);
          log_message('log_message: ' || SQLERRM,1);
       END IF;
       RAISE ;

  END ValidateOrgId;

  -- Added the function below for bug number 1275169.
  /* For bug 1426802 change employee_number from NUMBER to VARCHAR2 */

 FUNCTION GetOrgName(employee_number IN VARCHAR2,
                      expenditure_item_date IN DATE,
                      business_group_name IN VARCHAR2,
		      person_type IN VARCHAR2) RETURN VARCHAR2 IS
  X_emp_id  NUMBER;
  /* Bug No.2487147, UTF8 change, used %TYPE for X_org_name */
  /* X_org_name VARCHAR2(60); */
     X_org_name  hr_organization_units.name%TYPE;
  BEGIN

    --PA-K Changes: Caching the values.

    if employee_number is null then
      RETURN NULL;
    else

      If (G_OrgNameEmpNum = employee_number) and
         (trunc(G_OrgNameDate) = trunc(expenditure_item_date)) and
         (G_OrgNameBGName = business_group_name) and
	 (G_person_type = nvl(person_type,'EMP'))Then

         RETURN G_OrgNameOrgName;

      Else

         G_OrgNameBGId := pa_utils2.GetBusinessGroupId(business_group_name);

         BEGIN

            pa_utils2.GetEmpId ( P_Business_Group_Id  => G_OrgNameBGId
                      , P_Employee_Number          => employee_number
                      , X_Employee_Id              => X_emp_id
		      , P_Person_Type  => person_type
                      , P_EiDate                   => expenditure_item_date);

         EXCEPTION
            WHEN  NO_DATA_FOUND  THEN
                  NULL;
            WHEN  TOO_MANY_ROWS  THEN
                  NULL;
            WHEN  OTHERS  THEN
                  NULL;
         END;

         --X_emp_id := pa_utils.GetEmpId(employee_number) ;
         if X_emp_id is null then
           RETURN NULL;
         else

            X_org_name := pa_expenditures_utils.getorgtlname(pa_utils.GetEmpOrgId(X_emp_id, expenditure_item_date));

           G_OrgNameEmpNum := employee_number;
           G_OrgNameDate   := expenditure_item_date;
           G_OrgNameBGName := business_group_name;
           G_OrgNameOrgName  := X_org_name;
	   G_person_type := nvl(person_type,'EMP');

           RETURN X_org_name;
         end if;

      End If;

    end if;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
        RETURN null;
  WHEN OTHERS THEN
        RAISE;
  END GetOrgName;
  --
  -- 5235363 R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
  --
  PROCEDURE set_supplier_cost_eidate( X_transaction_source  IN VARCHAR2
                               , X_batch               IN VARCHAR2
                               , X_xface_id            IN NUMBER )
  IS
   V_src_txnifIDTab        PA_PLSQL_DATATYPES.IdTabTyp;
   V_dst_txnifIDTab        PA_PLSQL_DATATYPES.IdTabTyp;
   V_dst_ifIDTab           PA_PLSQL_DATATYPES.IdTabTyp;
   v_src_EiDateTab         PA_PLSQL_DATATYPES.DateTabTyp;
   v_dst_EiDateTab         PA_PLSQL_DATATYPES.DateTabTyp;
   v_dst_txnstatcdTab      PA_PLSQL_DATATYPES.Char1TabTyp;
   v_doc_headerIDTab       PA_PLSQL_DATATYPES.IdTabTyp;
   v_week_ending_dtTab     PA_PLSQL_DATATYPES.DateTabTyp;


  BEGIN
      pa_cc_utils.set_curr_function('Set_supplier_cost_eidate');

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: Set_supplier_cost_eidate begins ' );
         log_message('log_message: Populate bulk variables ' );
      END IF;
      v_src_txnifIDTab.DELETE ;
      v_src_eidateTab.DELETE ;
      v_dst_ifIDTab.DELETE ;
      v_dst_TxnifIDTab.DELETE ;
      v_dst_eidateTab.DELETE ;
      v_dst_txnstatcdTab.DELETE ;
      v_doc_headerIDTab.DELETE ;
      v_week_ending_dtTab.DELETE ;

      select a.txn_interface_id,
             a.expenditure_item_date,
	     b.interface_id,
	     b.txn_interface_id,
	     b.expenditure_item_date,
	     b.transaction_status_code
        BULK Collect into
             v_src_txnifIDTab,
	     v_src_eidateTab,
	     v_dst_ifIDTab,
	     v_dst_TxnifIDTab,
	     v_dst_eidateTab,
	     v_dst_txnstatcdTab
        from pa_transaction_interface_all a,
	     pa_transaction_interface_all b
       where a.interface_id          = X_xface_id
         and a.transaction_source    = X_transaction_source
	 and a.batch_name            = X_batch
	 and a.transaction_source    = b.transaction_source
	 and b.interface_id          <> X_xface_id
	 and a.cdl_system_reference1 = b.cdl_system_reference1
	 and a.cdl_system_reference2 = b.cdl_system_reference2
	 and a.cdl_system_reference3 = b.cdl_system_reference3
	 and NVL(a.cdl_system_reference4,'0')  = NVL(b.cdl_system_reference4, '0')
	 and NVL(a.cdl_system_reference5,0)    = NVL(b.cdl_system_reference5,0)
	 and b.transaction_status_code        <> 'A'
	 and NVL(a.expenditure_item_id, -1)   <> 0
	 and a.adjusted_expenditure_item_id is NULL ;

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message:  v_src_txnifIDTab.count '|| v_src_txnifIDTab.count );
      END IF ;

      IF v_src_txnifIDTab.count > 0 then
         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: Updating the ei date   ' );
         END IF ;

         FORALL indx in 1..v_src_TxnIfIDTab.count
	        Update pa_transaction_interface_all
		   set expenditure_item_date =  v_dst_eidateTab(indx)
		 where txn_interface_id  = v_src_TxnIfIDTab(indx) ;


         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: Updating the ei date on adjusted transactions(reversals)  ' );
         END IF ;

         FORALL indx in 1..v_src_TxnIfIDTab.count
	        Update pa_transaction_interface_all
		   set expenditure_item_date =  v_dst_eidateTab(indx)
		 where adjusted_txn_interface_id  = v_src_TxnIfIDTab(indx)
		   and net_zero_adjustment_flag   = 'Y' ;

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: Determine the week ending date for the affected transactions. ' );
         END IF ;

          select pa_utils.getweekending(max(a.expenditure_item_date)),
	         a.cdl_system_reference2
            BULK Collect into
	         v_week_ending_dtTab,
		 v_doc_headerIDTab
            from pa_transaction_interface_all a,
	         pa_transaction_interface_all b
           where a.interface_id          = X_xface_id
             and a.transaction_source    = X_transaction_source
	     and a.batch_name            = X_batch
	     and a.transaction_source    = b.transaction_source
	     and b.interface_id          <> X_xface_id
	     and a.cdl_system_reference1 = b.cdl_system_reference1
	     and a.cdl_system_reference2 = b.cdl_system_reference2
	     and a.cdl_system_reference3 = b.cdl_system_reference3
	     and NVL(a.cdl_system_reference4,'0') = NVL(b.cdl_system_reference4, '0')
	     and nvl(a.cdl_system_reference5,0)   = nvl(b.cdl_system_reference5 ,0)
	     and b.transaction_status_code        <> 'A'
	   group by a.cdl_system_reference2 ;

         IF v_doc_headerIDTab.count > 0 THEN

            IF PG_DEBUG = 'Y' THEN
               log_message('log_message: Update the weekending date... '|| v_doc_headerIDTab.count );
            END IF ;

            FORALL indx in 1..v_doc_headerIDTab.count
	        UPDATE pa_transaction_interface_all
		   set expenditure_ending_date = v_week_ending_dtTab(indx)
		 where interface_id          = X_xface_id
		   and transaction_source    = X_transaction_source
		   and batch_name            = X_batch
		   and cdl_system_reference2 =v_doc_headerIDTab(indx) ;

	 END IF ;
         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: Deleting the previous batch rejected transactions.  ' );
         END IF ;
	 FORALL indx in 1..v_dst_TxnIfIdTab.count
	        delete from pa_transaction_interface_all
		 where txn_interface_id = v_dst_TxnIfIdTab(indx) ;

      END IF ;
      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: End of set_supplier_cost_eidate.  ' );
      END IF ;

      pa_cc_utils.reset_curr_function;
  END set_supplier_cost_eidate ;

  PROCEDURE import1( X_transaction_source  IN VARCHAR2
                   , X_batch               IN VARCHAR2
                   , X_xface_id            IN NUMBER
                   , X_userid              IN NUMBER
                   , X_online_exp_comment  IN VARCHAR2 )
  IS

    dummy              NUMBER;
    G_expenditure_id   NUMBER(15);

    temp_status        NUMBER DEFAULT NULL;
    X_billable_flag    VARCHAR2(1);
    X_org_status       VARCHAR2(30);
    X_status           VARCHAR2(30);

    -- REL12 AP Lines Uptake
    -- Cash based accounting support
    --
    l_status           VARCHAR2(30);

    l_return_status    Varchar2(10);

    error_msg          VARCHAR2(512);

    FIRST_RECORD       BOOLEAN DEFAULT TRUE;
    GROUP_CREATED      BOOLEAN DEFAULT TRUE;
    REJECT_EXP	       BOOLEAN DEFAULT FALSE;

    /*Added three fields  local for bug 2048868*/
    prev_acct_rate_type      varchar2(30);
    prev_acct_rate_date      date;
    prev_acct_exchange_rate  Number;
    prev_denom_currency_code varchar2(30);
    prev_person_type         varchar2(30);

    -- REL12 AP Lines Uptake
    -- Cash based accounting support
    --
    l_rejectedSysRef5        NUMBER ;
    l_invoice_id             NUMBER ;
    l_payment_status_flag    varchar2(1) ;

    CURSOR c_final_payment is
    SELECT payment_status_flag
     FROM ap_payment_schedules_all pmt
    WHERE pmt.invoice_id          = l_invoice_id
      AND pmt.payment_status_flag = 'Y' ;


    --Bug 987539: New variable to identify calling module
    v_calling_module   VARCHAR2(30);

    CURSOR TrxBatches
    IS
    SELECT
	    xc.transaction_source
    ,       xc.batch_name
    ,       xc.system_linkage_function
    ,       xc.batch_name ||xc.system_linkage_function|| to_char(X_xface_id) exp_group_name
    ,       xc.transaction_count
    ,       xc.processed_count
      FROM
            pa_transaction_xface_control xc
     WHERE
            xc.transaction_source = X_transaction_source
       AND  xc.batch_name         = nvl(X_batch, xc.batch_name)
       AND  xc.status             = 'PENDING'
  --PA-K Changes: Added intermediate_flag
  ORDER BY  intermediate_flag desc;

    TrxBatch		TrxBatches%ROWTYPE;

    /* Trx_import enhancment: Modify the expend field in order to change the
       expenditure grouping logic
       PA-K Changes: Added the new ID columns.
                     Implementing 4 cursors depending on the system linkage and pre-defined flag
                     Expend and Expend2 will be constructed from the PLSQL tables in which the
                     values have been selected.
    */

   /** Modified the following cursors to support ID columns for Non-Oracle Txns
   *** The current code is based on four cursors - two cursors for pre-defined sources
   *** (one for ST, OT and the other for other than ST and OT) - two other cursors
   *** for non-oracle sources of which one for ST, OT and the other for rest Sys Links
   *** Now these four are collapsed into two cursors - irrespective of a transaction
   *** source whether pre-defined on user-defined - once cursor for ST and OT and the
   *** other for system linkages other than ST and OT
   *** Cursors are removed from the code and not commented for the sake of clarity.
   *** Hence there will be only two cursors, defined, opened, fetched from and closed
   *** with these changes
   **/

    /* TrxRecs1 is for ST, OT */
    CURSOR TrxRecs1 ( X_transaction_source  VARCHAR2
                   , current_batch         VARCHAR2
                   , curr_etype_class_code VARCHAR2  )
    IS
    SELECT
            system_linkage
    ,       trunc(expenditure_ending_date) expenditure_ending_date
    ,       employee_number

/* Moving the logic for getting organization name based on the G_emp_oride_flag to TrxRec cursor
   for fix 2686544 */
    ,	    organization_name
/* Bug fix 2655157 starts */
/*    ,       decode (G_emp_org_oride,
                        'Y',
                        decode (organization_name,
                                        null,
                                        GetOrgName(employee_number, expenditure_item_date, person_business_group_name),
                                        organization_name),
                        decode (employee_number,
                                        null,
                                        organization_name,
                                        GetOrgName(employee_number, expenditure_item_date, person_business_group_name))
                   ) organization_name */
           /* decode( employee_number, NULL, organization_name,
            decode(G_emp_org_oride,'Y',organization_name,NULL))
                 organization_name */
/* Bug fix 2655157 ends */
    ,       trunc(expenditure_item_date) expenditure_item_date
    ,       project_number
    ,       task_number
    ,       expenditure_type
    ,       non_labor_resource
    ,       non_labor_resource_org_name
    ,       quantity
    ,       raw_cost
    ,       raw_cost_rate
    ,       orig_transaction_reference
    ,       attribute_category
    ,       attribute1
    ,       attribute2
    ,       attribute3
    ,       attribute4
    ,       attribute5
    ,       attribute6
    ,       attribute7
    ,       attribute8
    ,       attribute9
    ,       attribute10
    ,       expenditure_comment
    ,       interface_id
    ,       expenditure_id
    ,       nvl(unmatched_negative_txn_flag, 'N') unmatched_negative_txn_flag
    ,       to_number( NULL )  expenditure_item_id
    ,       org_id             org_id
    ,       dr_code_combination_id
    ,       cr_code_combination_id
    ,       cdl_system_reference1
    ,       cdl_system_reference2
    ,       cdl_system_reference3
    ,       cdl_system_reference4
    ,       cdl_system_reference5
    ,       trunc(gl_date) gl_date --7535550
    ,       burdened_cost
    ,       burdened_cost_rate
    ,       receipt_currency_amount
    ,       receipt_currency_code
    ,	    receipt_exchange_rate
    ,       denom_currency_code
    ,	    denom_raw_cost
    ,	    denom_burdened_cost
    ,       trunc(acct_rate_date) acct_rate_date --7535550
    ,	    acct_rate_type
    ,       acct_exchange_rate
--  ,       pa_currency.round_currency_amt1(acct_raw_cost) acct_raw_cost  -- Bug 7522080
    ,       acct_raw_cost
    ,       acct_burdened_cost
    ,       acct_exchange_rounding_limit
    ,       project_currency_code
    ,       trunc(project_rate_date) project_rate_date --7535550
    ,       project_rate_type
    ,       project_exchange_rate
    ,       orig_exp_txn_reference1
    ,       orig_user_exp_txn_reference
    ,       vendor_number
    ,       orig_exp_txn_reference2
    ,       orig_exp_txn_reference3
    ,       override_to_organization_name
    ,       reversed_orig_txn_reference
    ,       billable_flag
    ,       txn_interface_id
    ,       person_business_group_name
    ,       projfunc_currency_code
    ,       trunc(projfunc_cost_rate_date) projfunc_cost_rate_date --7535550
    ,       projfunc_cost_rate_type
    ,       projfunc_cost_exchange_rate
    ,       project_raw_cost
    ,       project_burdened_cost
    ,       assignment_name
    ,       work_type_name
    ,       nvl(accrual_flag,'N') accrual_flag
    ,       project_id
    ,       task_id
    ,       person_id
    ,       organization_id
    ,       non_labor_resource_org_id
    ,       vendor_id
    ,       override_to_organization_id
    ,       assignment_id
    ,       work_type_id
    ,       person_business_group_id
    ,       po_number  /* cwk */
    ,       po_header_id
    ,       po_line_num
    ,       po_line_id
    ,       person_type
    ,       po_price_type
    ,       wip_resource_id
    ,       inventory_item_id
    ,       unit_of_measure
    ,       adjusted_expenditure_item_id
    ,       NVL(fc_document_type, 'NOT')
    ,       NULL document_type
    ,       document_distribution_type -- R12 AP lines uptake : Prepayment changes
    ,       si_assets_addition_flag
    ,       NULL -- adjusted_txn_interface_id
    ,       NULL -- net_zero_adjustment_flag
    ,       NULL -- sc_xfer_code
    ,       0    -- final_payment_id
  --  ,       agreement_id  --FSIO Changes
   -- ,       agreement_number
      FROM pa_transaction_interface
     WHERE transaction_source = X_transaction_source
       AND batch_name = current_batch
       AND transaction_status_code = 'P'
       AND system_linkage in ('ST', 'OT')
    ORDER BY
            expenditure_ending_date DESC
    ,       decode(nvl(person_id,0), 0, employee_number, person_id)
    ,       decode(nvl(organization_id,0), 0, organization_name, organization_id)
    ,       orig_exp_txn_reference1
    ,       orig_user_exp_txn_reference
    ,       decode(nvl(vendor_id,0), 0, vendor_number, vendor_id)
    ,       orig_exp_txn_reference2
    ,       orig_exp_txn_reference3
    ,       denom_currency_code
    ,	    acct_rate_date
    ,	    acct_rate_type
    ,	    acct_exchange_rate
    ,       expenditure_item_date
    ,       decode(nvl(project_id,0), 0, project_number, project_id)
    ,       decode(nvl(task_id,0), 0, task_number, task_id)
    ,       accrual_flag    ;


    /* TrxRecs2 is for other than ST, OT */

    CURSOR TrxRecs2 ( X_transaction_source  VARCHAR2
                   , current_batch         VARCHAR2
                   , curr_etype_class_code VARCHAR2  )
    IS
    SELECT
            system_linkage
    ,       trunc(expenditure_ending_date) expenditure_ending_date
    ,       employee_number

/* Moving the logic for getting organization name based on the G_emp_oride_flag to TrxRec cursor
   for fix 2686544 */
    ,	    organization_name
/* Bug fix 2655157 starts */
/*    ,       decode (G_emp_org_oride,
                        'Y',
                        decode (organization_name,
                                        null,
                                        GetOrgName(employee_number, expenditure_item_date, person_business_group_name),
                                        organization_name),
                        decode (employee_number,
                                        null,
                                        organization_name,
                                        GetOrgName(employee_number, expenditure_item_date, person_business_group_name))
                   ) organization_name */
           /* decode( employee_number, NULL, organization_name,
            decode(G_emp_org_oride,'Y',organization_name,NULL))
                 organization_name */
/* Bug fix 2655157 ends */
    ,       trunc(expenditure_item_date) expenditure_item_date
    ,       project_number
    ,       task_number
    ,       expenditure_type
    ,       non_labor_resource
    ,       non_labor_resource_org_name
    ,       quantity
    ,       raw_cost
    ,       raw_cost_rate
    ,       orig_transaction_reference
    ,       attribute_category
    ,       attribute1
    ,       attribute2
    ,       attribute3
    ,       attribute4
    ,       attribute5
    ,       attribute6
    ,       attribute7
    ,       attribute8
    ,       attribute9
    ,       attribute10
    ,       expenditure_comment
    ,       interface_id
    ,       expenditure_id
    ,       nvl(unmatched_negative_txn_flag, 'N') unmatched_negative_txn_flag
    -- REL12 AP Lines uptake.
    -- to_number(NULL) was removed.
    ,       expenditure_item_id
    ,       org_id             org_id
    ,       dr_code_combination_id
    ,       cr_code_combination_id
    ,       cdl_system_reference1
    ,       cdl_system_reference2
    ,       cdl_system_reference3
    ,       cdl_system_reference4
    ,       cdl_system_reference5
    ,       trunc(gl_date) gl_date --7535550
    ,       burdened_cost
    ,       burdened_cost_rate
    ,       receipt_currency_amount
    ,       receipt_currency_code
    ,	    receipt_exchange_rate
    ,       denom_currency_code
    ,	    denom_raw_cost
    ,	    denom_burdened_cost
    ,       trunc(acct_rate_date) acct_rate_date --7535550
    ,	    acct_rate_type
    ,       acct_exchange_rate
--    ,       pa_currency.round_currency_amt1(acct_raw_cost) acct_raw_cost  -- Bug 7522080
    ,       acct_raw_cost
    ,       acct_burdened_cost
    ,       acct_exchange_rounding_limit
    ,       project_currency_code
    ,       trunc(project_rate_date) project_rate_date --7535550
    ,       project_rate_type
    ,       project_exchange_rate
    ,       orig_exp_txn_reference1
    ,       orig_user_exp_txn_reference
    ,       vendor_number
    ,       orig_exp_txn_reference2
    ,       orig_exp_txn_reference3
    ,       override_to_organization_name
    ,       reversed_orig_txn_reference
    ,       billable_flag
    ,       txn_interface_id
    ,       person_business_group_name
    ,       projfunc_currency_code
    ,       trunc(projfunc_cost_rate_date) projfunc_cost_rate_date --7535550
    ,       projfunc_cost_rate_type
    ,       projfunc_cost_exchange_rate
    ,       project_raw_cost
    ,       project_burdened_cost
    ,       assignment_name
    ,       work_type_name
    ,       nvl(accrual_flag,'N') accrual_flag
    ,       project_id
    ,       task_id
    ,       person_id
    ,       organization_id
    ,       non_labor_resource_org_id
    ,       vendor_id
    ,       override_to_organization_id
    ,       assignment_id
    ,       work_type_id
    ,       person_business_group_id
    ,       po_number  /* cwk */
    ,       po_header_id
    ,       po_line_num
    ,       po_line_id
    ,       person_type
    ,       po_price_type
    ,       wip_resource_id
    ,       inventory_item_id
    ,       unit_of_measure
    ,       adjusted_expenditure_item_id
    ,       NVL(fc_document_type, 'NOT' )
    ,       document_type
    ,       document_distribution_type
    ,       si_assets_addition_flag
    ,       adjusted_txn_interface_id
    ,       net_zero_adjustment_flag
    ,       sc_xfer_code   -- supplier cost transfer status code.
    ,       0              -- final_payment_id
 --   ,       agreement_id  --FSIO Changes
  --  ,       agreement_number
      FROM pa_transaction_interface
     WHERE transaction_source = X_transaction_source
       AND batch_name = current_batch
       AND transaction_status_code = 'P'
       AND system_linkage = curr_etype_class_code
    ORDER BY
           expenditure_ending_date DESC
    ,       decode(nvl(person_id,0), 0, employee_number, person_id)
            -- 5389130 added order by criteria.
    ,       decode(nvl(override_to_organization_id     ,organization_id), 0, organization_name,
                      organization_id, organization_id, override_to_organization_id)
    ,       orig_exp_txn_reference1
    ,       orig_user_exp_txn_reference
    ,       decode(nvl(vendor_id,0), 0, vendor_number, vendor_id)
    ,       orig_exp_txn_reference2
    ,       orig_exp_txn_reference3
    ,       denom_currency_code
    ,	    acct_rate_date
    ,	    acct_rate_type
    ,	    acct_exchange_rate
    ,       expenditure_item_date
            -- 5389130 added order by criteria.
    ,       decode(adjusted_expenditure_item_id, null, 1, 0, 1, 0)
    ,	    decode(curr_etype_class_code, 'VI', cdl_system_reference2, '0' )
    ,       decode(curr_etype_class_code, 'VI', cdl_system_reference3, '0' )
    ,       decode(curr_etype_class_code, 'VI', cdl_system_reference5, '0' )
    ,       decode(curr_etype_class_code, 'VI', cdl_system_reference4, '0' )
    ,       decode(fc_document_type ,'ALL', 1, 'CMT', 2, 'ACT', 3 , 4 )
    ,       decode(nvl(project_id,0), 0, project_number, project_id)
    ,       decode(nvl(task_id,0), 0, task_number, task_id)
    ,       accrual_flag
    ,       NVL(adjusted_txn_interface_id,0) ;

    --PA-K Changes: Removing the for update clause
    --FOR UPDATE OF transaction_status_code;

    --TrxRec		TrxRecs%ROWTYPE;
    X_Owner_name        Dba_Tables.Owner%TYPE; /* 1869684 */

  --PA-K Changes: Declaration of the tables used for TrxRecs Bulk Fetch
  --l_ExpendTab
  --l_Expend2Tab
  l_SysLinkTab            PA_PLSQL_DATATYPES.Char30TabTyp;
  l_EmpNumTab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_EiEndDateTab          PA_PLSQL_DATATYPES.DateTabTyp;
  l_OrganizationNameTab   PA_PLSQL_DATATYPES.Char240TabTyp;
  l_EiDateTab             PA_PLSQL_DATATYPES.DateTabTyp;
  l_PrjNumTab             PA_PLSQL_DATATYPES.Char25TabTyp;
  l_TaskNumTab            PA_PLSQL_DATATYPES.Char25TabTyp;
  l_ETypeTab              PA_PLSQL_DATATYPES.Char30TabTyp;
  l_NlrTab                PA_PLSQL_DATATYPES.Char20TabTyp;
  l_NlrOrgNameTab         PA_PLSQL_DATATYPES.Char240TabTyp;
  l_QtyTab                PA_PLSQL_DATATYPES.QtyTabtyp;
  l_rawCostTab            PA_PLSQL_DATATYPES.NumTabTyp; -- Bug 5959023: Changed to NumTabTyp from QtyTabtyp
  l_rawCostRateTab        PA_PLSQL_DATATYPES.NumTabTyp; -- Bug 5959023: Changed to NumTabTyp from AmtTabTyp
  l_OrigTxnRefTab         PA_PLSQL_DATATYPES.Char30TabTyp;
  l_AttCatTab             PA_PLSQL_DATATYPES.Char30TabTyp;
  l_Att1Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att2Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att3Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att4Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att5Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att6Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att7Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att8Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att9Tab               PA_PLSQL_DATATYPES.Char150TabTyp;
  l_Att10Tab              PA_PLSQL_DATATYPES.Char150TabTyp;
  l_ExpCommentTab         PA_PLSQL_DATATYPES.Char240TabTyp;
  l_InterfaceIdTab        PA_PLSQL_DATATYPES.Num15TabTyp;
  l_ExpIdTab              PA_PLSQL_DATATYPES.Num15TabTyp;
  l_UnMatchNegFlagTab     PA_PLSQL_DATATYPES.Char1TabTyp;
  l_ExpItemIdTab          PA_PLSQL_DATATYPES.Num15TabTyp;
  --l_JobIdTab              PA_PLSQL_DATATYPES.
  l_OrgIdTab              PA_PLSQL_DATATYPES.Num15TabTyp;
  l_DRCCIDTab             PA_PLSQL_DATATYPES.Num15TabTyp;
  l_CRCCIDTab             PA_PLSQL_DATATYPES.Num15TabTyp;
  l_SysRef1Tab            PA_PLSQL_DATATYPES.Char30TabTyp;
  l_SysRef2Tab            PA_PLSQL_DATATYPES.Char30TabTyp;
  l_SysRef3Tab            PA_PLSQL_DATATYPES.Char30TabTyp;
  l_Sysref4Tab            PA_PLSQL_DATATYPES.Char30TabTyp;
  TYPE  Char30TabTyp  IS TABLE OF VARCHAR2(30) index by varchar2(30) ;
  l_txn_rejected_sr4Tab   Char30TabTyp;

  /* REL12-AP Lines uptake  START
  ** Support for cdl_system_reference5
  ** cdl_system_reference5 to store invoice distribution ID
  */
  l_Sysref5Tab            PA_PLSQL_DATATYPES.IdTabTyp;
  l_txn_rejected_sr5tab   PA_PLSQL_DATATYPES.IdTabTyp;
  l_AdjExpItemIdTab       PA_PLSQL_DATATYPES.IdTabTyp;
  l_FcDocTypeTab          PA_PLSQL_DATATYPES.Char3TabTyp;
  l_AdjTxnInterfaceIDTab  PA_PLSQL_DATATYPES.IdTabTyp;
  l_NZAdjFlagTab          PA_PLSQL_DATATYPES.Char1TabTyp;
  l_AdjTxnEiIDTab         PA_PLSQL_DATATYPES.IdTabTyp;
  l_temp_adjItemID        NUMBER ;
  l_scXferCdTab           PA_PLSQL_DATATYPES.Char1TabTyp ;

    -- REL12 AP Lines Uptake
    -- Cash based accounting support
    --
  -- bug 4902112 declaration was changed from Char1TabTyp to IdTabTyp.
  --
  l_finalPaymentIdTab     PA_PLSQL_DATATYPES.IdTabTyp ;

  --REL12 Changes
  l_siaAddFlagTab         PA_PLSQL_DATATYPES.Char1TabTyp ;
  l_old_SysRef1		  varchar2(30) ;
  l_old_SysRef2		  varchar2(30) ;
  l_old_SysRef3		  varchar2(30) ;
  l_old_SysRef4		  varchar2(30) ;
  l_old_SysRef5	          NUMBER ;
  l_doc_header_id         NUMBER ;
  l_vendor_id             NUMBER ;
  l_doc_distribution_id   NUMBER ;
  l_doc_payment_id        NUMBER ;
  l_doc_line_number       NUMBER ;
  l_gms_fundscheck        varchar2(1) ;
  l_DocumentTypeTab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_DocumentDistTypeTab   PA_PLSQL_DATATYPES.Char30TabTyp;

  /* REL12-AP Lines uptake  END */


  l_GlDateTab             PA_PLSQL_DATATYPES.DateTabTyp;
  l_burdenedCostTab       PA_PLSQL_DATATYPES.NumTabTyp; -- Bug 5959023: Changed to NumTabTyp from AmtTabTyp
  l_BdCostRateTab         PA_PLSQL_DATATYPES.NumTabTyp; -- Bug 5959023: Changed to NumTabTyp from AmtTabTyp
  l_RcptCurrAmtTab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_RcptCurrCodeTab       PA_PLSQL_DATATYPES.Char15TabTyp;
  l_RcptExchRateTab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_DenomCurrCodeTab      PA_PLSQL_DATATYPES.Char15TabTyp;
  l_DenomRawCostTab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_DenomBdCostTab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_AcctRateDateTab       PA_PLSQL_DATATYPES.DateTabTyp;
  l_AcctRateTypeTab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_AcctExchRateTab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_AcctRawCostTab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_AcctBdCostTab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_AcctExchRndLimitTab   PA_PLSQL_DATATYPES.NumTabTyp;
  l_ProjCurrCodeTab       PA_PLSQL_DATATYPES.Char15TabTyp;
  l_prjRateDateTab        PA_PLSQL_DATATYPES.DateTabTyp;
  l_PrjRateTypeTab        PA_PLSQL_DATATYPES.Char30TabTyp;
  l_PrjExchRateTab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_OrigExpTxnRef1Tab     PA_PLSQL_DATATYPES.Char60TabTyp;
  l_OrigUsrExpTxnRefTab   PA_PLSQL_DATATYPES.Char60TabTyp;
  l_VendorNumTab          PA_PLSQL_DATATYPES.Char30TabTyp;
  l_OrigExpTxnRef2Tab     PA_PLSQL_DATATYPES.Char60TabTyp;
  l_OrigExpTxnRef3Tab     PA_PLSQL_DATATYPES.Char60TabTyp;
  l_OverrideOrgNameTab    PA_PLSQL_DATATYPES.Char240TabTyp;
  l_RevOrigTxnRefTab      PA_PLSQL_DATATYPES.Char30TabTyp;
  l_billableFlagTab       PA_PLSQL_DATATYPES.Char1TabTyp;
  l_TxnIfIdTab            PA_PLSQL_DATATYPES.Num15TabTyp;
  l_PerBusGrpNameTab      PA_PLSQL_DATATYPES.Char60TabTyp;
  l_ProjFuncCurrCodeTab   PA_PLSQL_DATATYPES.Char15TabTyp;
  l_PrjFuncRateDateTab    PA_PLSQL_DATATYPES.DateTabTyp;
  l_PrjFuncRateTypeTab    PA_PLSQL_DATATYPES.Char30TabTyp;
  l_PrjFuncExchRateTab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_ProjRawCostTab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_ProjBdCostTab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_AsgnNameTab           PA_PLSQL_DATATYPES.Char80TabTyp;
  l_WorkTypeNameTab       PA_PLSQL_DATATYPES.Char80TabTyp;
  l_AccrualFlagTab        PA_PLSQL_DATATYPES.Char1TabTyp;
  l_PrjIdTab              PA_PLSQL_DATATYPES.IdTabTyp;
  l_TaskIdTab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_PersonIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_OrganizationIdTab     PA_PLSQL_DATATYPES.IdTabTyp;
  l_NLROrgIDTab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_VendorIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_OverrideOrgIdTab      PA_PLSQL_DATATYPES.IdTabTyp;
  l_AsgnIdTab             PA_PLSQL_DATATYPES.IdTabTyp;
  l_WorkTypeIdTab         PA_PLSQL_DATATYPES.IdTabTyp;
  l_PersonBusGrpIdTab     PA_PLSQL_DATATYPES.IdTabTyp;
  l_EmpOrgIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_EmpJobIdTab           PA_PLSQL_DATATYPES.IdTabTyp;
  l_po_numberTab          PA_PLSQL_DATATYPES.Char20TabTyp; /* cwk */
  l_po_header_idTab       PA_PLSQL_DATATYPES.IdTabTyp;
  l_po_line_numTab        PA_PLSQL_DATATYPES.NumTabTyp;
  l_po_line_idTab         PA_PLSQL_DATATYPES.IdTabTyp;
  l_person_typeTab        PA_PLSQL_DATATYPES.Char30TabTyp;
  l_po_price_typeTab      PA_PLSQL_DATATYPES.Char20TabTyp;
  l_wip_resource_idTab    PA_PLSQL_DATATYPES.IdTabTyp;
  l_inventory_item_idTab  PA_PLSQL_DATATYPES.IdTabTyp;
  l_unit_of_measureTab    PA_PLSQL_DATATYPES.Char30TabTyp;

  l_Batch_Size           NUMBER;
  l_CommitSizeRecCount   NUMBER;
  l_BatchRecCount        NUMBER;
  l_ActualBatchRecCnt    NUMBER;

  l_sys_link             VARCHAR2(30);
  l_expenditure_id       NUMBER;
  l_RevOrigTxnRef        VARCHAR2(30);
  l_Accrual_Flag         VARCHAR2(1);

  l_gms_enabled		 VARCHAR2(1); --> variable for holding gms_enabled flag.

  l_src_system_linkage_function   VARCHAR2(30); -- 4057874

 -- l_agreement_idTab       PA_PLSQL_DATATYPES.IdTabTyp;     --FSIO Changes
 -- l_agreement_numberTab   PA_PLSQL_DATATYPES.Char50TabTyp;

    FUNCTION lockCntrlRec ( trx_source   VARCHAR2
                          , batch        VARCHAR2
                          , etypeclasscode VARCHAR2 ) RETURN NUMBER
    IS
    BEGIN

      pa_cc_utils.set_curr_function('lockCntrlRec');

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Trying to get lock for record in xface ctrl:'||
                                ' transaction source ='||trx_source||
                                ' batch = '||batch||
                                ' sys link = '||etypeclasscode);
      END IF;

      BEGIN
        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'Before locking record');
        END IF;

        SELECT
              1
        INTO
              dummy
        FROM
              pa_transaction_xface_control
        WHERE
              transaction_source = trx_source
         AND  batch_name = batch
         AND  system_linkage_function = etypeclasscode
         AND  status = 'PENDING'
        FOR UPDATE OF status NOWAIT;

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'After locking record');
        END IF;

      EXCEPTION
        when no_data_found then
           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'Not able to Lock Record, in no data found');
           END IF;
           raise;
      END;

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Got lock for record');
      END IF;

      UPDATE  pa_transaction_xface_control
         SET
              interface_id = X_xface_id
      ,       status = 'IN_PROGRESS'
       WHERE
              transaction_source = trx_source
         AND  batch_name = batch
         AND  system_linkage_function = etypeclasscode
         AND  status = 'PENDING';

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Updated interface id/status on pa_transaction_xface_control');
      END IF;

      pa_cc_utils.reset_curr_function;
      RETURN 0;

    EXCEPTION
      WHEN  RESOURCE_BUSY  THEN
      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Cannot get lock',1);
      END IF;
      pa_cc_utils.reset_curr_function;
          RETURN -1;
    END lockCntrlRec;

    PROCEDURE UpdControlProcessed (P_TrxSource in VARCHAR2,
                                   P_BatchName in VARCHAR2,
                                   P_XfaceId  in NUMBER,
                                   P_TxnCount  in NUMBER,
                                   P_ProcCount in NUMBER,
                                   P_BatchProcCount in NUMBER,
                                   p_system_linkage_function  IN  VARCHAR2)
/* Added the parameter system_linkage_function for bug # 3291066 */
    IS
    BEGIN

      pa_cc_utils.set_curr_function('UpdControlProcessed');
      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Inside UpdControlProcessed,
                                P_TrxSource = ' || P_TrxSource ||
                              ' P_BatchName = ' || P_BatchName ||
                              ' P_Xface_Id = ' || P_XfaceId ||
                              ' P_TxnCount = ' || P_TxnCount ||
                              ' P_ProcCount = ' || P_ProcCount ||
                              ' P_BatchProcCount = '|| P_BatchProcCount);
      END IF;

      /*PA-K Changes: Replaced the existing update stmt */

      /* Bug#3451108. Added an 'AND' condition in the if clause to check if the
         P_BatchProcCount is not equal to Zero */
      If (((P_BatchProcCount + P_ProcCount) < P_TxnCount) And (P_BatchProcCount <> 0)) Then

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'Set ctrl record status to PENDING');
         END IF;

         UPDATE pa_transaction_xface_control
            SET status = 'PENDING',
                intermediate_flag = 'Y',
                processed_count = processed_count + P_BatchProcCount
          WHERE transaction_source = P_TrxSource
            AND batch_name = P_BatchName
            AND interface_id = P_XfaceId
            AND system_linkage_function = p_system_linkage_function;
/* Added the join with system_linkage_function for bug # 3291066 */

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'Updated ' || SQL%ROWCOUNT || ' records');
         END IF;

      Else

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'Set ctrl record status to PROCESSED');
         END IF;

         UPDATE pa_transaction_xface_control
            SET status = 'PROCESSED',
                processed_count = processed_count + P_BatchProcCount
          WHERE transaction_source = P_TrxSource
            AND batch_name = P_BatchName
            AND interface_id = P_XfaceId
	    AND system_linkage_function = p_system_linkage_function;
/* Added the join with system_linkage_function for bug # 3291066 */

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'Updated ' || SQL%ROWCOUNT || ' records');
         END IF;

      End If;

      pa_cc_utils.reset_curr_function;

    END UpdControlProcessed;

    PROCEDURE loadExpCompareVars ( expend    IN VARCHAR2
                               , expend2   IN VARCHAR2
                               , end_date  IN DATE
                               , orig_exp_txn_reference1 IN VARCHAR2
                               , orig_user_exp_txn_reference IN VARCHAR2
                               , orig_exp_txn_reference2 IN VARCHAR2
                               , orig_exp_txn_reference3 IN VARCHAR2)
    IS
    BEGIN

      pa_cc_utils.set_curr_function('loadExpCompareVars');
      current_expend  := expend;
      current_expend2 := expend2;
      current_period  := end_date;
      i               := 0;

      --  Trx_import enhancement
      G_orig_exp_txn_reference1 := orig_exp_txn_reference1;
      G_orig_user_exp_txn_reference := orig_user_exp_txn_reference;
      G_orig_exp_txn_reference2 := orig_exp_txn_reference2;
      G_orig_exp_txn_reference3 := orig_exp_txn_reference3;

      --  Current_system_linkage is added in init for creating expenditure groups
      --  Selva 03/10/97

      -- Bug 1000221, OT and ST txns will be created in the same exp group
      -- with the system linkage = ST.

      IF ( l_sys_link = 'OT' ) THEN
         current_system_linkage := 'ST';
      ELSE
         current_system_linkage := l_sys_link ;
      END IF;

      -- SST change: If transaction source is 'Oracle Self Service Time',
      -- then we do not need to get a new expenditure ID because for
      -- self service time, expenditure is created at entry time, thus
      -- expenditure ID already exists.
      IF X_transaction_source = 'Oracle Self Service Time' AND
          l_Expenditure_Id IS NOT NULL THEN

       G_expenditure_id := l_Expenditure_Id;

      ELSE
       SELECT pa_expenditures_s.nextval
       INTO G_expenditure_id
       FROM sys.dual;
      END IF;

      pa_cc_utils.reset_curr_function;
  END loadExpCompareVars;

  -- Bug 2048868 : Added 5 parameters to pass currency attributes to
  --               pa_transactions.insertexp

  PROCEDURE newExpend ( group_name   IN VARCHAR2
                      , ending_date  IN DATE
                      , record_count IN NUMBER
                      , p_denom_currency_code IN VARCHAR2   DEFAULT NULL
                      , p_acct_currency_code IN VARCHAR2   DEFAULT NULL
                      , p_acct_rate_type     IN VARCHAR2   DEFAULT NULL
                      , p_acct_rate_date     IN DATE   DEFAULT NULL
                      , p_acct_exchange_rate IN NUMBER DEFAULT NULL
		      , p_person_type IN VARCHAR2 DEFAULT NULL /*cwk */
		      , p_batch_name  IN VARCHAR2 )  -- Bug 3613784 : Performance fix
  IS

    X_status                VARCHAR2(30);
    X_outcome               NUMBER;
    X_route_to_person_id    NUMBER;
    X_comment               VARCHAR2(240);
    X_approval_status       VARCHAR2(80);

    l_acct_rate_type        VARCHAR2(30);
    l_acct_rate_date        DATE;
    l_acct_exchange_rate    NUMBER;
    l_gl_accted_flag          VARCHAR2(2);

  BEGIN
    pa_cc_utils.set_curr_function('newExpend');

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'record count = ' || record_count);
    END IF;

    -- BUG:4748305  DFHC.D4:PRC INTERFACE SUPPLIER COST NOT INTERFACING
    -- VALID INVOICE DISTRIBUTIONS
    -- We allow good ap invoice distributions to interface in a expenditure
    -- and do not reject all the expenditure items in expenditure
    -- This is only done for VI items.

    IF ( (NOT REJECT_EXP ) AND (v_calling_module <> 'PAAPIMP' OR record_count > 0)) OR /* Bug 8709614  */
        ( v_calling_module = 'PAAPIMP' and
          current_system_linkage = 'VI' and
          record_count > 0 )
    THEN

      IF ( NOT GROUP_CREATED ) THEN

        IF X_transaction_source NOT IN ('PTE TIME', 'PTE EXPENSE') THEN

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_Stage := 'Calling pa_transactions.InsertExpGroupNew';
             log_message('log_message: ' || pa_debug.G_err_Stage);
             log_message('log_message: ' || 'Group Name = ' || group_name || ' Sys Link = ' || current_system_linkage);
          END IF;

          IF (group_name <> nvl(G_group_name,'X')) THEN

                pa_transactions.InsertExpGroupNew(
                   group_name
                ,  'RELEASED'
                ,  ending_date
                ,  current_system_linkage
                ,  X_userid
                ,  X_transaction_source
                ,  l_Accrual_Flag
                -- MOAC Changes
                ,  g_moac_org_id );

             G_group_name := group_name;

             GROUP_CREATED := TRUE;

          END IF;

        END IF;

      END IF;

      -- SST Change: expenditure was created when user entered
      -- the SST.  Thus, we just need to update the expenditure_group
      -- for the expenditure.
      IF ( X_transaction_source = 'Oracle Self Service Time' ) THEN

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Updating exp for SST';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        UPDATE pa_expenditures
        SET expenditure_group = group_name
        WHERE expenditure_id = G_expenditure_id;

      ELSE
        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Calling pa_transactions.InsertExp';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;
        -- Trx_import enhancement
        -- Bug 2048868 : Added 5 parameters to pass currency attributes to
        --               pa_transactions.insertexp
        -- If system_linkage = ER



        IF ( (current_system_linkage = 'ER') and
            (p_denom_currency_code <> p_acct_currency_code) ) THEN

         if (p_acct_rate_type is null) then
           l_acct_rate_type := pa_multi_currency.get_rate_type;
         else
           l_acct_rate_type := p_acct_rate_type;
         end if;

         if (p_acct_rate_date is null) then
           pa_multi_currency_txn.get_acct_rate_date(
              P_EI_date        => ending_date,
              P_acct_rate_date => l_acct_rate_date);
         else
            l_acct_rate_date := p_acct_rate_date;
         end if;

         pa_transactions.InsertExp(
           X_expenditure_id   => G_expenditure_id,
           X_expend_status    => 'APPROVED',
           X_expend_ending    => ending_date,
           X_expend_class     => G_eclass,
           X_inc_by_person    => G_person_id,
           X_inc_by_org       => G_org_id,
           X_expend_group     => group_name,
  --         X_entered_by_id    => X_userid,
           X_entered_by_id    => FND_GLOBAL.employee_id, -- Bug 2396121
           X_created_by_id    => X_userid,
           X_denom_currency_code  =>  p_denom_currency_code,
           X_acct_currency_code   =>  p_acct_currency_code,
           X_acct_rate_type       =>  l_acct_rate_type,
           X_acct_rate_date       =>  l_acct_rate_date,
           X_acct_exchange_rate   =>  p_acct_exchange_rate,
           X_orig_exp_txn_reference1 => G_orig_exp_txn_reference1,
           X_orig_user_exp_txn_reference => G_orig_user_exp_txn_reference,
           X_vendor_id        => G_vendor_id,
           X_orig_exp_txn_reference2 => G_orig_exp_txn_reference2,
           X_orig_exp_txn_reference3 => G_orig_exp_txn_reference3,
  	   X_person_type => p_person_type,
          -- MOAC Changes
           p_org_id                => g_moac_org_id); /*cwk */

        ELSE

          pa_transactions.InsertExp(
           X_expenditure_id   => G_expenditure_id,
           X_expend_status    => 'APPROVED',
           X_expend_ending    => ending_date,
           X_expend_class     => G_eclass,
           X_inc_by_person    => G_person_id,
           X_inc_by_org       => G_org_id,
           X_expend_group     => group_name,
  --         X_entered_by_id    => X_userid,
           X_entered_by_id    => FND_GLOBAL.employee_id, -- Bug 2396121
           X_created_by_id    => X_userid,
           X_orig_exp_txn_reference1 => G_orig_exp_txn_reference1,
           X_orig_user_exp_txn_reference => G_orig_user_exp_txn_reference,
           X_vendor_id        => G_vendor_id,
           X_acct_currency_code   =>  p_acct_currency_code,        -- Bug 6412762: Base Bug 6354066
           X_orig_exp_txn_reference2 => G_orig_exp_txn_reference2,
           X_orig_exp_txn_reference3 => G_orig_exp_txn_reference3,
           X_person_type => p_person_type,
           -- MOAC Changes
           p_org_id      => g_moac_org_id); /* cwk */

		END IF;

      END IF;

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_Stage := 'Calling pa_transactions.InsItems';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      select decode(G_gl_accted_flag,'N','N',decode(G_gl_posted_flag,'Y','Y','P')) into l_gl_accted_flag from dual;

      pa_transactions.InsItems(
         X_userid
      ,  0
      ,  'PAXTRTRX'
      ,  'TRX_IMPORT'
      ,  record_count
      ,  temp_status
      ,  l_gl_accted_flag );

      -- -----------------------------------------------------------------------
      -- OGM_0.0 - Interface for creating new ADLS for each expenditure Item
      -- created. This will create award distribution lines only when OGM is
      -- installed for the ORG in process.
      -- The folowing procedure returns doing nothing if status is in ERROR for
      -- pa_transactions.InsItems.
      -- ------------------------------------------------------------------------
      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || '1760:Call Vertical APPS interface for i>=500');
      END IF;

      IF l_gms_enabled = 'Y' THEN

         PA_GMS_API.vert_trx_interface(   X_userid,
					   0,
					   'PAXTTRXB',
					   'TRX_IMPORT',
					   record_count,
					   temp_status,
					   G_gl_accted_flag) ;

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || '1760:Call Vertical APPS interface for i>=500 END.');
         END IF;

         IF ( temp_status <  0 ) THEN
           error_msg := SQLERRM( temp_status);
           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || pa_debug.G_err_Stack,1);
              log_message('log_message: ' || error_msg,1);
              log_message('log_message: ' || pa_debug.G_err_Stage,1);
           END IF;
           raise_application_error( -20000, error_msg ) ;
         END IF;
      END IF; --> l_gms_enabled = 'Y'

      IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Updating txn interface status to I';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

    -- BUG:4748305  DFHC.D4:PRC INTERFACE SUPPLIER COST NOT INTERFACING
    -- VALID INVOICE DISTRIBUTIONS
    -- We allow good ap invoice distributions to interface in a expenditure
    -- and do not reject all the expenditure items in expenditure
    -- This is only done for VI items.

      UPDATE  pa_transaction_interface
              -- SST Change: If there's post import extension, then
              -- set status code to 'I' so the post import extension
              -- will pick it up, otherwise set to 'A' meaning it has
              -- completed the transfer process.  Post-extension will
              -- eventually set the status code to 'A' as well if the
              -- the transaction went through post extension
              -- successfully.
         SET
              transaction_status_code = decode(G_post_processing_extn,NULL,'A',
                                        'I')
       WHERE
              expenditure_id = G_expenditure_id
         -- Bug 3613784 : Performance fix
	 AND  batch_name = P_batch_name
         AND transaction_rejection_code is NULL; -- Bug 3613784 : Performance fix

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Updated ' || SQL%ROWCOUNT || ' txn interface for accepted expenditures';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

    ELSE  --IF ( NOT REJECT_EXP ) THEN

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Updating txn interface for rejected expenditures';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
      UPDATE  pa_transaction_interface
         SET
               transaction_status_code = decode(expenditure_item_id, 0, 'P', 'R') , /* Bug 8709614  */
               expenditure_item_id = decode(expenditure_item_id, 0, 0, NULL), /* Bug 8709614  */
              -- SST Change: For rejected expenditure, we need
              -- to reset interface table's reversed_orig_txn_reference
              -- field.  This field is updated after calling validateitem
              -- for each transaction.  While processing an entire
              -- expenditure, some transaction may pass validateitem API
              -- and get their reversed_orig_txn_reference field modified;
              -- Thus, at the end of each expenditure, we need to go back
              -- to reset the reversed_orig_txn_reference field to the
              -- original value when the expenditure is rejected.
              reversed_orig_txn_reference = l_RevOrigTxnRef
       WHERE
              expenditure_id = G_expenditure_id
	 AND  batch_name = P_batch_name ; -- Bug 3613784 : Performance fix

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Updated ' || SQL%ROWCOUNT || ' txn interface for rejected expenditures';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
    END IF;

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling pa_transactions.FlushEiTabs';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;
    pa_transactions.FlushEiTabs;

    -- Bug 752915, added the following to flush the adjustments ei pl/sql table
    --
    pa_adjustments.ExpAdjItemTab := pa_utils.EmptyIdTab;

	/***** Bug 4106188 CWK Changes *****/
--	release_po_line_task_lock;
--	init_po_amt_chk;
	/***** Bug 4106188 CWK Changes *****/


    REJECT_EXP := FALSE;
    pa_cc_utils.reset_curr_function;
  END newExpend;

  PROCEDURE InitPLSQLTab IS
  BEGIN
    --l_ExpendTab
    --l_Expend2Tab
    l_SysLinkTab.Delete;
    l_EmpNumTab.Delete;
    l_EiEndDateTab.Delete;
    l_OrganizationNameTab.Delete;
    l_EiDateTab.Delete;
    l_PrjNumTab.Delete;
    l_TaskNumTab.Delete;
    l_ETypeTab.Delete;
    l_NlrTab.Delete;
    l_NlrOrgNameTab.Delete;
    l_QtyTab.Delete;
    l_rawCostTab.Delete;
    l_rawCostRateTab.Delete;
    l_OrigTxnRefTab.Delete;
    l_AttCatTab.Delete;
    l_Att1Tab.Delete;
    l_Att2Tab.Delete;
    l_Att3Tab.Delete;
    l_Att4Tab.Delete;
    l_Att5Tab.Delete;
    l_Att6Tab.Delete;
    l_Att7Tab.Delete;
    l_Att8Tab.Delete;
    l_Att9Tab.Delete;
    l_Att10Tab.Delete;
    l_ExpCommentTab.Delete;
    l_InterfaceIdTab.Delete;
    l_ExpIdTab.Delete;
    l_UnMatchNegFlagTab.Delete;
    l_ExpItemIdTab.Delete;
    --l_JobIdTab.Delete;
    l_OrgIdTab.Delete;
    l_DRCCIDTab.Delete;
    l_CRCCIDTab.Delete;
    l_SysRef1Tab.Delete;
    l_SysRef2Tab.Delete;
    l_SysRef3Tab.Delete;
    l_Sysref4Tab.Delete;
    l_GlDateTab.Delete;
    l_burdenedCostTab.Delete;
    l_BdCostRateTab.Delete;
    l_RcptCurrAmtTab.Delete;
    l_RcptCurrCodeTab.Delete;
    l_RcptExchRateTab.Delete;
    l_DenomCurrCodeTab.Delete;
    l_DenomRawCostTab.Delete;
    l_DenomBdCostTab.Delete;
    l_AcctRateDateTab.Delete;
    l_AcctRateTypeTab.Delete;
    l_AcctExchRateTab.Delete;
    l_AcctRawCostTab.Delete;
    l_AcctBdCostTab.Delete;
    l_AcctExchRndLimitTab.Delete;
    l_ProjCurrCodeTab.Delete;
    l_prjRateDateTab.Delete;
    l_PrjRateTypeTab.Delete;
    l_PrjExchRateTab.Delete;
    l_OrigExpTxnRef1Tab.Delete;
    l_OrigUsrExpTxnRefTab.Delete;
    l_VendorNumTab.Delete;
    l_OrigExpTxnRef2Tab.Delete;
    l_OrigExpTxnRef3Tab.Delete;
    l_OverrideOrgNameTab.Delete;
    l_RevOrigTxnRefTab.Delete;
    l_billableFlagTab.Delete;
    l_TxnIfIdTab.Delete;
    l_PerBusGrpNameTab.Delete;
    l_ProjFuncCurrCodeTab.Delete;
    l_PrjFuncRateDateTab.Delete;
    l_PrjFuncRateTypeTab.Delete;
    l_PrjFuncExchRateTab.Delete;
    l_ProjRawCostTab.Delete;
    l_ProjBdCostTab.Delete;
    l_AsgnNameTab.Delete;
    l_WorkTypeNameTab.Delete;
    l_AccrualFlagTab.Delete;
    l_PrjIdTab.Delete;
    l_TaskIdTab.Delete;
    l_PersonIdTab.Delete;
    l_OrganizationIdTab.Delete;
    l_NLROrgIDTab.Delete;
    l_VendorIdTab.Delete;
    l_OverrideOrgIdTab.Delete;
    l_AsgnIdTab.Delete;
    l_WorkTypeIdTab.Delete;
    l_PersonBusGrpIdTab.Delete;
    l_EmpOrgIdTab.Delete;
    l_EmpJobIdTab.Delete;
    l_po_numberTab.Delete; /* cwk */
    l_po_header_idTab.Delete;
    l_po_line_numTab.Delete;
    l_po_line_idTab.Delete;
    l_person_typeTab.Delete;
    l_po_price_typeTab.Delete;
    l_wip_resource_idTab.Delete;
    l_inventory_item_idTab.Delete;
    l_unit_of_measureTab.Delete;

    /* REL12-AP Lines uptake  START
    ** Support for Related items and cdl_system_reference5
    ** cdl_system_reference3 to store invoice distribution ID
    */
    l_SysRef5Tab.Delete ;
    l_AdjExpItemIdTab.Delete ;
    l_FcDocTypeTab.Delete ;
    l_DocumentTypeTab.DELETE ;
    l_DocumentDistTypeTab.DELETE ;
    l_siaAddFlagTab.DELETE ;
    l_adjTxnInterfaceIDTab.delete ;
    l_NZAdjFlagTab.delete ;
    l_AdjTxnEiIDTab.delete ;
    l_scXferCdTab.delete ;
    -- REL12 AP Lines Uptake
    -- Cash based accounting support
    --
    l_finalPaymentIdTab.delete ;
    l_txn_rejected_sr5tab.DELETE ;
    l_txn_rejected_sr4tab.DELETE ;

    /* REL12-AP Lines uptake  END   */

   -- l_agreement_idTab.DELETE ;    --FSIO Changes
   -- l_agreement_numberTab.DELETE ;

        init_po_amt_chk;

  END InitPLSQLTab;

  --
  -- Bug:5064930
  -- Reject the net zero reversals if pa adjustments have rejected
  -- logic description:
  --    supplier cost reversal transaction interface reverse the project
  --    adjustments corresponding to the source transactions.
  --    Supplier cost reversed transactions do not get interface if
  --    project adjustment reversal fails.
  --    Following function stamp the supplier cost reversal with the same rejection code as
  --    of the corresponding project adjustments that has rejected before in the same batch
  --
  --
  FUNCTION get_parent_txn_status( p_status varchar2, p_indx number ) return varchar2 is
     l_status         varchar2(50) ;
     l_parent_dist_id  number ;
     l_rejected_txn_id number ;

     cursor c_prepay is
	select reversed_prepay_app_dist_id
	  from ap_prepay_app_dists
         where prepay_app_dist_id =  NVL(l_SysRef4Tab(p_indx),0)  ;

     cursor c_payment is
	select reversal_inv_pmt_id
	  from AP_Invoice_Payments
         where Invoice_Payment_Id =  NVL(l_SysRef4Tab(p_indx),0)
	   and nvl(reversal_flag,'N')  = 'Y' ;

     cursor c_invdist is
	select parent_reversal_id
	  into l_parent_dist_id
	  from ap_invoice_distributions_all apd
         where invoice_distribution_id =  NVL(l_SysRef5Tab(p_indx),0)
	   and nvl(reversal_flag,'N')  = 'Y' ;

     cursor c_rcvtxn is
	select parent_transaction_id
	  from rcv_transactions
	 where transaction_id = NVL(l_SysRef4Tab(p_indx),0) ;

     cursor c_status_cd is
        select  transaction_rejection_code
          from  pa_transaction_interface_all
         where  txn_interface_id = l_rejected_txn_id
           and  transaction_status_code  = 'R'  ;
  BEGIN
      l_status := p_status ;

      IF l_status is not null                  OR
         NVL(l_nzAdjFlagTab(p_indx), 'N')  <> 'Y'   OR
         v_calling_module <> 'PAAPIMP'  THEN

          RETURN l_status ;
      end if ;
      pa_cc_utils.set_curr_function('get_parent_txn_status');

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: X_transaction_source :' || X_transaction_source);
         log_message('log_message: G_cash_based_accounting :' || G_cash_based_accounting);
         log_message('log_message: l_DocumentDistTypeTab :' || l_DocumentDistTypeTab(p_indx));
         log_message('log_message: l_SysRef5Tab(p_indx) :' ||  l_SysRef5Tab(p_indx));
         log_message('log_message: l_SysRef4Tab(p_indx) :' ||  l_SysRef4Tab(p_indx));
      END IF;

      l_parent_dist_id := NULL ;


      IF  X_transaction_source in ( 'AP EXPENSE', 'AP INVOICE', 'AP NRTAX' , 'AP ERV',
                                  'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES', 'AP VARIANCE' ) THEN
      -- {
	 IF  G_cash_based_accounting = 'Y' THEN
	 -- {{{
	    IF l_DocumentDistTypeTab(p_indx) = 'PREPAY' THEN
	       open c_prepay ;
	       fetch c_prepay into l_parent_dist_id ;
	       close c_prepay ;
	    ELSE
	       open c_payment ;
	       fetch c_payment into l_parent_dist_id ;
	       close c_payment ;
	    END IF ;

            IF  l_txn_rejected_sr4tab.EXISTS(l_parent_dist_id) THEN
                l_rejected_txn_id  := l_txn_rejected_sr4tab(l_parent_dist_id)  ;
	    END IF ;
         -- }}}
	 ELSE
	 -- {{{
	    open c_invdist ;
	    fetch c_invdist into l_parent_dist_id ;
	    close c_invdist ;

            IF  l_txn_rejected_sr5tab.EXISTS(l_parent_dist_id) THEN
	        l_rejected_txn_id  := l_txn_rejected_sr5tab(l_parent_dist_id)  ;
	    END IF ;

	 END IF ;
	 --}}}
      END IF ; -- }

      IF X_transaction_source in ( 'PO RECEIPT', 'PO RECEIPT NRTAX',
                                   'PO RECEIPT PRICE ADJ', 'PO RECEIPT NRTAX PRICE ADJ' )  THEN
      --{
	  open c_rcvtxn ;
	  fetch c_rcvtxn into l_parent_dist_id ;
	  close c_rcvtxn ;

          IF  l_txn_rejected_sr4tab.EXISTS(l_parent_dist_id) THEN
              l_rejected_txn_id  := l_txn_rejected_sr4tab(l_parent_dist_id)  ;
	  END IF ;
      END IF ; --}

      IF X_transaction_source in (  'AP DISCOUNTS') THEN
      -- {
            open c_payment ;
	    fetch c_payment into l_parent_dist_id ;
	    close c_payment ;

            IF  l_txn_rejected_sr4tab.EXISTS(l_parent_dist_id) THEN
                l_rejected_txn_id  := l_txn_rejected_sr4tab(l_parent_dist_id)  ;
	    END IF ;

      END IF ; --}

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: l_parent_dist_id :' || l_parent_dist_id);
         log_message('log_message: l_rejected_txn_id :' || l_rejected_txn_id);
      END IF;

      IF l_rejected_txn_id is not null then
         open c_status_cd ;
	 fetch c_status_cd into l_status ;
	 close c_status_cd ;
      END IF ;

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: l_status :' || l_status);
      END IF;

      -- 5235363   R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
      --
      IF l_status in ( 'GMS_EXP_ITEM_DT_BEFORE_AWD_ST' ,'GMS_EXP_ITEM_DT_AFTER_AWD_END' ,
                       'GMS_AWARD_IS_CLOSED' , 'EXP_TYPE_INACTIVE' , 'ETYPE_SLINK_INACTIVE' ,
		       'PA_EX_PROJECT_DATE' , 'PA_EXP_TASK_EFF' , 'PA_EXP_ORG_NOT_ACTIVE' , 'NO_ASSIGNMENT' ) THEN
	 --
	 -- l_status      := 'Unable to process this record because at least one record for the same
	 -- distributions has been rejected.'
	 --
	 l_status         := 'PA_REJECTED_PARENT_RECORD' ;
         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: Status Override for child (Date Failure) l_status :' || l_status);
         END IF;
       END IF ;

      pa_cc_utils.reset_curr_function;

      return l_status ;
  END get_parent_txn_status ;
  -- =========================================
  BEGIN

      -- Interface supplier invoices from AP and Web expenses
      -- Interface Web expenses from AP calls import1 program
      -- instead of Import, since the debug log messages are
      -- enabled only in import prog, log messages are not
      -- written out for the Interface programs from AP.
      -- The following two lines should take care of this problem.

      If G_debug_mode is NULL Then
         fnd_profile.get('PA_DEBUG_MODE',G_debug_mode);
         G_debug_mode := NVL(G_debug_mode, 'N');

         pa_debug.set_process(x_process => 'PLSQL',
                              x_debug_mode => G_debug_mode);
      End If;

      pa_cc_utils.log_message('Debug Mode = '||G_debug_mode,1);

      g_request_id := fnd_global.conc_request_id;
      pa_cc_utils.set_curr_function('Import1');
      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Start Transaction Import');
      END IF;

      /* Bug 2451653 commented FND_STATS.Gather_Table_Stats
         Please see earlier versions for the code
      */

      G_user := X_userid;

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'G_trx_link = '|| G_trx_link);
      END IF;

      IF (G_trx_link is null) Then
         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_Stage := 'Retriving Transaction_source';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;
         GetTrxSrcInfo( X_transaction_source );
      End If;

      l_Batch_Size := G_Batch_Size;
      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Initial l_Batch_Size = ' || l_Batch_Size);
      END IF;

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Retriving Currency Info from Imp options';
         log_message('log_message: ' || pa_debug.G_err_stage);
      END IF;

      IF (G_accounting_currency_code IS NULL) THEN
         GetImpCurrInfo;
      END IF;

      IF g_moac_org_id is NULL then
         g_moac_org_id := pa_moac_utils.get_current_org_id ;
      END IF ;

      -- Bug 987539: Initialize v_calling_module according
      -- to transaction source.  Basically this variable is
      -- used when calling validateitem API to let this API
      -- know who is calling it.  By initializing v_calling_module
      -- accordingly, we can let validateitem know that the item
      -- we're validating comes from AP, thus validation is
      -- is not necessary because AP does validation at entry time.
      IF (X_transaction_source in ( 'AP EXPENSE', 'AP INVOICE', 'AP NRTAX', 'AP DISCOUNTS', 'INTERCOMPANY_AP_INVOICES',
                                    'INTERPROJECT_AP_INVOICES', 'AP VARIANCE', 'AP ERV', 'PO RECEIPT', 'PO RECEIPT NRTAX',
				    'PO RECEIPT PRICE ADJ', 'PO RECEIPT NRTAX PRICE ADJ')) THEN
				    -- pricing changes
           --added for 1503237
    	   v_calling_module := 'PAAPIMP';
      ELSE
           v_calling_module := 'PAXTRTRX';
      END IF;

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Module:'||v_calling_module);
      END IF;
      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Open and Fetch transaction batches';
         log_message('log_message: ' || pa_debug.G_err_stage);
      END IF;

      /* Check if gms is enabled and keep the status in a variable */

      l_gms_enabled := gms_pa_costing_pkg.grants_implemented;

     /* if NVL(fnd_profile.value('PA_DEBUG_MODE'), 'N') = 'Y' then --FSIO Change
        G_FSIO_ENABLED := 'Y';
      else
        G_FSIO_ENABLED := 'N';
      end if; */

      Open TrxBatches;

      l_CommitSizeRecCount := 0;

      <<batches>>
      Loop    ---{

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_Stage := 'Start TrxBatches loop';
           log_message('log_message: ' || pa_debug.G_err_stage);
        END IF;

        Fetch TrxBatches INTO TrxBatch;

        If TrxBatches%ROWCOUNT = 0 and G_Exit_Main is null Then
           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || pa_debug.G_err_stage,1);
           END IF;
           G_Exit_Main := TRUE;
           Exit batches;
        Elsif TrxBatches%NOTFOUND Then
           IF PG_DEBUG = 'Y' THEN
           pa_debug.G_err_Stage := 'TrxBatches notfound, exit trxbatches';
              log_message('log_message: ' || pa_debug.G_err_stage,1);
           END IF;
           If X_transaction_source <>  'ORACLE TIME AND LABOR' Then  --bug8530681
           G_Exit_Main := TRUE; --Bug 7307479
           End If;
           Exit batches;
        End If;

        GROUP_CREATED := FALSE;
        --G_group_name := TrxBatch.exp_group_name;

        If l_Batch_Size = 0 Then

             SELECT sum(xc.transaction_count)
               INTO l_Batch_Size
               FROM pa_transaction_xface_control xc
              WHERE xc.transaction_source = TrxBatch.transaction_source
                AND xc.status             = 'PENDING';

             IF PG_DEBUG = 'Y' THEN
                log_message('log_message: ' || 'l_Batch_Size is zero,set it to sum of transaction_count = '||l_Batch_Size);
             END IF;

        End If;

        IF PG_DEBUG = 'Y' THEN
		   pa_debug.G_err_Stage := 'Locking xface ctrl record';
           log_message('log_message: ' || pa_debug.G_err_stage||
                         'Transaction source = '||TrxBatch.transaction_source
                         ||' batch= '||TrxBatch.batch_name||' sys link= '||
                         TrxBatch.system_linkage_function);
        END IF;

        dummy := lockCntrlRec( TrxBatch.transaction_source
                           , TrxBatch.batch_name
                           , TrxBatch.system_linkage_function );

        IF ( dummy = 0 ) THEN   ---{

          IF PG_DEBUG = 'Y' THEN
             log_message('log_message: ' || 'Final l_Batch_Size = '|| l_Batch_Size);
          END IF;

           IF (l_CommitSizeRecCount <> l_Batch_Size) THEN    ---{

             IF PG_DEBUG = 'Y' THEN
		pa_debug.G_err_Stage := 'Open cursor trxrecs';
                log_message('log_message: ' ||  pa_debug.G_err_Stage);
                log_message('log_message: ' || 'source = '||TrxBatch.transaction_source ||
                                     ' , batch = ' || TrxBatch.batch_name ||
                                     ' sys link = ' || TrxBatch.system_linkage_function);
	      END IF;

             /** Bug#3026218 There are only two cursors, as per the changes done
		     *** and hence open them based on Sys Link Fn
		     **/

			If (TrxBatch.system_linkage_function = 'ST') Then
                   OPEN TrxRecs1( TrxBatch.transaction_source
                               , TrxBatch.batch_name
                               , TrxBatch.system_linkage_function  );
             Else
                   OPEN TrxRecs2( TrxBatch.transaction_source
                               , TrxBatch.batch_name
                               , TrxBatch.system_linkage_function  );
             End If;

             FIRST_RECORD := TRUE;

             IF PG_DEBUG = 'Y' THEN
                log_message('log_message: ' ||  'Start Trxrec loop',1);
             END IF;

             --Initialize PL/SQL tables
             InitPlSqlTab;

             If l_Batch_Size = 0 Then
                l_BatchRecCount := TrxBatch.transaction_count;
             Else
                l_BatchRecCount := l_Batch_Size - l_CommitSizeRecCount;
             End If;

             IF PG_DEBUG = 'Y' THEN
                log_message('log_message: ' || 'Batch = '||l_BatchRecCount);
                log_message('log_message: ' ||  'Fetch bulk from Trxrec');
             END IF;

	     -- REL12 AP Lines Uptake
	     -- Determine cash Based accounting flag

	     SELECT NVL(glb.sla_ledger_cash_basis_flag,'N')
	       INTO G_cash_based_accounting
	       FROM gl_sets_of_books glb, pa_implementations_all pai
	      WHERE glb.set_of_books_id = pai.set_of_books_id
	        AND pai.org_id          = g_moac_org_id ;

             /** Bug#3026218 There will be only two fetches - from TrxRecs1 and TRxRecs2
             *** Removed the code that is based on Pre-defined flag
	     **/

             If (TrxBatch.system_linkage_function = 'ST') Then --{

                   FETCH TrxRecs1 bulk collect into
                         l_SysLinkTab
                       , l_EiEndDateTab
                       , l_EmpNumTab
                       , l_OrganizationNameTab
                       , l_EiDateTab
                       , l_PrjNumTab
                       , l_TaskNumTab
                       , l_ETypeTab
                       , l_NlrTab
                       , l_NlrOrgNameTab
                       , l_QtyTab
                       , l_rawCostTab
                       , l_rawCostRateTab
                       , l_OrigTxnRefTab
                       , l_AttCatTab
                       , l_Att1Tab
                       , l_Att2Tab
                       , l_Att3Tab
                       , l_Att4Tab
                       , l_Att5Tab
                       , l_Att6Tab
                       , l_Att7Tab
                       , l_Att8Tab
                       , l_Att9Tab
                       , l_Att10Tab
                       , l_ExpCommentTab
                       , l_InterfaceIdTab
                       , l_ExpIdTab
                       , l_UnMatchNegFlagTab
                       , l_ExpItemIdTab
                     --, l_JobIdTab
                       , l_OrgIdTab
                       , l_DRCCIDTab
                       , l_CRCCIDTab
                       , l_SysRef1Tab
                       , l_SysRef2Tab
                       , l_SysRef3Tab
                       , l_Sysref4Tab
                       , l_Sysref5Tab
                       , l_GlDateTab
                       , l_burdenedCostTab
                       , l_BdCostRateTab
                       , l_RcptCurrAmtTab
                       , l_RcptCurrCodeTab
                       , l_RcptExchRateTab
                       , l_DenomCurrCodeTab
                       , l_DenomRawCostTab
                       , l_DenomBdCostTab
                       , l_AcctRateDateTab
                       , l_AcctRateTypeTab
                       , l_AcctExchRateTab
                       , l_AcctRawCostTab
                       , l_AcctBdCostTab
                       , l_AcctExchRndLimitTab
                       , l_ProjCurrCodeTab
                       , l_prjRateDateTab
                       , l_PrjRateTypeTab
                       , l_PrjExchRateTab
                       , l_OrigExpTxnRef1Tab
                       , l_OrigUsrExpTxnRefTab
                       , l_VendorNumTab
                       , l_OrigExpTxnRef2Tab
                       , l_OrigExpTxnRef3Tab
                       , l_OverrideOrgNameTab
                       , l_RevOrigTxnRefTab
                       , l_billableFlagTab
                       , l_TxnIfIdTab
                       , l_PerBusGrpNameTab
                       , l_ProjFuncCurrCodeTab
                       , l_PrjFuncRateDateTab
                       , l_PrjFuncRateTypeTab
                       , l_PrjFuncExchRateTab
                       , l_ProjRawCostTab
                       , l_ProjBdCostTab
                       , l_AsgnNameTab
                       , l_WorkTypeNameTab
                       , l_AccrualFlagTab
                       , l_PrjIdTab
                       , l_TaskIdTab
                       , l_PersonIdTab
                       , l_OrganizationIdTab
                       , l_NLROrgIDTab
                       , l_VendorIdTab
                       , l_OverrideOrgIdTab
                       , l_AsgnIdTab
                       , l_WorkTypeIdTab
                       , l_PersonBusGrpIdTab
		       ,  l_po_numberTab /* cwk */
		       ,  l_po_header_idTab
		       ,  l_po_line_numTab
		       ,  l_po_line_idTab
		       ,  l_person_typeTab
		       ,  l_po_price_typeTab
		       ,  l_wip_resource_idTab
		       ,  l_inventory_item_idTab
		       ,  l_unit_of_measureTab
		       ,  l_AdjExpItemIdTab
		       ,  l_FcDocTypeTab
		       ,  l_DocumentTypeTab
		       ,  l_DocumentDistTypeTab
                       ,  l_siaAddFlagTab
		       ,  l_AdjTxnInterfaceIdTab
		       ,  l_nzAdjFlagTab
		       ,  l_scXferCdTab
		       ,  l_finalPaymentIdTab
                      -- ,  l_agreement_idTab     --FSIO Changes
                      -- ,  l_agreement_numberTab
                    LIMIT l_BatchRecCount;

             Else

                   FETCH TrxRecs2 bulk collect into
                         l_SysLinkTab
                       , l_EiEndDateTab
                       , l_EmpNumTab
                       , l_OrganizationNameTab
                       , l_EiDateTab
                       , l_PrjNumTab
                       , l_TaskNumTab
                       , l_ETypeTab
                       , l_NlrTab
                       , l_NlrOrgNameTab
                       , l_QtyTab
                       , l_rawCostTab
                       , l_rawCostRateTab
                       , l_OrigTxnRefTab
                       , l_AttCatTab
                       , l_Att1Tab
                       , l_Att2Tab
                       , l_Att3Tab
                       , l_Att4Tab
                       , l_Att5Tab
                       , l_Att6Tab
                       , l_Att7Tab
                       , l_Att8Tab
                       , l_Att9Tab
                       , l_Att10Tab
                       , l_ExpCommentTab
                       , l_InterfaceIdTab
                       , l_ExpIdTab
                       , l_UnMatchNegFlagTab
                       , l_ExpItemIdTab
                     --, l_JobIdTab
                       , l_OrgIdTab
                       , l_DRCCIDTab
                       , l_CRCCIDTab
                       , l_SysRef1Tab
                       , l_SysRef2Tab
                       , l_SysRef3Tab
                       , l_Sysref4Tab
                       , l_Sysref5Tab
                       , l_GlDateTab
                       , l_burdenedCostTab
                       , l_BdCostRateTab
                       , l_RcptCurrAmtTab
                       , l_RcptCurrCodeTab
                       , l_RcptExchRateTab
                       , l_DenomCurrCodeTab
                       , l_DenomRawCostTab
                       , l_DenomBdCostTab
                       , l_AcctRateDateTab
                       , l_AcctRateTypeTab
                       , l_AcctExchRateTab
                       , l_AcctRawCostTab
                       , l_AcctBdCostTab
                       , l_AcctExchRndLimitTab
                       , l_ProjCurrCodeTab
                       , l_prjRateDateTab
                       , l_PrjRateTypeTab
                       , l_PrjExchRateTab
                       , l_OrigExpTxnRef1Tab
                       , l_OrigUsrExpTxnRefTab
                       , l_VendorNumTab
                       , l_OrigExpTxnRef2Tab
                       , l_OrigExpTxnRef3Tab
                       , l_OverrideOrgNameTab
                       , l_RevOrigTxnRefTab
                       , l_billableFlagTab
                       , l_TxnIfIdTab
                       , l_PerBusGrpNameTab
                       , l_ProjFuncCurrCodeTab
                       , l_PrjFuncRateDateTab
                       , l_PrjFuncRateTypeTab
                       , l_PrjFuncExchRateTab
                       , l_ProjRawCostTab
                       , l_ProjBdCostTab
                       , l_AsgnNameTab
                       , l_WorkTypeNameTab
                       , l_AccrualFlagTab
                       , l_PrjIdTab
                       , l_TaskIdTab
                       , l_PersonIdTab
                       , l_OrganizationIdTab
                       , l_NLROrgIDTab
                       , l_VendorIdTab
                       , l_OverrideOrgIdTab
                       , l_AsgnIdTab
                       , l_WorkTypeIdTab
                       , l_PersonBusGrpIdTab
		       ,  l_po_numberTab /* cwk */
		       ,  l_po_header_idTab
		       ,  l_po_line_numTab
		       ,  l_po_line_idTab
		       ,  l_person_typeTab
		       ,  l_po_price_typeTab
		       ,  l_wip_resource_idTab
		       ,  l_inventory_item_idTab
		       ,  l_unit_of_measureTab
		       ,  l_AdjExpItemIdTab
		       ,  l_FcDocTypeTab
		       ,  l_DocumentTypeTab
		       ,  l_DocumentDistTypeTab
                       ,  l_siaAddFlagTab
		       ,  l_AdjTxnInterfaceIdTab
		       ,  l_nzAdjFlagTab
		       ,  l_scXferCdTab
		       ,  l_finalPaymentIdTab
                     --  ,  l_agreement_idTab     --FSIO Changes
                      -- ,  l_agreement_numberTab
                    LIMIT l_BatchRecCount;

             End If;  --} /* TrxBatch.system_linkage_function = 'ST' */


             IF PG_DEBUG = 'Y' THEN
             pa_debug.g_err_stage := 'Log: No. of records fetched = '||l_TxnIfIDTab.count;
                log_message('log_message: ' || pa_debug.G_err_stage);
             END IF;
             l_ActualBatchRecCnt := l_TxnIfIDTab.count;


	     /* Bug#3451108 - Added code - Start */
			 IF l_TxnIfIDTab.count = 0 THEN

                IF PG_DEBUG = 'Y' THEN
                  log_message('log_message: ' || 'Fetch did not get any records, exit batches');
                END IF;

		        UpdControlProcessed( P_TrxSource      => TrxBatch.transaction_source,
                             P_BatchName      => TrxBatch.batch_name,
                             P_XfaceId        => X_xface_id,
                             P_TxnCount       => TrxBatch.transaction_count,
                             P_ProcCount      => TrxBatch.processed_count,
                             P_BatchProcCount => l_ActualBatchRecCnt,
                             P_System_Linkage_Function  => TrxBatch.system_linkage_function);

G_Exit_Main := TRUE;--anuragag Bug9349328
                Exit batches;
              END IF; /* l_TxnIfIDTab.count = 0  */
	     /* Bug#3451108 - Added code - End */

             FOR Z in 1..l_TxnIfIDTab.count LOOP  ---{        /* cwk */

             IF TrxBatch.system_linkage_function in ('ST','OT','VI','ER') THEN
                    null;
             ELSE
		         l_po_numberTab(z) := null;
		         l_po_header_idTab(z) := null;
		         l_po_line_numTab(z) := null;
		         l_po_line_idTab(z) := null;
                   l_po_price_typeTab(z) := null;
              END IF;

              END LOOP;   ---}

            --
            -- Bug : 4962731
            --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
            --
            IF G_cash_based_accounting = 'Y' and
	       X_transaction_source in ( 'AP EXPENSE', 'AP INVOICE', 'AP NRTAX' , 'AP ERV',
	                                 'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES', 'AP VARIANCE' ) THEN
               G_Profile_Discount_Start_date := fnd_date.canonical_to_date(PAAPIMP_PKG.return_profile_discount_date);
	       G_Discount_Method             := PAAPIMP_PKG.return_discount_method;
	    END IF ;

             FOR J in 1..l_TxnIfIDTab.count LOOP  ---{

                 -- REL12 : AP Lines uptake
		 -- We only support net zero transactions for supplier invoice interface
		 --
	         IF v_calling_module <> 'PAAPIMP' THEN
		    l_adjTxnInterfaceIDTab(j) := NULL ;
		    l_NZAdjFlagTab(j)         := NULL ;
		    -- supplier cost transfer status code is used only for supplier cost
		    -- interface process.
		    -- The value is ignored for all other transaction source
		    l_scXfercdTab(j)          := NULL ;
                 ELSE
                    -- REL12 AP Lines Uptake
                    -- Cash based accounting support
                    --
                    IF G_cash_based_accounting = 'Y' and
	               X_transaction_source in ( 'AP EXPENSE', 'AP INVOICE', 'AP NRTAX' , 'AP ERV',
	                                         'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES', 'AP VARIANCE' ) THEN

                       l_invoice_id          := NVL(l_SysRef2Tab(j) ,0) ;
		       l_payment_status_flag := 'N' ;

		       -- R12 AP lines uptake : Prepayment changes
		       -- For R12 prepayments applications , final payment logic is not required.Hence introduced below If condition

		       l_finalPaymentIdTab(j) := 0 ;

                       IF l_DocumentDistTypeTab(j) <> 'PREPAY' THEN -- R12 AP lines uptake : Prepayment changes

			       open c_final_payment ;
			       fetch c_final_payment into l_payment_status_flag ;
			       close c_final_payment ;

			       IF NVL(l_payment_status_flag,'N')  = 'Y' THEN
				  SELECT max(Invoice_Payment_Id)
				    into l_finalPaymentIdTab(j)
				    from ap_payment_hist_dists Paydist
				    where NVL(paydist.pay_dist_lookup_code, 'CASH') = 'CASH'
				      and Paydist.invoice_distribution_id           = NVL(l_SysRef5Tab(j) ,0)  ;
			       END IF ; --  l_payment_status_flag = 'Y'

                       END IF;  --IF l_DocumentDistTypeTab(j) <> 'PREPAY' THEN
	             END IF ; -- G_cash_based_accounting = 'Y'

                     IF PG_DEBUG = 'Y' THEN
                        log_message('log_message: l_invoice_id :' || l_invoice_id);
                        log_message('log_message: l_payment_status_flag :' || l_payment_status_flag);
                        log_message('log_message: NVL(l_SysRef5Tab(j) ,0) :' || NVL(l_SysRef5Tab(j) ,0));
                        log_message('log_message: l_finalPaymentIdTab(j) :' || l_finalPaymentIdTab(j));
                     END IF;
		 END IF ;

                 IF PG_DEBUG = 'Y' THEN
                    log_message('log_message: ' || 'Inside TrxRec Loop ' || l_CommitSizeRecCount || 'Txn If = ' || l_TxnIfIDTab(j));
                 END IF;

                 l_CommitSizeRecCount := l_CommitSizeRecCount + 1;

                 -- Funds check related change
                 g_cdl_system_reference2 := to_number(TRIM(l_SysRef2Tab(j))); -- Bug 3704356
                 g_cdl_system_reference3 := to_number(TRIM(l_SysRef3Tab(j))); -- Bug 3704356
		 g_cdl_system_reference4 := l_SysRef4Tab(j); -- 2339216; Commented for bug 4281765
                 -- REL12 AP Lines Uptake
                 -- Cash based accounting support
                 --
		 g_finalPaymentId        := l_finalPaymentIdTab(j) ;

		 /* REL12-AP Lines uptake */
		 g_cdl_system_reference5 := to_number(TRIM(l_SysRef5Tab(j))); -- 2339216
                 -- End Funds check related change

                 IF PG_DEBUG = 'Y' THEN
                    log_message('log_message: g_cdl_system_reference2 :' || g_cdl_system_reference2);
                    log_message('log_message: g_cdl_system_reference3 :' || g_cdl_system_reference3);
                    log_message('log_message: g_cdl_system_reference4 :' || g_cdl_system_reference4);
                    log_message('log_message: g_cdl_system_reference5 :' || g_cdl_system_reference5);
                    log_message('log_message: g_finalPaymentId :' || g_finalPaymentId);
                 END IF;

                 -- SST Changes
                 -- Initilize reversed orig txn reference
                 G_reversed_orig_txn_reference := l_RevOrigTxnRefTab(j);

                 l_sys_link             := l_SysLinkTab(j);
                 l_expenditure_id       := l_ExpIdTab(j);
                 l_RevOrigTxnRef        := l_RevOrigTxnRefTab(j);
                 l_Accrual_Flag         := l_AccrualFlagTab(j);

		 /* Fix for bug 2686544: Getting organization_name based on G_emp_org_oride flag
		    here instead of inside the TrxRec cursors */
                 /* Bug#3026218 For user-defined sources and predefined source with no Ids use
		    the Organization_Name */
/**                 If ( (G_trx_predef_flag = 'N') OR
***                      (G_trx_predef_flag = 'Y' and l_PrjIdTab(j) is null) ) Then
**/
                IF  l_PrjIdTab(j) IS NULL THEN
                    If (nvl(G_emp_org_oride,'N') = 'Y') Then  --Bug 2719674 added nvl
                        If (l_OrganizationNameTab(j) is null) Then
			        l_OrganizationNameTab(j) := GetOrgName(l_EmpNumTab(j),
				                                       l_EiDateTab(j),
								       l_PerBusGrpNameTab(j),
								       l_person_typeTab(j)); /*cwk */
                        End If;
                    Else
			If (l_EmpNumTab(j) is not null) Then
			        l_OrganizationNameTab(j) := GetOrgName(l_EmpNumTab(j),
				                                       l_EiDateTab(j),
								       l_PerBusGrpNameTab(j),
								       l_person_typeTab(j)); /*cwk */
                        End If;
                    End If;
                 End If;
		 /* bug 2686544 */

                   IF PG_DEBUG = 'Y' THEN
                      log_message('log_message: ' || 'Before selecting expend grouping attributes for transaction sources');
                   END IF;

                   If (nvl(G_emp_org_oride,'N') = 'N' and l_PersonIdTab(j) is not NULL) Then /* bug#2719674 added nvl */

                       IF PG_DEBUG = 'Y' THEN
                       pa_debug.G_err_stage := 'Calling pa_utils.GetEmpOrgJobId';
                          log_message('log_message: ' || pa_debug.G_err_Stage);
                       END IF;
                       pa_utils.GetEmpOrgJobId( l_PersonIdTab(j),
                                                l_EiDateTab(j),
                                                l_EmpOrgIdTab(j),
                                                l_EmpJobIdTab(j) );

                         /* Bug 6857130: For Reversal trxns from OTL, stamping back the organization_id that was passed and
                             discarding the rederived value in the above call*/
                          if (X_transaction_source = 'ORACLE TIME AND LABOR' and
                              l_UnMatchNegFlagTab(j) = 'N' and l_OrganizationIdTab(j) is not null and l_RevOrigTxnRefTab(j) is not null) then

                              IF PG_DEBUG = 'Y' THEN
                                   log_message('log_message: ' || 'Restamping the organization_id back to the value passed from OTL');
                              END IF;

                              l_EmpOrgIdTab(j) := l_OrganizationIdTab(j);
                          end if;
                          /* Bug 6857130 End */


                       IF PG_DEBUG = 'Y' THEN
                       pa_debug.G_err_stage := 'l_EmpOrgIdTab = ' || l_EmpOrgIdTab(j) ||
                                               ' l_EmpJobIdTab = ' || l_EmpJobIdTab(j) ;
                          log_message('log_message: ' || pa_debug.G_err_Stage);
                       END IF;

                   Else
                       l_EmpOrgIdTab(j) := NULL;
                       l_EmpJobIdTab(j) := NULL;

                   End If;

                   SELECT
                     to_char(trunc(l_EiEndDateTab(j)), 'J')||':'||
                     nvl(decode(nvl(l_PersonIdTab(j),0), 0, l_EmpNumTab(j), l_PersonIdTab(j)),
                         '-DUMMY EMP-')||':'||
  		     --removing the logic for getting organization name for getting l_expend1
		     --as it has already been done above for 2686544. So we can just use l_OrganizationNameTab(j)
                     --nvl(decode(G_emp_org_oride,'Y',
                     --           decode(nvl(l_OrganizationIdTab(j),0), 0, l_OrganizationNameTab(j),l_OrganizationIdTab(j)),
                     --           decode(nvl(l_PersonIdTab(j),0),0,
                     --                  decode(l_EmpNumTab(j), null,l_OrganizationNameTab(j),
                     --                         GetOrgName(l_EmpNumTab(j),l_EiDateTab(j), l_PerBusGrpNameTab(j)))
                     --                ,l_EmpOrgIdTab(j))),
		     nvl(decode(nvl(l_OrganizationIdTab(j),0), 0, l_OrganizationNameTab(j), nvl(l_EmpOrgIdTab(j), l_OrganizationIdTab(j)))
                         ,'-DUMMY ORG-')||':'||
                     nvl(l_OrigExpTxnRef1Tab(j), '-DUMMY EXP_TXN_REF1-') || ':' ||
                     nvl(l_OrigUsrExpTxnRefTab(j), '-DUMMY USER_EXP_TXN_REF-') || ':' ||
                     nvl(decode(nvl(l_VendorIdTab(j),0),0,l_VendorNumTab(j),l_VendorIdTab(j)),
                         '-DUMMY VENDOR_NUMBER-') || ':' ||
                     nvl(l_OrigExpTxnRef2Tab(j), '-DUMMY EXP_TXN_REF2-') || ':' ||
                     nvl(l_OrigExpTxnRef3Tab(j), '-DUMMY EXP_TXN_REF3-') || ':' ||
                     nvl(l_AccrualFlagTab(j),'-DUMMY ACC_FLAG-')|| ':' ||
		     nvl(l_person_typeTab(j),'EMP') /* cwk */
                   , decode(l_SysLinkTab(j),'OT','ST',l_SysLinkTab(j)) || ':' ||
                     decode(l_SysLinkTab(j),'ER', nvl(l_DenomCurrCodeTab(j),'-DUMMY CODE-'),
                                           'VI', nvl(l_DenomCurrCodeTab(j),'-DUMMY CODE-'),
                                           '-DUMMY CODE-')||':'||
                     decode(l_SysLinkTab(j),'ER', nvl(to_char(l_AcctRateDateTab(j),'MMDDYYYY'),'-DUMMY DATE-'),
                                           'VI', nvl(to_char(l_AcctRateDateTab(j),'MMDDYYYY'),'-DUMMY DATE-'),
                                           '-DUMMY DATE-')||':'||
                     decode(l_SysLinkTab(j),'ER', nvl(l_AcctRateTypeTab(j),'-DUMMY TYPE-'),
                                           'VI', nvl(l_AcctRateTypeTab(j),'-DUMMY TYPE-'),
                                           '-DUMMY TYPE-')||':'||
                     decode(l_SysLinkTab(j),'ER', nvl(to_char(l_AcctExchRateTab(j)),'-DUMMY RATE-'),
                                           'VI', nvl(to_char(l_AcctExchRateTab(j)),'-DUMMY RATE-'),
                                           '-DUMMY RATE-')
                   Into l_Expend1, l_Expend2
                   From Dual;

                 IF ( FIRST_RECORD ) THEN
                   IF PG_DEBUG = 'Y' THEN
                   pa_debug.G_err_stage := 'Calling loadExpCompareVars';
                      log_message('log_message: ' || 'First Record Fetched');
                      log_message('log_message: ' || pa_debug.G_err_stage);
                   END IF;

                   loadExpCompareVars( l_Expend1
                              , l_Expend2
                              , l_EiEndDateTab(j)
                              , l_OrigExpTxnRef1Tab(j)
                              , l_OrigUsrExpTxnRefTab(j)
                              , l_OrigExpTxnRef2Tab(j)
                              , l_OrigExpTxnRef3Tab(j));
                   FIRST_RECORD := FALSE;

                 /* Bug#2374725 Commented the following ELSIF statement and added a new condition */
                 /* ELSIF ( current_expend <> l_Expend1 OR current_expend2 <> l_Expend2) THEN */
                 ELSIF (x_transaction_source <>  'Oracle Self Service Time' and
                        (current_expend <> l_Expend1 OR current_expend2 <> l_Expend2)) OR
                       (x_transaction_source = 'Oracle Self Service Time' and
                        l_ExpIdTab(j) <> G_expenditure_id) OR
		       (x_transaction_source = 'ORACLE TIME AND LABOR' and  --Bug#4049401
                        l_EmpOrgIdTab(j) <> G_org_id) THEN

                   IF PG_DEBUG = 'Y' THEN
                   pa_debug.G_err_stage := 'Calling newExpend when expenditure changes';
                      log_message('log_message: ' || pa_debug.G_err_stage);
                      log_message('log_message: ' || 'Record Count = ' || i);
                   END IF;

                    newExpend( TrxBatch.exp_group_name
                     , current_period
                     , i
                     , prev_denom_currency_code
                     , G_accounting_currency_code
                     , prev_acct_rate_type
                     , prev_acct_rate_date
                     , prev_acct_exchange_rate
                     , prev_person_type /* cwk */
					 , TrxBatch.batch_name ); -- Bug 3613784 : Performance fix

                   IF PG_DEBUG = 'Y' THEN
                   pa_debug.G_err_stage := 'CAlling loadExpCompareVars';
                      log_message('log_message: ' || pa_debug.G_err_stage);
                   END IF;

                   loadExpCompareVars( l_Expend1
                              , l_Expend2
                              , l_EiEndDateTab(j)
                              , l_OrigExpTxnRef1Tab(j)
                              , l_OrigUsrExpTxnRefTab(j)
                              , l_OrigExpTxnRef2Tab(j)
                              , l_OrigExpTxnRef3Tab(j));
                 END IF;

                 IF PG_DEBUG = 'Y' THEN
                 pa_debug.G_err_stage := 'CAlling ValidateOrgId';
                    log_message('log_message: ' || pa_debug.G_err_stage);
                 END IF;

                 ValidateOrgId(l_OrgIdTab(j),X_org_status );

				 IF ( X_org_status IS NOT NULL) THEN
     	   	     -- Org id is null. Update status.

                     X_status := X_org_status;

                 ELSE -- org id is not null. continue with other validations

                    -- REL12 AP Lines uptake.
		    -- Variance record created for CWK are only for funds check purpose
		    -- and expenditure item will not be created.
		    -- Variance in case of accrue on receipt and amount based PO
		    -- will not create exp items.
                    IF l_ExpItemIdTab(j) = 0 THEN
                       X_ei_id := NULL ;
		       -- null value of expenditure item id would indicate that expenditure item
		       -- will not be created.
                    ELSE
                       X_ei_id := pa_utils.GetNextEiId;

		       -- REL12 : AP Lines uptake
		       -- Support net zero adjusted transactions for the supplier invoice interface.
		       --
		       IF NVL(l_nzAdjFlagTab(j), 'N')  = 'Y' and
		          l_adjTxnInterfaceIdTab(j) is NULL THEN

			  l_adjTxnEiIDTab(l_txnIfIdTab(j)) := X_ei_id ;

                          IF PG_DEBUG = 'Y' THEN
                             pa_debug.G_err_stage := 'AP Net Zero adjusted expenditure item id:'||X_ei_id;
                             log_message('log_message: ' || pa_debug.G_err_stage);
                             pa_debug.G_err_stage := 'TXN Interface ID:'||l_txnIfIdTab(j);
                             log_message('log_message: ' || pa_debug.G_err_stage);
                             pa_debug.G_err_stage := 'l_adjTxnEiIDTab(l_txnIfIdTab(j)):'||l_adjTxnEiIDTab(l_txnIfIdTab(j));
                             log_message('log_message: ' || pa_debug.G_err_stage);
                          END IF;

                       END IF ;

		    END IF ;

                    IF PG_DEBUG = 'Y' THEN
                       log_message('log_message: l_ExpItemIdTab(j) :' || l_ExpItemIdTab(j));
                       log_message('log_message: NVL(l_nzAdjFlagTab(j), N) :' || NVL(l_nzAdjFlagTab(j), 'N'));
                       log_message('log_message: l_adjTxnInterfaceIdTab(j) :' || l_adjTxnInterfaceIdTab(j));
		    END IF ;

                    IF PG_DEBUG = 'Y' THEN
		       pa_debug.G_err_stage := 'CAlling ValidateItem';
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;
		    x_status := NULL ;

                    If (X_transaction_source = 'ORACLE TIME AND LABOR') Then

                       ValidateItemOTL(
                         X_trx_src                => X_transaction_source
                      ,  X_ei_date                => l_EiDateTab(j)
                      ,  X_etype                  => l_ETypeTab(j)
                      ,  X_nlr                    => l_NlrTab(j)
                      ,  X_qty                    => l_QtyTab(j)
                      ,  X_denom_raw_cost         => l_DenomRawCostTab(j)
                      ,  X_module                 => v_calling_module
                      ,  X_trx_ref                => l_OrigTxnRefTab(j)
                      ,  X_match_flag             => l_UnMatchNegFlagTab(j)
                      ,  X_att_cat                => l_AttCatTab(j)
                      ,  X_att1                   => l_Att1Tab(j)
                      ,  X_att2                   => l_Att2Tab(j)
                      ,  X_att3                   => l_Att3Tab(j)
                      ,  X_att4                   => l_Att4Tab(j)
                      ,  X_att5                   => l_Att5Tab(j)
                      ,  X_att6                   => l_Att6Tab(j)
                      ,  X_att7                   => l_Att7Tab(j)
                      ,  X_att8                   => l_Att8Tab(j)
                      ,  X_att9                   => l_Att9Tab(j)
                      ,  X_att10                  => l_Att10Tab(j)
                      ,  X_system_linkage         => l_SysLinkTab(j)
                      ,  X_status                 => X_status
                      --,  X_bill_flag              => X_billable_flag
                      ,  X_denom_currency_code    => l_DenomCurrCodeTab(j)
                      ,  X_acct_rate_date         => l_AcctRateDateTab(j)
                      ,  X_acct_rate_type         => l_AcctRateTypeTab(j)
                      ,  X_acct_exchange_rate     => l_AcctRateTypeTab(j)
                      ,  X_project_currency_code  => l_ProjCurrCodeTab(j)
                      ,  X_Projfunc_currency_code => l_ProjFuncCurrCodeTab(j)
                      ,  X_Projfunc_cost_rate_date =>l_PrjFuncRateDateTab(j)
                      ,  X_Projfunc_cost_rate_type => l_PrjFuncRateTypeTab(j)
                      ,  X_Projfunc_cost_exchange_rate => l_PrjFuncExchRateTab(j)
                      ,  X_Assignment_Name        => l_AsgnNameTab(j)
                      ,  X_Work_Type_Name         => l_WorkTypeNameTab(j)
                      ,  P_project_id             => l_PrjIdTab(j)
                      ,  P_task_id                => l_TaskIdTab(j)
                      ,  P_person_id              => l_PersonIdTab(j)
                      ,  P_organization_id        => l_OrganizationIdTab(j)
                      ,  P_assignment_id          => l_AsgnIdTab(j)
                      ,  P_work_type_id           => l_WorkTypeIdTab(j)
                      ,  P_Emp_Org_Id             => l_EmpOrgIdTab(j)
                      ,  P_Emp_Job_Id             => l_EmpJobIdTab(j)
                      ,  P_po_header_id          => l_po_header_idTab(j)
                      ,  P_po_line_id               => l_po_line_idTab(j)
                      ,  P_person_type            => l_person_typeTab(j)
                      ,  P_po_price_type          => l_po_price_typeTab(j)
					  ,  p_vendor_id              => l_VendorIdTab(j) /* Bug # 3601024 */
					  );

                      X_Billable_Flag := l_BillableFlagTab(j);

                    Else
		       l_gms_fundscheck := 'Y' ;

		       IF ( v_calling_module = 'PAAPIMP'  )  THEN
                          -- REL12 AP Lines Uptake
                          -- Cash based accounting support
                          --
                          IF G_cash_based_accounting = 'Y' and
	                     X_transaction_source in ( 'AP EXPENSE', 'AP INVOICE', 'AP NRTAX' , 'AP ERV',
	                                               'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES', 'AP VARIANCE' ) THEN
                             --
                             -- If one payment rejected then all the payments following it for the given
			     -- invoice distribution id should be rejected.
			     --
                             IF l_rejectedSysRef5 = NVL(l_SysRef5Tab(j),0) THEN

                                -- 5235363   R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
				--
				IF l_status in ( 'GMS_EXP_ITEM_DT_BEFORE_AWD_ST' ,'GMS_EXP_ITEM_DT_AFTER_AWD_END' ,
				                 'GMS_AWARD_IS_CLOSED' , 'EXP_TYPE_INACTIVE' , 'ETYPE_SLINK_INACTIVE' ,
				                 'PA_EX_PROJECT_DATE' , 'PA_EXP_TASK_EFF' , 'PA_EXP_ORG_NOT_ACTIVE' , 'NO_ASSIGNMENT'
					) THEN
				   --
				   -- x_status      := 'Unable to process this record because at least one record for the same
				   -- distributions has been rejected.'
				   --
				   x_status         := 'PA_REJECTED_PARENT_RECORD' ;
				ELSE
			           x_status         := l_status ;
				END IF ;

			     END IF ;

                             IF PG_DEBUG = 'Y' THEN
                                log_message('log_message: If one payment rejected then all the payments following it for the given' );
                                log_message('log_message: invoice distribution id should be rejected.') ;
                                log_message('log_message: x_status :'||x_status ) ;
		             END IF ;


			  ELSE
		             l_rejectedSysRef5   := 0 ;
			  END IF ;

		          IF ( NVL(l_old_sysRef1, '0')    = NVL(l_SysRef1Tab(j), '0') AND
			       NVL(l_old_sysRef2, '0')    = NVL(l_SysRef2Tab(j), '0') AND
			       NVL(l_old_sysRef3, '0')    = NVL(l_SysRef3Tab(j), '0') AND
			       NVL(l_old_sysRef4, '0')    = NVL(l_SysRef4Tab(j), '0') AND
			       NVL(l_old_sysRef5, 0)      = NVL(l_SysRef5Tab(j), 0) ) THEN
			       --
                               -- Project and GMS fundschecking should be done once for a given ap
			       -- distribution lines.
			       -- Here because of adjustments in projects/Grants there may be multiple
			       -- records created to back out the expenditure item.
			       --
			       l_gms_fundscheck := 'N' ;
		               l_FcDocTypeTab(j):= 'NOT' ;
			  ELSE
			       l_gms_fundscheck := 'Y' ;
			       l_old_sysRef1    := l_SysRef1Tab(j) ;
			       l_old_sysRef2    := l_SysRef2Tab(j) ;
			       l_old_sysRef3    := l_SysRef3Tab(j) ;
			       l_old_sysRef4    := l_SysRef4Tab(j) ;
			       l_old_sysRef5    := l_SysRef5Tab(j) ;
			  END IF ;

			  G_adj_item_id := l_AdjExpItemIDTab(j)  ;

                          IF PG_DEBUG = 'Y' THEN
                             log_message('log_message: l_gms_fundscheck :'||l_gms_fundscheck) ;
                             log_message('log_message: l_FcDocTypeTab(j) :'||l_FcDocTypeTab(j)) ;
                             log_message('log_message: G_adj_item_id :'|| G_adj_item_id ) ;
		           END IF ;

			  --
			  -- Bug:5064930
			  -- Reject the net zero reversals if pa adjustments have rejected
			  --
			  x_status := get_parent_txn_status(x_status, j) ;

		          -- R12 Check if we need date validations..
                          -- 5235363   R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
		          -- We do not validate expenditure item adjustments, Net Zero for reversals or
			  -- funds check adjustments.
			  --
			  IF ( G_adj_item_id is NOT NULL ) OR
			     ( l_ExpItemIdTab(j) = 0     ) OR
			     ( l_adjTxnInterfaceIDTab(j) is not NULL )
                          THEN
			     g_paapimp_validate_dt := 'N' ;

			     IF G_adj_item_id = 0 THEN
			        -- PAAPIMP create a record with G_adj_item_id value 0 to indicate date validation
				-- not required for the adjustment created to take care of the accounting mismatch
				-- for the supplier cost adjustments.
				--
			        G_adj_item_id        := NULL ;
				l_AdjExpItemIDTab(j) := NULL ;
			     END IF ;

                          ELSE
			     g_paapimp_validate_dt := 'Y' ;
			  END IF ;
		       END IF ;

                       -- REL12 AP Lines Uptake
                       -- Cash based accounting support
                       -- IF x_status is NULL THEN was added.
		       --
                       IF x_status is NULL THEN
			       ValidateItem(  X_transaction_source
			      ,  l_EmpNumTab(j)
			      ,  l_OrganizationNameTab(j)
			      ,  l_EiEndDateTab(j)
			      ,  l_EiDateTab(j)
			      ,  l_ETypeTab(j)
			      ,  l_PrjNumTab(j)
			      ,  l_TaskNumTab(j)
			      ,  l_NlrTab(j)
			      ,  l_NlrOrgNameTab(j)
			      ,  l_QtyTab(j)
			      ,  l_DenomRawCostTab(j)
			      -- Bug 987539
			      ,  v_calling_module   --'PAXTRTRX'
			      ,  l_OrigTxnRefTab(j)
			      ,  l_UnMatchNegFlagTab(j)
			      ,  X_userid
			      ,  l_AttCatTab(j)
			      ,  l_Att1Tab(j)
			      ,  l_Att2Tab(j)
			      ,  l_Att3Tab(j)
			      ,  l_Att4Tab(j)
			      ,  l_Att5Tab(j)
			      ,  l_Att6Tab(j)
			      ,  l_Att7Tab(j)
			      ,  l_Att8Tab(j)
			      ,  l_Att9Tab(j)
			      ,  l_Att10Tab(j)
			      ,  l_DRCCIDTab(j)
			      ,  l_CRCCIDTab(j)
			      ,  l_GlDateTab(j)
			      ,  l_DenomBdCostTab(j)
			      ,  l_SysLinkTab(j)
			      ,  X_status
			      ,  X_billable_flag
			      ,  l_RcptCurrAmtTab(j)
			      ,  l_RcptCurrCodeTab(j)
			      ,  l_RcptExchRateTab(j)
			      ,  l_DenomCurrCodeTab(j)
			      ,  l_AcctRateDateTab(j)
			      ,  l_AcctRateTypeTab(j)
			      ,  l_AcctExchRateTab(j)
			      ,  l_AcctRawCostTab(j)
			      ,  l_AcctBdCostTab(j)
			      ,  l_AcctExchRndLimitTab(j)
			      ,  l_ProjCurrCodeTab(j)
			      ,  l_prjRateDateTab(j)
			      ,  l_PrjRateTypeTab(j)
			      ,  l_PrjExchRateTab(j)
			      ,  l_rawCostTab(j)
			      ,  l_burdenedCostTab(j)
			      ,  l_OverrideOrgNameTab(j)
			      ,  l_VendorNumTab(j)
			      ,  l_OrgIdTab(j)
			      ,  l_PerBusGrpNameTab(j)
			      ,  l_ProjFuncCurrCodeTab(j)
			      ,  l_PrjFuncRateDateTab(j)
			      ,  l_PrjFuncRateTypeTab(j)
			      ,  l_PrjFuncExchRateTab(j)
			      ,  l_ProjRawCostTab(j)
			      ,  l_ProjBdCostTab(j)
			      ,  l_AsgnNameTab(j)
			      ,  l_WorkTypeNameTab(j)
			      ,  l_AccrualFlagTab(j)
			      ,  l_PrjIdTab(j)
			      ,  l_TaskIdTab(j)
			      ,  l_PersonIdTab(j)
			      ,  l_OrganizationIdTab(j)
			      ,  l_NLROrgIDTab(j)
			      ,  l_VendorIdTab(j)
			      ,  l_OverrideOrgIdTab(j)
			      ,  l_PersonBusGrpIdTab(j)
			      ,  l_AsgnIdTab(j)
			      ,  l_WorkTypeIdTab(j)
			      ,  l_EmpOrgIdTab(j)
			      ,  l_EmpJobIdTab(j)
			      /* Passed the value TrxRec.txn_interface_id for bug 2563364 */
			      ,  l_TxnIfIDTab(j)
			       ,  l_po_numberTab(j) /* cwk */
			       ,  l_po_header_idTab(j)
			       ,  l_po_line_numTab(j)
			       ,  l_po_line_idTab(j)
			       ,  l_person_typeTab(j)
			      ,  l_po_price_typeTab(j)
			      ,  l_AdjExpItemIdTab(j)
			      ,  l_FcDocTypeTab(j) );
                           --   ,  l_agreement_idTab(j) --FSIO Change
                          --    ,  l_agreement_numberTab(j) );
		       END IF ;

                    End If;
                  --  l_BdCostRateTab(j) := l_burdenedCostTab(j)/nvl(l_QtyTab(j),1); --For Bug 4057531

		   /* Changes for bug 6719252 start here */

	IF (l_SysLinkTab(j) = 'VI' OR l_SysLinkTab(j) = 'ER') THEN
		IF ( NVL(G_PrjInfoBdDisplay, 'S') = 'S') THEN
			IF (l_burdenedCostTab(j) = 0 or l_QtyTab(j)= 0) THEN --added condition to check for l_QtyTab(j)= 0 for the bug 7459889
				l_BdCostRateTab(j) := l_burdenedCostTab(j); -- which would be 0, in this case.
			ELSE
			 /*IF l_QtyTab(j) = 0 then --added For bug:7436883
	                 l_QtyTab(j) :=1;
                         END IF; Commented as part for bug 7591839*/
				l_BdCostRateTab(j) := l_burdenedCostTab(j)/nvl(l_QtyTab(j),1);
			END IF;
		END IF;
	 END IF;

	  /* Changes for bug 6719252 end here */

	            -- -----------------------------------------------------------------------
	            -- OGM_0.0 - Vertical application implementations may need to validate
	            -- transactions based on there business needs. So the following code hook
	            -- will call Vertical applications validations routines. It will look st
	            -- x_status and continue validations if x_status is NULL and vertical
	            -- application is implemented only.
	            -- ------------------------------------------------------------------------
                    IF PG_DEBUG = 'Y' THEN
	               pa_debug.G_err_stage := 'Calling PA_GMS_API api';
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;

                    IF l_gms_enabled = 'Y' and l_gms_fundscheck = 'Y'  THEN
                       PA_GMS_API.vert_app_validate(X_transaction_source,
               					    TrxBatch.batch_name,
						    l_TxnIfIDTab(j),
						    l_OrgIdTab(j),
						    X_status ) ;

                       if X_status is null then

                          GMS_PA_Costing_Pkg.FundsCheck_Supplier_Cost(p_transaction_source => x_transaction_source,
                                                                      p_txn_interface_id   => l_TxnIfIDTab(j),
				                                      p_request_id         => g_request_id,
                                                                      p_status             => X_status);

                       end if;

                    END IF; --> gms_enabled.

                    IF PG_DEBUG = 'Y' THEN
	               pa_debug.G_err_stage := 'After PA_GMS_API api';
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;

                    -- validateitem has lot of return statements, so instead
                    -- resetting the error stack for each return statement
                    -- we are resetting the stack after executing
                    -- validateitem.

                    --Bug 2749049
                    pa_cc_utils.reset_curr_function; /* Uncommented for Bug 4309932 */

	         END IF; -- end X_org_status is not null

                 IF ( X_status IS NOT NULL ) THEN

                    IF PG_DEBUG = 'Y' THEN
                    pa_debug.G_err_stage := 'Updating txn interface table for txn'||
                                     ' rejected by validateitem';
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;

                    /* PA-K
                       Performance Team Suggestion: To combine the below update (by txn_interface_id) with the
                       update in newexpend (by expenditure_id).
                       Results: For 20,000 records - gain of 30 sec.
                       Implementing this combined update has been phased out until there is a dire need to do it.
                       Placing this comment here for reference.
                    */
                    UPDATE pa_transaction_interface
                       SET
                            transaction_rejection_code = X_status
                    ,       interface_id = X_xface_id
                    ,       expenditure_id = G_expenditure_id
                    ,       transaction_status_code = 'R'
                     WHERE txn_interface_id = l_TxnIfIDTab(j);
                    --PA-K Changes: Removed 'current of' clause as the 'for update'
                    --              clause in Trxrecs has been removed.
                    --WHERE CURRENT OF TrxRecs;
                    IF PG_DEBUG = 'Y' THEN
                       log_message('log_message: ' || 'Updated to reject count ' || SQL%ROWCOUNT);
                    END IF;

                    REJECT_EXP := TRUE;

                    -- REL12 AP Lines Uptake
                    -- Cash based accounting support
                    -- l_rejectedSysRef5 and l_status was populated.
		    --
		    l_rejectedSysRef5   := NVL(l_SysRef5Tab(j), 0) ;
		    l_status            := X_status ;
		    l_txn_rejected_sr4tab(NVL(l_SysRef4Tab(j),0) )  := l_TxnIfIDTab(j) ;
		    l_txn_rejected_sr5tab(NVL(l_SysRef5Tab(j),0) )  := l_TxnIfIDTab(j) ;

                    IF PG_DEBUG = 'Y' THEN
                       log_message('log_message: l_txn_rejected_sr4tab(NVL(l_SysRef4Tab(j),0) ) :'||
		                    l_txn_rejected_sr4tab(NVL(l_SysRef4Tab(j),0) )) ;
                       log_message('log_message: l_txn_rejected_sr5tab(NVL(l_SysRef5Tab(j),0) ) :'||
		                    l_txn_rejected_sr5tab(NVL(l_SysRef5Tab(j),0) )) ;

                       log_message('log_message: NVL(l_SysRef5Tab(j), 0) :'|| NVL(l_SysRef5Tab(j), 0) ) ;
                       log_message('log_message: NVL(l_SysRef4Tab(j), 0) :'|| NVL(l_SysRef4Tab(j), 0) ) ;
		     END IF ;


                 ELSE

		    -- BUG:4748305  DFHC.D4:PRC INTERFACE SUPPLIER COST NOT INTERFACING
		    -- VALID INVOICE DISTRIBUTIONS
		    -- We allow good ap invoice distributions to interface in a expenditure
		    -- and do not reject all the expenditure items in expenditure
		    -- This is only done for VI items.
                     IF v_calling_module = 'PAAPIMP' and
            	        TrxBatch.system_linkage_function = 'VI' THEN

                        IF PG_DEBUG = 'Y' THEN
                           pa_debug.G_err_stage := 'Processing the valid distributions '||
                                     ' accepted by validateitem';
                           log_message('log_message: ' || pa_debug.G_err_stage);
                        END IF;


                        REJECT_EXP := FALSE;
                    END IF ;

                    IF PG_DEBUG = 'Y' THEN
                    pa_debug.G_err_stage := 'Updating txn interface table for txn'||
                                     ' accepted by validateitem';
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;

                    UPDATE pa_transaction_interface
                       SET
                            transaction_rejection_code = NULL
                    ,       interface_id = X_xface_id
                    ,       expenditure_id = G_expenditure_id
                    ,       expenditure_item_id = nvl(X_ei_id, 0) /* Bug 8709614  */
                            -- SST Changes: If TrxRec.reversed_orig_txn_reference
                            -- is NULL, this means we've called verifyorigitem API
                            -- to get the reversed item's orig_txn_reference and
                            -- store it in G_reversed_orig_txn_reference
                    ,       reversed_orig_txn_reference =
                            nvl(l_RevOrigTxnRefTab(j),G_reversed_orig_txn_reference)
                     WHERE txn_interface_id = l_TxnIfIDTab(j);

		     l_rejectedSysRef5   := 0 ;
		     l_status            := NULL ;

                    IF PG_DEBUG = 'Y' THEN
                       log_message('log_message: ' || 'Updated to accepted count ' || SQL%ROWCOUNT);
                       log_message('log_message: ' || 'l_AdjTxnInterfaceIdTab(j) ' ||
                       l_AdjTxnInterfaceIdTab(j));

                    END IF;

		    IF l_nzAdjFlagTab(j) = 'Y' and
		       l_AdjTxnInterfaceIdTab(j) is not NULL THEN
		       G_adj_item_id := l_AdjTxnEiIDTab(l_AdjTxnInterfaceIdTab(j) ) ;
		    END IF ;

                 END IF;

                 IF ( NOT REJECT_EXP ) THEN   ---{

                    i := i + 1;

                    IF (G_trx_costed = 'N' ) THEN

                      l_DenomRawCostTab(j) := NULL;
                      l_rawCostRateTab(j) := NULL;
                      l_AcctRawCostTab(j) := NULL;
                      l_rawCostTab(j) := NULL;

                    ELSIF ( G_trx_costed = 'Y' ) THEN

                      IF PG_DEBUG = 'Y' THEN
                      pa_debug.G_err_stage := 'rounding transaction raw cost';
                         log_message('log_message: ' || pa_debug.G_err_stage);
                      END IF;

                      l_DenomRawCostTab(j) := pa_currency.round_trans_currency_amt1(l_DenomRawCostTab(j),l_DenomCurrCodeTab(j));

	/* Added the call to round off denom_burdened_cost for bug 2871273 */

                      IF PG_DEBUG = 'Y' THEN
                      pa_debug.G_err_stage := 'rounding transaction burden cost';
                         log_message('log_message: ' || pa_debug.G_err_stage);
                      END IF;

                      l_DenomBdCostTab(j) := pa_currency.round_trans_currency_amt1(l_DenomBdCostTab(j),l_DenomCurrCodeTab(j));

                    END IF;

		    /* REL12-AP Lines uptake  START */
			    --
			    --BUG : 4696351 PJ.R12:DI4:APLINES: VENDOR INFORMATION NOT IMPORTED DURING TRANSACTION IMPORT
				--
			    IF v_calling_module <> 'PAAPIMP' THEN
			      IF l_SysLinkTab(j) in ( 'ER', 'VI' ) THEN
				     l_vendor_id      := g_vendor_id ;
					  l_SysRef1Tab(j) := g_vendor_id ;
				  END IF ;
				END IF ;

                    -- R12 Bug Fixes
		    -- 4919999
		    -- R12.PJ:XB1:DEV:APL:EIB RELATED CHANGES FOR R12 IN TRANSACTION IMPORT
		    --
                    IF X_transaction_source in ('CSE_PO_RECEIPT', 'CSE_PO_RECEIPT_DEPR'  ) THEN
		       l_vendor_id           := l_SysRef1Tab(j) ;
		       l_doc_header_id       := l_SysRef2Tab(j) ;
		       l_doc_distribution_id := l_SysRef4Tab(j) ; -- RCV Transaction ID
		       -- ===============
		       -- Populate po distribution id in l_Doc_line_number for receipt.
		       -- ===============
		       l_Doc_line_number     := l_SysRef3Tab(j) ;

		    ELSIF  X_transaction_source in ( 'CSE_IPV_ADJUSTMENT', 'CSE_IPV_ADJUSTMENT_DEPR' ) THEN
		       l_vendor_id           := l_SysRef1Tab(j) ;
		       l_doc_header_id       := l_SysRef2Tab(j) ;
		       l_doc_distribution_id := l_SysRef5Tab(j) ;
		       l_Doc_line_number     := l_SysRef3Tab(j) ;
		       l_SysRef5Tab(j)       := NULL ;
		    END IF ;
		    -- 4919999  R12.PJ:XB1:DEV:APL:EIB RELATED CHANGES FOR R12 IN TRANSACTION IMPORT
                    -- End of R12 Bug Fixes
		    --

                    -- 4927696  PAYABLES INTERFACE TO POPULATE SR_5 WITH PAYMENT_HIST_DIST_ID
		    -- Cost distribution lines , System_reference5 is populated with the payment_hist_dist_id
		    -- for discounts and payments.
		    -- For prepay application in cash based accounting, SR5 is populated with the pre-pay
		    -- appdist_id.
                    IF PG_DEBUG = 'Y' THEN
		       log_message('log_message: Cost distribution lines , System_reference5 is populated with the ') ;
		       log_message('log_message: payment_hist_dist_id for discounts and payments. ') ;
		       log_message('log_message: For prepay application in cash based accounting, SR5') ;
		       log_message('log_message: is populated with the pre-pay appdist_id.') ;

                       pa_debug.G_err_stage := 'l_VendorIdTab(j) : '|| l_VendorIdTab(j) ;
                       log_message('log_message: ' || pa_debug.G_err_stage);

                       pa_debug.G_err_stage := 'l_SysRef1Tab(j) : '|| l_SysRef1Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := 'l_SysRef2Tab(j) : '|| l_SysRef2Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := 'l_SysRef3Tab(j) : '|| l_SysRef3Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := 'l_SysRef4Tab(j) : '|| l_SysRef4Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := 'l_SysRef5Tab(j) : '|| l_SysRef5Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;

	            IF v_calling_module = 'PAAPIMP' THEN

                           -- 4927696  PAYABLES INTERFACE TO POPULATE SR_5 WITH PAYMENT_HIST_DIST_ID
			   l_vendor_id := NVL(l_VendorIdTab(j), l_SysRef1Tab(j))  ;

	                   IF X_transaction_source in ( 'AP EXPENSE', 'AP INVOICE', 'AP NRTAX' ,  'AP ERV',
		                                         'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES',
				              	         'AP VARIANCE' ) THEN
		              l_doc_header_id       := l_SysRef2Tab(j) ;
			      l_doc_distribution_id := l_SysRef5Tab(j) ;
			      l_Doc_line_number     := l_SysRef3Tab(j) ;

			      -- CDL place holder for subledger id for transaction source of RECEIPTS and
			      -- Manufacturing related records.
			      l_SysRef5Tab(j)       := NULL ;
			      IF g_cash_based_accounting = 'Y' Then

				-- For historical transactions  l_SysRef4Tab(j) is populated with the
				-- 'NONREC_TAX'. Invoice distributions gets interfaced instead of
				-- Payments.
				-- BUG : 5370864
				-- R12.PJ:XB6:QA:APL:UPG:INTERFACE SUPP COSTS ERRORS TAX NOT INTERFACED AFTER UPG
				--
			        IF l_DocumentDistTypeTab(j) <> NVL(l_SysRef4Tab(j), l_DocumentDistTypeTab(j))  THEN
 			           l_doc_payment_id    := l_SysRef4Tab(j) ; -- Populated when Cash based accounting is setup.
				ELSE
				   -- This is a historical transactions and payment is not interfaced. Invoice dist
				   -- is getting interfaced instead.
				   -- Bug : 5443263
				   --       R12.PJ:XB7:QA:APL:UPG:ADJUSTMENT REVERSAL NOT GETTING ACCOUNTED IN CASH
				   -- Resolution :
				   --       We need to mark such expenditure items corresponding to invoice distributions
				   --       as historical. The '-1' value in the l_doc_payment_id would indicate in
				   --       PA_transactions package that this is a cash based accounting when invoice distributions
				   --       is getting interfaced instead of payment. The value would be flipped back to null
				   --       in the pa transactions InsItems api before creating the exp items.
				   l_doc_payment_id := -1 ;
				END IF ;

				-- l_SysRef1Tab records the payment hist dist ID when needed to go to system_reference5
				-- of CDLs.
                                -- 4927696  PAYABLES INTERFACE TO POPULATE SR_5 WITH PAYMENT_HIST_DIST_ID
                                l_SysRef5Tab(j)     := l_SysRef1Tab(j) ;
				l_SysRef1Tab(j)     := l_VendorIdTab(j) ;

				IF l_DocumentDistTypeTab(j) = 'PREPAY' and
				   l_doc_payment_id is not NULL and
				   l_doc_payment_id <> -1 THEN
				   --
				   -- Document_payment_id is the prepay app dist id
				   --
                                   -- 4927696  PAYABLES INTERFACE TO POPULATE SR_5 WITH PAYMENT_HIST_DIST_ID
				   l_SysRef5Tab(j)     := l_doc_payment_id ;
                                END IF ;
			      END IF;


		           ELSIF X_transaction_source in (  'AP DISCOUNTS' ) THEN
		              l_doc_header_id       := l_SysRef2Tab(j) ;
			      l_doc_distribution_id := l_SysRef5Tab(j) ;
			      l_Doc_line_number     := l_SysRef3Tab(j) ;
			      l_doc_payment_id      := l_SysRef4Tab(j) ;

			      -- CDL place holder for subledger id for transaction source of RECEIPTS and
			      -- Manufacturing related records.

			      -- l_SysRef1Tab records the payment hist dist ID when needed to go to system_reference5
			      -- of CDLs.
                              -- 4927696  PAYABLES INTERFACE TO POPULATE SR_5 WITH PAYMENT_HIST_DIST_ID

	                /* Bug 8674676. If its cancelled payment then system_reference 5 should be parent payment_hist_dist_id.
 	                   Added additional debug messages also */
 	                        pa_debug.G_err_stage := '1. After l_SysRef5Tab(j) : '|| l_SysRef5Tab(j)  ;
 	                        log_message('log_message: ' || pa_debug.G_err_stage);

 	                         select decode(reversal_flag, 'Y', reversed_pay_hist_dist_id,l_SysRef1Tab(j))
 	                         into l_SysRef5Tab(j)
 	                         from ap_payment_hist_dists
 	                         where payment_hist_dist_id = l_SysRef1Tab(j);

 	                        pa_debug.G_err_stage := '2. After l_SysRef5Tab(j) : '|| l_SysRef5Tab(j)  ;
 	                        log_message('log_message: ' || pa_debug.G_err_stage);

 	                               --l_SysRef5Tab(j)     := l_SysRef1Tab(j) ;
 	                               --Commented for bug 8674676 and added above decode logic.

			      l_SysRef1Tab(j)     := l_VendorIdTab(j) ;

		           ELSIF X_transaction_source in ( 'PO RECEIPT', 'PO RECEIPT NRTAX',
		                                           'PO RECEIPT PRICE ADJ', 'PO RECEIPT NRTAX PRICE ADJ' )  THEN
		              l_doc_header_id       := l_SysRef2Tab(j) ;
			      l_doc_distribution_id := l_SysRef4Tab(j) ; -- RCV Transaction ID
			      -- ===============
			      -- Populate po distribution id in l_Doc_line_number for receipt.
			      -- ===============
			      l_Doc_line_number     := l_SysRef3Tab(j) ;
			      l_doc_payment_id      := NULL ;
                           ELSE
		              l_doc_header_id       := NULL ;
			      l_doc_distribution_id := NULL ;
			      l_Doc_line_number     := NULL ;
			      l_doc_payment_id      := NULL ;
		           END IF ;
	            END IF ;

                    IF PG_DEBUG = 'Y' THEN

                       pa_debug.G_err_stage := ' After l_VendorIdTab(j) : '|| l_VendorIdTab(j) ;
                       log_message('log_message: ' || pa_debug.G_err_stage);

                       pa_debug.G_err_stage := ' After l_SysRef1Tab(j) : '|| l_SysRef1Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := ' After l_SysRef2Tab(j) : '|| l_SysRef2Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := ' After l_SysRef3Tab(j) : '|| l_SysRef3Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := 'After l_SysRef4Tab(j) : '|| l_SysRef4Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                       pa_debug.G_err_stage := 'After l_SysRef5Tab(j) : '|| l_SysRef5Tab(j)  ;
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;

		    /* REL12-AP Lines uptake  END  */

	            IF ( nvl(G_gl_accted_flag,'N') = 'N' ) THEN
          	       -- If the transaction is not accounted, the costing
     	               -- program will calculate the functional and project
	               -- costs, so Null out the functional and project costs
          	       -- for un accounted txns. Null out the exchange rates if
          	       -- the exchange rate type is not user.

	               l_AcctRawCostTab(j) := NULL;
		       l_AcctBdCostTab(j) := NULL;
          	       l_rawCostTab(j) := NULL;
	               l_burdenedCostTab(j) := NULL;

               /*S.N. Bug 5170366 */
               IF (nvl(G_proj_bcost_flag, 'N') = 'N' AND l_DenomBdCostTab(j) = l_DenomRawCostTab(j) ) THEN
                   l_DenomBdCostTab(j) := Null;
                    l_BdCostRateTab(j)  := Null; /*Bug#5874347*/
               End IF;
               /*E.N. Bug 5170366 */

		       IF ( nvl(G_acct_rate_type,'DUMMY') <> 'User' ) THEN
			  l_AcctExchRateTab(j) := NULL;
		       END IF; -- end G_acct_rate_type <> User

		       IF ( nvl(G_project_rate_type,'DUMMY') <> 'User') THEN
		          l_PrjExchRateTab(j) := NULL;
		       END IF; -- end G_project_rate_type <> User

	/* Added the ELSE section to round off the acct raw and burden costs for gl costed transactions for bug 2871273 */

                    ELSE

                       l_AcctRawCostTab(j) :=  pa_currency.round_trans_currency_amt1(l_AcctRawCostTab(j),G_accounting_currency_code);
                       l_AcctBdCostTab(j)  :=  pa_currency.round_trans_currency_amt1(l_AcctBdCostTab(j),G_accounting_currency_code);

	            END IF; -- end G_gl_accted_flag = N

                    IF (l_DenomCurrCodeTab(j) = G_accounting_currency_code) THEN

	               l_AcctRateDateTab(j) := NULL;
		       l_AcctRateTypeTab(j) := NULL;
		       l_AcctExchRateTab(j) := NULL;

	            END IF; -- end denom currency = acct currency

	            IF ( l_DenomCurrCodeTab(j) = l_ProjCurrCodeTab(j)) THEN

	  	       l_prjRateDateTab(j) := NULL;
		       l_PrjRateTypeTab(j) := NULL;
		       l_PrjExchRateTab(j) := NULL;

	            END IF; -- End denom currency=project currency

                    -- SSt changes
                    -- For contract and capital projects, if the billable flag
                    -- is populated in the interface table, then override the
                    -- billable flag derived from pa_transactions_pub.validate_transaction
                    -- with the value in the billable flag column

                    IF PG_DEBUG = 'Y' THEN
                       log_message('log_message: ' || 'Intial Billable Flag = ' || X_billable_flag);
                    END IF;

                    --  Bug 8835571: Including project_type 'INDIRECT' also, as billability for Indirect Projects does not hold any meaning.
                    --  But in Grants, the underlying award_project is always a contract project and hence all the
                    -- trxns against the award/ project get picked up even if the project is INDIRECT project.
                    IF ( G_project_type_class IN ('CONTRACT','CAPITAL', 'INDIRECT') AND
                    --IF ( G_project_type_class IN ('CONTRACT','CAPITAL') AND
               	     l_billableFlagTab(j) IN ( 'Y','N')) THEN

                       IF PG_DEBUG = 'Y' THEN
                       pa_debug.G_err_stage := 'Project_type_class in Contract, Capital';
                          log_message('log_message: ' || pa_debug.G_err_stage);
                       END IF;

                       X_billable_flag := l_billableFlagTab(j);

                       --PA-I Changes
                       --If  profile - PA: Require Work Type Entry for Expenditures
                       --and profile - PA: Transaction Billability Derived from Work Type
                       --is set to Y then we have to derive billability from work_type
                       --else use what user has entered in TrxRec.billable_flag
                       --Here we are calling the API get_trxn_work_billabilty to override
                       --the billable flag.
                       --For now we can call the API but latter if performance is a
                       --bottleneck then we can replace this API call by just checking the
                       --two profiles and if it is Y then use the billable_flag from
                       --validate_transaction and if N then override with what user entered.

                       IF PG_DEBUG = 'Y' THEN
                       pa_debug.G_err_stage := 'Calling pa_utils4.get_transaction_billability';
                          log_message('log_message: ' || pa_debug.G_err_stage);
                          log_message('log_message: ' || 'Billable Flag before get_trxn_work_billabilty = ' || X_billable_flag);
                          log_message('log_message: ' || 'Work Type Id = ' || G_work_type_id);
                       END IF;

                       X_billable_flag :=  pa_utils4.get_trxn_work_billabilty(
                                           p_work_type_id      => G_work_type_id,
                                           p_tc_extn_bill_flag => X_billable_flag);

                       IF PG_DEBUG = 'Y' THEN
                          log_message('log_message: ' || 'Billable Flag after get_trxn_work_billabilty = ' || X_billable_flag);
                       END IF;

                    END IF;

                    IF PG_DEBUG = 'Y' THEN
                       log_message('log_message: ' || 'Final Billable Flag = ' || X_billable_flag);
                    END IF;

                    --PA-K Changes:
                    --TrxRec.expenditure_item_id := X_ei_id;

                    --Added for bug 2048868
                    prev_acct_rate_type     := G_acct_rate_type;
                    prev_acct_rate_date     := l_AcctRateDateTab(j);
                    prev_acct_exchange_rate := l_AcctExchRateTab(j);
                    prev_denom_currency_code := l_DenomCurrCodeTab(j);
                    prev_person_type := l_person_typeTab(j);

                    /* Added for 4057874 */
                    IF (l_SysLinkTab(j) = 'BTC'
                    AND G_trx_predef_flag = 'Y'
                    AND X_transaction_source <> 'ALLOCATIONS'
                    AND P_BTC_SRC_RESRC = 'Y' ) THEN

                         l_src_system_linkage_function := G_trx_link;

                         IF PG_DEBUG = 'Y' THEN
                          log_message('log_message: ' || 'Src system linkage function = '||l_src_system_linkage_function);
                         END IF;

                    ELSE

                         l_src_system_linkage_function := null;

                    END IF;

					/* Bug 4107560 : Overriding the wip_resource_id for the BTC transactions to be interfaced from transaction source
					   with wip_resource_id of parent source transaction */

					IF l_SysLinkTab(j) = 'BTC' AND l_wip_resource_idTab(j) IS NOT NULL Then

						If G_prev_ORIG_TRAN_REF Is Null or G_prev_ORIG_TRAN_REF <> l_OrigTxnRefTab(j) Then

							G_prev_ORIG_TRAN_REF := l_OrigTxnRefTab(j);

							Begin
								Select WIP_RESOURCE_ID
								  INTO G_WIP_RESOURCE_ID
								  FROM PA_TRANSACTION_INTERFACE_ALL
								 WHERE ORIG_TRANSACTION_REFERENCE =  l_OrigTxnRefTab(j)
								   and SYSTEM_LINKAGE  <> 'BTC'
								   and rownum = 1;
							Exception
								When No_data_found Then
									Select resource_id
									  into G_WIP_RESOURCE_ID
									  from wip_transactions
									 where transaction_id = l_OrigTxnRefTab(j);
							End;

							l_wip_resource_idTab(j) := G_WIP_RESOURCE_ID;
						Else
							l_wip_resource_idTab(j) := G_WIP_RESOURCE_ID;
						End if;

						IF PG_DEBUG = 'Y' THEN
                          log_message('log_message: ' || 'BTC WIP Resource ID = ' || G_WIP_RESOURCE_ID );
                        END IF;

					END IF;

					/* End of bug 4107560 */


                    IF PG_DEBUG = 'Y' THEN
                    pa_debug.G_err_stage := 'Calling Loadei';
                       log_message('log_message: ' || pa_debug.G_err_stage);
                    END IF;

                    -- REL12 AP Lines uptake..
		    l_temp_adjItemID := G_adj_item_id ;

		    --
		    -- The following code is added to calculate billable flag for the
		    -- ap reversal distributions which is interfaced as net zero
		    -- expenditure items
		    --
		    IF l_nzAdjFlagTab(j) = 'Y' Then
		       l_temp_adjItemID := NULL ;
		    END IF ;
		    -- This is to avoid calling the LoadEI/newExpend etc for Quantity Variance as
 	            -- we are only interested in Funds checking the variance txn but not in interfacing to PA
 	            -- Already the txn is funds checked, so reduce the count. Bug# 8709614
 	            IF (X_ei_id is NULL AND X_transaction_source = 'AP VARIANCE') THEN
 	            i := i-1;
 	            END IF;
		    IF X_ei_id is NOT NULL THEN
		            -- Bug 4604493, 4503768  begins
				    IF (l_SysLinkTab(j) <> 'USG')  THEN
                        G_nlro_id := Null;
                    END IF;/*Bug 4503768*/
		            -- Bug 4604493, 4503768  ends

                    pa_transactions.LoadEi( X_expenditure_item_id     =>	X_ei_id
                        --PA-K Changes: TrxRec.expenditure_item_id
                       ,X_expenditure_id          =>	G_expenditure_id
                       ,X_expenditure_item_date   =>	l_EiDateTab(j)
                       ,X_project_id              =>	G_project_id
                       ,X_task_id                 =>	G_task_id
                       ,X_expenditure_type        =>	l_ETypeTab(j)
                       ,X_non_labor_resource      =>	l_NlrTab(j)
                       ,X_nl_resource_org_id      =>	G_nlro_id
                       ,X_quantity                =>	l_QtyTab(j)
                       ,X_raw_cost                =>	l_rawCostTab(j)
                       ,X_raw_cost_rate           =>	l_rawCostRateTab(j)
                       -- Trx_import enhancement
                       ,X_override_to_org_id      =>	G_override_to_org_id -- Changed from NULL
                       /* Added for bug 3220230 for getting billability of items reversed in OIT    */
		               ,X_billable_flag           =>	pa_utils4.GetOrig_EiBillability_SST(l_temp_adjItemID,X_billable_flag,X_transaction_source)
                       /* Added for bug 4057474 for getting bill_hold_flag of items reversed in external txn sources like OTL. */
                       ,X_bill_hold_flag          =>	pa_utils4.GetOrig_EiBill_hold(l_temp_adjItemID,'N')
                       ,X_orig_transaction_ref    =>	l_OrigTxnRefTab(j)
                       ,X_transferred_from_ei     =>	NULL
                       ,X_adj_expend_item_id      =>	G_adj_item_id
                       ,X_attribute_category      =>	l_AttCatTab(j)
                       ,X_attribute1              =>	l_Att1Tab(j)
                       ,X_attribute2              =>	l_Att2Tab(j)
                       ,X_attribute3              =>	l_Att3Tab(j)
                       ,X_attribute4              =>	l_Att4Tab(j)
                       ,X_attribute5              =>	l_Att5Tab(j)
                       ,X_attribute6              =>	l_Att6Tab(j)
                       ,X_attribute7              =>	l_Att7Tab(j)
                       ,X_attribute8              =>	l_Att8Tab(j)
                       ,X_attribute9              =>	l_Att9Tab(j)
                       ,X_attribute10             =>	l_Att10Tab(j)
                       ,X_ei_comment              =>	l_ExpCommentTab(j)
                       ,X_transaction_source      =>	X_transaction_source
                       ,X_source_exp_item_id      =>	NULL
                       ,i                         =>	i
                       ,X_job_id                  =>	G_job_id
                       ,X_org_id                  =>	l_OrgIdTab(j)
                       ,X_labor_cost_multiplier_name =>  G_lcm
                       ,X_drccid                  =>	l_DRCCIDTab(j)
                       ,X_crccid                  =>	l_CRCCIDTab(j)
                       ,X_cdlsr1                  =>	l_SysRef1Tab(j)
                       ,X_cdlsr2                  =>	l_SysRef2Tab(j)
                       ,X_cdlsr3                  =>	l_SysRef3Tab(j)
                       ,X_gldate                  =>	l_GlDateTab(j)
                       ,X_bcost                   =>	l_burdenedCostTab(j)
                       ,X_bcostrate               =>	l_BdCostRateTab(j)
                       ,X_etypeclass              =>	l_SysLinkTab(j)
                       ,X_burden_sum_dest_run_id  =>	''
                       ,X_burden_compile_set_id   =>	G_burden_compile_set_id
                       ,X_receipt_currency_amount =>	l_RcptCurrAmtTab(j)
                       ,X_receipt_currency_code   =>	l_RcptCurrCodeTab(j)
                       ,X_receipt_exchange_rate   =>	l_RcptExchRateTab(j)
                       ,X_denom_currency_code     =>	l_DenomCurrCodeTab(j)
                       ,X_denom_raw_cost          =>	l_DenomRawCostTab(j)
                       ,X_denom_burdened_cost     =>	l_DenomBdCostTab(j)
                       ,X_acct_currency_code      =>	G_accounting_currency_code
                       ,X_acct_rate_date          =>	l_AcctRateDateTab(j)
                       ,X_acct_rate_type          =>     G_acct_rate_type
                       ,X_acct_exchange_rate      =>	l_AcctExchRateTab(j)
                       ,X_acct_raw_cost           =>	l_AcctRawCostTab(j)
                       ,X_acct_burdened_cost      =>	l_AcctBdCostTab(j)
                       ,X_acct_exchange_rounding_limit =>	l_AcctExchRndLimitTab(j)
                       ,X_project_currency_code   =>	l_ProjCurrCodeTab(j)
                       ,X_project_rate_date       =>	l_prjRateDateTab(j)
                       ,X_project_rate_type       =>	G_project_rate_type
                       ,X_project_exchange_rate   =>	l_PrjExchRateTab(j)
                       ,X_Cross_Charge_Type       => G_CrossChargeType
                       ,X_Cross_Charge_Code       => G_CrossChargeCode
                       ,X_Prvdr_organization_id   => G_PrvdrOrganizationId
                       ,X_Recv_organization_id    => G_RecvrOrganizationId
                       ,X_Recv_Operating_Unit     => G_RecvrOrgId
                       ,X_Borrow_Lent_Dist_Code   => G_BrowLentDistCode
                       ,X_Ic_Processed_Code       => G_IcProcessed_Code
                       ,P_PaDate                  => G_PaDate
                       ,P_PaPeriodName            => G_PaPeriodName
                       ,P_RecvrPaDate             => G_RecvrPaDate
                       ,P_RecvrPaPeriodName       => G_RecvrPaPeriodName
                       ,P_GlPeriodName            => G_GlPeriodName
                       ,P_RecvrGlDate             => G_RecvrGlDate
                       ,P_RecvrGlPeriodName       => G_RecvrGlPeriodName
                       -- PA-I Changes
                       ,p_assignment_id               => G_Assignment_Id
                       ,p_work_type_id                => G_Work_Type_Id
                       ,p_projfunc_currency_code      => l_ProjFuncCurrCodeTab(j)
                       ,p_projfunc_cost_rate_date     => l_PrjFuncRateDateTab(j)
                       ,p_projfunc_cost_rate_type     => G_projfunc_cost_rate_type
                       ,p_projfunc_cost_exchange_rate => l_PrjFuncExchRateTab(j)
                       ,p_project_raw_cost            => l_ProjRawCostTab(j)
                       ,p_project_burdened_cost       => l_ProjBdCostTab(j)
                       ,p_tp_amt_type_code            => G_Tp_Amt_Type_Code
                       -- AP Discounts
                       ,p_cdlsr4                      => l_Sysref4Tab(j)
                       ,p_accrual_Date                => G_AccDate
                       ,p_recvr_accrual_date          => G_RecvrAccDate
		               ,p_po_line_id                  =>          l_po_line_idTab(j) /* cwk */
		               ,p_po_price_type            =>          l_po_price_typeTab(j)
		               ,p_wip_resource_id          =>          l_wip_resource_idTab(j)
		               ,p_inventory_item_id        =>          l_inventory_item_idTab(j)
		               ,p_unit_of_measure          =>         l_unit_of_measureTab(j)
 	                   ,p_src_system_linkage_function  =>l_src_system_linkage_function /* 4057874 */
		               ,p_document_header_id       =>    l_doc_header_id
		               ,p_document_distribution_id =>    l_doc_distribution_ID
		               ,p_document_line_number     =>    l_doc_line_number
		               ,p_document_payment_ID      =>    l_doc_payment_ID
		               ,p_vendor_id                =>    l_vendor_id
		               ,p_document_type            =>    l_DocumentTypeTab(j)
		               ,p_document_distribution_type=>   l_DocumentDistTypeTab(j)
                       ,p_si_assets_addition_flag   =>   l_siaAddFlagTab(j)
		               ,p_sc_xfer_code              =>   l_scxfercdTab(j)
                       ,p_cdlsr5                    =>   l_Sysref5Tab(j)
                       --,p_agreement_id              =>   l_agreement_idTab(j)    --FSIO Changes
                        );
		    END IF ;

                    -- PA-J Period-End Accrual Changes
                    -- Call LoadEI for creating the reversing item.
                    if (l_AccrualFlagTab(j) = 'Y' and l_SysLinkTab(j) = 'PJ' and X_ei_id is not NULL ) then

                       IF PG_DEBUG = 'Y' THEN
                       pa_debug.G_err_stage := 'Calling Loadei for the reversing line of a Period-End Accrual transaction';
                          log_message('log_message: ' || pa_debug.G_err_stage);
                       END IF;

                       -- increment the counter
                       i := i + 1;

                       pa_transactions.LoadEi(
                          X_expenditure_item_id     =>	pa_utils.GetNextEiId
                         ,X_expenditure_id          =>	G_expenditure_id
                         ,X_expenditure_item_date   =>	l_EiDateTab(j)
                         ,X_project_id              =>	G_project_id
                         ,X_task_id                 =>	G_task_id
                         ,X_expenditure_type        =>	l_ETypeTab(j)
                         ,X_non_labor_resource      =>	l_NlrTab(j)
                         ,X_nl_resource_org_id      =>	G_nlro_id
                         ,X_quantity                =>	(0 - l_QtyTab(j))
                         ,X_raw_cost                =>	(0 - l_rawCostTab(j))
                         ,X_raw_cost_rate           =>	l_rawCostRateTab(j)
                         ,X_override_to_org_id      =>	G_override_to_org_id
                         ,X_billable_flag           =>	X_billable_flag
                         ,X_bill_hold_flag          =>	'N'
                         ,X_orig_transaction_ref    =>	l_OrigTxnRefTab(j)
                         ,X_transferred_from_ei     =>	NULL
                         ,X_adj_expend_item_id      =>	X_ei_id --PA-K Changes: TrxRec.expenditure_item_id
                         ,X_attribute_category      =>	l_AttCatTab(j)
                         ,X_attribute1              =>	l_Att1Tab(j)
                         ,X_attribute2              =>	l_Att2Tab(j)
                         ,X_attribute3              =>	l_Att3Tab(j)
                         ,X_attribute4              =>	l_Att4Tab(j)
                         ,X_attribute5              =>	l_Att5Tab(j)
                         ,X_attribute6              =>	l_Att6Tab(j)
                         ,X_attribute7              =>	l_Att7Tab(j)
                         ,X_attribute8              =>	l_Att8Tab(j)
                         ,X_attribute9              =>	l_Att9Tab(j)
                         ,X_attribute10             =>	l_Att10Tab(j)
                         ,X_ei_comment              =>	l_ExpCommentTab(j)
                         ,X_transaction_source      =>	X_transaction_source
                         ,X_source_exp_item_id      =>	NULL
                         ,i                         =>	i
                         ,X_job_id                  =>	G_job_id
                         ,X_org_id                  =>	l_OrgIdTab(j)
                         ,X_labor_cost_multiplier_name =>  G_lcm
                         ,X_drccid                  =>	l_DRCCIDTab(j)
                         ,X_crccid                  =>	l_CRCCIDTab(j)
                         ,X_cdlsr1                  =>	l_SysRef1Tab(j)
                         ,X_cdlsr2                  =>	l_SysRef2Tab(j)
                         ,X_cdlsr3                  =>	l_SysRef3Tab(j)
                         ,X_gldate                  =>	G_RevGlDate
                         ,X_bcost                   =>	(0 - l_burdenedCostTab(j))
                         ,X_bcostrate               =>	l_BdCostRateTab(j)
                         ,X_etypeclass              =>	l_SysLinkTab(j)
                         ,X_burden_sum_dest_run_id  =>	''
                         ,X_burden_compile_set_id   =>	G_burden_compile_set_id
                         ,X_receipt_currency_amount =>	(0 - l_RcptCurrAmtTab(j))
                         ,X_receipt_currency_code   =>	l_RcptCurrCodeTab(j)
                         ,X_receipt_exchange_rate   =>	l_RcptExchRateTab(j)
                         ,X_denom_currency_code     =>	l_DenomCurrCodeTab(j)
                         ,X_denom_raw_cost          =>	(0 - l_DenomRawCostTab(j))      --2436444
                         ,X_denom_burdened_cost     =>	(0 - l_DenomBdCostTab(j))
                         ,X_acct_currency_code      =>	G_accounting_currency_code
                         ,X_acct_rate_date          =>	l_AcctRateDateTab(j)
                         ,X_acct_rate_type          => G_acct_rate_type
                         ,X_acct_exchange_rate      =>	l_AcctExchRateTab(j)
                         ,X_acct_raw_cost           =>	(0 - l_AcctRawCostTab(j))
                         ,X_acct_burdened_cost      =>	(0 - l_AcctBdCostTab(j))
                         ,X_acct_exchange_rounding_limit =>	l_AcctExchRndLimitTab(j)
                         ,X_project_currency_code   =>	l_ProjCurrCodeTab(j)
                         ,X_project_rate_date       =>	l_prjRateDateTab(j)
                         ,X_project_rate_type       =>	G_project_rate_type
                         ,X_project_exchange_rate   =>	l_PrjExchRateTab(j)
                         ,X_Cross_Charge_Type       => G_CrossChargeType
                         ,X_Cross_Charge_Code       => G_CrossChargeCode
                         ,X_Prvdr_organization_id   => G_PrvdrOrganizationId
                         ,X_Recv_organization_id    => G_RecvrOrganizationId
                         ,X_Recv_Operating_Unit     => G_RecvrOrgId
                         ,X_Borrow_Lent_Dist_Code   => G_BrowLentDistCode
                         ,X_Ic_Processed_Code       => G_IcProcessed_Code
                         ,P_PaDate                  => G_RevPaDate
                         ,P_PaPeriodName            => G_RevPaPeriodName
                         ,P_RecvrPaDate             => G_RevRecvrPaDate
                         ,P_RecvrPaPeriodName       => G_RevRecvrPaPdName
                         ,P_GlPeriodName            => G_RevGlPeriodName
                         ,P_RecvrGlDate             => G_RevRecvrGlDate
                         ,P_RecvrGlPeriodName       => G_RevRecvrGlPdName
                         ,p_assignment_id               => G_Assignment_Id
                         ,p_work_type_id                => G_Work_Type_Id
                         ,p_projfunc_currency_code      => l_ProjFuncCurrCodeTab(j)
                         ,p_projfunc_cost_rate_date     => l_PrjFuncRateDateTab(j)
                         ,p_projfunc_cost_rate_type     => G_projfunc_cost_rate_type
                         ,p_projfunc_cost_exchange_rate => l_PrjFuncExchRateTab(j)
                         ,p_project_raw_cost            => (0 - l_ProjRawCostTab(j))
                         ,p_project_burdened_cost       => (0 - l_ProjBdCostTab(j))
                         ,p_tp_amt_type_code            => G_Tp_Amt_Type_Code
                         ,p_cdlsr4                      => l_Sysref4Tab(j)
                         ,p_accrual_Date                => G_RevAccDate
                         ,p_recvr_accrual_date          => G_RevRecvrAccDate
                       ,p_po_line_id                  =>          l_po_line_idTab(j) /* cwk */
		       ,p_po_price_type            =>          l_po_price_typeTab(j)
		       ,p_wip_resource_id          =>          l_wip_resource_idTab(j)
		       ,p_inventory_item_id        =>          l_inventory_item_idTab(j)
		       ,p_unit_of_measure          =>         l_unit_of_measureTab(j)
               ,p_si_assets_addition_flag  =>         l_siaAddFlagTab(j)
                      -- ,p_agreement_id             => l_agreement_idTab(j)    --FSIO Changes
                          );
                    end if;

                 END IF;  ---}

                 --EXIT WHEN TrxRecs%NOTFOUND;
                 --END LOOP expenditures ;
             END LOOP;   ---}


			/***** Bug 4091706 CWK Changes *****/
			--- release_po_line_task_lock; Commented out for bug 4106188
			--- init_po_amt_chk; Commented out for bug 4106188
			/***** Bug 4091706 CWK Changes *****/


             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling newExpend after TrxRecs loop';
                log_message('log_message: ' || pa_debug.G_err_stage);
             END IF;
             newExpend( TrxBatch.exp_group_name
                     , current_period
                     , i
                     , prev_denom_currency_code
                     , G_accounting_currency_code
                     , prev_acct_rate_type
                     , prev_acct_rate_date
                     , prev_acct_exchange_rate
                     , prev_person_type /*cwk */
    		     , TrxBatch.batch_name ); -- Bug 3613784 : Performance fix

             /** Bug#3026218 Close the tow cursors that are opened. Removed conditions on
	     *** pre-defined flag
	     **/
             If (TrxBatch.system_linkage_function = 'ST') Then
                    CLOSE TrxRecs1;
             Else
                    CLOSE TrxRecs2;
             End If;


          ELSE

             IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Processed the commit size records, exit batches';
                log_message('log_message: ' || pa_debug.G_err_stage);
             END IF;

             Exit batches;

          END IF;  ---}

        ELSE

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Not able to lock TrxBatch record';
             log_message('log_message: ' || pa_debug.G_err_stage);
          END IF;

          --Bug 3239369
          G_Exit_Main := TRUE;

          Exit batches;

        /***** CWK Changes *****/

	--- Bug 4091706 release_po_line_task_lock;
	--- BUg 4091706 init_po_amt_chk;

	/***** CWK Changes *****/

        END IF;  ---}


        --PA-K Changes: UpdControlProcessed will be done for each loop of TrxBatches
        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling UpdControlProcessed';
           log_message('log_message: ' || pa_debug.G_err_stage);
        END IF;

        UpdControlProcessed( P_TrxSource      => TrxBatch.transaction_source,
                             P_BatchName      => TrxBatch.batch_name,
                             P_XfaceId        => X_xface_id,
                             P_TxnCount       => TrxBatch.transaction_count,
                             P_ProcCount      => TrxBatch.processed_count,
                             P_BatchProcCount => l_ActualBatchRecCnt,
                             p_system_linkage_function     => trxbatch.system_linkage_function);
/* added the parameter system linkage function in the function call above for BUG # 3291066 */

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'l_CommitSizeRecCount = ' || l_CommitSizeRecCount || ' l_Batch_Size = ' || l_Batch_Size);
        END IF;

        If l_CommitSizeRecCount = l_Batch_Size Then
           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'l_CommitSizeRecCount equal to l_Batch_Size, exit batches');
           END IF;
           Exit batches;
        End If;


--Vijay
      END LOOP;   ---}

      Close TrxBatches;

      --PA-J Receipt Accrual Changes: Added AP VARIANCE and PO RECEIPT
      --PA-K Changes: Using the process_funds_check attributes of the source to perform funds checking
      --X_transaction_source in ('AP INVOICE', 'AP VARIANCE', 'PO RECEIPT', 'AP NRTAX', 'PO RECEIPT NRTAX') THEN
      IF G_gl_accted_flag = 'Y' AND
         G_Process_Funds_Flag = 'Y'  THEN

         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Calling tieback funds check records';
            log_message('log_message: ' || pa_debug.G_err_stage);
         END IF;

         IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Tieback Mode = '||X_transaction_source;
            log_message('log_message: ' || pa_debug.G_err_stage);
         END IF;

         tieback_fc_records (x_return_status => l_return_status,
                         p_calling_mode  => X_transaction_source) ;

      END IF;

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then

           raise_application_error(-20001,'Error during Balance Update');
           return ;

      end if;

      if l_gms_enabled = 'Y' then
         gms_pa_costing_pkg.Tieback_Interface(p_request_id => g_request_id,
                                              p_status     => l_return_status);

         if l_return_status <> FND_API.G_RET_STS_SUCCESS then
           raise_application_error(-20002,'Error during Grants Tieback process');
           return ;
         end if;
         --
         -- BUG : 5389130
	 --       R12.PJ:XB7:DEV:BC: TO TRACK GRANTS INTERFACE ISSUES
	 --
         gms_pa_costing_pkg.Net_zero_adls( X_transaction_source,
                                           X_batch ,
                                           X_xface_id,
                                           l_return_status) ;

         if l_return_status <> FND_API.G_RET_STS_SUCCESS then
           raise_application_error(-20002,'Error during Grants Tieback process net_zero_adjustment_flag Zero adls');
           return ;
         end if;

      end if;

      /*PA-K Changes: UpdControlProcessed will be done for each loop of TrxBatches*/

      pa_cc_utils.reset_curr_function;

  EXCEPTION

    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'In OTHERS exception of import1';
          log_message('log_message: ' || pa_debug.G_err_stage,1);
       END IF;

       release_po_line_task_lock;  -- bug 3512984

       --Call FC packets update API to update packets to T.
       Upd_PktSts_Fatal(p_request_id => G_REQUEST_ID);

       raise;

  END import1;

  PROCEDURE import( X_transaction_source  IN VARCHAR2
                  , X_batch               IN VARCHAR2
                  , X_xface_id            IN NUMBER
                  , X_userid              IN NUMBER
                  , X_online_exp_comment  IN VARCHAR2 )
  IS

   l_cursor         INTEGER;
   l_rows           INTEGER;
   l_stmt           VARCHAR2(2000);
   l_Exception_Desc VARCHAR2(2000);

   l_run binary_integer;
   l_uom_status VARCHAR2(2000) := 'S';

  BEGIN

   --SST changes
   <<init_prog>>
   BEGIN

     -- SST: Init calls GetTrxSrcInfo
     init(P_transaction_source => X_transaction_source);

   EXCEPTION WHEN others THEN
     IF PG_DEBUG = 'Y' THEN
        log_message('log_message: ' || 'Error in Init procedure',1);
        log_message('log_message: ' || 'Stage='||pa_debug.G_err_stage,1);
        log_message('log_message: ' || SQLERRM);
     END IF;

     raise_application_error(-20001,'Init:'||SQLERRM);
   END init_prog;

   IF PG_DEBUG = 'Y' THEN
      log_message('log_message: ' || 'Run = '|| l_run);
   END IF;

   -- 5235363 R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
   --
   IF (X_transaction_source in (  'AP INVOICE', 'AP NRTAX', 'AP DISCOUNTS', 'INTERCOMPANY_AP_INVOICES',
                                  'INTERPROJECT_AP_INVOICES', 'AP VARIANCE', 'AP ERV', 'PO RECEIPT', 'PO RECEIPT NRTAX',
				  'PO RECEIPT PRICE ADJ', 'PO RECEIPT NRTAX PRICE ADJ')) THEN
      set_supplier_cost_eidate(X_transaction_source,X_batch,X_xface_id) ;
   END IF ;
   --
   -- 5235363 end of code changes.
   /* PA.M PJM Additional Attribute changes: Calling unit of measure insertion api for all INV/WIP/ST sources from manufacturing */

   IF X_transaction_source in ('Inventory', 'Inventory Misc', 'PJM_CSTBP_INV_NO_ACCOUNTS',
                                           'PJM_CSTBP_INV_ACCOUNTS', 'Work In Process', 'PJM_CSTBP_ST_NO_ACCOUNTS',
                                           'PJM_CSTBP_WIP_NO_ACCOUNTS', 'PJM_CSTBP_ST_ACCOUNTS',
                                           'PJM_CSTBP_WIP_ACCOUNTS', 'PJM_NON_CSTBP_ST_ACCOUNTS') THEN

          IF PG_DEBUG = 'Y' THEN
               log_message('log_message: ' || 'Calling pa_uom.get_uom for transaction source '|| X_transaction_source);
          END IF;

          l_uom_status := Pa_Uom.Get_Uom (X_userid);

          IF l_uom_status <> 'S'  THEN

               IF PG_DEBUG = 'Y' THEN
               log_message('log_message: ' || 'Error in Get_Uom procedure',1);
               log_message('log_message: ' || l_uom_status);
              END IF;

               raise_application_error(-20001,'Get_Uom:'||SQLERRM);

          END IF;

     END IF; /* X_transaction_source */

   <<main_loop>>
   LOOP

    G_IterationNum := G_IterationNum + 1;
    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'G_IterationNum = '|| G_IterationNum);
    END IF;

    <<pre_import>>
    BEGIN
      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_Stage := 'Calling pre_import extension';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      pa_trx_import.pre_import(P_transaction_source => X_transaction_source,
                             P_batch => X_batch,
                             P_xface_id => X_xface_id,
                             P_user_id => X_userid);

      /* PA-K Changes: Remove the inter phase commits */

      /* PA-K Changes: Commenting the call to count_status
         Report will directly select the counts from the interface table */

    EXCEPTION WHEN others THEN
      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'Error in pre_import procedure',1);
         log_message('log_message: ' || 'Stage='||pa_debug.G_err_stage,1);
         log_message('log_message: ' || SQLERRM);
      END IF;
      raise_application_error(-20002,'pre_import:'||SQLERRM);
    END pre_import;

    <<Import1_prog>>
    BEGIN
   	 pa_trx_import.import1(X_transaction_source
                  , X_batch
                  , X_xface_id
                  , X_userid
                  , X_online_exp_comment);

      /* PA-K Changes: Remove the inter phase commits */

      /* PA-K Changes: Commenting the call to count_status
         Report will directly select the counts from the interface table */

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'After import1';
         log_message('log_message: ' || pa_debug.G_err_stage);
      END IF;


    EXCEPTION WHEN others THEN

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'Error in import1 procedure',1);
          log_message('log_message: ' || 'Stage='||pa_debug.G_err_stage,1);
          log_message('log_message: ' || SQLERRM);
       END IF;

       If X_transaction_source = 'ORACLE TIME AND LABOR' Then

               BEGIN

                      IF PG_DEBUG = 'Y' THEN
                      pa_debug.G_err_stage := 'Calling eception handler for OTL';
                         log_message('log_message: ' || pa_debug.G_err_stage,1);
                      END IF;


                      -- Get cursor handle
                      l_cursor  := dbms_sql.open_cursor;

                      l_Exception_Desc := 'Error in Projects Import routine: ' || pa_debug.G_err_stage || ' : ' || SQLERRM;

                      -- Associate a sql statement with the cursor.

                      --FP M OTL API changes (bug 3600642)
                      --replaced Hxc_Generic_Retrieval_Pkg with HXC_INTEGRATION_LAYER_V1_GRP
                      --l_stmt    := 'BEGIN Hxc_Generic_Retrieval_Pkg.Update_Transaction_Status ( ' ||
                      l_stmt    := 'BEGIN HXC_INTEGRATION_LAYER_V1_GRP.Update_Transaction_Status ( ' ||
                                   ' P_Process               => :process, '||
                                   ' P_Status                => :status, '||
                                   ' P_Exception_Description => :Exception_Desc );'||
                                   'END;';

                      IF PG_DEBUG = 'Y' THEN
                      pa_debug.G_err_stage := 'After constructing the  dynamic sql OTL';
                         log_message('log_message: ' || pa_debug.G_err_stage,1);
                      END IF;

                      -- parse the sql statement to check for any syntax or symantic errors

                      dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

                      -- before executing the sql statement bind the variables
                      dbms_sql.bind_variable(l_cursor,':process',
                                             'Projects Retrieval Process');

                      dbms_sql.bind_variable(l_cursor,'status',
                                             'ERRORS');

                      dbms_sql.bind_variable(l_cursor,'Exception_Desc',
                                             l_Exception_Desc);


                      l_rows := dbms_sql.execute(l_cursor);
                      IF PG_DEBUG = 'Y' THEN
                      pa_debug.G_err_stage := 'After executing the  dynamic sql OTL';
                         log_message('log_message: ' || pa_debug.G_err_stage,1);
                      END IF;

                EXCEPTION
                        When Others Then
                                IF PG_DEBUG = 'Y' THEN
                                pa_debug.G_err_stage := 'In excp of the dynamic sql executing OTL';
                                   log_message('log_message: ' || pa_debug.G_err_stage,1);
                                END IF;

                                dbms_sql.close_cursor(l_cursor);
                                RAISE;

                END;

       End If;




      raise_application_error(-20003,'import1_prog:'||SQLERRM||pa_debug.G_err_stage);

    END import1_prog;


	/***** CWK Changes *****/
	 release_po_line_task_lock;
	 init_po_amt_chk;
	/***** CWK Changes *****/



    <<post_import>>
    BEGIN
      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_Stage := 'Calling post_import extension';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      pa_trx_import.post_import(P_transaction_source => X_transaction_source,
                             P_batch => X_batch,
                             P_xface_id => X_xface_id,
                             P_user_id => X_userid);

      /* PA-K Changes: Remove the inter phase commits */

      /* PA-K Changes: Commenting the call to count_status
         Report will directly select the counts from the interface table */

    EXCEPTION WHEN others THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'Error in post import procedure',1);
          log_message('log_message: ' || SQLERRM);
          log_message('log_message: ' || 'Stage='||pa_debug.G_err_stage,1);
       END IF;
      raise_application_error(-20004,'post_import:'||SQLERRM);
    END post_import;

  /* Bug 6998382 Moved the condition to exit the import1 procedure here so that the post processing client extension
					is called for the last batch as well */
    If (G_Exit_Main) Then
       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'G_Exit_Main is true, exit main loop';
          log_message('log_message: ' || pa_debug.G_err_stage,1);
       END IF;
       Exit main_loop;
    End If;
  /* Bug 6998382 End */
    COMMIT;

   END LOOP;

   IF PG_DEBUG = 'Y' THEN
      log_message('log_message: ' || 'End of Procedure Import');
   END IF;

   /* PA-K Changes: Commenting the call to update_status_counter
         Report will directly select the counts from the interface table */

  END import;

  -- SST changes: New APIs

  PROCEDURE init(P_transaction_source IN VARCHAR2) IS

   --l_debug_mode  VARCHAR2(1);
  BEGIN

   -- Get the debug mode, if the debug is turned on then write
   -- log messages to the log file.

   fnd_profile.get('PA_DEBUG_MODE',G_debug_mode);
   G_debug_mode := NVL(G_debug_mode, 'N');

   pa_debug.set_process(x_process => 'PLSQL',
                        x_debug_mode => G_debug_mode);

   pa_cc_utils.log_message('Debug Mode = '||G_debug_mode,1);
   pa_cc_utils.set_curr_function('pa_trx_import.init');

   IF PG_DEBUG = 'Y' THEN
   pa_debug.G_err_Stage := 'retriving transaction source';
      log_message('log_message: ' || pa_debug.G_err_Stage);
   END IF;

   -- Transaction import program is always run for 1 transaction source
   -- get the transaction source info and store in pkg body global variables

   GetTrxSrcInfo ( X_trx_src  => P_transaction_source );

   --Pa.K Changes: For performance moved the Multi-Org check to the init procedure.
   G_Morg := pa_utils.pa_morg_implemented;

   -- MOAC changes. populate the operating unit org id variable.
   g_moac_org_id := pa_moac_utils.get_current_org_id ;

   IF (G_accounting_currency_code IS NULL) THEN
       GetImpCurrInfo;
   END IF;

   pa_cc_utils.reset_curr_function;

  END init;

  PROCEDURE execute_import_extensions(P_program_name IN VARCHAR2,
                                 P_transaction_source  IN VARCHAR2,
                                 P_batch               IN VARCHAR2,
                                 P_user_id             IN NUMBER,
                                 P_xface_id            IN NUMBER) IS

   l_cursor   INTEGER;
   l_rows     INTEGER;
   l_stmt     VARCHAR2(2000);

  BEGIN

   -- If the transaction source has a extension associated with it then
   -- execute the extn, else just exit with out doing anything.
   -- P_program_name is the name of the extension API.
   -- For instance 'PA_SELF_SERVICE_PVT.Upload_SS_Timecard'
   IF ( P_program_name IS NOT NULL ) THEN

      -- Get cursor handle
      l_cursor  := dbms_sql.open_cursor;

      -- Associate a sql statement with the cursor.

      l_stmt    := 'BEGIN '||P_program_name||
                       '(P_transaction_source =>:transaction_source,'||
                         ' P_batch => :batch,'||
                         ' P_user_id => :user_id,'||
                         ' P_xface_id => :xface_id);'||
                   ' END;';

      -- parse the sql statemnt to check for any syntax or symantic errors

      dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

      -- before executing the sql statement bind the variables

      dbms_sql.bind_variable(l_cursor,'transaction_source',
                                             P_transaction_source);
      dbms_sql.bind_variable(l_cursor,'batch',
                                             P_batch);
      dbms_sql.bind_variable(l_cursor,'user_id',
                                             P_user_id);
      dbms_sql.bind_variable(l_cursor,'xface_id',
                                             P_xface_id);

      l_rows := dbms_sql.execute(l_cursor);

   END IF;

  EXCEPTION WHEN others THEN
   dbms_sql.close_cursor(l_cursor);
   raise;
  END execute_import_extensions;

  PROCEDURE pre_import(P_transaction_source IN VARCHAR2,
                        P_batch              IN VARCHAR2,
                        P_xface_id           IN NUMBER,
                        P_user_id            IN NUMBER) IS
  BEGIN

     pa_trx_import.execute_import_extensions( P_program_name => G_pre_processing_extn,
                                P_transaction_source => P_transaction_source,
                                P_batch => P_batch,
                                P_xface_id  => P_xface_id,
                                P_user_id  => P_user_id);

  EXCEPTION WHEN others THEN
   raise;
  END pre_import;

  PROCEDURE post_import(P_transaction_source IN VARCHAR2,
                        P_batch              IN VARCHAR2,
                        P_xface_id           IN NUMBER,
                        P_user_id            IN NUMBER) IS
  BEGIN

     pa_trx_import.execute_import_extensions( P_program_name => G_post_processing_extn,
                                P_transaction_source => P_transaction_source,
                                P_batch => P_batch,
                                P_xface_id  => P_xface_id,
                                P_user_id  => P_user_id);


  EXCEPTION WHEN others THEN
   raise;
  END post_import;

  -- Changes for New TXN Codes
  --- New APIs
  ----------------------------------------------------------------------
  -- This new API counts the number of transactions which passed or failed
  -- certain phase, depending on the parameter

  PROCEDURE count_status(P_phase IN VARCHAR2,
                       P_xface_id IN NUMBER,
                       P_sucess_counter OUT NOCOPY NUMBER,
                       P_failed_counter OUT NOCOPY NUMBER) IS
	v_sucess VARCHAR2(2);
	v_failed VARCHAR2(2);

  BEGIN
	IF (P_phase = 'PREIMPORT') THEN
      IF (G_pre_processing_extn IS NULL) THEN
         P_sucess_counter := 0;
         P_failed_counter := 0;
         return;
      ELSE
		   v_sucess := 'P';
		   v_failed := 'PR';
      END IF;
	ELSIF (P_phase = 'IMPORT') THEN
		IF (G_post_processing_extn IS NULL) THEN
			v_sucess := 'A';
		ELSE
			v_sucess := 'I';
		END IF;
		v_failed := 'R';
	ELSIF (P_phase = 'POSTIMPORT') THEN
      IF (G_post_processing_extn IS NULL) THEN
         P_sucess_counter := 0;
         P_failed_counter := 0;
         return;
      ELSE
		   v_sucess := 'A';
		   v_failed := 'PO';
      END IF;
	END IF;

	SELECT COUNT(DECODE(transaction_status_code, v_sucess, 1, NULL)),
	       COUNT(DECODE(transaction_status_code, v_failed, 1, NULL))
	INTO P_sucess_counter, P_failed_counter
   FROM pa_transaction_interface
   WHERE interface_id = P_xface_id
   AND transaction_status_code IN (v_sucess, v_failed);

	EXCEPTION
   	WHEN OTHERS THEN
			RAISE;
  END;  -- procedure count_status

  -- This API updates the counters in pa_transaction_xface_ctrl_all table.
  -- It keeps one set of counters for each concurrent request. Within a
  -- concurrent request, it does not keep track of counts at the system
  -- linkage function modularity.

  PROCEDURE update_status_counter(P_xface_id IN NUMBER) IS
  BEGIN

	UPDATE pa_transaction_xface_ctrl_all
   SET pre_import_reject_count = G_PRE_IMPORT_REJECT_COUNT,
       pre_import_success_count = G_PRE_IMPORT_SUCCESS_COUNT,
       import_reject_count     = G_IMPORT_REJECT_COUNT,
       import_success_count     = G_IMPORT_SUCCESS_COUNT,
       post_import_reject_count = G_POST_IMPORT_REJECT_COUNT,
       post_import_success_count = G_POST_IMPORT_SUCCESS_COUNT
	WHERE interface_id = P_xface_id;

  EXCEPTION
		WHEN OTHERS THEN
			RAISE;
  END;

  -- Bug 5550268 : Added comments to this procedure for clarity
  PROCEDURE tieback_fc_records ( x_return_status   OUT NOCOPY VARCHAR2,
                               p_calling_mode    IN  VARCHAR2) IS

   -- Bug 5560524 : Modified the following cursor to also fetch AP ERV records
   -- Cursor to fetch AP VARIANCE,PO RECEIPT and PO RECEIPT NRTAX records
   cursor  select_bc_packets(p_calling_mode in varchar2) is
         select a.packet_id,
                a.document_header_id,
                a.document_distribution_id,
                a.budget_ccid,
                b.cdl_system_reference4,
                a.project_id,
		a.budget_line_id ,
		a.budget_version_id
           from pa_bc_packets a,
                pa_transaction_interface b
          where a.txn_interface_id = b.txn_interface_id
	    and a.document_header_id = b.cdl_system_reference2
            and a.document_distribution_id = decode(p_calling_mode, 'AP VARIANCE',b.cdl_system_reference5
	                                                          , 'AP ERV',b.cdl_system_reference5
	                                                          , b.cdl_system_reference3)
            and a.document_type = decode(p_calling_mode, 'AP VARIANCE', 'AP', 'AP ERV', 'AP' , 'PO RECEIPT', 'PO', 'PO RECEIPT NRTAX', 'PO')
            and a.parent_bc_packet_id is null
            and b.transaction_status_code = 'A'
            and a.request_id = g_request_id
            and to_char(a.request_id) = b.orig_transaction_reference
            and a.status_code = 'P'
            and b.transaction_source = p_calling_mode;

     -- Cursor to fetch expenditure records associated with AP DISCOUNTS records
     cursor select_disc_packets(p_calling_mode in varchar2) is
         select a.packet_id,
                b.cdl_system_reference2,
		b.cdl_system_reference5,
                a.budget_ccid,
                b.cdl_system_reference4,
                a.project_id,
		a.budget_line_id ,
		a.budget_version_id
           from pa_bc_packets a,
                pa_transaction_interface b,-- moac changes
                pa_expenditure_items c
          where a.txn_interface_id = b.txn_interface_id
	    and a.document_header_id = b.expenditure_item_id
            and a.document_distribution_id = 1
            and a.document_type = decode(p_calling_mode, 'AP DISCOUNTS', 'EXP')
            and a.parent_bc_packet_id is null
            and b.transaction_status_code = 'A'
            and a.request_id = g_request_id
            and a.request_id = b.orig_transaction_reference
            and a.status_code = 'P'
            and b.expenditure_item_id = c.expenditure_item_id
            and b.transaction_source = p_calling_mode;

   -- Cursor to fetch AP INVOICE/AP NRTAX records
   -- Second Union all is used to fetch PO records relieved while interfacing AP invoice distributions
   -- Eg : AP matched to CWK PO , AP matched to accrue on receipt
   cursor  rcpt_acc_ap_pkts(p_calling_mode in varchar2) is
         select a.packet_id ,
                a.document_header_id ,
                a.document_distribution_id ,
                a.budget_ccid,
                b.cdl_system_reference4,
                a.project_id,
		a.budget_line_id ,
		a.budget_version_id
           from pa_bc_packets a,
                pa_transaction_interface b -- moac changes
          where a.txn_interface_id = b.txn_interface_id
	    and a.document_header_id = b.cdl_system_reference2
            and a.document_distribution_id = b.cdl_system_reference5
            and a.document_type = 'AP'
            and a.parent_bc_packet_id is null
            and b.transaction_status_code = 'A'
            and a.request_id = g_request_id
            and b.transaction_source = p_calling_mode
            and a.status_code = 'P'
         union
         select a.packet_id ,
                to_number(b.cdl_system_reference2) ,
                to_number(b.cdl_system_reference5) ,
                a.budget_ccid,
                b.cdl_system_reference4,
                a.project_id,
		a.budget_line_id ,
		a.budget_version_id
           from pa_bc_packets a,
                pa_transaction_interface b, -- moac changes
                ap_invoice_distributions c,
                po_distributions d
          where a.txn_interface_id = b.txn_interface_id
	    and a.document_header_id = d.po_header_id
            and a.document_distribution_id = d.po_distribution_id
            and c.invoice_id = b.cdl_system_reference2
	    and c.invoice_distribution_id = b.cdl_system_reference5
            and c.po_distribution_id = d.po_distribution_id
            and a.document_type = 'PO'
            and a.parent_bc_packet_id is null
            and b.transaction_status_code = 'A'
            and a.request_id = g_request_id
            and b.transaction_source IN  ('AP INVOICE','AP NRTAX') -- Bug 5550268
            and a.status_code = 'P';

   CURSOR c_exp_item_id IS
   SELECT txn.expenditure_item_id ,
          pkt.bc_packet_id
     FROM pa_transaction_interface txn,-- moac changes
          pa_bc_packets pkt
    WHERE pkt.txn_interface_id = txn.txn_interface_id
      and pkt.request_id = g_request_id
      and txn.transaction_status_code = 'A'
      and pkt.status_code = 'P'
      and pkt.document_type ='EXP'
      and txn.adjusted_expenditure_item_id IS NOT NULL
      and pkt.document_header_id <> txn.expenditure_item_id;

   l_packet_id          NUMBER ;
   l_sys_ref2           NUMBER ;
   l_sys_ref3           NUMBER ;
   l_sys_ref4           VARCHAR2(30) ;
   l_doc_dist_id        pa_bc_packets.document_distribution_id%TYPE ;
   l_ExpItemId_temp_Tab PA_PLSQL_DATATYPES.Num15TabTyp;
   l_budget_ccid        NUMBER ;
   l_old_pkt            NUMBER := 0;
   l_project_id         NUMBER ;
   l_bc_pkt_id          pa_bc_packets.bc_packet_id%TYPE;
   l_exp_item_id        pa_expenditure_items_all.expenditure_item_id%TYPE;
   l_budget_line_id     pa_bc_packets.budget_line_id%TYPE;
   l_budget_version_id  pa_bc_packets.budget_version_id%TYPE;


   PROCEDURE Upd_Sts_Enc_Bal(p_packet_id in number,
                    x_return_status out NOCOPY varchar2 ) is

   l_fc_return_status   VARCHAR2(10);

   -- Bug 5372480 : Removed the cursor c_bcpkt_projects as we already have p_packet_id.

   l_records_updated number;

   BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Inside Upd_Sts_Enc_Bal');
    END IF;

    -- R12 funds management : 'C' status code has been obsoleted
    l_records_updated := 0;

    -- Bug 5372480 : Records of pa_bc_packets are marked to 'A' status before calling pa_funds_control_pkg.UPD_BDGT_ENCUM_BAL
    -- because the CURSOR bdgt_encum_details in pa_funds_control_pkg.UPD_BDGT_ENCUM_BAL queries for 'A' status records from pa_bc_packets.
    -- Also there is no need to loop for distinct projects earlier being fetched by cursor c_bcpkt_projects.

      update pa_bc_packets a
         set a.status_code = 'A'
       where a.packet_id = p_packet_id
         and a.request_id = g_request_id
         and a.status_code = 'P';

      l_records_updated := l_records_updated + SQL%ROWCOUNT;


    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Updated PacketId [' || p_packet_id || ']-' || l_records_updated || ' records to A/C';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;


    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Calling pa_funds_control_pkg.UPD_BDGT_ENCUM_BAL');
    END IF;

    -- set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_funds_control_pkg.UPD_BDGT_ENCUM_BAL(
                       p_packet_id       =>  p_packet_id,
                       p_calling_module  =>  'TRXIMPORT',
                       p_mode          =>  'R',
                       p_packet_status =>  'S',
                       x_return_status =>  l_fc_return_status);

    if l_fc_return_status <> FND_API.G_RET_STS_SUCCESS then
       x_return_status := l_fc_return_status ;
       return;
    end if;


   EXCEPTION
        WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        RAISE;

   END Upd_Sts_Enc_Bal;

  BEGIN

    pa_cc_utils.set_curr_function('tieback_fc_records');

    IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Start of tieback_fc_records';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    -- set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'p_calling_mode = ' || p_calling_mode);
    END IF;

    open c_exp_item_id;
      loop
       fetch c_exp_item_id
        into l_exp_item_id,
	     l_bc_pkt_id;

       if c_exp_item_id%notfound then
           IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'No packets found for updating of exp item id , exit';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;
           exit;
       end if;

      UPDATE pa_bc_packets
         SET document_header_id = l_exp_item_id,
	     reference1         = l_exp_item_id
       WHERE bc_packet_id = l_bc_pkt_id;
     END LOOP;
    CLOSE c_exp_item_id;

    -- Bug 5560524 : Added 'AP ERV' to the following condition.
    if (p_calling_mode in ('AP VARIANCE', 'AP ERV' , 'PO RECEIPT', 'PO RECEIPT NRTAX')) Then

      IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Before opening the cursor select_bc_packets for ' || p_calling_mode;
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      open select_bc_packets(p_calling_mode) ;

      loop

       fetch select_bc_packets
        into l_packet_id,
             l_sys_ref2,
             l_doc_dist_id,
             l_budget_ccid,
             l_sys_ref4,
             l_project_id,
    	     l_budget_line_id ,
	     l_budget_version_id;

       if select_bc_packets%notfound then
           IF PG_DEBUG = 'Y' THEN
               pa_debug.G_err_stage := 'No packets found, exit';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;
           exit ;
           end if;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Old Pkt = ' || l_old_pkt
                              || ' Packet Id = ' || l_packet_id
                              || ' Ref2 = ' || l_sys_ref2
                              || ' document dist id = ' || l_doc_dist_id
                              || ' Ref4 = ' || l_sys_ref4;
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       IF (l_old_pkt <> l_packet_id) THEN
          IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling Upd_Sts_Enc_Bal';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          Upd_Sts_Enc_Bal(p_packet_id   => l_packet_id,
                       x_return_status =>  x_return_status);

          IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'After Calling Upd_Sts_Enc_Bal';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
       END IF;

       IF (pa_funds_control_utils.get_bdgt_link(l_Project_Id, 'STD') = 'Y') THEN

          -- BUG : 4885459 : APPSPERF:PA:PJC: PA_TRX_IMPORT : PERF. REPOSITORY EXCEPTIONS

	  l_ExpItemId_temp_Tab.DELETE ;

	  select ei.expenditure_item_id
            bulk collect into l_ExpItemId_temp_Tab
	    from pa_expenditure_items_all ei
	   where ei.document_header_id = l_sys_ref2
             and ei.document_distribution_id = DECODE(p_calling_mode,'AP VARIANCE',l_doc_dist_id,'AP ERV',l_doc_dist_id,l_sys_ref4);  -- Bug 5560524

	  IF l_ExpItemId_temp_Tab.COUNT > 0 THEN

	     FORALL j in l_ExpItemId_temp_Tab.first..l_ExpItemId_temp_Tab.last
                   update pa_cost_distribution_lines_all cdl
                      set cdl.Budget_CCID         = l_budget_ccid    ,
                          cdl.encumbrance_type_id = pa_funds_control_utils.get_encum_type_id(cdl.project_id,'STD'),
                          cdl.budget_line_id      = DECODE(cdl.budget_line_id,NULL,l_budget_line_id,cdl.budget_line_id),
                          cdl.budget_version_id   = DECODE(cdl.budget_version_id,NULL,l_budget_version_id,cdl.budget_version_id)
                    Where cdl.budget_ccid is null
	              and cdl.expenditure_item_id  = l_ExpItemId_temp_Tab(j) ;
	  END IF ;

         IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_stage := 'Updated Ref2-Ref3 [' || l_sys_ref2 || ',' || l_doc_dist_id || ',' || l_sys_ref4 || ']-'
                                                     || SQL%ROWCOUNT || ' Budget CCID';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

       END IF;

       l_old_pkt := l_packet_id;

      end loop;

      /* start of bug 3905744 first part */
      IF select_bc_packets%isopen THEN
      close select_bc_packets;
      END IF;
     /* end of bug 3905744 first part */
     --bug  3905744 closed after the second part

    elsif (p_calling_mode in ('AP INVOICE', 'AP NRTAX') ) then

      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Before opening the cursor rcpt_acc_ap_pkts for ' || p_calling_mode;
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      open rcpt_acc_ap_pkts(p_calling_mode);

      loop

       fetch rcpt_acc_ap_pkts
        into l_packet_id,
             l_sys_ref2,
             l_doc_dist_id,
             l_budget_ccid,
             l_sys_ref4,
             l_project_id,
    	     l_budget_line_id ,
	     l_budget_version_id;

       if rcpt_acc_ap_pkts%notfound then
           IF PG_DEBUG = 'Y' THEN
           pa_debug.G_err_stage := 'No packets found, exit';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;
           exit;
       end if;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Old Pkt = ' || l_old_pkt
                              || ' Packet Id = ' || l_packet_id
                              || ' Ref2 = ' || l_sys_ref2
                              || ' Document dist Id = ' || l_doc_dist_id
                              || ' Ref4 = ' || l_sys_ref4;
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       IF (l_old_pkt <> l_packet_id) THEN
          IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling Upd_Sts_Enc_Bal';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          Upd_Sts_Enc_Bal(p_packet_id   => l_packet_id,
                       x_return_status =>  x_return_status);

          IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'After Calling Upd_Sts_Enc_Bal';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
       END IF;

       IF (pa_funds_control_utils.get_bdgt_link(l_Project_Id, 'STD') = 'Y') THEN

          -- BUG : 4885459  APPSPERF:PA:PJC: PA_TRX_IMPORT : PERF. REPOSITORY EXCEPTIONS
          l_ExpItemId_temp_Tab.DELETE ;

	  select ei.expenditure_item_id
            bulk collect into l_ExpItemId_temp_Tab
	    from pa_expenditure_items_all ei
	   where ei.document_header_id = l_sys_ref2
	     and ei.document_distribution_id = l_doc_dist_id;  /*REL12 : AP Lines Uptake changes*/

	  IF l_ExpItemId_temp_Tab.COUNT > 0 THEN

	     FORALL j in l_ExpItemId_temp_Tab.first..l_ExpItemId_temp_Tab.last
                    update pa_cost_distribution_lines_all cdl
                       set cdl.Budget_CCID = l_budget_ccid    ,
      	                  -- R12 Funds Management Uptake : Modified and added below columns logic
	                  cdl.encumbrance_type_id = pa_funds_control_utils.get_encum_type_id(cdl.project_id,'STD'),
                          cdl.budget_line_id      = DECODE(cdl.budget_line_id,NULL,l_budget_line_id,cdl.budget_line_id),
                          cdl.budget_version_id = DECODE(cdl.budget_version_id,NULL,l_budget_version_id,cdl.budget_version_id)
                    Where cdl.budget_ccid         is null
   	              and cdl.expenditure_item_id = l_ExpItemId_temp_Tab(j) ; /*REL12 : AP Lines Uptake changes*/
	  END IF ;

         IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_stage := 'Updated Ref2-Ref3 [' || l_sys_ref2 || ',' || l_doc_dist_id || ',' || l_sys_ref4 || ']-'
                                                     || SQL%ROWCOUNT || ' Budget CCID';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

       END IF;

       l_old_pkt := l_packet_id;

      end loop;

      /* Start of bug 3905744 second part */
      IF rcpt_acc_ap_pkts%isopen THEN
      close rcpt_acc_ap_pkts;
      END IF;
     /* End of bug 3905744 second part */
     --bug 3905744 is ended here
     --closed cursor select_bc_packets after use in the first part
     --closed cursor rcpt_acc_ap_pkts after use in the second part

    elsif (p_calling_mode in ('AP DISCOUNTS')) Then --Bug 2339216

      IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Before opening the cursor select_disc_packets for ' || p_calling_mode;
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      open select_disc_packets(p_calling_mode) ;

      loop

       fetch select_disc_packets
        into l_packet_id,
             l_sys_ref2,
             l_doc_dist_id,
             l_budget_ccid,
             l_sys_ref4,
             l_project_id,
    	     l_budget_line_id ,
	     l_budget_version_id;

       if select_disc_packets%notfound then
           IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'No discount packets found, exit';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;
           exit ;
       end if;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Old Pkt = ' || l_old_pkt
                              || ' Packet Id = ' || l_packet_id
                              || ' Ref2 = ' || l_sys_ref2
                              || ' Document dist Id = ' || l_doc_dist_id
                              || ' Ref4 = ' || l_sys_ref4;
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       IF (l_old_pkt <> l_packet_id) THEN
          IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'Calling Upd_Sts_Enc_Bal for discount';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          Upd_Sts_Enc_Bal(p_packet_id   => l_packet_id,
                       x_return_status =>  x_return_status);

          IF PG_DEBUG = 'Y' THEN
             pa_debug.G_err_stage := 'After Calling Upd_Sts_Enc_Bal';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;
       END IF;

       IF (pa_funds_control_utils.get_bdgt_link(l_Project_Id, 'STD') = 'Y') THEN

          -- BUG : 4885459  APPSPERF:PA:PJC: PA_TRX_IMPORT : PERF. REPOSITORY EXCEPTIONS

          l_ExpItemId_temp_Tab.DELETE ;

	  select ei.expenditure_item_id
            bulk collect into l_ExpItemId_temp_Tab
	    from pa_expenditure_items_all ei
	   where ei.document_header_id       = l_sys_ref2
	     and ei.document_distribution_id = l_doc_dist_id
	     and ei.document_payment_id      = to_number(l_sys_ref4);

	  IF l_ExpItemId_temp_Tab.COUNT > 0 THEN
	     FORALL j in l_ExpItemId_temp_Tab.first..l_ExpItemId_temp_Tab.last
	            update pa_cost_distribution_lines_all cdl
                       set cdl.Budget_CCID = l_budget_ccid    ,
                           cdl.encumbrance_type_id = pa_funds_control_utils.get_encum_type_id(cdl.project_id,'STD'),
			   -- R12 Funds Management Uptake
                           cdl.budget_line_id = DECODE(cdl.budget_line_id,NULL,l_budget_line_id,cdl.budget_line_id),
                           cdl.budget_version_id = DECODE(cdl.budget_version_id,NULL,l_budget_version_id,cdl.budget_version_id)
                     Where cdl.budget_ccid is null
	               and cdl.expenditure_item_id = l_ExpItemId_temp_Tab(j) ;
	  END IF ;

         IF PG_DEBUG = 'Y' THEN
            pa_debug.G_err_stage := 'Updated Ref2-Ref3 [' || l_sys_ref2 || ',' || l_sys_ref3 || ',' || l_sys_ref4 || ']-'
                                                     || SQL%ROWCOUNT || ' Budget CCID';
            log_message('log_message: ' || pa_debug.G_err_Stage);
         END IF;

       END IF;

       l_old_pkt := l_packet_id;

      end loop;
      close select_disc_packets;
    end if;

/* Start of bug 3239837 */
    pa_debug.G_err_stage := 'Update rejected interface records in pa_bc_packets to T';
    pa_cc_utils.log_message(pa_debug.G_err_Stage);

    update pa_bc_packets
    set status_code = 'T',
        result_code = 'F140'
    where request_id = g_request_id
    and   status_code = 'P'
    and   txn_interface_id in
          (select txn_interface_id   /*REL12 : AP Lines Uptake changes*/
             from pa_transaction_interface_all
            where transaction_source = p_calling_mode
             and  transaction_status_code = 'R'
             and  orig_transaction_reference = to_char(g_request_id)
          );

    pa_debug.G_err_stage := 'In stage 1 Updated count to T = '|| SQL%ROWCOUNT;
    pa_cc_utils.log_message(pa_debug.G_err_Stage);

 update pa_bc_packets
    set status_code = 'T',
        result_code = 'F140'
    where request_id = g_request_id
    and   status_code = 'P'
    and   (document_header_id, document_distribution_id) in
          (select po_header_id, po_distribution_id
	   from po_distributions_all
	   where po_distribution_id in
                  (select po_distribution_id
                   from ap_invoice_distributions_all inv, pa_transaction_interface_all pti
                  where inv.invoice_id = pti.cdl_system_reference2
		    and inv.invoice_distribution_id = pti.cdl_system_reference5 /*REL12 : AP Lines Uptake changes*/
                    and pti.transaction_source = p_calling_mode
                    and pti.transaction_status_code = 'R'
                    and pti.orig_transaction_reference = to_char(g_request_id))
          );

    pa_debug.G_err_stage := 'In stage 2 Updated count to T = '|| SQL%ROWCOUNT;
    pa_cc_utils.log_message(pa_debug.G_err_Stage);

/* End of bug 3239837 */

    --Bug 3592289
    --If pkts are still left in 'P' sts, it means the corresponding
    --EIs in the interface table are rejected. The above cursors select
    --only transaction status code = 'A'. Hence, here we update all
    --the remaining 'P' status for the request id to 'T'
    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: Before update to T');
    END IF;

    update pa_bc_packets
    set status_code = 'T',
      result_code = 'F140'
    where status_code = 'P'
    and request_id = G_REQUEST_ID;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Updated ' || SQL%ROWCOUNT || ' packet statuses to T');
    END IF;

    --Bug 3592289 End


    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Done with Tieback';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    pa_cc_utils.reset_curr_function;

  EXCEPTION
	WHEN OTHERS THEN
      	x_return_status  := fnd_api.g_ret_sts_unexp_error;
	RAISE;
  END tieback_fc_records;

  --PA-J Receipt Accrual Changes:
  --     1. Renamed all existing cursors so that it can be distinguished by the source.
  --        Renamed c_commitment, c_bc_packets, commitment_exist cursors to
  --                c_ap_commitment, c_ap_bc_packets, ap_commitment_exist.
  --     2. Added 2 more IN parameters to tr_import_funds_check, namely
  --        p_txn_source, p_acct_raw_cost
  --     3. Added 3 more cursors for the PO records - c_po_commitment, c_po_bc_packets, po_commitment_exist
  --     4. Converted the existing section to insert AP funds check records and added a new section for
  --        PO based on the p_txn_source.
  --     5. For the PO reversing raw line, use -p_acct_raw_cost as the
  --        (accounted_dr-accounted_cr) and (entered_dr-entered_cr) columns resp.
  --     6. For the PO reversing burden line, prorate the amount from the burden line of the original PO line.
  --     7. For the positive EXP line, use the p_acct_raw_cost for the amount columns.
  PROCEDURE tr_import_funds_check ( p_pa_date               IN  DATE,
                                  p_txn_source            IN VARCHAR2,
                                  p_acct_raw_cost         IN NUMBER,
				  p_adj_exp_item_id       IN NUMBER,
				  p_txn_interface_id      IN NUMBER,
				  p_fc_document_type      IN VARCHAR2,
                                  x_packet_id             OUT NOCOPY NUMBER,
                                  x_error_message_code    OUT NOCOPY VARCHAR2,
                                  x_error_stage           OUT NOCOPY VARCHAR2,
                                  x_return_status         OUT NOCOPY VARCHAR2) IS

   --R12 funds management uptake : modified corresponding insert api's to autonomous
   --   PRAGMA AUTONOMOUS_TRANSACTION;

   -- R12 AP lines uptake : Prepayment changes :
   -- Deleted obsolete variables

   l_packet_id          NUMBER ;
   l_po_dist_id         NUMBER;
   l_acc_flag           VARCHAR2(1);
   l_po_hdr_id          NUMBER;
   l_denom_po_amt       NUMBER;
   l_acct_po_amt        NUMBER;
   l_normal_inv         VARCHAR2(1) := 'Y';
   l_txn_source         VARCHAR2(30) := p_txn_source;
   --R12 Funds Management Uptake : Deleted variables defined for storing encumbrance types
   l_project_id              NUMBER(15);
   l_base_qv           NUMBER;
   l_base_av           NUMBER;
   l_period_year       pa_bc_packets.period_year%type; --REL12
   l_inv_type          ap_invoices_all.invoice_type_lookup_code%TYPE;
   l_line_type_lookup_code  ap_invoice_distributions_all.line_type_lookup_code%TYPE;

  -- R12 AP lines uptake : Prepayment changes :Cursor to fetch AP related details.
   CURSOR C_ap_details (p_invoice_id               NUMBER,
                        p_invoice_distribution_id  NUMBER) IS
   SELECT dist.po_distribution_id,
          dist.project_id,
          nvl(dist.base_quantity_variance,0), --PA.M QV and AV
          NVL(dist.base_amount_variance,0),
          inv.invoice_type_lookup_code,
	  dist.line_type_lookup_code
    FROM  ap_invoice_distributions dist,
          ap_invoices inv
   WHERE dist.invoice_id = p_invoice_id
     AND dist.invoice_distribution_id = p_invoice_distribution_id
     AND inv.invoice_id  = dist.invoice_id;

   --Bug 2905892
   --Derive Period_Name for the given GL_Date from GL_Period_Statuses
   --for Application_Id 101.
   --Funds checking is done using GL periods (application id = 101)
   FUNCTION Get_FC_Period_Name(P_GL_Date IN DATE) RETURN VARCHAR2 IS
      l_Period_Name pa_bc_packets.period_name%type;
   BEGIN

     If P_GL_Date = G_PrevFCGlDate Then

        l_Period_Name := G_PrevFCPdName;

     Else

       Select Period_Name,PERIOD_YEAR
         Into l_Period_Name,l_period_year
         From Gl_Period_Statuses
        Where Application_Id = 101
          And Trunc(P_GL_Date) Between Trunc(Start_Date) And Trunc(End_Date)
          And Set_Of_Books_Id = G_SobId
	  And adjustment_period_flag = 'N'; -- added for bug 3083625

        G_PrevFCGlDate := P_GL_Date;
        G_PrevFCPdName := l_Period_Name;
	G_Fc_Period_Year  := l_period_year;

     End If;

     Return l_Period_Name;

   EXCEPTION
       WHEN OTHERS THEN
          Raise;

   END Get_FC_Period_Name;

  BEGIN

    pa_cc_utils.set_curr_function('tr_import_funds_check');
    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Inside Tr_Import_Funds_Check';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    --
    -- 1. Generate a packet identifier for all the records that
    --    needs to be inserted into Pa BC Packets
    --
    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Generateing new packet Id';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;
     Select Gl_Bc_Packets_s.NextVal
       Into l_Packet_Id
       From dual;

    /*  Since we have divided the funds check packet insert code into 3 sections
    the bc packet id will be generated in each of the individual sections
    rather than in the beginning
    */

    --Bug 2905892
    --Get the GL Period Name from txn's gl_date. This will be inserted into pa_bc_packets
    --for both the reversing raw and burden lines and also the EXP lines.
    --Funds Check API will derive the GL_Date based on the Period_Name, so what
    --we insert for gl_date is irrelevant here.
    IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling G_FC_Period_Name';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    G_FC_Period_Name := Get_FC_Period_Name(P_Gl_Date => G_FC_Gl_Date);

    IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'G_FC_Period_Name = ' || G_FC_Period_Name;
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;
    --End Bug 2905892

     -- R12 : AP Lines Uptake changes + R12 AP lines uptake : Prepayment changes
     -- Cash based Accounting code : When Cash based accounting is set to Yes then
     -- following type of transactions are allowed to be interafced to projects :
     --  a.  Historical Data(i.e.11i) : System interfaces invoice distributions and not the payments.
     --      For these records g_cdl_system_reference4 will be NULL.
     --      Following invoices in Cash based accounting are considered as historical data :
     --        1. All Invoices (including prepayments) with historical_flag ='Y'
     --        2. All reversal/cancelled Invoices associated with Invoices which are interfaced
     --        3. Prepayment application associated with interfaced prepayment distribution.
     --
     --      These historical invoices will be firing the same fundscheck logic as that of
     --      accrual based accounting invoices.
     --  b.  R12 Data : Only payments will be interfaced.
     --      For these records g_cdl_system_reference4 will be NOT NULL

     IF (l_txn_source in ('AP INVOICE', 'AP NRTAX','AP EXPENSE','INTERCOMPANY_AP_INVOICES', 'AP ERV',
                          'INTERPROJECT_AP_INVOICES','AP VARIANCE') )
	             AND G_cash_based_accounting = 'Y'
	             AND NVL(g_cdl_system_reference4,0) <> 0  THEN

	            ap_cash_based_funds_check (
	             p_txn_source                => l_txn_source,
	             p_acct_raw_cost             => p_acct_raw_cost,
	             p_packet_id                 => l_packet_id,
                     p_sys_ref2                  => to_number(g_cdl_system_reference2),
                     p_sys_ref4                  => g_cdl_system_reference4,
	             p_sys_ref5                  => to_number(g_cdl_system_reference5),
	             p_adj_exp_item_id           => p_adj_exp_item_id,
	             p_txn_interface_id          => p_txn_interface_id,
	             p_fc_document_type          => p_fc_document_type,
	             x_error_message_code        => x_error_message_code,
	             x_error_stage               => x_error_stage,
	             x_return_status             => x_return_status);

    ELSIF (l_txn_source in ('AP INVOICE', 'AP NRTAX') ) THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Selecting PO Dist Id for AP Invoice';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       -- REL12 : AP Lines Uptake changes
       -- Commented logic associated with IPV and ERV columns as these will be now interfaced
       -- as seperate distribution lines

       -- R12 AP lines uptake : Prepayment changes: Shifted logic of SELECT statment to cursor .
       -- Also modified cursor to fetch value for invoice type

       OPEN c_ap_details (to_number(g_cdl_system_reference2),
                          to_number(g_cdl_system_reference5));
       FETCH c_ap_details INTO l_po_dist_id,
                               l_project_id,
                               l_base_qv,
			       l_base_av,
			       l_inv_type,
			       l_line_type_lookup_code;
       CLOSE c_ap_details;

       -- R12 AP lines uptake : Prepayment changes
       -- Deleted code added for bug 3746522 as the logic is not required

       --PA.M QV and AV
       /*REL12 : AP Lines uptake changes */
       /*Call to AP_PA_API_PKG.Get_Inv_Amount_Var is deleted and introduced logic to fetch
         amt variance from ap_invoice_distributions*/

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'Po Dist = ' || l_po_dist_id);
          log_message('log_message: ' || ' Base QV = ' || l_base_qv );
          log_message('log_message: ' || ' Base AV = ' || l_base_av );
          log_message('log_message: ' || ' line_type_lookup_code = ' || l_line_type_lookup_code );
       END IF;

       -- R12 AP lines uptake : Prepayment changes: For prepyament always fire ap_funds_check procedure
       -- as PREPAYMENT commitment matched to PO will never be fundschecked

       If (l_po_dist_id is not null AND l_inv_type <> 'PREPAYMENT' ) Then

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'PO Dist Found, Selecting Receipt Accrual Flag';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          --R12 Funds management uptake changes: Obsolete logic which was based on financial system parameters.Going forward
          --commitments fundscheck will be performed irrespective of value stored in encumbrance types.
          --Hence for matched invoices amount should always be relieved against AP.

          Select nvl(accrue_on_receipt_flag,'N'),
                 po_header_id
           Into l_acc_flag,
                l_po_hdr_id
           from Po_distributions
           where po_distribution_id = l_po_dist_id;

           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'Receipt Acc Flag = ' || l_acc_flag || ' Po Hdr = ' || l_po_hdr_id);
           END IF;

           --Bug 2672772: If non-accrue on receipt and enc type same, PO commitment should be relieved
	   -- Bug 5561690 : TIPV and TRV are interfaced with  'AP NRTAX' transaction source but
	   -- these lines( matched to PO with accrue on receipt) are reserved as AP commitments.
	   -- Hence should be treated as normal invoice lines.
           If (l_acc_flag = 'Y' AND l_line_type_lookup_code NOT IN ('TRV','TIPV'))
	      OR --(l_acc_flag = 'N' AND l_po_enc_type_id = l_ap_enc_type_id)  OR --R12 Funds Management Uptake
           /* when a variance exists on a tax distribution for an invoice matched to a rate based PO
              (for which the CWK Imp option is set to Y, meaning timecards are interfaced and only
              variance and tax are to be interfaced from AP/PO), the amount minus the variance should be
              deducted from PO commitment and the variance should be deducted from AP
              commitment */
              (l_txn_source = 'AP NRTAX'  AND
               nvl(Pa_Pjc_Cwk_Utils.Is_rate_based_line( null, l_po_dist_id),'N') = 'Y' AND
               Pa_Pjc_CWk_Utils.Is_CWK_TC_Xface_Allowed(l_project_id) = 'Y')Then

               IF PG_DEBUG = 'Y' THEN
               pa_debug.G_err_stage := 'PO accrues on receipt or Enc Type Same for non-accrue on receipt';
                  log_message('log_message: ' || pa_debug.G_err_Stage);
               END IF;

               --This is not a normal invoice meaning we have to reverse the
               --PO commitment and then check if there is any variances and
               --reverse them too.
               l_normal_inv := 'N';

               --l_denom_po_amt := p_denom_raw_cost - (l_ipv + l_erv);
               --PA.M QV and AV
               l_acct_po_amt  := p_acct_raw_cost - (/* l_base_ipv + l_erv + */ --REL12
	                                            l_base_qv + nvl(l_base_av,0));

               IF PG_DEBUG = 'Y' THEN
                  log_message('log_message: ' || ' Acct PO Amt = ' || l_acct_po_amt);
               END IF;

               IF PG_DEBUG = 'Y' THEN
               pa_debug.G_err_stage := 'Calling ap_po_funds_check';
                  log_message('log_message: ' || pa_debug.G_err_Stage);
               END IF;

               ap_po_funds_check (
                                  p_txn_source           => l_txn_source,
                                  p_acct_raw_cost        => l_acct_po_amt,
                                  p_packet_id            => l_packet_id,
                                  p_po_hdr_id            => l_po_hdr_id,
                                  p_po_dist_id           => l_po_dist_id,
                                  p_inv_id               => to_number(g_cdl_system_reference2),
				  p_inv_dist_id          => to_number(g_cdl_system_reference5),   --REL12
                                  p_dist_line            => to_number(g_cdl_system_reference3),   --REL12
				  p_adj_exp_item_id      => p_adj_exp_item_id,
				  p_txn_interface_id     => p_txn_interface_id,
				  p_fc_document_type     => p_fc_document_type,
				  p_base_qty_var_amt     => l_base_qv,
                                  p_base_amt_var_amt     => l_base_av,
                                  x_error_message_code   => x_error_message_code,
                                  x_error_stage          => x_error_stage,
                                  x_return_status        => x_return_status);

               IF PG_DEBUG = 'Y' THEN
               pa_debug.G_err_stage := 'After ap_po_funds_check';
                  log_message('log_message: ' || pa_debug.G_err_Stage);
               END IF;

           End If;

       End If;

       If (l_normal_inv = 'Y') Then

          IF PG_DEBUG = 'Y' THEN
          pa_debug.G_err_stage := 'Start funds check packet insert for AP - non accrue on receipt diff enc type';
             log_message('log_message: ' || pa_debug.G_err_Stage);
          END IF;

          ap_funds_check (
                     p_txn_source         => l_txn_source,
                     p_acct_raw_cost      => p_acct_raw_cost,
                     p_packet_id          => l_packet_id,
                     p_sys_ref2           => g_cdl_system_reference2,
                     p_sys_ref3           => g_cdl_system_reference3,
		     p_sys_ref5           => g_cdl_system_reference5, --REL12
		     p_adj_exp_item_id    => p_adj_exp_item_id,       --REL12
		     p_txn_interface_id   => p_txn_interface_id,      --REL12
		     p_fc_document_type   => p_fc_document_type,      --REL12
                     x_error_message_code => x_error_message_code,
                     x_error_stage        => x_error_stage,
                     x_return_status      => x_return_status);

           IF PG_DEBUG = 'Y' THEN
           pa_debug.G_err_stage := 'After ap_funds_check';
              log_message('log_message: ' || pa_debug.G_err_Stage);
           END IF;

           /*REL12 : AP Lines Uptake changes
	    Commented below logic as IPV / ERV/QV/AV lines will be separately interfaced
	    and picked by the AP VARIANCE section */

       End If;

    --PA-J Receipt Accrual Changes:
    --     Added the below section for Receipt records to be funds checked.
    ELSIF (l_txn_source in ('PO RECEIPT', 'PO RECEIPT NRTAX')) THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Start funds check packet insert for PO Receipts';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       po_funds_check (
                     p_txn_source         => l_txn_source,
                     p_acct_raw_cost      => p_acct_raw_cost,
                     p_packet_id          => l_packet_id,
                     p_sys_ref2           => g_cdl_system_reference2,
                     p_sys_ref3           => g_cdl_system_reference3,
		     p_sys_ref4           => g_cdl_system_reference4, -- Bug 5530897
		     p_adj_exp_item_id    => p_adj_exp_item_id,       --REL12
		     p_txn_interface_id   => p_txn_interface_id,      --REL12
		     p_fc_document_type   => p_fc_document_type,      --REL12
                     x_error_message_code => x_error_message_code,
                     x_error_stage        => x_error_stage,
                     x_return_status      => x_return_status);

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'After po_funds_check';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

    /* Bug 5560524 : Modified the following If condition so that ap_funds_check is also called for
                     'AP ERV' transaction source. */
    ELSIF (l_txn_source in ('AP VARIANCE','AP ERV')) THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Start funds check packet insert for AP Variance records';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       ap_funds_check (
                     p_txn_source         => l_txn_source,
                     p_acct_raw_cost      => p_acct_raw_cost,
                     p_packet_id          => l_packet_id,
                     p_sys_ref2           => g_cdl_system_reference2,
                     p_sys_ref3           => g_cdl_system_reference3,
		     p_sys_ref5           => g_cdl_system_reference5,
		     p_adj_exp_item_id    => p_adj_exp_item_id,       --REL12
		     p_txn_interface_id   => p_txn_interface_id,      --REL12
		     p_fc_document_type   => p_fc_document_type,      --REL12
                     x_error_message_code => x_error_message_code,
                     x_error_stage        => x_error_stage,
                     x_return_status      => x_return_status);

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'After ap_funds_check';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;
    -- R12 AP lines uptake : Prepayment changes: This is fired for both Cash and Accrual based AP discounts.
    ELSIF (l_txn_source in ('AP DISCOUNTS')) THEN --2339216
       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Selecting disc amount for AP Invoice';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Discount amount='||p_acct_raw_cost;
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;

       if ( p_acct_raw_cost <> 0 ) then
       ap_disc_funds_check (
                 p_txn_source         => l_txn_source,
                 p_acct_raw_cost      => p_acct_raw_cost,
                 p_packet_id          => l_packet_id,
                 p_sys_ref2           => g_cdl_system_reference2,
                 p_sys_ref3           => g_cdl_system_reference3,
		 p_sys_ref4           => g_cdl_system_reference4, --REL12
		 p_sys_ref5           => g_cdl_system_reference5, --REL12
		 p_adj_exp_item_id    => p_adj_exp_item_id,       --REL12
		 p_txn_interface_id   => p_txn_interface_id,      --REL12
		 p_fc_document_type   => p_fc_document_type,      --REL12
                 x_error_message_code => x_error_message_code,
                 x_error_stage        => x_error_stage,
                 x_return_status      => x_return_status);

              IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'After Call ap_disc_funds_check';
                 log_message('log_message: ' || pa_debug.G_err_Stage);
              END IF;
       end if; --2339216
    END IF;  --p_txn_source check

    x_packet_id  := l_packet_id ;
    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Returning from funds check');
    END IF;
    pa_cc_utils.reset_curr_function;

    -- set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
       log_message('log_message: In others of tr import, packet_id = '|| l_packet_id); -- Bug 3592289
       Upd_PktSts(p_packet_id => l_packet_id);

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' Returning from funds check');
          log_message('log_message: x_return_status = ' || x_return_status);  -- Bug 3592289
          log_message('log_message: x_error = ' || x_error_message_code);  -- Bug 3592289
       END IF;
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       pa_cc_utils.reset_curr_function;
  END tr_import_funds_check ;

  --2339216: Added procedure
  PROCEDURE ap_disc_funds_check (
          p_txn_source            IN VARCHAR2,
          p_acct_raw_cost         IN NUMBER,
          p_packet_id             IN NUMBER,
          p_sys_ref2              IN NUMBER,
          p_sys_ref3              IN NUMBER,
	  p_sys_ref4              IN VARCHAR2, --REL12
 	  p_sys_ref5              IN NUMBER, --REL12
	  p_adj_exp_item_id       IN NUMBER,        --REL12
	  p_txn_interface_id      IN NUMBER,        --REL12
	  p_fc_document_type      IN VARCHAR2,      --REL12
          x_error_message_code    OUT NOCOPY VARCHAR2,
          x_error_stage           OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY VARCHAR2) IS

  BEGIN

    pa_cc_utils.set_curr_function('ap_disc_funds_check');

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Inside AP_Disc_Funds_Check';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    insert_ap_bc_packets(   p_packet_id        => p_packet_id,
                            p_sys_ref2         => p_sys_ref2,
			    p_sys_ref4         => p_sys_ref4,
                            p_sys_ref5         => p_sys_ref5,
                            p_acct_raw_cost    => p_acct_raw_cost,
                            p_acct_bur_cost    => 0,
                            p_fc_document_type => p_fc_document_type ,
                            p_txn_source       => p_txn_source   ,
                            p_adj_exp_item_id  => p_adj_exp_item_id ,
			    p_txn_interface_id => p_txn_interface_id);

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Returning from ap funds check');
    END IF;

    -- set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_cc_utils.reset_curr_function;

  EXCEPTION
    --Bug 2672772: Handle the NDF exception,
    --raise the error here but not in tr_import_funds_check
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' In NDF: Returning from ap disc funds check');
       END IF;
       --Call FC packets update API to update packets to T.
       --moved to tr_import_funds_check
       --Upd_PktSts(p_packet_id => p_packet_id);

       x_return_status  := fnd_api.g_ret_sts_error;
       x_error_message_code := 'PA_FC_NDF';

       pa_cc_utils.reset_curr_function;
       RAISE;

    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' Returning from ap disc funds check');
       END IF;
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       pa_cc_utils.reset_curr_function;
       RAISE;
  END ap_disc_funds_check;

  PROCEDURE ap_funds_check (
          p_txn_source            IN VARCHAR2,
          p_acct_raw_cost         IN NUMBER,
          p_packet_id             IN NUMBER,
          p_sys_ref2              IN NUMBER,
          p_sys_ref3              IN NUMBER,
	  p_sys_ref5              IN NUMBER,        --REL12
	  p_adj_exp_item_id       IN NUMBER,        --REL12
	  p_txn_interface_id      IN NUMBER,        --REL12
	  p_fc_document_type      IN VARCHAR2,      --REL12
          x_error_message_code    OUT NOCOPY VARCHAR2,
          x_error_stage           OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY VARCHAR2) IS

  BEGIN

    pa_cc_utils.set_curr_function('ap_funds_check');

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Inside AP_Funds_Check';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

   insert_ap_bc_packets(   p_packet_id        => p_packet_id,
                            p_sys_ref2         => p_sys_ref2,
			    p_sys_ref4         => NULL,
                            p_sys_ref5         => p_sys_ref5,
                            p_acct_raw_cost    => p_acct_raw_cost,
                            p_acct_bur_cost    => 0,
                            p_fc_document_type => p_fc_document_type ,
                            p_txn_source       => p_txn_source   ,
                            p_adj_exp_item_id  => p_adj_exp_item_id ,
			    p_txn_interface_id => p_txn_interface_id);

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Returning from ap funds check');
    END IF;

    -- set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_cc_utils.reset_curr_function;

  EXCEPTION
    --Bug 2672772: Handle the NDF exception,
    --raise the error here but not in tr_import_funds_check
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' In NDF: Returning from ap funds check');
       END IF;
       --Call FC packets update API to update packets to T.
       --moved to tr_import_funds_check
       --Upd_PktSts(p_packet_id => p_packet_id);

        x_return_status  := fnd_api.g_ret_sts_error;
        x_error_message_code := 'PA_FC_NDF';

        pa_cc_utils.reset_curr_function;
        RAISE;


    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' Returning from ap funds check');
       END IF;
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       pa_cc_utils.reset_curr_function;
       RAISE;
  END ap_funds_check;

  PROCEDURE po_funds_check (
             p_txn_source            IN VARCHAR2,
             p_acct_raw_cost         IN NUMBER,
             p_packet_id             IN NUMBER,
             p_sys_ref2              IN NUMBER,
             p_sys_ref3              IN NUMBER,
             p_sys_ref4              IN NUMBER,        -- Bug 5530897
	     p_adj_exp_item_id       IN NUMBER,        --REL12
	     p_txn_interface_id      IN NUMBER,        --REL12
	     p_fc_document_type      IN VARCHAR2,      --REL12
             x_error_message_code    OUT NOCOPY VARCHAR2,
             x_error_stage           OUT NOCOPY VARCHAR2,
             x_return_status         OUT NOCOPY VARCHAR2) IS

     --PA.M QV and AV
     l_rev_acct_raw_cost     Number;
     l_rev_acct_cost_temp    Number; -- Bug 5731450
     l_sum_amt               Number;
     l_cmt_rate              Number; -- Bug 5731450
     l_act_rate              Number; -- Bug 5731450

     /* Bug 5731450 : Added the cursor to get the exchange rate for the actuals. */
     cursor c_acct_exchange_rate is
     select acct_exchange_rate
     from pa_transaction_interface_all
     where txn_interface_id = p_txn_interface_id;

     Procedure GetCommSummAmt(p_sys_ref2 In Number,
                              p_sys_ref3 In Number,
                              x_sum_amt  Out NOCOPY Number,
			      x_rate     Out NOCOPY Number -- Bug 5731450 : Added a new parameter x_rate.
			      ) Is
         l_pkt_summ number;
         l_com_summ number;
         l_pkt_rate number; -- Bug 5731450
	 l_com_rate number; -- Bug 5731450

     Begin

/* Bug 5731450 : The following two select statements are modified to also fetch the PO exchange rate. */

        select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0)),SUM(POD.rate)/SUM(1)
          into l_pkt_summ,l_pkt_rate
          from pa_bc_packets bcc,
               po_distributions pod     --Added for Bug#3693974
          where pod.po_header_id = p_sys_ref2
            and pod.po_distribution_id = p_sys_ref3
            and ((
                  bcc.document_type = 'PO'
                  and pod.po_distribution_id = bcc.document_distribution_id
                  and pod.po_header_id = bcc.document_header_id
                 )
                or
                 (
                 bcc.document_type = 'CC_C_PAY'
                 -- 4456442, 4221848
                 -- Bug : PQE:R12: PAAPIMP_SI: ORA-01722 IN  PO_FUNDS_CHECK AND ORA-01400
                 and pod.req_header_reference_num = to_char(bcc.document_header_id)
                 and pod.req_line_reference_num = to_char(bcc.document_distribution_id)
                 )
                )
           and  (
                 (bcc.Status_Code in('A','C'))
                 or
                 (bcc.Status_Code = 'P' and bcc.request_id = G_Request_Id)
                )
           and  bcc.Parent_Bc_Packet_Id is NULL;

        select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0)),SUM(POD.rate)/SUM(1)
          into l_com_summ,l_com_rate
          from pa_bc_commitments bcc,
               po_distributions pod          --Added for Bug#3693974
          where pod.po_header_id = p_sys_ref2
            and pod.po_distribution_id = p_sys_ref3
            and ((
                  bcc.document_type = 'PO'
                  and pod.po_distribution_id = bcc.document_distribution_id
                  and pod.po_header_id = bcc.document_header_id
                 )
                or
                 (
                 bcc.document_type = 'CC_C_PAY'
                 -- 4456442, 4221848
                 -- Bug : PQE:R12: PAAPIMP_SI: ORA-01722 IN  PO_FUNDS_CHECK AND ORA-01400
                 and pod.req_header_reference_num = to_char(bcc.document_header_id)
                 and pod.req_line_reference_num = to_char(bcc.document_distribution_id)
                 )
                )
            and  bcc.Parent_Bc_Packet_Id is NULL;

        x_sum_amt := nvl(l_pkt_summ,0) + nvl(l_com_summ,0) ;
	x_rate := COALESCE(l_pkt_rate,l_com_rate); -- Bug 5731450

      Exception
        When Others Then
             Raise;

      End GetCommSummAmt;

  BEGIN

    pa_cc_utils.set_curr_function('po_funds_check');

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Inside PO_Funds_Check';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    -- Bug 4346519 : Receipt Returns ( i.e. -ve amt getting interfaced to projects) should reserve the cmt costs that are getting
    -- interfaced without any manipulations.Below logic should get fired only if commitment is being relieved
    -- (+ve amt getting interfaced to projects) then we should not be relieving more than the reserved amount.

       --PA.M QV and AV
       GetCommSummAmt (p_sys_ref2 => p_sys_ref2,
                       p_sys_ref3 => p_sys_ref3,
                       x_sum_amt => l_sum_amt,
		       x_rate => l_cmt_rate);

       IF PG_DEBUG = 'Y' THEN
           log_message('log_message: l_sum_amt = ' || l_sum_amt || ' p_acct_raw_cost = '|| p_acct_raw_cost);
       END IF;

       --If commitment is liquidated completely then for the current record,
       --relieve 0 amount (l_rev_acct_raw_cost=0)
       /* Bug 5731450 : Derive the actual exchange rate only if the commitment exchange rate is not null. */
       If l_cmt_rate IS NOT NULL then
          open c_acct_exchange_rate;
	  fetch c_acct_exchange_rate into l_act_rate;
	  close c_acct_exchange_rate;
       end if;

       IF PG_DEBUG = 'Y' THEN
           log_message('log_message: l_cmt_rate = ' || l_cmt_rate || ' l_act_rate = '|| l_act_rate);
       END IF;

     /* Bug 5731450 : If the exchange rate for the PO commitment and the actuals are different then
        the commitment relieving is done using PO exchange rate. */
     If nvl(l_cmt_rate,1) <> nvl(l_act_rate,1) then
        l_rev_acct_cost_temp := nvl(p_acct_raw_cost,0)/nvl(l_act_rate,1)*nvl(l_cmt_rate,1);
     else
        l_rev_acct_cost_temp := nvl(p_acct_raw_cost,0);
     end If;

    IF NVL(p_acct_raw_cost,0) > 0 THEN

        if nvl(l_sum_amt,0) = 0 then
          if nvl(p_acct_raw_cost,0) < nvl(l_sum_amt,0) then  /* added for bug:7326188 */
            l_rev_acct_raw_cost := nvl(p_acct_raw_cost,0);
          else
             l_rev_acct_raw_cost := 0;
           end if;
       else
          if l_rev_acct_cost_temp > nvl(l_sum_amt,0) then -- Bug 5731450
             l_rev_acct_raw_cost := nvl(l_sum_amt,0);
          else
             l_rev_acct_raw_cost := l_rev_acct_cost_temp; -- Bug 5731450
          end if;
       end if;

    ELSE  -- Bug 4346519

      l_rev_acct_raw_cost := l_rev_acct_cost_temp; -- Bug 5731450

    END IF;

    IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Before Calling insert_po_bc_packets';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    insert_po_bc_packets   (p_packet_id          => p_packet_id ,
                            p_sys_ref2           => p_sys_ref2  ,
			    p_sys_ref4           => p_sys_ref4, -- Bug 5530897
                            p_sys_ref3           => p_sys_ref3  ,
                            p_acct_raw_cost      => p_acct_raw_cost,
			    p_cmt_raw_cost       => l_rev_acct_raw_cost,
                            p_fc_document_type   => p_fc_document_type,
                            p_txn_source         => p_txn_source ,
                            p_adj_exp_item_id    => p_adj_exp_item_id,
			    p_txn_interface_id   => p_txn_interface_id);

    IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'After Calling insert_po_bc_packets';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Returning from po funds check');
    END IF;

    -- set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_cc_utils.reset_curr_function;

  EXCEPTION
    --Bug 2672772: Handle the NDF exception,
    --raise the error here but not in tr_import_funds_check
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' In NDF: Returning from po funds check');
       END IF;
       --Call FC packets update API to update packets to T.
       --moved to tr_import_funds_check
       --Upd_PktSts(p_packet_id => p_packet_id);

       x_return_status  := fnd_api.g_ret_sts_error;
       x_error_message_code := 'PA_FC_NDF';

       pa_cc_utils.reset_curr_function;
       RAISE;

    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' Returning from po funds check');
       END IF;
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       pa_cc_utils.reset_curr_function;
       RAISE;
  END po_funds_check;

  PROCEDURE ap_po_funds_check (
             p_txn_source            IN VARCHAR2,
             p_acct_raw_cost         IN NUMBER,
             p_packet_id             IN NUMBER,
             p_po_hdr_id             IN NUMBER,
             p_po_dist_id            IN NUMBER,
             p_inv_id                IN NUMBER,
	     p_inv_dist_id           IN NUMBER, --REL12
             p_dist_line             IN NUMBER, --REL12
	     p_adj_exp_item_id       IN NUMBER,        --REL12
	     p_txn_interface_id      IN NUMBER,        --REL12
	     p_fc_document_type      IN VARCHAR2,      --REL12
             p_base_qty_var_amt      IN NUMBER,
             p_base_amt_var_amt      IN NUMBER,
             x_error_message_code    OUT NOCOPY VARCHAR2,
             x_error_stage           OUT NOCOPY VARCHAR2,
             x_return_status         OUT NOCOPY VARCHAR2) IS

  BEGIN

   pa_cc_utils.set_curr_function('ap_po_funds_check');

   IF PG_DEBUG = 'Y' THEN
   pa_debug.G_err_stage := 'Inside ap_po_Funds_Check';
      log_message('log_message: ' || pa_debug.G_err_Stage);
   END IF;

   IF PG_DEBUG = 'Y' THEN
   pa_debug.G_err_stage := 'Start funds check packet insert for AP records that accrue on receipt';
      log_message('log_message: ' || pa_debug.G_err_Stage);
   END IF;

   IF PG_DEBUG = 'Y' THEN
   pa_debug.G_err_stage := 'Call po_funds_check to reverse out the PO commitment';
      log_message('log_message: ' || pa_debug.G_err_Stage);
   END IF;

   po_funds_check (
                 p_txn_source         => p_txn_source,
                 p_acct_raw_cost      => p_acct_raw_cost,
                 p_packet_id          => p_packet_id,
                 p_sys_ref2           => p_po_hdr_id,
                 p_sys_ref3           => p_po_dist_id,
		 p_sys_ref4           => TO_NUMBER(NULL), --Bug 5550268
		 p_adj_exp_item_id    => p_adj_exp_item_id,       --REL12
		 p_txn_interface_id   => p_txn_interface_id,      --REL12
		 p_fc_document_type   => p_fc_document_type,      --REL12
                 x_error_message_code => x_error_message_code,
                 x_error_stage        => x_error_stage,
                 x_return_status      => x_return_status);

   /* Deleted code for IPV and ERV as these will be interfaced as seperate EXP's
      in REL12 */

   /* Replaced ap_funds_check calls for QV and AV with one call to ap_funds_check
      .In insert_ap_bc_packets procedure logic is introduced to relieve all the varaince/invoice
      amounts associated with invoice distribution */

   IF NVL(p_base_qty_var_amt,0) <> 0 THEN

      IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Call ap_funds_check to reverse out the ap p_base_qty_var_amt = '||p_base_qty_var_amt;
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      ap_funds_check (
                     p_txn_source         => 'AP VARIANCE',
                     p_acct_raw_cost      => p_base_qty_var_amt,
                     p_packet_id          => P_packet_id,
                     p_sys_ref2           => g_cdl_system_reference2,
                     p_sys_ref3           => g_cdl_system_reference3,
		     p_sys_ref5           => g_cdl_system_reference5, --REL12
		     p_adj_exp_item_id    => p_adj_exp_item_id,       --REL12
		     p_txn_interface_id   => p_txn_interface_id,      --REL12
		     p_fc_document_type   => p_fc_document_type,      --REL12
                     x_error_message_code => x_error_message_code,
                     x_error_stage        => x_error_stage,
                     x_return_status      => x_return_status);

   END IF; --IF NVL(p_base_qty_var_amt,0) <> 0 THEN


   IF NVL(p_base_amt_var_amt,0) <> 0 THEN

      IF PG_DEBUG = 'Y' THEN
         pa_debug.G_err_stage := 'Call ap_funds_check to reverse out the ap p_base_amt_var_amt = '||p_base_amt_var_amt;
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;

      ap_funds_check (
                     p_txn_source         => 'AP VARIANCE',
                     p_acct_raw_cost      => p_base_amt_var_amt,
                     p_packet_id          => P_packet_id,
                     p_sys_ref2           => g_cdl_system_reference2,
                     p_sys_ref3           => g_cdl_system_reference3,
		     p_sys_ref5           => g_cdl_system_reference5, --REL12
		     p_adj_exp_item_id    => p_adj_exp_item_id,       --REL12
		     p_txn_interface_id   => p_txn_interface_id,      --REL12
		     p_fc_document_type   => p_fc_document_type,      --REL12
                     x_error_message_code => x_error_message_code,
                     x_error_stage        => x_error_stage,
                     x_return_status      => x_return_status);

   END IF; --IF NVL(p_base_amt_var_amt,0) <> 0 THEN

   IF PG_DEBUG = 'Y' THEN
      log_message('log_message: ' || 'Returning from ap_po funds check');
   END IF;

   -- set the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   pa_cc_utils.reset_curr_function;

  EXCEPTION
   WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' Returning from ap po funds check');
       END IF;
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       pa_cc_utils.reset_curr_function;
       RAISE;
  END ap_po_funds_check;

  PROCEDURE Upd_PktSts_Fatal(p_request_id in number) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Inside Upd_PktSts_Fatal');
    END IF;

    update pa_bc_packets
    set status_code = 'T',
      result_code = 'F140'
    where status_code = 'P'
    and request_id = P_REQUEST_ID;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Updated ' || SQL%ROWCOUNT || ' packet statuses to T');
    END IF;

    commit;

  EXCEPTION

    WHEN OTHERS THEN
      --Bug 2672772
       rollback;
      IF PG_DEBUG = 'Y' THEN -- Printed for 3592289
         log_message('log_message: In others of UpdPktsts_Fatal');
      END IF;
      raise;

  END Upd_PktSts_Fatal;

  --Bug 2672772 : Added the below procedure to update the packet status to T
  --if NDF error occurs in ap_funds_check and po_funds_check
  PROCEDURE Upd_PktSts(p_packet_id in number) IS

    --PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Inside Upd_PktSts,packet_id = '|| p_packet_id);
    END IF;

    update pa_bc_packets
    set status_code = 'T',
      result_code = 'F140'
    where status_code = 'P'
    --Bug 3592289 changed p_packet_id to packet_id
    --and p_packet_id = p_packet_id;
    and packet_id = p_packet_id;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Updated ' || SQL%ROWCOUNT || ' packet statuses to T');
    END IF;

    --commit;

  EXCEPTION

    WHEN OTHERS THEN
      --Bug 2672772
      --rollback;
      IF PG_DEBUG = 'Y' THEN  -- Added 3 lines for 3592289
         log_message('log_message: In others of UpdPktsts');
      END IF;
      raise;

  END Upd_PktSts;

  PROCEDURE ValidateItemOTL(
               X_trx_src      IN VARCHAR2
            ,  X_ei_date      IN DATE
            ,  X_etype        IN VARCHAR2
            ,  X_nlr          IN VARCHAR2
            ,  X_qty          IN NUMBER
            ,  X_denom_raw_cost     IN NUMBER
            ,  X_module       IN VARCHAR2
            ,  X_trx_ref      IN VARCHAR2
            ,  X_match_flag   IN VARCHAR2
            ,  X_att_cat      IN VARCHAR2
            ,  X_att1         IN OUT NOCOPY VARCHAR2
            ,  X_att2         IN OUT NOCOPY VARCHAR2
            ,  X_att3         IN OUT NOCOPY VARCHAR2
            ,  X_att4         IN OUT NOCOPY VARCHAR2
            ,  X_att5         IN OUT NOCOPY VARCHAR2
            ,  X_att6         IN OUT NOCOPY VARCHAR2
            ,  X_att7         IN OUT NOCOPY VARCHAR2
            ,  X_att8         IN OUT NOCOPY VARCHAR2
            ,  X_att9         IN OUT NOCOPY VARCHAR2
            ,  X_att10        IN OUT NOCOPY VARCHAR2
            ,  X_system_linkage IN VARCHAR2
            ,  X_status       OUT NOCOPY VARCHAR2
            --,  X_bill_flag    OUT NOCOPY VARCHAR2
	        , X_denom_currency_code     IN OUT NOCOPY VARCHAR2
	        , X_acct_rate_date  	       IN OUT NOCOPY DATE
	        , X_acct_rate_type          IN OUT NOCOPY VARCHAR2
	        , X_acct_exchange_rate      IN OUT NOCOPY NUMBER
	        , X_acct_raw_cost           IN NUMBER
	        , X_project_currency_code   IN OUT NOCOPY VARCHAR2
            , X_Projfunc_currency_code  IN OUT NOCOPY VARCHAR2
            , X_Projfunc_cost_rate_date      IN OUT NOCOPY DATE
            , X_Projfunc_cost_rate_type      IN OUT NOCOPY VARCHAR2
            , X_Projfunc_cost_exchange_rate  IN OUT NOCOPY VARCHAR2
            , X_Assignment_Name           IN OUT NOCOPY VARCHAR2
            , X_Work_Type_Name            IN OUT NOCOPY VARCHAR2
            , P_project_id               IN NUMBER
            , P_task_id                  IN NUMBER
            , P_person_id                IN NUMBER
            , P_organization_id          IN NUMBER
            , P_assignment_id            IN NUMBER
            , P_work_type_id             IN NUMBER
            , P_Emp_Org_Id               IN NUMBER
            , P_Emp_Job_Id               IN NUMBER
            , P_po_header_id       IN NUMBER
            , P_po_line_id       IN NUMBER
            , P_person_type        IN VARCHAR2
            , P_po_price_type        IN VARCHAR2
		    , p_vendor_id			In Number	/* Bug# 3601024 : Vendor ID is not passed to the PA_EXPENDITURE_ITEMS_ALL.VENDOR_ID in OTL timecards  */
		   )
  IS

    temp_status      VARCHAR2(30) DEFAULT NULL;
    temp_bill_flag   VARCHAR2(1)  DEFAULT NULL;
    temp_msg_application VARCHAR2(50) := 'PA';
    temp_msg_type 	VARCHAR2(1) := 'E';
    temp_msg_token1  VARCHAR2(2000) := '';
    temp_msg_token2	VARCHAR2(2000) :='';
    temp_msg_token3	VARCHAR2(2000) :='';
    temp_msg_count	NUMBER :=1;

    dummy            NUMBER       DEFAULT NULL;

    l_project_rate_type  VARCHAR2(30) := NULL;

    l_projfunc_cost_rate_type VARCHAR2(30) := NULL;
    l_asgn_work_ret_sts       VARCHAR2(1);
    l_asgn_work_err_msg       VARCHAR2(1000);
    l_temp_g_assignment_id    number := null; -- bug 5297060

  BEGIN
    pa_cc_utils.set_curr_function('ValidateItemOTL');


    G_adj_item_id := NULL;
    G_job_id := NULL;


    X_status := NULL;

    G_project_id := P_Project_Id;
    G_task_id := P_Task_Id;
    G_Person_Id := P_Person_Id;

    G_Org_Id := P_Emp_Org_Id;

	G_Vendor_Id := P_Vendor_ID; /* Bug# 3601024 : Vendor ID is not passed to the PA_EXPENDITURE_ITEMS_ALL.VENDOR_ID in OTL timecards  */

    /*S.N. 5297060*/
    IF X_match_flag = 'N' THEN

         G_Assignment_Id := P_Assignment_Id;
         G_Work_Type_Id  := P_Work_Type_Id;

         G_Tp_Amt_Type_Code := pa_utils4.get_tp_amt_type_code(p_work_type_id => p_work_type_id);

    END IF;

    IF PG_DEBUG = 'Y' THEN
         log_message('log_message: G_Assignment_Id' ||G_Assignment_Id);
         log_message('log_message: G_Work_Type_Id' ||G_Work_Type_Id);
         log_message('log_message: G_Tp_Amt_Type_Code' ||G_Tp_Amt_Type_Code);
    END IF;

    /*E.N. 5297060*/

    IF ( G_Org_Id IS NULL ) THEN
       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_Stage := 'P_Emp_Org_Id is null';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;
       X_status := 'NO_ASSIGNMENT';
       pa_cc_utils.reset_curr_function;
       RETURN;
    END IF;

    IF (G_accounting_currency_code IS NULL) THEN
     GetImpCurrInfo;
    END IF;

    G_job_id := P_Emp_Job_Id;

    IF ( G_job_id IS NULL ) THEN
       X_status := 'NO_ASSIGNMENT';
       pa_cc_utils.reset_curr_function;
       RETURN;
    END IF;

    IF ( X_denom_currency_code IS NULL ) THEN

      X_denom_currency_code := G_accounting_currency_code;

    END IF;

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling GetProjCurrInfo';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    GetProjCurrInfo(G_task_id,
		X_project_currency_code,
		l_project_rate_type,
                X_projfunc_currency_code,
                l_projfunc_cost_rate_type);

    IF ( X_project_currency_code IS NULL ) THEN

    	X_status := 'PA_MISSING_PROJ_CURR';
        pa_cc_utils.reset_curr_function;
    	RETURN;

    END IF;

    IF ( X_projfunc_currency_code IS NULL ) THEN

        X_status := 'PA_MISSING_PRJFUNC_CURR';
        pa_cc_utils.reset_curr_function;
        RETURN;

    END IF;

/* Added the call to GetProjTypeInfo for getting the project type class for
 * bug#4903329 */
    IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling GetProjTypeInfo';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;


    GetProjTypeInfo( G_project_id,
                     G_Proj_bcost_flag,
                     G_project_type_class,
                     G_burden_amt_display_method,
                     G_Total_Burden_Flag ) ;
/* Ends changes for bug#4903329 */

    -- ===========================================================================
    --   Verify that the transaction has not already been loaded into PA (no
    --   other expenditure items exist having the same TRANSACTION SOURCE and
    --   ORIG TRANSACTION REFERENCE)

    IF G_allow_dup_flag <>  'Y' THEN

       IF PG_DEBUG = 'Y' THEN
       pa_debug.G_err_stage := 'Calling CheckDupItem';
          log_message('log_message: ' || pa_debug.G_err_Stage);
       END IF;
       CheckDupItem ( X_trx_src, X_trx_ref, temp_status );
       IF ( temp_status IS NOT NULL ) THEN
         X_status := temp_status;
         pa_cc_utils.reset_curr_function;
         RETURN;
       END IF;

    END IF ;

    -- ===========================================================================
    --  Oracle Time and Labor(OTL)requires the ability to reverse an ei with a quantity = 0
    --  so only for OTL that option has been added.
    --
    IF  ( ( X_qty < 0    and    X_match_flag = 'N' ) OR
          ( X_match_flag = 'N' and X_trx_src = 'ORACLE TIME AND LABOR' ) ) THEN
      IF PG_DEBUG = 'Y' THEN
      pa_debug.G_err_stage := 'Calling pa_adjustments.VerifyOrigItem';
         log_message('log_message: ' || pa_debug.G_err_Stage);
      END IF;
      G_adj_item_id := pa_adjustments.VerifyOrigItem(
                X_person_id => G_person_id
              , X_org_id => G_org_id
              , X_item_date => X_ei_date
              , X_task_id => G_task_id
              , X_exp_type => X_etype
              , X_system_linkage_function => X_system_linkage
              , X_nl_org_id => NULL
              , X_nl_resource => X_nlr
              , X_quantity => X_qty
              , X_denom_raw_cost => X_denom_raw_cost
              , X_trx_source => X_trx_src
              , X_denom_currency_code => X_denom_currency_code
              , X_acct_raw_cost => X_acct_raw_cost
              , X_reversed_orig_txn_reference => G_reversed_orig_txn_reference);

      IF ( G_adj_item_id IS NULL ) THEN

        X_status := 'NO_MATCHING_ITEM';
        pa_cc_utils.reset_curr_function;
        RETURN;

      ELSIF ( G_adj_item_id IS NOT NULL  AND   X_module = 'PAXTRTRX' ) THEN

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Calling pa_adjustments.ExpAdjItemTab';
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;
        pa_adjustments.ExpAdjItemTab(G_adj_item_id) := G_adj_item_id;

        IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'Locking adjusting item:'||to_char(G_adj_item_id);
           log_message('log_message: ' || pa_debug.G_err_Stage);
        END IF;

        BEGIN

          SELECT
                  expenditure_item_id
            INTO
                  dummy
            FROM
                  pa_expenditure_items
           WHERE
                  expenditure_item_id = G_adj_item_id
          FOR UPDATE NOWAIT;

        EXCEPTION
          WHEN  RESOURCE_BUSY  THEN
            temp_status := 'CANNOT_LOCK_ORIG_ITEM';
        END;
      END IF;

      IF ( temp_status IS NOT NULL ) THEN
        X_status := temp_status;
        pa_cc_utils.reset_curr_function;
        RETURN;
      END IF;

    END IF;

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling PA_UTILS2.GetPrjOrgId';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;
    G_RecvrOrgId := PA_UTILS2.GetPrjOrgId(p_project_id => G_project_id,
                                          p_task_id    => NULL);

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling API to derive/validate assignment and work type info';
       log_message('log_message: ' || pa_debug.G_err_Stage);
       log_message('log_message: ' || 'Assignment Name = ' || X_Assignment_Name || ' Work Type Name = ' || X_Work_Type_Name);
    END IF;

    /*S.N. 5297060*/
    If ( X_match_flag <> 'N' )  THEN

         pa_utils4.get_work_assignment(
	          p_person_id          => G_Person_Id
            , p_project_id         => G_Project_Id
            , p_task_id            => G_Task_Id
            , p_ei_date            => X_Ei_Date
            , p_system_linkage     => x_system_linkage
            , x_assignment_id      => G_Assignment_Id
            , x_assignment_name    => X_Assignment_Name
            , x_work_type_id       => G_Work_Type_Id
            , x_work_type_name     => X_Work_Type_Name
            , x_tp_amt_type_code   => G_Tp_Amt_Type_Code
            , x_return_status      => l_asgn_work_ret_sts
            , x_error_message_code => l_asgn_work_err_msg);

         IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'Assignment Id = ' || G_Assignment_Id ||
                                             ' Work Type Id = ' || G_Work_Type_Id ||
                                             ' Tp Amt Type = '  || G_Tp_Amt_Type_Code);
         END IF;

         IF (l_asgn_work_ret_sts <> FND_API.G_RET_STS_SUCCESS) THEN

              IF PG_DEBUG = 'Y' THEN
                   pa_debug.G_err_stage := 'Get Work Type and Assignment API failed';
                   log_message('log_message: ' || pa_debug.G_err_Stage);
                   log_message('log_message: ' || 'Ret Sts = ' || l_asgn_work_ret_sts || ' Error = ' || l_asgn_work_err_msg);
              END IF;

              X_Status := l_asgn_work_err_msg;
              pa_cc_utils.reset_curr_function;
              RETURN;

         END IF;

    END IF; -- ( X_match_flag <> 'N' )
    /*E.N. 5297060*/

    G_CrossChargeCode := 'P';
    G_BrowLentDistCode := 'X';
    G_IcProcessed_Code := 'X';
    l_temp_g_assignment_id := G_Assignment_Id; -- bug 5297060

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Calling patc client extension for override to assignment id';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    patcx.tc_extension( X_project_id => g_project_id
                      , X_task_id => g_task_id
                      , X_expenditure_item_date => X_ei_date
                      , X_expenditure_type => X_etype
                      , X_non_labor_resource => X_nlr
                      , X_incurred_by_person_id => g_person_id
                      , X_quantity => X_qty
                      , X_denom_currency_code => X_denom_currency_code
                      , X_acct_currency_code => G_accounting_currency_code
                      , X_denom_raw_cost => X_denom_raw_cost
                      , X_acct_raw_cost => X_acct_raw_cost
                      , X_acct_rate_type => X_acct_rate_type
                      , X_acct_rate_date => X_acct_rate_date
                      , X_acct_exchange_rate => X_acct_exchange_rate
                      , X_transferred_from_id => NULL
                      , X_incurred_by_org_id => G_org_id
                      , X_nl_resource_org_id => NULL
                      , X_transaction_source => X_trx_src
                      , X_calling_module => X_module
                      , X_vendor_id => NULL
                      , X_entered_by_user_id => G_user
                      , X_attribute_category => X_att_cat
                      , X_attribute1 => X_att1
                      , X_attribute2 => X_att2
                      , X_attribute3 => X_att3
                      , X_attribute4 => X_att4
                      , X_attribute5 => X_att5
                      , X_attribute6 => X_att6
                      , X_attribute7 => X_att7
                      , X_attribute8 => X_att8
                      , X_attribute9 => X_att9
                      , X_attribute10 => X_att10
                      , X_attribute11 => NULL
                      , X_attribute12 => NULL
                      , X_attribute13 => NULL
                      , X_attribute14 => NULL
                      , X_attribute15 => NULL
                      , X_msg_application => temp_msg_application
                      , X_billable_flag => temp_bill_flag
                      , X_msg_type => temp_msg_type
                      , X_msg_token1 => temp_msg_token1
                      , X_msg_token2 => temp_msg_token2
                      , X_msg_token3 => temp_msg_token3
                      , X_msg_count => temp_msg_count
                      , X_outcome => temp_status
                      , p_projfunc_currency_code   => x_projfunc_currency_code
                      , p_projfunc_cost_rate_type  => x_projfunc_cost_rate_type
                      , p_projfunc_cost_rate_date  => x_projfunc_cost_rate_date
                      , p_projfunc_cost_exchg_rate => X_Projfunc_cost_exchange_rate
                      , x_assignment_id            => G_ASSIGNMENT_ID
                      , p_work_type_id             => g_work_type_id
                      , p_sys_link_function        => x_system_linkage
                      , p_po_header_id  =>  p_po_header_id /* cwk */
                      , p_po_line_id => p_po_line_id
                      , p_person_type => p_person_type
                      , p_po_price_type => p_po_price_type );

    -- No change to Billable Flag here, use what is inserted into the interface table
          X_status := temp_status; -- Added for bug#6278593
    /*S.N. 5297060  The patcx extension parameter x_assignment_id is IN OUT so the value can change
                    for assignment_id.  To handle this we will use a dummy assigment id to hold the value
                    and reset the value back if the transaction is a reversal. */
    If X_match_flag = 'N' Then
         G_assignment_id := l_temp_g_assignment_id;
    End If;
    /*E.N. 5297060*/

    pa_cc_utils.reset_curr_function;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || pa_debug.G_err_Stack,1);
          log_message('log_message: ' || pa_debug.G_err_stage,1);
          log_message('log_message: ' || SQLERRM,1);
       END IF;
       pa_cc_utils.reset_curr_function;
       RAISE ;
  END  ValidateItemOTL;

  PROCEDURE Log_Message(p_message in VARCHAR2,
                        p_mode    in NUMBER DEFAULT 0) IS
  BEGIN
    If (G_Debug_Mode = 'Y') Then

       pa_cc_utils.log_message(p_message,p_mode);

    End If;
  END Log_Message;

PROCEDURE init_po_amt_chk IS

BEGIN

  PoLineTaskTab.DELETE;
  PoAmtTab.DELETE;

END init_po_amt_chk;

PROCEDURE  release_po_line_task_lock IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_lock_status     NUMBER         := -1;
BEGIN

  IF PoLineTaskTab.COUNT > 0 THEN
     FOR i IN PoLineTaskTab.FIRST..PoLineTaskTab.LAST
     LOOP
     BEGIN

       l_lock_status := -1;
       l_lock_status :=  Pa_Debug.Release_User_Lock(PoLineTaskTab(i));

       IF (l_lock_status = 0) THEN
           IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'RELEASE_PO_LINE_TASK_LOCK : Released Lock for : '||PoLineTaskTab(i);
              log_message('log_message: ' || pa_debug.G_err_stage,1);
           END IF;
       ELSE
           IF PG_DEBUG = 'Y' THEN
              pa_debug.G_err_stage := 'RELEASE_PO_LINE_TASK_LOCK : Failed To Release Lock for : '||PoLineTaskTab(i);
              log_message('log_message: ' || pa_debug.G_err_stage,1);
           END IF;
       END IF;

     EXCEPTION
     WHEN OTHERS THEN

     IF PG_DEBUG = 'Y' THEN
        pa_debug.G_err_stage := 'RELEASE_PO_LINE_TASK_LOCK : In Process of Releasing Locks : ' ||SQLERRM;
        log_message('log_message: ' || pa_debug.G_err_stage,1);
     END IF;

     END ;

     END LOOP;

   END IF ;

END release_po_line_task_lock;

/*
 API Decs : Retrieving rate from PO for the PO_LINE_ID And PO_PRICE_TYPE for CWK related Time Card EIs.
*/

Function GET_PO_PRICE_TYPE_RATE (p_project_id In Number, p_task_id In Number, P_Po_Line_Id In Number, P_Price_Type In Varchar2) Return Number
Is

	x_po_rate			NUMBER	;
	x_currency_code     VARCHAR (15) ;
	x_curr_rate_type    VARCHAR (30) ;
	x_curr_rate_date    DATE	;
	x_currency_rate     NUMBER	;
	x_vendor_id         NUMBER	;
	x_return_status     VARCHAR2(100) ;
	x_message_code      VARCHAR2(100) ;

Begin


	PO_PA_INTEGRATION_GRP.get_line_rate_info(   p_api_version    => 1.0 ,
											    p_price_type     => p_price_type ,
						                        p_po_line_id     => p_po_line_id ,
										        p_project_id     => p_project_id ,
				                                p_task_id        => p_task_id ,
								                x_po_rate        => x_po_rate ,
				                                x_currency_code  => x_currency_code  ,
				                                x_curr_rate_type => x_curr_rate_type ,
									            x_curr_rate_date => x_curr_rate_date ,
					                            x_currency_rate  => x_currency_rate ,
									            x_vendor_id      => x_vendor_id ,
					                            x_return_status  => x_return_status ,
									            x_message_code   => x_message_code
				                            );

	Return ( x_po_rate );

End GET_PO_PRICE_TYPE_RATE ;

  PROCEDURE ap_cash_based_funds_check (
          p_txn_source            IN VARCHAR2,
          p_acct_raw_cost         IN NUMBER,
          p_packet_id             IN NUMBER,
          p_sys_ref2              IN NUMBER,        --REL12
          p_sys_ref4              IN VARCHAR2,        --REL12
	  p_sys_ref5              IN NUMBER,        --REL12
	  p_adj_exp_item_id       IN NUMBER,        --REL12
	  p_txn_interface_id      IN NUMBER,        --REL12
	  p_fc_document_type      IN VARCHAR2,      --REL12
          x_error_message_code    OUT NOCOPY VARCHAR2,
          x_error_stage           OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY VARCHAR2) IS

    l_raw_amount              NUMBER;

    Procedure GetCommSummAmt( p_ap_pkt_raw_amt  OUT NOCOPY NUMBER) Is

         l_pkt_summ                NUMBER;
         l_com_summ                NUMBER;
	 l_ap_outstanding_raw      NUMBER;
	 l_pay_inv_dist_amt        NUMBER;
	 -- R12 AP lines uptake : Prepayment changes
	 l_cmt_pkt_found           VARCHAR2(1) := 'N';
	 l_disc_amount             NUMBER ;

     -- Below cursors calcultes Raw and Burden outstanding amount associated with AP Invoice Distribution.

     -- Fetch BC Pkt Raw outstanding amount
     CURSOR C_get_raw_pkt_amt IS
     select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
       from pa_bc_packets bcc
      where bcc.document_type = 'AP'
        and bcc.document_header_id = p_sys_ref2
        and bcc.document_distribution_id = p_sys_ref5
        and ( (bcc.Status_Code in('A','C'))
		 or
	      (bcc.Status_Code = 'P' and bcc.request_id = G_Request_Id))
        and bcc.Parent_Bc_Packet_Id is NULL;

     CURSOR C_get_raw_bccmt_amt IS
     select sum(nvl(accounted_dr,0)-nvl(accounted_cr,0))
       from pa_bc_commitments bcc
      where bcc.document_type = 'AP'
        and bcc.document_header_id = p_sys_ref2
        and bcc.document_distribution_id = p_sys_ref5
        and  bcc.Parent_Bc_Packet_Id is NULL;

     -- ====================================================================================
     --
     -- Bug : 4962731
     --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
     --       For payments, payment amount includes discount amount. So we are interfacing
     --       only payments. But we need to relieve corresponding invoice amount for that
     --       payment.
     --       Invoice dist amount :100
     --                  Payment  : 80
     --                  Disc     : 20
     --          Actual interface : 80
     --          AP Relieve       : 80 + 20 = 100
     -- Functionality :
     --       Discount is applicable when discount method is EXPENSE
     --       Discount is applicable for tax distributions  when discount method is TAX
     --       Discount is not applicable when discount method is 'SYSTEM'
     --       Discount is also based on the discount profile start date
     --       ap payment record includes the discount amount and we do not need to interface
     --       discount record because we are interfacing the payments.
     --       But we need to relieve corresponding inv dist amount paid to relieve the ap commitment amount.
     --       ap amount to relieve := payment amunt + discount amount (when applicable).
     -- ====================================================================================
     CURSOR c_get_disc_amount is
          SELECT  NVL(b.invoice_dist_base_amount , b.invoice_dist_amount) amount
	    from ap_payment_hist_dists b,
	         ap_invoice_distributions_all apd
	   where b.invoice_payment_id      = p_sys_ref4
	     and b.invoice_distribution_id = p_sys_ref5
	     and b.pay_dist_lookup_code    = 'DISCOUNT'
	     and apd.invoice_distribution_id = b.invoice_distribution_id
	     and NVL(apd.historical_flag,'N')       <> 'Y'
	     and apd.expenditure_item_date  >=G_Profile_Discount_Start_date
	     and apd.line_type_lookup_code  = decode ( G_discount_Method,
	                                                            'TAX', decode (apd.line_type_lookup_code,
                                                                                                      'TIPV', 'TIPV',
												      'TERV','TERV',
												      'TRV', 'TRV',
												      'NONREC_TAX') ,
	                                                            'SYSTEM', 'NOT APPLICABLE',
								     apd.line_type_lookup_code ) ;
     -- AP Invoice dist amount to be relieved for payment with ERV
     CURSOR   C_payment_erv_amount IS
     SELECT   NVL(paydist.invoice_dist_base_amount,paydist.invoice_dist_amount)
       FROM   ap_payment_hist_dists Paydist
      WHERE   paydist.pay_dist_lookup_code = 'CASH'
        AND   Paydist.invoice_distribution_id = p_sys_ref5
        AND   PayDIST.invoice_payment_id = p_sys_ref4
        AND   EXISTS
	        (SELECT 1
                   FROM ap_invoice_payments Pay,
		        ap_invoices_all inv
                  WHERE pay.invoice_payment_id   = p_sys_ref4
		    AND pay.invoice_id           =  inv.invoice_id
		    AND NVL(pay.exchange_rate,0) <> NVL(inv.exchange_rate,0));

     Begin
        -- Intializing Variables
        l_pkt_summ            := 0;
        l_com_summ            := 0;
	p_ap_pkt_raw_amt      := 0;
	l_pay_inv_dist_amt    := 0;
	l_disc_amount         := 0 ;

	-- Fetching applicable discount amount absed on the discount method and profile discount start date.
        --
        -- Bug : 4962731
        --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
        --
	OPEN  c_get_disc_amount ;
	fetch c_get_disc_amount into l_disc_amount ;
	close c_get_disc_amount ;
	l_disc_amount := NVL(l_disc_amount,0) ;

        -- Fetching outstanding AP Distribution Raw amount
	OPEN   C_get_raw_pkt_amt ;
        FETCH  C_get_raw_pkt_amt INTO l_pkt_summ;
	-- R12 AP lines uptake : Prepayment changes
	IF C_get_raw_pkt_amt%FOUND THEN
	  l_cmt_pkt_found := 'Y';
        END IF;
	CLOSE  C_get_raw_pkt_amt;

	OPEN   C_get_raw_bccmt_amt ;
        FETCH  C_get_raw_bccmt_amt INTO l_com_summ;
	-- R12 AP lines uptake : Prepayment changes
	IF C_get_raw_bccmt_amt%FOUND THEN
	  l_cmt_pkt_found := 'Y';
        END IF;
	CLOSE  C_get_raw_bccmt_amt;

        -- Calculating total Outstanding raw amount on AP dist
	l_ap_outstanding_raw := nvl(l_pkt_summ,0) + nvl(l_com_summ,0) ;

       -- R12 AP lines uptake : Prepayment changes
       -- Donot relieve commitment amount for records which have no entry in bc_commitments/bc_packets .
       -- These records were not Fundschecked (eg : pre-payment application , pre-payment matched to PO ..)

       IF l_cmt_pkt_found = 'N' THEN

	   p_ap_pkt_raw_amt := 0;

       ELSIF l_cmt_pkt_found = 'Y' THEN

        -- Below code populates l_pay_inv_dist_amt  with AP raw amount to be relieved against payments having ERV .
	-- If no ERV for payment then l_pay_inv_dist_amt = p_acct_raw_cost

        OPEN  C_payment_erv_amount;
        FETCH C_payment_erv_amount INTO l_pay_inv_dist_amt;
	IF C_payment_erv_amount%NOTFOUND THEN
	   l_pay_inv_dist_amt := P_acct_raw_cost;
        END IF;
        CLOSE C_payment_erv_amount;


        --
        -- Bug : 4962731
        --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
        --
	l_pay_inv_dist_amt := l_pay_inv_dist_amt + l_disc_amount ;

        -- If final payment relieve outstanding amount .
	-- Note : For refund final payment zero outstanding amount will be reserved
        IF NVL(G_finalPaymentID,-99) = NVL(p_sys_ref4,-99) THEN
	   p_ap_pkt_raw_amt := -1 * l_ap_outstanding_raw;

        -- If postive payment and not a final payment then relieve MIN(outstanding amount,payment amount)
        ELSIF l_pay_inv_dist_amt >0 THEN
	   IF l_pay_inv_dist_amt >= l_ap_outstanding_raw THEN
	      p_ap_pkt_raw_amt := -1 * l_ap_outstanding_raw;
           ELSE
	      p_ap_pkt_raw_amt := -1 * l_pay_inv_dist_amt;
           END IF;

        -- If negative payment and not a final payment then reserve payment amount
	ELSIF l_pay_inv_dist_amt < 0 THEN
	      p_ap_pkt_raw_amt := -1 * l_pay_inv_dist_amt;
        END IF;

      END IF; --IF l_cmt_pkt_found = 'N' THEN

     Exception
        When Others Then
             Raise;

      End GetCommSummAmt;

  BEGIN

    pa_cc_utils.set_curr_function('ap_funds_check');

    IF PG_DEBUG = 'Y' THEN
    pa_debug.G_err_stage := 'Inside AP_Funds_Check';
       log_message('log_message: ' || pa_debug.G_err_Stage);
    END IF;

    -- Calling GetCommSummAmt to calculate AP distribution's raw and burden amount to be relieved/reserved.
    GetCommSummAmt(p_ap_pkt_raw_amt  => l_raw_amount);

    insert_cash_ap_bc_packets(   p_packet_id         => p_packet_id,
                            p_sys_ref2         => p_sys_ref2,
                            p_sys_ref5         => p_sys_ref5,
                            p_acct_raw_cost    => p_acct_raw_cost,
                            p_fc_document_type => p_fc_document_type ,
                            p_txn_source       => p_txn_source   ,
                            p_adj_exp_item_id  => p_adj_exp_item_id,
			    p_txn_interface_id => p_txn_interface_id,
			    p_cash_pay_to_relieve => l_raw_amount   );


    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'Returning from ap funds check');
    END IF;

    -- set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_cc_utils.reset_curr_function;

  EXCEPTION
    --Bug 2672772: Handle the NDF exception,
    --raise the error here but not in tr_import_funds_check
    WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' In NDF: Returning from ap funds check');
       END IF;

    WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || sqlerrm||' Returning from ap funds check');
       END IF;
       x_return_status  := fnd_api.g_ret_sts_unexp_error;
       pa_cc_utils.reset_curr_function;
       RAISE;
  END ap_cash_based_funds_check;

-- R12 funds management Uptake : New procedure fired in non-autonomous mode to read
-- pa_transaction_interface_all table and to derive variables which drives the
-- relieving/reserving of commitments and actuals flow  during interface.

PROCEDURE insert_ap_bc_packets(p_packet_id             IN NUMBER,
                               p_sys_ref2              IN NUMBER,
  			       p_sys_ref4              IN VARCHAR2,
                               p_sys_ref5              IN NUMBER,
                               p_acct_raw_cost         IN NUMBER,
                               p_acct_bur_cost         IN NUMBER,
                               p_fc_document_type      IN VARCHAR2,
                               p_txn_source            IN VARCHAR2,
                               p_adj_exp_item_id       IN NUMBER,
		    	       p_txn_interface_id      IN NUMBER) IS

-- Cursor to fetch data from pa_transaction_interface_table.This data is later used
-- in autonomous fundscheck insert_ap_bc_pkts_autonomous procedure.


 CURSOR c_pa_txn_interface_data (p_adj_act_fc_req VARCHAR2,
                                 p_act_fc_req  VARCHAR2) IS
 Select txn.Project_Id
        ,txn.Task_Id
        ,txn.Expenditure_Type
        ,txn.Expenditure_Item_Date
        ,nvl(txn.OVERRIDE_TO_ORGANIZATION_ID,txn.Org_Id)
        ,bv.Budget_Version_Id
	-- R12 AP lines uptake : Prepayment changes
	-- For Prepayment application/pre-payment matched to PO records consider p_acct_raw_cost as amount
        ,DECODE(txn_interface_id,p_txn_interface_id, p_acct_raw_cost,txn.acct_raw_cost)
        ,0
        ,DECODE(txn_interface_id,p_txn_interface_id, p_acct_raw_cost,txn.acct_raw_cost)
        ,0
        ,txn.cr_code_combination_id
        ,txn.Org_id
        ,txn.txn_interface_id  --REL12
  From  Pa_Budget_Versions bv,
        Pa_Budget_Types bt,
        pa_budgetary_control_options pbct,
	pa_transaction_interface_all txn
 Where  bv.budget_type_code = bt.budget_type_code
   and  bt.budget_amount_code = 'C'
   and  bv.current_flag = 'Y'
   AND  pbct.project_id = bv.project_id
   AND  pbct.BDGT_CNTRL_FLAG = 'Y'
   AND  pbct.BUDGET_TYPE_CODE = bv.budget_type_code
   AND (pbct.EXTERNAL_BUDGET_CODE = 'GL'
        OR
        pbct.EXTERNAL_BUDGET_CODE is NULL
        )
   AND  bv.project_id = txn.project_id
   AND  txn.txn_interface_id in ( SELECT txn1.txn_interface_id
                                   FROM pa_transaction_interface_all txn1
 				   WHERE txn1.TRANSACTION_SOURCE = p_txn_source -- Condition for using index
				   -- new index usage needs to be verified for below columns
                                     AND txn1.cdl_system_reference2 = p_sys_ref2
                                     AND txn1.cdl_system_reference5 = p_sys_ref5
                                     AND txn1.fc_document_type in ('ACT','ALL')
	                             AND txn1.adjusted_expenditure_item_id IS NOT NULL
				     AND p_adj_act_fc_req = 'Y'
                                UNION ALL -- R12 AP lines uptake : Prepayment changes : Added to pick current transaction for prepayment scenarios
				  SELECT p_txn_interface_id
				    FROM DUAL
                                   WHERE p_act_fc_req  = 'Y');

l_comm_fc_req             VARCHAR2(1);  -- Variable to identify whether commitment fundscheck is required
l_act_fc_req              VARCHAR2(1);  -- Variable to identify whether actual fundscheck is required
l_adj_act_fc_req          VARCHAR2(1);  -- Variable to identify whether adjusted actual fundscheck is required


BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_bc_packets - Start');
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_packet_id '||p_packet_id);
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_sys_ref2  '||p_sys_ref2 );
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_sys_ref4  '||p_sys_ref4 );
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_sys_ref5  '||p_sys_ref5 );
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_acct_raw_cost '||p_acct_raw_cost);
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_acct_bur_cost '||p_acct_bur_cost);
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_fc_document_type  '||p_fc_document_type );
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_txn_source '||p_txn_source);
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_adj_exp_item_id '||p_adj_exp_item_id);
       log_message('log_message: ' || 'In insert_bc_packets - Value of p_txn_interface_id '||p_txn_interface_id);

    END IF;

    -- Code to derive values for variables which will decide the flow of this procedure

    l_comm_fc_req :='N';        -- Variable to identify whether commitment fundscheck is required
    l_act_fc_req :='N';         -- Variable to identify whether actual fundscheck is required
    l_adj_act_fc_req:='N';      -- Variable to identify whether adjusted actual fundscheck is required

    IF  p_adj_exp_item_id IS NULL THEN

        IF p_fc_document_type ='ALL' THEN  --ap normal lines import
           l_comm_fc_req := 'Y' ;
           l_act_fc_req  := 'Y' ;
        ELSIF p_fc_document_type ='ACT' OR p_txn_source = 'AP DISCOUNTS' THEN --ap discounts lines import
            l_act_fc_req  := 'Y' ;
        END IF;

    ELSIF p_adj_exp_item_id IS NOT NULL THEN

        IF p_fc_document_type ='ALL' THEN    --ap invoice having fc enabled and adjusted ei's having fc enabled
           l_comm_fc_req := 'Y' ;
           l_adj_act_fc_req := 'Y';
        ELSIF p_fc_document_type ='CMT' THEN --ap invoice having fc enabled and adjusted ei's having fc disabled
           l_comm_fc_req := 'Y' ;
        ELSIF p_fc_document_type ='ACT' THEN --ap invoice having fc disabled and adjusted ei's having fc ENabled
           l_adj_act_fc_req := 'Y';
        END IF;

    END IF;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_bc_packets - Value of l_comm_fc_req '||l_comm_fc_req);
       log_message('log_message: ' || 'In insert_bc_packets - Value of l_adj_act_fc_req   '||l_adj_act_fc_req  );
       log_message('log_message: ' || 'In insert_bc_packets - Value of l_act_fc_req  '||l_act_fc_req );
    END IF;

    -- Cursor to fetch data from pa_transaction_interface_table.This data is later used
    -- in autonomous fundscheck insert_ap_bc_pkts_autonomous procedure.

    IF ( l_adj_act_fc_req = 'Y'  OR l_act_fc_req  = 'Y' ) THEN

       -- call to clean up global plsql arrays used for storing interface data.
       init_xface_plsql_tables;

       OPEN c_pa_txn_interface_data(l_adj_act_fc_req ,l_act_fc_req);
       FETCH c_pa_txn_interface_data BULK COLLECT INTO
                                          g_xface_project_id_tbl,
					  g_xface_task_id_tbl,
					  g_xface_exp_type_tbl,
					  g_xface_ei_date_tbl,
					  g_xface_exp_org_id_tbl,
					  g_xface_bud_ver_id_tbl,
					  g_xface_Entered_Dr_tbl,
					  g_xface_Entered_Cr_tbl,
					  g_xface_acct_Dr_tbl,
				          g_xface_acct_Cr_tbl,
					  g_xface_Txn_Ccid_tbl,
					  g_xface_org_id_tbl,
					  g_xface_Txn_interface_tbl;
       CLOSE c_pa_txn_interface_data;

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'In insert_bc_packets - # of recs fetched from interface table c_pa_txn_interface_data = '||g_xface_Txn_interface_tbl.count);
       END IF;

    END IF; --IF ( l_adj_act_fc_req = 'Y'  OR l_act_fc_req  = 'Y' ) THEN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_bc_packets - calling insert_ap_bc_pkts_autonomous');
    END IF;

    insert_ap_bc_pkt_autonomous
                           (p_packet_id             => p_packet_id,
                            p_sys_ref2              => p_sys_ref2,
			    p_sys_ref4              => p_sys_ref4,
                            p_sys_ref5              => p_sys_ref5,
                            p_acct_raw_cost         => p_acct_raw_cost,
                            p_acct_bur_cost         => p_acct_bur_cost,
                            p_fc_document_type      => p_fc_document_type,
                            p_txn_source            => p_txn_source,
                            p_adj_exp_item_id       => p_adj_exp_item_id ,
			    p_txn_interface_id      => p_txn_interface_id,
			    p_comm_fc_req           => l_comm_fc_req,
                            p_act_fc_req            => l_act_fc_req,
                            p_adj_act_fc_req        => l_adj_act_fc_req );

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_bc_packets - End');
    END IF;

EXCEPTION
WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
      log_message('log_message:I n insert_bc_packets exception' || sqlerrm||' Returning from insert_bc_packets');
   END IF;
   RAISE;
END insert_ap_bc_packets;

-- This procedure inserts records into pa_bc_packets for relieving commitment raw and burden
-- and also for reserving raw and burden against actual.
-- 1. IF p_fc_document_type = 'CMT'/'ALL' then we need to relieve commitment amount.
-- 2. If commitment exists in pa_bc_commitments (i.e. sweeper process if run) then
--      insert records into pa_bc_packets to relieve the raw and burden commitment
--      amounts lying in pa_bc_commitments.
--    else
--      insert records into pa_bc_packets to relieve the raw and burden commitment
--      amounts lying in pa_bc_packets.
--    end if;
-- 3.p_document type = 'ALL' and p_adj_exp_item_id IS NULL implies its a regular
--   Payable Invoice getting interfaced to Projects. In this case
--      insert records into pa_bc_packets to reserve actual raw cost amount which is equal to
--      commitment amount in pa_bc_commitments relieved in step 2.
--      Note : parent_bc_packet_id is populated to -1 such that pa_funds_check process will
--             generate burden against this actual based on latest compiled set id.
-- 4.If p_document type = 'ACT'/'ALL' and p_adj_exp_item_id IS NOT NULL then it implies thats its a
--   reversing/cancelled Payable Invoice getting interfaced to Projects and original
--   interfaced exp in project has been adjusted .
--   In this case insert records into pa_bc_packets to fundscheck actual raw cost which is equal to
--      amount in pa_transaction_interface for each non net zero expenditures associated with this
--      invoice.
--      Note : In this scenraio if non net zero expenditures associated with this invoice are not costed
--             then import process (PAAPIMPB.pls) will reject the transactions with PA_EI_NOT_COST_DISTRIBUTED.
--             Hence the ind_compiled_set_id on original exp's will always be the latest ,so parent_bc_packet_id
--             is populated to -1 such that pa_funds_check process will generate burden against this
--             actual based on latest compiled set id.

PROCEDURE INSERT_AP_BC_PKT_AUTONOMOUS
                           (p_packet_id             IN NUMBER,
                            p_sys_ref2              IN NUMBER,
			    p_sys_ref4              IN VARCHAR2,
                            p_sys_ref5              IN NUMBER,
                            p_acct_raw_cost         IN NUMBER,
                            p_acct_bur_cost         IN NUMBER,
                            p_fc_document_type      IN VARCHAR2,
                            p_txn_source            IN VARCHAR2,
                            p_adj_exp_item_id       IN NUMBER,
			    p_txn_interface_id      IN NUMBER,
			    p_comm_fc_req           IN VARCHAR2,
                            p_act_fc_req            IN VARCHAR2,
                            p_adj_act_fc_req        IN VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_gen_raw_bc_pkt IS
SELECT Pa_Bc_Packets_s.NextVal
  FROM dual;

CURSOR c_get_po_dist_id IS
SELECT po_distribution_id
  FROM ap_invoice_distributions
 WHERE invoice_id = p_sys_ref2
   AND invoice_distribution_id = p_sys_ref5;

CURSOR c_get_po_LINE_id (p_po_dist_id NUMBER) IS
SELECT po_line_id
  FROM po_distributions_all
 WHERE po_distribution_id = p_po_dist_id;

-- R12 Funds Management : This cursor can fetches both Raw and Burden Lines for commitment
-- to be relieved.
-- Note : This cursor can fetch more than one raw record for Quantity/amount variance scenarios.
-- In this case QTY/Amount variance are stroed on same ITEM distributions , but there will be 2
-- bc records one for item amout and other for quantity/amount variance

Cursor C_Ap_Commitment Is
Select bcc.Set_Of_Books_Id
       ,bcc.Period_Year
       ,bcc.Project_Id
       ,bcc.Task_Id
       ,bcc.Expenditure_Type
       ,bcc.Expenditure_Item_Date
       ,bcc.Expenditure_Organization_Id
       ,bcc.Budget_Version_Id
       ,bcc.budget_line_id  -- R12 Funds Management uptake
       ,bcc.Document_Type
       ,bcc.Document_Header_Id
       ,bcc.Document_Distribution_Id
       ,bcc.Entered_Cr
       ,bcc.Entered_Dr
       ,bcc.Accounted_Cr
       ,bcc.Accounted_Dr
       ,bcc.Actual_Flag
       ,bcc.Txn_Ccid
       ,bcc.Je_Category_Name
       ,bcc.Je_Source_Name
       ,bcc.Org_Id
       ,bcc.Pa_Date
       ,bcc.bc_packet_id
       ,bcc.packet_id
       ,bcc.parent_bc_packet_id
       ,bcc.encumbrance_type_id
       ,bcc.document_header_id_2
       ,bcc.document_distribution_type
 From  Pa_Bc_Commitments_all bcc
Where  bcc.Document_Header_Id = p_sys_ref2
  and  bcc.Document_Distribution_Id =p_sys_ref5
  --PA-J Receipt accrual changes
  and  bcc.document_type = 'AP'
  and bcc.exp_item_id IS NULL -- Bug 5014138 : to pick just the encumbrance record
  and bcc.actual_flag = 'E' -- Bug 5014138 : to pick just the encumbrance record
  -- Bug 5550268 : For variance we should be picking just the variance records
  /* Bug 5560524 : Modified the following condition such that the burden commitment relieving record is also
                   fetched for 'AP VARIANCE' transaction source. */
  and ((nvl(bcc.accounted_dr,0)-nvl(bcc.accounted_cr,0) = p_acct_raw_cost
        and p_txn_source = 'AP VARIANCE' and bcc.parent_bc_packet_id is null)
        OR
        p_txn_source <> 'AP VARIANCE'
	OR
        (bcc.parent_bc_packet_id is NOT null AND  p_txn_source = 'AP VARIANCE')
	);



-- R12 Funds Management : This cursor can fetches both Raw and Burden Lines for commitment
-- to be relieved.
-- Note : This cursor can fetch more than one raw record for Quantity/amount variance scenarios.
-- In this case QTY/Amount variance are stroed on same ITEM distributions , but there will be 2
-- bc records one for item amout and other for quantity/amount variance

Cursor C_Ap_Bc_Packets Is
Select  bcc.Set_Of_Books_Id
       ,bcc.Period_Year
       ,bcc.Project_Id
       ,bcc.Task_Id
       ,bcc.Expenditure_Type
       ,bcc.Expenditure_Item_Date
       ,bcc.Expenditure_Organization_Id
       ,bcc.Budget_Version_Id
       ,bcc.budget_line_id  -- R12 Funds Management uptake
       ,bcc.Document_Type
       ,bcc.Document_Header_Id
       ,bcc.Document_Distribution_Id
       ,bcc.Entered_Cr
       ,bcc.Entered_Dr
       ,bcc.Accounted_Cr
       ,bcc.Accounted_Dr
       ,bcc.Actual_Flag
       ,bcc.Txn_Ccid
       ,bcc.Je_Category_Name
       ,bcc.Je_Source_Name
       ,bcc.Org_Id
       ,bcc.Pa_Date
       ,bcc.bc_packet_id
       ,bcc.packet_id
       ,bcc.parent_bc_packet_id
       ,bcc.encumbrance_type_id
       ,bcc.document_header_id_2
       ,bcc.document_distribution_type
 From  Pa_Bc_Packets bcc
where  bcc.Document_Header_Id = p_sys_ref2
  and  bcc.Document_Distribution_Id =p_sys_ref5
  and  bcc.Status_Code in ('A','C')
  and  bcc.document_type = 'AP'
  and bcc.exp_item_id IS NULL -- Bug 5014138 : to pick just the encumbrance record
  and bcc.actual_flag = 'E'   -- Bug 5014138 : to pick just the encumbrance record
    -- Bug 5550268 : For variance we should be picking just the variance records
  /* Bug 5560524 : Modified the following condition such that the burden commitment relieving record is also
                   fetched for 'AP VARIANCE' transaction source. */
  and ((nvl(bcc.accounted_dr,0)-nvl(bcc.accounted_cr,0) = p_acct_raw_cost
        and p_txn_source = 'AP VARIANCE' and bcc.parent_bc_packet_id is null)
        OR
        p_txn_source <> 'AP VARIANCE'
	OR
        (bcc.parent_bc_packet_id is NOT null AND  p_txn_source = 'AP VARIANCE')
	);

l_rec_bc_comm_exists      VARCHAR2(1);  -- Variable to identify whether commitment record exists in pa_bc_commitments
l_rec_pkt_comm_exists     VARCHAR2(1);  -- Variable to identify whether commitment record exists in pa_bc_packets
L_RAW_BC_PACKET_ID        NUMBER;
l_po_dist_id              ap_invoice_distributions.po_distribution_id%TYPE;
l_po_line_id              po_distributions_all.po_line_id%TYPE;


CURSOR c_curr_raw_pkt IS
SELECT bc_packet_id
  FROM pa_bc_packets
 WHERE packet_id = p_packet_id
   AND Document_Header_Id = p_sys_ref2
   AND Document_Distribution_Id =p_sys_ref5
   AND parent_bc_packet_id IS NULL
   AND status_code ='P';


BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Start');
    END IF;

    /* cwk */

    IF p_txn_source in ('AP NRTAX','AP VARIANCE') THEN

          OPEN c_get_po_dist_id;
          FETCH c_get_po_dist_id into l_po_dist_id;
          CLOSE c_get_po_dist_id;

          IF nvl(Pa_Pjc_Cwk_Utils.Is_rate_based_line( null, l_po_dist_id),'N') = 'Y' THEN
            OPEN c_get_po_LINE_id(l_po_dist_id);
            FETCH c_get_po_LINE_id into l_po_line_id;
            CLOSE c_get_po_LINE_id;
          END IF;

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - After fetching CWK related data l_po_dist_id'||l_po_dist_id);
            log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - After fetching CWK related data l_po_line_id'||l_po_line_id);
         END IF;

    END IF;

    -- Code to derive values for variables which will decide the flow of this procedure
    l_rec_bc_comm_exists:='N';  -- Variable to identify whether commitment record exists in pa_bc_commitments
    l_rec_pkt_comm_exists:='N'; -- Variable to identify whether commitment record exists in pa_bc_packets

    IF p_comm_fc_req ='Y' OR p_act_fc_req  = 'Y' THEN

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Fetchign data from bc commitments');
      END IF;

      clear_plsql_tables;

      Open C_Ap_Commitment ;
      FETCH C_Ap_Commitment BULK COLLECT INTO
                g_sob_Id_tbl,
                g_Period_Year_tbl,
                g_project_id_tbl,
                g_task_id_tbl,
                g_exp_type_tbl,
                g_ei_date_tbl,
                g_exp_org_id_tbl,
                g_bud_ver_id_tbl,
		g_budget_line_id_tbl, -- R12 Funds management uptake
                g_Document_Type_tbl,
                g_Doc_Header_Id_tbl,
                g_Doc_dist_Id_tbl,
                g_Entered_Cr_tbl,
                g_Entered_Dr_tbl,
                g_acct_Cr_tbl,
                g_acct_Dr_tbl,
                g_Actual_Flag_tbl,
                g_Txn_Ccid_tbl,
                g_Je_Catg_Name_tbl,
                g_Je_sorce_Name_tbl,
                g_org_id_tbl,
                g_Pa_Date_tbl,
                g_bc_packet_id_tbl,
                g_packet_id_tbl,
		g_bc_parent_pkt_id_tbl,
                g_enc_type_id_tbl,
                g_doc_hdr_id_2_tbl,
                g_doc_dist_type_tbl;


     IF g_bc_packet_id_tbl.COUNT <> 0 THEN
        l_rec_bc_comm_exists  := 'Y';
     END IF;
     CLOSE C_Ap_Commitment;

     IF l_rec_bc_comm_exists = 'N' THEN

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Fetchign data from bc packets');
        END IF;

        OPEN C_Ap_Bc_Packets;
        FETCH C_Ap_Bc_Packets BULK COLLECT INTO
                g_sob_Id_tbl,
                g_Period_Year_tbl,
                g_project_id_tbl,
                g_task_id_tbl,
                g_exp_type_tbl,
                g_ei_date_tbl,
                g_exp_org_id_tbl,
                g_bud_ver_id_tbl,
		g_budget_line_id_tbl, -- R12 Funds management uptake
                g_Document_Type_tbl,
                g_Doc_Header_Id_tbl,
                g_Doc_dist_Id_tbl,
                g_Entered_Cr_tbl,
                g_Entered_Dr_tbl,
                g_acct_Cr_tbl,
                g_acct_Dr_tbl,
                g_Actual_Flag_tbl,
                g_Txn_Ccid_tbl,
                g_Je_Catg_Name_tbl,
                g_Je_sorce_Name_tbl,
                g_org_id_tbl,
                g_Pa_Date_tbl,
                g_bc_packet_id_tbl,
                g_packet_id_tbl,
		g_bc_parent_pkt_id_tbl,
                g_enc_type_id_tbl,
                g_doc_hdr_id_2_tbl,
                g_doc_dist_type_tbl;

        IF g_bc_packet_id_tbl.COUNT <> 0 THEN
           l_rec_pkt_comm_exists := 'Y' ;
        END IF;
        CLOSE C_Ap_Bc_Packets;

      END IF;

      IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Number of commitment records fetched = '||g_bc_packet_id_tbl.count);
      END IF;

     IF (l_rec_bc_comm_exists ='Y' OR l_rec_pkt_comm_exists  = 'Y') THEN

     -- Bug 5510447 : Insert commitment relieving raw and burden records only if p_comm_fc_req = 'Y'
     IF p_comm_fc_req = 'Y' THEN

      -- Logic to insert commitment relieving raw and burden records
      FORALL i IN 1 .. g_bc_packet_id_tbl.count
          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
		,budget_line_id -- R12 Funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Exp_Item_Id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
		,encumbrance_type_id
		,document_header_id_2
		,document_distribution_type
                )
         Select  p_packet_id
                ,g_bc_packet_id_tbl(i) -- Later updated with newly generated Id's
                ,g_bc_parent_pkt_id_tbl(i) -- Later updated with newly generated Id's
                ,g_sob_Id_tbl(i)
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,g_Period_Year_tbl(i)
                ,g_Pa_Date_tbl(i)
                ,g_project_id_tbl(i)
                ,g_task_id_tbl(i)
                ,g_exp_type_tbl(i)
                ,g_ei_date_tbl(i)
                ,g_exp_org_id_tbl(i)
                ,g_bud_ver_id_tbl(i)
		,g_budget_line_id_tbl(i)
                ,g_Document_Type_tbl(i)
                ,g_Doc_Header_Id_tbl(i)
                ,g_Doc_dist_Id_tbl(i)
                ,g_Entered_Cr_tbl(i) -- reversing dr
                ,g_Entered_Dr_tbl(i) -- reversing cr
                ,g_acct_Cr_tbl(i)
                ,g_acct_Dr_tbl(i)
                ,g_Request_Id
                ,G_Program_Id
                ,G_PROG_APPL_ID
                ,sysdate
                ,g_Actual_Flag_tbl(i)
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,G_CONC_LOGIN_ID
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,g_Txn_Ccid_tbl(i)
                ,'R'
                ,'P'
                ,g_Je_Catg_Name_tbl(i)
                ,g_Je_sorce_Name_tbl(i)
                ,g_org_id_tbl(i)
                ,X_ei_id
                ,l_po_line_id
		,'EXP'
		,X_ei_id
		,1
		,p_txn_interface_id --REL12
		,g_enc_type_id_tbl(i)
		,g_doc_hdr_id_2_tbl(i)
		,g_doc_dist_type_tbl(i)
          From  dual;

        IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Inserted '||SQL%ROWCOUNT||' AP reversing raw and burden line(s) into bc packets');
        END IF;

        -- Logic to update bc_packet_id and parent_bc_packet_id with newly generated sequences
        FOR c_cur IN c_curr_raw_pkt LOOP

           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous -Logic to update correct bc pkt Id/parent BC pkt Id');
           END IF;

           OPEN  c_gen_raw_bc_pkt;
           FETCH c_gen_raw_bc_pkt INTO l_Raw_Bc_Packet_Id;
           CLOSE c_gen_raw_bc_pkt;

           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous -Old Bc Packet Id = ' || c_cur.bc_packet_id||'New Bc Packet Id = ' || l_Raw_Bc_Packet_Id ||'Packet Id = ' || p_packet_id);
           END IF;

	   -- Update raw records with new bc_packet_id
            UPDATE Pa_Bc_Packets
	       SET bc_packet_id = l_Raw_Bc_Packet_Id
             WHERE packet_id = p_packet_id
               AND bc_packet_id = c_cur.bc_packet_id;

           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - NUmber of raw packets updated with new bc_packet_id '||SQL%ROWCOUNT);
           END IF;

            -- Update burden records with new bc_packet_id abd parent_bc_packet_id
            UPDATE Pa_Bc_Packets
	       SET bc_packet_id = Pa_Bc_Packets_s.NextVal
	           ,parent_bc_packet_id = l_Raw_Bc_Packet_Id
             WHERE packet_id = p_packet_id
               AND parent_bc_packet_id = c_cur.bc_packet_id;

           IF PG_DEBUG = 'Y' THEN
              log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - NUmber of burden packets updated with new parent_bc_packet_id '||SQL%ROWCOUNT);
           END IF;

       END LOOP;

     END IF; -- Bug 5510447 : IF p_comm_fc_req = 'Y' THEN

       --Logic to Insert the positive records for the raw line with document type 'EXP'.
       IF p_act_fc_req = 'Y' THEN

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Before inserting ACTUAL raw line from bc packets');
         END IF;

         FOR i IN 1 .. g_bc_packet_id_tbl.count LOOP


          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,gl_date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
		,budget_line_id -- R12 Funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
                )
          Select p_Packet_Id
                ,Pa_Bc_Packets_s.NextVal
                ,-1
                ,g_sob_Id_tbl(i)
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,g_Period_Year_tbl(i)
                ,g_Pa_Date_tbl(i)
                ,g_project_id_tbl(i)
                ,g_task_id_tbl(i)
                ,g_exp_type_tbl(i)
                ,g_ei_date_tbl(i)
                ,g_exp_org_id_tbl(i)
                ,g_bud_ver_id_tbl(i)
		,g_budget_line_id_tbl(i) -- R12 Funds management uptake
                ,'EXP'
                ,X_ei_id
                ,1
                ,DECODE(p_txn_source,'AP DISCOUNTS',p_acct_raw_cost,g_Entered_Dr_tbl(i))
                ,DECODE(p_txn_source,'AP DISCOUNTS',0,g_Entered_Cr_tbl(i))
                ,DECODE(p_txn_source,'AP DISCOUNTS',p_acct_raw_cost,g_acct_Dr_tbl(i))
                ,DECODE(p_txn_source,'AP DISCOUNTS',0,g_acct_Cr_tbl(i))
                ,g_Request_Id
                ,g_program_id
                ,g_prog_appl_id
                ,sysdate
                ,'A'
                ,sysdate
                ,g_conc_login_id
                ,g_conc_login_id
                ,sysdate
                ,g_conc_login_id
                ,g_Txn_Ccid_tbl(i)
                ,'N'
                ,'P'
                ,'Expenditures'
                ,'Project Accounting'
                ,g_org_id_tbl(i)
                ,DECODE(p_txn_source,'AP DISCOUNTS',NULL,l_po_line_id)
		,DECODE(p_txn_source,'AP DISCOUNTS',NULL,'EXP')
		,DECODE(p_txn_source,'AP DISCOUNTS',NULL,x_Ei_Id)
		,DECODE(p_txn_source,'AP DISCOUNTS',NULL,1)
		,p_txn_interface_id  --REL12
          From  Pa_Budget_Versions bv,
                Pa_Budget_Types bt,
                pa_budgetary_control_options pbct
         Where  bt.budget_type_Code = bv.budget_type_Code
           and  bt.budget_amount_code = 'C'
           and  bv.project_id = g_project_id_tbl(i)
           and  bv.current_flag = 'Y'
           and  pbct.project_id = bv.project_id
           and  pbct.BDGT_CNTRL_FLAG = 'Y'
           and  pbct.BUDGET_TYPE_CODE = bv.budget_type_code
           and (pbct.EXTERNAL_BUDGET_CODE = 'GL'
                OR
                pbct.EXTERNAL_BUDGET_CODE is NULL
                )
	   and  g_bc_parent_pkt_id_tbl(i) IS NULL;  -- Need to fire only for raw records


          -- Bug 5562671 :  Scenario where QTY/AMT varaince exists there will be multiple records in
	  -- bc_commitments/bc_packets for same inv distribution, hence the global varaibles will have
	  -- multiple distributions.But there will be only one ap discount line for both item amount +
	  -- qty/amt varaince. Hence actuals need to reserved only once.
	  /* Bug 5984525 : The following code is modified so that ACTUAL lines are inserted correctly
	     into pa bc packets while interfacing discounts to Projects. */
	  IF p_txn_source = 'AP DISCOUNTS' AND SQL%ROWCOUNT = 1 THEN
            IF PG_DEBUG = 'Y' THEN
                 log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Inserted 1 ACTUAL raw line(s) into bc packets');
            END IF;
	    EXIT;
          END IF;

	 END LOOP;

       END IF;--IF p_act_fc_req = 'Y' THEN

     END IF; --IF l_rec_bc_comm_exists ='Y' OR l_rec_pkt_comm_exists  = 'Y' THEN

     END IF; -- p_comm_fc_req ='Y' OR p_act_fc_req  = 'Y' THEN


     -- R12 AP lines uptake : Prepayment changes : Below insert will be fired for inserting 'EXP'
     -- records by fetching data from pa_transaction_interface_all table for below TXN records :
     -- a. Adjusting expenditures in txn_interface table
     -- b. For those commitments which were never FC'ed (eg : Prepayment application, pre-payment matched to PO ..)

     IF ((p_adj_act_fc_req = 'Y')
         OR (l_rec_bc_comm_exists ='N' AND l_rec_pkt_comm_exists  = 'N' AND p_act_fc_req  = 'Y' )) THEN

	 IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Before inserting adjusted ACTUAL raw line from transaction import table');
         END IF;

         FORALL i IN 1 .. g_xface_Txn_interface_tbl.count
         Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
                )
          Select p_Packet_Id
                ,Pa_Bc_Packets_s.NextVal
                ,-1
                ,g_sobid
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,G_FC_Period_Year
                ,G_PaDate
                ,g_xface_project_id_tbl(i)
                ,g_xface_task_id_tbl(i)
                ,g_xface_exp_type_tbl(i)
                ,g_xface_ei_date_tbl(i)
                ,g_xface_exp_org_id_tbl(i)
                ,g_xface_bud_ver_id_tbl(i)
                ,'EXP'
                ,X_ei_id
                ,1
		-- R12 AP lines uptake : Prepayment changes
		-- For Prepayment application/pre-payment matched to PO records consider p_acct_raw_cost as amount
                ,g_xface_Entered_Dr_tbl(i)
                ,g_xface_acct_Cr_tbl(i)
                ,g_xface_acct_Dr_tbl(i)
                ,g_xface_acct_Cr_tbl(i)
                ,g_Request_Id
                ,g_program_id
                ,g_prog_appl_id
                ,sysdate
                ,'A' --Actual_Flag
                ,sysdate
                ,g_conc_login_id
                ,g_conc_login_id
                ,sysdate
                ,g_conc_login_id
                ,g_xface_Txn_Ccid_tbl(i)
                ,'N'
                ,'P'
                ,'Expenditures'
                ,'Project Accounting'
                ,g_xface_org_id_tbl(i)
                ,l_po_line_id
		,'EXP'
		,X_Ei_Id
		,1
		,g_xface_Txn_interface_tbl(i)  --REL12
          From  dual;

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - Inserted '||SQL%ROWCOUNT||' ACTUAL raw line(s) into bc packets');
         END IF;

       END IF;

 COMMIT;
 IF PG_DEBUG = 'Y' THEN
     log_message('log_message: ' || 'In insert_ap_bc_pkt_autonomous - End');
 END IF;

EXCEPTION
WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
      log_message('log_message: In insert_ap_bc_pkt_autonomous - ' || sqlerrm||' Returning from insert_ap_bc_pkt_autonomous');
   END IF;
   RAISE;
END insert_ap_bc_pkt_autonomous;


-- R12 funds management Uptake : New procedure fired in non-autonomous mode to read
-- pa_transaction_interface_all table and to derive variables which drives the
-- relieving/reserving of commitments and actuals flow during interface.

PROCEDURE insert_cash_ap_bc_packets(p_packet_id             IN NUMBER,
                                    p_sys_ref2              IN NUMBER,
                                    p_sys_ref5              IN NUMBER,
                                    p_acct_raw_cost         IN NUMBER,
                                    p_fc_document_type      IN VARCHAR2,
                                    p_txn_source            IN VARCHAR2,
                                    p_adj_exp_item_id       IN NUMBER,
			            p_txn_interface_id      IN NUMBER,
			            p_cash_pay_to_relieve   IN NUMBER DEFAULT 0) IS

-- Cursor to fetch data from pa_transaction_interface_table.This data is later used
-- in autonomous fundscheck insert_ap_bc_pkts_autonomous procedure.

 CURSOR c_pa_txn_interface_data (p_adj_act_fc_req VARCHAR2,
                                 p_act_fc_req  VARCHAR2) IS
 Select txn.Project_Id
        ,txn.Task_Id
        ,txn.Expenditure_Type
        ,txn.Expenditure_Item_Date
        ,nvl(txn.OVERRIDE_TO_ORGANIZATION_ID,txn.Org_Id)
        ,bv.Budget_Version_Id
	-- R12 AP lines uptake : Prepayment changes
	-- For Prepayment application/pre-payment matched to PO records consider p_acct_raw_cost as amount
        ,DECODE(txn_interface_id,p_txn_interface_id, p_acct_raw_cost,txn.acct_raw_cost)
        ,0
        ,DECODE(txn_interface_id,p_txn_interface_id, p_acct_raw_cost,txn.acct_raw_cost)
        ,0
        ,txn.cr_code_combination_id
        ,txn.Org_id
        ,txn.txn_interface_id  --REL12
  From  Pa_Budget_Versions bv,
        Pa_Budget_Types bt,
        pa_budgetary_control_options pbct,
	pa_transaction_interface_all txn
 Where  bv.budget_type_code = bt.budget_type_code
   and  bt.budget_amount_code = 'C'
   and  bv.current_flag = 'Y'
   AND  pbct.project_id = bv.project_id
   AND  pbct.BDGT_CNTRL_FLAG = 'Y'
   AND  pbct.BUDGET_TYPE_CODE = bv.budget_type_code
   AND (pbct.EXTERNAL_BUDGET_CODE = 'GL'
        OR
        pbct.EXTERNAL_BUDGET_CODE is NULL
        )
   AND  bv.project_id = txn.project_id
   AND  txn.txn_interface_id in ( SELECT txn1.txn_interface_id
                                   FROM pa_transaction_interface_all txn1
 				   WHERE txn1.TRANSACTION_SOURCE = p_txn_source -- Condition for using index
				   -- new index usage needs to be verified for below columns
                                     AND txn1.cdl_system_reference2 = p_sys_ref2
                                     AND txn1.cdl_system_reference5 = p_sys_ref5
                                     AND txn1.fc_document_type in ('ACT','ALL')
	                             AND txn1.adjusted_expenditure_item_id IS NOT NULL
				     AND p_adj_act_fc_req = 'Y'
                                UNION ALL -- R12 AP lines uptake : Prepayment changes : Added to pick current transaction for prepayment scenarios
				  SELECT p_txn_interface_id
				    FROM DUAL
                                   WHERE p_act_fc_req  = 'Y');

l_comm_fc_req             VARCHAR2(1);  -- Variable to identify whether commitment fundscheck is required
l_act_fc_req              VARCHAR2(1);  -- Variable to identify whether actual fundscheck is required
l_adj_act_fc_req          VARCHAR2(1);  -- Variable to identify whether adjusted actual fundscheck is required

BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Start');
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_packet_id '||p_packet_id);
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_sys_ref2  '||p_sys_ref2 );
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_sys_ref5  '||p_sys_ref5 );
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_acct_raw_cost '||p_acct_raw_cost);
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_fc_document_type  '||p_fc_document_type );
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_txn_source '||p_txn_source);
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_adj_exp_item_id '||p_adj_exp_item_id);
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of p_txn_interface_id '||p_txn_interface_id);

    END IF;

    -- Code to derive values for variables which will decide the flow of this procedure

    l_comm_fc_req :='N';        -- Variable to identify whether commitment fundscheck is required
    l_act_fc_req :='N';         -- Variable to identify whether actual fundscheck is required
    l_adj_act_fc_req:='N';      -- Variable to identify whether adjusted actual fundscheck is required

    -- Deriving value for variable which identifies if FC required for AP commitment

    IF ( (p_adj_exp_item_id IS NULL AND p_fc_document_type ='ALL') OR     --AP normal Invoice lines
         (p_adj_exp_item_id IS NOT NULL AND (p_fc_document_type ='ALL'    --FC enabled for AP INV and FC enabled for adjusted ei's
	                                     OR p_fc_document_type ='CMT')--FC enabled for AP INV and FC Disabled for adjusted ei's
          )
	) AND p_cash_pay_to_relieve <> 0 THEN
       l_comm_fc_req := 'Y' ;
    END IF;

    -- Deriving value for variable which identifies if FC required for Actuals
    IF  p_adj_exp_item_id IS NULL THEN

        IF ( p_fc_document_type ='ALL' OR p_fc_document_type ='ACT' OR p_txn_source = 'AP DISCOUNTS') THEN
            l_act_fc_req  := 'Y' ;
        END IF;

    ELSIF p_adj_exp_item_id IS NOT NULL THEN

        IF (p_fc_document_type ='ALL' OR  p_fc_document_type ='ACT') THEN
            l_adj_act_fc_req := 'Y';
        END IF;

    END IF;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of l_comm_fc_req '||l_comm_fc_req);
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of l_adj_act_fc_req   '||l_adj_act_fc_req  );
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - Value of l_act_fc_req  '||l_act_fc_req );
    END IF;

    -- Cursor to fetch data from pa_transaction_interface_table.This data is later used
    -- in autonomous fundscheck insert_ap_bc_pkts_autonomous procedure.

    IF ( l_adj_act_fc_req = 'Y'  OR l_act_fc_req  = 'Y' ) THEN

       -- call to clean up global plsql arrays used for storing interface data.
       init_xface_plsql_tables;

       OPEN c_pa_txn_interface_data(l_adj_act_fc_req ,l_act_fc_req);
       FETCH c_pa_txn_interface_data BULK COLLECT INTO
                                          g_xface_project_id_tbl,
					  g_xface_task_id_tbl,
					  g_xface_exp_type_tbl,
					  g_xface_ei_date_tbl,
					  g_xface_exp_org_id_tbl,
					  g_xface_bud_ver_id_tbl,
					  g_xface_Entered_Dr_tbl,
					  g_xface_Entered_Cr_tbl,
					  g_xface_acct_Dr_tbl,
				          g_xface_acct_Cr_tbl,
					  g_xface_Txn_Ccid_tbl,
					  g_xface_org_id_tbl,
					  g_xface_Txn_interface_tbl;
       CLOSE c_pa_txn_interface_data;

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'In insert_cash_ap_bc_packets - fetched data from interface table c_pa_txn_interface_data ');
       END IF;

    END IF; --IF ( l_adj_act_fc_req = 'Y'  OR l_act_fc_req  = 'Y' ) THEN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - calling insert_cash_ap_bc_pkt_auto');
    END IF;

    insert_cash_ap_bc_pkt_auto
                           (p_packet_id             => p_packet_id,
                            p_sys_ref2              => p_sys_ref2,
                            p_sys_ref5              => p_sys_ref5,
                            p_acct_raw_cost         => p_acct_raw_cost,
                            p_fc_document_type      => p_fc_document_type,
                            p_txn_source            => p_txn_source,
                            p_adj_exp_item_id       => p_adj_exp_item_id ,
			    p_txn_interface_id      => p_txn_interface_id,
		            p_cash_pay_to_relieve   => p_cash_pay_to_relieve,
			    p_comm_fc_req           => l_comm_fc_req,
                            p_act_fc_req            => l_act_fc_req,
                            p_adj_act_fc_req        => l_adj_act_fc_req );

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_cash_ap_bc_packets - End');
    END IF;

EXCEPTION
WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
      log_message('log_message:I n insert_cash_ap_bc_packets exception' || sqlerrm||' Returning from insert_cash_ap_bc_packets');
   END IF;
   RAISE;
END insert_cash_ap_bc_packets;

-- This procedure inserts records into pa_bc_packets for relieving commitment raw and burden
-- and also for reserving raw and burden against actual.

-- Parameter values : p_packet_id     -  Packet Id to be inserted
--                    p_sys_ref2      -  Invoice Id
--                    p_sys_ref5      -  Invoice Distribution Id
--                    p_acct_raw_cost -  Amount to be relieved against AP and to be reserved against EXP
--                    p_fc_document_type - 'CMT'/'ALL'/'ACT'/'NOT'
--                    p_txn_source       - Transaction source associated with the txn.
--                    p_adj_exp_item_id  - Exp item id to be adjusted
--                    p_txn_interface_id - txn interface Id
--                    p_cash_pay_to_relieve - AP distribution amount to be relieved for cash based accounting.
--                                            For cash based accounting p_acct_raw_cost amount will be reserved against EXP and
--                                            p_cash_amt_to_relieve amount will be relived against AP.

PROCEDURE insert_cash_ap_bc_pkt_auto
                                   (p_packet_id             IN NUMBER,
                                    p_sys_ref2              IN NUMBER,
                                    p_sys_ref5              IN NUMBER,
                                    p_acct_raw_cost         IN NUMBER,
                                    p_fc_document_type      IN VARCHAR2,
                                    p_txn_source            IN VARCHAR2,
                                    p_adj_exp_item_id       IN NUMBER,
			            p_txn_interface_id      IN NUMBER,
			            p_cash_pay_to_relieve   IN NUMBER DEFAULT 0,
            			    p_comm_fc_req           IN VARCHAR2,
                                    p_act_fc_req            IN VARCHAR2,
                                    p_adj_act_fc_req        IN VARCHAR2) IS

PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_gen_raw_bc_pkt IS
SELECT Pa_Bc_Packets_s.NextVal
  FROM dual;

CURSOR c_get_po_dist_id IS
SELECT po_distribution_id
  FROM ap_invoice_distributions
 WHERE invoice_id = p_sys_ref2
   AND invoice_distribution_id = p_sys_ref5;

CURSOR c_get_po_LINE_id (p_po_dist_id NUMBER) IS
SELECT po_line_id
  FROM po_distributions_all
 WHERE po_distribution_id = p_po_dist_id;

Cursor C_Ap_Commitment Is
Select  bcc.Set_Of_Books_Id
       ,bcc.Period_Year
       ,bcc.Project_Id
       ,bcc.Task_Id
       ,bcc.Expenditure_Type
       ,bcc.Expenditure_Item_Date
       ,bcc.Expenditure_Organization_Id
       ,bcc.Budget_Version_Id
       ,bcc.budget_line_id -- R12 Funds management uptake
       ,bcc.Document_Type
       ,bcc.Document_Header_Id
       ,bcc.Document_Distribution_Id
       ,bcc.Entered_Cr
       ,bcc.Entered_Dr
       ,bcc.Accounted_Cr
       ,bcc.Accounted_Dr
       ,bcc.Actual_Flag
       ,bcc.Txn_Ccid
       ,bcc.Je_Category_Name
       ,bcc.Je_Source_Name
       ,bcc.Org_Id
       ,bcc.Pa_Date
       ,bcc.bc_packet_id
       ,bcc.packet_id
 From  Pa_Bc_Commitments_all bcc
Where  bcc.Document_Header_Id = p_sys_ref2
  and  bcc.Document_Distribution_Id = p_sys_ref5
  and  bcc.Parent_Bc_Packet_Id is NULL
  --PA-J Receipt accrual changes
  and  bcc.document_type = 'AP'
  and bcc.exp_item_id IS NULL -- Bug 5014138 : to pick just the encumbrance record
  and bcc.actual_flag = 'E'   -- Bug 5014138 : to pick just the encumbrance record
  -- R12 Ap lines Uptake : For cash based accounting which can have multiple packets associated with a distribution.
  and  rownum = 1 ;


Cursor C_Ap_Bc_Packets Is
Select  bcc.Set_Of_Books_Id
       ,bcc.Period_Year
       ,bcc.Project_Id
       ,bcc.Task_Id
       ,bcc.Expenditure_Type
       ,bcc.Expenditure_Item_Date
       ,bcc.Expenditure_Organization_Id
       ,bcc.Budget_Version_Id
       ,bcc.budget_line_id -- R12 Funds management uptake
       ,bcc.Document_Type
       ,bcc.Document_Header_Id
       ,bcc.Document_Distribution_Id
       ,bcc.Entered_Cr
       ,bcc.Entered_Dr
       ,bcc.Accounted_Cr
       ,bcc.Accounted_Dr
       ,bcc.Actual_Flag
       ,bcc.Txn_Ccid
       ,bcc.Je_Category_Name
       ,bcc.Je_Source_Name
       ,bcc.Org_Id
       ,bcc.Pa_Date
       ,bcc.bc_packet_id
       ,bcc.packet_id
 From  Pa_Bc_Packets bcc
where  bcc.Document_Header_Id = p_sys_ref2
  and  bcc.Document_Distribution_Id = p_sys_ref5
  and  bcc.Status_Code in ('A','C')
  and  bcc.Parent_Bc_Packet_Id is NULL
  and  bcc.document_type = 'AP'
  and bcc.exp_item_id IS NULL -- Bug 5014138 : to pick just the encumbrance record
  and bcc.actual_flag = 'E'   -- Bug 5014138 : to pick just the encumbrance record
  -- R12 Ap lines Uptake : Added for cash based accounting which can have multiple packets associated witha  distribution.
  and  rownum = 1 ;

l_rec_bc_comm_exists      VARCHAR2(1);  -- Variable to identify whether commitment record exists in pa_bc_commitments
l_rec_pkt_comm_exists     VARCHAR2(1);  -- Variable to identify whether commitment record exists in pa_bc_packets
l_Raw_Bc_Packet_Id        pa_bc_packets.bc_packet_id%TYPE;
l_po_dist_id              ap_invoice_distributions.po_distribution_id%TYPE;
l_po_line_id              po_distributions_all.po_line_id%TYPE;

BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Start');
    END IF;

    /* cwk */

    IF p_txn_source in ('AP NRTAX','AP VARIANCE') THEN

          OPEN c_get_po_dist_id;
          FETCH c_get_po_dist_id into l_po_dist_id;
          CLOSE c_get_po_dist_id;

          IF nvl(Pa_Pjc_Cwk_Utils.Is_rate_based_line( null, l_po_dist_id),'N') = 'Y' THEN
            OPEN c_get_po_LINE_id(l_po_dist_id);
            FETCH c_get_po_LINE_id into l_po_line_id;
            CLOSE c_get_po_LINE_id;
          END IF;

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - After fetching CWK related data l_po_dist_id'||l_po_dist_id);
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - After fetching CWK related data l_po_line_id'||l_po_line_id);
         END IF;
    END IF;

    -- Code to derive values for variables which will decide the flow of this procedure

    l_rec_bc_comm_exists:='N';  -- Variable to identify whether commitment record exists in pa_bc_commitments
    l_rec_pkt_comm_exists:='N'; -- Variable to identify whether commitment record exists in pa_bc_packets

    IF p_comm_fc_req ='Y' OR p_act_fc_req  = 'Y' THEN

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Fetchign data from bc commitments');
      END IF;

      Open C_Ap_Commitment ;
      clear_plsql_tables;
      FETCH C_Ap_Commitment BULK COLLECT INTO
                g_sob_Id_tbl,
                g_Period_Year_tbl,
                g_project_id_tbl,
                g_task_id_tbl,
                g_exp_type_tbl,
                g_ei_date_tbl,
                g_exp_org_id_tbl,
                g_bud_ver_id_tbl,
 	        g_budget_line_id_tbl, -- R12 funds management uptake
                g_Document_Type_tbl,
                g_Doc_Header_Id_tbl,
                g_Doc_dist_Id_tbl,
                g_Entered_Cr_tbl,
                g_Entered_Dr_tbl,
                g_acct_Cr_tbl,
                g_acct_Dr_tbl,
                g_Actual_Flag_tbl,
                g_Txn_Ccid_tbl,
                g_Je_Catg_Name_tbl,
                g_Je_sorce_Name_tbl,
                g_org_id_tbl,
                g_Pa_Date_tbl,
                g_bc_packet_id_tbl,
                g_packet_id_tbl;

     IF g_bc_packet_id_tbl.COUNT <> 0 THEN
        l_rec_bc_comm_exists  := 'Y';
     END IF;
     CLOSE C_Ap_Commitment;

     IF l_rec_bc_comm_exists = 'N' THEN

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Fetchign data from bc packets');
        END IF;

        OPEN C_Ap_Bc_Packets;
        FETCH C_Ap_Bc_Packets BULK COLLECT INTO
                g_sob_Id_tbl,
                g_Period_Year_tbl,
                g_project_id_tbl,
                g_task_id_tbl,
                g_exp_type_tbl,
                g_ei_date_tbl,
                g_exp_org_id_tbl,
                g_bud_ver_id_tbl,
 	        g_budget_line_id_tbl, -- R12 funds management uptake
                g_Document_Type_tbl,
                g_Doc_Header_Id_tbl,
                g_Doc_dist_Id_tbl,
                g_Entered_Cr_tbl,
                g_Entered_Dr_tbl,
                g_acct_Cr_tbl,
                g_acct_Dr_tbl,
                g_Actual_Flag_tbl,
                g_Txn_Ccid_tbl,
                g_Je_Catg_Name_tbl,
                g_Je_sorce_Name_tbl,
                g_org_id_tbl,
                g_Pa_Date_tbl,
                g_bc_packet_id_tbl,
                g_packet_id_tbl;

        IF g_bc_packet_id_tbl.COUNT <> 0 THEN
           l_rec_pkt_comm_exists := 'Y' ;
        END IF;
        CLOSE C_Ap_Bc_Packets;

      END IF;

     IF l_rec_bc_comm_exists ='Y' OR l_rec_pkt_comm_exists  = 'Y' THEN

      FOR i IN g_bc_packet_id_tbl.FIRST..g_bc_packet_id_tbl.LAST LOOP

        -- Generate a packet identifier for RAW record that
        -- needs to be inserted into Pa BC Packets

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Generating new Bc packet Id for reversing RAW act and commitment line');
        END IF;

        OPEN  c_gen_raw_bc_pkt;
        FETCH c_gen_raw_bc_pkt INTO l_Raw_Bc_Packet_Id;
        CLOSE c_gen_raw_bc_pkt;

        IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Bc Packet Id = ' || l_Raw_Bc_Packet_Id ||'Packet Id = ' || p_packet_id);
        END IF;

        IF l_rec_bc_comm_exists = 'Y' AND p_comm_fc_req ='Y' THEN

          IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Before inserting AP reversing raw and burden line from bc commitments');
          END IF;

          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
 	        ,budget_line_id -- R12 funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Exp_Item_Id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
		,encumbrance_type_id
		,document_header_id_2
		,document_distribution_type
                )
         Select  p_packet_id
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,l_Raw_Bc_Packet_id,Pa_Bc_Packets_s.NextVal)
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,NULL,l_Raw_Bc_Packet_id)
                ,bcc.Set_Of_Books_Id
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,bcc.Period_Year
                ,bcc.Pa_Date -- pa_date on raw is used for burden line
                ,bcc.Project_Id
                ,bcc.Task_Id
                ,bcc.Expenditure_Type
                ,bcc.Expenditure_Item_Date
                ,bcc.Expenditure_Organization_Id
                ,bcc.Budget_Version_Id
 	        ,bcc.budget_line_id -- R12 funds management uptake
                ,bcc.Document_Type
                ,bcc.Document_Header_Id
                ,bcc.Document_Distribution_Id
                ,DECODE(bcc.Parent_Bc_Packet_Id,NULL,p_cash_pay_to_relieve
 	  				            ,pa_currency.round_trans_currency_amt1((p_cash_pay_to_relieve * bcc.compiled_multiplier),G_accounting_currency_code))
                ,0
                ,DECODE(bcc.Parent_Bc_Packet_Id,NULL,p_cash_pay_to_relieve
 	  				            ,pa_currency.round_trans_currency_amt1((p_cash_pay_to_relieve * bcc.compiled_multiplier),G_accounting_currency_code))
                ,0
                ,g_Request_Id
                ,G_Program_Id
                ,G_PROG_APPL_ID
                ,sysdate
                ,bcc.Actual_Flag
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,G_CONC_LOGIN_ID
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,bcc.Txn_Ccid
                ,'R'
                ,'P'
                ,bcc.Je_Category_Name
                ,bcc.Je_Source_Name
                ,bcc.Org_Id
                ,X_ei_id
                ,l_po_line_id
		,'EXP'
		,X_ei_id
		,1
		,p_txn_interface_id --REL12
		,bcc.encumbrance_type_id
		,bcc.document_header_id_2
		,bcc.document_distribution_type
          From  Pa_Bc_Commitments_all bcc
         Where  bcc.Document_Header_Id = p_sys_ref2 -- Added for using index
           and  bcc.Document_Distribution_Id = p_sys_ref5
           and  bcc.packet_id = g_packet_id_tbl(i)
	   and  bcc.document_type = 'AP' ;

        IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Inserted '||SQL%ROWCOUNT||' AP reversing raw and burden line(s) into bc packets');
        END IF;

       END IF; --IF l_rec_bc_comm_exists = 'Y' AND p_comm_fc_req ='Y' THEN


       IF l_rec_pkt_comm_exists='Y' AND p_comm_fc_req ='Y' THEN

          IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Before inserting the AP raw and burden lines from Bc Packets');
          END IF;

          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
 	        ,budget_line_id -- R12 funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Exp_Item_Id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
		,encumbrance_type_id
		,document_header_id_2
		,document_distribution_type
                )
          Select p_packet_id
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,l_Raw_Bc_Packet_id,Pa_Bc_Packets_s.NextVal)
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,NULL,l_Raw_Bc_Packet_id)
                ,bcc.Set_Of_Books_Id
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,bcc.Period_Year
                ,bcc.pa_date
                ,bcc.Project_Id
                ,bcc.Task_Id
                ,bcc.Expenditure_Type
                ,bcc.Expenditure_Item_Date
                ,bcc.Expenditure_Organization_Id
                ,bcc.Budget_Version_Id
 	        ,bcc.budget_line_id -- R12 funds management uptake
                ,bcc.Document_Type
                ,bcc.Document_Header_Id
                ,bcc.Document_Distribution_Id
                ,DECODE(bcc.Parent_Bc_Packet_Id,NULL,p_cash_pay_to_relieve
 	  				            ,pa_currency.round_trans_currency_amt1((p_cash_pay_to_relieve * bcc.compiled_multiplier),G_accounting_currency_code))
                ,0
                ,DECODE(bcc.Parent_Bc_Packet_Id,NULL,p_cash_pay_to_relieve
 	  				            ,pa_currency.round_trans_currency_amt1((p_cash_pay_to_relieve * bcc.compiled_multiplier),G_accounting_currency_code))
                ,0
		,g_Request_Id
                ,G_Program_Id
                ,G_PROG_APPL_ID
                ,sysdate
                ,bcc.Actual_Flag
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,G_CONC_LOGIN_ID
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,bcc.Txn_Ccid
                ,'R'
                ,'P'
                ,bcc.Je_Category_Name
                ,bcc.Je_Source_Name
                ,bcc.Org_id
                ,X_ei_id
                ,l_po_line_id
		,'EXP'
		,X_ei_id
		,1
		,p_txn_interface_id  --REL12
		,bcc.encumbrance_type_id
		,bcc.document_header_id_2
		,bcc.document_distribution_type
          From  Pa_Bc_Packets bcc
         Where  bcc.packet_id                = g_packet_id_tbl(i)
	   and  bcc.document_type            = 'AP'
           -- Bug : 4962731
           --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
           and  bcc.Document_Header_Id       = p_sys_ref2 -- Added for using index
           and  bcc.Document_Distribution_Id = p_sys_ref5
	   and  bcc.Status_Code in ('A','C');

          IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Before inserting the AP raw and burden lines from Bc Packets');
          END IF;

       END IF; --IF l_rec_pkt_comm_exists='Y' AND p_comm_fc_req ='Y' THEN

       IF p_act_fc_req = 'Y' THEN

         -- Insert the positive records for the raw line with
         -- document type 'EXP'.

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Before inserting ACTUAL raw line from bc packets');
         END IF;

          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,gl_date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
 	        ,budget_line_id -- R12 funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
                )
          Select p_Packet_Id
                ,Pa_Bc_Packets_s.NextVal
                ,-1
                ,g_sob_Id_tbl(i)
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,g_Period_Year_tbl(i)
                ,g_Pa_Date_tbl(i)
                ,g_project_id_tbl(i)
                ,g_task_id_tbl(i)
                ,g_exp_type_tbl(i)
                ,g_ei_date_tbl(i)
                ,g_exp_org_id_tbl(i)
                ,g_bud_ver_id_tbl(i)
 	        ,g_budget_line_id_tbl(i) -- R12 funds management uptake
                ,'EXP'
                ,X_ei_id
                ,1
                ,p_acct_raw_cost
                ,0
                ,p_acct_raw_cost
                ,0
                ,g_Request_Id
                ,g_program_id
                ,g_prog_appl_id
                ,sysdate
                ,'A'
                ,sysdate
                ,g_conc_login_id
                ,g_conc_login_id
                ,sysdate
                ,g_conc_login_id
                ,g_Txn_Ccid_tbl(i)
                ,'N'
                ,'P'
                ,'Expenditures'
                ,'Project Accounting'
                ,g_org_id_tbl(i)
                ,l_po_line_id
		,'EXP'
		,x_Ei_Id
		,1
		,p_txn_interface_id  --REL12
          From  Pa_Budget_Versions bv,
                Pa_Budget_Types bt,
                pa_budgetary_control_options pbct
         Where  bt.budget_type_Code = bv.budget_type_Code
           and  bt.budget_amount_code = 'C'
           and  bv.project_id = g_project_id_tbl(i)
           and  bv.current_flag = 'Y'
           and  pbct.project_id = bv.project_id
           and  pbct.BDGT_CNTRL_FLAG = 'Y'
           and  pbct.BUDGET_TYPE_CODE = bv.budget_type_code
           and (pbct.EXTERNAL_BUDGET_CODE = 'GL'
                OR
                pbct.EXTERNAL_BUDGET_CODE is NULL
                );

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Inserted '||SQL%ROWCOUNT||' ACTUAL raw line(s) into bc packets');
         END IF;

       END IF;--IF p_act_fc_req = 'Y' THEN
      END LOOP;
     END IF; -- l_rec_bc_comm_exists ='Y' OR l_rec_pkt_comm_exists  = 'Y' THEN

    END IF; -- p_comm_fc_req ='Y' OR p_act_fc_req  = 'Y' THEN


     -- R12 AP lines uptake : Prepayment changes : Below insert will be fired for inserting 'EXP'
     -- records by fetching data from pa_transaction_interface_all table for below TXN records :
     -- a. Adjusting expenditures in txn_interface table
     -- b. For those commitments which were never FC'ed (eg : Prepayment application, pre-payment matched to PO ..)

     IF ((p_adj_act_fc_req = 'Y')
         OR (l_rec_bc_comm_exists ='N' AND l_rec_pkt_comm_exists  = 'N' AND p_act_fc_req  = 'Y' )) THEN

	 IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Before inserting adjusted ACTUAL raw line from transaction import table');
         END IF;

         FORALL i IN 1 .. g_xface_Txn_interface_tbl.count
         Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
                )
          Select p_Packet_Id
                ,Pa_Bc_Packets_s.NextVal
                ,-1
                ,g_sobid
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,G_FC_Period_Year
                ,G_PaDate
                ,g_xface_project_id_tbl(i)
                ,g_xface_task_id_tbl(i)
                ,g_xface_exp_type_tbl(i)
                ,g_xface_ei_date_tbl(i)
                ,g_xface_exp_org_id_tbl(i)
                ,g_xface_bud_ver_id_tbl(i)
                ,'EXP'
                ,X_ei_id
                ,1
		-- R12 AP lines uptake : Prepayment changes
		-- For Prepayment application/pre-payment matched to PO records consider p_acct_raw_cost as amount
                ,g_xface_Entered_Dr_tbl(i)
                ,g_xface_acct_Cr_tbl(i)
                ,g_xface_acct_Dr_tbl(i)
                ,g_xface_acct_Cr_tbl(i)
                ,g_Request_Id
                ,g_program_id
                ,g_prog_appl_id
                ,sysdate
                ,'A' --Actual_Flag
                ,sysdate
                ,g_conc_login_id
                ,g_conc_login_id
                ,sysdate
                ,g_conc_login_id
                ,g_xface_Txn_Ccid_tbl(i)
                ,'N'
                ,'P'
                ,'Expenditures'
                ,'Project Accounting'
                ,g_xface_org_id_tbl(i)
                ,l_po_line_id
		,'EXP'
		,X_Ei_Id
		,1
		,g_xface_Txn_interface_tbl(i)  --REL12
          From  dual;

	 IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - Before inserting adjusted ACTUAL raw line from transaction import table');
         END IF;

       END IF;

 COMMIT;
 IF PG_DEBUG = 'Y' THEN
     log_message('log_message: ' || 'In insert_cash_ap_bc_pkt_auto - End');
 END IF;

EXCEPTION
WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
      log_message('log_message: In insert_cash_ap_bc_pkt_auto exception' || sqlerrm||' Returning from insert_cash_ap_bc_pkt_auto');
   END IF;
   RAISE;
END insert_cash_ap_bc_pkt_auto;

-- R12 funds management Uptake : New procedure fired in non-autonomous mode to read
-- pa_transaction_interface_all table and to derive variables which drives the
-- relieving/reserving of commitments and actuals flow during interface.

PROCEDURE insert_po_bc_packets
                           (p_packet_id             IN NUMBER,
                            p_sys_ref2              IN NUMBER,
                            p_sys_ref4              IN NUMBER,
			    p_sys_ref3              IN NUMBER,
                            p_acct_raw_cost         IN NUMBER,
			    p_cmt_raw_cost          IN NUMBER,
                            p_fc_document_type      IN VARCHAR2,
                            p_txn_source            IN VARCHAR2,
                            p_adj_exp_item_id       IN NUMBER,
			    p_txn_interface_id      IN NUMBER) IS

-- Cursor to fetch data from pa_transaction_interface_table.This data is later used
-- in autonomous fundscheck insert_ap_bc_pkts_autonomous procedure.

 CURSOR c_pa_txn_interface_data IS
 Select txn.Project_Id
        ,txn.Task_Id
        ,txn.Expenditure_Type
        ,txn.Expenditure_Item_Date
        ,nvl(txn.OVERRIDE_TO_ORGANIZATION_ID,txn.Org_Id)
        ,bv.Budget_Version_Id
	-- R12 AP lines uptake : Prepayment changes
	-- For Prepayment application/pre-payment matched to PO records consider p_acct_raw_cost as amount
        ,txn.acct_raw_cost
        ,0
        ,txn.acct_raw_cost
        ,0
        ,txn.cr_code_combination_id
        ,txn.Org_id
        ,txn.txn_interface_id  --REL12
  From  Pa_Budget_Versions bv,
        Pa_Budget_Types bt,
        pa_budgetary_control_options pbct,
        pa_transaction_interface_all txn
 Where  bv.budget_type_code = bt.budget_type_code
   and  bt.budget_amount_code = 'C'
   and  bv.current_flag = 'Y'
   AND  pbct.project_id = bv.project_id
   AND  pbct.BDGT_CNTRL_FLAG = 'Y'
   AND  pbct.BUDGET_TYPE_CODE = bv.budget_type_code
   AND (pbct.EXTERNAL_BUDGET_CODE = 'GL'
        OR
        pbct.EXTERNAL_BUDGET_CODE is NULL
        )
   AND bv.project_id = txn.project_id
   and txn.TRANSACTION_SOURCE = p_txn_source -- Condition for using index
    -- new index usage needs to be verified for below columns
   AND txn.cdl_system_reference2 = p_sys_ref2
   AND txn.cdl_system_reference3 = p_sys_ref3 --Bug 5550268
   --Bug 5550268  : Will be NULL when fired from ap_po_fundscheck_check
   AND (txn.cdl_system_reference4 = p_sys_ref4 OR p_sys_ref4 IS NULL)
   AND txn.fc_document_type in ('ACT','ALL')
   AND txn.adjusted_expenditure_item_id IS NOT NULL;

l_comm_fc_req             VARCHAR2(1);  -- Variable to identify whether commitment fundscheck is required
l_act_fc_req              VARCHAR2(1);  -- Variable to identify whether actual fundscheck is required
l_adj_act_fc_req          VARCHAR2(1);  -- Variable to identify whether adjusted actual fundscheck is required

BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_po_bc_packets - Start');
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_packet_id '||p_packet_id);
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_sys_ref2  '||p_sys_ref2 );
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_sys_ref4  '||p_sys_ref4 );
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_sys_ref3  '||p_sys_ref3 );
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_acct_raw_cost '||p_acct_raw_cost);
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_cmt_raw_cost '||p_cmt_raw_cost); -- Bug 5731450
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_fc_document_type  '||p_fc_document_type );
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_txn_source '||p_txn_source);
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_adj_exp_item_id '||p_adj_exp_item_id);
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of p_txn_interface_id '||p_txn_interface_id);

    END IF;

    -- Code to derive values for variables which will decide the flow of this procedure

    l_comm_fc_req :='N';        -- Variable to identify whether commitment fundscheck is required
    l_act_fc_req :='N';         -- Variable to identify whether actual fundscheck is required
    l_adj_act_fc_req:='N';      -- Variable to identify whether adjusted actual fundscheck is required

    -- Deriving value for variable which identifies if FC required for AP commitment
    IF  p_adj_exp_item_id IS NULL THEN

        IF p_fc_document_type ='ALL' THEN  --PO normal lines import
           l_comm_fc_req := 'Y' ;
           l_act_fc_req  := 'Y' ;
        END IF;

    ELSIF p_adj_exp_item_id IS NOT NULL THEN

        IF p_fc_document_type ='ALL' THEN    --PO having fc enabled and adjusted ei's having fc enabled
           l_comm_fc_req := 'Y' ;
           l_adj_act_fc_req := 'Y';
        ELSIF p_fc_document_type ='CMT' THEN --PO having fc enabled and adjusted ei's having fc disabled
           l_comm_fc_req := 'Y' ;
        ELSIF p_fc_document_type ='ACT' THEN --PO having fc disabled and adjusted ei's having fc ENabled
           l_adj_act_fc_req := 'Y';
        END IF;

    END IF;

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of l_comm_fc_req '||l_comm_fc_req);
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of l_adj_act_fc_req   '||l_adj_act_fc_req  );
       log_message('log_message: ' || 'In insert_po_bc_packets - Value of l_act_fc_req  '||l_act_fc_req );
    END IF;

    -- Cursor to fetch data from pa_transaction_interface_table.This data is later used
    -- in autonomous fundscheck insert_ap_bc_pkts_autonomous procedure.

    IF ( l_adj_act_fc_req = 'Y'  OR l_act_fc_req  = 'Y' ) THEN

       -- call to clean up global plsql arrays used for storing interface data.
       init_xface_plsql_tables;

       OPEN c_pa_txn_interface_data;
       FETCH c_pa_txn_interface_data BULK COLLECT INTO
                                          g_xface_project_id_tbl,
					  g_xface_task_id_tbl,
					  g_xface_exp_type_tbl,
					  g_xface_ei_date_tbl,
					  g_xface_exp_org_id_tbl,
					  g_xface_bud_ver_id_tbl,
					  g_xface_Entered_Dr_tbl,
					  g_xface_Entered_Cr_tbl,
					  g_xface_acct_Dr_tbl,
				          g_xface_acct_Cr_tbl,
					  g_xface_Txn_Ccid_tbl,
					  g_xface_org_id_tbl,
					  g_xface_Txn_interface_tbl;
       CLOSE c_pa_txn_interface_data;

       IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'In insert_po_bc_packets - fetched data from interface table c_pa_txn_interface_data ');
       END IF;

    END IF; --IF ( l_adj_act_fc_req = 'Y'  OR l_act_fc_req  = 'Y' ) THEN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_po_bc_packets - calling insert_po_bc_packets_auto');
    END IF;

    insert_po_bc_packets_auto
                           (p_packet_id             => p_packet_id,
                            p_sys_ref2              => p_sys_ref2,
                            p_sys_ref4              => p_sys_ref4,
			    p_sys_ref3              => p_sys_ref3,
                            p_acct_raw_cost         => p_acct_raw_cost,
			    p_cmt_raw_cost          => p_cmt_raw_cost,
                            p_fc_document_type      => p_fc_document_type,
                            p_txn_source            => p_txn_source,
                            p_adj_exp_item_id       => p_adj_exp_item_id ,
			    p_txn_interface_id      => p_txn_interface_id,
			    p_comm_fc_req           => l_comm_fc_req,
                            p_act_fc_req            => l_act_fc_req,
                            p_adj_act_fc_req        => l_adj_act_fc_req );

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_po_bc_packets - End');
    END IF;

EXCEPTION
WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
      log_message('log_message:I n insert_po_bc_packets exception' || sqlerrm||' Returning from insert_po_bc_packets');
   END IF;
   RAISE;
END insert_po_bc_packets;

PROCEDURE insert_po_bc_packets_auto
                           (p_packet_id             IN NUMBER,
                            p_sys_ref2              IN NUMBER,
                            p_sys_ref4              IN NUMBER,
			    p_sys_ref3              IN NUMBER,
                            p_acct_raw_cost         IN NUMBER,
                            p_cmt_raw_cost          IN NUMBER,
                            p_fc_document_type      IN VARCHAR2,
                            p_txn_source            IN VARCHAR2,
                            p_adj_exp_item_id       IN NUMBER,
			    p_txn_interface_id      IN NUMBER,
			    p_comm_fc_req           IN VARCHAR2,
                            p_act_fc_req            IN VARCHAR2,
                            p_adj_act_fc_req        IN VARCHAR2) IS
CURSOR c_gen_raw_bc_pkt IS
SELECT Pa_Bc_Packets_s.NextVal
  FROM dual;

CURSOR c_get_po_LINE_id (p_po_dist_id NUMBER) IS
SELECT po_line_id
  FROM po_distributions_all
 WHERE po_distribution_id = p_po_dist_id;

Cursor C_po_Commitment Is
Select  bcc.Set_Of_Books_Id
       ,bcc.Period_Year
       ,bcc.Project_Id
       ,bcc.Task_Id
       ,bcc.Expenditure_Type
       ,bcc.Expenditure_Item_Date
       ,bcc.Expenditure_Organization_Id
       ,bcc.Budget_Version_Id
       ,bcc.budget_line_id -- R12 funds management uptake
       ,bcc.Document_Type
       ,bcc.Document_Header_Id
       ,bcc.Document_Distribution_Id
       ,bcc.Entered_Cr
       ,bcc.Entered_Dr
       ,bcc.Accounted_Cr
       ,bcc.Accounted_Dr
       ,bcc.Actual_Flag
       ,bcc.Txn_Ccid
       ,bcc.Je_Category_Name
       ,bcc.Je_Source_Name
       ,bcc.Org_Id
       ,bcc.Pa_Date
       ,bcc.bc_packet_id
       ,bcc.packet_id
       ,bcc.bc_commitment_id
 From  Pa_Bc_Commitments_all bcc,
       po_distributions pod
  -- R12 Funds management Uptake : For fixing performance issues removing the code for CC which is obsolete for R12
  -- Modifying code to use Index on document_header_id and document_distribution_id of bc commitments
where bcc.document_header_id = pod.po_header_id
  and bcc.document_distribution_id = pod.po_distribution_id
  and bcc.project_id = pod.project_id -- Bug# 4479105
  and bcc.task_id = pod.task_id --Bug# 4479105
  and bcc.expenditure_type = pod.expenditure_type -- Bug7620577
  and bcc.document_type = 'PO'
  and pod.po_header_id = p_sys_ref2
  and pod.po_distribution_id = p_sys_ref3
  and bcc.exp_item_id IS NULL -- Bug 5014138 : to pick just the encumbrance record
  and bcc.actual_flag = 'E'   -- Bug 5014138 : to pick just the encumbrance record
  and  bcc.Parent_Bc_Packet_Id is NULL
Order By  bcc.packet_id;

Cursor C_po_Bc_Packets Is
Select  bcc.Set_Of_Books_Id
       ,bcc.Period_Year
       ,bcc.Project_Id
       ,bcc.Task_Id
       ,bcc.Expenditure_Type
       ,bcc.Expenditure_Item_Date
       ,bcc.Expenditure_Organization_Id
       ,bcc.Budget_Version_Id
       ,bcc.budget_line_id -- R12 funds management uptake
       ,bcc.Document_Type
       ,bcc.Document_Header_Id
       ,bcc.Document_Distribution_Id
       ,bcc.Entered_Cr
       ,bcc.Entered_Dr
       ,bcc.Accounted_Cr
       ,bcc.Accounted_Dr
       ,bcc.Actual_Flag
       ,bcc.Txn_Ccid
       ,bcc.Je_Category_Name
       ,bcc.Je_Source_Name
       ,bcc.Org_Id
       ,bcc.Pa_Date
       ,bcc.bc_packet_id
       ,bcc.packet_id
  -- R12 Funds management Uptake : For fixing performance issues removing the code for CC which is obsolete for R12
  -- Modifying code to use Index on document_header_id and document_distribution_id of bc commitments
 From  Pa_Bc_packets bcc,
       po_distributions pod
where bcc.document_header_id = pod.po_header_id
  and bcc.document_distribution_id = pod.po_distribution_id
  and bcc.project_id = pod.project_id -- Bug# 4479105
  and bcc.task_id = pod.task_id --Bug# 4479105
  and bcc.expenditure_type = pod.expenditure_type -- Bug7620577
  and bcc.document_type = 'PO'
  and pod.po_header_id = p_sys_ref2
  and pod.po_distribution_id = p_sys_ref3
  and bcc.exp_item_id IS NULL -- Bug 5014138 : to pick just the encumbrance record
  and bcc.actual_flag = 'E'   -- Bug 5014138 : to pick just the encumbrance record
  and  bcc.Status_Code in('A','C')
  and  bcc.Parent_Bc_Packet_Id is NULL
Order By  bcc.packet_id;

l_rec_bc_comm_exists      VARCHAR2(1);  -- Variable to identify whether commitment record exists in pa_bc_commitments
l_rec_pkt_comm_exists     VARCHAR2(1);  -- Variable to identify whether commitment record exists in pa_bc_packets
l_Raw_Bc_Packet_Id        pa_bc_packets.bc_packet_id%TYPE;
l_po_line_id              po_distributions_all.po_line_id%TYPE;

BEGIN

    IF PG_DEBUG = 'Y' THEN
       log_message('log_message: ' || 'In insert_po_bc_packets_auto - Start');
    END IF;

       /* cwk */

    IF p_txn_source in ('PO RECEIPT NRTAX', 'AP NRTAX') THEN
      IF nvl(Pa_Pjc_Cwk_Utils.Is_rate_based_line( null, p_sys_ref3),'N') = 'Y' THEN
        OPEN c_get_po_LINE_id(p_sys_ref3);
        FETCH c_get_po_LINE_id into l_po_line_id;
        CLOSE c_get_po_LINE_id;
      END IF;

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_po_bc_packets_auto - After fetching CWK related data l_po_line_id'||l_po_line_id);
         END IF;
    END IF;

    -- Code to derive values for variables which will decide the flow of this procedure

    l_rec_bc_comm_exists:='N';  -- Variable to identify whether commitment record exists in pa_bc_commitments
    l_rec_pkt_comm_exists:='N'; -- Variable to identify whether commitment record exists in pa_bc_packets

    IF p_comm_fc_req ='Y' OR p_act_fc_req  = 'Y' THEN

      IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'In insert_po_bc_packets_auto - Fetchign data from bc commitments');
      END IF;

      Open C_po_Commitment ;

      clear_plsql_tables;

      FETCH C_po_Commitment BULK COLLECT INTO
                g_sob_Id_tbl,
                g_Period_Year_tbl,
                g_project_id_tbl,
                g_task_id_tbl,
                g_exp_type_tbl,
                g_ei_date_tbl,
                g_exp_org_id_tbl,
                g_bud_ver_id_tbl,
                g_budget_line_id_tbl, -- R12 funds management uptake
                g_Document_Type_tbl,
                g_Doc_Header_Id_tbl,
                g_Doc_dist_Id_tbl,
                g_Entered_Cr_tbl,
                g_Entered_Dr_tbl,
                g_acct_Cr_tbl,
                g_acct_Dr_tbl,
                g_Actual_Flag_tbl,
                g_Txn_Ccid_tbl,
                g_Je_Catg_Name_tbl,
                g_Je_sorce_Name_tbl,
                g_org_id_tbl,
                g_Pa_Date_tbl,
                g_bc_packet_id_tbl,
                g_packet_id_tbl,
		g_bc_comt_id_tbl LIMIT 1;  /* Intended for the bug#9234914 */

     IF g_bc_packet_id_tbl.COUNT <> 0 THEN
        l_rec_bc_comm_exists  := 'Y';
     END IF;
     CLOSE C_po_Commitment;

     IF l_rec_bc_comm_exists = 'N' THEN

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'In insert_po_bc_packets_auto - Fetchign data from bc packets');
        END IF;

        OPEN C_po_Bc_Packets;
        FETCH C_po_Bc_Packets BULK COLLECT INTO
                g_sob_Id_tbl,
                g_Period_Year_tbl,
                g_project_id_tbl,
                g_task_id_tbl,
                g_exp_type_tbl,
                g_ei_date_tbl,
                g_exp_org_id_tbl,
                g_bud_ver_id_tbl,
                g_budget_line_id_tbl, -- R12 funds management uptake
                g_Document_Type_tbl,
                g_Doc_Header_Id_tbl,
                g_Doc_dist_Id_tbl,
                g_Entered_Cr_tbl,
                g_Entered_Dr_tbl,
                g_acct_Cr_tbl,
                g_acct_Dr_tbl,
                g_Actual_Flag_tbl,
                g_Txn_Ccid_tbl,
                g_Je_Catg_Name_tbl,
                g_Je_sorce_Name_tbl,
                g_org_id_tbl,
                g_Pa_Date_tbl,
                g_bc_packet_id_tbl,
                g_packet_id_tbl LIMIT 1;  /* Intended for the bug#9234914 */

        IF g_bc_packet_id_tbl.COUNT <> 0 THEN
           l_rec_pkt_comm_exists := 'Y' ;
        END IF;
        CLOSE C_po_Bc_Packets;

      END IF;

     IF l_rec_bc_comm_exists ='Y' OR l_rec_pkt_comm_exists  = 'Y' THEN

      FOR i IN g_bc_packet_id_tbl.FIRST..g_bc_packet_id_tbl.LAST LOOP


        -- Generate a packet identifier for RAW record that
        -- needs to be inserted into Pa BC Packets

        IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'In insert_po_bc_packets_auto - Generating new Bc packet Id for reversing RAW act and commitment line');
        END IF;

        OPEN  c_gen_raw_bc_pkt;
        FETCH c_gen_raw_bc_pkt INTO l_Raw_Bc_Packet_Id;
        CLOSE c_gen_raw_bc_pkt;

        IF PG_DEBUG = 'Y' THEN
          log_message('log_message: ' || 'In insert_po_bc_packets_auto - Bc Packet Id = ' || l_Raw_Bc_Packet_Id ||'Packet Id = ' || p_packet_id);
        END IF;

        IF l_rec_bc_comm_exists = 'Y' AND p_comm_fc_req ='Y' THEN

          IF PG_DEBUG = 'Y' THEN
           log_message('log_message: ' || 'In insert_po_bc_packets_auto - Before inserting PO reversing raw and burden line from bc commitments');
          END IF;

          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
                ,Budget_line_id -- R12 funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Exp_Item_Id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
		,encumbrance_type_id
		,document_header_id_2
		,document_distribution_type
                )
         Select  p_packet_id
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,l_Raw_Bc_Packet_id,Pa_Bc_Packets_s.NextVal)
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,NULL,l_Raw_Bc_Packet_id)
                ,bcc.Set_Of_Books_Id
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,bcc.Period_Year
                ,bcc.Pa_Date -- pa_date on raw is used for burden line
                ,bcc.Project_Id
                ,bcc.Task_Id
                ,bcc.Expenditure_Type
                ,bcc.Expenditure_Item_Date
                ,bcc.Expenditure_Organization_Id
                ,bcc.Budget_Version_Id
                ,bcc.Budget_line_id -- R12 funds management uptake
                ,bcc.Document_Type
                ,bcc.Document_Header_Id
                ,bcc.Document_Distribution_Id
                ,DECODE(bcc.parent_bc_packet_id,NULL,
                                                (-1 * p_cmt_raw_cost), --rshaik
                                                (0 - (pa_currency.round_trans_currency_amt1((((nvl(bcc.Entered_dr,0)-nvl(bcc.Entered_Cr,0))/
                                                  decode((nvl(g_Entered_Dr_tbl(i),0)-nvl(g_Entered_Cr_tbl(i),0)),
                                                  0,1,(nvl(g_Entered_Dr_tbl(i),0)-nvl(g_Entered_Cr_tbl(i),0))))
                                                  *p_cmt_raw_cost), G_accounting_currency_code))))
                ,0
                ,DECODE(bcc.parent_bc_packet_id,NULL,
                                                (-1 * p_cmt_raw_cost)
                                                ,(0 - (pa_currency.round_trans_currency_amt1((((nvl(bcc.Accounted_dr,0)-nvl(bcc.Accounted_cr,0))/
                                                  decode((nvl(g_acct_Dr_tbl(i),0)-nvl(g_acct_Cr_tbl(i),0))
                                                  ,0,1,(nvl(g_acct_Dr_tbl(i),0)-nvl(g_acct_Cr_tbl(i),0))))
                                                  *p_cmt_raw_cost), G_accounting_currency_code))))
                ,0
                ,g_Request_Id
                ,G_Program_Id
                ,G_PROG_APPL_ID
                ,sysdate
                ,bcc.Actual_Flag
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,G_CONC_LOGIN_ID
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,bcc.Txn_Ccid
                ,'R'
                ,'P'
                ,decode(p_txn_source, 'AP NRTAX' , g_Je_Catg_Name_tbl(i)||' Tax', g_Je_Catg_Name_tbl(i))
                ,bcc.Je_Source_Name
                ,bcc.Org_Id
                ,X_ei_id
                ,l_po_line_id
		,'EXP'
		,X_ei_id
		,1
		,p_txn_interface_id --REL12
		,bcc.encumbrance_type_id
		,bcc.document_header_id_2
		,bcc.document_distribution_type
          From  Pa_Bc_Commitments_all bcc
         Where  bcc.bc_commitment_id in (SELECT bcc1.bc_commitment_id
                                           FROM PA_BC_COMMITMENTS_ALL bcc1
                                          WHERE bcc1.document_header_id = p_sys_ref2
                                            AND bcc1.document_distribution_id = p_sys_ref3
					    AND bcc1.parent_bc_packet_id = g_bc_packet_id_tbl(i)
                                          UNIOn ALL
                                         SELECT g_bc_comt_id_tbl(i)
                                           FROM DUAL);

        IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'In insert_po_bc_packets_auto - Inserted '||SQL%ROWCOUNT||' PO reversing raw and burden line(s) into bc packets');
        END IF;

       END IF; --IF l_rec_bc_comm_exists = 'Y' AND p_comm_fc_req ='Y' THEN


       IF l_rec_pkt_comm_exists='Y' AND p_comm_fc_req ='Y' THEN

          IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_po_bc_packets_auto - Before inserting the PO raw and burden lines from Bc Packets');
          END IF;

          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
                ,Budget_line_id -- R12 funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Exp_Item_Id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
		,encumbrance_type_id
		,document_header_id_2
		,document_distribution_type
                )
          Select p_packet_id
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,l_Raw_Bc_Packet_id,Pa_Bc_Packets_s.NextVal)
                ,decode(bcc.Parent_Bc_Packet_Id,NULL,NULL,l_Raw_Bc_Packet_id)
                ,bcc.Set_Of_Books_Id
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,bcc.Period_Year
                ,bcc.pa_date
                ,bcc.Project_Id
                ,bcc.Task_Id
                ,bcc.Expenditure_Type
                ,bcc.Expenditure_Item_Date
                ,bcc.Expenditure_Organization_Id
                ,bcc.Budget_Version_Id
                ,bcc.Budget_line_id -- R12 funds management uptake
                ,bcc.Document_Type
                ,bcc.Document_Header_Id
                ,bcc.Document_Distribution_Id
                ,DECODE(bcc.parent_bc_packet_id,NULL,
                                                -1 * p_cmt_raw_cost,
                                                (0 - (pa_currency.round_trans_currency_amt1((((nvl(bcc.Entered_dr,0)-nvl(bcc.Entered_Cr,0))/
                                                  decode((nvl(g_Entered_Dr_tbl(i),0)-nvl(g_Entered_Cr_tbl(i),0)),
                                                  0,1,(nvl(g_Entered_Dr_tbl(i),0)-nvl(g_Entered_Cr_tbl(i) ,0))))
                                                  *p_cmt_raw_cost), G_accounting_currency_code))))
                ,0
                ,DECODE(bcc.parent_bc_packet_id,NULL,
                                                -1 * p_cmt_raw_cost
                                                ,(0 - (pa_currency.round_trans_currency_amt1((((nvl(bcc.Accounted_dr,0)-nvl(bcc.Accounted_cr,0))/
                                                  decode((nvl(g_acct_Dr_tbl(i),0)-nvl(g_acct_Cr_tbl(i),0))
                                                  ,0,1,(nvl(g_acct_Dr_tbl(i),0)-nvl(g_acct_Cr_tbl(i),0))))
                                                  *p_cmt_raw_cost), G_accounting_currency_code))))
                ,0
                ,g_Request_Id
                ,G_Program_Id
                ,G_PROG_APPL_ID
                ,sysdate
                ,bcc.Actual_Flag
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,G_CONC_LOGIN_ID
                ,sysdate
                ,G_CONC_LOGIN_ID
                ,bcc.Txn_Ccid
                ,'R'
                ,'P'
                ,bcc.Je_Category_Name
                ,bcc.Je_Source_Name
                ,bcc.Org_id
                ,X_ei_id
                ,l_po_line_id
		,'EXP'
		,X_ei_id
		,1
		,p_txn_interface_id  --REL12
		,bcc.encumbrance_type_id
		,bcc.document_header_id_2
		,bcc.document_distribution_type
          From  Pa_Bc_Packets bcc
         Where  bcc.packet_id = g_packet_id_tbl(i)
           and  bcc.bc_packet_id in (SELECT bcc1.bc_packet_id
                                       FROM PA_BC_PACKETS bcc1
                                      WHERE bcc1.packet_id = g_packet_id_tbl(i)
				       and  bcc1.parent_bc_packet_id = g_bc_packet_id_tbl(i)
				       and  bcc1.Status_Code in ('A','C')
                                     UNIOn ALL
                                     SELECT g_bc_packet_id_tbl(i)
                                       FROM DUAL);

         IF PG_DEBUG = 'Y' THEN
         log_message('log_message: ' || 'In insert_po_bc_packets_auto - Inserted '||SQL%ROWCOUNT||' PO reversing raw and burden line(s) into bc packets');
        END IF;

      END IF; --IF l_rec_pkt_comm_exists='Y' AND p_comm_fc_req ='Y' THEN

      IF p_act_fc_req = 'Y' THEN

         -- Insert the positive records for the raw line with
         -- document type 'EXP'.

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_po_bc_packets_auto - Before inserting ACTUAL raw line from bc packets');
         END IF;

          Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,gl_date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
                ,Budget_line_id -- R12 funds management uptake
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
                )
          Select p_Packet_Id
                ,Pa_Bc_Packets_s.NextVal
                ,-1
                ,g_sob_Id_tbl(i)
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,g_Period_Year_tbl(i)
                ,g_Pa_Date_tbl(i)
                ,g_project_id_tbl(i)
                ,g_task_id_tbl(i)
                ,g_exp_type_tbl(i)
                ,g_ei_date_tbl(i)
                ,g_exp_org_id_tbl(i)
                ,g_bud_ver_id_tbl(i)
                ,g_budget_line_id_tbl(i) -- R12 funds management uptake
                ,'EXP'
                ,X_ei_id
                ,1
                ,nvl(p_acct_raw_cost,0)
                ,0
                ,nvl(p_acct_raw_cost,0)
                ,0
                ,g_Request_Id
                ,g_program_id
                ,g_prog_appl_id
                ,sysdate
                ,'A'
                ,sysdate
                ,g_conc_login_id
                ,g_conc_login_id
                ,sysdate
                ,g_conc_login_id
                ,g_Txn_Ccid_tbl(i)
                ,'N'
                ,'P'
                ,'Expenditures'
                ,'Project Accounting'
                ,g_org_id_tbl(i)
                ,l_po_line_id
		,'EXP'
		,x_Ei_Id
		,1
		,p_txn_interface_id  --REL12
          From  Pa_Budget_Versions bv,
                Pa_Budget_Types bt,
                pa_budgetary_control_options pbct
         Where  bt.budget_type_Code = bv.budget_type_Code
           and  bt.budget_amount_code = 'C'
           and  bv.project_id = g_project_id_tbl(i)
           and  bv.current_flag = 'Y'
           and  pbct.project_id = bv.project_id
           and  pbct.BDGT_CNTRL_FLAG = 'Y'
           and  pbct.BUDGET_TYPE_CODE = bv.budget_type_code
           and (pbct.EXTERNAL_BUDGET_CODE = 'GL'
                OR
                pbct.EXTERNAL_BUDGET_CODE is NULL
                );

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_po_bc_packets_auto - Inserted '||SQL%ROWCOUNT||' ACTUAL raw line(s) into bc packets');
         END IF;

       END IF;--IF p_act_fc_req = 'Y' THEN
      END LOOP;
     END IF; -- l_rec_bc_comm_exists ='Y' OR l_rec_pkt_comm_exists  = 'Y' THEN
    END IF; -- p_comm_fc_req ='Y' OR p_act_fc_req  = 'Y' THEN

     IF p_adj_act_fc_req = 'Y' THEN

	 IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_po_bc_packets_auto - Before inserting adjusted ACTUAL raw line from transaction import table');
         END IF;

         FORALL i IN 1 .. g_xface_Txn_interface_tbl.count
         Insert Into Pa_Bc_Packets
                (Packet_Id
                ,Bc_Packet_Id
                ,Parent_Bc_Packet_Id
                ,Set_Of_Books_Id
                ,Gl_Date
                ,Period_Name
                ,Period_Year
                ,Pa_Date
                ,Project_Id
                ,Task_Id
                ,Expenditure_Type
                ,Expenditure_Item_Date
                ,Expenditure_Organization_Id
                ,Budget_Version_Id
                ,Document_Type
                ,Document_Header_Id
                ,Document_Distribution_Id
                ,Entered_Dr
                ,Entered_Cr
                ,Accounted_Dr
                ,Accounted_Cr
                ,Request_Id
                ,Program_Id
                ,Program_Application_Id
                ,Program_Update_Date
                ,Actual_Flag
                ,Last_Update_Date
                ,Last_Updated_By
                ,Created_By
                ,Creation_Date
                ,Last_Update_Login
                ,Txn_Ccid
                ,Burden_Cost_Flag
                ,Status_Code
                ,Je_Category_Name
                ,Je_Source_Name
                ,Org_id
                ,Document_Line_Id
		,reference1
		,reference2
		,reference3
		,txn_interface_id  --REL12
                )
          Select p_Packet_Id
                ,Pa_Bc_Packets_s.NextVal
                ,-1
                ,g_sobid
                ,G_FC_Gl_Date
                ,G_FC_Period_Name
                ,G_FC_Period_Year
                ,G_PaDate
                ,g_xface_project_id_tbl(i)
                ,g_xface_task_id_tbl(i)
                ,g_xface_exp_type_tbl(i)
                ,g_xface_ei_date_tbl(i)
                ,g_xface_exp_org_id_tbl(i)
                ,g_xface_bud_ver_id_tbl(i)
                ,'EXP'
                ,X_ei_id
                ,1
                ,g_xface_Entered_Dr_tbl(i)
                ,g_xface_acct_Cr_tbl(i)
                ,g_xface_acct_Dr_tbl(i)
                ,g_xface_acct_Cr_tbl(i)
                ,g_Request_Id
                ,g_program_id
                ,g_prog_appl_id
                ,sysdate
                ,'A' --Actual_Flag
                ,sysdate
                ,g_conc_login_id
                ,g_conc_login_id
                ,sysdate
                ,g_conc_login_id
                ,g_xface_Txn_Ccid_tbl(i)
                ,'N'
                ,'P'
                ,'Expenditures'
                ,'Project Accounting'
                ,g_xface_org_id_tbl(i)
                ,l_po_line_id
		,'EXP'
		,X_Ei_Id
		,1
		,g_xface_Txn_interface_tbl(i)
          From  dual;

         IF PG_DEBUG = 'Y' THEN
            log_message('log_message: ' || 'In insert_po_bc_packets_auto - Inserted '||SQL%ROWCOUNT||' ACTUAL raw line(s) into bc packets');
         END IF;

       END IF;

 COMMIT;
 IF PG_DEBUG = 'Y' THEN
     log_message('log_message: ' || 'In insert_po_bc_packets_auto - End');
 END IF;

EXCEPTION
WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
      log_message('log_message: insert_po_bc_packets_auto ' || sqlerrm||' Returning from insert_po_bc_packets_auto');
   END IF;
   RAISE;
END insert_po_bc_packets_auto;

-- BUG: 4600792 PQE:R12 CHANGE AWARD END WHEN ENCUMBRANCE EXISTS, IMPORT ENC REVERSALS FOR CLOSE
--
/* Added the following  procedure for the bug 4138033 */
PROCEDURE  Set_GVal_ProjTskEi_Date(L_Validate_Proj_Tsk_Ei_Date   IN VARCHAR2) IS
BEGIN
     G_Validate_Proj_Tsk_Ei_Date := L_Validate_Proj_Tsk_Ei_Date;
END Set_GVal_ProjTskEi_Date;

/* Added the following function for the bug 4138033 */
FUNCTION   Get_GVal_ProjTskEi_Date RETURN VARCHAR2 IS
BEGIN
     Return G_Validate_Proj_Tsk_Ei_Date;
END;

END PA_TRX_IMPORT;

/

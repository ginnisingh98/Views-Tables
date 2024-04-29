--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_DETAIL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_DETAIL_PROCESS" as
/* $Header: PAICINDB.pls 120.7.12000000.2 2007/02/12 02:06:09 lkan ship $ */

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');


  TYPE prv_class_rec IS RECORD ( DENOM_TP_CURRENCY_CODE     VARCHAR2(15),
                                 DENOM_TRANSFER_PRICE       NUMBER,
                                 TASK_ID                    NUMBER,
                                 AMOUNT                     NUMBER,
                                 ACCT_CURRENCY_CODE         VARCHAR2(15),
                                 ACCT_TP_RATE_TYPE          VARCHAR2(30),
                                 ACCT_TP_RATE_DATE          DATE,
                                 ACCT_TP_EXCHANGE_RATE      NUMBER,
                                 DR_CODE_COMBINATION_ID     NUMBER,
                                 CR_CODE_COMBINATION_ID     NUMBER,
                                 REFERENCE_2                VARCHAR2(1),
                                 REFERENCE_1                VARCHAR2(30),
                                 EXPENDITURE_ITEM_ID        NUMBER,
                                 EXPENDITURE_ITEM_DATE      DATE,
                                 CDL_LINE_NUM               NUMBER,
                                 PROJECT_ID                 NUMBER,
                                 CROSS_CHARGE_CODE          VARCHAR2(1),
                                 SYSTEM_LINKAGE_FUNCTION  VARCHAR2(3), /* added for 3857986 */
				 /*Added for cross proj*/
				 TP_AMT_TYPE_CODE           VARCHAR2(30),
				 PROJECT_TP_RATE_TYPE       VARCHAR2(30),
				 PROJECT_TP_RATE_DATE       VARCHAR2(30),
				 PROJECT_TP_EXCHANGE_RATE   VARCHAR2(30),
				 PROJECT_TRANSFER_PRICE     VARCHAR2(30),
				 PROJFUNC_TP_RATE_TYPE       VARCHAR2(30),
				 PROJFUNC_TP_RATE_DATE       VARCHAR2(30),
				 PROJFUNC_TP_EXCHANGE_RATE   VARCHAR2(30),
				 PROJFUNC_TRANSFER_PRICE     VARCHAR2(30),

				 PROJECT_TP_CURRENCY_CODE    VARCHAR2(15),
				 PROJFUNC_TP_CURRENCY_CODE   VARCHAR2(15)
				 /* End for cross proj*/
				 );



--Local Package Body Definition
  P_Insert_tab  PA_INVOICE_DETAIL_PKG.inv_rec_tab;
  P_Delete_tab  PA_INVOICE_DETAIL_PKG.inv_rec_tab;
  P_Update_tab  PA_INVOICE_DETAIL_PKG.inv_rec_tab;

--EI Table for marking status as IC Processed.
  P_Ei_table    PA_PLSQL_DATATYPES.IdTabTyp;
  I_Ei_count    number;

--storing Line num
  I_Line_num    Number;

--Table parameter of Transfer Price

 I_DENOM_CURRENCY_CODE            PA_PLSQL_DATATYPES.Char15TabTyp;
 I_DENOM_BILL_AMOUNT              PA_PLSQL_DATATYPES.Char30TabTyp;
 I_ACCT_CURRENCY_CODE             PA_PLSQL_DATATYPES.Char15TabTyp;
 I_BILL_AMOUNT                    PA_PLSQL_DATATYPES.Char30TabTyp;
 I_ACCT_RATE_TYPE                 PA_PLSQL_DATATYPES.Char30TabTyp;
 I_ACCT_RATE_DATE                 PA_PLSQL_DATATYPES.Char30TabTyp;
 I_ACCT_EXCHANGE_RATE             PA_PLSQL_DATATYPES.Char30TabTyp;
 I_REV_CODE_COMBINATION_ID        PA_PLSQL_DATATYPES.IdTabTyp;
 I_OUTPUT_VAT_TAX_ID              PA_PLSQL_DATATYPES.IdTabTyp;
 I_OUTPUT_TAX_CODE                PA_PLSQL_DATATYPES.Char30TabTyp;
 I_OUTPUT_TAX_EXEMPT_FLAG         PA_PLSQL_DATATYPES.Char1TabTyp;
 I_TAX_EXEMPT_REASON_CODE         PA_PLSQL_DATATYPES.Char80TabTyp;
 I_OUTPUT_TAX_EXEMPT_NUMBER       PA_PLSQL_DATATYPES.Char30TabTyp;
 I_PROJACCT_CURRENCY_CODE         PA_PLSQL_DATATYPES.Char30TabTyp;
 I_MARKUP_CALC_BASE_CODE          PA_PLSQL_DATATYPES.Char1TabTyp;
 I_IND_COMPILED_SET_ID            PA_PLSQL_DATATYPES.IdTabTyp;
 I_RULE_PERCENTAGE                PA_PLSQL_DATATYPES.Char30TabTyp;
 I_BILL_RATE                      PA_PLSQL_DATATYPES.Char30TabTyp;
 I_BILL_MARKUP_PERCENTAGE         PA_PLSQL_DATATYPES.Char30TabTyp;
 I_BASE_AMOUNT                    PA_PLSQL_DATATYPES.Char30TabTyp;
 I_SCHEDULE_LINE_PERCENTAGE       PA_PLSQL_DATATYPES.Char30TabTyp;
 I_MRC_REQD_FLAG                  PA_PLSQL_DATATYPES.Char1TabTyp;

-- Provider reclass enabled or not
 I_PRV_ENABLED                    PA_PLSQL_DATATYPES.Char1TabTyp;
 I_EXP_ITEM_USED                  PA_PLSQL_DATATYPES.Char1TabTyp;

/* Added for cross proj*/
I_TP_AMT_TYPE_CODE          PA_PLSQL_DATATYPES.Char30TabTyp;
I_PROJECT_TP_RATE_TYPE      PA_PLSQL_DATATYPES.char30tabtyp;
I_PROJECT_TP_RATE_DATE      PA_PLSQL_DATATYPES.char30tabtyp;
I_PROJECT_TP_EXCHANGE_RATE  PA_PLSQL_DATATYPES.char30tabtyp;
I_PROJECT_TRANSFER_PRICE    PA_PLSQL_DATATYPES.char30tabtyp;
I_PROJFUNC_TP_RATE_TYPE     PA_PLSQL_DATATYPES.char30tabtyp;
I_PROJFUNC_TP_RATE_DATE     PA_PLSQL_DATATYPES.char30tabtyp;
I_PROJFUNC_TP_EXCHANGE_RATE PA_PLSQL_DATATYPES.char30tabtyp;
I_PROJFUNC_TRANSFER_PRICE   PA_PLSQL_DATATYPES.char30tabtyp;

I_PROJECT_TP_CURRENCY_CODE  PA_PLSQL_DATATYPES.char15tabtyp;
I_PROJFUNC_TP_CURRENCY_CODE PA_PLSQL_DATATYPES.char15tabtyp;
/*End for cross proj*


/* CBGA and project Jobs */

   I_tp_job_id                      PA_PLSQL_DATATYPES.IdTabTyp;
   I_prov_proj_bill_job_id          PA_PLSQL_DATATYPES.IdTabTyp;

 /* Added for bug 3857986 --  The following variables are used during call to get_period_information. */

  l_return_status NUMBER;
  l_error_code   VARCHAR2(1000);
  l_error_stage  NUMBER;

  l_dummy VARCHAR2(15);
  l_dummy1 VARCHAR2(15);
  l_dummy2 VARCHAR2(15);
  l_dummy3 VARCHAR2(15);


  /* End addition for bug 3857986 */

--Procedure to initialize global counter
PROCEDURE init
IS
BEGIN
  PA_IC_INV_UTILS.log_message('Initializing Package Global variable......');
  PA_INVOICE_DETAIL_PKG.G_Ins_count  := 0;
  PA_INVOICE_DETAIL_PKG.G_Del_count  := 0;
  PA_INVOICE_DETAIL_PKG.G_Upd_count  := 0;
  I_EI_count                         := 0;
  PA_CC_BL_PROCESS.g_dcnt            := 0;
  PA_CC_BL_PROCESS.g_ucnt            := 0;
  PA_CC_BL_PROCESS.g_icnt            := 0;

/* Initialize the BL Package for Provider Reclass */
  PA_CC_BL_process.initialization(
        p_request_id     =>PA_IC_INV_UTILS.G_REQUEST_ID
       ,p_program_application_id =>PA_IC_INV_UTILS.G_PROGRAM_APPLICATION_ID
       ,p_program_id     => PA_IC_INV_UTILS.G_PROGRAM_ID
       ,p_user_id        => PA_IC_INV_UTILS.G_LAST_UPDATED_BY
       ,p_login_id       => PA_IC_INV_UTILS.G_LAST_UPDATE_LOGIN
       ,p_prvdr_org_id   => PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID
       ,p_primary_sob_id => PA_MC_INVOICE_DETAIL_PKG.G_SOB);

END init;

-- Function to get invoice detail id from sequence
FUNCTION get_nextval
RETURN NUMBER
IS
 l_nextval    NUMBER;
BEGIN

 SELECT pa_draft_invoice_details_s.nextval
 INTO   l_nextval
 FROM   SYS.DUAL;

 RETURN(l_nextval);

EXCEPTION
 WHEN OTHERS
 THEN
      RAISE;
END get_nextval;

-- Populate the delete table for CC Distribution
PROCEDURE delete_all_cc_dist (P_Draft_Inv_Id       IN Number,
                              P_index              IN number)
IS
  cursor get_cc_del_lines
  is
        select rowid,cc_dist_line_id
        from   pa_cc_dist_lines
        where  reference_1      = to_char(P_Draft_Inv_Id);
BEGIN
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.delete_all_cc_dist ...');
  END IF;
  for cc_get_cc_del_lines in get_cc_del_lines
  loop
--Increase the delete counter
     PA_CC_BL_PROCESS.g_dcnt := PA_CC_BL_PROCESS.g_dcnt + 1;
--Load the delete record
     PA_CC_BL_PROCESS.g_del_rec(PA_CC_BL_PROCESS.g_dcnt).CcdRowId
                             := cc_get_cc_del_lines.rowid;
     PA_CC_BL_PROCESS.g_del_rec(PA_CC_BL_PROCESS.g_dcnt).cc_dist_line_id
                             := cc_get_cc_del_lines.cc_dist_line_id;
  end loop;
--Set the expenditure Item as Used
  I_EXP_ITEM_USED(P_index) := 'Y';

EXCEPTION
  When Others
  Then
       raise;
END delete_all_cc_dist;

-- Populate the delete table for CC Distribution
PROCEDURE delete_cc_dist (P_CC_REC   IN get_cc_dist%rowtype,
                          P_index    IN number)
IS
BEGIN
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.delete_cc_dist ...');
  END IF;
--Increase the delete counter
  PA_CC_BL_PROCESS.g_dcnt := PA_CC_BL_PROCESS.g_dcnt + 1;
--Load the delete record
  PA_CC_BL_PROCESS.g_del_rec(PA_CC_BL_PROCESS.g_dcnt).CcdRowId
                             := P_CC_REC.rowid;
  PA_CC_BL_PROCESS.g_del_rec(PA_CC_BL_PROCESS.g_dcnt).cc_dist_line_id
                             := P_CC_REC.cc_dist_line_id;
--Set the expenditure Item as Used
  I_EXP_ITEM_USED(P_index) := 'Y';

EXCEPTION
  When Others
  Then
       raise;
END delete_cc_dist;


--Procedure to reverse the CC Distribution
PROCEDURE reverse_cc_dist ( P_INV_DET_ID   IN NUMBER,
                            P_EI_DATE      IN DATE,
                            P_Sys_linkage  IN VARCHAR2,  /* Added for 3857986 */
                            P_CC_REC       IN OUT NOCOPY  get_cc_dist%rowtype,
                            P_index        IN number)
IS
   l_pa_date date; /* Added for Bug2276729 */
BEGIN
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.reverse_cc_dist ...');
  END IF;
  If ((P_CC_REC.TRANSFER_STATUS_CODE = 'P')
  and (P_CC_REC.LINE_NUM_REVERSED IS NULL ))
  Then
     delete_cc_dist (P_CC_REC,P_index);
     P_CC_REC.line_num := P_CC_REC.line_num - 1;
  Elsif (P_CC_REC.LINE_NUM_REVERSED IS NULL )
  Then
    /* This part will reverse the existing CC Dist */
     PA_CC_BL_PROCESS.g_ucnt := PA_CC_BL_PROCESS.g_ucnt + 1;
     PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).upd_type := 'R';
     PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).CcdRowId :=
                                P_CC_REC.rowid;
   /* This part will create reversing CC Distribution */
     PA_CC_BL_PROCESS.g_icnt := PA_CC_BL_PROCESS.g_icnt + 1;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).expenditure_item_id
                             := P_CC_REC.expenditure_item_id;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_currency_code
                             := P_CC_REC.acct_currency_code;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_tp_exchange_rate
                             := P_CC_REC.acct_tp_exchange_rate;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_tp_rate_date
                             := P_CC_REC.acct_tp_rate_date;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_tp_rate_type
                             := P_CC_REC.acct_tp_rate_type;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).amount
                             := (-1)* P_CC_REC.amount;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).bill_markup_percentage
                             := P_CC_REC.bill_markup_percentage;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).bill_rate
                             := P_CC_REC.bill_rate;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).cc_rejection_code
                             := NULL;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).cr_code_combination_id
                             := P_CC_REC.cr_code_combination_id;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).cross_charge_code
                             := P_CC_REC.cross_charge_code;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).denom_tp_currency_code
                             := P_CC_REC.denom_tp_currency_code;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).denom_transfer_price
                             := (-1)*P_CC_REC.denom_transfer_price;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).dist_line_id_reversed
                             := P_CC_REC.cc_dist_line_id;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).dr_code_combination_id
                             := P_CC_REC.dr_code_combination_id;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).ind_compiled_set_id
                             := P_CC_REC.ind_compiled_set_id;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).line_num
                             := P_CC_REC.line_num + 1;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).line_num_reversed
                             := P_CC_REC.line_num ;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).line_type
                             := 'PC';
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).markup_calc_base_code
                             := P_CC_REC.markup_calc_base_code;

/* Bug 2276729 - Begin populating the gl_date also.  ** Commented for bug 3857986
***CBGA - Added new parameter org_id to get_pa_date***
l_pa_date :=  pa_utils2.get_pa_date(P_EI_DATE,SYSDATE, PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID);
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_date
                             := l_pa_date;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_date
:= pa_utils2.get_prvdr_gl_date(l_pa_date,PA_IC_INV_UTILS.G_PROGRAM_APPLICATION_ID, PA_MC_INVOICE_DETAIL_PKG.G_SOB);

** Bug 2276729 - End ** Commented for 3857986 - End */

/* Added for 3857986 */
BEGIN
 pa_utils2.get_period_information(
                           p_expenditure_item_date     => P_EI_DATE
                          ,p_expenditure_id            => NULL
                          ,p_system_linkage_function   => P_Sys_linkage
                          ,p_line_type                 => 'R'
                          ,p_prvdr_raw_pa_date         => NULL
                          ,p_recvr_raw_pa_date         => NULL
                          ,p_prvdr_raw_gl_date         => NULL
                          ,p_recvr_raw_gl_date         => NULL
                          ,p_prvdr_org_id              => PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID
                          ,p_recvr_org_id              => NULL
                          ,p_prvdr_sob_id              => PA_MC_INVOICE_DETAIL_PKG.G_SOB
                          ,p_recvr_sob_id              => NULL
                          ,p_calling_module            => 'CCDL'
                          ,x_prvdr_pa_date             => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_date
                          ,x_prvdr_pa_period_name      => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_period_name
                          ,x_prvdr_gl_date             => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_date
                          ,x_prvdr_gl_period_name      => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_period_name
                          ,x_recvr_pa_date             => l_dummy
                          ,x_recvr_pa_period_name      => l_dummy1
                          ,x_recvr_gl_date             => l_dummy2
                          ,x_recvr_gl_period_name      => l_dummy3
                          ,x_return_status             => l_return_status
                          ,x_error_code                => l_error_code
                          ,x_error_stage               => l_error_stage);


EXCEPTION
  When Others
  Then
       raise;
END;

/* Added for 3857986 End */

     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_id
                             := P_CC_REC.project_id;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).reversed_flag
                             := 'N';
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).rule_percentage
                             := P_CC_REC.rule_percentage;
    PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).schedule_line_percentage
                             := P_CC_REC.schedule_line_percentage;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).task_id
                             := P_CC_REC.task_id;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).tp_base_amount
                             := P_CC_REC.tp_base_amount;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).reference_1
                                                := to_char(P_INV_DET_ID);
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).reference_2
                                                := P_CC_REC.reference_2;
     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).expenditure_item_date
                                          := P_EI_DATE;

/* Added for cross proj*/
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).tp_amt_type_code
						  :=P_CC_REC.tp_amt_type_code;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_rate_type
						  :=P_CC_REC.project_tp_rate_type;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_rate_date
						  :=P_CC_REC.project_tp_rate_date;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_exchange_rate
						  :=P_CC_REC.project_tp_exchange_rate;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_transfer_price
						  :=(-1)*P_CC_REC.project_transfer_price;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_rate_type
						  :=P_CC_REC.projfunc_tp_rate_type;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_rate_date
						  :=P_CC_REC.projfunc_tp_rate_date;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_exchange_rate
						  :=P_CC_REC.projfunc_tp_exchange_rate;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_transfer_price
						  :=(-1)*P_CC_REC.projfunc_transfer_price;

  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_currency_code
						  :=P_CC_REC.project_tp_currency_code;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_currency_code
						  :=P_CC_REC.projfunc_tp_currency_code;
/* End for cross proj*/
/*  CBGA and project Jobs */

     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).tp_job_id
                                                := P_CC_REC.tp_job_id;
/*     PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).prov_proj_bill_job_id
                                                := P_CC_REC.prov_proj_bill_job_id; */

P_CC_REC.line_num  := P_CC_REC.line_num + 1;
--Set the expenditure Item as Used
     I_EXP_ITEM_USED(P_index) := 'Y';

  End if;

EXCEPTION
 WHEN Others
 Then
      Raise;
END reverse_cc_dist;

--Build CC Distribution
PROCEDURE build_cc_dist(P_Cdl_rec       IN prv_class_rec,
                        P_Line_num      IN NUMBER,
                        P_Index         IN NUMBER)
IS
l_pa_date date;
BEGIN

 /* Initialize the global record table */
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.build_cc_dist ...');
 	PA_IC_INV_UTILS.log_message('build_cc_dist: ' || 'Line Num...'||to_char(P_Line_num));
 END IF;
 PA_CC_BL_PROCESS.g_icnt := PA_CC_BL_PROCESS.g_icnt + 1;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).expenditure_item_id
                             := P_Cdl_rec.expenditure_item_id;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_currency_code
                             := P_Cdl_rec.ACCT_CURRENCY_CODE;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_tp_exchange_rate
                             := P_Cdl_rec.ACCT_TP_EXCHANGE_RATE;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_tp_rate_date
                             := P_Cdl_rec.ACCT_TP_RATE_DATE;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).acct_tp_rate_type
                             := P_Cdl_rec.ACCT_TP_RATE_TYPE;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).amount
                             := P_Cdl_rec.AMOUNT;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).bill_markup_percentage
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).bill_rate
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).cc_rejection_code
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).cr_code_combination_id
                             := P_Cdl_rec.CR_CODE_COMBINATION_ID;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).cross_charge_code
                             := P_Cdl_rec.CROSS_CHARGE_CODE;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).denom_tp_currency_code
                             := P_Cdl_rec.DENOM_TP_CURRENCY_CODE;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).denom_transfer_price
                             := P_Cdl_rec.DENOM_TRANSFER_PRICE;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).dist_line_id_reversed
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).dr_code_combination_id
                             := P_Cdl_rec.DR_CODE_COMBINATION_ID;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).ind_compiled_set_id
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).line_num
                             := nvl(P_line_num,0) + 1;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).line_num_reversed
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).line_type := 'PC';
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).markup_calc_base_code
                             := NULL;

/* Bug 2276729 - Begin populating the gl_date also. ** Commented for 3857986
***CBGA - Added new parameter org_id to get_pa_date***
l_pa_date:= pa_utils2.get_pa_date(P_Cdl_rec.EXPENDITURE_ITEM_DATE,SYSDATE, PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID);

 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_date
  := l_pa_date;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_date
:= pa_utils2.get_prvdr_gl_date(l_pa_date,PA_IC_INV_UTILS.G_PROGRAM_APPLICATION_ID, PA_MC_INVOICE_DETAIL_PKG.G_SOB);

** Bug 2276729 - End **  Commented for 3857986 End*/

/* Added for 3857986 */
BEGIN
 pa_utils2.get_period_information(
                           p_expenditure_item_date     => P_Cdl_rec.EXPENDITURE_ITEM_DATE
                          ,p_expenditure_id            => NULL
                          ,p_system_linkage_function   => P_CDL_REC.SYSTEM_LINKAGE_FUNCTION
                          ,p_line_type                 => 'R'
                          ,p_prvdr_raw_pa_date         => NULL
                          ,p_recvr_raw_pa_date         => NULL
                          ,p_prvdr_raw_gl_date         => NULL
                          ,p_recvr_raw_gl_date         => NULL
                          ,p_prvdr_org_id              => PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID
                          ,p_recvr_org_id              => NULL
                          ,p_prvdr_sob_id              => PA_MC_INVOICE_DETAIL_PKG.G_SOB
                          ,p_recvr_sob_id              => NULL
                          ,p_calling_module            => 'CCDL'
                          ,x_prvdr_pa_date             => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_date
                          ,x_prvdr_pa_period_name      => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_period_name
                          ,x_prvdr_gl_date             => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_date
                          ,x_prvdr_gl_period_name      => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_period_name
                          ,x_recvr_pa_date             => l_dummy
                          ,x_recvr_pa_period_name      => l_dummy1
                          ,x_recvr_gl_date             => l_dummy2
                          ,x_recvr_gl_period_name      => l_dummy3
                          ,x_return_status             => l_return_status
                          ,x_error_code                => l_error_code
                          ,x_error_stage               => l_error_stage);


EXCEPTION
  When Others
  Then
       raise;
END;

/* Added for 3857986 End */

PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_id
                             := P_Cdl_rec.project_id;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).reversed_flag
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).rule_percentage
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).schedule_line_percentage
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).task_id
                             := P_Cdl_rec.task_id;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).tp_base_amount
                             := NULL;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).expenditure_item_date
                                 := P_Cdl_rec.expenditure_item_date;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).reference_1
                                 := P_Cdl_rec.REFERENCE_1;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).reference_2
                                 := P_Cdl_rec.REFERENCE_2;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).reference_3
                                 := P_Cdl_rec.CDL_LINE_NUM;
/* Added for cross proj*/
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).tp_amt_type_code
                                                  :=P_Cdl_rec.tp_amt_type_code;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_rate_type
                                                  :=P_Cdl_rec.project_tp_rate_type;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_rate_date
                                                  :=to_date(P_Cdl_rec.project_tp_rate_date,'YYYY/MM/DD');/*FIle.Date.5*/
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_exchange_rate
                                                  :=P_Cdl_rec.project_tp_exchange_rate;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_transfer_price
                                                  :=P_Cdl_rec.project_transfer_price;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_rate_type
                                                  :=P_Cdl_rec.projfunc_tp_rate_type;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_rate_date
                                                  :=to_date(P_Cdl_rec.projfunc_tp_rate_date,'YYYY/MM/DD');/*File.Date.5*/
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_exchange_rate
                                                  :=P_Cdl_rec.projfunc_tp_exchange_rate;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_transfer_price
                                                  :=P_Cdl_rec.projfunc_transfer_price;

  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).project_tp_currency_code
                                                  :=P_Cdl_rec.project_tp_currency_code;
  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).projfunc_tp_currency_code
                                                  :=P_Cdl_rec.projfunc_tp_currency_code;
/* End for cross proj*/


/* CBGA and project Jobs */

 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).tp_job_id
                          := NULL;
/*  PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).prov_proj_bill_job_id
                          := NULL;
*/

--Set the expenditure Item as Used
 I_EXP_ITEM_USED(P_index) := 'Y';
END build_cc_dist;

--Update CC Distribution
PROCEDURE update_cc_dist(P_Cdl_rec       IN  prv_class_rec,
                         P_CC_rec        IN  get_cc_dist%rowtype,
                         P_Index         IN  NUMBER)
IS
l_pa_date date;
BEGIN

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.update_cc_dist ...');
  END IF;
-- Check if any attribute is changed or not
  If not (( P_Cdl_rec.DR_CODE_COMBINATION_ID = P_CC_rec.DR_CODE_COMBINATION_ID)
  and ( P_Cdl_rec.CR_CODE_COMBINATION_ID = P_CC_rec.CR_CODE_COMBINATION_ID)
  and ( P_Cdl_rec.AMOUNT = P_CC_rec.AMOUNT)
  and ( P_Cdl_rec.DENOM_TRANSFER_PRICE = P_CC_rec.DENOM_TRANSFER_PRICE)
  and ( nvl(P_Cdl_rec.ACCT_TP_RATE_TYPE,'X')
              = nvl(P_CC_rec.ACCT_TP_RATE_TYPE,'X') )
  and ( nvl(P_Cdl_rec.ACCT_TP_RATE_DATE,sysdate)
              = nvl(P_CC_rec.ACCT_TP_RATE_DATE,sysdate))
  and ( nvl(P_Cdl_rec.ACCT_TP_EXCHANGE_RATE,0)
              = nvl(P_CC_rec.ACCT_TP_EXCHANGE_RATE,0) )
  and ( P_Cdl_rec.DENOM_TP_CURRENCY_CODE = P_CC_rec.DENOM_TP_CURRENCY_CODE )
  and ( P_Cdl_rec.reference_2 = P_CC_rec.reference_2)
  and ( P_Cdl_rec.cdl_line_num = P_CC_rec.reference_3))
  then

      PA_CC_BL_PROCESS.g_ucnt := PA_CC_BL_PROCESS.g_ucnt + 1;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).upd_type := 'U';
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).CcdRowid
                             := P_CC_REC.rowid;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).expenditure_item_id
                             := P_Cdl_rec.expenditure_item_id;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).expenditure_item_date
                             := P_Cdl_rec.expenditure_item_date;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).acct_currency_code
                             := P_Cdl_rec.ACCT_CURRENCY_CODE;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).acct_tp_exchange_rate
                             := P_Cdl_rec.ACCT_TP_EXCHANGE_RATE;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).acct_tp_rate_date
                             := P_Cdl_rec.ACCT_TP_RATE_DATE;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).acct_tp_rate_type
                             := P_Cdl_rec.ACCT_TP_RATE_TYPE;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).amount
                             := P_Cdl_rec.AMOUNT;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).cr_code_combination_id
                             := P_Cdl_rec.CR_CODE_COMBINATION_ID;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).cross_charge_code
                             := P_Cdl_rec.CROSS_CHARGE_CODE;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).denom_tp_currency_code
                             := P_Cdl_rec.DENOM_TP_CURRENCY_CODE;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).denom_transfer_price
                             := P_Cdl_rec.DENOM_TRANSFER_PRICE;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).dr_code_combination_id
                             := P_Cdl_rec.DR_CODE_COMBINATION_ID;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).line_type := 'PC' ;/* Added for Bug 5704206 */

/* Bug 2276729 - Begin populating the gl_date also. ** Commented for 3857986
***CBGA - Added new parameter org_id to get_pa_date***
l_pa_date:= pa_utils2.get_pa_date(P_Cdl_rec.EXPENDITURE_ITEM_DATE,SYSDATE, PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID);
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).pa_date
       := l_pa_date;
 PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_date
      := pa_utils2.get_prvdr_gl_date(l_pa_date,PA_IC_INV_UTILS.G_PROGRAM_APPLICATION_ID, PA_MC_INVOICE_DETAIL_PKG.G_SOB);
** Bug 2276729 - End ** Commented for 3857986 */

/* Added for 3857986 */
BEGIN
 pa_utils2.get_period_information(
                           p_expenditure_item_date     => P_Cdl_rec.EXPENDITURE_ITEM_DATE
                          ,p_expenditure_id            => NULL
                          ,p_system_linkage_function   => P_CDL_REC.SYSTEM_LINKAGE_FUNCTION
                          ,p_line_type                 => 'R'
                          ,p_prvdr_raw_pa_date         => NULL
                          ,p_recvr_raw_pa_date         => NULL
                          ,p_prvdr_raw_gl_date         => NULL
                          ,p_recvr_raw_gl_date         => NULL
                          ,p_prvdr_org_id              => PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID
                          ,p_recvr_org_id              => NULL
                          ,p_prvdr_sob_id              => PA_MC_INVOICE_DETAIL_PKG.G_SOB
                          ,p_recvr_sob_id              => NULL
                          ,p_calling_module            => 'CCDL'
                          ,x_prvdr_pa_date             => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_date
                          ,x_prvdr_pa_period_name      => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).pa_period_name
                          ,x_prvdr_gl_date             => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_date
                          ,x_prvdr_gl_period_name      => PA_CC_BL_PROCESS.g_ins_rec(PA_CC_BL_PROCESS.g_icnt).gl_period_name
                          ,x_recvr_pa_date             => l_dummy
                          ,x_recvr_pa_period_name      => l_dummy1
                          ,x_recvr_gl_date             => l_dummy2
                          ,x_recvr_gl_period_name      => l_dummy3
                          ,x_return_status             => l_return_status
                          ,x_error_code                => l_error_code
                          ,x_error_stage               => l_error_stage);


EXCEPTION
  When Others
  Then
       raise;
END;

/* Added for 3857986 End */

      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).project_id
                             := P_Cdl_rec.project_id;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).task_id
                             := P_Cdl_rec.task_id;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).reference_1
                             := P_CC_rec.reference_1;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).reference_2
                             := P_Cdl_rec.reference_2;
      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).reference_3
                             := P_Cdl_rec.cdl_line_num;

 /* CBGA and project Jobs */

/*      PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).tp_job_id
                             := P_Cdl_rec.tp_job_id;

        PA_CC_BL_PROCESS.g_upd_rec(PA_CC_BL_PROCESS.g_ucnt).prov_proj_bill_job_id
                             := P_Cdl_rec.prov_proj_bill_job_id;

*/

--Set the expenditure Item as Used
      I_EXP_ITEM_USED(P_index) := 'Y';
  End if;

EXCEPTION
  When Others
  Then
       Raise;
END update_cc_dist;

--Procedure to add record in insert buffer
PROCEDURE insert_row ( p_inv_rec  IN OUT  NOCOPY   pa_draft_invoice_details%rowtype )
IS
BEGIN

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.insert_row ...');
  END IF;
--Increase the Insert counter
  PA_INVOICE_DETAIL_PKG.G_Ins_count := PA_INVOICE_DETAIL_PKG.G_Ins_count + 1;
--Assign Invoice detail Id from sequence
  p_inv_rec.DRAFT_INVOICE_DETAIL_ID := get_nextval;
--Add record to insert buffer
  P_Insert_tab(PA_INVOICE_DETAIL_PKG.G_Ins_count) := p_inv_rec;

END insert_row;

--Procedure to add record in delete buffer
PROCEDURE delete_row ( p_inv_rec  IN   pa_draft_invoice_details%rowtype )
IS
BEGIN

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.delete_row ...');
  END IF;
--Increase the Delete counter
  PA_INVOICE_DETAIL_PKG.G_Del_count := PA_INVOICE_DETAIL_PKG.G_Del_count + 1;
--Add record to delete buffer
  P_Delete_tab(PA_INVOICE_DETAIL_PKG.G_Del_count) := p_inv_rec;

END delete_row;

--Procedure to add record in update buffer
PROCEDURE update_row ( p_inv_rec  IN   pa_draft_invoice_details%rowtype,
                       p_mrc_required IN varchar2 )
IS
BEGIN

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.update_row ...');
  END IF;
--Increase the Update counter
  PA_INVOICE_DETAIL_PKG.G_Upd_count := PA_INVOICE_DETAIL_PKG.G_Upd_count + 1;
--Add record to update buffer
  P_Update_tab(PA_INVOICE_DETAIL_PKG.G_Upd_count) := p_inv_rec;
  I_MRC_REQD_FLAG(PA_INVOICE_DETAIL_PKG.G_Upd_count) := p_mrc_required;

END update_row;

-- Procedure to Update EI status as IC Processed.
PROCEDURE update_ei
IS
BEGIN
 PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.update_ei ...');
 /* For bug 2877649 Setting the Transfer_price amounts and TP rates to NULL for EIs marked as Never Processed */
  forall i in 1..I_EI_count
  Update PA_EXPENDITURE_ITEMS
   Set    CC_IC_PROCESSED_CODE  = 'X',
          DENOM_TP_CURRENCY_CODE      = NULL,
          DENOM_TRANSFER_PRICE        = NULL,
          ACCT_TP_RATE_TYPE           = NULL,
          ACCT_TP_RATE_DATE           = NULL,
          ACCT_TP_EXCHANGE_RATE       = NULL,
          ACCT_TRANSFER_PRICE         = NULL,
          PROJACCT_TRANSFER_PRICE     = NULL,
          CC_MARKUP_BASE_CODE         = NULL,
          TP_BASE_AMOUNT              = NULL,
          TP_IND_COMPILED_SET_ID      = NULL,
          TP_BILL_RATE                = NULL,
          TP_BILL_MARKUP_PERCENTAGE   = NULL,
          TP_SCHEDULE_LINE_PERCENTAGE = NULL,
          TP_RULE_PERCENTAGE          = NULL,
          TP_JOB_ID                   = NULL,
          PROJECT_TRANSFER_PRICE  =  NULL,
          PROJFUNC_TRANSFER_PRICE  = NULL,
          PROV_PROJ_BILL_JOB_ID       = NULL
   where  EXPENDITURE_ITEM_ID   = P_EI_table(i);
EXCEPTION
 When Others
 Then
      Raise;
END update_ei;

--Procedure to add record in update buffer
/* Added the parameter p_adjusted_ei for bug 2770182 */

PROCEDURE reverse_row ( p_inv_rec  IN  OUT  NOCOPY  pa_draft_invoice_details%rowtype,
                        p_adjusted_ei IN   NUMBER default null )
IS
 t_line_num   NUMBER:=0;
BEGIN

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.reverse_row ...');
 END IF;

 IF (p_inv_rec.LINE_NUM IS NOT NULL)
 THEN
     p_inv_rec.REVERSED_FLAG := 'Y';
     update_row(p_inv_rec,'N');
     p_inv_rec.LINE_NUM_REVERSED     := nvl(p_inv_rec.LINE_NUM,0);
 END IF;

-- Reverse The amount field
 p_inv_rec.DENOM_BILL_AMOUNT     := (-1)*p_inv_rec.DENOM_BILL_AMOUNT;
 p_inv_rec.BILL_AMOUNT           := (-1)*p_inv_rec.BILL_AMOUNT;
 p_inv_rec.LINE_NUM              := nvl(p_inv_rec.LINE_NUM,0) + 1;
 p_inv_rec.DETAIL_ID_REVERSED    := p_inv_rec.DRAFT_INVOICE_DETAIL_ID;
 p_inv_rec.ORIG_DRAFT_INVOICE_NUM:= p_inv_rec.DRAFT_INVOICE_NUM;
 p_inv_rec.ORIG_DRAFT_INVOICE_LINE_NUM :=
                                    p_inv_rec.DRAFT_INVOICE_LINE_NUM;
 p_inv_rec.DRAFT_INVOICE_NUM     := NULL;
 p_inv_rec.DRAFT_INVOICE_LINE_NUM
                                 := NULL;
 p_inv_rec.INVOICED_FLAG         := 'N';
 /*Cross charge*/
 p_inv_rec.project_transfer_price := (-1)* p_inv_rec.Project_transfer_price;
 p_inv_rec.projfunc_transfer_price:=(-1)*p_inv_rec.projfunc_transfer_price;
 /*Cross charge*/

/* Commented the below for bug 2770182 */

/* I_Line_num                      := I_Line_num + 1;

  Add the record to input buffer

 insert_row(p_inv_rec);  */

/* Added for bug 2770182 */

 -- If the EI is adjusted EI then check the invoice detail has record already or not
 -- if there is no records, continue insert or mark for update

   IF nvl(p_adjusted_ei,0) <> 0 THEN

       t_line_num :=0;

     SELECT max(line_num) INTO t_line_num
       FROM pa_draft_invoice_details_all
      WHERE expenditure_item_id = p_inv_rec.expenditure_item_id
       AND  draft_invoice_num  IS NULL
       AND  DRAFT_INVOICE_LINE_NUM IS NULL
       AND  NVL(invoiced_flag,'N') ='N';

        IF SQL%NOTFOUND THEN
                t_line_num :=0;
        END IF;
 PA_IC_INV_UTILS.log_message('Value of t_line_num '||t_line_num);
    IF NVL(t_line_num,0) <> 0 THEN

            I_line_num := t_line_num;
    ELSE
        I_Line_num := I_Line_num + 1;

    END IF;

  ELSE

    I_Line_num     := I_Line_num + 1;

  END IF;

  IF NVL(t_line_num,0) = 0 THEN

  -- Add the record to input buffer
  insert_row(p_inv_rec);

 ELSE
   update_row(p_inv_rec,'N');

 END IF;

END reverse_row;

-- Procedure to build new row from existing row
Procedure build_row ( P_Mode          IN Varchar2,
                      P_Arr_position  IN number,
                      P_Rev_ccid      IN number,
                      P_Inv_rec       IN OUT NOCOPY  pa_draft_invoice_details%rowtype)
IS
BEGIN
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.build_row1...');
 END IF;
 P_Inv_rec.INVOICED_FLAG        := 'N';
 P_Inv_rec.DENOM_CURRENCY_CODE  := I_DENOM_CURRENCY_CODE(P_Arr_position);
 P_Inv_rec.DENOM_BILL_AMOUNT    := I_DENOM_BILL_AMOUNT(P_Arr_position);
 P_Inv_rec.ACCT_CURRENCY_CODE   := I_ACCT_CURRENCY_CODE(P_Arr_position);
 P_Inv_rec.BILL_AMOUNT          := I_BILL_AMOUNT(P_Arr_position);
 P_Inv_rec.ACCT_RATE_TYPE       := I_ACCT_RATE_TYPE(P_Arr_position);
 P_Inv_rec.ACCT_RATE_DATE
                 := to_date(I_ACCT_RATE_DATE(P_Arr_position),'YYYY/MM/DD');
/* 2229894       := to_date(I_ACCT_RATE_DATE(P_Arr_position),'DD-MM-RR'); */
 P_Inv_rec.ACCT_EXCHANGE_RATE   := I_ACCT_EXCHANGE_RATE(P_Arr_position);
 P_Inv_rec.REV_CODE_COMBINATION_ID := P_Rev_ccid;
 -- Bug 4579791 P_Inv_rec.OUTPUT_VAT_TAX_ID       := I_OUTPUT_VAT_TAX_ID(P_Arr_position);
 P_Inv_rec.OUTPUT_TAX_CLASSIFICATION_CODE := I_OUTPUT_TAX_CODE(P_Arr_Position);
 P_Inv_rec.OUTPUT_TAX_EXEMPT_FLAG  := I_OUTPUT_TAX_EXEMPT_FLAG(P_Arr_position);
 P_Inv_rec.OUTPUT_TAX_EXEMPT_REASON_CODE
                            := I_TAX_EXEMPT_REASON_CODE(P_Arr_position);
 P_Inv_rec.OUTPUT_TAX_EXEMPT_NUMBER
                            := I_OUTPUT_TAX_EXEMPT_NUMBER(P_Arr_position);
 P_Inv_rec.MARKUP_CALC_BASE_CODE := I_MARKUP_CALC_BASE_CODE(P_Arr_position);
 P_Inv_rec.IND_COMPILED_SET_ID   := I_IND_COMPILED_SET_ID(P_Arr_position);
 P_Inv_rec.RULE_PERCENTAGE       := I_RULE_PERCENTAGE(P_Arr_position);
 P_Inv_rec.BILL_RATE             := I_BILL_RATE(P_Arr_position);
 P_Inv_rec.BILL_MARKUP_PERCENTAGE := I_BILL_MARKUP_PERCENTAGE(P_Arr_position);
 P_Inv_rec.BASE_AMOUNT           := I_BASE_AMOUNT(P_Arr_position);
 P_Inv_rec.SCHEDULE_LINE_PERCENTAGE
                              := I_SCHEDULE_LINE_PERCENTAGE(P_Arr_position);
 P_Inv_rec.DRAFT_INVOICE_NUM  := NULL;
 P_Inv_rec.DRAFT_INVOICE_LINE_NUM  := NULL;

/*Added for cross proj */
 P_Inv_rec.tp_amt_type_code           := I_tp_amt_type_code(P_Arr_position);
 P_Inv_rec.project_tp_rate_type       := I_project_tp_rate_type(P_Arr_position);
 P_Inv_rec.project_tp_rate_date       := to_date(I_project_tp_rate_date(P_Arr_position),'YYYY/MM/DD');/*file.Date.5*/
 P_Inv_rec.project_tp_exchange_rate   := I_project_tp_exchange_rate(P_Arr_position);
 P_Inv_rec.project_transfer_price     := I_project_transfer_price(P_Arr_position);
 P_Inv_rec.projfunc_tp_rate_type      := I_projfunc_tp_rate_type(P_Arr_position);
 P_Inv_rec.projfunc_tp_rate_date      := to_Date(I_projfunc_tp_rate_date(P_Arr_position),'YYYY/MM/DD');/*file.Date.5*/
 P_Inv_rec.projfunc_tp_exchange_rate  := I_projfunc_tp_exchange_rate(P_Arr_position);
 P_Inv_rec.projfunc_transfer_price    := I_projfunc_transfer_price(P_Arr_position);

 P_Inv_rec.project_tp_currency_code    := I_project_tp_currency_code(P_Arr_position);
 P_Inv_rec.projfunc_tp_currency_code   := I_projfunc_tp_currency_code(P_Arr_position);
/* End for cross proj*/
 /* CBGA and project Jobs */

 P_inv_rec.TP_JOB_ID      := I_TP_JOB_ID(P_Arr_position);
 P_inv_rec.PROV_PROJ_BILL_JOB_ID  := I_PROV_PROJ_BILL_JOB_ID(P_Arr_position);

 If P_Mode = 'A'
 Then
   /** Add the row to the insert buffer **/
   I_Line_num                        := I_Line_num + 1;
   P_Inv_rec.LINE_NUM                := I_Line_num;
   P_Inv_rec.DETAIL_ID_REVERSED      := NULL;
   P_Inv_rec.LINE_NUM_REVERSED       := NULL;
   insert_row(P_Inv_rec);
 Elsif P_Mode = 'U'
 Then
    update_row(P_Inv_rec,'Y');
 end if;

EXCEPTION
 When Others
 Then
      Raise;
END build_row;

-- Build a fresh row for PA_DRAFT_INVOICE_DETAILS
Procedure build_row ( P_Expenditure_item_id IN number,
                      P_Project_Id          IN number,
                      P_CC_Project_id       IN number,
                      P_CC_Tax_task_id      IN number,
                      P_Rev_ccid            IN number,
                      P_Arr_position        IN number,
                      X_Inv_rec             OUT  NOCOPY pa_draft_invoice_details%rowtype)
IS
 l_inv_rec    pa_draft_invoice_details%rowtype;
 c            number :=0;
BEGIN
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.build_row2...');
 END IF;
 I_Line_num                     := I_Line_num + 1;
/** Initialize all field of the structure **/
 l_inv_rec.EXPENDITURE_ITEM_ID  := P_Expenditure_item_id;
 l_inv_rec.LINE_NUM             := I_Line_num;
 l_inv_rec.PROJECT_ID           := P_Project_Id;
 l_inv_rec.INVOICED_FLAG        := 'N';
 l_inv_rec.DENOM_CURRENCY_CODE  := I_DENOM_CURRENCY_CODE(P_Arr_position);
 l_inv_rec.DENOM_BILL_AMOUNT
                          := to_number(I_DENOM_BILL_AMOUNT(P_Arr_position));
 l_inv_rec.ACCT_CURRENCY_CODE   := I_ACCT_CURRENCY_CODE(P_Arr_position);
 l_inv_rec.BILL_AMOUNT          := to_number(I_BILL_AMOUNT(P_Arr_position));
 l_inv_rec.ACCT_RATE_DATE
                 := to_date(I_ACCT_RATE_DATE(P_Arr_position),'YYYY/MM/DD');/*File.Date.5*/
/*2229894        := to_date(I_ACCT_RATE_DATE(P_Arr_position),'DD-MM-RR');*/
 l_inv_rec.ACCT_RATE_TYPE       := I_ACCT_RATE_TYPE(P_Arr_position);
 l_inv_rec.ACCT_EXCHANGE_RATE
                          := to_number(I_ACCT_EXCHANGE_RATE(P_Arr_position));
 l_inv_rec.CC_PROJECT_ID        := P_CC_Project_id;
 l_inv_rec.CC_TAX_TASK_ID       := P_CC_Tax_task_id;
 l_inv_rec.REV_CODE_COMBINATION_ID := P_Rev_ccid;
 -- Bug 4579791 l_inv_rec.OUTPUT_VAT_TAX_ID       := I_OUTPUT_VAT_TAX_ID(P_Arr_position);
 l_inv_rec.OUTPUT_TAX_CLASSIFICATION_CODE := I_OUTPUT_TAX_CODE(P_Arr_position);
 l_inv_rec.OUTPUT_TAX_EXEMPT_FLAG  := I_OUTPUT_TAX_EXEMPT_FLAG(P_Arr_position);
 If ( I_TAX_EXEMPT_REASON_CODE.exists(P_Arr_position))
 Then
    l_inv_rec.OUTPUT_TAX_EXEMPT_REASON_CODE
                            := I_TAX_EXEMPT_REASON_CODE(P_Arr_position);
 End if;
 c := 13;
 if ( I_OUTPUT_TAX_EXEMPT_NUMBER.exists(P_Arr_position) )
 Then
    l_inv_rec.OUTPUT_TAX_EXEMPT_NUMBER
                          := I_OUTPUT_TAX_EXEMPT_NUMBER(P_Arr_position);
 End if;
 c := 16;
 l_inv_rec.MARKUP_CALC_BASE_CODE := I_MARKUP_CALC_BASE_CODE(P_Arr_position);
 c := 17;
 l_inv_rec.IND_COMPILED_SET_ID   := I_IND_COMPILED_SET_ID(P_Arr_position);
 c := 18;
 l_inv_rec.RULE_PERCENTAGE
                           := to_number(I_RULE_PERCENTAGE(P_Arr_position));
 c := 19;
 l_inv_rec.BILL_RATE             := to_number(I_BILL_RATE(P_Arr_position));
 l_inv_rec.BILL_MARKUP_PERCENTAGE
                      := to_number(I_BILL_MARKUP_PERCENTAGE(P_Arr_position));
 l_inv_rec.BASE_AMOUNT           := to_number(I_BASE_AMOUNT(P_Arr_position));
 l_inv_rec.SCHEDULE_LINE_PERCENTAGE
                      := to_number(I_SCHEDULE_LINE_PERCENTAGE(P_Arr_position));

/* CBGA and project Jobs */

 l_inv_rec.tp_job_id  := I_tp_job_id(P_Arr_position);
 l_inv_rec.prov_proj_bill_job_id := I_prov_proj_bill_job_id(P_Arr_position);


/* Bug #1374381  Assigned the org_id for inert into pa_draft_invoice_details table*/
l_inv_rec.org_id      :=  PA_MC_INVOICE_DETAIL_PKG.G_ORG_ID;

/*Added for cross proj */
 l_inv_rec.tp_amt_type_code           := I_tp_amt_type_code(P_Arr_position);
 l_inv_rec.project_tp_rate_type       := I_project_tp_rate_type(P_Arr_position);
 l_inv_rec.project_tp_rate_date       := to_date(I_project_tp_rate_date(P_Arr_position),'YYYY/MM/DD');/*File.Date.5*/
 l_inv_rec.project_tp_exchange_rate   := I_project_tp_exchange_rate(P_Arr_position);
 l_inv_rec.project_transfer_price     := I_project_transfer_price(P_Arr_position);
 l_inv_rec.projfunc_tp_rate_type      := I_projfunc_tp_rate_type(P_Arr_position);
 l_inv_rec.projfunc_tp_rate_date      := to_date(I_projfunc_tp_rate_date(P_Arr_position),'YYYY/MM/DD');/*File.Date.5*/
 l_inv_rec.projfunc_tp_exchange_rate  := I_projfunc_tp_exchange_rate(P_Arr_position);
 l_inv_rec.projfunc_transfer_price    := I_projfunc_transfer_price(P_Arr_position);

 l_inv_rec.project_tp_currency_code    := I_project_tp_currency_code(P_Arr_position);
 l_inv_rec.projfunc_tp_currency_code   := I_projfunc_tp_currency_code(P_Arr_position);
/* End for cross proj*/



 /** Add the row to the insert buffer **/
 insert_row(l_inv_rec);

 X_Inv_rec := l_inv_rec;
EXCEPTION
  WHEN Others
  THEN
       Raise;
END build_row;

--Procedure to add record in Expenditure buffer
PROCEDURE add_ei ( P_Expenditure_item_id IN number )
IS
BEGIN

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.add_ei...');
  END IF;
--Increase the EI  counter
  I_Ei_count := I_Ei_count + 1;
--Add record to Expenditure Buffer buffer
  P_EI_table(I_Ei_count) := P_Expenditure_item_id;

END add_ei;

-- Function to check whether New invoice details to be created or not.
FUNCTION is_new_details(P_IND_REC     IN  pa_draft_invoice_details%rowtype,
                        P_Rev_ccid    IN  number,
                        P_Index       IN  number)
Return Boolean
IS
Begin
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.is_new_details...');
  END IF;
  Return( not
  (
       P_IND_REC.DENOM_CURRENCY_CODE = I_DENOM_CURRENCY_CODE(P_Index)
  AND  P_IND_REC.DENOM_BILL_AMOUNT   = I_DENOM_BILL_AMOUNT(P_Index)
  AND  P_IND_REC.ACCT_CURRENCY_CODE  = I_ACCT_CURRENCY_CODE(P_Index)
  AND  P_IND_REC.BILL_AMOUNT          = I_BILL_AMOUNT(P_Index)
  AND  P_IND_REC.ACCT_RATE_TYPE       = I_ACCT_RATE_TYPE(P_Index)
  AND  P_IND_REC.ACCT_RATE_DATE       = to_date(I_ACCT_RATE_DATE(P_Index),'YYYY/MM/DD') /*File.Date.5*/
  AND  P_IND_REC.ACCT_EXCHANGE_RATE   = I_ACCT_EXCHANGE_RATE(P_Index)
  AND  P_IND_REC.REV_CODE_COMBINATION_ID = P_Rev_ccid
  -- Bug 4579791 AND  P_IND_REC.OUTPUT_VAT_TAX_ID       = I_OUTPUT_VAT_TAX_ID(P_Index)
  AND  P_IND_REC.OUTPUT_TAX_CLASSIFICATION_CODE = I_OUTPUT_TAX_CODE(P_Index)
  AND  P_IND_REC.OUTPUT_TAX_EXEMPT_FLAG  = I_OUTPUT_TAX_EXEMPT_FLAG(P_Index)
  AND  P_IND_REC.OUTPUT_TAX_EXEMPT_REASON_CODE
                               = I_TAX_EXEMPT_REASON_CODE(P_Index)
  AND  P_IND_REC.OUTPUT_TAX_EXEMPT_NUMBER
                                      = I_OUTPUT_TAX_EXEMPT_NUMBER(P_Index)
  AND  P_IND_REC.MARKUP_CALC_BASE_CODE = I_MARKUP_CALC_BASE_CODE(P_Index)
  AND  P_IND_REC.IND_COMPILED_SET_ID   = I_IND_COMPILED_SET_ID(P_Index)
  AND  P_IND_REC.RULE_PERCENTAGE       = I_RULE_PERCENTAGE(P_Index)
  AND  P_IND_REC.BILL_RATE             = I_BILL_RATE(P_Index)
  AND  P_IND_REC.BILL_MARKUP_PERCENTAGE = I_BILL_MARKUP_PERCENTAGE(P_Index)
  AND  P_IND_REC.BASE_AMOUNT           = I_BASE_AMOUNT(P_Index)
  AND  P_IND_REC.SCHEDULE_LINE_PERCENTAGE
                              = I_SCHEDULE_LINE_PERCENTAGE(P_Index)
  AND  P_IND_REC.TP_JOB_ID    = I_TP_JOB_ID(P_Index)
  AND  P_IND_REC.PROV_PROJ_BILL_JOB_ID = I_PROV_PROJ_BILL_JOB_ID(P_Index)
  /*Cross proj*/
  AND  P_IND_REC.PROJECT_TRANSFER_PRICE =I_PROJECT_TRANSFER_PRICE(P_Index)
  AND  P_IND_REC.TP_AMT_TYPE_CODE       =I_TP_AMT_TYPE_CODE(P_Index)
  AND  P_IND_REC.PROJFUNC_TRANSFER_PRICE =I_PROJFUNC_TRANSFER_PRICE(P_Index)

  ));

EXCEPTION
 WHEN OTHERS
 THEN
      RAISE;
End is_new_details;

-- Read the Original Invoice details for reversing invoice details.
PROCEDURE  read_orig(P_Expenditure_item_id   IN Number,
                     P_Line_num              IN Number,
                     X_IND_REC
                                          OUT  NOCOPY pa_draft_invoice_details%rowtype)
IS
BEGIN
   IF g1_debug_mode  = 'Y' THEN
   	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.read_orig...');
   END IF;
   Select *
   INTO   X_IND_REC
   FROM   PA_DRAFT_INVOICE_DETAILS
   WHERE  EXPENDITURE_ITEM_ID      = P_Expenditure_item_id
   AND    LINE_NUM                 = P_Line_num ;
EXCEPTION
   WHEN Others
   Then
        RAISE;
END read_orig;

-- Upadate the rejection reason code of EI
PROCEDURE update_rejection_reason ( P_Error_code
                                             IN PA_PLSQL_DATATYPES.Char30TabTyp,
                                    P_Exp_Id     IN PA_PLSQL_DATATYPES.IdTabTyp,
                                    P_No_of_records IN number )
IS
BEGIN
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.update_rejection_reason...');
 END IF;
 FORALL I IN 1..P_No_of_records
   Update PA_EXPENDITURE_ITEMS
   Set    CC_REJECTION_CODE     = P_Error_code(I)
   Where  EXPENDITURE_ITEM_ID   = P_Exp_Id(I);

EXCEPTION
 When Others
 Then
      Raise;
END update_rejection_reason;

-- Apply all pending DB changes in Bulk
PROCEDURE apply_db_changes (P_Error_code    IN PA_PLSQL_DATATYPES.Char30TabTyp,
                            P_Exp_Id        IN PA_PLSQL_DATATYPES.IdTabTyp,
                            P_no_of_records IN Number )
IS
BEGIN

 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.apply_db_changes...');
 END IF;
/* Apply Pending Delete/Update/Insert in PA_DRAFT_INVOICE Details */
 PA_INVOICE_DETAIL_PKG.delete_rows(P_Delete_tab);
 PA_INVOICE_DETAIL_PKG.update_rows(P_Update_tab,I_MRC_REQD_FLAG);
 PA_INVOICE_DETAIL_PKG.insert_rows(P_Insert_tab);

/* Apply pending changes for PA_EXPENDITURE_ITEMS */
 update_ei;
 update_rejection_reason( P_Error_code, P_Exp_Id, P_no_of_records );

/* Apply changes for Provider Reclass */
 if (PA_CC_BL_PROCESS.g_dcnt > 0 )
 then
     PA_CC_BL_PROCESS.mass_delete;
 end if;
 if (PA_CC_BL_PROCESS.g_ucnt > 0 )
 then
     PA_CC_BL_PROCESS.mass_update;
 end if;
 if (PA_CC_BL_PROCESS.g_icnt > 0 )
 then
     PA_CC_BL_PROCESS.mass_insert;
 end if;
/* Commit the data */
 Commit;

Exception
 When Others
 Then
      Raise;
END apply_db_changes;

/* !!!!This is overloaded procedure for compilation of pro*c files of Patchset J */
/* !!!!Note: This .pls with overload function should not be sent along with the patch for Patchset J customers */
PROCEDURE process_invoice_details
           ( P_Project_Id          IN   number  ,
             P_Customer_Id         IN   number,
             P_Bill_to_site_use_id IN   number,
             P_Ship_to_site_use_id IN   number ,
             P_Set_of_books_id     IN   number ,
             P_Acct_curr_code      IN   varchar2,
             P_Expenditure_category IN  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_CC_Project_Id       IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_CC_Tax_task_id      IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_EI_id               IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_AdjEI_id            IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Net_zero_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_TP_sch_id           IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_revenue_ccid        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_cr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_dr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Task_id             IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Cross_charge_code   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Labor_nl_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Revenue_distributed_flag
                                   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Expend_type         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_EI_date             IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Sys_linkage         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_currency_code IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_Prj_currency_code   IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_TP_fixed_date       IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_raw_cost_amt  IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_burdened_cost_amt
                                   IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Raw_revenue_amt     IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Quantity            IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Non_labor_resource  IN   PA_PLSQL_DATATYPES.Char20TabTyp  ,
             P_Prvdr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_org_id        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Expnd_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NL_resource_organization
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Incurred_by_person_id
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Job_id              IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Denom_TP_currency_code
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_Denom_transfer_price
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_type   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_date   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_exchange_rate
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_transfer_price IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_CC_markup_base_code IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_ind_compiled_set_id
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_TP_bill_rate        IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_base_amt         IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_bill_markup_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_schedule_line_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_rule_percentage  IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_burden_disp_method  IN       PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_ca_prov_code        IN   Varchar2,
             P_nca_prov_code       IN   Varchar2,
             P_Processed_thru_date IN   Date ,
             P_No_of_records       IN   NUMBER  ,
             P_User_Id             IN   NUMBER  ,
             P_Request_id          IN   NUMBER  ,
             P_Error_Code      IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_tp_Job_id             IN OUT  NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
             P_prov_proj_bill_job_id IN OUT  NOCOPY   PA_PLSQL_DATATYPES.IdTabTyp,
/*Added for cross proj*/
             P_tp_amt_type_code        IN       PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_currency_code  IN       PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_project_tp_rate_type    IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_rate_date    IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_exchange_rate    IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_type   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_date   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_exchange_rate   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_assignment_id           IN       PA_PLSQL_DATATYPES.IdTabTyp,
             P_project_transfer_price   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_transfer_price   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
/*End for cross proj*/
             )
IS
             BEGIN
               null;
             END;
/* End of overload for Patchset J */

/* !!!This is overloaded procedure for compilation of pro*c files of Patchset H */
/* !!!Note: This .pls with overload function should not be sent along with the patch for Patchset H customers */
PROCEDURE process_invoice_details
           ( P_Project_Id          IN   number  ,
             P_Customer_Id         IN   number,
             P_Bill_to_site_use_id IN   number,
             P_Ship_to_site_use_id IN   number ,
             P_Set_of_books_id     IN   number ,
             P_Acct_curr_code      IN   varchar2,
             P_Expenditure_category IN  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_CC_Project_Id       IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_CC_Tax_task_id      IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_EI_id               IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_AdjEI_id            IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Net_zero_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_TP_sch_id           IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_revenue_ccid        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_cr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_dr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Task_id             IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Cross_charge_code   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Labor_nl_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Revenue_distributed_flag
                                   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Expend_type         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_EI_date             IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Sys_linkage         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_currency_code IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_Prj_currency_code   IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_TP_fixed_date       IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_raw_cost_amt  IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_burdened_cost_amt
                                   IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Raw_revenue_amt     IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Quantity            IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Non_labor_resource  IN   PA_PLSQL_DATATYPES.Char20TabTyp  ,
             P_Prvdr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_org_id        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Expnd_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NL_resource_organization
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Incurred_by_person_id
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Job_id              IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Denom_TP_currency_code
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_Denom_transfer_price
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_type   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_date   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_exchange_rate
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_transfer_price IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_CC_markup_base_code IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_ind_compiled_set_id
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_TP_bill_rate        IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_base_amt         IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_bill_markup_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_schedule_line_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_rule_percentage  IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_burden_disp_method  IN        PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_ca_prov_code        IN   Varchar2,
             P_nca_prov_code       IN   Varchar2,
             P_Processed_thru_date IN   Date ,
             P_No_of_records       IN   NUMBER  ,
             P_User_Id             IN   NUMBER  ,
             P_Request_id          IN   NUMBER  ,
             P_Error_Code      IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
             P_tp_Job_id             IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_prov_proj_bill_job_id IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp)
	     IS
	     BEGIN
	       null;
             END;
/* End of overload for Patchset H */

-- Main Procedure to process invoice details
PROCEDURE process_invoice_details
           ( P_Project_Id          IN   number  ,
             P_Customer_Id         IN   number,
             P_Bill_to_site_use_id IN   number,
             P_Ship_to_site_use_id IN   number ,
             P_Set_of_books_id     IN   number ,
             P_Acct_curr_code      IN   varchar2,
             P_Expenditure_category IN  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_CC_Project_Id       IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_CC_Tax_task_id      IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_EI_id               IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_AdjEI_id            IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Net_zero_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_TP_sch_id           IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_revenue_ccid        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_cr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_provider_dr_ccid    IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Task_id             IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Cross_charge_code   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Labor_nl_flag       IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Revenue_distributed_flag
                                   IN   PA_PLSQL_DATATYPES.Char1TabTyp  ,
             P_Expend_type         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_EI_date             IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Sys_linkage         IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_currency_code IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_Prj_currency_code   IN   PA_PLSQL_DATATYPES.Char15TabTyp  ,
             P_TP_fixed_date       IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_raw_cost_amt  IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Denom_burdened_cost_amt
                                   IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Raw_revenue_amt     IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Quantity            IN   PA_PLSQL_DATATYPES.Char30TabTyp  ,
             P_Non_labor_resource  IN   PA_PLSQL_DATATYPES.Char20TabTyp  ,
             P_Prvdr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_org_id        IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Recvr_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Expnd_Organization  IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_NL_resource_organization
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Incurred_by_person_id
                                   IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Job_id              IN   PA_PLSQL_DATATYPES.IdTabTyp ,
             P_Denom_TP_currency_code
                                   IN OUT  NOCOPY   PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_Denom_transfer_price
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_type   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_rate_date   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_TP_exchange_rate
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_Acct_transfer_price IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_CC_markup_base_code IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_ind_compiled_set_id
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_TP_bill_rate        IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_base_amt         IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_bill_markup_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_schedule_line_percentage
                                   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_TP_rule_percentage  IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_burden_disp_method  IN       PA_PLSQL_DATATYPES.Char1TabTyp ,
             P_ca_prov_code        IN   Varchar2,
             P_nca_prov_code       IN   Varchar2,
             P_Processed_thru_date IN   Date ,
             P_No_of_records       IN   NUMBER  ,
             P_User_Id             IN   NUMBER  ,
             P_Request_id          IN   NUMBER  ,
             P_Error_Code      IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
             P_tp_Job_id             IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
             P_prov_proj_bill_job_id IN OUT    NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
/*Added for cross proj*/
             P_tp_amt_type_code        IN       PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_currency_code  IN       PA_PLSQL_DATATYPES.Char15TabTyp ,
             P_project_tp_rate_type    IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_rate_date    IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_project_tp_exchange_rate    IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_type   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_rate_date   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_tp_exchange_rate   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_assignment_id           IN       PA_PLSQL_DATATYPES.IdTabTyp,
             P_project_transfer_price   IN OUT   NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp ,
             P_projfunc_transfer_price   IN OUT    NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp ,

/*End for cross proj*/
/* Bill rate Discount*/
        p_dist_rule                     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_mcb_flag                      IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_bill_rate_multiplier          IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_raw_cost                      IN       PA_PLSQL_DATATYPES.Char30TabTyp,
   /*   p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.NumTabTyp,  Commented for bug 3252190 */
        p_labor_schdl_discnt            IN       PA_PLSQL_DATATYPES.Char30TabTyp, /* Changed the data type from Num to char for bug3252190 */
        p_labor_schdl_fixed_date        IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_bill_job_grp_id               IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_labor_sch_type                IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_project_org_id                IN       PA_PLSQL_DATATYPES.NumTabTyp ,
        p_project_type                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_exp_func_curr_code            IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_incurred_by_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_raw_cost_rate                 IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_override_to_organz_id         IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_emp_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_job_bill_rate_schedule_id     IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_exp_raw_cost                  IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_assignment_precedes_task      IN       PA_PLSQL_DATATYPES.Char1TabTyp,

        p_burden_cost                   IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_task_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_proj_nl_bill_rate_org_id      IN       PA_PLSQL_DATATYPES.IdTabTyp,
        p_task_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_proj_nl_std_bill_rate_sch     IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_sch_type                   IN       PA_PLSQL_DATATYPES.Char1TabTyp,
        p_nl_task_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_proj_sch_date              IN       PA_PLSQL_DATATYPES.Char30TabTyp,
        p_nl_task_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        p_nl_proj_sch_discount          IN       PA_PLSQL_DATATYPES.NumTabTyp,
        /* The following two parameters are added for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_proj_nl_std_bill_rate_sch_id     IN PA_PLSQL_DATATYPES.NumTabTyp       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab,
        p_uom_flag                      IN       PA_PLSQL_DATATYPES.NumTabTyp
						  DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
             )
IS

/** Local variable for SQL Fetch *******/
/*Added L_IND_REC_NULL for bug 2296735 */
 L_IND_REC                         pa_draft_invoice_details%rowtype;
 L_IND_REC_NULL                    pa_draft_invoice_details%rowtype;
 L_IND_REC_NEW                     pa_draft_invoice_details%rowtype;
 X_Inv_rec                         pa_draft_invoice_details%rowtype;
 L_CC_REC                          get_cc_dist%rowtype;
 L_CDL_REC                         prv_class_rec;
 L_Compute_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 L_AdjEI_id                        PA_PLSQL_DATATYPES.IdTabTyp;
 L_Output_vat_tax_id               PA_PLSQL_DATATYPES.IdTabTyp;
 L_Output_tax_code                 PA_PLSQL_DATATYPES.Char30TabTyp;
 L_Output_tax_exempt_flag          PA_PLSQL_DATATYPES.Char1TabTyp;
 L_Output_tax_exempt_number        PA_PLSQL_DATATYPES.Char30TabTyp;
 L_Output_exempt_reason_code       PA_PLSQL_DATATYPES.Char80TabTyp;
 RECORD_FOUND                      BOOLEAN;
 CC_RECORD_FOUND                   BOOLEAN;
 X_Error_Code                      PA_PLSQL_DATATYPES.Char30TabTyp;
 X_Error_Stage                     number;
 L_PROV_ENABLED                    BOOLEAN := TRUE;
 l_cost_accrual_flag               Varchar2(1);
 l_denom_transfer_price            NUMBER;
 l_denom_transfer_price1            NUMBER;
 l_amount                          NUMBER;
 l_denom_tp_currency_code          Varchar2(15);
 l_acct_currency_code              Varchar2(15);
 l_acct_tp_rate_date               Date;
 l_acct_tp_rate_type               Varchar2(30);
 l_acct_tp_exchange_rate           NUMBER;
 l_line_num                        NUMBER;
 l_status_code                     Number;
 l_stage                           Number;
 l_ind_compiled_set_id             Number;
 l_multiplier                      Number;
 l_cc_Cross_charge_code            Varchar2(1); /*For bug 5370844*/

 /* CBGA and Project Jobs */

 l_job_group_id                    pa_projects_all.bill_job_group_id%TYPE;


BEGIN
 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('Enter pa_invoice_detail_process.process_invoice_details...');
 END IF;
/* Checking Provider Reclass Enabled or not...*/
 If (P_ca_prov_code = 'N' and P_nca_prov_code = 'N')
 Then
    L_PROV_ENABLED := FALSE;
 End if;

/** Initialize all local and Global variable
**/
 init;

/*** for cross charge code as 'B','X','N'
     No processing for Tax and Transfer Price is needed.
***/



 IF g1_debug_mode  = 'Y' THEN
 	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Setting Compute Flag ...');
 END IF;
 For I in 1..P_No_of_records
 Loop
    If (P_Cross_charge_code(I) in ('X','N','B')
    or  P_Net_zero_flag(I) = 'Y' )
    Then
       L_Compute_flag(I) := 'N';
    Else
       L_Compute_flag(I) := 'Y';
    End if;

    If not P_Error_code.exists(I)
    then
       P_Error_code(I) := NULL;
    End if;

    If not P_AdjEI_id.exists(I)
    Then
       L_AdjEI_id(I)     := NULL;
       L_Compute_flag(I) := 'N';
    Else
       L_AdjEI_id(I)     := P_AdjEI_id(I);
    End if;

    If  P_Denom_TP_currency_code.exists(I)
    then
        I_DENOM_CURRENCY_CODE(I) := P_Denom_TP_currency_code(I);
    End if;

    If  P_Denom_transfer_price.exists(I)
    then
        I_DENOM_BILL_AMOUNT(I) := P_Denom_transfer_price(I);
    End if;

    If  P_Acct_TP_rate_type.exists(I)
    then
        I_ACCT_RATE_TYPE(I) := P_Acct_TP_rate_type(I);
    End if;

    If  P_Acct_TP_rate_date.exists(I)
    then
        I_ACCT_RATE_DATE(I) := P_Acct_TP_rate_date(I);
    End if;

    If  P_Acct_TP_exchange_rate.exists(I)
    then
        I_ACCT_EXCHANGE_RATE(I) := P_Acct_TP_exchange_rate(I);
    End if;

    If  P_Acct_transfer_price.exists(I)
    then
        I_BILL_AMOUNT(I) := P_Acct_transfer_price(I);
    End if;

    If  P_CC_markup_base_code.exists(I)
    then
        I_MARKUP_CALC_BASE_CODE(I) := P_CC_markup_base_code(I);
    End if;

    If  P_TP_ind_compiled_set_id.exists(I)
    then
        I_IND_COMPILED_SET_ID(I) := P_TP_ind_compiled_set_id(I);
    End if;

    If  P_TP_bill_rate.exists(I)
    then
        I_BILL_RATE(I) := P_TP_bill_rate(I);
    End if;

    If P_tp_job_id.exists(I)
    then
       I_tp_job_id(I)  := P_tp_job_id(I);
    End if;


    If  P_TP_base_amt.exists(I)
    then
        I_BASE_AMOUNT(I) := P_TP_base_amt(I);
    End if;

    If  P_TP_bill_markup_percentage.exists(I)
    then
        I_BILL_MARKUP_PERCENTAGE(I) := P_TP_bill_markup_percentage(I);
    End if;

    If  P_TP_rule_percentage.exists(I)
    then
        I_RULE_PERCENTAGE(I) := P_TP_rule_percentage(I);
    End if;

    If  P_TP_schedule_line_percentage.exists(I)
    then
        I_SCHEDULE_LINE_PERCENTAGE(I) := P_TP_schedule_line_percentage(I);
    End if;

 /* Added for cross proj */
    If  P_project_tp_rate_type.exists(I)
    then
        I_project_tp_rate_type(I) := P_project_tp_rate_type(I);
    End if;
    If  P_project_tp_rate_date.exists(I)
    then
        I_project_tp_rate_date(I) := P_project_tp_rate_date(I);
    End if;
    If  P_project_tp_exchange_rate.exists(I)
    then
        I_project_tp_exchange_rate(I) := P_project_tp_exchange_rate(I);
    End if;
    If  P_projfunc_tp_rate_type.exists(I)
    then
        I_projfunc_tp_rate_type(I) := P_projfunc_tp_rate_type(I);
    End if;
    If  P_projfunc_tp_rate_date.exists(I)
    then
        I_projfunc_tp_rate_date(I) := P_projfunc_tp_rate_date(I);
    End if;
    If  P_projfunc_tp_exchange_rate.exists(I)
    then
        I_projfunc_tp_exchange_rate(I) := P_projfunc_tp_exchange_rate(I);
    End if;
    I_tp_amt_type_code(I) := P_tp_amt_type_code(I);

    I_project_tp_currency_code(I)  := P_Prj_currency_code(I);
    I_projfunc_tp_currency_code(I) := P_projfunc_currency_code(I);
 /* End for cross proj*/



    I_ACCT_CURRENCY_CODE(I) := P_Acct_curr_code;

    if (L_PROV_ENABLED)
    Then
     If  (not G_project_category.exists(P_CC_Project_Id(I)))
     Then
       /* Client Extension to identify the cost accrual project */
        pa_cc_ca.identify_ca_project
             ( p_project_id => P_CC_Project_Id(I),
               x_cost_accrual_flag  => l_cost_accrual_flag );

        G_project_category(P_CC_Project_Id(I)) := l_cost_accrual_flag;
     End if;

     If ( G_project_category(P_CC_Project_Id(I)) = 'Y'
     and  P_ca_prov_code <> 'N' )
     Then
          I_PRV_ENABLED(I) := P_ca_prov_code;
     Elsif ( G_project_category(P_CC_Project_Id(I)) = 'N'
     and     P_nca_prov_code <> 'N' )
     Then
          I_PRV_ENABLED(I) := P_nca_prov_code;
      Else    /* else part added for bug 2770240 */
	  I_PRV_ENABLED(I) := 'N';
     End if;
    Else
         I_PRV_ENABLED(I) := 'N';
    End if;


 End Loop;


/** Call Transfer Price API ****/
/** Not Ready till today ( 13 - JUL - 1999 ) **/

pa_cc_transfer_price.GET_TRANSFER_PRICE
(
 P_MODULE_NAME                 => 'PAICGEN',
 P_PRVDR_ORGANIZATION_ID       => P_Prvdr_Organization,
 P_RECVR_ORG_ID                => P_Recvr_org_id,
 P_RECVR_ORGANIZATION_ID       => P_Recvr_Organization,
 P_EXPND_ORGANIZATION_ID       => P_Expnd_Organization,
 P_EXPENDITURE_ITEM_ID         => P_EI_id,
 P_EXPENDITURE_TYPE            => P_Expend_type,
 P_EXPENDITURE_ITEM_DATE       => P_EI_date,
 P_EXPENDITURE_CATEGORY        => P_Expenditure_category,
 P_LABOR_NON_LABOR_FLAG        => P_Labor_nl_flag,
 P_SYSTEM_LINKAGE_FUNCTION     => P_Sys_linkage,
 P_TASK_ID                     => P_Task_id,
 P_TP_SCHEDULE_ID              => P_TP_sch_id,
 P_DENOM_CURRENCY_CODE         => P_Denom_currency_code,
 P_PROJECT_CURRENCY_CODE       => P_Prj_currency_code,
 P_REVENUE_DISTRIBUTED_FLAG    => P_Revenue_distributed_flag,
 P_PROCESSED_THRU_DATE         => P_Processed_thru_date,
 P_COMPUTE_FLAG                => L_Compute_flag,
 P_TP_FIXED_DATE               => P_TP_fixed_date,
 P_DENOM_RAW_COST_AMOUNT       => P_Denom_raw_cost_amt,
 P_DENOM_BURDENED_COST_AMOUNT  => P_Denom_burdened_cost_amt,
 P_RAW_REVENUE_AMOUNT          => P_Raw_revenue_amt,
 P_PROJECT_ID                  => P_CC_Project_Id,
 P_QUANTITY                    => P_Quantity,
 P_INCURRED_BY_PERSON_ID       => P_Incurred_by_person_id,
 P_JOB_ID                      => P_Job_id,
 P_NON_LABOR_RESOURCE          => P_Non_labor_resource,
 P_NL_RESOURCE_ORGANIZATION_ID => P_NL_resource_organization,
 P_ARRAY_SIZE                  => P_No_of_records,
 P_DEBUG_MODE                  => PA_IC_INV_UTILS.G_DEBUG_MODE,
 X_DENOM_TP_CURRENCY_CODE      => I_DENOM_CURRENCY_CODE,
 X_DENOM_TRANSFER_PRICE        => I_DENOM_BILL_AMOUNT,
 X_ACCT_TP_RATE_TYPE           => I_ACCT_RATE_TYPE,
 X_ACCT_TP_RATE_DATE           => I_ACCT_RATE_DATE,
 X_ACCT_TP_EXCHANGE_RATE       => I_ACCT_EXCHANGE_RATE,
 X_ACCT_TRANSFER_PRICE         => I_BILL_AMOUNT,
 X_CC_MARKUP_BASE_CODE         => I_MARKUP_CALC_BASE_CODE,
 X_TP_IND_COMPILED_SET_ID      => I_IND_COMPILED_SET_ID,
 X_TP_BILL_RATE                => I_BILL_RATE,
 X_TP_BASE_AMOUNT              => I_BASE_AMOUNT,
 X_TP_BILL_MARKUP_PERCENTAGE   => I_BILL_MARKUP_PERCENTAGE,
 X_TP_SCHEDULE_LINE_PERCENTAGE => I_SCHEDULE_LINE_PERCENTAGE,
 X_TP_RULE_PERCENTAGE          => I_RULE_PERCENTAGE,
 X_tp_job_id                   => I_tp_job_id,
 X_ERROR_CODE                  => P_Error_code,
 X_RETURN_STATUS               => X_Error_Stage
/* Added for cross proj*/
 ,p_projfunc_currency_code      => p_projfunc_currency_code
 ,p_tp_amt_type_code            => p_tp_amt_type_code
 ,p_assignment_id               => p_assignment_id
 ,x_proj_tp_rate_type           => I_project_tp_rate_type
 ,x_proj_tp_rate_date           => I_project_tp_rate_date
 ,x_proj_tp_exchange_rate       => I_project_tp_exchange_rate
 ,x_proj_transfer_price         => I_project_transfer_price
 ,x_projfunc_tp_rate_type       => I_projfunc_tp_rate_type
 ,x_projfunc_tp_rate_date       => I_projfunc_tp_rate_date
 ,x_projfunc_tp_exchange_rate   => I_projfunc_tp_exchange_rate
 ,x_projfunc_transfer_price     => I_projfunc_transfer_price,
  /* End for cross proj*/
/*Bill rate discount */
        p_dist_rule                     => p_dist_rule,
        p_mcb_flag                      => p_mcb_flag,
        p_bill_rate_multiplier          => p_bill_rate_multiplier,
        p_raw_cost                      => p_raw_cost,
        p_labor_schdl_discnt            => p_labor_schdl_discnt,
        p_labor_schdl_fixed_date        => p_labor_schdl_fixed_date,
        p_bill_job_grp_id               => p_bill_job_grp_id,
        p_labor_sch_type                => p_labor_sch_type,
        p_project_org_id                => p_project_org_id,
        p_project_type                  => p_project_type,
        p_exp_func_curr_code            => p_exp_func_curr_code,
        p_incurred_by_organz_id         => p_incurred_by_organz_id,
        p_raw_cost_rate                 => p_raw_cost_rate,
        p_override_to_organz_id         => p_override_to_organz_id,
        p_emp_bill_rate_schedule_id     => p_emp_bill_rate_schedule_id,
        p_job_bill_rate_schedule_id     => p_job_bill_rate_schedule_id,
        p_exp_raw_cost                  => p_exp_raw_cost,
        p_assignment_precedes_task      => p_assignment_precedes_task,

        p_burden_cost                   => p_burden_cost,
        p_task_nl_bill_rate_org_id      => p_task_nl_bill_rate_org_id,
        p_proj_nl_bill_rate_org_id      => p_proj_nl_bill_rate_org_id,
        p_task_nl_std_bill_rate_sch     => p_task_nl_std_bill_rate_sch,
        p_proj_nl_std_bill_rate_sch     => p_proj_nl_std_bill_rate_sch,
        p_nl_task_sch_date              => p_nl_task_sch_date,
        p_nl_proj_sch_date              => p_nl_proj_sch_date,
        p_nl_task_sch_discount          => p_nl_task_sch_discount,
        p_nl_proj_sch_discount          => p_nl_proj_sch_discount,
        p_nl_sch_type                   => p_nl_sch_type,
        /* Added the last two parameters for Doosan rate api enhancement */
        p_task_nl_std_bill_rate_sch_id  => p_task_nl_std_bill_rate_sch_id,
        p_proj_nl_std_bill_rate_sch_id  => p_proj_nl_std_bill_rate_sch_id,
        p_uom_flag                      => p_uom_flag

 );



/* CBGA and Project Jobs */


       SELECT bill_job_group_id
         INTO l_job_group_id
         FROM pa_projects_all
        WHERE project_id = P_project_id;


 FOR I in 1 .. P_No_of_records
 LOOP

    BEGIN

      I_prov_proj_bill_job_id(I) := PA_Cross_Business_grp.IsMappedToJob(p_job_id(I), l_job_group_id);

      /* Added for bug 5251471 */
      PA_IC_INV_UTILS.log_message('process_invoice_details: job_id: ' || to_char(p_job_id(I)));
      PA_IC_INV_UTILS.log_message('process_invoice_details: prov_proj_bill_job_id: ' || to_char(I_prov_proj_bill_job_id(I)));

      IF I_prov_proj_bill_job_id(I) IS NULL THEN
        I_prov_proj_bill_job_id(I):= p_job_id(I);
      END IF;

      PA_IC_INV_UTILS.log_message('process_invoice_details: job_id: ' || to_char(p_job_id(I)));
      PA_IC_INV_UTILS.log_message('process_invoice_details: prov_proj_bill_job_id: ' || to_char(I_prov_proj_bill_job_id(I)));
      /* End of bug 5251471 */

    END;

END LOOP;



/** Call Tax API **/
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Calling Tax API.....');
  END IF;
/*Last two parameters added for customer account relation 2760630 */
  PA_OUTPUT_TAX.GET_DEFAULT_TAX_INFO_ARR
           ( P_Project_Id                => P_Project_Id,
             P_Customer_Id               => P_Customer_Id,
             P_Bill_to_site_use_id       => P_Bill_to_site_use_id,
             P_Ship_to_site_use_id       => P_Ship_to_site_use_id,
             P_Set_of_books_id           => P_Set_of_books_id,
             P_Expenditure_item_id       => P_EI_id,
             P_User_Id                   => P_User_Id,
             P_Request_id                => P_Request_id,
             P_No_of_records             => P_No_of_records,
             P_Compute_flag              => L_Compute_flag,
             P_Error_Code                => P_Error_Code,
--             X_Output_vat_tax_id         => I_OUTPUT_VAT_TAX_ID,
             X_Output_tax_code           => I_OUTPUT_TAX_CODE,
             X_Output_tax_exempt_flag    => I_OUTPUT_TAX_EXEMPT_FLAG,
             X_Output_tax_exempt_number  => I_OUTPUT_TAX_EXEMPT_NUMBER,
             X_Output_exempt_reason_code => I_TAX_EXEMPT_REASON_CODE,
             Pbill_to_customer_id        => P_Customer_Id,
             Pship_to_customer_id        => P_Customer_Id);

/** Select the existing invoice details for EI if exists **/

FOR I in 1..P_No_of_records
LOOP
-- Checck whether any invoice detail exists for that EI
-- If Yes, fetech the latest invoice details of the EI.
 BEGIN

   L_IND_REC := L_IND_REC_NULL; /*Bug 2296735 */

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Fetching Existing Invoice details for EI'||to_char(P_EI_ID(I)));
  END IF;
  SELECT  DET.*
  INTO    L_IND_REC
  FROM    PA_DRAFT_INVOICE_DETAILS DET
  WHERE   DET.EXPENDITURE_ITEM_ID
          = decode(nvl(P_AdjEI_id(I),0),0,P_EI_id(I),P_AdjEI_id(I))
  AND     DET.LINE_NUM             = ( SELECT MAX(I.LINE_NUM)
                                       FROM   PA_DRAFT_INVOICE_DETAILS I
                                       WHERE  I.EXPENDITURE_ITEM_ID  =
                                              DET.EXPENDITURE_ITEM_ID );
  RECORD_FOUND := TRUE;
  I_Line_num   := L_IND_REC.Line_Num;

 /*Change for bug 5370844*/
  SELECT cc_Cross_charge_code
  INTO l_cc_Cross_charge_code
  FROM pa_expenditure_items
  WHERE expenditure_item_id = P_EI_id(I);

  IF nvl(P_AdjEI_id(I),0) <> 0 AND l_cc_Cross_charge_code = 'N'
  THEN
        RECORD_FOUND := FALSE;
  END IF;
 /*End of code change for bug 5370844*/

 EXCEPTION
   When NO_DATA_FOUND
   Then
        RECORD_FOUND := FALSE;
        I_Line_num   := 0;
 END;

-- Check whether any cc distribution exists for that invoice details.
 BEGIN

    IF g1_debug_mode  = 'Y' THEN
    	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Fetching Existing Cross Charge Distribution.....');
    END IF;

    open get_cc_dist(L_IND_REC.EXPENDITURE_ITEM_ID);
    fetch get_cc_dist INTO L_CC_REC;
    if get_cc_dist%notfound
    then
       IF g1_debug_mode  = 'Y' THEN
       	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Fetching Cross charge distribution - not Found');
       END IF;
       CC_RECORD_FOUND := FALSE;
    else
       IF g1_debug_mode  = 'Y' THEN
       	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Fetching Cross charge distribution - Found');
       	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Line - Found'||to_char(L_CC_REC.line_num));
       END IF;
       CC_RECORD_FOUND := TRUE;
    end if;

    close get_cc_dist;

 EXCEPTION
     When others
     Then
       IF g1_debug_mode  = 'Y' THEN
       	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Error in Fetching Cross charge distribution.....');
       END IF;
       raise;
 END;

/* Read attributes from CDL */
 IF ((I_PRV_ENABLED(I) <> 'N')
 AND (P_Cross_charge_code(I) = 'I')
 AND (P_Net_zero_flag(I) = 'N'))
 THEN
   BEGIN

      IF g1_debug_mode  = 'Y' THEN
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || ' Fetching Cost Distribution Lines for EI :'||to_char(P_EI_id(I)));
      END IF;
      /*changes done for burden schedule change enhancement */
      SELECT  decode(I_PRV_ENABLED(I),'B',(cdl.DENOM_BURDENED_COST+NVL(CDL.DENOM_BURDENED_CHANGE,0)),
                                      'R',cdl.DENOM_RAW_COST),
              decode(I_PRV_ENABLED(I),'B',(cdl.ACCT_BURDENED_COST+NVL(CDL.ACCT_BURDENED_CHANGE,0)),
                                      'R',cdl.ACCT_RAW_COST),
              cdl.DENOM_CURRENCY_CODE,
              cdl.ACCT_CURRENCY_CODE,
              cdl.ACCT_RATE_DATE,
              cdl.ACCT_RATE_TYPE,
              cdl.ACCT_EXCHANGE_RATE,
              cdl.LINE_NUM,
              cdl.IND_COMPILED_SET_ID
      INTO    l_denom_transfer_price,
              l_amount,
              l_denom_tp_currency_code,
              l_acct_currency_code,
              l_acct_tp_rate_date,
              l_acct_tp_rate_type,
              l_acct_tp_exchange_rate,
              l_line_num,
              l_ind_compiled_set_id
      FROM    pa_cost_distribution_lines_all cdl
      WHERE   cdl.EXPENDITURE_ITEM_ID  = P_EI_id(I)
      AND     cdl.LINE_NUM_REVERSED  IS NULL
      AND     cdl.LINE_NUM           = ( SELECT MAX(cdl1.LINE_NUM)
                                    FROM   pa_cost_distribution_lines_all cdl1
                                    WHERE  cdl1.EXPENDITURE_ITEM_ID =
                                           cdl.EXPENDITURE_ITEM_ID
                                    AND    cdl.LINE_NUM_REVERSED  IS NULL
                                    AND    cdl1.line_type = 'R' );
      IF g1_debug_mode  = 'Y' THEN
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'After Fetching Cost Distribution Lines.....');
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Display Method...'||P_burden_disp_method(I));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Cross Charge...'||P_Cross_Charge_code(I));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Base Method...'||I_PRV_ENABLED(I));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'date...'||P_EI_date(I));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Expn Org...'||to_char(P_Expnd_Organization(I)));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Exp type ...'||P_Expend_type(I));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Exp Id ...'||to_char(P_EI_id(I)));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Task id ...'||to_char(P_Task_id(I)));
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'TP Price ...'||to_char(l_denom_transfer_price));
      END IF;

      if ((P_burden_disp_method.exists(I))
      and (P_burden_disp_method(I) = 'D')
      and (I_PRV_ENABLED(I) = 'B')
      and (P_Cross_Charge_code(I) = 'I'))
      Then
      IF g1_debug_mode  = 'Y' THEN
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Enter.....');
      END IF;
  /*        l_multiplier := PA_COST_PLUS.Get_Mltplr_For_Compiled_Set
                        ( l_ind_compiled_set_id );
            l_amount               := (1 + l_multiplier ) * l_amount;
            l_denom_transfer_price
                    := ( 1 + l_multiplier ) * l_denom_transfer_price;  Commented for bug 3180315 */

      /* Start of changes for bug 3180315 */
 /* Made changes in burden cost calculation for bug 3180315 so that burden cost calculation process used here
    is in synch with that in PAXCCTPB.pls (PA_CC_TRANSFER_PRICE) package where changes were done for bug 2215942 */

                     DECLARE
                        l_burden_sch_rev_id Number;
                        l_Stage Number;
                        l_Status Number;
                        l_burden_calc_amount_l number;
                        l_tp_ind_compiled_set_id_l Number;
                        l_rate_schedule_id    Number;
                        t_rate_sch_rev_id number;
                        t_sch_fixed_date date;


                     BEGIN

      IF g1_debug_mode  = 'Y' THEN
        PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Inside Burden cost Calculation.....');
      END IF;

    PA_CLIENT_EXTN_BURDEN.Override_Rate_Rev_Id(
            'ACTUAL',
             P_EI_id(I),                  -- Transaction Item Id
            'PA',                         -- Transaction Type
            P_Task_id(I),                 -- Task Id
            'C',                          -- Schedule Type
            to_date(P_EI_date(I),'YYYY/MM/DD'),                 -- EI Date File.Date.5
            t_sch_fixed_date,             -- Sch_fixed_date (Out)
            t_rate_sch_rev_id,            -- Rate_sch_rev_id (Out)
            l_status);                    -- Status   (Out)

    IF (t_rate_sch_rev_id IS NOT NULL) THEN
         l_burden_sch_rev_id := t_rate_sch_rev_id;
             PA_COST_PLUS.Get_Burden_Amount1(
                         P_Expend_type(I),
                         P_Expnd_Organization(I),
                        l_denom_transfer_price,
                        l_burden_calc_amount_l,
                        l_burden_sch_rev_id,
                        l_tp_ind_compiled_set_id_l,
                        l_status,
                        l_stage
                        );


 l_denom_transfer_price :=
                                 l_denom_transfer_price+l_burden_calc_amount_l;

                        l_Stage :=0;
                        l_Status :=0;
                        l_burden_calc_amount_l :=0;
                        l_tp_ind_compiled_set_id_l :=0;

         PA_COST_PLUS.Get_Burden_Amount1(
                         P_Expend_type(I),
                         P_Expnd_Organization(I),
                        l_amount,
                        l_burden_calc_amount_l,
                        l_burden_sch_rev_id,
                        l_tp_ind_compiled_set_id_l,
                        l_status,
                        l_stage
                        );

    l_amount :=
                                 l_amount+l_burden_calc_amount_l;

   ELSE


/* get the task level burden schedule id by considering the task level overrides  */
                        select NVL(OVR_COST_IND_RATE_SCH_ID, COST_IND_RATE_SCH_ID)
                          into l_rate_schedule_id
                          from pa_tasks
                         where task_id in
                             ( select task_id
                                 from pa_expenditure_items_all
                                where expenditure_item_id = P_EI_id(I)
                             );
/* Get the burden amount from the call to the procedure PA_COST_PLUS.Get_Burden_Amount,
   which gets the revision for the given burden schedule, then burden structure,
   then cost base from the burden structure corresponding to the expenditure type,
   then sum of the compiled multipliers  */

             PA_COST_PLUS.Get_Burden_Amount(
                        l_rate_schedule_id,
                        to_Date(P_EI_date(I),'YYYY/MM/DD'),/*File.Date.5*/
                        P_Expend_type(I),
                        P_Expnd_Organization(I),
                        l_denom_transfer_price,
                        l_burden_calc_amount_l,
                        l_burden_sch_rev_id,
                        l_tp_ind_compiled_set_id_l,
                        l_status,
                        l_stage
                        );

     l_denom_transfer_price :=
                                 l_denom_transfer_price+l_burden_calc_amount_l;

                        l_burden_sch_rev_id :=0;
                        l_Stage :=0;
                        l_Status :=0;
                        l_burden_calc_amount_l :=0;
                        l_tp_ind_compiled_set_id_l :=0;

          PA_COST_PLUS.Get_Burden_Amount(
                        l_rate_schedule_id,
                        to_Date(P_EI_date(I),'YYYY/MM/DD'),/*File.date.5*/
                        P_Expend_type(I),
                        P_Expnd_Organization(I),
                        l_amount,
                        l_burden_calc_amount_l,
                        l_burden_sch_rev_id,
                        l_tp_ind_compiled_set_id_l,
                        l_status,
                        l_stage
                        );


                         l_amount :=
                                 l_amount+l_burden_calc_amount_l;

      END IF;  /* If t_rate_sch_rev_id IS NOT NULL */

      EXCEPTION
                        when no_data_found then
                             Raise;

                          When Others  Then
                            Raise;
    END;

/* End of changes for bug 3180315 */

      end if;


      L_CDL_REC.DENOM_TP_CURRENCY_CODE := l_denom_tp_currency_code;
      L_CDL_REC.DENOM_TRANSFER_PRICE   := l_denom_transfer_price;
      L_CDL_REC.AMOUNT                 := l_amount;
      L_CDL_REC.ACCT_CURRENCY_CODE     := l_acct_currency_code;
      L_CDL_REC.ACCT_TP_RATE_TYPE      := l_acct_tp_rate_type;
      L_CDL_REC.ACCT_TP_RATE_DATE      := l_acct_tp_rate_date;
      L_CDL_REC.ACCT_TP_EXCHANGE_RATE  := l_acct_tp_exchange_rate;
      L_CDL_REC.DR_CODE_COMBINATION_ID := P_provider_dr_ccid(I);
      L_CDL_REC.CR_CODE_COMBINATION_ID := P_provider_cr_ccid(I);
      L_CDL_REC.REFERENCE_2            := I_PRV_ENABLED(I);
      L_CDL_REC.CROSS_CHARGE_CODE      := P_Cross_charge_code(I);
      L_CDL_REC.CDL_LINE_NUM           := l_line_num;
      L_CDL_REC.EXPENDITURE_ITEM_DATE  := to_date(P_EI_date(I),'YYYY/MM/DD');/*File.Date.5*/
/*2229894      L_CDL_REC.EXPENDITURE_ITEM_DATE  := to_date(P_EI_date(I),'DD-MM-YY'); */
      L_CDL_REC.EXPENDITURE_ITEM_ID    := P_EI_ID(I);
      L_CDL_REC.PROJECT_ID             := P_CC_Project_Id(I);
      L_CDL_REC.TASK_ID                := P_Task_id(I);
      L_CDL_REC.SYSTEM_LINKAGE_FUNCTION:= P_Sys_linkage(I);  /* Added for 3857986 */
   EXCEPTION
    WHEN others
    Then
      IF g1_debug_mode  = 'Y' THEN
      	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Error in Fetching Cost Distribution Lines.....');
      END IF;
      Raise;
   END;
 END IF;

-- Process the CC_Cross_charge_code as 'B'/'N'/'X'

 If P_Cross_charge_code(I) <> 'I'
 Then
    IF g1_debug_mode  = 'Y' THEN
    	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Processing Cross_charge_code <> I...');
    END IF;
    /** If invoice details exist and not invoiced **/
    If (RECORD_FOUND)
    Then
      If ( L_IND_REC.Draft_invoice_num IS NULL
      AND  L_IND_REC.Line_num_reversed IS NULL)
      Then
         /** The existing record is to be deleted **/
         delete_row(L_IND_REC);
         if (CC_RECORD_FOUND)
         then
           /** Delete provider reclass entry **/
            delete_all_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,I);
         end if;
        /** Mark the EI 's ic processed flag as no processing
            required. **/
         add_ei(L_IND_REC.expenditure_item_id);
      Elsif ( L_IND_REC.Draft_invoice_num IS NULL
      AND     L_IND_REC.Line_num_reversed IS NOT NULL)
      Then
         update_row(L_IND_REC,'N');
      Elsif (L_IND_REC.Draft_invoice_num IS not NULL
      AND  L_IND_REC.Line_num_reversed IS NULL)
      Then
         /** Reverse existing invoice details **/
         reverse_row(p_inv_rec=>L_IND_REC);
         if (CC_RECORD_FOUND)
         then
             reverse_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,
                             to_Date(P_EI_date(I),'YYYY/MM/DD'),
                             P_Sys_linkage(I),  /* Added for 3857986 */
                             L_CC_REC,
                             I);
         end if;
      Elsif (L_IND_REC.Draft_invoice_num IS not NULL
      AND    L_IND_REC.Line_num_reversed IS NOT NULL)
      Then
        /** Mark the EI 's ic processed flag as no processing
            required. **/
         add_ei(L_IND_REC.expenditure_item_id);
      End if;
   Else
      /** Mark the EI 's ic processed flag as no processing
          required. **/
      add_ei(L_IND_REC.expenditure_item_id);
   End if;
 End if;

  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'P Error code - ' || P_Error_Code(I));
  END IF; /*Added for bug 2296735 */
-- Process the CC_Cross_charge_code as 'I'
 If P_Cross_charge_code(I) = 'I'
 Then
  IF g1_debug_mode  = 'Y' THEN
  	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Processing Cross_charge_code = I...');
  END IF;
  If P_Error_Code(I) Is NULL
  Then
   If (L_AdjEI_id(I) is null  or L_AdjEI_id(I) = 0 )
   Then
    if (P_Net_zero_flag(I) = 'N')
    Then
     If (not RECORD_FOUND)
     then
       /** Create New Rows.......**/
       build_row ( P_Expenditure_item_id  => P_EI_Id(I),
                      P_Project_Id        => P_Project_id,
                      P_CC_Project_id     => P_CC_Project_id(I),
                      P_CC_Tax_task_id    => P_CC_Tax_task_id(I),
                      P_Rev_ccid          => P_revenue_ccid(I),
                      P_Arr_position      => I,
                      X_Inv_rec           => X_Inv_rec );
       /** Create CC distribution **/
       if (I_PRV_ENABLED(I) <> 'N' )
       then

           L_CDL_REC.REFERENCE_1 := to_char(X_Inv_rec.DRAFT_INVOICE_DETAIL_ID);
           build_cc_dist(L_CDL_REC,
                         0,I);
       end if;
     Elsif (L_IND_REC.Draft_invoice_num IS  NULL
     AND    L_IND_REC.Line_num_reversed IS  NULL)
     Then
        if is_new_details(L_IND_REC,P_revenue_ccid(I),I)
        then
           build_row('U',I,P_revenue_ccid(I),L_IND_REC);
        else
           update_row(L_IND_REC,'N');
        end if;
        if ((I_PRV_ENABLED(I) <> 'N' )
        and (CC_RECORD_FOUND))
        then
            update_cc_dist(L_CDL_REC,L_CC_REC,I);
        end if;
     Elsif (L_IND_REC.Draft_invoice_num IS not NULL
     AND    L_IND_REC.Line_num_reversed IS  NULL)
     Then
        if is_new_details(L_IND_REC,P_revenue_ccid(I),I)
        then
           L_IND_REC_NEW := L_IND_REC;
           reverse_row(p_inv_rec=>L_IND_REC);
           build_row('A',I,P_revenue_ccid(I),L_IND_REC_NEW);
           if (I_PRV_ENABLED(I) <> 'N')  AND (CC_RECORD_FOUND)  /* added AND clause  for bug 2293378 */
           then
             reverse_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,
                             to_Date(P_EI_date(I),'YYYY/MM/DD'),/*File.Date.5*/
                             P_Sys_linkage(I),  /* Added for 3857986 */
                             L_CC_REC,
                             I);
             L_CDL_REC.REFERENCE_1 := to_char(L_IND_REC_NEW.DRAFT_INVOICE_DETAIL_ID);
             build_cc_dist(L_CDL_REC,
                           L_CC_REC.line_num,
                           I);
           end if;
        End if;
     Elsif (L_IND_REC.Draft_invoice_num IS not NULL
     AND    L_IND_REC.Line_num_reversed IS not NULL)
     Then
        build_row('A',I,P_revenue_ccid(I),L_IND_REC);
        if (I_PRV_ENABLED(I) <> 'N')
        then
            L_CDL_REC.REFERENCE_1 := to_char(L_IND_REC.DRAFT_INVOICE_DETAIL_ID);
            build_cc_dist(L_CDL_REC,
                          L_CC_REC.line_num,
                          I);
        end if;
     Elsif (L_IND_REC.Draft_invoice_num IS NULL
     AND    L_IND_REC.Line_num_reversed IS not NULL)
     Then
        update_row(L_IND_REC,'N');
     End If;
    End if;
   Else /* For adjusted EI */
    If RECORD_FOUND
    Then
       If (L_IND_REC.Draft_invoice_num IS NULL
       AND L_IND_REC.Line_num_reversed IS NULL)
       Then
           delete_row(L_IND_REC);
           if (CC_RECORD_FOUND)
           then
               delete_all_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,I);
           end if;
           add_ei(P_EI_id(I));
           add_ei(P_AdjEI_id(I));
       Elsif (L_IND_REC.Draft_invoice_num IS not NULL
       AND    L_IND_REC.Line_num_reversed IS NULL)
       Then
         PA_IC_INV_UTILS.log_message
                   ('L_IND_REC.Draft_invoice_num IS not NULL, L_IND_REC.Line_num_reversed IS NULL');
           L_IND_REC.Expenditure_item_id := P_EI_id(I);
           L_IND_REC.Line_num            := Null;
         /* Changed the call to reverse_row for bug 2770182 */

           reverse_row(p_inv_rec=>L_IND_REC,
                       p_adjusted_ei=>p_AdjEI_Id(I));
           if (CC_RECORD_FOUND)
           then
             reverse_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,
                             to_date(P_EI_date(I),'YYYY/MM/DD'),/*File.Date.5*/
                             P_Sys_linkage(I),  /* Added for 3857986 */
                             L_CC_REC,
                             I);
           end if;
       Else
           add_ei(P_EI_id(I));
           add_ei(P_AdjEI_id(I));
       End if;
    Else
       add_ei(P_EI_id(I));
       add_ei(P_AdjEI_id(I));
    End if; /* Record Found */
   End if; /* Adjusted EI is null */
  Else
    if (L_IND_REC.Draft_invoice_num IS NULL
    AND L_IND_REC.Line_num_reversed IS NULL)
    Then
        delete_row(L_IND_REC);
        if (CC_RECORD_FOUND)
        then
            delete_all_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,I);
        end if;
    End If;
  End If; /* P_Error_code(I) is Null */
 End if; /* CC_Cross_charge_code = 'I' */

 /* Process the EI if not processed in invoice details
    adjustment or creation */
 If (not(I_EXP_ITEM_USED.exists(I)) /* Step 1 */
 and ( P_Net_zero_flag(I) = 'N' )
 and ( P_Error_code(I) IS NULL ))
 Then
    IF g1_debug_mode  = 'Y' THEN
    	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Processing provider reclass only part...');
    	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Enabled...'||I_PRV_ENABLED(I));
    END IF;
    if CC_RECORD_FOUND
    then
    IF g1_debug_mode  = 'Y' THEN
    	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Record...');
    END IF;
    end if;
    IF g1_debug_mode  = 'Y' THEN
    	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Cross Charge Code...'||P_Cross_charge_code(I));
    END IF;
    if (( I_PRV_ENABLED(I) =  'N') /* Step 2 */
    and (CC_RECORD_FOUND))
    Then
         IF g1_debug_mode  = 'Y' THEN
         	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Processing provider reclass only reversing/delete .2');
         END IF;
         reverse_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,
                         to_Date(P_EI_date(I),'YYYY/MM/DD'),/*file.Date.5*/
                         P_Sys_linkage(I),  /* Added for 3857986 */
                         L_CC_REC,
                         I);
    Elsif ((I_PRV_ENABLED(I) <> 'N')
    and    (P_Cross_charge_code(I) = 'I'))
    Then
           IF g1_debug_mode  = 'Y' THEN
           	PA_IC_INV_UTILS.log_message('process_invoice_details: ' || 'Processing provider reclass only reversing/delete .3');
           END IF;
           /* If existing line is not transferred to GL */
           If (( L_CC_REC.TRANSFER_STATUS_CODE = 'P')
           and( CC_RECORD_FOUND))
           Then
               update_cc_dist(L_CDL_REC,L_CC_REC,I);
           Else
           /* If existing line is transferred to Gl, reverse the original
              and create the new */
             l_line_num := 0;
             if (CC_RECORD_FOUND)
             then
                 reverse_cc_dist(L_IND_REC.DRAFT_INVOICE_DETAIL_ID,
                                 to_date(P_EI_date(I),'YYYY/MM/DD'),/*File.Date.5*/
                                 P_Sys_linkage(I),  /* Added for 3857986 */
                                 L_CC_REC,
                                 I);
                 l_line_num := L_CC_REC.line_num;
             end if;
             L_CDL_REC.REFERENCE_1 := to_char(L_IND_REC.DRAFT_INVOICE_DETAIL_ID);
             build_cc_dist(L_CDL_REC,
                           l_line_num,
                           I);
           End if; /* L_CC_REC.TRANSFERRED_STATUS_CODE = 'P' */
    End if;/* Step 2 */
 End if;/* Step 1 */


 /* Return the TP attributes */
 P_Denom_TP_currency_code(I) := I_DENOM_CURRENCY_CODE(I);
 P_Denom_transfer_price(I)   := I_DENOM_BILL_AMOUNT(I) ;
 P_Acct_TP_rate_type(I)      := I_ACCT_RATE_TYPE(I);
 P_Acct_TP_rate_date(I)      := I_ACCT_RATE_DATE(I);
 P_Acct_TP_exchange_rate(I)  := I_ACCT_EXCHANGE_RATE(I);
 P_Acct_transfer_price(I)    := I_BILL_AMOUNT(I);
 P_CC_markup_base_code(I)    := I_MARKUP_CALC_BASE_CODE(I);
 P_TP_ind_compiled_set_id(I) := I_IND_COMPILED_SET_ID(I);
 P_TP_bill_rate(I)           := I_BILL_RATE(I) ;
 P_TP_base_amt(I)            := I_BASE_AMOUNT(I);
 P_TP_bill_markup_percentage(I) := I_BILL_MARKUP_PERCENTAGE(I);
 P_TP_rule_percentage(I)     := I_RULE_PERCENTAGE(I);
 P_TP_schedule_line_percentage(I) := I_SCHEDULE_LINE_PERCENTAGE(I);

/*Added for cross proj */
 P_project_tp_rate_type(I)       := I_project_tp_rate_type(I);
 P_project_tp_rate_date(I)       := I_project_tp_rate_date(I);
 P_project_tp_exchange_rate(I)   := I_project_tp_exchange_rate(I);
 P_project_transfer_price(I)     := I_project_transfer_price(I);
 P_projfunc_tp_rate_type(I)      := I_projfunc_tp_rate_type(I);
 P_projfunc_tp_rate_date(I)      := I_projfunc_tp_rate_date(I);
 P_projfunc_tp_exchange_rate(I)  := I_projfunc_tp_exchange_rate(I);
 P_projfunc_transfer_price(I)    := I_projfunc_transfer_price(I);
 /* End for cross proj*/

/* CBGA and project Jobs */

 P_tp_job_id(I)              := I_tp_job_id(I);
 P_prov_proj_bill_job_id(I)  := I_prov_proj_bill_job_id(I);

End Loop;

-- Apply all physical database changes
apply_db_changes (P_Error_Code ,
                  P_EI_id ,
                  P_No_of_records );


EXCEPTION
 When others
 Then
      Raise;
END process_invoice_details;

-- Apply all pending insert changes in Bulk
PROCEDURE apply_ins_changes IS
BEGIN
 PA_INVOICE_DETAIL_PKG.insert_rows(P_Insert_tab);

 if (PA_CC_BL_PROCESS.g_icnt > 0 )
 then
     PA_CC_BL_PROCESS.mass_insert;
 end if;
END apply_ins_changes;

-- Procedure to reverse provider reclass entries from
-- Invoice cancellation
--
PROCEDURE reverse_preclass (
  P_inv_detail_id        PA_PLSQL_DATATYPES.IdTabTyp,
  P_new_inv_detail_id    PA_PLSQL_DATATYPES.IdTabTyp,
  P_EI_id                PA_PLSQL_DATATYPES.IdTabTyp,
  P_EI_date              PA_PLSQL_DATATYPES.Char30TabTyp,
  P_Sys_Linkage          PA_PLSQL_DATATYPES.Char30TabTyp, /* Added for 3857986 */
  P_tab_count            NUMBER) IS

  l_cc_dist_rec          get_cc_dist%rowtype;

BEGIN
   FOR  I in 1..P_tab_count
   LOOP

  /* Open the cursor that checks if provider reclass rows are
      created corresponding to these Draft invoice details

      If Yes then reverse the rows

   */

   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('reverse_preclass: ' || 'Checking for reclasss for DID id  = '
                                  ||P_inv_detail_id(I)||' EI Id = '
                                  ||P_EI_id (I) );
   END IF;
   OPEN get_cc_dist( P_EI_id (I));

   FETCH get_cc_dist INTO l_cc_dist_rec;

   IF get_cc_dist%FOUND THEN
            reverse_cc_dist (
                            P_new_inv_detail_id(I),
                            P_EI_date(I),
                            P_Sys_linkage(I),  /* Added for 3857986 */
                            l_cc_dist_rec,
                            1);

   IF g1_debug_mode  = 'Y' THEN
   	pa_ic_inv_utils.log_message('reverse_preclass: ' || 'Created CC Dist line Id  = '
                                ||l_cc_dist_rec.CC_DIST_LINE_ID);
   END IF;

   END IF;

   CLOSE get_cc_dist;

   END LOOP;
END reverse_preclass;

END PA_INVOICE_DETAIL_PROCESS;

/

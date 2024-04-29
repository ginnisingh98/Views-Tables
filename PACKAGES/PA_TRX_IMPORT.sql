--------------------------------------------------------
--  DDL for Package PA_TRX_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TRX_IMPORT" AUTHID CURRENT_USER AS
/* $Header: PAXTTRXS.pls 120.9 2006/08/15 07:38:45 cmishra noship $ */
/*#
 * Oracle Projects provides a single open interface, called Transaction Import.
 * These procedures are called before and after the Transaction Import interface process.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Post-import{Transaction import}.
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
-- BUG: 4600792 PQE: R12 CHANGE AWARD END WHEN ENCUMBRANCE EXISTS, IMPORT ENC REVERSALS FOR CLOSE
G_validate_proj_tsk_Ei_Date VARCHAR2 (1) := 'Y';

G_cash_based_accounting VARCHAR2 (1);			/* REL12 */
--Identifier which is set to 'Y' if cash basis accounting is setup.
-- REL12 AP Lines Uptake-- Cash based accounting support--

G_finalPaymentID NUMBER;

  --
  -- Bug : 4962731
  --     : R12.PJ:XB1:QA:BC:INCORRECT AMOUNTS INTERFACED TO PROJECTS IN CASH BASED ACC
  -- Functionality :
  --       Discount is applicable when discount method is EXPENSE
  --       Discount is applicable for tax distributions  when discount method is TAX
  --       Discount is not applicable when discount method is 'SYSTEM'
  --       Discount is also based on the discount profile start date
  --       ap payment record includes the discount amount and we do not need to interface
  --       discount record because we are interfacing the payments.
  --       But we need to relieve corresponding inv dist amount paid to relieve the ap commitment amount.
  --       ap amount to relieve := payment amunt + discount amount (when applicable).
  -- ====================================================================================================
  G_Discount_Method              VARCHAR2(10);
  G_Profile_Discount_Start_date  DATE;

PROCEDURE GetTrxSrcInfo (X_trx_src IN VARCHAR2);

PROCEDURE GetEtypeInfo (X_etype IN VARCHAR2,
                        X_date IN DATE);

PROCEDURE GetNlrInfo (X_nlr IN VARCHAR2,
                      X_nlro_id IN NUMBER);

PROCEDURE CheckDupItem (X_trx_source IN VARCHAR2,
                        X_trx_ref IN VARCHAR2,
			X_status OUT NOCOPY VARCHAR2);

PROCEDURE CheckDupAdjItem (X_adj_item_id IN NUMBER,
                           X_status OUT NOCOPY VARCHAR2);

--SST Changes modified procedure name from GetProjBcostFlag to
-- GetProjTypeInfo, also added project type class parameter.

  PROCEDURE GetProjTypeInfo (X_project_id IN NUMBER,
			     X_proj_bcost_flag OUT NOCOPY VARCHAR2,
			     X_proj_type_class OUT NOCOPY VARCHAR2,
			     X_burden_amt_display_method OUT NOCOPY VARCHAR2,
			     X_Total_Burden_Flag OUT NOCOPY VARCHAR2);

FUNCTION CheckCCID (ccid NUMBER) RETURN NUMBER;
--pragma RESTRICT_REFERENCES (CheckCCID, WNDS, WNPS);

/* Added the function below for bug number 1254143. Bug 1426802 changed NUMBER TO VARCHAR2(30) */
FUNCTION GetOrgName (employee_number VARCHAR2,
	    expenditure_item_date DATE,
	    business_group_name IN VARCHAR2,
	    person_type IN varchar2 default NULL)
RETURN VARCHAR2;
--pragma RESTRICT_REFERENCES (GetOrgName, WNDS, WNPS);

PROCEDURE Validate_VI (X_vendor_number IN VARCHAR2 DEFAULT NULL,
	               X_employee_number IN VARCHAR2 DEFAULT NULL,
	               X_result OUT NOCOPY NUMBER,
		       X_status OUT NOCOPY VARCHAR2);


PROCEDURE ValidateItem (X_trx_src IN VARCHAR2,
                        X_enum IN VARCHAR2,
	                X_oname IN VARCHAR2,
			X_end_date IN DATE,
	                X_ei_date IN DATE,
			X_etype IN VARCHAR2,
	                X_pnum IN VARCHAR2,
			X_tnum IN VARCHAR2,
	                X_nlr IN VARCHAR2,
			X_nlro_name IN VARCHAR2,
	                X_qty IN NUMBER,
			X_denom_raw_cost IN NUMBER,
	                X_module IN VARCHAR2,
			X_trx_ref IN VARCHAR2,
	                X_match_flag IN VARCHAR2,
			X_entered_by IN NUMBER,
	                X_att_cat IN VARCHAR2,
			X_att1 IN OUT NOCOPY VARCHAR2,
	      X_att2 IN OUT NOCOPY VARCHAR2,
	      X_att3 IN OUT NOCOPY VARCHAR2,
	      X_att4 IN OUT NOCOPY VARCHAR2,
	      X_att5 IN OUT NOCOPY VARCHAR2,
	      X_att6 IN OUT NOCOPY VARCHAR2,
	      X_att7 IN OUT NOCOPY VARCHAR2,
	      X_att8 IN OUT NOCOPY VARCHAR2,
	      X_att9 IN OUT NOCOPY VARCHAR2,
	      X_att10 IN OUT NOCOPY VARCHAR2,
	      X_drccid IN NUMBER,
	      X_crccid IN NUMBER,
	      X_gl_date IN OUT NOCOPY DATE  -- bug 3357936 change param to in out,
	      , X_denom_burdened_cost IN OUT NOCOPY NUMBER,
	      X_system_linkage IN VARCHAR2,
	      X_status OUT NOCOPY VARCHAR2,
	      X_bill_flag OUT NOCOPY VARCHAR2,
	      X_receipt_currency_amount IN NUMBER default null,
	      X_receipt_currency_code IN VARCHAR2 default NULL,
	      X_receipt_exchange_rate IN OUT NOCOPY NUMBER,
	      X_denom_currency_code IN OUT NOCOPY VARCHAR2,
	      X_acct_rate_date IN OUT NOCOPY DATE,
	      X_acct_rate_type IN OUT NOCOPY VARCHAR2,
	      X_acct_exchange_rate IN OUT NOCOPY NUMBER,
	      X_acct_raw_cost IN NUMBER default NULL,
	      X_acct_burdened_cost IN OUT NOCOPY NUMBER,
	      X_acct_exchange_rounding_limit IN NUMBER default NULL,
	      X_project_currency_code IN OUT NOCOPY VARCHAR2,
	      X_project_rate_date IN OUT NOCOPY DATE,
	      X_project_rate_type IN OUT NOCOPY VARCHAR2,
	      X_project_exchange_rate IN OUT NOCOPY NUMBER,
	      X_project_raw_cost IN OUT NOCOPY NUMBER,
	      X_project_burdened_cost IN OUT NOCOPY NUMBER
	      /* Trx_Import Enhancement */
	      , X_override_to_oname IN VARCHAR2 default NULL,
	      X_vendor_number IN VARCHAR2 default NULL, X_org_id IN NUMBER,
	      X_Business_Group_Name IN VARCHAR2 default NULL, -- PA - I Changes,
	      X_Projfunc_currency_code IN OUT NOCOPY VARCHAR2,
	      X_Projfunc_cost_rate_date IN OUT NOCOPY DATE,
	      X_Projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2,
	      X_Projfunc_cost_exchange_rate IN OUT NOCOPY NUMBER,
	      X_actual_project_raw_cost IN OUT NOCOPY NUMBER,
	      X_actual_project_burdened_cost IN OUT NOCOPY NUMBER,
	      X_Assignment_Name IN OUT NOCOPY VARCHAR2,
	      X_Work_Type_Name IN OUT NOCOPY VARCHAR2,  -- PA J Changes,
	      X_Accrual_Flag IN VARCHAR2,    -- PA - L Changes,
	      P_project_id IN NUMBER DEFAULT NULL,
	      P_task_id IN NUMBER DEFAULT NULL,
	      P_person_id IN NUMBER DEFAULT NULL,
	      P_organization_id IN NUMBER DEFAULT NULL,
	      P_NLR_Org_Id IN NUMBER DEFAULT NULL,
	      P_Vendor_Id IN NUMBER DEFAULT NULL,
	      P_Override_Organization_Id IN NUMBER DEFAULT NULL,
	      P_Person_business_Group_Id IN NUMBER DEFAULT NULL,
	      P_assignment_id IN NUMBER DEFAULT NULL,
	      P_work_type_id IN NUMBER DEFAULT NULL,
	      P_Emp_Org_Id IN NUMBER DEFAULT NULL,
	      P_Emp_Job_Id IN NUMBER DEFAULT NULL
/* Added parameter X_txn_interface_id for bug 2563364 */
	      , X_txn_interface_id IN NUMBER default NULL, P_po_number IN VARCHAR2 default NULL	/* cwk */
	      , P_po_header_id IN OUT NOCOPY NUMBER,
	      P_po_line_num IN NUMBER default NULL,
	      P_po_line_id IN OUT NOCOPY NUMBER,
	      P_person_type IN VARCHAR2 default NULL,
	      P_po_price_type IN VARCHAR2 default NULL
/* REL12-AP Lines uptake */
	      , p_adj_exp_item_id IN NUMBER default NULL,
	      p_fc_document_type IN varchar2 default NULL);

PROCEDURE
ValidateOrgId (X_org_id IN NUMBER, X_status OUT NOCOPY VARCHAR2);

PROCEDURE
import (X_transaction_source IN VARCHAR2, X_batch IN VARCHAR2,
	X_xface_id IN NUMBER, X_userid IN NUMBER,
	X_online_exp_comment IN VARCHAR2 DEFAULT NULL);

PROCEDURE
import1 (X_transaction_source IN VARCHAR2, X_batch IN VARCHAR2,
	 X_xface_id IN NUMBER, X_userid IN NUMBER,
	 X_online_exp_comment IN VARCHAR2 DEFAULT NULL);

--SST:New APIs
PROCEDURE init (P_transaction_source IN VARCHAR2);


/*#
* Use the Pre-Import Client Extension to load approved self-service time cards from Internet Time into the Oracle Projects Transaction
* Interface Table (PA_TRANSACTION_INTERFACE_ALL). Once data is loaded in the transaction interface table,
* the Transaction Import Process will load the data into Oracle Projects.
* This client extension allows you to automate the process of loading
* Oracle Internet Time data to the interface table as part of the import process.
* @param P_transaction_source Classification of the transactions loaded into Oracle Projects from an external system.
* @rep:paraminfo {@rep:required}
* @param P_batch User entered name for grouping expenditures within a transaction source.
* @rep:paraminfo {@rep:required}
* @param P_xface_id System-generated number that identifies all the transactions processed by a given concurrent request.
* @rep:paraminfo {@rep:required}
* @param P_user_id User.
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Pre-import.
* @rep:compatibility S
*/

PROCEDURE
pre_import (P_transaction_source IN VARCHAR2,
	    P_batch IN VARCHAR2, P_xface_id IN NUMBER, P_user_id IN NUMBER);



/*#
* Use the Post-Import Client Extension to tie back the Oracle Internet Time records that have been imported into Oracle Projects from Internet Time.
* Projects to the source transactions in Oracle Internet Time.
* Oracle Projects calls the Post-Import Client Extension for Internet Time after the Transaction Import Process runs when you use the Oracle
* Internet Time transaction source.
* @param P_transaction_source Classification of the transactions loaded into Oracle Projects from an external system.
* @rep:paraminfo {@rep:required}
* @param P_batch User entered name for grouping expenditures within a transaction source.
* @rep:paraminfo {@rep:required}
* @param  P_xface_id System-generated number that identifies all the transactions processed by a given concurrent request.
* @rep:paraminfo {@rep:required}
* @param P_user_id User.
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Post-import.
* @rep:compatibility S
*/
PROCEDURE
post_import (P_transaction_source IN VARCHAR2,
	     P_batch IN VARCHAR2, P_xface_id IN NUMBER, P_user_id IN NUMBER);

PROCEDURE
execute_import_extensions (P_program_name IN VARCHAR2,
			   P_transaction_source IN VARCHAR2,
			   P_batch IN VARCHAR2,
			   P_user_id IN NUMBER, P_xface_id IN NUMBER);


--New Package Variables for counting transactions with New TXN Codes

G_PRE_IMPORT_SUCCESS_COUNT NUMBER;

G_PRE_IMPORT_REJECT_COUNT NUMBER;
G_IMPORT_SUCCESS_COUNT NUMBER;
G_IMPORT_REJECT_COUNT NUMBER;
G_POST_IMPORT_SUCCESS_COUNT NUMBER;
G_POST_IMPORT_REJECT_COUNT NUMBER;
G_SKIP_TC_FLAG VARCHAR2 (1) := 'N'; --made changes for bug 1299909

G_REQUEST_ID NUMBER:= fnd_global.conc_request_id;
G_PROGRAM_ID NUMBER:= fnd_global.conc_program_id;
G_PROG_APPL_ID NUMBER:= fnd_global.PROG_APPL_ID;
G_CONC_LOGIN_ID NUMBER:= fnd_global.CONC_LOGIN_ID;
G_LOGIN_ID NUMBER:= fnd_global.LOGIN_ID;
G_USER_ID NUMBER:= fnd_global.USER_ID;


--New APIs for New TXN Codes
    PROCEDURE count_status (P_phase IN VARCHAR2,
			    P_xface_id IN NUMBER,
			    P_sucess_counter OUT NOCOPY NUMBER,
			    P_failed_counter OUT NOCOPY NUMBER);


PROCEDURE
update_status_counter (P_xface_id IN NUMBER);

----New global variables created for CBGA--

G_Business_Group_Id NUMBER;
G_Prev_Business_Group_Id NUMBER;
G_Prev_Business_Group_Name VARCHAR2 (240);

PROCEDURE
Upd_PktSts_Fatal (p_request_id in number);

PROCEDURE
Upd_PktSts (p_packet_id in number);

--PA - L Changes:Added ValidateItemOTL and G_Exit_Main flag.
  PROCEDURE ValidateItemOTL (X_trx_src IN VARCHAR2, X_ei_date IN DATE,
			     X_etype IN VARCHAR2, X_nlr IN VARCHAR2,
			     X_qty IN NUMBER, X_denom_raw_cost IN NUMBER,
			     X_module IN VARCHAR2, X_trx_ref IN VARCHAR2,
			     X_match_flag IN VARCHAR2, X_att_cat IN VARCHAR2,
			     X_att1 IN OUT NOCOPY VARCHAR2,
			     X_att2 IN OUT NOCOPY VARCHAR2,
			     X_att3 IN OUT NOCOPY VARCHAR2,
			     X_att4 IN OUT NOCOPY VARCHAR2,
			     X_att5 IN OUT NOCOPY VARCHAR2,
			     X_att6 IN OUT NOCOPY VARCHAR2,
			     X_att7 IN OUT NOCOPY VARCHAR2,
			     X_att8 IN OUT NOCOPY VARCHAR2,
			     X_att9 IN OUT NOCOPY VARCHAR2,
			     X_att10 IN OUT NOCOPY VARCHAR2,
			     X_system_linkage IN VARCHAR2,
			     X_status OUT NOCOPY VARCHAR2,   -- X_bill_flag OUT NOCOPY VARCHAR2,
			     X_denom_currency_code IN OUT NOCOPY VARCHAR2,
			     X_acct_rate_date IN OUT NOCOPY DATE,
			     X_acct_rate_type IN OUT NOCOPY VARCHAR2,
			     X_acct_exchange_rate IN OUT NOCOPY NUMBER,
			     X_acct_raw_cost IN NUMBER default NULL,
			     X_project_currency_code IN OUT NOCOPY VARCHAR2,
			     X_Projfunc_currency_code IN OUT NOCOPY VARCHAR2,
			     X_Projfunc_cost_rate_date IN OUT NOCOPY DATE,
			     X_Projfunc_cost_rate_type IN OUT NOCOPY VARCHAR2,
			     X_Projfunc_cost_exchange_rate IN OUT NOCOPY VARCHAR2,
			     X_Assignment_Name IN OUT NOCOPY VARCHAR2,
			     X_Work_Type_Name IN OUT NOCOPY VARCHAR2,
			     P_project_id IN NUMBER,
			     P_task_id IN NUMBER,
			     P_person_id IN NUMBER,
			     P_organization_id IN NUMBER,
			     P_assignment_id IN NUMBER,
			     P_work_type_id IN NUMBER,
			     P_Emp_Org_Id IN NUMBER,
			     P_Emp_Job_Id IN NUMBER,
			     P_po_header_id IN NUMBER, /* cwk */
			     P_po_line_id IN NUMBER,
			     P_person_type IN VARCHAR2,
			     P_po_price_type IN VARCHAR2,
			     p_vendor_id In Number
			     /* Bug# 3601024 : Vendor ID is not passed to the PA_EXPENDITURE_ITEMS_ALL.VENDOR_ID in OTL timecards  */
  );

G_Exit_Main BOOLEAN:= NULL;
G_Batch_Size NUMBER;
G_IterationNum NUMBER  := 0;

G_Po_Line_Amt NUMBER := 0;	/*cwk */
G_person_type VARCHAR2 (30) := 'EMP';

PoLineTaskTab pa_utils.Char150TabTyp;
PoAmtTab pa_utils.AmtTabTyp;

PROCEDURE init_po_amt_chk;
PROCEDURE release_po_line_task_lock;

Function
GET_PO_PRICE_TYPE_RATE (p_project_id In Number, p_task_id In Number,
			P_Po_Line_Id In Number, P_Price_Type In Varchar2)
Return Number;

/* Added this for bug# 4138033 */
--S.N.Bug #4138033
  PROCEDURE Set_GVal_ProjTskEi_Date (L_Validate_Proj_Tsk_Ei_Date IN VARCHAR2);

     FUNCTION Get_GVal_ProjTskEi_Date
       RETURN
       VARCHAR2;

--E.N.Bug #4138033
-- --5235363 R12.PJ: XB4: DEV: APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
  --
  PROCEDURE validate_exp_date (p_project_id IN NUMBER,
			       p_task_id In NUMBER,
			       p_award_id in NUMBER,
			       p_incurred_by_org_id in number,
			       p_vendor_id in NUMBER,
			       p_person_id in number,
			       p_exp_item_date in date,
			       p_exp_type in varchar2,
			       p_system_linkage in varchar2,
			       p_txn_source in varchar2,
			       p_calling_modle in varchar2,
			       x_err_msg_cd in out nocopy varchar2,
			       x_status out nocopy varchar2);

END PA_TRX_IMPORT;

 

/

--------------------------------------------------------
--  DDL for Package PA_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING" AUTHID CURRENT_USER AS
/* $Header: PAXIBILS.pls 120.2.12010000.3 2009/07/23 09:53:34 dbudhwar ship $ */
--
   TYPE GlobalVars IS RECORD
    (  ProjectId	 	NUMBER(15)
     , TaskId		 	NUMBER(15)
     , BillingAssignmentId	NUMBER(15)
     , ReqId          	   	NUMBER(15)
     , CallingPlace      	VARCHAR2(10)
     , CallingProcess    	VARCHAR2(10)
     , AccrueThruDate           VARCHAR2(10)
     , MassGenFlag              VARCHAR2(1)
     , BillingExtensionId       NUMBER(15)
     , PaDate                   VARCHAR2(11) /* Added for EPP changes */
     , InvoiceDate              VARCHAR2(30) /* Added for MCB II changes */
     , GlDate              	VARCHAR2(11) /* Added for EPP changes */
     , GlPeriodName             VARCHAR2(15) /* Added for EPP changes */
     , PaPeriodName             VARCHAR2(15)  /* Added for EPP changes */
     , BillThruDate             VARCHAR2(10)    /* Added for Retention Enhancements */
     , InvoiceSetId             NUMBER	     /* Added for Retention Enhancements */
     , inv_by_btc_flag          VARCHAR2(1)  /* Added for Revenue in foreign currency */
     , mcb_flag                 VARCHAR2(1)  /* Added for Revenue in foreign currency */
     , pf_curr_code             VARCHAR2(15)  /* Added for Revenue in foreign currency */
     , rev_in_txn_curr_flag     VARCHAR2(1)  /* Added for Revenue in foreign currency */
    );


   GlobVars    GlobalVars;

   /* Start of Changes for BUG 8666892 */
   G_ORG_ID		NUMBER(15) := NULL;
   G_INV_NZ_LINES	VARCHAR2(1) := NULL;

   FUNCTION  GetInvoiceNZ  RETURN VARCHAR2;
   /* End of Changes for BUG 8666892 */

   PROCEDURE SetMassGen (x_Massgenflag VARCHAR2);

   /* MCB related changes */
   FUNCTION  GetPADate  RETURN DATE;
   pragma RESTRICT_REFERENCES ( GetPADate, WNDS,WNPS );

   FUNCTION  GetInvoiceDate  RETURN DATE;
   pragma RESTRICT_REFERENCES ( GetInvoiceDate, WNDS, WNPS );

   FUNCTION GetBillingAssignmentId RETURN NUMBER;
   pragma RESTRICT_REFERENCES ( GetBillingAssignmentId, WNDS, WNPS ); /* changed from GetInvoiceDate to GetBillingAssignmentId */
   /* Till Here */

   /* MCB related changes */

   FUNCTION  GetGLDate  RETURN DATE;
   pragma RESTRICT_REFERENCES ( GetPADate, WNDS,WNPS );

   FUNCTION  GetGLPeriodName  RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES ( GetGlPeriodName, WNDS,WNPS );

   FUNCTION  GetPAPeriodName  RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES ( GetPAPeriodName, WNDS,WNPS );

  /* End of EPP changes */

   /* Retention Enhancements Begin */

    FUNCTION  GetBillThruDate RETURN VARCHAR2;
    pragma RESTRICT_REFERENCES ( GetBillThruDate, WNDS, WNPS );

    /* Retention Enhancements End */

   FUNCTION  GetMassGen  RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES ( GetMassGen, WNDS, WNPS );

   FUNCTION  GetReqId  RETURN NUMBER;
   pragma RESTRICT_REFERENCES ( GetReqId, WNDS, WNPS );

   FUNCTION  GetProjId  RETURN NUMBER;
   pragma RESTRICT_REFERENCES ( GetProjId, WNDS, WNPS );

   PROCEDURE  SetProjId (x_project_id      IN      NUMBER); /* Added procedure for bug 7606086*/

   FUNCTION  GetTaskId  RETURN NUMBER;
   pragma RESTRICT_REFERENCES ( GetTaskId, WNDS, WNPS );

   FUNCTION  GetCallPlace  RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES ( GetCallPlace, WNDS, WNPS );

   FUNCTION  GetCallProcess RETURN VARCHAR2;
   pragma RESTRICT_REFERENCES ( GetCallProcess, WNDS, WNPS );

   FUNCTION  GetBillingExtensionId RETURN NUMBER;
   pragma RESTRICT_REFERENCES ( GetBillingExtensionId, WNDS, WNPS );

   PROCEDURE bill_ext_driver (
		   x_project_id        IN     NUMBER,
                   x_calling_process   IN     VARCHAR2,
                   x_calling_place     IN     VARCHAR2,
                   x_rev_or_bill_date  IN     VARCHAR2,
                   x_request_id        IN     NUMBER,
                   x_error_message     IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE  ccrev(	X_project_id               IN     NUMBER,
	             	X_top_task_id              IN     NUMBER DEFAULT NULL,
                     	X_calling_process          IN     VARCHAR2 DEFAULT NULL,
                     	X_calling_place            IN     VARCHAR2 DEFAULT NULL,
                     	X_amount                   IN     NUMBER DEFAULT NULL,
                     	X_percentage               IN     NUMBER DEFAULT NULL,
                     	X_rev_or_bill_date         IN     DATE DEFAULT NULL,
                     	X_billing_assignment_id    IN     NUMBER DEFAULT NULL,
                     	X_billing_extension_id     IN     NUMBER DEFAULT NULL,
                     	X_request_id               IN     NUMBER DEFAULT NULL
                     );


PROCEDURE Delete_Automatic_Events ( 	X_Project_id	NUMBER,
					X_request_id	NUMBER DEFAULT NULL,
					X_rev_inv_num	NUMBER DEFAULT NULL,
					X_calling_process	VARCHAR2);

PROCEDURE Call_Calc_Bill_Amount(
                                x_transaction_type         in varchar2 default 'ACTUAL',
				x_expenditure_item_id      in number,
                              	x_sys_linkage_function     in varchar2,
                              	x_amount                   in out NOCOPY number, /* This amount is treated as amount in Transaction currency */ --File.Sql.39 bug 4440895
                              	x_bill_rate_flag           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                              	x_status                   in out NOCOPY number,     --File.Sql.39 bug 4440895
                              	x_bill_trans_currency_code out NOCOPY varchar2,     --File.Sql.39 bug 4440895
                              	x_bill_txn_bill_rate       out NOCOPY number,     --File.Sql.39 bug 4440895
                              	x_markup_percentage        out NOCOPY number,     --File.Sql.39 bug 4440895
                              	x_rate_source_id           out NOCOPY number     --File.Sql.39 bug 4440895
                                );

PROCEDURE DUMMY;


/* Billing Enhancement : Added the new parameters */

PROCEDURE CHECK_SPF_AMOUNTS( X_option            in varchar2,
                             X_proj_id           in number,
                             X_start_proj_num    in varchar2,
                             X_end_proj_num      in varchar2);


PROCEDURE  Get_WriteOff_Revenue_Amount (p_project_id               IN  NUMBER DEFAULT NULL,
                                        p_task_id                  IN  NUMBER DEFAULT NULL,
                                        p_agreement_id             IN  NUMBER DEFAULT NULL,
                                        p_funding_flag             IN  VARCHAR2 DEFAULT NULL,
                                        p_writeoff_amount          IN  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_projfunc_writeoff_amount OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_project_writeoff_amount  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_revproc_writeoff_amount  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                         );
/*Added for bug 2121103*/
PROCEDURE forecast_rev_billamount
	      (NC in out NOCOPY number, --File.Sql.39 bug 4440895
	       process_irs in out NOCOPY varchar2, --File.Sql.39 bug 4440895
	       process_bill_rate  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
	       message_code in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
	       rows_this_time  number,
	       error_code in out  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       reason     in out  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	       bill_amount in out   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	       d_rule_decode in out  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       sl_function in out  NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       ei_id in  PA_PLSQL_DATATYPES.IdTabTyp,
	       t_rev_irs_id in out   NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       rev_comp_set_id in out   NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
	       rev_amount     in out  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
	       mcb_flag     in out  NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,
               x_bill_trans_currency_code in out  NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp
,
               x_bill_trans_bill_rate in out   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
               x_rate_source_id in out   NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
               x_markup_percentage in out   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp);


--

/* This Procedure is added by Manish Gupta on 08-May-2003 for MRC Schema Elimination Changes */
PROCEDURE  Get_WriteOff_Rep_Revenue_Amt (p_project_id               IN     NUMBER DEFAULT NULL,
                                         p_task_id                  IN     NUMBER DEFAULT NULL,
                                         p_agreement_id             IN     NUMBER DEFAULT NULL,
                                         p_funding_flag             IN     VARCHAR2 DEFAULT NULL,
                                         px_writeoff_amount         IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                         x_rep_projfunc_writeoff_amt OUT   NOCOPY NUMBER ); --File.Sql.39 bug 4440895

/*Added for non labor client extension*/
PROCEDURE Call_Calc_Non_Labor_Bill_Amt
(
x_transaction_type      IN      VARCHAR2 DEFAULT 'ACTUAL',
x_expenditure_item_id   IN      NUMBER DEFAULT NULL ,
x_sys_linkage_function  IN      VARCHAR2 DEFAULT NULL ,
x_amount                IN OUT  NOCOPY NUMBER , --File.Sql.39 bug 4440895
x_expenditure_type      IN      VARCHAR2 DEFAULT NULL ,
x_non_labor_resource    IN      VARCHAR2 DEFAULT NULL ,
x_non_labor_res_org     IN      NUMBER DEFAULT NULL ,
x_bill_rate_flag        IN OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
x_status                IN OUT  NOCOPY NUMBER , --File.Sql.39 bug 4440895
x_bill_trans_currency_code      OUT     NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
x_bill_txn_bill_rate    OUT     NOCOPY NUMBER , --File.Sql.39 bug 4440895
x_markup_percentage     OUT     NOCOPY NUMBER , --File.Sql.39 bug 4440895
x_rate_source_id        OUT     NOCOPY NUMBER ); --File.Sql.39 bug 4440895


/*Added for Customer at Top Task changes in FP_M */
 FUNCTION  Validate_Task_Customer(
           p_project_id           IN       NUMBER
           , p_customer_id        IN       NUMBER
           , p_task_id            IN       NUMBER
) RETURN VARCHAR2;


END pa_billing;

/

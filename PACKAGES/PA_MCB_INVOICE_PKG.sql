--------------------------------------------------------
--  DDL for Package PA_MCB_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MCB_INVOICE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXMCIUS.pls 120.2 2007/02/07 23:59:26 rmarcel ship $ */

G_LAST_UPDATE_LOGIN      NUMBER;
G_REQUEST_ID             NUMBER;
G_PROGRAM_APPLICATION_ID NUMBER;
G_PROGRAM_ID             NUMBER;
G_LAST_UPDATED_BY        NUMBER;
G_CREATED_BY             NUMBER;
G_DEBUG_MODE             VARCHAR2(1);


PROCEDURE Event_Convert_amount_bulk
                                        (
    p_agreement_id		   IN        	NUMBER DEFAULT 0,
    p_project_id                   IN 	 	Number,
    p_request_id	           IN		NUMBER,
    p_task_id                      IN		 PA_PLSQL_DATATYPES.NumTabTyp,
    p_event_num                    IN		 PA_PLSQL_DATATYPES.NumTabTyp,
    p_bill_trans_currency_code     IN 		 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_bill_trans_bill_amount       IN 		 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_invproc_currency_code        IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_invproc_rate_type            IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_invproc_rate_date            IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_invproc_exchange_rate        IN OUT  NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_invproc_bill_amount          IN OUT	 NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
    p_project_currency_code        IN      	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_project_rate_type            IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_project_rate_date            IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_project_exchange_rate        IN OUT  NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_projfunc_currency_code       IN  		 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_projfunc_rate_type           IN OUT  NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_projfunc_rate_date           IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_projfunc_exchange_rate       IN OUT 	 NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
    p_funding_rate_type            IN OUT  NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_funding_rate_date            IN OUT	 NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
    p_funding_exchange_rate        IN OUT NOCOPY  	 PA_PLSQL_DATATYPES.Char30TabTyp,
    p_shared_funds_consumption     IN                    NUMBER,
    p_completion_date              IN                    PA_PLSQL_DATATYPES.Char30TabTyp,
    x_status_tab		   IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
    x_return_status                IN OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );
/* Procedure to Convert the Line Amount to Funding Amount */
PROCEDURE Convert_Line_Event_amount (
                                p_agreement_id IN NUMBER ,
                                p_project_id IN NUMBER ,
                                p_task_id IN NUMBER ,
                                p_event_num IN NUMBER ,
                                p_invproc_bill_amount IN VARCHAR2,
                                x_project_bill_amount OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_projfunc_bill_amount OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_currency_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_bill_amount OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_rate_date OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_exchange_rate OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_rate_type OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_bill_trans_inv_amount OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_status_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Procedure will check whether the BTC can be converted to funding
-- currency

PROCEDURE Check_Funding_Conv_Attributes (
                                p_funding_currency_code  IN VARCHAR2 ,
                                p_bill_trans_currency_code IN VARCHAR2 ,
                                p_bill_trans_bill_amount   IN VARCHAR2 ,
                                p_funding_rate_type	   IN VARCHAR2 ,
                                p_funding_rate_date 	   IN VARCHAR2,
                                p_funding_exchange_rate    IN VARCHAR2,
                                x_funding_bill_amount      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_status_code 		   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status            IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);

PROCEDURE log_message (p_log_msg IN VARCHAR2);

PROCEDURE Init (
        P_DEBUG_MODE             VARCHAR2);

 PROCEDURE Inv_by_Bill_Trans_Currency(
                                p_project_id    IN      NUMBER,
                                p_request_id    IN      NUMBER,
                                x_return_status IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END PA_MCB_INVOICE_PKG;

/

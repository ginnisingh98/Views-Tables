--------------------------------------------------------
--  DDL for Package PA_BILL_PCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILL_PCT" AUTHID CURRENT_USER AS
/* $Header: PAXPCTS.pls 120.1 2005/08/05 02:12:15 bchandra noship $ */
--

PROCEDURE  calc_pct_comp_amt
		(	X_project_id               IN     NUMBER,
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


PROCEDURE PotEventAmount( 	X2_project_id 	NUMBER,
				X2_task_id 	NUMBER DEFAULT NULL,
				X2_accrue_through_date DATE DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY REAL,
				X2_invoice_amount OUT NOCOPY REAL);

Procedure RevenueAmount(  	X2_project_id NUMBER,
	 			X2_task_Id   NUMBER DEFAULT NULL,
				X2_revenue_amount OUT NOCOPY REAL);

Procedure InvoiceAmount(	X2_project_id	NUMBER,
				X2_task_id	NUMBER default NULL,
				X2_invoice_amount OUT NOCOPY REAL);

Function GetPercentComplete( 	X2_project_id 	NUMBER,
				X2_task_id 	NUMBER DEFAULT NULL,
				X2_accrue_through_date DATE DEFAULT NULL)
          RETURN REAL;

PROCEDURE get_rev_budget_amount( X2_project_id       NUMBER,
                         X2_task_id              NUMBER DEFAULT NULL,
                         X2_revenue_amount       OUT NOCOPY REAL,
                         P_rev_budget_type_code  IN VARCHAR2 DEFAULT NULL,
                         P_rev_plan_type_id      IN  NUMBER DEFAULT NULL, /* Added fin plan impact */
                         X_rev_budget_type_code  OUT NOCOPY VARCHAR2,
                         X_rev_plan_type_id      OUT NOCOPY NUMBER, /* Added fin plan impact */
                         X_error_message         OUT NOCOPY VARCHAR2,
                         X_status                OUT NOCOPY NUMBER
                         );


PRAGMA RESTRICT_REFERENCES (GetPercentComplete , WNDS);

END pa_bill_pct;

 

/

--------------------------------------------------------
--  DDL for Package PA_EXPENDITURE_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXPENDITURE_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXTGRPS.pls 120.2 2005/08/09 04:53:49 avajain noship $ */

/* Table handler procedures */

 procedure insert_row (x_rowid				  in out NOCOPY VARCHAR2,
                       x_expenditure_group		  in VARCHAR2,
                       x_last_update_date		  in DATE,
                       x_last_updated_by		  in NUMBER,
                       x_creation_date			  in DATE,
                       x_created_by			      in NUMBER,
                       x_expenditure_group_status in VARCHAR2,
                       x_expenditure_ending_date  in DATE,
                       x_system_linkage_function  in VARCHAR2,
                       x_control_count			  in NUMBER,
                       x_control_total_amount	  in NUMBER,
                       x_description			  in VARCHAR2,
                       x_last_update_login		  in NUMBER,
                       x_transaction_source		  in VARCHAR2,
		               x_period_accrual_flag      in VARCHAR2,
                       P_Org_Id                   In NUMBER); -- 12i MOAC changes

 procedure update_row (x_rowid				      in VARCHAR2,
                       x_expenditure_group		  in VARCHAR2,
                       x_last_update_date		  in DATE,
                       x_last_updated_by		  in NUMBER,
                       x_expenditure_group_status in VARCHAR2,
                       x_expenditure_ending_date  in DATE,
                       x_system_linkage_function  in VARCHAR2,
                       x_control_count			  in NUMBER,
                       x_control_total_amount	  in NUMBER,
                       x_description			  in VARCHAR2,
                       x_last_update_login		  in NUMBER,
                       x_transaction_source		  in VARCHAR2,
		               x_period_accrual_flag      in VARCHAR2);


 procedure delete_row (x_rowid	in VARCHAR2);

 procedure lock_row (x_rowid	in VARCHAR2);


/* Procedures to change the status of an expenditure group */


 -- Possible error codes for submit:
 --  submit_only_working
 --  control_amounts_must_match
 --  exp_items_must_exist
 --  no_null_quantity

 procedure submit (x_expenditure_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2);

 procedure release (x_expenditure_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2);

 procedure rework (x_expenditure_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2);

END pa_expenditure_groups_pkg;

 

/

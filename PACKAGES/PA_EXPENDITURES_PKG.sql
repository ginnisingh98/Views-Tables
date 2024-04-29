--------------------------------------------------------
--  DDL for Package PA_EXPENDITURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXPENDITURES_PKG" AUTHID CURRENT_USER as
/* $Header: PAXTEXPS.pls 120.2 2005/08/09 04:53:39 avajain noship $ */

 procedure insert_row (x_rowid				         in out NOCOPY VARCHAR2,
                       x_expenditure_id			     in out NOCOPY NUMBER,
                       x_last_update_date		     in DATE,
                       x_last_updated_by		     in NUMBER,
                       x_creation_date			     in DATE,
                       x_created_by			         in NUMBER,
                       x_expenditure_status_code     in VARCHAR2,
                       x_expenditure_ending_date     in DATE,
                       x_expenditure_class_code	     in VARCHAR2,
                       x_incurred_by_person_id	     in NUMBER,
                       x_incurred_by_organization_id in NUMBER,
                       x_expenditure_group		     in VARCHAR2,
                       x_control_total_amount		 in NUMBER,
                       x_entered_by_person_id		 in NUMBER,
                       x_description			     in VARCHAR2,
                       x_initial_submission_date	 in DATE,
                       x_last_update_login		     in NUMBER,
                       x_attribute_category		     in VARCHAR2,
                       x_attribute1			         in VARCHAR2,
                       x_attribute2			         in VARCHAR2,
                       x_attribute3			         in VARCHAR2,
                       x_attribute4			         in VARCHAR2,
                       x_attribute5			         in VARCHAR2,
                       x_attribute6			         in VARCHAR2,
                       x_attribute7			         in VARCHAR2,
                       x_attribute8			         in VARCHAR2,
                       x_attribute9			         in VARCHAR2,
                       x_attribute10			     in VARCHAR2,
	                   x_denom_currency_code		 in VARCHAR2,
		               x_acct_currency_code		     in VARCHAR2,
		               x_acct_rate_type			     in VARCHAR2,
		               x_acct_rate_date			     in DATE,
		               x_acct_exchange_rate		     in NUMBER,
                       -- Trx_import enhancement:
                       x_orig_exp_txn_reference1     in VARCHAR2,
                       x_orig_exp_txn_reference2     in VARCHAR2,
                       x_orig_exp_txn_reference3     in VARCHAR2,
                       x_orig_user_exp_txn_reference in VARCHAR2,
                       x_vendor_id                   in NUMBER,
                       x_person_type                 in VARCHAR2,
                       P_Org_ID                      IN NUMBER);  -- 12i MOAC changes

 procedure update_row (x_rowid				         in VARCHAR2,
                       x_expenditure_id			     in NUMBER,
                       x_last_update_date		     in DATE,
                       x_last_updated_by		     in NUMBER,
                       x_expenditure_status_code	 in VARCHAR2,
                       x_expenditure_ending_date	 in DATE,
                       x_expenditure_class_code		 in VARCHAR2,
                       x_incurred_by_person_id		 in NUMBER,
                       x_incurred_by_organization_id in NUMBER,
                       x_expenditure_group		     in VARCHAR2,
                       x_control_total_amount		 in NUMBER,
                       x_entered_by_person_id		 in NUMBER,
                       x_description			     in VARCHAR2,
                       x_initial_submission_date	 in DATE,
                       x_last_update_login		     in NUMBER,
                       x_attribute_category		     in VARCHAR2,
                       x_attribute1			         in VARCHAR2,
                       x_attribute2			         in VARCHAR2,
                       x_attribute3			         in VARCHAR2,
                       x_attribute4			         in VARCHAR2,
                       x_attribute5			         in VARCHAR2,
                       x_attribute6			         in VARCHAR2,
                       x_attribute7			         in VARCHAR2,
                       x_attribute8			         in VARCHAR2,
                       x_attribute9			         in VARCHAR2,
                       x_attribute10			     in VARCHAR2,
	                   x_denom_currency_code		 in VARCHAR2,
		               x_acct_currency_code		     in VARCHAR2,
		               x_acct_rate_type			     in VARCHAR2,
		               x_acct_rate_date			     in DATE,
		               x_acct_exchange_rate		     in NUMBER,
                       -- Trx_import enhancement
                       x_orig_exp_txn_reference1     in VARCHAR2,
                       x_orig_exp_txn_reference2     in VARCHAR2,
                       x_orig_exp_txn_reference3     in VARCHAR2,
                       x_orig_user_exp_txn_reference in VARCHAR2,
                       x_vendor_id                   in NUMBER,
                       x_person_type                 in VARCHAR2);

 -- overload delete_row to take the rowid or the expenditure_id
 procedure delete_row (x_expenditure_id		in NUMBER);
 procedure delete_row (x_rowid			in VARCHAR2);

 procedure lock_row (x_rowid	in VARCHAR2);

END pa_expenditures_pkg;

 

/

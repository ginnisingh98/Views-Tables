--------------------------------------------------------
--  DDL for Package GMS_ENCUMBRANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_ENCUMBRANCES_PKG" AUTHID CURRENT_USER as
/* $Header: GMSTEXPS.pls 115.5 2002/11/26 12:40:13 mmalhotr ship $ */

 procedure insert_row (x_rowid				in out NOCOPY VARCHAR2	,
                       x_encumbrance_id			in out NOCOPY NUMBER,
                       x_last_update_date		in DATE,
                       x_last_updated_by		in NUMBER,
                       x_creation_date			in DATE,
                       x_created_by			in NUMBER,
                       x_encumbrance_status_code	in VARCHAR2,
                       x_encumbrance_ending_date	in DATE,
                       x_encumbrance_class_code		in VARCHAR2,
                       x_incurred_by_person_id		in NUMBER	DEFAULT NULL,
                       x_incurred_by_organization_id	in NUMBER	DEFAULT NULL,
                       x_encumbrance_group		in VARCHAR2	DEFAULT NULL,
                       x_control_total_amount		in NUMBER	DEFAULT NULL,
                       x_entered_by_person_id		in NUMBER	DEFAULT NULL,
                       x_description			in VARCHAR2	DEFAULT NULL,
                       x_initial_submission_date	in DATE		DEFAULT NULL,
                       x_last_update_login		in NUMBER	DEFAULT NULL,
                       x_attribute_category		in VARCHAR2	DEFAULT NULL,
                       x_attribute1			in VARCHAR2	DEFAULT NULL,
                       x_attribute2			in VARCHAR2	DEFAULT NULL,
                       x_attribute3			in VARCHAR2	DEFAULT NULL,
                       x_attribute4			in VARCHAR2	DEFAULT NULL,
                       x_attribute5			in VARCHAR2	DEFAULT NULL,
                       x_attribute6			in VARCHAR2	DEFAULT NULL,
                       x_attribute7			in VARCHAR2	DEFAULT NULL,
                       x_attribute8			in VARCHAR2	DEFAULT NULL,
                       x_attribute9			in VARCHAR2	DEFAULT NULL,
                       x_attribute10			in VARCHAR2	DEFAULT NULL,
	                    x_denom_currency_code	in VARCHAR2	DEFAULT NULL,
		                 x_acct_currency_code	in VARCHAR2	DEFAULT NULL,
		                 x_acct_rate_type	in VARCHAR2	DEFAULT NULL,
		                 x_acct_rate_date	in DATE		DEFAULT NULL,
		                 x_acct_exchange_rate	in NUMBER	DEFAULT NULL,
                       x_orig_enc_txn_reference1 	in VARCHAR2	DEFAULT NULL,
                       x_orig_enc_txn_reference2 	in VARCHAR2	DEFAULT NULL,
                       x_orig_enc_txn_reference3 	in VARCHAR2	DEFAULT NULL,
                       x_orig_user_enc_txn_reference 	in VARCHAR2	DEFAULT NULL,
                       x_vendor_id 			in NUMBER	DEFAULT NULL,
                       x_org_id                         in NUMBER );

 procedure update_row (x_rowid				in VARCHAR2,
                       x_encumbrance_id			in NUMBER,
                       x_last_update_date		in DATE,
                       x_last_updated_by		in NUMBER,
                       x_encumbrance_status_code	in VARCHAR2,
                       x_encumbrance_ending_date	in DATE,
                       x_encumbrance_class_code		in VARCHAR2,
                       x_incurred_by_person_id		in NUMBER,
                       x_incurred_by_organization_id	in NUMBER,
                       x_encumbrance_group		in VARCHAR2,
                       x_control_total_amount		in NUMBER,
                       x_entered_by_person_id		in NUMBER,
                       x_description			in VARCHAR2,
                       x_initial_submission_date	in DATE,
                       x_last_update_login		in NUMBER,
                       x_attribute_category		in VARCHAR2,
                       x_attribute1			in VARCHAR2,
                       x_attribute2			in VARCHAR2,
                       x_attribute3			in VARCHAR2,
                       x_attribute4			in VARCHAR2,
                       x_attribute5			in VARCHAR2,
                       x_attribute6			in VARCHAR2,
                       x_attribute7			in VARCHAR2,
                       x_attribute8			in VARCHAR2,
                       x_attribute9			in VARCHAR2,
                       x_attribute10			in VARCHAR2,
	                    x_denom_currency_code		in VARCHAR2,
		                 x_acct_currency_code		in VARCHAR2,
		                 x_acct_rate_type			in VARCHAR2,
		                 x_acct_rate_date			in DATE,
		                 x_acct_exchange_rate		in NUMBER,
                       -- Trx_import enhancement
                       x_orig_enc_txn_reference1 in VARCHAR2,
                       x_orig_enc_txn_reference2 in VARCHAR2,
                       x_orig_enc_txn_reference3 in VARCHAR2,
                       x_orig_user_enc_txn_reference in VARCHAR2,
                       x_vendor_id in NUMBER);

 -- overload delete_row to take the rowid or the encumbrance_id
 procedure delete_row (x_encumbrance_id		in NUMBER);
 procedure delete_row (x_rowid			in VARCHAR2);

 procedure lock_row (x_rowid	in VARCHAR2);

END gms_encumbrances_pkg;

 

/

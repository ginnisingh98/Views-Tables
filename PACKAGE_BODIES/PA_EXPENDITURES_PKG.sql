--------------------------------------------------------
--  DDL for Package Body PA_EXPENDITURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXPENDITURES_PKG" as
/* $Header: PAXTEXPB.pls 120.2 2005/08/09 04:53:34 avajain noship $ */

 procedure insert_row (x_rowid				         in out NOCOPY VARCHAR2,
                       x_expenditure_id			     in out NOCOPY NUMBER,
                       x_last_update_date		     in DATE,
                       x_last_updated_by		     in NUMBER,
                       x_creation_date			     in DATE,
                       x_created_by			         in NUMBER,
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
                       -- Trx_import enhancement:
                       -- These new parameters are needed to populate
                       -- PA_EXPENDITURES_ALL table's new columns
                       x_orig_exp_txn_reference1     in VARCHAR2,
                       x_orig_exp_txn_reference2     in VARCHAR2,
                       x_orig_exp_txn_reference3     in VARCHAR2,
                       x_orig_user_exp_txn_reference in VARCHAR2,
                       x_vendor_id                   in NUMBER,
                       x_person_type                 in VARCHAR2,
                       P_Org_ID                      IN NUMBER) -- 12i MOAC changes
 is

  cursor return_rowid is select rowid from pa_expenditures
                         where expenditure_id = x_expenditure_id;
  cursor get_exp_id is select pa_expenditures_s.nextval from dual;

 BEGIN

  if (x_expenditure_id is null) then
    open get_exp_id;
    fetch get_exp_id into x_expenditure_id;
  end if;

  insert into pa_expenditures (
          expenditure_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          expenditure_status_code,
          expenditure_ending_date,
          expenditure_class_code,
          incurred_by_person_id,
          incurred_by_organization_id,
          expenditure_group,
          control_total_amount,
          entered_by_person_id,
          description,
          initial_submission_date,
          last_update_login,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
		  denom_currency_code,
		  acct_currency_code,
		  acct_rate_type,
		  acct_rate_date,
	  	  acct_exchange_rate,
          orig_exp_txn_reference1,
          orig_exp_txn_reference2,
          orig_exp_txn_reference3,
          orig_user_exp_txn_reference,
          vendor_id,
          person_type,
          Org_Id) -- 12i MOAC changes
  values (x_expenditure_id,
          x_last_update_date,
          x_last_updated_by,
          x_creation_date,
          x_created_by,
          x_expenditure_status_code,
          x_expenditure_ending_date,
          x_expenditure_class_code,
          x_incurred_by_person_id,
          x_incurred_by_organization_id,
          x_expenditure_group,
          x_control_total_amount,
          x_entered_by_person_id,
          x_description,
          x_initial_submission_date,
          x_last_update_login,
          x_attribute_category,
          x_attribute1,
          x_attribute2,
          x_attribute3,
          x_attribute4,
          x_attribute5,
          x_attribute6,
          x_attribute7,
          x_attribute8,
          x_attribute9,
          x_attribute10,
          x_denom_currency_code,
          x_acct_currency_code,
          x_acct_rate_type,
          x_acct_rate_date,
          x_acct_exchange_rate,
          x_orig_exp_txn_reference1,
          x_orig_exp_txn_reference2,
          x_orig_exp_txn_reference3,
          x_orig_user_exp_txn_reference,
          x_vendor_id,
          x_person_type,
          P_Org_Id); -- 12i MOAC changes

  open return_rowid;
  fetch return_rowid into x_rowid;
  if (return_rowid%notfound) then
    raise NO_DATA_FOUND;
  end if;
  close return_rowid;

 END insert_row;

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
                       -- Trx_import enhancement:
                       -- These new parameters are needed to populate
                       -- PA_EXPENDITURES_ALL table's new columns
                       x_orig_exp_txn_reference1     in VARCHAR2,
                       x_orig_exp_txn_reference2     in VARCHAR2,
                       x_orig_exp_txn_reference3     in VARCHAR2,
                       x_orig_user_exp_txn_reference in VARCHAR2,
                       x_vendor_id                   in NUMBER,
                       x_person_type                 in VARCHAR2	) is
 BEGIN

  update pa_expenditures
  set expenditure_id			= x_expenditure_id,
      last_update_date			= x_last_update_date,
      last_updated_by			= x_last_updated_by,
      expenditure_status_code		= x_expenditure_status_code,
      expenditure_ending_date		= x_expenditure_ending_date,
      expenditure_class_code		= x_expenditure_class_code,
      incurred_by_person_id		= x_incurred_by_person_id,
      incurred_by_organization_id	= x_incurred_by_organization_id,
      expenditure_group			= x_expenditure_group,
      control_total_amount		= x_control_total_amount,
      entered_by_person_id		= x_entered_by_person_id,
      description			= x_description,
      initial_submission_date		= x_initial_submission_date,
      last_update_login			= x_last_update_login,
      attribute_category		= x_attribute_category,
      attribute1			= x_attribute1,
      attribute2			= x_attribute2,
      attribute3			= x_attribute3,
      attribute4			= x_attribute4,
      attribute5			= x_attribute5,
      attribute6			= x_attribute6,
      attribute7			= x_attribute7,
      attribute8			= x_attribute8,
      attribute9			= x_attribute9,
      attribute10			= x_attribute10,
      denom_currency_code               = x_denom_currency_code,
      acct_currency_code                = x_acct_currency_code,
      acct_rate_date                    = x_acct_rate_date,
      acct_rate_type                    = x_acct_rate_type,
      acct_exchange_rate                = x_acct_exchange_rate,
      orig_exp_txn_reference1           = x_orig_exp_txn_reference1,
      orig_exp_txn_reference2           = x_orig_exp_txn_reference2,
      orig_exp_txn_reference3           = x_orig_exp_txn_reference3,
      orig_user_exp_txn_reference       = x_orig_user_exp_txn_reference,
      vendor_id                         = x_vendor_id,
      person_type                       = x_person_type
  where rowid = x_rowid;

 END update_row;


 procedure delete_row (x_expenditure_id		in NUMBER) is
  cursor items is select expenditure_item_id from pa_expenditure_items
                  where expenditure_id = x_expenditure_id
                  for update of expenditure_item_id nowait;
  items_rec items%rowtype;
 BEGIN
  --
  -- 3733123 - PJ.M:B5: QA:P11:OTH: MANUAL ENC/EXP  FORM CREATING ORPHAN ADLS
  -- delete award distribution lines..
  --
  gms_awards_dist_pkg.delete_adls(x_expenditure_id, NULL, 'EXP' ) ;

  -- cascade delete the expenditure items.
  open items;
  LOOP
    fetch items into items_rec;
    if (items%notfound) then
      exit;
    else
      pa_expenditure_items_pkg.delete_row (items_rec.expenditure_item_id);
     end if;
  END LOOP;

  delete from pa_expenditures
  where expenditure_id = x_expenditure_id;
 EXCEPTION
  when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
    fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
    app_exception.raise_exception;
 END delete_row;


 procedure delete_row (x_rowid	in VARCHAR2) is
  cursor get_exp_id is select expenditure_id from pa_expenditures
                       where rowid = x_rowid;
  exp_rec  get_exp_id%rowtype;
 BEGIN
  open get_exp_id;
  fetch get_exp_id into exp_rec;

  delete_row (exp_rec.expenditure_id);

 END delete_row;


 procedure lock_row (x_rowid	in VARCHAR2) is
 BEGIN
  null;
 END lock_row;

END pa_expenditures_pkg;

/

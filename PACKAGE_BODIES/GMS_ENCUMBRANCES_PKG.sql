--------------------------------------------------------
--  DDL for Package Body GMS_ENCUMBRANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_ENCUMBRANCES_PKG" as
/* $Header: GMSTEXPB.pls 120.0 2005/05/29 12:09:04 appldev noship $ */

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
                       x_org_id                         in NUMBER 	) is

  cursor return_rowid is select rowid from gms_encumbrances
                         where encumbrance_id = x_encumbrance_id;
  cursor get_enc_id is select gms_encumbrances_s.nextval from dual;

 BEGIN

  if (x_encumbrance_id is null) then
    open get_enc_id;
    fetch get_enc_id into x_encumbrance_id;
  end if;

  insert into gms_encumbrances (encumbrance_id,
                               last_update_date,
                               last_updated_by,
                               creation_date,
                               created_by,
                               encumbrance_status_code,
                               encumbrance_ending_date,
                               encumbrance_class_code,
                               incurred_by_person_id,
                               incurred_by_organization_id,
                               encumbrance_group,
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
                               orig_enc_txn_reference1,
                               orig_enc_txn_reference2,
                               orig_enc_txn_reference3,
                               orig_user_enc_txn_reference,
                               vendor_id ,
                               org_id)
  values (x_encumbrance_id,
          x_last_update_date,
          x_last_updated_by,
          x_creation_date,
          x_created_by,
          x_encumbrance_status_code,
          x_encumbrance_ending_date,
          x_encumbrance_class_code,
          x_incurred_by_person_id,
          x_incurred_by_organization_id,
          x_encumbrance_group,
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
          x_orig_enc_txn_reference1,
          x_orig_enc_txn_reference2,
          x_orig_enc_txn_reference3,
          x_orig_user_enc_txn_reference,
          x_vendor_id ,
          x_org_id );

  open return_rowid;
  fetch return_rowid into x_rowid;
  if (return_rowid%notfound) then
    raise NO_DATA_FOUND;
  end if;
  close return_rowid;

 END insert_row;

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
                       -- Trx_import enhancement:
                       -- These new parameters are needed to populate
                       -- PA_EXPENDITURES_ALL table's new columns
                       x_orig_enc_txn_reference1 in VARCHAR2,
                       x_orig_enc_txn_reference2 in VARCHAR2,
                       x_orig_enc_txn_reference3 in VARCHAR2,
                       x_orig_user_enc_txn_reference in VARCHAR2,
                       x_vendor_id in NUMBER	) is
 BEGIN

  update gms_encumbrances
  set encumbrance_id			= x_encumbrance_id,
      last_update_date			= x_last_update_date,
      last_updated_by			= x_last_updated_by,
      encumbrance_status_code		= x_encumbrance_status_code,
      encumbrance_ending_date		= x_encumbrance_ending_date,
      encumbrance_class_code		= x_encumbrance_class_code,
      incurred_by_person_id		= x_incurred_by_person_id,
      incurred_by_organization_id	= x_incurred_by_organization_id,
      encumbrance_group			= x_encumbrance_group,
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
      orig_enc_txn_reference1           = x_orig_enc_txn_reference1,
      orig_enc_txn_reference2           = x_orig_enc_txn_reference2,
      orig_enc_txn_reference3           = x_orig_enc_txn_reference3,
      orig_user_enc_txn_reference       = x_orig_user_enc_txn_reference,
      vendor_id                         = x_vendor_id
  where rowid = x_rowid;

 END update_row;


 procedure delete_row (x_encumbrance_id		in NUMBER) is
  cursor items is select encumbrance_item_id from gms_encumbrance_items
                  where encumbrance_id = x_encumbrance_id
                  for update of encumbrance_item_id nowait;
  items_rec items%rowtype;
 BEGIN
  --
  --3733123 - PJ.M:B5: QA:P11:OTH: MANUAL ENC/EXP  FORM CREATING ORPHAN ADLS
  -- delete the award_distribution lines.
  --
  gms_awards_dist_pkg.delete_adls(x_encumbrance_id, NULL, 'ENC' ) ;

  -- cascade delete the encumbrance items.
  open items;
  LOOP
    fetch items into items_rec;
    if (items%notfound) then
      exit;
    else
      gms_encumbrance_items_pkg.delete_row (items_rec.encumbrance_item_id);
     end if;
  END LOOP;

  delete from gms_encumbrances
  where encumbrance_id = x_encumbrance_id;
 EXCEPTION
  when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
    fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
    app_exception.raise_exception;
 END delete_row;


 procedure delete_row (x_rowid	in VARCHAR2) is
  cursor get_enc_id is select encumbrance_id from gms_encumbrances
                       where rowid = x_rowid;
  enc_rec  get_enc_id%rowtype;
 BEGIN
  open get_enc_id;
  fetch get_enc_id into enc_rec;

  delete_row (enc_rec.encumbrance_id);

 END delete_row;


 procedure lock_row (x_rowid	in VARCHAR2) is
 BEGIN
  null;
 END lock_row;

END gms_encumbrances_pkg;

/

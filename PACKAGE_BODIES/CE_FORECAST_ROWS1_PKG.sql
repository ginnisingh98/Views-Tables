--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_ROWS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_ROWS1_PKG" AS
/* $Header: cefrow1b.pls 120.1 2002/11/12 21:25:37 bhchung ship $ 	*/
--
-- Package
--   CE_FORECAST_ROWS1_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   ce_forecast_rows table.
-- History
--   07.10.96   C. Kawamoto   Created
--

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.1 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  --
  -- Procedure
  --   Check_Unique
  -- Purpose
  --   Checks the uniqueness of the forecast row inserted.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS1_PKG.Check_Unique(...)
  -- Notes
  --
  PROCEDURE Check_Unique(
		X_rowid			VARCHAR2,
		X_forecast_header_id	NUMBER,
		X_row_number		NUMBER) IS
	CURSOR chk_duplicates IS
		SELECT 'Duplidate'
		FROM ce_forecast_rows cfr
		WHERE cfr.forecast_header_id = X_forecast_header_id
	 	AND   cfr.row_number = X_row_number
		AND  (X_rowid IS NULL
		   OR cfr.rowid <> chartorowid(X_rowid));
	dummy VARCHAR2(100);
  BEGIN
	OPEN chk_duplicates;
	FETCH chk_duplicates INTO dummy;

	IF chk_duplicates%FOUND THEN
		FND_MESSAGE.Set_Name('CE', 'CE_DUPLICATE_ROW_NUMBER');
		APP_EXCEPTION.Raise_exception;
	END IF;
	CLOSE chk_duplicates;
  EXCEPTION
	WHEN APP_EXCEPTIONS.application_exception THEN
		RAISE;
	WHEN OTHERS THEn
		FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
		FND_MESSAGE.Set_Token('PROCEDURE', 'ce_cf_rows1_pkg.check_unique');
	RAISE;
  END Check_Unique;

  --
  -- Procedure
  --   insert_row
  -- Purpose
  --   To insert new row to ce_forecast_rows.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS1_PKG.Insert_Row(...)
  -- Notes
  --

  PROCEDURE Insert_Row(
		X_rowid			IN OUT NOCOPY	VARCHAR2,
		X_forecast_row_id	IN OUT NOCOPY	NUMBER,
		X_forecast_header_id		NUMBER,
		X_row_number			NUMBER,
		X_trx_type			VARCHAR2,
		X_lead_time			NUMBER,
		X_forecast_method		VARCHAR2,
		X_discount_option		VARCHAR2,
		X_order_status			VARCHAR2,
		X_order_date_type		VARCHAR2,
		X_code_combination_id		NUMBER,
		X_set_of_books_id		NUMBER,
		X_org_id			NUMBER,
		X_chart_of_accounts_id		NUMBER,
		X_budget_name			VARCHAR2,
		X_budget_version_id		NUMBER,
		X_encumbrance_type_id		NUMBER,
		X_roll_forward_type		VARCHAR2,
		X_roll_forward_period		NUMBER,
		X_customer_profile_class_id	NUMBER,
		X_include_dispute_flag		VARCHAR2,
		X_sales_stage_id		NUMBER,
		X_channel_code			VARCHAR2,
		X_win_probability		NUMBER,
                X_sales_forecast_status		VARCHAR2,
		X_receipt_method_id		NUMBER,
		X_bank_account_id		NUMBER,
		X_payment_method		VARCHAR2,
		X_pay_group			VARCHAR2,
		X_payment_priority		NUMBER,
		X_vendor_type			VARCHAR2,
		X_authorization_status		VARCHAR2,
		X_type				VARCHAR2,
		X_budget_type			VARCHAR2,
		X_budget_version		VARCHAR2,
		X_include_hold_flag		VARCHAR2,
                X_include_net_cash_flag		VARCHAR2,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER,
		X_org_payment_method_id		NUMBER,
		X_xtr_bank_account		VARCHAR2,
		X_exclude_indic_exp		VARCHAR2,
		X_company_code			VARCHAR2,
		X_attribute_category		VARCHAR2,
		X_attribute1			VARCHAR2,
		X_attribute2			VARCHAR2,
		X_attribute3			VARCHAR2,
		X_attribute4			VARCHAR2,
		X_attribute5			VARCHAR2,
		X_attribute6			VARCHAR2,
		X_attribute7			VARCHAR2,
		X_attribute8			VARCHAR2,
		X_attribute9			VARCHAR2,
		X_attribute10			VARCHAR2,
		X_attribute11			VARCHAR2,
		X_attribute12			VARCHAR2,
		X_attribute13			VARCHAR2,
		X_attribute14			VARCHAR2,
		X_attribute15			VARCHAR2,
		X_description			VARCHAR2,
		X_payroll_id			NUMBER,
		X_external_source_type		VARCHAR2,
		X_criteria_category		VARCHAR2,
		X_criteria1			VARCHAR2,
		X_criteria2			VARCHAR2,
		X_criteria3			VARCHAR2,
		X_criteria4			VARCHAR2,
		X_criteria5			VARCHAR2,
		X_criteria6			VARCHAR2,
		X_criteria7			VARCHAR2,
		X_criteria8			VARCHAR2,
		X_criteria9			VARCHAR2,
		X_criteria10			VARCHAR2,
		X_criteria11			VARCHAR2,
		X_criteria12			VARCHAR2,
		X_criteria13			VARCHAR2,
		X_criteria14			VARCHAR2,
		X_criteria15			VARCHAR2,
                X_use_average_payment_days      VARCHAR2,
                X_period                        NUMBER,
                X_order_type_id                 NUMBER,
                X_use_payment_terms             VARCHAR2
	) IS
		CURSOR C IS SELECT rowid FROM ce_forecast_rows
			WHERE forecast_row_id = X_forecast_row_id;
		CURSOR C2 IS SELECT ce_forecast_rows_s.nextval FROM sys.dual;

	BEGIN
		OPEN C2;
		FETCH C2 INTO X_forecast_row_id;
		CLOSE C2;

		INSERT INTO ce_forecast_rows(
			forecast_row_id,
			forecast_header_id,
			row_number,
			trx_type,
			lead_time,
			forecast_method,
			discount_option,
			order_status,
			order_date_type,
			code_combination_id,
			set_of_books_id,
			org_id,
			chart_of_accounts_id,
			budget_name,
			budget_version_id,
			encumbrance_type_id,
			roll_forward_type,
			roll_forward_period,
			customer_profile_class_id,
			include_dispute_flag,
			sales_stage_id,
			channel_code,
			win_probability,
                        sales_forecast_status,
			receipt_method_id,
			bank_account_id,
			payment_method,
			pay_group,
			payment_priority,
			vendor_type,
			authorization_status,
			type,
			budget_type,
			budget_version,
			include_hold_flag,
                	include_net_cash_flag,
			xtr_bank_account,
			exclude_indic_exp,
			company_code,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			org_payment_method_id,
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
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
			description,
			payroll_id,
			external_source_type,
			criteria_category,
			criteria1,
			criteria2,
			criteria3,
			criteria4,
			criteria5,
			criteria6,
			criteria7,
			criteria8,
			criteria9,
			criteria10,
			criteria11,
			criteria12,
			criteria13,
			criteria14,
			criteria15,
                        use_average_payment_days,
                        period,
                        order_type_id,
                        use_payment_terms
		) VALUES (
			X_forecast_row_id,
			X_forecast_header_id,
			X_row_number,
			X_trx_type,
			X_lead_time,
			X_forecast_method,
			X_discount_option,
			X_order_status,
			X_order_date_type,
			X_code_combination_id,
			X_set_of_books_id,
			X_org_id,
			X_chart_of_accounts_id,
			X_budget_name,
			X_budget_version_id,
			X_encumbrance_type_id,
			X_roll_forward_type,
			X_roll_forward_period,
			X_customer_profile_class_id,
			X_include_dispute_flag,
			X_sales_stage_id,
			X_channel_code,
			X_win_probability,
                        X_sales_forecast_status,
			X_receipt_method_id,
			X_bank_account_id,
			X_payment_method,
			X_pay_group,
			X_payment_priority,
			X_vendor_type,
			X_authorization_status,
			X_type,
			X_budget_type,
			X_budget_version,
			X_include_hold_flag,
                   	X_include_net_cash_flag,
			X_xtr_bank_account,
			X_exclude_indic_exp,
			X_company_code,
			X_created_by,
			X_creation_date,
			X_last_updated_by,
			X_last_update_date,
			X_last_update_login,
			X_org_payment_method_id,
			X_attribute_category,
			X_attribute1,
			X_attribute2,
			X_attribute3,
			X_attribute4,
			X_attribute5,
			X_attribute6,
			X_attribute7,
			X_attribute8,
			X_attribute9,
			X_attribute10,
			X_attribute11,
			X_attribute12,
			X_attribute13,
			X_attribute14,
			X_attribute15,
			X_description,
			X_payroll_id,
			X_external_source_type,
			X_criteria_category,
			X_criteria1,
			X_criteria2,
			X_criteria3,
			X_criteria4,
			X_criteria5,
			X_criteria6,
			X_criteria7,
			X_criteria8,
			X_criteria9,
			X_criteria10,
			X_criteria11,
			X_criteria12,
			X_criteria13,
			X_criteria14,
			X_criteria15,
                        X_use_average_payment_days,
                        X_period,
                        X_order_type_id,
                        X_use_payment_terms
		);
		OPEN C;
		FETCH C INTO X_rowid;
		if (C%NOTFOUND) then
			CLOSE C;
			Raise NO_DATA_FOUND;
		end if;
		CLOSE C;
	END Insert_Row;
  --
  -- Procedure
  --   lock_row
  -- Purpose
  --   To lock a row from ce_forecast_rows.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS1_PKG.Lock_Row(...)
  -- Notes
  --

  PROCEDURE Lock_Row(
		X_rowid				VARCHAR2,
		X_forecast_row_id		NUMBER,
		X_forecast_header_id		NUMBER,
		X_row_number			NUMBER,
		X_trx_type			VARCHAR2,
		X_lead_time			NUMBER,
		X_forecast_method		VARCHAR2,
		X_discount_option		VARCHAR2,
		X_order_status			VARCHAR2,
		X_order_date_type		VARCHAR2,
		X_code_combination_id		NUMBER,
		X_set_of_books_id		NUMBER,
		X_org_id			NUMBER,
		X_chart_of_accounts_id		NUMBER,
		X_budget_name			VARCHAR2,
		X_budget_version_id		NUMBER,
		X_encumbrance_type_id		NUMBER,
		X_roll_forward_type		VARCHAR2,
		X_roll_forward_period		NUMBER,
		X_customer_profile_class_id	NUMBER,
		X_include_dispute_flag		VARCHAR2,
		X_sales_stage_id		NUMBER,
		X_channel_code			VARCHAR2,
		X_win_probability		NUMBER,
                X_sales_forecast_status		VARCHAR2,
		X_receipt_method_id		NUMBER,
		X_bank_account_id		NUMBER,
		X_payment_method		VARCHAR2,
		X_pay_group			VARCHAR2,
		X_payment_priority		NUMBER,
		X_vendor_type			VARCHAR2,
		X_authorization_status		VARCHAR2,
		X_type				VARCHAR2,
		X_budget_type			VARCHAR2,
		X_budget_version		VARCHAR2,
		X_include_hold_flag		VARCHAR2,
                X_include_net_cash_flag		VARCHAR2,
		X_created_by			NUMBER,
		X_creation_date			DATE,
		X_last_updated_by		NUMBER,
		X_last_update_date		DATE,
		X_last_update_login		NUMBER,
		X_org_payment_method_id		NUMBER,
		X_xtr_bank_account		VARCHAR2,
		X_exclude_indic_exp		VARCHAR2,
		X_company_code			VARCHAR2,
		X_attribute_category		VARCHAR2,
		X_attribute1			VARCHAR2,
		X_attribute2			VARCHAR2,
		X_attribute3			VARCHAR2,
		X_attribute4			VARCHAR2,
		X_attribute5			VARCHAR2,
		X_attribute6			VARCHAR2,
		X_attribute7			VARCHAR2,
		X_attribute8			VARCHAR2,
		X_attribute9			VARCHAR2,
		X_attribute10			VARCHAR2,
		X_attribute11			VARCHAR2,
		X_attribute12			VARCHAR2,
		X_attribute13			VARCHAR2,
		X_attribute14			VARCHAR2,
		X_attribute15			VARCHAR2,
		X_description			VARCHAR2,
		X_payroll_id			NUMBER,
		X_external_source_type		VARCHAR2,
		X_criteria_category		VARCHAR2,
		X_criteria1			VARCHAR2,
		X_criteria2			VARCHAR2,
		X_criteria3			VARCHAR2,
		X_criteria4			VARCHAR2,
		X_criteria5			VARCHAR2,
		X_criteria6			VARCHAR2,
		X_criteria7			VARCHAR2,
		X_criteria8			VARCHAR2,
		X_criteria9			VARCHAR2,
		X_criteria10			VARCHAR2,
		X_criteria11			VARCHAR2,
		X_criteria12			VARCHAR2,
		X_criteria13			VARCHAR2,
		X_criteria14			VARCHAR2,
		X_criteria15			VARCHAR2,
                X_use_average_payment_days      VARCHAR2,
                X_period                        NUMBER,
                X_order_type_id                 NUMBER,
                X_use_payment_terms             VARCHAR2
	) IS
		CURSOR C IS
			SELECT *
			FROM ce_forecast_rows
			WHERE rowid = X_rowid
			FOR UPDATE of forecast_row_id NOWAIT;
		Recinfo C%ROWTYPE;
  BEGIN
	OPEN C;
	FETCH C INTO Recinfo;
	if (C%NOTFOUND) then
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
			(Recinfo.forecast_row_id = X_forecast_row_id)
		   AND	(Recinfo.forecast_header_id = X_forecast_header_id)
		   AND  (Recinfo.row_number = X_row_number)
	   	   AND  (Recinfo.trx_type = X_trx_type)
		   AND	(    (Recinfo.lead_time = X_lead_time)
			 OR  (  (Recinfo.lead_time IS NULL)
			     AND (X_lead_time IS NULL)))
	 	   AND  (    (Recinfo.forecast_method = X_forecast_method)
			 OR  (  (Recinfo.forecast_method IS NULL)
			     AND (X_forecast_method IS NULL)))
		   AND  (    (Recinfo.discount_option = X_discount_option)
			 OR  (  (Recinfo.discount_option IS NULL)
	 	 	     AND (X_discount_option IS NULL)))
	 	   AND  (    (Recinfo.order_status = X_order_status)
			 OR  (  (Recinfo.order_status IS NULL)
                             AND (X_order_status IS NULL)))
	 	   AND  (    (Recinfo.order_date_type = X_order_date_type)
			 OR  (  (Recinfo.order_date_type IS NULL)
  			     AND (X_order_date_type IS NULL)))
	 	   AND  (    (Recinfo.code_combination_id = X_code_combination_id)
			 OR  (  (Recinfo.code_combination_id IS NULL)
			     AND (X_code_combination_id IS NULL)))
	 	   AND  (    (Recinfo.set_of_books_id = X_set_of_books_id)
			 OR  (  (Recinfo.set_of_books_id IS NULL)
			     AND (X_set_of_books_id IS NULL)))
	 	   AND  (    (Recinfo.org_id = X_org_id)
			 OR  (  (Recinfo.org_id IS NULL)
			     AND (X_org_id IS NULL)))
	 	   AND  (    (Recinfo.chart_of_accounts_id = X_chart_of_accounts_id)
			 OR  (  (Recinfo.chart_of_accounts_id IS NULL)
			     AND (X_chart_of_accounts_id IS NULL)))
	 	   AND  (    (Recinfo.budget_name = X_budget_name)
			 OR  (  (Recinfo.budget_name IS NULL)
			     AND (X_budget_name IS NULL)))
		   AND  (    (Recinfo.budget_version_id = X_budget_version_id)
			 OR  (  (Recinfo.budget_version_id IS NULL)
			     AND (X_budget_version_id IS NULL)))
	 	   AND  (    (Recinfo.encumbrance_type_id = X_encumbrance_type_id)
			 OR  (  (Recinfo.encumbrance_type_id IS NULL)
			     AND (X_encumbrance_type_id IS NULL)))
		   AND  (    (Recinfo.roll_forward_type = X_roll_forward_type)
			 OR  (  (Recinfo.roll_forward_type IS NULL)
			     AND (X_roll_forward_type IS NULL)))
		   AND  (    (Recinfo.roll_forward_period = X_roll_forward_period)
			 OR  (  (Recinfo.roll_forward_period IS NULL)
			     AND (X_roll_forward_period IS NULL)))
                   AND  (    (Recinfo.customer_profile_class_id = X_customer_profile_class_id)
                         OR  (  (Recinfo.customer_profile_class_id IS NULL)
                             AND (X_customer_profile_class_id IS NULL)))
                   AND  (    (Recinfo.include_dispute_flag = X_include_dispute_flag)
                         OR  (  (Recinfo.include_dispute_flag IS NULL)
                             AND (X_include_dispute_flag IS NULL)))
                   AND  (    (Recinfo.include_hold_flag = X_include_hold_flag)
                         OR  (  (Recinfo.include_hold_flag IS NULL)
                             AND (X_include_hold_flag IS NULL)))
                   AND  (    (Recinfo.include_net_cash_flag = X_include_net_cash_flag)
                         OR  (  (Recinfo.include_net_cash_flag IS NULL)
                             AND (X_include_net_cash_flag IS NULL)))
                   AND  (    (Recinfo.sales_stage_id = X_sales_stage_id)
                         OR  (  (Recinfo.sales_stage_id IS NULL)
                             AND (X_sales_stage_id IS NULL)))
                   AND  (    (Recinfo.channel_code = X_channel_code)
                         OR  (  (Recinfo.channel_code IS NULL)
                             AND (X_channel_code IS NULL)))
                   AND  (    (Recinfo.win_probability = X_win_probability)
                         OR  (  (Recinfo.win_probability IS NULL)
                             AND (X_win_probability IS NULL)))
                   AND  (    (Recinfo.sales_forecast_status = X_sales_forecast_status)
                         OR  (  (Recinfo.sales_forecast_status IS NULL)
                             AND (X_sales_forecast_status IS NULL)))
                   AND  (    (Recinfo.receipt_method_id = X_receipt_method_id)
                         OR  (  (Recinfo.receipt_method_id IS NULL)
                             AND (X_receipt_method_id IS NULL)))
                   AND  (    (Recinfo.bank_account_id = X_bank_account_id)
                         OR  (  (Recinfo.bank_account_id IS NULL)
                             AND (X_bank_account_id IS NULL)))
                   AND  (    (Recinfo.payment_method = X_payment_method)
                         OR  (  (Recinfo.payment_method IS NULL)
                             AND (X_payment_method IS NULL)))
		   AND  (    (Recinfo.pay_group = X_pay_group)
                         OR  (  (Recinfo.pay_group IS NULL)
                             AND (X_pay_group IS NULL)))
                   AND  (    (Recinfo.payment_priority = X_payment_priority)
                         OR  (  (Recinfo.payment_priority IS NULL)
                             AND (X_payment_priority IS NULL)))
		   AND  (    (Recinfo.vendor_type = X_vendor_type)
		         OR  (  (Recinfo.vendor_type IS NULL)
			     AND (X_vendor_type IS NULL)))
                   AND  (    (Recinfo.org_payment_method_id = X_org_payment_method_id)
                         OR  (  (Recinfo.org_payment_method_id IS NULL)
                             AND (X_org_payment_method_id IS NULL)))
                   AND  (    (Recinfo.type = X_type)
                         OR  (  (Recinfo.type IS NULL)
                             AND (X_type IS NULL)))
                   AND  (    (Recinfo.xtr_bank_account = X_xtr_bank_account)
                         OR  (  (Recinfo.xtr_bank_account IS NULL)
                             AND (X_xtr_bank_account IS NULL)))
                   AND  (    (Recinfo.exclude_indic_exp = X_exclude_indic_exp)
                         OR  (  (Recinfo.exclude_indic_exp IS NULL)
                             AND (X_exclude_indic_exp IS NULL)))
                   AND  (    (Recinfo.company_code = X_company_code)
                         OR  (  (Recinfo.company_code IS NULL)
                             AND (X_company_code IS NULL)))
                   AND  (    (Recinfo.budget_type = X_budget_type)
                         OR  (  (Recinfo.budget_type IS NULL)
                             AND (X_budget_type IS NULL)))
                   AND  (    (Recinfo.budget_version = X_budget_version)
                         OR  (  (Recinfo.budget_version IS NULL)
                             AND (X_budget_version IS NULL)))
	   	   AND  (    (Recinfo.attribute_category = X_attribute_category)
			 OR  (  (Recinfo.attribute_category IS NULL)
			     AND (X_attribute_category IS NULL)))
		   AND  (    (Recinfo.attribute1 = X_attribute1)
			 OR  (  (Recinfo.attribute1 IS NULL)
			     AND (X_attribute1 IS NULL)))
		   AND  (    (Recinfo.attribute2 = X_attribute2)
			 OR  (  (Recinfo.attribute2 IS NULL)
			     AND (X_attribute2 IS NULL)))
		   AND  (    (Recinfo.attribute3 = X_attribute3)
			 OR  (  (Recinfo.attribute3 IS NULL)
			     AND (X_attribute3 IS NULL)))
		   AND  (    (Recinfo.attribute4 = X_attribute4)
			 OR  (  (Recinfo.attribute4 IS NULL)
			     AND (X_attribute4 IS NULL)))
		   AND  (    (Recinfo.attribute5 = X_attribute5)
			 OR  (  (Recinfo.attribute5 IS NULL)
			     AND (X_attribute5 IS NULL)))
		   AND  (    (Recinfo.attribute6 = X_attribute6)
			 OR  (  (Recinfo.attribute6 IS NULL)
			     AND (X_attribute6 IS NULL)))
		   AND  (    (Recinfo.attribute7 = X_attribute7)
			 OR  (  (Recinfo.attribute7 IS NULL)
			     AND (X_attribute7 IS NULL)))
		   AND  (    (Recinfo.attribute8 = X_attribute8)
			 OR  (  (Recinfo.attribute8 IS NULL)
			     AND (X_attribute8 IS NULL)))
		   AND  (    (Recinfo.attribute9 = X_attribute9)
			 OR  (  (Recinfo.attribute9 IS NULL)
			     AND (X_attribute9 IS NULL)))
		   AND  (    (Recinfo.attribute10 = X_attribute10)
			 OR  (  (Recinfo.attribute10 IS NULL)
			     AND (X_attribute10 IS NULL)))
		   AND  (    (Recinfo.attribute11 = X_attribute11)
			 OR  (  (Recinfo.attribute11 IS NULL)
			     AND (X_attribute11 IS NULL)))
		   AND  (    (Recinfo.attribute12 = X_attribute12)
			 OR  (  (Recinfo.attribute12 IS NULL)
			     AND (X_attribute12 IS NULL)))
		   AND  (    (Recinfo.attribute13 = X_attribute13)
			 OR  (  (Recinfo.attribute13 IS NULL)
			     AND (X_attribute13 IS NULL)))
		   AND  (    (Recinfo.attribute14 = X_attribute14)
			 OR  (  (Recinfo.attribute14 IS NULL)
			     AND (X_attribute14 IS NULL)))
		   AND  (    (Recinfo.attribute15 = X_attribute15)
			 OR  (  (Recinfo.attribute15 IS NULL)
			     AND (X_attribute15 IS NULL)))
                   AND  (    (Recinfo.description = X_description)
                         OR  (  (Recinfo.description IS NULL)
                             AND (X_description IS NULL)))
                   AND  (    (Recinfo.payroll_id = X_payroll_id)
                         OR  (  (Recinfo.payroll_id IS NULL)
                             AND (X_payroll_id IS NULL)))
                   AND  (    (Recinfo.external_source_type = X_external_source_type)
                         OR  (  (Recinfo.external_source_type IS NULL)
                             AND (X_external_source_type IS NULL)))
                   AND  (    (Recinfo.criteria_category = X_criteria_category)
                         OR  (  (Recinfo.criteria_category IS NULL)
                             AND (X_criteria_category IS NULL)))
                   AND  (    (Recinfo.criteria1 = X_criteria1)
                         OR  (  (Recinfo.criteria1 IS NULL)
                             AND (X_criteria1 IS NULL)))
                   AND  (    (Recinfo.criteria2 = X_criteria2)
                         OR  (  (Recinfo.criteria2 IS NULL)
                             AND (X_criteria2 IS NULL)))
                   AND  (    (Recinfo.criteria3 = X_criteria3)
                         OR  (  (Recinfo.criteria3 IS NULL)
                             AND (X_criteria3 IS NULL)))
                   AND  (    (Recinfo.criteria4 = X_criteria4)
                         OR  (  (Recinfo.criteria4 IS NULL)
                             AND (X_criteria4 IS NULL)))
                   AND  (    (Recinfo.criteria5 = X_criteria5)
                         OR  (  (Recinfo.criteria5 IS NULL)
                             AND (X_criteria5 IS NULL)))
                   AND  (    (Recinfo.criteria6 = X_criteria6)
                         OR  (  (Recinfo.criteria6 IS NULL)
                             AND (X_criteria6 IS NULL)))
                   AND  (    (Recinfo.criteria7 = X_criteria7)
                         OR  (  (Recinfo.criteria7 IS NULL)
                             AND (X_criteria7 IS NULL)))
                   AND  (    (Recinfo.criteria8 = X_criteria8)
                         OR  (  (Recinfo.criteria8 IS NULL)
                             AND (X_criteria8 IS NULL)))
                   AND  (    (Recinfo.criteria9 = X_criteria9)
                         OR  (  (Recinfo.criteria9 IS NULL)
                             AND (X_criteria9 IS NULL)))
                   AND  (    (Recinfo.criteria10 = X_criteria10)
                         OR  (  (Recinfo.criteria10 IS NULL)
                             AND (X_criteria10 IS NULL)))
                   AND  (    (Recinfo.criteria11 = X_criteria11)
                         OR  (  (Recinfo.criteria11 IS NULL)
                             AND (X_criteria11 IS NULL)))
                   AND  (    (Recinfo.criteria12 = X_criteria12)
                         OR  (  (Recinfo.criteria12 IS NULL)
                             AND (X_criteria12 IS NULL)))
                   AND  (    (Recinfo.criteria13 = X_criteria13)
                         OR  (  (Recinfo.criteria13 IS NULL)
                             AND (X_criteria13 IS NULL)))
                   AND  (    (Recinfo.criteria14 = X_criteria14)
                         OR  (  (Recinfo.criteria14 IS NULL)
                             AND (X_criteria14 IS NULL)))
                   AND  (    (Recinfo.criteria15 = X_criteria15)
                         OR  (  (Recinfo.criteria15 IS NULL)
                             AND (X_criteria15 IS NULL)))
                   AND  (    (Recinfo.use_average_payment_days = X_use_average_payment_days)
                         OR  (  (Recinfo.use_average_payment_days IS NULL)
                             AND (X_use_average_payment_days IS NULL)))
                   AND  (    (Recinfo.period = X_period)
                         OR  (  (Recinfo.period IS NULL)
                             AND (X_period IS NULL)))
                   AND  (    (Recinfo.order_type_id = X_order_type_id)
                         OR  (  (Recinfo.order_type_id IS NULL)
                             AND (X_order_type_id IS NULL)))
                   AND  (    (Recinfo.use_payment_terms = X_use_payment_terms)
                         OR  (  (Recinfo.use_payment_terms IS NULL)
                             AND (X_use_payment_terms IS NULL)))
	) then
	return;
	else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;
  END Lock_Row;


END CE_FORECAST_ROWS1_PKG;

/

--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_ROWS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_ROWS2_PKG" AS
/* $Header: cefrow2b.pls 120.0 2002/08/24 02:36:14 appldev noship $ 	*/

--
-- Package
--   CE_FORECAST_ROWS2_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   ce_forecast_rows table.
-- History
--   07.10.96   C. Kawamoto   Created
--   07.28.97   E. Lau        Added org_payment_method_id

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.0 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   To update ce_forecast_rows with changes made.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS2_PKG.Update_Row(...)
  -- Notes
  --

  PROCEDURE Update_Row(
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
		X_include_dispute_flag 		VARCHAR2,
		X_sales_stage_id		NUMBER,
		X_channel_code			VARCHAR2,
		X_win_probability		NUMBER,
                X_sales_forecast_status	 	VARCHAR2,
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
                X_payroll_id                    NUMBER,
                X_external_source_type          VARCHAR2,
                X_criteria_category             VARCHAR2,
                X_criteria1                     VARCHAR2,
                X_criteria2                     VARCHAR2,
                X_criteria3                     VARCHAR2,
                X_criteria4                     VARCHAR2,
                X_criteria5                     VARCHAR2,
                X_criteria6                     VARCHAR2,
                X_criteria7                     VARCHAR2,
                X_criteria8                     VARCHAR2,
                X_criteria9                     VARCHAR2,
                X_criteria10                    VARCHAR2,
                X_criteria11                    VARCHAR2,
                X_criteria12                    VARCHAR2,
                X_criteria13                    VARCHAR2,
                X_criteria14                    VARCHAR2,
                X_criteria15                    VARCHAR2,
                X_use_average_payment_days      VARCHAR2,
                X_period                        NUMBER,
                X_order_type_id                 NUMBER,
                X_use_payment_terms             VARCHAR2
	) IS
  BEGIN
	UPDATE ce_forecast_rows
	SET
		forecast_row_id		= X_forecast_row_id,
		forecast_header_id 	= X_forecast_header_id,
		row_number		= X_row_number,
		trx_type		= X_trx_type,
		lead_time		= X_lead_time,
		forecast_method		= X_forecast_method,
		discount_option		= X_discount_option,
		order_status		= X_order_status,
		order_date_type		= X_order_date_type,
		code_combination_id	= X_code_combination_id,
		set_of_books_id		= X_set_of_books_id,
		org_id			= X_org_id,
		chart_of_accounts_id	= X_chart_of_accounts_id,
		budget_name		= X_budget_name,
		budget_version_id	= X_budget_version_id,
		encumbrance_type_id	= X_encumbrance_type_id,
		roll_forward_type	= X_roll_forward_type,
		roll_forward_period	= X_roll_forward_period,
		customer_profile_class_id
					= X_customer_profile_class_id,
		include_dispute_flag	= X_include_dispute_flag,
		sales_stage_id		= X_sales_stage_id,
		channel_code		= X_channel_code,
		win_probability		= X_win_probability,
                sales_forecast_status   = X_sales_forecast_status,
		receipt_method_id	= X_receipt_method_id,
		bank_account_id		= X_bank_account_id,
		payment_method		= X_payment_method,
		pay_group		= X_pay_group,
		payment_priority	= X_payment_priority,
		vendor_type		= X_vendor_type,
		authorization_status	= X_authorization_status,
		type			= X_type,
		budget_type 		= X_budget_type,
		budget_version		= X_budget_version,
		include_hold_flag	= X_include_hold_flag,
		include_net_cash_flag	= X_include_net_cash_flag,
		created_by		= X_created_by,
		creation_date		= X_creation_date,
		last_updated_by		= X_last_updated_by,
		last_update_date	= X_last_update_date,
		last_update_login	= X_last_update_login,
		org_payment_method_id	= X_org_payment_method_id,
		xtr_bank_account	= X_xtr_bank_account,
		exclude_indic_exp	= X_exclude_indic_exp,
		company_code		= X_company_code,
		attribute_category	= X_attribute_category,
		attribute1		= X_attribute1,
		attribute2		= X_attribute2,
		attribute3		= X_attribute3,
		attribute4		= X_attribute4,
		attribute5		= X_attribute5,
		attribute6		= X_attribute6,
		attribute7		= X_attribute7,
		attribute8		= X_attribute8,
		attribute9		= X_attribute9,
		attribute10		= X_attribute10,
		attribute11		= X_attribute11,
		attribute12		= X_attribute12,
		attribute13		= X_attribute13,
		attribute14		= X_attribute14,
		attribute15		= X_attribute15,
		description		= X_description,
                payroll_id		= X_payroll_id,
                external_source_type	= X_external_source_type,
                criteria_category	= X_criteria_category,
                criteria1		= X_criteria1,
                criteria2		= X_criteria2,
                criteria3		= X_criteria3,
                criteria4		= X_criteria4,
                criteria5		= X_criteria5,
                criteria6		= X_criteria6,
                criteria7		= X_criteria7,
                criteria8		= X_criteria8,
                criteria9		= X_criteria9,
                criteria10		= X_criteria10,
                criteria11		= X_criteria11,
                criteria12		= X_criteria12,
                criteria13		= X_criteria13,
                criteria14		= X_criteria14,
                criteria15		= X_criteria15,
		use_average_payment_days
					= X_use_average_payment_days,
		period			= X_period,
                order_type_id           = X_order_type_id,
                use_payment_terms       = X_use_payment_terms
	WHERE rowid = X_rowid;
	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Update_Row;

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   To delete a  row from ce_forecast_rows.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS2_PKG.Delete_Row(...)
  -- Notes
  --

  PROCEDURE Delete_Row(X_rowid VARCHAR2) IS
  BEGIN
	DELETE FROM ce_forecast_rows
	WHERE rowid = X_rowid;
	if (SQL%NOTFOUND) then
		Raise NO_DATA_FOUND;
	end if;
  END Delete_Row;


  PROCEDURE Delete_Forecast_Cells(X_rowid VARCHAR2) IS
        p_forecast_header_id    NUMBER;
	p_forecast_row_id	NUMBER;
  BEGIN
  --
  -- delete all forecast cells that belong to the template row
  --
        SELECT     forecast_header_id, forecast_row_id
        INTO       p_forecast_header_id, p_forecast_row_id
        FROM       CE_FORECAST_ROWS
        WHERE      rowid = X_rowid;

        DELETE FROM CE_FORECAST_CELLS
        WHERE       forecast_header_id = p_forecast_header_id AND
		    forecast_row_id    = p_forecast_row_id;

  END Delete_Forecast_Cells;


END CE_FORECAST_ROWS2_PKG;

/

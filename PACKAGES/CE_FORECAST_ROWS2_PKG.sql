--------------------------------------------------------
--  DDL for Package CE_FORECAST_ROWS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECAST_ROWS2_PKG" AUTHID CURRENT_USER as
/* $Header: cefrow2s.pls 120.0 2002/08/24 02:36:18 appldev noship $	*/
--
-- Package
--   CE_FORECAST_ROWS2_PKG
-- Purpose
--   To group all the procedures/functions for table handling of the
--   ce_forecast_rows table.
-- History
--   07.10.96   C. Kawamoto   Created
--
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.0 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   To update ce_forecast_rows with changes made.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS2_PKG.Update_Row(...);
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
                X_use_average_payment_days      VARCHAR2 DEFAULT NULL,
                X_period                        NUMBER DEFAULT NULL,
                X_order_type_id                 NUMBER DEFAULT NULL,
                X_use_payment_terms             VARCHAR2 DEFAULT NULL);

  --
  -- Procedure
  --   Delete_Row
  -- Purpose
  --   To delete a  row from ce_forecast_rows.
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS2_PKG.Delete_Row(...);
  -- Notes
  --

  PROCEDURE Delete_Row(X_rowid VARCHAR2);

  --
  -- Procedure
  --   Delete_Forecast_Cells
  -- Purpose
  --   To delete all forecast cells belonging the forecast template Row
  -- History
  --   07.10.96   C. Kawamoto   Created
  -- Example
  --   CE_FORECAST_ROWS_PKG.Delete_Forecast_Cells(...)
  -- Notes
  --
PROCEDURE Delete_Forecast_Cells(X_rowid VARCHAR2);


END CE_FORECAST_ROWS2_PKG;

 

/

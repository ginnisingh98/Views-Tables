--------------------------------------------------------
--  DDL for Package XTR_CASH_FCST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_CASH_FCST" AUTHID CURRENT_USER AS
/*$Header: xtrcshfs.pls 120.1 2005/06/29 06:15:26 badiredd ship $ 	*/

-- CONTEXT: CALL = XTR_CASH_FCST.Forecast

-- GLOBAL VARIABLES
--
TYPE RowInfoRec is record ( forecast_row_id		CE_FORECAST_ROWS.forecast_row_id%TYPE,
			    set_of_books_id		CE_FORECAST_ROWS.set_of_books_id%TYPE,
			    chart_of_accounts_id	CE_FORECAST_ROWS.chart_of_accounts_id%TYPE,
			    code_combination_id		CE_FORECAST_ROWS.code_combination_id%TYPE);
TYPE RowInfoTab is table of RowInfoRec index by BINARY_INTEGER;

--G_glc_rowinfo		RowInfoTab;
--
--Run-Time Parameters
--
G_rp_forecast_header_id		CE_FORECAST_HEADERS.forecast_header_id%TYPE;
G_rp_forecast_runname		CE_FORECASTS.name%TYPE;
G_rp_forecast_start_period	CE_FORECASTS.start_period%TYPE;
G_rp_forecast_start_date	CE_FORECASTS.start_date%TYPE;
G_rp_forecast_currency		FND_CURRENCIES.currency_code%TYPE;
G_rp_src_curr_type		VARCHAR2(30);
G_rp_src_currency		FND_CURRENCIES.currency_code%TYPE;
G_rp_exchange_type		GL_DAILY_RATES.conversion_type%TYPE;
--G_rp_exchange_date		GL_DAILY_RATES.conversion_date%TYPE;
--G_rp_exchange_rate		GL_DAILY_RATES.conversion_rate%TYPE;
G_rp_rownum_from		CE_FORECAST_ROWS.row_number%TYPE;
G_rp_rownum_to			CE_FORECAST_ROWS.row_number%TYPE;
G_rp_calendar_name		GL_PERIOD_SETS.period_set_name%TYPE;
--G_rp_amount_threshold		NUMBER;
--G_rp_project_id			NUMBER;
G_rp_legal_entity_id		NUMBER;
G_rp_sub_request		VARCHAR2(30);
G_rp_org_ids                    VARCHAR2(500);

--
--Header Info
--
G_aging_type			CE_FORECAST_HEADERS.aging_type%TYPE;
G_forecast_id			CE_FORECASTS.forecast_id%TYPE;
G_forecast_name			CE_FORECAST_HEADERS.name%TYPE;
--G_forecast_history_date		DATE;
--G_forecast_history_period	VARCHAR2(30);
G_period_set_name		GL_PERIODS.period_set_name%TYPE;
G_overdue_transactions		CE_FORECAST_HEADERS.overdue_transactions%TYPE;
--G_cutoff_period			CE_FORECAST_HEADERS.cutoff_period%TYPE;
G_transaction_calendar_id	CE_FORECAST_HEADERS.transaction_calendar_id%TYPE;
G_start_project_id		CE_FORECAST_HEADERS.start_project_id%TYPE;
G_end_project_id		CE_FORECAST_HEADERS.end_project_id%TYPE;
G_treasury_template		CE_FORECAST_HEADERS.treasury_template%TYPE;
G_party_code			XTR_PARTY_INFO.party_code%TYPE;

--row info
G_rowid				VARCHAR2(30);
G_forecast_row_id		CE_FORECAST_ROWS.forecast_row_id%TYPE;
G_row_number			CE_FORECAST_ROWS.row_number%TYPE;
G_trx_type			CE_FORECAST_ROWS.trx_type%TYPE;
G_lead_time			CE_FORECAST_ROWS.lead_time%TYPE;
G_forecast_method		CE_FORECAST_ROWS.forecast_method%TYPE;
G_discount_option		CE_FORECAST_ROWS.discount_option%TYPE;
G_include_float_flag		CE_FORECAST_ROWS.include_float_flag%TYPE;
G_order_status			CE_FORECAST_ROWS.order_status%TYPE;
G_order_date_type		CE_FORECAST_ROWS.order_date_type%TYPE;
G_code_combination_id  		CE_FORECAST_ROWS.code_combination_id%TYPE;
G_set_of_books_id		CE_FORECAST_ROWS.set_of_books_id%TYPE;
G_org_id			CE_FORECAST_ROWS.org_id%TYPE;
G_chart_of_accounts_id 	 	CE_FORECAST_ROWS.chart_of_accounts_id%TYPE;
G_budget_name			CE_FORECAST_ROWS.budget_name%TYPE;
G_encumbrance_type_id		CE_FORECAST_ROWS.encumbrance_type_id%TYPE;
G_roll_forward_type		CE_FORECAST_ROWS.roll_forward_type%TYPE;
G_roll_forward_period		CE_FORECAST_ROWS.roll_forward_period%TYPE;
G_include_dispute_flag		CE_FORECAST_ROWS.include_dispute_flag%TYPE;
G_sales_stage_id		CE_FORECAST_ROWS.sales_stage_id%TYPE;
G_channel_code			CE_FORECAST_ROWS.channel_code%TYPE;
G_win_probability		CE_FORECAST_ROWS.win_probability%TYPE;
G_sales_forecast_status		CE_FORECAST_ROWS.sales_forecast_status%TYPE;
--G_functional_currency		FND_CURRENCIES.currency_code%TYPE;
G_customer_profile_class_id 	CE_FORECAST_ROWS.customer_profile_class_id%TYPE;
G_bank_account_id		CE_FORECAST_ROWS.bank_account_id%TYPE;
G_receipt_method_id		CE_FORECAST_ROWS.receipt_method_id%TYPE;
G_payment_method		CE_FORECAST_ROWS.payment_method%TYPE;
G_pay_group			CE_FORECAST_ROWS.pay_group%TYPE;
G_payment_priority		CE_FORECAST_ROWS.payment_priority%TYPE;
G_vendor_type			CE_FORECAST_ROWS.vendor_type%TYPE;
G_app_short_name		CE_FORECAST_ROWS.trx_type%TYPE;
G_authorization_status 		CE_FORECAST_ROWS.authorization_status%TYPE;
G_type				CE_FORECAST_ROWS.type%TYPE;
G_budget_type			CE_FORECAST_ROWS.budget_type%TYPE;
G_budget_version		CE_FORECAST_ROWS.budget_version%TYPE;
G_include_hold_flag		CE_FORECAST_ROWS.include_hold_flag%TYPE;
G_include_net_cash_flag		CE_FORECAST_ROWS.include_net_cash_flag%TYPE;
G_budget_version_id		CE_FORECAST_ROWS.budget_version_id%TYPE;
G_payroll_id			CE_FORECAST_ROWS.payroll_id%TYPE;
G_org_payment_method_id		CE_FORECAST_ROWS.org_payment_method_id%TYPE;
G_external_source_type		CE_FORECAST_ROWS.external_source_type%TYPE;
G_criteria_category		CE_FORECAST_ROWS.criteria_category%TYPE;
G_criteria1			CE_FORECAST_ROWS.criteria1%TYPE;
G_criteria2			CE_FORECAST_ROWS.criteria2%TYPE;
G_criteria3			CE_FORECAST_ROWS.criteria3%TYPE;
G_criteria4			CE_FORECAST_ROWS.criteria4%TYPE;
G_criteria5			CE_FORECAST_ROWS.criteria5%TYPE;
G_criteria6			CE_FORECAST_ROWS.criteria6%TYPE;
G_criteria7			CE_FORECAST_ROWS.criteria7%TYPE;
G_criteria8			CE_FORECAST_ROWS.criteria8%TYPE;
G_criteria9			CE_FORECAST_ROWS.criteria9%TYPE;
G_criteria10			CE_FORECAST_ROWS.criteria10%TYPE;
G_criteria11			CE_FORECAST_ROWS.criteria11%TYPE;
G_criteria12			CE_FORECAST_ROWS.criteria12%TYPE;
G_criteria13			CE_FORECAST_ROWS.criteria13%TYPE;
G_criteria14			CE_FORECAST_ROWS.criteria14%TYPE;
G_criteria15			CE_FORECAST_ROWS.criteria15%TYPE;
--
G_sob_currency_code		GL_SETS_OF_BOOKS.currency_code%TYPE;
G_parent_process		BOOLEAN;
G_overdue_period_id		NUMBER;

--
-- Forecast Currency Info
--
G_precision			NUMBER;
G_ext_precision			NUMBER;
G_min_acct_unit			NUMBER;
--
G_max_col			NUMBER;
G_min_col			NUMBER;
G_invalid_overdue		BOOLEAN;
G_invalid_overdue_row		BOOLEAN;
--G_gl_cash_only			BOOLEAN;
--
FUNCTION set_parameters (p_forecast_header_id	IN NUMBER,
			p_forecast_runname	IN VARCHAR2,
			p_forecast_start_date	IN VARCHAR2,
			p_forecast_currency	IN VARCHAR2,
			p_src_curr_type		IN VARCHAR2,
			p_company_code		IN VARCHAR2,
			p_rownum_from		IN NUMBER,
			p_rownum_to		IN NUMBER,
			p_sub_request		IN VARCHAR2) RETURN NUMBER;

PROCEDURE Print_Report;


PROCEDURE Forecast(	errbuf			OUT NOCOPY VARCHAR2,
			retcode			OUT NOCOPY NUMBER,
			p_forecast_header_id	IN NUMBER,
			p_forecast_runname	IN VARCHAR2,
			p_company_code		IN VARCHAR2,
			p_forecast_start_date	IN VARCHAR2,
			p_rownum_from		IN NUMBER,
			p_rownum_to		IN NUMBER,
			p_sub_request		IN VARCHAR2);

PROCEDURE Create_Forecast;

END XTR_CASH_FCST;


 

/

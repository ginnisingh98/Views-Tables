--------------------------------------------------------
--  DDL for Package CE_FORECAST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FORECAST_UTILS" AUTHID CURRENT_USER as
/* $Header: cefutils.pls 120.1 2006/03/14 23:26:23 eliu ship $ */

G_xtr_user	VARCHAR2(1);

FUNCTION get_xtr_user RETURN VARCHAR2;

FUNCTION get_xtr_user_first RETURN VARCHAR2;


PROCEDURE Delete_Forecast_Children (X_forecast_id	NUMBER);

PROCEDURE Create_Dummy_Rows (X_forecast_header_id 	NUMBER);

PROCEDURE Update_Column_Setup (X_forecast_header_id 	NUMBER);

PROCEDURE Duplicate_Template (X_forecast_header_id NUMBER,
				X_new_name VARCHAR2,
				X_forecast_id NUMBER DEFAULT NULL);

PROCEDURE populate_temp_buckets ( p_forecast_header_id NUMBER,
				p_start_date DATE);

PROCEDURE Submit_Forecast(p_forecast_header_id	IN NUMBER,
		p_forecast_name		IN VARCHAR2,
		p_start_project_num	IN VARCHAR2,
                p_end_project_num	IN VARCHAR2,
		p_calendar_name		IN VARCHAR2,
		p_forecast_start_date	IN VARCHAR2,
		p_forecast_start_period	IN VARCHAR2,
		p_forecast_currency	IN VARCHAR2,
		p_src_curr_type		IN VARCHAR2,
		p_src_currency		IN VARCHAR2,
		p_exchange_date		IN VARCHAR2,
		p_exchange_type		IN VARCHAR2,
		p_exchange_rate		IN NUMBER,
		p_amount_threshold	IN NUMBER,
		p_rownum_from		IN NUMBER,
		p_rownum_to		IN NUMBER,
		p_sub_request		IN VARCHAR2,
		p_factor		IN NUMBER,
		p_include_sub_account	IN VARCHAR2,
		p_view_by		IN VARCHAR2,
		p_bank_balance_type	IN VARCHAR2,
		p_float_type		IN VARCHAR2,
		p_fc_name_exists	IN VARCHAR2);

PROCEDURE Refresh_Processing_Status;

FUNCTION Aging_Buckets_String (X_forecast_id NUMBER,
				X_forecast_header_id NUMBER DEFAULT NULL,
				X_start_date DATE DEFAULT NULL,
				X_start_period VARCHAR2 DEFAULT NULL,
				X_period_set_name VARCHAR2 DEFAULT NULL)
				RETURN VARCHAR2;

FUNCTION XTR_USER RETURN NUMBER;

FUNCTION IS_INSTALLED(X_prod_id number) RETURN VARCHAR2;

FUNCTION CHECK_SECURITY (X_le_id NUMBER) RETURN NUMBER;

PROCEDURE populate_dev_columns ( p_forecast_header_id NUMBER);


END CE_FORECAST_UTILS;

 

/

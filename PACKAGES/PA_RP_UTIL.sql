--------------------------------------------------------
--  DDL for Package PA_RP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RP_UTIL" AUTHID CURRENT_USER AS
/* $Header: PARPUTILS.pls 120.1 2006/12/06 01:13:33 ninzhang noship $ */
G_RET_STS_WARNING		VARCHAR2(1):='W';
G_RET_STS_ERROR		VARCHAR2(1):='E';

PROCEDURE Add_Message (p_app_short_name VARCHAR2
                , p_msg_name VARCHAR2
                , p_msg_type VARCHAR2
				, p_token1 VARCHAR2 DEFAULT NULL
				, p_token1_value VARCHAR2 DEFAULT NULL
				, p_token2 VARCHAR2 DEFAULT NULL
				, p_token2_value VARCHAR2 DEFAULT NULL
				, p_token3 VARCHAR2 DEFAULT NULL
				, p_token3_value VARCHAR2 DEFAULT NULL
				, p_token4 VARCHAR2 DEFAULT NULL
				, p_token4_value VARCHAR2 DEFAULT NULL
				, p_token5 VARCHAR2 DEFAULT NULL
				, p_token5_value VARCHAR2 DEFAULT NULL
				);


PROCEDURE Assign_Job(p_main_request_id NUMBER
, p_worker_request_id NUMBER
, p_previous_succeed VARCHAR
, x_job_assigned OUT NOCOPY VARCHAR2
, x_bursting_values OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);


PROCEDURE Is_DT_Trimmed (p_rp_id NUMBER
, p_app_short_name VARCHAR2
, x_is_dt_trimmed OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Save_Trimmed_DT (p_rp_id NUMBER
, x_trimmed_dt OUT NOCOPY BLOB
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Start_Workers (p_request_id NUMBER
, p_rp_id NUMBER
, x_worker_request_ids OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
, x_return_status IN OUT NOCOPY VARCHAR
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Check_Workers (p_main_request_id NUMBER
, p_worker_request_ids SYSTEM.PA_NUM_TBL_TYPE
, x_conc_prog_status OUT NOCOPY NUMBER -- 0 normal 1 warning 2 error
, x_return_status IN OUT NOCOPY VARCHAR
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Save_Params (p_main_request_id NUMBER
, p_rp_id NUMBER
, p_param_names SYSTEM.PA_VARCHAR2_240_TBL_TYPE
, p_param_values SYSTEM.PA_VARCHAR2_240_TBL_TYPE
, x_return_status IN OUT NOCOPY VARCHAR
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);


PROCEDURE get_email_addresses (p_rp_id NUMBER
, p_project_id NUMBER
, x_email_addresses OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Currency_Info(
p_project_id NUMBER
, p_currency_type VARCHAR2
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY  VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Proj_Params (p_project_id NUMBER
, p_calendar_type VARCHAR2
, p_currency_type VARCHAR2
, p_cstbudget2_plan_type_id NUMBER
, p_revbudget2_plan_type_id NUMBER
, p_report_period VARCHAR2
, p_spec_period_name VARCHAR2
, x_wbs_version_id OUT NOCOPY NUMBER
, x_wbs_element_id OUT NOCOPY  NUMBER
, x_rbs_version_id OUT NOCOPY  NUMBER
, x_rbs_element_id OUT NOCOPY  NUMBER
, x_calendar_id                  OUT NOCOPY NUMBER
, x_report_date            OUT NOCOPY NUMBER
, x_period_name                 OUT NOCOPY VARCHAR2
, x_period_id                 OUT NOCOPY NUMBER
, x_actual_version_id            OUT NOCOPY NUMBER
, x_cstforecast_version_id       OUT NOCOPY NUMBER
, x_cstbudget_version_id         OUT NOCOPY NUMBER
, x_cstbudget2_version_id        OUT NOCOPY NUMBER
, x_revforecast_version_id       OUT NOCOPY NUMBER
, x_revbudget_version_id         OUT NOCOPY NUMBER
, x_revbudget2_version_id        OUT NOCOPY NUMBER
, x_orig_cstbudget_version_id    OUT NOCOPY NUMBER
, x_orig_cstbudget2_version_id   OUT NOCOPY NUMBER
, x_orig_revbudget_version_id    OUT NOCOPY NUMBER
, x_orig_revbudget2_version_id   OUT NOCOPY NUMBER
, x_prior_cstforecast_version_id OUT NOCOPY NUMBER
, x_prior_revforecast_version_id OUT NOCOPY NUMBER
, x_cstforecast_plan_type_id	 OUT NOCOPY NUMBER
, x_cstbudget_plan_type_id		 OUT NOCOPY NUMBER
, x_revforecast_plan_type_id	 OUT NOCOPY NUMBER
, x_revbudget_plan_type_id		 OUT NOCOPY NUMBER
, x_currency_record_type_id         OUT NOCOPY NUMBER
, x_Currency_Code                OUT NOCOPY VARCHAR2
, x_period_start_date                  OUT NOCOPY NUMBER
, x_period_end_date                    OUT NOCOPY NUMBER
, x_project_type				 OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);


PROCEDURE Derive_Calendar_Info(p_project_id NUMBER
, p_report_period VARCHAR2
, p_calendar_type VARCHAR2
, p_spec_period_name VARCHAR2
, x_calendar_id OUT NOCOPY NUMBER
, x_report_date OUT NOCOPY NUMBER
, x_period_name OUT NOCOPY VARCHAR2
, x_period_id OUT NOCOPY NUMBER
, x_start_date OUT NOCOPY NUMBER
, x_end_date OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
);

FUNCTION Get_Percent_Complete
( p_project_id NUMBER
, p_wbs_version_id NUMBER
, p_wbs_element_id NUMBER
, p_report_date_julian NUMBER
, p_calendar_type VARCHAR2 DEFAULT 'E'
, p_calendar_id NUMBER DEFAULT -1
) RETURN NUMBER;


FUNCTION Get_Task_Proj_Number
( p_project_id NUMBER
, p_proj_elem_id NUMBER
) RETURN VARCHAR;

END Pa_Rp_Util;

/

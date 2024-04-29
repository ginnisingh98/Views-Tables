--------------------------------------------------------
--  DDL for Package PJI_REP_PRF_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_REP_PRF_DFLT_PARAMS" AUTHID CURRENT_USER AS
/* $Header: PJIRX08S.pls 120.5 2006/09/06 09:59:08 pschandr noship $ */

PROCEDURE derive_dflt_params(
  p_project_id                   NUMBER
, x_WBS_Version_ID               OUT NOCOPY NUMBER
, x_WBS_Element_Id               OUT NOCOPY NUMBER
, x_RBS_Version_ID               OUT NOCOPY NUMBER
, x_RBS_Element_Id               OUT NOCOPY NUMBER
, x_calendar_id                  OUT NOCOPY NUMBER
, x_calendar_type                OUT NOCOPY VARCHAR2
, x_report_date_julian           OUT NOCOPY NUMBER
, x_period_name                  OUT NOCOPY VARCHAR2
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
, x_cstbudget2_plan_type_id		 OUT NOCOPY NUMBER
, x_revforecast_plan_type_id	 OUT NOCOPY NUMBER
, x_revbudget_plan_type_id		 OUT NOCOPY NUMBER
, x_revbudget2_plan_type_id		 OUT NOCOPY NUMBER
, x_currency_record_type         OUT NOCOPY NUMBER
, x_Currency_Code                OUT NOCOPY VARCHAR2
, x_currency_type                OUT NOCOPY VARCHAR2
, x_Factor_By                    OUT NOCOPY NUMBER
, x_prg_display                   OUT NOCOPY VARCHAR2
, x_Effort_UOM                   OUT NOCOPY NUMBER
, x_slice_name                   OUT NOCOPY VARCHAR2
, x_task_ref_flag                OUT NOCOPY VARCHAR2
, x_time_slice                   OUT NOCOPY INTEGER
, x_page_links_selection         OUT NOCOPY VARCHAR2
, x_from_period                  OUT NOCOPY NUMBER
, x_to_period                    OUT NOCOPY NUMBER
, x_project_type				 OUT NOCOPY VARCHAR2
, x_ptc_flag					 OUT NOCOPY VARCHAR2
, p_prg_rollup					 IN OUT NOCOPY VARCHAR2
, x_Return_Status                OUT NOCOPY VARCHAR2
, x_Msg_Count                    OUT NOCOPY NUMBER
, x_Msg_Data                     OUT NOCOPY VARCHAR2
, p_currency_record_type				 VARCHAR2 DEFAULT NULL
, p_period_type					 VARCHAR2 DEFAULT NULL
, p_as_of_date					 NUMBER DEFAULT NULL
, p_cstbudget_plan_type_id		 NUMBER DEFAULT NULL
, p_cstforecast_plan_type_id	 NUMBER DEFAULT NULL
, p_revbudget_plan_type_id		 NUMBER DEFAULT NULL
, p_revforecast_plan_type_id	 NUMBER DEFAULT NULL
, p_calling_type				 VARCHAR DEFAULT NULL
, x_fbs_expansion_lvl                  OUT NOCOPY NUMBER
);


END Pji_Rep_Prf_Dflt_Params;

 

/

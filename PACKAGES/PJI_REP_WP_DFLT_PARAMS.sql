--------------------------------------------------------
--  DDL for Package PJI_REP_WP_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_REP_WP_DFLT_PARAMS" AUTHID CURRENT_USER as
/*$Header: PJIRX09S.pls 120.0 2005/05/29 12:47:37 appldev noship $*/


-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
--   This procedures derives the default values for the listed parameters
-- ----------------------------------------------------------------------

procedure Derive_Default_Parameters(
	p_project_id			in 		number,
	p_structure_version_id		in 		number,

	x_wbs_element_id		out nocopy 	number,
	x_wbs_version_id		out nocopy 	number,
	x_rbs_element_id		out nocopy 	number,
	x_rbs_version_id		out nocopy 	number,

	x_calendar_type			out nocopy 	varchar2,
	x_calendar_id			out nocopy 	number,

	x_current_version_id		out nocopy 	number,
	x_actual_version_id		out nocopy 	number,
	x_latest_published_version_id	out nocopy 	number,
	x_baselined_version_id		out nocopy 	number,

	x_currency_record_type		out nocopy 	number,
	x_currency_code			out nocopy 	varchar2,
	x_program_flag  		out nocopy 	varchar2,
	x_factor_by  			out nocopy 	number,
	x_published_version_flag	out nocopy 	varchar2,
	x_versioning_enabled_flag	out nocopy 	varchar2,

	x_from_period 			out nocopy 	number,
	x_to_period 			out nocopy 	number,
	x_report_period 		out nocopy 	number,

	x_context_margin_mask 		out nocopy 	varchar2,
	x_str_editable_flag         out nocopy varchar2,
	x_wbs_expansion_lvl		out nocopy number,
	x_rbs_expansion_lvl     out nocopy number,
	x_return_status 		out nocopy 	varchar2,
	x_msg_count 			out nocopy 	number,
	x_msg_data 			out nocopy 	varchar2
);

-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
--   This procedure derives the tip message for view workplan pages
-- ----------------------------------------------------------------------

procedure Get_Currency_Tip(
	p_project_id			in		number,
	p_currency_record_type		in		varchar2,
	x_tip_message			out nocopy 	varchar2,

	x_return_status			out nocopy 	varchar2,
	x_msg_count			out nocopy	number,
	x_msg_data			out nocopy 	varchar2
);

-- ----------------------------------------------------------------------

end PJI_REP_WP_DFLT_PARAMS;

 

/

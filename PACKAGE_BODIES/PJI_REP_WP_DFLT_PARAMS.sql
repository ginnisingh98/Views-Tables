--------------------------------------------------------
--  DDL for Package Body PJI_REP_WP_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_REP_WP_DFLT_PARAMS" as
/*$Header: PJIRX09B.pls 120.0 2005/05/29 12:56:24 appldev noship $*/

-- ---------------------------------------------------------------------

g_msg_level_data_bug		number;
g_msg_level_data_corruption 	number;
g_msg_level_proc_call		number;
g_msg_level_high_detail		number;
g_msg_level_low_detail		number;


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
) is

-- ---------------------------------------------------------

-- Declare statements

g_ret_sts_warning		varchar2(1);
g_ret_sts_error			varchar2(1);

l_org_id 			varchar2(30);
l_edit_task_ok			varchar2(1);
l_period_name			varchar2(30);
l_report_date_julian		number;
l_currency_type			varchar2(30);
l_actual_summ_date 		date;


-- ---------------------------------------------------------

begin

g_ret_sts_warning 	:= 'W';
g_ret_sts_error		:= 'E';


-- ---------------------------

if 	x_return_status is null
then
	x_msg_count := 0;
	x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
end if;


-- ---------------------------
-- x_program_flag --

-- x_program_flag := 'N'; -- hard-code value to deactivate programs

x_program_flag :=
	Pji_Rep_Util.Derive_Prg_Rollup_Flag(
		p_project_id
	 );

/*
-- --------------------------
-- populate project hierarch cache

Pji_Rep_Util.Populate_WBS_Hierarchy_Cache(
	p_project_id,
	p_structure_version_id,
	x_program_flag,
	'WORKPLAN',
	null,
	x_return_status,
	x_msg_count,
	x_msg_data
	);
*/


-- --------------------------
-- x_current_version_id --
-- x_latest_published_version_id --
-- x_baselined_version_id --

Pji_Rep_Util.Derive_Work_Plan_Versions(
	p_project_id,
	p_structure_version_id,
	x_current_version_id,
	x_baselined_version_id,
	x_latest_published_version_id,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


-- ---------------------------
-- x_wbs_element_id --
-- x_wbs_version_id --

Pji_Rep_Util.Derive_Default_WBS_Parameters(
	p_project_id,
	x_current_version_id, 		-- derived
	x_wbs_version_id,
	x_wbs_element_id,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


-- ---------------------------
-- x_rbs_element_id --
-- x_rbs_version_id --

Pji_Rep_Util.Derive_Default_RBS_Parameters(
	p_project_id,
	x_current_version_id, -- p_structure_version_id,
	x_rbs_version_id,
	x_rbs_element_id,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


-- ---------------------------
-- x_calendar_id --
-- x_calendar_type --

Pji_Rep_Util.Derive_WP_Calendar_Info(
	p_project_id,
	x_current_version_id,  		-- derived
	x_calendar_id,
	x_calendar_type,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


-- ---------------------------
-- x_actual_version_id --

x_actual_version_id :=
	Pji_Rep_Util.get_work_plan_actual_version(
		p_project_id
	);


-- ---------------------------
-- x_currency_record_type --
-- x_currency_code --

Pji_Rep_Util.Derive_Default_Currency_Info(
	p_project_id,
	x_currency_record_type,
	x_currency_code,
	l_currency_type,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


-- ---------------------------
-- x_from_period
-- x_to_period

Pji_Rep_Util.Derive_WP_Period(
	p_project_id,
	x_latest_published_version_id, 	-- derived
	x_current_version_id, 		-- derived
	x_from_period,
	x_to_period,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


-- ---------------------------
-- x_factor_by --

x_factor_by :=
	Pji_Rep_Util.Derive_Factorby(
		p_project_id,
		--NULL,			-- p_fin_plan_type_id
		x_current_version_id, --bug 3793041
		x_return_status,
		x_msg_count,
		x_msg_data
	);

/*
-- ---------------------------
-- l_edit_task_ok--
-- x_published_version_flag --

l_edit_task_ok :=
        pa_proj_elements_utils.Check_Edit_Task_Ok(
                p_project_id,
                p_structure_version_id,
                p_structure_version_id
        );

if      l_edit_task_ok = 'Y'
then
        x_published_version_flag := 'N';
else
        x_published_version_flag := 'Y';

end if;
*/
-- ---------------------------
-- x_published_version_flag --

x_published_version_flag :=
PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
		p_project_id => p_project_id,
		p_structure_version_id => p_structure_version_id);

if x_published_version_flag not in ('Y','N') then
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
end if;
-- ---------------------------
-- x_editable_flag --

x_str_editable_flag :=
	pa_proj_elements_utils.Check_Edit_Task_Ok(
		p_project_id,
		p_structure_version_id,
		p_structure_version_id
	);

-- ---------------------------
-- x_context_margin_mask

Pji_Rep_Util.Derive_Version_Margin_Mask(
	p_project_id,
	x_current_version_id,
	x_context_margin_mask,
	x_return_status,
	x_msg_count,
	x_msg_data
	);

if 	x_context_margin_mask is null
then
	x_context_margin_mask := 'B';
end if;


-- ---------------------------
-- l_versioning_enabled--

x_versioning_enabled_flag :=
	PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
		p_project_id
	);

if 	x_versioning_enabled_flag is null
then
	x_versioning_enabled_flag := 'N';

end if;


-- ---------------------------
-- x_report_period

l_actual_summ_date :=
	pa_progress_utils.get_actual_summ_date(
		p_project_id
	);

begin
	select 	to_char(start_date,'j')
	into 	x_report_period
	from 	pji_time_cal_period
	where 	l_actual_summ_date -- sysdate
	between start_date
	and 	end_date
	and 	calendar_id = x_calendar_id;
exception
	when no_data_found
	then
		x_report_period := 1;
end;


if 	l_actual_summ_date is null
then
	x_report_period := 1;
end if;

-- ---------------------------
-- Get the default expansion levels

x_wbs_expansion_lvl := pji_rep_util.GET_DEFAULT_EXPANSION_LEVEL
								(p_project_id => p_project_id,
								 p_object_type => 'T');

x_rbs_expansion_lvl := pji_rep_util.GET_DEFAULT_EXPANSION_LEVEL
								(p_project_id => p_project_id,
								 p_object_type => 'R');

exception

	when 	NO_DATA_FOUND
	then
		x_msg_count := 1;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_NO_DATA_MSG', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR, p_token1=>'ITEM_NAME', p_token1_value=>'plan type attributes');
	when 	OTHERS
	then
		x_msg_count := 1;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Plan_Type_Parameters');

	raise;


-- ---------------------------

end Derive_Default_Parameters;

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
) is

-- -------------------------------------
-- Declare statements

l_prj_curr		varchar2(30);
l_pfc_curr		varchar2(30);

l_curr_text		varchar2(60);
l_version_text		varchar2(60);

l_curr_code		varchar2(30);
l_curr_type_msg		fnd_new_messages.MESSAGE_TEXT%TYPE; /* commented and modified for bug 4135886 varchar2(40); */

l_version_type_msg	fnd_new_messages.MESSAGE_TEXT%TYPE; /* commented and modified for bug 4135886 varchar(60); */


-- -------------------------------------

begin

-- ---------------------------

if 	x_return_status is null
then
	x_msg_count := 0;
	x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
end if;


-- -------------------------------------

select 	project_currency_code,
	projfunc_currency_code
into	l_prj_curr,
	l_pfc_curr
from	pa_projects
where	project_id = p_project_id;


-- -------------------------------------

-- record type id for project currency code is 8
-- record type id for project functional currency code is 4

if	(p_currency_record_type = '8')
then
	l_curr_code	:= l_prj_curr;
	l_curr_type_msg	:= fnd_message.get_string('PJI', 'PJI_REP_PROJECT_CURR');

elsif 	(p_currency_record_type = '4')
then
	l_curr_code	:= l_pfc_curr;
	l_curr_type_msg	:= fnd_message.get_string('PJI', 'PJI_REP_PFC_CURR');

else
	l_curr_code	:= l_prj_curr;
	l_curr_type_msg	:= fnd_message.get_string('PJI', 'PJI_REP_PROJECT_CURR');

end if;


-- -------------------------------------

fnd_Message.set_name('PJI','PJI_WP_CURR_TIP');
fnd_Message.set_token('CURRTYPE', l_curr_type_msg);
fnd_Message.set_token('CURRCODE',l_curr_code);
x_tip_message := Fnd_Message.get;


-- -------------------------------------

exception

	when 	NO_DATA_FOUND
	then
		x_msg_count := 1;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_NO_DATA_MSG', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR, p_token1=>'ITEM_NAME', p_token1_value=>'plan type attributes');
	when 	OTHERS
	then
		x_msg_count := 1;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Plan_Type_Parameters');

	raise;

-- -------------------------------------

end Get_Currency_Tip;

-- ----------------------------------------------------------------------





-- --------------------------------------------------------------------

begin

-- --------------------------------------------------------------------

-- Declare Global Variables

g_msg_level_data_bug		:= 6;
g_msg_level_data_corruption 	:= 5;
g_msg_level_proc_call		:= 3;
g_msg_level_high_detail		:= 2;
g_msg_level_low_detail		:= 1;

-- ----------------------------------------------------------------------

end PJI_REP_WP_DFLT_PARAMS;

-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------



/

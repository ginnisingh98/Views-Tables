--------------------------------------------------------
--  DDL for Package Body PA_SCHEDULE_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SCHEDULE_OBJECTS_PVT" as
/*$Header: PASCHOBB.pls 120.18.12010000.2 2008/09/16 06:24:58 dbudhwar ship $*/

  G_Pkg_Name    CONSTANT VARCHAR2(30):= 'PA _SCHEDULE_OBJECTS_PVT';
  G1_Debug_Mode VARCHAR2(1)          := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
-------------------------------------------------------------

  procedure GENERATE_SCHEDULE (
     p_api_version			IN	NUMBER	default	1.0
    ,p_commit				IN	VARCHAR2 default 'N'
    ,p_calling_module			IN	VARCHAR2 default 'SELF_SERVICE'
    ,p_debug_mode			IN	VARCHAR2 default 'N'
    ,p_max_msg_count			IN	NUMBER	 default NULL
    ,p_number_digit			IN	NUMBER	 default 4
    ,x_return_status			OUT NOCOPY	VARCHAR2
    ,x_msg_count			OUT NOCOPY	NUMBER
    ,x_msg_data				OUT NOCOPY	VARCHAR2
    ,p_data_structure			IN OUT NOCOPY	PA_SCHEDULE_OBJECTS_TBL_TYPE
    ,x_Process_Number			OUT NOCOPY	NUMBER
    ,p_process_flag1			IN	VARCHAR2 default 'N'
    ,p_derived_field1			IN	VARCHAR2 default 'DURATION'
    ,p_process_rollup_flag1		IN	VARCHAR2 default 'N'
    ,p_partial_process_flag1		IN	VARCHAR2 default 'N'
    ,p_process_dependency_flag1		IN	VARCHAR2 default 'N'
    ,p_process_constraint_flag1		IN	VARCHAR2 default 'N'
    ,p_process_task_status_flag1	IN	VARCHAR2 default 'N'
    ,p_process_progress_flag1		IN	VARCHAR2 default 'N'
    ,p_process_effort_flag1		IN	VARCHAR2 default 'N'
    ,p_process_percent_flag1		IN	VARCHAR2 default 'N'
    ,p_process_number_flag1		IN	VARCHAR2 default 'N'
    ,p_partial_dates_flag1		IN	VARCHAR2 default 'N'
    ,p_partial_task_status_flag1	IN	VARCHAR2 default 'N'
    ,p_partial_progress_flag1		IN	VARCHAR2 default 'N'
    ,p_partial_effort_flag1		IN	VARCHAR2 default 'N'
    ,p_partial_percent_flag1		IN	VARCHAR2 default 'N'
    ,p_partial_number_flag1		IN	VARCHAR2 default 'N'
    ,p_process_flag2			IN	VARCHAR2 default 'N'
    ,p_derived_field2			IN	VARCHAR2 default 'DURATION'
    ,p_process_rollup_flag2		IN	VARCHAR2 default 'N'
    ,p_partial_process_flag2		IN	VARCHAR2 default 'N'
    ,p_process_dependency_flag2		IN	VARCHAR2 default 'N'
    ,p_process_constraint_flag2		IN	VARCHAR2 default 'N'
    ,p_process_task_status_flag2	IN	VARCHAR2 default 'N'
    ,p_process_progress_flag2		IN	VARCHAR2 default 'N'
    ,p_process_effort_flag2		IN	VARCHAR2 default 'N'
    ,p_process_percent_flag2		IN	VARCHAR2 default 'N'
    ,p_process_number_flag2		IN	VARCHAR2 default 'N'
    ,p_partial_dates_flag2		IN	VARCHAR2 default 'N'
    ,p_partial_task_status_flag2	IN	VARCHAR2 default 'N'
    ,p_partial_progress_flag2		IN	VARCHAR2 default 'N'
    ,p_partial_effort_flag2		IN	VARCHAR2 default 'N'
    ,p_partial_percent_flag2		IN	VARCHAR2 default 'N'
    ,p_partial_number_flag2		IN	VARCHAR2 default 'N'
    ,p_process_flag3			IN	VARCHAR2 default 'N'
    ,p_derived_field3			IN	VARCHAR2 default 'DURATION'
    ,p_process_rollup_flag3		IN	VARCHAR2 default 'N'
    ,p_partial_process_flag3		IN	VARCHAR2 default 'N'
    ,p_process_dependency_flag3		IN	VARCHAR2 default 'N'
    ,p_process_constraint_flag3		IN	VARCHAR2 default 'N'
    ,p_process_task_status_flag3	IN	VARCHAR2 default 'N'
    ,p_process_progress_flag3		IN	VARCHAR2 default 'N'
    ,p_process_effort_flag3		IN	VARCHAR2 default 'N'
    ,p_process_percent_flag3		IN	VARCHAR2 default 'N'
    ,p_process_number_flag3		IN	VARCHAR2 default 'N'
    ,p_partial_dates_flag3		IN	VARCHAR2 default 'N'
    ,p_partial_task_status_flag3	IN	VARCHAR2 default 'N'
    ,p_partial_progress_flag3		IN	VARCHAR2 default 'N'
    ,p_partial_effort_flag3		IN	VARCHAR2 default 'N'
    ,p_partial_percent_flag3		IN	VARCHAR2 default 'N'
    ,p_partial_number_flag3		IN	VARCHAR2 default 'N'
    ,p_process_flag4			IN	VARCHAR2 default 'N'
    ,p_derived_field4			IN	VARCHAR2 default 'DURATION'
    ,p_process_rollup_flag4		IN	VARCHAR2 default 'N'
    ,p_partial_process_flag4		IN	VARCHAR2 default 'N'
    ,p_process_dependency_flag4		IN	VARCHAR2 default 'N'
    ,p_process_constraint_flag4		IN	VARCHAR2 default 'N'
    ,p_process_task_status_flag4	IN	VARCHAR2 default 'N'
    ,p_process_progress_flag4		IN	VARCHAR2 default 'N'
    ,p_process_effort_flag4		IN	VARCHAR2 default 'N'
    ,p_process_percent_flag4		IN	VARCHAR2 default 'N'
    ,p_process_number_flag4		IN	VARCHAR2 default 'N'
    ,p_partial_dates_flag4		IN	VARCHAR2 default 'N'
    ,p_partial_task_status_flag4	IN	VARCHAR2 default 'N'
    ,p_partial_progress_flag4		IN	VARCHAR2 default 'N'
    ,p_partial_effort_flag4		IN	VARCHAR2 default 'N'
    ,p_partial_percent_flag4		IN	VARCHAR2 default 'N'
    ,p_partial_number_flag4		IN	VARCHAR2 default 'N'
    ,p_process_flag5			IN	VARCHAR2 default 'N'
    ,p_derived_field5			IN	VARCHAR2 default 'DURATION'
    ,p_process_rollup_flag5		IN	VARCHAR2 default 'N'
    ,p_partial_process_flag5		IN	VARCHAR2 default 'N'
    ,p_process_dependency_flag5		IN	VARCHAR2 default 'N'
    ,p_process_constraint_flag5		IN	VARCHAR2 default 'N'
    ,p_process_task_status_flag5	IN	VARCHAR2 default 'N'
    ,p_process_progress_flag5		IN	VARCHAR2 default 'N'
    ,p_process_effort_flag5		IN	VARCHAR2 default 'N'
    ,p_process_percent_flag5		IN	VARCHAR2 default 'N'
    ,p_process_number_flag5		IN	VARCHAR2 default 'N'
    ,p_partial_dates_flag5		IN	VARCHAR2 default 'N'
    ,p_partial_task_status_flag5	IN	VARCHAR2 default 'N'
    ,p_partial_progress_flag5		IN	VARCHAR2 default 'N'
    ,p_partial_effort_flag5		IN	VARCHAR2 default 'N'
    ,p_partial_percent_flag5		IN	VARCHAR2 default 'N'
    ,p_partial_number_flag5		IN	VARCHAR2 default 'N'
    ,p_process_flag6			IN	VARCHAR2 default 'N'
    ,p_derived_field6			IN	VARCHAR2 default 'DURATION'
    ,p_process_rollup_flag6		IN	VARCHAR2 default 'N'
    ,p_partial_process_flag6		IN	VARCHAR2 default 'N'
    ,p_process_dependency_flag6		IN	VARCHAR2 default 'N'
    ,p_process_constraint_flag6		IN	VARCHAR2 default 'N'
    ,p_process_task_status_flag6	IN	VARCHAR2 default 'N'
    ,p_process_progress_flag6		IN	VARCHAR2 default 'N'
    ,p_process_effort_flag6		IN	VARCHAR2 default 'N'
    ,p_process_percent_flag6		IN	VARCHAR2 default 'N'
    ,p_process_number_flag6		IN	VARCHAR2 default 'N'
    ,p_partial_dates_flag6		IN	VARCHAR2 default 'N'
    ,p_partial_task_status_flag6	IN	VARCHAR2 default 'N'
    ,p_partial_progress_flag6		IN	VARCHAR2 default 'N'
    ,p_partial_effort_flag6		IN	VARCHAR2 default 'N'
    ,p_partial_percent_flag6		IN	VARCHAR2 default 'N'
    ,p_partial_number_flag6		IN	VARCHAR2 default 'N'
    ,p_process_ETC_Flag1		IN	VARCHAR2 default 'N'
    ,p_partial_ETC_Flag1		IN	VARCHAR2 default 'N'
    ,p_process_ETC_Flag2		IN	VARCHAR2 default 'N'
    ,p_partial_ETC_Flag2		IN	VARCHAR2 default 'N'
    ,p_process_ETC_Flag3		IN	VARCHAR2 default 'N'
    ,p_partial_ETC_Flag3		IN	VARCHAR2 default 'N'
    ,p_process_ETC_Flag4		IN	VARCHAR2 default 'N'
    ,p_partial_ETC_Flag4		IN	VARCHAR2 default 'N'
    ,p_process_ETC_Flag5		IN	VARCHAR2 default 'N'
    ,p_partial_ETC_Flag5		IN	VARCHAR2 default 'N'
    ,p_process_ETC_Flag6		IN	VARCHAR2 default 'N'
    ,p_partial_ETC_Flag6		IN	VARCHAR2 default 'N'
    ,p_Rollup_Method			IN	VARCHAR2 default 'COST'
  )
  IS

API_ERROR			EXCEPTION;
l_msg_index_out			NUMBER;
l_Process_Number		NUMBER;
l_msg_count			NUMBER := 0;
l_msg_data			VARCHAR2(2000);
l_return_status			VARCHAR2(1) := 'N';
l_data_record			PA_SCHEDULE_OBJECTS_REC_TYPE;



l_OBJECT_TYPE			PA_PLSQL_DATATYPES.Char30TabTyp;
l_OBJECT_ID			PA_PLSQL_DATATYPES.IdTabTyp;
l_PARENT_OBJECT_TYPE		PA_PLSQL_DATATYPES.Char30TabTyp;
l_PARENT_OBJECT_ID		PA_PLSQL_DATATYPES.IdTabTyp;
l_CALENDAR_ID			PA_PLSQL_DATATYPES.NumTabTyp;
l_CONSTRAINT_TYPE_CODE		PA_PLSQL_DATATYPES.Char1TabTyp;
l_CONSTRAINT_DATE		PA_PLSQL_DATATYPES.DateTabTyp;
l_WBS_LEVEL			PA_PLSQL_DATATYPES.IdTabTyp;
l_SUMMARY_OBJECT_FLAG		PA_PLSQL_DATATYPES.Char1TabTyp; -- 4370746

l_START_DATE1			PA_PLSQL_DATATYPES.DateTabTyp;
l_START_DATE_OVERRIDE1		PA_PLSQL_DATATYPES.DateTabTyp;
l_FINISH_DATE1			PA_PLSQL_DATATYPES.DateTabTyp;
l_DURATION1			PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_STATUS1			PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_STATUS_WEIGHT1	PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_OVERRIDE1		PA_PLSQL_DATATYPES.NumTabTyp;
l_REMAINING_EFFORT1		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_COMPLETE1		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_OVERRIDE1		PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_WEIGHT1			PA_PLSQL_DATATYPES.NumTabTyp;
l_NUMBER_FIELD1			PA_PLSQL_DATATYPES.NumTabTyp;
l_ROLLUP_NODE1			PA_PLSQL_DATATYPES.Char1TabTyp;
l_DIRTY_FLAG1			PA_PLSQL_DATATYPES.Char1TabTyp;
l_Etc_Cost1			PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_ETC_Cost1			PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_COST1		PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_UNPLAND_EFFORT1		PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_EFFORT1		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_ETC_COST1		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_COST1		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_COST1	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_EFFORT1	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_EFFORT1	PA_PLSQL_DATATYPES.NumTabTyp;
l_EARNED_VALUE1			PA_PLSQL_DATATYPES.NumTabTyp;
l_BAC_VALUE1			PA_PLSQL_DATATYPES.NumTabTyp;
l_Perc_Comp_Deriv_Code1		PA_PLSQL_DATATYPES.Char30TabTyp;
l_START_DATE2			PA_PLSQL_DATATYPES.DateTabTyp;
l_START_DATE_OVERRIDE2		PA_PLSQL_DATATYPES.DateTabTyp;
l_FINISH_DATE2			PA_PLSQL_DATATYPES.DateTabTyp;
l_DURATION2			PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_STATUS2			PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_STATUS_WEIGHT2	PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_OVERRIDE2		PA_PLSQL_DATATYPES.NumTabTyp;
l_REMAINING_EFFORT2		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_COMPLETE2		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_OVERRIDE2		PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_WEIGHT2			PA_PLSQL_DATATYPES.NumTabTyp;
l_NUMBER_FIELD2			PA_PLSQL_DATATYPES.NumTabTyp;
l_ROLLUP_NODE2			PA_PLSQL_DATATYPES.Char1TabTyp;
l_DIRTY_FLAG2			PA_PLSQL_DATATYPES.Char1TabTyp;
l_Etc_Cost2			PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_ETC_Cost2			PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_COST2		PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_UNPLAND_EFFORT2		PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_EFFORT2		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_ETC_COST2		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_COST2		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_COST2	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_EFFORT2	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_EFFORT2	PA_PLSQL_DATATYPES.NumTabTyp;
l_EARNED_VALUE2			PA_PLSQL_DATATYPES.NumTabTyp;
l_BAC_VALUE2			PA_PLSQL_DATATYPES.NumTabTyp;
l_Perc_Comp_Deriv_Code2		PA_PLSQL_DATATYPES.Char30TabTyp;
l_START_DATE3			PA_PLSQL_DATATYPES.DateTabTyp;
l_START_DATE_OVERRIDE3		PA_PLSQL_DATATYPES.DateTabTyp;
l_FINISH_DATE3			PA_PLSQL_DATATYPES.DateTabTyp;
l_DURATION3			PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_STATUS3			PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_STATUS_WEIGHT3	PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_OVERRIDE3		PA_PLSQL_DATATYPES.NumTabTyp;
l_REMAINING_EFFORT3		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_COMPLETE3		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_OVERRIDE3		PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_WEIGHT3			PA_PLSQL_DATATYPES.NumTabTyp;
l_NUMBER_FIELD3			PA_PLSQL_DATATYPES.NumTabTyp;
l_ROLLUP_NODE3			PA_PLSQL_DATATYPES.Char1TabTyp;
l_DIRTY_FLAG3			PA_PLSQL_DATATYPES.Char1TabTyp;
l_Etc_Cost3			PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_ETC_Cost3			PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_COST3		PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_UNPLAND_EFFORT3		PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_EFFORT3		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_ETC_COST3		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_COST3		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_COST3	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_EFFORT3	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_EFFORT3	PA_PLSQL_DATATYPES.NumTabTyp;
l_EARNED_VALUE3			PA_PLSQL_DATATYPES.NumTabTyp;
l_BAC_VALUE3			PA_PLSQL_DATATYPES.NumTabTyp;
l_Perc_Comp_Deriv_Code3		PA_PLSQL_DATATYPES.Char30TabTyp;
l_START_DATE4			PA_PLSQL_DATATYPES.DateTabTyp;
l_START_DATE_OVERRIDE4		PA_PLSQL_DATATYPES.DateTabTyp;
l_FINISH_DATE4			PA_PLSQL_DATATYPES.DateTabTyp;
l_DURATION4			PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_STATUS4			PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_STATUS_WEIGHT4	PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_OVERRIDE4		PA_PLSQL_DATATYPES.NumTabTyp;
l_REMAINING_EFFORT4		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_COMPLETE4		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_OVERRIDE4		PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_WEIGHT4			PA_PLSQL_DATATYPES.NumTabTyp;
l_NUMBER_FIELD4			PA_PLSQL_DATATYPES.NumTabTyp;
l_ROLLUP_NODE4			PA_PLSQL_DATATYPES.Char1TabTyp;
l_DIRTY_FLAG4			PA_PLSQL_DATATYPES.Char1TabTyp;
l_Etc_Cost4			PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_ETC_Cost4			PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_COST4		PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_UNPLAND_EFFORT4		PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_EFFORT4		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_ETC_COST4		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_COST4		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_COST4	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_EFFORT4	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_EFFORT4	PA_PLSQL_DATATYPES.NumTabTyp;
l_EARNED_VALUE4			PA_PLSQL_DATATYPES.NumTabTyp;
l_BAC_VALUE4			PA_PLSQL_DATATYPES.NumTabTyp;
l_Perc_Comp_Deriv_Code4		PA_PLSQL_DATATYPES.Char30TabTyp;
l_START_DATE5			PA_PLSQL_DATATYPES.DateTabTyp;
l_START_DATE_OVERRIDE5		PA_PLSQL_DATATYPES.DateTabTyp;
l_FINISH_DATE5			PA_PLSQL_DATATYPES.DateTabTyp;
l_DURATION5			PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_STATUS5			PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_STATUS_WEIGHT5	PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_OVERRIDE5		PA_PLSQL_DATATYPES.NumTabTyp;
l_REMAINING_EFFORT5		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_COMPLETE5		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_OVERRIDE5		PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_WEIGHT5			PA_PLSQL_DATATYPES.NumTabTyp;
l_NUMBER_FIELD5			PA_PLSQL_DATATYPES.NumTabTyp;
l_ROLLUP_NODE5			PA_PLSQL_DATATYPES.Char1TabTyp;
l_DIRTY_FLAG5			PA_PLSQL_DATATYPES.Char1TabTyp;
l_Etc_Cost5			PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_ETC_Cost5			PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_COST5		PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_UNPLAND_EFFORT5		PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_EFFORT5		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_ETC_COST5		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_COST5		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_COST5	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_EFFORT5	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_EFFORT5	PA_PLSQL_DATATYPES.NumTabTyp;
l_EARNED_VALUE5			PA_PLSQL_DATATYPES.NumTabTyp;
l_BAC_VALUE5			PA_PLSQL_DATATYPES.NumTabTyp;
l_Perc_Comp_Deriv_Code5		PA_PLSQL_DATATYPES.Char30TabTyp;
l_START_DATE6			PA_PLSQL_DATATYPES.DateTabTyp;
l_START_DATE_OVERRIDE6		PA_PLSQL_DATATYPES.DateTabTyp;
l_FINISH_DATE6			PA_PLSQL_DATATYPES.DateTabTyp;
l_DURATION6			PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_STATUS6			PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_STATUS_WEIGHT6	PA_PLSQL_DATATYPES.NumTabTyp;
l_PROGRESS_OVERRIDE6		PA_PLSQL_DATATYPES.NumTabTyp;
l_REMAINING_EFFORT6		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_COMPLETE6		PA_PLSQL_DATATYPES.NumTabTyp;
l_PERCENT_OVERRIDE6		PA_PLSQL_DATATYPES.NumTabTyp;
l_TASK_WEIGHT6			PA_PLSQL_DATATYPES.NumTabTyp;
l_NUMBER_FIELD6			PA_PLSQL_DATATYPES.NumTabTyp;
l_ROLLUP_NODE6			PA_PLSQL_DATATYPES.Char1TabTyp;
l_DIRTY_FLAG6			PA_PLSQL_DATATYPES.Char1TabTyp;
l_Etc_Cost6			PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_ETC_Cost6			PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_COST6		PA_PLSQL_DATATYPES.NumTabTyp;
l_PPL_UNPLAND_EFFORT6		PA_PLSQL_DATATYPES.NumTabTyp;
l_EQPMT_ETC_EFFORT6		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_ETC_COST6		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_COST6		PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_COST6	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_PPL_ETC_EFFORT6	PA_PLSQL_DATATYPES.NumTabTyp;
l_SUB_PRJ_EQPMT_ETC_EFFORT6	PA_PLSQL_DATATYPES.NumTabTyp;
l_EARNED_VALUE6			PA_PLSQL_DATATYPES.NumTabTyp;
l_BAC_VALUE6			PA_PLSQL_DATATYPES.NumTabTyp;
l_Perc_Comp_Deriv_Code6		PA_PLSQL_DATATYPES.Char30TabTyp;

l_task_count                    NUMBER;
l_task_flag                     NUMBER;
L_DATA_COUNT			NUMBER;
l_partial_rollup1		BOOLEAN;
l_partial_rollup2		BOOLEAN;
l_partial_rollup3		BOOLEAN;
l_partial_rollup4		BOOLEAN;
l_partial_rollup5		BOOLEAN;
l_partial_rollup6		BOOLEAN;
l_lowest_task			VARCHAR2(1);

l_wbs_level_tab                 SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_task_flag_tab                 SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_task_count_tab                SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_update_flag_tab               SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();

l_child_update_required         VARCHAR2(1);
l_parent_update_required         VARCHAR2(1);
l_parent_rowid_tab              SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
L_CHILD_OBJECT_IDS_TAB          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
L_PARENT_OBJECT_IDS_TAB         SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_parent_object_types_tab       SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_child_object_types_tab        SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_parent_start_date_tab1        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_tab2        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_tab3        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_tab4        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_tab5        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_tab6        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_or_tab1     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_or_tab2     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_or_tab3     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_or_tab4     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_or_tab5     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_start_date_or_tab6     SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_finish_date_tab1       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_finish_date_tab2       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_finish_date_tab3       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_finish_date_tab4       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_finish_date_tab5       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_finish_date_tab6       SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_parent_duration_tab1          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_parent_duration_tab2          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_parent_duration_tab3          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_parent_duration_tab4          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_parent_duration_tab5          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_parent_duration_tab6          SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();

l_child_start_date_tab1         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_start_date_tab2         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_start_date_tab3         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_start_date_tab4         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_start_date_tab5         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_start_date_tab6         SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_finish_date_tab1        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_finish_date_tab2        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_finish_date_tab3        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_finish_date_tab4        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_finish_date_tab5        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_finish_date_tab6        SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
l_child_duration_tab1           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_child_duration_tab2           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_child_duration_tab3           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_child_duration_tab4           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_child_duration_tab5           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_child_duration_tab6           SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();


l_object_ids_tab		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_object_types_tab		SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_count_tab			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_sum_tab1			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_sum_tab2			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_sum_tab3			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_sum_tab4			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_sum_tab5			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_sum_tab6			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_task_status_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_task_status_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_task_status_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_task_status_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_task_status_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_task_status_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_perc_comp_deriv_code_tab	SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_bac_value_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_bac_value_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_bac_value_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_bac_value_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_bac_value_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_bac_value_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_complete_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_complete_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_complete_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_complete_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_complete_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_complete_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_override_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_override_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_override_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_override_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_override_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_percent_override_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_earned_value_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_earned_value_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_earned_value_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_earned_value_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_earned_value_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_earned_value_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_ETC_Cost_tab1			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_ETC_Cost_tab2			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_ETC_Cost_tab3			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_ETC_Cost_tab4			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_ETC_Cost_tab5			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_ETC_Cost_tab6			SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_ETC_COST_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_ETC_COST_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_ETC_COST_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_ETC_COST_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_ETC_COST_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_ETC_COST_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_COST_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_COST_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_COST_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_COST_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_COST_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_COST_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_UNPLAND_EFFORT_tab1       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_UNPLAND_EFFORT_tab2       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_UNPLAND_EFFORT_tab3       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_UNPLAND_EFFORT_tab4       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_UNPLAND_EFFORT_tab5       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_PPL_UNPLAND_EFFORT_tab6       SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_EFFORT_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_EFFORT_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_EFFORT_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_EFFORT_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_EFFORT_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_EQPMT_ETC_EFFORT_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_ETC_COST_tab1		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_ETC_COST_tab2		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_ETC_COST_tab3		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_ETC_COST_tab4		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_ETC_COST_tab5		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_ETC_COST_tab6		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_COST_tab1     SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_COST_tab2     SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_COST_tab3     SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_COST_tab4     SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_COST_tab5     SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_COST_tab6     SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_EQPMT_ETC_COST_tab1   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_EQPMT_ETC_COST_tab2   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_EQPMT_ETC_COST_tab3   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_EQPMT_ETC_COST_tab4   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_EQPMT_ETC_COST_tab5   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_EQPMT_ETC_COST_tab6   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_EFFORT_tab1   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_EFFORT_tab2   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_EFFORT_tab3   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_EFFORT_tab4   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_EFFORT_tab5   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_SUB_PRJ_PPL_ETC_EFFORT_tab6   SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
L_SP_EQPMT_ETC_EFFORT_TAB1	SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
L_SP_EQPMT_ETC_EFFORT_TAB2	SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
L_SP_EQPMT_ETC_EFFORT_TAB3	SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
L_SP_EQPMT_ETC_EFFORT_TAB4	SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
L_SP_EQPMT_ETC_EFFORT_TAB5	SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
L_SP_EQPMT_ETC_EFFORT_TAB6	SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();

l_temp_object_ids_tab		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_temp_object_types_tab		SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_temp_dirty_flag_tab1		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_temp_dirty_flag_tab2		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_temp_dirty_flag_tab3		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_temp_dirty_flag_tab4		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_temp_dirty_flag_tab5		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_temp_dirty_flag_tab6		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

l_int_object_ids_tab		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_int_object_types_tab		SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_int_dirty_flag_tab1		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_dirty_flag_tab2		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_dirty_flag_tab3		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_dirty_flag_tab4		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_dirty_flag_tab5		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_dirty_flag_tab6		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

l_int_ref_object_ids_tab	SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_int_ref_dirty_flag_tab1	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_ref_dirty_flag_tab2	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_ref_dirty_flag_tab3	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_ref_dirty_flag_tab4	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_ref_dirty_flag_tab5	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_int_ref_dirty_flag_tab6	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

l_ref_object_ids_tab		SYSTEM.pa_num_tbl_type            := SYSTEM.pa_num_tbl_type();
l_dirty_flag_tab1		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_dirty_flag_tab2		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_dirty_flag_tab3		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_dirty_flag_tab4		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_dirty_flag_tab5		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_dirty_flag_tab6		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_ref_dirty_flag_tab1		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_ref_dirty_flag_tab2		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_ref_dirty_flag_tab3		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_ref_dirty_flag_tab4		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_ref_dirty_flag_tab5		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_ref_dirty_flag_tab6		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

l_update_date_flag_tab1		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_date_flag_tab2		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_date_flag_tab3		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_date_flag_tab4		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_date_flag_tab5		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_date_flag_tab6		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_upd_req_flag_tab1	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_upd_req_flag_tab2	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_upd_req_flag_tab3	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_upd_req_flag_tab4	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_upd_req_flag_tab5	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_upd_req_flag_tab6	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_dirty_flag_tab1		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_dirty_flag_tab2		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_dirty_flag_tab3		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_dirty_flag_tab4		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_dirty_flag_tab5		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_child_dirty_flag_tab6		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_parent_dirty_flag_tab1	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_parent_dirty_flag_tab2	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_parent_dirty_flag_tab3	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_parent_dirty_flag_tab4	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_parent_dirty_flag_tab5	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_parent_dirty_flag_tab6	SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_requ_flag_tab1		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_requ_flag_tab2		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_requ_flag_tab3		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_requ_flag_tab4		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_requ_flag_tab5		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_update_requ_flag_tab6		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

l_summ_obj_flag_tab		SYSTEM.PA_VARCHAR2_1_TBL_TYPE	  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE(); -- 4587517


l_actual_duration1		NUMBER;
l_actual_duration2		NUMBER;
l_actual_duration3		NUMBER;
l_actual_duration4		NUMBER;
l_actual_duration5		NUMBER;
l_actual_duration6		NUMBER;
l_pc_duration1			NUMBER;
l_pc_duration2			NUMBER;
l_pc_duration3			NUMBER;
l_pc_duration4			NUMBER;
l_pc_duration5			NUMBER;
l_pc_duration6			NUMBER;
l_actual_duration1_a		NUMBER;
l_actual_duration2_a		NUMBER;
l_actual_duration3_a		NUMBER;
l_actual_duration4_a		NUMBER;
l_actual_duration5_a		NUMBER;
l_actual_duration6_a		NUMBER;
l_duration1_a			NUMBER;
l_duration2_a			NUMBER;
l_duration3_a			NUMBER;
l_duration4_a			NUMBER;
l_duration5_a			NUMBER;
l_duration6_a			NUMBER;
l_actual_duration1_t		NUMBER;
l_actual_duration2_t		NUMBER;
l_actual_duration3_t		NUMBER;
l_actual_duration4_t		NUMBER;
l_actual_duration5_t		NUMBER;
l_actual_duration6_t		NUMBER;
l_duration1_t			NUMBER;
l_duration2_t			NUMBER;
l_duration3_t			NUMBER;
l_duration4_t			NUMBER;
l_duration5_t			NUMBER;
l_duration6_t			NUMBER;
l_Weight			NUMBER;
l_Weight1			NUMBER;
l_Weight2			NUMBER;
l_Weight3			NUMBER;
l_Weight4			NUMBER;
l_Weight5			NUMBER;
l_Weight6			NUMBER;
l_update_required		VARCHAR2(1):= 'N';
l_Count				NUMBER;
l_not_started 			VARCHAR2(1);
l_completed 			VARCHAR2(1);
l_in_progress 			VARCHAR2(1);
l_on_hold 			VARCHAR2(1);
l_temp_percent1			NUMBER;
l_temp_percent2			NUMBER;
l_temp_percent3			NUMBER;
l_temp_percent4			NUMBER;
l_temp_percent5			NUMBER;
l_temp_percent6			NUMBER;
l_counter			NUMBER;
l_count1			NUMBER;
l_count2			NUMBER;
l_count3			NUMBER;
l_count4			NUMBER;
l_count5			NUMBER;
l_count6			NUMBER;
l_task_count1			NUMBER;
l_task_count2			NUMBER;
l_task_count3			NUMBER;
l_task_count4			NUMBER;
l_task_count5			NUMBER;
l_task_count6			NUMBER;
l_null_flag1			NUMBER;
l_null_flag2			NUMBER;
l_null_flag3			NUMBER;
l_null_flag4			NUMBER;
l_null_flag5			NUMBER;
l_null_flag6			NUMBER;
l_new_start_date1		DATE;
l_new_start_date2		DATE;
l_new_start_date3		DATE;
l_new_start_date4		DATE;
l_new_start_date5		DATE;
l_new_start_date6		DATE;
l_new_completion_date1		DATE;
l_new_completion_date2		DATE;
l_new_completion_date3		DATE;
l_new_completion_date4		DATE;
l_new_completion_date5		DATE;
l_new_completion_date6		DATE;

/* Starts Added for the bug#6185523 */
l_parent_start_date1_tmp		DATE;
l_parent_finish_date1_tmp	DATE;
l_parent_duration1_tmp		NUMBER;
l_parent_start_date2_tmp		DATE;
l_parent_finish_date2_tmp	DATE;
l_parent_duration2_tmp		NUMBER;
l_parent_start_date3_tmp		DATE;
l_parent_finish_date3_tmp	DATE;
l_parent_duration3_tmp		NUMBER;
l_parent_start_date4_tmp		DATE;
l_parent_finish_date4_tmp	DATE;
l_parent_duration4_tmp		NUMBER;
l_parent_start_date5_tmp		DATE;
l_parent_finish_date5_tmp	DATE;
l_parent_duration5_tmp		NUMBER;
l_parent_start_date6_tmp		DATE;
l_parent_finish_date6_tmp	DATE;
l_parent_duration6_tmp		NUMBER;
dirty_flag1_tmp			VARCHAR2(1);
dirty_flag2_tmp			VARCHAR2(1);
dirty_flag3_tmp			VARCHAR2(1);
dirty_flag4_tmp			VARCHAR2(1);
dirty_flag5_tmp			VARCHAR2(1);
dirty_flag6_tmp			VARCHAR2(1);
/* Ends Added for the bug#6185523 */

 CURSOR Processed_Data_Structure(C_Process_Number NUMBER) IS
      SELECT
	OBJECT_TYPE,
	OBJECT_ID,
	PARENT_OBJECT_TYPE,
	PARENT_OBJECT_ID,
	CALENDAR_ID,
	CONSTRAINT_TYPE_CODE,
	CONSTRAINT_DATE,
	WBS_LEVEL,
	START_DATE1,
	START_DATE_OVERRIDE1,
	FINISH_DATE1,
	DURATION1,
	TASK_STATUS1,
	PROGRESS_STATUS_WEIGHT1,
	PROGRESS_OVERRIDE1,
	REMAINING_EFFORT1,
	PERCENT_COMPLETE1,
	PERCENT_OVERRIDE1,
	TASK_WEIGHT1,
	NUMBER_FIELD1,
	ROLLUP_NODE1,
	DIRTY_FLAG1,
	ETC_Cost1,
	PPL_ETC_COST1,
	EQPMT_ETC_COST1,
	PPL_UNPLAND_EFFORT1,
	EQPMT_ETC_EFFORT1,
	SUB_PRJ_ETC_COST1,
	SUB_PRJ_PPL_ETC_COST1,
	SUB_PRJ_EQPMT_ETC_COST1,
	SUB_PRJ_PPL_ETC_EFFORT1,
	SUB_PRJ_EQPMT_ETC_EFFORT1,
	EARNED_VALUE1,
	BAC_VALUE1,
	START_DATE2,
	START_DATE_OVERRIDE2,
	FINISH_DATE2,
	DURATION2,
	TASK_STATUS2,
	PROGRESS_STATUS_WEIGHT2,
	PROGRESS_OVERRIDE2,
	REMAINING_EFFORT2,
	PERCENT_COMPLETE2,
	PERCENT_OVERRIDE2,
	TASK_WEIGHT2,
	NUMBER_FIELD2,
	ROLLUP_NODE2,
	DIRTY_FLAG2,
	ETC_Cost2,
	PPL_ETC_COST2,
	EQPMT_ETC_COST2,
	PPL_UNPLAND_EFFORT2,
	EQPMT_ETC_EFFORT2,
	SUB_PRJ_ETC_COST2,
	SUB_PRJ_PPL_ETC_COST2,
	SUB_PRJ_EQPMT_ETC_COST2,
	SUB_PRJ_PPL_ETC_EFFORT2,
	SUB_PRJ_EQPMT_ETC_EFFORT2,
	EARNED_VALUE2,
	BAC_VALUE2,
	START_DATE3,
	START_DATE_OVERRIDE3,
	FINISH_DATE3,
	DURATION3,
	TASK_STATUS3,
	PROGRESS_STATUS_WEIGHT3,
	PROGRESS_OVERRIDE3,
	REMAINING_EFFORT3,
	PERCENT_COMPLETE3,
	PERCENT_OVERRIDE3,
	TASK_WEIGHT3,
	NUMBER_FIELD3,
	ROLLUP_NODE3,
	DIRTY_FLAG3,
	ETC_Cost3,
	PPL_ETC_COST3,
	EQPMT_ETC_COST3,
	PPL_UNPLAND_EFFORT3,
	EQPMT_ETC_EFFORT3,
	SUB_PRJ_ETC_COST3,
	SUB_PRJ_PPL_ETC_COST3,
	SUB_PRJ_EQPMT_ETC_COST3,
	SUB_PRJ_PPL_ETC_EFFORT3,
	SUB_PRJ_EQPMT_ETC_EFFORT3,
	EARNED_VALUE3,
	BAC_VALUE3,
	START_DATE4,
	START_DATE_OVERRIDE4,
	FINISH_DATE4,
	DURATION4,
	TASK_STATUS4,
	PROGRESS_STATUS_WEIGHT4,
	PROGRESS_OVERRIDE4,
	REMAINING_EFFORT4,
	PERCENT_COMPLETE4,
	PERCENT_OVERRIDE4,
	TASK_WEIGHT4,
	NUMBER_FIELD4,
	ROLLUP_NODE4,
	DIRTY_FLAG4,
	ETC_Cost4,
	PPL_ETC_COST4,
	EQPMT_ETC_COST4,
	PPL_UNPLAND_EFFORT4,
	EQPMT_ETC_EFFORT4,
	SUB_PRJ_ETC_COST4,
	SUB_PRJ_PPL_ETC_COST4,
	SUB_PRJ_EQPMT_ETC_COST4,
	SUB_PRJ_PPL_ETC_EFFORT4,
	SUB_PRJ_EQPMT_ETC_EFFORT4,
	EARNED_VALUE4,
	BAC_VALUE4,
	START_DATE5,
	START_DATE_OVERRIDE5,
	FINISH_DATE5,
	DURATION5,
	TASK_STATUS5,
	PROGRESS_STATUS_WEIGHT5,
	PROGRESS_OVERRIDE5,
	REMAINING_EFFORT5,
	PERCENT_COMPLETE5,
	PERCENT_OVERRIDE5,
	TASK_WEIGHT5,
	NUMBER_FIELD5,
	ROLLUP_NODE5,
	DIRTY_FLAG5,
	ETC_Cost5,
	PPL_ETC_COST5,
	EQPMT_ETC_COST5,
	PPL_UNPLAND_EFFORT5,
	EQPMT_ETC_EFFORT5,
	SUB_PRJ_ETC_COST5,
	SUB_PRJ_PPL_ETC_COST5,
	SUB_PRJ_EQPMT_ETC_COST5,
	SUB_PRJ_PPL_ETC_EFFORT5,
	SUB_PRJ_EQPMT_ETC_EFFORT5,
	EARNED_VALUE5,
	BAC_VALUE5,
	START_DATE6,
	START_DATE_OVERRIDE6,
	FINISH_DATE6,
	DURATION6,
	TASK_STATUS6,
	PROGRESS_STATUS_WEIGHT6,
	PROGRESS_OVERRIDE6,
	REMAINING_EFFORT6,
	PERCENT_COMPLETE6,
	PERCENT_OVERRIDE6,
	TASK_WEIGHT6,
	NUMBER_FIELD6,
	ROLLUP_NODE6,
	DIRTY_FLAG6,
	ETC_Cost6,
	PPL_ETC_COST6,
	EQPMT_ETC_COST6,
	PPL_UNPLAND_EFFORT6,
	EQPMT_ETC_EFFORT6,
	SUB_PRJ_ETC_COST6,
	SUB_PRJ_PPL_ETC_COST6,
	SUB_PRJ_EQPMT_ETC_COST6,
	SUB_PRJ_PPL_ETC_EFFORT6,
	SUB_PRJ_EQPMT_ETC_EFFORT6,
	EARNED_VALUE6,
	BAC_VALUE6,
	PERC_COMP_DERIVATIVE_CODE1,
	PERC_COMP_DERIVATIVE_CODE2,
	PERC_COMP_DERIVATIVE_CODE3,
	PERC_COMP_DERIVATIVE_CODE4,
	PERC_COMP_DERIVATIVE_CODE5,
	PERC_COMP_DERIVATIVE_CODE6,
	SUMMARY_OBJECT_FLAG -- 4370746
      FROM PA_PROJ_ROLLUP_BULK_TEMP
      WHERE PROCESS_NUMBER  = C_Process_Number
      order by Object_Type, Object_ID;

-- Bug 4218507 : Added Processed_Data_Structure_rollup
 CURSOR Processed_Data_Structure_rol(C_Process_Number NUMBER) IS
      SELECT
	OBJECT_TYPE,
	OBJECT_ID,
	PARENT_OBJECT_TYPE,
	PARENT_OBJECT_ID,
	CALENDAR_ID,
	CONSTRAINT_TYPE_CODE,
	CONSTRAINT_DATE,
	WBS_LEVEL,
	START_DATE1,
	START_DATE_OVERRIDE1,
	FINISH_DATE1,
	DURATION1,
	TASK_STATUS1,
	PROGRESS_STATUS_WEIGHT1,
	PROGRESS_OVERRIDE1,
	REMAINING_EFFORT1,
	PERCENT_COMPLETE1,
	PERCENT_OVERRIDE1,
	TASK_WEIGHT1,
	NUMBER_FIELD1,
	ROLLUP_NODE1,
	DIRTY_FLAG1,
	ETC_Cost1,
	PPL_ETC_COST1,
	EQPMT_ETC_COST1,
	PPL_UNPLAND_EFFORT1,
	EQPMT_ETC_EFFORT1,
	SUB_PRJ_ETC_COST1,
	SUB_PRJ_PPL_ETC_COST1,
	SUB_PRJ_EQPMT_ETC_COST1,
	SUB_PRJ_PPL_ETC_EFFORT1,
	SUB_PRJ_EQPMT_ETC_EFFORT1,
	EARNED_VALUE1,
	BAC_VALUE1,
	START_DATE2,
	START_DATE_OVERRIDE2,
	FINISH_DATE2,
	DURATION2,
	TASK_STATUS2,
	PROGRESS_STATUS_WEIGHT2,
	PROGRESS_OVERRIDE2,
	REMAINING_EFFORT2,
	PERCENT_COMPLETE2,
	PERCENT_OVERRIDE2,
	TASK_WEIGHT2,
	NUMBER_FIELD2,
	ROLLUP_NODE2,
	DIRTY_FLAG2,
	ETC_Cost2,
	PPL_ETC_COST2,
	EQPMT_ETC_COST2,
	PPL_UNPLAND_EFFORT2,
	EQPMT_ETC_EFFORT2,
	SUB_PRJ_ETC_COST2,
	SUB_PRJ_PPL_ETC_COST2,
	SUB_PRJ_EQPMT_ETC_COST2,
	SUB_PRJ_PPL_ETC_EFFORT2,
	SUB_PRJ_EQPMT_ETC_EFFORT2,
	EARNED_VALUE2,
	BAC_VALUE2,
	START_DATE3,
	START_DATE_OVERRIDE3,
	FINISH_DATE3,
	DURATION3,
	TASK_STATUS3,
	PROGRESS_STATUS_WEIGHT3,
	PROGRESS_OVERRIDE3,
	REMAINING_EFFORT3,
	PERCENT_COMPLETE3,
	PERCENT_OVERRIDE3,
	TASK_WEIGHT3,
	NUMBER_FIELD3,
	ROLLUP_NODE3,
	DIRTY_FLAG3,
	ETC_Cost3,
	PPL_ETC_COST3,
	EQPMT_ETC_COST3,
	PPL_UNPLAND_EFFORT3,
	EQPMT_ETC_EFFORT3,
	SUB_PRJ_ETC_COST3,
	SUB_PRJ_PPL_ETC_COST3,
	SUB_PRJ_EQPMT_ETC_COST3,
	SUB_PRJ_PPL_ETC_EFFORT3,
	SUB_PRJ_EQPMT_ETC_EFFORT3,
	EARNED_VALUE3,
	BAC_VALUE3,
	START_DATE4,
	START_DATE_OVERRIDE4,
	FINISH_DATE4,
	DURATION4,
	TASK_STATUS4,
	PROGRESS_STATUS_WEIGHT4,
	PROGRESS_OVERRIDE4,
	REMAINING_EFFORT4,
	PERCENT_COMPLETE4,
	PERCENT_OVERRIDE4,
	TASK_WEIGHT4,
	NUMBER_FIELD4,
	ROLLUP_NODE4,
	DIRTY_FLAG4,
	ETC_Cost4,
	PPL_ETC_COST4,
	EQPMT_ETC_COST4,
	PPL_UNPLAND_EFFORT4,
	EQPMT_ETC_EFFORT4,
	SUB_PRJ_ETC_COST4,
	SUB_PRJ_PPL_ETC_COST4,
	SUB_PRJ_EQPMT_ETC_COST4,
	SUB_PRJ_PPL_ETC_EFFORT4,
	SUB_PRJ_EQPMT_ETC_EFFORT4,
	EARNED_VALUE4,
	BAC_VALUE4,
	START_DATE5,
	START_DATE_OVERRIDE5,
	FINISH_DATE5,
	DURATION5,
	TASK_STATUS5,
	PROGRESS_STATUS_WEIGHT5,
	PROGRESS_OVERRIDE5,
	REMAINING_EFFORT5,
	PERCENT_COMPLETE5,
	PERCENT_OVERRIDE5,
	TASK_WEIGHT5,
	NUMBER_FIELD5,
	ROLLUP_NODE5,
	DIRTY_FLAG5,
	ETC_Cost5,
	PPL_ETC_COST5,
	EQPMT_ETC_COST5,
	PPL_UNPLAND_EFFORT5,
	EQPMT_ETC_EFFORT5,
	SUB_PRJ_ETC_COST5,
	SUB_PRJ_PPL_ETC_COST5,
	SUB_PRJ_EQPMT_ETC_COST5,
	SUB_PRJ_PPL_ETC_EFFORT5,
	SUB_PRJ_EQPMT_ETC_EFFORT5,
	EARNED_VALUE5,
	BAC_VALUE5,
	START_DATE6,
	START_DATE_OVERRIDE6,
	FINISH_DATE6,
	DURATION6,
	TASK_STATUS6,
	PROGRESS_STATUS_WEIGHT6,
	PROGRESS_OVERRIDE6,
	REMAINING_EFFORT6,
	PERCENT_COMPLETE6,
	PERCENT_OVERRIDE6,
	TASK_WEIGHT6,
	NUMBER_FIELD6,
	ROLLUP_NODE6,
	DIRTY_FLAG6,
	ETC_Cost6,
	PPL_ETC_COST6,
	EQPMT_ETC_COST6,
	PPL_UNPLAND_EFFORT6,
	EQPMT_ETC_EFFORT6,
	SUB_PRJ_ETC_COST6,
	SUB_PRJ_PPL_ETC_COST6,
	SUB_PRJ_EQPMT_ETC_COST6,
	SUB_PRJ_PPL_ETC_EFFORT6,
	SUB_PRJ_EQPMT_ETC_EFFORT6,
	EARNED_VALUE6,
	BAC_VALUE6,
	PERC_COMP_DERIVATIVE_CODE1,
	PERC_COMP_DERIVATIVE_CODE2,
	PERC_COMP_DERIVATIVE_CODE3,
	PERC_COMP_DERIVATIVE_CODE4,
	PERC_COMP_DERIVATIVE_CODE5,
	PERC_COMP_DERIVATIVE_CODE6,
	SUMMARY_OBJECT_FLAG -- 4370746
      FROM PA_PROJ_ROLLUP_BULK_TEMP
      WHERE PROCESS_NUMBER  = C_Process_Number
      order by calendar_id;

CURSOR lowest_dirty_object_list_dates IS
SELECT object_id, object_type, start_date1, start_date2, start_date3,
       start_date4, start_date5, start_date6, finish_date1,finish_date2, finish_date3,
       finish_date4, finish_date5, finish_date6, duration1, duration2, duration3, duration4,
       duration5, duration6, dirty_flag1, dirty_flag2, dirty_flag3, dirty_flag4, dirty_flag5, dirty_flag6
       , 'N', 'N', 'N', 'N', 'N', 'N'
       FROM   PA_PROJ_ROLLUP_BULK_TEMP t1
       WHERE  PROCESS_NUMBER  = l_process_number
       -- 4218507 : This could be made dependenct on dirty_flag1='Y' only. Not sure whethere this will improve performance
       AND    (dirty_flag1='Y' OR dirty_flag2='Y' OR dirty_flag3='Y' OR dirty_flag4='Y' OR dirty_flag5='Y'
               OR dirty_flag6='Y')
       AND    Not Exists (select * from PA_PROJ_ROLLUP_BULK_TEMP t2
		where t2.PROCESS_NUMBER = l_process_number
		and t2.parent_object_id = t1.object_id
		AND ROWNUM < 2);

CURSOR dirty_Parent_List (c_object_ID NUMBER ) IS
SELECT object_id, object_type, start_date1, start_date2, start_date3,
       start_date4, start_date5, start_date6, finish_date1,finish_date2, finish_date3,
       finish_date4, finish_date5, finish_date6, duration1, duration2, duration3, duration4,
       duration5, duration6, dirty_flag1, dirty_flag2, dirty_flag3, dirty_flag4, dirty_flag5, dirty_flag6,
       start_date_override1, start_date_override2, start_date_override3, start_date_override4,
       start_date_override5, start_date_override6
	  FROM   PA_PROJ_ROLLUP_BULK_TEMP
	  WHERE  PROCESS_NUMBER   = l_process_number
       -- 4218507 : This could be made dependent on dirty_flag1=Y only
	  AND    (dirty_flag1='Y' OR dirty_flag2='Y' OR dirty_flag3='Y' OR dirty_flag4='Y' OR dirty_flag5='Y' OR
                 dirty_flag6='Y')
	  AND object_id <> c_object_id
	  START  WITH object_id   = c_object_ID
	    CONNECT BY object_id  = PRIOR parent_object_id
order by wbs_level desc;


CURSOR Parent_Objects_List_Effort IS
SELECT object_id, object_type,REMAINING_EFFORT1,REMAINING_EFFORT2, REMAINING_EFFORT3, REMAINING_EFFORT4
, REMAINING_EFFORT5, REMAINING_EFFORT6
FROM   PA_PROJ_ROLLUP_BULK_TEMP t1
WHERE  process_number = l_process_number
AND OBJECT_TYPE <> 'PA_DELIVERABLES'
AND Exists (SELECT * from PA_PROJ_ROLLUP_BULK_TEMP t2
	  WHERE t2.OBJECT_TYPE <> 'PA_DELIVERABLES'
	  AND t2.parent_object_id = t1.object_id
          AND t2.parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
	  AND process_number = l_process_number
	  AND ROWNUM < 2)
Order By WBS_LEVEL DESC;

-- 4366733 : Deliverable Progress Status should not rollup
CURSOR Parent_Objects_List_prog_sts IS
SELECT Object_ID, object_type, PROGRESS_STATUS_WEIGHT1, PROGRESS_STATUS_WEIGHT2, PROGRESS_STATUS_WEIGHT3
, PROGRESS_STATUS_WEIGHT4, PROGRESS_STATUS_WEIGHT5, PROGRESS_STATUS_WEIGHT6
FROM   PA_PROJ_ROLLUP_BULK_TEMP t1
--WHERE  OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES', 'PA_DELIVERABLES')
WHERE  OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES')
AND process_number = l_process_number
AND Exists (Select * From PA_PROJ_ROLLUP_BULK_TEMP t2
--	 Where t2.OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES', 'PA_DELIVERABLES', 'PA_SUBPROJECTS')
	 Where t2.OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES', 'PA_SUBPROJECTS')
	  AND t2.parent_object_id = t1.object_id
          AND t2.parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
	  AND process_number = l_process_number
	  AND ROWNUM < 2)
Order By WBS_LEVEL DESC;


CURSOR parent_objects_list_task_sts IS
SELECT object_id, object_type, task_status1, task_status2, task_status3, task_status4, task_status5, task_status6
FROM PA_PROJ_ROLLUP_BULK_TEMP t1
WHERE PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE <> 'PA_ASSIGNMENTS'
      AND Exists (Select * From PA_PROJ_ROLLUP_BULK_TEMP t2
		Where t2.PROCESS_NUMBER = l_process_number
      		AND OBJECT_TYPE <> 'PA_ASSIGNMENTS'
		AND t2.parent_object_id = t1.object_id
                AND t2.parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
		AND RowNum < 2)
Order By WBS_LEVEL DESC;

CURSOR Child_Task_Status_partial(p_parent_id NUMBER) IS
SELECT decode(rollup_node1, 'Y', TASK_STATUS1, -1)
      , decode(rollup_node2, 'Y', TASK_STATUS2, -1)
      , decode(rollup_node3, 'Y', TASK_STATUS3, -1)
      , decode(rollup_node4, 'Y', TASK_STATUS4, -1)
      , decode(rollup_node5, 'Y', TASK_STATUS5, -1)
      , decode(rollup_node6, 'Y', TASK_STATUS6, -1)
FROM PA_PROJ_ROLLUP_BULK_TEMP
WHERE PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE <> 'PA_ASSIGNMENTS'
AND parent_object_id = p_parent_id
AND parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
;

CURSOR Child_Task_Status_full(p_parent_id NUMBER) IS
SELECT TASK_STATUS1, TASK_STATUS2, TASK_STATUS3, TASK_STATUS4, TASK_STATUS5, TASK_STATUS6
FROM PA_PROJ_ROLLUP_BULK_TEMP
WHERE PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE <> 'PA_ASSIGNMENTS'
AND parent_object_id = p_parent_id
AND parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
;

-- Perc_Comp_Derivative_Code1 serves purpose for all 6 sets
CURSOR lowest_tasks_per_comp IS
SELECT object_id, OBJECT_TYPE, Perc_Comp_Derivative_Code1, BAC_VALUE1, BAC_VALUE2, BAC_VALUE3, BAC_VALUE4,
BAC_VALUE5, BAC_VALUE6, PERCENT_COMPLETE1, PERCENT_COMPLETE2, PERCENT_COMPLETE3,
PERCENT_COMPLETE4, PERCENT_COMPLETE5, PERCENT_COMPLETE6, PERCENT_OVERRIDE1, PERCENT_OVERRIDE2,
PERCENT_OVERRIDE3, PERCENT_OVERRIDE4, PERCENT_OVERRIDE5, PERCENT_OVERRIDE6, EARNED_VALUE1, EARNED_VALUE2
, EARNED_VALUE3, EARNED_VALUE4, EARNED_VALUE5, EARNED_VALUE6
FROM PA_PROJ_ROLLUP_BULK_TEMP t1
WHERE PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES')
AND nvl(SUMMARY_OBJECT_FLAG, 'N') NOT IN ('Y', 'L') -- 4370746 -- 4586449 : Added 'L'
AND not Exists (Select * From PA_PROJ_ROLLUP_BULK_TEMP t2
		  Where t2.PROCESS_NUMBER = l_process_number
      		  AND t2.OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES')
		  And t2.parent_object_id = t1.object_id
                  AND t2.parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
		  AND ROWNUM < 2);

CURSOR parent_objects_list_per_comp IS
SELECT object_id, OBJECT_TYPE, Perc_Comp_Derivative_Code1, BAC_VALUE1, BAC_VALUE2, BAC_VALUE3, BAC_VALUE4,
BAC_VALUE5, BAC_VALUE6, PERCENT_COMPLETE1, PERCENT_COMPLETE2, PERCENT_COMPLETE3,
PERCENT_COMPLETE4, PERCENT_COMPLETE5, PERCENT_COMPLETE6, PERCENT_OVERRIDE1, PERCENT_OVERRIDE2,
PERCENT_OVERRIDE3, PERCENT_OVERRIDE4, PERCENT_OVERRIDE5, PERCENT_OVERRIDE6, EARNED_VALUE1, EARNED_VALUE2
, EARNED_VALUE3, EARNED_VALUE4, EARNED_VALUE5, EARNED_VALUE6
, summary_object_flag -- 4587517
FROM PA_PROJ_ROLLUP_BULK_TEMP t1
WHERE PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES')
-- 4530036 : SUMMARY_OBJECT_FLAG is added so that
-- earned value gets recalculated even if no childs are passed to summary level
AND( nvl(SUMMARY_OBJECT_FLAG, 'N') IN ('Y','L') -- 4586449 : Added 'L'
OR Exists (Select * From PA_PROJ_ROLLUP_BULK_TEMP t2
		  Where t2.PROCESS_NUMBER = l_process_number
      		  AND t2.OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES')
		  And t2.parent_object_id = t1.object_id
                  AND t2.parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
		  AND ROWNUM < 2)
   )
Order By WBS_LEVEL DESC;

CURSOR Parent_Objects_List_ETC_COST IS
SELECT object_id, object_type, ETC_Cost1, ETC_Cost2, ETC_Cost3, ETC_Cost4, ETC_Cost5, ETC_Cost6
, PPL_ETC_COST1, PPL_ETC_COST2, PPL_ETC_COST3, PPL_ETC_COST4, PPL_ETC_COST5, PPL_ETC_COST6
, EQPMT_ETC_COST1, EQPMT_ETC_COST2, EQPMT_ETC_COST3, EQPMT_ETC_COST4, EQPMT_ETC_COST5, EQPMT_ETC_COST6
, PPL_UNPLAND_EFFORT1, PPL_UNPLAND_EFFORT2, PPL_UNPLAND_EFFORT3, PPL_UNPLAND_EFFORT4, PPL_UNPLAND_EFFORT5, PPL_UNPLAND_EFFORT6
, EQPMT_ETC_EFFORT1, EQPMT_ETC_EFFORT2, EQPMT_ETC_EFFORT3, EQPMT_ETC_EFFORT4, EQPMT_ETC_EFFORT5, EQPMT_ETC_EFFORT6
, SUB_PRJ_ETC_COST1, SUB_PRJ_ETC_COST2, SUB_PRJ_ETC_COST3, SUB_PRJ_ETC_COST4, SUB_PRJ_ETC_COST5, SUB_PRJ_ETC_COST6
, SUB_PRJ_PPL_ETC_COST1, SUB_PRJ_PPL_ETC_COST2, SUB_PRJ_PPL_ETC_COST3, SUB_PRJ_PPL_ETC_COST4, SUB_PRJ_PPL_ETC_COST5, SUB_PRJ_PPL_ETC_COST6
, SUB_PRJ_EQPMT_ETC_COST1, SUB_PRJ_EQPMT_ETC_COST2, SUB_PRJ_EQPMT_ETC_COST3, SUB_PRJ_EQPMT_ETC_COST4, SUB_PRJ_EQPMT_ETC_COST5, SUB_PRJ_EQPMT_ETC_COST6
, SUB_PRJ_PPL_ETC_EFFORT1, SUB_PRJ_PPL_ETC_EFFORT2, SUB_PRJ_PPL_ETC_EFFORT3, SUB_PRJ_PPL_ETC_EFFORT4, SUB_PRJ_PPL_ETC_EFFORT5, SUB_PRJ_PPL_ETC_EFFORT6
, SUB_PRJ_EQPMT_ETC_EFFORT1, SUB_PRJ_EQPMT_ETC_EFFORT2, SUB_PRJ_EQPMT_ETC_EFFORT3, SUB_PRJ_EQPMT_ETC_EFFORT4, SUB_PRJ_EQPMT_ETC_EFFORT5, SUB_PRJ_EQPMT_ETC_EFFORT6
, REMAINING_EFFORT1, REMAINING_EFFORT2, REMAINING_EFFORT3, REMAINING_EFFORT4, REMAINING_EFFORT5, REMAINING_EFFORT6
FROM   PA_PROJ_ROLLUP_BULK_TEMP t1
WHERE  PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE NOT IN ( 'PA_DELIVERABLES',  'PA_ASSIGNMENTS', 'PA_SUBPROJECTS')
AND Exists (SELECT * from PA_PROJ_ROLLUP_BULK_TEMP t2
	  WHERE t2.PROCESS_NUMBER = l_process_number
	  AND t2.OBJECT_TYPE <> 'PA_DELIVERABLES'
	  AND t2.parent_object_id = t1.object_id
          AND t2.parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
	  AND ROWNUM < 2)
Order By WBS_LEVEL DESC;

CURSOR all_dirty_object_list_summary IS
SELECT object_id, object_type, dirty_flag1, dirty_flag2, dirty_flag3, dirty_flag4, dirty_flag5, dirty_flag6
FROM PA_PROJ_ROLLUP_BULK_TEMP t1
WHERE PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE <> 'PA_DELIVERABLES'
AND (Dirty_flag1 ='Y' OR Dirty_flag2 ='Y' OR Dirty_flag3 ='Y' OR Dirty_flag4 ='Y' OR Dirty_flag5 ='Y'
	OR Dirty_flag6 ='Y')
AND Exists (select 1 from PA_PROJ_ROLLUP_BULK_TEMP t2
	  where t2.PROCESS_NUMBER = l_process_number
	  and t2.OBJECT_TYPE <> 'PA_DELIVERABLES'
	  and t2.parent_object_id = t1.object_id
	  AND ROWNUM < 2
	      );

--Bug 5942861. Modified the Cursor so that Connect by and Order by on done on different sets of data.
CURSOR all_Parent_Dirty_Object_List(c_object_id NUMBER, c_dirty_flag1 VARCHAR2, c_dirty_flag2 VARCHAR2
    , c_dirty_flag3 VARCHAR2, c_dirty_flag4 VARCHAR2, c_dirty_flag5 VARCHAR2, c_dirty_flag6 VARCHAR2) IS
SELECT t.Object_ID, t.object_type, t.dirty_flag1, t.dirty_flag2, t.dirty_flag3
     , t.dirty_flag4, t.dirty_flag5, t.dirty_flag6, c_dirty_flag1 ref_dirty_flag1
     , c_dirty_flag2 ref_dirty_flag2, c_dirty_flag3 ref_dirty_flag3, c_dirty_flag4 ref_dirty_flag4
     , c_dirty_flag5 ref_dirty_flag5, c_dirty_flag6 ref_dirty_flag6
FROM
   (SELECT t2.Object_ID, t2.object_type, t2.dirty_flag1, t2.dirty_flag2, t2.dirty_flag3
         , t2.dirty_flag4, t2.dirty_flag5, t2.dirty_flag6,t2.wbs_level order_by_clause
FROM PA_PROJ_ROLLUP_BULK_TEMP T2
WHERE T2.PROCESS_NUMBER = l_process_number
AND T2.Object_ID <> c_object_id
START WITH T2.PROCESS_NUMBER = l_process_number
AND        T2.Object_ID = c_object_id
CONNECT BY T2.PROCESS_NUMBER = l_process_number
AND        T2.Parent_Object_ID = PRIOR T2.Object_ID) t
order by order_by_clause desc;

CURSOR all_dirty_object_list_lowest IS
SELECT object_id, object_type, dirty_flag1, dirty_flag2, dirty_flag3, dirty_flag4, dirty_flag5, dirty_flag6
FROM PA_PROJ_ROLLUP_BULK_TEMP t1
WHERE PROCESS_NUMBER = l_process_number
AND OBJECT_TYPE <> 'PA_DELIVERABLES'
AND (Dirty_flag1 ='Y' OR Dirty_flag2 ='Y' OR Dirty_flag3 ='Y' OR Dirty_flag4 ='Y' OR Dirty_flag5 ='Y'
	OR Dirty_flag6 ='Y')
AND NOT Exists (select 1 from PA_PROJ_ROLLUP_BULK_TEMP t2
	  where t2.PROCESS_NUMBER = l_process_number
	  and t2.OBJECT_TYPE <> 'PA_DELIVERABLES'
	  and t2.parent_object_id = t1.object_id
	  AND ROWNUM < 2
	      );

--Bug 5942861. Modified the Cursor so that Connect by and Order by on done on different sets of data.
CURSOR all_child_Dirty_Object_List(c_object_id NUMBER, c_dirty_flag1 VARCHAR2, c_dirty_flag2 VARCHAR2
    , c_dirty_flag3 VARCHAR2, c_dirty_flag4 VARCHAR2, c_dirty_flag5 VARCHAR2, c_dirty_flag6 VARCHAR2) IS
SELECT t.Object_ID, t.object_type, t.dirty_flag1, t.dirty_flag2, t.dirty_flag3
     , t.dirty_flag4, t.dirty_flag5, t.dirty_flag6, c_dirty_flag1 ref_dirty_flag1
     , c_dirty_flag2 ref_dirty_flag2, c_dirty_flag3 ref_dirty_flag3, c_dirty_flag4 ref_dirty_flag4
     , c_dirty_flag5 ref_dirty_flag5, c_dirty_flag6 ref_dirty_flag6
FROM
(   SELECT t2.Object_ID, t2.object_type, t2.dirty_flag1, t2.dirty_flag2, t2.dirty_flag3
         , t2.dirty_flag4, t2.dirty_flag5, t2.dirty_flag6, t2.wbs_level order_by_clause
FROM PA_PROJ_ROLLUP_BULK_TEMP T2
WHERE T2.PROCESS_NUMBER = l_process_number
AND T2.Object_ID <> c_object_id
START WITH T2.PROCESS_NUMBER = l_process_number
AND        T2.Object_ID = c_object_id
CONNECT BY T2.PROCESS_NUMBER = l_process_number
AND        T2.Object_ID = PRIOR T2.Parent_Object_ID) t
order by t.order_by_clause asc;


CURSOR dirty_all_List IS
SELECT object_id, object_type, start_date1, start_date2, start_date3,
       start_date4, start_date5, start_date6, finish_date1,finish_date2, finish_date3,
       finish_date4, finish_date5, finish_date6, duration1, duration2, duration3, duration4,
       duration5, duration6, dirty_flag1, dirty_flag2, dirty_flag3, dirty_flag4, dirty_flag5, dirty_flag6,
       start_date_override1, start_date_override2, start_date_override3, start_date_override4,
       start_date_override5, start_date_override6, 'N', 'N', 'N', 'N', 'N', 'N' , 'N', 'N', 'N', 'N', 'N', 'N'
	  FROM   PA_PROJ_ROLLUP_BULK_TEMP
	  WHERE  PROCESS_NUMBER   = l_process_number
	  AND    (dirty_flag1='Y' OR dirty_flag2='Y' OR dirty_flag3='Y' OR dirty_flag4='Y' OR dirty_flag5='Y' OR
                 dirty_flag6='Y')
order by wbs_level desc;

BEGIN
        g1_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');
	IF(p_debug_mode = 'Y') and  g1_debug_mode  = 'Y' THEN
		PA_DEBUG.init_err_stack('PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE');
	END IF;

	-- Initialize the return status to success

	X_Return_Status := FND_API.G_RET_STS_SUCCESS;

	l_msg_count := 0;
	x_msg_data := ' ';

	SAVEPOINT GENERATE_SCHEDULE_SP;

	-- Derive the next Process Number
	SELECT PA_PROJ_ROLLUP_BULK_TEMP_S.nextval
	INTO   l_Process_Number FROM dual;

	x_Process_Number := l_Process_Number;

	l_data_count := P_Data_Structure.COUNT;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Start', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'l_data_count='||l_data_count, x_Log_Level=> 3);
        END IF;


	IF l_data_count <= 0 THEN
		return;
	END IF;

	IF (p_partial_dates_flag1       = 'Y') OR
	(p_partial_task_status_flag1 = 'Y') OR
	(p_partial_progress_flag1    = 'Y') OR
	(p_partial_effort_flag1      = 'Y') OR
	(p_partial_percent_flag1     = 'Y')
	THEN
		l_partial_rollup1 := TRUE;
	ELSE
		l_partial_rollup1 := FALSE;
	END IF;

	IF (p_partial_dates_flag2       = 'Y') OR
	(p_partial_task_status_flag2 = 'Y') OR
	(p_partial_progress_flag2    = 'Y') OR
	(p_partial_effort_flag2      = 'Y') OR
	(p_partial_percent_flag2     = 'Y')
	THEN
		l_partial_rollup2 := TRUE;
	ELSE
		l_partial_rollup2 := FALSE;
	END IF;

	IF (p_partial_dates_flag3       = 'Y') OR
	(p_partial_task_status_flag3 = 'Y') OR
	(p_partial_progress_flag3    = 'Y') OR
	(p_partial_effort_flag3      = 'Y') OR
	(p_partial_percent_flag3     = 'Y')
	THEN
		l_partial_rollup3 := TRUE;
	ELSE
		l_partial_rollup3 := FALSE;
	END IF;

	IF (p_partial_dates_flag4       = 'Y') OR
	(p_partial_task_status_flag4 = 'Y') OR
	(p_partial_progress_flag4    = 'Y') OR
	(p_partial_effort_flag4      = 'Y') OR
	(p_partial_percent_flag4     = 'Y')
	THEN
		l_partial_rollup4 := TRUE;
	ELSE
		l_partial_rollup4 := FALSE;
	END IF;

	IF (p_partial_dates_flag5       = 'Y') OR
	(p_partial_task_status_flag5 = 'Y') OR
	(p_partial_progress_flag5    = 'Y') OR
	(p_partial_effort_flag5      = 'Y') OR
	(p_partial_percent_flag5     = 'Y')
	THEN
		l_partial_rollup5 := TRUE;
	ELSE
		l_partial_rollup5 := FALSE;
	END IF;

	IF (p_partial_dates_flag6       = 'Y') OR
	(p_partial_task_status_flag6 = 'Y') OR
	(p_partial_progress_flag6    = 'Y') OR
	(p_partial_effort_flag6      = 'Y') OR
	(p_partial_percent_flag6     = 'Y')
	THEN
		l_partial_rollup6 := TRUE;
	ELSE
		l_partial_rollup6 := FALSE;
	END IF;

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After deriving partial rollup flags', x_Log_Level=> 3);
        END IF;



	FOR i IN 1..P_Data_Structure.COUNT LOOP
		l_OBJECT_TYPE(i)  		:= p_data_structure(i).OBJECT_TYPE;
		l_OBJECT_ID(i)  		:= p_data_structure(i).OBJECT_ID;
		l_PARENT_OBJECT_TYPE(i) 	:= p_data_structure(i).PARENT_OBJECT_TYPE;
		l_PARENT_OBJECT_ID(i)  		:= p_data_structure(i).PARENT_OBJECT_ID;
		l_CALENDAR_ID(i)  		:= p_data_structure(i).CALENDAR_ID;
		l_CONSTRAINT_TYPE_CODE(i)  	:= p_data_structure(i).CONSTRAINT_TYPE_CODE;
		l_CONSTRAINT_DATE(i)  		:= p_data_structure(i).CONSTRAINT_DATE;
		l_WBS_LEVEL(i)  		:= p_data_structure(i).WBS_LEVEL;
		l_SUMMARY_OBJECT_FLAG(i) 	:= p_data_structure(i).SUMMARY_OBJECT_FLAG; --4370746

		l_START_DATE1(i)  		:= p_data_structure(i).START_DATE1;
		l_START_DATE_OVERRIDE1(i)  	:= p_data_structure(i).START_DATE_OVERRIDE1;
		l_FINISH_DATE1(i)  		:= p_data_structure(i).FINISH_DATE1;
		l_DURATION1(i)  		:= p_data_structure(i).DURATION1;
		l_TASK_STATUS1(i)  		:= p_data_structure(i).TASK_STATUS1;
		l_PROGRESS_STATUS_WEIGHT1(i)  	:= p_data_structure(i).PROGRESS_STATUS_WEIGHT1;
		l_PROGRESS_OVERRIDE1(i) 	:= p_data_structure(i).PROGRESS_OVERRIDE1;
		l_REMAINING_EFFORT1(i)  	:= p_data_structure(i).REMAINING_EFFORT1;
		l_PERCENT_COMPLETE1(i)  	:= p_data_structure(i).PERCENT_COMPLETE1;
		l_PERCENT_OVERRIDE1(i)  	:= p_data_structure(i).PERCENT_OVERRIDE1;
		l_TASK_WEIGHT1(i)  		:= p_data_structure(i).TASK_WEIGHT1;
		l_NUMBER_FIELD1(i)  		:= p_data_structure(i).NUMBER_FIELD1;
		l_Etc_Cost1(i)			:= p_data_structure(i).ETC_COST1;
		l_PPL_ETC_Cost1(i)		:= p_data_structure(i).PPL_ETC_Cost1;
		l_EQPMT_ETC_COST1(i)		:= p_data_structure(i).EQPMT_ETC_COST1;
		l_PPL_UNPLAND_EFFORT1(i)	:= p_data_structure(i).PPL_UNPLAND_EFFORT1;
		l_EQPMT_ETC_EFFORT1(i)		:= p_data_structure(i).EQPMT_ETC_EFFORT1;
		l_SUB_PRJ_ETC_COST1(i)		:= p_data_structure(i).SUB_PRJ_ETC_COST1;
		l_SUB_PRJ_PPL_ETC_COST1(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_COST1;
		l_SUB_PRJ_EQPMT_ETC_COST1(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_COST1;
		l_SUB_PRJ_PPL_ETC_EFFORT1(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_EFFORT1;
		l_SUB_PRJ_EQPMT_ETC_EFFORT1(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_EFFORT1;
		l_EARNED_VALUE1(i)		:= p_data_structure(i).EARNED_VALUE1;
		l_BAC_VALUE1(i)			:= p_data_structure(i).BAC_VALUE1;
		l_Perc_Comp_Deriv_Code1(i) 	:= p_data_structure(i).PERC_COMP_DERIVATIVE_CODE1;

		IF(l_partial_rollup1) Then
			IF(p_data_structure(i).ROLLUP_NODE1 = 'N') THEN
				l_ROLLUP_NODE1(i)  := 'N';
			ELSE
				l_ROLLUP_NODE1(i)  := 'Y';
			END IF;
		ELSE
			l_ROLLUP_NODE1(i)  := 'Y';
		END IF;

		IF(p_partial_process_flag1 = 'Y') Then
			l_DIRTY_FLAG1(i)  := p_data_structure(i).DIRTY_FLAG1;
		ELSE
			l_DIRTY_FLAG1(i)  := 'Y';
		END IF;

		IF p_process_flag1 <> 'Y' THEN
			l_DIRTY_FLAG1(i)  := null;
			l_ROLLUP_NODE1(i)  := null;
		END IF;

		l_START_DATE2(i)  		:= p_data_structure(i).START_DATE2;
		l_START_DATE_OVERRIDE2(i)  	:= p_data_structure(i).START_DATE_OVERRIDE2;
		l_FINISH_DATE2(i)  		:= p_data_structure(i).FINISH_DATE2;
		l_DURATION2(i)  		:= p_data_structure(i).DURATION2;
		l_TASK_STATUS2(i)  		:= p_data_structure(i).TASK_STATUS2;
		l_PROGRESS_STATUS_WEIGHT2(i)  	:= p_data_structure(i).PROGRESS_STATUS_WEIGHT2;
		l_PROGRESS_OVERRIDE2(i) 	:= p_data_structure(i).PROGRESS_OVERRIDE2;
		l_REMAINING_EFFORT2(i)  	:= p_data_structure(i).REMAINING_EFFORT2;
		l_PERCENT_COMPLETE2(i)  	:= p_data_structure(i).PERCENT_COMPLETE2;
		l_PERCENT_OVERRIDE2(i)  	:= p_data_structure(i).PERCENT_OVERRIDE2;
		l_TASK_WEIGHT2(i)  		:= p_data_structure(i).TASK_WEIGHT2;
		l_NUMBER_FIELD2(i)  		:= p_data_structure(i).NUMBER_FIELD2;
		l_Etc_Cost2(i)			:= p_data_structure(i).ETC_COST2;
		l_PPL_ETC_Cost2(i)		:= p_data_structure(i).PPL_ETC_Cost2;
		l_EQPMT_ETC_COST2(i)		:= p_data_structure(i).EQPMT_ETC_COST2;
		l_PPL_UNPLAND_EFFORT2(i)	:= p_data_structure(i).PPL_UNPLAND_EFFORT2;
		l_EQPMT_ETC_EFFORT2(i)		:= p_data_structure(i).EQPMT_ETC_EFFORT2;
		l_SUB_PRJ_ETC_COST2(i)		:= p_data_structure(i).SUB_PRJ_ETC_COST2;
		l_SUB_PRJ_PPL_ETC_COST2(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_COST2;
		l_SUB_PRJ_EQPMT_ETC_COST2(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_COST2;
		l_SUB_PRJ_PPL_ETC_EFFORT2(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_EFFORT2;
		l_SUB_PRJ_EQPMT_ETC_EFFORT2(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_EFFORT2;
		l_EARNED_VALUE2(i)		:= p_data_structure(i).EARNED_VALUE2;
		l_BAC_VALUE2(i)			:= p_data_structure(i).BAC_VALUE2;
		l_Perc_Comp_Deriv_Code2(i) 	:= p_data_structure(i).PERC_COMP_DERIVATIVE_CODE2;

		IF(l_partial_rollup2) Then
			IF(p_data_structure(i).ROLLUP_NODE2 = 'N') THEN
				l_ROLLUP_NODE2(i)  := 'N';
			ELSE
				l_ROLLUP_NODE2(i)  := 'Y';
			END IF;
		ELSE
			l_ROLLUP_NODE2(i)  := 'Y';
		END IF;

		IF(p_partial_process_flag2 = 'Y') Then
			l_DIRTY_FLAG2(i)  := p_data_structure(i).DIRTY_FLAG2;
		ELSE
			l_DIRTY_FLAG2(i)  := 'Y';
		END IF;

		IF p_process_flag2 <> 'Y' THEN
			l_DIRTY_FLAG2(i)  := null;
			l_ROLLUP_NODE2(i)  := null;
		END IF;


		l_START_DATE3(i)  		:= p_data_structure(i).START_DATE3;
		l_START_DATE_OVERRIDE3(i)  	:= p_data_structure(i).START_DATE_OVERRIDE3;
		l_FINISH_DATE3(i)  		:= p_data_structure(i).FINISH_DATE3;
		l_DURATION3(i)  		:= p_data_structure(i).DURATION3;
		l_TASK_STATUS3(i)  		:= p_data_structure(i).TASK_STATUS3;
		l_PROGRESS_STATUS_WEIGHT3(i)  	:= p_data_structure(i).PROGRESS_STATUS_WEIGHT3;
		l_PROGRESS_OVERRIDE3(i) 	:= p_data_structure(i).PROGRESS_OVERRIDE3;
		l_REMAINING_EFFORT3(i)  	:= p_data_structure(i).REMAINING_EFFORT3;
		l_PERCENT_COMPLETE3(i)  	:= p_data_structure(i).PERCENT_COMPLETE3;
		l_PERCENT_OVERRIDE3(i)  	:= p_data_structure(i).PERCENT_OVERRIDE3;
		l_TASK_WEIGHT3(i)  		:= p_data_structure(i).TASK_WEIGHT3;
		l_NUMBER_FIELD3(i)  		:= p_data_structure(i).NUMBER_FIELD3;
		l_Etc_Cost3(i)			:= p_data_structure(i).ETC_COST3;
		l_PPL_ETC_Cost3(i)		:= p_data_structure(i).PPL_ETC_Cost3;
		l_EQPMT_ETC_COST3(i)		:= p_data_structure(i).EQPMT_ETC_COST3;
		l_PPL_UNPLAND_EFFORT3(i)	:= p_data_structure(i).PPL_UNPLAND_EFFORT3;
		l_EQPMT_ETC_EFFORT3(i)		:= p_data_structure(i).EQPMT_ETC_EFFORT3;
		l_SUB_PRJ_ETC_COST3(i)		:= p_data_structure(i).SUB_PRJ_ETC_COST3;
		l_SUB_PRJ_PPL_ETC_COST3(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_COST3;
		l_SUB_PRJ_EQPMT_ETC_COST3(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_COST3;
		l_SUB_PRJ_PPL_ETC_EFFORT3(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_EFFORT3;
		l_SUB_PRJ_EQPMT_ETC_EFFORT3(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_EFFORT3;
		l_EARNED_VALUE3(i)		:= p_data_structure(i).EARNED_VALUE3;
		l_BAC_VALUE3(i)			:= p_data_structure(i).BAC_VALUE3;
		l_Perc_Comp_Deriv_Code3(i) 	:= p_data_structure(i).PERC_COMP_DERIVATIVE_CODE3;

		IF(l_partial_rollup3) Then
			IF(p_data_structure(i).ROLLUP_NODE3 = 'N') THEN
				l_ROLLUP_NODE3(i)  := 'N';
			ELSE
				l_ROLLUP_NODE3(i)  := 'Y';
			END IF;
		ELSE
			l_ROLLUP_NODE3(i)  := 'Y';
		END IF;

		IF(p_partial_process_flag3 = 'Y') Then
			l_DIRTY_FLAG3(i)  := p_data_structure(i).DIRTY_FLAG3;
		ELSE
			l_DIRTY_FLAG3(i)  := 'Y';
		END IF;

		IF p_process_flag3 <> 'Y' THEN
			l_DIRTY_FLAG3(i)  := null;
			l_ROLLUP_NODE3(i)  := null;
		END IF;


		l_START_DATE4(i)  		:= p_data_structure(i).START_DATE4;
		l_START_DATE_OVERRIDE4(i)  	:= p_data_structure(i).START_DATE_OVERRIDE4;
		l_FINISH_DATE4(i)  		:= p_data_structure(i).FINISH_DATE4;
		l_DURATION4(i)  		:= p_data_structure(i).DURATION4;
		l_TASK_STATUS4(i)  		:= p_data_structure(i).TASK_STATUS4;
		l_PROGRESS_STATUS_WEIGHT4(i)  	:= p_data_structure(i).PROGRESS_STATUS_WEIGHT4;
		l_PROGRESS_OVERRIDE4(i) 	:= p_data_structure(i).PROGRESS_OVERRIDE4;
		l_REMAINING_EFFORT4(i)  	:= p_data_structure(i).REMAINING_EFFORT4;
		l_PERCENT_COMPLETE4(i)  	:= p_data_structure(i).PERCENT_COMPLETE4;
		l_PERCENT_OVERRIDE4(i)  	:= p_data_structure(i).PERCENT_OVERRIDE4;
		l_TASK_WEIGHT4(i)  		:= p_data_structure(i).TASK_WEIGHT4;
		l_NUMBER_FIELD4(i)  		:= p_data_structure(i).NUMBER_FIELD4;
		l_Etc_Cost4(i)			:= p_data_structure(i).ETC_COST4;
		l_PPL_ETC_Cost4(i)		:= p_data_structure(i).PPL_ETC_Cost4;
		l_EQPMT_ETC_COST4(i)		:= p_data_structure(i).EQPMT_ETC_COST4;
		l_PPL_UNPLAND_EFFORT4(i)	:= p_data_structure(i).PPL_UNPLAND_EFFORT4;
		l_EQPMT_ETC_EFFORT4(i)		:= p_data_structure(i).EQPMT_ETC_EFFORT4;
		l_SUB_PRJ_ETC_COST4(i)		:= p_data_structure(i).SUB_PRJ_ETC_COST4;
		l_SUB_PRJ_PPL_ETC_COST4(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_COST4;
		l_SUB_PRJ_EQPMT_ETC_COST4(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_COST4;
		l_SUB_PRJ_PPL_ETC_EFFORT4(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_EFFORT4;
		l_SUB_PRJ_EQPMT_ETC_EFFORT4(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_EFFORT4;
		l_EARNED_VALUE4(i)		:= p_data_structure(i).EARNED_VALUE4;
		l_BAC_VALUE4(i)			:= p_data_structure(i).BAC_VALUE4;
		l_Perc_Comp_Deriv_Code4(i) 	:= p_data_structure(i).PERC_COMP_DERIVATIVE_CODE4;

		IF(l_partial_rollup4) Then
			IF(p_data_structure(i).ROLLUP_NODE4 = 'N') THEN
				l_ROLLUP_NODE4(i)  := 'N';
			ELSE
				l_ROLLUP_NODE4(i)  := 'Y';
			END IF;
		ELSE
			l_ROLLUP_NODE4(i)  := 'Y';
		END IF;

		IF(p_partial_process_flag4 = 'Y') Then
			l_DIRTY_FLAG4(i)  := p_data_structure(i).DIRTY_FLAG4;
		ELSE
			l_DIRTY_FLAG4(i)  := 'Y';
		END IF;

		IF p_process_flag4 <> 'Y' THEN
			l_DIRTY_FLAG4(i)  := null;
			l_ROLLUP_NODE4(i)  := null;
		END IF;


		l_START_DATE5(i)  		:= p_data_structure(i).START_DATE5;
		l_START_DATE_OVERRIDE5(i)  	:= p_data_structure(i).START_DATE_OVERRIDE5;
		l_FINISH_DATE5(i)  		:= p_data_structure(i).FINISH_DATE5;
		l_DURATION5(i)  		:= p_data_structure(i).DURATION5;
		l_TASK_STATUS5(i)  		:= p_data_structure(i).TASK_STATUS5;
		l_PROGRESS_STATUS_WEIGHT5(i)  	:= p_data_structure(i).PROGRESS_STATUS_WEIGHT5;
		l_PROGRESS_OVERRIDE5(i) 	:= p_data_structure(i).PROGRESS_OVERRIDE5;
		l_REMAINING_EFFORT5(i)  	:= p_data_structure(i).REMAINING_EFFORT5;
		l_PERCENT_COMPLETE5(i)  	:= p_data_structure(i).PERCENT_COMPLETE5;
		l_PERCENT_OVERRIDE5(i)  	:= p_data_structure(i).PERCENT_OVERRIDE5;
		l_TASK_WEIGHT5(i)  		:= p_data_structure(i).TASK_WEIGHT5;
		l_NUMBER_FIELD5(i)  		:= p_data_structure(i).NUMBER_FIELD5;
		l_Etc_Cost5(i)			:= p_data_structure(i).ETC_COST5;
		l_PPL_ETC_Cost5(i)		:= p_data_structure(i).PPL_ETC_Cost5;
		l_EQPMT_ETC_COST5(i)		:= p_data_structure(i).EQPMT_ETC_COST5;
		l_PPL_UNPLAND_EFFORT5(i)	:= p_data_structure(i).PPL_UNPLAND_EFFORT5;
		l_EQPMT_ETC_EFFORT5(i)		:= p_data_structure(i).EQPMT_ETC_EFFORT5;
		l_SUB_PRJ_ETC_COST5(i)		:= p_data_structure(i).SUB_PRJ_ETC_COST5;
		l_SUB_PRJ_PPL_ETC_COST5(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_COST5;
		l_SUB_PRJ_EQPMT_ETC_COST5(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_COST5;
		l_SUB_PRJ_PPL_ETC_EFFORT5(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_EFFORT5;
		l_SUB_PRJ_EQPMT_ETC_EFFORT5(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_EFFORT5;
		l_EARNED_VALUE5(i)		:= p_data_structure(i).EARNED_VALUE5;
		l_BAC_VALUE5(i)			:= p_data_structure(i).BAC_VALUE5;
		l_Perc_Comp_Deriv_Code5(i) 	:= p_data_structure(i).PERC_COMP_DERIVATIVE_CODE5;

		IF(l_partial_rollup5) Then
			IF(p_data_structure(i).ROLLUP_NODE5 = 'N') THEN
				l_ROLLUP_NODE5(i)  := 'N';
			ELSE
				l_ROLLUP_NODE5(i)  := 'Y';
			END IF;
		ELSE
			l_ROLLUP_NODE5(i)  := 'Y';
		END IF;

		IF(p_partial_process_flag5 = 'Y') Then
			l_DIRTY_FLAG5(i)  := p_data_structure(i).DIRTY_FLAG5;
		ELSE
			l_DIRTY_FLAG5(i)  := 'Y';
		END IF;

		IF p_process_flag5 <> 'Y' THEN
			l_DIRTY_FLAG5(i)  := null;
			l_ROLLUP_NODE5(i)  := null;
		END IF;

		l_START_DATE6(i)  		:= p_data_structure(i).START_DATE6;
		l_START_DATE_OVERRIDE6(i)  	:= p_data_structure(i).START_DATE_OVERRIDE6;
		l_FINISH_DATE6(i)  		:= p_data_structure(i).FINISH_DATE6;
		l_DURATION6(i)  		:= p_data_structure(i).DURATION6;
		l_TASK_STATUS6(i)  		:= p_data_structure(i).TASK_STATUS6;
		l_PROGRESS_STATUS_WEIGHT6(i)  	:= p_data_structure(i).PROGRESS_STATUS_WEIGHT6;
		l_PROGRESS_OVERRIDE6(i) 	:= p_data_structure(i).PROGRESS_OVERRIDE6;
		l_REMAINING_EFFORT6(i)  	:= p_data_structure(i).REMAINING_EFFORT6;
		l_PERCENT_COMPLETE6(i)  	:= p_data_structure(i).PERCENT_COMPLETE6;
		l_PERCENT_OVERRIDE6(i)  	:= p_data_structure(i).PERCENT_OVERRIDE6;
		l_TASK_WEIGHT6(i)  		:= p_data_structure(i).TASK_WEIGHT6;
		l_NUMBER_FIELD6(i)  		:= p_data_structure(i).NUMBER_FIELD6;
		l_Etc_Cost6(i)			:= p_data_structure(i).ETC_COST6;
		l_PPL_ETC_Cost6(i)		:= p_data_structure(i).PPL_ETC_Cost6;
		l_EQPMT_ETC_COST6(i)		:= p_data_structure(i).EQPMT_ETC_COST6;
		l_PPL_UNPLAND_EFFORT6(i)	:= p_data_structure(i).PPL_UNPLAND_EFFORT6;
		l_EQPMT_ETC_EFFORT6(i)		:= p_data_structure(i).EQPMT_ETC_EFFORT6;
		l_SUB_PRJ_ETC_COST6(i)		:= p_data_structure(i).SUB_PRJ_ETC_COST6;
		l_SUB_PRJ_PPL_ETC_COST6(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_COST6;
		l_SUB_PRJ_EQPMT_ETC_COST6(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_COST6;
		l_SUB_PRJ_PPL_ETC_EFFORT6(i)	:= p_data_structure(i).SUB_PRJ_PPL_ETC_EFFORT6;
		l_SUB_PRJ_EQPMT_ETC_EFFORT6(i)	:= p_data_structure(i).SUB_PRJ_EQPMT_ETC_EFFORT6;
		l_EARNED_VALUE6(i)		:= p_data_structure(i).EARNED_VALUE6;
		l_BAC_VALUE6(i)			:= p_data_structure(i).BAC_VALUE6;
		l_Perc_Comp_Deriv_Code6(i) 	:= p_data_structure(i).PERC_COMP_DERIVATIVE_CODE6;

		IF(l_partial_rollup6) Then
			IF(p_data_structure(i).ROLLUP_NODE6 = 'N') THEN
				l_ROLLUP_NODE6(i)  := 'N';
			ELSE
				l_ROLLUP_NODE6(i)  := 'Y';
			END IF;
		ELSE
			l_ROLLUP_NODE6(i)  := 'Y';
		END IF;

		IF(p_partial_process_flag6 = 'Y') Then
			l_DIRTY_FLAG6(i)  := p_data_structure(i).DIRTY_FLAG6;
		ELSE
			l_DIRTY_FLAG6(i)  := 'Y';
		END IF;

		IF p_process_flag6 <> 'Y' THEN
			l_DIRTY_FLAG6(i)  := null;
			l_ROLLUP_NODE6(i)  := null;
		END IF;

	END LOOP;	-- FOR i IN 1..P_Data_Structure.COUNT LOOP

        IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After building the table', x_Log_Level=> 3);
        END IF;

	FORALL i IN 1..P_Data_Structure.COUNT
		INSERT INTO PA_PROJ_ROLLUP_BULK_TEMP(
			PROCESS_NUMBER,
			OBJECT_TYPE,
			OBJECT_ID,
			PARENT_OBJECT_TYPE,
			PARENT_OBJECT_ID,
			CALENDAR_ID,
			CONSTRAINT_TYPE_CODE,
			CONSTRAINT_DATE,
			WBS_LEVEL,
			START_DATE1,
			START_DATE_OVERRIDE1,
			FINISH_DATE1,
			DURATION1,
			TASK_STATUS1,
			PROGRESS_STATUS_WEIGHT1,
			PROGRESS_OVERRIDE1,
			REMAINING_EFFORT1,
			PERCENT_COMPLETE1,
			PERCENT_OVERRIDE1,
			TASK_WEIGHT1,
			NUMBER_FIELD1,
			ROLLUP_NODE1,
			DIRTY_FLAG1,
			ETC_Cost1,
			PPL_ETC_COST1,
			EQPMT_ETC_COST1,
			PPL_UNPLAND_EFFORT1,
			EQPMT_ETC_EFFORT1,
			SUB_PRJ_ETC_COST1,
			SUB_PRJ_PPL_ETC_COST1,
			SUB_PRJ_EQPMT_ETC_COST1,
			SUB_PRJ_PPL_ETC_EFFORT1,
			SUB_PRJ_EQPMT_ETC_EFFORT1,
			EARNED_VALUE1,
			BAC_VALUE1,
			PERC_COMP_DERIVATIVE_CODE1,
			START_DATE2,
			START_DATE_OVERRIDE2,
			FINISH_DATE2,
			DURATION2,
			TASK_STATUS2,
			PROGRESS_STATUS_WEIGHT2,
			PROGRESS_OVERRIDE2,
			REMAINING_EFFORT2,
			PERCENT_COMPLETE2,
			PERCENT_OVERRIDE2,
			TASK_WEIGHT2,
			NUMBER_FIELD2,
			ROLLUP_NODE2,
			DIRTY_FLAG2,
			ETC_Cost2,
			PPL_ETC_COST2,
			EQPMT_ETC_COST2,
			PPL_UNPLAND_EFFORT2,
			EQPMT_ETC_EFFORT2,
			SUB_PRJ_ETC_COST2,
			SUB_PRJ_PPL_ETC_COST2,
			SUB_PRJ_EQPMT_ETC_COST2,
			SUB_PRJ_PPL_ETC_EFFORT2,
			SUB_PRJ_EQPMT_ETC_EFFORT2,
			EARNED_VALUE2,
			BAC_VALUE2,
			PERC_COMP_DERIVATIVE_CODE2,
			START_DATE3,
			START_DATE_OVERRIDE3,
			FINISH_DATE3,
			DURATION3,
			TASK_STATUS3,
			PROGRESS_STATUS_WEIGHT3,
			PROGRESS_OVERRIDE3,
			REMAINING_EFFORT3,
			PERCENT_COMPLETE3,
			PERCENT_OVERRIDE3,
			TASK_WEIGHT3,
			NUMBER_FIELD3,
			ROLLUP_NODE3,
			DIRTY_FLAG3,
			ETC_Cost3,
			PPL_ETC_COST3,
			EQPMT_ETC_COST3,
			PPL_UNPLAND_EFFORT3,
			EQPMT_ETC_EFFORT3,
			SUB_PRJ_ETC_COST3,
			SUB_PRJ_PPL_ETC_COST3,
			SUB_PRJ_EQPMT_ETC_COST3,
			SUB_PRJ_PPL_ETC_EFFORT3,
			SUB_PRJ_EQPMT_ETC_EFFORT3,
			EARNED_VALUE3,
			BAC_VALUE3,
			PERC_COMP_DERIVATIVE_CODE3,
			START_DATE4,
			START_DATE_OVERRIDE4,
			FINISH_DATE4,
			DURATION4,
			TASK_STATUS4,
			PROGRESS_STATUS_WEIGHT4,
			PROGRESS_OVERRIDE4,
			REMAINING_EFFORT4,
			PERCENT_COMPLETE4,
			PERCENT_OVERRIDE4,
			TASK_WEIGHT4,
			NUMBER_FIELD4,
			ROLLUP_NODE4,
			DIRTY_FLAG4,
			ETC_Cost4,
			PPL_ETC_COST4,
			EQPMT_ETC_COST4,
			PPL_UNPLAND_EFFORT4,
			EQPMT_ETC_EFFORT4,
			SUB_PRJ_ETC_COST4,
			SUB_PRJ_PPL_ETC_COST4,
			SUB_PRJ_EQPMT_ETC_COST4,
			SUB_PRJ_PPL_ETC_EFFORT4,
			SUB_PRJ_EQPMT_ETC_EFFORT4,
			EARNED_VALUE4,
			BAC_VALUE4,
			PERC_COMP_DERIVATIVE_CODE4,
			START_DATE5,
			START_DATE_OVERRIDE5,
			FINISH_DATE5,
			DURATION5,
			TASK_STATUS5,
			PROGRESS_STATUS_WEIGHT5,
			PROGRESS_OVERRIDE5,
			REMAINING_EFFORT5,
			PERCENT_COMPLETE5,
			PERCENT_OVERRIDE5,
			TASK_WEIGHT5,
			NUMBER_FIELD5,
			ROLLUP_NODE5,
			DIRTY_FLAG5,
			ETC_Cost5,
			PPL_ETC_COST5,
			EQPMT_ETC_COST5,
			PPL_UNPLAND_EFFORT5,
			EQPMT_ETC_EFFORT5,
			SUB_PRJ_ETC_COST5,
			SUB_PRJ_PPL_ETC_COST5,
			SUB_PRJ_EQPMT_ETC_COST5,
			SUB_PRJ_PPL_ETC_EFFORT5,
			SUB_PRJ_EQPMT_ETC_EFFORT5,
			EARNED_VALUE5,
			BAC_VALUE5,
			PERC_COMP_DERIVATIVE_CODE5,
			START_DATE6,
			START_DATE_OVERRIDE6,
			FINISH_DATE6,
			DURATION6,
			TASK_STATUS6,
			PROGRESS_STATUS_WEIGHT6,
			PROGRESS_OVERRIDE6,
			REMAINING_EFFORT6,
			PERCENT_COMPLETE6,
			PERCENT_OVERRIDE6,
			TASK_WEIGHT6,
			NUMBER_FIELD6,
			ROLLUP_NODE6,
			DIRTY_FLAG6,
			ETC_Cost6,
			PPL_ETC_COST6,
			EQPMT_ETC_COST6,
			PPL_UNPLAND_EFFORT6,
			EQPMT_ETC_EFFORT6,
			SUB_PRJ_ETC_COST6,
			SUB_PRJ_PPL_ETC_COST6,
			SUB_PRJ_EQPMT_ETC_COST6,
			SUB_PRJ_PPL_ETC_EFFORT6,
			SUB_PRJ_EQPMT_ETC_EFFORT6,
			EARNED_VALUE6,
			BAC_VALUE6,
			PERC_COMP_DERIVATIVE_CODE6,
			SUMMARY_OBJECT_FLAG -- 4370746
		      ) VALUES (
			l_process_number,
			l_OBJECT_TYPE(i),
			l_OBJECT_ID(i),
			l_PARENT_OBJECT_TYPE(i),
			l_PARENT_OBJECT_ID(i),
			l_CALENDAR_ID(i),
			l_CONSTRAINT_TYPE_CODE(i),
			l_CONSTRAINT_DATE(i),
			l_WBS_LEVEL(i),
			l_START_DATE1(i),
			l_START_DATE_OVERRIDE1(i),
			l_FINISH_DATE1(i),
			l_DURATION1(i),
			l_TASK_STATUS1(i),
			l_PROGRESS_STATUS_WEIGHT1(i),
			l_PROGRESS_OVERRIDE1(i),
			l_REMAINING_EFFORT1(i),
			l_PERCENT_COMPLETE1(i),
			l_PERCENT_OVERRIDE1(i),
			l_TASK_WEIGHT1(i),
			l_NUMBER_FIELD1(i),
			l_ROLLUP_NODE1(i),
			l_DIRTY_FLAG1(i),
			l_Etc_Cost1(i),
			l_PPL_ETC_Cost1(i),
			l_EQPMT_ETC_COST1(i),
			l_PPL_UNPLAND_EFFORT1(i),
			l_EQPMT_ETC_EFFORT1(i),
			l_SUB_PRJ_ETC_COST1(i),
			l_SUB_PRJ_PPL_ETC_COST1(i),
			l_SUB_PRJ_EQPMT_ETC_COST1(i),
			l_SUB_PRJ_PPL_ETC_EFFORT1(i),
			l_SUB_PRJ_EQPMT_ETC_EFFORT1(i),
			l_EARNED_VALUE1(i),
			l_BAC_VALUE1(i),
			l_Perc_Comp_Deriv_Code1(i),
			l_START_DATE2(i),
			l_START_DATE_OVERRIDE2(i),
			l_FINISH_DATE2(i),
			l_DURATION2(i),
			l_TASK_STATUS2(i),
			l_PROGRESS_STATUS_WEIGHT2(i),
			l_PROGRESS_OVERRIDE2(i),
			l_REMAINING_EFFORT2(i),
			l_PERCENT_COMPLETE2(i),
			l_PERCENT_OVERRIDE2(i),
			l_TASK_WEIGHT2(i),
			l_NUMBER_FIELD2(i),
			l_ROLLUP_NODE2(i),
			l_DIRTY_FLAG2(i),
			l_Etc_Cost2(i),
			l_PPL_ETC_Cost2(i),
			l_EQPMT_ETC_COST2(i),
			l_PPL_UNPLAND_EFFORT2(i),
			l_EQPMT_ETC_EFFORT2(i),
			l_SUB_PRJ_ETC_COST2(i),
			l_SUB_PRJ_PPL_ETC_COST2(i),
			l_SUB_PRJ_EQPMT_ETC_COST2(i),
			l_SUB_PRJ_PPL_ETC_EFFORT2(i),
			l_SUB_PRJ_EQPMT_ETC_EFFORT2(i),
			l_EARNED_VALUE2(i),
			l_BAC_VALUE2(i),
			l_Perc_Comp_Deriv_Code2(i),
			l_START_DATE3(i),
			l_START_DATE_OVERRIDE3(i),
			l_FINISH_DATE3(i),
			l_DURATION3(i),
			l_TASK_STATUS3(i),
			l_PROGRESS_STATUS_WEIGHT3(i),
			l_PROGRESS_OVERRIDE3(i),
			l_REMAINING_EFFORT3(i),
			l_PERCENT_COMPLETE3(i),
			l_PERCENT_OVERRIDE3(i),
			l_TASK_WEIGHT3(i),
			l_NUMBER_FIELD3(i),
			l_ROLLUP_NODE3(i),
			l_DIRTY_FLAG3(i),
			l_Etc_Cost3(i),
			l_PPL_ETC_Cost3(i),
			l_EQPMT_ETC_COST3(i),
			l_PPL_UNPLAND_EFFORT3(i),
			l_EQPMT_ETC_EFFORT3(i),
			l_SUB_PRJ_ETC_COST3(i),
			l_SUB_PRJ_PPL_ETC_COST3(i),
			l_SUB_PRJ_EQPMT_ETC_COST3(i),
			l_SUB_PRJ_PPL_ETC_EFFORT3(i),
			l_SUB_PRJ_EQPMT_ETC_EFFORT3(i),
			l_EARNED_VALUE3(i),
			l_BAC_VALUE3(i),
			l_Perc_Comp_Deriv_Code3(i),
			l_START_DATE4(i),
			l_START_DATE_OVERRIDE4(i),
			l_FINISH_DATE4(i),
			l_DURATION4(i),
			l_TASK_STATUS4(i),
			l_PROGRESS_STATUS_WEIGHT4(i),
			l_PROGRESS_OVERRIDE4(i),
			l_REMAINING_EFFORT4(i),
			l_PERCENT_COMPLETE4(i),
			l_PERCENT_OVERRIDE4(i),
			l_TASK_WEIGHT4(i),
			l_NUMBER_FIELD4(i),
			l_ROLLUP_NODE4(i),
			l_DIRTY_FLAG4(i),
			l_Etc_Cost4(i),
			l_PPL_ETC_Cost4(i),
			l_EQPMT_ETC_COST4(i),
			l_PPL_UNPLAND_EFFORT4(i),
			l_EQPMT_ETC_EFFORT4(i),
			l_SUB_PRJ_ETC_COST4(i),
			l_SUB_PRJ_PPL_ETC_COST4(i),
			l_SUB_PRJ_EQPMT_ETC_COST4(i),
			l_SUB_PRJ_PPL_ETC_EFFORT4(i),
			l_SUB_PRJ_EQPMT_ETC_EFFORT4(i),
			l_EARNED_VALUE4(i),
			l_BAC_VALUE4(i),
			l_Perc_Comp_Deriv_Code4(i),
			l_START_DATE5(i),
			l_START_DATE_OVERRIDE5(i),
			l_FINISH_DATE5(i),
			l_DURATION5(i),
			l_TASK_STATUS5(i),
			l_PROGRESS_STATUS_WEIGHT5(i),
			l_PROGRESS_OVERRIDE5(i),
			l_REMAINING_EFFORT5(i),
			l_PERCENT_COMPLETE5(i),
			l_PERCENT_OVERRIDE5(i),
			l_TASK_WEIGHT5(i),
			l_NUMBER_FIELD5(i),
			l_ROLLUP_NODE5(i),
			l_DIRTY_FLAG5(i),
			l_Etc_Cost5(i),
			l_PPL_ETC_Cost5(i),
			l_EQPMT_ETC_COST5(i),
			l_PPL_UNPLAND_EFFORT5(i),
			l_EQPMT_ETC_EFFORT5(i),
			l_SUB_PRJ_ETC_COST5(i),
			l_SUB_PRJ_PPL_ETC_COST5(i),
			l_SUB_PRJ_EQPMT_ETC_COST5(i),
			l_SUB_PRJ_PPL_ETC_EFFORT5(i),
			l_SUB_PRJ_EQPMT_ETC_EFFORT5(i),
			l_EARNED_VALUE5(i),
			l_BAC_VALUE5(i),
			l_Perc_Comp_Deriv_Code5(i),
			l_START_DATE6(i),
			l_START_DATE_OVERRIDE6(i),
			l_FINISH_DATE6(i),
			l_DURATION6(i),
			l_TASK_STATUS6(i),
			l_PROGRESS_STATUS_WEIGHT6(i),
			l_PROGRESS_OVERRIDE6(i),
			l_REMAINING_EFFORT6(i),
			l_PERCENT_COMPLETE6(i),
			l_PERCENT_OVERRIDE6(i),
			l_TASK_WEIGHT6(i),
			l_NUMBER_FIELD6(i),
			l_ROLLUP_NODE6(i),
			l_DIRTY_FLAG6(i),
			l_Etc_Cost6(i),
			l_PPL_ETC_Cost6(i),
			l_EQPMT_ETC_COST6(i),
			l_PPL_UNPLAND_EFFORT6(i),
			l_EQPMT_ETC_EFFORT6(i),
			l_SUB_PRJ_ETC_COST6(i),
			l_SUB_PRJ_PPL_ETC_COST6(i),
			l_SUB_PRJ_EQPMT_ETC_COST6(i),
			l_SUB_PRJ_PPL_ETC_EFFORT6(i),
			l_SUB_PRJ_EQPMT_ETC_EFFORT6(i),
			l_EARNED_VALUE6(i),
			l_BAC_VALUE6(i),
			l_Perc_Comp_Deriv_Code6(i),
			l_SUMMARY_OBJECT_FLAG(i) -- 4370746
		      );

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After insertion into table', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before dirty processing', x_Log_Level=> 3);
        END IF;

	-- p_process_flag1  to 6 to decide whether to process anything or not....
	-- p_process_rollup_flag1 to 6 determine whether the following processing is required


	-- ********* DIRTY PROCESSING BEGIN **********

	IF ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'
		OR p_process_flag5 = 'Y' OR p_process_flag6 = 'Y')
		AND(p_process_rollup_flag1 = 'Y' OR p_process_rollup_flag2 = 'Y' OR p_process_rollup_flag3 = 'Y'
		OR p_process_rollup_flag4 = 'Y' OR p_process_rollup_flag5 = 'Y' OR p_process_rollup_flag6 = 'Y')
		AND(p_partial_process_flag1 = 'Y' OR p_partial_process_flag2 = 'Y'  OR p_partial_process_flag3 = 'Y'
		    OR p_partial_process_flag4 = 'Y' OR p_partial_process_flag5 = 'Y' OR p_partial_process_flag6 = 'Y' ))
	THEN
		l_temp_object_ids_tab.delete;
		l_temp_object_types_tab.delete;
		l_temp_dirty_flag_tab1.delete;
		l_temp_dirty_flag_tab2.delete;
		l_temp_dirty_flag_tab3.delete;
		l_temp_dirty_flag_tab4.delete;
		l_temp_dirty_flag_tab5.delete;
		l_temp_dirty_flag_tab6.delete;
		l_object_ids_tab.delete;
		l_object_types_tab.delete;
		l_dirty_flag_tab1.delete;
		l_dirty_flag_tab2.delete;
		l_dirty_flag_tab3.delete;
		l_dirty_flag_tab4.delete;
		l_dirty_flag_tab5.delete;
		l_dirty_flag_tab6.delete;

		OPEN all_dirty_object_list_summary;
		FETCH all_dirty_object_list_summary BULK COLLECT INTO l_temp_object_ids_tab, l_temp_object_types_tab
		, l_temp_dirty_flag_tab1, l_temp_dirty_flag_tab2, l_temp_dirty_flag_tab3, l_temp_dirty_flag_tab4
		, l_temp_dirty_flag_tab5, l_temp_dirty_flag_tab6;
		CLOSE all_dirty_object_list_summary;

		FOR i IN 1..l_temp_object_ids_tab.count LOOP
			l_int_object_ids_tab.delete;
			l_int_object_types_tab.delete;
			l_int_dirty_flag_tab1.delete;
			l_int_dirty_flag_tab2.delete;
			l_int_dirty_flag_tab3.delete;
			l_int_dirty_flag_tab4.delete;
			l_int_dirty_flag_tab5.delete;
			l_int_dirty_flag_tab6.delete;
			l_int_ref_dirty_flag_tab1.delete;
			l_int_ref_dirty_flag_tab2.delete;
			l_int_ref_dirty_flag_tab3.delete;
			l_int_ref_dirty_flag_tab4.delete;
			l_int_ref_dirty_flag_tab5.delete;
			l_int_ref_dirty_flag_tab6.delete;

			OPEN all_Parent_Dirty_Object_List(l_temp_object_ids_tab(i)
					,l_temp_dirty_flag_tab1(i), l_temp_dirty_flag_tab2(i)
					, l_temp_dirty_flag_tab3(i), l_temp_dirty_flag_tab4(i)
					, l_temp_dirty_flag_tab4(i), l_temp_dirty_flag_tab6(i)) ;
			FETCH all_Parent_Dirty_Object_List
			BULK COLLECT INTO
				l_int_object_ids_tab, l_int_object_types_tab
				, l_int_dirty_flag_tab1, l_int_dirty_flag_tab2, l_int_dirty_flag_tab3
				, l_int_dirty_flag_tab4, l_int_dirty_flag_tab5, l_int_dirty_flag_tab6
				, l_int_ref_dirty_flag_tab1, l_int_ref_dirty_flag_tab2
				, l_int_ref_dirty_flag_tab3, l_int_ref_dirty_flag_tab4, l_int_ref_dirty_flag_tab5
				, l_int_ref_dirty_flag_tab6 ;
			CLOSE all_Parent_Dirty_Object_List;


			FOR j IN 1..l_int_object_ids_tab.count LOOP
				l_object_ids_tab.extend;
				l_object_types_tab.extend;
				l_dirty_flag_tab1.extend;
				l_dirty_flag_tab2.extend;
				l_dirty_flag_tab3.extend;
				l_dirty_flag_tab4.extend;
				l_dirty_flag_tab5.extend;
				l_dirty_flag_tab6.extend;
				l_object_ids_tab(l_object_ids_tab.count) := l_int_object_ids_tab(j);
				l_object_types_tab(l_object_types_tab.count) := l_int_object_types_tab(j);

				IF p_process_flag1 = 'Y' AND p_process_rollup_flag1 = 'Y' AND p_partial_process_flag1 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab1(j) = 'Y' THEN
						l_dirty_flag_tab1(l_dirty_flag_tab1.count) := 'Y';
					ELSE
						l_dirty_flag_tab1(l_dirty_flag_tab1.count) := l_int_dirty_flag_tab1(j);
					END IF;
				ELSE
					l_dirty_flag_tab1(l_dirty_flag_tab1.count) := l_int_dirty_flag_tab1(j);
				END IF;
				IF p_process_flag2 = 'Y' AND p_process_rollup_flag2 = 'Y' AND p_partial_process_flag2 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab2(j) = 'Y' THEN
						l_dirty_flag_tab2(l_dirty_flag_tab2.count) := 'Y';
					ELSE
						l_dirty_flag_tab2(l_dirty_flag_tab2.count) := l_int_dirty_flag_tab2(j);
					END IF;
				ELSE
					l_dirty_flag_tab2(l_dirty_flag_tab2.count) := l_int_dirty_flag_tab2(j);
				END IF;
				IF p_process_flag3 = 'Y' AND p_process_rollup_flag3 = 'Y' AND p_partial_process_flag3 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab3(j) = 'Y' THEN
						l_dirty_flag_tab3(l_dirty_flag_tab3.count) := 'Y';
					ELSE
						l_dirty_flag_tab3(l_dirty_flag_tab3.count) := l_int_dirty_flag_tab3(j);
					END IF;
				ELSE
					l_dirty_flag_tab3(l_dirty_flag_tab3.count) := l_int_dirty_flag_tab3(j);
				END IF;
				IF p_process_flag4 = 'Y' AND p_process_rollup_flag4 = 'Y' AND p_partial_process_flag4 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab4(j) = 'Y' THEN
						l_dirty_flag_tab4(l_dirty_flag_tab4.count) := 'Y';
					ELSE
						l_dirty_flag_tab4(l_dirty_flag_tab4.count) := l_int_dirty_flag_tab4(j);
					END IF;
				ELSE
					l_dirty_flag_tab4(l_dirty_flag_tab4.count) := l_int_dirty_flag_tab4(j);
				END IF;
				IF p_process_flag5 = 'Y' AND p_process_rollup_flag5 = 'Y' AND p_partial_process_flag5 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab5(j) = 'Y' THEN
						l_dirty_flag_tab5(l_dirty_flag_tab5.count) := 'Y';
					ELSE
						l_dirty_flag_tab5(l_dirty_flag_tab5.count) := l_int_dirty_flag_tab5(j);
					END IF;
				ELSE
					l_dirty_flag_tab5(l_dirty_flag_tab5.count) := l_int_dirty_flag_tab5(j);
				END IF;
				IF p_process_flag6 = 'Y' AND p_process_rollup_flag6 = 'Y' AND p_partial_process_flag6 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab6(j) = 'Y' THEN
						l_dirty_flag_tab6(l_dirty_flag_tab6.count) := 'Y';
					ELSE
						l_dirty_flag_tab6(l_dirty_flag_tab6.count) := l_int_dirty_flag_tab6(j);
					END IF;
				ELSE
					l_dirty_flag_tab6(l_dirty_flag_tab6.count) := l_int_dirty_flag_tab6(j);
				END IF;
			END LOOP; -- FOR j IN 1..l_int_object_ids_tab.count LOOP
		END LOOP; -- FOR i IN 1..l_temp_object_ids_tab.count LOOP


	        FORALL i in 1..l_object_ids_tab.count
	      /* Added the hint to force the unique index for bug#6185523 */
		     UPDATE  /*+ INDEX( T1 PA_PROJ_ROLLUP_BULK_TEMP_U1) */ PA_PROJ_ROLLUP_BULK_TEMP T1
			SET    T1.DIRTY_FLAG1=l_dirty_flag_tab1(i)
			, T1.DIRTY_FLAG2=l_dirty_flag_tab2(i)
			, T1.DIRTY_FLAG3=l_dirty_flag_tab3(i)
			, T1.DIRTY_FLAG4=l_dirty_flag_tab4(i)
			, T1.DIRTY_FLAG5=l_dirty_flag_tab5(i)
			, T1.DIRTY_FLAG6=l_dirty_flag_tab6(i)
		       WHERE T1.object_id = l_object_ids_tab(i)
			 AND T1.object_type = l_object_types_tab(i)
   		        AND process_number = l_Process_Number
		      ;

		-- Lowest tasks Processing
		l_temp_object_ids_tab.delete;
		l_temp_object_types_tab.delete;
		l_temp_dirty_flag_tab1.delete;
		l_temp_dirty_flag_tab2.delete;
		l_temp_dirty_flag_tab3.delete;
		l_temp_dirty_flag_tab4.delete;
		l_temp_dirty_flag_tab5.delete;
		l_temp_dirty_flag_tab6.delete;
		l_object_ids_tab.delete;
		l_object_types_tab.delete;
		l_dirty_flag_tab1.delete;
		l_dirty_flag_tab2.delete;
		l_dirty_flag_tab3.delete;
		l_dirty_flag_tab4.delete;
		l_dirty_flag_tab5.delete;
		l_dirty_flag_tab6.delete;


		OPEN all_dirty_object_list_lowest;
		FETCH all_dirty_object_list_lowest BULK COLLECT INTO l_temp_object_ids_tab, l_temp_object_types_tab
		, l_temp_dirty_flag_tab1, l_temp_dirty_flag_tab2, l_temp_dirty_flag_tab3, l_temp_dirty_flag_tab4
		, l_temp_dirty_flag_tab5, l_temp_dirty_flag_tab6;
		CLOSE all_dirty_object_list_lowest;

		FOR i IN 1..l_temp_object_ids_tab.count LOOP
			l_int_object_ids_tab.delete;
			l_int_object_types_tab.delete;
			l_int_dirty_flag_tab1.delete;
			l_int_dirty_flag_tab2.delete;
			l_int_dirty_flag_tab3.delete;
			l_int_dirty_flag_tab4.delete;
			l_int_dirty_flag_tab5.delete;
			l_int_dirty_flag_tab6.delete;
			l_int_ref_dirty_flag_tab1.delete;
			l_int_ref_dirty_flag_tab2.delete;
			l_int_ref_dirty_flag_tab3.delete;
			l_int_ref_dirty_flag_tab4.delete;
			l_int_ref_dirty_flag_tab5.delete;
			l_int_ref_dirty_flag_tab6.delete;

			OPEN all_child_Dirty_Object_List(l_temp_object_ids_tab(i)
					,l_temp_dirty_flag_tab1(i), l_temp_dirty_flag_tab2(i)
					, l_temp_dirty_flag_tab3(i), l_temp_dirty_flag_tab4(i)
					, l_temp_dirty_flag_tab4(i), l_temp_dirty_flag_tab6(i)) ;
			FETCH all_child_Dirty_Object_List
			BULK COLLECT INTO
				l_int_object_ids_tab, l_int_object_types_tab
				, l_int_dirty_flag_tab1, l_int_dirty_flag_tab2, l_int_dirty_flag_tab3
				, l_int_dirty_flag_tab4, l_int_dirty_flag_tab5, l_int_dirty_flag_tab6
				, l_int_ref_dirty_flag_tab1, l_int_ref_dirty_flag_tab2
				, l_int_ref_dirty_flag_tab3, l_int_ref_dirty_flag_tab4, l_int_ref_dirty_flag_tab5
				, l_int_ref_dirty_flag_tab6 ;
			CLOSE all_child_Dirty_Object_List;

			FOR j IN 1..l_int_object_ids_tab.count LOOP
				l_object_ids_tab.extend;
				l_object_types_tab.extend;
				l_dirty_flag_tab1.extend;
				l_dirty_flag_tab2.extend;
				l_dirty_flag_tab3.extend;
				l_dirty_flag_tab4.extend;
				l_dirty_flag_tab5.extend;
				l_dirty_flag_tab6.extend;
				l_object_ids_tab(l_object_ids_tab.count) := l_int_object_ids_tab(j);
				l_object_types_tab(l_object_types_tab.count) := l_int_object_types_tab(j);
				IF p_process_flag1 = 'Y' AND p_process_rollup_flag1 = 'Y' AND p_partial_process_flag1 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab1(j) = 'Y' THEN
						l_dirty_flag_tab1(l_dirty_flag_tab1.count) := 'Y';
					ELSE
						l_dirty_flag_tab1(l_dirty_flag_tab1.count) := l_int_dirty_flag_tab1(j);
					END IF;
				ELSE
					l_dirty_flag_tab1(l_dirty_flag_tab1.count) := l_int_dirty_flag_tab1(j);
				END IF;
				IF p_process_flag2 = 'Y' AND p_process_rollup_flag2 = 'Y' AND p_partial_process_flag2 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab2(j) = 'Y' THEN
						l_dirty_flag_tab2(l_dirty_flag_tab2.count) := 'Y';
					ELSE
						l_dirty_flag_tab2(l_dirty_flag_tab2.count) := l_int_dirty_flag_tab2(j);
					END IF;
				ELSE
					l_dirty_flag_tab2(l_dirty_flag_tab2.count) := l_int_dirty_flag_tab2(j);
				END IF;
				IF p_process_flag3 = 'Y' AND p_process_rollup_flag3 = 'Y' AND p_partial_process_flag3 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab3(j) = 'Y' THEN
						l_dirty_flag_tab3(l_dirty_flag_tab3.count) := 'Y';
					ELSE
						l_dirty_flag_tab3(l_dirty_flag_tab3.count) := l_int_dirty_flag_tab3(j);
					END IF;
				ELSE
					l_dirty_flag_tab3(l_dirty_flag_tab3.count) := l_int_dirty_flag_tab3(j);
				END IF;
				IF p_process_flag4 = 'Y' AND p_process_rollup_flag4 = 'Y' AND p_partial_process_flag4 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab4(j) = 'Y' THEN
						l_dirty_flag_tab4(l_dirty_flag_tab4.count) := 'Y';
					ELSE
						l_dirty_flag_tab4(l_dirty_flag_tab4.count) := l_int_dirty_flag_tab4(j);
					END IF;
				ELSE
					l_dirty_flag_tab4(l_dirty_flag_tab4.count) := l_int_dirty_flag_tab4(j);
				END IF;
				IF p_process_flag5 = 'Y' AND p_process_rollup_flag5 = 'Y' AND p_partial_process_flag5 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab5(j) = 'Y' THEN
						l_dirty_flag_tab5(l_dirty_flag_tab5.count) := 'Y';
					ELSE
						l_dirty_flag_tab5(l_dirty_flag_tab5.count) := l_int_dirty_flag_tab5(j);
					END IF;
				ELSE
					l_dirty_flag_tab5(l_dirty_flag_tab5.count) := l_int_dirty_flag_tab5(j);
				END IF;
				IF p_process_flag6 = 'Y' AND p_process_rollup_flag6 = 'Y' AND p_partial_process_flag6 = 'Y' THEN
					IF l_int_ref_dirty_flag_tab6(j) = 'Y' THEN
						l_dirty_flag_tab6(l_dirty_flag_tab6.count) := 'Y';
					ELSE
						l_dirty_flag_tab6(l_dirty_flag_tab6.count) := l_int_dirty_flag_tab6(j);
					END IF;
				ELSE
					l_dirty_flag_tab6(l_dirty_flag_tab6.count) := l_int_dirty_flag_tab6(j);
				END IF;
			END LOOP; -- FOR j IN 1..l_int_object_ids_tab.count LOOP
		END LOOP; -- FOR i IN 1..l_temp_object_ids_tab.count LOOP

	        FORALL i in 1..l_object_ids_tab.count
	      /* Added the hint to force the unique index for bug#6185523 */
		     UPDATE  /*+ INDEX( T1 PA_PROJ_ROLLUP_BULK_TEMP_U1) */ PA_PROJ_ROLLUP_BULK_TEMP T1
			SET    T1.DIRTY_FLAG1=l_dirty_flag_tab1(i)
			, T1.DIRTY_FLAG2=l_dirty_flag_tab2(i)
			, T1.DIRTY_FLAG3=l_dirty_flag_tab3(i)
			, T1.DIRTY_FLAG4=l_dirty_flag_tab4(i)
			, T1.DIRTY_FLAG5=l_dirty_flag_tab5(i)
			, T1.DIRTY_FLAG6=l_dirty_flag_tab6(i)
		       WHERE T1.object_id = l_object_ids_tab(i)
			 AND T1.object_type = l_object_types_tab(i)
   		        AND process_number = l_Process_Number
		      ;
	END IF; -- ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'

	-- ********* DIRTY PROCESSING END ***********

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After dirty processing', x_Log_Level=> 3);
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before Date processing', x_Log_Level=> 3);
        END IF;

	-- ********* NEW DATES PROCESSING BEGIN **********

	OPEN dirty_all_List;
	FETCH dirty_all_List BULK COLLECT INTO
	l_parent_object_ids_tab
	, l_parent_object_types_tab
	, l_parent_start_date_tab1
	, l_parent_start_date_tab2
	, l_parent_start_date_tab3
	, l_parent_start_date_tab4
	, l_parent_start_date_tab5
	, l_parent_start_date_tab6
	, l_parent_finish_date_tab1
	, l_parent_finish_date_tab2
	, l_parent_finish_date_tab3
	, l_parent_finish_date_tab4
	, l_parent_finish_date_tab5
	, l_parent_finish_date_tab6
	, l_parent_duration_tab1
	, l_parent_duration_tab2
	, l_parent_duration_tab3
	, l_parent_duration_tab4
	, l_parent_duration_tab5
	, l_parent_duration_tab6
	, l_parent_dirty_flag_tab1
	, l_parent_dirty_flag_tab2
	, l_parent_dirty_flag_tab3
	, l_parent_dirty_flag_tab4
	, l_parent_dirty_flag_tab5
	, l_parent_dirty_flag_tab6
	, l_parent_start_date_or_tab1
	, l_parent_start_date_or_tab2
	, l_parent_start_date_or_tab3
	, l_parent_start_date_or_tab4
	, l_parent_start_date_or_tab5
	, l_parent_start_date_or_tab6
	, l_update_date_flag_tab1
	, l_update_date_flag_tab2
	, l_update_date_flag_tab3
	, l_update_date_flag_tab4
	, l_update_date_flag_tab5
	, l_update_date_flag_tab6
	, l_update_requ_flag_tab1
	, l_update_requ_flag_tab2
	, l_update_requ_flag_tab3
	, l_update_requ_flag_tab4
	, l_update_requ_flag_tab5
	, l_update_requ_flag_tab6
	;
	CLOSE dirty_all_List;

	l_count1 := 0;
	l_count2 := 0;
	l_count3 := 0;
	l_count4 := 0;
	l_count5 := 0;
	l_count6 := 0;


	IF p_process_flag1 <> 'Y' AND p_process_rollup_flag1 <> 'Y' THEN
		l_count1 := 1;
	END IF;
	IF p_process_flag2 <> 'Y' AND p_process_rollup_flag2 <> 'Y' THEN
		l_count2 := 1;
	END IF;
	IF p_process_flag3 <> 'Y' AND p_process_rollup_flag3 <> 'Y' THEN
		l_count3 := 1;
	END IF;
	IF p_process_flag4 <> 'Y' AND p_process_rollup_flag4 <> 'Y' THEN
		l_count4 := 1;
	END IF;
	IF p_process_flag5 <> 'Y' AND p_process_rollup_flag5 <> 'Y' THEN
		l_count5 := 1;
	END IF;
	IF p_process_flag6 <> 'Y' AND p_process_rollup_flag6 <> 'Y' THEN
		l_count6 := 1;
	END IF;


	For j IN 1..l_parent_object_ids_tab.count LOOP
		BEGIN
			l_parent_update_required := 'N';
			l_lowest_task := 'N';
			l_task_flag := 0;
			l_task_count1 := 0;
			l_task_count2 := 0;
			l_task_count3 := 0;
			l_task_count4 := 0;
			l_task_count5 := 0;
			l_task_count6 := 0;
			l_null_flag1 := 0;
			l_null_flag2 := 0;
			l_null_flag3 := 0;
			l_null_flag4 := 0;
			l_null_flag5 := 0;
			l_null_flag6 := 0;
			l_new_start_date1 := null;
			l_new_start_date2 := null;
			l_new_start_date3 := null;
			l_new_start_date4 := null;
			l_new_start_date5 := null;
			l_new_start_date6 := null;
			l_new_completion_date1 := null;
			l_new_completion_date2 := null;
			l_new_completion_date3 := null;
			l_new_completion_date4 := null;
			l_new_completion_date5 := null;
			l_new_completion_date6 := null;
			/* Starts added for bug# 6185523 */

			l_parent_start_date1_tmp := null;
			l_parent_finish_date1_tmp := null;
			l_parent_duration1_tmp	 := null;
			l_parent_start_date2_tmp := null;
			l_parent_finish_date2_tmp := null;
			l_parent_duration2_tmp	 := null;
			l_parent_start_date3_tmp := null;
			l_parent_finish_date3_tmp := null;
			l_parent_duration3_tmp	 := null;
			l_parent_start_date4_tmp := null;
			l_parent_finish_date4_tmp := null;
			l_parent_duration4_tmp	 := null;
			l_parent_start_date5_tmp := null;
			l_parent_finish_date5_tmp := null;
			l_parent_duration5_tmp	 := null;
			l_parent_start_date6_tmp := null;
			l_parent_finish_date6_tmp := null;
			l_parent_duration6_tmp	 := null;
			dirty_flag1_tmp	 := null;
			dirty_flag2_tmp	 := null;
			dirty_flag3_tmp	 := null;
			dirty_flag4_tmp	 := null;
			dirty_flag5_tmp	 := null;
			dirty_flag6_tmp := null;

			/* Ends added for bug# 6185523 */

			IF l_partial_rollup1 OR l_partial_rollup2 OR l_partial_rollup3
				   OR l_partial_rollup4 OR l_partial_rollup5 OR l_partial_rollup6
			THEN
				SELECT
					MIN(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', start_date1, null), start_date1))
					, MAX(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', finish_date1, null), finish_date1))
					, MAX(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', DECODE(finish_date1,NULL,1,0), 0), 0))
					, MAX(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', 1, 0), 1))
					, MIN(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', start_date2, null), start_date2))
					, MAX(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', finish_date2, null), finish_date2))
					, MAX(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', DECODE(finish_date2,NULL,1,0), 0), 0))
					, MAX(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', 1, 0), 1))
					, MIN(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', start_date3, null), start_date3))
					, MAX(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', finish_date3, null), finish_date3))
					, MAX(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', DECODE(finish_date3,NULL,1,0), 0), 0))
					, MAX(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', 1, 0), 1))
					, MIN(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', start_date4, null), start_date4))
					, MAX(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', finish_date4, null), finish_date4))
					, MAX(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', DECODE(finish_date4,NULL,1,0), 0), 0))
					, MAX(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', 1, 0), 1))
					, MIN(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', start_date5, null), start_date5))
					, MAX(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', finish_date5, null), finish_date5))
					, MAX(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', DECODE(finish_date5,NULL,1,0), 0), 0))
					, MAX(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', 1, 0), 1))
					, MIN(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', start_date6, null), start_date6))
					, MAX(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', finish_date6, null), finish_date6))
					, MAX(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', DECODE(finish_date6,NULL,1,0), 0), 0))
					, MAX(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', 1, 0), 1))
					, MAX(DECODE(OBJECT_TYPE,'PA_TASKS',1,0))
				INTO
					l_new_start_date1
					, l_new_completion_date1
					, l_null_flag1
					, l_task_count1
					, l_new_start_date2
					, l_new_completion_date2
					, l_null_flag2
					, l_task_count2
					, l_new_start_date3
					, l_new_completion_date3
					, l_null_flag3
					, l_task_count3
					, l_new_start_date4
					, l_new_completion_date4
					, l_null_flag4
					, l_task_count4
					, l_new_start_date5
					, l_new_completion_date5
					, l_null_flag5
					, l_task_count5
					, l_new_start_date6
					, l_new_completion_date6
					, l_null_flag6
					, l_task_count6
					, l_task_flag
				FROM PA_PROJ_ROLLUP_BULK_TEMP
				WHERE PROCESS_NUMBER = l_process_number
				AND parent_object_id = l_parent_object_ids_tab(j)
				AND parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
				;
			ELSE
				SELECT
					MIN(start_date1)
					, MAX(finish_date1)
					, MAX(DECODE(finish_date1,NULL,1,0))
					, MAX(1)
					, MIN(start_date2)
					, MAX(finish_date2)
					, MAX(DECODE(finish_date2,NULL,1,0))
					, MAX(1)
					, MIN(start_date3)
					, MAX(finish_date3)
					, MAX(DECODE(finish_date3,NULL,1,0))
					, MAX(1)
					, MIN(start_date4)
					, MAX(finish_date4)
					, MAX(DECODE(finish_date4,NULL,1,0))
					, MAX(1)
					, MIN(start_date5)
					, MAX(finish_date5)
					, MAX(DECODE(finish_date5,NULL,1,0))
					, MAX(1)
					, MIN(start_date6)
					, MAX(finish_date6)
					, MAX(DECODE(finish_date6,NULL,1,0))
					, MAX(1)
					, MAX(DECODE(OBJECT_TYPE,'PA_TASKS',1,0))
				INTO
					l_new_start_date1
					, l_new_completion_date1
					, l_null_flag1
					, l_task_count1
					, l_new_start_date2
					, l_new_completion_date2
					, l_null_flag2
					, l_task_count2
					, l_new_start_date3
					, l_new_completion_date3
					, l_null_flag3
					, l_task_count3
					, l_new_start_date4
					, l_new_completion_date4
					, l_null_flag4
					, l_task_count4
					, l_new_start_date5
					, l_new_completion_date5
					, l_null_flag5
					, l_task_count5
					, l_new_start_date6
					, l_new_completion_date6
					, l_null_flag6
					, l_task_count6
					, l_task_flag
				FROM PA_PROJ_ROLLUP_BULK_TEMP
				WHERE PROCESS_NUMBER = l_process_number
				AND parent_object_id = l_parent_object_ids_tab(j)
				AND parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
				;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				l_lowest_task := 'Y';
				l_task_count1 := 1;
				l_task_count2 := 1;
				l_task_count3 := 1;
				l_task_count4 := 1;
				l_task_count5 := 1;
				l_task_count6 := 1;
			WHEN OTHERS THEN
				l_task_flag := 0;
				l_task_count1 := 0;
				l_task_count2 := 0;
				l_task_count3 := 0;
				l_task_count4 := 0;
				l_task_count5 := 0;
				l_task_count6 := 0;
		END;

		IF l_count1= 1 OR l_task_count1 = 0 THEN
			l_update_requ_flag_tab1(j) := 'N';
		ELSE
			IF l_lowest_task = 'Y' THEN
				IF l_parent_dirty_flag_tab1(j) <> 'Y' THEN
					l_update_requ_flag_tab1(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab1(j) := 'Y';
					IF P_Derived_Field1 = 'DURATION' THEN
						IF((l_parent_start_date_tab1(j) IS NULL) OR (l_parent_finish_date_tab1(j) IS NULL))
						THEN
							l_update_date_flag_tab1(j) := 'N';
						ELSE
							l_update_date_flag_tab1(j) := 'Y';
							l_parent_duration_tab1(j) := l_parent_finish_date_tab1(j) - l_parent_start_date_tab1(j) +1;
						END IF;
					ELSIF P_Derived_Field1 = 'START' THEN
						IF((l_parent_duration_tab1(j) IS NULL) OR (l_parent_finish_date_tab1(j) IS NULL))
						THEN
							l_update_date_flag_tab1(j) := 'N';
						ELSE
							l_update_date_flag_tab1(j) := 'Y';
							l_parent_start_date_tab1(j) := l_parent_finish_date_tab1(j) - l_parent_duration_tab1(j) +1;
						END IF;
					ELSIF P_Derived_Field1 = 'FINISH' THEN
						IF((l_parent_duration_tab1(j) IS NULL) OR (l_parent_start_date_tab1(j) IS NULL))
						THEN
							l_update_date_flag_tab1(j) := 'Y';
						ELSE
							l_update_date_flag_tab1(j) := 'Y';
							l_parent_finish_date_tab1(j) := l_parent_start_date_tab1(j) + l_parent_duration_tab1(j)-1;
						END IF;
					END IF; -- P_Derived_Field1 = 'DURATION'
				END IF;
			ELSE
				IF l_parent_dirty_flag_tab1(j) <> 'Y' THEN
					l_update_requ_flag_tab1(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab1(j) := 'Y';

					IF l_null_flag1 = 1 THEN
						l_new_completion_date1 := null;
					END IF;
					l_new_start_date1 := NVL(l_parent_start_date_or_tab1(j), l_new_start_date1);
					l_parent_start_date_tab1(j) := l_new_start_date1;
					l_parent_finish_date_tab1(j) := l_new_completion_date1;
					IF l_new_start_date1 IS NULL AND l_new_completion_date1 IS NULL THEN
						l_parent_duration_tab1(j) := null;
					ELSE
						l_parent_duration_tab1(j) := l_new_completion_date1 - l_new_start_date1 +1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab1(j) :='Y';
					ELSE
						IF l_new_start_date1 IS NULL AND l_new_completion_date1 IS NULL THEN
							l_update_date_flag_tab1(j) :='N';
						ELSE
							l_update_date_flag_tab1(j) :='Y';
						END IF;
					END IF;
				END IF;
			END IF; -- l_lowest_task = 'Y'
		END IF; -- l_count1= 1 OR l_task_count1 = 0
		IF l_count2= 1 OR l_task_count2 = 0 THEN
			l_update_requ_flag_tab2(j) := 'N';
		ELSE
			IF l_lowest_task = 'Y' THEN
				IF l_parent_dirty_flag_tab2(j) <> 'Y' THEN
					l_update_requ_flag_tab2(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab2(j) := 'Y';
					IF P_Derived_Field2 = 'DURATION' THEN
						IF((l_parent_start_date_tab2(j) IS NULL) OR (l_parent_finish_date_tab2(j) IS NULL))
						THEN
							l_update_date_flag_tab2(j) := 'N';
						ELSE
							l_update_date_flag_tab2(j) := 'Y';
							l_parent_duration_tab2(j) := l_parent_finish_date_tab2(j) - l_parent_start_date_tab2(j) +1;
						END IF;
					ELSIF P_Derived_Field2 = 'START' THEN
						IF((l_parent_duration_tab2(j) IS NULL) OR (l_parent_finish_date_tab2(j) IS NULL))
						THEN
							l_update_date_flag_tab2(j) := 'N';
						ELSE
							l_update_date_flag_tab2(j) := 'Y';
							l_parent_start_date_tab2(j) := l_parent_finish_date_tab2(j) - l_parent_duration_tab2(j) +1;
						END IF;
					ELSIF P_Derived_Field2 = 'FINISH' THEN
						IF((l_parent_duration_tab2(j) IS NULL) OR (l_parent_start_date_tab2(j) IS NULL))
						THEN
							l_update_date_flag_tab2(j) := 'Y';
						ELSE
							l_update_date_flag_tab2(j) := 'Y';
							l_parent_finish_date_tab2(j) := l_parent_start_date_tab2(j) + l_parent_duration_tab2(j)-1;
						END IF;
					END IF; -- P_Derived_Field2 = 'DURATION'
				END IF;
			ELSE
				IF l_parent_dirty_flag_tab2(j) <> 'Y' THEN
					l_update_requ_flag_tab2(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab2(j) := 'Y';

					IF l_null_flag2 = 1 THEN
						l_new_completion_date2 := null;
					END IF;
					l_new_start_date2 := NVL(l_parent_start_date_or_tab2(j), l_new_start_date2);
					l_parent_start_date_tab2(j) := l_new_start_date2;
					l_parent_finish_date_tab2(j) := l_new_completion_date2;
					IF l_new_start_date2 IS NULL AND l_new_completion_date2 IS NULL THEN
						l_parent_duration_tab2(j) := null;
					ELSE
						l_parent_duration_tab2(j) := l_new_completion_date2 - l_new_start_date2 +1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab2(j) :='Y';
					ELSE
						IF l_new_start_date2 IS NULL AND l_new_completion_date2 IS NULL THEN
							l_update_date_flag_tab2(j) :='N';
						ELSE
							l_update_date_flag_tab2(j) :='Y';
						END IF;
					END IF;
				END IF;
			END IF; -- l_lowest_task = 'Y'
		END IF; -- l_count2= 1 OR l_task_count2 = 0
		IF l_count3= 1 OR l_task_count3 = 0 THEN
			l_update_requ_flag_tab3(j) := 'N';
		ELSE
			IF l_lowest_task = 'Y' THEN
				IF l_parent_dirty_flag_tab3(j) <> 'Y' THEN
					l_update_requ_flag_tab3(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab3(j) := 'Y';
					IF P_Derived_Field3 = 'DURATION' THEN
						IF((l_parent_start_date_tab3(j) IS NULL) OR (l_parent_finish_date_tab3(j) IS NULL))
						THEN
							l_update_date_flag_tab3(j) := 'N';
						ELSE
							l_update_date_flag_tab3(j) := 'Y';
							l_parent_duration_tab3(j) := l_parent_finish_date_tab3(j) - l_parent_start_date_tab3(j) +1;
						END IF;
					ELSIF P_Derived_Field3 = 'START' THEN
						IF((l_parent_duration_tab3(j) IS NULL) OR (l_parent_finish_date_tab3(j) IS NULL))
						THEN
							l_update_date_flag_tab3(j) := 'N';
						ELSE
							l_update_date_flag_tab3(j) := 'Y';
							l_parent_start_date_tab3(j) := l_parent_finish_date_tab3(j) - l_parent_duration_tab3(j) +1;
						END IF;
					ELSIF P_Derived_Field3 = 'FINISH' THEN
						IF((l_parent_duration_tab3(j) IS NULL) OR (l_parent_start_date_tab3(j) IS NULL))
						THEN
							l_update_date_flag_tab3(j) := 'Y';
						ELSE
							l_update_date_flag_tab3(j) := 'Y';
							l_parent_finish_date_tab3(j) := l_parent_start_date_tab3(j) + l_parent_duration_tab3(j)-1;
						END IF;
					END IF; -- P_Derived_Field3 = 'DURATION'
				END IF;
			ELSE
				IF l_parent_dirty_flag_tab3(j) <> 'Y' THEN
					l_update_requ_flag_tab3(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab3(j) := 'Y';

					IF l_null_flag3 = 1 THEN
						l_new_completion_date3 := null;
					END IF;
					l_new_start_date3 := NVL(l_parent_start_date_or_tab3(j), l_new_start_date3);
					l_parent_start_date_tab3(j) := l_new_start_date3;
					l_parent_finish_date_tab3(j) := l_new_completion_date3;
					IF l_new_start_date3 IS NULL AND l_new_completion_date3 IS NULL THEN
						l_parent_duration_tab3(j) := null;
					ELSE
						l_parent_duration_tab3(j) := l_new_completion_date3 - l_new_start_date3 +1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab3(j) :='Y';
					ELSE
						IF l_new_start_date3 IS NULL AND l_new_completion_date3 IS NULL THEN
							l_update_date_flag_tab3(j) :='N';
						ELSE
							l_update_date_flag_tab3(j) :='Y';
						END IF;
					END IF;
				END IF;
			END IF; -- l_lowest_task = 'Y'
		END IF; -- l_count3= 1 OR l_task_count3 = 0
		IF l_count4= 1 OR l_task_count4 = 0 THEN
			l_update_requ_flag_tab4(j) := 'N';
		ELSE
			IF l_lowest_task = 'Y' THEN
				IF l_parent_dirty_flag_tab4(j) <> 'Y' THEN
					l_update_requ_flag_tab4(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab4(j) := 'Y';
					IF P_Derived_Field4 = 'DURATION' THEN
						IF((l_parent_start_date_tab4(j) IS NULL) OR (l_parent_finish_date_tab4(j) IS NULL))
						THEN
							l_update_date_flag_tab4(j) := 'N';
						ELSE
							l_update_date_flag_tab4(j) := 'Y';
							l_parent_duration_tab4(j) := l_parent_finish_date_tab4(j) - l_parent_start_date_tab4(j) +1;
						END IF;
					ELSIF P_Derived_Field4 = 'START' THEN
						IF((l_parent_duration_tab4(j) IS NULL) OR (l_parent_finish_date_tab4(j) IS NULL))
						THEN
							l_update_date_flag_tab4(j) := 'N';
						ELSE
							l_update_date_flag_tab4(j) := 'Y';
							l_parent_start_date_tab4(j) := l_parent_finish_date_tab4(j) - l_parent_duration_tab4(j) +1;
						END IF;
					ELSIF P_Derived_Field4 = 'FINISH' THEN
						IF((l_parent_duration_tab4(j) IS NULL) OR (l_parent_start_date_tab4(j) IS NULL))
						THEN
							l_update_date_flag_tab4(j) := 'Y';
						ELSE
							l_update_date_flag_tab4(j) := 'Y';
							l_parent_finish_date_tab4(j) := l_parent_start_date_tab4(j) + l_parent_duration_tab4(j)-1;
						END IF;
					END IF; -- P_Derived_Field4 = 'DURATION'
				END IF;
			ELSE
				IF l_parent_dirty_flag_tab4(j) <> 'Y' THEN
					l_update_requ_flag_tab4(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab4(j) := 'Y';

					IF l_null_flag4 = 1 THEN
						l_new_completion_date4 := null;
					END IF;
					l_new_start_date4 := NVL(l_parent_start_date_or_tab4(j), l_new_start_date4);
					l_parent_start_date_tab4(j) := l_new_start_date4;
					l_parent_finish_date_tab4(j) := l_new_completion_date4;
					IF l_new_start_date4 IS NULL AND l_new_completion_date4 IS NULL THEN
						l_parent_duration_tab4(j) := null;
					ELSE
						l_parent_duration_tab4(j) := l_new_completion_date4 - l_new_start_date4 +1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab4(j) :='Y';
					ELSE
						IF l_new_start_date4 IS NULL AND l_new_completion_date4 IS NULL THEN
							l_update_date_flag_tab4(j) :='N';
						ELSE
							l_update_date_flag_tab4(j) :='Y';
						END IF;
					END IF;
				END IF;
			END IF; -- l_lowest_task = 'Y'
		END IF; -- l_count4= 1 OR l_task_count4 = 0
		IF l_count5= 1 OR l_task_count5 = 0 THEN
			l_update_requ_flag_tab5(j) := 'N';
		ELSE
			IF l_lowest_task = 'Y' THEN
				IF l_parent_dirty_flag_tab5(j) <> 'Y' THEN
					l_update_requ_flag_tab5(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab5(j) := 'Y';
					IF P_Derived_Field5 = 'DURATION' THEN
						IF((l_parent_start_date_tab5(j) IS NULL) OR (l_parent_finish_date_tab5(j) IS NULL))
						THEN
							l_update_date_flag_tab5(j) := 'N';
						ELSE
							l_update_date_flag_tab5(j) := 'Y';
							l_parent_duration_tab5(j) := l_parent_finish_date_tab5(j) - l_parent_start_date_tab5(j) +1;
						END IF;
					ELSIF P_Derived_Field5 = 'START' THEN
						IF((l_parent_duration_tab5(j) IS NULL) OR (l_parent_finish_date_tab5(j) IS NULL))
						THEN
							l_update_date_flag_tab5(j) := 'N';
						ELSE
							l_update_date_flag_tab5(j) := 'Y';
							l_parent_start_date_tab5(j) := l_parent_finish_date_tab5(j) - l_parent_duration_tab5(j) +1;
						END IF;
					ELSIF P_Derived_Field5 = 'FINISH' THEN
						IF((l_parent_duration_tab5(j) IS NULL) OR (l_parent_start_date_tab5(j) IS NULL))
						THEN
							l_update_date_flag_tab5(j) := 'Y';
						ELSE
							l_update_date_flag_tab5(j) := 'Y';
							l_parent_finish_date_tab5(j) := l_parent_start_date_tab5(j) + l_parent_duration_tab5(j)-1;
						END IF;
					END IF; -- P_Derived_Field5 = 'DURATION'
				END IF;
			ELSE
				IF l_parent_dirty_flag_tab5(j) <> 'Y' THEN
					l_update_requ_flag_tab5(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab5(j) := 'Y';

					IF l_null_flag5 = 1 THEN
						l_new_completion_date5 := null;
					END IF;
					l_new_start_date5 := NVL(l_parent_start_date_or_tab5(j), l_new_start_date5);
					l_parent_start_date_tab5(j) := l_new_start_date5;
					l_parent_finish_date_tab5(j) := l_new_completion_date5;
					IF l_new_start_date5 IS NULL AND l_new_completion_date5 IS NULL THEN
						l_parent_duration_tab5(j) := null;
					ELSE
						l_parent_duration_tab5(j) := l_new_completion_date5 - l_new_start_date5 +1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab5(j) :='Y';
					ELSE
						IF l_new_start_date5 IS NULL AND l_new_completion_date5 IS NULL THEN
							l_update_date_flag_tab5(j) :='N';
						ELSE
							l_update_date_flag_tab5(j) :='Y';
						END IF;
					END IF;
				END IF;
			END IF; -- l_lowest_task = 'Y'
		END IF; -- l_count5= 1 OR l_task_count5 = 0
		IF l_count6= 1 OR l_task_count6 = 0 THEN
			l_update_requ_flag_tab6(j) := 'N';
		ELSE
			IF l_lowest_task = 'Y' THEN
				IF l_parent_dirty_flag_tab6(j) <> 'Y' THEN
					l_update_requ_flag_tab6(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab6(j) := 'Y';
					IF P_Derived_Field6 = 'DURATION' THEN
						IF((l_parent_start_date_tab6(j) IS NULL) OR (l_parent_finish_date_tab6(j) IS NULL))
						THEN
							l_update_date_flag_tab6(j) := 'N';
						ELSE
							l_update_date_flag_tab6(j) := 'Y';
							l_parent_duration_tab6(j) := l_parent_finish_date_tab6(j) - l_parent_start_date_tab6(j) +1;
						END IF;
					ELSIF P_Derived_Field6 = 'START' THEN
						IF((l_parent_duration_tab6(j) IS NULL) OR (l_parent_finish_date_tab6(j) IS NULL))
						THEN
							l_update_date_flag_tab6(j) := 'N';
						ELSE
							l_update_date_flag_tab6(j) := 'Y';
							l_parent_start_date_tab6(j) := l_parent_finish_date_tab6(j) - l_parent_duration_tab6(j) +1;
						END IF;
					ELSIF P_Derived_Field6 = 'FINISH' THEN
						IF((l_parent_duration_tab6(j) IS NULL) OR (l_parent_start_date_tab6(j) IS NULL))
						THEN
							l_update_date_flag_tab6(j) := 'Y';
						ELSE
							l_update_date_flag_tab6(j) := 'Y';
							l_parent_finish_date_tab6(j) := l_parent_start_date_tab6(j) + l_parent_duration_tab6(j)-1;
						END IF;
					END IF; -- P_Derived_Field6 = 'DURATION'
				END IF;
			ELSE
				IF l_parent_dirty_flag_tab6(j) <> 'Y' THEN
					l_update_requ_flag_tab6(j) := 'N';
				ELSE
					l_parent_update_required := 'Y';
					l_update_requ_flag_tab6(j) := 'Y';

					IF l_null_flag6 = 1 THEN
						l_new_completion_date6 := null;
					END IF;
					l_new_start_date6 := NVL(l_parent_start_date_or_tab6(j), l_new_start_date6);
					l_parent_start_date_tab6(j) := l_new_start_date6;
					l_parent_finish_date_tab6(j) := l_new_completion_date6;
					IF l_new_start_date6 IS NULL AND l_new_completion_date6 IS NULL THEN
						l_parent_duration_tab6(j) := null;
					ELSE
						l_parent_duration_tab6(j) := l_new_completion_date6 - l_new_start_date6 +1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab6(j) :='Y';
					ELSE
						IF l_new_start_date6 IS NULL AND l_new_completion_date6 IS NULL THEN
							l_update_date_flag_tab6(j) :='N';
						ELSE
							l_update_date_flag_tab6(j) :='Y';
						END IF;
					END IF;
				END IF;
			END IF; -- l_lowest_task = 'Y'
		END IF; -- l_count6= 1 OR l_task_count6 = 0

		/* Starts Added the following logic for bug#6185523 */
	IF (l_update_requ_flag_tab1(j) = 'Y') THEN
	   IF (l_update_date_flag_tab1(j) = 'Y') THEN
	      l_parent_start_date1_tmp  := l_parent_start_date_tab1(j);
	      l_parent_finish_date1_tmp := l_parent_finish_date_tab1(j);
              l_parent_duration1_tmp	:= l_parent_duration_tab1(j);
           END IF;
	   dirty_flag1_tmp := 'N';
        END IF;

	IF (l_update_requ_flag_tab2(j) = 'Y') THEN
	   IF (l_update_date_flag_tab2(j) = 'Y') THEN
	      l_parent_start_date2_tmp  := l_parent_start_date_tab2(j);
	      l_parent_finish_date2_tmp := l_parent_finish_date_tab2(j);
              l_parent_duration2_tmp	:= l_parent_duration_tab2(j);
           END IF;
	   dirty_flag2_tmp := 'N';
        END IF;

	IF (l_update_requ_flag_tab3(j) = 'Y') THEN
	   IF (l_update_date_flag_tab3(j) = 'Y') THEN
	      l_parent_start_date3_tmp  := l_parent_start_date_tab3(j);
	      l_parent_finish_date3_tmp := l_parent_finish_date_tab3(j);
              l_parent_duration3_tmp	:= l_parent_duration_tab3(j);
           END IF;
	   dirty_flag3_tmp := 'N';
        END IF;

	IF (l_update_requ_flag_tab4(j) = 'Y') THEN
	   IF (l_update_date_flag_tab4(j) = 'Y') THEN
	      l_parent_start_date4_tmp  := l_parent_start_date_tab4(j);
	      l_parent_finish_date4_tmp := l_parent_finish_date_tab4(j);
              l_parent_duration4_tmp	:= l_parent_duration_tab4(j);
           END IF;
	   dirty_flag4_tmp := 'N';
        END IF;

	IF (l_update_requ_flag_tab5(j) = 'Y') THEN
	   IF (l_update_date_flag_tab5(j) = 'Y') THEN
	      l_parent_start_date5_tmp  := l_parent_start_date_tab5(j);
	      l_parent_finish_date5_tmp := l_parent_finish_date_tab5(j);
              l_parent_duration5_tmp	:= l_parent_duration_tab5(j);
           END IF;
	   dirty_flag5_tmp := 'N';
        END IF;

	IF (l_update_requ_flag_tab6(j) = 'Y') THEN
	   IF (l_update_date_flag_tab6(j) = 'Y') THEN
	      l_parent_start_date6_tmp  := l_parent_start_date_tab6(j);
	      l_parent_finish_date6_tmp := l_parent_finish_date_tab6(j);
              l_parent_duration6_tmp	:= l_parent_duration_tab6(j);
           END IF;
	   dirty_flag6_tmp := 'N';
        END IF;

        /* Ends Added the following logic for bug#6185523 */

		IF l_parent_update_required = 'Y' THEN
		/* Commented the following update statement and introduced a new one for bug#6185523
			UPDATE  + INDEX( SchTmp PA_PROJ_ROLLUP_BULK_TEMP_U1)   PA_PROJ_ROLLUP_BULK_TEMP SchTmp SET
			start_date1  = decode(l_update_requ_flag_tab1(j), 'Y', decode(l_update_date_flag_tab1(j), 'Y', l_parent_start_date_tab1(j), start_date1), start_date1)
			, finish_date1 = decode(l_update_requ_flag_tab1(j), 'Y', decode(l_update_date_flag_tab1(j), 'Y', l_parent_finish_date_tab1(j),finish_date1),finish_date1)
			, duration1    = decode(l_update_requ_flag_tab1(j), 'Y', decode(l_update_date_flag_tab1(j), 'Y', l_parent_duration_tab1(j), duration1), duration1)
			, start_date2  = decode(l_update_requ_flag_tab2(j), 'Y', decode(l_update_date_flag_tab2(j), 'Y', l_parent_start_date_tab2(j), start_date2), start_date2)
			, finish_date2 = decode(l_update_requ_flag_tab2(j), 'Y', decode(l_update_date_flag_tab2(j), 'Y', l_parent_finish_date_tab2(j), finish_date2), finish_date2)
			, duration2    = decode(l_update_requ_flag_tab2(j), 'Y', decode(l_update_date_flag_tab2(j), 'Y', l_parent_duration_tab2(j), duration2), duration2)
			, start_date3  = decode(l_update_requ_flag_tab3(j), 'Y', decode(l_update_date_flag_tab3(j), 'Y', l_parent_start_date_tab3(j), start_date3), start_date3)
			, finish_date3 = decode(l_update_requ_flag_tab3(j), 'Y', decode(l_update_date_flag_tab3(j), 'Y', l_parent_finish_date_tab3(j), finish_date3), finish_date3)
			, duration3    = decode(l_update_requ_flag_tab3(j), 'Y', decode(l_update_date_flag_tab3(j), 'Y', l_parent_duration_tab3(j), duration3), duration3)
			, start_date4  = decode(l_update_requ_flag_tab4(j), 'Y', decode(l_update_date_flag_tab4(j), 'Y', l_parent_start_date_tab4(j), start_date4), start_date4)
			, finish_date4 = decode(l_update_requ_flag_tab4(j), 'Y', decode(l_update_date_flag_tab4(j), 'Y', l_parent_finish_date_tab4(j), finish_date4), finish_date4)
			, duration4    = decode(l_update_requ_flag_tab4(j), 'Y', decode(l_update_date_flag_tab4(j), 'Y', l_parent_duration_tab4(j), duration4), duration4)
			, start_date5  = decode(l_update_requ_flag_tab5(j), 'Y', decode(l_update_date_flag_tab5(j), 'Y', l_parent_start_date_tab5(j), start_date5), start_date5)
			, finish_date5 = decode(l_update_requ_flag_tab5(j), 'Y', decode(l_update_date_flag_tab5(j), 'Y', l_parent_finish_date_tab5(j), finish_date5), finish_date5)
			, duration5    = decode(l_update_requ_flag_tab5(j), 'Y', decode(l_update_date_flag_tab5(j), 'Y', l_parent_duration_tab5(j), duration5), duration5)
			, start_date6  = decode(l_update_requ_flag_tab6(j), 'Y', decode(l_update_date_flag_tab6(j), 'Y', l_parent_start_date_tab6(j), start_date6), start_date6)
			, finish_date6 = decode(l_update_requ_flag_tab6(j), 'Y', decode(l_update_date_flag_tab6(j), 'Y', l_parent_finish_date_tab6(j), finish_date6), finish_date6)
			, duration6    = decode(l_update_requ_flag_tab6(j), 'Y', decode(l_update_date_flag_tab6(j), 'Y', l_parent_duration_tab6(j), duration6), duration6)
			, dirty_flag1  = decode(l_update_requ_flag_tab1(j), 'Y', 'N',dirty_flag1)
			, dirty_flag2  = decode(l_update_requ_flag_tab2(j), 'Y', 'N',dirty_flag2)
			, dirty_flag3  = decode(l_update_requ_flag_tab3(j), 'Y', 'N',dirty_flag3)
			, dirty_flag4  = decode(l_update_requ_flag_tab4(j), 'Y', 'N',dirty_flag4)
			, dirty_flag5  = decode(l_update_requ_flag_tab5(j), 'Y', 'N',dirty_flag5)
			, dirty_flag6  = decode(l_update_requ_flag_tab6(j), 'Y', 'N',dirty_flag6)
			WHERE object_id = l_parent_object_ids_tab(j)
			AND object_type = l_parent_object_types_tab(j)
			and process_number = l_process_number;
			Ends commented code for bug#6185523 And added the below update*/

			UPDATE  /*+ INDEX( SchTmp PA_PROJ_ROLLUP_BULK_TEMP_U1) */  PA_PROJ_ROLLUP_BULK_TEMP SchTmp SET
			  start_date1  = nvl(l_parent_start_date1_tmp, start_date1)
			, finish_date1 = nvl(l_parent_finish_date1_tmp, finish_date1)
			, duration1    = nvl(l_parent_duration1_tmp, duration1)
			, start_date2  = nvl(l_parent_start_date2_tmp, start_date2)
			, finish_date2 = nvl(l_parent_finish_date2_tmp, finish_date2)
			, duration2    = nvl(l_parent_duration2_tmp, duration2)
			, start_date3  = nvl(l_parent_start_date3_tmp, start_date3)
			, finish_date3 = nvl(l_parent_finish_date3_tmp, finish_date3)
			, duration3    = nvl(l_parent_duration3_tmp, duration3)
			, start_date4  = nvl(l_parent_start_date4_tmp, start_date4)
			, finish_date4 = nvl(l_parent_finish_date4_tmp, finish_date4)
			, duration4    = nvl(l_parent_duration4_tmp, duration4)
			, start_date5  = nvl(l_parent_start_date5_tmp, start_date5)
			, finish_date5 = nvl(l_parent_finish_date5_tmp, finish_date5)
			, duration5    = nvl(l_parent_duration5_tmp, duration5)
			, start_date6  = nvl(l_parent_start_date6_tmp, start_date6)
			, finish_date6 = nvl(l_parent_finish_date6_tmp, finish_date6)
			, duration6    = nvl(l_parent_duration6_tmp, duration6)
			, dirty_flag1  = nvl(dirty_flag1_tmp, dirty_flag1)
			, dirty_flag2  = nvl(dirty_flag2_tmp, dirty_flag2)
			, dirty_flag3  = nvl(dirty_flag3_tmp, dirty_flag3)
			, dirty_flag4  = nvl(dirty_flag4_tmp, dirty_flag4)
			, dirty_flag5  = nvl(dirty_flag5_tmp, dirty_flag5)
			, dirty_flag6  = nvl(dirty_flag6_tmp, dirty_flag6)
			WHERE object_id = l_parent_object_ids_tab(j)
			AND object_type = l_parent_object_types_tab(j)
			and process_number = l_process_number;



		END IF;
	END LOOP;

	-- ********* NEW DATES PROCESSING END **********
/*
	-- ********* DATES PROCESSING BEGIN **********

	IF ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'
		OR p_process_flag5 = 'Y' OR p_process_flag6 = 'Y')
		AND(p_process_rollup_flag1 = 'Y' OR p_process_rollup_flag2 = 'Y' OR p_process_rollup_flag3 = 'Y'
		OR p_process_rollup_flag4 = 'Y' OR p_process_rollup_flag5 = 'Y' OR p_process_rollup_flag6 = 'Y'))
	THEN
		l_child_update_required := 'N';

		OPEN lowest_dirty_object_list_dates;
		FETCH lowest_dirty_object_list_dates BULK COLLECT INTO
		l_child_object_ids_tab
		, l_child_object_types_tab
		, l_child_start_date_tab1
		, l_child_start_date_tab2
		, l_child_start_date_tab3
		, l_child_start_date_tab4
		, l_child_start_date_tab5
		, l_child_start_date_tab6
		, l_child_finish_date_tab1
		, l_child_finish_date_tab2
		, l_child_finish_date_tab3
		, l_child_finish_date_tab4
		, l_child_finish_date_tab5
		, l_child_finish_date_tab6
		, l_child_duration_tab1
		, l_child_duration_tab2
		, l_child_duration_tab3
		, l_child_duration_tab4
		, l_child_duration_tab5
		, l_child_duration_tab6
		, l_child_dirty_flag_tab1
		, l_child_dirty_flag_tab2
		, l_child_dirty_flag_tab3
		, l_child_dirty_flag_tab4
		, l_child_dirty_flag_tab5
		, l_child_dirty_flag_tab6
		, l_child_upd_req_flag_tab1
		, l_child_upd_req_flag_tab2
		, l_child_upd_req_flag_tab3
		, l_child_upd_req_flag_tab4
		, l_child_upd_req_flag_tab5
		, l_child_upd_req_flag_tab6
		;
		CLOSE lowest_dirty_object_list_dates;

		IF(P_Process_Dependency_flag1 = 'Y' AND P_Process_Dependency_flag2 = 'Y'
			AND P_Process_Dependency_flag3 = 'Y' AND P_Process_Dependency_flag4 = 'Y'
			AND P_Process_Dependency_flag5 = 'Y' AND P_Process_Dependency_flag6 = 'Y')
		THEN
			l_child_update_required := 'N';
		END IF;


		FOR i IN 1..l_child_object_ids_tab.count LOOP
			IF l_child_dirty_flag_tab1(i) = 'Y' AND P_Process_Dependency_flag1 <> 'Y'
				AND p_process_flag1 = 'Y' AND p_process_rollup_flag1 = 'Y'
			THEN
				IF P_Derived_Field1 = 'DURATION'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_start_date_tab1(i) IS NULL) OR (l_child_finish_date_tab1(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab1(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab1(i) := 'Y';
						l_child_duration_tab1(i) := l_child_finish_date_tab1(i) - l_child_start_date_tab1(i) +1;
					END IF;
				ELSIF P_Derived_Field1 = 'START'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab1(i) IS NULL) OR (l_child_finish_date_tab1(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab1(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab1(i) := 'Y';
						l_child_start_date_tab1(i) := l_child_finish_date_tab1(i) - l_child_duration_tab1(i) +1;
					END IF;
				ELSIF P_Derived_Field1 = 'FINISH'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab1(i) IS NULL) OR (l_child_start_date_tab1(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab1(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab1(i) := 'Y';
						l_child_finish_date_tab1(i) := l_child_start_date_tab1(i) + l_child_duration_tab1(i)-1;
					END IF;
				END IF; -- P_Derived_Field1 = 'DURATION'
			END IF; -- l_child_dirty_flag_tab1(i) AND  THEN
			IF l_child_dirty_flag_tab2(i) = 'Y' AND P_Process_Dependency_flag2 <> 'Y'
				AND p_process_flag2 = 'Y' AND p_process_rollup_flag2 = 'Y'
			THEN
				IF P_Derived_Field2 = 'DURATION'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_start_date_tab2(i) IS NULL) OR (l_child_finish_date_tab2(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab2(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab2(i) := 'Y';
						l_child_duration_tab2(i) := l_child_finish_date_tab2(i) - l_child_start_date_tab2(i) +1;
					END IF;
				ELSIF P_Derived_Field2 = 'START'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab2(i) IS NULL) OR (l_child_finish_date_tab2(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab2(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab2(i) := 'Y';
						l_child_start_date_tab2(i) := l_child_finish_date_tab2(i) - l_child_duration_tab2(i) +1;
					END IF;
				ELSIF P_Derived_Field2 = 'FINISH'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab2(i) IS NULL) OR (l_child_start_date_tab2(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab2(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab2(i) := 'Y';
						l_child_finish_date_tab2(i) := l_child_start_date_tab2(i) + l_child_duration_tab2(i)-1;
					END IF;
				END IF; -- P_Derived_Field2 = 'DURATION'
			END IF; -- l_child_dirty_flag_tab2(i) AND  THEN
			IF l_child_dirty_flag_tab3(i) = 'Y' AND P_Process_Dependency_flag3 <> 'Y'
				AND p_process_flag3 = 'Y' AND p_process_rollup_flag3 = 'Y'
			THEN
				IF P_Derived_Field3 = 'DURATION'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_start_date_tab3(i) IS NULL) OR (l_child_finish_date_tab3(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab3(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab3(i) := 'Y';
						l_child_duration_tab3(i) := l_child_finish_date_tab3(i) - l_child_start_date_tab3(i) +1;
					END IF;
				ELSIF P_Derived_Field3 = 'START'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab3(i) IS NULL) OR (l_child_finish_date_tab3(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab3(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab3(i) := 'Y';
						l_child_start_date_tab3(i) := l_child_finish_date_tab3(i) - l_child_duration_tab3(i) +1;
					END IF;
				ELSIF P_Derived_Field3 = 'FINISH'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab3(i) IS NULL) OR (l_child_start_date_tab3(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab3(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab3(i) := 'Y';
						l_child_finish_date_tab3(i) := l_child_start_date_tab3(i) + l_child_duration_tab3(i)-1;
					END IF;
				END IF; -- P_Derived_Field3 = 'DURATION'
			END IF; -- l_child_dirty_flag_tab3(i) AND  THEN
			IF l_child_dirty_flag_tab4(i) = 'Y' AND P_Process_Dependency_flag4 <> 'Y'
				AND p_process_flag4 = 'Y' AND p_process_rollup_flag4 = 'Y'
			THEN
				IF P_Derived_Field4 = 'DURATION'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_start_date_tab4(i) IS NULL) OR (l_child_finish_date_tab4(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab4(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab4(i) := 'Y';
						l_child_duration_tab4(i) := l_child_finish_date_tab4(i) - l_child_start_date_tab4(i) +1;
					END IF;
				ELSIF P_Derived_Field4 = 'START'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab4(i) IS NULL) OR (l_child_finish_date_tab4(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab4(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab4(i) := 'Y';
						l_child_start_date_tab4(i) := l_child_finish_date_tab4(i) - l_child_duration_tab4(i) +1;
					END IF;
				ELSIF P_Derived_Field4 = 'FINISH'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab4(i) IS NULL) OR (l_child_start_date_tab4(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab4(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab4(i) := 'Y';
						l_child_finish_date_tab4(i) := l_child_start_date_tab4(i) + l_child_duration_tab4(i)-1;
					END IF;
				END IF; -- P_Derived_Field4 = 'DURATION'
			END IF; -- l_child_dirty_flag_tab4(i) AND  THEN
			IF l_child_dirty_flag_tab5(i) = 'Y' AND P_Process_Dependency_flag5 <> 'Y'
				AND p_process_flag5 = 'Y' AND p_process_rollup_flag5 = 'Y'
			THEN
				IF P_Derived_Field5 = 'DURATION'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_start_date_tab5(i) IS NULL) OR (l_child_finish_date_tab5(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab5(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab5(i) := 'Y';
						l_child_duration_tab5(i) := l_child_finish_date_tab5(i) - l_child_start_date_tab5(i) +1;
					END IF;
				ELSIF P_Derived_Field5 = 'START'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab5(i) IS NULL) OR (l_child_finish_date_tab5(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab5(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab5(i) := 'Y';
						l_child_start_date_tab5(i) := l_child_finish_date_tab5(i) - l_child_duration_tab5(i) +1;
					END IF;
				ELSIF P_Derived_Field5 = 'FINISH'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab5(i) IS NULL) OR (l_child_start_date_tab5(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab5(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab5(i) := 'Y';
						l_child_finish_date_tab5(i) := l_child_start_date_tab5(i) + l_child_duration_tab5(i)-1;
					END IF;
				END IF; -- P_Derived_Field5 = 'DURATION'
			END IF; -- l_child_dirty_flag_tab5(i) AND  THEN
			IF l_child_dirty_flag_tab6(i) = 'Y' AND P_Process_Dependency_flag6 <> 'Y'
				AND p_process_flag6 = 'Y' AND p_process_rollup_flag6 = 'Y'
			THEN
				IF P_Derived_Field6 = 'DURATION'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_start_date_tab6(i) IS NULL) OR (l_child_finish_date_tab6(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab6(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab6(i) := 'Y';
						l_child_duration_tab6(i) := l_child_finish_date_tab6(i) - l_child_start_date_tab6(i) +1;
					END IF;
				ELSIF P_Derived_Field6 = 'START'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab6(i) IS NULL) OR (l_child_finish_date_tab6(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab6(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab6(i) := 'Y';
						l_child_start_date_tab6(i) := l_child_finish_date_tab6(i) - l_child_duration_tab6(i) +1;
					END IF;
				ELSIF P_Derived_Field6 = 'FINISH'
				THEN
					l_child_update_required := 'Y';
					IF((l_child_duration_tab6(i) IS NULL) OR (l_child_start_date_tab6(i) IS NULL))
					THEN
						l_child_upd_req_flag_tab6(i) := 'Y';
					ELSE
						l_child_upd_req_flag_tab6(i) := 'Y';
						l_child_finish_date_tab6(i) := l_child_start_date_tab6(i) + l_child_duration_tab6(i)-1;
					END IF;
				END IF; -- P_Derived_Field6 = 'DURATION'
			END IF; -- l_child_dirty_flag_tab6(i) AND  THEN
		END LOOP; -- FOR i IN 1..l_child_object_ids_tab.count LOOP

		IF l_child_update_required = 'Y' THEN
			FORALL i in 1..l_child_object_ids_tab.count
			     UPDATE PA_PROJ_ROLLUP_BULK_TEMP T1
				SET    T1.start_date1=decode(l_child_upd_req_flag_tab1(i), 'Y', l_child_start_date_tab1(i), T1.start_date1)
				, T1.start_date2=decode(l_child_upd_req_flag_tab2(i), 'Y', l_child_start_date_tab2(i), T1.start_date2)
				, T1.start_date3=decode(l_child_upd_req_flag_tab3(i), 'Y', l_child_start_date_tab3(i), T1.start_date3)
				, T1.start_date4=decode(l_child_upd_req_flag_tab4(i), 'Y', l_child_start_date_tab4(i), T1.start_date4)
				, T1.start_date5=decode(l_child_upd_req_flag_tab5(i), 'Y', l_child_start_date_tab5(i), T1.start_date5)
				, T1.start_date6=decode(l_child_upd_req_flag_tab6(i), 'Y', l_child_start_date_tab6(i), T1.start_date6)
				, T1.finish_date1=decode(l_child_upd_req_flag_tab1(i), 'Y', l_child_finish_date_tab1(i), T1.finish_date1)
				, T1.finish_date2=decode(l_child_upd_req_flag_tab2(i), 'Y', l_child_finish_date_tab2(i), T1.finish_date2)
				, T1.finish_date3=decode(l_child_upd_req_flag_tab3(i), 'Y', l_child_finish_date_tab3(i), T1.finish_date3)
				, T1.finish_date4=decode(l_child_upd_req_flag_tab4(i), 'Y', l_child_finish_date_tab4(i), T1.finish_date4)
				, T1.finish_date5=decode(l_child_upd_req_flag_tab5(i), 'Y', l_child_finish_date_tab5(i), T1.finish_date5)
				, T1.finish_date6=decode(l_child_upd_req_flag_tab6(i), 'Y', l_child_finish_date_tab6(i), T1.finish_date6)
				, T1.duration1=decode(l_child_upd_req_flag_tab1(i), 'Y', l_child_duration_tab1(i), T1.duration1)
				, T1.duration2=decode(l_child_upd_req_flag_tab2(i), 'Y', l_child_duration_tab2(i), T1.duration2)
				, T1.duration3=decode(l_child_upd_req_flag_tab3(i), 'Y', l_child_duration_tab3(i), T1.duration3)
				, T1.duration4=decode(l_child_upd_req_flag_tab4(i), 'Y', l_child_duration_tab4(i), T1.duration4)
				, T1.duration5=decode(l_child_upd_req_flag_tab5(i), 'Y', l_child_duration_tab5(i), T1.duration5)
				, T1.duration6=decode(l_child_upd_req_flag_tab6(i), 'Y', l_child_duration_tab6(i), T1.duration6)
				, T1.DIRTY_FLAG1=decode(l_child_upd_req_flag_tab1(i), 'Y', 'N', T1.DIRTY_FLAG1)
				, T1.DIRTY_FLAG2=decode(l_child_upd_req_flag_tab2(i), 'Y', 'N', T1.DIRTY_FLAG2)
				, T1.DIRTY_FLAG3=decode(l_child_upd_req_flag_tab3(i), 'Y', 'N', T1.DIRTY_FLAG3)
				, T1.DIRTY_FLAG4=decode(l_child_upd_req_flag_tab4(i), 'Y', 'N', T1.DIRTY_FLAG4)
				, T1.DIRTY_FLAG5=decode(l_child_upd_req_flag_tab5(i), 'Y', 'N', T1.DIRTY_FLAG5)
				, T1.DIRTY_FLAG6=decode(l_child_upd_req_flag_tab6(i), 'Y', 'N', T1.DIRTY_FLAG6)
			       WHERE T1.object_id = l_child_object_ids_tab(i)
				 AND T1.object_type = l_child_object_types_tab(i)
				AND process_number = l_Process_Number;
		END IF;

		l_object_ids_tab.delete;
		l_object_types_tab.delete;

		FOR i IN 1..l_child_object_ids_tab.count LOOP
			l_parent_object_ids_tab.delete;
			l_parent_object_types_tab.delete;
			l_parent_start_date_tab1.delete;
			l_parent_start_date_tab2.delete;
			l_parent_start_date_tab3.delete;
			l_parent_start_date_tab4.delete;
			l_parent_start_date_tab5.delete;
			l_parent_start_date_tab6.delete;
			l_parent_finish_date_tab1.delete;
			l_parent_finish_date_tab2.delete;
			l_parent_finish_date_tab3.delete;
			l_parent_finish_date_tab4.delete;
			l_parent_finish_date_tab5.delete;
			l_parent_finish_date_tab6.delete;
			l_parent_duration_tab1.delete;
			l_parent_duration_tab2.delete;
			l_parent_duration_tab3.delete;
			l_parent_duration_tab4.delete;
			l_parent_duration_tab5.delete;
			l_parent_duration_tab6.delete;
			l_parent_dirty_flag_tab1.delete;
			l_parent_dirty_flag_tab2.delete;
			l_parent_dirty_flag_tab3.delete;
			l_parent_dirty_flag_tab4.delete;
			l_parent_dirty_flag_tab5.delete;
			l_parent_dirty_flag_tab6.delete;
			l_parent_start_date_or_tab1.delete;
			l_parent_start_date_or_tab2.delete;
			l_parent_start_date_or_tab3.delete;
                        l_parent_start_date_or_tab4.delete;
			l_parent_start_date_or_tab5.delete;
			l_parent_start_date_or_tab6.delete;


			OPEN dirty_Parent_List(l_child_object_ids_tab(i));
			FETCH dirty_Parent_List BULK COLLECT INTO
			l_parent_object_ids_tab
			, l_parent_object_types_tab
			, l_parent_start_date_tab1
			, l_parent_start_date_tab2
			, l_parent_start_date_tab3
			, l_parent_start_date_tab4
			, l_parent_start_date_tab5
			, l_parent_start_date_tab6
			, l_parent_finish_date_tab1
			, l_parent_finish_date_tab2
			, l_parent_finish_date_tab3
			, l_parent_finish_date_tab4
			, l_parent_finish_date_tab5
			, l_parent_finish_date_tab6
			, l_parent_duration_tab1
			, l_parent_duration_tab2
			, l_parent_duration_tab3
			, l_parent_duration_tab4
			, l_parent_duration_tab5
			, l_parent_duration_tab6
			, l_parent_dirty_flag_tab1
			, l_parent_dirty_flag_tab2
			, l_parent_dirty_flag_tab3
			, l_parent_dirty_flag_tab4
			, l_parent_dirty_flag_tab5
			, l_parent_dirty_flag_tab6
			, l_parent_start_date_or_tab1
			, l_parent_start_date_or_tab2
			, l_parent_start_date_or_tab3
                        , l_parent_start_date_or_tab4
			, l_parent_start_date_or_tab5
			, l_parent_start_date_or_tab6;
			CLOSE dirty_Parent_List;

			-- We have two approached to update dates at parent level
			-- 1. Do FORALL Bulk Update. But this will require to do Connect BY at each node to drill down all its child, grand child ...
			-- Currently it is just looking its childs and not grand ones
			-- 2. Update at each node level in database and do not do bulk update.
			-- Currently implementing this approach as it seems more performant.

			For j IN 1..l_parent_object_ids_tab.count LOOP
				BEGIN
					l_count1 := 1;
					l_count2 := 1;
					l_count3 := 1;
					l_count4 := 1;
					l_count5 := 1;
					l_count6 := 1;

					SELECT MAX(decode(p_partial_dates_flag1, 'Y',decode(rollup_node1, 'Y', decode(dirty_flag1,'Y',1,0), 0),decode(dirty_flag1,'Y',1,0)))
					, MAX(decode(p_partial_dates_flag2, 'Y',decode(rollup_node2, 'Y', decode(dirty_flag2,'Y',1,0), 0),decode(dirty_flag2,'Y',1,0)))
					, MAX(decode(p_partial_dates_flag3, 'Y',decode(rollup_node3, 'Y', decode(dirty_flag3,'Y',1,0), 0),decode(dirty_flag3,'Y',1,0)))
					, MAX(decode(p_partial_dates_flag4, 'Y',decode(rollup_node4, 'Y', decode(dirty_flag4,'Y',1,0), 0),decode(dirty_flag4,'Y',1,0)))
					, MAX(decode(p_partial_dates_flag5, 'Y',decode(rollup_node5, 'Y', decode(dirty_flag5,'Y',1,0), 0),decode(dirty_flag5,'Y',1,0)))
					, MAX(decode(p_partial_dates_flag6, 'Y',decode(rollup_node6, 'Y', decode(dirty_flag6,'Y',1,0), 0),decode(dirty_flag6,'Y',1,0)))
					INTO l_count1, l_count2, l_count3, l_count4, l_count5, l_count6
					FROM PA_PROJ_ROLLUP_BULK_TEMP
					WHERE PROCESS_NUMBER = l_process_number
					AND parent_object_id = l_parent_object_ids_tab(j)
					AND (DIRTY_FLAG1 = 'Y' OR DIRTY_FLAG2 = 'Y'  OR DIRTY_FLAG3 = 'Y'
						OR DIRTY_FLAG4 = 'Y' OR DIRTY_FLAG5 = 'Y' OR DIRTY_FLAG6 = 'Y')
						;
				EXCEPTION
					WHEN OTHERS THEN
						l_count1 := 0;
						l_count2 := 0;
						l_count3 := 0;
						l_count4 := 0;
						l_count5 := 0;
						l_count6 := 0;
				End;

				IF p_process_flag1 <> 'Y' AND p_process_rollup_flag1 <> 'Y' THEN
					l_count1 := 1;
				END IF;
				IF p_process_flag2 <> 'Y' AND p_process_rollup_flag2 <> 'Y' THEN
					l_count2 := 1;
				END IF;
				IF p_process_flag3 <> 'Y' AND p_process_rollup_flag3 <> 'Y' THEN
					l_count3 := 1;
				END IF;
				IF p_process_flag4 <> 'Y' AND p_process_rollup_flag4 <> 'Y' THEN
					l_count4 := 1;
				END IF;
				IF p_process_flag5 <> 'Y' AND p_process_rollup_flag5 <> 'Y' THEN
					l_count5 := 1;
				END IF;
				IF p_process_flag6 <> 'Y' AND p_process_rollup_flag6 <> 'Y' THEN
					l_count6 := 1;
				END IF;

				IF l_count1 <> 0 AND l_count2 <> 0 AND l_count3 <> 0 AND l_count4 <> 0
					AND l_count5 <> 0 AND l_count6 <> 0
				THEN
					EXIT;
				ELSE
					-- There is extra tables created here.
					-- We could have used the parent tables itself.
					-- This is kept as it is so in future if want to move to FOR ALL BULK UPDATE

					l_object_ids_tab.extend(1);
					l_object_types_tab.extend(1);
					l_update_date_flag_tab1.extend(1);
					l_update_date_flag_tab2.extend(1);
					l_update_date_flag_tab3.extend(1);
					l_update_date_flag_tab4.extend(1);
					l_update_date_flag_tab5.extend(1);
					l_update_date_flag_tab6.extend(1);
					l_new_start_date1.extend(1);
					l_new_start_date2.extend(1);
					l_new_start_date3.extend(1);
					l_new_start_date4.extend(1);
					l_new_start_date5.extend(1);
					l_new_start_date6.extend(1);
					l_new_completion_date1.extend(1);
					l_new_completion_date2.extend(1);
					l_new_completion_date3.extend(1);
					l_new_completion_date4.extend(1);
					l_new_completion_date5.extend(1);
					l_new_completion_date6.extend(1);
					l_new_duration1.extend(1);
					l_new_duration2.extend(1);
					l_new_duration3.extend(1);
					l_new_duration4.extend(1);
					l_new_duration5.extend(1);
					l_new_duration6.extend(1);
					l_update_requ_flag_tab1.extend(1);
					l_update_requ_flag_tab2.extend(1);
					l_update_requ_flag_tab3.extend(1);
					l_update_requ_flag_tab4.extend(1);
					l_update_requ_flag_tab5.extend(1);
					l_update_requ_flag_tab6.extend(1);
					l_counter := l_object_ids_tab.count;
					l_object_ids_tab(l_counter) := l_parent_object_ids_tab(j);
					l_object_types_tab(l_counter) := l_parent_object_types_tab(j);
					l_new_start_date1(l_counter) := l_parent_start_date_tab1(j);
					l_new_start_date2(l_counter) := l_parent_start_date_tab2(j);
					l_new_start_date3(l_counter) := l_parent_start_date_tab3(j);
					l_new_start_date4(l_counter) := l_parent_start_date_tab4(j);
					l_new_start_date5(l_counter) := l_parent_start_date_tab5(j);
					l_new_start_date6(l_counter) := l_parent_start_date_tab6(j);
					l_new_completion_date1(l_counter) := l_parent_finish_date_tab1(j);
					l_new_completion_date2(l_counter) := l_parent_finish_date_tab2(j);
					l_new_completion_date3(l_counter) := l_parent_finish_date_tab3(j);
					l_new_completion_date4(l_counter) := l_parent_finish_date_tab4(j);
					l_new_completion_date5(l_counter) := l_parent_finish_date_tab5(j);
					l_new_completion_date6(l_counter) := l_parent_finish_date_tab6(j);
					l_new_duration1(l_counter) := l_parent_duration_tab1(j);
					l_new_duration2(l_counter) := l_parent_duration_tab2(j);
					l_new_duration3(l_counter) := l_parent_duration_tab3(j);
					l_new_duration4(l_counter) := l_parent_duration_tab4(j);
					l_new_duration5(l_counter) := l_parent_duration_tab5(j);
					l_new_duration6(l_counter) := l_parent_duration_tab6(j);
					l_parent_update_required := 'N';

					BEGIN
						l_task_flag := 0;
						l_task_count1 := 0;
						l_task_count2 := 0;
						l_task_count3 := 0;
						l_task_count4 := 0;
						l_task_count5 := 0;
						l_task_count6 := 0;
						l_null_flag1 := 0;
						l_null_flag2 := 0;
						l_null_flag3 := 0;
						l_null_flag4 := 0;
						l_null_flag5 := 0;
						l_null_flag6 := 0;

						SELECT
							MIN(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', start_date1, null), start_date1))
							, MAX(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', finish_date1, null), finish_date1))
							, MAX(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', DECODE(finish_date1,NULL,1,0), 0), 0))
							, MAX(decode(p_partial_dates_flag1, 'Y', decode(rollup_node1, 'Y', 1, 0), 1))
							, MIN(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', start_date2, null), null))
							, MAX(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', finish_date2, null), null))
							, MAX(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', DECODE(finish_date2,NULL,1,0), 0), 0))
							, MAX(decode(p_partial_dates_flag2, 'Y', decode(rollup_node2, 'Y', 1, 0), 1))
							, MIN(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', start_date3, null), null))
							, MAX(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', finish_date3, null), null))
							, MAX(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', DECODE(finish_date3,NULL,1,0), 0), 0))
							, MAX(decode(p_partial_dates_flag3, 'Y', decode(rollup_node3, 'Y', 1, 0), 1))
							, MIN(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', start_date4, null), null))
							, MAX(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', finish_date4, null), null))
							, MAX(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', DECODE(finish_date4,NULL,1,0), 0), 0))
							, MAX(decode(p_partial_dates_flag4, 'Y', decode(rollup_node4, 'Y', 1, 0), 1))
							, MIN(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', start_date5, null), null))
							, MAX(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', finish_date5, null), null))
							, MAX(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', DECODE(finish_date5,NULL,1,0), 0), 0))
							, MAX(decode(p_partial_dates_flag5, 'Y', decode(rollup_node5, 'Y', 1, 0), 1))
							, MIN(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', start_date6, null), null))
							, MAX(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', finish_date6, null), null))
							, MAX(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', DECODE(finish_date6,NULL,1,0), 0), 0))
							, MAX(decode(p_partial_dates_flag6, 'Y', decode(rollup_node6, 'Y', 1, 0), 1))
							, MAX(DECODE(OBJECT_TYPE,'PA_TASKS',1,0))

						INTO
							l_new_start_date1(l_counter)
							, l_new_completion_date1(l_counter)
							, l_null_flag1
							, l_task_count1
							, l_new_start_date2(l_counter)
							, l_new_completion_date2(l_counter)
							, l_null_flag2
							, l_task_count2
							, l_new_start_date3(l_counter)
							, l_new_completion_date3(l_counter)
							, l_null_flag3
							, l_task_count3
							, l_new_start_date4(l_counter)
							, l_new_completion_date4(l_counter)
							, l_null_flag4
							, l_task_count4
							, l_new_start_date5(l_counter)
							, l_new_completion_date5(l_counter)
							, l_null_flag5
							, l_task_count5
							, l_new_start_date6(l_counter)
							, l_new_completion_date6(l_counter)
							, l_null_flag6
							, l_task_count6
							, l_task_flag
						FROM PA_PROJ_ROLLUP_BULK_TEMP
						WHERE PROCESS_NUMBER = l_process_number
						AND parent_object_id = l_parent_object_ids_tab(j);
					EXCEPTION
						WHEN OTHERS THEN
							l_task_flag := 0;
							l_task_count1 := 0;
							l_task_count2 := 0;
							l_task_count3 := 0;
							l_task_count4 := 0;
							l_task_count5 := 0;
							l_task_count6 := 0;
					END;
				END IF; -- l_count1= 0 AND l_count2 = 0 AND l_count3 = 0 AND l_count4 = 0

				IF l_count1= 1 OR l_task_count1 = 0 THEN
					l_update_requ_flag_tab1(l_counter) := 'N';
				ELSE
					IF l_null_flag1 = 1 THEN
						l_new_completion_date1(l_counter) := null;
					END IF;
					l_new_start_date1(l_counter) := NVL(l_parent_start_date_or_tab1(j), l_new_start_date1(l_counter));

					IF l_new_start_date1(l_counter) IS NULL AND l_new_completion_date1(l_counter) IS NULL THEN
						l_new_duration1(l_counter) := null;
					ELSE
						l_new_duration1(l_counter) := l_new_completion_date1(l_counter) - l_new_start_date1(l_counter) +1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab1(l_counter) :='Y';
					ELSE
						IF l_new_start_date1(l_counter) IS NULL AND l_new_completion_date1(l_counter) IS NULL THEN
							l_update_date_flag_tab1(l_counter) :='N';
						ELSE
							l_update_date_flag_tab1(l_counter) :='Y';
						END IF;
					END IF;

					IF l_child_dirty_flag_tab1(i) <> 'Y' OR l_parent_dirty_flag_tab1(j) <> 'Y' THEN
						l_update_requ_flag_tab1(l_counter) := 'N';
					ELSE
						l_update_requ_flag_tab1(l_counter) := 'Y';
						l_parent_update_required := 'Y';
					END IF;
				END IF; -- l_task_count1 = 0
				IF l_count2= 1 OR l_task_count2 = 0 THEN
					l_update_requ_flag_tab2(l_counter) := 'N';
				ELSE
					IF l_null_flag2 = 1 THEN
						l_new_completion_date2(l_counter) := null;
					END IF;
					l_new_start_date2(l_counter) := NVL(l_parent_start_date_or_tab2(j), l_new_start_date2(l_counter));

					IF l_new_start_date2(l_counter) IS NULL AND l_new_completion_date2(l_counter) IS NULL THEN
						l_new_duration2(l_counter) := null;
					ELSE
						l_new_duration2(l_counter) := l_new_completion_date2(l_counter) - l_new_start_date2(l_counter)+1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab2(l_counter) :='Y';
					ELSE
						IF l_new_start_date2(l_counter) IS NULL AND l_new_completion_date2(l_counter) IS NULL THEN
							l_update_date_flag_tab2(l_counter) :='N';
						ELSE
							l_update_date_flag_tab2(l_counter) :='Y';
						END IF;
					END IF;

					IF l_child_dirty_flag_tab2(i) <> 'Y' OR l_parent_dirty_flag_tab2(j) <> 'Y' THEN
						l_update_requ_flag_tab2(l_counter) := 'N';
					ELSE
						l_update_requ_flag_tab2(l_counter) := 'Y';
						l_parent_update_required := 'Y';
					END IF;
				END IF; -- l_task_count2 = 0
				IF l_count3= 1 OR l_task_count3 = 0 THEN
					l_update_requ_flag_tab3(l_counter) := 'N';
				ELSE
					IF l_null_flag3 = 1 THEN
						l_new_completion_date3(l_counter) := null;
					END IF;
					l_new_start_date3(l_counter) := NVL(l_parent_start_date_or_tab3(j), l_new_start_date3(l_counter));

					IF l_new_start_date3(l_counter) IS NULL AND l_new_completion_date3(l_counter) IS NULL THEN
						l_new_duration3(l_counter) := null;
					ELSE
						l_new_duration3(l_counter) := l_new_completion_date3(l_counter) - l_new_start_date3(l_counter)+1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab3(l_counter) :='Y';
					ELSE
						IF l_new_start_date3(l_counter) IS NULL AND l_new_completion_date3(l_counter) IS NULL THEN
							l_update_date_flag_tab3(l_counter) :='N';
						ELSE
							l_update_date_flag_tab3(l_counter) :='Y';
						END IF;
					END IF;

					IF l_child_dirty_flag_tab3(i) <> 'Y' OR l_parent_dirty_flag_tab3(j) <> 'Y' THEN
						l_update_requ_flag_tab3(l_counter) := 'N';
					ELSE
						l_update_requ_flag_tab3(l_counter) := 'Y';
						l_parent_update_required := 'Y';
					END IF;
				END IF; -- l_task_count3 = 0
				IF l_count4 = 1 OR l_task_count4 = 0 THEN
					l_update_requ_flag_tab4(l_counter) := 'N';
				ELSE
					IF l_null_flag4 = 1 THEN
						l_new_completion_date4(l_counter) := null;
					END IF;
					l_new_start_date4(l_counter) := NVL(l_parent_start_date_or_tab4(j), l_new_start_date4(l_counter));

					IF l_new_start_date4(l_counter) IS NULL AND l_new_completion_date4(l_counter) IS NULL THEN
						l_new_duration4(l_counter) := null;
					ELSE
						l_new_duration4(l_counter) := l_new_completion_date4(l_counter) - l_new_start_date4(l_counter)+1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab4(l_counter) :='Y';
					ELSE
						IF l_new_start_date4(l_counter) IS NULL AND l_new_completion_date4(l_counter) IS NULL THEN
							l_update_date_flag_tab4(l_counter) :='N';
						ELSE
							l_update_date_flag_tab4(l_counter) :='Y';
						END IF;
					END IF;

					IF l_child_dirty_flag_tab4(i) <> 'Y' OR l_parent_dirty_flag_tab4(j) <> 'Y' THEN
						l_update_requ_flag_tab4(l_counter) := 'N';
					ELSE
						l_update_requ_flag_tab4(l_counter) := 'Y';
						l_parent_update_required := 'Y';
					END IF;
				END IF; -- l_task_count4 = 0
				IF l_count5 = 1 OR l_task_count5 = 0 THEN
					l_update_requ_flag_tab5(l_counter) := 'N';
				ELSE
					IF l_null_flag5 = 1 THEN
						l_new_completion_date5(l_counter) := null;
					END IF;
					l_new_start_date5(l_counter) := NVL(l_parent_start_date_or_tab5(j), l_new_start_date5(l_counter));

					IF l_new_start_date5(l_counter) IS NULL AND l_new_completion_date5(l_counter) IS NULL THEN
						l_new_duration5(l_counter) := null;
					ELSE
						l_new_duration5(l_counter) := l_new_completion_date5(l_counter) - l_new_start_date5(l_counter)+1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab5(l_counter) :='Y';
					ELSE
						IF l_new_start_date5(l_counter) IS NULL AND l_new_completion_date5(l_counter) IS NULL THEN
							l_update_date_flag_tab5(l_counter) :='N';
						ELSE
							l_update_date_flag_tab5(l_counter) :='Y';
						END IF;
					END IF;

					IF l_child_dirty_flag_tab5(i) <> 'Y' OR l_parent_dirty_flag_tab5(j) <> 'Y' THEN
						l_update_requ_flag_tab5(l_counter) := 'N';
					ELSE
						l_update_requ_flag_tab5(l_counter) := 'Y';
						l_parent_update_required := 'Y';
					END IF;
				END IF; -- l_task_count5 = 0
				IF l_count6 = 1 OR l_task_count6 = 0 THEN
					l_update_requ_flag_tab6(l_counter) := 'N';
				ELSE
					IF l_null_flag6 = 1 THEN
						l_new_completion_date6(l_counter) := null;
					END IF;
					l_new_start_date6(l_counter) := NVL(l_parent_start_date_or_tab6(j), l_new_start_date6(l_counter));

					IF l_new_start_date6(l_counter) IS NULL AND l_new_completion_date6(l_counter) IS NULL THEN
						l_new_duration6(l_counter) := null;
					ELSE
						l_new_duration6(l_counter) := l_new_completion_date6(l_counter) - l_new_start_date6(l_counter)+1;
					END IF;

					IF l_task_flag = 1 THEN
						l_update_date_flag_tab6(l_counter) :='Y';
					ELSE
						IF l_new_start_date6(l_counter) IS NULL AND l_new_completion_date6(l_counter) IS NULL THEN
							l_update_date_flag_tab6(l_counter) :='N';
						ELSE
							l_update_date_flag_tab6(l_counter) :='Y';
						END IF;
					END IF;

					IF l_child_dirty_flag_tab6(i) <> 'Y' OR l_parent_dirty_flag_tab6(j) <> 'Y' THEN
						l_update_requ_flag_tab6(l_counter) := 'N';
					ELSE
						l_update_requ_flag_tab6(l_counter) := 'Y';
						l_parent_update_required := 'Y';
					END IF;
				END IF; -- l_task_count6 = 0
				-- We have two approached to update dates at parent level
				-- 1. Do FORALL Bulk Update. But this will require to do Connect BY at each node to drill down all its child, grand child ...
				-- Currently it is just looking its childs and not grand ones
				-- 2. Update at each node level in database and do not do bulk update.
				-- Currently implementing this approach as it seems more performant.

				IF l_parent_update_required = 'Y' THEN
					UPDATE PA_PROJ_ROLLUP_BULK_TEMP SET
					start_date1  = decode(l_update_requ_flag_tab1(l_counter), 'Y', decode(l_update_date_flag_tab1(l_counter), 'Y', l_new_start_date1(l_counter), start_date1),start_date1)
					, finish_date1 = decode(l_update_requ_flag_tab1(l_counter), 'Y', decode(l_update_date_flag_tab1(l_counter), 'Y', l_new_completion_date1(l_counter),finish_date1),finish_date1)
					, duration1    = decode(l_update_requ_flag_tab1(l_counter), 'Y', decode(l_update_date_flag_tab1(l_counter), 'Y', l_new_duration1(l_counter), duration1), duration1)
					, start_date2  = decode(l_update_requ_flag_tab2(l_counter), 'Y', decode(l_update_date_flag_tab2(l_counter), 'Y', l_new_start_date2(l_counter), start_date2), start_date2)
					, finish_date2 = decode(l_update_requ_flag_tab2(l_counter), 'Y', decode(l_update_date_flag_tab2(l_counter), 'Y', l_new_completion_date2(l_counter), finish_date2), finish_date2)
					, duration2    = decode(l_update_requ_flag_tab2(l_counter), 'Y', decode(l_update_date_flag_tab2(l_counter), 'Y', l_new_duration2(l_counter), duration2), duration2)
					, start_date3  = decode(l_update_requ_flag_tab3(l_counter), 'Y', decode(l_update_date_flag_tab3(l_counter), 'Y', l_new_start_date3(l_counter), start_date3), start_date3)
					, finish_date3 = decode(l_update_requ_flag_tab3(l_counter), 'Y', decode(l_update_date_flag_tab3(l_counter), 'Y', l_new_completion_date3(l_counter), finish_date3), finish_date3)
					, duration3    = decode(l_update_requ_flag_tab3(l_counter), 'Y', decode(l_update_date_flag_tab3(l_counter), 'Y', l_new_duration3(l_counter), duration3), duration3)
					, start_date4  = decode(l_update_requ_flag_tab4(l_counter), 'Y', decode(l_update_date_flag_tab4(l_counter), 'Y', l_new_start_date4(l_counter), start_date4), start_date4)
					, finish_date4 = decode(l_update_requ_flag_tab4(l_counter), 'Y', decode(l_update_date_flag_tab4(l_counter), 'Y', l_new_completion_date4(l_counter), finish_date4), finish_date4)
					, duration4    = decode(l_update_requ_flag_tab4(l_counter), 'Y', decode(l_update_date_flag_tab4(l_counter), 'Y', l_new_duration4(l_counter), duration4), duration4)
					, start_date5  = decode(l_update_requ_flag_tab5(l_counter), 'Y', decode(l_update_date_flag_tab5(l_counter), 'Y', l_new_start_date5(l_counter), start_date5), start_date5)
					, finish_date5 = decode(l_update_requ_flag_tab5(l_counter), 'Y', decode(l_update_date_flag_tab5(l_counter), 'Y', l_new_completion_date5(l_counter), finish_date5), finish_date5)
					, duration5    = decode(l_update_requ_flag_tab5(l_counter), 'Y', decode(l_update_date_flag_tab5(l_counter), 'Y', l_new_duration5(l_counter), duration5), duration5)
					, start_date6  = decode(l_update_requ_flag_tab6(l_counter), 'Y', decode(l_update_date_flag_tab6(l_counter), 'Y', l_new_start_date6(l_counter), start_date6), start_date6)
					, finish_date6 = decode(l_update_requ_flag_tab6(l_counter), 'Y', decode(l_update_date_flag_tab6(l_counter), 'Y', l_new_completion_date6(l_counter), finish_date6), finish_date6)
					, duration6    = decode(l_update_requ_flag_tab6(l_counter), 'Y', decode(l_update_date_flag_tab6(l_counter), 'Y', l_new_duration6(l_counter), duration6), duration6)
					, dirty_flag1  = decode(l_update_requ_flag_tab1(l_counter), 'Y', 'N', dirty_flag1)
					, dirty_flag2  = decode(l_update_requ_flag_tab2(l_counter), 'Y', 'N', dirty_flag2)
					, dirty_flag3  = decode(l_update_requ_flag_tab3(l_counter), 'Y', 'N', dirty_flag3)
					, dirty_flag4  = decode(l_update_requ_flag_tab4(l_counter), 'Y', 'N', dirty_flag4)
					, dirty_flag5  = decode(l_update_requ_flag_tab5(l_counter), 'Y', 'N', dirty_flag5)
					, dirty_flag6  = decode(l_update_requ_flag_tab6(l_counter), 'Y', 'N', dirty_flag6)
					WHERE object_id = l_object_ids_tab(l_counter)
					AND object_type = l_object_types_tab(l_counter)
					and process_number = l_process_number;
				END IF;
			END LOOP; -- For j IN 1..l_parent_object_ids_tab.count LOOP
		END LOOP; -- FOR i IN 1..l_child_object_ids_tab.count LOOP

		-- We have two approached to update dates at parent level
		-- 1. Do FORALL Bulk Update. But this will require to do Connect BY at each node to drill down all its child, grand child ...
		-- Currently it is just looking its childs and not grand ones
		-- 2. Update at each node level in database and do not do bulk update.
		-- Currently implementing this approach as it seems more performant.
		/* Do not remove
		IF l_parent_update_required = 'Y' THEN
                FORALL k in 1..l_object_ids_tab.count
			UPDATE PA_PROJ_ROLLUP_BULK_TEMP SET
			start_date1  = decode(l_update_requ_flag_tab1(k), 'Y', decode(l_update_date_flag_tab1(k), 'Y', l_new_start_date1(k), start_date1),start_date1)
			, finish_date1 = decode(l_update_requ_flag_tab1(k), 'Y', decode(l_update_date_flag_tab1(k), 'Y', l_new_completion_date1(k),finish_date1),finish_date1)
			, duration1    = decode(l_update_requ_flag_tab1(k), 'Y', decode(l_update_date_flag_tab1(k), 'Y', l_new_duration1(k), duration1), duration1)
			, start_date2  = decode(l_update_requ_flag_tab2(k), 'Y', decode(l_update_date_flag_tab2(k), 'Y', l_new_start_date2(k), start_date2), start_date2)
			, finish_date2 = decode(l_update_requ_flag_tab2(k), 'Y', decode(l_update_date_flag_tab2(k), 'Y', l_new_completion_date2(k), finish_date2), finish_date2)
			, duration2    = decode(l_update_requ_flag_tab2(k), 'Y', decode(l_update_date_flag_tab2(k), 'Y', l_new_duration2(k), duration2), duration2)
			, start_date3  = decode(l_update_requ_flag_tab3(k), 'Y', decode(l_update_date_flag_tab3(k), 'Y', l_new_start_date3(k), start_date3), start_date3)
			, finish_date3 = decode(l_update_requ_flag_tab3(k), 'Y', decode(l_update_date_flag_tab3(k), 'Y', l_new_completion_date3(k), finish_date3), finish_date3)
			, duration3    = decode(l_update_requ_flag_tab3(k), 'Y', decode(l_update_date_flag_tab3(k), 'Y', l_new_duration3(k), duration3), duration3)
			, start_date4  = decode(l_update_requ_flag_tab4(k), 'Y', decode(l_update_date_flag_tab4(k), 'Y', l_new_start_date4(k), start_date4), start_date4)
			, finish_date4 = decode(l_update_requ_flag_tab4(k), 'Y', decode(l_update_date_flag_tab4(k), 'Y', l_new_completion_date4(k), finish_date4), finish_date4)
			, duration4    = decode(l_update_requ_flag_tab4(k), 'Y', decode(l_update_date_flag_tab4(k), 'Y', l_new_duration4(k), duration4), duration4)
			, start_date5  = decode(l_update_requ_flag_tab5(k), 'Y', decode(l_update_date_flag_tab5(k), 'Y', l_new_start_date5(k), start_date5), start_date5)
			, finish_date5 = decode(l_update_requ_flag_tab5(k), 'Y', decode(l_update_date_flag_tab5(k), 'Y', l_new_completion_date5(k), finish_date5), finish_date5)
			, duration5    = decode(l_update_requ_flag_tab5(k), 'Y', decode(l_update_date_flag_tab5(k), 'Y', l_new_duration5(k), duration5), duration5)
			, start_date6  = decode(l_update_requ_flag_tab6(k), 'Y', decode(l_update_date_flag_tab6(k), 'Y', l_new_start_date6(k), start_date6), start_date6)
			, finish_date6 = decode(l_update_requ_flag_tab6(k), 'Y', decode(l_update_date_flag_tab6(k), 'Y', l_new_completion_date6(k), finish_date6), finish_date6)
			, duration6    = decode(l_update_requ_flag_tab6(k), 'Y', decode(l_update_date_flag_tab6(k), 'Y', l_new_duration6(k), duration6), duration6)
			, dirty_flag1  = decode(l_update_requ_flag_tab1(k), 'Y', 'N', dirty_flag1)
			, dirty_flag2  = decode(l_update_requ_flag_tab2(k), 'Y', 'N', dirty_flag2)
			, dirty_flag3  = decode(l_update_requ_flag_tab3(k), 'Y', 'N', dirty_flag3)
			, dirty_flag4  = decode(l_update_requ_flag_tab4(k), 'Y', 'N', dirty_flag4)
			, dirty_flag5  = decode(l_update_requ_flag_tab5(k), 'Y', 'N', dirty_flag5)
			, dirty_flag6  = decode(l_update_requ_flag_tab6(k), 'Y', 'N', dirty_flag6)
			WHERE object_id = l_object_ids_tab(k)
			AND object_type = l_object_types_tab(k)
			and process_number = l_process_number;
		END IF; -- l_parent_update_required = 'Y'

	END IF; -- ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'

	-- ********* DATES PROCESSING END ***********
		*/
	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After Date processing', x_Log_Level=> 3);
        END IF;


	-- ********* EFFORT PROCESSING BEGIN **********
	-- Bug 4218507 : Effort Processing has been merged with ETC Cost processing
	-- ********* EFFORT PROCESSING END ***********


	-- ********* PROGRESS STATUS PROCESSING BEGIN ***********

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before Progress Status processing', x_Log_Level=> 3);
        END IF;


	IF ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'
		OR p_process_flag5 = 'Y' OR p_process_flag6 = 'Y')
		AND(p_process_progress_flag1 = 'Y' OR p_process_progress_flag2 = 'Y' OR p_process_progress_flag3 = 'Y'
		OR p_process_progress_flag4 = 'Y' OR p_process_progress_flag5 = 'Y' OR p_process_progress_flag6 = 'Y'))
	THEN
		l_object_ids_tab.delete;
		l_object_types_tab.delete;
		l_sum_tab1.delete;
		l_sum_tab2.delete;
		l_sum_tab3.delete;
		l_sum_tab4.delete;
		l_sum_tab5.delete;
		l_sum_tab6.delete;
		l_update_required := 'N';


 	        IF g1_debug_mode  = 'Y' THEN
			pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before data fetch', x_Log_Level=> 3);
		END IF;

		OPEN Parent_Objects_List_prog_sts;
		FETCH Parent_Objects_List_prog_sts BULK COLLECT INTO l_object_ids_tab, l_object_types_tab
		, l_sum_tab1, l_sum_tab2, l_sum_tab3, l_sum_tab4, l_sum_tab5, l_sum_tab6;
		CLOSE Parent_Objects_List_prog_sts;

		IF g1_debug_mode  = 'Y' THEN
			pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Afetr data fetch', x_Log_Level=> 3);
		END IF;

		FOR i IN 1..l_object_ids_tab.count LOOP
			l_Weight1 := null;
			l_Weight2 := null;
			l_Weight3 := null;
			l_Weight4 := null;
			l_Weight5 := null;
			l_Weight6 := null;
			l_Count := 0;

			BEGIN
				IF l_partial_rollup1 OR l_partial_rollup2 OR l_partial_rollup3
				   OR l_partial_rollup4 OR l_partial_rollup5 OR l_partial_rollup6
				THEN
					SELECT MAX(decode(rollup_node1, 'Y', nvl(PROGRESS_OVERRIDE1, nvl(PROGRESS_STATUS_WEIGHT1, -99)), -99))
						, MAX(decode(rollup_node2, 'Y', nvl(PROGRESS_OVERRIDE2, nvl(PROGRESS_STATUS_WEIGHT2, -99)), -99))
						, MAX(decode(rollup_node3, 'Y', nvl(PROGRESS_OVERRIDE3, nvl(PROGRESS_STATUS_WEIGHT3, -99)), -99))
						, MAX(decode(rollup_node4, 'Y', nvl(PROGRESS_OVERRIDE4, nvl(PROGRESS_STATUS_WEIGHT4, -99)), -99))
						, MAX(decode(rollup_node5, 'Y', nvl(PROGRESS_OVERRIDE5, nvl(PROGRESS_STATUS_WEIGHT5, -99)), -99))
						, MAX(decode(rollup_node6, 'Y', nvl(PROGRESS_OVERRIDE6, nvl(PROGRESS_STATUS_WEIGHT6, -99)), -99))
						, count(*)
					INTO   l_weight1, l_weight2, l_weight3, l_weight4, l_weight5, l_weight6, l_count
					FROM   PA_PROJ_ROLLUP_BULK_TEMP
					WHERE  PROCESS_NUMBER   = l_process_number
					AND    Parent_Object_ID = l_object_ids_tab(i)
					--AND    OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES', 'PA_DELIVERABLES', 'PA_SUBPROJECTS')
					-- 4366733 : Deliverable Progress Status should not rollup
					AND    OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES', 'PA_SUBPROJECTS')
					;
				ELSE
					SELECT MAX(nvl(PROGRESS_OVERRIDE1, nvl(PROGRESS_STATUS_WEIGHT1, -99)))
						, MAX(nvl(PROGRESS_OVERRIDE2, nvl(PROGRESS_STATUS_WEIGHT2, -99)))
						, MAX(nvl(PROGRESS_OVERRIDE3, nvl(PROGRESS_STATUS_WEIGHT3, -99)))
						, MAX(nvl(PROGRESS_OVERRIDE4, nvl(PROGRESS_STATUS_WEIGHT4, -99)))
						, MAX(nvl(PROGRESS_OVERRIDE5, nvl(PROGRESS_STATUS_WEIGHT5, -99)))
						, MAX(nvl(PROGRESS_OVERRIDE6, nvl(PROGRESS_STATUS_WEIGHT6, -99)))
						, count(*)
					INTO   l_weight1, l_weight2, l_weight3, l_weight4, l_weight5, l_weight6, l_count
					FROM   PA_PROJ_ROLLUP_BULK_TEMP
					WHERE  PROCESS_NUMBER   = l_process_number
					AND    Parent_Object_ID = l_object_ids_tab(i)
					--AND    OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES', 'PA_DELIVERABLES','PA_SUBPROJECTS')
					-- 4366733 : Deliverable Progress Status should not rollup
					AND    OBJECT_TYPE IN ('PA_TASKS', 'PA_STRUCTURES', 'PA_SUBPROJECTS')
					;
				END IF; -- l_partial_rollup1 OR ..

			EXCEPTION
				WHEN OTHERS THEN
					l_Weight1 := null;
					l_Weight2 := null;
					l_Weight3 := null;
					l_Weight4 := null;
					l_Weight5 := null;
					l_Weight6 := null;
					l_Count := 0;
			END;

			IF l_Count = 0 THEN
				null;
			ELSE
				IF(l_weight1 = -99) Then
					l_weight1 := null;
				END IF;

				IF(l_weight2 = -99) Then
					l_weight2 := null;
				END IF;

				IF(l_weight3 = -99) Then
					l_weight3 := null;
				END IF;

				IF(l_weight4 = -99) Then
					l_weight4 := null;
				END IF;

				IF(l_weight5 = -99) Then
					l_weight5 := null;
				END IF;

				IF(l_weight6 = -99) Then
					l_weight6 := null;
				END IF;

				l_update_required := 'Y';

				IF p_process_flag1 = 'Y' and p_process_progress_flag1 = 'Y' THEN
					l_sum_tab1(i) := l_Weight1;
				END IF;
				IF p_process_flag2 = 'Y' and p_process_progress_flag2 = 'Y' THEN
					l_sum_tab2(i) := l_Weight2;
				END IF;
				IF p_process_flag3 = 'Y' and p_process_progress_flag3 = 'Y' THEN
					l_sum_tab3(i) := l_Weight3;
				END IF;
				IF p_process_flag4 = 'Y' and p_process_progress_flag4 = 'Y' THEN
					l_sum_tab4(i) := l_Weight4;
				END IF;
				IF p_process_flag5 = 'Y' and p_process_progress_flag5 = 'Y' THEN
					l_sum_tab5(i) := l_Weight5;
				END IF;
				IF p_process_flag6 = 'Y' and p_process_progress_flag6 = 'Y' THEN
					l_sum_tab6(i) := l_Weight6;
				END IF;
			END IF;
			IF l_update_required = 'Y' THEN
	      /* Added the hint to force the unique index for bug#6185523 */
		   		UPDATE  /*+ INDEX( T1 PA_PROJ_ROLLUP_BULK_TEMP_U1) */ PA_PROJ_ROLLUP_BULK_TEMP T1
				SET    T1.PROGRESS_STATUS_WEIGHT1=l_sum_tab1(i)
				, T1.PROGRESS_STATUS_WEIGHT2=l_sum_tab2(i)
				, T1.PROGRESS_STATUS_WEIGHT3=l_sum_tab3(i)
				, T1.PROGRESS_STATUS_WEIGHT4=l_sum_tab4(i)
				, T1.PROGRESS_STATUS_WEIGHT5=l_sum_tab5(i)
				, T1.PROGRESS_STATUS_WEIGHT6=l_sum_tab6(i)
			       WHERE T1.Process_Number = l_Process_Number
				 AND T1.object_id = l_object_ids_tab(i)
				 AND T1.object_type = l_object_types_tab(i)
				;
			END IF;
		END LOOP; -- i IN 1..l_object_ids_tab.count LOOP
		-- Note that Bulk Update is not implemented due to the reasons mentioned in Date Rollup section
		/* Please Do no remove
		IF l_update_required = 'Y' THEN
		   FORALL i in 1..l_object_ids_tab.count
		     UPDATE PA_PROJ_ROLLUP_BULK_TEMP T1
			SET    T1.PROGRESS_STATUS_WEIGHT1=l_sum_tab1(i)
			, T1.PROGRESS_STATUS_WEIGHT2=l_sum_tab2(i)
			, T1.PROGRESS_STATUS_WEIGHT3=l_sum_tab3(i)
			, T1.PROGRESS_STATUS_WEIGHT4=l_sum_tab4(i)
			, T1.PROGRESS_STATUS_WEIGHT5=l_sum_tab5(i)
			, T1.PROGRESS_STATUS_WEIGHT6=l_sum_tab6(i)
		       WHERE T1.Process_Number = l_Process_Number
			 AND T1.object_id = l_object_ids_tab(i)
			 AND T1.object_type = l_object_types_tab(i)
		      ;
		END IF; -- l_update_required = 'Y' THEN
		*/
	END IF; -- ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After Progress Status processing', x_Log_Level=> 3);
        END IF;

	-- ********* PROGRESS STATUS PROCESSING END **************

	-- ********* TASK STATUS PROCESSING BEGIN **************

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before Task Status processing', x_Log_Level=> 3);
        END IF;


	IF ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'
		OR p_process_flag5 = 'Y' OR p_process_flag6 = 'Y')
		AND(p_process_task_status_flag1 = 'Y' OR p_process_task_status_flag2 = 'Y' OR p_process_task_status_flag3 = 'Y'
	        OR p_process_task_status_flag4 = 'Y' OR p_process_task_status_flag5 = 'Y' OR p_process_task_status_flag6 = 'Y'))
	THEN
		l_object_ids_tab.delete;
		l_object_types_tab.delete;
		l_sum_tab1.delete;
		l_sum_tab2.delete;
		l_sum_tab3.delete;
		l_sum_tab4.delete;
		l_sum_tab5.delete;
		l_sum_tab6.delete;
		l_update_required := 'N';

		OPEN parent_objects_list_task_sts;
		FETCH parent_objects_list_task_sts BULK COLLECT INTO
			l_object_ids_tab, l_object_types_tab, l_sum_tab1
			, l_sum_tab2, l_sum_tab3, l_sum_tab4, l_sum_tab5, l_sum_tab6;
		CLOSE parent_objects_list_task_sts;

		FOR i IN 1..l_object_ids_tab.count LOOP
			l_update_required := 'N';
			l_count       := 0;
			l_task_status_tab1.delete;
			l_task_status_tab2.delete;
			l_task_status_tab3.delete;
			l_task_status_tab4.delete;
			l_task_status_tab5.delete;
			l_task_status_tab6.delete;

			IF l_partial_rollup1 OR l_partial_rollup2 OR l_partial_rollup3
			   OR l_partial_rollup4 OR l_partial_rollup5 OR l_partial_rollup6
			THEN
				OPEN Child_Task_Status_partial(l_object_ids_tab(i));
				FETCH Child_Task_Status_partial BULK COLLECT INTO l_task_status_tab1
				,l_task_status_tab2, l_task_status_tab3
				, l_task_status_tab4, l_task_status_tab5, l_task_status_tab6;
				CLOSE Child_Task_Status_partial;
			ELSE
				OPEN Child_Task_Status_full(l_object_ids_tab(i));
				FETCH Child_Task_Status_full BULK COLLECT INTO l_task_status_tab1
				,l_task_status_tab2, l_task_status_tab3
				, l_task_status_tab4, l_task_status_tab5, l_task_status_tab6;
				CLOSE Child_Task_Status_full;
			END IF; -- l_partial_rollup1 OR ..

				l_not_started := 'N';
				l_completed   := 'N';
				l_in_progress := 'N';
				l_on_hold     := 'N';

				FOR j IN 1..l_task_status_tab1.count LOOP
					IF (l_task_status_tab1(j) = '0') THEN
						l_on_hold     := 'Y';
					ELSIF (l_task_status_tab1(j) = '10') THEN
						l_not_started := 'Y';
					ELSIF (l_task_status_tab1(j) = '20') THEN
						l_completed   := 'Y';
					ELSIF (l_task_status_tab1(j) = '30') THEN
						l_in_progress := 'Y';
					END IF;
				END LOOP;


				IF p_process_flag1 = 'Y' AND p_process_task_status_flag1 = 'Y'
					AND l_task_status_tab1.count > 0
				THEN
					l_update_required := 'Y';
					l_weight := PA_SCHEDULE_OBJECTS_PVT.GET_PROGRESS_STATUS(
						 p_not_started  		=> l_not_started
						,p_completed  			=> l_completed
						,p_in_progress 			=> l_in_progress
						,p_on_hold  			=> l_on_hold);
					l_sum_tab1(i) := l_weight;
				END IF;


				l_not_started := 'N';
				l_completed   := 'N';
				l_in_progress := 'N';
				l_on_hold     := 'N';

				FOR j IN 1..l_task_status_tab2.count LOOP
					IF (l_task_status_tab2(j) = '0') THEN
						l_on_hold     := 'Y';
					ELSIF (l_task_status_tab2(j) = '10') THEN
						l_not_started := 'Y';
					ELSIF (l_task_status_tab2(j) = '20') THEN
						l_completed   := 'Y';
					ELSIF (l_task_status_tab2(j) = '30') THEN
						l_in_progress := 'Y';
					END IF;
				END LOOP;

				IF p_process_flag2 = 'Y' AND p_process_task_status_flag2 = 'Y'
					AND l_task_status_tab2.count > 0
				THEN
					l_update_required := 'Y';
					l_weight := PA_SCHEDULE_OBJECTS_PVT.GET_PROGRESS_STATUS(
							 p_not_started  		=> l_not_started
							,p_completed  			=> l_completed
							,p_in_progress 			=> l_in_progress
							,p_on_hold  			=> l_on_hold);
					l_sum_tab2(i) := l_weight;
				END IF;

				l_not_started := 'N';
				l_completed   := 'N';
				l_in_progress := 'N';
				l_on_hold     := 'N';

				FOR j IN 1..l_task_status_tab3.count LOOP
					IF (l_task_status_tab3(j) = '0') THEN
						l_on_hold     := 'Y';
					ELSIF (l_task_status_tab3(j) = '10') THEN
						l_not_started := 'Y';
					ELSIF (l_task_status_tab3(j) = '20') THEN
						l_completed   := 'Y';
					ELSIF (l_task_status_tab3(j) = '30') THEN
						l_in_progress := 'Y';
					END IF;
				END LOOP;

				IF p_process_flag3 = 'Y' AND p_process_task_status_flag3 = 'Y'
					AND l_task_status_tab3.count > 0
				THEN
					l_update_required := 'Y';
					l_weight := PA_SCHEDULE_OBJECTS_PVT.GET_PROGRESS_STATUS(
							 p_not_started  		=> l_not_started
							,p_completed  			=> l_completed
							,p_in_progress 			=> l_in_progress
							,p_on_hold  			=> l_on_hold);
					l_sum_tab3(i) := l_weight;
				END IF;

				l_not_started := 'N';
				l_completed   := 'N';
				l_in_progress := 'N';
				l_on_hold     := 'N';

				FOR j IN 1..l_task_status_tab4.count LOOP
					IF (l_task_status_tab4(j) = '0') THEN
						l_on_hold     := 'Y';
					ELSIF (l_task_status_tab4(j) = '10') THEN
						l_not_started := 'Y';
					ELSIF (l_task_status_tab4(j) = '20') THEN
						l_completed   := 'Y';
					ELSIF (l_task_status_tab4(j) = '30') THEN
						l_in_progress := 'Y';
					END IF;
				END LOOP;

				IF p_process_flag4 = 'Y' AND p_process_task_status_flag4 = 'Y'
					AND l_task_status_tab4.count > 0
				THEN
					l_update_required := 'Y';
					l_weight := PA_SCHEDULE_OBJECTS_PVT.GET_PROGRESS_STATUS(
							 p_not_started  		=> l_not_started
							,p_completed  			=> l_completed
							,p_in_progress 			=> l_in_progress
							,p_on_hold  			=> l_on_hold);
					l_sum_tab4(i) := l_weight;
				END IF;

				l_not_started := 'N';
				l_completed   := 'N';
				l_in_progress := 'N';
				l_on_hold     := 'N';

				FOR j IN 1..l_task_status_tab5.count LOOP
					IF (l_task_status_tab5(j) = '0') THEN
						l_on_hold     := 'Y';
					ELSIF (l_task_status_tab5(j) = '10') THEN
						l_not_started := 'Y';
					ELSIF (l_task_status_tab5(j) = '20') THEN
						l_completed   := 'Y';
					ELSIF (l_task_status_tab5(j) = '30') THEN
						l_in_progress := 'Y';
					END IF;
				END LOOP;

				IF p_process_flag5 = 'Y' AND p_process_task_status_flag5 = 'Y'
					AND l_task_status_tab5.count > 0
				THEN
					l_update_required := 'Y';
					l_weight := PA_SCHEDULE_OBJECTS_PVT.GET_PROGRESS_STATUS(
							 p_not_started  		=> l_not_started
							,p_completed  			=> l_completed
							,p_in_progress 			=> l_in_progress
							,p_on_hold  			=> l_on_hold);
					l_sum_tab5(i) := l_weight;
				END IF;

				l_not_started := 'N';
				l_completed   := 'N';
				l_in_progress := 'N';
				l_on_hold     := 'N';

				FOR j IN 1..l_task_status_tab6.count LOOP
					IF (l_task_status_tab6(j) = '0') THEN
						l_on_hold     := 'Y';
					ELSIF (l_task_status_tab6(j) = '10') THEN
						l_not_started := 'Y';
					ELSIF (l_task_status_tab6(j) = '20') THEN
						l_completed   := 'Y';
					ELSIF (l_task_status_tab6(j) = '30') THEN
						l_in_progress := 'Y';
					END IF;
				END LOOP;

				IF p_process_flag6 = 'Y' AND p_process_task_status_flag6 = 'Y'
					AND l_task_status_tab6.count > 0
				THEN
					l_update_required := 'Y';
					l_weight := PA_SCHEDULE_OBJECTS_PVT.GET_PROGRESS_STATUS(
							 p_not_started  		=> l_not_started
							,p_completed  			=> l_completed
							,p_in_progress 			=> l_in_progress
							,p_on_hold  			=> l_on_hold);
					l_sum_tab6(i) := l_weight;
				END IF;

				IF l_update_required = 'Y' THEN
				      /* Added the hint to force the unique index for bug#6185523 */
					UPDATE /*+ INDEX( T1 PA_PROJ_ROLLUP_BULK_TEMP_U1) */ PA_PROJ_ROLLUP_BULK_TEMP T1
					SET    T1.TASK_STATUS1= l_sum_tab1(i)
					, T1.TASK_STATUS2=l_sum_tab2(i)
					, T1.TASK_STATUS3=l_sum_tab3(i)
					, T1.TASK_STATUS4=l_sum_tab4(i)
					, T1.TASK_STATUS5=l_sum_tab5(i)
					, T1.TASK_STATUS6=l_sum_tab6(i)
					WHERE T1.Process_Number = l_Process_Number
					AND T1.object_id = l_object_ids_tab(i)
					AND T1.object_type = l_object_types_tab(i);
				END IF;
		END LOOP; -- i IN 1..l_object_ids_tab.count LOOP
		-- Note that Bulk Update is not implemented due to the reasons mentioned in Date Rollup section
		/* Please Do no remove
		IF l_update_required = 'Y' THEN
		   FORALL i in 1..l_object_ids_tab.count
	             UPDATE PA_PROJ_ROLLUP_BULK_TEMP T1
		        SET    T1.TASK_STATUS1= l_sum_tab1(i)
			, T1.TASK_STATUS2=l_sum_tab2(i)
			, T1.TASK_STATUS3=l_sum_tab3(i)
			, T1.TASK_STATUS4=l_sum_tab4(i)
			, T1.TASK_STATUS5=l_sum_tab5(i)
			, T1.TASK_STATUS6=l_sum_tab6(i)
	               WHERE T1.Process_Number = l_Process_Number
	                 AND T1.object_id = l_object_ids_tab(i)
	                 AND T1.object_type = l_object_types_tab(i)
		      ;
		END IF; -- l_update_required = 'Y' THEN
		*/
	END IF; -- ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After Task Status processing', x_Log_Level=> 3);
        END IF;


	-- ********* TASK STATUS PROCESSING END  **************

	-- ********* PERCENT COMPLETE PROCESSING BEGIN ***********

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before % Complete processing', x_Log_Level=> 3);
        END IF;

	IF ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'
		OR p_process_flag5 = 'Y' OR p_process_flag6 = 'Y')
	     AND(p_process_percent_flag1 = 'Y' OR p_process_percent_flag2 = 'Y' OR p_process_percent_flag3 = 'Y'
	         OR p_process_percent_flag4 = 'Y' OR p_process_percent_flag5 = 'Y' OR p_process_percent_flag6 = 'Y'))
	THEN
		l_object_ids_tab.delete;
		l_object_types_tab.delete;
		l_perc_comp_deriv_code_tab.delete;
		l_bac_value_tab1.delete;
		l_bac_value_tab2.delete;
		l_bac_value_tab3.delete;
		l_bac_value_tab4.delete;
		l_bac_value_tab5.delete;
		l_bac_value_tab6.delete;
		l_percent_complete_tab1.delete;
		l_percent_complete_tab2.delete;
		l_percent_complete_tab3.delete;
		l_percent_complete_tab4.delete;
		l_percent_complete_tab5.delete;
		l_percent_complete_tab6.delete;
		l_percent_override_tab1.delete;
		l_percent_override_tab2.delete;
		l_percent_override_tab3.delete;
		l_percent_override_tab4.delete;
		l_percent_override_tab5.delete;
		l_percent_override_tab6.delete;
		l_earned_value_tab1.delete;
		l_earned_value_tab2.delete;
		l_earned_value_tab3.delete;
		l_earned_value_tab4.delete;
		l_earned_value_tab5.delete;
		l_earned_value_tab6.delete;
		l_update_required := 'N';

		OPEN lowest_tasks_per_comp;
		FETCH lowest_tasks_per_comp bulk collect into l_object_ids_tab, l_object_types_tab, l_perc_comp_deriv_code_tab
		, l_bac_value_tab1, l_bac_value_tab2, l_bac_value_tab3, l_bac_value_tab4, l_bac_value_tab5, l_bac_value_tab6
		, l_percent_complete_tab1, l_percent_complete_tab2, l_percent_complete_tab3, l_percent_complete_tab4
		, l_percent_complete_tab5, l_percent_complete_tab6, l_percent_override_tab1, l_percent_override_tab2
		, l_percent_override_tab3, l_percent_override_tab4, l_percent_override_tab5, l_percent_override_tab6
		, l_earned_value_tab1, l_earned_value_tab2, l_earned_value_tab3, l_earned_value_tab4, l_earned_value_tab5
		, l_earned_value_tab6;
		CLOSE lowest_tasks_per_comp;


		FOR i IN 1..l_object_ids_tab.count LOOP
			l_actual_duration1 := 0;
			l_pc_duration1 := 0;
			l_actual_duration2 := 0;
			l_pc_duration2 := 0;
			l_actual_duration3 := 0;
			l_pc_duration3 := 0;
			l_actual_duration4 := 0;
			l_pc_duration4 := 0;
			l_actual_duration5 := 0;
			l_pc_duration5 := 0;
			l_actual_duration6 := 0;
			l_pc_duration6 := 0;
			l_Count := 0;

			IF (l_perc_comp_deriv_code_tab(i) = 'DELIVERABLE') THEN
				BEGIN
					-- Note that % complete calculation does not currently uses rollup_node feature
                        --  l_actual_duration is devided by 100, added by rtarway for bug 4216030
					SELECT sum(nvl(percent_override1, nvl(percent_complete1, 0))*nvl(task_weight1, 0))/100,
					  sum(nvl(task_weight1, 0)),
					  sum(nvl(percent_override2, nvl(percent_complete2, 0))*nvl(task_weight2, 0))/100,
					  sum(nvl(task_weight2, 0)),
					  sum(nvl(percent_override3, nvl(percent_complete3, 0))*nvl(task_weight3, 0))/100,
					  sum(nvl(task_weight3, 0)),
					  sum(nvl(percent_override4, nvl(percent_complete4, 0))*nvl(task_weight4, 0))/100,
					  sum(nvl(task_weight4, 0)),
					  sum(nvl(percent_override5, nvl(percent_complete5, 0))*nvl(task_weight5, 0))/100,
					  sum(nvl(task_weight5, 0)),
					  sum(nvl(percent_override6, nvl(percent_complete6, 0))*nvl(task_weight6, 0))/100,
					  sum(nvl(task_weight6, 0)),
					  count(*)
					INTO   l_actual_duration1, l_pc_duration1
					, l_actual_duration2, l_pc_duration2
					, l_actual_duration3, l_pc_duration3
					, l_actual_duration4, l_pc_duration4
					, l_actual_duration5, l_pc_duration5
					, l_actual_duration6, l_pc_duration6
					, l_count
					FROM   PA_PROJ_ROLLUP_BULK_TEMP
					WHERE  Process_Number    = l_Process_Number
					AND    OBJECT_TYPE = 'PA_DELIVERABLES'
					AND    Parent_Object_ID  = l_object_ids_tab(i)
					AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
					;
				EXCEPTION
					WHEN OTHERS THEN
					l_count := 0;
				END;
			ELSIF (l_perc_comp_deriv_code_tab(i)  IN ('COST','EFFORT')) THEN
				BEGIN
					select sum(nvl(earned_value1, 0)), sum(nvl(bac_value1, 0))
					, sum(nvl(earned_value2, 0)), sum(nvl(bac_value2, 0))
					, sum(nvl(earned_value3, 0)), sum(nvl(bac_value3, 0))
					, sum(nvl(earned_value4, 0)), sum(nvl(bac_value4, 0))
					, sum(nvl(earned_value5, 0)), sum(nvl(bac_value5, 0))
					, sum(nvl(earned_value6, 0)), sum(nvl(bac_value6, 0))
					,  count(*)
					INTO   l_actual_duration1, l_pc_duration1
					, l_actual_duration2, l_pc_duration2
					, l_actual_duration3, l_pc_duration3
					, l_actual_duration4, l_pc_duration4
					, l_actual_duration5, l_pc_duration5
					, l_actual_duration6, l_pc_duration6
					, l_count
					FROM   PA_PROJ_ROLLUP_BULK_TEMP
					WHERE  Process_Number    = l_Process_Number
					AND    OBJECT_TYPE IN ('PA_ASSIGNMENTS', 'PA_SUBPROJECTS')
					AND    Parent_Object_ID  = l_object_ids_tab(i)
					AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
					;
				EXCEPTION
					WHEN OTHERS THEN
						l_count := 0;
				END;
			END IF;	-- (l_perc_comp_deriv_code_tab(i) = 'DELIVERABLE') THEN

			IF (l_count > 0) THEN
				-- 4579654 : For more accuracy, we will first derive the earned value and then
				-- round the % complete.
				IF p_process_flag1 = 'Y' and p_process_percent_flag1 = 'Y' THEN
					l_update_required := 'Y';
							IF (l_pc_duration1 = 0 AND l_actual_duration1 > 0) THEN
					      l_percent_complete_tab1(i) := 100;  /* Added for bug 7409515 */
					ELSIF
            (l_pc_duration1 = 0 OR (l_actual_duration1 < 0 and l_pc_duration1 > 0) OR (l_actual_duration1 > 0 and l_pc_duration1 < 0)) THEN --OR added for BUG 4346107 --5463690
						l_percent_complete_tab1(i) := 0;
					ELSE
						--l_percent_complete_tab1(i) := round(100*l_actual_duration1/l_pc_duration1, p_number_digit);
						l_percent_complete_tab1(i) := 100*l_actual_duration1/l_pc_duration1;
						if l_percent_complete_tab1(i) > 100 then   --5726773
 	                                                    l_percent_complete_tab1(i) := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab1(i) := nvl(l_bac_value_tab1(i), 0)*nvl(l_percent_override_tab1(i), l_percent_complete_tab1(i))/100;
					l_percent_complete_tab1(i) := round(l_percent_complete_tab1(i), p_number_digit);
				END IF;
				IF p_process_flag2 = 'Y' and p_process_percent_flag2 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration2 = 0 OR (l_actual_duration2 < 0 and l_pc_duration2 > 0) OR (l_actual_duration2 > 0 and l_pc_duration2 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab2(i) := 0;
					ELSE
						--l_percent_complete_tab2(i) := round(100*l_actual_duration2/l_pc_duration2, p_number_digit);
						l_percent_complete_tab2(i) := 100*l_actual_duration2/l_pc_duration2;
						if l_percent_complete_tab2(i) > 100 then   --5726773
 	                                                    l_percent_complete_tab2(i) := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab2(i) := nvl(l_bac_value_tab2(i), 0)*nvl(l_percent_override_tab2(i), l_percent_complete_tab2(i))/100;
					l_percent_complete_tab2(i) := round(l_percent_complete_tab2(i), p_number_digit);
				END IF;
				IF p_process_flag3 = 'Y' and p_process_percent_flag3 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration3 = 0 OR (l_actual_duration3 < 0 and l_pc_duration3 > 0) OR (l_actual_duration3 > 0 and l_pc_duration3 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab3(i) := 0;
					ELSE
						--l_percent_complete_tab3(i) := round(100*l_actual_duration3/l_pc_duration3, p_number_digit);
						l_percent_complete_tab3(i) := 100*l_actual_duration3/l_pc_duration3;
						if l_percent_complete_tab3(i) > 100 then   --5726773
 	                                                    l_percent_complete_tab3(i) := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab3(i) := nvl(l_bac_value_tab3(i), 0)*nvl(l_percent_override_tab3(i), l_percent_complete_tab3(i))/100;
					l_percent_complete_tab3(i) := round(l_percent_complete_tab3(i), p_number_digit);
				END IF;
				IF p_process_flag4 = 'Y' and p_process_percent_flag4 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration4 = 0 OR (l_actual_duration4 < 0 and l_pc_duration4 > 0) OR (l_actual_duration4 > 0 and l_pc_duration4 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab4(i) := 0;
					ELSE
						--l_percent_complete_tab4(i) := round(100*l_actual_duration4/l_pc_duration4, p_number_digit);
						l_percent_complete_tab4(i) := 100*l_actual_duration4/l_pc_duration4;
						if l_percent_complete_tab4(i) > 100 then   --5726773
 	                                                    l_percent_complete_tab4(i) := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab4(i) := nvl(l_bac_value_tab4(i), 0)*nvl(l_percent_override_tab4(i), l_percent_complete_tab4(i))/100;
					l_percent_complete_tab4(i) := round(l_percent_complete_tab4(i), p_number_digit);
				END IF;
				IF p_process_flag5 = 'Y' and p_process_percent_flag5 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration5 = 0 OR (l_actual_duration5 < 0 and l_pc_duration5 > 0) OR (l_actual_duration5 > 0 and l_pc_duration5 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab5(i) := 0;
					ELSE
						--l_percent_complete_tab5(i) := round(100*l_actual_duration5/l_pc_duration5, p_number_digit);
						l_percent_complete_tab5(i) := 100*l_actual_duration5/l_pc_duration5;
						if l_percent_complete_tab5(i) > 100 then   --5726773
 	                                                    l_percent_complete_tab5(i) := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab5(i) := nvl(l_bac_value_tab5(i), 0)*nvl(l_percent_override_tab5(i), l_percent_complete_tab5(i))/100;
					l_percent_complete_tab5(i) := round(l_percent_complete_tab5(i), p_number_digit);
				END IF;
				IF p_process_flag6 = 'Y' and p_process_percent_flag6 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration6 = 0 OR (l_actual_duration6 < 0 and l_pc_duration6 > 0) OR (l_actual_duration6 > 0 and l_pc_duration6 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab6(i) := 0;
					ELSE
						--l_percent_complete_tab6(i) := round(100*l_actual_duration6/l_pc_duration6, p_number_digit);
						l_percent_complete_tab6(i) := 100*l_actual_duration6/l_pc_duration6;
						if l_percent_complete_tab6(i) > 100 then   --5726773
 	                                                    l_percent_complete_tab6(i) := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab6(i) := nvl(l_bac_value_tab6(i), 0)*nvl(l_percent_override_tab6(i), l_percent_complete_tab6(i))/100;
					l_percent_complete_tab6(i) := round(l_percent_complete_tab6(i), p_number_digit);
				END IF;
			ELSE -- IF l_count > 0
				IF p_process_flag1 = 'Y' and p_process_percent_flag1 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab1(i) := nvl(l_bac_value_tab1(i), 0)*nvl(l_percent_override_tab1(i), nvl(l_percent_complete_tab1(i),0))/100;
				END IF;
				IF p_process_flag2 = 'Y' and p_process_percent_flag2 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab2(i) := nvl(l_bac_value_tab2(i), 0)*nvl(l_percent_override_tab2(i), nvl(l_percent_complete_tab2(i),0))/100;
				END IF;
				IF p_process_flag3 = 'Y' and p_process_percent_flag3 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab3(i) := nvl(l_bac_value_tab3(i), 0)*nvl(l_percent_override_tab3(i), nvl(l_percent_complete_tab3(i),0))/100;
				END IF;
				IF p_process_flag4 = 'Y' and p_process_percent_flag4 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab4(i) := nvl(l_bac_value_tab4(i), 0)*nvl(l_percent_override_tab4(i), nvl(l_percent_complete_tab4(i),0))/100;
				END IF;
				IF p_process_flag5 = 'Y' and p_process_percent_flag5 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab5(i) := nvl(l_bac_value_tab5(i), 0)*nvl(l_percent_override_tab5(i), nvl(l_percent_complete_tab5(i),0))/100;
				END IF;
				IF p_process_flag6 = 'Y' and p_process_percent_flag6 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab6(i) := nvl(l_bac_value_tab6(i), 0)*nvl(l_percent_override_tab6(i), nvl(l_percent_complete_tab6(i),0))/100;
				END IF;
			END IF; -- (l_count > 0) THEN
		END LOOP; -- i IN 1..l_object_ids_tab.count LOOP

		IF l_update_required = 'Y' THEN
			FORALL i in 1..l_object_ids_tab.count
	      /* Added the hint to force the unique index for bug#6185523 */
			UPDATE  /*+ INDEX( T1 PA_PROJ_ROLLUP_BULK_TEMP_U1) */ PA_PROJ_ROLLUP_BULK_TEMP T1
			SET    t1.percent_complete1=l_percent_complete_tab1(i)
			, t1.percent_complete2=l_percent_complete_tab2(i)
			, t1.percent_complete3=l_percent_complete_tab3(i)
			, t1.percent_complete4=l_percent_complete_tab4(i)
			, t1.percent_complete5=l_percent_complete_tab5(i)
			, t1.percent_complete6=l_percent_complete_tab6(i)
			, t1.earned_value1=l_earned_value_tab1(i)
			, t1.earned_value2=l_earned_value_tab2(i)
			, t1.earned_value3=l_earned_value_tab3(i)
			, t1.earned_value4=l_earned_value_tab4(i)
			, t1.earned_value5=l_earned_value_tab5(i)
			, t1.earned_value6=l_earned_value_tab6(i)
		       WHERE T1.Process_Number = l_Process_Number
			 AND T1.object_id = l_object_ids_tab(i)
			 AND T1.object_type = l_object_types_tab(i)
		      ;
		END IF; -- l_update_required = 'Y' THEN


		-- Parent Tasks(Summary Tasks)

		l_object_ids_tab.delete;
		l_object_types_tab.delete;
		l_perc_comp_deriv_code_tab.delete;
		l_bac_value_tab1.delete;
		l_bac_value_tab2.delete;
		l_bac_value_tab3.delete;
		l_bac_value_tab4.delete;
		l_bac_value_tab5.delete;
		l_bac_value_tab6.delete;
		l_percent_complete_tab1.delete;
		l_percent_complete_tab2.delete;
		l_percent_complete_tab3.delete;
		l_percent_complete_tab4.delete;
		l_percent_complete_tab5.delete;
		l_percent_complete_tab6.delete;
		l_percent_override_tab1.delete;
		l_percent_override_tab2.delete;
		l_percent_override_tab3.delete;
		l_percent_override_tab4.delete;
		l_percent_override_tab5.delete;
		l_percent_override_tab6.delete;
		l_earned_value_tab1.delete;
		l_earned_value_tab2.delete;
		l_earned_value_tab3.delete;
		l_earned_value_tab4.delete;
		l_earned_value_tab5.delete;
		l_earned_value_tab6.delete;
		l_summ_obj_flag_tab.delete; -- 4587517
		l_update_required := 'N';

		OPEN parent_objects_list_per_comp;
		FETCH parent_objects_list_per_comp BULK COLLECT INTO l_object_ids_tab, l_object_types_tab, l_perc_comp_deriv_code_tab
		, l_bac_value_tab1, l_bac_value_tab2, l_bac_value_tab3, l_bac_value_tab4, l_bac_value_tab5, l_bac_value_tab6
		, l_percent_complete_tab1, l_percent_complete_tab2, l_percent_complete_tab3, l_percent_complete_tab4
		, l_percent_complete_tab5, l_percent_complete_tab6, l_percent_override_tab1, l_percent_override_tab2
		, l_percent_override_tab3, l_percent_override_tab4, l_percent_override_tab5, l_percent_override_tab6
		, l_earned_value_tab1, l_earned_value_tab2, l_earned_value_tab3, l_earned_value_tab4, l_earned_value_tab5
		, l_earned_value_tab6
		, l_summ_obj_flag_tab -- 4587517
		;
		CLOSE parent_objects_list_per_comp;


		FOR i IN 1..l_object_ids_tab.count LOOP
			l_update_required := 'N';
			l_actual_duration1 := 0;
			l_pc_duration1 := 0;
			l_actual_duration2 := 0;
			l_pc_duration2 := 0;
			l_actual_duration3 := 0;
			l_pc_duration3 := 0;
			l_actual_duration4 := 0;
			l_pc_duration4 := 0;
			l_actual_duration5 := 0;
			l_pc_duration5 := 0;
			l_actual_duration6 := 0;
			l_pc_duration6 := 0;
			l_Count := 0;
			l_Count1 := 0;

			IF (l_perc_comp_deriv_code_tab(i) = 'DELIVERABLE') THEN
				BEGIN
                         --  l_actual_duration is devided by 100, added by rtarway for bug 4216030
                         SELECT sum(nvl(percent_override1, nvl(percent_complete1, 0))*nvl(task_weight1, 0))/100,
					  sum(nvl(task_weight1, 0)),
					  sum(nvl(percent_override2, nvl(percent_complete2, 0))*nvl(task_weight2, 0))/100,
					  sum(nvl(task_weight2, 0)),
					  sum(nvl(percent_override3, nvl(percent_complete3, 0))*nvl(task_weight3, 0))/100,
					  sum(nvl(task_weight3, 0)),
					  sum(nvl(percent_override4, nvl(percent_complete4, 0))*nvl(task_weight4, 0))/100,
					  sum(nvl(task_weight4, 0)),
					  sum(nvl(percent_override5, nvl(percent_complete5, 0))*nvl(task_weight5, 0))/100,
					  sum(nvl(task_weight5, 0)),
					  sum(nvl(percent_override6, nvl(percent_complete6, 0))*nvl(task_weight6, 0))/100,
					  sum(nvl(task_weight6, 0)),
					  count(*)
					INTO   l_actual_duration1, l_pc_duration1
					, l_actual_duration2, l_pc_duration2
					, l_actual_duration3, l_pc_duration3
					, l_actual_duration4, l_pc_duration4
					, l_actual_duration5, l_pc_duration5
					, l_actual_duration6, l_pc_duration6
					, l_count
					FROM   PA_PROJ_ROLLUP_BULK_TEMP
					WHERE  Process_Number    = l_Process_Number
					AND    OBJECT_TYPE = 'PA_DELIVERABLES'
					AND    Parent_Object_ID  = l_object_ids_tab(i)
					AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
					;
				EXCEPTION
					WHEN OTHERS THEN
						l_count := 0;
				END;
			-- 4587517 : For Deliverable and Work Quantity, Sub project do not contribute in % complete
			-- Added ELSIF for Work Quantity
			ELSIF l_perc_comp_deriv_code_tab(i) = 'WQ_DERIVED' AND nvl(l_summ_obj_flag_tab(i),'N') = 'L' THEN
				l_count := 0;
			-- 4587367 : Seprate processing for link task for manual duration rollup
			-- Moved existing ('MANUAL','DURATION') condition below
			-- Added new condition "OR"  in COST, EFFORT
			ELSIF P_Rollup_Method IN ('COST','EFFORT') OR (P_Rollup_Method IN ('MANUAL','DURATION') AND nvl(l_summ_obj_flag_tab(i),'N') = 'L')THEN
				IF nvl(l_summ_obj_flag_tab(i),'N') = 'L' THEN -- 4586449 : For link task separate processing
					l_actual_duration1_a := 0;
					l_actual_duration2_a := 0;
					l_actual_duration3_a := 0;
					l_actual_duration4_a := 0;
					l_actual_duration5_a := 0;
					l_actual_duration6_a := 0;
					l_duration1_a := 0;
					l_duration2_a := 0;
					l_duration3_a := 0;
					l_duration4_a := 0;
					l_duration5_a := 0;
					l_duration6_a := 0;
					l_actual_duration1_t := 0;
					l_actual_duration2_t := 0;
					l_actual_duration3_t := 0;
					l_actual_duration4_t := 0;
					l_actual_duration5_t := 0;
					l_actual_duration6_t := 0;
					l_duration1_t := 0;
					l_duration2_t := 0;
					l_duration3_t := 0;
					l_duration4_t := 0;
					l_duration5_t := 0;
					l_duration6_t := 0;
					l_temp_percent1 := 0;
					l_temp_percent2 := 0;
					l_temp_percent3 := 0;
					l_temp_percent4 := 0;
					l_temp_percent5 := 0;
					l_temp_percent6 := 0;

					BEGIN
						SELECT sum(nvl(earned_value1, 0)), sum(nvl(bac_value1, 0))
						, sum(nvl(earned_value2, 0)), sum(nvl(bac_value2, 0))
						, sum(nvl(earned_value3, 0)), sum(nvl(bac_value3, 0))
						, sum(nvl(earned_value4, 0)), sum(nvl(bac_value4, 0))
						, sum(nvl(earned_value5, 0)), sum(nvl(bac_value5, 0))
						, sum(nvl(earned_value6, 0)), sum(nvl(bac_value6, 0))
						,  count(*)
						INTO   l_actual_duration1_a, l_duration1_a
						, l_actual_duration2_a, l_duration2_a
						, l_actual_duration3_a, l_duration3_a
						, l_actual_duration4_a, l_duration4_a
						, l_actual_duration5_a, l_duration5_a
						, l_actual_duration6_a, l_duration6_a
						, l_count
						FROM   PA_PROJ_ROLLUP_BULK_TEMP
						WHERE  Process_Number = l_Process_Number
						AND    OBJECT_TYPE = 'PA_ASSIGNMENTS'
						AND    Parent_Object_ID  = l_object_ids_tab(i)
						AND    parent_object_type = 'PA_TASKS'
						;

					EXCEPTION
						WHEN OTHERS THEN
							l_count := 0;
					END;
					-- 4579654 : For more accuracy, we will not round the temp % complete here.
					IF (l_count > 0) THEN
						IF(l_duration1_a = 0 OR (l_actual_duration1_a < 0 and l_duration1_a > 0) OR (l_actual_duration1_a > 0 and l_duration1_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent1 := 0;
						ELSE
							--l_temp_percent1 := ROUND(100*l_actual_duration1_a/l_duration1_a, p_number_digit);
							l_temp_percent1 := 100*l_actual_duration1_a/l_duration1_a;
							if l_temp_percent1 > 100 then   --5726773
 	                                                    l_temp_percent1 := 100;
 	                                                end if;
						END IF;
						IF(l_duration2_a = 0 OR (l_actual_duration2_a < 0 and l_duration2_a > 0) OR (l_actual_duration2_a > 0 and l_duration2_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent2 := 0;
						ELSE
							--l_temp_percent2 := ROUND(100*l_actual_duration2_a/l_duration2_a, p_number_digit);
							l_temp_percent2 := 100*l_actual_duration2_a/l_duration2_a;
							if l_temp_percent2 > 100 then   --5726773
 	                                                            l_temp_percent2 := 100;
 	                                                end if;
						END IF;
						IF(l_duration3_a = 0 OR (l_actual_duration3_a < 0 and l_duration3_a > 0) OR (l_actual_duration3_a > 0 and l_duration3_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent3 := 0;
						ELSE
							--l_temp_percent3 := ROUND(100*l_actual_duration3_a/l_duration3_a, p_number_digit);
							l_temp_percent3 := 100*l_actual_duration3_a/l_duration3_a;
							if l_temp_percent3 > 100 then   --5726773
 	                                                            l_temp_percent3 := 100;
 	                                               end if;
						END IF;
						IF(l_duration4_a = 0 OR (l_actual_duration4_a < 0 and l_duration4_a > 0) OR (l_actual_duration4_a > 0 and l_duration4_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent4 := 0;
						ELSE
							--l_temp_percent4 := ROUND(100*l_actual_duration4_a/l_duration4_a, p_number_digit);
							l_temp_percent4 := 100*l_actual_duration4_a/l_duration4_a;
							if l_temp_percent4 > 100 then   --5726773
 	                                                            l_temp_percent4 := 100;
 	                                                end if;
						END IF;
						IF(l_duration5_a = 0 OR (l_actual_duration5_a < 0 and l_duration5_a > 0) OR (l_actual_duration5_a > 0 and l_duration5_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent5 := 0;
						ELSE
							--l_temp_percent5 := ROUND(100*l_actual_duration5_a/l_duration5_a, p_number_digit);
							l_temp_percent5 := 100*l_actual_duration5_a/l_duration5_a;
							if l_temp_percent5 > 100 then   --5726773
 	                                                            l_temp_percent5 := 100;
 	                                                end if;
						END IF;
						IF(l_duration6_a = 0 OR (l_actual_duration6_a < 0 and l_duration6_a > 0) OR (l_actual_duration6_a > 0 and l_duration6_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent6 := 0;
						ELSE
							--l_temp_percent6 := ROUND(100*l_actual_duration6_a/l_duration6_a, p_number_digit);
							l_temp_percent6 := 100*l_actual_duration6_a/l_duration6_a;
							if l_temp_percent6 > 100 then   --5726773
 	                                                            l_temp_percent6 := 100;
 	                                               end if;
						END IF;
					ELSE
						l_temp_percent1 := 0;
						l_temp_percent2 := 0;
						l_temp_percent3 := 0;
						l_temp_percent4 := 0;
						l_temp_percent5 := 0;
						l_temp_percent6 := 0;
					END IF;

					BEGIN
						SELECT sum(nvl(percent_override1, nvl(percent_complete1, 0))*nvl(bac_value1, 0)/100)
						, sum(nvl(bac_value1, 0))
						, sum(nvl(percent_override2, nvl(percent_complete2, 0))*nvl(bac_value2, 0)/100)
						, sum(nvl(bac_value2, 0))
						, sum(nvl(percent_override3, nvl(percent_complete3, 0))*nvl(bac_value3, 0)/100)
						, sum(nvl(bac_value3, 0))
						, sum(nvl(percent_override4, nvl(percent_complete4, 0))*nvl(bac_value4, 0)/100)
						, sum(nvl(bac_value4, 0))
						, sum(nvl(percent_override5, nvl(percent_complete5, 0))*nvl(bac_value5, 0)/100)
						, sum(nvl(bac_value5, 0))
						, sum(nvl(percent_override6, nvl(percent_complete6, 0))*nvl(bac_value6, 0)/100)
						, sum(nvl(bac_value6, 0))
						,  count(*)
						INTO   l_actual_duration1_t, l_duration1_t
						, l_actual_duration2_t, l_duration2_t
						, l_actual_duration3_t, l_duration3_t
						, l_actual_duration4_t, l_duration4_t
						, l_actual_duration5_t, l_duration5_t
						, l_actual_duration6_t, l_duration6_t
						, l_count1
						FROM   PA_PROJ_ROLLUP_BULK_TEMP
						WHERE  Process_Number    = l_Process_Number
						AND    OBJECT_TYPE = 'PA_SUBPROJECTS'
						AND    Parent_Object_ID  = l_object_ids_tab(i)
						AND    parent_object_type = 'PA_TASKS'
						;
					EXCEPTION
						WHEN OTHERS THEN
							l_count1 := 0;
					END;

					IF l_count = 0 and l_count1 = 0 THEN
						l_count := 0;
					ELSE
						l_count := 1;
					END IF;
					-- Bug 4601473 : Added nvl's here
					-- Here l_earned_value_tab is actually storing BAC value in task derivation method
					l_pc_duration1 := nvl(l_earned_value_tab1(i),0);
					l_actual_duration1:= nvl(l_actual_duration1_t,0) + (nvl(l_earned_value_tab1(i),0)-nvl(l_duration1_t,0))*nvl(l_temp_percent1,0)/100;
					l_pc_duration2 := nvl(l_earned_value_tab2(i),0);
					l_actual_duration2:= nvl(l_actual_duration2_t,0) + (nvl(l_earned_value_tab2(i),0)-nvl(l_duration2_t,0))*nvl(l_temp_percent2,0)/100;
					l_pc_duration3 := nvl(l_earned_value_tab3(i),0);
					l_actual_duration3:= nvl(l_actual_duration3_t,0) + (nvl(l_earned_value_tab3(i),0)-nvl(l_duration3_t,0))*nvl(l_temp_percent3,0)/100;
					l_pc_duration4 := nvl(l_earned_value_tab4(i),0);
					l_actual_duration4:= nvl(l_actual_duration4_t,0) + (nvl(l_earned_value_tab4(i),0)-nvl(l_duration4_t,0))*nvl(l_temp_percent4,0)/100;
					l_pc_duration5 := nvl(l_earned_value_tab5(i),0);
					l_actual_duration5:= nvl(l_actual_duration5_t,0) + (nvl(l_earned_value_tab5(i),0)-nvl(l_duration5_t,0))*nvl(l_temp_percent5,0)/100;
					l_pc_duration6 := nvl(l_earned_value_tab6(i),0);
					l_actual_duration6:= nvl(l_actual_duration6_t,0) + (nvl(l_earned_value_tab6(i),0)-nvl(l_duration6_t,0))*nvl(l_temp_percent6,0)/100;

				ELSE -- 4586449 nvl(l_summ_obj_flag_tab(i),'N') = 'L'
					l_actual_duration1_a := 0;
					l_actual_duration2_a := 0;
					l_actual_duration3_a := 0;
					l_actual_duration4_a := 0;
					l_actual_duration5_a := 0;
					l_actual_duration6_a := 0;
					l_duration1_a := 0;
					l_duration2_a := 0;
					l_duration3_a := 0;
					l_duration4_a := 0;
					l_duration5_a := 0;
					l_duration6_a := 0;
					l_actual_duration1_t := 0;
					l_actual_duration2_t := 0;
					l_actual_duration3_t := 0;
					l_actual_duration4_t := 0;
					l_actual_duration5_t := 0;
					l_actual_duration6_t := 0;
					l_duration1_t := 0;
					l_duration2_t := 0;
					l_duration3_t := 0;
					l_duration4_t := 0;
					l_duration5_t := 0;
					l_duration6_t := 0;
					l_temp_percent1 := 0;
					l_temp_percent2 := 0;
					l_temp_percent3 := 0;
					l_temp_percent4 := 0;
					l_temp_percent5 := 0;
					l_temp_percent6 := 0;

					BEGIN
						SELECT sum(nvl(earned_value1, 0)), sum(nvl(bac_value1, 0))
						, sum(nvl(earned_value2, 0)), sum(nvl(bac_value2, 0))
						, sum(nvl(earned_value3, 0)), sum(nvl(bac_value3, 0))
						, sum(nvl(earned_value4, 0)), sum(nvl(bac_value4, 0))
						, sum(nvl(earned_value5, 0)), sum(nvl(bac_value5, 0))
						, sum(nvl(earned_value6, 0)), sum(nvl(bac_value6, 0))
						,  count(*)
						INTO   l_actual_duration1_a, l_duration1_a
						, l_actual_duration2_a, l_duration2_a
						, l_actual_duration3_a, l_duration3_a
						, l_actual_duration4_a, l_duration4_a
						, l_actual_duration5_a, l_duration5_a
						, l_actual_duration6_a, l_duration6_a
						, l_count
						FROM   PA_PROJ_ROLLUP_BULK_TEMP
						WHERE  Process_Number = l_Process_Number
						AND    OBJECT_TYPE = 'PA_ASSIGNMENTS'
						AND    Parent_Object_ID  = l_object_ids_tab(i)
						AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
						;

					EXCEPTION
						WHEN OTHERS THEN
							l_count := 0;
					END;
					-- 4579654 : For more accuracy, we will not round the temp % complete here.
					IF (l_count > 0) THEN
						IF(l_duration1_a = 0 OR (l_actual_duration1_a < 0 and l_duration1_a > 0) OR (l_actual_duration1_a > 0 and l_duration1_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent1 := 0;
						ELSE
							--l_temp_percent1 := ROUND(100*l_actual_duration1_a/l_duration1_a, p_number_digit);
							l_temp_percent1 := 100*l_actual_duration1_a/l_duration1_a;
							if l_temp_percent1 > 100 then   --5726773
 	                                                            l_temp_percent1 := 100;
 	                                                end if;
						END IF;
						IF(l_duration2_a = 0 OR (l_actual_duration2_a < 0 and l_duration2_a > 0) OR (l_actual_duration2_a > 0 and l_duration2_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent2 := 0;
						ELSE
							--l_temp_percent2 := ROUND(100*l_actual_duration2_a/l_duration2_a, p_number_digit);
							l_temp_percent2 := 100*l_actual_duration2_a/l_duration2_a;
							if l_temp_percent2 > 100 then   --5726773
 	                                                            l_temp_percent2 := 100;
 	                                                end if;
						END IF;
						IF(l_duration3_a = 0 OR (l_actual_duration3_a < 0 and l_duration3_a > 0) OR (l_actual_duration3_a > 0 and l_duration3_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent3 := 0;
						ELSE
							--l_temp_percent3 := ROUND(100*l_actual_duration3_a/l_duration3_a, p_number_digit);
							l_temp_percent3 := 100*l_actual_duration3_a/l_duration3_a;
							if l_temp_percent3 > 100 then   --5726773
 	                                                            l_temp_percent3 := 100;
 	                                               end if;
						END IF;
						IF(l_duration4_a = 0 OR (l_actual_duration4_a < 0 and l_duration4_a > 0) OR (l_actual_duration4_a > 0 and l_duration4_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent4 := 0;
						ELSE
							--l_temp_percent4 := ROUND(100*l_actual_duration4_a/l_duration4_a, p_number_digit);
							l_temp_percent4 := 100*l_actual_duration4_a/l_duration4_a;
							if l_temp_percent4 > 100 then   --5726773
 	                                                            l_temp_percent4 := 100;
 	                                                end if;
						END IF;
						IF(l_duration5_a = 0 OR (l_actual_duration5_a < 0 and l_duration5_a > 0) OR (l_actual_duration5_a > 0 and l_duration5_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent5 := 0;
						ELSE
							--l_temp_percent5 := ROUND(100*l_actual_duration5_a/l_duration5_a, p_number_digit);
							l_temp_percent5 := 100*l_actual_duration5_a/l_duration5_a;
							if l_temp_percent5 > 100 then   --5726773
 	                                                            l_temp_percent5 := 100;
 	                                               end if;
						END IF;
						IF(l_duration6_a = 0 OR (l_actual_duration6_a < 0 and l_duration6_a > 0) OR (l_actual_duration6_a > 0 and l_duration6_a < 0)) THEN --OR added for BUG 4346107 --5726773
							l_temp_percent6 := 0;
						ELSE
							--l_temp_percent6 := ROUND(100*l_actual_duration6_a/l_duration6_a, p_number_digit);
							l_temp_percent6 := 100*l_actual_duration6_a/l_duration6_a;
							if l_temp_percent6 > 100 then   --5726773
 	                                                            l_temp_percent6 := 100;
 	                                                end if;
						END IF;
					ELSE
						l_temp_percent1 := 0;
						l_temp_percent2 := 0;
						l_temp_percent3 := 0;
						l_temp_percent4 := 0;
						l_temp_percent5 := 0;
						l_temp_percent6 := 0;
					END IF;

					BEGIN
						SELECT sum(nvl(percent_override1, nvl(percent_complete1, 0))*nvl(bac_value1, 0)/100)
						, sum(nvl(bac_value1, 0))
						, sum(nvl(percent_override2, nvl(percent_complete2, 0))*nvl(bac_value2, 0)/100)
						, sum(nvl(bac_value2, 0))
						, sum(nvl(percent_override3, nvl(percent_complete3, 0))*nvl(bac_value3, 0)/100)
						, sum(nvl(bac_value3, 0))
						, sum(nvl(percent_override4, nvl(percent_complete4, 0))*nvl(bac_value4, 0)/100)
						, sum(nvl(bac_value4, 0))
						, sum(nvl(percent_override5, nvl(percent_complete5, 0))*nvl(bac_value5, 0)/100)
						, sum(nvl(bac_value5, 0))
						, sum(nvl(percent_override6, nvl(percent_complete6, 0))*nvl(bac_value6, 0)/100)
						, sum(nvl(bac_value6, 0))
						,  count(*) -- Bug 4343615
						INTO   l_actual_duration1_t, l_duration1_t
						, l_actual_duration2_t, l_duration2_t
						, l_actual_duration3_t, l_duration3_t
						, l_actual_duration4_t, l_duration4_t
						, l_actual_duration5_t, l_duration5_t
						, l_actual_duration6_t, l_duration6_t
						, l_count1 -- Bug 4343615
						FROM   PA_PROJ_ROLLUP_BULK_TEMP
						WHERE  Process_Number    = l_Process_Number
						--AND    OBJECT_TYPE = 'PA_TASKS' --4582956
						AND    OBJECT_TYPE IN ('PA_TASKS','PA_SUBPROJECTS') --4582956 : Added PA_SUBPROJECTS
						AND    Parent_Object_ID  = l_object_ids_tab(i)
						AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
						;
						--AND     rollup_node = 'Y';

					EXCEPTION
						WHEN OTHERS THEN
							l_count1 := 0; -- Bug 4343615
					END;

					-- Bug 4343615 : Added following IF
					IF l_count = 0 and l_count1 = 0 THEN
						l_count := 0;
					ELSE
						l_count := 1;
					END IF;
					-- Bug 4601473 : Added nvl's here
					l_pc_duration1 := nvl(l_BAC_VALUE_tab1(i),0);
					l_actual_duration1:= nvl(l_actual_duration1_t,0) + (nvl(l_BAC_VALUE_tab1(i),0)-nvl(l_duration1_t,0))*nvl(l_temp_percent1,0)/100;
					l_pc_duration2 := nvl(l_BAC_VALUE_tab2(i),0);
					l_actual_duration2:= nvl(l_actual_duration2_t,0) + (nvl(l_BAC_VALUE_tab2(i),0)-nvl(l_duration2_t,0))*nvl(l_temp_percent2,0)/100;
					l_pc_duration3 := nvl(l_BAC_VALUE_tab3(i),0);
					l_actual_duration3:= nvl(l_actual_duration3_t,0) + (nvl(l_BAC_VALUE_tab3(i),0)-nvl(l_duration3_t,0))*nvl(l_temp_percent3,0)/100;
					l_pc_duration4 := nvl(l_BAC_VALUE_tab4(i),0);
					l_actual_duration4:= nvl(l_actual_duration4_t,0) + (nvl(l_BAC_VALUE_tab4(i),0)-nvl(l_duration4_t,0))*nvl(l_temp_percent4,0)/100;
					l_pc_duration5 := nvl(l_BAC_VALUE_tab5(i),0);
					l_actual_duration5:= nvl(l_actual_duration5_t,0) + (nvl(l_BAC_VALUE_tab5(i),0)-nvl(l_duration5_t,0))*nvl(l_temp_percent5,0)/100;
					l_pc_duration6 := nvl(l_BAC_VALUE_tab6(i),0);
					l_actual_duration6:= nvl(l_actual_duration6_t,0) + (nvl(l_BAC_VALUE_tab6(i),0)-nvl(l_duration6_t,0))*nvl(l_temp_percent6,0)/100;

				END IF; -- 4586449 nvl(l_summ_obj_flag_tab(i),'N') = 'L'

			ELSIF P_Rollup_Method IN ('MANUAL','DURATION') THEN
				BEGIN
					--  l_actual_duration is devided by 100, added by rtarway for bug 4216030
                         SELECT sum(nvl(percent_override1, nvl(percent_complete1, 0))*nvl(task_weight1, 0))/100
					, sum(nvl(task_weight1, 0))
					, sum(nvl(percent_override2, nvl(percent_complete2, 0))*nvl(task_weight2, 0))/100
					, sum(nvl(task_weight2, 0))
					, sum(nvl(percent_override3, nvl(percent_complete3, 0))*nvl(task_weight3, 0))/100
					, sum(nvl(task_weight3, 0))
					, sum(nvl(percent_override4, nvl(percent_complete4, 0))*nvl(task_weight4, 0))/100
					, sum(nvl(task_weight4, 0))
					, sum(nvl(percent_override5, nvl(percent_complete5, 0))*nvl(task_weight5, 0))/100
					, sum(nvl(task_weight5, 0))
					, sum(nvl(percent_override6, nvl(percent_complete6, 0))*nvl(task_weight6, 0))/100
					, sum(nvl(task_weight6, 0))
					,  count(*)
					INTO   l_actual_duration1, l_pc_duration1
					, l_actual_duration2, l_pc_duration2
					, l_actual_duration3, l_pc_duration3
					, l_actual_duration4, l_pc_duration4
					, l_actual_duration5, l_pc_duration5
					, l_actual_duration6, l_pc_duration6
					, l_count
					FROM   PA_PROJ_ROLLUP_BULK_TEMP
					WHERE  Process_Number    = l_Process_Number
					AND    OBJECT_TYPE = 'PA_TASKS'
					AND    Parent_Object_ID  = l_object_ids_tab(i)
					AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
					;
					--AND Rollup_Node  = 'Y';
				EXCEPTION
					WHEN OTHERS THEN
						l_count := 0;
				END;
			END IF;	-- (l_perc_comp_deriv_code_tab(i) = 'DELIVERABLE') THEN

			-- Bug 4343615 : Added following IF
			IF (l_count > 0) THEN
				-- 4579654 : For more accuracy, we will first derive the earned value and then
				-- round the % complete.
				IF p_process_flag1 = 'Y' and p_process_percent_flag1 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration1 = 0 OR (l_actual_duration1 < 0 and l_pc_duration1 > 0) OR (l_actual_duration1 > 0 and l_pc_duration1 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab1(i) := 0;
					ELSE
						--l_percent_complete_tab1(i) := round(100*l_actual_duration1/l_pc_duration1, p_number_digit);
						l_percent_complete_tab1(i) := 100*l_actual_duration1/l_pc_duration1;
						if l_percent_complete_tab1(i) > 100 then   --5726773
 	                                                       l_percent_complete_tab1(i)  := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab1(i) := nvl(l_bac_value_tab1(i), 0)*nvl(l_percent_override_tab1(i), l_percent_complete_tab1(i))/100;
					l_percent_complete_tab1(i) := round(l_percent_complete_tab1(i), p_number_digit);
				END IF;
				IF p_process_flag2 = 'Y' and p_process_percent_flag2 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration2 = 0 OR (l_actual_duration2 < 0 and l_pc_duration2 > 0) OR (l_actual_duration2 > 0 and l_pc_duration2 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab2(i) := 0;
					ELSE
						--l_percent_complete_tab2(i) := round(100*l_actual_duration2/l_pc_duration2, p_number_digit);
						l_percent_complete_tab2(i) := 100*l_actual_duration2/l_pc_duration2;
						if l_percent_complete_tab2(i) > 100 then   --5726773
 	                                                       l_percent_complete_tab2(i)  := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab2(i) := nvl(l_bac_value_tab2(i), 0)*nvl(l_percent_override_tab2(i), l_percent_complete_tab2(i))/100;
					l_percent_complete_tab2(i) := round(l_percent_complete_tab2(i), p_number_digit);
				END IF;
				IF p_process_flag3 = 'Y' and p_process_percent_flag3 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration3 = 0 OR (l_actual_duration3 < 0 and l_pc_duration3 > 0) OR (l_actual_duration3 > 0 and l_pc_duration3 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab3(i) := 0;
					ELSE
						--l_percent_complete_tab3(i) := round(100*l_actual_duration3/l_pc_duration3, p_number_digit);
						l_percent_complete_tab3(i) := 100*l_actual_duration3/l_pc_duration3;
						if l_percent_complete_tab3(i) > 100 then   --5726773
 	                                                       l_percent_complete_tab3(i)  := 100;
 	                                       end if;
					END IF;
					l_earned_value_tab3(i) := nvl(l_bac_value_tab3(i), 0)*nvl(l_percent_override_tab3(i), l_percent_complete_tab3(i))/100;
					l_percent_complete_tab3(i) := round(l_percent_complete_tab3(i), p_number_digit);
				END IF;
				IF p_process_flag4 = 'Y' and p_process_percent_flag4 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration4 = 0 OR (l_actual_duration4 < 0 and l_pc_duration4 > 0) OR (l_actual_duration4 > 0 and l_pc_duration4 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab4(i) := 0;
					ELSE
						--l_percent_complete_tab4(i) := round(100*l_actual_duration4/l_pc_duration4, p_number_digit);
						l_percent_complete_tab4(i) := 100*l_actual_duration4/l_pc_duration4;
						if l_percent_complete_tab4(i) > 100 then   --5726773
 	                                                       l_percent_complete_tab4(i)  := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab4(i) := nvl(l_bac_value_tab4(i), 0)*nvl(l_percent_override_tab4(i), l_percent_complete_tab4(i))/100;
					l_percent_complete_tab4(i) := round(l_percent_complete_tab4(i), p_number_digit);
				END IF;
				IF p_process_flag5 = 'Y' and p_process_percent_flag5 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration5 = 0 OR (l_actual_duration5 < 0 and l_pc_duration5 > 0) OR (l_actual_duration5 > 0 and l_pc_duration5 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab5(i) := 0;
					ELSE
						--l_percent_complete_tab5(i) := round(100*l_actual_duration5/l_pc_duration5, p_number_digit);
						l_percent_complete_tab5(i) := 100*l_actual_duration5/l_pc_duration5;
						if l_percent_complete_tab5(i) > 100 then   --5726773
 	                                                       l_percent_complete_tab5(i)  := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab5(i) := nvl(l_bac_value_tab5(i), 0)*nvl(l_percent_override_tab5(i), l_percent_complete_tab5(i))/100;
					l_percent_complete_tab5(i) := round(l_percent_complete_tab5(i), p_number_digit);
				END IF;
				IF p_process_flag6 = 'Y' and p_process_percent_flag6 = 'Y' THEN
					l_update_required := 'Y';
					IF(l_pc_duration6 = 0 OR (l_actual_duration6 < 0 and l_pc_duration6 > 0) OR (l_actual_duration6 > 0 and l_pc_duration6 < 0)) THEN --OR added for BUG 4346107 --5726773
						l_percent_complete_tab6(i) := 0;
					ELSE
						--l_percent_complete_tab6(i) := round(100*l_actual_duration6/l_pc_duration6, p_number_digit);
						l_percent_complete_tab6(i) := 100*l_actual_duration6/l_pc_duration6;
						if l_percent_complete_tab6(i) > 100 then   --5726773
 	                                                       l_percent_complete_tab6(i)  := 100;
 	                                        end if;
					END IF;
					l_earned_value_tab6(i) := nvl(l_bac_value_tab6(i), 0)*nvl(l_percent_override_tab6(i), l_percent_complete_tab6(i))/100;
					l_percent_complete_tab6(i) := round(l_percent_complete_tab6(i), p_number_digit);
				END IF;
			ELSE -- l_count > 0 -- Bug 4343615 : Added following ELSE and code in ELSE part
				IF p_process_flag1 = 'Y' and p_process_percent_flag1 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab1(i) := nvl(l_bac_value_tab1(i), 0)*nvl(l_percent_override_tab1(i), l_percent_complete_tab1(i))/100;
				END IF;
				IF p_process_flag2 = 'Y' and p_process_percent_flag2 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab2(i) := nvl(l_bac_value_tab2(i), 0)*nvl(l_percent_override_tab2(i), l_percent_complete_tab2(i))/100;
				END IF;
				IF p_process_flag3 = 'Y' and p_process_percent_flag3 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab3(i) := nvl(l_bac_value_tab3(i), 0)*nvl(l_percent_override_tab3(i), l_percent_complete_tab3(i))/100;
				END IF;
				IF p_process_flag4 = 'Y' and p_process_percent_flag4 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab4(i) := nvl(l_bac_value_tab4(i), 0)*nvl(l_percent_override_tab4(i), l_percent_complete_tab4(i))/100;
				END IF;
				IF p_process_flag5 = 'Y' and p_process_percent_flag5 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab5(i) := nvl(l_bac_value_tab5(i), 0)*nvl(l_percent_override_tab5(i), l_percent_complete_tab5(i))/100;
				END IF;
				IF p_process_flag6 = 'Y' and p_process_percent_flag6 = 'Y' THEN
					l_update_required := 'Y';
					l_earned_value_tab6(i) := nvl(l_bac_value_tab6(i), 0)*nvl(l_percent_override_tab6(i), l_percent_complete_tab6(i))/100;
				END IF;
			END IF; -- l_count > 0

			IF l_update_required = 'Y' THEN
	      /* Added the hint to force the unique index for bug#6185523 */
				UPDATE  /*+ INDEX( T1 PA_PROJ_ROLLUP_BULK_TEMP_U1) */ PA_PROJ_ROLLUP_BULK_TEMP T1
				SET    T1.PERCENT_COMPLETE1=l_PERCENT_COMPLETE_tab1(i)
					, T1.PERCENT_COMPLETE2=l_PERCENT_COMPLETE_tab2(i)
					, T1.PERCENT_COMPLETE3=l_PERCENT_COMPLETE_tab3(i)
					, T1.PERCENT_COMPLETE4=l_PERCENT_COMPLETE_tab4(i)
					, T1.PERCENT_COMPLETE5=l_PERCENT_COMPLETE_tab5(i)
					, T1.PERCENT_COMPLETE6=l_PERCENT_COMPLETE_tab6(i)
					, T1.EARNED_VALUE1=l_EARNED_VALUE_tab1(i)
					, T1.EARNED_VALUE2=l_EARNED_VALUE_tab2(i)
					, T1.EARNED_VALUE3=l_EARNED_VALUE_tab3(i)
					, T1.EARNED_VALUE4=l_EARNED_VALUE_tab4(i)
					, T1.EARNED_VALUE5=l_EARNED_VALUE_tab5(i)
					, T1.EARNED_VALUE6=l_EARNED_VALUE_tab6(i)
				WHERE T1.Process_Number = l_Process_Number
				AND T1.object_id = l_object_ids_tab(i)
				AND T1.object_type = l_object_types_tab(i)
				;
			END IF;
		END LOOP; -- i IN 1..l_object_ids_tab.count LOOP
		-- Note that Bulk Update is not implemnted due to reason mentioned in Dates Rollup section
		/* Please do not remove
		IF l_update_required = 'Y' THEN
			FORALL i in 1..l_object_ids_tab.count
			     UPDATE PA_PROJ_ROLLUP_BULK_TEMP T1
				SET    T1.PERCENT_COMPLETE1=l_PERCENT_COMPLETE_tab1(i)
				, T1.PERCENT_COMPLETE2=l_PERCENT_COMPLETE_tab2(i)
				, T1.PERCENT_COMPLETE3=l_PERCENT_COMPLETE_tab3(i)
				, T1.PERCENT_COMPLETE4=l_PERCENT_COMPLETE_tab4(i)
				, T1.PERCENT_COMPLETE5=l_PERCENT_COMPLETE_tab5(i)
				, T1.PERCENT_COMPLETE6=l_PERCENT_COMPLETE_tab6(i)
				, T1.EARNED_VALUE1=l_EARNED_VALUE_tab1(i)
				, T1.EARNED_VALUE2=l_EARNED_VALUE_tab2(i)
				, T1.EARNED_VALUE3=l_EARNED_VALUE_tab3(i)
				, T1.EARNED_VALUE4=l_EARNED_VALUE_tab4(i)
				, T1.EARNED_VALUE5=l_EARNED_VALUE_tab5(i)
				, T1.EARNED_VALUE6=l_EARNED_VALUE_tab6(i)
			       WHERE T1.Process_Number = l_Process_Number
				 AND T1.object_id = l_object_ids_tab(i)
				 AND T1.object_type = l_object_types_tab(i)
				;
		END IF; -- l_update_required = 'Y' THEN
		*/
	END IF; -- ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After % Complete processing', x_Log_Level=> 3);
        END IF;

	-- ********* PERCENT COMPLETE  PROCESSING END ******************

	 -- ********* ETC COST ROLLUP BEGIN ****************
	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before ETC Cost processing', x_Log_Level=> 3);
        END IF;


	-- Bug 4218507 : To do effort or ETC processing, atleast one of the flags p_process_ETC_Flag1 or p_process_effort_flag1
	-- should be passed as Y
	IF ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'
	        OR p_process_flag5 = 'Y' OR p_process_flag6 = 'Y')
	     AND((p_process_ETC_Flag1 = 'Y' OR p_process_ETC_Flag2 = 'Y' OR p_process_ETC_Flag3 = 'Y'
		 OR p_process_ETC_Flag4 = 'Y' OR p_process_ETC_Flag5 = 'Y' OR p_process_ETC_Flag6 = 'Y')
		 OR (p_process_effort_flag1 = 'Y' OR p_process_effort_flag2 = 'Y' OR p_process_effort_flag3 = 'Y'
		OR p_process_effort_flag4 = 'Y' OR p_process_effort_flag5 = 'Y' OR p_process_effort_flag6 = 'Y')
		 ))
	THEN
		l_object_ids_tab.delete;
		l_object_types_tab.delete;
		l_update_required := 'N';
		-- Bug 4218507 : Merged Effort Processing with ETC Cost processing
                l_sum_tab1.delete;
                l_sum_tab2.delete;
                l_sum_tab3.delete;
                l_sum_tab4.delete;
                l_sum_tab5.delete;
                l_sum_tab6.delete;


		OPEN Parent_Objects_List_ETC_COST;
		FETCH Parent_Objects_List_ETC_COST
		BULK COLLECT INTO l_object_ids_tab, l_object_types_tab
		, l_ETC_Cost_tab1, l_ETC_Cost_tab2, l_ETC_Cost_tab3, l_ETC_Cost_tab4, l_ETC_Cost_tab5, l_ETC_Cost_tab6
		, l_PPL_ETC_COST_tab1, l_PPL_ETC_COST_tab2, l_PPL_ETC_COST_tab3, l_PPL_ETC_COST_tab4, l_PPL_ETC_COST_tab5, l_PPL_ETC_COST_tab6
		, l_EQPMT_ETC_COST_tab1, l_EQPMT_ETC_COST_tab2, l_EQPMT_ETC_COST_tab3, l_EQPMT_ETC_COST_tab4, l_EQPMT_ETC_COST_tab5, l_EQPMT_ETC_COST_tab6
		, l_PPL_UNPLAND_EFFORT_tab1, l_PPL_UNPLAND_EFFORT_tab2, l_PPL_UNPLAND_EFFORT_tab3, l_PPL_UNPLAND_EFFORT_tab4, l_PPL_UNPLAND_EFFORT_tab5, l_PPL_UNPLAND_EFFORT_tab6
		, l_EQPMT_ETC_EFFORT_tab1, l_EQPMT_ETC_EFFORT_tab2, l_EQPMT_ETC_EFFORT_tab3, l_EQPMT_ETC_EFFORT_tab4, l_EQPMT_ETC_EFFORT_tab5, l_EQPMT_ETC_EFFORT_tab6
		, l_SUB_PRJ_ETC_COST_tab1, l_SUB_PRJ_ETC_COST_tab2, l_SUB_PRJ_ETC_COST_tab3, l_SUB_PRJ_ETC_COST_tab4, l_SUB_PRJ_ETC_COST_tab5, l_SUB_PRJ_ETC_COST_tab6
		, l_SUB_PRJ_PPL_ETC_COST_tab1, l_SUB_PRJ_PPL_ETC_COST_tab2, l_SUB_PRJ_PPL_ETC_COST_tab3, l_SUB_PRJ_PPL_ETC_COST_tab4, l_SUB_PRJ_PPL_ETC_COST_tab5, l_SUB_PRJ_PPL_ETC_COST_tab6
		, l_SUB_PRJ_EQPMT_ETC_COST_tab1, l_SUB_PRJ_EQPMT_ETC_COST_tab2, l_SUB_PRJ_EQPMT_ETC_COST_tab3, l_SUB_PRJ_EQPMT_ETC_COST_tab4, l_SUB_PRJ_EQPMT_ETC_COST_tab5, l_SUB_PRJ_EQPMT_ETC_COST_tab6
		, l_SUB_PRJ_PPL_ETC_EFFORT_tab1, l_SUB_PRJ_PPL_ETC_EFFORT_tab2, l_SUB_PRJ_PPL_ETC_EFFORT_tab3, l_SUB_PRJ_PPL_ETC_EFFORT_tab4, l_SUB_PRJ_PPL_ETC_EFFORT_tab5, l_SUB_PRJ_PPL_ETC_EFFORT_tab6
		, L_SP_EQPMT_ETC_EFFORT_TAB1, L_SP_EQPMT_ETC_EFFORT_TAB2, L_SP_EQPMT_ETC_EFFORT_TAB3, L_SP_EQPMT_ETC_EFFORT_TAB4, L_SP_EQPMT_ETC_EFFORT_TAB5, L_SP_EQPMT_ETC_EFFORT_TAB6
		, l_sum_tab1, l_sum_tab2, l_sum_tab3, l_sum_tab4, l_sum_tab5, l_sum_tab6;
		CLOSE Parent_Objects_List_ETC_COST;

		FOR i IN 1..l_object_ids_tab.count LOOP
			l_Count := 0;
			l_update_required := 'N';
			BEGIN

				IF l_partial_rollup1 OR l_partial_rollup2 OR l_partial_rollup3
				   OR l_partial_rollup4 OR l_partial_rollup5 OR l_partial_rollup6
				THEN
					SELECT Sum(decode(rollup_node1, 'Y', NVL(ETC_Cost1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(ETC_Cost2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(ETC_Cost3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(ETC_Cost4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(ETC_Cost5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(ETC_Cost6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(PPL_ETC_COST1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(PPL_ETC_COST2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(PPL_ETC_COST3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(PPL_ETC_COST4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(PPL_ETC_COST5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(PPL_ETC_COST6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(EQPMT_ETC_COST1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(EQPMT_ETC_COST2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(EQPMT_ETC_COST3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(EQPMT_ETC_COST4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(EQPMT_ETC_COST5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(EQPMT_ETC_COST6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(PPL_UNPLAND_EFFORT1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(PPL_UNPLAND_EFFORT2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(PPL_UNPLAND_EFFORT3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(PPL_UNPLAND_EFFORT4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(PPL_UNPLAND_EFFORT5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(PPL_UNPLAND_EFFORT6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(EQPMT_ETC_EFFORT1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(EQPMT_ETC_EFFORT2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(EQPMT_ETC_EFFORT3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(EQPMT_ETC_EFFORT4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(EQPMT_ETC_EFFORT5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(EQPMT_ETC_EFFORT6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(SUB_PRJ_ETC_COST1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(SUB_PRJ_ETC_COST2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(SUB_PRJ_ETC_COST3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(SUB_PRJ_ETC_COST4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(SUB_PRJ_ETC_COST5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(SUB_PRJ_ETC_COST6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(SUB_PRJ_PPL_ETC_COST1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(SUB_PRJ_PPL_ETC_COST2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(SUB_PRJ_PPL_ETC_COST3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(SUB_PRJ_PPL_ETC_COST4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(SUB_PRJ_PPL_ETC_COST5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(SUB_PRJ_PPL_ETC_COST6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(SUB_PRJ_EQPMT_ETC_COST1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(SUB_PRJ_EQPMT_ETC_COST2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(SUB_PRJ_EQPMT_ETC_COST3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(SUB_PRJ_EQPMT_ETC_COST4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(SUB_PRJ_EQPMT_ETC_COST5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(SUB_PRJ_EQPMT_ETC_COST6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(SUB_PRJ_PPL_ETC_EFFORT1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(SUB_PRJ_PPL_ETC_EFFORT2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(SUB_PRJ_PPL_ETC_EFFORT3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(SUB_PRJ_PPL_ETC_EFFORT4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(SUB_PRJ_PPL_ETC_EFFORT5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(SUB_PRJ_PPL_ETC_EFFORT6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(SUB_PRJ_EQPMT_ETC_EFFORT1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(SUB_PRJ_EQPMT_ETC_EFFORT2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(SUB_PRJ_EQPMT_ETC_EFFORT3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(SUB_PRJ_EQPMT_ETC_EFFORT4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(SUB_PRJ_EQPMT_ETC_EFFORT5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(SUB_PRJ_EQPMT_ETC_EFFORT6,0),0)),
					     Sum(decode(rollup_node1, 'Y', NVL(REMAINING_EFFORT1,0),0)),
					     Sum(decode(rollup_node2, 'Y', NVL(REMAINING_EFFORT2,0),0)),
					     Sum(decode(rollup_node3, 'Y', NVL(REMAINING_EFFORT3,0),0)),
					     Sum(decode(rollup_node4, 'Y', NVL(REMAINING_EFFORT4,0),0)),
					     Sum(decode(rollup_node5, 'Y', NVL(REMAINING_EFFORT5,0),0)),
					     Sum(decode(rollup_node6, 'Y', NVL(REMAINING_EFFORT6,0),0)),
					     Count(*)
				      INTO   l_ETC_Cost_tab1(i),
					     l_ETC_Cost_tab2(i),
					     l_ETC_Cost_tab3(i),
					     l_ETC_Cost_tab4(i),
					     l_ETC_Cost_tab5(i),
					     l_ETC_Cost_tab6(i),
					     l_PPL_ETC_COST_tab1(i),
					     l_PPL_ETC_COST_tab2(i),
					     l_PPL_ETC_COST_tab3(i),
					     l_PPL_ETC_COST_tab4(i),
					     l_PPL_ETC_COST_tab5(i),
					     l_PPL_ETC_COST_tab6(i),
					     l_EQPMT_ETC_COST_tab1(i),
					     l_EQPMT_ETC_COST_tab2(i),
					     l_EQPMT_ETC_COST_tab3(i),
					     l_EQPMT_ETC_COST_tab4(i),
					     l_EQPMT_ETC_COST_tab5(i),
					     l_EQPMT_ETC_COST_tab6(i),
					     l_PPL_UNPLAND_EFFORT_tab1(i),
					     l_PPL_UNPLAND_EFFORT_tab2(i),
					     l_PPL_UNPLAND_EFFORT_tab3(i),
					     l_PPL_UNPLAND_EFFORT_tab4(i),
					     l_PPL_UNPLAND_EFFORT_tab5(i),
					     l_PPL_UNPLAND_EFFORT_tab6(i),
					     l_EQPMT_ETC_EFFORT_tab1(i),
					     l_EQPMT_ETC_EFFORT_tab2(i),
					     l_EQPMT_ETC_EFFORT_tab3(i),
					     l_EQPMT_ETC_EFFORT_tab4(i),
					     l_EQPMT_ETC_EFFORT_tab5(i),
					     l_EQPMT_ETC_EFFORT_tab6(i),
					     l_SUB_PRJ_ETC_COST_tab1(i),
					     l_SUB_PRJ_ETC_COST_tab2(i),
					     l_SUB_PRJ_ETC_COST_tab3(i),
					     l_SUB_PRJ_ETC_COST_tab4(i),
					     l_SUB_PRJ_ETC_COST_tab5(i),
					     l_SUB_PRJ_ETC_COST_tab6(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab1(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab2(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab3(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab4(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab5(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab6(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab1(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab2(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab3(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab4(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab5(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab6(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab1(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab2(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab3(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab4(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab5(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab6(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB1(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB2(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB3(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB4(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB5(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB6(i),
                                              l_sum_tab1(i),
                                              l_sum_tab2(i),
                                              l_sum_tab3(i),
                                              l_sum_tab4(i),
                                              l_sum_tab5(i),
                                              l_sum_tab6(i),
					     l_Count
				      FROM   PA_PROJ_ROLLUP_BULK_TEMP
				      WHERE  Process_Number    = l_Process_Number
				      AND    OBJECT_TYPE <> 'PA_DELIVERABLES'
				      AND    Parent_Object_ID  =l_object_ids_tab(i)
    				      AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
				      ;
				ELSE
					SELECT Sum(NVL(ETC_Cost1,0)),
					     Sum(NVL(ETC_Cost2,0)),
					     Sum(NVL(ETC_Cost3,0)),
					     Sum(NVL(ETC_Cost4,0)),
					     Sum(NVL(ETC_Cost5,0)),
					     Sum(NVL(ETC_Cost6,0)),
					     Sum(NVL(PPL_ETC_COST1,0)),
					     Sum(NVL(PPL_ETC_COST2,0)),
					     Sum(NVL(PPL_ETC_COST3,0)),
					     Sum(NVL(PPL_ETC_COST4,0)),
					     Sum(NVL(PPL_ETC_COST5,0)),
					     Sum(NVL(PPL_ETC_COST6,0)),
					     Sum(NVL(EQPMT_ETC_COST1,0)),
					     Sum(NVL(EQPMT_ETC_COST2,0)),
					     Sum(NVL(EQPMT_ETC_COST3,0)),
					     Sum(NVL(EQPMT_ETC_COST4,0)),
					     Sum(NVL(EQPMT_ETC_COST5,0)),
					     Sum(NVL(EQPMT_ETC_COST6,0)),
					     Sum(NVL(PPL_UNPLAND_EFFORT1,0)),
					     Sum(NVL(PPL_UNPLAND_EFFORT2,0)),
					     Sum(NVL(PPL_UNPLAND_EFFORT3,0)),
					     Sum(NVL(PPL_UNPLAND_EFFORT4,0)),
					     Sum(NVL(PPL_UNPLAND_EFFORT5,0)),
					     Sum(NVL(PPL_UNPLAND_EFFORT6,0)),
					     Sum(NVL(EQPMT_ETC_EFFORT1,0)),
					     Sum(NVL(EQPMT_ETC_EFFORT2,0)),
					     Sum(NVL(EQPMT_ETC_EFFORT3,0)),
					     Sum(NVL(EQPMT_ETC_EFFORT4,0)),
					     Sum(NVL(EQPMT_ETC_EFFORT5,0)),
					     Sum(NVL(EQPMT_ETC_EFFORT6,0)),
					     Sum(NVL(SUB_PRJ_ETC_COST1,0)),
					     Sum(NVL(SUB_PRJ_ETC_COST2,0)),
					     Sum(NVL(SUB_PRJ_ETC_COST3,0)),
					     Sum(NVL(SUB_PRJ_ETC_COST4,0)),
					     Sum(NVL(SUB_PRJ_ETC_COST5,0)),
					     Sum(NVL(SUB_PRJ_ETC_COST6,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_COST1,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_COST2,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_COST3,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_COST4,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_COST5,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_COST6,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_COST1,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_COST2,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_COST3,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_COST4,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_COST5,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_COST6,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_EFFORT1,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_EFFORT2,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_EFFORT3,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_EFFORT4,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_EFFORT5,0)),
					     Sum(NVL(SUB_PRJ_PPL_ETC_EFFORT6,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_EFFORT1,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_EFFORT2,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_EFFORT3,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_EFFORT4,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_EFFORT5,0)),
					     Sum(NVL(SUB_PRJ_EQPMT_ETC_EFFORT6,0)),
					     Sum(NVL(REMAINING_EFFORT1,0)),
					     Sum(NVL(REMAINING_EFFORT2,0)),
					     Sum(NVL(REMAINING_EFFORT3,0)),
					     Sum(NVL(REMAINING_EFFORT4,0)),
					     Sum(NVL(REMAINING_EFFORT5,0)),
					     Sum(NVL(REMAINING_EFFORT6,0)),
					     Count(*)
				      INTO   l_ETC_Cost_tab1(i),
					     l_ETC_Cost_tab2(i),
					     l_ETC_Cost_tab3(i),
					     l_ETC_Cost_tab4(i),
					     l_ETC_Cost_tab5(i),
					     l_ETC_Cost_tab6(i),
					     l_PPL_ETC_COST_tab1(i),
					     l_PPL_ETC_COST_tab2(i),
					     l_PPL_ETC_COST_tab3(i),
					     l_PPL_ETC_COST_tab4(i),
					     l_PPL_ETC_COST_tab5(i),
					     l_PPL_ETC_COST_tab6(i),
					     l_EQPMT_ETC_COST_tab1(i),
					     l_EQPMT_ETC_COST_tab2(i),
					     l_EQPMT_ETC_COST_tab3(i),
					     l_EQPMT_ETC_COST_tab4(i),
					     l_EQPMT_ETC_COST_tab5(i),
					     l_EQPMT_ETC_COST_tab6(i),
					     l_PPL_UNPLAND_EFFORT_tab1(i),
					     l_PPL_UNPLAND_EFFORT_tab2(i),
					     l_PPL_UNPLAND_EFFORT_tab3(i),
					     l_PPL_UNPLAND_EFFORT_tab4(i),
					     l_PPL_UNPLAND_EFFORT_tab5(i),
					     l_PPL_UNPLAND_EFFORT_tab6(i),
					     l_EQPMT_ETC_EFFORT_tab1(i),
					     l_EQPMT_ETC_EFFORT_tab2(i),
					     l_EQPMT_ETC_EFFORT_tab3(i),
					     l_EQPMT_ETC_EFFORT_tab4(i),
					     l_EQPMT_ETC_EFFORT_tab5(i),
					     l_EQPMT_ETC_EFFORT_tab6(i),
					     l_SUB_PRJ_ETC_COST_tab1(i),
					     l_SUB_PRJ_ETC_COST_tab2(i),
					     l_SUB_PRJ_ETC_COST_tab3(i),
					     l_SUB_PRJ_ETC_COST_tab4(i),
					     l_SUB_PRJ_ETC_COST_tab5(i),
					     l_SUB_PRJ_ETC_COST_tab6(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab1(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab2(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab3(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab4(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab5(i),
					      l_SUB_PRJ_PPL_ETC_COST_tab6(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab1(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab2(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab3(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab4(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab5(i),
					      l_SUB_PRJ_EQPMT_ETC_COST_tab6(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab1(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab2(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab3(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab4(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab5(i),
					      l_SUB_PRJ_PPL_ETC_EFFORT_tab6(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB1(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB2(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB3(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB4(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB5(i),
					      L_SP_EQPMT_ETC_EFFORT_TAB6(i),
                                              l_sum_tab1(i),
                                              l_sum_tab2(i),
                                              l_sum_tab3(i),
                                              l_sum_tab4(i),
                                              l_sum_tab5(i),
                                              l_sum_tab6(i),
					     l_Count
				      FROM   PA_PROJ_ROLLUP_BULK_TEMP
				      WHERE  Process_Number    = l_Process_Number
				      AND    OBJECT_TYPE <> 'PA_DELIVERABLES'
				      AND    Parent_Object_ID  =l_object_ids_tab(i)
    				      AND    parent_object_type IN ('PA_STRUCTURES','PA_TASKS') -- Bug 4450587
				      ;
				END IF; -- l_partial_rollup1 ...
			EXCEPTION
				WHEN OTHERS THEN
				l_count := 0;
			END;
			IF (l_count > 0) THEN
				l_update_required := 'Y';
	      /* Added the hint to force the unique index for bug#6185523 */
				UPDATE  /*+ INDEX( T1 PA_PROJ_ROLLUP_BULK_TEMP_U1) */ PA_PROJ_ROLLUP_BULK_TEMP T1
				SET    T1.ETC_Cost1=l_ETC_Cost_tab1(i)
				, T1.ETC_Cost2=l_ETC_Cost_tab2(i)
				, T1.ETC_Cost3=l_ETC_Cost_tab3(i)
				, T1.ETC_Cost4=l_ETC_Cost_tab4(i)
				, T1.ETC_Cost5=l_ETC_Cost_tab5(i)
				, T1.ETC_Cost6=l_ETC_Cost_tab6(i)
				, T1.PPL_ETC_COST1=l_PPL_ETC_COST_tab1(i)
				, T1.PPL_ETC_COST2=l_PPL_ETC_COST_tab2(i)
				, T1.PPL_ETC_COST3=l_PPL_ETC_COST_tab3(i)
				, T1.PPL_ETC_COST4=l_PPL_ETC_COST_tab4(i)
				, T1.PPL_ETC_COST5=l_PPL_ETC_COST_tab5(i)
				, T1.PPL_ETC_COST6=l_PPL_ETC_COST_tab6(i)
				, T1.EQPMT_ETC_COST1=l_EQPMT_ETC_COST_tab1(i)
				, T1.EQPMT_ETC_COST2=l_EQPMT_ETC_COST_tab2(i)
				, T1.EQPMT_ETC_COST3=l_EQPMT_ETC_COST_tab3(i)
				, T1.EQPMT_ETC_COST4=l_EQPMT_ETC_COST_tab4(i)
				, T1.EQPMT_ETC_COST5=l_EQPMT_ETC_COST_tab5(i)
				, T1.EQPMT_ETC_COST6=l_EQPMT_ETC_COST_tab6(i)
				, T1.PPL_UNPLAND_EFFORT1=l_PPL_UNPLAND_EFFORT_tab1(i)
				, T1.PPL_UNPLAND_EFFORT2=l_PPL_UNPLAND_EFFORT_tab2(i)
				, T1.PPL_UNPLAND_EFFORT3=l_PPL_UNPLAND_EFFORT_tab3(i)
				, T1.PPL_UNPLAND_EFFORT4=l_PPL_UNPLAND_EFFORT_tab4(i)
				, T1.PPL_UNPLAND_EFFORT5=l_PPL_UNPLAND_EFFORT_tab5(i)
				, T1.PPL_UNPLAND_EFFORT6=l_PPL_UNPLAND_EFFORT_tab6(i)
				, T1.EQPMT_ETC_EFFORT1=l_EQPMT_ETC_EFFORT_tab1(i)
				, T1.EQPMT_ETC_EFFORT2=l_EQPMT_ETC_EFFORT_tab2(i)
				, T1.EQPMT_ETC_EFFORT3=l_EQPMT_ETC_EFFORT_tab3(i)
				, T1.EQPMT_ETC_EFFORT4=l_EQPMT_ETC_EFFORT_tab4(i)
				, T1.EQPMT_ETC_EFFORT5=l_EQPMT_ETC_EFFORT_tab5(i)
				, T1.EQPMT_ETC_EFFORT6=l_EQPMT_ETC_EFFORT_tab6(i)
				, T1.SUB_PRJ_ETC_COST1=l_SUB_PRJ_ETC_COST_tab1(i)
				, T1.SUB_PRJ_ETC_COST2=l_SUB_PRJ_ETC_COST_tab2(i)
				, T1.SUB_PRJ_ETC_COST3=l_SUB_PRJ_ETC_COST_tab3(i)
				, T1.SUB_PRJ_ETC_COST4=l_SUB_PRJ_ETC_COST_tab4(i)
				, T1.SUB_PRJ_ETC_COST5=l_SUB_PRJ_ETC_COST_tab5(i)
				, T1.SUB_PRJ_ETC_COST6=l_SUB_PRJ_ETC_COST_tab6(i)
				, T1.SUB_PRJ_PPL_ETC_COST1=l_SUB_PRJ_PPL_ETC_COST_tab1(i)
				, T1.SUB_PRJ_PPL_ETC_COST2=l_SUB_PRJ_PPL_ETC_COST_tab2(i)
				, T1.SUB_PRJ_PPL_ETC_COST3=l_SUB_PRJ_PPL_ETC_COST_tab3(i)
				, T1.SUB_PRJ_PPL_ETC_COST4=l_SUB_PRJ_PPL_ETC_COST_tab4(i)
				, T1.SUB_PRJ_PPL_ETC_COST5=l_SUB_PRJ_PPL_ETC_COST_tab5(i)
				, T1.SUB_PRJ_PPL_ETC_COST6=l_SUB_PRJ_PPL_ETC_COST_tab6(i)
				, T1.SUB_PRJ_EQPMT_ETC_COST1=l_SUB_PRJ_EQPMT_ETC_COST_tab1(i)
				, T1.SUB_PRJ_EQPMT_ETC_COST2=l_SUB_PRJ_EQPMT_ETC_COST_tab2(i)
				, T1.SUB_PRJ_EQPMT_ETC_COST3=l_SUB_PRJ_EQPMT_ETC_COST_tab3(i)
				, T1.SUB_PRJ_EQPMT_ETC_COST4=l_SUB_PRJ_EQPMT_ETC_COST_tab4(i)
				, T1.SUB_PRJ_EQPMT_ETC_COST5=l_SUB_PRJ_EQPMT_ETC_COST_tab5(i)
				, T1.SUB_PRJ_EQPMT_ETC_COST6=l_SUB_PRJ_EQPMT_ETC_COST_tab6(i)
				, T1.SUB_PRJ_PPL_ETC_EFFORT1=l_SUB_PRJ_PPL_ETC_EFFORT_tab1(i)
				, T1.SUB_PRJ_PPL_ETC_EFFORT2=l_SUB_PRJ_PPL_ETC_EFFORT_tab2(i)
				, T1.SUB_PRJ_PPL_ETC_EFFORT3=l_SUB_PRJ_PPL_ETC_EFFORT_tab3(i)
				, T1.SUB_PRJ_PPL_ETC_EFFORT4=l_SUB_PRJ_PPL_ETC_EFFORT_tab4(i)
				, T1.SUB_PRJ_PPL_ETC_EFFORT5=l_SUB_PRJ_PPL_ETC_EFFORT_tab5(i)
				, T1.SUB_PRJ_PPL_ETC_EFFORT6=l_SUB_PRJ_PPL_ETC_EFFORT_tab6(i)
				, T1.SUB_PRJ_EQPMT_ETC_EFFORT1=L_SP_EQPMT_ETC_EFFORT_TAB1(i)
				, T1.SUB_PRJ_EQPMT_ETC_EFFORT2=L_SP_EQPMT_ETC_EFFORT_TAB2(i)
				, T1.SUB_PRJ_EQPMT_ETC_EFFORT3=L_SP_EQPMT_ETC_EFFORT_TAB3(i)
				, T1.SUB_PRJ_EQPMT_ETC_EFFORT4=L_SP_EQPMT_ETC_EFFORT_TAB4(i)
				, T1.SUB_PRJ_EQPMT_ETC_EFFORT5=L_SP_EQPMT_ETC_EFFORT_TAB5(i)
				, T1.SUB_PRJ_EQPMT_ETC_EFFORT6=L_SP_EQPMT_ETC_EFFORT_TAB6(i)
                                , T1.REMAINING_EFFORT1 = l_sum_tab1(i)
                                , T1.REMAINING_EFFORT2 = l_sum_tab2(i)
                                , T1.REMAINING_EFFORT3 = l_sum_tab3(i)
                                , T1.REMAINING_EFFORT4 = l_sum_tab4(i)
                                , T1.REMAINING_EFFORT5 = l_sum_tab5(i)
                                , T1.REMAINING_EFFORT6 = l_sum_tab6(i)
			       WHERE T1.Process_Number = l_Process_Number
				 AND T1.object_id = l_object_ids_tab(i)
				 AND T1.object_type = l_object_types_tab(i)
			      ;
			END IF; -- (l_count > 0) THEN
		END LOOP;
		-- NOte that Bulk Update is not done due to problem mentioned in Dates Rollup Section
		/* Please do not remove
		IF l_update_required = 'Y' THEN
			FORALL i in 1..l_object_ids_tab.count
			UPDATE PA_PROJ_ROLLUP_BULK_TEMP T1
			SET    T1.ETC_Cost1=l_ETC_Cost_tab1(i)
			, T1.ETC_Cost2=l_ETC_Cost_tab2(i)
			, T1.ETC_Cost3=l_ETC_Cost_tab3(i)
			, T1.ETC_Cost4=l_ETC_Cost_tab4(i)
			, T1.ETC_Cost5=l_ETC_Cost_tab5(i)
			, T1.ETC_Cost6=l_ETC_Cost_tab6(i)
			, T1.PPL_ETC_COST1=l_PPL_ETC_COST_tab1(i)
			, T1.PPL_ETC_COST2=l_PPL_ETC_COST_tab2(i)
			, T1.PPL_ETC_COST3=l_PPL_ETC_COST_tab3(i)
			, T1.PPL_ETC_COST4=l_PPL_ETC_COST_tab4(i)
			, T1.PPL_ETC_COST5=l_PPL_ETC_COST_tab5(i)
			, T1.PPL_ETC_COST6=l_PPL_ETC_COST_tab6(i)
			, T1.EQPMT_ETC_COST1=l_EQPMT_ETC_COST_tab1(i)
			, T1.EQPMT_ETC_COST2=l_EQPMT_ETC_COST_tab2(i)
			, T1.EQPMT_ETC_COST3=l_EQPMT_ETC_COST_tab3(i)
			, T1.EQPMT_ETC_COST4=l_EQPMT_ETC_COST_tab4(i)
			, T1.EQPMT_ETC_COST5=l_EQPMT_ETC_COST_tab5(i)
			, T1.EQPMT_ETC_COST6=l_EQPMT_ETC_COST_tab6(i)
			, T1.PPL_UNPLAND_EFFORT1=l_PPL_UNPLAND_EFFORT_tab1(i)
			, T1.PPL_UNPLAND_EFFORT2=l_PPL_UNPLAND_EFFORT_tab2(i)
			, T1.PPL_UNPLAND_EFFORT3=l_PPL_UNPLAND_EFFORT_tab3(i)
			, T1.PPL_UNPLAND_EFFORT4=l_PPL_UNPLAND_EFFORT_tab4(i)
			, T1.PPL_UNPLAND_EFFORT5=l_PPL_UNPLAND_EFFORT_tab5(i)
			, T1.PPL_UNPLAND_EFFORT6=l_PPL_UNPLAND_EFFORT_tab6(i)
			, T1.EQPMT_ETC_EFFORT1=l_EQPMT_ETC_EFFORT_tab1(i)
			, T1.EQPMT_ETC_EFFORT2=l_EQPMT_ETC_EFFORT_tab2(i)
			, T1.EQPMT_ETC_EFFORT3=l_EQPMT_ETC_EFFORT_tab3(i)
			, T1.EQPMT_ETC_EFFORT4=l_EQPMT_ETC_EFFORT_tab4(i)
			, T1.EQPMT_ETC_EFFORT5=l_EQPMT_ETC_EFFORT_tab5(i)
			, T1.EQPMT_ETC_EFFORT6=l_EQPMT_ETC_EFFORT_tab6(i)
			, T1.SUB_PRJ_ETC_COST1=l_SUB_PRJ_ETC_COST_tab1(i)
			, T1.SUB_PRJ_ETC_COST2=l_SUB_PRJ_ETC_COST_tab2(i)
			, T1.SUB_PRJ_ETC_COST3=l_SUB_PRJ_ETC_COST_tab3(i)
			, T1.SUB_PRJ_ETC_COST4=l_SUB_PRJ_ETC_COST_tab4(i)
			, T1.SUB_PRJ_ETC_COST5=l_SUB_PRJ_ETC_COST_tab5(i)
			, T1.SUB_PRJ_ETC_COST6=l_SUB_PRJ_ETC_COST_tab6(i)
			, T1.SUB_PRJ_PPL_ETC_COST1=l_SUB_PRJ_PPL_ETC_COST_tab1(i)
			, T1.SUB_PRJ_PPL_ETC_COST2=l_SUB_PRJ_PPL_ETC_COST_tab2(i)
			, T1.SUB_PRJ_PPL_ETC_COST3=l_SUB_PRJ_PPL_ETC_COST_tab3(i)
			, T1.SUB_PRJ_PPL_ETC_COST4=l_SUB_PRJ_PPL_ETC_COST_tab4(i)
			, T1.SUB_PRJ_PPL_ETC_COST5=l_SUB_PRJ_PPL_ETC_COST_tab5(i)
			, T1.SUB_PRJ_PPL_ETC_COST6=l_SUB_PRJ_PPL_ETC_COST_tab6(i)
			, T1.SUB_PRJ_EQPMT_ETC_COST1=l_SUB_PRJ_EQPMT_ETC_COST_tab1(i)
			, T1.SUB_PRJ_EQPMT_ETC_COST2=l_SUB_PRJ_EQPMT_ETC_COST_tab2(i)
			, T1.SUB_PRJ_EQPMT_ETC_COST3=l_SUB_PRJ_EQPMT_ETC_COST_tab3(i)
			, T1.SUB_PRJ_EQPMT_ETC_COST4=l_SUB_PRJ_EQPMT_ETC_COST_tab4(i)
			, T1.SUB_PRJ_EQPMT_ETC_COST5=l_SUB_PRJ_EQPMT_ETC_COST_tab5(i)
			, T1.SUB_PRJ_EQPMT_ETC_COST6=l_SUB_PRJ_EQPMT_ETC_COST_tab6(i)
			, T1.SUB_PRJ_PPL_ETC_EFFORT1=l_SUB_PRJ_PPL_ETC_EFFORT_tab1(i)
			, T1.SUB_PRJ_PPL_ETC_EFFORT2=l_SUB_PRJ_PPL_ETC_EFFORT_tab2(i)
			, T1.SUB_PRJ_PPL_ETC_EFFORT3=l_SUB_PRJ_PPL_ETC_EFFORT_tab3(i)
			, T1.SUB_PRJ_PPL_ETC_EFFORT4=l_SUB_PRJ_PPL_ETC_EFFORT_tab4(i)
			, T1.SUB_PRJ_PPL_ETC_EFFORT5=l_SUB_PRJ_PPL_ETC_EFFORT_tab5(i)
			, T1.SUB_PRJ_PPL_ETC_EFFORT6=l_SUB_PRJ_PPL_ETC_EFFORT_tab6(i)
			, T1.SUB_PRJ_EQPMT_ETC_EFFORT1=L_SP_EQPMT_ETC_EFFORT_TAB1(i)
			, T1.SUB_PRJ_EQPMT_ETC_EFFORT2=L_SP_EQPMT_ETC_EFFORT_TAB2(i)
			, T1.SUB_PRJ_EQPMT_ETC_EFFORT3=L_SP_EQPMT_ETC_EFFORT_TAB3(i)
			, T1.SUB_PRJ_EQPMT_ETC_EFFORT4=L_SP_EQPMT_ETC_EFFORT_TAB4(i)
			, T1.SUB_PRJ_EQPMT_ETC_EFFORT5=L_SP_EQPMT_ETC_EFFORT_TAB5(i)
			, T1.SUB_PRJ_EQPMT_ETC_EFFORT6=L_SP_EQPMT_ETC_EFFORT_TAB6(i)
		       WHERE T1.Process_Number = l_Process_Number
			 AND T1.object_id = l_object_ids_tab(i)
			 AND T1.object_type = l_object_types_tab(i)
		      ;
		END IF; -- l_update_required = 'Y' THEN
		*/
	END IF; -- ((p_process_flag1 = 'Y' OR p_process_flag2 = 'Y' OR p_process_flag3 = 'Y' OR p_process_flag4 = 'Y'

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After ETC Cost processing', x_Log_Level=> 3);
        END IF;

	-- ********* ETC COST ROLLUP END  *************



	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'Before Assigning data back to plsql table', x_Log_Level=> 3);
        END IF;

	l_data_count := 1;

	IF p_calling_module = 'ROLLUP_API' THEN -- Bug 4218507 : Added IF
		OPEN processed_data_structure_rol(l_process_number);
		LOOP
		  FETCH processed_data_structure_rol INTO l_data_record;
		  EXIT WHEN processed_data_structure_rol%NOTFOUND;
		  p_data_structure(l_data_count) := l_data_record;
		  l_data_count := l_data_count + 1;
		END LOOP;
		CLOSE processed_data_structure_rol;
	ELSE
		OPEN processed_data_structure(l_process_number);
		LOOP
		  FETCH processed_data_structure INTO l_data_record;
		  EXIT WHEN processed_data_structure%NOTFOUND;
		  p_data_structure(l_data_count) := l_data_record;
		  l_data_count := l_data_count + 1;
		END LOOP;
		CLOSE processed_data_structure;
	END IF;

	IF g1_debug_mode  = 'Y' THEN
                pa_debug.write(x_Module=>'PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE', x_Msg => 'After Assigning data back to plsql table', x_Log_Level=> 3);
        END IF;

	-- Bug 4289748 : removed rollback, used delete instead
        --ROLLBACK TO SAVEPOINT GENERATE_SCHEDULE_SP;
	delete from PA_PROJ_ROLLUP_BULK_TEMP where process_number = l_process_number;
        --4538049 : No need to check for x_msg_count
        --x_msg_count :=  FND_MSG_PUB.Count_Msg;
	--IF x_msg_count = 1 THEN
	--	pa_interface_utils_pub.get_messages (
	--	p_encoded       => FND_API.G_TRUE
	--	,p_msg_index     => 1
	--	,p_data          => x_msg_data
	--	,p_msg_index_out => l_msg_index_out
	--	);
	--END IF;

	--IF FND_MSG_PUB.Count_Msg > 0  THEN
	--	x_return_status := FND_API.G_RET_STS_ERROR;
	--END IF;

	IF (p_debug_mode = 'Y') AND g1_debug_mode  = 'Y' THEN
		pa_debug.debug('PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE END');
	END IF;

  EXCEPTION
    WHEN API_ERROR THEN
      x_msg_count :=  FND_MSG_PUB.Count_Msg;
      ROLLBACK TO SAVEPOINT GENERATE_SCHEDULE_SP;
      IF x_msg_count = 1 THEN
         pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT GENERATE_SCHEDULE_SP;
      FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_SCHEDULE_OBJECTS_PVT'
                                ,p_procedure_name => 'GENERATE_SCHEDULE'
			        , p_error_text     => SUBSTRB(SQLERRM,1,120));
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := substr(sqlerrm, 1, 120);
  END GENERATE_SCHEDULE;

  FUNCTION GET_PROGRESS_STATUS
  (
	 p_not_started IN VARCHAR2 default 'N'
	,p_completed IN VARCHAR2 default 'N'
	,p_in_progress IN VARCHAR2 default 'N'
	,p_on_hold IN VARCHAR2 default 'N'
  ) RETURN VARCHAR2
  IS
    l_text 			       VARCHAR2(1000);

  BEGIN
    IF(p_not_started = 'Y' AND p_completed = 'Y' AND p_in_progress = 'Y' AND p_on_hold = 'Y') THEN
	return '30';
    ELSIF(p_not_started = 'Y' AND p_completed = 'Y' AND p_in_progress = 'Y' AND p_on_hold = 'N') THEN
	return '30';
    ELSIF(p_not_started = 'Y' AND p_completed = 'Y' AND p_in_progress = 'N' AND p_on_hold = 'N') THEN
	return '30';
    ELSIF(p_not_started = 'Y' AND p_completed = 'Y' AND p_in_progress = 'N' AND p_on_hold = 'Y') THEN
	return '30';
    ELSIF(p_not_started = 'Y' AND p_completed = 'N' AND p_in_progress = 'Y' AND p_on_hold = 'N') THEN
	return '30';
    ELSIF(p_not_started = 'Y' AND p_completed = 'N' AND p_in_progress = 'Y' AND p_on_hold = 'Y') THEN
	return '30';
    ELSIF(p_not_started = 'Y' AND p_completed = 'N' AND p_in_progress = 'N' AND p_on_hold = 'Y') THEN
	return NULL;
    ELSIF(p_not_started = 'Y' AND p_completed = 'N' AND p_in_progress = 'N' AND p_on_hold = 'N') THEN
	return '10';
    ELSIF(p_not_started = 'N' AND p_completed = 'Y' AND p_in_progress = 'Y' AND p_on_hold = 'Y') THEN
	return '30';
    ELSIF(p_not_started = 'N' AND p_completed = 'Y' AND p_in_progress = 'Y' AND p_on_hold = 'N') THEN
	return '30';
    ELSIF(p_not_started = 'N' AND p_completed = 'Y' AND p_in_progress = 'N' AND p_on_hold = 'N') THEN
	return '20';
    ELSIF(p_not_started = 'N' AND p_completed = 'Y' AND p_in_progress = 'N' AND p_on_hold = 'Y') THEN
	return '30';
    ELSIF(p_not_started = 'N' AND p_completed = 'N' AND p_in_progress = 'Y' AND p_on_hold = 'N') THEN
	return '30';
    ELSIF(p_not_started = 'N' AND p_completed = 'N' AND p_in_progress = 'Y' AND p_on_hold = 'Y') THEN
	return '30';
    ELSIF(p_not_started = 'N' AND p_completed = 'N' AND p_in_progress = 'N' AND p_on_hold = 'Y') THEN
	return NULL;
    ELSIF(p_not_started = 'N' AND p_completed = 'N' AND p_in_progress = 'N' AND p_on_hold = 'N') THEN
	return NULL;
    ELSE
	return NULL;
    END IF;

  END GET_PROGRESS_STATUS;

End PA_SCHEDULE_OBJECTS_PVT;

/

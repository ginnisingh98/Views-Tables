--------------------------------------------------------
--  DDL for Package PA_SCHEDULE_OBJECTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCHEDULE_OBJECTS_PVT" AUTHID CURRENT_USER as
/*$Header: PASCHOBS.pls 120.1 2005/06/09 03:23:12 appldev  $*/


TYPE PA_SCHEDULE_OBJECTS_REC_TYPE IS RECORD (
OBJECT_TYPE				VARCHAR2(30)	:= NULL,
OBJECT_ID				NUMBER		:= NULL,
PARENT_OBJECT_TYPE			VARCHAR2(30)	:= NULL,
PARENT_OBJECT_ID			NUMBER		:= NULL,
CALENDAR_ID				NUMBER		:= NULL,
CONSTRAINT_TYPE_CODE			VARCHAR2(1)	:= NULL,
CONSTRAINT_DATE				DATE		:= NULL,
WBS_LEVEL				NUMBER		:= NULL,
START_DATE1				DATE		:= NULL,
START_DATE_OVERRIDE1			DATE		:= NULL,
FINISH_DATE1				DATE		:= NULL,
DURATION1				NUMBER		:= NULL,
TASK_STATUS1				NUMBER		:= NULL,
PROGRESS_STATUS_WEIGHT1			NUMBER		:= NULL,
PROGRESS_OVERRIDE1			NUMBER		:= NULL,
REMAINING_EFFORT1			NUMBER		:= NULL,
PERCENT_COMPLETE1			NUMBER		:= NULL,
PERCENT_OVERRIDE1			NUMBER		:= NULL,
TASK_WEIGHT1				NUMBER		:= NULL,
NUMBER_FIELD1				NUMBER		:= NULL,
ROLLUP_NODE1				VARCHAR2(1)	:= NULL,
DIRTY_FLAG1				VARCHAR2(1)	:= NULL,
  ETC_Cost1			NUMBER		:= NULL,
  PPL_ETC_COST1			NUMBER		:= NULL,
  EQPMT_ETC_COST1		NUMBER		:= NULL,
  PPL_UNPLAND_EFFORT1		NUMBER		:= NULL,
  EQPMT_ETC_EFFORT1		NUMBER		:= NULL,
  SUB_PRJ_ETC_COST1		NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_COST1		NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_COST1	NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_EFFORT1	NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_EFFORT1	NUMBER		:= NULL,
  EARNED_VALUE1			NUMBER		:= NULL,
  BAC_VALUE1			NUMBER		:= NULL,
START_DATE2				DATE		:= NULL,
START_DATE_OVERRIDE2			DATE		:= NULL,
FINISH_DATE2				DATE		:= NULL,
DURATION2				NUMBER		:= NULL,
TASK_STATUS2				NUMBER		:= NULL,
PROGRESS_STATUS_WEIGHT2			NUMBER		:= NULL,
PROGRESS_OVERRIDE2			NUMBER		:= NULL,
REMAINING_EFFORT2			NUMBER		:= NULL,
PERCENT_COMPLETE2			NUMBER		:= NULL,
PERCENT_OVERRIDE2			NUMBER		:= NULL,
TASK_WEIGHT2				NUMBER		:= NULL,
NUMBER_FIELD2				NUMBER		:= NULL,
ROLLUP_NODE2				VARCHAR2(1)	:= NULL,
DIRTY_FLAG2				VARCHAR2(1) 	:= NULL,
  ETC_Cost2			NUMBER		:= NULL,
  PPL_ETC_COST2			NUMBER		:= NULL,
  EQPMT_ETC_COST2		NUMBER		:= NULL,
  PPL_UNPLAND_EFFORT2		NUMBER		:= NULL,
  EQPMT_ETC_EFFORT2		NUMBER		:= NULL,
  SUB_PRJ_ETC_COST2		NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_COST2		NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_COST2	NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_EFFORT2	NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_EFFORT2	NUMBER		:= NULL,
  EARNED_VALUE2			NUMBER		:= NULL,
  BAC_VALUE2			NUMBER		:= NULL,
START_DATE3				DATE		:= NULL,
START_DATE_OVERRIDE3			DATE		:= NULL,
FINISH_DATE3				DATE		:= NULL,
DURATION3				NUMBER		:= NULL,
TASK_STATUS3				NUMBER		:= NULL,
PROGRESS_STATUS_WEIGHT3			NUMBER		:= NULL,
PROGRESS_OVERRIDE3			NUMBER		:= NULL,
REMAINING_EFFORT3			NUMBER		:= NULL,
PERCENT_COMPLETE3			NUMBER		:= NULL,
PERCENT_OVERRIDE3			NUMBER		:= NULL,
TASK_WEIGHT3				NUMBER		:= NULL,
NUMBER_FIELD3				NUMBER		:= NULL,
ROLLUP_NODE3				VARCHAR2(1)	:= NULL,
DIRTY_FLAG3				VARCHAR2(1) 	:= NULL,
  ETC_Cost3			NUMBER		:= NULL,
  PPL_ETC_COST3			NUMBER		:= NULL,
  EQPMT_ETC_COST3		NUMBER		:= NULL,
  PPL_UNPLAND_EFFORT3		NUMBER		:= NULL,
  EQPMT_ETC_EFFORT3		NUMBER		:= NULL,
  SUB_PRJ_ETC_COST3		NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_COST3		NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_COST3	NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_EFFORT3	NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_EFFORT3	NUMBER		:= NULL,
  EARNED_VALUE3			NUMBER		:= NULL,
  BAC_VALUE3			NUMBER		:= NULL,
START_DATE4				DATE		:= NULL,
START_DATE_OVERRIDE4			DATE		:= NULL,
FINISH_DATE4				DATE		:= NULL,
DURATION4				NUMBER		:= NULL,
TASK_STATUS4				NUMBER		:= NULL,
PROGRESS_STATUS_WEIGHT4			NUMBER		:= NULL,
PROGRESS_OVERRIDE4			NUMBER		:= NULL,
REMAINING_EFFORT4			NUMBER		:= NULL,
PERCENT_COMPLETE4			NUMBER		:= NULL,
PERCENT_OVERRIDE4			NUMBER		:= NULL,
TASK_WEIGHT4				NUMBER		:= NULL,
NUMBER_FIELD4				NUMBER		:= NULL,
ROLLUP_NODE4				VARCHAR2(1)	:= NULL,
DIRTY_FLAG4				VARCHAR2(1) 	:= NULL,
  ETC_Cost4			NUMBER		:= NULL,
  PPL_ETC_COST4			NUMBER		:= NULL,
  EQPMT_ETC_COST4		NUMBER		:= NULL,
  PPL_UNPLAND_EFFORT4		NUMBER		:= NULL,
  EQPMT_ETC_EFFORT4		NUMBER		:= NULL,
  SUB_PRJ_ETC_COST4		NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_COST4		NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_COST4	NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_EFFORT4	NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_EFFORT4	NUMBER		:= NULL,
  EARNED_VALUE4			NUMBER		:= NULL,
  BAC_VALUE4			NUMBER		:= NULL,
START_DATE5				DATE		:= NULL,
START_DATE_OVERRIDE5			DATE		:= NULL,
FINISH_DATE5				DATE		:= NULL,
DURATION5				NUMBER		:= NULL,
TASK_STATUS5				NUMBER		:= NULL,
PROGRESS_STATUS_WEIGHT5			NUMBER		:= NULL,
PROGRESS_OVERRIDE5			NUMBER		:= NULL,
REMAINING_EFFORT5			NUMBER		:= NULL,
PERCENT_COMPLETE5			NUMBER		:= NULL,
PERCENT_OVERRIDE5			NUMBER		:= NULL,
TASK_WEIGHT5				NUMBER		:= NULL,
NUMBER_FIELD5				NUMBER		:= NULL,
ROLLUP_NODE5				VARCHAR2(1)	:= NULL,
DIRTY_FLAG5				VARCHAR2(1) 	:= NULL,
  ETC_Cost5			NUMBER		:= NULL,
  PPL_ETC_COST5			NUMBER		:= NULL,
  EQPMT_ETC_COST5		NUMBER		:= NULL,
  PPL_UNPLAND_EFFORT5		NUMBER		:= NULL,
  EQPMT_ETC_EFFORT5		NUMBER		:= NULL,
  SUB_PRJ_ETC_COST5		NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_COST5		NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_COST5	NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_EFFORT5	NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_EFFORT5	NUMBER		:= NULL,
  EARNED_VALUE5			NUMBER		:= NULL,
  BAC_VALUE5			NUMBER		:= NULL,
START_DATE6				DATE		:= NULL,
START_DATE_OVERRIDE6			DATE		:= NULL,
FINISH_DATE6				DATE		:= NULL,
DURATION6				NUMBER		:= NULL,
TASK_STATUS6				NUMBER		:= NULL,
PROGRESS_STATUS_WEIGHT6			NUMBER		:= NULL,
PROGRESS_OVERRIDE6			NUMBER		:= NULL,
REMAINING_EFFORT6			NUMBER		:= NULL,
PERCENT_COMPLETE6			NUMBER		:= NULL,
PERCENT_OVERRIDE6			NUMBER		:= NULL,
TASK_WEIGHT6				NUMBER		:= NULL,
NUMBER_FIELD6				NUMBER		:= NULL,
ROLLUP_NODE6				VARCHAR2(1)	:= NULL,
DIRTY_FLAG6				VARCHAR2(1) 	:= NULL,
  ETC_Cost6			NUMBER		:= NULL,
  PPL_ETC_COST6			NUMBER		:= NULL,
  EQPMT_ETC_COST6		NUMBER		:= NULL,
  PPL_UNPLAND_EFFORT6		NUMBER		:= NULL,
  EQPMT_ETC_EFFORT6		NUMBER		:= NULL,
  SUB_PRJ_ETC_COST6		NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_COST6		NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_COST6	NUMBER		:= NULL,
  SUB_PRJ_PPL_ETC_EFFORT6	NUMBER		:= NULL,
  SUB_PRJ_EQPMT_ETC_EFFORT6	NUMBER		:= NULL,
  EARNED_VALUE6			NUMBER		:= NULL,
  BAC_VALUE6			NUMBER		:= NULL,
  PERC_COMP_DERIVATIVE_CODE1	VARCHAR(30)	:= NULL,
  PERC_COMP_DERIVATIVE_CODE2	VARCHAR(30)	:= NULL,
  PERC_COMP_DERIVATIVE_CODE3	VARCHAR(30)	:= NULL,
  PERC_COMP_DERIVATIVE_CODE4	VARCHAR(30)	:= NULL,
  PERC_COMP_DERIVATIVE_CODE5	VARCHAR(30)	:= NULL,
  PERC_COMP_DERIVATIVE_CODE6	VARCHAR(30)	:= NULL,
  SUMMARY_OBJECT_FLAG		VARCHAR(1)	:= NULL -- Bug 4370746
);
TYPE PA_SCHEDULE_OBJECTS_TBL_TYPE IS TABLE OF PA_SCHEDULE_OBJECTS_REC_TYPE
   INDEX BY BINARY_INTEGER;


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
    ,p_data_structure		IN OUT NOCOPY	PA_SCHEDULE_OBJECTS_TBL_TYPE
    ,x_process_Number			OUT NOCOPY 	NUMBER
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
--
    ,p_process_ETC_Flag1        IN      VARCHAR2 default 'N'
    ,p_partial_ETC_Flag1        IN      VARCHAR2 default 'N'
    ,p_process_ETC_Flag2        IN      VARCHAR2 default 'N'
    ,p_partial_ETC_Flag2        IN      VARCHAR2 default 'N'
    ,p_process_ETC_Flag3        IN      VARCHAR2 default 'N'
    ,p_partial_ETC_Flag3        IN      VARCHAR2 default 'N'
    ,p_process_ETC_Flag4        IN      VARCHAR2 default 'N'
    ,p_partial_ETC_Flag4        IN      VARCHAR2 default 'N'
    ,p_process_ETC_Flag5        IN      VARCHAR2 default 'N'
    ,p_partial_ETC_Flag5        IN      VARCHAR2 default 'N'
    ,p_process_ETC_Flag6        IN      VARCHAR2 default 'N'
    ,p_partial_ETC_Flag6        IN      VARCHAR2 default 'N'
    --
    ,p_Rollup_Method		IN	VARCHAR2 default 'COST'
  );


  FUNCTION GET_PROGRESS_STATUS
  (
	 p_not_started IN VARCHAR2 default 'N'
	,p_completed IN VARCHAR2 default 'N'
	,p_in_progress IN VARCHAR2 default 'N'
	,p_on_hold IN VARCHAR2 default 'N'
  ) RETURN VARCHAR2;

End PA_SCHEDULE_OBJECTS_PVT;

 

/

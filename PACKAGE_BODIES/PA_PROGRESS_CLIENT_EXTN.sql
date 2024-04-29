--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_CLIENT_EXTN" as
/* $Header: PAPCTCXB.pls 120.2 2005/09/23 04:54:40 amksingh noship $ */

-- Procedure            : GET_TASK_RES_OVERRIDE_INFO
-- Type                 : Public Procedure
-- Purpose              : This API is to be used to override the default behaviour of Oracle Application
--                      : for deriving Actual and Estimated dates for lowest tasks and task assignments.
--                      : This API will be called for all lowest tasks and task assignments, while progress
--                      : entry and running summarization process. The three places it will be called from are
--                      : pa_progress_pub.update_task_progress, pa_assignment_progress_pub.update_assignment_progress
--                      : pa_progress_pub.get_summarized_actuals.
-- Note                 : The default behavior of this API will be to return the passed dates without any modifications.
-- Assumptions          : None.
-- Patching Instruction : Please do take backup of this package if any customizations are done. After patch application
--                      : , you need to apply this backed up package again.

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_project_id		        NUMBER     NO            Unique key for the project.
-- p_structure_type		VARCHAR2   NO            Structure Type. Currently only WORKPLAN structure is supported.
--                                                       Possible values are WORKPLAN, FINANCIAL.
-- p_structure_version_id       NUMEBR     NO            Unique key for workplan structure version.
-- p_object_id		        NUMEBR     NO            Unique key for the object info. It is pa_proj_elements.proj_element_id for tasks
--                                                       and pa_resource_assignments.resource_list_member_id for task assignments.
-- p_object_type	        VARCHAR2   NO            Possible values are 'PA_TASKS', 'PA_ASSIGNMENTS'
-- p_object_version_id          NUMEBR     NO            Unique key for the object version info. It is pa_proj_element_versions.element_version_id
--                                                       for tasks and task assignments both.
-- p_proj_element_id            NUMEBR     NO            Unique key for the task. It is pa_proj_elements.proj_element_id.
-- p_task_status		VARCHAR2   NO            Current status for the task. It is pa_percent_completes.status_code.
-- p_percent_complete		NUMEBR     NO            Physical percent complete. This is applicable for tasks only.
-- p_estimated_start_date	DATE       NO            Estimated start date for task and task assignments.
-- p_estimated_finish_date	DATE       NO            Estimated finish date for task and task assignments.
-- p_actual_start_date		DATE       NO            Actual start date for task and task assignments.
-- p_actual_finish_date		DATE       NO            Actual finish date for task and task assignments.
-- x_estimated_start_date	DATE       N/A            Returned Estimated start date for task and task assignments.
-- x_estimated_finish_date	DATE       N/A            Returned Estimated finish date for task and task assignments.
-- x_actual_start_date		DATE       N/A            Returned Actual start date for task and task assignments.
-- x_actual_finish_date		DATE       N/A            Returned Actual finish date for task and task assignments.
-- x_return_status		VARCHAR2   N/A            Return Status to identify if any issue in this API. Possible values
--                                                        are S for Success, E for Failure, U for Unexpected errors.
-- x_msg_count			NUMBER     N/A            Count of the messages pushed into FND message stack.
-- x_msg_data			VARCHAR2   N/A            Last message data from FND message stack if exists.



PROCEDURE GET_TASK_RES_OVERRIDE_INFO(
	p_project_id			IN	NUMBER		:= FND_API.g_miss_num	,
	p_structure_type                IN	VARCHAR2	:= 'WORKPLAN'		,
	p_structure_version_id		IN	NUMBER		:= FND_API.g_miss_num	,
	p_object_type			IN	VARCHAR2	:= FND_API.g_miss_char	,
	p_object_id			IN	NUMBER		:= FND_API.g_miss_num	,
	p_object_version_id             IN	NUMBER		:= FND_API.g_miss_num	,
	p_proj_element_id		IN	NUMBER		:= FND_API.g_miss_num	,
	p_task_status			IN	VARCHAR2	:= FND_API.g_miss_num	,
	p_percent_complete		IN	NUMBER		:= FND_API.g_miss_num	,
	p_estimated_start_date		IN	DATE		:= FND_API.g_miss_date	,
	p_estimated_finish_date		IN	DATE		:= FND_API.g_miss_date	,
	p_actual_start_date		IN	DATE		:= FND_API.g_miss_date	,
	p_actual_finish_date		IN	DATE		:= FND_API.g_miss_date	,
	x_estimated_start_date		OUT	NOCOPY	DATE				,
	x_estimated_finish_date		OUT	NOCOPY	DATE				,
	x_actual_start_date		OUT	NOCOPY	DATE				,
	x_actual_finish_date		OUT	NOCOPY	DATE				,
	x_return_status			OUT	NOCOPY	VARCHAR2			,
	x_msg_count			OUT	NOCOPY	NUMBER				,
	x_msg_data			OUT	NOCOPY	VARCHAR2
	) IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS; -- Initialize value 'S'
	x_estimated_start_date := p_estimated_start_date;
	x_estimated_finish_date := p_estimated_finish_date;
	x_actual_start_date := p_actual_start_date;
	x_actual_finish_date := p_actual_finish_date;

	-- Your Override Implmentation code should start from here

	-- Sample for Error Message population into message stack
	-- IF error condition THEN
	--	fnd_message.set_name('PA','<MESSAGE CODE AS DEFINED IN MESSAGES SCREEN>');
	--	fnd_msg_pub.add;
	--	raise FND_API.G_EXC_ERROR;
	-- END IF;

	-- Your Override Implmentation code should End here
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_count := fnd_msg_pub.count_msg;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		fnd_msg_pub.add_exc_msg(p_pkg_name	=> 'PA_PROGRESS_CLIENT_EXTN',
                              p_procedure_name		=> 'GET_TASK_RES_OVERRIDE_INFO',
                              p_error_text		=> SUBSTRB(SQLERRM,1,120));
		x_msg_count := fnd_msg_pub.count_msg;
END GET_TASK_RES_OVERRIDE_INFO;
END;

/

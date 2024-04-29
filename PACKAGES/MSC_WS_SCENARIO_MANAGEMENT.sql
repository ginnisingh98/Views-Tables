--------------------------------------------------------
--  DDL for Package MSC_WS_SCENARIO_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_SCENARIO_MANAGEMENT" AUTHID CURRENT_USER AS
/* $Header: MSCWSMAS.pls 120.7 2008/03/12 12:00:08 bnaghi noship $ */

-- =============================================================
-- Desc: Qurery msc_planning_process table and returns.
--       ProcessName
--       ProcessFlowId
--       CurrRunSequence
--
-- Input:
--        UserId             User ID.
--        ResponsibilityId   Responsibility Id.
--        ProcessId          Process Id.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
-- =============================================================
PROCEDURE GET_PROCESS_INFO(
        Status             OUT NOCOPY VARCHAR2,
        ProcessName        OUT NOCOPY VARCHAR2,
        ProcessFlowId      OUT NOCOPY NUMBER,
        CurrRunSequence    OUT NOCOPY NUMBER,
        UserId             IN         NUMBER,
        ResponsibilityId   IN         NUMBER,
        ProcessId          IN         NUMBER
        );

 -- =============================================================
-- Desc: Qurery msc_planning_process table and returns.
--       ProcessName
--       ProcessFlowId
--       CurrRunSequence
--
-- Input:
--        UserName              User Name.
--        RespName   		Responsibility name.
--        RespApplName          Resp application name
--        SecurityGroupName     Security group name
--        Language
--        ProcessId          Process Id.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_USER_NAME, INVALID_RESP_NAME
--          INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
-- =============================================================

 PROCEDURE GET_PROCESS_INFO_PUBLIC(
        Status             OUT NOCOPY VARCHAR2,
        ProcessName        OUT NOCOPY VARCHAR2,
        ProcessFlowId      OUT NOCOPY NUMBER,
        CurrRunSequence    OUT NOCOPY NUMBER,
        UserName               IN VARCHAR2,
	RespName     IN VARCHAR2,
	RespApplName IN VARCHAR2,
	SecurityGroupName      IN VARCHAR2,
	Language            IN VARCHAR2,
        ProcessId          IN         NUMBER
        );

-- =============================================================
-- Desc: Qurery msc_planning_proc_activities table and returns.
--       PlanId
--       Skip
--       Owner (Name)
--       Time_Out
--       Alternate_Owner (Name)
--       ActivityStatus
--       ActivityType.
--
-- Input:
--        UserId             User ID.
--        ResponsibilityId   Responsibility Id.
--        ProcessId          Process Id.
--        RunSequence        Run sequence.
--        ProcessScope       Activity name.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
--          INVALID_MISSING_OWNER_ID
--          INVALID_UNKWON_OWNER_ID
--          INVALID_UNKWON_ALTERNATE_OWNER_ID
-- =============================================================
PROCEDURE GET_ACTIVITY_INST_INFO(
        Status             OUT NOCOPY VARCHAR2,
        PlanId             OUT NOCOPY NUMBER,
        Skip               OUT NOCOPY VARCHAR2,
        OwnerName          OUT NOCOPY VARCHAR2,
        TimeOut            OUT NOCOPY NUMBER,
        AlternateOwnerName OUT NOCOPY VARCHAR2,
        ActivityStatus     OUT NOCOPY VARCHAR2,
        ActivityType       OUT NOCOPY NUMBER,
        UserId             IN         NUMBER,
        ResponsibilityId   IN         NUMBER,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2
        );

-- =============================================================
-- Desc: Qurery msc_planning_proc_activities table and returns.
--       PlanId
--       Skip
--       Owner (Name)
--       Time_Out
--       Alternate_Owner (Name)
--       ActivityStatus
--       ActivityType.
--
-- Input:
--        UserName              User Name.
--        RespName   		Responsibility name.
--        RespApplName          Resp application name
--        SecurityGroupName     Security group name
--        Language
--        ProcessId          Process Id.
--        RunSequence        Run sequence.
--        ProcessScope       Activity name.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_USER_NAME, INVALID_RESP_NAME
--          INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
--          INVALID_MISSING_OWNER_ID
--          INVALID_UNKWON_OWNER_ID
--          INVALID_UNKWON_ALTERNATE_OWNER_ID
-- =============================================================

PROCEDURE GET_ACTIVITY_INST_INFO_PUBLIC(
        Status             OUT NOCOPY VARCHAR2,
        PlanId             OUT NOCOPY NUMBER,
        Skip               OUT NOCOPY VARCHAR2,
        OwnerName          OUT NOCOPY VARCHAR2,
        TimeOut            OUT NOCOPY NUMBER,
        AlternateOwnerName OUT NOCOPY VARCHAR2,
        ActivityStatus     OUT NOCOPY VARCHAR2,
        ActivityType       OUT NOCOPY NUMBER,
        UserName               IN VARCHAR2,
	RespName     IN VARCHAR2,
	RespApplName IN VARCHAR2,
	SecurityGroupName      IN VARCHAR2,
	Language            IN VARCHAR2,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2
        );

-- =============================================================
-- Desc: Update activity_status in msc_planning_proc_activities table.
-- Input:
--        UserId             User ID.
--        ResponsibilityId   Responsibility Id.
--        ProcessInstanceId  Process instance Id.
--        ProcessId          Process Id.
--        RunSequence        Run sequence.
--        ProcessScope       Activity name.
--        NewStatus          New activity status
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
--          INVALID_STATUS
-- =============================================================
PROCEDURE SET_ACTIVITY_INST_STATUS(
        Status             OUT NOCOPY VARCHAR2,
        UserId             IN         NUMBER,
        ResponsibilityId   IN         NUMBER,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2,
        NewStatus          IN         VARCHAR2
        );


-- =============================================================
-- Desc: Update activity_status in msc_planning_proc_activities table.
-- Input:
--        UserName              User Name.
--        RespName   		Responsibility name.
--        RespApplName          Resp application name
--        SecurityGroupName     Security group name
--        Language
--        ProcessInstanceId  Process instance Id.
--        ProcessId          Process Id.
--        RunSequence        Run sequence.
--        ProcessScope       Activity name.
--        NewStatus          New activity status
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_USER_NAME, INVALID_RESP_NAME
--          INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
--          INVALID_STATUS
-- =============================================================
PROCEDURE SET_ACTIVITY_INST_ST_PUBLIC(
        Status             	OUT NOCOPY VARCHAR2,
        UserName               	IN VARCHAR2,
	RespName     		IN VARCHAR2,
	RespApplName 		IN VARCHAR2,
	SecurityGroupName       IN VARCHAR2,
	Language            	IN VARCHAR2,
        ProcessId          	IN         NUMBER,
        RunSequence        	IN         NUMBER,
        ProcessScope       	IN         VARCHAR2,
        NewStatus          	IN         VARCHAR2
        );


-- =============================================================
-- Desc: Update msc_planning_process.curr_run_sequence and
--       msc_process_instances.actual_start_date.
-- Input:
--        UserId             User ID.
--        ResponsibilityId   Responsibility Id.
--        ProcessInstanceId  Process instance Id.
--        ProcessId          Process Id.
--        RunSequence        Run sequence.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
-- =============================================================
PROCEDURE UPDATE_PROCESS(
        Status             OUT NOCOPY VARCHAR2,
        UserId             IN         NUMBER,
        ResponsibilityId   IN         NUMBER,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER
        );

-- =============================================================
-- Desc: Update msc_planning_process.curr_run_sequence and
--       msc_process_instances.actual_start_date.
-- Input:
--        UserName              User Name.
--        RespName   		Responsibility name.
--        RespApplName          Resp application name
--        SecurityGroupName     Security group name
--        Language
--        ProcessInstanceId  Process instance Id.
--        ProcessId          Process Id.
--        RunSequence        Run sequence.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_USER_NAME, INVALID_RESP_NAME
--          INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
-- =============================================================

PROCEDURE UPDATE_PROCESS_PUBLIC(
        Status             OUT NOCOPY VARCHAR2,
        UserName               IN VARCHAR2,
		   RespName     IN VARCHAR2,
		   RespApplName IN VARCHAR2,
		   SecurityGroupName      IN VARCHAR2,
		   Language            IN VARCHAR2,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER
        );


-- =============================================================
-- Desc: Get value for all parameters.
-- Input:
--        UserId             User ID.
--        ResponsibilityId   Responsibility Id.
--        ProcessId          Process Id.
--        RunSequence        Run sequence.
--        ProcessScope       Activity Name.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
-- =============================================================
PROCEDURE GET_PARAMETER_VALUE(
        Status             OUT NOCOPY VARCHAR2,
        ParameterValues    OUT NOCOPY MscActivityParaTbl,
        UserId             IN         NUMBER,
        ResponsibilityId   IN         NUMBER,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2
        );

 -- =============================================================
-- Desc: Get value for all parameters.
-- Input:
--        UserName              User Name.
--        RespName   		Responsibility name.
--        RespApplName          Resp application name
--        SecurityGroupName     Security group name
--        Language
--        ProcessId             Process Id.
--        RunSequence           Run sequence.
--        ProcessScope          Activity Name.
--
-- Output: The possible return statuses are:
--          SUCCESS if everything is ok
--          NO_DATA_FOUND
--          INVALID_USER_NAME, INVALID_RESP_NAME
--       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
-- =============================================================
PROCEDURE GET_PARAMETER_VALUE_PUBLIC(
        Status             OUT NOCOPY VARCHAR2,
        ParameterValues    OUT NOCOPY MscActivityParaTbl,
        UserName               IN VARCHAR2,
        RespName     IN VARCHAR2,
	RespApplName IN VARCHAR2,
	SecurityGroupName      IN VARCHAR2,
	Language            IN VARCHAR2,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2
        );

-- =============================================================
-- Desc: This procedure is invoked from web service to launch
--       the Archive Scenario concurrent program.  The input
--       parameters mirror the parameters for the concurrent program.
-- Input:
--        UserName          User name.
--        RespName          Responsibility name.
--        RespAppName       Responsibility application name.
--        SecurityGroupName Security group name.
--        Language          Language.
--        ScenarioId        Scenario Id.
--
-- Output: Procedure returns a status and conc program req id.
--       The possible return statuses are:
--          SUCCESS if everything is ok
--          ERROR_SUBMIT          failed to submit the concurrent program
--          ERROR_UNEXPECTED_#    unexpected error
--          INVALID_USER_NAME
--          INVALID_LANGUAGE
--          INVALID_RESP_NAME
--          INVALID_SECUTITY_GROUP_NAME
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
--          INVALID_SCENARIO_ID   invalid scenario id
-- =============================================================
PROCEDURE ARCHIVE_SCENARIO_PUBLIC(
        ProcessId          OUT NOCOPY NUMBER,
        Status             OUT NOCOPY VARCHAR2,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        ScenarioId         IN         NUMBER
        );

END MSC_WS_SCENARIO_MANAGEMENT;


/

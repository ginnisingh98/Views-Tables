--------------------------------------------------------
--  DDL for Package Body MSC_WS_SCENARIO_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_SCENARIO_MANAGEMENT" AS
/* $Header: MSCWSMAB.pls 120.13 2008/03/17 19:31:15 bnaghi noship $ */
g_UserId         NUMBER;
g_ErrorCode      VARCHAR2(9);

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
        ) AS
l_String            VARCHAR2(100);
l_Skip              NUMBER;
l_Owner             NUMBER;
l_ActivityStatus    NUMBER;
BEGIN
    -- check user id and responsibility
    MSC_WS_COMMON.VALIDATE_USER_RESP(l_String, UserId, ResponsibilityId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    BEGIN
        SELECT
            process_name, process_flow_id, curr_run_sequence
        INTO
            ProcessName, ProcessFlowId, CurrRunSequence
        FROM msc_planning_process
        WHERE
            process_id = ProcessId;
        EXCEPTION
            WHEN no_data_found THEN
                Status := 'NO_DATA_FOUND';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_01001';
                RETURN;
    END;

    Status := 'SUCCESS';
END GET_PROCESS_INFO;


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
        ) AS
		     userid    number;
		     respid    number;
		     l_String VARCHAR2(30);
		     error_tracking_num number;
		     l_SecutirtGroupId  NUMBER;
		    BEGIN
		      error_tracking_num :=2010;
		       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
		       IF (l_String <> 'OK') THEN
		           Status := l_String;
		           RETURN;
		       END IF;

		        error_tracking_num :=2030;
		        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_SCN_MANAGE_SCENARIOS',l_SecutirtGroupId);
		       IF (l_String <> 'OK') THEN
		          Status := l_String;
		          RETURN;
		      END IF;
		       error_tracking_num :=2040;

		      GET_PROCESS_INFO ( Status,ProcessName, ProcessFlowId, CurrRunSequence, userId , respid, ProcessId );



		         EXCEPTION
		         WHEN others THEN
		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

		            return;
END GET_PROCESS_INFO_PUBLIC;

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
        ) AS
l_String            VARCHAR2(100);
l_Skip              NUMBER;
l_Owner             NUMBER;
l_AltOwner          NUMBER;
l_ActivityStatus    NUMBER;
BEGIN
    -- check user id and responsibility
    MSC_WS_COMMON.VALIDATE_USER_RESP(l_String, UserId, ResponsibilityId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    BEGIN
        SELECT
            plan_id, skip, owner,
            nvl(time_out,1440),
            alternate_owner,
            status, activity_type
        INTO
            PlanId, l_Skip, l_Owner, TimeOut,
            l_AltOwner, l_ActivityStatus, ActivityType
        FROM msc_planning_proc_activities
        WHERE
            process_id = ProcessId AND
            run_sequence = RunSequence AND
            process_scope = ProcessScope;
        EXCEPTION
            WHEN no_data_found THEN
                Status := 'NO_DATA_FOUND';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_01002';
                RETURN;
    END;
    -- convert Skip
    CASE l_Skip
        WHEN 1 THEN
            Skip := 'Y';
        WHEN 2 THEN
            Skip := 'N';
        ELSE
            Status := 'ERROR_UNEXPECTED_01003';
            RETURN;
    END CASE;

    -- convert Owner from ID to name
    IF l_Owner IS NULL THEN
        Status := 'INVALID_MISSING_OWNER_ID';
        RETURN;
    END IF;
    BEGIN
        SELECT user_name
        INTO   OwnerName
        FROM   fnd_user
        where  user_id = l_Owner;
        EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_UNKWON_OWNER_ID';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_01004';
                RETURN;
    END;

    -- convert EscalateTo from ID to name
    IF l_AltOwner IS NULL THEN
        AlternateOwnerName := '-1';
    ELSE
        BEGIN
            SELECT user_name
            INTO   AlternateOwnerName
            FROM   fnd_user
            WHERE  user_id = l_AltOwner;
            EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_UNKWON_ALTERNATE_OWNER_ID';
                RETURN;
                WHEN others THEN
                    Status := 'ERROR_UNEXPECTED_01005';
                    RETURN;
        END;
    END IF;

    -- convert activity status
    IF l_ActivityStatus =1 THEN
        ActivityStatus := 'NOT_START';
    ELSIF l_ActivityStatus = 2 THEN
        ActivityStatus := 'IN_PROGRESS';
    ELSIF l_ActivityStatus = 3 THEN
        ActivityStatus := 'COMPLETED';
    ELSIF l_ActivityStatus = 4 THEN
        ActivityStatus := 'ERROR';
    ELSIF l_ActivityStatus = 5 THEN
        ActivityStatus := 'ABORTED';
    ELSIF l_ActivityStatus = 6 THEN
        ActivityStatus := 'WARNING';
    ELSE
        Status := 'ERROR_UNEXPECTED_01006';
        RETURN;
    END IF;

    Status := 'SUCCESS';
END GET_ACTIVITY_INST_INFO;


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
        )  AS
		     userid    number;
		     respid    number;
		     l_String VARCHAR2(30);
		     error_tracking_num number;
		     l_SecutirtGroupId  NUMBER;
		    BEGIN
		      error_tracking_num :=2010;
		       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
		       IF (l_String <> 'OK') THEN
		           Status := l_String;
		           RETURN;
		       END IF;

		        error_tracking_num :=2030;
		        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_SCN_MANAGE_SCENARIOS',l_SecutirtGroupId);
		       IF (l_String <> 'OK') THEN
		          Status := l_String;
		          RETURN;
		      END IF;
		       error_tracking_num :=2040;

		      GET_ACTIVITY_INST_INFO ( Status,
                                          PlanId,
                                          Skip,
                                          OwnerName,
                                          TimeOut,
                                          AlternateOwnerName,
                                          ActivityStatus,
                                          ActivityType,
                                          userid,
                                          respid,
                                          ProcessId ,
                                          RunSequence ,
                                          ProcessScope);



		         EXCEPTION
		         WHEN others THEN
		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

		            return;
END GET_ACTIVITY_INST_INFO_PUBLIC;

-- =============================================================
-- Desc: Qurery current activity status.
-- Input:
--        ProcessInstanceId  Process instance Id.
--        ActivityId         Activity Id.
--
-- Output: The possible return statuses are:
--          OK
--          NO_DATA_FOUND
-- =============================================================
FUNCTION GET_ACTIVITY_STATUS(
        ActivityStatus     OUT NOCOPY NUMBER,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2
        ) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        -- SELECT status
        SELECT status
        INTO   ActivityStatus
        FROM msc_planning_proc_activities
        WHERE
            process_id = ProcessId AND
            run_sequence = RunSequence AND
            Process_Scope = ProcessScope;
        EXCEPTION
            WHEN no_data_found THEN
                RETURN 'NO_DATA_FOUND';
            WHEN others THEN
                RETURN 'ERROR_UNEXPECTED_01007';
    END;
    RETURN 'OK';
END GET_ACTIVITY_STATUS;

-- =============================================================
-- Desc: verify the input activity status.
-- Input:
--        ProcessInstanceId  Process instance Id.
--        ActivityId         Activity Id.
--
-- Output: The possible return statuses are:
--          OK
--          NO_DATA_FOUND
-- =============================================================
FUNCTION VALIDATE_ACTIVITY_STATUS(
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2,
        ActivityStatus     IN         NUMBER
        ) RETURN VARCHAR2 AS
l_String            VARCHAR2(100);
l_ActivityStatus    NUMBER;
BEGIN
    l_String := GET_ACTIVITY_STATUS(l_ActivityStatus, ProcessId, RunSequence, ProcessScope);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- safety net, Not Start, Aborted and Warning are restricted by xsd.
    IF ActivityStatus = 1 OR ActivityStatus = 5 OR ActivityStatus = 6 THEN
        RETURN 'INVALID_STATUS';
    END IF;

    -- =======================================
    -- Activity status can be changed from :-
    --     Not Start to In Process
    --     In Process to Error
    --     In Process to Completed
    --     In Completed to Completed (special requested by Beatrice)
    -- =======================================
    CASE ActivityStatus
        WHEN 2 THEN -- In Process
            IF l_ActivityStatus <> 1 THEN
                RETURN 'INVALID_STATUS';
            END IF;
        WHEN 3 THEN -- Completed
            -- New behaviour, able to change from process to completed
            IF l_ActivityStatus <> 2 AND l_ActivityStatus <> 3 THEN
                RETURN 'INVALID_STATUS';
            END IF;
        WHEN 4 THEN -- Error
            IF l_ActivityStatus <> 2 THEN
                RETURN 'INVALID_STATUS';
            END IF;
        ELSE
            RETURN 'INVALID_STATUS';
    END CASE;

    RETURN 'OK';
END VALIDATE_ACTIVITY_STATUS;

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
        ) AS
l_String            VARCHAR2(100);
l_NewStatus         NUMBER;
BEGIN
    -- check user id and responsibility
    MSC_WS_COMMON.VALIDATE_USER_RESP(l_String, UserId, ResponsibilityId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- convert activity status, NOT_START, ABORTED and WARNING are not allowed in xsd
    IF NewStatus = 'IN_PROGRESS' THEN
        l_NewStatus := 2;
    ELSIF NewStatus = 'COMPLETED' THEN
        l_NewStatus := 3;
    ELSIF NewStatus = 'ERROR' THEN
        l_NewStatus := 4;
    END IF;

    l_String := VALIDATE_ACTIVITY_STATUS(ProcessId, RunSequence, ProcessScope, l_NewStatus);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- update msc_planning_proc_activities
    BEGIN
        UPDATE msc_planning_proc_activities
        SET status = l_NewStatus
        WHERE
            process_id = ProcessId AND
            run_sequence = RunSequence AND
            Process_Scope = ProcessScope;
        EXCEPTION
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_01008';
                RETURN;
    END;

    -- Just find out from Vijay, we don't need to do this
       -- update scenario_definitions as well if need
       -- to do:
       -- if this is the 1st act and is set to In Progress, set scenario_definitions.process_status to In Progress as well
       -- if this is the last act and is set to Completed, set scenario_definitions.process_status to Completed as well
       -- if new status is Error, set scenario_definitions.process_status to Error as well

    Status := 'SUCCESS';
END SET_ACTIVITY_INST_STATUS;

PROCEDURE SET_ACTIVITY_INST_ST_PUBLIC(
        Status             OUT NOCOPY VARCHAR2,
        UserName               IN VARCHAR2,
		   		   RespName     IN VARCHAR2,
		   		   RespApplName IN VARCHAR2,
		   		   SecurityGroupName      IN VARCHAR2,
		   		   Language            IN VARCHAR2,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER,
        ProcessScope       IN         VARCHAR2,
        NewStatus          IN         VARCHAR2
        ) AS
		     userid    number;
		     respid    number;
		     l_String VARCHAR2(30);
		     error_tracking_num number;
		     l_SecutirtGroupId  NUMBER;
		    BEGIN
		      error_tracking_num :=2010;
		       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
		       IF (l_String <> 'OK') THEN
		           Status := l_String;
		           RETURN;
		       END IF;

		      error_tracking_num :=2030;
		        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_SCN_MANAGE_SCENARIOS',l_SecutirtGroupId);
		       IF (l_String <> 'OK') THEN
		          Status := l_String;
		          RETURN;
		      END IF;
		       error_tracking_num :=2040;

		      SET_ACTIVITY_INST_STATUS (  status,
                                                  userid ,
                                                  respid,
                                                  ProcessId,
                                                  RunSequence,
                                                  ProcessScope,
                                                  NewStatus);
		      --      dbms_output.put_line('USERID=' || userid);


		         EXCEPTION
		         WHEN others THEN
		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

		            return;
END SET_ACTIVITY_INST_ST_PUBLIC;

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
        ) AS
l_String            VARCHAR2(100);
l_NextActivityId    NUMBER;
e_NoDataFound       EXCEPTION;
BEGIN
    -- check user id and responsibility
    MSC_WS_COMMON.VALIDATE_USER_RESP(l_String, UserId, ResponsibilityId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;


    -- update msc_process_instances.actual_start_date
    UPDATE msc_process_instances
    SET actual_start_date = sysdate,
        last_update_date = sysdate,
        last_updated_by = userid,
        last_update_login = userid
    WHERE
        process_id = ProcessId AND
        run_sequence = RunSequence;
    IF SQL%NOTFOUND THEN
        raise e_NoDataFound;
    END IF;

    COMMIT;
    Status := 'SUCCESS';

    EXCEPTION
        WHEN e_NoDataFound THEN
            Status := 'NO_DATA_FOUND';
            RETURN;
        WHEN others THEN
            Status := 'ERROR_UNEXPECTED_01009';
            RETURN;

END UPDATE_PROCESS;


PROCEDURE UPDATE_PROCESS_PUBLIC(
        Status             OUT NOCOPY VARCHAR2,
        UserName               IN VARCHAR2,
		   RespName     IN VARCHAR2,
		   RespApplName IN VARCHAR2,
		   SecurityGroupName      IN VARCHAR2,
		   Language            IN VARCHAR2,
        ProcessId          IN         NUMBER,
        RunSequence        IN         NUMBER
        ) AS
		     userid    number;
		     respid    number;
		     l_String VARCHAR2(30);
		     error_tracking_num number;
		     l_SecutirtGroupId  NUMBER;
		    BEGIN
		      error_tracking_num :=2010;
		       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
		       IF (l_String <> 'OK') THEN
		           Status := l_String;
		           RETURN;
		       END IF;

		      error_tracking_num :=2030;
		        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_SCN_MANAGE_SCENARIOS',l_SecutirtGroupId);
		       IF (l_String <> 'OK') THEN
		          Status := l_String;
		          RETURN;
		      END IF;
		       error_tracking_num :=2040;

		      UPDATE_PROCESS( status,
                                      userId ,
                                    respid,
                                    ProcessId,
                                    RunSequence );



		         EXCEPTION
		         WHEN others THEN
		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

		            return;
END UPDATE_PROCESS_PUBLIC;
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
        ) AS
CURSOR getParameter_c (idProcess NUMBER, seqRun NUMBER, nameActivity VARCHAR2) IS
    SELECT param_name, param_value
    FROM   msc_proc_inst_act_params
    WHERE  process_id = idProcess AND
           run_sequence = seqRun AND
           activity_id =
               ( SELECT activity_id FROM msc_planning_proc_activities
                 WHERE  process_id = idProcess AND
                        run_sequence = seqRun AND
                        process_scope = nameActivity)
    ORDER BY parameterSequence;
l_String            VARCHAR2(100);
l_ParameterName     VARCHAR2(50);
l_ParameterValue    VARCHAR2(50);
l_Dummy             NUMBER;
BEGIN
    BEGIN
        ParameterValues := MscActivityParaTbl();
        OPEN getParameter_c(ProcessId, RunSequence, ProcessScope);
        LOOP
            FETCH getParameter_c into l_ParameterName, l_ParameterValue;
            EXIT WHEN getParameter_c%NOTFOUND;
            ParameterValues.extend;
            ParameterValues(ParameterValues.count) := MscActivityParaRec(l_ParameterName, l_ParameterValue);
        END LOOP;
        CLOSE getParameter_c;

        IF ParameterValues.count = 0 THEN
            SELECT count(*) INTO l_Dummy
            FROM   msc_proc_inst_act_params
            WHERE  process_id = ProcessId AND
                   run_sequence = RunSequence AND
                   activity_id =
                       ( SELECT activity_id FROM msc_planning_proc_activities
                         WHERE  process_id = RunSequence AND
                                run_sequence = RunSequence AND
                                process_scope = ProcessScope);
            IF l_Dummy = 0 THEN
                status := 'NO_DATA_FOUND'; -- wrong Process id / activity name
                RETURN;
            END IF;
            -- do nothing, this activity has no parameter
        END IF;
        Status := 'SUCCESS';

        EXCEPTION WHEN others THEN
            status := 'ERROR_UNEXPECTED_01010';
    END;
END GET_PARAMETER_VALUE;


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
        ) AS
		     userid    number;
		     respid    number;
		     l_String VARCHAR2(30);
		     error_tracking_num number;
		     l_SecutirtGroupId  NUMBER;
		    BEGIN
		     ParameterValues := MscActivityParaTbl();
		      error_tracking_num :=2010;
		       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
		       IF (l_String <> 'OK') THEN
		           Status := l_String;
		           RETURN;
		       END IF;

		     error_tracking_num :=2030;
		        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_SCN_MANAGE_SCENARIOS',l_SecutirtGroupId);
		       IF (l_String <> 'OK') THEN
		          Status := l_String;
		          RETURN;
		      END IF;
		       error_tracking_num :=2040;

		      GET_PARAMETER_VALUE ( status,
                                           ParameterValues,
                                           userid ,
                                           respid,
                                           ProcessId ,
                                            RunSequence,
                                           ProcessScope);



		         EXCEPTION
		         WHEN others THEN
		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

		            return;
END GET_PARAMETER_VALUE_PUBLIC;
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
        ) IS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_Dummy             NUMBER;
l_Number            NUMBER;
error_tracking_num  NUMBER;
BEGIN
-- dbms_output.put_line('Matthew: Init');
    -- init global variables
    g_ErrorCode    := '';
    ProcessId      := -1;

    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
 error_tracking_num :=2030;
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSC_SCN_MANAGE_SCENARIOS',l_SecurityGroupId);
    		       IF (l_String <> 'OK') THEN
    		          Status := l_String;
    		          RETURN;
	END IF;

    -- check scenario id
    BEGIN
        SELECT 1 INTO l_Dummy
        FROM msc_scenarios
        WHERE
            NVL(valid_from, TRUNC(SYSDATE) - 1) < TRUNC(SYSDATE) AND
            NVL(valid_to, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE) AND
            scenario_id = ScenarioId;
        EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_SCENARIO_ID';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_01011';
                RETURN;
    END;

    -- Now, submit the conc. program to run
    l_Number := fnd_request.submit_request(
                          application => 'MSC',
                          program => 'MSCSCNAR',
                          argument1 => ScenarioId
                          );
    IF (l_Number = 0) THEN
        Status := 'ERROR_SUBMIT';
    ELSE
        ProcessId := l_Number;
        Status := 'SUCCESS';
    END IF;

    EXCEPTION
        WHEN others THEN
            Status := g_ErrorCode;

END ARCHIVE_SCENARIO_PUBLIC;

END MSC_WS_SCENARIO_MANAGEMENT;


/

--------------------------------------------------------
--  DDL for Package Body MSC_WS_SNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_SNO" AS
/* $Header: MSCWSNOB.pls 120.8.12010000.1 2008/05/02 19:09:18 appldev ship $ */

g_ErrorCode      VARCHAR2(9);

PROCEDURE GENERATE_SNO_MODEL(
        processId          OUT NOCOPY NUMBER,
        status             OUT NOCOPY VARCHAR2,
        userId             IN NUMBER,
        respId             IN NUMBER,
        planId             IN NUMBER,
        solveOnServer      IN VARCHAR2
        ) IS
l_String            VARCHAR2(100);
l_PlanName          VARCHAR2(100);
l_Number            NUMBER;
l_Result            BOOLEAN;
BEGIN
    -- check user name , responsibility and form function
    -- bpel flow has trouble to validate function, comment out it right now.
    -- VALIDATE_USER_RESP_FUNC(l_String, userId, respId, 'MSC_FNDRSRUN_LAUNCH_SNO_PLAN' );
    MSC_WS_COMMON.VALIDATE_USER_RESP(l_String, userId, respId);
    IF (l_String <> 'OK') THEN
        processId := -1;
        status := l_String;
        RETURN;
    END IF;

    -- check the plan
     BEGIN
       SELECT COMPILE_DESIGNATOR INTO l_PlanName
       FROM MSC_PLANS
       WHERE PLAN_ID = planId and PLAN_TYPE = 6;
       EXCEPTION WHEN no_data_found THEN
              processId := -1;
              status := 'INVALID_PLANID';
              RETURN;
                 WHEN others THEN
              raise;
     END;


    -- Now, submit the conc. program to run
    l_Number := fnd_request.submit_request(
                          'MSC',
                          'MSCSCPSNO',
                             NULL,                      -- description
                             NULL,                      -- start_time
                             FALSE,                     -- sub_request
                           l_PlanName,
                           solveOnServer
                          );
    IF (l_Number = 0) THEN
        processId := -1;
        status := 'Failed '||fnd_message.get;
        --status := 'ERROR_SUBMIT';
    ELSE
        processId := l_Number;
        status := 'SUCCESS';
    END IF;

    EXCEPTION
        WHEN others THEN
            processId := -1;
            status := g_ErrorCode;

END GENERATE_SNO_MODEL;

PROCEDURE     GENERATE_SNO_MODEL_PUBLIC (
                           processId          OUT NOCOPY NUMBER,
                           status             OUT NOCOPY VARCHAR2,
                           UserName               IN VARCHAR2,
			   RespName     IN VARCHAR2,
			   RespApplName IN VARCHAR2,
			   SecurityGroupName      IN VARCHAR2,
			   Language            IN VARCHAR2,
                           planId             IN NUMBER,
                           solveOnServer      IN VARCHAR2
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
		        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_FNDRSRUN_LAUNCH_SNO_PLAN',l_SecutirtGroupId);
		       IF (l_String <> 'OK') THEN
		           Status := l_String;
		           RETURN;
		       END IF;
		       error_tracking_num :=2040;

		      GENERATE_SNO_MODEL ( PROCESSID,
                                            Status,
                                            userId ,
                                            respid,
                                            planId,
                                            solveOnServer );



		         EXCEPTION
		         WHEN others THEN
		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

		            return;
END  GENERATE_SNO_MODEL_PUBLIC;

PROCEDURE     PUBLISH_SNO_PLAN (
                       processId          OUT NOCOPY NUMBER,
                       status             OUT NOCOPY VARCHAR2,
                       userId             IN NUMBER,
                       respId             IN NUMBER,
                       planId             IN NUMBER,
                       appProfile         IN VARCHAR2
                      ) IS
l_String            VARCHAR2(100);
l_PlanName          VARCHAR2(100);
l_Number            NUMBER;
BEGIN
    -- check user name and responsibility
    -- VALIDATE_USER_RESP_FUNC(l_String, userId, respId, 'MSC_FNDRSRUN_LAUNCH_SNO_PLAN' );
    MSC_WS_COMMON.VALIDATE_USER_RESP(l_String, userId, respId);

    IF (l_String <> 'OK') THEN
        processId := -1;
        status := l_String;
        RETURN;
    END IF;

    -- check profile
    IF ( appProfile <> 'SCRM' AND appProfile <> 'SOP') THEN
        processId := -1;
        status := 'INVALID_PROFILE';
        RETURN;
    END IF;

    -- check the plan
     BEGIN
       SELECT COMPILE_DESIGNATOR INTO l_PlanName
       FROM MSC_PLANS
       WHERE PLAN_ID = planId and PLAN_TYPE = 6;
       EXCEPTION WHEN no_data_found THEN
              processId := -1;
              status := 'INVALID_PLANID';
              RETURN;
                 WHEN others THEN
              raise;
     END;


    -- Now, submit the conc. program to run
    l_Number := fnd_request.submit_request(
                          'MSC',
                          'MSCSNOPUBLISH',
                             NULL,                      -- description
                             NULL,                      -- start_time
                             FALSE,                     -- sub_request
                           planId,                      -- plan id
                           appProfile,                  -- app profile (SOP/SCRM)
                           'N',                         -- zip option (not used)
                           'Y'                          -- server mode
                          );
    IF (l_Number = 0) THEN
        processId := -1;
        status := 'Failed '||fnd_message.get;
        --status := 'ERROR_SUBMIT';
    ELSE
        processId := l_Number;
        status := 'SUCCESS';
    END IF;

    EXCEPTION
        WHEN others THEN
            processId := -1;
            status := g_ErrorCode;

END PUBLISH_SNO_PLAN;

PROCEDURE     PUBLISH_SNO_PLAN_PUBLIC (
                           processId          OUT NOCOPY NUMBER,
                           status             OUT NOCOPY VARCHAR2,
                            UserName               IN VARCHAR2,
			   RespName     IN VARCHAR2,
			   RespApplName IN VARCHAR2,
			   SecurityGroupName      IN VARCHAR2,
			   Language            IN VARCHAR2,
                           planId             IN NUMBER,
                           appProfile         IN VARCHAR2
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
		        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_FNDRSRUN_LAUNCH_SNO_PLAN',l_SecutirtGroupId);
		       IF (l_String <> 'OK') THEN
		           Status := l_String;
		           RETURN;
		       END IF;

		       error_tracking_num :=2040;

		      PUBLISH_SNO_PLAN ( processid,Status, userId , respid, planId,
                           appProfile   );



		         EXCEPTION
		         WHEN others THEN
		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

		            return;
END  PUBLISH_SNO_PLAN_PUBLIC;


END MSC_WS_SNO;

/

--------------------------------------------------------
--  DDL for Package Body MSC_WS_PLAN_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_PLAN_MANAGEMENT" AS
/* $Header: MSCWPMAB.pls 120.8 2008/03/14 23:17:46 ryliu noship $ */

g_UserId         NUMBER;
g_ErrorCode      VARCHAR2(9);

-- validate source plan id, simulate the logic from Value Set "MSC_SRS_NAME_COPY"
FUNCTION VALIDATE_COPY_PLAN_ID(
        OrgId              OUT NOCOPY NUMBER,
        InsId              OUT NOCOPY NUMBER,
        SrcPlanName        OUT NOCOPY VARCHAR2,
        PlanId             IN         NUMBER
        ) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(30);
l_OrgId            NUMBER;
l_InsId            NUMBER;
l_PlanName         VARCHAR2(10);
BEGIN
    BEGIN
        SELECT
            plans.organization_id,
            plans.sr_instance_id,
            plans.compile_designator
        INTO
            l_OrgId,
            l_InsId,
            l_PlanName
        FROM
            msc_plans       plans,
            msc_designators desig
        WHERE
            plans.organization_id = desig.organization_id AND
            plans.sr_instance_id = desig.sr_instance_id AND
            plans.compile_designator = desig.designator AND
            NVL(desig.disable_date, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE) AND
            plans.organization_selection <> 1 AND
            plans.curr_plan_type in (1,2,3,4,5,8,9) AND
            plans.plan_completion_date IS NOT NULL AND
            plans.data_completion_date IS NOT NULL AND
            plans.plan_id <> -1 AND
            ( (plans.curr_plan_type in (1,2,3,4,8,9) AND
              plans.organization_selection <> 1) or
              plans.curr_plan_type = 5 ) AND
            NVL(plans.copy_plan_id,-1) = -1 AND
            NVL(desig.copy_designator_id, -1) = -1 AND
            plans.plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_ReturnString := 'INVALID_SRCPLNID';
            RETURN l_ReturnString;
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00001';
            raise;
    END;

    l_ReturnString := 'OK';
    OrgId := l_OrgId;
    InsId := l_InsId;
    SrcPlanName := l_PlanName;
    RETURN l_ReturnString;
END VALIDATE_COPY_PLAN_ID;

-- validate destination plan name
FUNCTION VALIDATE_DEST_PLAN_NAME(
        OrgId              IN         NUMBER,
        InsId              IN         NUMBER,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(30);
l_Dummy           NUMBER;
BEGIN
    BEGIN
        SELECT 1 INTO l_Dummy
        FROM
            msc_plans       plans
        WHERE
            plans.organization_id = OrgId AND
            plans.sr_instance_id = InsId AND
            plans.compile_designator = PlanName;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_ReturnString := 'OK';
            RETURN l_ReturnString;
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00002';
            raise;
    END;

    l_ReturnString := 'INVALID_DESTPLNNAME';
    RETURN l_ReturnString;
END VALIDATE_DEST_PLAN_NAME;

-- get Destination Org Selection
FUNCTION GET_DEST_ORG_SELECTION(
        OrgId              IN         NUMBER,
        InsId              IN         NUMBER,
        PlanName           IN         VARCHAR2
        ) RETURN NUMBER AS
l_Dest_OrgSel           NUMBER;
BEGIN
    BEGIN
        SELECT organization_selection INTO l_Dest_OrgSel
        FROM msc_designators
        WHERE
            designator = PlanName AND
            organization_id = OrgId AND
            sr_instance_id = InsId;
        EXCEPTION
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00003';
            raise;
    END;
    RETURN l_Dest_OrgSel;
END GET_DEST_ORG_SELECTION;


-- validate Designator Id
FUNCTION VALIDATE_DESIGATOR_ID( DesignatorId IN  NUMBER ) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(30);
l_DesignatorId    NUMBER;
BEGIN
    BEGIN
        SELECT
            designator_id INTO l_DesignatorId
	FROM
	    msc_designators
	WHERE
	    designator_id = DesignatorId AND
	    nvl(copy_designator_id,-1) = -1 AND
	    (
	        -- 2,3,4 for ASCP. 8 is DRP. 11 is SRP
	        ( designator_type IN (2, 3, 4, 8, 11) AND nvl(collected_flag,2) <> 1 ) OR
	        -- IO plan
	        /*
	         This decode statement is copied from the 'Name' form of IO plan.
	         Will come back and re-look at this decode, it always returns 5,
	         why?
	        */
	        ( designator_type = decode(4, 1,3,2,2,3,4,4,5,9,12) )
	    );
        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_ReturnString := 'INVALID_DESIGNATORID';
            RETURN l_ReturnString;
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00004';
            raise;

    END;

    l_ReturnString := 'OK';
    RETURN l_ReturnString;
END VALIDATE_DESIGATOR_ID;

-- validate archive plan id, simulate the logic from Value Set "MSC_SRS_NAME_COPY"
FUNCTION VALIDATE_ARCHIVE_PLAN_ID(
        ArchiveFlag        OUT NOCOPY NUMBER,
        PlanId             IN         NUMBER
        ) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT NVL(archive_flag, 2)
        INTO ArchiveFlag
        FROM
            msc_plans       plans,
            msc_designators desig
        WHERE
            plans.organization_id = desig.organization_id AND
            plans.sr_instance_id = desig.sr_instance_id AND
            plans.compile_designator = desig.designator AND
            NVL(desig.disable_date, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE) AND
            plans.organization_selection <> 1 AND
            plans.curr_plan_type in (1,2,3,4,5,8,9) AND
            plans.plan_completion_date IS NOT NULL AND
            plans.data_completion_date IS NOT NULL AND
            plans.plan_id <> -1 AND
            ( (plans.curr_plan_type in (1,2,3,4,8,9) AND
              plans.organization_selection <> 1) or
              plans.curr_plan_type = 5 ) AND
            NVL(plans.copy_plan_id,-1) = -1 AND
            NVL(desig.copy_designator_id, -1) = -1 AND
            plans.plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLAN_ID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00007';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_ARCHIVE_PLAN_ID;

PROCEDURE COPY_PLAN(
        ProcessId          OUT NOCOPY NUMBER,
        Status             OUT NOCOPY VARCHAR2,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        SrcPlanId          IN         NUMBER,
        DestPlanName       IN         VARCHAR2,
        DestPlanDesc       IN         VARCHAR2 default NULL,
        DestATP            IN         VARCHAR2,
        DestProd           IN         VARCHAR2,
        DestNoti           IN         VARCHAR2,
        DestInacOn         IN         DATE default NULL,
        CopyOptionsOnly    IN         VARCHAR2
        ) IS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_OrgId             NUMBER;
l_InsId             NUMBER;
l_SrcPlanName       VARCHAR2(10);
l_DestOrgSelection  NUMBER;
l_Number            NUMBER;
l_PlanType          NUMBER;
BEGIN
    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SCP',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
      MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SRO',l_SecurityGroupId);
      IF (l_String <> 'OK') THEN
        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCDP',l_SecurityGroupId);
        IF (l_String <> 'OK') THEN
          MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SRP',l_SecurityGroupId);
          IF (l_String <> 'OK') THEN
            Status := l_String;
            RETURN;
          END IF;
        END IF;
      END IF;
    END IF;

    IF MSC_WS_COMMON.BOOL_TO_NUMBER(CopyOptionsOnly) = MSC_UTIL.SYS_YES THEN
        /*
        The Copy Plan Options Only feature is not implemented yet, will do it later.
        */
        ProcessId := -1;
        Status := 'We don''t support Copy Plan Options Only feature for now!';
    ELSE
        -- check source plan id
        l_String := VALIDATE_COPY_PLAN_ID(l_OrgId, l_InsId, l_SrcPlanName, SrcPlanId);
        IF (l_String <> 'OK') THEN
            ProcessId := -1;
            Status := l_String;
            RETURN;
        END IF;

        -- check destination plan name
        l_String := VALIDATE_DEST_PLAN_NAME(l_OrgId, l_InsId, DestPlanName);
        IF (l_String <> 'OK') THEN
            ProcessId := -1;
            Status := l_String;
            RETURN;
        END IF;

        -- get Destination Org Selection
        l_DestOrgSelection := GET_DEST_ORG_SELECTION(l_OrgId, l_InsId, l_SrcPlanName);

        BEGIN
            SELECT curr_plan_type INTO l_PlanType
	    FROM   msc_plans
            WHERE  plan_id = SrcPlanId;
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_00005';
                raise;
        END;

        -- validate the rest parameters for diff plan type
        IF l_PlanType  = 4 OR l_PlanType  = 8 THEN -- IO/SRP
            IF DestATP <> 'N' THEN
                ProcessId := -1;
                Status := 'INVALID_DESTATP';
                RETURN;
            END IF;
            IF DestProd <> 'N' THEN
                ProcessId := -1;
                Status := 'INVALID_DESTPROD';
                RETURN;
            END IF;
            IF l_PlanType  = 4 THEN -- IO
                IF DestNoti <> 'N' THEN
                    ProcessId := -1;
                    Status := 'INVALID_DESTNOTI';
                    RETURN;
                END IF;
            END IF;
        END IF;

        -- Now, submit the conc. program to run
        l_Number := fnd_request.submit_request(
                              application => 'MSC',
                              program => 'MSCCPP5',
                              argument1 => SrcPlanId,
                              argument2 => DestPlanName,
                              argument3 => DestPlanDesc,
                              argument4 => l_DestOrgSelection,
                              argument5 => MSC_WS_COMMON.BOOL_TO_NUMBER(DestATP),
                              argument6 => MSC_WS_COMMON.BOOL_TO_NUMBER(DestProd),
                              argument7 => MSC_WS_COMMON.BOOL_TO_NUMBER(DestNoti),
                              argument8 => to_char(DestInacOn, 'DD-MM-YYYY'),
                              argument9 => l_OrgId,
                              argument10 => l_InsId
                              );
    IF (l_Number = 0) THEN
        ProcessId := -1;
        -- Status := 'Failed '||fnd_message.get;
        Status := 'ERROR_SUBMIT';
    ELSE
        ProcessId := l_Number;
        Status := 'SUCCESS';
    END IF;

    END IF;
    EXCEPTION
        WHEN others THEN
            ProcessId := -1;
            Status := g_ErrorCode;

END COPY_PLAN;

PROCEDURE PURGE_PLAN(
        ProcessId          OUT NOCOPY NUMBER,
        Status             OUT NOCOPY VARCHAR2,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        DesignatorId       IN         NUMBER
        ) IS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_Number            NUMBER;
BEGIN
    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SCP',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
      MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SRO',l_SecurityGroupId);
      IF (l_String <> 'OK') THEN
        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCDP',l_SecurityGroupId);
        IF (l_String <> 'OK') THEN
          MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SRP',l_SecurityGroupId);
          IF (l_String <> 'OK') THEN
            Status := l_String;
            RETURN;
          END IF;
        END IF;
      END IF;
    END IF;


    -- check DesignatorId
    l_String := Validate_Desigator_Id(DesignatorId);
    IF (l_String <> 'OK') THEN
        ProcessId := -1;
        Status := l_String;
        RETURN;
    END IF;

    -- Hardcoding to mfg, Advanced Supply Chain Planner for prototype
    -- this init function call is embedded in MSC_WS_COMMON.VALIDATE_USER_RESP
    -- fnd_global.apps_initialize(1068, 21634, 724);

    -- Update the MSC_DESIGNATORS table to disable it to prevent further
    -- activities, such as plan launch while the purge is taking place
    BEGIN
        UPDATE msc_designators
        SET disable_date = sysdate
        WHERE designator_id = DesignatorId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00006';
            raise;
    END;

    -- Now, submit the conc. program to run
    l_Number := fnd_request.submit_request(
                              application => 'MSC',
                              program => 'MSCPRG',
                              argument1 => to_char(DesignatorId)
                              );
    IF (l_Number = 0) THEN
        ProcessId := -1;
        -- Status := 'Failed '||fnd_message.get;
        Status := 'ERROR_SUBMIT';
    ELSE
        ProcessId := l_Number;
        Status := 'SUCCESS';
    END IF;

    EXCEPTION
        WHEN others THEN
            ProcessId := -1;
            Status := g_ErrorCode;

END PURGE_PLAN;

PROCEDURE ARCHIVE_PLAN(
        ProcessId          OUT NOCOPY NUMBER,
        Status             OUT NOCOPY VARCHAR2,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        PlanId             IN         NUMBER
        ) IS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_ArchiveFlag       NUMBER;
l_Number            NUMBER;
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

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SCP',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
      MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SRO',l_SecurityGroupId);
      IF (l_String <> 'OK') THEN
        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCDP',l_SecurityGroupId);
        IF (l_String <> 'OK') THEN
          MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSCFPCMN-SRP',l_SecurityGroupId);
          IF (l_String <> 'OK') THEN
            Status := l_String;
            RETURN;
          END IF;
        END IF;
      END IF;
    END IF;

    -- check plan id
    l_String := VALIDATE_ARCHIVE_PLAN_ID(l_ArchiveFlag, PlanId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- Now, submit the conc. program to run
    /* * * * * * * * * * * * * * * * * * * * * * * *
    2008/02/25
    Although Archive Plan Summary conc prog is documented
    to take plan id as the only parameter in MA1DV210,
    it is coded to take an extra parameter in
    patch/115/sql/MSCBISUB.pls, 120.7 2008/01/26 01:18:16.

    l_Number := fnd_request.submit_request(
                          application => 'MSC',
                          program => 'MSCHUBA',
                          argument1 => to_char(PlanId)
                          );
    * * * * * * * * * * * * * * * * * * * * * * * */

    l_Number := fnd_request.submit_request(
                          application => 'MSC',
                          program => 'MSCHUBA',
                          argument1 => PlanId,
                          argument3 => l_ArchiveFlag
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

END ARCHIVE_PLAN;

END MSC_WS_PLAN_MANAGEMENT;


/

--------------------------------------------------------
--  DDL for Package Body MSC_WS_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_COMMON" AS
/* $Header: MSCWCOMB.pls 120.8 2008/03/25 19:22:50 bnaghi noship $ */

   PROCEDURE  VALIDATE_USER_RESP(
                     VRETURN            OUT NOCOPY VARCHAR2,
                     USERID             IN         NUMBER,
                     RESPID             IN         NUMBER,
                     SECURITYID         IN         NUMBER    DEFAULT 0) AS

 V_USER_ID NUMBER;
 V_RESPID NUMBER;
 V_APPID NUMBER :=0;
 BEGIN

 BEGIN
   SELECT USER_ID INTO V_USER_ID
   FROM FND_USER
   WHERE USER_ID = USERID;
   EXCEPTION WHEN no_data_found THEN
          VRETURN := 'INVALID_USERID';
          RETURN;
                WHEN others THEN
          raise;
 END;

 BEGIN
       SELECT RESPONSIBILITY_ID  INTO V_RESPID
       FROM FND_USER_RESP_GROUPS
       WHERE USER_ID = V_USER_ID AND RESPONSIBILITY_ID = RESPID AND
      (sysdate BETWEEN nvl(start_date,sysdate) AND nvl(end_date,sysdate));
       EXCEPTION WHEN no_data_found THEN
            VRETURN := 'USER_NOT_ASSIGNED_RESP';
             RETURN;
                WHEN others THEN
          raise;
  END;

 BEGIN
       SELECT APPLICATION_ID  INTO  V_APPID
       FROM FND_RESPONSIBILITY
       WHERE  RESPONSIBILITY_ID = V_RESPID;
       EXCEPTION  WHEN others THEN
          raise;
  END;


 fnd_global.apps_initialize(USERID, RESPID, V_APPID, SECURITYID);
 VRETURN :='OK';

 END VALIDATE_USER_RESP;
 PROCEDURE  VALIDATE_USER_RESP_FUNC(
                             VRETURN OUT NOCOPY VARCHAR2,
                             USERID IN  NUMBER,
                             RESPID  IN NUMBER,
                             FUNC_NAME    IN VARCHAR2,
                             SECURITYID         IN         NUMBER
                             ) IS
  l_Status        VARCHAR2(100);
  BEGIN
     MSC_WS_COMMON.VALIDATE_USER_RESP(l_Status, USERID, RESPID,SECURITYID);
     IF (l_Status<> 'OK') THEN
         VRETURN:= l_Status;
         RETURN;
     END IF;

      -- check form function
     IF (fnd_function.test( FUNC_NAME) ) THEN
          VRETURN := 'OK';
     ELSE
          VRETURN := 'RESP_NO_ACCESS_TO_WEBSERVICE';
      END IF;



END VALIDATE_USER_RESP_FUNC;

PROCEDURE GET_PERMISSION_IDS(
        Status             OUT NOCOPY VARCHAR2,
        UserId             OUT NOCOPY NUMBER,
        ResponsibilityId   OUT NOCOPY NUMBER,
        SecurityGroupId    OUT NOCOPY NUMBER,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2
) AS
l_LanguageCode    VARCHAR2(4);
l_application_id  NUMBER;
BEGIN
    -- query user id by UserName.
    BEGIN
        SELECT user_id INTO UserId
        FROM fnd_user
        WHERE user_name = upper(UserName);
        EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_USER_NAME';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_00001';
                RETURN;
    END;

    -- query language code by Language.
    BEGIN
        SELECT language_code INTO l_LanguageCode
        FROM fnd_languages
        WHERE nls_language = Language;
        EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_LANGUAGE';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_00002';
                RETURN;
    END;


    -- query application_id by application_code.
    BEGIN
        SELECT application_id INTO l_application_id
        FROM fnd_application
        WHERE application_short_name = RespAppName;
    EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_APPLICATION';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_00003';
                RETURN;
    END;


    -- query responsibility id by RespName and RespAppName.
    BEGIN
        SELECT resp_tl.responsibility_id INTO ResponsibilityId
        FROM
            fnd_responsibility_tl resp_tl
        WHERE
            resp_tl.application_id       = l_application_id          AND
            resp_tl.language             = l_LanguageCode            AND
            resp_tl.responsibility_name  = RespName;

        EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_RESP_NAME';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_00004';
                RETURN;
    END;

    -- query security group id by SecurityGroupName.
    BEGIN
        SELECT security_group_id INTO SecurityGroupId
        FROM fnd_security_groups
        WHERE security_group_key = SecurityGroupName;
        EXCEPTION
            WHEN no_data_found THEN
                Status := 'INVALID_SECUTITY_GROUP_NAME';
                RETURN;
            WHEN others THEN
                Status := 'ERROR_UNEXPECTED_00005';
                RETURN;
    END;

END GET_PERMISSION_IDS;

 -- get plan name from plan Id
 FUNCTION GET_PLAN_NAME_BY_PLAN_ID(
                 Status OUT NOCOPY  VARCHAR2,
                 PlanId IN NUMBER
                 ) RETURN BOOLEAN AS
 l_PlanName    VARCHAR2(10);
 BEGIN
     BEGIN
         SELECT COMPILE_DESIGNATOR INTO l_PlanName
         FROM MSC_PLANS
         WHERE PLAN_ID = PlanId;
         EXCEPTION WHEN NO_DATA_FOUND THEN
             Status := 'INVALID_PLANID';
             RETURN FALSE;
         WHEN others THEN
             raise;
     END;

     Status := l_PlanName;
     RETURN TRUE;
 END GET_PLAN_NAME_BY_PLAN_ID;



 FUNCTION Bool_to_Number( flag IN varchar2) RETURN number IS
     begin
     if ( flag ='Y') then return MSC_UTIL.SYS_YES;
     else return MSC_UTIL.SYS_NO;
     end if;
 end Bool_to_Number;

 FUNCTION get_cat_set_id(arg_plan_id number) RETURN NUMBER is
   l_cat_set_id number;
   l_def_pref_id number;
   l_plan_type number;
   cursor plan_type_c(v_plan_id number) is
   select curr_plan_type
   from msc_plans
   where plan_id = v_plan_id;
 BEGIN
   open plan_type_c(arg_plan_id);
   fetch plan_type_c into l_plan_type;
   close plan_type_c;

   l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
   l_cat_set_id:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);
   return l_cat_set_id;
 END get_cat_set_id;


-- =============================================================
--
-- Helper functions used by Set Plan Options.
--
-- Caller has to handle the exception.
--
-- =============================================================


-- =============================================================
-- Desc: Validate plan id, simulate the logic from Value
--       Set "MSC_SRS_NAME_COPY"
-- Input:
--       PlanId            Plan Id.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_PLANID
-- =============================================================
FUNCTION VALIDATE_PLAN_ID(
        OrgId              OUT NOCOPY NUMBER,
        InsId              OUT NOCOPY NUMBER,
        PlanName           OUT NOCOPY VARCHAR2,
        PlanId             IN         NUMBER
        ) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
BEGIN
    BEGIN
        SELECT
            plans.organization_id,
            plans.sr_instance_id,
            plans.compile_designator
        INTO
            OrgId,
            InsId,
            PlanName
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
            plans.plan_id <> -1 AND
            NVL(plans.copy_plan_id,-1) = -1 AND
            NVL(desig.copy_designator_id, -1) = -1 AND
            plans.plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLANID';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END VALIDATE_PLAN_ID;

-- =============================================================
-- Desc: Check if the plan contains this org organization.
--       for a pecified plan id
-- Input:
--       OrgId             Organization Id.
--       PlanId            Plan Id.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_ORGID
-- =============================================================
FUNCTION PLAN_CONTAINS_THIS_ORG(
        InsId              OUT NOCOPY NUMBER,
        OrgId              IN         NUMBER,
        PlanId             IN         NUMBER
        ) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        -- check if the organization is already in the plan
        -- its not allow to add organization to the plan in the set plan option
        SELECT
            sr_instance_id  INTO InsId
        FROM
            msc_plan_organizations
        WHERE
            plan_id = PlanId AND
            organization_id = OrgId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_ORGID';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END PLAN_CONTAINS_THIS_ORG;


-- =============================================================
-- Desc: Validate item simulation set id.
-- Input:
--       SetId             Simulation set Id.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_SIMULATION_SET_ID
-- =============================================================
FUNCTION VALIDATE_SIMULATION_SET_ID( SetId IN  NUMBER ) RETURN VARCHAR2 AS
l_Dummy           NUMBER;
BEGIN
    IF SetId IS NOT NULL THEN
        BEGIN
            SELECT
               1 INTO l_Dummy
            FROM
                msc_item_simulation_sets
            WHERE
                simulation_set_id = SetId;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN 'INVALID_SIMULATION_SET_ID';
            WHEN others THEN
                raise;
        END;
    END IF;

    RETURN 'OK';
END VALIDATE_SIMULATION_SET_ID;

-- =============================================================
-- Desc: purge all schedules, including global demand schediles,
--       local demand schedules and local supply schedules for this plan
--
-- Input:
--       PlanId                Id of the plan.
--
-- Output: No output.
-- =============================================================
PROCEDURE PURGE_ALL_SCHEDULES(PlanId IN NUMBER) AS
BEGIN
    BEGIN
        DELETE FROM msc_plan_schedules
        WHERE
            plan_id = PlanId;
        EXCEPTION WHEN others THEN
            raise;
    END;

END PURGE_ALL_SCHEDULES;

-- =============================================================
-- Desc: update item simulation set and overwrite
--
--       Note, this function doesn't update overwrite supplies nor nanual forecast.
--
-- Input:
--       PlanId                Id of the plan.
--       ItemSimulationSetId   Id of the item simulation set.
--       Overwrite             Overwrite.
--
-- Output: No output.
-- =============================================================
PROCEDURE UPDATE_PLAN_OPTIONS(
        PlanId              IN         NUMBER,
        ItemSimulationSetId IN         NUMBER,
        Overwrite           IN         NUMBER
) AS
BEGIN
    BEGIN
        UPDATE msc_plans
        SET
            item_simulation_set_id = ItemSimulationSetId,
            curr_overwrite_option = Overwrite
        WHERE
            plan_id = PlanId;
        EXCEPTION WHEN others THEN
            raise;
    END;

END UPDATE_PLAN_OPTIONS;


-- =============================================================
-- Desc: Convert Overwrite from string to number
--
-- Input:
--       Overwrite             Overwrite.
--
-- Output: Convert Overwrite in number.
-- =============================================================
FUNCTION CONVERT_OVERWRITE( Overwrite IN  VARCHAR2 ) RETURN NUMBER AS
l_Overwrite    NUMBER;
BEGIN
    -- Overwrite is restricted to 'ALL', 'OUTSIDE_PTF' or 'NONE' by xsd.
    CASE Overwrite
         WHEN 'ALL' THEN l_Overwrite := 1;
         WHEN 'OUTSIDE_PTF' THEN l_Overwrite := 2;
         WHEN 'NONE' THEN l_Overwrite := 3;
    END CASE;
    RETURN l_Overwrite;
END CONVERT_OVERWRITE;

-- =============================================================
-- Desc: Insert a global demand schedule
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       Schrec                global demand schedule data.
--
-- Output: The possible return statuses are:
--         OK
--         ERROR_DUP_GLOBALDMDSCH
-- =============================================================
FUNCTION INSERT_G_DMD_SCH(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscIGlbDmdSchRec
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        INSERT INTO msc_plan_schedules
            (
            plan_id, organization_id, input_schedule_id, sr_instance_id,
            input_type, last_update_date, last_updated_by,
            creation_date, created_by, designator_type, ship_to
            )
        VALUES
            (
            PlanId, -1, SchRec.DmdSchId, InsId,
            SchRec.input_type, sysdate, UserId,
            sysdate, UserId, SchRec.designator_type, SchRec.ShipToConsumptionLvl
            ) ;
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            RETURN 'ERROR_DUP_GLOBALDMDSCH';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END INSERT_G_DMD_SCH;

-- =============================================================
-- Desc: Insert a local demand schedule
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       Schrec                local demand schedule data.
--
-- Output: The possible return statuses are:
--         OK
--         ERROR_DUP_LOCALDMDSCH
-- =============================================================
FUNCTION INSERT_L_DMD_SCH(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscILocDmdSchRec
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        INSERT INTO msc_plan_schedules
            (
            plan_id, organization_id,
            input_schedule_id, sr_instance_id,
            input_type, last_update_date, last_updated_by,
            creation_date, created_by, designator_type,
            include_target_demands,
            ship_to,
            interplant_demand_flag
            )
        VALUES
            (
            PlanId, SchRec.OrgId,
            SchRec.DmdSchId, InsId,
            SchRec.input_type, sysdate, UserId,
            sysdate, UserId, SchRec.designator_type,
            SchRec.IncludeTargetDmd,
            SchRec.ShipToConsumptionLvl,
            SchRec.InterPlantFlg
            ) ;
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            RETURN 'ERROR_DUP_LOCALDMDSCH';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END INSERT_L_DMD_SCH;

-- =============================================================
-- Desc: Insert a local supply schedule
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       Schrec                local supply schedule data.
--
-- Output: The possible return statuses are:
--         OK
--         ERROR_DUP_LOCALSUPSCH
-- =============================================================
FUNCTION INSERT_L_SUP_SCH(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscILocSupSchRec
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        INSERT INTO msc_plan_schedules
            (
            plan_id, organization_id,
            input_schedule_id, sr_instance_id,
            input_type, last_update_date, last_updated_by,
            creation_date, created_by, designator_type
            )
        VALUES
            (
            PlanId, SchRec.OrgId,
            SchRec.SupSchId, InsId,
            SchRec.input_type, sysdate, UserId,
            sysdate, UserId, SchRec.designator_type
            ) ;
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            RETURN 'ERROR_DUP_LOCALSUPSCH';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END INSERT_L_SUP_SCH;

-- =============================================================
-- Desc: this function is call when the PurgeAllSchsFlag is set,
--       insert all schedules, including global demand schediles,
--       local demand schedules and local supply schedules for this plan
--
--       Note, this function doesn't update global return forecasts
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       GlbDmdSchs            global demand schedules
--       LocDmdSchs            local demand schedules
--       LocSupSchs            local supply schedules
--
-- Output: No output.
-- =============================================================
FUNCTION INSERT_ALL_SCHEDULES(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        GlbDmdSchs          IN         MscIGlbDmdSchTbl,
        LocDmdSchs          IN         MscILocDmdSchTbl,
        LocSupSchs          IN         MscILocSupSchTbl
) RETURN VARCHAR2 AS
l_String               VARCHAR2(100);
BEGIN
    -- insert all global demand schedules
    IF GlbDmdSchs.COUNT > 0 THEN
        FOR I IN GlbDmdSchs.first..GlbDmdSchs.last
            LOOP
                l_String := INSERT_G_DMD_SCH(PlanId, InsId, UserId, GlbDmdSchs(I));
                IF (l_String <> 'OK') THEN
                    RETURN l_String;
                END IF;
            END LOOP;
    END IF;

    -- insert all local demand schedules
    IF LocDmdSchs.COUNT > 0 THEN
        FOR I IN LocDmdSchs.first..LocDmdSchs.last
            LOOP
                l_String := INSERT_L_DMD_SCH(PlanId, InsId, UserId, LocDmdSchs(I));
                IF (l_String <> 'OK') THEN
                    RETURN l_String;
                END IF;
            END LOOP;
    END IF;

    -- insert all local supply schedules
    IF LocSupSchs.COUNT > 0 THEN
        FOR I IN LocSupSchs.first..LocSupSchs.last
            LOOP
                l_String := INSERT_L_SUP_SCH(PlanId, InsId, UserId, LocSupSchs(I));
                IF (l_String <> 'OK') THEN
                    RETURN l_String;
                END IF;
            END LOOP;
    END IF;

    RETURN 'OK';
END INSERT_ALL_SCHEDULES;

-- =============================================================
-- Desc: Update a global demand schedule
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       Schrec                global demand schedule data.
--
-- Output: No output.
-- =============================================================
PROCEDURE UPDATE_G_DMD_SCH(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscIGlbDmdSchRec
) AS
BEGIN
    BEGIN
        UPDATE msc_plan_schedules
        SET
            ship_to = SchRec.ShipToConsumptionLvl
        WHERE
            plan_id = PlanId AND
            organization_id = -1 AND
            sr_instance_id = InsId AND
            input_schedule_id = SchRec.DmdSchId;
        EXCEPTION WHEN others THEN
            raise;
    END;

END UPDATE_G_DMD_SCH;

-- =============================================================
-- Desc: update a local demand schedule
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       Schrec                local demand schedule data.
--
-- Output: No output.
-- =============================================================
PROCEDURE UPDATE_L_DMD_SCH(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscILocDmdSchRec
) AS
BEGIN
    BEGIN
        UPDATE msc_plan_schedules
        SET
            ship_to = SchRec.ShipToConsumptionLvl,
            include_target_demands = SchRec.IncludeTargetDmd,
            interplant_demand_flag = SchRec.InterPlantFlg
        WHERE
            plan_id = PlanId AND
            organization_id = SchRec.OrgId AND
            sr_instance_id = InsId AND
            input_schedule_id = SchRec.DmdSchId;
        EXCEPTION WHEN others THEN
            raise;
    END;

END UPDATE_L_DMD_SCH;

-- =============================================================
-- Desc: this function is call when the PurgeAllSchsFlag is not set,
--       insert or update all schedules, including global demand schediles,
--       local demand schedules and local supply schedules for this plan
--
--       Note, this function doesn't insert or update global return forecasts
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       GlbDmdSchs            global demand schedules
--       LocDmdSchs            local demand schedules
--       LocSupSchs            local supply schedules
--
-- Output: No output.
-- =============================================================
FUNCTION INSERT_OR_UPDATE_ALL_SCHS(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        GlbDmdSchs          IN         MscIGlbDmdSchTbl,
        LocDmdSchs          IN         MscILocDmdSchTbl,
        LocSupSchs          IN         MscILocSupSchTbl
) RETURN VARCHAR2 AS
l_Dummy           NUMBER;
l_String               VARCHAR2(100);
BEGIN
    -- insert/update all global demand schedules
    IF GlbDmdSchs.COUNT > 0 THEN
        FOR I IN GlbDmdSchs.first..GlbDmdSchs.last
            LOOP
                BEGIN
                    Select count(*) INTO l_Dummy
                    FROM   msc_plan_schedules
                    WHERE
                        plan_id = PlanId AND
                        organization_id = -1 AND
                        sr_instance_id = InsId AND
                        input_schedule_id  = GlbDmdSchs(I).DmdSchId;
                    EXCEPTION WHEN others THEN
                        raise;
                END;
                IF l_Dummy = 0 THEN
                    l_String := INSERT_G_DMD_SCH(PlanId, InsId, UserId, GlbDmdSchs(I));
                    IF (l_String <> 'OK') THEN
                        RETURN l_String;
                    END IF;
                ELSE
                    UPDATE_G_DMD_SCH(PlanId, InsId, UserId, GlbDmdSchs(I));
                END IF;
            END LOOP;
    END IF;

    -- insert/update all local demand schedules
    IF LocDmdSchs.COUNT > 0 THEN
        FOR I IN LocDmdSchs.first..LocDmdSchs.last
            LOOP
                BEGIN
                    Select count(*) INTO l_Dummy
                    FROM   msc_plan_schedules
                    WHERE
                        plan_id = PlanId AND
                        organization_id = LocDmdSchs(I).OrgId AND
                        sr_instance_id = InsId AND
                        input_schedule_id  = LocDmdSchs(I).DmdSchId;
                    EXCEPTION WHEN others THEN
                        raise;
                END;
                IF l_Dummy = 0 THEN
                    l_String := INSERT_L_DMD_SCH(PlanId, InsId, UserId, LocDmdSchs(I));
                    IF (l_String <> 'OK') THEN
                        RETURN l_String;
                    END IF;
                ELSE
                    UPDATE_L_DMD_SCH(PlanId, InsId, UserId, LocDmdSchs(I));
                END IF;
            END LOOP;
    END IF;

    -- insert/update all local supply schedules
    IF LocSupSchs.COUNT > 0 THEN
        FOR I IN LocSupSchs.first..LocSupSchs.last
            LOOP
                BEGIN
                    Select count(*) INTO l_Dummy
                    FROM   msc_plan_schedules
                    WHERE
                        plan_id = PlanId AND
                        organization_id = LocSupSchs(I).OrgId AND
                        sr_instance_id = InsId AND
                        input_schedule_id  = LocSupSchs(I).SupSchId;
                    EXCEPTION WHEN others THEN
                        raise;
                END;
                IF l_Dummy = 0 THEN
                    l_String := INSERT_L_SUP_SCH(PlanId, InsId, UserId, LocSupSchs(I));
                    IF (l_String <> 'OK') THEN
                        RETURN l_String;
                    END IF;
                ELSE
                    -- Nothing to update for local supply schedule
                    NULL;
                END IF;
            END LOOP;
    END IF;

    RETURN 'OK';
END INSERT_OR_UPDATE_ALL_SCHS;


-- =============================================================
-- Desc: Validate the global demand schedule id. This function is
--       used by DRP and SRP. ASCP has its own function.
-- Input:
--       SchId                 Global demand schedule id.
--       PlanName              Plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_GLOBALDMDSCHS_DMD_SCH_ID
--- =============================================================
FUNCTION VALIDATE_G_DMD_SCH_ID(
        SchId              IN         NUMBER,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
l_Dummy           NUMBER;
BEGIN
    BEGIN
        SELECT
            1 INTO l_Dummy
        FROM
            msd_dp_ascp_scenarios_v
        WHERE
            global_scenario_flag = 'Y' AND
            last_revision IS NOT NULL AND -- ASCP doesn't has this condition
            scenario_name <> PlanName AND
            scenario_id = SchId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_GLOBALDMDSCHS_DMD_SCH_ID';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END VALIDATE_G_DMD_SCH_Id;


-- =============================================================
-- Desc: Validate the ship to consumption level. This function is
--       used by DRP and SRP. ASCP have its own function in
--       MSC_WS_ASCP.
-- Input:
--       ShipTo                Ship to consumption level.
--       SchId                 Demand schedule id.
--       IsLocal               Is this ship to consumption level
--                             for a local demand schedule?
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_SHIP_TO_CONSUMPTION_LVL
-- =============================================================
FUNCTION VALIDATE_CONSUM_LVL(
        ShipTo             IN         NUMBER,
        SchId              IN         NUMBER
) RETURN VARCHAR2 AS
l_scenario_lvl_geo  NUMBER;
l_scenario_lvl_item NUMBER;
BEGIN
    BEGIN
        SELECT level_id INTO l_scenario_lvl_geo
        FROM msd_dp_scenario_output_levels
        WHERE
            scenario_id = SchId AND
            level_id IN (11,15,41,42,40);
        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_scenario_lvl_geo := 30;
        WHEN others THEN
            raise;
    END;

    BEGIN
        SELECT level_id INTO l_scenario_lvl_item
        FROM msd_dp_scenario_output_levels
        WHERE
            scenario_id = SchId AND
            level_id = 34;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_scenario_lvl_item := 40;
        WHEN others THEN
            raise;
    END;

    /*
    2    Ship
    3    Bill
    4    Customer
    5    Region
    6    Item
    7    Customer Site
    8    Zone
    9    Customer Zone
    10   Demand Class
    */

-- dbms_output.put_line('SchId: ' || SchId);
-- dbms_output.put_line('l_scenario_lvl_item: ' || l_scenario_lvl_item);
-- dbms_output.put_line('l_scenario_lvl_geo: ' || l_scenario_lvl_geo);
    IF l_scenario_lvl_item = 40 THEN
        IF l_scenario_lvl_geo = 11 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_CS_ALL'
            IF ShipTo NOT IN (4, 6, 7, 9) THEN -- Item, Customer, Customer Zone, Customer Site
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 15 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_C_ALL'
            IF ShipTo NOT IN (4, 6) THEN -- Item, Customer
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 42 then
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_Z_ALL'
            IF ShipTo NOT IN (6, 8) THEN -- Item, Zone
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 41 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_CZ_ALL'
            IF ShipTo NOT IN (4, 6, 8, 9) THEN -- Item, Customer, Customer Zone, Zone
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 30 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_ALL_ALL'
            IF ShipTo <> 6 THEN -- Item'
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSE
            -- ???? use the default record group ?????
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_CS_ALL'
            IF ShipTo NOT IN (4, 6, 7, 9) THEN -- Item, Customer, Customer Zone, Customer Site
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        END IF;
    ELSE -- IF l_scenario_lvl_item <> 40 THEN
        IF l_scenario_lvl_geo = 11 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_CS_DC'
            IF ShipTo NOT IN (4, 6, 7, 9, 10) THEN -- Item, Customer, Demand Class, Customer Zone, Customer Site
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 15 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_C_DC'
            IF ShipTo NOT IN (4, 6, 10) THEN -- Item, Customer, Demand Class
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 42 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_Z_DC'
            IF ShipTo NOT IN (6, 8, 10) THEN -- Item, Demand Class, Zone
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 41 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_CZ_DC'
            IF ShipTo NOT IN (4, 6, 8, 9, 10) THEN -- Item', Customer, Customer Zone, Zone, Demand Class
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSIF l_scenario_lvl_geo = 30 THEN
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_ALL_DC'
            IF ShipTo NOT IN (6, 10) THEN -- Item, Demand Class
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        ELSE
            -- ???? which record group should I use ?????
            -- simulate the logic from Record Groups 'MSC_SHIP_TO_CS_DC'
            IF ShipTo NOT IN (4, 6, 7, 9, 10) THEN -- Item, Customer, Demand Class, Customer Zone, Customer Site
                RETURN 'INVALID_SHIP_TO_CONSUMPTION_LVL';
            END IF;
        END IF;
    END IF;

    RETURN 'OK';
END VALIDATE_CONSUM_LVL;


-- =============================================================
-- Desc: Validate loal supply schedule id
-- Input:
--       SchId             local supply schedule id.
--       OrgId             organization id.
--       InsId             sr instance id.
--       PlanName          plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_LOCALSUPSCHS_SUP_SCH_ID
-- =============================================================
FUNCTION VALIDATE_L_SUP_SCH_ID(
        DesigType          OUT NOCOPY NUMBER,
        SchId              IN         NUMBER,
        OrgId              IN         NUMBER,
        InsId              IN         NUMBER,
        PlanName           IN         VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT
            designator_type INTO DesigType
        FROM
            msc_designators
        WHERE
            trunc(nvl(disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            designator <> PlanName AND
            organization_id = OrgId AND
            sr_instance_id = InsId AND
            designator_id = SchId AND
            designator_type not in (1,6)
        UNION
        SELECT
            desig.designator_type
        FROM
            msc_designators desig,
            msc_plan_organizations_v mpo
        WHERE
            desig.designator_type not in (1,6) AND
            trunc(nvl(desig.disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            mpo.organization_id  = desig.organization_id AND
            mpo.sr_instance_id  = desig.sr_instance_id AND
            mpo.compile_designator = desig.designator AND
            mpo.planned_organization = OrgId AND
            mpo.sr_instance_id = InsId AND
            desig.designator <> PlanName AND
            desig.designator_id = SchId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_LOCALSUPSCHS_SUP_SCH_ID';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END VALIDATE_L_SUP_SCH_ID;

-- =============================================================
-- Desc: validate local supply schedules
-- Input:
--       SchTable              Local supply schedules.
--       PlanName              Plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_LOCALSUPSCHS_ORGID
--         INVALID_LOCALSUPSCHS_SUP_SCH_ID
-- =============================================================
FUNCTION VALIDATE_LOC_SUP_SCHS(
        OutSchTable        OUT NOCOPY MscILocSupSchTbl,
        InSchTable         IN         MscLocSupSchTbl,
        PlanId             IN         NUMBER,
        PlanName           IN         VARCHAR2
) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
l_OrgInsId        NUMBER;
l_DesigType       NUMBER;
BEGIN
    OutSchTable := MscILocSupSchTbl(); -- need to re-init it here
    IF InSchTable IS NOT NULL  AND InSchTable.count > 0 THEN
        FOR I IN InSchTable.first..InSchTable.last
            LOOP
                -- validate organization id
                BEGIN
                    l_ReturnString := MSC_WS_COMMON.PLAN_CONTAINS_THIS_ORG(l_OrgInsId, InSchTable(I).OrgId, PlanId);
                    IF (l_ReturnString <> 'OK') THEN
                        -- overwrite the error token here.
                        l_ReturnString := 'INVALID_LOCALSUPSCHS_ORGID';
                        RETURN l_ReturnString;
                    END IF;
                    EXCEPTION WHEN others THEN
                        raise;
                END;

                -- validate supply schedule id
                l_ReturnString := VALIDATE_L_SUP_SCH_ID(
                                         l_DesigType,
                                         InSchTable(I).SupSchId,
                                         InSchTable(I).OrgId,
                                         l_OrgInsId,
                                         PlanName);
                IF (l_ReturnString <> 'OK') THEN
                    RETURN l_ReturnString;
                END IF;

                OutSchTable.extend;
                OutSchTable(OutSchTable.count) :=
                    MscILocSupSchRec(InSchTable(I).OrgId,
                                  InSchTable(I).SupSchId,
                                  2,           -- input_type
                                  l_DesigType  -- designator_type
                                  );

            END LOOP;
    END IF;

    RETURN 'OK';
END VALIDATE_LOC_SUP_SCHS;

END MSC_WS_COMMON;


/

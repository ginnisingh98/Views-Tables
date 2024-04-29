--------------------------------------------------------
--  DDL for Package Body MSC_WS_IO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_IO" AS
/* $Header: MSCWIOPB.pls 120.5 2008/03/20 15:57:58 bnaghi noship $  */

g_IGlbDmdSchTbl  MscIGlbIODmdSchTbl; -- store all global demand schediles data
g_ILocDmdSchTbl  MscILocIODmdSchTbl; -- store all local demand schediles data
g_ErrorCode      VARCHAR2(9);

-- =============================================================
-- Desc: Please see package spec file for description
-- =============================================================
PROCEDURE  LAUNCH_IO_BATCH (
                   processId                OUT NOCOPY NUMBER,
                   status                   OUT NOCOPY VARCHAR2,
                   userId                   IN  NUMBER,
                   responsibilityId         IN  NUMBER,
                   planId                   IN  NUMBER,
                   anchorDate               IN  DATE,
                   archiveCurrVersPlan IN VARCHAR2) AS

  l_error_tracking_num          NUMBER;
  l_result                      VARCHAR2(30);
  l_plan_name                   VARCHAR2(10);
  l_org_id                      NUMBER;
  l_sr_instance_id              NUMBER;
  l_inventory_atp_flag          NUMBER;
  l_production                  NUMBER;
  l_release_resched             NUMBER;
  l_24x7_purge                  NUMBER;
  l_val_archivePlan         NUMBER;

BEGIN

  l_error_tracking_num := 3010;

  -- ------------------------------------
  -- validate and initialize apps
  -- ------------------------------------
  MSC_WS_COMMON.VALIDATE_USER_RESP(l_result, userId, responsibilityId);

  IF (l_result <> 'OK') THEN
      processId := -1;
      status := l_result;
      RETURN;
  END IF;

  l_error_tracking_num := 3020;

  -- ------------------------------------
  -- validate planId
  -- ------------------------------------

  BEGIN
     SELECT plans.compile_designator, plans.organization_id, plans.sr_instance_id,
            desig.inventory_atp_flag, desig.production
     INTO   l_plan_name, l_org_id, l_sr_instance_id, l_inventory_atp_flag, l_production
     FROM   msc_plans plans, msc_designators desig
     WHERE  plans.curr_plan_type = 4
     AND    plans.organization_id = desig.organization_id
     AND    plans.sr_instance_id = desig.sr_instance_id
     AND    plans.compile_designator = desig.designator
     AND    NVL(desig.disable_date, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE)
     AND    plans.organization_selection <> 1
     AND    plans.plan_id = planId;

  EXCEPTION
     WHEN no_data_found THEN
        processId := -1;
        status := 'INVALID_PLANID';
        RETURN;
  END;

  l_error_tracking_num := 3030;

  -- ------------------------------------
  -- validate anchorDate
  -- ------------------------------------
  BEGIN
    SELECT  'Y'
    INTO    l_result
    FROM    msc_calendar_dates dates,
            msc_trading_partners mtp
    WHERE   dates.calendar_code = mtp.calendar_code
    AND     dates.exception_set_id = mtp.calendar_exception_set_id
    AND     mtp.sr_instance_id = dates.sr_instance_id
    AND     mtp.sr_tp_id = l_org_id
    AND     mtp.sr_instance_id = l_sr_instance_id
    AND     dates.calendar_date <= TRUNC(SYSDATE)
    AND     dates.calendar_date = anchorDate;
  EXCEPTION
     WHEN no_data_found THEN
        processId := -1;
        status := 'INVALID_ANCHORDATE';
        RETURN;
  END;


l_error_tracking_num:= 3035;

     BEGIN
       SELECT  decode(archiveCurrVersPlan, 'Y', msc_ws_common.sys_yes, msc_ws_common.sys_no)
       INTO   l_val_archivePlan
       FROM   dual;

     END;

  l_error_tracking_num := 3040;

  -- ------------------------------------
  -- setting hidden parameters
  -- ------------------------------------

  -- PLAN_TYPE_DUMMY hidden parameter
  -- Original default logic is "SELECT inventory_atp_flag from msc_designators d
  -- where d.designator = :$FLEX$.MSC_SRS_SRO_NAME_LAUNCH_1 and d.inventory_atp_flag = 1"
  -- Which pretty much meant this flag is set to either NULL or 1
  IF (l_inventory_atp_flag  <> 1) THEN l_inventory_atp_flag := NULL;
  END IF;


  -- MSC_24X7 hidden parameter
  -- Original default logic is "Select meaning From Mfg_Lookups Where Lookup_Type = 'MSC_24X7_PURGE'
  --                             AND (DECODE(NVL(:$FLEX$.FND_CHAR240,2),2,2,1)=2 OR LOOKUP_CODE=2
  -- Where FND_CHAR240 was referring to l_inventory_atp_flag variable.  This is tricky since
  -- if l_inventory_atp_flag is NULL, the above query will return 2 values, which invalidates the
  -- default logic (since default logic can only return 1 value) resulting in default value being NULL
  -- Most likely, this is some kinda of faulty logic in conc program definition
  IF (l_inventory_atp_flag is NULL)
  THEN l_24x7_purge := NULL;
  ELSE l_24x7_purge := 2;
  END IF;

  -- RESCHEDULE_DUMMY parameter
  -- Similar default logic as l_inventory_atp, "SELECT production from msc_designators d
  -- where d.designator = :$FLEX$.MSC_SRS_SRO_NAME_LAUNCH_1 and d.production = 1"
  IF (l_production  <> 1)
  THEN l_production := NULL;
  END IF;

  -- Similar logic as l_24x7_purge
  IF (l_production is NULL)
  THEN l_release_resched := NULL;
  ELSE l_release_resched := 2;
  END IF;


  l_error_tracking_num := 3050;

  -- ------------------------------------
  -- Launch conc program
  -- ------------------------------------
  processId := FND_REQUEST.SUBMIT_REQUEST(
     'MSC',                                    -- application
     'MSCSLPPR4',                              -- program
     NULL,                                     -- description
     NULL,                                     -- start_time
     FALSE,                                    -- sub_request
     l_plan_name,                              -- plan name, argument 1
     planId,                                   -- plan name hidden, argument 2
     to_char(msc_ws_common.sys_yes),           -- launch snapshot, argument 3, set to Yes always
     to_char(msc_ws_common.sys_yes),           -- launch planner, argument 4, set to Yes always
     to_char(msc_ws_common.sys_no),            -- netchange, argument 5, set to No always
     fnd_date.date_to_chardate(anchorDate),    -- anchor date, argument 6
     l_val_archivePlan,
     l_inventory_atp_flag,                          -- plan type dummy, argument 7
     l_24x7_purge,                             -- msc 24x7, argument 8
     l_production,                             -- reschedule dummy, argument 9
     l_release_resched);                       -- release rescheduled, argument 10

  IF (processId = 0) THEN
    processId := -1;
    status := 'ERROR_SUBMIT';
    return;
  END IF;

  status := 'SUCCESS';

EXCEPTION
  WHEN others THEN
    status := 'ERROR_UNEXPECTED_'||l_error_tracking_num;
    processId := -1;
    return;

END LAUNCH_IO_BATCH;


PROCEDURE  LAUNCH_IO_BATCH_PUBLIC (
                   processId              OUT NOCOPY NUMBER,
		   status                 OUT NOCOPY VARCHAR2,
		   UserName               IN VARCHAR2,
		   RespName     IN VARCHAR2,
		   RespApplName IN VARCHAR2,
		   SecurityGroupName      IN VARCHAR2,
		   Language            IN VARCHAR2,
                   planId                   IN  NUMBER,
                   anchorDate               IN  DATE,
                   archiveCurrVersPlan IN VARCHAR2)AS
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

     MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFNSCW-SRO',l_SecutirtGroupId);
   IF (l_String <> 'OK') THEN
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFPCMN-SRO', l_SecutirtGroupId);
       IF (l_String <> 'OK') THEN
       MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_ORG_FNDRSRUN_LAUNCH_SRO',l_SecutirtGroupId);
       IF (l_String <> 'OK') THEN
       Status := l_String;
       RETURN;
    END IF;
    END IF;
    END IF;
    error_tracking_num :=2040;

   LAUNCH_IO_BATCH ( processId, status, userId ,respid, planId , anchorDate, archiveCurrVersPlan );
   --      dbms_output.put_line('USERID=' || userid);


      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;
END  LAUNCH_IO_BATCH_PUBLIC;


-- =============================================================
--
-- SET_IO_PLAN_OPTIONS and its private helper functions.
--
-- Un-handled exceptions generate error tokens in the
-- format of ERROR_UNEXPECTED_#####.
-- The possible values are:
--   00301 - SET_IO_PLAN_OPTIONS/VALIDATE_PLAN_ID
--   00302 - SET_IO_PLAN_OPTIONS/VALIDATE_PLAN_TYPE
--   00303 - SET_IO_PLAN_OPTIONS/MSC_WS_COMMON.VALIDATE_SIMULATION_SET_ID
--   00304 - SET_IO_PLAN_OPTIONS/VALIDATE_SER_LVL_SET_ID
--   00305 - SET_IO_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/VALIDATE_G_DMD_SCH_ID
--   00306 - SET_IO_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/VALIDATE_CONSUM_LVL (goe)
--         - SET_IO_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/VALIDATE_CONSUM_LVL (goe)
--   00307 - SET_IO_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/VALIDATE_CONSUM_LVL (item)
--         - SET_IO_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/VALIDATE_CONSUM_LVL (item)
--   -- 00308 - SET_IO_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/VALIDATE_G_VARIABILITY/VALIDATE_G_VARIABILITY_ID
--   00309 - SET_IO_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/MSC_WS_COMMON.PLAN_CONTAINS_THIS_ORG
--   00310 - SET_IO_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/VALIDATE_L_DMD_SCH_ID
--   00311 - SET_IO_PLAN_OPTIONS/MSC_WS_COMMON.PURGE_ALL_SCHEDULES
--   00312 - SET_IO_PLAN_OPTIONS/UPDATE_PLAN_OPTIONS
--   00313 - SET_IO_PLAN_OPTIONS/INSERT_ALL_SCHEDULES/INSERT_GLB_DMD_SCHEDULE
--           SET_IO_PLAN_OPTIONS/INSERT_OR_UPDATE_ALL_SCHS/INSERT_GLB_DMD_SCHEDULE
--   00314 - SET_IO_PLAN_OPTIONS/INSERT_ALL_SCHEDULES/INSERT_LOC_DMD_SCHEDULE
--         - SET_IO_PLAN_OPTIONS/INSERT_OR_UPDATE_ALL_SCHS/INSERT_LOC_DMD_SCHEDULE
--   00315 - SET_IO_PLAN_OPTIONS/INSERT_OR_UPDATE_ALL_SCHS
--   00316 - SET_IO_PLAN_OPTIONS/INSERT_OR_UPDATE_ALL_SCHS/UPDATE_GLB_DMD_SCHEDULE
--   00317 - SET_IO_PLAN_OPTIONS/INSERT_OR_UPDATE_ALL_SCHS
--   00318 - SET_IO_PLAN_OPTIONS/INSERT_OR_UPDATE_ALL_SCHS/UPDATE_LOC_DMD_SCHEDULE
-- =============================================================

-- =============================================================
-- Desc: Validate plan id, copy the where clause from LAUNCH_IO_BATCH
--
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
            -- NVL(plans.copy_plan_id,-1) = -1 AND
            -- NVL(desig.copy_designator_id, -1) = -1 AND
            plans.plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLANID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00301';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_PLAN_ID;

-- =============================================================
-- Desc: Validate plan type is IO
-- Input:
--       PlanId            plan id.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_PLAN_TYPE
-- =============================================================
FUNCTION VALIDATE_PLAN_TYPE( PlanId IN  NUMBER ) RETURN VARCHAR2 AS
l_Dummy           NUMBER;
BEGIN
    BEGIN
        SELECT
            1 INTO l_Dummy
        FROM
            msc_plans
        WHERE
            curr_plan_type = 4 AND
            plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLAN_TYPE';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00302';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_PLAN_TYPE;

-- =============================================================
-- Desc: Validate Service Level set id.
-- Input:
--       SetId             Service level set Id.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_SERVICE_LVL_SET_ID
-- =============================================================
FUNCTION VALIDATE_SER_LVL_SET_ID( SetId IN  NUMBER ) RETURN VARCHAR2 AS
l_Dummy           NUMBER;
BEGIN
    IF SetId IS NOT NULL THEN
        BEGIN
            SELECT
               1 INTO l_Dummy
            FROM
                msc_service_level_sets
            WHERE
                service_level_set_id = SetId;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN 'INVALID_SERVICE_LVL_SET_ID';
            WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_00304';
                raise;
        END;
    END IF;

    RETURN 'OK';
END VALIDATE_SER_LVL_SET_ID;

-- =============================================================
-- Desc: Validate global demand schedule id
-- Input:
--       SchId             global demand schedule id.
--       PlanName          plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_GLOBALDMDSCHS_DMD_SCH_ID
-- =============================================================
FUNCTION VALIDATE_G_DMD_SCH_ID(
        ErrorType          OUT NOCOPY VARCHAR2,
        SchId              IN         NUMBER,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT
            error_type INTO ErrorType
        FROM
            msd_dp_ascp_scenarios_v
        WHERE
            global_scenario_flag = 'Y' AND
            scenario_name <> PlanName AND
            scenario_id = SchId AND
            last_revision IS NOT NULL;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_GLOBALDMDSCHS_DMD_SCH_ID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00305';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_G_DMD_SCH_ID;

-- =============================================================
-- Desc: Validate the ship to consumption level. This function is
--       used by IO only. DRP and SRP have their own function in
--       MSC_WS_COMMON. ASCP has its own in MSC_WS_ASCP.
-- Input:
--       ShipTo                Ship to consumption level.
--       SchId                 Demand schedule id.
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
        FROM   msd_dp_scenario_output_levels
        WHERE  scenario_id = SchId AND level_id in (11,15,41,42,30);
        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_scenario_lvl_geo := 30;
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00306';
            raise;
    END;

    BEGIN
        SELECT level_id INTO l_scenario_lvl_item
        FROM   msd_dp_scenario_output_levels
        WHERE  scenario_id = SchId AND level_id in (34,40);
        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_scenario_lvl_item := 40;
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00307';
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
-- Desc: Validate demand variability type
--
-- Input:
--       VarId                 demand variability type id.
--       DesigType
--
-- Output: The possible return statuses are:
--         OK
--         INVALID
-- =============================================================
FUNCTION VALIDATE_VARIABILITY_ID(
        VarId              IN         NUMBER,
        DesigType          IN         NUMBER
        ) RETURN VARCHAR2 AS
BEGIN
    IF VarId = 1 AND DesigType <> 7 THEN
        RETURN 'INVALID'; -- caller has to overwrite this
    ELSIF VarId < 1 OR VarId > 3 THEN
        RETURN 'INVALID'; -- caller has to overwrite this
    END IF;
    RETURN 'OK';
END VALIDATE_VARIABILITY_ID;


-- =============================================================
-- Desc: Validate demand variability type and its dependance
-- Input:
--       SchRec            global demand schedule data.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_GLOBALDMDSCHS_VARIABILITY_TYPE
--         INVALID_GLOBALDMDSCHS_PROBABILITY
--         INVALID_GLOBALDMDSCHS_MEAN_ABS_PCT_ERROR
-- =============================================================
FUNCTION VALIDATE_G_VARIABILITY(SchRec IN MscGlbIODmdSchRec) RETURN VARCHAR2 AS
l_String          VARCHAR2(100);
BEGIN
    l_String := VALIDATE_VARIABILITY_ID(SchRec.DmdVariabilityType, 7);
    IF l_String <> 'OK' THEN
        RETURN 'INVALID_GLOBALDMDSCHS_VARIABILITY_TYPE';
    END IF;
    BEGIN
        CASE SchRec.DmdVariabilityType
            WHEN 1 THEN -- Accuracy_Metric_MAD
                BEGIN
                    -- probability can be null or in the range of 0 to 1
                    IF SchRec.Probability IS NOT NULL THEN
                        IF SchRec.Probability < 0 OR SchRec.Probability > 1 THEN
                            RETURN 'INVALID_GLOBALDMDSCHS_PROBABILITY';
                        END IF;
                    END IF;
                    -- mean absolute % error can be null or in the range of 0 to 100
                    IF SchRec.MeanAbsPctError IS NOT NULL THEN
                        IF SchRec.MeanAbsPctError < 0 OR SchRec.MeanAbsPctError > 100 THEN
                            RETURN 'INVALID_GLOBALDMDSCHS_MEAN_ABS_PCT_ERROR';
                        END IF;
                    END IF;
                END;
            WHEN 2 THEN -- 'Probability'
                    -- probability is required and in the range of 0 to 1
                    IF SchRec.Probability IS NULL THEN
                        RETURN 'INVALID_GLOBALDMDSCHS_PROBABILITY';
                    ELSE
                        IF SchRec.Probability < 0 OR SchRec.Probability > 1 THEN
                            RETURN 'INVALID_GLOBALDMDSCHS_PROBABILITY';
                        END IF;
                    END IF;
                    -- mean absolute % error has to be null
                    IF SchRec.MeanAbsPctError IS NOT NULL THEN
                        RETURN 'INVALID_GLOBALDMDSCHS_MEAN_ABS_PCT_ERROR';
                    END IF;
            WHEN 3 THEN -- 'Mean_Absolute_Pct_Err'
                    -- probability has to be null
                    IF SchRec.Probability IS NOT NULL THEN
                        RETURN 'INVALID_GLOBALDMDSCHS_PROBABILITY';
                    END IF;
                    -- mean absolute % error is required and in the range of 0 to 100
                    IF SchRec.MeanAbsPctError IS NOT NULL THEN
                        IF SchRec.MeanAbsPctError < 0 OR SchRec.MeanAbsPctError > 100 THEN
                            RETURN 'INVALID_GLOBALDMDSCHS_MEAN_ABS_PCT_ERROR';
                        END IF;
                    END IF;
        END CASE;
    END;

    RETURN 'OK';
END VALIDATE_G_VARIABILITY;

-- =============================================================
-- Desc: load global demand schedules
-- Input:
--       PurgeAll              Purge All Schs Flag
--       PlanId
--
-- Output: No output.
-- =============================================================
PROCEDURE LOAD_GLB_DMD_SCH_TBL(
        SchTbl             OUT NOCOPY MscIDmdSchVarTbl,
        PurgeAll           IN         VARCHAR2,
        PlanId             IN         NUMBER
        ) AS
cursor schedule_c(idPlan number) is
SELECT
    sr_instance_id,
    input_schedule_id,
    demand_variability_type,
    probability
FROM
    msc_plan_schedules
WHERE
    plan_id = idPlan AND
    organization_id = -1;

l_InsId           NUMBER;
l_SchedId         NUMBER;
l_VarType         NUMBER;
l_Probability     NUMBER;
BEGIN
    SchTbl := MscIDmdSchVarTbl();
    SchTbl.DELETE;
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAll) = MSC_UTIL.SYS_NO THEN
        BEGIN
            OPEN schedule_c(PlanId);
            LOOP
                FETCH schedule_c into l_InsId, l_SchedId, l_VarType, l_Probability;
                EXIT WHEN schedule_c%NOTFOUND;
                SchTbl.extend;
                SchTbl(SchTbl.count) :=
                    MscIDmdSchVarRec(
                              l_InsId,
                              -1,
                              l_SchedId,
                              l_VarType,
                              l_Probability
                              );
            END LOOP;
            CLOSE schedule_c;
        END;
    END IF;

END LOAD_GLB_DMD_SCH_TBL;

-- =============================================================
-- Desc: All global demand schedules have the same variability type
--       If the the variability type is probability, the sun must equal to 1
-- Input:
--       InsId              Instance id
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_VAR_TYPE_IN_GBL_SCH
--         INVALID_GLB_SUM_OF_PROB
-- =============================================================
FUNCTION VALIDATE_G_PROB(
        PurgeAll           IN         VARCHAR2,
        InsId              IN         NUMBER,
        PlanId             IN         NUMBER
        ) RETURN VARCHAR2 AS
l_String         VARCHAR2(100);
l_SchTbl         MscIDmdSchVarTbl;  -- global shedules in database
l_VarType        NUMBER;
l_Sum            NUMBER;
BEGIN
    IF g_IGlbDmdSchTbl.COUNT > 0 THEN
        -- get all global schedules from database and store them in l_SchTbl
        LOAD_GLB_DMD_SCH_TBL(l_SchTbl, PurgeAll, PlanId);
        l_VarType := -1;
        l_Sum := 0;
        FOR I in g_IGlbDmdSchTbl.first..g_IGlbDmdSchTbl.last
            LOOP
                IF l_VarType = -1 THEN
                    l_VarType := g_IGlbDmdSchTbl(I).DmdVariabilityType;
                ELSIF l_VarType <> g_IGlbDmdSchTbl(I).DmdVariabilityType THEN
                    RETURN 'INVALID_VAR_TYPE_IN_GBL_SCH';
                END IF;
                IF l_VarType = 2 THEN
                    l_Sum := l_Sum + g_IGlbDmdSchTbl(I).Probability;
                END IF;
                -- delete this demand schedule from l_SchTbl.
                IF l_SchTbl.COUNT > 0 THEN
                    FOR J IN l_SchTbl.first..l_SchTbl.last
                        LOOP
                            BEGIN
                                IF l_SchTbl(J).InsId = InsId AND
                                    l_SchTbl(J).SchId = g_IGlbDmdSchTbl(I).DmdSchId THEN
                                    l_SchTbl.delete(J);
                                    EXIT;
                                END IF;
                                EXCEPTION WHEN NO_DATA_FOUND THEN
                                    NULL; -- skip, this element is deleted.
                            END;
                        END LOOP;
                END IF;
            END LOOP;
        IF l_SchTbl.COUNT > 0 THEN
            FOR I IN l_SchTbl.first..l_SchTbl.last
                LOOP
                    BEGIN
                        IF l_SchTbl(I).DmdVariabilityType <> l_VarType THEN
                            RETURN 'INVALID_VAR_TYPE_IN_GBL_SCH';
                        ELSIF l_VarType = 2 THEN
                            l_Sum := l_Sum + l_SchTbl(I).Probability;
                        END IF;
                        EXCEPTION WHEN NO_DATA_FOUND THEN
                            NULL; -- skip, this element is deleted.
                    END;
                END LOOP;
        END IF;
        -- test the sum
        IF l_VarType = 2 AND l_Sum <> 1 THEN
            RETURN 'INVALID_GBL_SUM_OF_PROB';
        END IF;
    END IF;
    RETURN 'OK';
END VALIDATE_G_PROB;

-- =============================================================
-- Desc: validate global demand schedules
-- Input:
--       SchTable              Global demand schedules.
--       PlanName              Plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_GLOBALDMDSCHS_DMD_SCH_ID
--         INVALID_GLOBALDMDSCHS_SHP_TO_CONSUMPTION_LVL
-- =============================================================
FUNCTION VALIDATE_GLB_DMD_SCHS(
        SchTable           IN         MscGlbIODmdSchTbl,
        PlanId             IN         NUMBER,
        PlanName           IN         VARCHAR2,
        InsId              IN         NUMBER,
        PurgeAll           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
l_String          VARCHAR2(100);
l_ErrorType       VARCHAR2(30);
BEGIN
    IF SchTable IS NOT NULL AND SchTable.COUNT > 0 THEN
        FOR I IN SchTable.first..SchTable.last
            LOOP
                -- validate demand schedule id
                l_String := VALIDATE_G_DMD_SCH_ID(l_ErrorType, SchTable(I).DmdSchId, PlanName);
                IF (l_String <> 'OK') THEN
                    RETURN l_String;
                END IF;

                -- validate ship to consumption level
                l_String := VALIDATE_CONSUM_LVL(
                                  SchTable(I).ShipToConsumptionLvl,
                                  SchTable(I).DmdSchId
                                  );
                IF (l_String <> 'OK') THEN
                    RETURN 'INVALID_GLOBALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                END IF;

                -- validate Type of Demand Variability and its dependence
                l_String := VALIDATE_G_VARIABILITY(SchTable(I));
                IF (l_String <> 'OK') THEN
                    RETURN l_String;
                END IF;

                g_IGlbDmdSchTbl.extend;
                g_IGlbDmdSchTbl(g_IGlbDmdSchTbl.count) :=
                     MscIGlbIODmdSchRec(SchTable(I).DmdSchId,
                                   SchTable(I).ShipToConsumptionLvl,
                                   SchTable(I).DmdVariabilityType,
                                   SchTable(I).Probability,
                                   SchTable(I).MeanAbsPctError,
                                   1, -- input_type
                                   7  -- designator_type
                                   );

            END LOOP;
        l_String := VALIDATE_G_PROB(PurgeAll, InsId, PlanId);
        IF (l_String <> 'OK') THEN
            RETURN l_String;
        END IF;
    END IF;

    RETURN 'OK';
END VALIDATE_GLB_DMD_SCHS;

-- =============================================================
-- Desc: load local demand schedules for this scenario set
-- Input:
--       PurgeAll              Purge All Schs Flag
--       ScenarioSetId
--       PlanId
--
-- Output: No output.
-- =============================================================
PROCEDURE LOAD_LOC_DMD_SCH_TBL(
        SchTbl             OUT NOCOPY MscIDmdSchVarTbl,
        PurgeAll           IN         VARCHAR2,
        ScenarioSetId      IN         NUMBER,
        PlanId             IN         NUMBER
        ) AS
cursor schedule_c(idPlan number, idScenarioSet number) is
SELECT
    sr_instance_id,
    organization_id,
    input_schedule_id,
    demand_variability_type,
    probability
FROM
    msc_plan_schedules
WHERE
    plan_id = idPlan AND
    organization_id <> -1 AND
    scenario_set = idScenarioSet;

l_InsId           NUMBER;
l_OrgId           NUMBER;
l_SchedId         NUMBER;
l_VarType         NUMBER;
l_Probability     NUMBER;
BEGIN
    SchTbl := MscIDmdSchVarTbl();
    SchTbl.DELETE;
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAll) = MSC_UTIL.SYS_NO THEN
        BEGIN
            OPEN schedule_c(PlanId, ScenarioSetId);
            LOOP
                FETCH schedule_c into l_InsId, l_OrgId, l_SchedId, l_VarType, l_Probability;
                EXIT WHEN schedule_c%NOTFOUND;
                SchTbl.extend;
                SchTbl(SchTbl.count) :=
                    MscIDmdSchVarRec(
                              l_InsId,
                              l_OrgId,
                              l_SchedId,
                              l_VarType,
                              l_Probability
                              );
            END LOOP;
            CLOSE schedule_c;
        END;
    END IF;

END LOAD_LOC_DMD_SCH_TBL;

-- =============================================================
-- Desc: All demand schedules in a scenario set have the same variability type
--       If the the variability type is probability, the sun must equal to 1 in any scenario set
-- Input:
--       InsId              Instance id
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_VAR_TYPE_IN_SCENARIO_SET
--         INVALID_LOC_SUM_OF_PROB
-- =============================================================
FUNCTION VALIDATE_L_PROB(
        PurgeAll           IN         VARCHAR2,
        InsId              IN         NUMBER,
        PlanId             IN         NUMBER
        ) RETURN VARCHAR2 AS
l_String         VARCHAR2(100);
l_ScenarioTbl    MscNumberArr;         -- scenario sets in local demand schedules parameter
l_SchTbl         MscIDmdSchVarTbl;  -- local shedules for a single scenario set
l_Insert         NUMBER;
l_VarType        NUMBER;
l_Sum            NUMBER;
BEGIN
    IF g_ILocDmdSchTbl.COUNT > 0 THEN
        l_ScenarioTbl := MscNumberArr();

        -- insert all scenario set from parameter into l_ScenarioTbl
        FOR I IN g_ILocDmdSchTbl.first..g_ILocDmdSchTbl.last
            LOOP
                l_Insert := MSC_UTIL.SYS_YES;
                IF l_ScenarioTbl.COUNT > 0 THEN
                     FOR J IN l_ScenarioTbl.first..l_ScenarioTbl.last
                         LOOP
                             IF l_ScenarioTbl(J) = g_ILocDmdSchTbl(I).ScenarioSet THEN
                                 l_Insert := MSC_UTIL.SYS_NO;
                                 EXIT;
                             END IF;
                         END LOOP;
                END IF;
                IF l_Insert = MSC_UTIL.SYS_YES THEN
                    l_ScenarioTbl.extend;
                    l_ScenarioTbl(l_ScenarioTbl.COUNT) := g_ILocDmdSchTbl(I).ScenarioSet;
                END IF;
            END LOOP;

        -- l_ScenarioTbl must not empty!!!
        FOR I IN l_ScenarioTbl.first..l_ScenarioTbl.last
            LOOP
                -- get all schedules for this scenario set from database and store them in l_SchTbl
                LOAD_LOC_DMD_SCH_TBL(l_SchTbl, PurgeAll, l_ScenarioTbl(I), PlanId);

                l_VarType := -1;
                l_Sum := 0;
                FOR J in g_ILocDmdSchTbl.first..g_ILocDmdSchTbl.last
                    LOOP
                        IF g_ILocDmdSchTbl(J).ScenarioSet = l_ScenarioTbl(I) THEN
                            IF l_VarType = -1 THEN
                                l_VarType := g_ILocDmdSchTbl(J).DmdVariabilityType;
                            ELSIF l_VarType <> g_ILocDmdSchTbl(J).DmdVariabilityType THEN
                                RETURN 'INVALID_VAR_TYPE_IN_SCENARIO_SET';
                            END IF;
                            IF l_VarType = 2 THEN
                                l_Sum := l_Sum + g_ILocDmdSchTbl(J).Probability;
                            END IF;
                        END IF;
                        -- delete this demand schedule from l_SchTbl.
                        IF l_SchTbl.COUNT > 0 THEN
                            FOR K IN l_SchTbl.first..l_SchTbl.last
                                LOOP
                                    BEGIN
                                        IF l_SchTbl(K).InsId = InsId AND
                                           l_SchTbl(K).OrgId = g_ILocDmdSchTbl(J).OrgId AND
                                           l_SchTbl(K).SchId = g_ILocDmdSchTbl(J).DmdSchId THEN
                                            l_SchTbl.delete(K);
                                            EXIT;
                                        END IF;
                                        EXCEPTION WHEN NO_DATA_FOUND THEN
                                            NULL; -- skip, this element is deleted.
                                    END;
                                END LOOP;
                            END IF;
                    END LOOP;
                IF l_SchTbl.COUNT > 0 THEN
                    FOR L IN l_SchTbl.first..l_SchTbl.last
                    LOOP
                        IF l_SchTbl(L).DmdVariabilityType <> l_VarType THEN
                            RETURN 'INVALID_VAR_TYPE_IN_SCENARIO_SET';
                        ELSIF l_VarType = 2 THEN
                            l_Sum := l_Sum + l_SchTbl(L).Probability;
                        END IF;
                    END LOOP;
                END IF;
                -- test the sum
                IF l_VarType = 2 AND l_Sum <> 1 THEN
                    RETURN 'INVALID_LOC_SUM_OF_PROB';
                END IF;
            END LOOP;
    END IF;
    RETURN 'OK';
END VALIDATE_L_PROB;

-- =============================================================
-- Desc: Validate loal demand schedule id
-- Input:
--       SchId             local demand schedule id.
--       OrgId             organization id.
--       InsId             sr instance id.
--       PlanName          plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_LOCALDMDSCHS_DMD_SCH_ID
-- =============================================================
FUNCTION VALIDATE_L_DMD_SCH_ID(
        DesigType          OUT NOCOPY NUMBER,
        SchId              IN         NUMBER,
        OrgId              IN         NUMBER,
        InsId              IN         NUMBER,
        PlanName           IN         VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT designator_type
        INTO   DesigType
        FROM   msc_designators
        WHERE
            ((designator_type = 6 AND forecast_set_id IS NULL) OR
             (designator_type in  (1,2,3,4,5,8)) ) AND
            trunc(nvl(disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            (designator <> PlanName OR designator_type = 1) AND
            organization_id = OrgId AND
            sr_instance_id = InsId AND
            designator_id = SchId
        UNION
        SELECT 7
        FROM   msd_dp_ascp_scenarios_v
        WHERE
            global_scenario_flag = 'N' AND
            scenario_name <> PlanName AND
            sr_instance_id = InsId AND
            (sr_instance_id = -23453 OR sr_instance_id = InsId) AND
            scenario_id = SchId
        UNION
        SELECT designator_type
        FROM
            msc_designators desig,
            msc_plan_organizations_v mpo
        WHERE
            ((desig.designator_type = 6 and desig.forecast_set_id IS NULL) OR
             (desig.designator_type IN (2,3,4,5,8) )) AND
            NVL(desig.disable_date, trunc(sysdate) + 1) > trunc(sysdate) AND
            mpo.organization_id  = desig.organization_id AND
            mpo.sr_instance_id  = desig.sr_instance_id AND
            mpo.compile_designator = desig.designator AND
            mpo.planned_organization = OrgId AND
            mpo.sr_instance_id = InsId AND
            desig.designator <> PlanName AND
            desig.designator_id = SchId
        UNION
        SELECT desig.designator_type
        FROM
            msc_designators desig,
            msc_item_sourcing mis,
            msc_plans mp
        WHERE
            ((desig.designator_type = 6 AND desig.forecast_set_id IS NULL) OR
             (desig.designator_type IN (2,3,4,5,8)) ) AND
            trunc(nvl(desig.disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            mis.plan_id = mp.plan_id AND
            mp.organization_id  = desig.organization_id AND
            mp.sr_instance_id  = desig.sr_instance_id AND
            mp.compile_designator = desig.designator AND
            mis.source_organization_id = OrgId AND
            mis.sr_instance_id2 = InsId AND
            desig.designator <> PlanName AND
            desig.designator_id = SchId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_LOCALDMDSCHS_DMD_SCH_ID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00310';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_L_DMD_SCH_ID;

-- =============================================================
-- Desc: Validate demand variability type and its dependance
-- Input:
--       SchRec            local demand schedule data.
--       DesigType         Designator type.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_LOCALDMDSCHS_VARIABILITY_TYPE
--         INVALID_LOCBALDMDSCHS_PROBABILITY
--         INVALID_LOCBALDMDSCHS_MEAN_ABS_PCT_ERROR
-- =============================================================
FUNCTION VALIDATE_L_VARIABILITY(
        SchRec             IN         MscLocIODmdSchRec,
        DesigType          IN         NUMBER
        ) RETURN VARCHAR2 AS
l_String          VARCHAR2(100);
BEGIN
    l_String := VALIDATE_VARIABILITY_ID(SchRec.DmdVariabilityType, DesigType);
    IF l_String <> 'OK' THEN
        RETURN 'INVALID_LOCALDMDSCHS_VARIABILITY_TYPE';
    END IF;
    BEGIN
        CASE SchRec.DmdVariabilityType
            WHEN 1 THEN -- Accuracy_Metric_MAD
                BEGIN
                    -- probability has to be null
                    IF SchRec.Probability IS NOT NULL THEN
                        RETURN 'INVALID_LOCBALDMDSCHS_PROBABILITY';
                    END IF;
                    -- mean absolute % error has to be null
                    IF SchRec.MeanAbsPctError IS NOT NULL THEN
                        RETURN 'INVALID_LOCBALDMDSCHS_MEAN_ABS_PCT_ERROR';
                    END IF;
                END;
            WHEN 2 THEN -- 'Probability'
                    -- probability is required and in the range of 0 to 1
                    IF SchRec.Probability IS NULL THEN
                        RETURN 'INVALID_LOCBALDMDSCHS_PROBABILITY';
                    ELSE
                        IF SchRec.Probability < 0 OR SchRec.Probability > 1 THEN
                            RETURN 'INVALID_LOCBALDMDSCHS_PROBABILITY';
                        END IF;
                    END IF;
                    -- mean absolute % error has to be null
                    IF SchRec.MeanAbsPctError IS NOT NULL THEN
                        RETURN 'INVALID_LOCBALDMDSCHS_MEAN_ABS_PCT_ERROR';
                    END IF;
            WHEN 3 THEN -- 'Mean_Absolute_Pct_Err'
                    -- probability has to be null
                    IF SchRec.Probability IS NOT NULL THEN
                        RETURN 'INVALID_LOCBALDMDSCHS_PROBABILITY';
                    END IF;
                    -- mean absolute % error is required and in the range of 0 to 100
                    IF SchRec.MeanAbsPctError IS NULL THEN
                        RETURN 'INVALID_LOCBALDMDSCHS_MEAN_ABS_PCT_ERROR';
                    ELSE
                        IF SchRec.MeanAbsPctError < 0 OR SchRec.MeanAbsPctError > 100 THEN
                            RETURN 'INVALID_LOCBALDMDSCHS_MEAN_ABS_PCT_ERROR';
                        END IF;
                    END IF;
        END CASE;
    END;

    RETURN 'OK';
END VALIDATE_L_VARIABILITY;

-- =============================================================
-- Desc: validate local demand schedules
-- Input:
--       SchTable              Local demand schedules.
--       PlanId                Plan id
--       PlanName              Plan name.
--       InsId                 Instance id
--       PurgeAll              Purge All Schs Flag
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_LOCALDMDSCHS_ORGID
--         INVALID_LOCALDMDSCHS_SCENARIO_SET
--         INVALID_LOCALDMDSCHS_DMD_SCH_ID
--         INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL
-- =============================================================
FUNCTION VALIDATE_LOC_DMD_SCHS(
        SchTable           IN         MscLocIODmdSchTbl,
        PlanId             IN         NUMBER,
        PlanName           IN         VARCHAR2,
        InsId              IN         NUMBER,
        PurgeAll           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
l_OrgInsId        NUMBER;
l_DesigType       NUMBER;
BEGIN
    IF SchTable IS NOT NULL AND SchTable.count > 0 THEN
        FOR I IN SchTable.first..SchTable.last
            LOOP
                -- validate organization id
                BEGIN
                    l_ReturnString := MSC_WS_COMMON.PLAN_CONTAINS_THIS_ORG(l_OrgInsId, SchTable(I).OrgId, PlanId);
                    IF (l_ReturnString <> 'OK') THEN
                        -- overwrite the error token here.
                        l_ReturnString := 'INVALID_LOCALDMDSCHS_ORGID';
                        RETURN l_ReturnString;
                    END IF;
                    EXCEPTION WHEN others THEN
                        g_ErrorCode := 'ERROR_UNEXPECTED_00309';
                        raise;
                END;

                -- validate scenario set
                IF SchTable(I).ScenarioSet IS NULL THEN
                    RETURN 'INVALID_LOCALDMDSCHS_SCENARIO_SET';
                ELSIF SchTable(I).ScenarioSet < 0 OR SchTable(I).ScenarioSet > 9999 THEN
                    RETURN 'INVALID_LOCALDMDSCHS_SCENARIO_SET';
                END IF;

                -- validate demand schedule id
                l_ReturnString := VALIDATE_L_DMD_SCH_ID(
                                         l_DesigType,
                                         SchTable(I).DmdSchId,
                                         SchTable(I).OrgId,
                                         l_OrgInsId,
                                         PlanName);
                IF (l_ReturnString <> 'OK') THEN
                    RETURN l_ReturnString;
                END IF;

                -- validate ship to consumption level
                IF l_DesigType = 7 THEN
                    l_ReturnString := VALIDATE_CONSUM_LVL(
                                      SchTable(I).ShipToConsumptionLvl,
                                      SchTable(I).DmdSchId);
                    IF (l_ReturnString <> 'OK') THEN
                        RETURN 'INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                    END IF;
                ELSE
                    IF SchTable(I).ShipToConsumptionLvl IS NOT NULL THEN
                        RETURN 'INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                    END IF;
                END IF;

                -- validate Type of Demand Variability and its dependence
                l_ReturnString := VALIDATE_L_VARIABILITY(SchTable(I), l_DesigType);
                IF (l_ReturnString <> 'OK') THEN
                    RETURN l_ReturnString;
                END IF;

                g_ILocDmdSchTbl.extend;
                g_ILocDmdSchTbl(g_ILocDmdSchTbl.count) :=
                    MscILocIODmdSchRec(SchTable(I).OrgId,
                                  SchTable(I).ScenarioSet,
                                  SchTable(I).DmdSchId,
                                  SchTable(I).ShipToConsumptionLvl,
                                  SchTable(I).DmdVariabilityType,
                                  SchTable(I).Probability,
                                  SchTable(I).MeanAbsPctError,
                                  1,           -- input_type
                                  l_DesigType  -- designator_type
                                  );
            END LOOP;
        l_ReturnString := VALIDATE_L_PROB(PurgeAll, InsId, PlanId);
        IF (l_ReturnString <> 'OK') THEN
            RETURN l_ReturnString;
        END IF;
    END IF;

    RETURN 'OK';
END VALIDATE_LOC_DMD_SCHS;

-- =============================================================
-- Desc: update item simulation set and service level set
--
-- Input:
--       PlanId                Id of the plan.
--       ItemSimulationSetId   Id of the item simulation set.
--       SvcLvlSet             Service level set.
--
-- Output: No output.
-- =============================================================
PROCEDURE UPDATE_PLAN_OPTIONS(
        PlanId              IN         NUMBER,
        ItemSimulationSetId IN         NUMBER,
        SvcLvlSetId         IN         NUMBER
) AS
BEGIN
    BEGIN
        UPDATE msc_plans
        SET
            item_simulation_set_id = ItemSimulationSetId,
            curr_service_level_set_id = SvcLvlSetId
        WHERE
            plan_id = PlanId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00312';
            raise;
    END;

END UPDATE_PLAN_OPTIONS;

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
FUNCTION INSERT_GLB_DMD_SCHEDULE(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscIGlbIODmdSchRec
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        INSERT INTO msc_plan_schedules
            (
            plan_id, organization_id, input_schedule_id, sr_instance_id,
            input_type, last_update_date, last_updated_by,
            creation_date, created_by, designator_type, ship_to,
            demand_variability_type, probability, mape_value
            )
        VALUES
            (
            PlanId, -1, SchRec.DmdSchId, InsId,
            SchRec.input_type, sysdate, UserId,
            sysdate, UserId, SchRec.designator_type, SchRec.ShipToConsumptionLvl,
            SchRec.DmdVariabilityType, SchRec.Probability, SchRec.MeanAbsPctError
            );
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            RETURN 'ERROR_DUP_GLOBALDMDSCH';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00313';
            raise;
    END;

    RETURN 'OK';
END INSERT_GLB_DMD_SCHEDULE;


-- =============================================================
-- Desc: Insert a locaal demand schedule
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       Schrec                local demand schedule data.
--
-- Output: The possible return statuses are:
--         OK
--         ERROR_DUP_LOCBALDMDSCH
-- =============================================================
FUNCTION INSERT_LOC_DMD_SCHEDULE(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscILocIODmdSchRec
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        INSERT INTO msc_plan_schedules
            (
            plan_id, organization_id, input_schedule_id, sr_instance_id,
            input_type, last_update_date, last_updated_by,
            creation_date, created_by, designator_type, ship_to,
            demand_variability_type, probability, mape_value,
            scenario_set, include_target_demands -- include_target_demands is hard coded to 2
            )
        VALUES
            (
            PlanId, SchRec.OrgId, SchRec.DmdSchId, InsId,
            SchRec.input_type, sysdate, UserId,
            sysdate, UserId, SchRec.designator_type, SchRec.ShipToConsumptionLvl,
            SchRec.DmdVariabilityType, SchRec.Probability, SchRec.MeanAbsPctError,
            SchRec.ScenarioSet, 2
            );
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            RETURN 'ERROR_DUP_LOCBALDMDSCH';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00314';
            raise;
    END;

    RETURN 'OK';
END INSERT_LOC_DMD_SCHEDULE;

-- =============================================================
-- Desc: this function is call when the PurgeAllSchsFlag is set,
--       insert all global and local demand schedules.
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--
-- Output: No output.
-- =============================================================
FUNCTION INSERT_ALL_SCHEDULES(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER
) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
BEGIN
    -- insert global demand schedules
    IF g_IGlbDmdSchTbl.COUNT > 0 THEN
        FOR I IN g_IGlbDmdSchTbl.first..g_IGlbDmdSchTbl.last
            LOOP
                l_ReturnString:= INSERT_GLB_DMD_SCHEDULE(PlanId, InsId, UserId, g_IGlbDmdSchTbl(I));
                IF (l_ReturnString <> 'OK') THEN
                    RETURN l_ReturnString;
                END IF;
            END LOOP;
    END IF;

    -- insert local demand schedules
    IF g_ILocDmdSchTbl.COUNT > 0 THEN
        FOR I IN g_ILocDmdSchTbl.first..g_ILocDmdSchTbl.last
            LOOP
                l_ReturnString:= INSERT_LOC_DMD_SCHEDULE(PlanId, InsId, UserId, g_ILocDmdSchTbl(I));
                IF (l_ReturnString <> 'OK') THEN
                    RETURN l_ReturnString;
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
PROCEDURE UPDATE_GLB_DMD_SCHEDULE(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscIGlbIODmdSchRec
) AS
BEGIN
    BEGIN
        UPDATE msc_plan_schedules
        SET
            ship_to                 = SchRec.ShipToConsumptionLvl,
            demand_variability_type = SchRec.DmdVariabilityType,
            probability             = SchRec.Probability,
            mape_value              = SchRec.MeanAbsPctError
        WHERE
            plan_id = PlanId AND
            organization_id = -1 AND
            sr_instance_id = InsId AND
            input_schedule_id = SchRec.DmdSchId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00316';
            raise;
    END;

END UPDATE_GLB_DMD_SCHEDULE;

-- =============================================================
-- Desc: Update a local demand schedule
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       Schrec                local demand schedule data.
--
-- Output: No output.
-- =============================================================
PROCEDURE UPDATE_LOC_DMD_SCHEDULE(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        SchRec              IN         MscILocIODmdSchRec
) AS
BEGIN
    BEGIN
        UPDATE msc_plan_schedules
        SET
            ship_to                 = SchRec.ShipToConsumptionLvl,
            demand_variability_type = SchRec.DmdVariabilityType,
            probability             = SchRec.Probability,
            mape_value              = SchRec.MeanAbsPctError,
            scenario_set            = SchRec.ScenarioSet
        WHERE
            plan_id = PlanId AND
            organization_id = SchRec.OrgId AND
            sr_instance_id = InsId AND
            input_schedule_id = SchRec.DmdSchId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00318';
            raise;
    END;

END UPDATE_LOC_DMD_SCHEDULE;

-- =============================================================
-- Desc: this function is call when the PurgeAllSchsFlag is not set,
--       insert or update bothe global and local demand schedules.
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--
-- Output: No output.
-- =============================================================
FUNCTION INSERT_OR_UPDATE_ALL_SCHS(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER
) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
l_Dummy           NUMBER;
BEGIN
    -- insert/update all global demand schedules
    IF g_IGlbDmdSchTbl.COUNT > 0 THEN
        FOR I IN g_IGlbDmdSchTbl.FIRST..g_IGlbDmdSchTbl.LAST
            LOOP
                BEGIN
                    Select count(*) INTO l_Dummy
                    FROM   msc_plan_schedules
                    WHERE
                        plan_id = PlanId AND
                        organization_id = -1 AND
                        sr_instance_id = InsId AND
                        input_schedule_id  = g_IGlbDmdSchTbl(I).DmdSchId;
                    EXCEPTION WHEN others THEN
                        g_ErrorCode := 'ERROR_UNEXPECTED_00315';
                        raise;
                END;
                IF l_Dummy = 0 THEN
                    l_ReturnString := INSERT_GLB_DMD_SCHEDULE(PlanId, InsId, UserId, g_IGlbDmdSchTbl(I));
                ELSE
                    UPDATE_GLB_DMD_SCHEDULE(PlanId, InsId, UserId, g_IGlbDmdSchTbl(I));
                END IF;
            END LOOP;
    END IF;

    -- insert/update all local demand schedules
    IF g_ILocDmdSchTbl.COUNT > 0 THEN
        FOR I IN g_ILocDmdSchTbl.first..g_ILocDmdSchTbl.last
            LOOP
                BEGIN
                    Select count(*) INTO l_Dummy
                    FROM   msc_plan_schedules
                    WHERE
                        plan_id = PlanId AND
                        organization_id = g_ILocDmdSchTbl(I).OrgId AND
                        sr_instance_id = InsId AND
                        input_schedule_id  = g_ILocDmdSchTbl(I).DmdSchId;
                    EXCEPTION WHEN others THEN
                        g_ErrorCode := 'ERROR_UNEXPECTED_7';
                        raise;
                END;
                IF l_Dummy = 0 THEN
                    l_ReturnString := INSERT_LOC_DMD_SCHEDULE(PlanId, InsId, UserId, g_ILocDmdSchTbl(I));
                    IF (l_ReturnString <> 'OK') THEN
                        RETURN l_ReturnString;
                     END IF;
                ELSE
                    UPDATE_LOC_DMD_SCHEDULE(PlanId, InsId, UserId, g_ILocDmdSchTbl(I));
                    IF (l_ReturnString <> 'OK') THEN
                        RETURN l_ReturnString;
                     END IF;
                END IF;
            END LOOP;
    END IF;


RETURN 'OK';
END INSERT_OR_UPDATE_ALL_SCHS;

-- =============================================================
-- Desc: This procedure is invoked from web service to
--       updates Plan Options for IO plans.
-- Input:
--        UserId            User ID.
--        ResponsibilityId  Responsibility Id.
--        PlanId            Plan Id.
--        ItemSimulationSet Item Simulation Set.
--        ServiceLvlSetId   Service Level Set Id.
--        PurgeAllSchsFlag  There is no such parameter in UI. Allowed
--                          input is Y or N. This is a new parameter
--                          to control how Global and local Demand Schedules
--                          are updated / inserted. If this flag is set, all
--                          Global and Local Demand will be purged before
--                          update / insert from the input parameters.
--                          If this flag is not set, no global or local demand
--                          schedules will be purged, schedules in the input
--                          parameters will be updated or inserted.
--        GlobalDmdSchs	    Global Demand Schedules. Each global demand schedule
--                          contains the schedule id, ship to consumption,
--                          demand variability type, probability and/or
--                          mean absolue % error parameters.
--        LocalDmdSchs      Local Demand Schedules. Each local demand schedule
--                          contains the organization id, schedule id, scenario set id,
--                          ship to consumption, demand variability type, probability and/or
--                          mean absolue % error parameters.
--
-- Output: Procedure returns a status and conc program req id.
--       The possible return statuses are:
--          SUCCESS if everything is ok
--          ERROR_DUP_GLOBALDMDSCH
--          ERROR_DUP_LOCBALDMDSCH
--          ERROR_UNEXPECTED_#####  unexpected error
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
--          INVALID_PLANID          invalid source plan id
--          INVALID_PLAN_TYPE       non IO plan
--          INVALID_SIMULATION_SET_ID
--          INVALID_SERVICE_LVL_SET_ID
--          INVALID_GLOBALDMDSCHS_DMD_SCH_ID
--          INVALID_GLOBALDMDSCHS_SHP_TO_CONSUMPTION_LVL
--          INVALID_GLOBALDMDSCHS_VARIABILITY_TYPE
--          INVALID_GLOBALDMDSCHS_PROBABILITY
--          INVALID_GLOBALDMDSCHS_MEAN_ABS_PCT_ERROR
--          INVALID_VAR_TYPE_IN_GBL_SCH
--          INVALID_GLB_SUM_OF_PROB
--          INVALID_LOCALDMDSCHS_ORGID
--          INVALID_LOCALDMDSCHS_SCENARIO_SET
--          INVALID_LOCALDMDSCHS_DMD_SCH_ID
--          INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL
--          INVALID_LOCALDMDSCHS_VARIABILITY_TYPE
--          INVALID_LOCBALDMDSCHS_PROBABILITY
--          INVALID_LOCBALDMDSCHS_MEAN_ABS_PCT_ERROR
--          INVALID_VAR_TYPE_IN_SCENARIO_SET
--          INVALID_LOC_SUM_OF_PROB
-- =============================================================
PROCEDURE SET_IO_PLAN_OPTIONS(
        Status               OUT NOCOPY VARCHAR2,
        UserId               IN         NUMBER,
        ResponsibilityId     IN         NUMBER,
        PlanId               IN         NUMBER,
        ItemSimulationSetId  IN         NUMBER default NULL,
        ServiceLvlSetId      IN         NUMBER default NULL,
        PurgeAllSchsFlag     IN         VARCHAR2,
        GlobalDmdSchs        IN         MscGlbIODmdSchTbl default NULL,
        LocalDmdSchs         IN         MscLocIODmdSchTbl default NULL
        ) IS
l_String            VARCHAR2(100);
l_OrgId             NUMBER;
l_InsId             NUMBER;
l_PlanName          VARCHAR2(10);
BEGIN
-- dbms_output.put_line('Matthew: Init');

    -- init global variables
    g_IGlbDmdSchTbl  := MscIGlbIODmdSchTbl();
    g_ILocDmdSchTbl  := MscILocIODmdSchTbl();

    -- check user id and responsibility
    MSC_WS_COMMON.VALIDATE_USER_RESP(l_String, UserId, ResponsibilityId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- check plan id
    -- l_String := MSC_WS_COMMON.VALIDATE_PLAN_ID(l_OrgId, l_InsId, l_PlanName, PlanId);
    l_String := VALIDATE_PLAN_ID(l_OrgId, l_InsId, l_PlanName, PlanId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- check plan type
    l_String := VALIDATE_PLAN_TYPE(PlanId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;


    -- validate item simulation set id
    BEGIN
        l_String := MSC_WS_COMMON.VALIDATE_SIMULATION_SET_ID(ItemSimulationSetId);
        IF (l_String <> 'OK') THEN
            Status := l_String;
            RETURN;
        END IF;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00303';
            raise;
    END;

    -- validate service level set id
    l_String := VALIDATE_SER_LVL_SET_ID(ServiceLvlSetId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;


    -- validate global demand schedules
    l_String := VALIDATE_GLB_DMD_SCHS(GlobalDmdSchs, PlanId, l_PlanName, l_InsId, PurgeAllSchsFlag);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- validate local demand schedules
    l_String := VALIDATE_LOC_DMD_SCHS(LocalDmdSchs, PlanId, l_PlanName, l_InsId, PurgeAllSchsFlag);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- if PurgeAllSchsFlag is set, purge all global demand schedules,
    -- local demand schedule and local supply schedules
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllSchsFlag) = MSC_UTIL.SYS_YES THEN
        BEGIN
            MSC_WS_COMMON.PURGE_ALL_SCHEDULES(PlanId);
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_00011';
                raise;
        END;
    END IF;

    -- update item simulation set and overwrite
    UPDATE_PLAN_OPTIONS(PlanId, ItemSimulationSetId, ServiceLvlSetId);

    -- set all global/local demand/supply schedules
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllSchsFlag) = MSC_UTIL.SYS_YES THEN
        l_String := INSERT_ALL_SCHEDULES(PlanId, l_InsId, UserId);
    ELSE
        l_String := INSERT_OR_UPDATE_ALL_SCHS(PlanId, l_InsId, UserId);
    END IF;

    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    ELSE
        Status := 'SUCCESS';
    END IF;

    COMMIT;

    EXCEPTION
        WHEN others THEN
        -- Status := 'Failed '||fnd_message.get;
            Status := g_ErrorCode;
            ROLLBACK;

END SET_IO_PLAN_OPTIONS;


PROCEDURE SET_IO_PLAN_OPTIONS_PUBLIC (

		   status                 OUT NOCOPY VARCHAR2,
		   UserName               IN VARCHAR2,
		   RespName     IN VARCHAR2,
		   RespApplName IN VARCHAR2,
		   SecurityGroupName      IN VARCHAR2,
		   Language            IN VARCHAR2,
        PlanId               IN         NUMBER,
        ItemSimulationSetId  IN         NUMBER default NULL,
        ServiceLvlSetId      IN         NUMBER default NULL,
        PurgeAllSchsFlag     IN         VARCHAR2,
        GlobalDmdSchs        IN         MscGlbIODmdSchTbl default NULL,
        LocalDmdSchs         IN         MscLocIODmdSchTbl default NULL

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
     MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFPPMR-SRO',l_SecutirtGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
    error_tracking_num :=2040;

   SET_IO_PLAN_OPTIONS ( Status, userId , respid, PlanId, ItemSimulationSetId, ServiceLvlSetId, PurgeAllSchsFlag, GlobalDmdSchs, LocalDmdSchs );
   --      dbms_output.put_line('USERID=' || userid);


      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;
END  SET_IO_PLAN_OPTIONS_PUBLIC;

END MSC_WS_IO;


/

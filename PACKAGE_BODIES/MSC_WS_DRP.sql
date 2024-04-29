--------------------------------------------------------
--  DDL for Package Body MSC_WS_DRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_DRP" AS
/* $Header: MSCWDRPB.pls 120.10 2008/03/20 15:56:53 bnaghi noship $  */


g_IGlbDmdSchTbl  MscIGlbDmdSchTbl; -- store all global demand schediles data
g_ILocDmdSchTbl  MscILocDmdSchTbl; -- store all local demand schediles data
g_ILocSupSchTbl  MscILocSupSchTbl; -- store all local supply schediles data
g_ErrorCode      VARCHAR2(9);

-- =============================================================
-- Desc: Please see package spec for description
-- =============================================================
PROCEDURE LAUNCH_DRP_BATCH (
                           processId              OUT NOCOPY NUMBER,
                           status                 OUT NOCOPY VARCHAR2,
                           userId                 IN NUMBER,
                           responsibilityId       IN NUMBER,
                           planId                 IN NUMBER,
                           launchSnapshot         IN VARCHAR2,
                           launchPlanner          IN VARCHAR2,
                           anchorDate             IN DATE,
                           archiveCurrVersPlan IN VARCHAR2,
                           enable24x7Atp          IN VARCHAR2 ,
                           releaseReschedules     IN VARCHAR2
                       ) AS
    l_val_result               VARCHAR2(30);
    l_val_planId               NUMBER;
    l_val_planName             VARCHAR2(10);
    l_val_launchSnapshot       NUMBER;
    l_val_launchPlanner        NUMBER;
    l_val_netchange            NUMBER;
    l_val_anchorDate           DATE;
    l_val_archivePlan         NUMBER;
    l_val_inventory_atp_flag   NUMBER;
    l_val_enable24x7Atp        NUMBER;
    l_val_production           NUMBER;
    l_val_releaseReschedules   NUMBER;
    l_val_orgId                NUMBER;
    l_val_instanceId           NUMBER;
    error_tracking_num         NUMBER;
  BEGIN
     error_tracking_num := 1010;

     -- validate and initialize apps
     MSC_WS_COMMON.VALIDATE_USER_RESP(l_val_result, userId, responsibilityId);

     IF (l_val_result <> 'OK') THEN
       processId := -1;
       status := l_val_result;
       RETURN;
     END IF;

     error_tracking_num := 1020;

     -- validate planId
     BEGIN
       SELECT plans.compile_designator, plans.organization_id, plans.sr_instance_id,
              desig.inventory_atp_flag, desig.production
       INTO l_val_planName,l_val_orgId,l_val_instanceId,l_val_inventory_atp_flag,
            l_val_production
       FROM   msc_plans plans, msc_designators desig
       WHERE  plans.curr_plan_type = 5
       AND    plans.organization_id = desig.organization_id
       AND    plans.sr_instance_id = desig.sr_instance_id
       AND    plans.compile_designator = desig.designator
       AND    NVL(desig.disable_date, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE)
       AND    plans.plan_id = planId;


     EXCEPTION
       WHEN no_data_found THEN
         processid := -1;
         status := 'INVALID_PLANID';
         RETURN;
     END;


     error_tracking_num := 1030;
     -- validate anchor date
     BEGIN
       SELECT calendar_date
       INTO l_val_anchorDate
       FROM msc_calendar_dates dates,
         msc_trading_partners mtp
       WHERE dates.calendar_code = mtp.calendar_code
        AND dates.exception_set_id = mtp.calendar_exception_set_id
        AND mtp.sr_instance_id = dates.sr_instance_id
        AND mtp.sr_tp_id = l_val_orgid
        AND mtp.sr_instance_id = l_val_instanceid
        AND dates.calendar_date <= TRUNC(sysdate)
        AND dates.calendar_date = anchorDate;

     EXCEPTION
     WHEN no_data_found THEN
       processid := -1;
       status := 'INVALID_ANCHORDATE';
       RETURN;
     END;


     error_tracking_num := 1040;
     -- expected values are Y and N , if it is Y then converted to SYS_YES ,others to SYS_NO
     BEGIN
       SELECT DECODE(launchSnapshot,
                 'Y' ,MSC_WS_COMMON.SYS_YES, MSC_WS_COMMON.SYS_NO)
       INTO   l_val_launchSnapshot
       FROM   DUAL;

     END;


     error_tracking_num := 1050;
     -- validate launchPlanner
     BEGIN
       SELECT lookup_code
       INTO   l_val_launchPlanner
       FROM   MFG_LOOKUPS
       WHERE  lookup_type = 'SYS_YES_NO'
       AND    ((lookup_code = 1 AND l_val_launchSnapshot = 1) OR
               (l_val_launchSnapshot = 2))
       AND    lookup_code = decode(launchPlanner, 'Y', msc_ws_common.sys_yes, msc_ws_common.sys_no);
     EXCEPTION
       WHEN no_data_found THEN
         processid := -1;
         status := 'INVALID_LAUNCH_PLANNER';
         RETURN;
     END;

  error_tracking_num := 1055;

     BEGIN
       SELECT  decode(archiveCurrVersPlan, 'Y', msc_ws_common.sys_yes, msc_ws_common.sys_no)
       INTO   l_val_archivePlan
       FROM   dual;

     END;
     -- netchange hidden parameter always set to the value 2, which is sys_no
     l_val_netchange := msc_ws_common.sys_no;



     -- populating PLAN_TYPE_DUMMY hidden parameter
     -- Original default logic is "SELECT inventory_atp_flag from msc_designators d
     -- where d.designator = :$FLEX$.MSC_SRS_SRO_NAME_LAUNCH_1 and d.inventory_atp_flag = 1"
     -- Which pretty much meant this flag is set to either NULL or 1
     IF (l_val_inventory_atp_flag  <> 1)
     THEN l_val_inventory_atp_flag := NULL;
     END IF;


     error_tracking_num := 1060;
    -- validating enable24x7atp
     BEGIN
       SELECT lookup_code
       INTO   l_val_enable24x7Atp
       FROM   MFG_LOOKUPS
       WHERE  LOOKUP_TYPE = 'MSC_24X7_PURGE'
       AND    (( LOOKUP_CODE IN (1,2,3) and NVL(l_val_inventory_atp_flag,2) = 1 )
               OR LOOKUP_CODE=2)
       AND    LOOKUP_CODE = decode(enable24x7atp,'YES_PURGE',1,'NO',2,'YES_NO_PURGE',3,-1);
     EXCEPTION
       WHEN no_data_found THEN
         processid := -1;
         status := 'INVALID_ENABLE24X7ATP';
         RETURN;
     END;


     -- populating RESCHEDULE_DUMMY hidden parameter
     -- Similar default logic as l_val_inventory_atp_flag, "SELECT production from
     -- msc_designators d where d.designator = :$FLEX$.MSC_SRS_SRO_NAME_LAUNCH_1 and d.production = 1"
     IF (l_val_production  <> 1)
     THEN l_val_production := NULL;
     END IF;

     error_tracking_num := 1070;
     -- validating releaseReschedules
     BEGIN
       SELECT lookup_code
       INTO   l_val_releaseReschedules
       FROM   MFG_LOOKUPS
       WHERE  lookup_type='SYS_YES_NO'
       AND    (NVL(l_val_production,2)=1  or lookup_code=2)
       AND    lookup_code = decode(releaseReschedules,'Y',msc_ws_common.sys_yes, msc_ws_common.sys_no);
     EXCEPTION
       WHEN no_data_found THEN
         processid := -1;
         status := 'INVALID_RELEASE_RESCHEDULES';
         RETURN;
     END;

     processId := FND_REQUEST.SUBMIT_REQUEST(
                                'MSC',                        -- application
                                'MSCSLPPR6',                  -- program
                                NULL,                         -- description
                                NULL,                         -- start_time
                                FALSE,                        -- sub_request
                                l_val_planName,
                                planId,
                                l_val_launchSnapshot,
                                l_val_launchPlanner,
                                l_val_netchange,              -- netchange,
                                to_char(l_val_anchorDate, 'YYYY/MM/DD HH24:MI:SS'),
                                l_val_archivePlan,
                                l_val_inventory_atp_flag,     -- plan_type_dummy param
                                l_val_enable24x7Atp,
                                l_val_production,             -- rescheduleDummy VARCHAR2
                                l_val_releaseReschedules      -- release
                                );

     IF (processId = 0) then
       processId := -1;
       status := 'ERROR_SUBMIT';
       return;
     END IF;

     status := 'SUCCESS';

  EXCEPTION
     WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;
         processId := -1;
         return;
  END LAUNCH_DRP_BATCH;

 PROCEDURE 	LAUNCH_DRP_BATCH_PUBLIC (
                              processId              OUT NOCOPY NUMBER,
                              status                 OUT NOCOPY VARCHAR2,
                              UserName               IN VARCHAR2,
                              RespName     IN VARCHAR2,
                              RespApplName IN VARCHAR2,
                              SecurityGroupName      IN VARCHAR2,
                              Language            IN VARCHAR2,
                              planId                 IN NUMBER,
                              launchSnapshot         IN VARCHAR2,
                              launchPlanner          IN VARCHAR2,
                              anchorDate             IN DATE,
                              archiveCurrVersPlan IN VARCHAR2,
                              enable24x7Atp          IN VARCHAR2,
                              releaseReschedules     IN VARCHAR2

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
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFNDRP',l_SecutirtGroupId);
   IF (l_String <> 'OK') THEN
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFPCDP', l_SecutirtGroupId);
       IF (l_String <> 'OK') THEN
       MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_ORG_FNDRSRUN_LAUNCH_DRP',l_SecutirtGroupId);
       IF (l_String <> 'OK') THEN
       Status := l_String;
       RETURN;
    END IF;
    END IF;
    END IF;

    error_tracking_num :=2040;
   LAUNCH_DRP_BATCH ( processId, status, userId ,respid, planId , launchSnapshot ,launchPlanner, anchorDate ,archiveCurrVersPlan, enable24x7Atp, releaseReschedules );



      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;
         processId := -1;
         return;
END LAUNCH_DRP_BATCH_PUBLIC;

-- =============================================================
-- Desc: Please see package spec for description
-- =============================================================
 PROCEDURE RELEASE_DRP (    req_id              OUT NOCOPY REQTBLTYP,
                              status              OUT NOCOPY VARCHAR2,
                              userId              IN NUMBER,
                              responsibilityId    IN NUMBER,
                              planId              IN NUMBER,
                              release_time_fence_anchor_date IN VARCHAR2
                             ) AS
        error_tracking_num       NUMBER;
        l_val_result             VARCHAR2(30);
        l_val_planid             NUMBER;
        l_val_planName           VARCHAR2(10);
        l_val_orgid              NUMBER;
        l_val_instanceid         NUMBER;
        l_rel_time_window        VARCHAR2(1);
        RETCODE NUMBER;
        ERRMSG                   VARCHAR2(200);
        l_req_id             MSC_RELEASE_PK.REQTBLTYP;

        i     number;
        j     number :=1;

   BEGIN
       req_id  := REQTBLTYP();
        error_tracking_num :=2010;
        msc_ws_common.validate_user_resp(l_val_result,   userid,   responsibilityid);

        IF(l_val_result <> 'OK') THEN
          status := l_val_result;
          RETURN;
        END IF;


        error_tracking_num :=2020;
        -- check plan id
        BEGIN
         SELECT plans.compile_designator
        INTO l_val_planName
        FROM   msc_plans plans, msc_designators desig
        WHERE  plans.curr_plan_type = 5
        AND    plans.organization_id = desig.organization_id
        AND    plans.sr_instance_id = desig.sr_instance_id
        AND    plans.compile_designator = desig.designator
        AND    NVL(desig.disable_date, TRUNC(SYSDATE) + 1) > TRUNC(SYSDATE)
        AND    plans.plan_id = planId;
        EXCEPTION
          WHEN no_data_found THEN
           status := 'INVALID_PLANID';
            RETURN;
        END;

        error_tracking_num :=2010;
        if (release_time_fence_anchor_date = 'PLAN_START_DATE')THEN
              l_rel_time_window := 'Y';
         elsif   (release_time_fence_anchor_date = 'CURRENT_DATE')THEN
              l_rel_time_window := 'N';
         elsE


           status := 'INVALID_RELEASE_TIME_FENCE_ANCHOR_DATE';
           RETURN;

           end if;

         error_tracking_num :=2030;
         msc_release_pk.msc_web_service_release(planId, l_rel_time_window, RETCODE, ERRMSG,l_REQ_ID);
        IF (RETCODE = 2) THEN
                   status := 'ERROR_RELEASE '|| ERRMSG;
                   RETURN;
        END IF;

        error_tracking_num :=2040;
        FOR i IN 1..l_REQ_ID.count LOOP
        if (l_REQ_ID(i).ReqID is not null) then
               req_id.extend;
               req_id(j) :=  reqrectyp(l_REQ_ID(i).instanceCode,l_REQ_ID(i).ReqID, l_REQ_ID(i).ReqType);
                j := j + 1;
        end if;

         END LOOP;


        status := 'SUCCESS';


      EXCEPTION
        WHEN others THEN
            status := 'ERROR_UNEXPECTED_'||error_tracking_num;


            rollback;
            return;


  END RELEASE_DRP;

PROCEDURE RELEASE_DRP_PUBLIC (   req_id              OUT NOCOPY  REQTBLTYP,
                            status              OUT NOCOPY VARCHAR2,
                            UserName               IN VARCHAR2,
			    RespName     IN VARCHAR2,
			    RespApplName IN VARCHAR2,
			    SecurityGroupName      IN VARCHAR2,
			    Language            IN VARCHAR2,
                            planId              IN NUMBER,
                            release_time_fence_anchor_date IN VARCHAR2
                          ) AS
  userid    number;
  respid    number;
  l_String VARCHAR2(30);
  error_tracking_num number;
  l_SecutirtGroupId  NUMBER;
 BEGIN
   req_id  := REQTBLTYP();
   error_tracking_num :=2010;
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    error_tracking_num :=2030;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFNDRP',l_SecutirtGroupId);
    IF (l_String <> 'OK') THEN
       Status := l_String;
       RETURN;
    END IF;
    -- END IF;
    error_tracking_num :=2040;

   RELEASE_DRP (  req_id  , status, userId ,respid, planId , release_time_fence_anchor_date );



      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;
END  RELEASE_DRP_PUBLIC;

-- =============================================================
--
-- SET_DRP_PLAN_OPTIONS and its private helper functions.
--
-- Un-handled exceptions generate error tokens in the
-- format of ERROR_UNEXPECTED_#####.
-- The possible values are:
--   00101 - SET_DRP_PLAN_OPTIONS/MSC_WS_COMMON.VALIDATE_PLAN_ID
--   00102 - SET_DRP_PLAN_OPTIONS/VALIDATE_PLAN_TYPE
--   00103 - SET_DRP_PLAN_OPTIONS/MSC_WS_COMMON.VALIDATE_SIMULATION_SET_ID
--   00104 - SET_DRP_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/MSC_WS_COMMON.VALIDATE_G_DMD_SCH_ID
--   00105 - SET_DRP_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/MSC_WS_COMMON.VALIDATE_CONSUM_LVL (goe / item)
--   00106 - SET_DRP_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/VALIDATE_L_DMD_SCH_ID
--   00107 - SET_DRP_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/MSC_WS_COMMON.PLAN_CONTAINS_THIS_ORG
--   00108 - SET_DRP_PLAN_OPTIONS/MSC_WS_COMMON.VALIDATE_LOC_SUP_SCHS
--   00109 - SET_DRP_PLAN_OPTIONS/MSC_WS_COMMON.PURGE_ALL_SCHEDULES
--   00110 - SET_DRP_PLAN_OPTIONS/MSC_WS_COMMON.UPDATE_PLAN_OPTIONS
--   00111 - SET_DRP_PLAN_OPTIONS/MSC_WS_COMMON.INSERT_ALL_SCHEDULES
--   00112 - SET_DRP_PLAN_OPTIONS/MSC_WS_COMMON.INSERT_OR_UPDATE_ALL_SCHS
-- =============================================================

-- =============================================================
-- Desc: Validate plan id, copy the where clause from LAUNCH_DRP_BATCH
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
            -- plans.organization_selection <> 1 AND
            plans.curr_plan_type in (1,2,3,4,5,8,9) AND
            plans.plan_id <> -1 AND
            -- NVL(plans.copy_plan_id,-1) = -1 AND
            -- NVL(desig.copy_designator_id, -1) = -1 AND
            plans.plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLANID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00101';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_PLAN_ID;

-- =============================================================
-- Desc: Validate plan type is DRP
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
            curr_plan_type = 5 AND
            plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLAN_TYPE';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00102';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_PLAN_TYPE;

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
        SchTable           IN         MscGlbDmdSchTbl,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
l_String          VARCHAR2(100);
BEGIN
    IF SchTable IS NOT NULL AND SchTable.count > 0 THEN
        FOR I IN SchTable.first..SchTable.last
            LOOP
                -- validate demand schedule id
                BEGIN
                    l_String := MSC_WS_COMMON.VALIDATE_G_DMD_SCH_ID(SchTable(I).DmdSchId, PlanName);
                    IF (l_String <> 'OK') THEN
                        RETURN l_String;
                    END IF;
                EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UNEXPECTED_00104';
                    raise;
                END;

                -- validate ship to consumption level
                BEGIN
                    l_String := MSC_WS_COMMON.VALIDATE_CONSUM_LVL(
                                      SchTable(I).ShipToConsumptionLvl,
                                      SchTable(I).DmdSchId);
                    IF (l_String <> 'OK') THEN
                        RETURN 'INVALID_GLOBALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                    END IF;
                EXCEPTION WHEN others THEN
                    g_ErrorCode := 'ERROR_UNEXPECTED_00105';
                    raise;
                END;
                g_IGlbDmdSchTbl.extend;
                g_IGlbDmdSchTbl(g_IGlbDmdSchTbl.count) :=
                     MscIGlbDmdSchRec(SchTable(I).DmdSchId,
                                   SchTable(I).ShipToConsumptionLvl,
                                   1, -- input_type
                                   7  -- designator_type
                                   );
            END LOOP;
    END IF;

    l_ReturnString := 'OK';
    RETURN l_ReturnString;
END VALIDATE_GLB_DMD_SCHS;

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
        FcstShipTo         OUT NOCOPY NUMBER,
        SchId              IN         NUMBER,
        OrgId              IN         NUMBER,
        InsId              IN         NUMBER,
        PlanName           IN         VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT
            desig.designator_type,
            decode(desig.designator_type,  6, desig.update_type, -1)
        INTO
            DesigType,
            FcstShipTo
        FROM
            msc_designators desig,
            fnd_lookups lu
        WHERE
            ( (desig.designator_type = 6 and desig.forecast_set_id is null) OR
              (desig.designator_type in (5,8)) ) AND
            trunc(nvl(desig.disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            ( desig.designator <> PlanName OR desig.designator_type = 1 ) AND
            desig.organization_id = OrgId AND
            desig.sr_instance_id = InsId AND
            desig.designator_id = SchId AND
            lu.lookup_code(+) = desig.update_type AND
            lu.lookup_type(+) = 'MSC_SHIP_TO'
        UNION
        SELECT
            7, -1
        FROM
            msd_dp_ascp_scenarios_v
        WHERE
            scenario_name <> PlanName AND
            sr_instance_id = InsId AND
            scenario_id = SchId AND
            last_revision IS NOT NULL
        UNION
        SELECT
            desig.designator_type,
            decode(desig.designator_type, 6, desig.update_type, -1)
        FROM
            msc_designators desig,
            msc_plan_organizations_v mpo,
            fnd_lookups lu
        WHERE
            ( (desig.designator_type = 6 AND desig.forecast_set_id is null) OR
              (desig.designator_type in (5,8)) ) AND
            trunc(nvl(desig.disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            mpo.organization_id  = desig.organization_id AND
            mpo.sr_instance_id  = desig.sr_instance_id AND
            mpo.compile_designator = desig.designator AND
            mpo.planned_organization = OrgId AND
            mpo.sr_instance_id = InsId AND
            desig.designator <> PlanName AND
            desig.designator_id = SchId AND
            lu.lookup_code(+) = desig.update_type AND
            lu.lookup_type(+) = 'MSC_SHIP_TO'
        UNION
        SELECT
            desig.designator_type,
            decode(desig.designator_type, 6, desig.update_type, -1)
        FROM
            msc_designators desig,
            msc_item_sourcing mis,
            msc_plans mp,
            fnd_lookups lu
        WHERE
            ( (desig.designator_type = 6 AND desig.forecast_set_id is null) OR
              (desig.designator_type IN (5,8)) ) AND
            trunc(nvl(desig.disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            mis.plan_id = mp.plan_id AND
            mp.organization_id  = desig.organization_id AND
            mp.sr_instance_id  = desig.sr_instance_id AND
            mp.compile_designator = desig.designator AND
            mis.source_organization_id = OrgId AND
            mis.sr_instance_id2 = InsId AND
            desig.designator <> PlanName AND
            desig.designator_id = SchId AND
            lu.lookup_code(+) = desig.update_type AND
            lu.lookup_type(+) = 'MSC_SHIP_TO';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_LOCALDMDSCHS_DMD_SCH_ID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00106';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_L_DMD_SCH_ID;

-- =============================================================
-- Desc: validate local demand schedules
-- Input:
--       SchTable              Local demand schedules.
--       PlanName              Plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_LOCALDMDSCHS_ORGID
--         INVALID_LOCALDMDSCHS_DMD_SCH_ID
--         INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL
-- =============================================================
FUNCTION VALIDATE_LOC_DMD_SCHS(
        SchTable           IN         MscLocSRPDmdSchTbl,
        PlanId             IN         NUMBER,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
l_OrgInsId        NUMBER;
l_DesigType       NUMBER;
l_FcstShipTo      NUMBER;
l_ShipTo          NUMBER;
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
                        g_ErrorCode := 'ERROR_UNEXPECTED_00107';
                        raise;
                END;

                -- validate demand schedule id
                l_ReturnString := VALIDATE_L_DMD_SCH_ID(
                                         l_DesigType,
                                         l_FcstShipTo,
                                         SchTable(I).DmdSchId,
                                         SchTable(I).OrgId,
                                         l_OrgInsId,
                                         PlanName);
                IF (l_ReturnString <> 'OK') THEN
                    RETURN l_ReturnString;
                END IF;

                -- validate ship to consumption level
                -- if l_DesigType = 7 , DPSCN, do validation
                -- else if l_DesigType = 6, FCST, copy forecast_ship_to to ship to
                -- else default to null, 1 MDS, 2 MPS, 3 MRP, 4 MPP, 5 IP, 8 DPP, 9 MNTDS, 10 MFGDS
                IF l_DesigType = 7 THEN
                    IF SchTable(I).ShipToConsumptionLvl IS NULL THEN
                        RETURN 'INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                    END IF;
                    l_ShipTo := SchTable(I).ShipToConsumptionLvl;
                    l_ReturnString := MSC_WS_COMMON.VALIDATE_CONSUM_LVL(
                                          SchTable(I).ShipToConsumptionLvl,
                                          SchTable(I).DmdSchId);
                    IF (l_ReturnString <> 'OK') THEN
                        RETURN 'INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                    END IF;
                ELSE
                    IF SchTable(I).ShipToConsumptionLvl IS NOT NULL THEN
                        RETURN 'INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                    END IF;
                    IF l_DesigType = 6 THEN
                        l_ShipTo := l_FcstShipTo;
                    ELSE
                        l_ShipTo := NULL;
                    END IF;
                END IF;

                -- I don't see any check boxes for include target demands and inter plant in UI ???

                g_ILocDmdSchTbl.extend;
                g_ILocDmdSchTbl(g_ILocDmdSchTbl.count) :=
                    MscILocDmdSchRec(SchTable(I).OrgId,
                                  SchTable(I).DmdSchId,
                                  2, -- IncludeTargetDmd is hard coded to 2
                                  l_ShipTo,
                                  NULL,
                                  1,           -- input_type
                                  l_DesigType  -- designator_type
                                  );
            END LOOP;
    END IF;

    l_ReturnString := 'OK';
    RETURN l_ReturnString;
END VALIDATE_LOC_DMD_SCHS;

-- =============================================================
-- Desc: This procedure is invoked from web service to
--       updates Plan Options for DRP plans.
-- Input:
--        UserId            User ID.
--        ResponsibilityId  Responsibility Id.
--        PlanId            Plan Id.
--        ItemSimulationSet Item Simulation Set.
--        Overwrite         Overwrite. Expected values are All,
--                          Outside PTF or None.
--        PurgeAllSchsFlag  There is no such parameter in UI. Allowed
--                          input is Y or N. This is a new parameter
--                          to control how Global Demand Schedules, Local
--                          Demand Schedules and Local Supply Schedules
--                          are updated / inserted. If this flag is set, all
--                          Global Demand Schedules, Local Demand Schedules and
--                          Local Supply Schedule will be purged before
--                          update / insert any demand / supply schedules from
--                          the input parameters. If this flag is not set, no
--                          demand / supple schedules will be purged, schedules in
--                          the input parameters will be updated or inserted.
--        GlobalDmdSchs	    Global Demand Schedules. Each demand schedule contains
--                          the schedule id and ship to consumption level parameters.
--                          Although this is not a required parameter, we need both
--                          id and ShpToConsumptionLvl to define a demand schedule,
--                          so either both parameters are empty or both are entered.
--        LocalDmdSchs      Local Demand Schedules. List of all local demand schedules.
--                          Each local demand schedule contains the organization id,
--                          demand schedule id and ship to consumption level. Similar to
--                          Global Demand Schedules, these Three parameters have to be
--        LocalSupSchs      Supply Schedules.List of local supply schedules. Each local
--                          supply schedule contains the organization id and supply
--                          schedule id. Similar to Global Demand Schedules, these
--                          two parameters have to be either both empty or both entered
--
-- Output: Procedure returns a status and conc program req id.
--       The possible return statuses are:
--          SUCCESS if everything is ok
--          ERROR_DUP_GLOBALDMDSCH
--          ERROR_DUP_LOCALDMDSCH
--          ERROR_DUP_LOCALSUPSCH
--          ERROR_UNEXPECTED_#####  unexpected error
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
--          INVALID_PLANID          invalid source plan id
--          INVALID_PLAN_TYPE       non DRP plan
--          INVALID_SIMULATION_SET_ID
--          INVALID_OVERWRITE       Only 'Y' or 'N' is allowed.
--          INVALID_GLOBALDMDSCHS_DMD_SCH_NAME
--          INVALID_GLOBALDMDSCHS_SHP_TO_CONSUMPTION_LVL
--          INVALID_LOCALDMDSCHS_ORGID
--          INVALID_LOCALDMDSCHS_DMD_SCH_ID
--          INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL
--          INVALID_LOCALSUPSCHS_ORGID
--          INVALID_LOCALSUPSCHS_SUP_SCH_NAME
-- =============================================================
PROCEDURE SET_DRP_PLAN_OPTIONS (
        Status               OUT NOCOPY VARCHAR2,
        UserId               IN         NUMBER,
        ResponsibilityId     IN         NUMBER,
        PlanId               IN         NUMBER,
        ItemSimulationSetId  IN         NUMBER default NULL,
        Overwrite            IN         VARCHAR2 default 'All',
        PurgeAllSchsFlag     IN         VARCHAR2,
        GlobalDmdSchs        IN         MscGlbDmdSchTbl default NULL,
        LocalDmdSchs         IN         MscLocSRPDmdSchTbl default NULL,
        LocalSupSchs         IN         MscLocSupSchTbl default NULL
        ) AS
l_String            VARCHAR2(100);
l_OrgId             NUMBER;
l_InsId             NUMBER;
l_PlanName          VARCHAR2(10);
l_Overwrite         NUMBER;
  BEGIN
-- dbms_output.put_line('Matthew: Init');

    -- init global variables
    g_IGlbDmdSchTbl := MscIGlbDmdSchTbl();
    g_ILocDmdSchTbl := MscILocDmdSchTbl();
    g_ILocSupSchTbl := MscILocSupSchTbl();

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
            g_ErrorCode := 'ERROR_UNEXPECTED_00103';
            raise;
    END;

    l_Overwrite := MSC_WS_COMMON.CONVERT_OVERWRITE(Overwrite);


    -- validate global demand schedules
    l_String := VALIDATE_GLB_DMD_SCHS(GlobalDmdSchs, l_PlanName);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- validate local demand schedules
    l_String := VALIDATE_LOC_DMD_SCHS(LocalDmdSchs, PlanId, l_PlanName);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- validate local supply schedules
    BEGIN
        l_String := MSC_WS_COMMON.VALIDATE_LOC_SUP_SCHS(g_ILocSupSchTbl, LocalSupSchs, PlanId, l_PlanName);
        IF (l_String <> 'OK') THEN
            Status := l_String;
            RETURN;
        END IF;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00108';
            raise;
    END;

    -- if PurgeAllSchsFlag is set, purge all global demand schedules,
    -- local demand schedule and local supply schedules
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllSchsFlag) = MSC_UTIL.SYS_YES THEN
        BEGIN
            MSC_WS_COMMON.PURGE_ALL_SCHEDULES(PlanId);
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_00109';
                raise;
        END;
    END IF;

    -- update item simulation set and overwrite
    BEGIN
        MSC_WS_COMMON.UPDATE_PLAN_OPTIONS(PlanId, ItemSimulationSetId, l_Overwrite);
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00110';
            raise;
    END;

    -- set all global/local demand/supply schedules
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllSchsFlag) = MSC_UTIL.SYS_YES THEN
        BEGIN
            l_String := MSC_WS_COMMON.INSERT_ALL_SCHEDULES(
                             PlanId, l_InsId, UserId,
                             g_IGlbDmdSchTbl, g_ILocDmdSchTbl, g_ILocSupSchTbl);
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_00111';
                raise;
        END;
    ELSE
        BEGIN
            l_String := MSC_WS_COMMON.INSERT_OR_UPDATE_ALL_SCHS(
                             PlanId, l_InsId, UserId,
                             g_IGlbDmdSchTbl, g_ILocDmdSchTbl, g_ILocSupSchTbl);
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_00112';
                raise;
        END;
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

  END SET_DRP_PLAN_OPTIONS;

  PROCEDURE SET_DRP_PLAN_OPTIONS_PUBLIC (
          Status               OUT NOCOPY VARCHAR2,
          UserName               IN VARCHAR2,
  	RespName     IN VARCHAR2,
  	RespApplName IN VARCHAR2,
  	SecurityGroupName      IN VARCHAR2,
  	Language            IN VARCHAR2,
          PlanId               IN         NUMBER,
          ItemSimulationSetId  IN         NUMBER default NULL,
          Overwrite            IN         VARCHAR2 default 'All',
          PurgeAllSchsFlag     IN         VARCHAR2,
         GlobalDmdSchs        IN         MscGlbDmdSchTbl default NULL,
          LocalDmdSchs         IN         MscLocSRPDmdSchTbl default NULL,
          LocalSupSchs         IN         MscLocSupSchTbl default NULL
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
      MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFPDRP',l_SecutirtGroupId);
      -- MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MRPFPPMRSDRP',l_SecutirtGroupId);
      IF (l_String <> 'OK') THEN
         Status := l_String;
         RETURN;
      END IF;

      error_tracking_num :=2040;


    SET_DRP_PLAN_OPTIONS ( Status, userId , respid, PlanId, ItemSimulationSetId, Overwrite, PurgeAllSchsFlag, GlobalDmdSchs, LocalDmdSchs, LocalSupSchs );



        EXCEPTION
        WHEN others THEN
           status := 'ERROR_UNEXPECTED_'||error_tracking_num;

           return;


END SET_DRP_PLAN_OPTIONS_PUBLIC;

END MSC_WS_DRP;


/

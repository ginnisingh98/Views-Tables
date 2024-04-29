--------------------------------------------------------
--  DDL for Package Body MSC_WS_SRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_SRP" AS
/* $Header: MSCWSRPB.pls 120.9 2008/03/25 18:31:22 bnaghi noship $  */

g_IGlbDmdSchTbl  MscIGlbDmdSchTbl;  -- store all global demand schediles data
g_IGlbRetFcstTbl MscIGlbRetFcstTbl; -- store all global return forecasts data
g_ILocDmdSchTbl  MscILocDmdSchTbl;  -- store all local demand schediles data
g_ILocSupSchTbl  MscILocSupSchTbl;  -- store all local supply schediles data
g_ErrorCode      VARCHAR2(9);

-- =============================================================
-- Desc: Please see package spec for description
-- =============================================================
  PROCEDURE 	LAUNCH_SRP_BATCH (
                           processId          OUT NOCOPY NUMBER,
                           status             OUT NOCOPY VARCHAR2,
                           userId             IN NUMBER,
                           responsibilityId   IN NUMBER,
                           planId             IN NUMBER,
                           launchSnapshot     IN VARCHAR2,
                           launchPlanner      IN VARCHAR2,
                           netchange          IN VARCHAR2,
                           anchorDate         IN DATE,
                           archiveCurrVersPlan IN VARCHAR2,
                           enable24x7Atp      IN VARCHAR2,
                           releaseReschedules IN VARCHAR2,
                           snapStaticEntities IN VARCHAR2,
                           generateForecast   IN VARCHAR2
                          ) AS
   l_val_result              VARCHAR2(30);
   l_val_planname            VARCHAR2(10);
   l_val_launchsnapshot      NUMBER;
   l_val_launchplanner       NUMBER;
   l_val_netchange           NUMBER;
   l_val_anchordate          DATE;
   l_val_inventory_atp_flag  NUMBER;
   l_val_enable24x7atp       NUMBER;
   l_val_production          NUMBER;
   l_val_releasereschedules  NUMBER;
   l_val_snapstaticentities  NUMBER;
   l_val_orgid               NUMBER;
   l_val_instanceid          NUMBER;
   error_tracking_num        NUMBER;
   l_val_archivePlan        NUMBER;
   l_val_generateForecast    NUMBER;
   BEGIN
     error_tracking_num := 1010;

     -- validate and initialize apps
     msc_ws_common.validate_user_resp(l_val_result,   userid,   responsibilityid);

     IF(l_val_result <> 'OK') THEN
       processid := -1;
       status := l_val_result;
       RETURN;
     END IF;

     error_tracking_num := 1020;

     -- validate planId
     BEGIN
       SELECT plans.compile_designator, plans.organization_id, plans.sr_instance_id,
              desig.inventory_atp_flag, desig.production
       INTO l_val_planname,l_val_orgid,l_val_instanceid,l_val_inventory_atp_flag,
            l_val_production
       FROM  msc_plans plans, msc_designators desig
       WHERE plans.curr_plan_type in (8)
       AND   plans.organization_id = desig.organization_id
       AND   plans.sr_instance_id = desig.sr_instance_id
       AND   plans.compile_designator = desig.designator
       AND   NVL(desig.disable_date, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
       AND   NVL(plans.copy_plan_id,-1) = -1
       AND   NVL(desig.copy_designator_id, -1) = -1
       AND   plans.plan_id = planId;
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
       INTO l_val_anchordate
       FROM msc_calendar_dates dates,
         msc_trading_partners mtp
       WHERE dates.calendar_code = mtp.calendar_code
        AND dates.exception_set_id = mtp.calendar_exception_set_id
        AND mtp.sr_instance_id = dates.sr_instance_id
        AND mtp.sr_tp_id = l_val_orgid
        AND mtp.sr_instance_id = l_val_instanceid
        AND dates.calendar_date <= TRUNC(sysdate)
        AND dates.calendar_date = anchordate;

     EXCEPTION
     WHEN no_data_found THEN
       processid := -1;
       status := 'INVALID_ANCHORDATE';
       RETURN;
     END;

     error_tracking_num := 1040;
     -- validate launchSnapshot
     BEGIN
       SELECT lookup_code
       INTO   l_val_launchsnapshot
       FROM   mfg_lookups
       WHERE  lookup_type = 'MSC_LAUNCH_SNAPSHOT'
       AND    lookup_code in decode(lookup_code,1,1,2,2,3,
                       decode((select count(*) from msc_plan_schedules
                               where plan_id = planId
                               and rownum = 1
                               and designator_type = 7
                               and input_type = 1),0,1,3 ) )
       AND    lookup_code = decode(launchsnapshot,'FULL',1,'NO',2,'DP_ONLY',3,-1);

     EXCEPTION
       WHEN no_data_found THEN
         processid := -1;
         status := 'INVALID_LAUNCH_SNAPSHOT';
         RETURN;
     END;


     error_tracking_num := 1050;
     BEGIN
       SELECT lookup_code
       INTO   l_val_launchplanner
       FROM   MFG_LOOKUPS
       WHERE  lookup_type = 'SYS_YES_NO'
       AND    ((lookup_code = 1 AND l_val_launchsnapshot in (1,3,4)) OR
               (l_val_launchsnapshot = 2))
       AND    lookup_code = decode(launchplanner, 'Y', msc_ws_common.sys_yes, msc_ws_common.sys_no);

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
     -- populating PLAN_TYPE_DUMMY hidden parameter
     -- Original default logic is "SELECT inventory_atp_flag from msc_designators d where
     --   d.designator = (SELECT compile_designator from msc_plans p where
     --   p.plan_id=:$FLEX$.MSC_SRS_SCP_NAME_LAUNCH) and d.inventory_atp_flag = 1"
     -- Which pretty much meant this flag is set to either NULL or 1
     IF (l_val_inventory_atp_flag  <> 1)
     THEN l_val_inventory_atp_flag := NULL;
     END IF;


     error_tracking_num := 1060;
    -- validating enable24x7atp
     BEGIN
       SELECT lookup_code
       INTO   l_val_enable24x7atp
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
     -- Similar default logic as l_val_inventory_atp_flag, "SELECT production from msc_designators d
     -- where d.designator = (SELECT compile_designator from msc_plans p where p.plan_id =
     -- :$FLEX$.MSC_SRS_SCP_NAME_LAUNCH)  and d.production = 1"
     IF (l_val_production  <> 1)
     THEN l_val_production := NULL;
     END IF;

     error_tracking_num := 1070;
     -- validating releasereschedules
     BEGIN
       SELECT lookup_code
       INTO   l_val_releasereschedules
       FROM   MFG_LOOKUPS
       WHERE  lookup_type='SYS_YES_NO'
       AND    (NVL(l_val_production,2)=1  or lookup_code=2)
       AND    lookup_code = decode(releasereschedules,'Y',msc_ws_common.sys_yes, msc_ws_common.sys_no);
     EXCEPTION
       WHEN no_data_found THEN
         processid := -1;
         status := 'INVALID_RELEASE_RESCHEDULES';
         RETURN;
     END;

 BEGIN
        SELECT lookup_code
        INTO   l_val_generateForecast
        FROM   MFG_LOOKUPS
        where lookup_type = 'SYS_YES_NO'
        AND ( (l_val_launchplanner = 1 and lookup_code in (1,2)  )  OR
                  (l_val_launchplanner = 2 and lookup_code in   (1)     ) )
        AND    lookup_code = decode(generateForecast, 'Y', msc_ws_common.sys_yes, msc_ws_common.sys_no);

     EXCEPTION  WHEN no_data_found THEN
         processid := -1;
         status := 'INVALID_GENERATE_FORECAST';
         RETURN;
     END;
     error_tracking_num := 1080;
     -- snapstaticentities, netchange, can be either Y or N, converted to 1 or 2
     BEGIN
       SELECT to_number(decode(snapstaticentities,   'Y',   msc_ws_common.sys_yes,   msc_ws_common.sys_no))
       INTO l_val_snapstaticentities
       FROM dual;

       SELECT to_number(decode(netchange,   'Y',   msc_ws_common.sys_yes,   msc_ws_common.sys_no))
       INTO l_val_netchange
       FROM dual;
     END;

     processid := fnd_request.submit_request(
                             'MSC',                     -- application
                             'MSCSLPPR7',               -- program
                             NULL,                      -- description
                             NULL,                      -- start_time
                             FALSE,                     -- sub_request
                             l_val_planname,
                             planId,
                             l_val_launchsnapshot,
                             l_val_launchplanner,
                             l_val_netchange,
                             to_char(l_val_anchordate, 'YYYY/MM/DD HH24:MI:SS'),
                             l_val_archivePlan,
                             l_val_inventory_atp_flag,  -- plan_type_dummy param
                             l_val_enable24x7atp,
                             l_val_production,          -- rescheduleDummy VARCHAR2
                             l_val_releasereschedules,  --release
                             l_val_snapstaticentities,   -- snapStaticEntities
                             NULL, -- calculate Liability dummy 1
                             NULL,  -- calculate liability dummy 2
                             l_val_generateForecast --tTBD VALIDATION
                            );

      IF(processid = 0) THEN
       processid := -1;
       status := 'ERROR_SUBMIT';
       RETURN;
     END IF;

     status := 'SUCCESS';

   EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;
         processId := -1;
         return;
   END LAUNCH_SRP_BATCH;

   PROCEDURE 	LAUNCH_SRP_BATCH_PUBLIC (
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
                                      netchange          IN VARCHAR2,
   			                             anchorDate             IN DATE,
                                 archiveCurrVersPlan IN VARCHAR2,
   			                             enable24x7Atp          IN VARCHAR2,
   			                             releaseReschedules     IN VARCHAR2,
                                 snapStaticEntities IN VARCHAR2,
                                 generateForecast   IN VARCHAR2
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

       MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFNSCW-SRP',l_SecutirtGroupId);
      IF (l_String <> 'OK') THEN
       MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFPCMN-SRP', l_SecutirtGroupId);
          IF (l_String <> 'OK') THEN
          MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_ORG_FNDRSRUN_LAUNCH_SRP',l_SecutirtGroupId);
          IF (l_String <> 'OK') THEN
          Status := l_String;
          RETURN;
       END IF;
       END IF;
       END IF;
       error_tracking_num :=2040;
      LAUNCH_SRP_BATCH ( processId, status, userId ,respid, planId , launchSnapshot ,launchPlanner, netchange, anchorDate , archiveCurrVersPlan,  enable24x7Atp, releaseReschedules,snapStaticEntities,generateForecast );

      --      dbms_output.put_line('USERID=' || userid);


         EXCEPTION
         WHEN others THEN
            status := 'ERROR_UNEXPECTED_'||error_tracking_num;
            processId := -1;
            return;
END LAUNCH_SRP_BATCH_PUBLIC;



-- =============================================================
-- Desc: Please see package spec for description
-- =============================================================
   PROCEDURE RELEASE_SRP  (  req_id              OUT NOCOPY REQTBLTYP,
                               status              OUT NOCOPY VARCHAR2,
                               userId              IN NUMBER,
                               responsibilityId    IN NUMBER,
                               planId              IN NUMBER,
                               release_time_fence_anchor_date IN VARCHAR2
                              ) AS
         error_tracking_num       NUMBER;
         l_val_result             VARCHAR2(30);
         l_val_planid             NUMBER;
         l_val_planname           VARCHAR2(10);
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
         INTO l_val_planname
         FROM  msc_plans plans, msc_designators desig
         WHERE plans.curr_plan_type in (8)
         AND   plans.organization_id = desig.organization_id
         AND   plans.sr_instance_id = desig.sr_instance_id
         AND   plans.compile_designator = desig.designator
         AND   NVL(desig.disable_date, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
         AND   NVL(plans.copy_plan_id,-1) = -1
         AND   NVL(desig.copy_designator_id, -1) = -1
         AND   plans.plan_id = planId;
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

   END RELEASE_SRP;

PROCEDURE RELEASE_SRP_PUBLIC (   req_id              OUT NOCOPY  REQTBLTYP,
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
     MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFNSCW-SRP', l_SecutirtGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
    error_tracking_num :=2040;

   RELEASE_SRP (  req_id  , status, userId ,respid, planId , release_time_fence_anchor_date );


      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;
END  RELEASE_SRP_PUBLIC;




-- =============================================================
--
-- SET_DRP_PLAN_OPTIONS and its private helper functions.
--
-- Un-handled exceptions generate error tokens in the
-- format of ERROR_UNEXPECTED_#####.
-- The possible values are:
--   00201 - SET_SRP_PLAN_OPTIONS/MSC_WS_COMMON.VALIDATE_PLAN_ID
--   00202 - SET_SRP_PLAN_OPTIONS/VALIDATE_PLAN_TYPE
--   00203 - SET_SRP_PLAN_OPTIONS/MSC_WS_COMMON.VALIDATE_SIMULATION_SET_ID
--   00204 - SET_SRP_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/VALIDATE_G_DMD_SCH_ID
--   00205 - SET_SRP_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/VALIDATE_CONSUM_LVL (goe)
--   00206 - SET_SRP_PLAN_OPTIONS/VALIDATE_GLB_DMD_SCHS/VALIDATE_G_RET_FCST_ID
--   00207 - SET_SRP_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/MSC_WS_COMMON.PLAN_CONTAINS_THIS_ORG
--   00208 - SET_SRP_PLAN_OPTIONS/VALIDATE_LOC_DMD_SCHS/VALIDATE_L_DMD_SCH_ID
--   00209 - SET_SRP_PLAN_OPTIONS/VALIDATE_LOC_SUP_SCHS/VALIDATE_L_SUP_SCH_ID
--   00210 - SET_SRP_PLAN_OPTIONS/MSC_WS_COMMON.PURGE_ALL_SCHEDULES
--   00211 - SET_SRP_PLAN_OPTIONS/UPDATE_PLAN_OPTIONS
--   00212 - SET_SRP_PLAN_OPTIONS/INSERT_ALL_SCHEDULES/MSC_WS_COMMON.INSERT_ALL_SCHEDULES
--   00213 - SET_SRP_PLAN_OPTIONS/INSERT_ALL_SCHEDULES/INSERT_G_MAN_FCST
--   00214 - SET_SRP_PLAN_OPTIONS/INSERT_OR_UPDATE_ALL_SCHS/MSC_WS_COMMON.INSERT_OR_UPDATE_ALL_SCHS
-- =============================================================


-- =============================================================
-- Desc: Validate plan id, copy the where clause from LAUNCH_SRP_BATCH
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
            NVL(plans.copy_plan_id,-1) = -1 AND
            NVL(desig.copy_designator_id, -1) = -1 AND
            plans.plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLANID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00201';
            raise;
    END;

    RETURN 'OK';
END VALIDATE_PLAN_ID;

-- =============================================================
-- Desc: Validate plan type is SRP
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
            curr_plan_type = 8 AND
            plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLAN_TYPE';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00202';
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
                        g_ErrorCode := 'ERROR_UNEXPECTED_00204';
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
                        g_ErrorCode := 'ERROR_UNEXPECTED_00205';
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
-- Desc: validate global return forecast schedules
-- Input:
--       SchId                 Global return forecast id.
--       PlanName              Plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_GLOBALRETFCST_RET_FCST_ID
-- =============================================================
FUNCTION VALIDATE_G_RET_FCST_ID(
        InsId              OUT NOCOPY NUMBER,
        SchId              IN         NUMBER,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT
            sr_instance_id INTO InsId
        FROM
            msd_dp_ascp_scenarios_v
        WHERE
            scenario_name <> PlanName AND
            last_revision IS NOT NULL AND
            scenario_id = SchId AND
            global_scenario_flag = 'Y';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_GLOBALRETFCST_RET_FCST_ID';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00206';
            raise;
    END;
    RETURN 'OK';
END VALIDATE_G_RET_FCST_ID;


-- =============================================================
-- Desc: validate global return forecast schedules
-- Input:
--       SchTable              Global return forecast schedules
--       PlanName              Plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_GLOBALRETFCST_RET_FCST_ID
-- =============================================================
FUNCTION VALIDATE_GLB_RET_FCST(
        SchTable           IN         MscGlbReturnFcstTbl,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2 AS
l_String          VARCHAR2(100);
l_InsId           NUMBER;
BEGIN
    IF SchTable IS NOT NULL AND SchTable.count > 0 THEN
        FOR I IN SchTable.first..SchTable.last
            LOOP
                -- validate return forecast id
                l_String := VALIDATE_G_RET_FCST_ID(l_InsId, SchTable(I), PlanName);
                IF (l_String <> 'OK') THEN
                    RETURN l_String;
                END IF;

                g_IGlbRetFcstTbl.extend;
                g_IGlbRetFcstTbl(g_IGlbRetFcstTbl.count) :=
                     MscIGlbRetFcstRec(SchTable(I),
                                   l_InsId,
                                   -99, -- input_type
                                   9  -- designator_type
                                   );
            END LOOP;
    END IF;

    RETURN 'OK';
END;

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
-- <RL: if you are only selecting from desig table, then you can get rid of
--  lu join.  The join is an outer join and will not do any filtering >
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
            ( (desig.designator_type = 6 AND desig.forecast_set_id is null) OR
              (desig.designator_type IN (5,8)) ) AND
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
            (sr_instance_id = InsId or sr_instance_id = -23453) AND
            scenario_id = SchId AND
            global_scenario_flag = 'N' AND
            last_revision IS NOT NULL
        UNION
        SELECT
            desig.designator_type,
            decode(desig.designator_type,  6, desig.update_type, -1)
        FROM
            msc_designators desig,
            msc_plan_organizations_v mpo,
            fnd_lookups lu
        WHERE
            ( (desig.designator_type = 6 AND desig.forecast_set_id IS NULL) OR
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
            decode(desig.designator_type,  6, desig.update_type, -1)
        FROM
            msc_designators desig,
            msc_item_sourcing mis,
            msc_plans mp,
            fnd_lookups lu
        WHERE
            ( (desig.designator_type = 6 AND desig.forecast_set_id IS NULL) OR
              (desig.designator_type IN (5,8)) ) AND
            trunc(nvl(desig.disable_date, trunc(sysdate) + 1)) > trunc(sysdate) AND
            mis.plan_id = mp.plan_id AND
            mp.organization_id = desig.organization_id AND
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
            g_ErrorCode := 'ERROR_UNEXPECTED_00208';
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
                        g_ErrorCode := 'ERROR_UNEXPECTED_00207';
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
                    l_ReturnString := MSC_WS_COMMON.VALIDATE_CONSUM_LVL(
                                      SchTable(I).ShipToConsumptionLvl,
                                      SchTable(I).DmdSchId);
                    IF (l_ReturnString <> 'OK') THEN
                        RETURN 'INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL';
                    END IF;
                    l_ShipTo := SchTable(I).ShipToConsumptionLvl;
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
-- Desc: update item simulation set, update overwrite supplies and nanual forecast
--
-- Input:
--       PlanId                Id of the plan.
--       ItemSimulationSetId   Id of the item simulation set.
--       Overwrite             Overwrite.
--
-- Output: No output.
-- =============================================================
FUNCTION UPDATE_PLAN_OPTIONS(
        PlanId              IN         NUMBER,
        ItemSimulationSetId IN         NUMBER,
        OverwriteSup        IN         NUMBER,
        OverwriteManualFcst IN         NUMBER
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        UPDATE msc_plans
        SET
            item_simulation_set_id = ItemSimulationSetId,
            curr_overwrite_option = OverwriteSup,
            manual_fcst_overwrite_option =OverwriteManualFcst
        WHERE
            plan_id = PlanId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00211';
            raise;
    END;

    RETURN 'OK';
END UPDATE_PLAN_OPTIONS;

-- =============================================================
-- Desc: Insert a global manual forecast
--
-- Input:
--       PlanId                Id of the plan.
--       UserId                user id,
--       FcstRec               global manual forecast data.
--
-- Output: No output.
-- =============================================================
FUNCTION INSERT_G_MAN_FCST(
        PlanId              IN         NUMBER,
        UserId              IN         NUMBER,
        FcstRec             IN         MscIGlbRetFcstRec
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        INSERT INTO msc_plan_schedules
            (
            plan_id, organization_id, input_schedule_id, sr_instance_id,
            input_type, last_update_date, last_updated_by,
            creation_date, created_by, designator_type
            )
        VALUES
            (
            PlanId, -1, FcstRec.FcstId, FcstRec.InsId,
            FcstRec.input_type, sysdate, UserId,
            sysdate, UserId, FcstRec.designator_type
            ) ;
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            RETURN 'ERROR_DUP_GLOBALMANFCST';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00213';
            raise;
    END;

    RETURN 'OK';
END INSERT_G_MAN_FCST;

-- =============================================================
-- Desc: this function is call when the PurgeAllSchsFlag is set,
--       insert all schedules, including global demand schediles,
--       global return forecasts, local demand schedules and
--       local supply schedules for this plan
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       GlbDmdSchs            global demand schedules
--       GlbManFcsta           global manual forecast
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
        GlbManFcsts         IN         MscIGlbRetFcstTbl,
        LocDmdSchs          IN         MscILocDmdSchTbl,
        LocSupSchs          IN         MscILocSupSchTbl
) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
BEGIN
    -- insert all global demand schedules, local
    -- demand schedules and local supply schedules
    BEGIN
        l_ReturnString:= MSC_WS_COMMON.INSERT_ALL_SCHEDULES(
                             PlanId, InsId, UserId,
                             g_IGlbDmdSchTbl, g_ILocDmdSchTbl, g_ILocSupSchTbl);
        IF (l_ReturnString <> 'OK') THEN
            RETURN l_ReturnString;
        END IF;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00212';
            raise;
    END;

    -- insert global manual forecasts
    IF GlbManFcsts.COUNT > 0 THEN
        FOR I IN GlbManFcsts.first..GlbManFcsts.last
            LOOP
                l_ReturnString:= INSERT_G_MAN_FCST(PlanId, UserId, GlbManFcsts(I));
                IF (l_ReturnString <> 'OK') THEN
                    RETURN l_ReturnString;
                 END IF;
            END LOOP;
    END IF;

    RETURN 'OK';
END INSERT_ALL_SCHEDULES;

-- =============================================================
-- Desc: this function is call when the PurgeAllSchsFlag is not set,
--       insert or update all schedules, including global demand
--       schediles, global return forecasts, local demand
--       schedules and local supply schedules for this plan
--
-- Input:
--       PlanId                Id of the plan.
--       InsId                 Sr instance id.
--       UserId                user id,
--       GlbDmdSchs            global demand schedules
--       GlbManFcsta           global manual forecast
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
        GlbManFcsts         IN         MscIGlbRetFcstTbl,
        LocDmdSchs          IN         MscILocDmdSchTbl,
        LocSupSchs          IN         MscILocSupSchTbl
) RETURN VARCHAR2 AS
l_ReturnString    VARCHAR2(100);
l_Dummy           NUMBER;
BEGIN
    -- insert/update all global demand schedules, local
    -- demand schedules and local supply schedules
    BEGIN
        l_ReturnString := MSC_WS_COMMON.INSERT_OR_UPDATE_ALL_SCHS(
                             PlanId, InsId, UserId,
                             g_IGlbDmdSchTbl, g_ILocDmdSchTbl, g_ILocSupSchTbl);
        IF (l_ReturnString <> 'OK') THEN
            RETURN l_ReturnString;
        END IF;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_00214';
            raise;
    END;

    -- insert/update all global manual forecasts
    IF GlbManFcsts.COUNT > 0 THEN
        FOR I IN GlbManFcsts.first..GlbManFcsts.last
            LOOP
                BEGIN
                    Select count(*) INTO l_Dummy
                    FROM   msc_plan_schedules
                    WHERE
                        plan_id = PlanId AND
                        organization_id = -1 AND
                        sr_instance_id = GlbManFcsts(I).InsId AND
                        input_schedule_id  = GlbManFcsts(I).FcstId;
                    EXCEPTION WHEN others THEN
                        raise;
                END;
                IF l_Dummy = 0 THEN
                    l_ReturnString := INSERT_G_MAN_FCST(PlanId, UserId, GlbManFcsts(I));
                    IF (l_ReturnString <> 'OK') THEN
                        RETURN l_ReturnString;
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
-- Desc: This procedure is invoked from web service to
--       updates Plan Options for SRP plans.
-- Input:
--        UserId            User ID.
--        ResponsibilityId  Responsibility Id.
--        PlanId            Plan Id.
--        ItemSimulationSet Item Simulation Set.
--        OverwriteSup      Overwrite Supplies. Expected values are All,
--                          Outside PTF or None.
--        OverwriteManualFcst
--                          Overwrite Manual Forecast. Expected values
--                          are All, Outside PTF or None.
--        PurgeAllSchsFlag  There is no such parameter in UI. Allowed
--                          input is Y or N. This is a new parameter
--                          to control how Global Demand Schedules, Global
--                          Return Forecast, Local Demand Schedules and
--                          Local Supply Schedules are updated / inserted.
--                          If this flag is set, all Global Demand
--                          Schedules, Global Return Forecast, Local Demand
--                          Schedules and Local Supply Schedule will be purged
--                          before update / insert any demand / supply
--                          schedules an d return forecast from
--                          the input parameters. If this flag is not set, no
--                          demand / supple schedules will be purged, schedules in
--                          the input parameters will be updated or inserted.
--        GlobalDmdSchs	    Global Demand Schedules. Each demand schedule contains
--                          the schedule id and ship to consumption level parameters.
--                          Although this is not a required parameter, we need both
--                          id and ShpToConsumptionLvl to define a demand schedule,
--                          so either both parameters are empty or both are entered.
--        GlobalReturnFcst  Global Return Forecasts. Each global return forecast contains
--                          the schedule id.
--        LocalDmdSchs      Local Demand Schedules. List of all local demand schedules.
--                          Each local demand schedule contains the organization id,
--                          demand schedule name, include target demands, ship to
--                          consumption level and inter plant demand flag. Similar to
--                          Global Demand Schedules, these five parameters have to be
--                          either all empty or all entered.
--        LocalSupSchs      Supply Schedules.List of local supply schedules. Each local
--                          supply schedule contains the organization id and supply
--                          schedule name. Similar to Global Demand Schedules, these
--                          two parameters have to be either both empty or both entered
--
-- Output: Procedure returns a status and conc program req id.
--       The possible return statuses are:
--          SUCCESS if everything is ok
--          ERROR_DUP_GLOBALDMDSCH
--          ERROR_DUP_GLOBALMANFCST
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
--          INVALID_GLOBALRETFCST_RET_FCST_ID
--          INVALID_LOCALDMDSCHS_ORGID
--          INVALID_LOCALDMDSCHS_DMD_SCH_ID
--          INVALID_LOCALDMDSCHS_SHP_TO_CONSUMPTION_LVL
--          INVALID_LOCALSUPSCHS_ORGID
--          INVALID_LOCALSUPSCHS_SUP_SCH_NAME
-- =============================================================
PROCEDURE SET_SRP_PLAN_OPTIONS (
        Status               OUT NOCOPY VARCHAR2,
        UserId               IN         NUMBER,
        ResponsibilityId     IN         NUMBER,
        PlanId               IN         NUMBER,
        ItemSimulationSetId  IN         NUMBER default NULL,
        OverwriteSup         IN         VARCHAR2 default 'All',
        OverwriteManualFcst  IN         VARCHAR2 default 'All',
        PurgeAllSchsFlag     IN         VARCHAR2,
        GlobalDmdSchs        IN         MscGlbDmdSchTbl default NULL,
        GlobalReturnFcst     IN         MscGlbReturnFcstTbl default NULL,
        LocalDmdSchs         IN         MscLocSRPDmdSchTbl default NULL,
        LocalSupSchs         IN         MscLocSupSchTbl default NULL
        ) AS
l_String               VARCHAR2(100);
l_OrgId                NUMBER;
l_InsId                NUMBER;
l_PlanName             VARCHAR2(10);
l_OverwriteSup         NUMBER;
l_OverwriteManualFcst  NUMBER;
    BEGIN
-- dbms_output.put_line('Matthew: Init');

    -- init global variables
    g_IGlbDmdSchTbl  := MscIGlbDmdSchTbl();
    g_IGlbRetFcstTbl := MscIGlbRetFcstTbl();
    g_ILocDmdSchTbl  := MscILocDmdSchTbl();
    g_ILocSupSchTbl  := MscILocSupSchTbl();


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
            g_ErrorCode := 'ERROR_UNEXPECTED_00203';
            raise;
    END;

    l_OverwriteSup := MSC_WS_COMMON.CONVERT_OVERWRITE(OverwriteSup);
    l_OverwriteManualFcst := MSC_WS_COMMON.CONVERT_OVERWRITE(OverwriteManualFcst);

    -- validate global demand schedules
    l_String := VALIDATE_GLB_DMD_SCHS(GlobalDmdSchs, l_PlanName);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- validate global return forecast schedules
    l_String := VALIDATE_GLB_RET_FCST(GlobalReturnFcst, l_PlanName);
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
            g_ErrorCode := 'ERROR_UNEXPECTED_00209';
            raise;
    END;

    -- if PurgeAllSchsFlag is set, purge all global demand schedules,
    -- local demand schedule and local supply schedules
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllSchsFlag) = MSC_UTIL.SYS_YES THEN
        BEGIN
            MSC_WS_COMMON.PURGE_ALL_SCHEDULES(PlanId);
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_00210';
                raise;
        END;
    END IF;

    -- update item simulation set, overwrite supplies and overwrite manual forecast,
    l_String := UPDATE_PLAN_OPTIONS(PlanId, ItemSimulationSetId, l_OverwriteSup, l_OverwriteManualFcst);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- set all global/local demand/supply schedules
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllSchsFlag) = MSC_UTIL.SYS_YES THEN
        l_String := INSERT_ALL_SCHEDULES(
                             PlanId, l_InsId, UserId,
                             g_IGlbDmdSchTbl, g_IGlbRetFcstTbl, g_ILocDmdSchTbl, g_ILocSupSchTbl);
    ELSE
        l_String := INSERT_OR_UPDATE_ALL_SCHS(
                             PlanId, l_InsId, UserId,
                             g_IGlbDmdSchTbl, g_IGlbRetFcstTbl, g_ILocDmdSchTbl, g_ILocSupSchTbl);
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

    END SET_SRP_PLAN_OPTIONS;

  PROCEDURE SET_SRP_PLAN_OPTIONS_PUBLIC (
        Status               OUT NOCOPY VARCHAR2,
        UserName               IN VARCHAR2,
	      RespName     IN VARCHAR2,
	      RespApplName IN VARCHAR2,
	      SecurityGroupName      IN VARCHAR2,
	      Language            IN VARCHAR2,
        PlanId               IN         NUMBER,
        ItemSimulationSetId  IN         NUMBER default NULL,
        OverwriteSup         IN         VARCHAR2 default 'All',
        OverwriteManualFcst  IN         VARCHAR2 default 'All',
        PurgeAllSchsFlag     IN         VARCHAR2,
        GlobalDmdSchs        IN         MscGlbDmdSchTbl default NULL,
        GlobalReturnFcst     IN         MscGlbReturnFcstTbl default NULL,
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
     MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSCFPPMR-SRP',l_SecutirtGroupId);
    IF (l_String <> 'OK') THEN
       Status := l_String;
        RETURN;
    END IF;
    error_tracking_num :=2040;


  SET_SRP_PLAN_OPTIONS ( Status, userId , respid,
                    PlanId ,
        ItemSimulationSetId ,
        OverwriteSup,
        OverwriteManualFcst ,
        PurgeAllSchsFlag,
        GlobalDmdSchs,
        GlobalReturnFcst,
        LocalDmdSchs,
        LocalSupSchs );
   --      dbms_output.put_line('USERID=' || userid);


      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;


END SET_SRP_PLAN_OPTIONS_PUBLIC;


END MSC_WS_SRP;


/

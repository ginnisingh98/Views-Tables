--------------------------------------------------------
--  DDL for Package MSC_WS_DRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_DRP" AUTHID CURRENT_USER AS
/* $Header: MSCWDRPS.pls 120.4 2008/03/20 15:56:23 bnaghi noship $ */


  -- =============================================================
  -- Desc: This procedure is invoke from web services to launch
  --       DRP plan.  It mirrors all the parameters from the Launch
  --       Plan concurrent program.  Some of the child programs
  --       that gets launched include  Memory-Based Snapshot,
  --       Snapshot Monitor, Snapshot Delete Worker,
  --       Memory-Based Snapshot Worker, Loader Worker With Direct Load Option,
  --       Memory-Based Planner, Post Plan Program for UI,
  --       Refresh One KPI Summary Table   The procedure returns
  --       a status and concurrent program request id.
  -- Input: enable24x7Atp, can conditionally be
  --              YES_PURGE - Yes , purge current plan after switch plan
  --              NO - No
  --              YES_NOPURGE - Yes , do not purge current plan after switch plan
  --        launchPlanner, launchSnapshot, releaseReschedules
  --        can be conditionally be Y or N
  -- Output:  possible output status value include following
  --       INVALID_PLANID, INVALID_ANCHORDATE, INVALID_LAUNCH_PLANNER,
  --       INVALID_ENABLE24X7ATP, INVALID_RELEASE_RESCHEDULES,
  --       INVALID_FND_USERID, INVALID_FND_RESP
  -- =============================================================
   PROCEDURE 	LAUNCH_DRP_BATCH (
                          processId            OUT NOCOPY NUMBER,
                          status               OUT NOCOPY VARCHAR2,
                          userId               IN NUMBER,
                          responsibilityId     IN NUMBER,
                          planId               IN NUMBER,
                          launchSnapshot       IN VARCHAR2,
                          launchPlanner        IN VARCHAR2,
                          anchorDate           IN DATE,
                          archiveCurrVersPlan IN VARCHAR2,
                          enable24x7Atp        IN VARCHAR2 ,
                          releaseReschedules   IN VARCHAR2 );

    -- =============================================================
  -- Desc: This procedure is invoke from web services to launch
  --       DRP plan.  It mirrors all the parameters from the Launch
  --       Plan concurrent program.  Some of the child programs
  --       that gets launched include  Memory-Based Snapshot,
  --       Snapshot Monitor, Snapshot Delete Worker,
  --       Memory-Based Snapshot Worker, Loader Worker With Direct Load Option,
  --       Memory-Based Planner, Post Plan Program for UI,
  --       Refresh One KPI Summary Table   The procedure returns
  --       a status and concurrent program request id.
  -- Input: enable24x7Atp, can conditionally be
  --              YES_PURGE - Yes , purge current plan after switch plan
  --              NO - No
  --              YES_NOPURGE - Yes , do not purge current plan after switch plan
  --        launchPlanner, launchSnapshot, releaseReschedules
  --        can be conditionally be Y or N
  -- Output:  possible output status value include following
  --       INVALID_PLANID, INVALID_ANCHORDATE, INVALID_LAUNCH_PLANNER,
  --       INVALID_ENABLE24X7ATP, INVALID_RELEASE_RESCHEDULES,
  --       INVALID_USER_NAME, INVALID_RESP_NAME
  --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
  -- =============================================================
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

                          ) ;

-- =============================================================
  -- Desc: This procedure is invoke from web services to release PO
  --       for a pecified plan id
  -- Input:  release_time_fence_anchor_date - value can be PLAN_START_DATE ans CURRENT_DATE
  --
  -- Output:  possible output status value include following
  --          INVALID_PLANID, INVALID_RELEASE_TIME_FENCE_ANCHOR_DATE,
  --
  --          INVALID_USERID, INVALID_RESP
  -- =============================================================

PROCEDURE RELEASE_DRP (    req_id              OUT NOCOPY  REQTBLTYP,
                            status              OUT NOCOPY VARCHAR2,
                            userId              IN NUMBER,
                            responsibilityId    IN NUMBER,
                            planId              IN NUMBER,
                            release_time_fence_anchor_date IN VARCHAR2
                          ) ;

  -- =============================================================
  -- Desc: This procedure is invoke from web services to release PO
  --       for a pecified plan id
  -- Input:  release_time_fence_anchor_date - value can be PLAN_START_DATE ans CURRENT_DATE
  --
  -- Output:  possible output status value include following
  --          INVALID_PLANID, INVALID_RELEASE_TIME_FENCE_ANCHOR_DATE,
  --
  --         INVALID_USER_NAME, INVALID_RESP_NAME
  --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
  -- =============================================================



PROCEDURE RELEASE_DRP_PUBLIC (   req_id              OUT NOCOPY  REQTBLTYP,
                            status              OUT NOCOPY VARCHAR2,
                            UserName               IN VARCHAR2,
			    RespName     IN VARCHAR2,
			    RespApplName IN VARCHAR2,
			    SecurityGroupName      IN VARCHAR2,
			    Language            IN VARCHAR2,
                            planId              IN NUMBER,
                            release_time_fence_anchor_date IN VARCHAR2
                          ) ;


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
--                          either all empty or all entered.
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
        );


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
--                          either all empty or all entered.
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
--          INVALID_USER_NAME, INVALID_RESP_NAME
--          INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
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
        );

END MSC_WS_DRP;


/

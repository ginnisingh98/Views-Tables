--------------------------------------------------------
--  DDL for Package MSC_WS_IO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_IO" AUTHID CURRENT_USER AS
/* $Header: MSCWIOPS.pls 120.3 2008/03/20 15:57:28 bnaghi noship $  */

  -- =============================================================
  -- Desc: This procedure is invoke from web services to launch
  --       IO plan.  It mirrors all the parameters from the
  --       Launch Inventory Planning Process conc prog.  The procedure
  --       returns a status and concurrent program request id.
  -- Output:  possible output status value include following
  --       INVALID_PLANID, INVALID_ANCHORDATE,
  --       INVALID_FND_USERID, INVALID_FND_RESP, ERROR_UNEXPECTED
  -- =============================================================
PROCEDURE  LAUNCH_IO_BATCH (
                   processId                OUT NOCOPY NUMBER,
                   status                   OUT NOCOPY VARCHAR2,
                   userId                   IN  NUMBER,
                   responsibilityId         IN  NUMBER,
                   planId                   IN  NUMBER,
                   anchorDate               IN  DATE,
                    archiveCurrVersPlan IN VARCHAR2) ;

-- =============================================================
  -- Desc: This procedure is invoke from web services to launch
  --       IO plan.  It mirrors all the parameters from the
  --       Launch Inventory Planning Process conc prog.  The procedure
  --       returns a status and concurrent program request id.
  -- Output:  possible output status value include following
  --       INVALID_PLANID, INVALID_ANCHORDATE,
  --       INVALID_FND_USERID, INVALID_USER_NAME, INVALID_RESP_NAME
  --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
  -- =============================================================

PROCEDURE  LAUNCH_IO_BATCH_PUBLIC (
                   processId              OUT NOCOPY NUMBER,
		   status                 OUT NOCOPY VARCHAR2,
		   UserName               IN VARCHAR2,
		   RespName     IN VARCHAR2,
		   RespApplName IN VARCHAR2,
		   SecurityGroupName      IN VARCHAR2,
		   Language            IN VARCHAR2,
                   planId                   IN  NUMBER,
                   anchorDate               IN  DATE ,
                   archiveCurrVersPlan IN VARCHAR2) ;



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
PROCEDURE SET_IO_PLAN_OPTIONS (
        Status               OUT NOCOPY VARCHAR2,
        UserId               IN         NUMBER,
        ResponsibilityId     IN         NUMBER,
        PlanId               IN         NUMBER,
        ItemSimulationSetId  IN         NUMBER default NULL,
        ServiceLvlSetId      IN         NUMBER default NULL,
        PurgeAllSchsFlag     IN         VARCHAR2,
        GlobalDmdSchs        IN         MscGlbIODmdSchTbl default NULL,
        LocalDmdSchs         IN         MscLocIODmdSchTbl default NULL
        );


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
--          INVALID_USER_NAME, INVALID_RESP_NAME
--       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
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

PROCEDURE SET_IO_PLAN_OPTIONS_PUBLIC (
      	status               OUT 	NOCOPY VARCHAR2,
	UserName             IN 	VARCHAR2,
	RespName     	     IN 	VARCHAR2,
	RespApplName 	     IN 	VARCHAR2,
	SecurityGroupName    IN 	VARCHAR2,
	Language             IN 	VARCHAR2,
        PlanId               IN         NUMBER,
        ItemSimulationSetId  IN         NUMBER default NULL,
        ServiceLvlSetId      IN         NUMBER default NULL,
        PurgeAllSchsFlag     IN         VARCHAR2,
        GlobalDmdSchs        IN         MscGlbIODmdSchTbl default NULL,
        LocalDmdSchs         IN         MscLocIODmdSchTbl default NULL
        );

END MSC_WS_IO;

/

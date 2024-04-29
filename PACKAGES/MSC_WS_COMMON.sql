--------------------------------------------------------
--  DDL for Package MSC_WS_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_COMMON" AUTHID CURRENT_USER AS
/* $Header: MSCWCOMS.pls 120.4 2008/03/12 01:21:00 bnaghi noship $ */

     SYS_YES CONSTANT NUMBER := 1;
     SYS_NO CONSTANT NUMBER := 2;
      PROCEDURE  VALIDATE_USER_RESP(
                     VRETURN            OUT NOCOPY VARCHAR2,
                     USERID             IN         NUMBER,
                     RESPID             IN         NUMBER,
                     SECURITYID         IN         NUMBER    DEFAULT 0) ;
      PROCEDURE  VALIDATE_USER_RESP_FUNC(
                                        VRETURN OUT NOCOPY VARCHAR2,
                                        USERID IN  NUMBER,
                                        RESPID  IN NUMBER,
                                        FUNC_NAME    IN VARCHAR2,
                                  SECURITYID         IN         NUMBER);
      -- query user id, responsibility id and security group id.
      PROCEDURE  GET_PERMISSION_IDS(
                     Status             OUT NOCOPY VARCHAR2,
                     UserId             OUT NOCOPY NUMBER,
                     ResponsibilityId   OUT NOCOPY NUMBER,
                     SecurityGroupId    OUT NOCOPY NUMBER,
                     UserName           IN         VARCHAR2,
                     RespName           IN         VARCHAR2,
                     RespAppName        IN         VARCHAR2,
                     SecurityGroupName  IN         VARCHAR2,
                     Language           IN         VARCHAR2);

      -- get plan name from Plan Id
      FUNCTION GET_PLAN_NAME_BY_PLAN_ID(Status OUT NOCOPY VARCHAR2, PlanId IN NUMBER) RETURN BOOLEAN;

      -- conversion of Y/N to SYS_YES/ SYS_NO
      FUNCTION Bool_to_Number( flag IN varchar2) RETURN number;

      FUNCTION get_cat_set_id(arg_plan_id number) RETURN NUMBER;

-- =============================================================
--    The following functions are declared here to make them as
--    public is because they are re-used by Set Plan Options for
--    DRP, SRP and IO plans.
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
        ) RETURN VARCHAR2;

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
        ) RETURN VARCHAR2;

-- =============================================================
-- Desc: Validate item simulation set id.
-- Input:
--       SetId             Simulation set Id.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_SIMULATION_SET_ID
-- =============================================================
FUNCTION VALIDATE_SIMULATION_SET_ID( SetId IN  NUMBER ) RETURN VARCHAR2;

-- =============================================================
-- Desc: Purge all schedules, including global demand schediles,
--       local demand schedules and local supply schedules for this plan.
-- Input:
--       PlanId            Plan Id.
--
-- Output: No output.
-- =============================================================
PROCEDURE PURGE_ALL_SCHEDULES(PlanId IN NUMBER);

-- =============================================================
-- Desc: Update item simulation set and overwrite.
-- Input:
--       PlanId                Plan Id.
--       ItemSimulationSetId   Item simulation set Id.
--       Overwrite             overwrite.
--
-- Output: No output.
-- =============================================================
PROCEDURE UPDATE_PLAN_OPTIONS(
        PlanId              IN         NUMBER,
        ItemSimulationSetId IN         NUMBER,
        Overwrite           IN         NUMBER
);



-- =============================================================
-- Desc: Convert overwrite from string to number.
--       'All'         => 1
--       'Outside PTF' => 2
--       'None'        => 3
-- Input:
--       Overwrite             overwrite.
--
-- Output: The possible return statuses are:
-- =============================================================
FUNCTION CONVERT_OVERWRITE( Overwrite IN  VARCHAR2 ) RETURN NUMBER;

-- =============================================================
-- Desc: If the PurgeAllSchsFlag is set, this function is called
--       to insert all schedules, including global demand schediles,
--       local demand schedules and local supply schedules.
-- Input:
--       PlanId                Plan Id.
--       InsId                 Sr instance Id.
--       UserId                User Id.
--       GlbDmdSchs            global demand schedules.
--       LocDmdSchs            local demand schedules.
--       LocSupSchs            local supply schedules.
--
-- Output: The possible return statuses are:
-- =============================================================
FUNCTION INSERT_ALL_SCHEDULES(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        GlbDmdSchs          IN         MscIGlbDmdSchTbl,
        LocDmdSchs          IN         MscILocDmdSchTbl,
        LocSupSchs          IN         MscILocSupSchTbl
) RETURN VARCHAR2;


-- =============================================================
-- Desc: If the PurgeAllSchsFlag is not set, this function is called
--       to insert or update all schedules, including global demand
--       schediles, local demand schedules and local supply schedules.
-- Input:
--       PlanId                Plan Id.
--       InsId                 Sr instance Id.
--       UserId                User Id.
--       GlbDmdSchs            global demand schedules.
--       LocDmdSchs            local demand schedules.
--       LocSupSchs            local supply schedules.
--
-- Output: The possible return statuses are:
-- =============================================================
FUNCTION INSERT_OR_UPDATE_ALL_SCHS(
        PlanId              IN         NUMBER,
        InsId               IN         NUMBER,
        UserId              IN         NUMBER,
        GlbDmdSchs          IN         MscIGlbDmdSchTbl,
        LocDmdSchs          IN         MscILocDmdSchTbl,
        LocSupSchs          IN         MscILocSupSchTbl
) RETURN VARCHAR2;


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
-- =============================================================
FUNCTION VALIDATE_G_DMD_SCH_ID(
        SchId              IN         NUMBER,
        PlanName           IN         VARCHAR2
        ) RETURN VARCHAR2;


-- =============================================================
-- Desc: Validate the ship to consumption level. This function is
--       used by DRP and SRP. ASCP has its own function.
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
) RETURN VARCHAR2;


-- =============================================================
-- Desc: validate local supply schedules
-- Input:
--       SchTable              Local supply schedules.
--       PlanName              Plan name.
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_LOCALSUPSCHS_SUP_SCH_ID
-- =============================================================
FUNCTION VALIDATE_LOC_SUP_SCHS(
        OutSchTable        OUT NOCOPY MscILocSupSchTbl,
        InSchTable         IN         MscLocSupSchTbl,
        PlanId             IN         NUMBER,
        PlanName           IN         VARCHAR2
) RETURN VARCHAR2;


END MSC_WS_COMMON;


/

--------------------------------------------------------
--  DDL for Package MSC_WS_PLAN_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_PLAN_MANAGEMENT" AUTHID CURRENT_USER AS
/* $Header: MSCWPMAS.pls 120.1 2008/02/25 19:16:44 mtsui noship $ */

-- =============================================================
-- Desc: This procedure is invoked from web service to launch
--       the Copy Plan concurrent program.  The input parameters
--       mirror the parameters for the concurrent program.
-- Input:
--        UserName          User name.
--        RespName          Responsibility name.
--        RespAppName       Responsibility application name.
--        SecurityGroupName Security group name.
--        Language          Language.
--        SrcPlanId         Source Plan Id.
--        DestPlanName      Destination Plan Name.
--        DestPlanDesc      Destination Plan Description.
--        DestATP           Destination ATP. Allowed input is Y or N
--        DestProd          Destination Production. Allowed input is Y or N
--        DestNoti          Destination Notification. Allowed input is Y or N
--        DestInacOn        Destination Inactive On. Allowed input is Y or N
--        CopyOptionsOnly   Copy Plan Options Only. Allowed input is Y or N
--                          if 'Y', copy plan options only
--                          else copy the entire plan
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
--          INVALID_SRCPLNID      invalid source plan id
--          INVALID_DESTPLNNAME   duplicated destination plan name
-- =============================================================
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
        -- Destination Org Selection
        DestATP            IN         VARCHAR2,
        DestProd           IN         VARCHAR2,
        DestNoti           IN         VARCHAR2,
        DestInacOn         IN         DATE default NULL,
        -- Organization ID
        -- Instance ID
        CopyOptionsOnly    IN         VARCHAR2
        );


-- =============================================================
-- Desc: This procedure is invoked from web service to launch
--       the Purge Plan concurrent program.  The input parameters
--       mirror the parameters for the concurrent program.
-- Input:
--        UserName          User name.
--        RespName          Responsibility name.
--        RespAppName       Responsibility application name.
--        SecurityGroupName Security group name.
--        Language          Language.
--        DesignatorId      Designator Id.
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
--          INVALID_FND_USERID
--          INVALID_FND_RESPONSIBILITYID
--          INVALID_DESIGNATORID  invalid designator id
-- =============================================================
PROCEDURE PURGE_PLAN(
        ProcessId          OUT NOCOPY NUMBER,
        Status             OUT NOCOPY VARCHAR2,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        DesignatorId       IN         NUMBER
        );


-- =============================================================
-- Desc: This procedure is invoked from web service to launch
--       the Archive Plan Summary concurrent program.  The input
--       parameters mirror the parameters for the concurrent program.
-- Input:
--        UserName          User name.
--        RespName          Responsibility name.
--        RespAppName       Responsibility application name.
--        SecurityGroupName Security group name.
--        Language          Language.
--        PlanId            Plan Id.
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
--          INVALID_PLAN_ID       invalid plan id
-- =============================================================
PROCEDURE ARCHIVE_PLAN(
        ProcessId          OUT NOCOPY NUMBER,
        Status             OUT NOCOPY VARCHAR2,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        PlanId             IN         NUMBER
        );

END MSC_WS_PLAN_MANAGEMENT;


/

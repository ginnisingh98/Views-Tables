--------------------------------------------------------
--  DDL for Package MSC_WS_SNO_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_SNO_PUBLISH" AUTHID CURRENT_USER AS
 /* $Header: MSCWSPBS.pls 120.6.12010000.1 2008/05/02 19:09:23 appldev ship $ */
    PROCEDURE LOG_MESSAGE (p_message varchar2);
    PROCEDURE SET_UP_SYSTEM_ITEMS(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER
          );
    PROCEDURE SET_ASCP_PLAN_BUCKETS(
        Status               OUT NOCOPY VARCHAR2,
        PlanIdVar            IN         NUMBER
        );
    PROCEDURE SET_ASCP_DEMANDS(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER
          );
    PROCEDURE SET_ASCP_SUPPLIES(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER
          );
    PROCEDURE SET_ASCP_SAFETY_STOCKS(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER
          );
    PROCEDURE SET_ASCP_ALERTS(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar               IN         NUMBER
          );
    PROCEDURE SET_ASCP_DEPARTMENT_RESOURCES(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER
          );
    PROCEDURE SET_ASCP_RES_SUMMARY(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER,
          ScenarioNameVar      OUT NOCOPY VARCHAR2
          );
    PROCEDURE SET_ASCP_BIS_INV_DETAIL(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER
          );
    PROCEDURE SET_ASCP_SRC_RECOMMEND_DETAIL(
          Status               OUT NOCOPY VARCHAR2,
          PlanIdVar            IN         NUMBER,
          AssignmentSetOutIdVar IN        NUMBER
          );

-- =============================================================
--
-- Helper functions used defined in MSC_WS_COMMON package ( copies here ).
-- =============================================================

  -- get plan name from plan Id
  FUNCTION GET_PLAN_NAME_BY_PLAN_ID(
                 Status OUT NOCOPY  VARCHAR2,
                 PlanId IN NUMBER
                 ) RETURN BOOLEAN ;
  -- validate userId
  PROCEDURE  VALIDATE_USER_RESP( VRETURN OUT NOCOPY VARCHAR2,
                                  USERID IN  NUMBER,
                                  RESPID  IN NUMBER);

-- ===========================================================
PROCEDURE PUBLISH_SNO_RESULTS( processId        OUT NOCOPY Number,
                                status            OUT NOCOPY Varchar2,
                                planIdVar         IN         Number,
                                assignmentSetOutIdVar IN Number);

  PROCEDURE VALIDATE_FOR_PUBLISH_SNO_RES( processId        OUT NOCOPY Number,
                                status            OUT NOCOPY Varchar2,
                                userId            IN         Number,
                                responsibilityId  IN         Number,
                                planIdVar         IN         Number);
 PROCEDURE PUBLISH_SNO_RESULTS_WITH_VAL( processId        OUT NOCOPY Number,
                                status            OUT NOCOPY Varchar2,
                                userId            IN         Number,
                                responsibilityId  IN         Number,
                                planIdVar         IN         Number,
                                assignmentSetOutIdVar IN Number);

END MSC_WS_SNO_PUBLISH;

/

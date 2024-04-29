--------------------------------------------------------
--  DDL for Package MSD_ROLL_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_ROLL_DEMAND_PLAN" AUTHID CURRENT_USER AS
/* $Header: msddprls.pls 120.1.12010000.1 2009/04/30 06:43:27 vrepaka ship $ */


  SYS_YES                         CONSTANT NUMBER := 1;
  SYS_NO                          CONSTANT NUMBER := 2;

 -- ================== Period Types ========================================
  G_VALID_PLAN                    CONSTANT NUMBER := 0;
  G_INVALID_PLAN                  CONSTANT NUMBER := 1;

  -- ================== Period Types ========================================
  G_DAY                           CONSTANT NUMBER := 9;
  G_WEEK                          CONSTANT NUMBER := 10;
  G_GREGORIAN_MONTH               CONSTANT NUMBER := 6;


  -- ================== Parameter Types =====================================
  G_TYPE_INPUT_SCENARIO           CONSTANT VARCHAR2(100) :='MSD_INPUT_SCENARIO';


  -- ============ NULL VALUE USED IN THE WHERE CLAUSE========================
  NULL_CHAR                       CONSTANT VARCHAR2(6) := '-23453';


PROCEDURE launching_roll (    ERRBUF   OUT NOCOPY VARCHAR2,
                              RETCODE  OUT NOCOPY NUMBER,
                              p_demand_plan_id IN NUMBER,
                              p_period_type IN NUMBER,
                              p_number_of_periods IN NUMBER );

END msd_roll_demand_plan;

/

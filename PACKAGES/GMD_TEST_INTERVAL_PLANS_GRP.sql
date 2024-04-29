--------------------------------------------------------
--  DDL for Package GMD_TEST_INTERVAL_PLANS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_TEST_INTERVAL_PLANS_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGTIPS.pls 115.1 2003/04/20 23:38:40 mchandak noship $ */

FUNCTION Test_Interval_Plan_Exist
(
  p_test_interval_plan_name IN VARCHAR2 ) RETURN BOOLEAN;


FUNCTION Test_Interval_Period_Exist
(
  p_period IN VARCHAR2,
  p_test_interval_plan_id  IN NUMBER ) RETURN BOOLEAN;

FUNCTION GET_TL_TEST_INT_PLAN_DURATION(p_test_interval_plan_id 	IN NUMBER,
				       p_year_desc		IN VARCHAR2	DEFAULT NULL,
				       p_month_desc		IN VARCHAR2	DEFAULT NULL,
				       p_week_desc		IN VARCHAR2	DEFAULT NULL,
				       p_day_desc		IN VARCHAR2	DEFAULT NULL,
				       p_hour_desc		IN VARCHAR2	DEFAULT NULL )
RETURN VARCHAR2 ;


END GMD_TEST_INTERVAL_PLANS_GRP;

 

/

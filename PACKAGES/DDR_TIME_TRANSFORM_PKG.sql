--------------------------------------------------------
--  DDL for Package DDR_TIME_TRANSFORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_TIME_TRANSFORM_PKG" AUTHID CURRENT_USER AS
/* $Header: ddrttfms.pls 120.0 2008/02/13 07:04:07 vbhave noship $ */
  PROCEDURE Populate_BSNS_Transformation (
        p_org_cd          IN VARCHAR2,
        p_start_year      IN NUMBER,
        p_end_year        IN NUMBER
  );

  FUNCTION Add_Day (p_day_code IN VARCHAR2,p_no_of_days IN NUMBER DEFAULT 1)
  RETURN VARCHAR2;

  FUNCTION Add_Week (p_week_code IN VARCHAR2,p_no_of_weeks IN NUMBER DEFAULT 1)
  RETURN VARCHAR2;

  FUNCTION Add_Month (p_month_code IN VARCHAR2,p_no_of_months IN NUMBER DEFAULT 1)
  RETURN VARCHAR2;

  FUNCTION Add_Quarter (p_qtr_code IN VARCHAR2,p_no_of_qtrs IN NUMBER DEFAULT 1)
  RETURN VARCHAR2;

END ddr_time_transform_pkg;

/

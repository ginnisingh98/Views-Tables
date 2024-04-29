--------------------------------------------------------
--  DDL for Package DDR_POP_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_POP_CALENDAR_PKG" AUTHID CURRENT_USER AS
/* $Header: ddrcldrs.pls 120.0 2008/02/13 07:11:11 vbhave noship $ */

  TYPE Number_Tab IS TABLE OF NUMBER INDEX BY VARCHAR2(30);

  PROCEDURE Populate_STND_Calendar (
        p_no_of_years         IN NUMBER,
        p_start_year          IN NUMBER    DEFAULT NULL
  );

  PROCEDURE Populate_BSNS_Calendar (
        p_org_cd                IN VARCHAR2,
        p_no_of_years           IN NUMBER,
        p_start_date            IN DATE     DEFAULT NULL,
        p_five_week_month_list  IN VARCHAR2,
        p_special_year_list     IN VARCHAR2,
        p_extra_week_month      IN VARCHAR2
  );

  PROCEDURE Populate_FSCL_Calendar (
        p_org_cd              IN VARCHAR2,
        p_no_of_years         IN NUMBER,
        p_start_year_month    IN NUMBER  DEFAULT NULL
  );

  PROCEDURE Populate_ADVR_Calendar (
        p_org_cd                IN VARCHAR2,
        p_no_of_years           IN NUMBER,
        p_start_date            IN DATE     DEFAULT NULL,
        p_period_dist_list      IN VARCHAR2,
        p_week_dist_list        IN VARCHAR2,
        p_special_year_list     IN VARCHAR2,
        p_extra_week_period     IN VARCHAR2
  );

  PROCEDURE Populate_PLNG_Calendar (
        p_org_cd                IN VARCHAR2,
        p_no_of_years           IN NUMBER,
        p_start_date            IN DATE     DEFAULT NULL,
        p_period_dist_list      IN VARCHAR2,
        p_week_dist_list        IN VARCHAR2,
        p_special_year_list     IN VARCHAR2,
        p_extra_week_period     IN VARCHAR2
  );

END ddr_pop_calendar_pkg;

/

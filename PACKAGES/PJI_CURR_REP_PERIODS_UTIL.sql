--------------------------------------------------------
--  DDL for Package PJI_CURR_REP_PERIODS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_CURR_REP_PERIODS_UTIL" AUTHID CURRENT_USER AS
/* $Header: PJIRX19S.pls 120.1 2005/07/12 01:23 mogupta noship $ */

-- -----------------------------------------------------------------
-- Setup Current Reporting Periods
-- -----------------------------------------------------------------

PROCEDURE update_curr_rep_periods(
	p_pa_curr_rep_period 	VARCHAR2,
	p_gl_curr_rep_period 	VARCHAR2,
	p_ent_curr_rep_period	VARCHAR2,
	p_org_id NUMBER
);

END Pji_Curr_Rep_Periods_Util;

 

/

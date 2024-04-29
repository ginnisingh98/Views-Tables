--------------------------------------------------------
--  DDL for Package BIV_HS_PROB_AVOID_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_HS_PROB_AVOID_REPORT_PKG" AUTHID CURRENT_USER AS
	-- $Header: bivhpros.pls 115.4 2002/11/15 17:46:46 smisra noship $ */
-- Problem avoidence report

	PROCEDURE get_params (p_param_str in VARCHAR2);

	-- Problem Avoidance Report
	PROCEDURE load_prob_avoid_rpt(p_param_str IN VARCHAR2 DEFAULT NULL);
	FUNCTION  get_prob_avoid_rpt_select RETURN VARCHAR2;
	FUNCTION get_prob_avoid_rpt_table RETURN VARCHAR2;
	FUNCTION get_prob_avoid_rpt_where RETURN VARCHAR2;

	-- Problem Avoidance Resolution
	PROCEDURE load_prob_avoid_res_rpt(p_param_str IN VARCHAR2 DEFAULT NULL);
	FUNCTION  get_prob_avoid_res_rpt_select RETURN VARCHAR2;
	FUNCTION get_prob_avoid_res_rpt_table RETURN VARCHAR2;
	FUNCTION get_prob_avoid_res_rpt_where RETURN VARCHAR2;

END BIV_HS_PROB_AVOID_REPORT_PKG;

 

/

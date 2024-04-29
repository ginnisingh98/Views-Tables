--------------------------------------------------------
--  DDL for Package BIV_RT_SR_AGE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_RT_SR_AGE_REPORT_PKG" AUTHID CURRENT_USER AS
	-- $Header: bivrblas.pls 115.4 2002/11/18 17:24:44 smisra noship $ */
	-- SR back log age report

	-- Service Request Backlog Age Report
	PROCEDURE load_sr_backlog_age_report(p_param_str IN VARCHAR2 DEFAULT NULL);

--------------------------------------------------------------------------------
-- Report Functions
--------------------------------------------------------------------------------
	FUNCTION  get_select RETURN VARCHAR2;
	FUNCTION get_table RETURN VARCHAR2;
	FUNCTION get_where RETURN VARCHAR2;
	FUNCTION get_extra_param RETURN VARCHAR2;
	-- Get Column Label
	FUNCTION get_sr_blog_col_1_label(p_param_str IN VARCHAR2 DEFAULT NULL)
		RETURN VARCHAR2;
	FUNCTION get_sr_blog_col_2_label(p_param_str IN VARCHAR2 DEFAULT NULL)
		RETURN VARCHAR2;
	FUNCTION get_sr_blog_col_3_label(p_param_str IN VARCHAR2 DEFAULT NULL)
		RETURN VARCHAR2;
	FUNCTION get_sr_blog_col_4_label(p_param_str IN VARCHAR2 DEFAULT NULL)
		RETURN VARCHAR2;
	FUNCTION get_sr_blog_col_5_label(p_param_str IN VARCHAR2 DEFAULT NULL)
		RETURN VARCHAR2;
END BIV_RT_SR_AGE_REPORT_PKG;

 

/

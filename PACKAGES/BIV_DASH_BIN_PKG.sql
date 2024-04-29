--------------------------------------------------------
--  DDL for Package BIV_DASH_BIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DASH_BIN_PKG" AUTHID CURRENT_USER AS
	-- $Header: bivdsbns.pls 115.7 2002/11/18 17:23:27 smisra noship $
	-- This package is used to render the picasso BIN in setup form home page
	-- all procedure are called by seeded AK_REGION via JTF
	PROCEDURE load_sr_bin(p_param_str IN VARCHAR2 DEFAULT NULL);

    -- Monitor Report
	PROCEDURE load_sr_sum_report(p_param_str IN VARCHAR2 DEFAULT NULL);
    function  get_esc_sr_backlog(p_owner number, p_status number) return number;

    -- Service Request Severity Report
    PROCEDURE load_sr_sev_report(p_param_str IN VARCHAR2 DEFAULT NULL);
    FUNCTION get_sr_sev_report_name(p_param_str IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
    FUNCTION get_sr_sev_column_label(p_param_str IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

    -- Date util for SR SEv report
    function get_hours (p_day Date) return VARCHAR2;
    function check_esc (p_sr_id number) return varchar2;

end;

 

/

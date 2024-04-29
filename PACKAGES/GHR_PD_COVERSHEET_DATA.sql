--------------------------------------------------------
--  DDL for Package GHR_PD_COVERSHEET_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PD_COVERSHEET_DATA" AUTHID CURRENT_USER AS
/* $Header: ghrwspdc.pkh 120.0.12010000.3 2009/05/26 12:07:50 utokachi noship $ */

FUNCTION get_fr_position_group(p_position_id IN NUMBER,
		p_info_type IN VARCHAR2,
		p_info_number IN NUMBER) RETURN VARCHAR2;
FUNCTION get_gen_emp(p_pa_req_id IN NUMBER,
            p_info_number IN NUMBER) RETURN VARCHAR2;
FUNCTION get_pay_plan(p_lookup_cd IN VARCHAR2) RETURN VARCHAR2;
FUNCTION flexfield( p_position_id IN NUMBER, p_structure IN VARCHAR2, p_segment IN VARCHAR2)
	RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_fr_position_group, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES (get_gen_emp, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES (get_pay_plan, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES (flexfield , WNDS, WNPS);
END ghr_pd_coversheet_data;

/

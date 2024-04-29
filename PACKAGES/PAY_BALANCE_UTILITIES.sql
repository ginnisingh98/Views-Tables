--------------------------------------------------------
--  DDL for Package PAY_BALANCE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_UTILITIES" AUTHID CURRENT_USER AS
 /* $Header: pyblutil.pkh 115.0 99/07/17 05:46:25 porting ship $ */

PROCEDURE  get_work_codes (p_assignment_id         in number,
                           p_session_date          in date,
                           p_work_state_code       out varchar2,
                           p_work_county_code      out varchar2,
                           p_work_city_code        out varchar2,
                           p_work_state_name       out varchar2,
                           p_work_county_name      out varchar2,
                           p_work_city_name        out varchar2);

FUNCTION get_current_asact_id (p_date IN DATE,
			p_assignment_id IN NUMBER,
			p_tax_unit_id IN NUMBER,
			p_action_type IN OUT VARCHAR2,
			p_eff_date IN OUT DATE )RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(get_current_asact_id, WNDS);
end pay_balance_utilities;


 

/

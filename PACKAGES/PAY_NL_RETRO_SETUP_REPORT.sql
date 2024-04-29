--------------------------------------------------------
--  DDL for Package PAY_NL_RETRO_SETUP_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_RETRO_SETUP_REPORT" AUTHID CURRENT_USER AS
/* $Header: pynlersr.pkh 120.0.12000000.1 2007/04/11 12:49:49 rlingama noship $ */


-------------------------------------------------------------------------------
-- get_IANA_charset
-------------------------------------------------------------------------------
FUNCTION get_IANA_charset RETURN VARCHAR2;


-------------------------------------------------------------------------------
-- Procedure to Generate XML Data
-------------------------------------------------------------------------------
PROCEDURE generate
	 		( 	p_business_group_id IN NUMBER,
	 			p_eff_date IN VARCHAR2,
	 			p_ele_records IN VARCHAR2,
	 			p_template_name IN VARCHAR2,
	 			p_xml OUT NOCOPY CLOB
	 		) ;

END pay_nl_retro_setup_report;

 

/

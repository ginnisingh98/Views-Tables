--------------------------------------------------------
--  DDL for Package PAY_JP_TRANSLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_TRANSLATION_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjptrns.pkh 115.4 99/10/12 02:17:43 porting ship $ */
	FUNCTION element_name(
			p_system_name	IN VARCHAR2) RETURN VARCHAR2;
--	pragma restrict_references(element_name,WNDS,WNPS);
--
	FUNCTION input_value_name(
			p_system_element_name		IN VARCHAR2,
			p_system_input_value_name	IN VARCHAR2) RETURN VARCHAR2;
--	pragma restrict_references(input_value_name,WNDS,WNPS);
--
	FUNCTION balance_name(
			p_system_name	IN VARCHAR2) RETURN VARCHAR2;
--	pragma restrict_references(balance_name,WNDS,WNPS);
--
	FUNCTION dimension_name(
			p_system_name	IN VARCHAR2) RETURN VARCHAR2;
--	pragma restrict_references(dimension_name,WNDS,WNPS);
END PAY_JP_TRANSLATION_PKG;

 

/

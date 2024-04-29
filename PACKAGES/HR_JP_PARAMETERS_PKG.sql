--------------------------------------------------------
--  DDL for Package HR_JP_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JP_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: hrjpparm.pkh 115.1 99/10/12 02:10:41 porting ship $ */
--------------------------------------------------------------------------------
	FUNCTION get_parameter_value(
			p_owner			IN VARCHAR2,
			p_parameter_name	IN VARCHAR2) RETURN VARCHAR2;
--	pragma restrict_references(get_parameter_value,WNDS,WNPS,RNPS);
----------------------------------------------------------------------------------
	PROCEDURE put_parameter_value(
			p_owner			IN VARCHAR2,
			p_parameter_name	IN VARCHAR2,
			p_parameter_value	IN VARCHAR2);
--------------------------------------------------------------------------------
end;

 

/

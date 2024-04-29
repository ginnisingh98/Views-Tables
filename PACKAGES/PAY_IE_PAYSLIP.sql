--------------------------------------------------------
--  DDL for Package PAY_IE_PAYSLIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAYSLIP" AUTHID CURRENT_USER AS
/* $Header: pyiepsar.pkh 115.2 2002/03/11 06:28:43 pkm ship        $ */

FUNCTION get_payroll_parameter (p_parameter_string in varchar2
                               ,p_token 	   in varchar2)
RETURN varchar2;

END pay_ie_payslip;

 

/

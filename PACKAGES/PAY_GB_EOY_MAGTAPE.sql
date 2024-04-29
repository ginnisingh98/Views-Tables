--------------------------------------------------------
--  DDL for Package PAY_GB_EOY_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_EOY_MAGTAPE" AUTHID CURRENT_USER AS
/* $Header: pygbemag.pkh 120.3 2007/11/22 06:48:03 abhgangu noship $ */

PROCEDURE eoy_control;
--
FUNCTION validate_input(p_input_value    varchar2,
                        p_validate_mode  varchar2 default 'FULL_CHAR')
        return number;
--
FUNCTION validate_tax_code(p_tax_code          in varchar2,
                            p_effective_date    in date,
                            p_assignment_id     in number)
return VARCHAR2;

FUNCTION validate_tax_code_yrfil(c_assignment_action_id     in number,
                            p_tax_code          in varchar2,
                            p_effective_date    in date)
return VARCHAR2;

FUNCTION get_payroll_version
RETURN VARCHAR2;
END;

/

--------------------------------------------------------
--  DDL for Package Body PAY_IE_PAYSLIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PAYSLIP" AS
/* $Header: pyiepsar.pkb 115.2 2002/03/11 06:28:35 pkm ship        $ */

g_package                CONSTANT VARCHAR2(30) := 'Pay_ie_P30lock';


FUNCTION get_payroll_parameter (p_parameter_string in varchar2
                               ,p_token 	   in varchar2)
RETURN varchar2 IS
  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
  l_start_pos  NUMBER;
  l_delimiter  varchar2(1):=' ';
  l_proc VARCHAR2(160):= g_package||'.get payroll parameter ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  end if;
  IF l_start_pos <> 0 THEN
    l_start_pos := l_start_pos + length(p_token||'=');
    l_parameter := substr(p_parameter_string,
                          l_start_pos,
                          instr(p_parameter_string||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
  END IF;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  RETURN (l_parameter);

END get_payroll_parameter;

END pay_ie_payslip;

/

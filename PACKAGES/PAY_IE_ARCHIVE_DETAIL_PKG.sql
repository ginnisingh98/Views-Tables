--------------------------------------------------------
--  DDL for Package PAY_IE_ARCHIVE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_ARCHIVE_DETAIL_PKG" AUTHID CURRENT_USER as
/* $Header: pyieelin.pkh 120.1 2006/12/11 13:39:45 sgajula noship $ */
--
/*
  MODIFIED       (DD-MON-YYYY)
  ILeath         08-NOV-2001 - Initial Version
  aashokan       17-DEC-2004 - Bug 4069789
  aashokan       23-DEC-2004 - Bug 40683856
  sgajula        11-DEC-2006 - Bug 5696117
*/
-- Bug 5696117 added global variables to enable caching in get_paypathid to
-- improve the performance
g_payroll_id            pay_payrolls_f.payroll_id%TYPE;
g_consolidation_set_id  pay_consolidation_sets.consolidation_set_id%TYPE;
g_payroll_action_id     pay_payroll_actions.payroll_action_id%TYPE;
g_paypathid             varchar2(150);
FUNCTION get_tax_details(p_run_assignment_action_id number,
			 p_input_value_id number,
                         p_date_earned varchar2)
                           return varchar2;

FUNCTION get_parameter(p_payroll_action_id   NUMBER,
                       p_token_name          VARCHAR2) RETURN VARCHAR2;
/*Bug 40683856*/
PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT NOCOPY VARCHAR2);
FUNCTION GET_PAYPATHID return varchar2; -- Bug No 3060464

END PAY_IE_ARCHIVE_DETAIL_PKG;

/

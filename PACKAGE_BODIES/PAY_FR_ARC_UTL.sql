--------------------------------------------------------
--  DDL for Package Body PAY_FR_ARC_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_ARC_UTL" as
/* $Header: pyfrarcu.pkb 120.0 2005/05/29 04:58:23 appldev noship $ */
--
-- Globals
g_package    CONSTANT VARCHAR2(20):= 'pay_fr_arc_utl.';
--
-------------------------------------------------------------------------------
-- Function: range_person_enh_enabled.
-- Description: Returns true if the range_person performance enhancement
--              3628032 is enabled for the system and specified archive.
-------------------------------------------------------------------------------
FUNCTION range_person_enh_enabled(p_payroll_action_id number) RETURN BOOLEAN IS
--
 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';
--
 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_payroll_actions            ppa,
         pay_report_format_mappings_f   map,
         pay_report_format_parameters   par
  where  ppa.payroll_action_id        = p_payroll_action_id
  and    map.report_type              = ppa.report_type
  and    map.report_category          = ppa.report_category
  and    map.report_qualifier         = ppa.report_qualifier
  and    ppa.effective_date     between map.effective_start_date
                                    and map.effective_end_date
  and    map.report_format_mapping_id = par.report_format_mapping_id
  and    par.parameter_name           = 'RANGE_PERSON_ID';
--
  l_action_param_val pay_action_parameters.parameter_value%TYPE;
  l_report_param_val pay_report_format_parameters.parameter_value%TYPE;
  l_proc CONSTANT VARCHAR2(62):= g_package||'.range_person_enh_enabled';
--
BEGIN
  hr_utility.set_location('Entering: ' || l_proc,10);
  open csr_action_parameter;
  fetch csr_action_parameter into l_action_param_val;
  close csr_action_parameter;
  --
  open csr_range_format_param;
  fetch csr_range_format_param into l_report_param_val;
  close csr_range_format_param;
  --
  hr_utility.set_location(' Leaving: ' || l_proc,99);
  RETURN (nvl(l_action_param_val,'N')='Y' AND nvl(l_report_param_val,'N')='Y');
  --
END range_person_enh_enabled;
--
END pay_fr_arc_utl;

/

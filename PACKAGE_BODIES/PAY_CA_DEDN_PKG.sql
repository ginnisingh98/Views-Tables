--------------------------------------------------------
--  DDL for Package Body PAY_CA_DEDN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_DEDN_PKG" AS
/* $Header: pycadedn.pkb 120.0 2005/05/29 03:29:57 appldev noship $ */
--
------------------------------------------------------------------------
-- PAY_CA_TOT_OWED returns total owed input value of those deduction elements
-- for which the stop rule is defined as total reached.
-------------------------------------------------------------------------
FUNCTION pay_ca_tot_owed (
    p_assignment_id         IN    NUMBER   DEFAULT NULL
   ,p_element_type_id       IN    NUMBER   DEFAULT NULL
   ,p_effective_date        IN    DATE     DEFAULT NULL
   ,p_date_earned           IN    DATE     DEFAULT NULL)

RETURN number IS
--
   l_Total_owed       NUMBER;
--
BEGIN
--
   l_Total_owed := 0;
   BEGIN
      select  peev.screen_entry_value
      into l_Total_owed
      from
	   pay_element_entry_values_f peev,
           pay_input_values_f piv,
           pay_element_links_f pel,
           pay_element_entries_f pee
      where pee.assignment_id = p_assignment_id
      and  p_date_earned between  pee.effective_start_date
                          and     pee.effective_end_date
      and  pee.element_link_id = pel.element_link_id
      and  p_date_earned between  pel.effective_start_date
                          and     pel.effective_end_date
      and  pel.element_type_id = p_element_type_id
      and  piv.element_type_id = p_element_type_id
      and  piv.name = 'Total Owed'
      and  p_date_earned between  piv.effective_start_date
                          and     piv.effective_end_date
      and  piv.input_value_id = peev.input_value_id
      and  pee.element_entry_id = peev.element_entry_id
      and  p_date_earned between  peev.effective_start_date
                          and     peev.effective_end_date;

   EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         return -9999999.99;
      WHEN OTHERS THEN
         null;
   END;

   RETURN l_Total_owed;
--
END pay_ca_tot_owed;
end pay_ca_dedn_pkg;

/

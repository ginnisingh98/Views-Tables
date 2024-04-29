--------------------------------------------------------
--  DDL for Package PAY_AE_USER_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_USER_FUNCTION" AUTHID CURRENT_USER as
/* $Header: pyaerunf.pkh 120.1 2005/10/14 01:54:47 spendhar noship $ */

function run_SI_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   --,p_balance_date          IN DATE
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   --,p_jurisdiction_code     IN VARCHAR2
   --,p_tax_group             IN VARCHAR2
   --,p_source_id             IN NUMBER
   --,p_source_text           IN VARCHAR2
   )
  return NUMBER;

--
end pay_ae_user_function;

 

/

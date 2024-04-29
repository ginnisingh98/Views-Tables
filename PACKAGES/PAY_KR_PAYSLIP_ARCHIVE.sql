--------------------------------------------------------
--  DDL for Package PAY_KR_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER as
 /* $Header: pykrparc.pkh 120.0.12000000.1 2007/01/17 22:09:59 appldev noship $ */


  g_archive_payroll_action_id   pay_payroll_actions.payroll_action_id%TYPE;
  g_archive_effective_date      pay_payroll_actions.effective_date%TYPE;


 PROCEDURE range_code(
             p_payroll_action_id IN pay_payroll_actions.payroll_action_id%type
            ,sqlstr              OUT NOCOPY VARCHAR2);

 PROCEDURE initialization_code(
             p_payroll_action_id IN pay_payroll_actions.payroll_action_id%type);

 PROCEDURE assignment_action_code(
             p_payroll_action_id IN NUMBER
            ,p_start_person      IN NUMBER
            ,p_end_person        IN NUMBER
            ,p_chunk             IN NUMBER);


 PROCEDURE archive_code (
             p_assignment_action_id IN NUMBER
            ,p_effective_date       IN DATE);

END pay_kr_payslip_archive;

 

/

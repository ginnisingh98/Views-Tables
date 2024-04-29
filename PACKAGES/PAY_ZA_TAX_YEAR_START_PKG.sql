--------------------------------------------------------
--  DDL for Package PAY_ZA_TAX_YEAR_START_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_TAX_YEAR_START_PKG" AUTHID CURRENT_USER AS
/* $Header: pyzatysp.pkh 115.2 2002/11/28 15:16:28 jlouw noship $ */

/* This cursur selects all assignments for payroll_id in tax_year */
CURSOR c_assignments
           (p_payroll       IN NUMBER,
            p_effective_date IN DATE)
IS
      SELECT assignment_id,
             p_payroll,
             p_effective_date
       FROM  per_assignments_f
       WHERE payroll_id = p_payroll
       AND   p_effective_date BETWEEN effective_start_date AND effective_end_date;

/* This cursor select the screen entry values for each assignment */
CURSOR c_entry_details
          (p_element_type_id IN NUMBER,
           p_input_value_id  IN NUMBER,
           p_assignment_id   IN NUMBER,
           p_payroll         IN NUMBER,
           p_effective_date  IN DATE)
IS
      SELECT c.element_entry_id,
             a.screen_entry_value,
             d.input_value_id,
             d.name,
             p_payroll,
             p_effective_date
       FROM  pay_element_entry_values_f a,
             pay_element_links_f b,
             pay_element_entries_f c,
             pay_input_values_f d
      WHERE  c.assignment_id = p_assignment_id
        AND  p_effective_date BETWEEN c.effective_start_date AND c.effective_end_date
        AND  p_effective_date BETWEEN a.effective_start_date AND a.effective_end_date
        AND  p_effective_date BETWEEN b.effective_start_date AND b.effective_end_date
        AND  p_effective_date BETWEEN d.effective_start_date AND d.effective_end_date
        AND  b.element_type_id  = p_element_type_id
        AND  b.element_link_id  = c.element_link_id
        AND  d.input_value_id   = a.input_value_id
        AND  c.element_entry_id = a.element_entry_id
        AND  a.input_value_id   = p_input_value_id;


PROCEDURE reset_all_ind
          (
           p_errmsg        OUT NOCOPY VARCHAR2,
           p_errcode       OUT NOCOPY NUMBER,
           p_payroll           NUMBER   DEFAULT NULL,
           p_tax_year          VARCHAR2 DEFAULT NULL
          );

PROCEDURE rollback_all_ind
          (
           p_errmsg        OUT NOCOPY VARCHAR2,
           p_errcode       OUT NOCOPY NUMBER,
           p_payroll           NUMBER DEFAULT NULL,
           p_tax_year          VARCHAR2 DEFAULT NULL
          );

END Pay_Za_Tax_Year_Start_Pkg;

 

/

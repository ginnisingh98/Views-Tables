--------------------------------------------------------
--  DDL for Package PAY_AU_TFN_MAGTAPE_FLAGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_TFN_MAGTAPE_FLAGS" AUTHID CURRENT_USER AS
/* $Header: pyautfnf.pkh 120.0.12010000.3 2009/10/13 13:52:37 dduvvuri ship $*/
--------------------------------------------------------------------------+

--------------------------------------------------------------------------+
-- Record type to store the current reporting period's tax
-- details field values to be used by the cursor for printing details
--------------------------------------------------------------------------+

TYPE tfn_flags_record IS RECORD
  (
    k_assignment_id              per_all_assignments_f.assignment_id%TYPE,
    australian_res_flag          pay_au_tfn_tax_info_v.australian_resident_flag%TYPE,
    tax_free_threshold_flag      pay_au_tfn_tax_info_v.tax_free_threshold_flag%TYPE,
    fta_claim_flag               pay_au_tfn_tax_info_v.fta_claim_flag%TYPE,
    basis_of_payment             pay_au_tfn_tax_info_v.basis_of_payment%TYPE,
    hecs_flag                    pay_au_tfn_tax_info_v.hecs_flag%TYPE,
    sfss_flag                    pay_au_tfn_tax_info_v.sfss_flag%TYPE,
    declaration_signed_date      pay_au_tfn_tax_info_v.declaration_signed_date%TYPE,
    rebate_flag                  pay_au_tfn_tax_info_v.rebate_flag%TYPE,
    tax_file_number              pay_au_tfn_tax_info_v.tax_file_number%TYPE,
    effective_start_date         pay_au_tfn_tax_info_v.effective_start_date%TYPE,
    tfn_for_super                pay_payautax_spr_ent_v.tfn_for_super_flag%TYPE,
    senior_flag                  pay_au_tfn_tax_info_v.australian_resident_flag%TYPE,/*bug7270073*/
    current_or_terminated        varchar2(1)
   );

TYPE tfn_flags_table IS TABLE OF tfn_flags_record INDEX BY BINARY_INTEGER;

g_tfn_flags_table             tfn_flags_table;


--------------------------------------------------------------------------+
-- PROCEDURE to populate the plsql table with tax detail field values
-- for current reporting period
--------------------------------------------------------------------------+
PROCEDURE populate_tfn_flags
      (p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE,
       p_business_group_id in per_business_groups.business_group_id%TYPE,
       p_legal_employer_id in hr_soft_coding_keyflex.segment1%TYPE,
       p_report_end_date   in date);


--------------------------------------------------------------------------+
-- FUNCTION to return the values of the tax details feilds
--------------------------------------------------------------------------+
FUNCTION get_tfn_flag_values
      (p_assignment_id     in per_all_assignments_f.assignment_id%TYPE,
       p_flag_name         in varchar2) return varchar2;


--------------------------------------------------------------------------+
-- Bug 9000052 - Declaration of the new function remove_extra_spaces
--------------------------------------------------------------------------+

FUNCTION remove_extra_spaces(p_str in varchar2) return varchar2;


END PAY_AU_TFN_MAGTAPE_FLAGS;

/

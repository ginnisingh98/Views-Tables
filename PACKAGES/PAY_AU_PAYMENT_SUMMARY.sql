--------------------------------------------------------
--  DDL for Package PAY_AU_PAYMENT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYMENT_SUMMARY" AUTHID CURRENT_USER as
/* $Header: pyaupsp.pkh 120.1.12010000.5 2009/12/15 12:46:31 pmatamsr ship $ */

  level_cnt             number;
  pkg_lump_sum_c_def_bal_id     number;
  g_fbt_defined_balance_id      pay_defined_balances.defined_balance_id%type;
  --
  type r_allowance_bal       is record (balance_name  pay_balance_types.balance_name%type, balance_value number);
  type tab_allownace_balance is table of r_allowance_bal index by binary_integer;
  t_allowance_balance        tab_allownace_balance;
  t_union_table              tab_allownace_balance;
  --

/* Bug 6470581 - Added the payment summary type global variable */
  g_payment_summary_type        VARCHAR2(10);

  function adjust_retro_allowances
  (t_allowance_balance       in out nocopy tab_allownace_balance
  ,p_year_start              in date
  ,p_year_end                in date
  ,p_assignment_id           in pay_assignment_actions.assignment_id%type
  ,p_registered_employer     in number                  --2610141
  )
  return number;
  --
  --------------------------------------------------------------------
  -- These are PUBLIC procedures are required by the Archive process.
  -- There names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the archive process knows what code to execute for each step of
  -- the archive.
  --------------------------------------------------------------------
  --
  --------------------------------------------------------------------
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archival.
  --------------------------------------------------------------------
  --
  procedure range_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_sql               out nocopy varchar2);
  --
  --------------------------------------------------------------------
  -- This procedure is used to set global contexts
  -- however in current case it is a dummy procedure. In case this
  -- procedure is not present then archiver assumes that
  -- no archival is required.
  --------------------------------------------------------------------
  --
  procedure initialization_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type);
  --
  --------------------------------------------------------------------
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  --------------------------------------------------------------------
  --
  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number);


  --------------------------------------------------------------------
  -- This procedure is actually used to archive data . It
  -- internally calls private procedures to archive balances ,
  -- employee details, employer details and supplier details .
  --------------------------------------------------------------------
  procedure archive_code
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date);



  --------------------------------------------------------------------
  -- These procedures are used by validation report
  -- Called from
    -- PYAUPSVR.rdf
    -- PYAUPSSP.rdf
    -- PYAUPSET.rdf

  --------------------------------------------------------------------
  -- This function is used to get end of year values for archive items
  --------------------------------------------------------------------

  function get_archive_value(p_user_entity_name      in ff_user_entities.user_entity_name%type,
                             p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type)
   return varchar2;

  procedure spawn_data_file -- (Bug 3132178) Created to call magtape process
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type);

/*bug8711855 - this function returns sum of other lump sum e balances
               The function is called in pay_au_payment_summary, pay_au_recon_summary, pay_au_rec_det_paysum_mode package*/
/*Bug 9190980 - Added argument p_adj_lump_sum_pre_tax to get_lumpsumE_value function */
function get_lumpsumE_value
     (p_registered_employer     in   NUMBER
     ,p_assignment_id           in   pay_assignment_actions.ASSIGNMENT_ID%type
     ,p_year_start              in   DATE
     ,p_year_end                in   DATE
     ,p_lump_sum_E_ptd_tab in pay_balance_pkg.t_balance_value_tab
     ,p_lump_sum_E_ytd in number
     ,p_adj_lump_sum_E_ptd out nocopy number
     ,p_adj_lump_sum_pre_tax out nocopy NUMBER) return number;

end pay_au_payment_summary;

/

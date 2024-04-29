--------------------------------------------------------
--  DDL for Package Body HR_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DELETE" AS
/* $Header: pedelete.pkb 120.0 2005/05/31 07:34:08 appldev noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ******************************************************************
 ==================================================================

 Name        : hr_delete  (BODY)

 Description : Contains the definition of general delete procedures
               as declared in the hr_delete package header


 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    17-NOV-92 SZWILLIA             Date Created
 70.1    09-FEB-93 SZWILLIA             Corrected ref to
                                        PER_SECONDARY_ASS_STATUSES
 70.2    11-MAR-93 NKHAN                added 'exit' to the end
 70.3    13-APR-93 abraae               remove references to defunct "legal
                                        company" tables
 70.5    30-APR-93 M DYER               Commented out reference to
                                        ssp_maternity_pay_periods.
 70.6    30-APR-93 M DYER               now deletes database items for elements
                                        and input values.
 70.7    01-JUN-93 JTHURING             Removed references to
                                        ssp_maternity_pay_periods and
                                        ssp_periods_of_incapacity
 70.10   07-JUL-93 SZWILLIA             Moved delete of PER_VACANCIES which
                                        was in conflict with assignments.
                                        Now in delete_per_misc. Also, moved
                                        PER_REQUISITIONS.
 70.10   07-JUL-93 mwcallag             Delete all database items for a given
                                        business group, procedure
                                        'delete_database_items' added. Element
                                        type and input value database item
                                        deletion procedures removed from
                                        'delete_element_direct', now all done
                                        by 'delete_database_items'.
 70.11   13-JUL-93 SZWILLIA   B80       Previous changes made in response to
                                         bug number 80.
 80.1    15-DEC-93 JHOBBS     G284      Corrected delete of PAY_USER_COLUMN_ ..
                                        INSTANCES to use base table and not the
                                        view.
                              G325      Made sure the removal of assignment
                                        actions orders by descending payroll
                                        actions so that multiple assignments
                                        are dealt with correctly.
 80.2    22-DEC-93 DSAXBY     G470      Avoid constraint violation problem
                                        by removing pre-payment delete and
                                        leaving it to rollback assignment
                                        actions procedure.
                                        Also, fix problem that still exists
                                        with the order by that drives the
                                        delete of assignment actions (should
                                        not order by
                                        pay_payroll_actions.action_sequence).
 80.3    22-FEB-94 JTHURING   B402      Remove references to pay_holidays and
                                        pay_holiday_parameters
 80.4    28-APR-94 DSAXBY     G655      Need to delete hr_assignment_set rows
                                        after payroll actions.
 70.15   23-NOV-94 RFINE      G1725     Suppressed index on business_group_id
 70.16   29-NOV-94 DSAXBY               Altered the way payroll actions and
                                        assignment actions are rolled back
                                        following change in rollback rules.
 70.17   16-FEB-95 DSAXBY               Delete from pay_monetary_units.
 70.18   24-FEB-95 NBRISTOW             Delete from pay_magnetic_records.
 70.19   14-JUN-95 NLBARLOW           Delete from per_special_info_type_usages
 70.20   26-JUL-95 Kev Koh              Added deletions for per_person_types
 70.21   23-AUG-95 DSAXBY               Improved deletion from element entries
                                        and values. Was causing full table
                                        scans on both these tables!!
 70.22   24-AUG-95 Kev Koh              Improved deletion from link input
                                        values.
 70.23   24-AUG-95 Kev Koh              Added deletions for per_number_
                                        generation_controls in delete_misc.
 70.24   27-SEP-95 akelly               Added deletion from hr_organization_
                                        information to delete_org_direct.
                                        Added deletions from pay_wc_rates and
                                        pay_wc_funds to delete_org_detail.
                                        Added new procedure delete_location.
 70.25  15-oct-95 akelly                Removed delete_location.
 70.26  17-OCT-95 nbristow              Added delete_bal_load_struct to delete
                                        from pay_balance_batch_headers and
                                        pay_balance_batch_lines.
 70.27  31-OCT-95 Kev Koh               Enhanced delete_secure_objects with
                                        delete cursor
 70.28  31-OCT-95 Kev Koh               Enhanced delete_secure_objects and
                                        delete_bal_load_struct with
                                        delete cursor
 70.29  01-NOV-95 dsaxby                Added p_preserve_org_information param
                                        to the delete_below_bg procedure.
 70.30  02-NOV-95 nbristow              Corrected cursors in
                                        delete_bal_load_struct and balance
                                        transfers are rolled back.
 70.31  06-NOV-95 nbristow              delete_bal_load_struct now deletes from
                                        pay_message_lines rather that doing a
                                        full rollback of the batch upload.
 70.32  17-JAN-96 nbristow              Now deleting from per_pay_bases,
                                        pay_freq_rule_periods,
                                        pay_ele_freq_rules and
                                        ben_benefit_contributions_f.
 70.33  22-JAN-96 mhoyes                Added delete statements to
                                        delete_assign_detail which delete from
                                        per_pay_proposal_components and
                                        per_pay_proposals for a business group.
 70.34  19-MAR-95 dsaxby                Now call py_rollback_pkg version of
                                        rollback_payroll_action.
 70.35  28-JUN-96 mhoyes              a Added delete statement to
                                        delete_bg_misc to delete
                                        financials_system param_all for
                                        a business group.
                                      b Moved the delete statement for
                                        PER_PAY_BASES to before the delete
                                        statement for PAY_RATES to avoid
                                        the referential integrity error
                                        when RATE_ID is set for a pay basis.
                                      c Moved the delete statement for
                                        PER_EVENTS to after the delete
                                        statement for PER_PAY_PROPOSALS to
                                        avoid the referential integrity error
                                        when EVENT_ID is set for a pay proposal.
 70.36  31-JUL-96 Tmathers            a Made delete statment a dynamic sql
 70.37  28-AUG-96 mhoyes              a Created new procedure
                                        delete_competence_detail to delete
                                        business group data from new
                                        competence tables.
													 cursor so it will not fail compilation
													 in a stand alone 10.5 environment.
 70.38 16-SEP-96  DKerr		      Performance Tuning
				      a. delete_secure_objects :
				      Re-enabled use of business group index
				      in person_list cursor
				      b. delete_bal_load_struct :
				      Split PAY_BALANCE_BATCH_HEADERS cursor
				      into two separate statements.
 70.39 18-SEP-96  GPerry              Added per_estab_attendances to per
				      misc delete block.
 70.40 18-SEP-96  M.J.Hoyes         a Removed all code which suppressed
                                      the business_group_id index.
                                    b Restructured the order of all
                                      personnel related delete statements.
                                    c Placed cursors around groups of
                                      delete statements which are
                                      inter-dependent.
                                    d Added procedures delete_grade_direct
                                      and delete_job_direct.
 70.41 25-SEP-96                      Added delete calls to all tables
				      relevant to the professional qualification
				      modules. This comprises of the tables
				      PER_ESTABLISHMENTS
				      PER_SUBJECT_USAGES
				      PER_QUAL_HISTORIES
				      PER_QUAL_SUBJECT_USAGES
				      PER_QUALIFICATION_TYPES
				      PER_QUALIFICATIONS
 70.42 30-SEP-96  N.Bristow         Constraint error encountered when deleting
                                    from hr_assignment_set_amendments,
                                    deletions where being performed in the
                                    wrong order.

 70.43 06-OCT-96 D.Kerr             Temporarily removed delete_competence_detail
				    during 10.7/Prod15 release phase
 70.44 11-NOV-96 N.Bristow          Uncommented the deletion from
                                    pay_balance_batch_headers and
                                    pay_balance_batch_lines.
 70.45 18-NOV-96 Tmathers           Added p_rt_running parameter to allow
                                    Rt's once again to be re-runnable.
 70.46 12-MAR-97 DLo                1 Added delete statements to
                                      delete_job_direct to
                                      delete per_position_extra_info and
                                      per_job_extra_info.
                                    2 Added delete statement to
                                      delete_person_direct to delete
                                      per_people_extra_info.
110.1 27-JAN-97 N.Bristow           Now deleting balance types correctly.
110.2 16-APR-98 SASmith            Change required from
                                    per_assignment_budget_values to
                                    per_assignment_budget_values_f.
                                    This is due to the table changes to
                                    make it date tracked.

110.3 07-MAY-98 NBristow           Revised the order of deletion of
                                    database items and assignment details
110.4 08-SEP-98 smcmilla           Added procedure to delete from
                                   questionnaire tables (delete_qun_misc).
115.4 08-MAR-99 ALogue		   Delete of Security Group Info.
115.5 16-APR-99 ALogue		   Delete of Assignment_sets + removed
                                   deletion form pay_exchange_rates_f.
115.7 07-JUL-99 MStewart           Added code to check the enable_security_groups
                                   profile and only delete lookups and security
                                   groups if it is enabled and the security group
                                   id is more than zero.
115.8 01-Oct-99 SCNair             Date Track Position related changes
115.9 26-Oct-99 Susivasu           Delete pay_batch_headers and associated entities.
115.10 12-JUN-00 N.Bristow         Added delete_run_types and now removing
                                   process_events and iterative rules.
115.11 03-OCT-00 I.Harding         Added delete of job groups
115.12 03-OCT-00 I.Harding         Change to above fix.
115.13 31-OCT-00 D.Saxby           Fixed deletion of hr_assignment_set_criteria.
115.14 28-MAR-01 N.Bristow         Deleting from pay_dated_tables,
                                   pay_event_updates, payevent_groups
                                   and pay_datetracked_events.
115.15 19-JUN-01 G.Perry           Fixed WWBUG 1833930.
                                   Changed SQL code to use exists rather than
                                   selecting every row from the db. This makes
                                   a significant performance gain.
115.16 02-JUL-01 N.Bristow         Deleting from pay_event_procedures now.
115.17 04-Sep-00 dsaxby            Changes for purge (1682940).
                                   - Added deletes for pay_us_asg_reporting,
                                     pay_balance_sets, pay_balance_set_members.
                                   - Update the secondary_status for any purge
                                     assignment actions before attempting to
                                     call rollback_payroll_action procedure.
115.18 21-NOV-02 N.Bristow         Now deleting from pay_element_types_f_tl,
                                   pay_input_values_f_tl and pay_balance_types_tl
115.19 09-DEC-02 jonward           Deleted grade MLS table
115.20 13-DEC-02 pmfletch          Added delete from positions MLS table
115.21 27-DEC-02 joward            Added delete from jobs MLS table
115.23 01-JUL-03 tvankayl          Procedure DELETE_PAY_MISC modified to
				   delete records from PAY_CUSTOM_RESTRICTIONS_TL
				   before deleting from PAY_CUSTOMIZED_RESTRICTIONS
115.24 15-JUL-03 scchakra          Bug 2982582. Added deletion of
                                   pay_monetary_units_tl in
				   delete_assign_low_detail.
115.25 28-AUG-03 nbristow          Added procedure delete_retro_details.
115.26 sep-2003  mbocutt           Ex-person security enhancements.  Remove
                                   references to per_person_list_changes.
                       This file is now dependent on other
                       security changes delivered in Nov 2003 FP.
115.27 09-DEC-03 nbristow          Now delete from pay_latest_balances.
115.28 12-DEC-03 nbristow          Now delete from pay_upgrade_status.
115.29 30-APR-04 alogue            Performance Repository : remove deletion from
                                   pay_quickpay_inclusions as occurs within rollback
                                   anyway.
115.30 11-MAY-04 smparame 3622082  Modified the delete from per_organization_list in
						   delete_secure_objects procedure to improve
						   performance.
115.31 24-MAY-04 alogue   3640651  Performance Repository fixes:
                                   Rewrote delete_formula_direct.
                                   Remove deletion from pay_costs in
                                   delete_assign_low_detail as occurs within
                                   rollback anyway!
                                   Remove deletion from pay_run_results in
                                   delete_assign_detail as occurs within
                                   rollback anyway!
                                   Removed redundant cursor ass_actions from
                                   delete_assign_detail.
115.32 02-JUN-04 sbuche   3598568  Private procedure delete_secure_objects directly
                                   referred HRMS internal objects. Hence it is removed
                                   from this package and added to hr_security_internal.
                                   Call to this procedure in delete_below_bg is replaced
                                   with hr_security.delete_list_for_bg.
115.33 23-JUN-04 adhunter 3710074  added delete of absence types tl table in
                                   delete_person_direct
115.34 23-JUN-04 adhunter          added revision comment
115.35 26-SEP-04 nbristow          Changed code so that it can be run on the
                                   test harness DB. Also not deleting
                                   from pay_object_groups.
115.36 06-MAR-05 nbristow          Now deleting the time definitions.
*/
--
-- Package variables
--
g_package  varchar2(33)	:= 'hr_delete.';  -- Global package name
--
  PROCEDURE delete_time_def_direct(p_business_group_id NUMBER)
  IS
--
  cursor get_time_defs(p_bg_id number)
  is
  select time_definition_id
    from pay_time_definitions
   where business_group_id = p_bg_id;
--
  BEGIN
--
     for timrec in get_time_defs(p_business_group_id) loop
--
        delete from per_time_periods
         where time_definition_id = timrec.time_definition_id;
--
     end loop;
--
     delete from pay_time_definitions
      where business_group_id = p_business_group_id;
--
  END delete_time_def_direct;
--
  PROCEDURE delete_retro_details(p_business_group_id NUMBER)
  IS
--
  cursor get_ret_asg(p_bg_id number) is
  select pra.retro_assignment_id
    from pay_retro_assignments pra
   where pra.assignment_id in (select distinct paf.assignment_id
                                 from per_assignments_f paf
                                where paf.business_group_id = p_bg_id);
--
  cursor get_ret_comp_use(p_bg_id number) is
  select retro_component_usage_id
    from pay_retro_component_usages
   where business_group_id = p_bg_id;
--
  BEGIN
--
    for rarec in get_ret_asg(p_business_group_id) loop
--
      delete from pay_retro_entries
       where retro_assignment_id = rarec.retro_assignment_id;
--
      delete from pay_retro_assignments
       where retro_assignment_id = rarec.retro_assignment_id;
--
    end loop;
--
    for retrec in get_ret_comp_use(p_business_group_id) loop
--
      delete from pay_element_span_usages
       where retro_component_usage_id = retrec.retro_component_usage_id;
--
      delete from pay_retro_component_usages
       where retro_component_usage_id = retrec.retro_component_usage_id;
--
    end loop;
--
  END delete_retro_details;
--
--
  PROCEDURE delete_run_types(p_business_group_id NUMBER)
  IS
    cursor getrt(p_business_group_id number)
    is
      select run_type_id
        from pay_run_types_f
       where business_group_id = p_business_group_id;
  BEGIN
--
     for rtrec in getrt (p_business_group_id) loop
--
        delete from pay_run_type_usages_f
         where parent_run_type_id = rtrec.run_type_id;
        delete from pay_run_type_usages_f
         where child_run_type_id = rtrec.run_type_id;
        delete from pay_element_type_usages_f
         where run_type_id = rtrec.run_type_id;
        delete from pay_run_type_org_methods_f
         where run_type_id = rtrec.run_type_id;
        delete from pay_run_types_f
         where run_type_id = rtrec.run_type_id;
--
     end loop;
--
  END delete_run_types;
--
  PROCEDURE delete_mag_structure(p_business_group_id NUMBER)
  IS
  begin
  --
    hr_utility.set_location('hr_delete.delete_mag_structure',1);
    DELETE FROM pay_magnetic_records mr
    WHERE EXISTS ( SELECT ''
                   FROM   ff_formulas_f ff
                   WHERE  ff.formula_id = mr.formula_id
                   AND    ff.business_group_id = p_business_group_id);
    --
  --
  end delete_mag_structure;
--
  PROCEDURE delete_bal_load_struct(p_business_group_id NUMBER)
  IS
    --
    l_business_group_name  per_business_groups.name%type ;
    --
    CURSOR get_bg IS
    SELECT bg.name
    FROM   per_business_groups bg
    WHERE  bg.business_group_id = p_business_group_id ;
    --
    CURSOR pbh IS
    SELECT bh.batch_id,
           bh.batch_status
    FROM   pay_balance_batch_headers bh
    WHERE ( (bh.business_group_id = p_business_group_id)
    OR     ( upper(bh.business_group_name) = upper(l_business_group_name)) );
    --
    CURSOR pbl (p_batch in number) IS
    SELECT bl.batch_line_id
    FROM   pay_balance_batch_lines bl
    where  bl.batch_id = p_batch;
    --
  begin
  --
    hr_utility.set_location('hr_delete.delete_bal_load_struct',10);
    --
    OPEN get_bg ;
    FETCH get_bg INTO l_business_group_name ;
    CLOSE get_bg ;
    --
    hr_utility.set_location('hr_delete.delete_bal_load_struct',20);
    --
    FOR pbhrec IN pbh LOOP
       if (pbhrec.batch_status in ('E', 'P', 'V')) then
         hr_utility.set_location('hr_delete.delete_bal_load_struct',30);
         FOR pblrec IN pbl (pbhrec.batch_id) LOOP
            DELETE FROM pay_message_lines
            WHERE source_id = pblrec.batch_line_id
              AND source_type = 'L';
         END LOOP;
         --
         DELETE FROM pay_message_lines
               WHERE source_id = pbhrec.batch_id
                 AND source_type = 'H';
       end if;
       DELETE FROM pay_balance_batch_lines bl
            WHERE bl.batch_id = pbhrec.batch_id;
--
       DELETE FROM pay_balance_batch_headers bh
       WHERE bh.batch_id  = pbhrec.batch_id;
    END LOOP;
  --
    hr_utility.set_location('hr_delete.delete_bal_load_struct',99);
  --
  end delete_bal_load_struct;
--
  PROCEDURE delete_formula_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_formula_direct';
    --
    cursor csr_get_bg_formulas
      (c_business_group_id  ff_formulas_f.business_group_id%TYPE)
    is
      SELECT distinct formula_id
      FROM   ff_formulas_f
      WHERE  business_group_id = c_business_group_id;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Check if a formulas exist for the business group
    --
    for form in csr_get_bg_formulas(p_business_group_id) loop
      --
      DELETE FROM ff_compiled_info_f  ci
      WHERE ci.formula_id = form.formula_id;
      hr_utility.set_location(l_proc,20);
      --
      DELETE FROM ff_fdi_usages_f fdi
      WHERE fdi.formula_id = form.formula_id;
      hr_utility.set_location(l_proc,30);
      --
      DELETE FROM ff_formulas_f ff
      WHERE  ff.formula_id = form.formula_id;
      hr_utility.set_location(l_proc,40);
      --
    end loop;
    --
    hr_utility.set_location('Leaving: '||l_proc,100);
  end delete_formula_direct;
--
  PROCEDURE delete_database_items(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_database_items';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_ff_user_ents
      (c_business_group_id  ff_user_entities.business_group_id%TYPE)
    is
      SELECT null
      FROM   ff_user_entities
      WHERE  business_group_id = c_business_group_id;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc, 10);
    --
    -- Check if a user entities exist for the business group
    --
    open csr_get_ff_user_ents(p_business_group_id);
    fetch csr_get_ff_user_ents into l_exists;
    if csr_get_ff_user_ents%found then
      --
      DELETE FROM ff_user_entities
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 20);
      --
    end if;
    close csr_get_ff_user_ents;
    hr_utility.set_location('Leaving: '||l_proc, 30);
    --
  end delete_database_items;
--
  PROCEDURE delete_assign_low_detail(p_business_group_id NUMBER)
  IS
  begin
  --
    hr_utility.set_location('hr_delete.delete_assign_low_detail',1);
    DELETE FROM pay_coin_anal_elements cae
    WHERE EXISTS (SELECT ''
                  FROM   pay_pre_payments ppp
                  WHERE  ppp.pre_payment_id
                         = cae.pre_payment_id
                  AND EXISTS ( SELECT ''
                               FROM   pay_assignment_actions paa
                               WHERE  paa.assignment_action_id
                                      = ppp.assignment_action_id
                               AND EXISTS (SELECT ''
                                           FROM   per_assignments_f pa
                                           WHERE  pa.assignment_id
                                                   = paa.assignment_id
                                           AND    pa.business_group_id
                                                   = p_business_group_id
                                          )
                              )
                  );
    --
    hr_utility.set_location('hr_delete.delete_assign_low_detail',3);
    DELETE FROM pay_monetary_units_tl montl
    WHERE EXISTS ( SELECT ''
                   FROM   pay_monetary_units mon
		   WHERE  montl.monetary_unit_id = mon.monetary_unit_id
		   AND    mon.business_group_id = p_business_group_id
                 );
    --
    DELETE FROM pay_monetary_units mon
    WHERE  mon.business_group_id = p_business_group_id;
    --
    hr_utility.set_location('hr_delete.delete_assign_low_detail',5);
    DELETE FROM pay_process_events ppe
     WHERE EXISTS (SELECT ''
                     FROM per_assignments_f pa
                    WHERE pa.assignment_id = ppe.assignment_id
                      AND    pa.business_group_id = p_business_group_id
                  );
  --
  end delete_assign_low_detail;
--
--
  PROCEDURE delete_assign_detail(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_assign_detail';
    --
    l_exists            varchar2(1);
    --
    -- This cursor used in the delete of entry values.
    CURSOR cev is
      SELECT pee.element_entry_id
      from   pay_element_entries_f pee,
             pay_element_links_f   pel
      where  pel.business_group_id = p_business_group_id
      and    pee.element_link_id       = pel.element_link_id;
  --
  begin
    hr_utility.set_location('Entering: '||l_proc, 10);
    --
    -- This performed here because we have to cope with
    -- the rollback rules that prevent rolling back
    -- single assignment actions for various action types.
    --
    declare
--
      cursor lbcur(p_bg_id number) is
       select palb.latest_balance_id,
              'ASG' bal_type
         from pay_assignment_latest_balances palb,
              pay_assignment_actions paa,
              pay_payroll_actions ppa
        where ppa.business_group_id = p_bg_id
          and ppa.payroll_action_id = paa.payroll_action_id
          and paa.assignment_action_id = palb.assignment_action_id
       union all
       select pplb.latest_balance_id,
              'PER' bal_type
         from pay_person_latest_balances pplb,
              pay_assignment_actions paa,
              pay_payroll_actions ppa
        where ppa.business_group_id = p_bg_id
          and ppa.payroll_action_id = paa.payroll_action_id
          and paa.assignment_action_id = pplb.assignment_action_id
       union all
       select plb.latest_balance_id,
              'AP' bal_type
         from pay_latest_balances plb,
              pay_assignment_actions paa,
              pay_payroll_actions ppa
        where ppa.business_group_id = p_bg_id
          and ppa.payroll_action_id = paa.payroll_action_id
          and paa.assignment_action_id = plb.assignment_action_id;
--
      cursor c1 is
      select pac.payroll_action_id,
             pac.action_type
      from   pay_payroll_actions pac
      where  pac.business_group_id = p_business_group_id
      order  by pac.effective_date    desc,
                pac.payroll_action_id desc;
    begin
       for c1rec in c1 loop
          if(c1rec.action_type = 'Z') then
             -- Ensure the Purge action can be rolled back.
             update pay_assignment_actions act
             set    act.secondary_status  = 'U'
             where  act.payroll_action_id = c1rec.payroll_action_id;
          end if;
          --
          -- Delete any latest balances that exist prior to the rollback
          -- This is done sine we don't know the value of SINGLE_BAL_TABLE
          -- at the time of the original processing.
          --
          for lbrec in lbcur(p_business_group_id) loop
            if (lbrec.bal_type in ('ASG', 'PER')) then
              delete from pay_balance_context_values
               where latest_balance_id = lbrec.latest_balance_id;
            end if;
--
            if lbrec.bal_type = 'ASG' then
              delete from pay_assignment_latest_balances
               where latest_balance_id = lbrec.latest_balance_id;
            elsif lbrec.bal_type = 'PER' then
              delete from pay_person_latest_balances
               where latest_balance_id = lbrec.latest_balance_id;
            else
              delete from pay_latest_balances
               where latest_balance_id = lbrec.latest_balance_id;
            end if;
--
          end loop;
          --
          py_rollback_pkg.rollback_payroll_action(c1rec.payroll_action_id);
       end loop;
    end;
    hr_utility.set_location(l_proc, 30);
    --
    -- Delete entries and entry values.
    --
    for cevrec in cev loop
      delete from pay_element_entry_values_f eev
      where  eev.element_entry_id = cevrec.element_entry_id;
      --
      delete from pay_entry_process_details
       where element_entry_id = cevrec.element_entry_id;
      --
      delete from pay_element_entries_f pee
      where  pee.element_entry_id = cevrec.element_entry_id;
    end loop;
    hr_utility.set_location('Leaving: '||l_proc, 90);
    --
  end delete_assign_detail;
--
--
  PROCEDURE delete_assign_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_assign_direct';
    --
    l_exists            varchar2(1);
    --
    -- WWBUG 1833930.
    -- Changed all following cursors to use exists and for assignments
    -- to use the base table
    --
    cursor csr_get_asg
      (c_business_group_id  per_assignments_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   per_all_assignments_f
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_ast
      (c_business_group_id  per_assignments_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   per_assignment_status_types
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_ltp
      (c_business_group_id  per_letter_types.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   per_letter_types
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_prs
      (c_business_group_id  per_parent_spines.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   per_parent_spines
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_gra
      (c_business_group_id  per_grades.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   per_grades
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_job
      (c_business_group_id  per_jobs.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   per_jobs
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_rca
      (c_business_group_id
      PER_RECRUITMENT_ACTIVITIES.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   PER_RECRUITMENT_ACTIVITIES
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_req
      (c_business_group_id
      PER_REQUISITIONS.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   PER_REQUISITIONS
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_bud
      (c_business_group_id
      PER_BUDGETS.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   PER_BUDGETS
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_pyp
      (c_business_group_id
      PER_PAY_PROPOSALS.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   PER_PAY_PROPOSALS
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_crp
      (c_business_group_id
      PER_CAREER_PATHS.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   PER_CAREER_PATHS
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_pst
      (c_business_group_id
      PER_POSITION_STRUCTURES.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   PER_POSITION_STRUCTURES
                    WHERE  business_group_id = c_business_group_id);
    --
    cursor csr_get_evt
      (c_business_group_id
       per_events.business_group_id%TYPE)
    is
      SELECT null
      FROM   sys.dual
      WHERE  exists(select null
                    FROM   per_events
                    WHERE  business_group_id = c_business_group_id);
    --
    -- End of fix for WWBUG 1833930.
    -- Changed all following cursors to use exists and for assignments
    -- to use the base table
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Check if letter types exist for the
    -- business group
    --
    open csr_get_ltp (p_business_group_id);
    fetch csr_get_ltp into l_exists;
    if csr_get_ltp%found then
      --
      DELETE FROM per_letter_request_lines
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,20);
      --
      DELETE per_letter_requests
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,30);
      --
      DELETE per_letter_gen_statuses
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,40);
      --
      DELETE per_letter_types
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,50);
      --
    end if;
    close csr_get_ltp;
    hr_utility.set_location(l_proc,60);
    --
    -- Check if pay proposals exist for the
    -- business group
    --
    open csr_get_pyp (p_business_group_id);
    fetch csr_get_pyp into l_exists;
    if csr_get_pyp%found then
      --
      delete from per_pay_proposal_components ppc
      where ppc.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 70);
      --
      delete from per_pay_proposals
      where business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 80);
      --
    end if;
    close csr_get_pyp;
    hr_utility.set_location(l_proc,90);
    --
    -- Check if an event exists for the business group.
    --
    open csr_get_evt(p_business_group_id);
    fetch csr_get_evt into l_exists;
    if csr_get_evt%found then
      --
      DELETE FROM per_bookings pb
      WHERE  pb.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,100);
      --
      DELETE FROM per_events
      WHERE business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,110);
      --
    end if;
    close csr_get_evt;
    hr_utility.set_location(l_proc,120);
    --
    -- Check if a budget exists for the
    -- business group
    --
    open csr_get_bud (p_business_group_id);
    fetch csr_get_bud into l_exists;
    if csr_get_bud%found then
      --
      DELETE FROM per_assignment_budget_values_f abv
      WHERE  abv.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 130);
      --
      DELETE FROM per_budget_values
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,140);
      --
      DELETE FROM per_budget_values
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,150);
      --
      DELETE FROM per_budget_elements
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,160);
      --
      DELETE FROM per_budget_versions
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,170);
      --
      DELETE FROM per_budgets
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,180);
      --
    end if;
    close csr_get_bud;
    hr_utility.set_location(l_proc,190);
    --
    -- Check if an assignment exists for the business group
    --
    open csr_get_asg (p_business_group_id);
    fetch csr_get_asg into l_exists;
    if csr_get_asg%found then
      --
      DELETE FROM pay_object_groups pog
       WHERE
         SOURCE_TYPE = 'PAF'
       AND
         EXISTS
         (SELECT ''
          FROM   per_assignments_f pa
          WHERE  pa.assignment_id = pog.source_id
          AND    pa.business_group_id = p_business_group_id);
      --
      DELETE FROM pay_us_asg_reporting uar
      WHERE
        EXISTS
         (SELECT ''
          FROM   per_assignments_f pa
          WHERE  pa.assignment_id = uar.assignment_id
          AND    pa.business_group_id = p_business_group_id);
      --
      DELETE FROM pay_personal_payment_methods_f ppm
      WHERE  ppm.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 200);
      --
      DELETE FROM pay_cost_allocations_f ca
      WHERE  ca.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 210);
      --
      DELETE FROM per_assignment_extra_info aei
      WHERE
        EXISTS
         (SELECT ''
          FROM   per_assignments_f pa
          WHERE  pa.assignment_id = aei.assignment_id
          AND    pa.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc, 220);
      --
      DELETE FROM per_quickpaint_result_text qrt
      WHERE
        EXISTS
          (SELECT ''
           FROM   per_assignments_f pa
           WHERE  pa.assignment_id = qrt.assignment_id
           AND    pa.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,230);
      --
      DELETE FROM pay_assignment_link_usages alu
      WHERE EXISTS ( SELECT ''
                     FROM   per_assignments_f pa
                     WHERE  pa.assignment_id = alu.assignment_id
                     AND    pa.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,235);
      --
      DELETE FROM hr_assignment_set_amendments asa
      WHERE EXISTS ( SELECT ''
                     FROM   per_assignments_f pa
                     WHERE  pa.assignment_id = asa.assignment_id
                     AND    pa.business_group_id = p_business_group_id);
      hr_utility.set_location('Leaving: '||l_proc,237);
      --
      DELETE FROM per_spinal_point_placements_f
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 240);
      --
      DELETE FROM per_secondary_ass_statuses
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 250);
      --
      -- WWBUG 1833930. Changed to use base table per_all_assignments_f
      --
      DELETE FROM per_all_assignments_f
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc, 260);
      --
    end if;
    close csr_get_asg;
    hr_utility.set_location(l_proc, 270);
    --
    DELETE FROM per_pay_bases
    WHERE  business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,160);
    --
    -- Check if career paths exist for the business group
    --
    open csr_get_crp (p_business_group_id);
    fetch csr_get_crp into l_exists;
    if csr_get_crp%found then
      --
      DELETE FROM per_career_path_elements
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,60);
      --
      DELETE FROM per_career_paths
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,70);
      --
    end if;
    close csr_get_crp;
    hr_utility.set_location(l_proc,70);
    --
    -- Check if an assignment status type exists for the
    -- business group
    --
    open csr_get_ast (p_business_group_id);
    fetch csr_get_ast into l_exists;
    if csr_get_ast%found then
      --
      DELETE PER_ASS_STATUS_TYPE_AMENDS
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,150);
      --
      DELETE per_assignment_status_types
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,160);
      --
    end if;
    close csr_get_ast;
    hr_utility.set_location(l_proc,170);
    --
    -- Check if a recruitment activity exists for the
    -- business group
    --
    open csr_get_rca (p_business_group_id);
    fetch csr_get_rca into l_exists;
    if csr_get_rca%found then
      --
      DELETE FROM per_recruitment_activity_for
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,280);
      --
      DELETE FROM per_recruitment_activities
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,290);
      --
    end if;
    close csr_get_rca;
    hr_utility.set_location(l_proc,300);
    --
    -- Check if a requisition exists for the
    -- business group
    --
    open csr_get_req (p_business_group_id);
    fetch csr_get_req into l_exists;
    if csr_get_req%found then
      --
      DELETE FROM per_vacancies vac
      WHERE  vac.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,310);
      --
      DELETE FROM per_requisitions pr
      WHERE  pr.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,320);
      --
    end if;
    close csr_get_req;
    hr_utility.set_location(l_proc,330);
    --
    DELETE FROM pay_org_payment_methods_f
    WHERE  business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,340);
    --
  end delete_assign_direct;
--
--
  PROCEDURE delete_grade_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_grade_direct';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_gra
      (c_business_group_id  per_grades.business_group_id%TYPE)
    is
      SELECT null
      FROM   per_grades
      WHERE  business_group_id = c_business_group_id;
    --
    cursor csr_get_prs
      (c_business_group_id  per_parent_spines.business_group_id%TYPE)
    is
      SELECT null
      FROM   per_parent_spines
      WHERE  business_group_id = c_business_group_id;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Check if grades exist for the
    -- business group
    --
    open csr_get_gra (p_business_group_id);
    fetch csr_get_gra into l_exists;
    if csr_get_gra%found then
      --
      DELETE FROM per_grade_spines_f gs
      WHERE  gs.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,200);
      --
      DELETE FROM per_valid_grades vg
      WHERE  vg.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,230);
      --
      DELETE FROM per_grades_tl gdt
      WHERE  gdt.grade_id IN (SELECT pg.grade_id
                              FROM   per_grades pg
                              WHERE  pg.business_group_id  = p_business_group_id);
      hr_utility.set_location(l_proc,235);
      --
      DELETE FROM per_grades pg
      WHERE  pg.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,240);
      --
    end if;
    close csr_get_gra;
    hr_utility.set_location(l_proc,170);
    --
    -- Check if parent spines exist for the
    -- business group
    --
    open csr_get_prs (p_business_group_id);
    fetch csr_get_prs into l_exists;
    if csr_get_prs%found then
      --
      DELETE FROM PER_SPINAL_POINT_STEPS_F
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,180);
      --
      DELETE FROM per_spinal_points
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,190);
      --
      DELETE FROM per_parent_spines
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,200);
      --
    end if;
    close csr_get_prs;
    hr_utility.set_location('Leaving: '||l_proc,130);
    --
  end delete_grade_direct;
--
--
  PROCEDURE delete_job_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_job_direct';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_pst
      (c_business_group_id
      PER_POSITION_STRUCTURES.business_group_id%TYPE)
    is
      SELECT null
      FROM   PER_POSITION_STRUCTURES
      WHERE  business_group_id = c_business_group_id;
    --
    cursor csr_get_job
      (c_business_group_id  per_jobs.business_group_id%TYPE)
    is
      SELECT null
      FROM   per_jobs
      WHERE  business_group_id = c_business_group_id;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Check if position structures exist for the
    -- business group
    --
    open csr_get_pst (p_business_group_id);
    fetch csr_get_pst into l_exists;
    if csr_get_pst%found then
      --
      DELETE FROM per_pos_structure_elements pse
      WHERE  pse.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,20);
      --
      DELETE FROM per_pos_structure_versions psv
      WHERE  psv.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,30);
      --
      DELETE FROM per_position_structures ps
      WHERE  ps.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,40);
      --
    end if;
    close csr_get_pst;
    hr_utility.set_location(l_proc,50);
    --
    DELETE FROM per_job_evaluations
    WHERE  business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,60);
    --
    DELETE FROM per_job_requirements
    WHERE  business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,70);
    --
    -- Check if jobs exist for the business group
    --
    open csr_get_job (p_business_group_id);
    fetch csr_get_job into l_exists;
    if csr_get_job%found then
      --
      -- Changes 02-Oct-99 SCNair (per_positions to hr_all_positions_f) date track position req.
      --
      DELETE FROM per_position_extra_info poi
      WHERE  EXISTS (SELECT ''
                     FROM   hr_all_positions_f pos
                     WHERE  pos.position_id = poi.position_id
                     AND    pos.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,75);
      --
      -- PMFLETCH Delete from hr_all_positions_f_tl
      --
      DELETE FROM hr_all_positions_f_tl pft
      WHERE  pft.position_id IN (SELECT psf.position_id
                                    FROM hr_all_positions_f psf
                                   WHERE psf.business_group_id  = p_business_group_id);
      hr_utility.set_location(l_proc,76);
      --
      -- Changes 02-Oct-99 SCNair (delete hr_all_positions_f) date track position req.
      --
      DELETE FROM hr_all_positions_f
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,77);
      --
      DELETE FROM per_positions
      WHERE  business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,80);
      --
      DELETE FROM per_job_extra_info jei
      WHERE  EXISTS (SELECT ''
                     FROM   per_jobs job
                     WHERE  job.job_id = jei.job_id
                     AND    job.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,85);
      --
      hr_utility.set_location(l_proc,86);
      --
      DELETE FROM per_jobs_tl jbt
      WHERE  EXISTS (SELECT ''
                     FROM   per_jobs job
                     WHERE  job.job_id = jbt.job_id
                     AND    job.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,87);
      --
      DELETE FROM per_jobs job
      WHERE  job.business_group_id  = p_business_group_id;
      --
      hr_utility.set_location(l_proc,90);
      --
    end if;
    close csr_get_job;
    --
    DELETE FROM per_job_groups jgr
    WHERE  jgr.business_group_id  = p_business_group_id;
    --
    hr_utility.set_location('Leaving: '||l_proc,100);
    --
  end delete_job_direct;
--
--
--
  PROCEDURE delete_person_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_person_direct';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_person
      (c_business_group_id  per_people_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   per_people_f
      WHERE  business_group_id = c_business_group_id;
    --
    cursor csr_get_aats
      (c_business_group_id
       per_absence_attendance_types.business_group_id%TYPE)
    is
      SELECT null
      FROM   per_absence_attendance_types
      WHERE  business_group_id = c_business_group_id;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Check if a absence attendence types exist
    -- for the business group.
    --
    open csr_get_aats(p_business_group_id);
    fetch csr_get_aats into l_exists;
    if csr_get_aats%found then
      --
      DELETE FROM per_absence_attendances
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,20);
      --
      DELETE FROM per_abs_attendance_reasons
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,30);
      --
      DELETE FROM per_abs_attendance_types_tl t
      WHERE  t.absence_attendance_type_id in
             (select b.absence_attendance_type_id
              from per_absence_attendance_types b
              where b.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,40);
      --
      DELETE FROM per_absence_attendance_types
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,40);
      --
    end if;
    close csr_get_aats;
    hr_utility.set_location(l_proc,50);
    --
    -- Check if a person exists for the business group
    --
    open csr_get_person(p_business_group_id);
    fetch csr_get_person into l_exists;
    if csr_get_person%found then
      --
      DELETE FROM pay_object_groups pog
       WHERE
         SOURCE_TYPE = 'PPF'
       AND
           EXISTS (SELECT ''
                     FROM   per_people_f per
                     WHERE  per.person_id = pog.source_id
                     AND    per.business_group_id = p_business_group_id);
      --
      DELETE FROM per_people_extra_info pei
      WHERE  EXISTS (SELECT ''
                     FROM   per_people_f per
                     WHERE  per.person_id = pei.person_id
                     AND    per.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,55);
      --
      DELETE FROM per_person_analyses
      WHERE  business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,60);
      --
      DELETE FROM per_contact_relationships cr
      WHERE  cr.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,70);
      --
      DELETE FROM per_applications app
      WHERE  app.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,80);
      --
      DELETE FROM per_periods_of_service pos
      WHERE  pos.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,90);
      --
      DELETE FROM per_addresses pa
      WHERE  pa.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,100);
      --
      DELETE FROM per_people_f pp
      WHERE  pp.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,110);
      --
    end if;
    close csr_get_person;
    hr_utility.set_location(l_proc,120);
    --
    DELETE FROM per_person_types
    WHERE  business_group_id = p_business_group_id;
    hr_utility.set_location('Leaving: '||l_proc,130);
    --
  end delete_person_direct;
--
--
  PROCEDURE delete_per_misc(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_person_direct';
    --
    l_exists            varchar2(1);
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    DELETE FROM per_number_generation_controls png
    WHERE png.business_group_id = p_business_group_id;
    hr_utility.set_location('Leaving: '||l_proc,10);
    --
  end delete_per_misc;
--
  PROCEDURE delete_element_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_element_direct';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_ele_types
      (c_business_group_id  pay_element_types_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   pay_element_types_f
      WHERE  business_group_id = c_business_group_id;
    --
    --
    -- Cursor to loop through all input values in order to delete
    -- the database items.
    --
    CURSOR get_input_values is
    SELECT iv.input_value_id input_value_id,
           iv.generate_db_items_flag generate_db_items_flag
    FROM pay_input_values_f iv
    WHERE EXISTS ( SELECT ''
                   FROM   pay_element_types_f pet
                   WHERE  pet.element_type_id = iv.element_type_id
                   AND    pet.business_group_id = p_business_group_id)
    FOR UPDATE;
    --
    -- Cursor to loop through all the element types to delete all the
    -- database items
    --
    CURSOR get_element_types is
    SELECT element_type_id
    FROM pay_element_types_f
    WHERE business_group_id  = p_business_group_id
    FOR UPDATE;
--
  -- This cursor deletes link input values
    CURSOR lev is
    SELECT liv.link_input_value_id
    from   pay_link_input_values_f liv,
           pay_element_links_f     pel
    where  pel.business_group_id  = p_business_group_id
    and    liv.element_link_id       = pel.element_link_id;
  --
  begin
    hr_utility.set_location('Entering: '||l_proc, 10);
    DELETE FROM pay_balance_feeds_f pbf
    WHERE  pbf.business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 20);
    --
    FOR levrec in lev LOOP
      delete from pay_link_input_values_f liv
      where liv.link_input_value_id  = levrec.link_input_value_id;
    END LOOP;
    hr_utility.set_location(l_proc, 30);
    --
    DELETE FROM pay_element_links_f el
    WHERE  el.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 40);
    --
    DELETE FROM pay_element_type_rules etr
    WHERE  EXISTS (SELECT ''
                   FROM   pay_element_sets es
                   WHERE  es.element_set_id = etr.element_set_id
                   AND    es.business_group_id  = p_business_group_id);
    hr_utility.set_location(l_proc, 50);
    --
    DELETE FROM pay_ele_classification_rules ecr
    WHERE  EXISTS (SELECT ''
                   FROM   pay_element_sets es
                   WHERE  es.element_set_id = ecr.element_set_id
                   AND    es.business_group_id  = p_business_group_id);
    hr_utility.set_location(l_proc, 60);
    --
    DELETE FROM pay_element_sets es
    WHERE  es.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 70);
    --
    DELETE FROM pay_sub_classification_rules_f scr
    WHERE  scr.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 80);
    --
    DELETE FROM pay_formula_result_rules_f frr
    WHERE  frr.business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 90);
    --
    DELETE FROM pay_status_processing_rules_f spr
    WHERE  spr.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 90);
    --
    DELETE FROM pay_iterative_rules_f pir
    WHERE  exists (select ''
                     from pay_element_types pet
                    where pir.business_group_id  = p_business_group_id
                      and pet.element_type_id = pir.element_type_id
                  );
    hr_utility.set_location(l_proc, 95);
    --
    -- Check if a element types exist for the business group
    --
    open csr_get_ele_types(p_business_group_id);
    fetch csr_get_ele_types into l_exists;
    if csr_get_ele_types%found then
      --
      -- Loop through and lock all input values within
      -- the business group.
      --
      for iv_rec in get_input_values loop
        --
        -- Delete input values
        --
        DELETE FROM pay_input_values_f
        WHERE CURRENT OF get_input_values;
        --
        delete from pay_input_values_f_tl
         where input_value_id = iv_rec.input_value_id;
        --
      end loop;
      hr_utility.set_location(l_proc, 100);
      --
      for et_rec in get_element_types loop
      --
          -- delete element types
          --
          delete from pay_element_types_f_tl
           where element_type_id = et_rec.element_type_id;
          --
          delete from pay_element_types_f
          where current of get_element_types;
          --
      --
      end loop;
      hr_utility.set_location(l_proc, 110);
      --
    end if;
    close csr_get_ele_types;
    hr_utility.set_location('Leaving: '||l_proc, 120);
    --
  end delete_element_direct;
--
--
  PROCEDURE delete_org_low_detail(p_business_group_id NUMBER)
  IS
  begin
  --
    hr_utility.set_location('hr_delete.delete_org_low_detail',10);
    DELETE FROM pay_grade_rules_f gr
    WHERE  gr.business_group_id  = p_business_group_id;
    --
    hr_utility.set_location('hr_delete.delete_org_low_detail',30);
    DELETE FROM pay_rates  pr
    WHERE  pr.business_group_id = p_business_group_id;
    hr_utility.set_location('hr_delete.delete_org_low_detail',70);
    --
  --
  end delete_org_low_detail;
--
--
  PROCEDURE delete_org_detail(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_org_detail';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_spec_inf_type
      (c_business_group_id  ff_formulas_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   per_special_info_types sit
      WHERE  business_group_id = c_business_group_id;
    --
  begin
  --
    hr_utility.set_location('Entering: '||l_proc,10);
    DELETE FROM pay_wc_rates pwr
    WHERE  pwr.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,20);
    --
    DELETE FROM pay_wc_funds pwf
    WHERE  pwf.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,30);
    --



    --
    -- Check if a special information type exists for the
    -- business group.
    --
    open csr_get_spec_inf_type(p_business_group_id);
    fetch csr_get_spec_inf_type into l_exists;
    if csr_get_spec_inf_type%found then
      --
      DELETE FROM per_special_info_type_usages situ
      WHERE  situ.special_information_type_id =
        (SELECT sit.special_information_type_id
         FROM   per_special_info_types sit
         WHERE  sit.special_information_type_id = situ.special_information_type_id
         AND    sit.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,100);
      --
      DELETE FROM per_special_info_types sit
      WHERE  sit.business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc,110);
      --
    end if;
    close csr_get_spec_inf_type;
    hr_utility.set_location(l_proc,120);
    --
    hr_utility.set_location('Leaving: '||l_proc,200);
    --
  end delete_org_detail;
--
  PROCEDURE delete_payroll_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_payroll_direct';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_bg_payrolls
      (c_business_group_id  pay_payrolls_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   pay_payrolls_f
      WHERE  business_group_id = c_business_group_id;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    -- Check if a payrolls exist for the business group
    --
    open csr_get_bg_payrolls(p_business_group_id);
    fetch csr_get_bg_payrolls into l_exists;
    if csr_get_bg_payrolls%found then
      --
      DELETE FROM pay_org_pay_method_usages_f pmu
      WHERE
        EXISTS ( SELECT ''
                 FROM   pay_payrolls_f pp
                 WHERE  pp.payroll_id = pmu.payroll_id
                 AND    pp.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,30);
      --
      DELETE FROM hr_assignment_set_criteria has
      WHERE
        EXISTS ( SELECT ''
                 FROM   hr_assignment_sets ase
                 WHERE  ase.assignment_set_id = has.assignment_set_id
                 AND    ase.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,40);
      --
      DELETE FROM hr_assignment_sets ase
      WHERE ase.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,50);
      --
      --
      DELETE FROM PER_TIME_PERIODS tim
      WHERE  EXISTS ( SELECT ''
                      FROM   pay_payrolls_f pp
                      WHERE  pp.payroll_id = tim.payroll_id
                      AND    pp.business_group_id = p_business_group_id);
      hr_utility.set_location(l_proc,70);
      --
      DELETE FROM pay_payroll_gl_flex_maps glf
      WHERE  EXISTS ( SELECT ''
                      FROM   pay_payrolls_f pp
                      WHERE  pp.payroll_id = glf.payroll_id
                      AND    pp.business_group_id  = p_business_group_id);
      hr_utility.set_location(l_proc,80);
      --
      DELETE FROM pay_payrolls_f pay
      WHERE  pay.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,90);
      --
    end if;
    close csr_get_bg_payrolls;
    hr_utility.set_location('Leaving: '||l_proc,100);
    --
  --
  end delete_payroll_direct;
--
--
  PROCEDURE delete_balance_direct(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_balance_direct';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_def_bals
      (c_business_group_id  pay_payrolls_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   PAY_DEFINED_BALANCES
      WHERE  business_group_id = c_business_group_id;
    --
    cursor csr_get_bal_types
      (c_business_group_id  pay_payrolls_f.business_group_id%TYPE)
     is
      select balance_type_id
        from pay_balance_types
       where business_group_id = c_business_group_id;
  begin
  --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    DELETE FROM pay_backpay_rules  br
    WHERE EXISTS ( SELECT ''
                   FROM   pay_backpay_sets  bs
                   WHERE  bs.backpay_set_id = br.backpay_set_id
                   AND    bs.business_group_id  = p_business_group_id);
    hr_utility.set_location(l_proc,30);
    --
    DELETE FROM pay_backpay_sets  bs
    WHERE  bs.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,40);
    --
    DELETE FROM pay_balance_set_members bsm
    WHERE EXISTS ( SELECT ''
                   FROM   pay_balance_sets pbs
                   WHERE  pbs.balance_set_id = bsm.balance_set_id
                   AND    pbs.business_group_id = p_business_group_id);
    hr_utility.set_location(l_proc,50);
    --
    DELETE FROM pay_balance_sets pbs
    WHERE  pbs.business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc,60);
    --
    DELETE FROM pay_balance_classifications pbc
    WHERE  pbc.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,70);
    --
    -- Check if a defined balance exists for the business group
    --
    open csr_get_def_bals(p_business_group_id);
    fetch csr_get_def_bals into l_exists;
    if csr_get_def_bals%found then
      --
      DELETE FROM pay_defined_balances pdb
      WHERE  pdb.business_group_id = p_business_group_id;
      hr_utility.set_location(l_proc,80);
      --
    end if;
    close csr_get_def_bals;
    hr_utility.set_location(l_proc,90);
    --
    DELETE FROM pay_balance_dimensions pbd
    WHERE  pbd.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc,100);
    --
    for balrec in csr_get_bal_types(p_business_group_id) loop
      --
      DELETE FROM pay_balance_feeds_f pbf
      WHERE  pbf.balance_type_id = balrec.balance_type_id;
      hr_utility.set_location('Leaving: '||l_proc,90);
      --
      DELETE FROM pay_balance_types_tl pbt
      WHERE  pbt.balance_type_id = balrec.balance_type_id;
      hr_utility.set_location('Leaving: '||l_proc,95);
      --
      DELETE FROM pay_balance_types pbt
      WHERE  pbt.balance_type_id = balrec.balance_type_id;
      hr_utility.set_location('Leaving: '||l_proc,100);
      --
    end loop;
  --
  end delete_balance_direct;
--
--
  PROCEDURE delete_pay_misc(p_business_group_id NUMBER)
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_pay_misc';
    --
    l_exists            varchar2(1);
    --
    cursor csr_get_mess_lines
      (c_business_group_id  pay_payrolls_f.business_group_id%TYPE)
    is
      SELECT null
      FROM   PAY_MESSAGE_LINES
      WHERE  source_id = c_business_group_id
      and    source_type = 'B';
    --
    cursor csr_batch_header (p_bg_id number)
    is
      SELECT pbh.BATCH_ID
      FROM   PAY_BATCH_HEADERS pbh
      WHERE  pbh.BUSINESS_GROUP_ID = p_bg_id;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc, 10);
    DELETE pay_consolidation_sets cs
    WHERE  cs.business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 20);
    --
    DELETE pay_restriction_values rv
    WHERE  EXISTS (SELECT ''
                   FROM   pay_customized_restrictions cr
                   WHERE  cr.customized_restriction_id
                                               = rv.customized_restriction_id
                   AND    cr.business_group_id  = p_business_group_id);
    hr_utility.set_location(l_proc, 30);
    --

    DELETE pay_custom_restrictions_tl crtl
    WHERE  EXISTS (SELECT ''
                   FROM   pay_customized_restrictions cr
                   WHERE  cr.customized_restriction_id
                                               = crtl.customized_restriction_id
                   AND    cr.business_group_id  = p_business_group_id);
    hr_utility.set_location(l_proc, 35);

    ------

    DELETE pay_customized_restrictions cr
    WHERE  cr.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 40);
    --
    DELETE pay_user_column_instances_f uci
    WHERE  uci.business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 50);
    --
    DELETE pay_user_columns uc
    WHERE  uc.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 60);
    --
    DELETE pay_user_rows_f  ur
    WHERE  ur.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 70);
    --
    DELETE pay_user_tables  ut
    WHERE  ut.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 80);
    --
    DELETE pay_element_classifications ec
    WHERE  ec.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 90);
    --
    -- Check if a message lines exist for the business group
    --
    open csr_get_mess_lines(p_business_group_id);
    fetch csr_get_mess_lines into l_exists;
    if csr_get_mess_lines%found then
      --
      DELETE FROM pay_message_lines ml
      WHERE  ml.source_type = 'B'
      AND    ml.source_id = p_business_group_id;
      --
    end if;
    close csr_get_mess_lines;
    hr_utility.set_location(l_proc, 100);
    --
    DELETE FROM pay_freq_rule_periods pfr
    WHERE  pfr.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 110);
    --
    DELETE FROM pay_ele_payroll_freq_rules pef
    WHERE  pef.business_group_id  = p_business_group_id;
    hr_utility.set_location(l_proc, 120);
    --
    FOR bahrec IN csr_batch_header(p_business_group_id) LOOP
      --
      payplnk.purge(bahrec.batch_id);
      --
    END LOOP;
    hr_utility.set_location(l_proc, 130);
    --
    DELETE FROM ben_benefit_contributions_f bbc
    WHERE  bbc.business_group_id  = p_business_group_id;
    --
    DELETE FROM pay_datetracked_events
    WHERE business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 140);
    --
    DELETE FROM pay_event_groups
    WHERE business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 150);
    --
    DELETE FROM pay_event_procedures
    WHERE business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 155);
    --
    DELETE FROM pay_event_updates
    WHERE business_group_id = p_business_group_id;
    hr_utility.set_location(l_proc, 160);
    --
    DELETE FROM pay_dated_tables
    WHERE business_group_id = p_business_group_id;
    --
    hr_utility.set_location('Leaving: '||l_proc, 200);
  end delete_pay_misc;
--
  Procedure delete_qun_misc(p_business_group_id number)
  IS
  --
    l_proc  varchar2(80) := g_package || 'delete_qun_misc';
 --
  BEGIN
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    DELETE from hr_quest_answer_values qsv
    WHERE qsv.quest_answer_val_id in (
     SELECT qv.quest_answer_val_id
       FROM hr_quest_answer_values qv
          , hr_quest_answers qa
      WHERE qa.questionnaire_answer_id = qv.questionnaire_answer_id
        AND qa.business_group_id = P_BUSINESS_GROUP_ID);
    --
    hr_utility.set_location(l_proc,20);
    --
    DELETE from hr_quest_answers qsa
    WHERE qsa.business_group_id = P_BUSINESS_GROUP_ID;
    --
    hr_utility.set_location(l_proc,30);
    --
    DELETE from hr_quest_fields qsf
    WHERE qsf.field_id in (
     SELECT qf.field_id
       FROM hr_quest_fields qf
          , hr_questionnaires qn
      WHERE qf.questionnaire_template_id = qn.questionnaire_template_id
        AND qn.business_group_id = P_BUSINESS_GROUP_ID);
    --
    hr_utility.set_location(l_proc,40);
    --
    DELETE from hr_questionnaires qsn
     WHERE qsn.business_group_id = P_BUSINESS_GROUP_ID;
    --
    hr_utility.set_location(l_proc,50);
    --
    DELETE from per_participants par
     WHERE par.business_group_id = P_BUSINESS_GROUP_ID;
    --
    hr_utility.set_location(l_proc,60);
    --
    DELETE from per_appraisals apr
     WHERE apr.business_group_id = P_BUSINESS_GROUP_ID;
    --
    hr_utility.set_location('Leaving: '||l_proc,70);
    --
  END;
--
  PROCEDURE delete_org_direct(p_business_group_id NUMBER,
                         p_rt_running in VARCHAR2 default 'N')
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_org_direct';
    --
    l_exists            varchar2(1);
    --
    l_organization_id   hr_organization_units.organization_id%TYPE;
    --
    l_security_group_id       per_business_groups.security_group_id%TYPE;
    --
    cursor csr_get_ost
      (c_business_group_id
      PER_ORGANIZATION_STRUCTURES.business_group_id%TYPE)
    is
      SELECT null
      FROM   PER_ORGANIZATION_STRUCTURES
      WHERE  business_group_id = c_business_group_id;
    --
    cursor deltype (p_sec_grp in number) is
    select lookup_type
    from   fnd_lookup_types
    where  security_group_id = p_sec_grp;
    --
  begin
    hr_utility.set_location('Entering: '||l_proc, 10);
    --
    if p_rt_running = 'N' then
    --
    select security_group_id
    into l_security_group_id
    from per_business_groups
    where business_group_id = p_business_group_id;
    --
    hr_utility.set_location('Entering: '||l_proc, 13);
    --
    DELETE  FROM hr_organization_information hoi
    WHERE
      EXISTS
        (SELECT ''
         FROM   hr_organization_units hou
         WHERE  hou.organization_id = hoi.organization_id
         AND    hou.business_group_id = p_business_group_id);
    --
    hr_utility.set_location('Entering: '||l_proc, 14);
    --
    --
    -- Check if the enable_security_groups profile is set to 'Y'
    -- for any applications - if it is then delete the security
    -- group - if not, then leave it
    --
    DECLARE
       CURSOR c_sg_enabled
       IS
       SELECT 'Y'
         FROM fnd_profile_options po
             ,fnd_profile_option_values pov
        WHERE po.profile_option_name = 'ENABLE_SECURITY_GROUPS'
          AND po.profile_option_id = pov.profile_option_id
          AND po.application_id = pov.application_id
          AND pov.level_id = 10002
          AND pov.profile_option_value = 'Y'
          AND to_number(pov.level_value) BETWEEN 800 AND 900;
    --
    l_sg_enabled  BOOLEAN  DEFAULT FALSE;
    --
    BEGIN
      OPEN c_sg_enabled;
      --
      FETCH c_sg_enabled INTO l_exists;
      --
      IF c_sg_enabled%FOUND THEN
         l_sg_enabled := TRUE;
      ELSE
         l_sg_enabled := FALSE;
      END IF;
      --
      CLOSE c_sg_enabled;
      --
      IF l_sg_enabled AND l_security_group_id > 0 THEN
         for typrec in deltype (l_security_group_id) loop
         --
           DELETE FROM fnd_lookup_values
           WHERE security_group_id = l_security_group_id
             AND lookup_type = typrec.lookup_type;
           --
           DELETE  FROM fnd_lookup_types_tl
           WHERE security_group_id = l_security_group_id
             AND lookup_type = typrec.lookup_type;
           --
           DELETE  FROM fnd_lookup_types
           WHERE security_group_id = l_security_group_id
             AND lookup_type = typrec.lookup_type;
           --
         end loop;
         --
         hr_utility.set_location(l_proc, 15);
         --
         DELETE  FROM fnd_security_groups_tl
         WHERE security_group_id = l_security_group_id;
         --
         hr_utility.set_location('Entering: '||l_proc, 16);
         --
         DELETE  FROM fnd_security_groups
         WHERE security_group_id = l_security_group_id;
         --
      END IF;
    END;
    end if;
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check if an organization structure exists for the
    -- business group
    --
    open csr_get_ost(p_business_group_id);
    fetch csr_get_ost into l_exists;
    if csr_get_ost%found then
      --
      DELETE  per_org_structure_elements
      WHERE   business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc, 30);
      --
      DELETE  per_org_structure_versions
      WHERE   business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc, 40);
      --
      DELETE  per_organization_structures
      WHERE   business_group_id  = p_business_group_id;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    close csr_get_ost;
    hr_utility.set_location(l_proc, 60);
    --
    if p_rt_running = 'N' then
    DELETE  hr_organization_units
    WHERE   business_group_id  = p_business_group_id
    AND     organization_id  <> p_business_group_id;
    end if;
    hr_utility.set_location('Leaving: '||l_proc, 100);
  end delete_org_direct;
--
--
  PROCEDURE delete_bg_misc(p_business_group_id NUMBER)
  IS
  --
  -- Bug fix required for 10,5 stand alone
  -- make delete from financials_system_parameters dynamic plsql.
  --
  -- Cursor to find out which of the financials_system_parameters
  -- tables is available
  -- FINANCIALS_SYSTEM_PARAMS_ALL    (10.6 install)
  -- FINANCIALS_SYSTEM_PARAMETERS    (10.5 HR + other apps install)
  -- none                            (10.5 HR only install)
  --The ORDER BY clause ensures we pick up FINANCIALS_SYSTEM_PARAMS_ALL
  --if it's there, ahead of FINANCIALS_SYSTEM_PARAMETERS.
  --
  cursor fsp_table_name is
        select   table_name
        from     user_catalog
        where    table_name in ('FINANCIALS_SYSTEM_PARAMS_ALL',
                                'FINANCIALS_SYSTEM_PARAMETERS')
        order by table_name desc;
  --
  l_fsp_table_name varchar2(30);
  l_sql_text       varchar2(2000);
  l_sql_cursor     number;
  l_rows_processed number;
  --
  begin
  --
    hr_utility.set_location('hr_delete.delete_bg_misc',1);
    hr_utility.set_location('hr_delete.delete_bg_misc',2);
    DELETE per_letter_gen_statuses
    WHERE  business_group_id  = p_business_group_id;
    --
    hr_utility.set_location('hr_delete.delete_bg_misc',4);
    --
    -- Get table name if it exists.
    --
    open  fsp_table_name;
    fetch fsp_table_name into l_fsp_table_name;
    if fsp_table_name%found then
      close fsp_table_name;
		--
      hr_utility.set_location('hr_delete.delete_bg_misc',7);
      --
      -- Define the dynamic cursor.
      --
      l_sql_text := 'delete from '
                        || l_fsp_table_name
                        || ' where business_group_id = '
                        || to_char (p_business_group_id);
      --
      -- Open Cursor for Processing Sql statment.
      --
      l_sql_cursor := dbms_sql.open_cursor;
		--
      hr_utility.set_location('hr_delete.delete_bg_misc',8);
      --
      -- Parse SQL statement.
      --
      dbms_sql.parse(l_sql_cursor, l_sql_text, dbms_sql.v7);
		--
      hr_utility.set_location('hr_delete.delete_bg_misc',9);
      --
      -- Execute the sql
      --
      l_rows_processed := dbms_sql.execute(l_sql_cursor);
		--
      hr_utility.set_location('hr_delete.delete_bg_misc',10);
      --
      -- Close cursor.
      --
      dbms_sql.close_cursor(l_sql_cursor);
		--
      hr_utility.set_location('hr_delete.delete_bg_misc',11);
      --
      --
    else
      close fsp_table_name;
		--
      hr_utility.set_location('hr_delete.delete_bg_misc',12);
    end if;
  end delete_bg_misc;
--
  PROCEDURE delete_upg_details(p_business_group_id NUMBER)
  IS
  --
  begin
  --
    hr_utility.set_location('hr_delete.p_business_group_id',1);
--
    delete from pay_upgrade_status
     where business_group_id = p_business_group_id;
--
    hr_utility.set_location('hr_delete.p_business_group_id',2);
  --
  end delete_upg_details;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_security_list_for_bg >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_security_list_for_bg(p_business_group_id NUMBER)
IS
    --
    l_proc    varchar2(80) := g_package||'delete_security_list_for_bg';
    --
    -- DK 16-SEP-1996 Enabled use of business group index
    -- In development there are lots of business groups
    -- and otherwise it is not a very high cost.
    CURSOR pev IS
    SELECT pp.person_id
    FROM   per_people_f    pp,
           per_person_list pl
    WHERE  pp.person_id  = pl.person_id
    AND    pp.business_group_id = p_business_group_id;
BEGIN
    --
    hr_utility.set_location(l_proc,20);
    --
    DELETE FROM pay_security_payrolls psp
    WHERE  psp.business_group_id =  p_business_group_id;
    hr_utility.set_location(l_proc,30);
    --
    DELETE FROM pay_payroll_list ppl
    WHERE EXISTS ( SELECT ''
                   FROM   pay_payrolls_f pay
                   WHERE  pay.payroll_id = ppl.payroll_id
                   AND    pay.business_group_id = p_business_group_id);
    hr_utility.set_location(l_proc,40);
    --
    FOR pevrec IN pev LOOP
    DELETE FROM per_person_list pl
    WHERE pl.person_id = pevrec.person_id;
    END LOOP;
    hr_utility.set_location(l_proc,50);
    --
    -- Changes 02-Oct-99 SCNair (per_positions to hr_all_positions_f) date track position req.
    --
    DELETE FROM per_position_list pol
    WHERE EXISTS ( SELECT ''
                   FROM   hr_all_positions_f pos
                   WHERE  pos.position_id = pol.position_id
                   AND    pos.business_group_id = p_business_group_id);
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',6);

    -- Bug fix 3622082.
    -- Delete statement modified to improve performance.

    DELETE FROM per_organization_list ol
    WHERE ol.organization_id  IN ( SELECT ou.organization_id
                   FROM   hr_all_organization_units  ou
                   WHERE  ou.business_group_id = p_business_group_id);
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',7);
    DELETE FROM per_security_profiles psp
    WHERE  psp.business_group_id = p_business_group_id
    AND    psp.view_all_flag = 'N';
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',8);
    DELETE FROM per_security_organizations pso
    WHERE pso.organization_id  IN ( SELECT ou.organization_id
                                    FROM   hr_all_organization_units  ou
                                    WHERE  ou.business_group_id = p_business_group_id);
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',9);
    DELETE FROM per_security_users psu
    WHERE psu.security_profile_id  IN (SELECT sp.security_profile_id
                                       FROM   per_security_profiles  sp
                                       WHERE  sp.business_group_id = p_business_group_id);
    --
END delete_security_list_for_bg;
--
  -- The p_preserve_org_information parameter allows this procedure to
  -- be called without deleting the org information and org structures
  -- that have been inserted.  i.e. this preserves the essential
  -- business group information from being deleted. This is important
  -- in at least one testing application.
  PROCEDURE delete_below_bg(p_business_group_id NUMBER,
                         p_preserve_org_information in VARCHAR2 default 'N',
                         p_rt_running in VARCHAR2 default 'N')
  IS
    --
    l_proc    varchar2(80) := g_package||'delete_below_bg';
    --
    l_exists            varchar2(1);
    --
  begin
    hr_utility.set_location('Entering: '||l_proc,5);
    delete_run_types(p_business_group_id);
--
    hr_utility.set_location(l_proc,10);
    delete_security_list_for_bg(p_business_group_id);
    hr_utility.set_location(l_proc,20);
    --
    delete_retro_details(p_business_group_id);
    hr_utility.set_location(l_proc,25);
    --
    delete_mag_structure(p_business_group_id);
    hr_utility.set_location(l_proc,30);
    --
    delete_bal_load_struct(p_business_group_id);
    hr_utility.set_location(l_proc,40);
    --
    delete_formula_direct(p_business_group_id);
    hr_utility.set_location(l_proc,50);
    --
    delete_assign_low_detail(p_business_group_id);
    hr_utility.set_location(l_proc,60);
    --
    delete_assign_detail(p_business_group_id);
    hr_utility.set_location(l_proc,70);
    --
    delete_database_items(p_business_group_id);
    hr_utility.set_location(l_proc,80);
    --
    delete_assign_direct(p_business_group_id);
    hr_utility.set_location(l_proc,90);
    --
    delete_grade_direct(p_business_group_id);
    hr_utility.set_location(l_proc,100);
    --
    delete_job_direct(p_business_group_id);
    hr_utility.set_location(l_proc,110);
    --
    delete_person_direct(p_business_group_id);
    hr_utility.set_location(l_proc,140);
    --
    delete_per_misc(p_business_group_id);
    hr_utility.set_location(l_proc,150);
    --
    delete_element_direct(p_business_group_id);
    hr_utility.set_location(l_proc,160);
    --
    delete_org_low_detail(p_business_group_id);
    hr_utility.set_location(l_proc,170);
    --
    delete_org_detail(p_business_group_id);
    hr_utility.set_location(l_proc,180);
    --
    delete_time_def_direct(p_business_group_id);
    hr_utility.set_location(l_proc,185);
    --
    delete_payroll_direct(p_business_group_id);
    hr_utility.set_location(l_proc,190);
    --
    delete_balance_direct(p_business_group_id);
    hr_utility.set_location(l_proc,200);
    --
    delete_pay_misc(p_business_group_id);
    hr_utility.set_location(l_proc,210);
    --
    delete_qun_misc(p_business_group_id);
    hr_utility.set_location(l_proc,215);
    --
    delete_upg_details(p_business_group_id);
    hr_utility.set_location(l_proc,217);
    --
    -- Caller can choose not to delete business group info.
    if p_preserve_org_information = 'N' then
       delete_org_direct(p_business_group_id,
                         p_rt_running);
       hr_utility.set_location(l_proc,220);
    end if;
    hr_utility.set_location(l_proc,230);
    --
    delete_bg_misc(p_business_group_id);
    hr_utility.set_location('Leaving: '||l_proc,230);
  end delete_below_bg;
--
--
end hr_delete;

/

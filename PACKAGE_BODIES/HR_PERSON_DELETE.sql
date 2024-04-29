--------------------------------------------------------
--  DDL for Package Body HR_PERSON_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_DELETE" AS
/* $Header: peperdel.pkb 120.9.12010000.2 2009/02/23 10:15:14 ghshanka ship $ */
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
11 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_person  (HEADER)

 Description : This package declares procedures required to DELETE
   people on Oracle Human Resources. Note, this
   does not include extra validation provided by calling programs (such
   as screen QuickPicks and HRLink validation) OR that provided by use
   of constraints and triggers held against individual tables.
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    10-AUG-93 TMATHERS             Date Created
 80.0                                   Removed these functions from
                                        peperson, all were created
                                        Pbarry.

 80.1    19-Oct-93 JRhodes           1. Added extra check in weak_predel_val..
                    			and strong_predel_val.. to ensure
			                that a person cannot be deleted if
			                they have a contact who has COBRA
			                enrollments related to the Persons
			                assignment

                                     2. Added extra delete statements in
                    delete_a_person so that any COBRA
                    enrollment records are removed when a
                    contact is removed.
80.2      17-FEB-94  PBARRY    B339    Change HR_PERSDON_DELETE to
                    HR_PERSON_DELETE in locations.
80.3    23-FEB-93  PBARRY    B402    PAY_HOLIDAY* tables removed from R10
                    and R10G.
80.4    11-APR-94 JTHURING              Made changes to 1st select in
                                        product_installed procedure:
                                        (1) stop selecting oracle_username
                                            as it's no longer needed
                    (2) add 'distinct' to select clause
                                        to avoid ORA-1422 when products
                                        installed multiple times
                    (3) don't return 'Y' if install status
                    is 'S'
                    - wwbug 210697
80.5 (70.8)  11-AUG-94 JRHODES   #226211 Changed del from pay_element_entries_f
                                        to improve performance
70.9    01-FEB-95   JRHODES             Delete PER_PAY_PROPOSALS (G1773)
70.10   06-APR-95   JRHODES             Bug 271369
                                        Use effective_start_date in
                                        closed_element_entry_check
70.11   14-jun-95   TMathers            Added moderate_predel_validation
                                        moved all but one test from strong
                                        into moderate, and added call to
                                         moderate in strong after test.
70.12   03-jan-96   AMills              Changed HR_PERSON_DELETE.DELETE_A_
                                        PERSON,35 (pay_assignment_link_usages_f)
                                        to improve performance,
                                        using index instead of F.T.Scan,
                                        Bug 329490.
70.14   03-Jul-96   SXShah        Added call to ota_predel_per_validation
                    to moderate_predel_validation procedure.
70.15   10-Jul-96   AMills              Bug 349818.
                                        Added cursor DELETE_COMPONENTS
                                        to procedure delete_a_person
                                        to delete per_pay_proposal_components
                                        in the case of a multi-component
                                        proposal, to maintain referential
                                        integrity. The original delete from
                                        per_pay_proposals follows as before.
70.16   22-Oct-96   Ty Hayden           Added section to delete phones.
70.17   06-Nov-96   BSanders   410245   Performance modifications to delete
                                        statements replacing the exists statement
                                        with 'in' to prevent full table scan of
                                        delete table.
70.18   14-Nov-96   BSanders   410245   Previous fix had to be applied to version 70.12
70.19   14-Nov-96   BSanders   410245   Reinstate 70.17
110.01  25-Aug-97   mswanson            Remove and aol.person_type = 'E' from
                                        aol_predel_validation.
110.2   13-Oct-97   rfine      563034   Changed parent table name from
                                        PER_PEOPLE_F to PER_ALL_PEOPLE_F
110.3   06-Nov-97   mmillmor   593864   Added pa validation to moderate delete

110.4   18-Mar-98   fychu      642566   Added code to delete_a_person procedure
                                        to delete per_people_extra_info records.
110.5   25-MAR-1998 mmillmor            Added delete from per_performance_reviews for
                                         (in dynamic sql because table
                                        may not exist for some clients)
110.6   16-APR-1998 SASmith             Change to table from
                                        per_assignment_budget_values to
                                        per_assignment_budget_values_f. Required
                                        as table changed to being a datetrack
                                        table.
115.2   12-Jun-98   M Bocutt            Added call to maintain_ptu to delete
                                        PTU records when person deleted.
115.3   13-Aug-98   I Harding           Delete records from the table
                                        per_person_dlvry_methods
115.4   07-Sep-98   smcmilla            Added to delete_a_person to delete from
                                        hr_quest_answer_values,
                                        hr_quest_answers,
                                        per_appraisals,
                                        per_participants.
115.5   08-SEP-98   smcmilla            Disallow delete if orws exist in
                                        PER_APPRAISALS or PER_PARTICIPANTS.
                                        Change made to moderate_predel...
115.6   17-MAR-1999 mmillmor  814301    Altered DELETE_A_PERSON to delete from
                                        per_all_people_f and per_all_assignments_f
115.7   18-MAR-98   CColeman            Added WIP pre-del validation.
115.8   13-APR-99   CCarter   800050    Added pre-del validation for the
                                        following products ENG, AP, FA, PO
                                        and RCV.
115.9   23-JUL-99   Asahay    941591    Modified v_dummy definition to number(3)
115.10  22-Nov-99   Rvydyana            Added delete of per_checklist_items
115.11  10-Mar-00   I Harding           Added contracts_check and called it
                                        from weak_predel and moderate_predel.
                                        Added callto hr_contract_api.maintain_contracts
                                        in delete_a_person to remove contracts.
115.12  15-MAR-00   CDickinson          Added a call to the Work Incident api and
                                        Disability api to delete any child records
115.13  26-JUL-00   CCarter             Added a call to the Roles api to delete
                                any child records.
115.16  19-SEP-2000 VTreiger            Added P_SESSION_DATE to validations to fix
                                        bug 1403481.
115.17  31-OCT-2000 GPERRY              Fixed WWBUG 1294400.
                                        Added in checks for benefits.
115.18  20-DEC-2000 MGettins            Changed Delete_A_person to now also delete
                                        From PER_MEDICAL_ASSESSMENTS.
115.19  08-Aug-2001 Tmathers            Added new weak_predel checks when called
                                        from delete person screen.
115.20  24-AUG-2001 ASahay              Replaced maintain_ptu with
                                        delete_person_type_usage
115.21  30-Aug-2001 rvydyana            added PTU call for default applicant delete
                                        note : no ptu delete reqd in default
                                        person delete procedure as it is not used
115.22  06-AUG-2001 rvydyana  1844844  Added per_qualifications  to the delete
                                       list.
115.23  22-FEB-2002 rmonge    1686922  Added code to delete tax records from
                                       pay_us_emp_fed_tax_rules_f
                                       pay_us_emp_state_tax_rules_f
                                       pay_us_emp_county_tax_rules_f
                                       pay_us_emp_city_tax_rules_f
                                       The deletion process was leaving
                                       orphan rows.
115.24 02-DEC-2002 eumenyio            added the nocopy compiler and also
                                       the WHENEVER OSERROR EXIT FAILURE
                                       ROLLBACK
115.25  03-DEC-2002 pmfletch  MLS      Added delete from per_subjects_taken_tl
                                       for MLS
115.26  03-DEC-2002 pmfletch  MLS      Added delete from per_qualifications_tl
                                       for MLS
115.27  16-JUL-2003 jpthomas  3026024  Added delete from ben_covered_dependents_f.
                                       Delete the entry in the above table for the
                                       contact person whom is getting deleted.
115.29  Sep-2003    mbocutt            ex-person security enhancements.
                                       Remove refs to per_person_list_changes.
                   This file is now dependent on other
                   security changes delivered in Nov 2003 FP.
115.30  10-OCT-2003 njaladi   3183868  Removed the per_periods_of_placement
                                       validation Code in procedure
                                       moderate_pre_del_validation as this check
				       is not required for CWK.
115.31  12-May-2004 bdivvela  3619599  Modified delete queries on tables
                                       hr_quest_answer_values and hr_quest_answers
                                       in delete_a_person procedure
115.32  07-Jun-2004 sbuche    3598568  Modified delete_a_person and people_default_deletes
                                       procedures to call hr_security.delete_per_from_list
                                       procedure for deleting a record in static list
                                       instead of deleting it directly from unsecured
                                       table per_person_list.
115.33  24-Jun-2004 smparame  3732129  Modified delete_a_person procedure. Assignment ids
				       forthe person_id passed fetched into a pl/sql table
				       to improve performance.
115.35  10-Aug-2004 jpthomas  3524713  Modified the procedure moderate_predel_validation in the
				       package HR_PERSON_DELETE to delete the child items from the
				       table BEN_EXT_CHG_EVT_LOG for the selected person.
115.36  14-Mar-2004 njaladi   4169275  Modified procedures strong_pre_del_validation,
                                       moderate_pre_del_validion and weak_pre_del_validation
				       to add parameter of date track mode.
115.37  04-Aug-2005 pchowdav  4508139 Modified procedure strong_pre_del_validation to call
                                      moderate_pre_del_validion if p_dt_delete_mode = 'ZAP'.
115.38  29-Sep-2005 pchowdav  4238025 Modified the procedure
                                      hr_person_delete.moderate_predel_validation
115.39  04-Jan-2006 bshukla   4889068 Performance Fix of SQL ID:14960008
115.40  04-Jan-2006 bshukla   4889068 Performance Fix of SQL ID:14961062,14961042
                                      and 14960478
115.41  19-JAN-2006  vbanner  4873360 Performance Fix of SQL ID:14959971
                                      Rewrote Delete from HR_QUEST_ANSWER_VALUES
				      to avoid a cartesian join and a full
                                      table scan on PER_PARTICIPANTS,
                                      HR_QUEST_ANSWER_VALUES and PER_APPRAISALS.
                                      Broke query into two peices using   			                      Conditional logic in a pl/sql block to see
				      if delete needs to be run.
115.42 27-Jul-2006 pdkundu   5405424  Modified the procedure hr_person_delete.
     	 			      moderate_predel_validation to change the
				      message number for checking secondary assignment
				      status links.
115.43 16-Aug-2006 pdkundu   5464252  Modified the procedure delete_a_person
				                              to add exception handlers.
115.44 20-Nov-2006 risgupta  5464252  Modified the fix done in 115.43 in
                                      procedure delete_a_person to put exception
                                      at correct place.
115.45 05-APR-2007 pdkundu   5945972  Modified the call to Validation for OTA.
115.46 23-Feb-2009 ghshanka  8265994  Modified the procedure delete_a_person added dmls to delete the personal score cards.

 ========================================================================= */
--
  -------------------- BEGIN: product_installed ------------------------------
  /*
    NAME
      product_installed
    DESCRIPTION
      Returns 'Y' if this product is installed, 'N' if not in p_yes_no
      and the ORACLEID of the application in p_oracle_username.
  */
  --
  PROCEDURE product_installed (p_application_short_name    IN varchar2,
                   p_status            OUT NOCOPY varchar2,
                        p_yes_no            OUT NOCOPY varchar2,
                   p_oracle_username    OUT NOCOPY varchar2)
  IS
  --
  BEGIN
    --
    p_yes_no := 'N';
    p_oracle_username := 'DUMMY';
    --
    begin
      select    'Y',
        fpi.status
      into    p_yes_no,
        p_status
      from    fnd_product_installations    fpi
      where    fpi.status = 'I'
      and    fpi.application_id =
        (select    fa.application_id
         from    fnd_application        fa
          where    fa.application_short_name = P_APPLICATION_SHORT_NAME
        );
    exception
      when NO_DATA_FOUND then null;
    end;
    --
  END product_installed;
  -------------------- END: product_installed --------------------------------
  --
  -------------------- BEGIN: person_existance_check -------------------------
  /*
    NAME
      person_existance_check
    DESCRIPTION
      Raises error (and hence falls right out of package) if this person does
      not exist.
  */
  --
  PROCEDURE person_existance_check (p_person_id  number)
  IS
  --
  v_dummy    number(15);
  --
  BEGIN
    select    count(*)
    into    v_dummy
    from    per_all_people_f    p
    where    p.person_id    = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token ('PROCEDURE',
            'PERSON_EXISTANCE_CHECK');
        hr_utility.set_message_token ('STEP', '1');
                hr_utility.raise_error;
  END person_existance_check;
  -------------------- END: person_existance_check ---------------------------
--
  -------------------- BEGIN: pay_predel_validation --------------------------
  /*
    NAME
      pay_predel_validation
    DESCRIPTION
      Ensures that there are no assignments actions for this person other than
      Purge actions. If there are then raise an error and disallow delete.
  */
  --
  PROCEDURE pay_predel_validation (p_person_id    number)
  IS
  --
  v_delete_permitted    varchar2(1);
  --
  BEGIN
     --
     begin
    select    'Y'
    into    v_delete_permitted
    from    sys.dual
    where    not exists (
        select    null
              from    pay_assignment_actions    paa,
            per_assignments_f    ass,
            pay_payroll_actions    ppa
        where    paa.assignment_id    = ass.assignment_id
        and    ass.person_id        = P_PERSON_ID
        and    ppa.payroll_action_id    = paa.payroll_action_id
        and    ppa.action_type        <> 'Z');
     --
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6237_ALL_ASS_ACTIONS_EXIST');
        hr_utility.raise_error;
     end;
     --
  END pay_predel_validation;
  -------------------- END: pay_predel_validation ---------------------------
  --
  -- Start of Fix for WWBUG 1294400
  -------------------- BEGIN: ben_predel_validation --------------------------
  /*
    NAME
      ben_predel_validation
    DESCRIPTION
      Ensures that there are no open life events for a person.
  */
  --
  PROCEDURE ben_predel_validation (p_person_id         NUMBER
                                   ,p_effective_date    DATE)
  IS
  --
  --
  BEGIN
     --
     ben_person_delete.check_ben_rows_before_delete(p_person_id
                                              ,p_effective_date);
     --
  END ben_predel_validation;
  -------------------- END: ben_predel_validation ---------------------------
  -- End of Fix for WWBUG 1294400
  -------------------- BEGIN: aol_predel_validation -------------------------
  /*
    NAME
      aol_predel_validation
    DESCRIPTION
      Foreign key reference check.
  */
  --
  PROCEDURE aol_predel_validation (p_person_id    number)
  IS
  --
  v_delete_permitted    varchar2(1);
  --
  BEGIN
    --
    begin
    select 'Y'
    into    v_delete_permitted
    from    sys.dual
    where    not exists (
        select    null
        from    fnd_user    aol
        where     aol.employee_id    = P_PERSON_ID
        );
     --
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6274_ALL_AOL_PER_NO_DEL');
        hr_utility.raise_error;
     end;
     --
  END aol_predel_validation;
  --------------------  END: aol_predel_validation  -------------------------
  --
  -------------------- BEGIN: assignment_set_check ----------------------------
  /*
    NAME
      assignment_set_check
    DESCRIPTION
      Sets error code and status if this person has any assignments which are
      the only ones in an assignment set and where that assginment is included.
  */
  PROCEDURE assignment_set_check (p_person_id     IN number)
  IS
  --
  v_delete_permitted    varchar2(1);
  --
  BEGIN
    select    'Y'
    into    v_delete_permitted
    from    sys.dual
    where    not exists (
        select    null
        from    per_assignments_f        ass,
            hr_assignment_set_amendments    asa
        where    asa.assignment_id    = ass.assignment_id
        and    ass.person_id        = P_PERSON_ID
        and    asa.include_or_exclude    = 'I'
        and    not exists (
            select    null
            from    hr_assignment_set_amendments    asa2
            where    asa2.assignment_set_id    = asa.assignment_set_id
            and    asa2.assignment_id    <> asa.assignment_id)
        );
  EXCEPTION
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6305_ALL_ASSGT_SET_NO_DEL');
        hr_utility.raise_error;
  --
  END assignment_set_check;
  -------------------- END: assignment_set_check -------------------------
  --
  -------------------- BEGIN: closed_element_entry_check --------------------
  /*
    NAME
      closed_element_entry_check
    DESCRIPTION
      Check that for any element entries that are about to be deleted, the
      element type is not closed for the duration of that entry. Also check
      that if the assignment is to a payroll, the payroll period is not closed.
      If any of these 2 checks fail, the delete is disallowed.
  */
  --
  PROCEDURE closed_element_entry_check (p_person_id    IN number,
                    p_session_date    IN date)
  IS
  --
  cursor THIS_PERSONS_ELEMENT_ENTRIES is
    select    l.element_type_id,
        e.effective_start_date,
        e.effective_end_date,
        a.assignment_id
    from    pay_element_entries_f    e,
        per_assignments_f    a,
        pay_element_links_f    l
    where    a.person_id        = P_PERSON_ID
    and    a.assignment_id        = e.assignment_id
    and    e.effective_start_date between
            a.effective_start_date and a.effective_end_date
    and    e.element_link_id    = l.element_link_id
    and    e.effective_start_date between
            l.effective_start_date and l.effective_end_date;
  --
  BEGIN
    --
    hr_utility.set_location('closed_element_entry_check',1);
    --
    for EACH_ENTRY in THIS_PERSONS_ELEMENT_ENTRIES loop
    hr_entry.chk_element_entry_open(EACH_ENTRY.ELEMENT_TYPE_ID,
                EACH_ENTRY.EFFECTIVE_START_DATE,
                EACH_ENTRY.EFFECTIVE_START_DATE,
                EACH_ENTRY.EFFECTIVE_END_DATE,
                EACH_ENTRY.ASSIGNMENT_ID);
    end loop;
    --
    hr_utility.set_location('closed_element_entry_check',2);
    --
  END closed_element_entry_check;
  -------------------- END: closed_element_entry_check -----------------------
--
  -------------------- BEGIN: contact_cobra_validation -----------------------
  /*
    NAME
      contact_cobra_validation
    DESCRIPTION
      Searches for any contacts of the person being deleted who have
      COBRA Coverage Enrollments which are as a result of the Persons
      Assignments.
  */
  --
  PROCEDURE contact_cobra_validation (p_person_id    number)
  IS
  --
  v_delete_permitted    varchar2(1);
  --
  BEGIN
     --
     begin
    select    'Y'
    into    v_delete_permitted
    from    sys.dual
    where    not exists (
        select    null
        from    per_assignments_f a
        ,       per_contact_relationships c
        ,       per_cobra_cov_enrollments e
                where   a.person_id = P_PERSON_ID
        and     a.assignment_id = e.assignment_id
        and     c.person_id = P_PERSON_ID
        and     c.contact_relationship_id = e.contact_relationship_id);
     --
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6981_ALL_CONT_COBRA_EXISTS');
        hr_utility.raise_error;
     end;
     --
  END contact_cobra_validation;
  -------------------- END: pay_predel_validation ---------------------------
    -------------------- BEGIN: contracts_check -----------------------
  /*
    NAME
      contracts_check
    DESCRIPTION
      Raise an error if related contracts exist for the given person.
  */
  --
  PROCEDURE contracts_check (p_person_id number)
  IS
  --
  v_delete_permitted    varchar2(1);
  --
  begin
  --
  hr_utility.set_location('contracts_check',10);
  --
  -- Check that no child records exist for the
  -- person on per_contracts_f when
  -- the person is deleted
  --
     select   null
     into v_delete_permitted
     from     sys.dual
     where not exists(select   null
                  from     per_contracts_f
                  where    person_id = p_person_id);
  --
     exception
        when NO_DATA_FOUND then
                hr_utility.set_message(800,'PER_52851_PER_NO_DEL_CONTRACTS');
                hr_utility.raise_error;
       --
  END contracts_check;

  --
  -------------------- BEGIN: weak_predel_validation -------------------------
  /*
    NAME
      weak_predel_validation
    DESCRIPTION
      Validates whether a person can be deleted from the HR database.
      This is the weak validation performed prior to delete using the
      Delete Person form.
  */
  --
  PROCEDURE weak_predel_validation (p_person_id        IN number,
                                    p_session_date    IN date,
                                    p_dt_delete_mode    IN varchar2) -- 4169275
  IS
  --
  -- DECLARE THE LOCAL VARIABLES
  --
  v_pay_installed    varchar2(1);
  v_pay_status        varchar2(1);
  v_ben_installed    varchar2(1);
  v_ben_status        varchar2(1);
  v_oracle_id        varchar2(30);
  v_delete_permitted    varchar2(1);
  --
  BEGIN
  --
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',1);
    --
    hr_person_delete.person_existance_check(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',2);
    --
    hr_person_delete.product_installed('PAY', v_pay_status,
    v_pay_installed, v_oracle_id);
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',4);
    --
    -- 4169275 start
    -- During deletion of next change or future change need not require
    -- this validation
    --
    if upper(p_dt_delete_mode) not in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
       hr_person_delete.aol_predel_validation(P_PERSON_ID);
    end if;
    -- 4169275 end
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',5);
    --
    hr_person_delete.assignment_set_check(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',6);
    --
    if (v_pay_installed = 'Y') then
       hr_person_delete.pay_predel_validation(P_PERSON_ID);
    end if;
    --
    -- Removed check for ben install
    -- as OSB can now have enrollment results
    -- and unrestricted Life events in progress
    --
       hr_person_delete.ben_predel_validation(P_PERSON_ID,p_session_date);
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',8);
    --
    hr_person_delete.closed_element_entry_check(P_PERSON_ID, P_SESSION_DATE);
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',9);
    --
    hr_person_delete.contact_cobra_validation(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',10);
    --
    hr_person_delete.contracts_check(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.WEAK_PREDEL_VALIDATION',11);
    --

  END weak_predel_validation;
  -------------------- END: weak_predel_validation --------------------------
--
--
  -------------------- BEGIN: moderate_predel_validation ---------------------
/*
    NAME
      moderate_predel_validation
    DESCRIPTION
      Moderate pre-delete validation called from the Stong_predel_validation
      procedure and HR API's.

*/
  PROCEDURE moderate_predel_validation (p_person_id IN number,
                                      p_session_date IN date,
                                      p_dt_delete_mode    IN varchar2) -- 4169275

  IS
  v_delete_permitted    varchar2(1);
     --
-- Bug 3524713 Starts Here
  CURSOR ben_ext_chg_log (
     p_person_id   NUMBER
     ) IS
     SELECT        ext_chg_evt_log_id
     FROM          ben_ext_chg_evt_log
     WHERE         person_id = p_person_id
     FOR UPDATE OF ext_chg_evt_log_id;
     --
     l_id   NUMBER;
-- Bug 3524713 Ends Here
     --
begin
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 1);
     --
     hr_person_delete.person_existance_check(P_PERSON_ID);
     --
     hr_person_delete.assignment_set_check(P_PERSON_ID);
     --
     --
     -- 4169275 start
     -- During deletion of next change or future change need not require
     -- this validation
     --
     if upper(p_dt_delete_mode) not in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
        hr_person_delete.aol_predel_validation(P_PERSON_ID);
     end if;
     -- 4169275 end
     --
     --
     hr_person_delete.pay_predel_validation(P_PERSON_ID);
     --
     hr_person_delete.ben_predel_validation(P_PERSON_ID,p_session_date);
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 2);
     --
     -- VT 1403481 09/19/00
     begin
     	 -- bug fix 3732129.
	 -- Select statement modified to improve performance.

          select    'Y'
	          into    v_delete_permitted
	          from    sys.dual
	          where    not exists (
	          select    null
	          from    per_letter_request_lines r
	          where    r.person_id    = P_PERSON_ID
	                  and     r.date_from >= P_SESSION_DATE );

	  select    'Y'
	  into    v_delete_permitted
	  from    sys.dual
	  where    not exists (
	        select    null
	        from    per_letter_request_lines r
	         where exists (
	         	select  null
	                from    per_assignments_f a
	                where   a.person_id     = P_PERSON_ID
	                and     a.effective_start_date >= P_SESSION_DATE
	                and     a.assignment_id = r.assignment_id));


        /* select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_letter_request_lines r
        where    r.person_id    = P_PERSON_ID
                and     r.date_from >= P_SESSION_DATE
                or    exists (
                        select  null
                        from    per_assignments_f a
                        where   a.person_id     = P_PERSON_ID
                        and     a.effective_start_date >= P_SESSION_DATE
                        and     a.assignment_id = r.assignment_id));*/


     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6325_ALL_PER_RL_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 3);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_contact_relationships r
        where    r.person_id        = P_PERSON_ID
        or    r.contact_person_id    = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6326_ALL_PER_CR_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 5);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_events e
        where    e.internal_contact_person_id = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6328_ALL_PER_EVENT_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 6);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_bookings b
        where    b.person_id         = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6329_ALL_PER_BOOK_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 7);
     --
     -- VT 1403481 09/19/00
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    1 >= (
        select    count(*)
        from    per_assignments_f a
        where    a.person_id         = P_PERSON_ID
                and     a.effective_start_date > P_SESSION_DATE);-- fix for bug 4238025
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6330_ALL_PER_ASSGT_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 8);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_assignments_f a
        where    a.recruiter_id        = P_PERSON_ID
        or    a.supervisor_id        = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6331_ALL_PER_RT_SUP_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 9);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_periods_of_service    p
        where    p.termination_accepted_person_id = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6332_ALL_PER_TERM_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 10);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_person_analyses a
        where    a.person_id         = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6334_ALL_PER_ANAL_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 11);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_absence_attendances a
        where    a.person_id         = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6335_ALL_PER_ABS_ATT_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 12);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_absence_attendances a
        where    a.authorising_person_id        = P_PERSON_ID
        or    a.replacement_person_id        = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6336_ALL_PER_AUTH_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 13);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_recruitment_activities r
        where    r.authorising_person_id        = P_PERSON_ID
        or    r.internal_contact_person_id    = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6337_ALL_PER_REC_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION',13);
     begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    per_appraisals apr
                where   apr.appraisee_person_id = P_PERSON_ID
                   or   apr.appraiser_person_id = P_PERSON_ID);
     exception
        when NO_DATA_FOUND then
                fnd_message.set_name(801,'PER_52467_APR_PAR_REC_NO_DEL');
                fnd_message.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION',13);
     begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    per_participants par
                where   par.person_id = P_PERSON_ID);
     exception
        when NO_DATA_FOUND then
                fnd_message.set_name(801,'PER_52467_APR_PAR_REC_NO_DEL');
                fnd_message.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 14);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_requisitions r
        where    r.person_id         = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6338_ALL_PER_REQ_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 15);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_vacancies v
        where    v.recruiter_id         = P_PERSON_ID);
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6339_ALL_PER_VAC_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 16);
     --
     --  Any discretionary link element entries?
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    pay_element_entries_f    e,
            per_assignments_f    a,
            pay_element_links_f    l
        where    a.person_id         = P_PERSON_ID
        and    a.assignment_id        = e.assignment_id
        and    e.element_link_id    = l.element_link_id
        and    l.standard_link_flag    = 'N');
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6340_ALL_PER_DISC_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 17);
     --
     --   Any entry adjustments, overrides etc.?
     --   (We cannot capture manual enty of standard link entries)
     --
     begin
        select  'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    pay_element_entries_f   e,
            per_assignments_f       a
        where   a.person_id             = P_PERSON_ID
                and     a.assignment_id         = e.assignment_id
        and    e.entry_type        <> 'E');
     exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801,'HR_6375_ALL_PER_ENTRY_NO_DEL');
                hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 171);
     --
     --  Are the entries to be deleted in a closed period? If so cannot delete.
     --
     hr_person_delete.closed_element_entry_check(P_PERSON_ID, P_SESSION_DATE);
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 18);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_assignment_extra_info i
        where    exists (
            select    null
            from    per_assignments_f a
            where    a.person_id    = P_PERSON_ID
            and    a.assignment_id    = i.assignment_id));
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6341_ALL_PER_ASS_INFO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 19);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_secondary_ass_statuses s
        where    exists (
            select    null
            from    per_assignments_f a
            where    a.person_id    = P_PERSON_ID
            and    a.assignment_id    = s.assignment_id));
     exception
    when NO_DATA_FOUND then
---changed the message number from 6340 to 7407 for bug 5405424
        hr_utility.set_message (801,'HR_7407_ASG_NO_DEL_ASS_STATUS');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 20);
     --
     begin
         select    'Y'
         into    v_delete_permitted
         from    sys.dual
         where    not exists (
        select    null
        from    per_events    e
        where    exists (
            select    null
            from    per_assignments_f a
            where    a.person_id    = P_PERSON_ID
            and    a.assignment_id    = e.assignment_id));
     exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6344_ALL_PER_INT_NO_DEL');
        hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 21);
     --
     begin
        select  'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
        from    per_spinal_point_placements_f    p
        where    exists  (
                        select  null
                        from    per_assignments_f a
                        where   a.person_id     = P_PERSON_ID
                        and     a.assignment_id = p.assignment_id));
     exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801,'HR_6374_ALL_PER_SPINE_NO_DEL');
                hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 22);
     --
     begin
        select  'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    per_quickpaint_result_text t
                where   exists  (
                        select  null
                        from    per_assignments_f a
                        where   a.person_id     = P_PERSON_ID
                        and     a.assignment_id = t.assignment_id));
     exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801,'HR_6379_ALL_PER_QP_NO_DEL');
                hr_utility.raise_error;
     end;
     --
     hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 26);
     --
     begin
        select  'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    per_cobra_cov_enrollments c
        where   exists  (
                        select  null
                        from    per_assignments_f a
                        where   a.person_id     = P_PERSON_ID
                        and     a.assignment_id = c.assignment_id));
     exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801,'HR_6476_ALL_PER_COB_NO_DEL');
                hr_utility.raise_error;
     end;
     --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 27);
    --
    hr_person_delete.contact_cobra_validation(P_PERSON_ID);
    --
    hr_person_delete.contracts_check(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 28);
    -- Validation for BEN
    --
-- Bug 3524713 Starts Here
    OPEN ben_ext_chg_log (
         p_person_id
    );
    --
    LOOP
      FETCH ben_ext_chg_log INTO l_id;
      EXIT WHEN ben_ext_chg_log%NOTFOUND;
      DELETE FROM ben_ext_chg_evt_log
      WHERE  CURRENT OF ben_ext_chg_log;
    END LOOP;
    CLOSE ben_ext_chg_log;
-- Bug 3524713 Ends Here
    --
    ben_person_delete.perform_ri_check(p_person_id);
    --
    -- Validation for OTA.
    --Added for bug 5945972

  if upper(p_dt_delete_mode) not in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE') then
    per_ota_predel_validation.ota_predel_per_validation(P_PERSON_ID);
  end if;

    --
    -- validation for PA
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 29);
    --
    pa_person.pa_predel_validation(P_PERSON_ID);
    --
    -- validation for WIP
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 30);
    --
    wip_person.wip_predel_validation(P_PERSON_ID);
    --
    -- validation for ENG
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 31);
    --
    eng_person.eng_predel_validation(P_PERSON_ID);
    --
    -- validation for AP
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 32);
    --
    ap_person.ap_predel_validation(P_PERSON_ID);
    --
    -- validation for FA
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 33);
    --
    fa_person.fa_predel_validation(P_PERSON_ID);
    --
    -- validation for PO
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 34);
    --
    po_person.po_predel_validation(P_PERSON_ID);
    --
    -- validation for RCV
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 35);
    --
    rcv_person.rcv_predel_validation(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.MODERATE_PREDEL_VALIDATION', 36);
     --
--
end moderate_predel_validation;
  -------------------- END: moderate_predel_validation ---------------------
--
--
  -------------------- BEGIN: strong_predel_validation ---------------------
  /*
    NAME
      strong_predel_validation
    DESCRIPTION
      Called from PERREAQE and PERPEEPI. It performs many checks
      to find if additional data has been entered for this person. It is
      more stringent than weak_predel_validation and ensures that this
      person only has the default data set up by entering a person, contact
      or applicant afresh onto the system.
      If additional data is found then the delete of this person from
      the calling module is invalid as it is beyond its scope. The Delete
      Person form should therefore be used (which only performs
      weak_predel_validation) if a delete really is required.
        p_person_mode  -  'A' check for applicants
                          'E' check for employees
                          'O' check for other types

    NOTE
      No validation is required for security (PER_PERSON_LIST* tables) as
      this is implicit for the person via assignment criteria. The
      rows in these tables can just be deleted.
  */
  PROCEDURE strong_predel_validation (p_person_id    IN number,
                                      p_session_date    IN date,
                                      p_dt_delete_mode    IN varchar2) -- 4169275
  IS
  --
  v_person_types    number;
  --
  BEGIN
     --
     hr_utility.set_location('HR_PERSON_DELETE.STRONG_PREDEL_VALIDATION', 1);
     --
     --   If >1 system person types then non default amendments have been made.
     --   If v_person_types = 0 then only 1 system person type else > 1.
     --
     -- VT 1403481 09/19/00
     select    count(*)
     into    v_person_types
     from    per_people_f p,
                per_person_types ppt
     where      p.person_id     = P_PERSON_ID
     and        p.effective_end_date >= P_SESSION_DATE
     and        p.person_type_id = ppt.person_type_id
     and    exists
        (select    null
         from    per_people_f p2,
            per_person_types ppt2
         where    p2.person_id    = p.person_id
                 and    p2.effective_end_date >= P_SESSION_DATE
         and    p2.person_type_id = ppt2.person_type_id
         and    ppt2.system_person_type <> ppt.system_person_type
        );
     --
     if v_person_types > 0 then
    hr_utility.set_message (801,'HR_6324_ALL_PER_ADD_NO_DEL');
    hr_utility.raise_error;
     end if;
     --
     hr_utility.set_location('HR_PERSON_DELETE.STRONG_PREDEL_VALIDATION', 1);
     --
    -- fix for bug 4508139
    if p_dt_delete_mode = 'ZAP' then
     hr_person_delete.moderate_predel_validation(p_person_id => p_person_id
                                            ,p_session_date =>p_session_date
					    ,p_dt_delete_mode => p_dt_delete_mode -- 4169275
					    );
    end if;
     --
  END strong_predel_validation;
  -------------------- END: strong_predel_validation -----------------------
--
  -------------------- BEGIN: check_contact ---------------------------------
  /*
    NAME
      check_contact
    DESCRIPTION
      Is this contact a contact for anybody else? If so then do nothing.
      If not then check if this person has ever been an employee or
      applicant. If they have not then check whether they have any extra
      info entered for them (other than default info). If they have not
      then delete this contact also. Otherwise do nothing.
    NOTES
      p_person_id        non-contact in relationship
      p_contact_person_id    contact in this relationship - the person
                who the check is performed against.
      p_contact_relationship_id relationship which is currently being
                considered for this contact.
  */
  --
  PROCEDURE check_contact (p_person_id        IN number,
               p_contact_person_id    IN number,
               p_contact_relationship_id IN number,
               p_session_date    IN date)
  IS
  --
  v_contact_elsewhere    varchar2(1);
  v_other_only        varchar2(1);
  v_delete_contact       varchar2(1);
  --
  BEGIN
    --
    hr_utility.set_location('HR_PERSON_DELETE.CHECK_CONTACT', 1);
    --
    hr_person_delete.person_existance_check(P_CONTACT_PERSON_ID);
    --
    begin
        select    'Y'
        into    v_contact_elsewhere
    from    sys.dual
    where    exists (
        select    null
            from    per_contact_relationships r
            where    r.contact_relationship_id <> P_CONTACT_RELATIONSHIP_ID
        and    r.contact_person_id      = P_CONTACT_PERSON_ID);
    exception
    when NO_DATA_FOUND then null;
    end;
    --
    if SQL%ROWCOUNT > 0 then
    return;
    end if;
    --
    hr_utility.set_location('HR_PERSON_DELETE.CHECK_CONTACT', 2);
    --
    begin
        select    'Y'
        into    v_other_only
        from    sys.dual
        where    not exists
            (select null
             from    per_people_f p
             where    p.person_id        = P_CONTACT_PERSON_ID
             and    p.current_emp_or_apl_flag    = 'Y');
    exception
        when NO_DATA_FOUND then return;
    end;
    --
    begin
    --
    --  Can contact be deleted? If strong val errors then just trap
    --  error as we will continue as usual. If it succeeds then delete
    --  contact.
    --
    begin
        v_delete_contact := 'Y';
            hr_person_delete.strong_predel_validation(P_CONTACT_PERSON_ID,
                            P_SESSION_DATE);
    exception
        when hr_utility.hr_error then
            v_delete_contact := 'N';
    end;
    --
        if v_delete_contact = 'Y' then
         hr_person_delete.people_default_deletes(P_CONTACT_PERSON_ID,
                                TRUE);
        end if;
        --
    end;
    --
    --
  END check_contact;
  -------------------- END: check_contact  ---------------------------------
--
  -------------------- BEGIN: delete_a_person --------------------------------
  /*
    NAME
      delete_a_person
    DESCRIPTION
      Validates whether a person can be deleted from the HR database.
      It is assumed that weak_predel_validation and the other application
      *_delete_person.*_predel_valdation procedures have been successfully
      completed first.
      Cascades are all performed according to the locking ladder.
    NOTE
      P_FORM_CALL is set to 'Y' if this procedure is called from a forms
      module. In this case, the deletes are performed post-delete and a
      row therefore may not exist in per_people_f (for this person_id).
      For this reason the existance check will be ignored.
  */
  --
  PROCEDURE delete_a_person (p_person_id        IN number,
                 p_form_call        IN boolean,
                 p_session_date        IN date)
  IS
  --
  cursor THIS_PERSONS_CONTACTS is
    select    contact_person_id,
        contact_relationship_id
    from    per_contact_relationships
    where    person_id    = P_PERSON_ID;
  --
  cursor LOCK_PERSON_ROWS is
    select    person_id
    from    per_people_f
    where    person_id    = P_PERSON_ID
    FOR    UPDATE;
  --
  cursor LOCK_ASSIGNMENT_ROWS is
    select    assignment_id
    from    per_assignments_f
    where    person_id    = P_PERSON_ID
    FOR    UPDATE;
  --
  cursor DELETE_COMPONENTS is
        select  pp.pay_proposal_id
        from    per_pay_proposals pp,
                per_assignments_f pa
        where   pa.person_id       = P_PERSON_ID
        and     pa.assignment_id   = pp.assignment_id
        FOR     UPDATE;
  --
  CURSOR   medical_assessment_records IS
    SELECT medical_assessment_id,
           object_version_number
    FROM   per_medical_Assessments pma
    WHERE  pma.person_id = p_person_id;
  --
  cursor WORK_INCIDENTS is
          select incident_id, object_version_number
          from per_work_incidents
          where person_id =  p_person_id;
  --
  cursor DISABILITIES is
          select disability_id, object_version_number, effective_start_date, effective_end_date
          from per_disabilities_f
          where person_id = p_person_id;
  --
  cursor ROLES is
        select role_id, object_version_number
        from per_roles
        where person_id= p_person_id;

cursor c_ptu is
       	select   distinct person_type_usage_id
--		,ptu.effective_start_date
--		,ptu.object_version_number
	from 	per_person_type_usages_f ptu
	where 	ptu.person_id = p_person_id
	order by person_type_usage_id;

  --
  --   v_dummy              varchar2(1);
  v_dummy                 number(3);  /* Bug 941 591 and 4873360*/
  v_proposal_id           number;
  v_review_cursor         number;
  v_rows_processed        number;
  v_incident_id           per_work_incidents.person_id%TYPE;
  v_object_version_number per_work_incidents.object_version_number%TYPE;
  v_disability_id         per_disabilities_f.disability_id%TYPE;
  v_object_version_no     per_disabilities_f.object_version_number%TYPE;
  v_effective_start_date  per_disabilities_f.effective_start_date%TYPE;
  v_effective_end_date    per_disabilities_f.effective_end_date%TYPE;
  v_ovn_roles             per_roles.object_version_number%TYPE;
  v_role_id               per_roles.role_id%TYPE;
   --
l_person_type_usage_id	per_person_type_usages_f.person_type_usage_id%TYPE;
l_effective_date	per_person_type_usages_f.effective_start_date%TYPE;
l_object_version_number	per_person_type_usages_f.object_version_number%TYPE;
l_effective_start_date	per_person_type_usages_f.effective_start_date%TYPE;
l_effective_end_date	per_person_type_usages_f.effective_end_date%TYPE;

-- bug fix 3732129 starts here.
-- to improve performance assignment id fetched into a pl/sql table.

type assignmentid is table of per_all_assignments_f.assignment_id%type index by binary_integer;
l_assignment_id assignmentid;

Cursor c_asg is
	select distinct assignment_id
	from per_assignments_f
	where person_id = p_person_id;
-- bug fix 3732129 ends here.

  BEGIN
  --
    --
    --
    if P_FORM_CALL = FALSE then
        hr_person_delete.person_existance_check(P_PERSON_ID);
    end if;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 0);
    --
    --  Lock person rows, delete at end of procedure.
    --
    open LOCK_PERSON_ROWS;
    --
    --  Now start cascade.
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1);
    --
    -- bug fix 3732129 starts here.
    -- fetching the assignment ids into a pl/sql table.

    open c_asg;
    fetch c_asg bulk collect into l_assignment_id;
    close c_asg;

    -- bug fix 3732129 ends here.

    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 888);

    begin
    update    per_requisitions r
        set    r.person_id    = null
        where    r.person_id    = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 101);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2);
    --
    begin
       -- bug fix 3732129.
       -- Delete statement modified to improve performance.

     delete    from per_letter_request_lines l
        where    l.person_id     = P_PERSON_ID;

     forall i in 1..l_assignment_id.count
    		delete from per_letter_request_lines l
        	where l.assignment_id = l_assignment_id(i);

    /*
    delete    from per_letter_request_lines l
        where    l.person_id     = P_PERSON_ID
    or    exists (
        select  null
                        from    per_assignments_f a
                        where   a.person_id     = P_PERSON_ID
                        and     a.assignment_id = l.assignment_id);*/
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 201);
    end;
    --
    --  Leave per_letter_requests for the moment - may not be necessary to
    --  delete the parent with no children which requires some work with
    --  cursors.
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3);
    --
    begin
    delete    from per_absence_attendances a
        where    a.person_id    = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 301);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4);
    --
    begin
        update    per_absence_attendances a
        set    a.authorising_person_id    = null
    where    a.authorising_person_id = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 401);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 5);
    --
    begin
    update    per_absence_attendances a
        set    a.replacement_person_id    = null
        where     a.replacement_person_id = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 501);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 6);
    --
    begin
    delete    from per_person_analyses a
        where    a.person_id     = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 601);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 8);
    --
    --  Delete of per_periods_of_service at end after delete of
    --  per_assignments_f.
    --
    begin
    update    per_periods_of_service p
    set    p.termination_accepted_person_id    = null
    where     p.termination_accepted_person_id    = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 801);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 9);
    --
    begin
        update    per_recruitment_activities r
    set    r.authorising_person_id    = null
    where    r.authorising_person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 901);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 10);
    --
    begin
        update  per_recruitment_activities r
        set     r.internal_contact_person_id    = null
    where    r.internal_contact_person_id    =  P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1001);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON',11);
  --
  -- Bug 4873360 fix for performance repository sql id 14959971.
  -- Rewrote the delete query commented out below (and already once tuned for
  -- bug 3619599) to avoid a merge join cartesian and a full table scan on
  -- PER_PARTICIPANTS, HR_QUEST_ANSWER_VALUES and PER_APPRAISALS
  --
  -- Broke query into two peices using conditional logic in a pl/sql block to
  -- see if delete needs to be run.
  --
begin -- Delete from HR_QUEST_ANSWER_VALUES
  begin -- Delete from HR_QUEST_ANSWER_VALUES: PARTICIPANTS
     select 1
     into v_dummy
     from sys.dual
     where exists (
	    select null
	      from per_participants par
	     where par.person_id = P_PERSON_ID);

     if v_dummy = 1
     then
        v_dummy := null;
        delete from hr_quest_answer_values qsv2
         where qsv2.quest_answer_val_id in
       (select qsv.quest_answer_val_id
          from hr_quest_answer_values qsv
              ,hr_quest_answers qsa
              ,per_participants par
          where qsv.questionnaire_answer_id = qsa.questionnaire_answer_id
            and qsa.type_object_id = par.participant_id
            and qsa.type = 'PARTICIPANT'
            and par.person_id = P_PERSON_ID);
     end if;
     hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 215); --added for bug 5464252
  /*Start of bug 5464252*/
  exception
    when NO_DATA_FOUND then
      v_dummy := null;
      hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 211);
  /*End of bug 5464252*/
  end;  -- Delete from HR_QUEST_ANSWER_VALUES: PARTICIPANTS

  begin -- Delete from HR_QUEST_ANSWER_VALUES: APPRAISALS
     select 2
     into v_dummy
     from sys.dual
     where exists (
	    select null
		  from per_appraisals apr
		 where (apr.appraiser_person_id = P_PERSON_ID
            or  apr.appraisee_person_id = P_PERSON_ID));

     if v_dummy = 2
     then
       v_dummy := null;
       delete from hr_quest_answer_values qsv2
         where qsv2.quest_answer_val_id in
       (select qsv.quest_answer_val_id
          from hr_quest_answer_values qsv
              ,hr_quest_answers qsa
              ,per_appraisals apr
         where qsv.questionnaire_answer_id = qsa.questionnaire_answer_id
         and   qsa.type_object_id = apr.appraisal_id
         and   qsa.type='APPRAISAL'
         and   (apr.appraisee_person_id = P_PERSON_ID
         or     apr.appraiser_person_id = P_PERSON_ID));
     end if;
   /* start of bug 5464252 */
	 exception
	   when NO_DATA_FOUND then
	     v_dummy := null;
	     hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 220);
  /* end of bug 5464252 */
   end; -- Delete from HR_QUEST_ANSWER_VALUES: APPRAISALS
end; -- Delete from HR_QUEST_ANSWER_VALUES
-- original sql.
        -- begin
        -- Delete from HR_QUEST_ANSWER_VALUES
/*        delete from hr_quest_answer_values qsv2
        where qsv2.quest_answer_val_id in (
        select qsv.quest_answer_val_id
          from hr_quest_answer_values qsv
             , hr_quest_answers qsa
             , per_appraisals apr
             , per_participants par
         where qsv.questionnaire_answer_id = qsa.questionnaire_answer_id
           and (qsa.type_object_id = apr.appraisal_id
                    and qsa.type='APPRAISAL'
                    and (apr.appraisee_person_id = P_PERSON_ID
                         or  apr.appraiser_person_id = P_PERSON_ID))
            or (qsa.type_object_id = par.participant_id
                    and qsa.type='PARTICIPANT'
                    and  par.person_id = P_PERSON_ID)
             ); -- Fix 3619599
    exception
         when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1101);
    end;
    */
    -- Now delete from HR_QUEST_ANSWERS
    --

    -- fix for the bug 8265994
   BEGIN
   DELETE
   FROM   per_objectives
   WHERE  scorecard_id IN (SELECT scorecard_id
                           FROM   per_personal_scorecards
                           WHERE  person_id = P_PERSON_ID)
    OR    appraisal_id in (SELECT appraisal_id
                           FROM per_appraisals
                           WHERE appraisee_person_id = p_person_id) ;

   DELETE
   FROM  per_scorecard_sharing
   WHERE scorecard_id IN (SELECT scorecard_id
                          FROM   per_personal_scorecards
                          WHERE  person_id = P_PERSON_ID);
   DELETE
   FROM   hr_api_transaction_steps
   WHERE  transaction_id IN (SELECT a.transaction_id
                             FROM   hr_api_transactions a,
                                    per_personal_scorecards sc
                             WHERE  a.transaction_ref_table = 'PER_PERSONAL_SCORECARDS'
                             AND    a.transaction_ref_id = sc.scorecard_id
                             AND    sc.person_id = P_PERSON_ID);

 DELETE
 FROM   hr_api_transactions
 WHERE  transaction_id IN (SELECT transaction_id
                           FROM   hr_api_transactions a,
                                  per_personal_scorecards sc
                           WHERE  a.transaction_ref_table =  'PER_PERSONAL_SCORECARDS'
                           AND    a.transaction_ref_id = sc.scorecard_id
                           AND    sc.person_id = P_PERSON_ID);
   DELETE
   FROM   per_personal_scorecards
   WHERE  person_id =  P_PERSON_ID;

 EXCEPTION
   WHEN Others Then
     hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1111);

 END;
  BEGIN
    DELETE
    FROM per_competence_elements
    WHERE assessment_id  IN (SELECT assessment_id
                             FROM   per_assessments
                             WHERE  appraisal_id  IN (SELECT appraisal_id
                                                      FROM per_appraisals
                                                      WHERE  appraisee_person_id = P_PERSON_ID));
    DELETE
    FROM   per_performance_ratings
    WHERE  appraisal_id  IN (SELECT appraisal_id
                             FROM per_appraisals
                             WHERE  appraisee_person_id = P_PERSON_ID);
    DELETE
    FROM   per_assessments
    WHERE  appraisal_id  IN (SELECT appraisal_id
                             FROM per_appraisals
                             WHERE  appraisee_person_id = P_PERSON_ID);

 EXCEPTION
   WHEN Others Then
     hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1112);
  END;
-- fix for the bug 8265994
--
    begin
        delete from hr_quest_answers qsa2
         where qsa2.questionnaire_answer_id in (
         select qsa.questionnaire_answer_id
           from hr_quest_answers qsa
              , per_participants par
              , per_appraisals apr
          where (qsa.type_object_id = apr.appraisal_id
                      and qsa.type='APPRAISAL'
                     and (apr.appraiser_person_id = P_PERSON_ID
                          or  apr.appraisee_person_id = P_PERSON_ID))
             or (qsa.type_object_id = par.participant_id
                 and qsa.type='PARTICIPANT'
                 and  par.person_id = P_PERSON_ID)
            ); -- Fix 3619599
     exception
          when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1102);
     end;
    --
    -- Now delete from per_participants
    -- SQL Fixed for Performance
    begin
    DELETE
    FROM per_participants par2
    WHERE par2.person_id = P_PERSON_ID
    OR
    (
        par2.participation_in_column = 'APPRAISAL_ID'
        AND par2.participation_in_table = 'PER_APPRAISALS'
        AND par2.participation_in_id in
        (
        SELECT
            apr.appraisal_id
        FROM per_appraisals apr
        WHERE
            (
                apr.appraisee_person_id = P_PERSON_ID
                OR apr.appraiser_person_id = P_PERSON_ID
            )
        )
    );
    exception
         when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1103);
    end;
    --
    -- Now delete from per_appraisals
    --
     begin
       delete from per_appraisals apr
        where --apr.appraiser_person_id = P_PERSON_ID  or    -- changed as part of bug#8265994
        apr.appraisee_person_id = P_PERSON_ID;
    exception
         when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1104);
    end;

    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 12);
    --
    hr_security.delete_per_from_list(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 14);
    --
    begin
        update    per_vacancies v
    set    v.recruiter_id    = null
    where    v.recruiter_id    = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1401);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 15);
    --
    begin
    update    per_assignments_f ass
        set    ass.person_referred_by_id = null
        where    ass.person_referred_by_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1501);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 16);
    --
    begin
    update    per_assignments_f a
        set    a.recruiter_id        = null
        where    a.recruiter_id        = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1601);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 17);
    --
    begin
    update    per_assignments_f a
        set    a.supervisor_id        = null
        where    a.supervisor_id         = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1701);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 18);
    --
    --  LOCK ASSIGNMENTS NOW: have to use cursor as cannot return >1 row for
    --  'into' part of PL/SQL.
    --
    open LOCK_ASSIGNMENT_ROWS;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 185);
    --
    begin
    --
    --  Bug 349818. Delete from per_pay_proposal_components before
    --  deleting from the parent record in per_pay_proposals to
    --  maintain referential integrity, using the cursor DELETE_COMPONENTS
    --  and the original per_pay_proposals delete.
    --
        open DELETE_COMPONENTS;
        LOOP
           FETCH DELETE_COMPONENTS INTO v_proposal_id;
           EXIT WHEN DELETE_COMPONENTS%NOTFOUND;
           DELETE FROM per_pay_proposal_components
              WHERE pay_proposal_id = v_proposal_id;
        END LOOP;
        close DELETE_COMPONENTS;
    --
    --  Now delete the parent proposal record.
    --
       delete  from per_pay_proposals p
        where   exists (
                select  null
                from    per_assignments_f ass
                where   ass.assignment_id       = p.assignment_id
                and     ass.person_id           = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1801);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 19);
    --
    begin
        delete  from pay_personal_payment_methods_f m
        where   m.assignment_id in (
                select ass.assignment_id
                from   per_assignments_f ass
                where  ass.person_id  = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 1901);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 20);
    --
    begin
        delete    from per_assignment_budget_values_f a
        where   a.assignment_id in (
        select    ass.assignment_id
        from    per_assignments_f ass
        where   ass.person_id    = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2001);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 21);
    --
    begin
        delete    from per_assignment_extra_info a
        where   a.assignment_id in (
        select    ass.assignment_id
        from    per_assignments_f ass
        where    ass.person_id        = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2101);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 22);
    --
    begin
        delete    from per_secondary_ass_statuses a
        where   a.assignment_id in (
        select    ass.assignment_id
        from    per_assignments_f ass
        where    ass.person_id        = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2201);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23);
    --
    --  Delete COBRA references and then any contact relationships. COBRA
    --  must be deleted first as PER_COBRA_COV_ENROLLMENTS has a
    --  contact_relationship_id which may be constrained later.
    --
    begin
        delete  from per_cobra_coverage_benefits c2
        where   c2.cobra_coverage_enrollment_id in (
        select    c.cobra_coverage_enrollment_id
        from    per_cobra_cov_enrollments c
        where    exists (
            select  null
                        from    per_assignments_f ass
                        where   ass.assignment_id       = c.assignment_id
                        and     ass.person_id           = P_PERSON_ID)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2301);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 230);
    --
    begin
        delete  from per_cobra_coverage_benefits c2
        where   c2.cobra_coverage_enrollment_id in (
        select    c.cobra_coverage_enrollment_id
        from    per_cobra_cov_enrollments c
        ,       per_contact_relationships r
        where    r.contact_person_id = P_PERSON_ID
        and     c.contact_relationship_id = r.contact_relationship_id
        and     exists (
            select  null
                        from    per_assignments_f ass
                        where   ass.assignment_id       = c.assignment_id
                        and     ass.person_id           = r.person_id)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23001);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 231);
    --
    begin
        delete  from per_cobra_coverage_statuses c2
        where   c2.cobra_coverage_enrollment_id in (
        select    c.cobra_coverage_enrollment_id
        from    per_cobra_cov_enrollments c
        where    exists (
            select  null
                        from    per_assignments_f ass
                        where   ass.assignment_id       = c.assignment_id
                        and     ass.person_id           = P_PERSON_ID)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23101);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 232);
    --
    begin
        delete  from per_cobra_coverage_statuses c2
        where   c2.cobra_coverage_enrollment_id in (
        select    c.cobra_coverage_enrollment_id
        from    per_cobra_cov_enrollments c
        ,       per_contact_relationships r
        where    r.contact_person_id = P_PERSON_ID
        and     c.contact_relationship_id = r.contact_relationship_id
        and     exists (
            select  null
                        from    per_assignments_f ass
                        where   ass.assignment_id       = c.assignment_id
                        and     ass.person_id           = r.person_id)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23201);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 233);
    --
    begin
        delete  from per_sched_cobra_payments c2
        where   c2.cobra_coverage_enrollment_id in (
        select    c.cobra_coverage_enrollment_id
        from    per_cobra_cov_enrollments c
        where    exists (
            select  null
                        from    per_assignments_f ass
                        where   ass.assignment_id       = c.assignment_id
                        and     ass.person_id           = P_PERSON_ID)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23301);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 234);
    --
    begin
        delete  from per_sched_cobra_payments c2
        where   c2.cobra_coverage_enrollment_id in (
        select    c.cobra_coverage_enrollment_id
        from    per_cobra_cov_enrollments c
        ,       per_contact_relationships r
        where    r.contact_person_id = P_PERSON_ID
        and     c.contact_relationship_id = r.contact_relationship_id
        and     exists (
            select  null
                        from    per_assignments_f ass
                        where   ass.assignment_id       = c.assignment_id
                        and     ass.person_id           = r.person_id)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23401);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 235);
    --
    begin
        delete  from per_cobra_cov_enrollments c
    where    c.assignment_id in  (
                        select  ass.assignment_id
                        from    per_assignments_f ass
                        where   ass.person_id           = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23501);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 236);
    --
    begin
        delete  from per_cobra_cov_enrollments c
    where    exists
           (select null
        from   per_contact_relationships r
        where   r.contact_person_id = P_PERSON_ID
        and     c.contact_relationship_id = r.contact_relationship_id
        and exists (
                        select  null
                        from    per_assignments_f ass
                        where   ass.assignment_id       = c.assignment_id
                        and     ass.person_id           = r.person_id)
               );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23601);
    end;
--
--Bug# 3026024 Start Here
--Description : Delete the entry in the table ben_covered_dependents_f for the
--              contact person whom is getting deleted.
--
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 237);
    --
    begin
        delete  from ben_covered_dependents_f c
    	where c.contact_relationship_id in (
    	    select r.contact_relationship_id
    	    from per_contact_relationships r
    	    where r.contact_person_id = p_person_id
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23701);
    end;
--
--Bug# 3026024 End Here
--

    --
    --  If this person has any contacts then check whether they have had any
    --  extra info entered for them. If they have not then delete the
    --  contacts as well. If they do have extra info then just delete the
    --  relationship.
    --
    -- NB If b is created as a contact of b then 2 contact relationships are
    -- are created:  a,b  and  b,a   so that they can be queried in either
    -- direction. Hence must delete both here.
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 237);
    --
    begin
    select    count(*)
    into     v_dummy
    from    per_contact_relationships r
    where    r.person_id        = P_PERSON_ID;
    --
    if v_dummy > 0 then
       for EACH_CONTACT in THIS_PERSONS_CONTACTS loop
        --
        delete    from per_contact_relationships r
        where    (r.person_id = P_PERSON_ID
        and    r.contact_person_id = EACH_CONTACT.CONTACT_PERSON_ID)
        or    (r.person_id = EACH_CONTACT.CONTACT_PERSON_ID
        and    r.contact_person_id = P_PERSON_ID);
        --
             hr_person_delete.check_contact(P_PERSON_ID,
                    EACH_CONTACT.CONTACT_PERSON_ID,
                    EACH_CONTACT.CONTACT_RELATIONSHIP_ID,
                    P_SESSION_DATE);
         end loop;
    end if;
        --
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 23701);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 24);
    --
    begin
        delete    from per_contact_relationships r
        where    r.contact_person_id    = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2401);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 25);
    --
    begin
        delete    from per_addresses a
        where    a.person_id    = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2501);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 25.5);
    --
    begin
        delete    from per_phones a
        where    a.parent_id    = P_PERSON_ID
                and a.parent_table = 'PER_ALL_PEOPLE_F';
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 25501);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 26);
    --
-- we must do this delete in dynamic sql because the per_performance_reviews
-- table will not exist if the database has not been upgraded to new salary admin
-- (introduced April 1998). The procedure would not compile if this was not dynamic.
-- if the table is not found then the error (which starts with 'ORA-00942') is ignored.
    begin
        v_review_cursor:=dbms_sql.open_cursor;
        dbms_sql.parse(v_review_cursor,'DELETE from PER_PERFORMANCE_REVIEWS
                                        where person_id=:x',dbms_sql.v7);
        dbms_sql.bind_variable(v_review_cursor, ':x',P_PERSON_ID);
        v_rows_processed:=dbms_sql.execute(v_review_cursor);
        dbms_sql.close_cursor(v_review_cursor);
    exception
        when NO_DATA_FOUND then dbms_sql.close_cursor(v_review_cursor);
        when OTHERS then
          dbms_sql.close_cursor(v_review_cursor);
          if(substr(sqlerrm,0,9)<>'ORA-00942') then
            raise;
          end if;
    end;
--
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 261);
--
    --  About to delete interview events for assignments. However, must
    --  first delete bookings (interviewers) for those events.
    --
    begin

        -- bug fix 3732129.
	-- Delete statement modified to improve performance.

	forall i in 1..l_assignment_id.count
		delete  from per_bookings b
		where    b.event_id in (select  e.event_id
         				from    per_events e
         				where    e.assignment_id = l_assignment_id(i));

        /*delete  from per_bookings b
        where    b.event_id in
        (select    e.event_id
         from    per_events e
         where    exists (
            select    null
            from    per_assignments_f ass
            where    ass.assignment_id    = e.assignment_id
            and    ass.person_id         = P_PERSON_ID)
        );*/
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 26101);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 262);
    --
    begin
    	-- bug fix 3732129.
    	-- Delete statement modified to improve performance.

    	forall i in 1..l_assignment_id.count
    		delete    from per_events e
        	where    e.assignment_id = l_assignment_id(i);

       /* delete    from per_events e
        where    e.assignment_id in (
                    select ass.assignment_id
                    from   per_assignments_f ass
                    where  ass.person_id           = P_PERSON_ID);*/
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 26201);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 27);
    --
    begin
        update    per_events e
        set    e.internal_contact_person_id    = null
        where    e.internal_contact_person_id    = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2701);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 28);
    --
    begin
        delete    from per_bookings b
        where    b.person_id    = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2801);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 29);
    --
    begin
        delete  from per_quickpaint_result_text q
        where   q.assignment_id in  (
                    select  ass.assignment_id
                    from    per_assignments_f ass
                    where   ass.person_id           = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 2901);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 30);
    --
    --  Validation has already been performed against
    --  hr_assignment_set_amendments in weak_predel_validation.
    --
    begin
        delete    from hr_assignment_set_amendments h
        where  h.assignment_id in     (
                    select  ass.assignment_id
                    from    per_assignments_f ass
                    where   ass.person_id           = P_PERSON_ID);
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3001);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 31);
    --
    begin
        delete  from pay_cost_allocations_f a
        where   a.assignment_id in (
                select  ass.assignment_id
                from    per_assignments_f ass
                where   ass.person_id           = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3101);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 32);
    --
    begin
        delete  from per_spinal_point_placements_f p
    where    p.assignment_id in (
        select  ass.assignment_id
        from    per_assignments_f ass
        where   ass.person_id           = P_PERSON_ID);
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3201);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 33);
    --
    --  Validation has already been performed against
    --  pay_assignment_actions in weak_predel_validation.
    --
    begin
        delete    from pay_assignment_actions a
        where    exists  (
                    select  null
                    from    per_assignments_f ass
                    where   ass.person_id     = P_PERSON_ID
                    and     ass.assignment_id = a.assignment_id);
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3301);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 34);
    --
    begin
        delete    from pay_assignment_latest_balances b
        where   b.assignment_id in  (
                    select  ass.assignment_id
                    from    per_assignments_f ass
                    where   ass.person_id           = P_PERSON_ID);
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3401);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 35);
    --
    begin
        -- bug fix 3732129
        -- Delete statement modified to improve performance.

        forall i in 1..l_assignment_id.count
        	delete  from pay_assignment_link_usages_f u
        		where  u.assignment_id	= l_assignment_id(i);

        /*delete  from pay_assignment_link_usages_f u
        where
        u.assignment_id in (
                   select ass.assignment_id
                   from per_assignments_f ass
                   where ass.person_id = P_PERSON_ID); */
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3501);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 36);
    --
    begin
    delete    from pay_element_entry_values_f v
    where    v.element_entry_id in (
        select    e.element_entry_id
        from    pay_element_entries_f e
        where    exists (
            select    null
            from    per_assignments_f ass
            where    ass.assignment_id    = e.assignment_id
            and    ass.person_id        = P_PERSON_ID)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3601);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 37);
    --
    begin
    delete    from pay_run_results r
    where    r.source_type    = 'E'
    and    r.source_id    in (
        select    e.element_entry_id
        from    pay_element_entries_f e
        where    exists (
            select    null
            from    per_assignments_f ass
            where    ass.assignment_id    = e.assignment_id
            and    ass.person_id        = P_PERSON_ID)
        );
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3701);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 38);
    --
    begin
        delete    from pay_element_entries_f e
        where    e.assignment_id in (
                    select  ass.assignment_id
                    from    per_assignments_f ass
                    where   ass.person_id           = P_PERSON_ID);
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 3801);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 39);
    --
-- Rmonge Bug 1686922 22-FEB-2002
-- Tax records were not being deleted. Therefore, there were orphans rows in
-- the pay_us_fed_tax_rules_f, pay_us_state_tax_rules_f,
-- pay_us_county_tax_rules_f, and pay_us_city_tax_rules_f.
--
    begin

             Delete  pay_us_emp_fed_tax_rules_f peft
             Where   peft.assignment_id   in (
                     select ass.assignment_id
                     from per_assignments_f ass
                     where ass.person_id    = p_person_id );
    exception
          when no_data_found then
          hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON',3802);
   end;

    begin

    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 40);

             Delete  pay_us_emp_state_tax_rules_f pest
             Where   pest.assignment_id   in (
                     select ass.assignment_id
                     from per_assignments_f ass
                     where ass.person_id    = p_person_id );
    exception
          when no_data_found then
          hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON',3803);
   end;

    begin

    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 41);

             Delete  pay_us_emp_county_tax_rules_f pect
             Where   pect.assignment_id   in (
                     select ass.assignment_id
                     from per_assignments_f ass
                     where ass.person_id    = p_person_id );
    exception
          when no_data_found then
          hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON',3804);
   end;

    begin

    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 42);

             Delete  pay_us_emp_city_tax_rules_f pecit
             Where   pecit.assignment_id   in (
                     select ass.assignment_id
                     from per_assignments_f ass
                     where ass.person_id    = p_person_id );
    exception
          when no_data_found then
          hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON',3805);
   end;

    --  Finished, now unlock assignments and delete them.
    --
    close LOCK_ASSIGNMENT_ROWS;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 43);
    --
    begin
        delete    from per_all_assignments_f a
        where    a.person_id     = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4001);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 44);
    --
    begin
    delete    from per_periods_of_service p
        where    p.person_id     = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4101);
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 45);
    --
    begin
    delete    from per_applications a
        where    a.person_id     = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4201);
    end;
    --
    -- 03/18/98 Bug #642566
    -- delete per_people_extra_info records
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 46);
    --
    begin
        delete  from per_people_extra_info  e
        where   e.person_id     = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4301);
    end;
    -- 03/18/98 Change Ends
    --
    -- 03/18/98 Change Ends
    --
    -- 28/5/98
    -- Add delete from per_person_type_usages_f
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON',47);

	for ptu_rec in c_ptu loop

 	select 	min(ptu1.effective_start_date)
	into	l_effective_date
	from 	per_person_type_usages_f ptu1
	where 	ptu1.person_type_usage_id = ptu_rec.person_type_usage_id;

 	select 	ptu2.object_version_number
	into	l_object_version_number
	from 	per_person_type_usages_f ptu2
	where 	ptu2.person_type_usage_id = ptu_rec.person_type_usage_id
	and	ptu2.effective_start_date = l_effective_date;

hr_utility.set_location('l_person_type_usage_id = '||to_char(ptu_rec.person_type_usage_id),44);
hr_utility.set_location('l_effective_date  = '||to_char(l_effective_date,'DD/MM/YYYY'),44);
hr_utility.set_location('l_object_version_number = '||to_char(l_object_version_number),44);
    begin
--        hr_per_type_usage_internal.maintain_ptu(
--                 p_person_id               => p_person_id,
--                 p_action                  => 'DELETE',
--                 p_period_of_service_id    => NULL,
--                 p_actual_termination_date => NULL,
--                 p_business_group_id       => NULL,
--                 p_date_start              => NULL,
--                 p_leaving_reason          => NULL,
--                 p_old_date_start          => NULL,
--                 p_old_leaving_reason      => NULL);

       hr_per_type_usage_internal.delete_person_type_usage
		(p_person_type_usage_id  => ptu_rec.person_type_usage_id
		,p_effective_date	 => l_effective_date
		,p_datetrack_mode 	 => 'ZAP'
		,p_object_version_number => l_object_version_number
		,p_effective_start_date  => l_effective_start_date
		,p_effective_end_date	 => l_effective_end_date
		);
    exception
        when NO_DATA_FOUND then null;
    end;

    	end loop;
    --
    -- delete per_person_dlvry_methods
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 48);
    --
    begin
       delete from per_person_dlvry_methods
       where person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    --  Added this delete for quickhire checklists
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 49);
    begin
       delete from per_checklist_items
       where person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    -- End addition for quickhire checklists
    --
    -- delete per_qualification and per_subjects_taken records
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 50);
    --
    begin

        --PMFLETCH Added delete from tl table
        delete from per_subjects_taken_tl st
         where st.subjects_taken_id IN ( select s.subjects_taken_id
                                           from per_subjects_taken s
                                              , per_qualifications q
                                          where q.person_id = P_PERSON_ID
                                            and s.qualification_id = q.qualification_id
                                       );

        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4698);


        delete from per_subjects_taken s
        where s.qualification_id in ( select qualification_id
                                      from per_qualifications
                                      where person_id = P_PERSON_ID );

        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4699);

        --PMFLETCH Added delete from tl table
        delete from per_qualifications_tl  qt
         where qt.qualification_id in ( select q.qualification_id
                                          from per_qualifications q
                                         where q.person_id = P_PERSON_ID
                                      );

        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4700);

        delete  from per_qualifications  q
        where   q.person_id     = P_PERSON_ID;

    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4701);
    end;
    --

    close LOCK_PERSON_ROWS;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 99);
    --
    begin
    delete    from per_all_people_f
        where    person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4401);
    end;
    --
    -- Now remove contracts
    --
    hr_contract_api.maintain_contracts (
      P_PERSON_ID,
      NULL,
      NULL);
   --
   hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 100);
   --
   -- Now remove Medical Assessments
   --
   FOR mea_rec IN medical_assessment_records LOOP
     --
     per_medical_assessment_api.delete_medical_assessment
       (FALSE
       ,mea_rec.medical_assessment_id
       ,mea_rec.object_version_number);
     --
   END LOOP;
    --
   hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 110);
   --
   --
   -- Now remove disabilities
   --
   open DISABILITIES;
   loop
       fetch DISABILITIES INTO v_disability_id, v_object_version_no, v_effective_start_date, v_effective_end_date;
       EXIT when DISABILITIES%NOTFOUND;
          per_disability_api.delete_disability(false,p_session_date ,'ZAP',v_disability_id, v_object_version_no, v_effective_start_date, v_effective_end_date);
       END LOOP;
    --
   hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 120);
   --
  --
   -- Now remove Work incidences
   --
   open WORK_INCIDENTS;
   loop
       fetch  WORK_INCIDENTS INTO v_incident_id, v_object_version_number;
       EXIT when WORK_INCIDENTS%NOTFOUND;
        per_work_incident_api.delete_work_incident(false,v_incident_id, v_object_version_number);
   END LOOP;
   --
   hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 130);
   --
   --
   --  Now remove Supplementary Roles
   --
   open ROLES;
   loop
      fetch ROLES into v_role_id, v_ovn_roles;
      EXIT when ROLES%notfound;
        per_supplementary_role_api.delete_supplementary_role(false, v_role_id, v_ovn_roles);
   END LOOP;
   --
   hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 150);
   --
   --
    begin
    delete    from per_periods_of_placement p
        where    p.person_id     = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then
        hr_utility.set_location('HR_PERSON_DELETE.DELETE_A_PERSON', 4501);
    end;
   --
 --
--
  END delete_a_person;
  -------------------- END: delete_a_person ----------------------------------
--
  -------------------- BEGIN: people_default_deletes -------------------------
  /*
    NAME
      people_default_deletes
    DESCRIPTION
      Delete routine for deleting information set up as default when people
      are created. Used primarily for delete on PERPEEPI (Enter Person).
      The strong_predel_validation should first be performed to ensure that
      no additional info (apart from default) has been entered.
    NOTE
      See delete_a_person for p_form_call details. Further, p_form_call is
      set to TRUE when this procedure is called from check_contact as
      there is no need to check the existance of the contact.
  */
  --
  PROCEDURE people_default_deletes (p_person_id    IN number,
                    p_form_call    IN boolean)
  IS
  --
  v_assignment_id    number(15);
  --
  cursor LOCK_PERSON_ROWS is
        select  person_id
        from    per_people_f
        where   person_id       = P_PERSON_ID
        FOR     UPDATE;
  --
  BEGIN
    --
    --
    if P_FORM_CALL = FALSE then
    hr_person_delete.person_existance_check(P_PERSON_ID);
    end if;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 1);
    --
    open LOCK_PERSON_ROWS;
    --
    --  Now start cascade.
    --
    -- Start of Fix for WWBUG 1294400
    -- All of benefits is a child of HR and PAY so its safe to delete
    -- benefits stuff first.
    --
    ben_person_delete.delete_ben_rows(p_person_id);
    --
    -- End of Fix for WWBUG 1294400
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 2);
    --
    hr_security.delete_per_from_list(P_PERSON_ID);
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 4);
    --
    --  Lock assignments now, delete at end.
    --  Can select into a variable as max one assignment should exist (as
    --  strong_predel_validation has already been performed).
    --  May not be assignments (for contacts, for eg) so exception.
    --
    begin
        select    ass.assignment_id
    into    v_assignment_id
    from    per_assignments_f ass
    where    ass.person_id    = P_PERSON_ID
    FOR UPDATE;
    exception
    when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 5);
    --
    begin
        delete  from pay_personal_payment_methods p
    where    p.assignment_id = V_ASSIGNMENT_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 6);
    --
    begin
        delete  from per_assignment_budget_values_f v
        where   v.assignment_id = V_ASSIGNMENT_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 7);
    --
    begin
        delete  from per_addresses a
    where    a.person_id    = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.DELETE_DEFAULT_DELETES', 7.5);
    --
    begin
        delete  from per_phones a
        where   a.parent_id     = P_PERSON_ID
                and a.parent_table = 'PER_ALL_PEOPLE_F';
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 8);
    --
    begin
        delete  from pay_cost_allocations_f a
    where    a.assignment_id = V_ASSIGNMENT_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 9);
    --
    begin
    delete    from pay_element_entry_values_f v
    where   exists (
            select   null
            from     pay_element_entries_f e
            where    e.assignment_id = V_ASSIGNMENT_ID
            and      e.element_entry_id = v.element_entry_id);
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 10);
    --
    begin
    delete    from pay_run_results r
    where    r.source_type    = 'E'
    and    EXISTS (
            select null
            from    pay_element_entries_f e
            where    e.assignment_id = V_ASSIGNMENT_ID
                 and e.element_entry_id = r.source_id);
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 11);
    --
    begin
        delete  from pay_element_entries_f e
        where   e.assignment_id = V_ASSIGNMENT_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 12);
    --
    --  No exception, should succeed.
    --
    begin
    delete     from per_assignments_f ass
    where    ass.assignment_id = V_ASSIGNMENT_ID;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 13);
    --
    begin
    delete    from per_periods_of_service p
    where    p.person_id = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 14);
    --
    begin
        delete  from per_applications a
        where    a.person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    --  Added this delete for quickhire checklists
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 17);
    begin
       delete from per_checklist_items
       where person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    -- End addition for quickhire checklists
    --
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 15);
    --
    close LOCK_PERSON_ROWS;
    --
    hr_utility.set_location('HR_PERSON_DELETE.PEOPLE_DEFAULT_DELETES', 16);
    --
    begin
        delete      from per_people_f
        where       person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
   begin
    delete    from per_periods_of_placement p
    where    p.person_id = P_PERSON_ID;
    exception
    when NO_DATA_FOUND then null;
    end;
   --
  --
  END people_default_deletes;
  -------------------- END: people_default_deletes --------------------------
--
  -------------------- BEGIN: applicant_default_deletes ---------------------
  /*
    NAME
      applicant_default_deletes
    DESCRIPTION
      Delete routine for deleting information set up as default when
      applicants are entered.  Used primarily for delete on PERREAQE
      (Applicant Quick Entry). The strong_predel_validation should first be
      performed to ensure that no additional info (apart from default) has
      been entered.
    NOTE
      See delete_a_person for p_form_call details.
  */
  --
  PROCEDURE applicant_default_deletes (p_person_id IN number,
                       p_form_call IN boolean)
  IS
  --
  v_assignment_id       number(15);
  --
  cursor LOCK_PERSON_ROWS is
        select  person_id
        from    per_people_f
        where   person_id       = P_PERSON_ID
        FOR     UPDATE;
  --
  BEGIN
    --
    --
    if P_FORM_CALL = FALSE then
    hr_person_delete.person_existance_check(P_PERSON_ID);
    end if;
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 1);
    --
    open LOCK_PERSON_ROWS;
    --
    --  Now start cascade.
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 3);
    --
    begin
        delete  from per_person_list l
        where    l.person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 5);
    --
    --  Can select into a variable as only one assignment should exist (as
    --  strong_predel_validation has already been performed).
    --
    begin
        select    ass.assignment_id
    into    v_assignment_id
    from    per_assignments_f ass
    where    ass.person_id    = P_PERSON_ID
    FOR UPDATE;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 6);
    --
    begin
        delete  from per_addresses a
        where   a.person_id     = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 6.5);
    --
    begin
        delete  from per_phones a
        where   a.parent_id     = P_PERSON_ID
                and a.parent_table = 'PER_ALL_PEOPLE_F';
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 7);
    --
    begin
    delete     from per_assignments_f ass
    where    ass.assignment_id = V_ASSIGNMENT_ID;
    end;
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 8);
    --
    begin
        delete  from per_applications a
        where    a.person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    --  Added this delete for quickhire checklists
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 15);
    begin
       delete from per_checklist_items
       where person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    -- End addition for quickhire checklists
    --
    --
    --
    --  Added this delete for PTU
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 16);
    begin
       delete from per_person_type_usages_f
       where person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
    --
    -- End addition for PTU
    --
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 9);
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 9);
    --
    close LOCK_PERSON_ROWS;
    --
    hr_utility.set_location('HR_PERSON_DELETE.APPLICANT_DEFAULT_DELETES', 10);
    --
    begin
        delete      from per_people_f
        where       person_id = P_PERSON_ID;
    exception
        when NO_DATA_FOUND then null;
    end;
  --
  END applicant_default_deletes;
  -------------------- END: applicant_default_deletes -----------------------
--
end hr_person_delete;

/

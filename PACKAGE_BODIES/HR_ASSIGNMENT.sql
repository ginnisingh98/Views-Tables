--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT" AS
/* $Header: peassign.pkb 120.11.12010000.8 2009/08/31 12:44:53 ktithy ship $ */
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
 ****************************************************************** */
/*
 Name        : hr_assignment  (BODY)

 Description : This package defines procedures required to
               INSERT, UPDATE and DELETE assignments and all
               associated tables :

                  PER_ASSIGNMENTS_F
                  PER_SECONDARY_ASSIGNMENT_STATUSES
                  PER_ASSIGNMENT_BUDGET_VALUES_F



 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    19-NOV-92 SZWILLIA             Date Created
 70.8    30-DEC-92 SZWILLIA             Added error locations.
 70.9    08-FEB-93 JHOBBS               Changed secondary_asg.. to
          secondary_ass...
 70.10   11-FEB-93 JRHODES              When searching for an assignment
          TERM_ASSIGN row that has been brought
          about by the Employee Termination
          the date to look for should be
          ACTUAL_TERMINATION_DATE + 1 (the day
          after actual termination date).
 70.11   15-FEB-93 JRHODES              In check_term setting of END_DATE
          for DELETE_NEXT_CHANGE was incorrect.
          It now only resets the End DATE to the
          ATD when the current en date is after
          the ATD.
 70.12   16-FEB-93 JHOBBS               Added maintain_alu_asg procedure for
          maintaining alus for the assignment.
 70.13   03-MAR-93 JHOBBS               Removed maintain_alu_asg. It is now in
          hrentmnt.
 70.14   10-MAR-93 JRHODES              Included extra Set_location calls.
          All dates are passed in as type DATE.
          Select for Update when date effectively
          updating the Assignment.
          Added CURSOR to select for
          update Assignment rows in
          DO_PRIMARY_UPDATE
 70.23   11-MAR-93 NKHAN    Added 'exit' to end of code
 70.24   25-MAR-93 JRHODES              Added procedure 'tidy_up_ref_int'
 70.25   27-MAY-93 JRHODES              PER_SECONDARY_ASS_STATUSES are now
          removed when they start after an
          assignment end date.
 70.26   02-JUN-93 JRHODES              PER_SECONDARY_ASS_STATUSES are removed
          totally on ZAP.
          The ref int check on LETTER REQUESTS
          is no longer required - they are
          Auto Shut Down.
 70.27   07-JUN-93 JRHODES              New Procedure 'call_terminate_entries'
 70.31   11-OCT-93 JRHODES              Added extra columns to
          Insert statement in do_primary_update
          Bug No 240
 70.32   12-OCT-93 JRHODES              Fixed referential integrity checking
          omission when assignment
                                        is ENDED by check_term.
 80.3    15-OCT-93 JRHODES              Added check_for_cobra
 80.4    04-NOV-93 PBARRY   Added pay_proposals check for
          del_ref_int_delete.
 80.5    09-DEC-93 JRhodes              New Procedure 'test_for_cancel_reterm'
 80.6    03-Feb-93 JRhodes              Bug 370
 70.32   16-JUN-94 PShergill            Fixed 220466 added ASS_ATTRIBUTE21..30
 70.33   04-Jun-94 JRhodes              Added Validate_Pos
 70.34   26-AUG-94 JRhodes              WWBUG# 232359 -
          added check to del_ref_int_check
          to ensure that Employee ASG cannot be
          removed if they have an earlier
          Applicant ASG
 70.39   28-OCT-94 RFine    Amended load_budget_values to prevent
          one from being loaded if it already
          exists.
 70.40   23-NOV-94 RFine    Suppressed index on business_group_id
 70.41   02-MAR-95 JRhodes              Added order by to select of
                                        periods of service - fix to 265262
 70.42   25-MAY-95 JRhodes              273820
          Fixed insert into budget values
          statement to make better use of
          default_budget_values view
 70.43  21-JUL-95  AForte   Changed tokenised messages to
       AMills   hard coded messages.
          From HR_6401_ASS_DEL_ASS (tokenised)
          To
          HR_7625_ASS_DEL_APP_ASS
          HR_ 7630_ASS_EVE_DEL_ASS
          HR_7633_ASS_EVE_END_ASS
          HR_7634_ASS_LET_DEL_ASS
          HR_7637_ASS_EVE_END_ASS
          HR_7638_ASS_COST_DEL_ASS
          HR_7641_ASS_COST_END_ASS
          HR_7642_ASS_INF_DEL_ASS
          HR_7652_ASS_STAT_DEL_ASS
          HR_7655_ASS_SATA_END_ASS
          HR_7656_ASS_PAY_DEL_ASS
          HR_7659_ASS_PAY_END_ASS
          HR_7664_ASS_ASS_DEL_ASS
          HR_7667_ASS_ASS_END_ASS
          HR_7668_ASS_COBR_DEL_ASS
          HR_7671_ASS_COBR_END_ASS
          HR_7672_ASS_COBRA_DEL_ASS
          HR_7675_ASS_COBRA_END_ASS
 70.44   12-AUG-94 RFine  306211  In the procedure check_ass_for_primary,
          NVL null ATD to EOT - 1 instead of EOT.
          This is because the code adds 1 to the
          value at certain points, and trying to
          add 1 to EOT raises an ORA-1841 error.
          So use Dec 30 instead of Dec 31.
 70.45   02-JUL-96 SXShah               Added call to ota_predel_asg_validation
          for OTA to perform referential integrity
          checks.
 70.46   17-Oct-96 VTreiger  306710     Changed call to terminate_entries_and_
                                        alus.
 70.49   17-Jan-97 JAlloun   424224     Amended cursor get_candidate_primary_ass, so the
                                        effective_start_date is between the session date
                                        and the actual termination date.
                                        Also the per_system_status = ACTIVE_ASSIGN for
                                        the particular assignment.

70.50   18-Mar-98  fychu     642566     1) Removed code in del_ref_int_check
                                           procedure.  APP-07642 error message
                                           is no longer issued if there is
                                           per_assignment_extra_info exists on
                                           a delete.
                                        2) Added code to del_ref_int_delete
                                           procedure to remove
                                           per_assignment_extra_info records
                                           when an assignment is deleted.
110.4   16-APR-1998 SASmith            Due to date tracking of the per_assignment_budget_values_f
                                       table the following changes have been made.
                                       1.load_budget_values parameters changed to include
                                         effective start and end dates and also changed to ensure these
                                         are added when the row is inserted into the db.
                                       2.Procedure del_ref_int_delete. remove the current zap of
                                         per_assignment_budget_values_f and include a delete,zap
                                         and future logic instead. Also change to the '_F' table.
                                       3.delete_ass_ref_int - change to reference the '_F' per_assignment_
                                         budget_values_f.
                                       4.tidy_up_ref_int - new logic to handle change in assignment
                                         effective end date to ensure this cascades to the assignment_
                                         budget_values.
                                         NOTE: As part of these changes no change has been made to del_ref
                                         _int_check. The reason for pointing this out nocopy is potentially a change could
                                         have been included so that any forward dated changes would not
                                         allow the user to delete the row. It was decided that as per_assignment_
                                         budget_values is essentially an attribute of assignment then deletes
                                         should be cascaded.
110.6   23-JUN-1998 mshah     682452     Corrected typo in call to message numbers 7630 and 7633: '...7630)...'
                                         was changed to '...7630...'.

110.7   22-DEC-1998 bgoodsel  679966     Removed restriction in not exists... sub-query that causes
                                         duplicate rows in some circumstances
110.8   07-MAY-1999 achauhan             For Bug# 787633, in del_ref_int_check, added the join to
                                         per_assignments_f to check for the primary assignment. If
                                         it is not a primary assignment then let it get purged.
                                         For Bug# 785427,if the federal tax record exists then the
                                         state, county and city tax records also exist (due to the
                                         defaulting of tax records). So, delete from all 4 table.
                                         In addition, delete from the table pay_us_asg_reporting as
                                         well.
110.9   24-MAY-1999 HWinsor   896943     Added new columns into do_primary_update.
110.10  02-OCT-2001 vsjain               Added new parameters for collective_agreement module
           Like notice period, notice_period_uom, work_at_home,
           employee category and job source
115.12  26-Nov-2001 HSAJJA               Added procedure load_assignment_allocation
115.13  26-Nov-2001 HSAJJA               Added dbdrv command
115.14  30-Nov-2001 HSAJJA               Added per_dflt_asg_cost_alloc_ff
                                         function used to load dflt asg cost
                                         allocations using Fast Formula
115.17  22-JAN-2002 HSAJJA               Changed id_flex_num to to_char(id_flex_num) in
                                         cursor c_cost_allocation_keyflex functions
                                         load_assignment_allocation and
                                         per_dflt_asg_cost_alloc_ff
115.18 13-FEB-02 M Bocutt     1681015   Changed tidy_up_ref_int so that in FUTURE
                                        mode costing records are only opened out
          if there are no future dated records
          present. This prevents overlapping
          records which total over 100%. New OUT
          parameter added to pass this back to
          caller.
115.19 26-FEB-02 MGettins                Added update_primary_cwk as part of
                                         of the contingent labour project.
       08-MAR-02 adhunter               Overloaded gen_new_ass_number
115.20 25-Jun-2002 HSAJJA               Changed proportion decimal pt
                                        from 2 to 4 in
                                        per_dflt_asg_cost_alloc_ff and
                                        load_assignment_allocation
115.22 08-AUG-02 irgonzal     2468916   Modified update_primary procedure.
                                        First call to do_primary_update procedure
                                        converts current primary asg. to a
                                        secondary asg; int his case, the primary flag
                                        has to be 'N'. Second call will convert
                                        the new asg. into a primary asignment.
                                        The p_new_primary_flag parameter is being
                                        ignored.
115.23 15-AUG-02 irgonzal    2437795    Modified tidy_up_ref_int procedure and
                                        added call to reverse_term_emp_tax_records
                                        procedure to ensure tax records get updated
                                        properly.
115.24 04-OCT-02 adhunter    2537091    modify tidy_up_ref_int to remove future payment meths
                                        and end date the "current" one. Remove paymeth check
                                        from del_ref_int_check
115.25 21-NOV-02 dcasemor    2643203    Changed check_ass_for_primary and
                                        get_new_primary_assignment
                                        to handle contingent workers.
115.26 13-nov-02 raranjan               Made nocopy changes.
115.27 07-Nov-02 dcasemor    2468916    Cascaded same change as in 115.22
                                        to update_primary_cwk. This will
                                        go in patch 2643203.
115.28 07-Nov-02 dcasemor    2643203    Changed check_term so that it supports
                                        all date-track operations for CWKs.
115.29 09-Jan-03 dcasemor    2643203    Changed validate_pos so that it
                                        checks for periods of placements in
                                        the case of contingent workers.
115.30 17-Jan-03 dcasemor    2643203    Added 10 missing columns to INSERT
                                        statement in do_primary_update.
115.31 24-Feb-03 MGettins    2806210    Updated tidy_up_ref_int procedure to
                                        end date Assignment Rate records.
115.32 28-Feb-03 dcasemor    2806210    Further changed validate_pos.
115.33 20-Mar-03 skota       2854295    Modified the code that end-dates the
          grade step records.
115.34 29-MAy-03 adudekul    2956160    In del_ref_int_check procedure,
                                        excluded X or BEE type pay assignment
                                        actions while checking for future pay
                                        actions for an Assignment.
115.35 27-AUG-03 bsubrama    306713     In check_term added a check for
                                        NEXT_CHANGE / FUTURE_CHANGE
115.36 27-FEB-04 kjagadee    3335915    Modified proc del_ref_int_delete
115.37 09-Mar-04 njaladi     2371510    Modified proc gen_new_ass_number
                                        to restrict the new assignment number
                                        being generated to length of 30.
115.38 05-May-04 njaladi     3584122    Modified update_primary and update_primary_cwk
                                        procedure.Reverted Back the change done in
                                        115.22 and 115.27 to consider
                                        p_new_primary_flag instead of 'N'
115.39 01-Dec-04 jpthomas    4040403    Modified the procedure DEL_REF_INT_DELETE() in
                                        the package HR_ASSIGNMENT to implement the
                                        DELETE_NEXT_CHANGE and FUTURE_CHANGE for the
                                        Assignment Budget Values records.
115.40 27-DEC-04 kramajey    4071460    Modified the check_hours procedure to
                                        to enable the proper validation
                                        if hours is selected as frequency
115.41 16-Feb-05 jpthomas    4186091    Backedout the changes made for the bug 4040403
115.42 13-Jun-05 hsajja                 Changed cursors c0, c1, c2 in procedure
                                        load_assignment_allocation
115.43 25-Jan-06 bshukla     4946199    Modified DEL_REF_INT_CHECK()
115.44 02-Mar-06 risgupta    4232539    used per_all_assignments_f in place of
                                        per_assignments_f in the function
                                        validate_ass_number of procedure
                                        gen_new_ass_number.
115.47 12-Sep-06 ghshanka    5498344    Modified the procedure gen_new_ass_number.
115.48 26-Oct-06 agolechh    5619940    Modified the procedure gen_probation_end.
115.51 05-nov-07 sidsaxen    6598795    Created update_assgn_context_value and
                                        get_assgn_dff_value new procedures
115.54 05-nov-07 pchowdav    6711256    Modified the procedure gen_new_ass_number.
115.55 02-Jun-08 brsinha     7112709    Modified the procedure del_ref_int_delete.
					Added the IF condition for FUTURE delete mode.
115.56 03-Jun-08 brsinha     7112709    Fix the compilation error.
115.57 27-oct-08 sidsaxen    7503993    Modified query in gen_new_ass_number
                                        to improve performance.
115.58 20-may-08 sathkris    8252045    Modified the cursor csr_dff_context
					in the procedure update_assgn_context_value
115.59 31-AUG-09 ktithy      8710298    Removed hr_utility.set_location calls.
 ================================================================= */
--
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_assignment.';
--
----------------------- gen_probation_end ----------------------------
/*
  NAME
     gen_probation_end
  DESCRIPTION

  PARAMETERS
     p_assignment_id    - assignment_id or NULL if in insert mode
     p_probation_period - probation period, NULL if validating DATE_END
     p_probation_unit   - probation unit, NULL if validating DATE_END
     p_start_date       - Validation start date of the assignment
     p_date_probation_end - User entered date or NULL when default required
*/
PROCEDURE gen_probation_end
         ( p_assignment_id        IN     INTEGER
         , p_probation_period     IN     NUMBER
         , p_probation_unit       IN     VARCHAR2
         , p_start_date           IN     DATE
         , p_date_probation_end   IN OUT NOCOPY DATE
         ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
 check_date NUMBER;
 v_start_date DATE;
 v_date_probation_end DATE;
--
 BEGIN
--
    hr_utility.set_location('hr_assignment.gen_probation_end',1);
    --
    v_start_date := p_start_date;
    v_date_probation_end := p_date_probation_end;
--
    IF v_date_probation_end IS NULL THEN
    --
    -- generate new default probation end date
    --
    hr_utility.set_location('hr_assignment.gen_probation_end',2);
    --
    /*------ changes made for bug 5619940 ---- */
       IF      p_probation_period = 0
         and ( p_probation_unit = 'D'
         or    p_probation_unit = 'W'
         or    p_probation_unit = 'M'
         or    p_probation_unit = 'Y'
             )  THEN
          v_date_probation_end := v_start_date ;
   /*------ changes end for bug 5619940 ---- */
       ELSIF p_probation_unit = 'D' THEN
          v_date_probation_end := v_start_date + p_probation_period -1;
       ELSIF
          p_probation_unit = 'W' THEN
          v_date_probation_end := v_start_date + (p_probation_period * 7) -1;
       ELSIF
          p_probation_unit = 'M' THEN
          v_date_probation_end := ADD_MONTHS(v_start_date
              ,p_probation_period) -1;
       ELSIF
          p_probation_unit = 'Y' THEN
          v_date_probation_end :=ADD_MONTHS(v_start_date
             ,12*p_probation_period) -1;
       END IF;


    --
    --
    ELSIF
       p_assignment_id IS NULL THEN
    --
       hr_utility.set_location('hr_assignment.gen_probation_end',3);
    --
    -- If the Assignment is a new one
    -- ensure that the DATE_PROBATION_END is on or after the assignment
    -- start date
    --
       IF v_date_probation_end < v_start_date THEN
    hr_utility.set_message(801,'HR_6150_EMP_ASS_PROB_END');
    hr_utility.raise_error;
       END IF;
    --
    ELSE
    --
    -- If checking the validity of the DATE_PROBATION_END when the
    -- assignment already exists
    -- ensure that DATE_PROBATION_END is on or after the earliest effective
    -- date for the assignment.
    --
       BEGIN
       --
   hr_utility.set_location('hr_assignment.gen_probation_end',4);
   select v_date_probation_end - min(effective_start_date)
   into   check_date
   from   per_assignments_f
   where  assignment_id = p_assignment_id
   and    assignment_type = 'E';
       --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
       --
       END;
       --
       hr_utility.set_location('hr_assignment.gen_probation_end',5);
       --
       IF check_date < 0 THEN
    hr_utility.set_message(801,'HR_6150_EMP_ASS_PROB_END');
    hr_utility.raise_error;
       END IF;
    --
    END IF;
--
    p_date_probation_end := v_date_probation_end;
--
 END gen_probation_end; ---------------------------------------------
--
--
----------------------- gen_new_ass_sequence -------------------------
/*
  NAME
    gen_new_ass_sequence
  DESCRIPTION
    Generates a new assignment sequence for Applicant and Employee
    Assignments.
*/
PROCEDURE gen_new_ass_sequence
         (  p_person_id       in  number
         ,  p_assignment_type     in  varchar2
         ,  p_assignment_sequence in out nocopy number
         ) is
--
 begin
--
  hr_utility.set_location('hr_assignment.gen_new_ass_sequence',1);
  select nvl(max(assignment_sequence),0) +1
  into   p_assignment_sequence
  from   per_assignments_f
  where  person_id = p_person_id
  and    assignment_type = p_assignment_type;
--
 end gen_new_ass_sequence; ------------------------------------------
--
--
----------------------- gen_new_ass_number ---------------------------
/*
  NAME
    gen_new_ass_number
  DESCRIPTION
    If an Assignment Number is passed to the procedure it validates
    that it is a unique number within the business group.

    If no Assignment Number is passed to the procedure then it determines
    the value of the newxt assignment number. If the assignment sequence
    is 1 then it is just the value of the employee number otherwise it is
    the employee number || assignment sequence. If the generated assignment
    number is not unique then the assignment sequence is incremented until
    a valid assignment number is generated.
*/
PROCEDURE gen_new_ass_number
         (  p_assignment_id       IN    NUMBER
         ,  p_business_group_id   IN    NUMBER
         ,  p_employee_number     IN    VARCHAR2
         ,  p_assignment_sequence IN    NUMBER
         ,  p_assignment_number   IN OUT NOCOPY VARCHAR2
         ) IS
begin
gen_new_ass_number
(  p_assignment_id       => p_assignment_id
,  p_business_group_id   => p_business_group_id
,  p_worker_number       => p_employee_number
,  p_assignment_type     => 'E'
,  p_assignment_sequence => p_assignment_sequence
,  p_assignment_number   => p_assignment_number
 );
end gen_new_ass_number;
--
--
----------------------- gen_new_ass_number ----OVERLOADED-------------
/*
  NAME
    gen_new_ass_number
  DESCRIPTION
    If an Assignment Number is passed to the procedure it validates
    that it is a unique number within the business group.

    If no Assignment Number is passed to the procedure then it determines
    the value of the newxt assignment number. If the assignment sequence
    is 1 then it is just the value of the worker number otherwise it is
    the worker number || assignment sequence. If the generated assignment
    number is not unique then the assignment sequence is incremented until
    a valid assignment number is generated.
*/
PROCEDURE gen_new_ass_number
         (  p_assignment_id       IN    NUMBER
         ,  p_business_group_id   IN    NUMBER
         ,  p_worker_number       IN    VARCHAR2
                           ,  p_assignment_type     IN    VARCHAR2
         ,  p_assignment_sequence IN    NUMBER
         ,  p_assignment_number   IN OUT NOCOPY VARCHAR2
         ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
 loop_count INTEGER;
 ass_seq    NUMBER;
----------------------------------------------------------------
-- DECLARE THE SUB-PROGRAMS
-----------------------------------------------------------------
-- VALIDATE THAT THE ASSIGNMENT NUMBER IS UNIQUE FOR THE PERSON
--
 FUNCTION validate_ass_number
    (  p_assignment_id     INTEGER
    ,  p_business_group_id INTEGER
    ,  p_assignment_number VARCHAR2
    ) RETURN BOOLEAN IS
--
 duplicate VARCHAR2(1);
--
 BEGIN
--
    duplicate := 'N';
--
    BEGIN
--
       hr_utility.set_location('hr_assignment.gen_new_ass_number',1);
       select 'Y'
       into   duplicate
       from sys.dual
       where exists
       ( select 'Y'
           from per_all_assignments_f
        -- from   per_assignments_f commented for bug 4232539
         where  ((p_assignment_id is null)
               or
      (    p_assignment_id is not null
             and assignment_id <> p_assignment_id))
         and    business_group_id + 0 = p_business_group_id
         and    assignment_type = p_assignment_type
         and    assignment_number = p_assignment_number);
--
       EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
--
    END;
--
    RETURN (duplicate = 'N');
--
 END validate_ass_number;
--
 BEGIN
--
  loop_count := 100;
  ass_seq := p_assignment_sequence;
--
  IF p_assignment_number IS NOT NULL THEN
--
  hr_utility.set_location('hr_assignment.gen_new_ass_number',2);
     IF validate_ass_number(p_assignment_id
         ,p_business_group_id
         ,p_assignment_number) THEN
  NULL;
     ELSE
  hr_utility.set_message(801,'HR_6146_EMP_ASS_DUPL_NUMBER');
  hr_utility.raise_error;
     END IF;
--
  ELSE
--
     hr_utility.set_location('hr_assignment.gen_new_ass_number',3);
     WHILE loop_count > 0 LOOP
--
  IF ass_seq = 1 THEN
--     p_assignment_number := p_worker_number;
      p_assignment_number := substr(p_worker_number,1,30); --2371510
        ELSE
	-- fix for the bug 5498344
	-- initialized the sequence with 2 so that the assignments numbers are generated correctly
	--  when whiring exemp with more than one application and hiring into the last one
	if loop_count = 100 then  -- added fix

	  --start changes for bug 6328981
	  -- ass_seq :=2;
       begin
	 /*   select  max(
            case
                when replace(assignment_number,p_worker_number) is null then 2
                else to_number(replace(assignment_number,p_worker_number||'-'))
            end
             ) into ass_seq
         from  per_all_assignments_f
         where person_id = (select distinct person_id
                            from per_all_people_f
                            where employee_number = p_worker_number
                            and business_group_id = p_business_group_id)
          and business_group_id + 0 = p_business_group_id;*/
  --Added for bug 6633320
		--start changes for bug 7503993
		If p_assignment_type = 'E' then
			 select  nvl(max(
			case
			    when replace(assignment_number,p_worker_number) is null then 2
			    else to_number(replace(assignment_number,p_worker_number||'-'))
			end
			 ),2) into ass_seq
			 from  per_all_assignments_f
			 where person_id = (select distinct person_id
					from per_all_people_f
					where employee_number = p_worker_number
					and business_group_id = p_business_group_id)
			 and business_group_id = p_business_group_id
			 and instr(assignment_number,p_worker_number||'-',1) > 0;
		elsif p_assignment_type = 'C' then
			 select  nvl(max(
			case
			    when replace(assignment_number,p_worker_number) is null then 2
			    else to_number(replace(assignment_number,p_worker_number||'-'))
			end
			 ),2) into ass_seq
			 from  per_all_assignments_f
			 where person_id = (select distinct person_id
					from per_all_people_f
					where npw_number = p_worker_number
					and business_group_id = p_business_group_id)
			 and business_group_id = p_business_group_id
			 and instr(assignment_number,p_worker_number||'-',1) > 0;
		end if;
		--end changes for bug 7503993
        exception
            when no_data_found then
                ass_seq :=2;
            when others then
                ass_seq :=2;
        end;

        --end changes for bug 6328981
        end if;
	-- end of fix 5498344
	--
     --2371510
     p_assignment_number := substr(p_worker_number,1,29-length(TO_CHAR(ass_seq)))||'-'||TO_CHAR(ass_seq);
--     p_assignment_number := p_worker_number||'-'||TO_CHAR(ass_seq);
        END IF;
--
  hr_utility.set_location('hr_assignment.gen_new_ass_number',4);
        IF validate_ass_number(p_assignment_id
                ,p_business_group_id
            ,p_assignment_number) THEN
     EXIT;
        ELSE
     ass_seq := ass_seq + 1;
     loop_count := loop_count - 1;
        END IF;
--
     END LOOP;
--
     hr_utility.set_location('hr_assignment.gen_new_ass_number',5);
     IF loop_count = 0 THEN
  hr_utility.set_message(801,'HR_6148_EMP_ASS_LOOP_OUT');
  hr_utility.raise_error;
     END IF;
--
  END IF;
--
 END gen_new_ass_number; ---------------------------------------------
--
--
----------------------- check_hours ----------------------------------
/*
  NAME
     check_hours
  DESCRIPTION
     Validation to ensure that the normal working hours do not exceed
     the maximum availble for the Frequency.
  PARAMETERS
     p_frequency        - Standard Conditions PER field
      - only D,W,M,Y are valid values
     p_normal_hours     - Standard Conditions WORKING HOURS field
*/
PROCEDURE check_hours
         ( p_frequency            IN     VARCHAR2
         , p_normal_hours         IN     NUMBER
         ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
 no_of_hours NUMBER;
--
 BEGIN
--
    hr_utility.set_location('hr_assignment.check_hours',1);
    IF    p_frequency = 'D' THEN
       no_of_hours := 24;
    ELSIF p_frequency = 'W' THEN
       no_of_hours := 168;
    ELSIF p_frequency = 'M' THEN
       no_of_hours := 744;
    ELSIF p_frequency = 'Y' THEN
       no_of_hours := 8784;
    ELSIF p_frequency = 'H' THEN
       no_of_hours := 1;
    ELSE
       no_of_hours := 0;
    END IF;
--
    IF no_of_hours - p_normal_hours < 0 THEN
       hr_utility.set_message(801,'HR_6015_ALL_FORMAT_WKG_HRS');
       hr_utility.raise_error;
    END IF;
--
 END check_hours; -----------------------------------------------------
--
--
------------------- check_term -----------------------------
/*
  NAME
     check_term
  DESCRIPTION
     If an Update Override, Delete Next Change or Future Change Delete
     will remove terminated assignments or end dates after
     assignment status changes of TERM_ASSIGN then the end date may need
     to be fixed to either the Actual Termination Date or the Final
     Process Date or the Employees Period of Service. This procedure
     determines the requirement and returns an new End Date if one is
     required.
  PARAMETERS
     p_period_of_service_id - Employee's Current Period of Service ID
     p_assignment_id    - Assignment ID
     p_sdate                - Start Date of current Assignment row
     p_edate              - End Date of current Assignment row
     p_current_status           - The PER_SYSTEM_STATUS of the current row
     p_mode     - FUTURE_CHANGES, DELETE_NEXT_CHANGE,
          UPDATE_OVERRIDE
     p_newdate                  - The New ASsignment End Date
*/
PROCEDURE check_term
          (
           p_period_of_service_id IN INTEGER
                            ,p_assignment_id IN INTEGER
          ,p_sdate IN DATE
          ,p_edate IN DATE
          ,p_current_status IN VARCHAR2
          ,p_mode IN VARCHAR2
                        ,p_newdate OUT NOCOPY DATE
          ) IS
p_atd                 DATE;
p_fpd                 DATE;
p_ass_end_date        DATE;
p_first_term_date     DATE;
p_start_date          DATE;
p_end_date            DATE;
p_new_ass_end_date    DATE;
p_flag                VARCHAR2(1);
p_next_eff_start_date DATE;
p_next_eff_end_date   DATE;
l_person_id           NUMBER;
l_assignment_type     per_all_assignments_f.assignment_type%TYPE;
l_pdp_date_start      DATE;

--
-- Fetch the person ID and assignment type so the
-- period of placement can be obtained for
-- contingent workers.
--
CURSOR csr_get_assignment_info IS
SELECT paaf.person_id
      ,paaf.assignment_type
      ,paaf.period_of_placement_date_start
FROM   per_all_assignments_f paaf
WHERE  paaf.assignment_id = p_assignment_id
AND    paaf.assignment_type IN ('E', 'C');

--
-- Get the termination dates for the period of placement and
-- period of service.
--
CURSOR csr_get_term_dates IS
SELECT actual_termination_date
      ,NVL(final_process_date, hr_api.g_eot)
FROM   per_periods_of_service
WHERE  period_of_service_id = p_period_of_service_id
UNION
SELECT pdp.actual_termination_date
      ,NVL(pdp.final_process_date, hr_api.g_eot)
FROM   per_periods_of_placement pdp
WHERE  pdp.person_id = l_person_id
AND    pdp.date_start = l_pdp_date_start;


BEGIN
--
   hr_utility.set_location('hr_assignment.check_term',1);
   p_start_date := p_sdate;
   p_end_date   := p_edate;
   p_new_ass_end_date := null;

  --
  -- Fetch the desired assignment details.
  --
  OPEN  csr_get_assignment_info;
  FETCH csr_get_assignment_info INTO l_person_id
                                    ,l_assignment_type
                                    ,l_pdp_date_start;
  CLOSE csr_get_assignment_info;

  --
  -- Fetch the termination dates.
  --
  OPEN  csr_get_term_dates;
  FETCH csr_get_term_dates INTO p_atd
                               ,p_fpd;
  CLOSE csr_get_term_dates;

   hr_utility.set_location('hr_assignment.check_term',2);

   IF p_atd IS NULL THEN null;
   ELSE
   --
      -------------------------------------
      -- Get the Effective End Date of the Assignment
      -------------------------------------
      hr_utility.set_location('hr_assignment.check_term',3);
      --
      select max(effective_end_date)
      into   p_ass_end_date
      from   per_assignments_f
      where  assignment_id = p_assignment_id;
      --
      -------------------------------------
      -- Get the Start Date of the First TERM_ASSIGN status.
      --
      -- If the mode is UPDATE_OVERRIDE and the current status is TERM_ASSIGN
      -- then compare the session date with the earliest TERM_ASSIGN date
      -- and store the earliest.
      -------------------------------------
      hr_utility.set_location('hr_assignment.check_term',4);
      --
      select min(a.effective_start_date)
      into   p_first_term_date
      from   per_assignments_f a
      where  a.assignment_id = p_assignment_id
      and    exists ( select null
                      from   per_assignment_status_types s
                      where  s.assignment_status_type_id
                         = a.assignment_status_type_id
                      and    s.per_system_status = 'TERM_ASSIGN');
   --
      hr_utility.set_location('hr_assignment.check_term',5);
      IF p_mode = 'UPDATE_OVERRIDE' AND
         p_current_status = 'TERM_ASSIGN' THEN
   --
         IF p_first_term_date IS NULL OR
           (p_first_term_date IS NOT NULL AND p_first_term_date > p_start_date)
         THEN
            p_first_term_date := p_start_date;
         END IF;
   --
      END IF;
--
      ---------------------------------------------------------------
      -- If the mode is UPDATE_OVERRIDE or FUTURE_CHANGE
      -- then establish whether this will remove a TERM_ASSIGN
      -- status on the day after ACTUAL_TERMINATION_DATE
      --
      -- If it does then issue an error
      --
      -- NB The same check is performed slightly differntly
      -- for DELETE_NEXT_CHANGE below
      ---------------------------------------------------------------

      -- Bug 306713 Start

      IF (p_mode = 'DELETE_NEXT_CHANGE' or p_mode = 'FUTURE_CHANGE') and p_ass_end_date = p_atd then
        hr_utility.set_message(801,'HR_6200_EMP_ASS_TERM_EXISTS');
        hr_utility.raise_error;
      end if;

      -- Bug 306713 End

      IF (p_mode = 'UPDATE_OVERRIDE' or p_mode = 'FUTURE_CHANGE')
   AND p_start_date < p_atd + 1 THEN
   --
   hr_utility.set_location('hr_assignment.check_term',6);
   --
   p_flag := 'N';
   --
   BEGIN
   --
         hr_utility.set_location('hr_assignment.check_term',7);
   --
      select 'Y'
      into   p_flag
      from   per_assignments_f a
      where  a.assignment_id = p_assignment_id
      and    a.effective_start_date = p_atd + 1
      and    exists
        (select null
         from   per_assignment_status_types s
         where  s.assignment_status_type_id
         = a.assignment_status_type_id
                     and    s.per_system_status = 'TERM_ASSIGN');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
   --
   hr_utility.set_location('hr_assignment.check_term',8);
   IF p_flag = 'Y' THEN
      hr_utility.set_message(801,'HR_6200_EMP_ASS_TERM_EXISTS');
      hr_utility.raise_error;
         END IF;
      END IF;
      --
      ---------------------------------------------------------------
      -- If mode is UPDATE_OVERRIDE then
      --   if end date of assignment is before actual_termination_date
      --      then don't do anything
      --   otherwise
      --   if the session date is on or after the first termination date
      --      then don't do anything
      --   otherwise
      --      set the new_assignment_end_date = actual_termination_date
      ---------------------------------------------------------------
      IF p_mode = 'UPDATE_OVERRIDE' THEN
   hr_utility.set_location('hr_assignment.check_term',9);
   IF p_ass_end_date <= p_atd THEN
      NULL;
         ELSE
      hr_utility.set_location('hr_assignment.check_term',10);
      IF p_first_term_date <= p_start_date THEN
         NULL;
            ELSE
         p_new_ass_end_date := p_atd;
      END IF;
         END IF;
      --
      ---------------------------------------------------------------
      -- If mode is FUTURE_CHANGE then
      --   if the first termination date is on or before the current start date
      --      then open the assignment up to the final process date
      --   otherwise
      --           open the assignment up to the actual term date.
      ---------------------------------------------------------------
      ELSIF
   p_mode = 'FUTURE_CHANGE' THEN
   hr_utility.set_location('hr_assignment.check_term',11);
   IF p_first_term_date <= p_start_date THEN
      p_new_ass_end_date := p_fpd;
         ELSE
      p_new_ass_end_date := p_atd;
   END IF;
      --
      ---------------------------------------------------------------
      -- If mode is DELETE_NEXT_CHANGE then
      --    IF the current row is the last for this assignment
      --       then the end date will be removed by the DELETE NEXT CHANGE
      --       in this case make sure the end date is reset correctly
      --   i.e.
      --   if the first termination date is on or before the current start date
      --      then open the assignment up to the final process date
      --   otherwise
      --           open the assignment up to the actual term date.
      --    END IF;
      --
      --    Otherwise
      --    read the row that is going to be removed
      --    if its status is TERM_ASSIGN then store the effective start date
      --       and effective end date
      --    otherwise end the step because the delete will remove an
      --    innocuous change.
      --
      --    If the effective start date is the same as the actual term date
      --    then issue an error because we are trying to remove a change
      --    brought about by Termination of Employee
      --
      --    Otherwise
      --    If the first termination date is on or before the current start
      --    date then open up the assignment to the final process date
      --    otherwise
      --       we will be removing the first TERM_ASSIGN
      --       if the row is be removed is the last one then
      --    if its end date is after the ATD then
      --      set new end date = actual termination date
      --          otherwise don't do anything
      --       otherwise
      --          a TERM_ASSIGN record will be left in the future,
      --          if this is after the atd then there is an invlaid situation
      --          where the active assignment runs past the ATD
      --          therefore in this case issue an error.
      ---------------------------------------------------------------
      ELSIF
   p_mode = 'DELETE_NEXT_CHANGE' THEN
   hr_utility.set_location('hr_assignment.check_term',12);
   IF p_end_date = p_ass_end_date THEN
      hr_utility.set_location('hr_assignment.check_term',13);
      IF p_first_term_date <= p_start_date THEN
         p_new_ass_end_date := p_fpd;
            ELSE
         p_new_ass_end_date := p_atd;
      END IF;
   ELSE
      --
      p_flag := 'N';
      --
      BEGIN
      --
            hr_utility.set_location('hr_assignment.check_term',14);
      --
         select 'Y'
         ,      a.effective_start_date
         ,      a.effective_end_date
         into   p_flag
         ,      p_next_eff_start_date
         ,      p_next_eff_end_date
         from   per_assignments_f a
         where  a.assignment_id = p_assignment_id
         and    a.effective_start_date = p_end_date + 1
         and    exists
        (select null
         from   per_assignment_status_types s
         where  s.assignment_status_type_id
         = a.assignment_status_type_id
                     and    s.per_system_status = 'TERM_ASSIGN');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
            END;
      --
      hr_utility.set_location('hr_assignment.check_term',15);
      IF p_flag = 'Y' THEN
         hr_utility.set_location('hr_assignment.check_term',16);
         IF p_next_eff_start_date = p_atd + 1 THEN
      hr_utility.set_message(801,'HR_6200_EMP_ASS_TERM_EXISTS');
      hr_utility.raise_error;
               ELSE
      IF p_first_term_date <= p_start_date THEN
      hr_utility.set_location('hr_assignment.check_term',17);
         p_new_ass_end_date := p_fpd;
                  ELSE
                     IF p_next_eff_end_date = p_ass_end_date THEN
    hr_utility.set_location('hr_assignment.check_term',18);
      IF p_ass_end_date > p_atd THEN
         p_new_ass_end_date := p_atd;
                        ELSE
         NULL;
                        END IF; -- (p_ass_end_date > p_atd)
                     ELSE
                        IF p_next_eff_end_date >= p_atd + 1 THEN
       hr_utility.set_message(801,'HR_6320_EMP_ASS_AFTER_ATD');
         hr_utility.raise_error;
                        END IF; -- (p_next_eff_end_date >= p_atd + 1)
         END IF; -- (p_next_eff_end_date = p_ass_end_date)
      END IF; -- (p_first_term_date <= p_start_date)
         END IF; -- (p_next_eff_start_date = p_atd + 1)
            END IF; -- (p_flag = 'Y')
   END IF; -- (p_end_date = p_ass_end_date)
      --
      END IF; -- (p_mode = 'UPDATE_OVERRIDE')
   --
   END IF; -- (p_atd IS NULL)
--
  hr_utility.set_location('hr_assignment.check_term',19);
  IF p_new_ass_end_date IS NOT  NULL THEN
     ------------------------------------------------------------
     -- First check whether setting this end date will invalidate
     -- any child rows.
     ------------------------------------------------------------
     hr_assignment.del_ref_int_check
      ( p_assignment_id
      , 'END'
      , p_new_ass_end_date);
     p_newdate := p_new_ass_end_date;
  END IF;
--
END check_term;
--
--
------------------- warn_del_term      ----------------------------
/*
  NAME
     warn_del_term
  DESCRIPTION
     If the operation will remove an assignment with TERM_ASSIGN status
     then a warning will be issued from the form. This procedure
     determines whether such an operation will take place.
  PARAMETERS
     p_assignment_id    - Assignment ID
     p_effective_start_date - Start Date of current Assignment row
     p_effective_end_date - End Date of current Assignment row
     p_mode     - FUTURE_CHANGES, DELETE_NEXT_CHANGE,
          UPDATE_OVERRIDE
*/
PROCEDURE warn_del_term
          (
           p_assignment_id IN INTEGER
                            ,p_mode IN VARCHAR2
          ,p_effective_start_date IN DATE
          ,p_effective_end_date IN DATE
          ) IS
--
p_term_found VARCHAR2(1);
local_warning exception;
--
BEGIN
   --
   p_term_found := 'N';
   --
   begin
   --
   hr_utility.set_location('hr_assignment.warn_del_term',1);
   --
   select 'Y'
   into   p_term_found
   from   sys.dual
   where exists
   (select null
    from   per_assignments_f a
    ,      per_assignment_status_types s
    where  a.assignment_id = p_assignment_id
    and    a.effective_start_date
     > p_effective_start_date
    and    a.effective_start_date =
      decode(p_mode,'DELETE_NEXT_CHANGE',
        p_effective_end_date + 1
             ,a.effective_start_date)
    and    s.assignment_status_type_id = a.assignment_status_type_id
    and    s.per_system_status = 'TERM_ASSIGN');
   --
   exception
      when NO_DATA_FOUND then null;
   end;
   --
   hr_utility.set_location('hr_assignment.warn_del_term',2);
   if p_term_found = 'Y' then
      raise local_warning;
   end if;
   --
   EXCEPTION
      when local_warning then
     hr_utility.set_warning;
END warn_del_term;
--
--
------------------- delete_ass_ref_int ----------------------------
/*
  NAME
     delete_ass_ref_int
  DESCRIPTION
     Determines whether there are any dependent records for the Assignment.
     If any are found then delete them.
     The following tables are examined
    PER_SPINAL_POINT_PLACEMENTS
    PER_SECONDARY_ASS_STATUSES
    PER_ASSIGNMENT_BUDGET_VALUES

  PARAMETERS
     p_business_group_id  - Business Group ID
     p_assignment_id    - Assignment ID
*/
PROCEDURE delete_ass_ref_int
          (
           p_business_group_id    IN INTEGER
                            ,p_assignment_id IN INTEGER
          ) IS
del_flag VARCHAR2(1);
--
BEGIN
--
-- del_flag  := 'N';
--
   BEGIN
   hr_utility.set_location('hr_assignment.delete_ass_ref_int',1);
--
   SELECT 'Y'
   into   del_flag
   FROM   SYS.DUAL
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_SPINAL_POINT_PLACEMENTS_F P
          WHERE  P.business_group_id + 0 = p_business_group_id
          AND    P.ASSIGNMENT_ID     = p_assignment_id);
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF del_flag  = 'Y' THEN
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',2);
   --
      DELETE FROM PER_SPINAL_POINT_PLACEMENTS_F P
      WHERE  P.business_group_id + 0 = p_business_group_id
      AND    P.ASSIGNMENT_ID     = p_assignment_id;
--
   END IF;
--
   del_flag  := 'N';
--
   BEGIN
   --
   hr_utility.set_location('hr_assignment.delete_ass_ref_int',3);
--
   SELECT 'Y'
   into   del_flag
   from sys.dual
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_SECONDARY_ASS_STATUSES S
          WHERE  S.business_group_id + 0 = p_business_group_id
          AND    S.ASSIGNMENT_ID     = p_assignment_id);
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF del_flag  = 'Y' THEN
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',4);
--
      DELETE FROM PER_SECONDARY_ASS_STATUSES
      WHERE  business_group_id + 0 = p_business_group_id
      AND    ASSIGNMENT_ID     = p_assignment_id;
--
   END IF;
--
   del_flag  := 'N';
--
   BEGIN
   hr_utility.set_location('hr_assignment.delete_ass_ref_int',5);
--
   SELECT 'Y'
   into   del_flag
   from sys.dual
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_ASSIGNMENT_BUDGET_VALUES_F BV
          WHERE  BV.business_group_id + 0 = p_business_group_id
          AND    BV.ASSIGNMENT_ID     = p_assignment_id);
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF del_flag  = 'Y' THEN
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',6);
--
      DELETE FROM PER_ASSIGNMENT_BUDGET_VALUES_F BV
      WHERE  BV.business_group_id + 0 = p_business_group_id
      AND    BV.ASSIGNMENT_ID     = p_assignment_id;
--
   END IF;
--
END delete_ass_ref_int;
--
--
------------------- get_act_term_date -----------------------------
/*
  NAME
     get_act_term_date
  DESCRIPTION
     Returns the Actual Termination Date of the Employee Period of Service.

  PARAMETERS
     p_period_of_service_id
     p_actual_termination_date
*/
PROCEDURE get_act_term_date
          (
           p_period_of_service_id IN INTEGER
          ,p_actual_termination_date OUT NOCOPY DATE
          ) IS
--
BEGIN
--
-------------------------------------------------
-- Retrieve the ACTUAL TERMINATION DATE for the Period of Service
-------------------------------------------------
   hr_utility.set_location('hr_assignment.get_act_term_date',1);
   --
   select actual_termination_date
   into   p_actual_termination_date
   from   per_periods_of_service
   where  period_of_service_id = p_period_of_service_id;
--
END get_act_term_date;
--
--
------------------- check_future_primary --------------------------
/*
  NAME
     check_future_primary
  DESCRIPTION
     Checks to see whether the operation will remove a row
     that has a primary flag value differnet to the current one.
     If such a row is found then the P_CHANGE_FLAG is set to 'Y' and
     the date from which changes to other assignment primary flag
     changes must be catered for is determined and passed back in
     P_PRIMARY_DATE_FROM.
  PARAMETERS
     p_assignment_id  - The current assignment to be checked
     p_sdate    - The start date of the current row
        NB this depends on the Mode
        UPDATE_OVERRIDE ==> Validation Start Date
        Otherwise ==> Effective Start Date
     p_edate    - Effective End Date of the current row
     p_mode   - The DT_UPDATE_MODE or DT_DELETE_MODE
     p_primary_flag - The Primary Flag Value for the current assignment
     p_change_flag  - An indicator to detect whether primary changes are
        required.
     p_new_primary_flag - The value that the current assignment will have
        after the operation
     p_primary_date_from- The date from which changes to other assignments
        must be catered for
*/
PROCEDURE check_future_primary
          (
                             p_assignment_id IN INTEGER
          ,p_sdate IN DATE
          ,p_edate IN DATE
          ,p_mode  IN VARCHAR2
          ,p_primary_flag IN VARCHAR2
          ,p_change_flag IN OUT NOCOPY VARCHAR2
          ,p_new_primary_flag IN OUT NOCOPY VARCHAR2
          ,p_primary_date_from OUT NOCOPY DATE
          ) IS
p_start_date DATE;
p_end_date   DATE;
p_primary_date_from_d DATE;
--
l_change_flag  VARCHAR2(2000) := p_change_flag ;
l_new_primary_flag VARCHAR2(2000) := p_new_primary_flag ;
l_primary_date_from DATE  :=   p_primary_date_from ;

--
BEGIN
--
   hr_utility.set_location('hr_assignment.check_future_primary',1);
   p_start_date := p_sdate;
   p_end_date   := p_edate;
--
   -------------------------------------
   --
   -------------------------------------
   p_change_flag := 'N';
   -------------------------------------
   -- If the mode is ZAP then the new primary flag is effectively 'N' i.e.
   -- it cannot be 'Y'
   --
   -- Otherwise the new primary flag for the current assignment is that passed
   -- into the procedure
   -- Also the date from which primary flag changes are to effective from
   -- is set set to the start date of the current record
   -- see below for ZAP.
   -------------------------------------
   IF p_mode = 'ZAP' THEN
      p_new_primary_flag := 'N';
   ELSE
      p_new_primary_flag  := p_primary_flag;
      p_primary_date_from := p_sdate;
   END IF;
   --
   -------------------------------------
   -- Search the appropriate row(s) (depending on the mode) for
   -- a change of primary flag that will removed as a result of the
   -- current operation
   -- i.e ZAP - All rows
   -- NEXT_CHANGE - the next row
   -- FUTURE_CHANGES and UPDATE_OVERRIDE - All rows in future
   -------------------------------------
   begin
      hr_utility.set_location('hr_assignment.check_future_primary',2);
      --
      select 'Y'
      into   p_change_flag
      from   sys.dual
      where exists
      (select null
      from   per_assignments_f
      where  assignment_id = p_assignment_id
      and    primary_flag  <> p_new_primary_flag
      and    effective_start_date >
         decode(p_mode,'ZAP',effective_start_date-1,p_start_date)
      and    effective_start_date =
         decode(p_mode,'DELETE_NEXT_CHANGE',p_end_date+1
             ,effective_start_date));
   exception
      when NO_DATA_FOUND then NULL;
   end;
--
   ---------------------------------------
   -- If the mode is ZAP and a change has been found
   -- retrieve the earliest occurrence of PRIMARY_FLAG = 'Y'. A new
   -- Primary Assignment will be required from this date.
   ---------------------------------------
   IF p_mode = 'ZAP' AND p_change_flag = 'Y' THEN
      hr_utility.set_location('hr_assignment.check_future_primary',3);
      --
      select min(effective_start_date)
      into   p_primary_date_from_d
      from   per_assignments_f
      where  assignment_id = p_assignment_id
      and    primary_flag = 'Y';
   END IF;
--
   IF p_primary_date_from_d IS NOT NULL THEN
      p_primary_date_from := p_primary_date_from_d;
   END IF;
--
EXCEPTION
   when others then
   p_change_flag := l_change_flag ;
   p_new_primary_flag := l_new_primary_flag ;
   p_primary_date_from := l_primary_date_from ;
   RAISE ;

END check_future_primary;
--
--
------------------- check_ass_for_primary -------------------------
/*
  NAME
     check_ass_for_primary
  DESCRIPTION
     Checks to ensure that the record is continuous until the end
     of the Period Of Service / Placement and that if it has been terminated
     then termination was as a result of the termination of the employee
     i.e. the termination date is the same as the ACTUAL TERMINATION DATE.
  PARAMETERS
     p_period_of_service_id - The current Period of Service ID
     p_assignment_id        - The current assignment ID
     p_sdate                - The validation start date of the updated record
*/
PROCEDURE check_ass_for_primary
          (
           p_period_of_service_id IN INTEGER
                            ,p_assignment_id IN INTEGER
          ,p_sdate IN DATE
          ) IS
p_atd DATE;
p_fpd DATE;
p_ass_end_date DATE;
p_first_term_date DATE;
p_start_date DATE;
l_pdp_date_start  DATE;
l_person_id       NUMBER;
l_assignment_type per_all_assignments_f.assignment_type%TYPE;

CURSOR csr_get_assignment_info IS
SELECT paaf.person_id
      ,paaf.assignment_type
      ,paaf.period_of_placement_date_start
FROM   per_all_assignments_f paaf
WHERE  paaf.assignment_id = p_assignment_id
AND    paaf.assignment_type IN ('E', 'C');

CURSOR csr_get_term_dates IS
SELECT NVL(actual_termination_date, to_date('30/12/4712','DD/MM/YYYY'))
      ,NVL(final_process_date,to_date('31/12/4712','DD/MM/YYYY'))
FROM   per_periods_of_service
WHERE  period_of_service_id = p_period_of_service_id
UNION
SELECT NVL(pdp.actual_termination_date,to_date('30/12/4712','DD/MM/YYYY'))
      ,NVL(pdp.final_process_date,to_date('31/12/4712','DD/MM/YYYY'))
FROM   per_periods_of_placement pdp
WHERE  pdp.person_id = l_person_id
AND    pdp.date_start = l_pdp_date_start;

--
BEGIN
--
   --
   -- Fetch the assignment type and placement date start.
   --
   OPEN  csr_get_assignment_info;
   FETCH csr_get_assignment_info INTO l_person_id
                                     ,l_assignment_type
                                     ,l_pdp_date_start;
   CLOSE csr_get_assignment_info;

   p_start_date := p_sdate;

   -------------------------------------
   -- Get the Actual Termination Date and Final Process Date
   -------------------------------------
   hr_utility.set_location('hr_assignment.check_ass_for_primary',1);
   --
   -- #306211. If ATD was null, then NVL to EOT - 1, instead of EOT. This is
   -- because trying to add 1 to EOT (as happens in a number of places below)
   -- raises an ORA-1841 error. So use Dec 30 instead of Dec 31.
   -- The ATD and FPD for contingent workers will be the same.
   --
   OPEN  csr_get_term_dates;
   FETCH csr_get_term_dates INTO p_atd, p_fpd;
   CLOSE csr_get_term_dates;

   -------------------------------------
   -- Get the Effective End Date of the Assignment
   -------------------------------------
   hr_utility.set_location('hr_assignment.check_ass_for_primary',2);
   --
   select max(effective_end_date)
   into   p_ass_end_date
   from   per_assignments_f
   where  assignment_id = p_assignment_id;
   --
   -- If the end date of the assignment is not on or after the
   -- period of service final process date then ERROR
   --
   IF p_ass_end_date < p_fpd THEN
      hr_utility.set_message(801,'HR_6380_EMP_ASS_END_OFF_FPD');
      hr_utility.raise_error;
   END IF;
   --
   -------------------------------------
   -- If the Start Date of the record is on or before the day after ATD
   -- then the first TERM_ASSIGN must be on the day after the ATD i.e.
   -- the TERMINATION was brought about by the Employee Termination.
   -------------------------------------
   IF p_atd IS NULL THEN NULL;
   ELSIF p_atd + 1 <= p_start_date THEN NULL;
      ELSE
        -------------------------------------
        -- Get the Start Date of the First terminated status.
        -------------------------------------
        hr_utility.set_location('hr_assignment.check_ass_for_primary',3);
        --
        if l_assignment_type <> 'C' then

          select min(a.effective_start_date)
          into   p_first_term_date
          from   per_assignments_f a
          where  a.assignment_id = p_assignment_id
          and    exists ( select null
                          from   per_assignment_status_types s
                          where  s.assignment_status_type_id
                           = a.assignment_status_type_id
                          and    s.per_system_status = 'TERM_ASSIGN');
     --
            hr_utility.set_location('hr_assignment.check_ass_for_primary',4);
          IF p_first_term_date = p_atd + 1
       OR
       p_first_term_date IS NULL THEN NULL;
          ELSE
             hr_utility.set_message(801,'HR_6381_EMP_ASS_TERM_OFF_ATD');
             hr_utility.raise_error;
          END IF;
        END IF;
      END IF;
--
END check_ass_for_primary;
--
--------------------------------------------------------------------
------------------- update_primary_cwk -----------------------------
--------------------------------------------------------------------
--
PROCEDURE update_primary_cwk
  (p_assignment_id        IN INTEGER
  ,p_person_id            IN NUMBER
  ,p_pop_date_start       IN DATE
  ,p_new_primary_ass_id   IN INTEGER
  ,p_sdate                IN DATE
  ,p_new_primary_flag     IN VARCHAR2
  ,p_mode                 IN VARCHAR2
  ,p_last_updated_by      IN INTEGER
  ,p_last_update_login    IN INTEGER  ) IS
  --
  l_start_date DATE;
  l_proc       VARCHAR2(72) :=  g_package||'update_primary_cwk';
  --
  CURSOR get_future_primary_assignments IS
    SELECT assignment_id
    FROM   per_assignments_f
    WHERE  assignment_id NOT IN  (p_assignment_id,p_new_primary_ass_id)
    AND    person_id           = p_person_id
    AND    period_of_placement_date_start = p_pop_date_start
    AND    effective_end_date  >= l_start_date;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  l_start_date := p_sdate;
  --
  -- Update the future changes for the current
  -- assignment with the new Primary Flag
  --
  IF p_mode <> 'ZAP' THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    ----------------------------------------------------------------
    -- 3584122: The value of 'N' is not updating the future
    -- changes of the secondar_assignment to primary if a
    -- secondary assignment is updated to primary. As the calling
    -- procedure would set the new_primary_flag correctly so setting
    -- back to p_new_primary_flag.
    ----------------------------------------------------------------
    do_primary_update
      (p_assignment_id
      ,p_sdate
      ,p_new_primary_flag -- Bug 3584122 'N'-- Bug 2468916 p_new_primary_flag
      ,'Y'
      ,p_last_updated_by
      ,p_last_update_login);
    --
  END IF;
  --
  hr_utility.set_location(l_proc,30);
  --
  -- If the New Primary Asg is not the Current Asg then the Primary
  -- Flag has to be set to 'Y' on all the changes on or after the
  -- Start Date
  --
  IF p_assignment_id <> p_new_primary_ass_id THEN
    --
    hr_utility.set_location(l_proc,40);
    --
    do_primary_update
      (p_new_primary_ass_id
      ,p_sdate
      ,'Y'
      ,'N'
      ,p_last_updated_by
      ,p_last_update_login);
    --
  END IF;
  --
  hr_utility.set_location(l_proc,50);
  --
  -- Now for each assignment other than P_ASSIGNMENT_ID and
  -- P_NEW_PRIMARY_ASS_ID within the period_of_service
  -- future changes must have their Primary Flag set to 'N'. It is only
  -- necessary to update the ones that are currently 'Y'.
  --
  FOR ass_rec IN get_future_primary_assignments LOOP
    --
    do_primary_update
      (ass_rec.assignment_id
      ,p_sdate
      ,'N'
      ,'N'
      ,p_last_updated_by
      ,p_last_update_login);
    --
  END LOOP;
  --
  hr_utility.set_location(' Leaving : '||l_proc,999);
  --
END update_primary_cwk;
--
--
------------------- update_primary    -----------------------------
/*
  NAME
     update_primary
  DESCRIPTION
     For the Current Assignment, if the operation is not ZAP then updates
     all the future rows to the NEW_PRIMARY_FLAG value.
     For other assignments,
  if the other assignment is the new primary then ensure that there
  is a record starting on the correct date with Primary Flag = 'Y'
  and update all other future changes to the same Primary value.
     For any other assignments
      if the assignment is primary on the date in question then
      ensure that that there is a row on this date with primary
      flag = 'N' and that all future changes are set to 'N'
      otherwise
      ensure that all future primary flags are set to 'N'.
     NB. This uses several calls to DO_PRIMARY_UPDATE which handles the
   date effective insert for an individual assignment row if one
   is required.
  PARAMETERS
     p_assignment_id    - The current assignment
     p_period_of_service_id - The current Period of Service
     p_new_primary_ass_id - The Assignment ID that will be primary after
          the operation
     p_sdate      - The date from which changes are to be made
     p_new_primary_flag   - The current assignment primary flag after the
          operation
     p_mode     - The DT_DELETE_MODE or DT_UPDATE_MODE
*/
PROCEDURE update_primary
          (
                             p_assignment_id IN INTEGER
          ,p_period_of_service_id IN INTEGER
                            ,p_new_primary_ass_id IN INTEGER
          ,p_sdate IN DATE
          ,p_new_primary_flag IN VARCHAR2
          ,p_mode IN VARCHAR2
          ,p_last_updated_by IN INTEGER
          ,p_last_update_login IN INTEGER
          ) IS
p_start_date DATE;
--
CURSOR get_future_primary_assignments IS
   select assignment_id
   from   per_assignments_f
   where  assignment_id not in (P_ASSIGNMENT_ID,P_NEW_PRIMARY_ASS_ID)
   and    period_of_service_id = P_PERIOD_OF_SERVICE_ID
   and    effective_end_date >= P_START_DATE;
--
BEGIN
--
   p_start_date := p_sdate;
--
   -------------------------------------
   -- Update the future changes for the current assignment with the
   -- new Primary Flag
   -- 2468916: this first update ensures the current assignment
   -- gets converted to a secondary assignment.
   -- 3584122: The value of 'N' is not updating the future
   -- changes of the secondar_assignment to primary if a
   -- secondary assignment is updated to primary. As the calling
   -- procedure would set the new_primary_flag correctly so setting
   -- back to p_new_primary_flag.
   -------------------------------------
   --
   IF p_mode <> 'ZAP' THEN
   hr_utility.set_location('hr_assignment.update_primary',1);
      do_primary_update(p_assignment_id
           ,p_sdate
           ,p_new_primary_flag -- Bug 3584122 'N'-- Bug 2468916 p_new_primary_flag
           ,'Y'
           ,p_last_updated_by
           ,p_last_update_login
           );
   END IF;
   --
   -------------------------------------
   -- If the New Primary Asg is not the Current Asg then the Primary
   -- Flag has to be set to 'Y' on all the changes on or after the
   -- Start Date
   -------------------------------------
   IF p_assignment_id <> p_new_primary_ass_id THEN
   hr_utility.set_location('hr_assignment.update_primary',2);
      do_primary_update(p_new_primary_ass_id
                       ,p_sdate
           ,'Y'
           ,'N'
           ,p_last_updated_by
           ,p_last_update_login
           );
      END IF;
   --
   -------------------------------------
   -- Now for each assignment other than P_ASSIGNMENT_ID and
   -- P_NEW_PRIMARY_ASS_ID within the period_of_service
   -- future changes must have their Primary Flag set to 'N'. It is only
   -- necessary to update the ones that are currently 'Y'.
   -------------------------------------
      hr_utility.set_location('hr_assignment.update_primary',3);
   --
      FOR ass_rec IN get_future_primary_assignments LOOP
          do_primary_update(ass_rec.assignment_id
        ,p_sdate
        ,'N'
        ,'N'
           ,p_last_updated_by
           ,p_last_update_login
      );
      END LOOP;
--
--
END update_primary;
--
--
------------------- do_primary_update -----------------------------
/*
  NAME
     do_primary_update
  DESCRIPTION
     Performs updates on the Assignment to set the Primary Flag to the value
     passed in to the procedure.
     If a Primary Flag is to be reset on the Date passed in and a row does
     not start on this date then a date effective insert is performed.
  PARAMETERS
     p_assignment_id - The assignment to be updated
     p_sdate         - The date from which to update
     p_primary_flag  - The primary flag value
     p_current_ass   - Whether the assignment is the current one (Y/N)
*/
PROCEDURE do_primary_update
          (
           p_assignment_id IN INTEGER
                            ,p_sdate IN DATE
          ,p_primary_flag IN VARCHAR2
          ,p_current_ass IN VARCHAR2
          ,p_last_updated_by IN INTEGER
          ,p_last_update_login IN INTEGER
          ) IS
--
x VARCHAR2(30);
p_start_date DATE;
--
CURSOR select_ass_for_update IS
   select *
   from   per_assignments_f
   where  assignment_id = P_ASSIGNMENT_ID
   and  ((p_current_ass <> 'Y'
          and (P_START_DATE
                  between effective_start_date
          and effective_end_date
            or P_START_DATE < effective_start_date))
   or (p_current_ass = 'Y'
       and P_START_DATE < effective_start_date))
   for update;
--
BEGIN
   hr_utility.set_location('hr_assignment.do_primary_update',1);
   p_start_date := p_sdate;
--
   -------------------------------------
   -- If the Assignment is Current i.e. P_CURRENT_ASS = 'Y' then the form
   -- has already updated the primary flag. So we only need to update
   -- future changes.
   --
   -- Otherwise attempt to update a row with effective start date on
   -- P_START_DATE.
   --
   -- If one row is updated then there is no need to perform a date
   -- effective insert.
   --
   -- If no rows are updated then perform date effective insert
   --    i. If there is a row that spans the P_START_DATE then duplicate the
   --       row with effective end date = P_START_DATE - 1
   --   ii. Update the row to have effective start date = P_START_DATE and
   --       PRIMARY_FLAG = P_PRIMARY_FLAG
   --
   -- Now Update the Primary Flag to P_PRIMARY_FLAG for all future Changes
   -------------------------------------
      ---------------------------------------------------------------------
      -- Added 10-MAR-93
      -- Select for update is only applicable when we are updating 3rd party
      -- assignment rows (i.e. not the one that is updated on the form)
      -- i.e. p_current_ass <> 'Y' and all the rows that either span the
      --      p_start_date or are after it
      --   or
      --      p_current_ass = 'Y' and all the rows that are after the
      --                      p_start_date
      --
      -- IMPORTANT - do not lock the row updated by the form!
      --
      -- See CURSOR select_ass_for_update
      ----------------------------------------------------------------------
   --
      hr_utility.set_location('hr_assignment.do_primary_update',2);
      --
      FOR ass_rec IN select_ass_for_update LOOP
    NULL;
      END LOOP;
--
   IF p_current_ass = 'Y' THEN
      NULL;
   ELSE
      hr_utility.set_location('hr_assignment.do_primary_update',3);
      --
      update per_assignments_f
      set    primary_flag  = P_PRIMARY_FLAG
      ,      last_updated_by = P_LAST_UPDATED_BY
      ,      last_update_login = P_LAST_UPDATE_LOGIN
      ,      last_update_date  = sysdate
      where  assignment_id = P_ASSIGNMENT_ID
      and    effective_start_date = P_START_DATE;
      --
  --    hr_utility.set_location('hr_assignment.do_primary_update',4);  -- Fix For Bug # 8710298. Commented the Call.
      IF SQL%ROWCOUNT = 1 THEN
   NULL;
      ELSIF SQL%ROWCOUNT > 1 THEN
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','DO_PRIMARY_UPDATE');
      hr_utility.set_message_token('STEP','1');
            hr_utility.raise_error;
      ELSE
      --
         hr_utility.set_location('hr_assignment.do_primary_update',5);
   --
   insert into per_assignments_f
   (
 ASSIGNMENT_ID
,EFFECTIVE_START_DATE
,EFFECTIVE_END_DATE
,BUSINESS_GROUP_ID
,GRADE_ID
,POSITION_ID
,JOB_ID
,ASSIGNMENT_STATUS_TYPE_ID
,PAYROLL_ID
,LOCATION_ID
,PERSON_ID
,ORGANIZATION_ID
,PEOPLE_GROUP_ID
,SOFT_CODING_KEYFLEX_ID
,VACANCY_ID
,ASSIGNMENT_SEQUENCE
,ASSIGNMENT_TYPE
,MANAGER_FLAG
,PRIMARY_FLAG
,APPLICATION_ID
,ASSIGNMENT_NUMBER
,CHANGE_REASON
,COMMENT_ID
,DATE_PROBATION_END
,DEFAULT_CODE_COMB_ID
,FREQUENCY
,INTERNAL_ADDRESS_LINE
,NORMAL_HOURS
,PERIOD_OF_SERVICE_ID
,PROBATION_PERIOD
,PROBATION_UNIT
,RECRUITER_ID
,SET_OF_BOOKS_ID
,SPECIAL_CEILING_STEP_ID
,SUPERVISOR_ID
,TIME_NORMAL_FINISH
,TIME_NORMAL_START
,PERSON_REFERRED_BY_ID
,RECRUITMENT_ACTIVITY_ID
,SOURCE_ORGANIZATION_ID
,SOURCE_TYPE
,PAY_BASIS_ID
,EMPLOYMENT_CATEGORY
,PERF_REVIEW_PERIOD
,PERF_REVIEW_PERIOD_FREQUENCY
,SAL_REVIEW_PERIOD
,SAL_REVIEW_PERIOD_FREQUENCY
,CONTRACT_ID
,CAGR_ID_FLEX_NUM
,CAGR_GRADE_DEF_ID
,ESTABLISHMENT_ID
,COLLECTIVE_AGREEMENT_ID
,NOTICE_PERIOD
,NOTICE_PERIOD_UOM
,WORK_AT_HOME
,EMPLOYEE_CATEGORY
,JOB_POST_SOURCE_NAME
,REQUEST_ID
,PROGRAM_APPLICATION_ID
,PROGRAM_ID
,PROGRAM_UPDATE_DATE
,ASS_ATTRIBUTE_CATEGORY
,ASS_ATTRIBUTE1
,ASS_ATTRIBUTE2
,ASS_ATTRIBUTE3
,ASS_ATTRIBUTE4
,ASS_ATTRIBUTE5
,ASS_ATTRIBUTE6
,ASS_ATTRIBUTE7
,ASS_ATTRIBUTE8
,ASS_ATTRIBUTE9
,ASS_ATTRIBUTE10
,ASS_ATTRIBUTE11
,ASS_ATTRIBUTE12
,ASS_ATTRIBUTE13
,ASS_ATTRIBUTE14
,ASS_ATTRIBUTE15
,ASS_ATTRIBUTE16
,ASS_ATTRIBUTE17
,ASS_ATTRIBUTE18
,ASS_ATTRIBUTE19
,ASS_ATTRIBUTE20
,ASS_ATTRIBUTE21
,ASS_ATTRIBUTE22
,ASS_ATTRIBUTE23
,ASS_ATTRIBUTE24
,ASS_ATTRIBUTE25
,ASS_ATTRIBUTE26
,ASS_ATTRIBUTE27
,ASS_ATTRIBUTE28
,ASS_ATTRIBUTE29
,ASS_ATTRIBUTE30
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_LOGIN
,CREATED_BY
,CREATION_DATE
,BARGAINING_UNIT_CODE
,LABOUR_UNION_MEMBER_FLAG
,HOURLY_SALARIED_CODE
,TITLE
,PERIOD_OF_PLACEMENT_DATE_START
,VENDOR_ID
,VENDOR_EMPLOYEE_NUMBER
,VENDOR_ASSIGNMENT_NUMBER
,ASSIGNMENT_CATEGORY
,PROJECT_TITLE
)
   select
 ASSIGNMENT_ID
,EFFECTIVE_START_DATE
,p_start_date - 1
,BUSINESS_GROUP_ID
,GRADE_ID
,POSITION_ID
,JOB_ID
,ASSIGNMENT_STATUS_TYPE_ID
,PAYROLL_ID
,LOCATION_ID
,PERSON_ID
,ORGANIZATION_ID
,PEOPLE_GROUP_ID
,SOFT_CODING_KEYFLEX_ID
,VACANCY_ID
,ASSIGNMENT_SEQUENCE
,ASSIGNMENT_TYPE
,MANAGER_FLAG
,PRIMARY_FLAG
,APPLICATION_ID
,ASSIGNMENT_NUMBER
,CHANGE_REASON
,COMMENT_ID
,DATE_PROBATION_END
,DEFAULT_CODE_COMB_ID
,FREQUENCY
,INTERNAL_ADDRESS_LINE
,NORMAL_HOURS
,PERIOD_OF_SERVICE_ID
,PROBATION_PERIOD
,PROBATION_UNIT
,RECRUITER_ID
,SET_OF_BOOKS_ID
,SPECIAL_CEILING_STEP_ID
,SUPERVISOR_ID
,TIME_NORMAL_FINISH
,TIME_NORMAL_START
,PERSON_REFERRED_BY_ID
,RECRUITMENT_ACTIVITY_ID
,SOURCE_ORGANIZATION_ID
,SOURCE_TYPE
,PAY_BASIS_ID
,EMPLOYMENT_CATEGORY
,PERF_REVIEW_PERIOD
,PERF_REVIEW_PERIOD_FREQUENCY
,SAL_REVIEW_PERIOD
,SAL_REVIEW_PERIOD_FREQUENCY
,CONTRACT_ID
,CAGR_ID_FLEX_NUM
,CAGR_GRADE_DEF_ID
,ESTABLISHMENT_ID
,COLLECTIVE_AGREEMENT_ID
,NOTICE_PERIOD
,NOTICE_PERIOD_UOM
,WORK_AT_HOME
,EMPLOYEE_CATEGORY
,JOB_POST_SOURCE_NAME
,REQUEST_ID
,PROGRAM_APPLICATION_ID
,PROGRAM_ID
,PROGRAM_UPDATE_DATE
,ASS_ATTRIBUTE_CATEGORY
,ASS_ATTRIBUTE1
,ASS_ATTRIBUTE2
,ASS_ATTRIBUTE3
,ASS_ATTRIBUTE4
,ASS_ATTRIBUTE5
,ASS_ATTRIBUTE6
,ASS_ATTRIBUTE7
,ASS_ATTRIBUTE8
,ASS_ATTRIBUTE9
,ASS_ATTRIBUTE10
,ASS_ATTRIBUTE11
,ASS_ATTRIBUTE12
,ASS_ATTRIBUTE13
,ASS_ATTRIBUTE14
,ASS_ATTRIBUTE15
,ASS_ATTRIBUTE16
,ASS_ATTRIBUTE17
,ASS_ATTRIBUTE18
,ASS_ATTRIBUTE19
,ASS_ATTRIBUTE20
,ASS_ATTRIBUTE21
,ASS_ATTRIBUTE22
,ASS_ATTRIBUTE23
,ASS_ATTRIBUTE24
,ASS_ATTRIBUTE25
,ASS_ATTRIBUTE26
,ASS_ATTRIBUTE27
,ASS_ATTRIBUTE28
,ASS_ATTRIBUTE29
,ASS_ATTRIBUTE30
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_LOGIN
,CREATED_BY
,CREATION_DATE
,BARGAINING_UNIT_CODE
,LABOUR_UNION_MEMBER_FLAG
,HOURLY_SALARIED_CODE
,TITLE
,PERIOD_OF_PLACEMENT_DATE_START
,VENDOR_ID
,VENDOR_EMPLOYEE_NUMBER
,VENDOR_ASSIGNMENT_NUMBER
,ASSIGNMENT_CATEGORY
,PROJECT_TITLE
   from   per_assignments_f
   where  assignment_id = P_ASSIGNMENT_ID
   and    P_START_DATE
       between effective_start_date and effective_end_date
         and    primary_flag <> P_PRIMARY_FLAG ;
         --
         IF SQL%ROWCOUNT = 0 THEN
       NULL; -- This Assignment Start in the Future
         ELSE
            hr_utility.set_location('hr_assignment.do_primary_update',6);
      --
            update per_assignments_f
      set    effective_start_date = P_START_DATE
      ,      primary_flag         = P_PRIMARY_FLAG
            ,      last_updated_by = P_LAST_UPDATED_BY
            ,      last_update_login = P_LAST_UPDATE_LOGIN
            ,      last_update_date  = sysdate
      where  assignment_id = P_ASSIGNMENT_ID
      and    P_START_DATE
       between effective_start_date and effective_end_date
       and   primary_flag <> P_PRIMARY_FLAG;
      --
  --    hr_utility.set_location('hr_assignment.do_primary_update',7);  -- Fix For Bug # 8710298. Commented the call.
      IF SQL%ROWCOUNT <> 1 THEN
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','DO_PRIMARY_UPDATE');
      hr_utility.set_message_token('STEP','3');
            hr_utility.raise_error;
            END IF; -- (SQL%ROWCOUNT <> 1)
      hr_utility.set_location('hr_assignment.do_primary_update',7);   -- Fix For Bug # 8710298 . Moved the hr_utility.set_location call.
         END IF; -- (SQL%ROWCOUNT = 0)
      END IF; -- (SQL%ROWCOUNT = 1)
   END IF; -- (p_current_ass = 'Y')
   --
   hr_utility.set_location('hr_assignment.do_primary_update',8);
   --
   update per_assignments_f
   set    primary_flag = P_PRIMARY_FLAG
   ,      last_updated_by = P_LAST_UPDATED_BY
   ,      last_update_login = P_LAST_UPDATE_LOGIN
   ,      last_update_date  = sysdate
   where  assignment_id = P_ASSIGNMENT_ID
   and    effective_start_date > P_START_DATE;
--
  --
--
END do_primary_update;
--
--
------------------- get_new_primary_assignment --------------------
/*
   NAME
      get_new_primary_assignment
   DESCRIPTION
      Searches for a candidate assignment which will become Primary
      on the Date passed into the procedure. The assignment must be continuous
      to the end of the period of service and if it is terminated the
      first termination must be as aresult of termination of the employee.
      If more than one candidate assignment is found then a warning status is
      raised (the form detect the warning and pops a QuickPick).
   PARAMETERS
      p_assignment_id   - The current assignment
      p_period_of_service_id  - The current period of service
      p_sdate     - The date upon which the assignment will
          become primary
      p_new_primary_ass_id  - The new Primary Assignment ID
*/
PROCEDURE get_new_primary_assignment
          (
                             p_assignment_id IN NUMBER
                            ,p_period_of_service_id IN NUMBER
          ,p_sdate IN DATE
          ,p_new_primary_ass_id OUT NOCOPY VARCHAR2
          ) IS
p_atd             DATE;
p_fpd             DATE;
p_start_date      DATE;
l_person_id       NUMBER;
l_assignment_type per_all_assignments_f.assignment_type%TYPE;
l_pdp_date_start  DATE;

--
-- Fetch the person ID and assignment type so the
-- period of placement can be obtained for
-- contingent workers.
--
CURSOR csr_get_assignment_info IS
SELECT paaf.person_id
      ,paaf.assignment_type
      ,paaf.period_of_placement_date_start
FROM   per_all_assignments_f paaf
WHERE  paaf.assignment_id = p_assignment_id
AND    paaf.assignment_type IN ('E', 'C');

--
-- Get the termination dates for the period of placement and
-- period of service.
--
CURSOR csr_get_term_dates IS
SELECT NVL(actual_termination_date, hr_api.g_eot)
      ,NVL(final_process_date, hr_api.g_eot)
FROM   per_periods_of_service
WHERE  period_of_service_id = p_period_of_service_id
UNION
SELECT NVL(pdp.actual_termination_date, hr_api.g_eot)
      ,NVL(pdp.final_process_date, hr_api.g_eot)
FROM   per_periods_of_placement pdp
WHERE  pdp.person_id = l_person_id
AND    pdp.date_start = l_pdp_date_start;

--
local_warning EXCEPTION;
--
   -------------------------------------
   -- Find an assignment for this period of service / placement that is
   -- continuous from the start date passed in as a parameter
   -- to the end of time or the final processing date or the period of
   -- service (whicever is the sooner)
   -- and
   -- which is not terminated between now and the atd (or eot if atd is null)
   -- i.e. as a result of termination.
   -- This cursor has been changed to support contingent workers but it
   -- should be noted that the 'TERM_ASSIGN' sub-select has not changed
   -- as this is wrapped in an AND NOT EXISTS and an equivalent "Terminated"
   -- assignment is not possible for contingent workers.
   -------------------------------------
      CURSOR get_candidate_primary_ass IS
      select to_char(a.assignment_id)
      from   per_assignments_f a,
             per_assignment_status_types ast
      where  assignment_id <> p_assignment_id
      and    a.effective_start_date <= p_start_date
      and    a.effective_end_date >= p_start_date
      and    a.assignment_status_type_id = ast.assignment_status_type_id
      and  ((a.period_of_service_id = p_period_of_service_id and
             a.assignment_type = 'E' and
             ast.per_system_status = 'ACTIVE_ASSIGN')
       or   (a.period_of_placement_date_start = l_pdp_date_start and
             a.person_id = l_person_id and
             a.assignment_type = 'C' and
             ast.per_system_status = 'ACTIVE_CWK'))
      and    exists
     (select null
      from per_assignments_f a2
      where a2.assignment_id = a.assignment_id
      and   a2.effective_end_date >= p_fpd)
      and not exists
     (select null
      from   per_assignments_f a3
      where  a3.assignment_id = a.assignment_id
      and    a3.effective_start_date between p_start_date and p_atd
      and exists
     (select null
      from   per_assignment_status_types s
      where  s.assignment_status_type_id = a3.assignment_status_type_id
      and    s.per_system_status = 'TERM_ASSIGN'));
--
BEGIN
--
  p_start_date := p_sdate;

  hr_utility.set_location('hr_assignment.get_new_primary_assignment',1);

  --
  -- Fetch the desired assignment details.
  --
  OPEN  csr_get_assignment_info;
  FETCH csr_get_assignment_info INTO l_person_id
                                    ,l_assignment_type
                                    ,l_pdp_date_start;
  CLOSE csr_get_assignment_info;

  --
  -- Fetch the termination dates.
  --
  OPEN  csr_get_term_dates;
  FETCH csr_get_term_dates INTO p_atd
                               ,p_fpd;
  CLOSE csr_get_term_dates;

   --
   hr_utility.set_location('hr_assignment.get_new_primary_assignment',2);
   --
    ---------------------------------------------------
    -- open the cursor and read the first record if one exists
    -- If one doesn't exists then ERROR
    -- Try and read another record
    -- If one exists then WARNING (prompt user in Form for which one)
    ---------------------------------------------------
    hr_utility.set_location('hr_assignment.get_new_primary_assignment',3);
    OPEN get_candidate_primary_ass;
    --
    hr_utility.set_location('hr_assignment.get_new_primary_assignment',4);
    FETCH get_candidate_primary_ass INTO p_new_primary_ass_id;
    --
    IF get_candidate_primary_ass%NOTFOUND THEN
       hr_utility.set_location('hr_assignment.get_new_primary_assignment',5);
       CLOSE get_candidate_primary_ass;
      hr_utility.set_message(801,'HR_6384_EMP_ASS_NO_PRIM');
            hr_utility.raise_error;
    ELSE
       hr_utility.set_location('hr_assignment.get_new_primary_assignment',7);
       FETCH get_candidate_primary_ass INTO p_new_primary_ass_id;
       --
       hr_utility.set_location('hr_assignment.get_new_primary_assignment',8);
       IF get_candidate_primary_ass%FOUND THEN
    raise local_warning;
       END IF;
       --
       hr_utility.set_location('hr_assignment.get_new_primary_assignment',9);
       CLOSE get_candidate_primary_ass;
    END IF;
--
EXCEPTION
   when local_warning then
        p_new_primary_ass_id := null ;
  hr_utility.set_warning;

   when others then
        p_new_primary_ass_id := null;
        raise;
--
END get_new_primary_assignment;
--
--
------------------- load_budget_values         --------------------
/*
   NAME
      load_budget_values
   DESCRIPTION
      Creates Assignment Budget Values form the Default ones for the Business
      Group.
   PARAMETERS
      p_assignment_id   - The current assignment
      p_business_group_id       - The business Group
      p_userid
      p_login
      p_effective_start_date     - assignment start date
      p_effective_end_date       - assignment end date
*/
PROCEDURE load_budget_values
         (p_assignment_id IN INTEGER
         ,p_business_group_id IN INTEGER
         ,p_userid IN VARCHAR2
         ,p_login IN VARCHAR2
         ,p_effective_start_date IN DATE
         ,p_effective_end_date   IN DATE) IS

--
BEGIN
   hr_utility.set_location('hr_assignment.load_budget_values',1);
--
/* 25/05/95 Fixed bug 273820 - performance of following statement
   NB the business_group_id no longer needs +0 appended to it, this
      is because the view per_default_budget_values is in fact returning
      organization_id in place of business_group_id in ordre to make use
      of an index
      */
-- Change to include effective start and end dates in parameters and logic to check these and
-- insert the assignment dates into the budget values table.
-- Also change of table from per_assignment_budget_values to  per_assignment_budget_values_f.
-- This is required as per_assignment_budget_values_f is now a datetracked table.
-- 16-APR-1998 : SASmith.


  insert into per_assignment_budget_values_f
  (assignment_budget_value_id
  ,business_group_id
  ,assignment_id
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date
  ,unit
  ,value
  ,effective_start_date
  ,effective_end_date)
  select per_assignment_budget_values_s.nextval
  ,      pabv1.business_group_id
  ,      p_assignment_id
  ,      sysdate
  ,      p_userid
  ,      p_login
  ,      p_userid
  ,      sysdate
  ,      pabv1.unit
  ,      pabv1.value
  ,      p_effective_start_date
  ,      p_effective_end_date
  from   per_default_budget_values pabv1
  where  pabv1.business_group_id = p_business_group_id
  and not exists (select 'already there'
      from   per_assignment_budget_values_f pabv2
      where  pabv2.assignment_id  = p_assignment_id
      and    pabv2.unit   = pabv1.unit );
   /* BDG 22/12/98 for Bug 679966
      and    pabv2.value  = pabv1.value */
 --
--
END load_budget_values;
--
--
------------------- del_ref_int_check          --------------------
/*
   NAME
      del_ref_int_check
   DESCRIPTION
      Performs Referential Integrity Checks on the following tables
      For 'ZAP'
          PER_EVENTS
          PER_LETTER_REQUEST_LINES
          PAY_COST_ALLOCATIONS_F
          PER_ASSIGNMENT_EXTRA_INFO
          PAY_PERSONAL_PAYMENT_METHODS_F
    HR_ASSIGNMENT_SET_AMENDMENTS
    PAY_ASSIGNMENT_ACTIONS
    PER_COBRA_COV_ENROLLMENTS
    PER_COBRA_COVERAGE_BENEFITS_F
    OTA_DELEGATE_BOOKINGS (per_ota_predel_validation.ota_predel_asg_validation)

      For 'END' (date effective delete)
          PER_EVENTS
          PER_LETTER_REQUEST_LINES
          PAY_COST_ALLOCATIONS_F
          PAY_PERSONAL_PAYMENT_METHODS_F
    PAY_ASSIGNMENT_ACTIONS
    PER_COBRA_COV_ENROLLMENTS
    PER_COBRA_COVERAGE_BENEFITS_F

      Determines whether the delete operation is permissible
   PARAMETERS
      p_assignment_id   - The current assignment
      p_mode      - The mode of operation (ZAP or END)
      p_edate     - The date the assignment is ENDed
          only required for 'END'
*/
PROCEDURE del_ref_int_check
          (
                             p_assignment_id IN INTEGER
          ,p_mode IN VARCHAR2
          ,p_edate IN DATE
          ) IS
p_end_date DATE;
p_del_flag VARCHAR2(1);
--
BEGIN
--
   --
   p_end_date := p_edate;
   --
--
IF p_mode = 'ZAP' THEN
  hr_utility.set_location('hr_assignment.del_ref_int_check',0);
  p_del_flag := 'N';
  --
  BEGIN
  select 'Y'
  into   p_del_flag
  from   sys.dual
  where exists (
  select null
  from   PER_ASSIGNMENTS_F A
  ,      FND_SESSIONS S
  where  a.assignment_id     = p_assignment_id
  and    a.assignment_type = 'E'
  and    effective_date
    between a.effective_start_date and a.effective_end_date
  and    session_id = userenv('SESSIONID')
  and exists
      (select null
       from PER_ASSIGNMENTS_F B
       where b.assignment_id = p_assignment_id
       and   b.assignment_type = 'A'
       and   b.effective_end_date < a.effective_start_date)
   );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
--
  IF p_del_flag = 'Y' THEN
     hr_utility.set_message(801,'HR_7625_ASS_DEL_APP_ASS');
     hr_utility.raise_error;
  END IF;
END IF;
--
  hr_utility.set_location('hr_assignment.del_ref_int_check',1);
  p_del_flag := 'N';
  --
  BEGIN
  select 'Y'
  into   p_del_flag
  from sys.dual
  where exists (
  select null
  from   PER_EVENTS
  where  assignment_id     = p_assignment_id
  and   (p_mode = 'ZAP'
      or (p_mode = 'END'
    and date_start > p_end_date)));
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
--
  IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7630_ASS_EVE_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7633_ASS_EVE_END_ASS');
     END IF;
     hr_utility.raise_error;
  END IF;
--
--
  /* Took out nocopy the check on letter requests as they are now Auto Deleted
     - 2/6/93
  */
  /*
  hr_utility.set_location('hr_assignment.del_ref_int_check',2);
  p_del_flag := 'N';
  --
  BEGIN
  select 'Y'
  into   p_del_flag
  from sys.dual
  where exists (
  select null
  from   PER_LETTER_REQUEST_LINES
  where  assignment_id     = p_assignment_id
  and   (p_mode = 'ZAP'
      or (p_mode = 'END'
    and date_from > p_end_date)));
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
--
  IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7634_ASS_LET_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7637_ASS_EVE_END_ASS');
     END IF;
     hr_utility.raise_error;
  END IF;
  */
--
--
  hr_utility.set_location('hr_assignment.del_ref_int_check',3);
  p_del_flag := 'N';
  --
  BEGIN
  select 'Y'
  into   p_del_flag
  from sys.dual
  where exists (
  select null
  from   PAY_COST_ALLOCATIONS_F
  where  assignment_id     = p_assignment_id
  and   (p_mode = 'ZAP'
      or (p_mode = 'END'
    and effective_start_date > p_end_date)));
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
--
  IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7638_ASS_COST_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7641_ASS_COST_END_ASS');
     END IF;
     hr_utility.raise_error;
  END IF;
--
--
-- 03/18/1998 Bug #642566
-- Removed code to check for existence of per_assignment_extra_info on a delete
-- as per_assignment_extra_info are now deleted along with other
-- assignment related records.
--
--
  hr_utility.set_location('hr_assignment.del_ref_int_check',5);
  p_del_flag := 'N';
  /*
    N.B. PER_SECONDARY_ASS_STATUSES rows will now be deleted if they
    started after the Assignment End Date - changed 27/5/93.
  --
  BEGIN
  select 'Y'
  into   p_del_flag
  from sys.dual
  where exists (
  select null
  from   PER_SECONDARY_ASS_STATUSES
  where  assignment_id     = p_assignment_id
  and    p_mode = 'ZAP');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
--
  IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7652_ASS_STAT_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7655_ASS_SATA_END_ASS');
     END IF;
     hr_utility.raise_error;
  END IF;
  */
--
--
  hr_utility.set_location('hr_assignment.del_ref_int_check',6);
  p_del_flag := 'N';

  /* 2537091: PPMs will be deleted if they started after end date of assignment
     changed 04-OCT-2002
  --
  BEGIN
  select 'Y'
  into   p_del_flag
  from   sys.dual
  where exists (
  select null
  from   PAY_PERSONAL_PAYMENT_METHODS_F
  where  assignment_id     = p_assignment_id
  and   (p_mode = 'ZAP'
      or (p_mode = 'END'
    and effective_start_date > p_end_date)));
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
--
  IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7656_ASS_PAY_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7659_ASS_PAY_END_ASS');
     END IF;
     hr_utility.raise_error;
  END IF;

  */
--
--
  hr_utility.set_location('hr_assignment.del_ref_int_check',7);
  p_del_flag := 'N';
  --
/*  BEGIN
  select 'Y'
  into   p_del_flag
  from   sys.dual
  where exists
     (select null
      from   pay_payroll_actions ps
      ,      pay_assignment_actions aa
      where  aa.assignment_id = P_ASSIGNMENT_ID
      and    ps.payroll_action_id = aa.payroll_action_id
      and    ps.action_type not in ('X','BEE')  --Added for bug2956160
      and   (P_MODE = 'ZAP'
         or (P_MODE = 'END' and
            ps.effective_date > P_END_DATE)));
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;*/

 IF P_MODE = 'ZAP' then -- Added for Bug 4946199
    BEGIN
     select 'Y'
     into   p_del_flag
     from   dual
     where exists
        (select null
         from   pay_payroll_actions ps
         ,      pay_assignment_actions aa
         where  aa.assignment_id = P_ASSIGNMENT_ID
	 and    ps.action_type not in ('X','BEE')  --Added for bug2956160
         and    ps.payroll_action_id = aa.payroll_action_id);
    EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
    END;

  ELSIF p_MODE = 'END' then
    BEGIN
     select 'Y'
     into   p_del_flag
     from   sys.dual
     where exists
       (select null
        from   pay_payroll_actions ps
        ,      pay_assignment_actions aa
        where  aa.assignment_id = P_ASSIGNMENT_ID
        and    ps.payroll_action_id = aa.payroll_action_id
        and    ps.action_type not in ('X','BEE')  --Added for bug2956160
        and    ps.effective_date > P_END_DATE);
    EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
    END;
   END IF;
--
  IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7664_ASS_ASS_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7667_ASS_ASS_END_ASS');
     END IF;
     hr_utility.raise_error;
  END IF;
--
--
IF p_mode = 'ZAP' THEN
--
  hr_utility.set_location('hr_assignment.del_ref_int_check',8);
  p_del_flag := 'N';
  --
  BEGIN
  select  'Y'
  into  p_del_flag
  from  sys.dual
  where exists (
    select  null
    from  hr_assignment_set_amendments  asa
    where asa.assignment_id = p_assignment_id
    and asa.include_or_exclude  = 'I'
    and not exists (
      select  null
      from  hr_assignment_set_amendments  asa2
      where asa2.assignment_set_id  = asa.assignment_set_id
      and asa2.assignment_id  <> asa.assignment_id)
    );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
--
  IF p_del_flag = 'Y' THEN
     hr_utility.set_message(801,'HR_6305_ALL_ASSGT_SET_NO_DEL');
     hr_utility.raise_error;
  END IF;
END IF;
------------------------------
-- Cobra Coverage Enrollments
--
hr_utility.set_location('hr_assignment.del_ref_int_check',9);
p_del_flag := 'N';
  --
BEGIN
select 'Y'
into   p_del_flag
from sys.dual
where exists (
select null
from   PER_COBRA_COV_ENROLLMENTS
where  assignment_id     = p_assignment_id
and   (p_mode = 'ZAP'
      or (p_mode = 'END'
    and coverage_start_date > p_end_date)));
EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
END;
--
IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7672_ASS_COBRA_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7675_ASS_COBRA_END_ASS');
     END IF;
     hr_utility.raise_error;
END IF;
------------------------------
-- Cobra Coverage Benefits
--
hr_utility.set_location('hr_assignment.del_ref_int_check',9);
p_del_flag := 'N';
  --
BEGIN
      select 'Y'
      into   p_del_flag
      from   dual
      where  exists
      (select null
       from   per_cobra_cov_enrollments     e
       ,      per_cobra_coverage_benefits_f b
       where  e.assignment_id = P_ASSIGNMENT_ID
       and    e.cobra_coverage_enrollment_id
      = b.cobra_coverage_enrollment_id
       and  (p_mode = 'ZAP'
       or   (p_mode = 'END'
       and    b.effective_end_date > P_END_DATE)));
  --
  EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
  END;
--
IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
  hr_utility.set_message(801,'HR_7668_ASS_COBR_DEL_ASS');
     ELSE
  hr_utility.set_message(801,'HR_7671_ASS_COBRA_END_ASS');
     END IF;
     hr_utility.raise_error;
END IF;
--
------------------------------
-- OTA_DELEGATE_BOOKINGS
--
hr_utility.set_location('hr_assignment.del_ref_int_check',10);
--
p_del_flag := 'N';
  --
BEGIN

/* In the select below, added the join to
   per_assignments_f to check for the primary assignment. If
   it is not a primary assignment then let it get purged.
   This has beeen changed for Bug# 787633 */

select 'Y'
into   p_del_flag
from sys.dual
where exists (
select null
from   PAY_US_EMP_FED_TAX_RULES_F pef,
       per_assignments_f          paf
where  pef.assignment_id     = p_assignment_id
 and    paf.assignment_id = pef.assignment_id
 and    paf.primary_flag = 'Y'
and   (p_mode = 'ZAP'
     or (p_mode = 'END'
     and pef.effective_start_date > p_end_date)));



EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
END;
--
IF p_del_flag = 'Y' THEN
     IF p_mode = 'ZAP' THEN
   hr_utility.set_message(801,'HR_52281_ASS_TAX_DEL_ASS');
     ELSE
   hr_utility.set_message(801,'HR_52280_ASS_TAX_END_ASS');
     END IF;
     hr_utility.raise_error;
END IF;

------------------------------
IF p_mode = 'ZAP' THEN
--
-- OTA_DELEGATE_BOOKINGS

hr_utility.set_location('hr_assignment.del_ref_int_check',11);
  per_ota_predel_validation.ota_predel_asg_validation(P_ASSIGNMENT_ID);
END IF;
---
END del_ref_int_check;
--
------------------- del_ref_int_delete         --------------------
/*
   NAME
      del_ref_int_delete
   DESCRIPTION
      Performs Third Party Delete on data that is not checked in
      del_ref_in_check. Removes data from the following tables

      For 'ZAP'
    HR_ASSIGNMENT_SET_AMENDMENTS
    PER_ASSIGNMENT_BUDGET_VALUES_F
    PER_SPINAL_POINT_PLACEMENTS_F
    PER_PAY_PROPOSALS

      For 'END' (performs a date effective delete)
    PER_SPINAL_POINT_PLACEMENTS_F
    PER_ASSIGNMENT_BUDGET_VALUES_F

      For 'FUTURE' (including FUTURE_CHANGES, DELETE_NEXT_CHANGE,
            UPDATE_OVERRIDE)
                PER_SPINAL_POINT_PLACEMENTS_F
                PER_ASSIGNMENT_BUDGET_VALUES_F

   PARAMETERS
      p_assignment_id   - The current assignment
      p_grade_id                - The current grade ('FUTURE' only')
      p_mode      - The mode of operation (ZAP, END or FUTURE)
      p_edate     - For END  the date the assignment is ENDed
          For FUTURE the date the change applies from
          For ZAP not required
      p_last_updated_by
      p_last_update_login
*/
-- Change to include table per_assignment_budget_values_f in END and FUTURE logic. Now
-- required as this table is datetracked.
-- 16-APR-1998 : SASmith

PROCEDURE del_ref_int_delete
          (
                             p_assignment_id IN INTEGER
                            ,p_grade_id IN INTEGER
          ,p_mode IN VARCHAR2
          ,p_edate IN DATE
          ,p_last_updated_by IN INTEGER
          ,p_last_update_login IN INTEGER
          ,p_calling_proc IN VARCHAR2
          ,p_val_st_date IN DATE
          ,p_val_end_date IN DATE
          ,p_datetrack_mode IN VARCHAR2
          ,p_future_spp_warning OUT NOCOPY BOOLEAN
          ) IS
p_del_flag VARCHAR2(1);
p_end_date DATE;
--
-- Parameters added for calls to spp api
--
l_placement_id    number;
l_object_version_number number;
l_effective_start_date  date;
l_effective_end_date  date;
l_datetrack_mode  varchar2(30);
l_update    number;
l_date_temp   date;
l_old_parent_spine_id   number;
l_parent_spine_id number;
l_temp      number;
l_min_step_id   number;
l_sequence    number;
l_min_start_date  date;
l_new_date    date;
l_future_spp_warning    boolean;
l_ass_end_date     date;   -- bug 7112709

  --
  -- Check to see if a grade step has been created for assignment
  --
  cursor csr_grade_step is
         select spp.placement_id
         from per_spinal_point_placements_f  spp
         where spp.assignment_id = p_assignment_id
         and p_val_st_date between spp.effective_start_date
                                 and spp.effective_end_date;
  --
  -- Checks to see if future rows exist - Datetrack mode
  --
  cursor csr_future_records is
         select spp1.placement_id
         from per_spinal_point_placements_f  spp1
         where spp1.assignment_id = p_assignment_id
         and spp1.effective_start_date > p_val_st_date;
  --
  -- Check to see if future records are for current parent spine
  -- If so flag a warning!
  --
  cursor csr_record_check is
         select spp2.placement_id
         from per_spinal_point_placements_f  spp2
         where spp2.assignment_id = p_assignment_id
         and spp2.effective_start_date > p_val_st_date
         and spp2.parent_spine_id = l_old_parent_spine_id
         and spp2.effective_end_date <= p_val_end_date;
  --
  -- Start of fix 3280773
  -- Cursor to retrive the spinal point records
  --
  cursor csr_spp_rec(p_new_date date) is
         select spp.effective_end_date,
                spp.placement_id,
                spp.object_version_number
         from   per_spinal_point_placements_f spp
         where  spp.assignment_id = p_assignment_id
         and    p_new_date between spp.effective_start_date
         and    spp.effective_end_date;
  --
  -- Cursor to retrive the SPP effective_end_date
  --
  cursor csr_spp_end_date(p_placement_id number, l_edate date) is
         select spp.effective_end_date
         from   per_spinal_point_placements_f spp
         where  spp.placement_id = p_placement_id
         and    l_edate between spp.effective_start_date
         and    spp.effective_end_date;
  -- End of 3280773
--
BEGIN
--
   --
   p_end_date := p_edate;
   --
   hr_utility.set_location('hr_assignment.del_ref_int_delete',1);
   p_del_flag  := 'N';
--
   BEGIN
--
   SELECT 'Y'
   into   p_del_flag
   FROM   SYS.DUAL
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_SPINAL_POINT_PLACEMENTS_F P
          WHERE P.ASSIGNMENT_ID     = p_assignment_id
          AND    (p_mode = 'ZAP'
              OR (p_mode = 'END'
            AND EFFECTIVE_END_DATE > p_end_date)
        OR (p_mode = 'FUTURE'
      AND P.EFFECTIVE_START_DATE >= p_end_date
      AND    NOT EXISTS
      (SELECT NULL
       FROM   PER_SPINAL_POINT_STEPS_F S
       ,      PER_GRADE_SPINES_F GS
             WHERE  GS.GRADE_SPINE_ID = S.GRADE_SPINE_ID
                         AND    S.STEP_ID         = P.STEP_ID
                   AND    GS.GRADE_ID       = NVL(p_grade_id,-1)))));
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
   hr_utility.set_location('p_del_flag :'||p_del_flag,2);
   hr_utility.set_location('p_mode :'||p_mode,2);
   hr_utility.set_location('p_edate :'||p_edate,2);
   hr_utility.set_location('p_val_st_date: '||p_val_st_date,2);
   hr_utility.set_location('p_val_end_date: '||p_val_end_date,2);

--
   IF p_del_flag  = 'Y' THEN
   --
   -- Get the min start date for the placement
   --
     select min(effective_start_date)
     into l_min_start_date
     from per_spinal_point_placements_f
     where assignment_id = p_assignment_id;

   if l_min_start_date = p_val_st_date
    and p_datetrack_mode = 'DELETE_NEXT_CHANGE' then

     hr_assignment_internal.delete_first_spp
       (p_effective_date  => p_edate,
        p_assignment_id   => p_assignment_id,
  p_validation_start_date => p_val_st_date,
      p_validation_end_date => p_val_end_date,
  p_future_spp_warning  => l_future_spp_warning
       );

     p_future_spp_warning := l_future_spp_warning;

   else

      IF p_mode = 'ZAP' THEN
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',2);

  l_datetrack_mode := 'ZAP';

           --
           -- Check that there has been a grade step created for this assignment
           --
           open csr_grade_step;
           fetch csr_grade_step into l_update;
           if csr_grade_step%found then

         --
       -- Delete using the api passing the minimum start date
       --
         hr_sp_placement_api.delete_spp
         (p_effective_date        => l_min_start_date
         ,p_datetrack_mode        => l_datetrack_mode
         ,p_placement_id          => l_placement_id
         ,p_object_version_number => l_object_version_number
         ,p_effective_start_date  => l_effective_start_date
         ,p_effective_end_date    => l_effective_end_date);

      end if;
     close csr_grade_step;

         --
   -- Removed dml and inserted call to api
   --
     /* DELETE FROM PER_SPINAL_POINT_PLACEMENTS_F P
            WHERE  P.ASSIGNMENT_ID     = p_assignment_id;
         */
   --
      ELSIF p_mode = 'FUTURE' THEN
   -- If mode is 'FUTURE' then do Delete Placements that
   -- start on or after the vaidation start date, which are related
   -- to grade spine records where the grade is different the
     --
           -- Check that there has been a grade step created for this assignment
           --
           open csr_grade_step;
           fetch csr_grade_step into l_update;
           if csr_grade_step%found then
       hr_utility.set_location('Grade Step Found',4);
             hr_utility.set_location('p_calling_proc :'||p_calling_proc,4);
             hr_utility.set_location('p_val_st_date: '||p_val_st_date,4);

     --
     -- Calling proces = 'POST_UPDATE' then a min step has to be created for the new grade scale
     --
     if p_calling_proc = 'POST_UPDATE' and
	p_datetrack_mode <> hr_api.g_update_override then -- Bug 3335915

       --
             -- get the placement_id and object_version_number for
             -- the current record as of the effective date
             --
             select spp.placement_id,spp.object_version_number,spp.effective_start_date,spp.parent_spine_id
             into l_placement_id,l_object_version_number,l_date_temp,l_old_parent_spine_id
             from per_spinal_point_placements_f spp
             where spp.assignment_id = p_assignment_id
             and p_val_st_date between spp.effective_start_date
                                              and spp.effective_end_date;

       hr_utility.set_location('l_placement_id :'||l_placement_id,5);
             hr_utility.set_location('l_object_version_number :'||l_object_version_number,5);
             hr_utility.set_location('l_date_temp :'||l_date_temp,5);
             hr_utility.set_location('l_old_parent_spine_id :'||l_old_parent_spine_id,5);

       --
             -- get the parent spine_id for the new grade
             --
             select pgs.parent_spine_id
             into l_parent_spine_id
             from per_grade_spines_f pgs
             where pgs.grade_id = p_grade_id
             and P_edate between pgs.effective_start_date
                                              and pgs.effective_end_date;

       hr_utility.set_location('l_parent_spine_id :'||l_parent_spine_id,6);

             --
             -- Get the min seuence for the new grade
             --
             select min(psp.sequence)
             into l_sequence
             from per_spinal_points psp,
                  per_spinal_point_steps_f sps
             where psp.parent_spine_id = l_parent_spine_id
             and psp.spinal_point_id = sps.spinal_point_id
             and P_edate between sps.effective_start_date
                                              and sps.effective_end_date;

       hr_utility.set_location('l_sequence :'||l_sequence,7);
             --
             -- Get the step id for the min sequence
             --
             select sps.step_id
             into l_min_step_id
             from per_spinal_point_steps_f sps,
                  per_spinal_points psp
             where sps.spinal_point_id = psp.spinal_point_id
             and   psp.parent_spine_id = l_parent_spine_id
             and   psp.sequence = l_sequence;


       hr_utility.set_location('l_min_step_id :'||l_min_step_id,8);

    open csr_future_records;
                fetch csr_future_records into l_temp;

                  if csr_future_records%found then

      hr_utility.set_location('Future record found.',9);

                  --
                  -- check if there is a step placement record starting on the same day
                  --
                    if l_date_temp = p_edate then
                      l_datetrack_mode := 'CORRECTION';
          p_future_spp_warning := TRUE;
                    else
                      l_datetrack_mode := 'UPDATE_OVERRIDE';
          p_future_spp_warning := TRUE;
                    end if;

                 else

       hr_utility.set_location('Future record not found,',10);

                   if l_date_temp = p_edate then
                     l_datetrack_mode := 'CORRECTION';
         p_future_spp_warning := FALSE;
                   else
                     l_datetrack_mode := 'UPDATE';
         p_future_spp_warning := FALSE;
                   end if;
     end if;
               close csr_future_records;

                        --
                        -- Update the now current record
                        --
                        hr_sp_placement_api.update_spp
                        (p_effective_date        => p_edate
                        ,p_datetrack_mode        => l_datetrack_mode
                        ,p_placement_id          => l_placement_id
                        ,p_object_version_number => l_object_version_number
                        ,p_step_id               => l_min_step_id
                        ,p_auto_increment_flag   => 'N'
                        ,p_reason                => ''
                        ,p_increment_number      => NULL
                        ,p_effective_start_date  => l_effective_start_date
                        ,p_effective_end_date    => l_effective_end_date);

    l_new_date := p_edate;

     end if;

     hr_utility.set_location('Deleteing the next change.',15);

     /*if p_datetrack_mode <> 'UPDATE_OVERRIDE' then
       l_new_date := p_val_st_date;
     else
       l_new_date := p_edate;
     end if;
     */
     l_new_date := p_edate;

     hr_utility.set_location('l_new_date: '||l_new_date,15);

           --
           -- Delete next change until the effective end date of the record
           -- that was just inserted matches the validation end date
           --
     -- Start of 3335915
             open csr_spp_rec(l_new_date);
             fetch csr_spp_rec into l_effective_end_date
                                   ,l_placement_id
                                   ,l_object_version_number;
             if csr_spp_rec%found then
                --
                l_datetrack_mode := 'DELETE_NEXT_CHANGE';
                --
                hr_utility.set_location('l_effective_end_date :'||l_effective_end_date, 25);
                hr_utility.set_location('p_val_end_date :'||p_val_end_date, 25);
                --
                loop
                --
                   if l_effective_end_date = p_val_end_date then
                      --
                      exit;
                      --
                   end if;
                   --
                   hr_sp_placement_api.delete_spp(
                                p_effective_date        => p_edate
                               ,p_datetrack_mode        => l_datetrack_mode
                               ,p_placement_id          => l_placement_id
                               ,p_object_version_number => l_object_version_number
                               ,p_effective_start_date  => l_effective_start_date
                               ,p_effective_end_date    => l_effective_end_date);
                   --
                   open csr_spp_end_date(l_placement_id, p_edate);
                   fetch csr_spp_end_date into l_effective_end_date;
                   close csr_spp_end_date;
                   --
                end loop;
             end if;
             --
             close csr_spp_rec;
     -- End of 3335915

     end if;
     close csr_grade_step;

         hr_utility.set_location('hr_assignment.delete_ass_ref_int',3);
         --
         -- Removed dml and inserted call to api
         --
   /*
   DELETE FROM PER_SPINAL_POINT_PLACEMENTS_F P
   WHERE  P.ASSIGNMENT_ID     = p_assignment_id
   AND    P.EFFECTIVE_START_DATE >= p_end_date
   AND    NOT EXISTS
         (SELECT NULL
    FROM   PER_SPINAL_POINT_STEPS_F S
    ,      PER_GRADE_SPINES_F GS
    WHERE  GS.GRADE_SPINE_ID = S.GRADE_SPINE_ID
    AND    S.STEP_ID         = P.STEP_ID
    AND    GS.GRADE_ID       = NVL(p_grade_id,-1));
   */
         --
      ELSE
   -- If mode is 'END' then do Date Effective Delete
   -- from p_end_date.
   --
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',4);
   --
   -- Removed dml and using api
   --
   /*
   DELETE FROM PER_SPINAL_POINT_PLACEMENTS_F P
   WHERE  P.ASSIGNMENT_ID     = p_assignment_id
   AND    P.EFFECTIVE_START_DATE > p_end_date;
   */

           --
           -- Check that there has been a grade step created for this assignment
           --
           open csr_grade_step;
           fetch csr_grade_step into l_update;
           if csr_grade_step%found then

         select spp.placement_id,spp.object_version_number,spp.effective_start_date
             into l_placement_id,l_object_version_number,l_date_temp
             from per_spinal_point_placements_f spp
             where spp.assignment_id = p_assignment_id
             and p_end_date between spp.effective_start_date
                                and spp.effective_end_date;

       -- This code has been re-written to perform the end-dating of
           -- spinal point placement records. Bug# 2854295

        l_datetrack_mode := 'DELETE';

        hr_sp_placement_api.delete_spp
                (p_effective_date        => P_edate
                ,p_datetrack_mode        => l_datetrack_mode
                ,p_placement_id          => l_placement_id
                ,p_object_version_number => l_object_version_number
                ,p_effective_start_date  => l_effective_start_date
                ,p_effective_end_date    => l_effective_end_date);

     end if;
           close csr_grade_step;


      /*hr_utility.set_location('hr_assignment.delete_ass_ref_int',5);
   UPDATE PER_SPINAL_POINT_PLACEMENTS_F
   SET    EFFECTIVE_END_DATE = p_end_date
         ,      LAST_UPDATED_BY = p_last_updated_by
         ,      LAST_UPDATE_LOGIN = p_last_update_login
         ,      LAST_UPDATE_DATE  = sysdate
   WHERE  ASSIGNMENT_ID   = p_assignment_id
   AND    p_end_date
        BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;
      */
      END IF;

    end if;
--
   END IF;

   p_del_flag  := 'N';
--
-- Check the assignment budget values
--
   BEGIN
--
   SELECT 'Y'
   into   p_del_flag
   FROM   SYS.DUAL
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_ASSIGNMENT_BUDGET_VALUES_F ABV
          WHERE ABV.ASSIGNMENT_ID     = p_assignment_id
          AND    (p_mode = 'ZAP'
              OR (p_mode = 'END'
            AND ABV.EFFECTIVE_END_DATE > p_end_date)
        OR (p_mode = 'FUTURE'
      --AND ABV.EFFECTIVE_START_DATE >= p_end_date))); -- this condition will never satisfy, as when end dating,
						       -- we do not create a record for with start date = end_date+1
       AND ABV.EFFECTIVE_END_DATE >= p_end_date)));   -- bug 7112709

--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag  = 'Y' THEN
   --
      IF p_mode = 'ZAP' THEN
      hr_utility.set_location('hr_assignment.del_ref_int_delet',30);
         DELETE FROM PER_ASSIGNMENT_BUDGET_VALUES_F ABV
         WHERE  ABV.ASSIGNMENT_ID     = p_assignment_id;

         --
      ELSE
        IF p_mode = 'END' THEN
    -- If mode is 'END' then do Date Effective Delete
    -- from p_end_date.
    --
           hr_utility.set_location('hr_assignment.del_ref_int_delete',40);

     DELETE FROM PER_ASSIGNMENT_BUDGET_VALUES_F ABV
     WHERE  ABV.ASSIGNMENT_ID     = p_assignment_id
     AND    ABV.EFFECTIVE_START_DATE > p_end_date;
   --
           hr_utility.set_location('hr_assignment.del_ref_int_delete',45);
     UPDATE PER_ASSIGNMENT_BUDGET_VALUES_F
     SET    EFFECTIVE_END_DATE = p_end_date
           ,      LAST_UPDATED_BY    = p_last_updated_by
           ,      LAST_UPDATE_LOGIN  = p_last_update_login
           ,      LAST_UPDATE_DATE   = sysdate
     WHERE  ASSIGNMENT_ID      = p_assignment_id
     AND    p_end_date
            BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;
        END IF;
       --
     -- addition for Bug 7112709 starts
     IF p_mode = 'FUTURE' THEN
    -- If mode is 'FUTURE' then do Date Effective Delete for all future records
    -- from p_end_date. Further, open the current end dated record. Set the last date
    -- of assignment_budget_value record same as the last date of current assignmet.
    --
     hr_utility.set_location('hr_assignment.del_ref_int_delete',46);
     hr_utility.set_location('p_end_date '||p_end_date, 47);

     DELETE FROM PER_ASSIGNMENT_BUDGET_VALUES_F ABV
     WHERE  ABV.ASSIGNMENT_ID     = p_assignment_id
     AND    ABV.EFFECTIVE_START_DATE > p_end_date;
   --
     hr_utility.set_location(' No of rows deleted '||sql%rowcount,48);
     hr_utility.set_location('hr_assignment.del_ref_int_delete',49);

     select effective_end_date into l_ass_end_date
     from per_all_assignments_f
     where assignment_id = p_assignment_id
     and p_end_date between EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

     hr_utility.set_location('l_ass_end_date '||l_ass_end_date,50);


     UPDATE PER_ASSIGNMENT_BUDGET_VALUES_F
     SET    EFFECTIVE_END_DATE = l_ass_end_date
           ,      LAST_UPDATED_BY    = p_last_updated_by
           ,      LAST_UPDATE_LOGIN  = p_last_update_login
           ,      LAST_UPDATE_DATE   = sysdate
     WHERE  ASSIGNMENT_ID      = p_assignment_id
     AND    p_end_date
            BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

      hr_utility.set_location('No of rows updated '||sql%rowcount,51);

      END IF;
      -- Addition for Bug 7112709 ends

      END IF;
--
   END IF;

 --
 --

IF p_mode = 'ZAP' THEN
   hr_utility.set_location('hr_assignment.del_ref_int_delete',5);
   p_del_flag  := 'N';
--
   BEGIN
--
-- Just do a lookup without any complex where clause because the complex
-- where clause has been done in PRE-DELETE triggers.
   SELECT 'Y'
   into   p_del_flag
   FROM   SYS.DUAL
   WHERE  EXISTS
         (SELECT NULL
          FROM   HR_ASSIGNMENT_SET_AMENDMENTS
          WHERE  ASSIGNMENT_ID     = p_assignment_id);
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag  = 'Y' THEN
   --
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',6);
         DELETE FROM HR_ASSIGNMENT_SET_AMENDMENTS
         WHERE  ASSIGNMENT_ID     = p_assignment_id;
   END IF;
--
  --
 --
   hr_utility.set_location('hr_assignment.del_ref_int_delete',9);
   p_del_flag  := 'N';
--
   BEGIN
--
   SELECT 'Y'
   into   p_del_flag
   FROM   SYS.DUAL
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_SECONDARY_ASS_STATUSES
          WHERE  ASSIGNMENT_ID     = p_assignment_id);
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag  = 'Y' THEN
   --
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',10);
         DELETE FROM PER_SECONDARY_ASS_STATUSES
         WHERE  ASSIGNMENT_ID     = p_assignment_id;
   END IF;
   --
--
   hr_utility.set_location('hr_assignment.del_ref_int_delete',11);
   p_del_flag  := 'N';
--
   BEGIN
--
   SELECT 'Y'
   into   p_del_flag
   FROM   SYS.DUAL
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_PAY_PROPOSALS
          WHERE  ASSIGNMENT_ID     = p_assignment_id);
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag  = 'Y' THEN
   --
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',12);
         DELETE FROM PER_PAY_PROPOSALS
         WHERE  ASSIGNMENT_ID     = p_assignment_id;
   END IF;
   --
   /* This is being changed for Bug# 785427 */

   hr_utility.set_location('hr_assignment.del_ref_int_delete',11);
   p_del_flag  := 'N';

   BEGIN
        select 'Y'
       into   p_del_flag
       from sys.dual
       where exists (
             select null
             from   PAY_US_EMP_FED_TAX_RULES_F pef
             where  pef.assignment_id     = p_assignment_id);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag  = 'Y' THEN
   --
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',12);
      /* If the federal tax record exists then the state, county
         and city tax records also exist (due to the defaulting of
         tax records). So, delete from all 4 table. In addition, delete
         from the table pay_us_asg_reporting as well */

      DELETE FROM PAY_US_ASG_REPORTING
      WHERE  ASSIGNMENT_ID     = p_assignment_id;

      DELETE FROM PAY_US_EMP_CITY_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id;

      DELETE FROM PAY_US_EMP_COUNTY_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id;

      DELETE FROM PAY_US_EMP_STATE_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id;

      DELETE FROM PAY_US_EMP_FED_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id;

   END IF;
   --

   -- 03/18/1998 Bug #642566
   -- Remove per_assignment_extra_info records
   hr_utility.set_location('hr_assignment.del_ref_int_delete',14);
   p_del_flag  := 'N';
--
   BEGIN
--
   SELECT 'Y'
   into   p_del_flag
   FROM   SYS.DUAL
   WHERE  EXISTS
         (SELECT NULL
          FROM   PER_ASSIGNMENT_EXTRA_INFO
          WHERE  ASSIGNMENT_ID     = p_assignment_id);
--
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag  = 'Y' THEN
   --
      hr_utility.set_location('hr_assignment.delete_ass_ref_int',16);
         DELETE FROM PER_ASSIGNMENT_EXTRA_INFO
         WHERE  ASSIGNMENT_ID     = p_assignment_id;
   END IF;
   -- 03/18/1998 Change Ends
--
ELSIF p_mode = 'END' then

      DELETE FROM PAY_US_EMP_CITY_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id
      AND    EFFECTIVE_START_DATE > p_end_date;

      UPDATE PAY_US_EMP_CITY_TAX_RULES_F
      SET    EFFECTIVE_END_DATE = p_end_date
      ,      LAST_UPDATED_BY = p_last_updated_by
      ,      LAST_UPDATE_LOGIN = p_last_update_login
      ,      LAST_UPDATE_DATE  = sysdate
      WHERE  ASSIGNMENT_ID   = p_assignment_id
      AND    p_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

      DELETE FROM PAY_US_EMP_COUNTY_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id
      AND    EFFECTIVE_START_DATE > p_end_date;

      UPDATE PAY_US_EMP_COUNTY_TAX_RULES_F
      SET    EFFECTIVE_END_DATE = p_end_date
      ,      LAST_UPDATED_BY = p_last_updated_by
      ,      LAST_UPDATE_LOGIN = p_last_update_login
      ,      LAST_UPDATE_DATE  = sysdate
      WHERE  ASSIGNMENT_ID   = p_assignment_id
      AND    p_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

      DELETE FROM PAY_US_EMP_STATE_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id
      AND    EFFECTIVE_START_DATE > p_end_date;

      UPDATE PAY_US_EMP_STATE_TAX_RULES_F
      SET    EFFECTIVE_END_DATE = p_end_date
      ,      LAST_UPDATED_BY = p_last_updated_by
      ,      LAST_UPDATE_LOGIN = p_last_update_login
      ,      LAST_UPDATE_DATE  = sysdate
      WHERE  ASSIGNMENT_ID   = p_assignment_id
      AND    p_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

      DELETE FROM PAY_US_EMP_FED_TAX_RULES_F
      WHERE  ASSIGNMENT_ID     = p_assignment_id
      AND    EFFECTIVE_START_DATE > p_end_date;

      UPDATE PAY_US_EMP_FED_TAX_RULES_F
      SET    EFFECTIVE_END_DATE = p_end_date
      ,      LAST_UPDATED_BY = p_last_updated_by
      ,      LAST_UPDATE_LOGIN = p_last_update_login
      ,      LAST_UPDATE_DATE  = sysdate
      WHERE  ASSIGNMENT_ID   = p_assignment_id
      AND    p_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

END IF;  -- ZAP /END section
--
--
END del_ref_int_delete;
--
--
------------------- del_ref_int_delete         --------------------
--
/*
  NAME
     tidy_up_ref_int
  DESCRIPTION
     This procedure performs two operations.
     The first occurs when it is called with a parameter of 'END' - the
     procedure then moves the end date of any child rows for the assignment
     so that it is set to be the end date of the assignment.

     The second occurs when it is called with a parameter of 'FUTURE'.
     This is the case when a FUTURE_CHANGE of DELETE_NEXT_CHANGE is going
     to open the assignment out nocopy beyond its current End Date. The procedure
     resets the End Dates of any child rows to be that on the Assignment. In
     the case of Costing records dates are only changed if there are not
     future records.

     The following tables are affected.

     PAY_COST_ALLOCATIONS_F
     PER_SECONDARY_ASS_STATUSES
     PAY_PERSONAL_PAYMENT_METHODS_F
     PER_ASSIGNMENT_BUDGET_VALUES_F

  PARAMETERS
     p_assignment_id    - Assignment ID
     p_mode                     - 'END' or 'FUTURE'
     p_new_end_date             - The new end date of the parent Assignment
     p_old_end_date             - The Assignment End Date before the operation
     p_last_updated_by
     p_last_update_login
     p_cost_warning             - Pass back warning if future costing records
                                  exist. Can only set to TRUE if mode is
                                  FUTURE.
*/
--
PROCEDURE tidy_up_ref_int
  (p_assignment_id     IN            INTEGER
   ,p_mode              IN            VARCHAR2
   ,p_new_end_date      IN            DATE
  ,p_old_end_date                    DATE
   ,p_last_updated_by                 INTEGER
    ,p_last_update_login               INTEGER
  ,p_cost_warning         OUT NOCOPY BOOLEAN) IS
  --
  p_del_flag             VARCHAR2(1) := 'N';
  l_exists               NUMBER := 0;
  l_proc                 VARCHAR(72) := 'hr_assignment.tidy_up_ref_int';
  l_effective_start_Date DATE;
  l_effective_end_date   DATE;
  --
  -- Retrieve all current Assignment Rate records for the assignment.
  --
  CURSOR csr_current_asg_rates IS
    SELECT pgr.grade_rule_id,
           pgr.object_version_number
    FROM   pay_grade_rules_f pgr
    WHERE  pgr.grade_or_spinal_point_id = p_assignment_id
    AND    pgr.rate_type = 'A'
    AND    p_new_end_date BETWEEN pgr.effective_start_date
                              AND pgr.effective_end_date
    AND    p_mode='END';
  --
  -- Retrieve all the future-only Assignment Rate records for the assignment.
  --
  CURSOR csr_future_asg_rates IS
    SELECT pgr.grade_rule_id,
           pgr.object_version_number,
           pgr.effective_start_date
    FROM   pay_grade_rules_f pgr
    WHERE  pgr.grade_or_spinal_point_id = p_assignment_id
    AND    pgr.rate_type = 'A'
    AND    p_new_end_date < pgr.effective_start_date
    AND    p_mode='END';
  --
BEGIN
  --
  hr_utility.set_location('hr_assignment.tidy_up_ref_int',1);
  --
   p_cost_warning := FALSE;
   BEGIN
      select 'Y'
      into   p_del_flag
      from   sys.dual
      where exists (
       select null
       from   per_secondary_ass_statuses
       where  assignment_id = p_assignment_id
       and    ((p_mode = 'END'
       and p_new_end_date
     between START_DATE and nvl(END_DATE,
              to_date('31/12/4712','DD/MM/YYYY')))
             or
         (p_mode = 'FUTURE'
         and p_old_end_date = nvl(END_DATE,
                     to_date('31/12/4712','DD/MM/YYYY')))));
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;
  --
   IF p_del_flag = 'Y' THEN
   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',2);
   --
      update per_secondary_ass_statuses
      set END_DATE = decode(p_new_end_date,to_date('31/12/4712','DD/MM/YYYY'),
          null,p_new_end_date)
      ,      last_updated_by = P_LAST_UPDATED_BY
      ,      last_update_login = P_LAST_UPDATE_LOGIN
      ,      last_update_date  = sysdate
      where assignment_id = p_assignment_id
      and   ((p_mode = 'END'
    and p_new_end_date
     between START_DATE and nvl(END_DATE,
              to_date('31/12/4712','DD/MM/YYYY')))
             or
         (p_mode = 'FUTURE'
         and p_old_end_date = nvl(END_DATE,
                     to_date('31/12/4712','DD/MM/YYYY'))));
   END IF;
   --
   p_del_flag := 'N';
   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',3);
   --
   BEGIN
      select 'Y'
      into   p_del_flag
      from   sys.dual
      where exists (
       select null
       from   per_secondary_ass_statuses
       where  assignment_id = p_assignment_id
       and    p_mode = 'END'
       and p_new_end_date < START_DATE);
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;
   --
   IF p_del_flag = 'Y' THEN
   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',4);
   --
      delete from per_secondary_ass_statuses
      where assignment_id = p_assignment_id
      and   p_mode = 'END'
      and p_new_end_date < START_DATE;
   END IF;
   --
   p_del_flag := 'N';
   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',5);
   --
   BEGIN
      select 'Y'
      into   p_del_flag
      from   sys.dual
      where exists (
       select null
       from   pay_cost_allocations_f
       where  assignment_id = p_assignment_id
       and    ((p_mode = 'END'
       and p_new_end_date
     between effective_start_date and effective_end_date)
             or
         (p_mode = 'FUTURE'
         and p_old_end_date = effective_end_date)));
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag = 'Y' THEN
   --
      hr_utility.set_location('hr_assignment.tidy_up_ref_int',6);

      if p_mode = 'END' then
        hr_utility.set_location('hr_assignment.tidy_up_ref_int',7);
        update pay_cost_allocations_f
        set effective_end_date = p_new_end_date
        ,      last_updated_by = P_LAST_UPDATED_BY
        ,      last_update_login = P_LAST_UPDATE_LOGIN
        ,      last_update_date  = sysdate
        where assignment_id = p_assignment_id
        and   ((p_mode = 'END'
      and p_new_end_date
       between effective_start_date and effective_end_date));
      elsif p_mode='FUTURE' then
        hr_utility.set_location('hr_assignment.tidy_up_ref_int',8);

        /*
  ** When dealing with delete FUTURE_CHANGE, only open out
  ** the costing record if no future costing record exists.
  ** If they do leaving the costing alone and display
  ** message to the user informing them of the situation.
  */
  select count(*)
    into l_exists
    from pay_cost_allocations_f
   where assignment_id = p_assignment_id
     and effective_start_date > p_old_end_date;

  if l_exists = 0 then
          hr_utility.set_location('hr_assignment.tidy_up_ref_int',9);
          update pay_cost_allocations_f
          set effective_end_date = p_new_end_date
          ,      last_updated_by = P_LAST_UPDATED_BY
          ,      last_update_login = P_LAST_UPDATE_LOGIN
          ,      last_update_date  = sysdate
          where assignment_id = p_assignment_id
          and   (p_mode = 'FUTURE'
    and    p_old_end_date = effective_end_date);
  else
          hr_utility.set_location('hr_assignment.tidy_up_ref_int',10);
    p_cost_warning := TRUE;
        end if;

      end if;
   --
   END IF;


 -- New logic added to deal with per assignment_budget_values_f. Now required as this
-- table is datetracked. The following code works when a mode of end is required (i.e. the
-- user has requested a date effective delete which will terminate the row at a given point in time).
--
-- The first thing is to remove any rows which have a start date greater than the requested NEW
-- end date. This will take care of all future rows.
-- What then needs to happen is to change the end date of the existing row to make sure the current child
-- row stays in line with the parent.
-- SASmith : 16-APR-1998

 hr_utility.set_location(p_new_end_date,11);
 hr_utility.set_location(p_mode,12);
 hr_utility.set_location(p_old_end_date,13);

 hr_utility.set_location('hr_assignment.tidy_up_ref_int',15);

 p_del_flag := 'N';

    --
   --
   BEGIN
      select 'Y'
      into   p_del_flag
      from   sys.dual
      where exists (
       select null
       from   per_assignment_budget_values_f abv
       where  abv.assignment_id = p_assignment_id
       and    p_mode = 'END'
       and p_new_end_date < abv.effective_start_date);
   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;
--
   IF p_del_flag = 'Y' THEN
   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',20);
   --
      delete from per_assignment_budget_values_f abv
      where abv.assignment_id = p_assignment_id
      and   p_mode = 'END'
      and p_new_end_date < abv.effective_start_date;
   END IF;

 p_del_flag := 'N';
   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',25);


   BEGIN
      select 'Y'
      into   p_del_flag
      from   sys.dual
      where exists (
       select null
       from   per_assignment_budget_values_f abv
       where  abv.assignment_id = p_assignment_id
       and    p_mode = 'END'
       and p_new_end_date between abv.effective_start_date and abv.effective_end_date);

   EXCEPTION
       WHEN NO_DATA_FOUND THEN NULL;
   END;

   IF p_del_flag = 'Y' THEN
   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',30);
   --
      update per_assignment_budget_values_f abv
      set abv.effective_end_date   = p_new_end_date
      ,      abv.last_updated_by   = P_LAST_UPDATED_BY
      ,      abv.last_update_login = P_LAST_UPDATE_LOGIN
      ,      abv.last_update_date  = sysdate
      where abv.assignment_id      = p_assignment_id
      and   p_mode = 'END'
        and p_new_end_date between abv.effective_start_date and abv.effective_end_date;

   END IF;

   --
   hr_utility.set_location('hr_assignment.tidy_up_ref_int',35);
   --
   -- # 2437795
   -- Reversing TAX records
     --
     IF p_mode = 'FUTURE' THEN
     --
         hr_utility.set_location('hr_assignment.tidy_up_ref_int',42);
         hr_utility.trace(' **** old end date = '||to_char(p_old_end_date,'dd-mon-yyyy'));
         declare
            cursor csr_asg is
              select max(effective_end_date)
                from pay_us_emp_fed_tax_rules_f
               where assignment_id = p_assignment_id;
            l_end_date date;
         begin
            open csr_asg;
            fetch csr_asg into l_end_date;
            close csr_asg;
            hr_utility.trace(' **** l_end_date = '||to_char(l_end_date,'dd-mon-yyyy'));
            if l_end_date is not null then
               pay_us_update_tax_rec_pkg.reverse_term_emp_tax_records(p_assignment_id, l_end_date);
            end if;
         end;
         --
         hr_utility.set_location('hr_assignment.tidy_up_ref_int',45);
      END IF;
      -- end #2437795
  --
  --adhunter added for bug 2537091 04-OCT-02
  --need to handle pay_personal_payment_methods in the same way as the others above.
  --
  hr_utility.set_location('hr_assignment.tidy_up_ref_int',50);
  DECLARE
    l_effective_start_date date;
    l_effective_end_date date;
    --
    --retrieve all the current PPMs
    --
    cursor csr_curr_ppm is
    select ppm.personal_payment_method_id,ppm.object_version_number
    from   pay_personal_payment_methods_f ppm
    where  ppm.assignment_id = p_assignment_id
    and    p_new_end_date between ppm.effective_start_date and ppm.effective_end_date
    and    p_mode='END';
    --
    --retrieve all the future-only PPMs
    --
    cursor csr_fut_ppm is
    select ppm.personal_payment_method_id,ppm.object_version_number,ppm.effective_start_date
    from   pay_personal_payment_methods_f ppm
    where  ppm.assignment_id = p_assignment_id
    and    p_new_end_date < ppm.effective_start_date
    and    p_mode='END';
  --
  BEGIN
    for l_curr_rec in csr_curr_ppm loop
     hr_utility.set_location('ppm_id '||l_curr_rec.personal_payment_method_id,55);
     --
     --end date current DT row and delete future rows for this PPM
     --this means that future-only PPMs are left.
     --
     hr_personal_pay_method_api.delete_personal_pay_method
        (p_effective_date                => p_new_end_date
        ,p_datetrack_delete_mode         => 'DELETE'
        ,p_personal_payment_method_id    => l_curr_rec.personal_payment_method_id
        ,p_object_version_number         => l_curr_rec.object_version_number
        ,p_effective_start_date          => l_effective_start_date
        ,p_effective_end_date            => l_effective_end_date
        );
    end loop;
    for l_fut_rec in csr_fut_ppm loop
     hr_utility.set_location('ppm_id '||l_fut_rec.personal_payment_method_id,60);
     --
     --delete future-only PPMs, last loop removed future DT rows of current PPMs
     --
     hr_personal_pay_method_api.delete_personal_pay_method
        (p_effective_date                => l_fut_rec.effective_start_date
        ,p_datetrack_delete_mode         => 'ZAP'
        ,p_personal_payment_method_id    => l_fut_rec.personal_payment_method_id
        ,p_object_version_number         => l_fut_rec.object_version_number
        ,p_effective_start_date          => l_effective_start_date
        ,p_effective_end_date            => l_effective_end_date
        );
    end loop;
  END;
  --
  hr_utility.set_location(l_proc,70);
  --
  -- End Date any current Assignment Rates
  --
  FOR crec_current_asg_rates IN csr_current_asg_rates LOOP
    --
    hr_utility.set_location(l_proc||'/'||crec_current_asg_rates.grade_rule_id,80);
    --
    hr_rate_values_api.delete_rate_value
      (p_validate              => FALSE
      ,p_grade_rule_id         => crec_current_asg_rates.grade_rule_id
      ,p_datetrack_mode        => hr_api.g_delete
      ,p_effective_date        => p_new_end_date
      ,p_object_version_number => crec_current_asg_rates.object_version_number
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date);
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,90);
  --
  -- Delete any future dated assignment rates if we are Ending the Assignment.
  --
  FOR crec_future_asg_rates IN csr_future_asg_rates LOOP
    --
    hr_utility.set_location(l_proc||'/'||crec_future_asg_rates.grade_rule_id,100);
    --
    hr_rate_values_api.delete_rate_value
      (p_validate              => FALSE
      ,p_grade_rule_id         => crec_future_asg_rates.grade_rule_id
      ,p_datetrack_mode        => hr_api.g_zap
      ,p_effective_date        => crec_future_asg_rates.effective_start_date
      ,p_object_version_number => crec_future_asg_rates.object_version_number
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date);
    --
  END LOOP;
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
EXCEPTION
   when others then
      p_cost_warning := null ;
      RAISE ;
--
END tidy_up_ref_int;
--
--
------------------- call_terminate_entries     --------------------
/*
  NAME
     call_terminate_entries
  DESCRIPTION
     This procedure determines the Actual Termination Date, Last Standard
     Processing Date and Final Process Date in order to terminate element
     entries and ALUs when an individual assignment is terminated or ended.

     There are several cases :-

     i. Status is END and there are no prior TERM_ASSIGNs
  => ATD = Session date
     LSD = Session date
     FPD = Session date

    ii. Status is END and there is a prior TERM_ASSIGN
  => ATD = NULL
     LSD = NULL
     FPD = Session Date

   iii. Status is TERM_ASSIGN and there are no prior TERM_ASSIGNs
  => ATD = Validation Start Date - 1
     LSD = (IF Assignment has Payroll then END_DATE of current
      processing period
      ELSE
         Validation Start Date - 1)
           FPD = NULL

    iv. Status is TERM_ASSIGN and there is a prior TERM_ASSIGN
  => No processing required

  PARAMETERS
     p_assignment_id    - Assignment ID
     p_status                   - 'END' or 'TERM_ASSIGN'
     p_start_date               - Validation Start Date for TERM_ASSIGN or
          Session Date for 'END'
*/
--
PROCEDURE call_terminate_entries
          (P_ASSIGNMENT_ID IN NUMBER
          ,P_STATUS        IN VARCHAR2
          ,P_START_DATE    IN DATE
          ) IS
--
p_actual_term_date   DATE;
p_last_standard_date DATE;
p_final_process_date DATE;
--
-- VT 10/08/96 bug #306710 new local variable
l_entries_changed VARCHAR2(1) := 'N';
--
FUNCTION previous_term_exists
   (   p_assignment_id    NUMBER
   ,   p_start_date       DATE
   ) RETURN BOOLEAN IS
--
term_exists          VARCHAR2(1) := 'N';
------------------------
BEGIN
-- This function returns TRUE if a TERM_ASSIGN status exists earlier than the
-- date we are considering.
--
   hr_utility.set_location('peassign.call_terminate_entries',1);
   --
   BEGIN
      select 'Y'
      into   term_exists
      from sys.dual
      where exists
      (select null
      from   per_assignments_f a
      ,      per_assignment_status_types s
      where  a.assignment_id = p_assignment_id
      and    a.effective_start_date < p_start_date
      and    a.assignment_status_type_id = s.assignment_status_type_id
      and    s.per_system_status = 'TERM_ASSIGN');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
   END;
   --
   RETURN (term_exists = 'Y');
--
END previous_term_exists;
-------------------------
BEGIN
--
  hr_utility.set_location('peassign.call_terminate_entries',2);
  IF P_STATUS = 'END' THEN
  --
     IF previous_term_exists(p_assignment_id
          ,p_start_date) THEN
        p_actual_term_date    := NULL;
  p_last_standard_date  := NULL;
  p_final_process_date  := p_start_date;
     ELSE
  p_actual_term_date    := p_start_date;
  p_last_standard_date  := p_start_date;
  p_final_process_date  := p_start_date;
     END IF;   -- IF previous_term_exists(....
     --
  hr_utility.set_location('peassign.call_terminate_entries',3);
  -- VT 10/08/96 bug #306710 added parameter
     hrempter.terminate_entries_and_alus(p_assignment_id
          ,p_actual_term_date
          ,p_last_standard_date
          ,p_final_process_date
          ,null
          ,l_entries_changed);
  --
  ELSE   -- (IF p_status = 'TERM_ASSIGN')
  --
  hr_utility.set_location('peassign.call_terminate_entries',4);
     IF previous_term_exists(p_assignment_id
          ,p_start_date) THEN NULL;
     ELSE
  p_actual_term_date    := p_start_date -1;
  p_last_standard_date  := p_start_date -1;
  p_final_process_date  := NULL;
  --
  hr_utility.set_location('peassign.call_terminate_entries',5);
  BEGIN
    select tp.end_date
    into   p_last_standard_date
    from   per_assignments_f a
    ,      per_time_periods  tp
    where  a.assignment_id = p_assignment_id
    and    a.effective_end_date = p_start_date - 1
    and    a.payroll_id = tp.payroll_id
    and    p_start_date - 1 between tp.start_date and tp.end_date;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
        END;
     --
  hr_utility.set_location('peassign.call_terminate_entries',6);
  -- VT 10/08/96 bug #306710 added parameter
  hrempter.terminate_entries_and_alus(p_assignment_id
             ,p_actual_term_date
             ,p_last_standard_date
             ,p_final_process_date
             ,null
             ,l_entries_changed);
     --
     END IF; -- IF previous_term_exists( ...
  --
  END IF; -- IF P_STATUS = 'END'
--
END call_terminate_entries;
--
------------ test_for_cancel_reterm ------------------------------------
  /*
   This procedure works out nocopy whether a Cancel or retermination is required
   follwoing an operation that affects the "leading TERM_ASSIGN" status
   */
procedure test_for_cancel_reterm
(p_assignment_id         in number
,p_validation_start_date in date
,p_validation_end_date   in date
,p_mode                  in varchar2
,p_current_status_type   in varchar2
,p_old_status_type       in varchar2
,p_cancel_atd            in out nocopy date
,p_cancel_lspd           in out nocopy date
,p_reterm_atd            in out nocopy date
,p_reterm_lspd           in out nocopy date
) is
--
l_leading_date DATE;
l_new_leading_date DATE;
--
l_cancel_atd            date := p_cancel_atd ;
l_cancel_lspd           date := p_cancel_lspd ;
l_reterm_atd            date := p_reterm_atd ;
l_reterm_lspd           date := p_reterm_lspd;
--
function leading_term_assign(l_ignore_val_start_date varchar2)
return boolean is
begin
      select min(a.effective_start_date)
      into   l_leading_date
      from   per_assignments_f a
      ,      per_assignment_status_types s
      where  a.assignment_id = p_assignment_id
      and   (l_ignore_val_start_date = 'N' or
      (l_ignore_val_start_date = 'Y' and
             effective_start_date <> p_validation_start_date ))
      and    a.assignment_status_type_id = s.assignment_status_type_id
      and    s.per_system_status = 'TERM_ASSIGN';
      --
      return(l_leading_date is not null);
end leading_term_assign;
--
function get_lspd(l_default_lspd date) return date is
l_new_lspd date;
begin
   l_new_lspd := l_default_lspd;
   begin
      select tp.end_date
      into   l_new_lspd
      from   per_assignments_f a
      ,      per_time_periods  tp
      where  a.assignment_id = p_assignment_id
      and    a.effective_end_date = l_default_lspd
      and    a.payroll_id = tp.payroll_id
      and    l_default_lspd between tp.start_date and tp.end_date;
   exception
      WHEN NO_DATA_FOUND THEN NULL;
   end;
   --
   return(l_new_lspd);
end;
--
procedure cancel_required is
/*----------------------------------------------------------------
  This procedure sets the ATD and LSPD of the leading TERM_ASSIGN
  so that POST-COMMIT cancellation can use them.

  N.B. Strictly the FPD should also be set in the case when the operation
       is removing the assignment END date. However this is complicated
       by the fact that under certain circumstances the END date may be
       automatically moved to be at the ATD (see
       hr_assignment.check_term).

       This is not too problematic because a call to
       maintain_entries_asg will end any entries that are left open
       incorrectly.
-----------------------------------------------------------------*/
begin
   p_cancel_atd  := l_leading_date - 1;
   p_cancel_lspd := get_lspd(l_leading_date - 1);
end cancel_required;
--
begin
--
/*----------------------------------------------------------------
   Firstly do the check to see if CANCEL is required
-----------------------------------------------------------------*/

/*----------------------------------------------------------------
   if the mode is CORRECTION,UPDATE,UPDATE-OVERRIDE or UPDATE_INSERT
   AND
   if the current assignment status type is TERM_ASSIGN and the old
   assignment status type is not TERM_ASSIGN i.e. this operation is actually
   altering the assignment status type
   AND
   there is a leading TERM_ASSIGN out nocopy of all the TERM_ASSIGNS other
   than the one currently being created

       then if this leading TERM_ASSIGN is after the validation start date
      of the current modification then cancellation of entries
      will be required

   ELSE

   if the mode is UPDATE-OVERRIDE
   AND
   the assignment status is not being changed by this operation
   AND
   there is a leading TERM_ASSIGN other out nocopy of all the TERM_ASSIGNS

       then if this leading TERM_ASSIGN is after the validation start
      date of the current operation then cancellation of entries
      will be required

   ELSE

   if the mode is DELETE-NEXT-CHANGE or FUTURE-CHANGES-DELETE
   AND
   there is a leading TERM_ASSIGN other out nocopy of all the TERM_ASSIGNS

       then if this leading TERM_ASSIGN is on or after the validation start
      date of the current operation then cancellation of entries
      will be required
-----------------------------------------------------------------*/
--
hr_utility.set_location('hr_assignment.test_for_cancel_reterm',1);
   if p_mode in ('CORRECTION'
    ,'UPDATE'
    ,'UPDATE_OVERRIDE'
    ,'UPDATE_CHANGE_INSERT' )
      and p_current_status_type = 'TERM_ASSIGN'
      and p_current_status_type <> p_old_status_type
      and leading_term_assign('Y') then
      --
      if l_leading_date > p_validation_start_date then
   cancel_required;
      end if;
      --
   elsif
      --
      p_mode = 'UPDATE_OVERRIDE'
      and p_current_status_type <> 'TERM_ASSIGN'
      and leading_term_assign('N') then
      --
      if l_leading_date > p_validation_start_date then
   cancel_required;
      end if;
      --
   elsif
      --
      p_mode in ('DELETE_NEXT_CHANGE'
    ,'FUTURE_CHANGE')
      and leading_term_assign('N') then
      --
      if l_leading_date between p_validation_start_date
          and p_validation_end_date then
   cancel_required;
   --
/*-----------------------------------------------------------------
  Now do the check to see if RE-TERMINATION is required
-----------------------------------------------------------------*/
--
/*-----------------------------------------------------------------
  If the operation is a DELETE_NEXT_CHANGE that will remove the
  leading TERM_ASSIGN and leave a subsequent TERM_ASSIGN as the
  new leading one then the re-termination process is required
  as though the new leaading TERM_ASSIGN were being created for
  the first time

  N.B. This is only necessary if the leading TERM_ASSIGN has been
       removed (i.e. if all the conditions for CANCEL_REQUIRED to
       be called are met)
-----------------------------------------------------------------*/
--
         if p_mode = 'DELETE_NEXT_CHANGE' then
      begin
         select min(a.effective_start_date)
         into   l_new_leading_date
         from   per_assignments_f a
               ,      per_assignment_status_types s
               where  a.assignment_id = p_assignment_id
               and    effective_start_date > p_validation_end_date
               and    a.assignment_status_type_id = s.assignment_status_type_id
               and    s.per_system_status = 'TERM_ASSIGN';
         --
         p_reterm_atd  := l_new_leading_date - 1;
         p_reterm_lspd := get_lspd(l_new_leading_date - 1);
         --
            exception
         when no_data_found then null;
            end;
   end if;
      --
      end if;
      --
   end if;
--
EXCEPTION
  when others then
   p_cancel_atd := l_cancel_atd ;
   p_cancel_lspd := l_cancel_lspd ;
   p_reterm_atd  := l_reterm_atd ;
   p_reterm_lspd := l_reterm_lspd ;
   RAISE;

end test_for_cancel_reterm;
--
--
-----------------------------------------------------------------------
-- check_for_cobra
--
-- This procedure checks to see if there are COBRA Enrollments
-- that have a Qualifying Date on Termination Date + 1 (i.e. Enrollment
-- is as a result of the termination)
--
-- If this Termination will be removed as a result of the operation
-- then issue a warning stating that COBRA Coverage may no longer be
-- applicable
--
PROCEDURE check_for_cobra
(p_assignment_id IN INTEGER
,p_sdate         IN DATE
,p_edate         IN DATE
) IS
--
l_cobra_term_exists VARCHAR2(1);
local_warning exception;
--
BEGIN
   hr_utility.set_location('hr_assignment.check_for_cobra',1);
  BEGIN
     select 'Y'
     into l_cobra_term_exists
     from sys.dual
     where exists
  (select null
   from   per_cobra_cov_enrollments e
   where  e.assignment_id = p_assignment_id
   and    exists
     (select null
      from   per_assignments_f a
      where  a.assignment_id = p_assignment_id
            and    a.effective_start_date between p_sdate and p_edate
            and    exists ( select null
                            from   per_assignment_status_types s
                            where  s.assignment_status_type_id
                                   = a.assignment_status_type_id
                            and    s.per_system_status = 'TERM_ASSIGN')
            and    a.effective_start_date + 1 = e.qualifying_date));
  EXCEPTION
     WHEN NO_DATA_FOUND THEN NULL;
  END;
   --
   hr_utility.set_location('hr_assignment.check_for_cobra',2);
   if l_cobra_term_exists = 'Y' then
      raise local_warning;
   end if;
   --
   EXCEPTION
      when local_warning then
     hr_utility.set_warning;
END check_for_cobra;
--
-----------------------------------------------------------------------
-- validate_pos
--
-- This procedure is called from hr_chg_date.call_session_date to ensure
-- that a new session date that is being set in PERWSEMA does not lie
-- outside the bounds of a Period of Service or Period of Placement.
--
PROCEDURE validate_pos
  (p_person_id IN VARCHAR2
  ,p_new_date  IN VARCHAR2)
IS

l_proc          VARCHAR2(80) := g_package||'validate_pos';
l_dummy_dt      DATE;
l_pos_id        NUMBER;

CURSOR   get_pos IS
SELECT   p.date_start date_start, p.period_of_service_id
FROM     per_periods_of_service p
WHERE    p.person_id = to_number(p_person_id)
AND      fnd_date.canonical_to_date(p_new_date) BETWEEN
         p.date_start AND NVL(p.final_process_date, hr_api.g_eot)
UNION
SELECT   pdp.date_start date_start, pdp.period_of_placement_id
FROM     per_periods_of_placement pdp
WHERE    pdp.person_id = to_number(p_person_id)
AND      fnd_date.canonical_to_date(p_new_date) BETWEEN
         pdp.date_start AND NVL(pdp.final_process_date, hr_api.g_eot)
ORDER BY date_start DESC;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  OPEN  get_pos;
  FETCH get_pos INTO l_dummy_dt, l_pos_id;
  CLOSE get_pos;

  hr_utility.trace('l_pos_id: '||to_char(l_pos_id));

  IF l_pos_id IS NULL THEN
     hr_utility.set_message(801,'HR_6346_EMP_ASS_NO_POS');
     hr_utility.raise_error;
  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 40);

END validate_pos;
--
--
function per_dflt_asg_cost_alloc_ff(
    p_assignment_id number,
    p_business_group_id number,
    p_position_id number,
    p_effective_date date) return varchar2 is
  l_session_date  date;
  l_formula_id    number;
  l_inputs     ff_exec.inputs_t;
  l_outputs    ff_exec.outputs_t;
  i number;
  l_cost_allocation_id number;
  l_cost_allocation_keyflex_id number;
  l_proportion number;
  l_combination_name varchar2(2000);
  l_effective_start_date  date;
  l_effective_end_date  date;
  l_object_version_number number;
  l_use_formula    varchar2(30) := 'N';
  l_formula_name varchar2(100):= 'PER_DFLT_ASG_COST_ALLOCATION';
  --
  type t_asg_cost_rec is record (
    cost_allocation_keyflex_id  number, proportion number
   );
  --
  type t_asg_cost_table is table of t_asg_cost_rec index by binary_integer;
  --
  l_rec t_asg_cost_table;
--
cursor c_formula_id(p_formula_name varchar2, p_business_group_id number,
                    p_effective_date date) is
select ff.formula_id
from ff_formulas_f ff where upper(ff.formula_name) = p_formula_name
and business_group_id = p_business_group_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor c_session_date is
select effective_date
from fnd_sessions
where session_id = userenv('sessionid');
--
--
cursor c_cost_allocation_keyflex(p_cost_allocation_keyflex_id number) is
select *
from pay_cost_allocation_keyflex
where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
and to_char(id_flex_num) in (select cost_allocation_structure
  from per_business_groups
  where business_group_id = p_business_group_id);
--
begin
  --
  hr_utility.set_location('Entering hr_assignment.per_dflt_asg_cost_alloc_ff',25);
  --
  open c_formula_id(l_formula_name, p_business_group_id, p_effective_date);
  fetch c_formula_id into l_formula_id;
  --
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',26);
  --
  if c_formula_id%notfound then
    hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',27);
    close c_formula_id;
    return 'N';
  end if;
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',28);
  close c_formula_id;
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff-formula_id :'
                                || l_formula_id,29);
  -- Insert fnd_sessions row
  open c_session_date;
  fetch c_session_date into l_session_date;
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff' || l_session_date,30);
  if c_session_date%notfound then
    hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',31);
    insert into fnd_sessions (SESSION_ID, EFFECTIVE_DATE) values(userenv('sessionid'), trunc(p_effective_date));
    hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',32);
  end if;
  --
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',33);
  -- Initialize the formula
  ff_exec.init_formula(l_formula_id,p_effective_date, l_inputs, l_outputs);
  --
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',34);
  --
  --set the inputs
  --
  for i in nvl(l_inputs.first,0) .. nvl(l_inputs.last,-1) loop
    if l_inputs(i).name = 'ASSIGNMENT_ID' then
      l_inputs(i).value := p_assignment_id;
    elsif l_inputs(i).name = 'BUSSINESS_GROUP_ID' then
      l_inputs(i).value := p_business_group_id;
    elsif l_inputs(i).name = 'POSITION_ID' then
      l_inputs(i).value := p_position_id;
    elsif l_inputs(i).name = 'EFFECTIVE_DATE' then
      l_inputs(i).value := trunc(p_effective_date);
    end if;
  end loop;
  --
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',35);
  --
  ff_exec.run_formula(l_inputs, l_outputs);
  --
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',36);
  --
  for i in nvl(l_outputs.first,0) .. nvl(l_outputs.last,-1) loop
    if (l_outputs(i).name = 'USE_FORMULA') then
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff-'|| l_outputs(i).value,361);
     l_use_formula := nvl(l_outputs(i).value,'N');
     if (l_use_formula <> 'Y')then
      return 'N';
     end if;
    elsif (substr(l_outputs(i).name,1,26) = 'COST_ALLOCATION_KEYFLEX_ID') then
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff-'|| l_outputs(i).value,362);
      l_rec(to_number(substr(l_outputs(i).name,27))).cost_allocation_keyflex_id := l_outputs(i).value;
    elsif (substr(l_outputs(i).name,1,10) = 'PROPORTION') then
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff-'|| l_outputs(i).value,363);
      l_rec(to_number(substr(l_outputs(i).name,11))).PROPORTION := l_outputs(i).value;
    end if;
  end loop;
  --
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',37);
  --
  if l_use_formula = 'Y' then
  for i in nvl(l_rec.first,0) .. nvl(l_rec.last,-1) loop
    hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff l_rec(i).cost_all_kf_id'
         || l_rec(i).cost_allocation_keyflex_id,381);
    hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff l_rec(i).proportion'
         || l_rec(i).proportion,382);
    if (nvl(l_rec(i).cost_allocation_keyflex_id, -1) <> -1) then
     --
     --
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff - l_rec(i).proportion:'||l_rec(i).proportion,313);
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff - l_rec(i).cost_kf_id:'||l_rec(i).cost_allocation_keyflex_id,314);
     --
     l_proportion := trunc(l_rec(i).proportion,4);
     --
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff - l_proportion1 :'||l_proportion,315);
     if l_proportion > 1 then
       l_proportion := 1;
     end if;
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff - l_proportion2 :'||l_proportion,316);
     --
     if l_proportion > 0 then
     for r3 in c_cost_allocation_keyflex(l_rec(i).cost_allocation_keyflex_id) loop
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',39);
     --
     pay_cost_allocation_api.create_cost_allocation(
                       p_validate             =>false ,
                       p_effective_date         =>p_effective_date,
                       p_assignment_id          =>p_assignment_id,
                       p_cost_allocation_id     =>l_cost_allocation_id,
                       p_business_group_id      =>p_business_group_id,
                       p_combination_name       =>l_combination_name,
                       p_cost_allocation_keyflex_id =>l_cost_allocation_keyflex_id,
                       p_proportion             =>l_proportion,
                       p_effective_start_date   =>l_effective_start_date,
                       p_effective_end_date     =>l_effective_end_date,
                       p_object_version_number  =>l_object_version_number,
                       p_segment1                   =>r3.segment1,
                       p_segment2                   =>r3.segment2,
                       p_segment3                   =>r3.segment3,
                       p_segment4                   =>r3.segment4,
                       p_segment5                   =>r3.segment5,
                       p_segment6                   =>r3.segment6,
                       p_segment7                   =>r3.segment7,
                       p_segment8                   =>r3.segment8,
                       p_segment9                   =>r3.segment9,
                       p_segment10                  =>r3.segment10,
                       p_segment11                  =>r3.segment11,
                       p_segment12                  =>r3.segment12,
                       p_segment13                  =>r3.segment13,
                       p_segment14                  =>r3.segment14,
                       p_segment15                  =>r3.segment15,
                       p_segment16                  =>r3.segment16,
                       p_segment17                  =>r3.segment17,
                       p_segment18                  =>r3.segment18,
                       p_segment19                  =>r3.segment19,
                       p_segment20                  =>r3.segment20,
                       p_segment21                  =>r3.segment21,
                       p_segment22                  =>r3.segment22,
                       p_segment23                  =>r3.segment23,
                       p_segment24                  =>r3.segment24,
                       p_segment25                  =>r3.segment25,
                       p_segment26                  =>r3.segment26,
                       p_segment27                  =>r3.segment27,
                       p_segment28                  =>r3.segment28,
                       p_segment29                  =>r3.segment29,
                       p_segment30                  =>r3.segment30,
                       p_concat_segments            =>r3.concatenated_segments
                       );
     end loop;
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',391);
     --
     end if;
     --
     hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',40);
     --
    end if;
    --
    hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',41);
    --
  end loop;
  --
  hr_utility.set_location('hr_assignment.per_dflt_asg_cost_alloc_ff',42);
  --
  return 'Y';
  --
  end if;
  --
  hr_utility.set_location('Leaving hr_assignment.per_dflt_asg_cost_alloc_ff',43);
  --
  return 'N';
  --
end;
--
PROCEDURE load_assignment_allocation
         (p_assignment_id IN INTEGER
         ,p_business_group_id IN INTEGER
         ,p_effective_date IN DATE
                                 ,p_position_id in number) IS
--
l_row_id varchar2(100);
l_cost_allocation_id number(20);
l_cost_allocation_keyflex_id number;
l_money   varchar2(10) := 'MONEY';
l_unit1   varchar2(30);
l_unit2   varchar2(30);
l_unit3   varchar2(30);
l_period_value number;
l_period1_value number;
l_period2_value number;
l_period3_value number;
l_combination_name  varchar2(2000);
l_effective_start_date date;
l_effective_end_date date;
l_object_version_number number;
l_dummy   varchar2(30);
l_proportion    number;
--
cursor c_asg_cost_allocations(p_assignment_id number) is
select 'x'
from pay_cost_allocations_f
where assignment_id = p_assignment_id;
--
cursor c_cost_allocation_keyflex(p_cost_allocation_keyflex_id number) is
select *
from pay_cost_allocation_keyflex
where cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
and to_char(id_flex_num) in (select cost_allocation_structure
  from per_business_groups
  where business_group_id = p_business_group_id);
--
--
cursor c0 is
select *
from (
select
hr_psf_shd.system_availability_status(budget_unit1_id) unit1,
hr_psf_shd.system_availability_status(budget_unit2_id) unit2,
hr_psf_shd.system_availability_status(budget_unit3_id) unit3
from pqh_budgets
where p_effective_date between budget_start_date and budget_end_date
and position_control_flag = 'Y'
and budgeted_entity_cd = 'POSITION'
and business_group_id = p_business_group_id
)
where unit1 = 'MONEY' or unit2 = 'MONEY' or unit3 = 'MONEY';
--
cursor c1(unit1 varchar2, unit2 varchar2, unit3 varchar2) is
select src.cost_allocation_keyflex_id,
sum((decode(unit1,l_money,nvl(bset.budget_unit1_value,0),0)
    + decode(unit2,l_money,nvl(bset.budget_unit2_value,0),0)
    + decode(unit3,l_money,nvl(bset.budget_unit3_value,0),0))
    * (ele.distribution_percentage * src.distribution_percentage/10000)) proportion
from pqh_budget_fund_srcs src, pqh_budget_elements ele, pqh_budget_sets bset,
pqh_budget_periods per, pqh_budget_details det, per_time_periods stp, per_time_periods etp
where
det.position_id = p_position_id and
det.budget_detail_id= per.budget_detail_id
and per.budget_period_id = bset.budget_period_id
and per.start_time_period_id = stp.time_period_id
and per.end_time_period_id = etp.time_period_id
and p_effective_date
between stp.start_date and etp.end_date
and bset.budget_set_id = ele.budget_set_id
and ele.budget_element_id = src.budget_element_id
and src.cost_allocation_keyflex_id is not null
and det.budget_version_id in
(select budget_version_id
from pqh_budget_versions ver, pqh_budgets bgt
where ver.budget_id = bgt.budget_id
and bgt.position_control_flag = 'Y'
and bgt.budgeted_entity_cd = 'POSITION'
and bgt.business_group_id = p_business_group_id
and p_effective_date
between ver.date_from and ver.date_to
and p_effective_date
between bgt.budget_start_date and  bgt.budget_end_date
and (hr_psf_shd.system_availability_status(budget_unit1_id) = 'MONEY'
  or hr_psf_shd.system_availability_status(budget_unit2_id) = 'MONEY'
  or hr_psf_shd.system_availability_status(budget_unit3_id) = 'MONEY')
)
group by src.cost_allocation_keyflex_id;
--
cursor c2(unit1 varchar2, unit2 varchar2, unit3 varchar2) is
select
decode(unit1,l_money,nvl(per.budget_unit1_value,0),0)+
decode(unit2,l_money,nvl(per.budget_unit2_value,0),0)+
decode(unit3,l_money,nvl(per.budget_unit3_value,0),0) period_value
from pqh_budget_periods per, pqh_budget_details det,
per_time_periods stp, per_time_periods etp
where
det.position_id = p_position_id and
det.budget_detail_id= per.budget_detail_id
and per.start_time_period_id = stp.time_period_id
and per.end_time_period_id = etp.time_period_id
and p_effective_date
between stp.start_date and etp.end_date
and det.budget_version_id in
(select budget_version_id
from pqh_budget_versions ver, pqh_budgets bgt
where ver.budget_id = bgt.budget_id
and bgt.position_control_flag = 'Y'
and bgt.budgeted_entity_cd = 'POSITION'
and bgt.business_group_id = p_business_group_id
and p_effective_date
between ver.date_from and ver.date_to
and p_effective_date
between bgt.budget_start_date and  bgt.budget_end_date
and (hr_psf_shd.system_availability_status(budget_unit1_id) = 'MONEY'
  or hr_psf_shd.system_availability_status(budget_unit2_id) = 'MONEY'
  or hr_psf_shd.system_availability_status(budget_unit3_id) = 'MONEY')
);
--
BEGIN
   hr_utility.set_location('hr_assignment.load_assignment_allocation',1);
   --
   if nvl(fnd_profile.value('HR_DEFAULT_ASG_COST_ALLOC'),'N') <> 'Y' then
     return;
   end if;
   --
   hr_utility.set_location('hr_assignment.load_assignment_allocation',2);
   --
   if p_position_id is null then
     return;
   end if;
   --
   hr_utility.set_location('hr_assignment.load_assignment_allocation',3);
   hr_utility.set_location('hr_assignment.load_assignment_allocation - effec date :'|| p_effective_date,3);
   hr_utility.set_location('hr_assignment.load_assignment_allocation - p_position_id :'|| p_position_id,3);
   hr_utility.set_location('hr_assignment.load_assignment_allocation - assignment_id :'|| p_assignment_id,3);
   hr_utility.set_location('hr_assignment.load_assignment_allocation - business_group_id :'|| p_business_group_id,3);
   --
   open c_asg_cost_allocations(p_assignment_id);
   fetch c_asg_cost_allocations into l_dummy;
   if c_asg_cost_allocations%found then
     hr_utility.set_location('hr_assignment.load_assignment_allocation',4);
     return;
   end if;
   --
   hr_utility.set_location('hr_assignment.load_assignment_allocation',5);
   --
   if (per_dflt_asg_cost_alloc_ff(p_assignment_id, p_business_group_id, p_position_id, p_effective_date) = 'Y') then
     hr_utility.set_location('hr_assignment.load_assignment_allocation',6);
     return;
   end if;
   --
   hr_utility.set_location('hr_assignment.load_assignment_allocation',7);
   --
   open c0;
   fetch c0 into l_unit1, l_unit2, l_unit3;
   close c0;
   --
   hr_utility.set_location('hr_assignment.load_assignment_allocation - ' || l_unit1,8);
   hr_utility.set_location('hr_assignment.load_assignment_allocation - ' || l_unit2,9);
   hr_utility.set_location('hr_assignment.load_assignment_allocation - ' || l_unit3,10);
   --
   open c2(l_unit1, l_unit2, l_unit3);
   fetch c2 into l_period_value;
   close c2;
   --
   hr_utility.set_location('hr_assignment.load_assignment_allocation - '|| l_period_value,11);
   --
   if nvl(l_period_value,0) <> 0 then
     --
     hr_utility.set_location('hr_assignment.load_assignment_allocation ',12);
     --
     for r1 in c1(l_unit1, l_unit2, l_unit3) loop
       --
       hr_utility.set_location('hr_assignment.load_assignment_allocation - '||r1.proportion,13);
       hr_utility.set_location('hr_assignment.load_assignment_allocation - '||r1.cost_allocation_keyflex_id,14);
       --
       l_proportion := trunc(r1.proportion/l_period_value,4);
       --
       if l_proportion > 1 then
         l_proportion := 1;
       end if;
       --
       if l_proportion >0 then
       for r3 in c_cost_allocation_keyflex(r1.cost_allocation_keyflex_id) loop
         pay_cost_allocation_api.create_cost_allocation(
                       p_validate                 =>false ,
                       p_effective_date             =>p_effective_date,
                       p_assignment_id              =>p_assignment_id,
                       p_cost_allocation_id         =>l_cost_allocation_id,
                       p_business_group_id          =>p_business_group_id,
                       p_combination_name           =>l_combination_name,
                       p_cost_allocation_keyflex_id =>l_cost_allocation_keyflex_id,
                       p_proportion                 =>l_proportion,
                       p_effective_start_date       =>l_effective_start_date,
                       p_effective_end_date         =>l_effective_end_date,
                       p_object_version_number      =>l_object_version_number,
                       p_segment1                   =>r3.segment1,
                       p_segment2                   =>r3.segment2,
                       p_segment3                   =>r3.segment3,
                       p_segment4                   =>r3.segment4,
                       p_segment5                   =>r3.segment5,
                       p_segment6                   =>r3.segment6,
                       p_segment7                   =>r3.segment7,
                       p_segment8                   =>r3.segment8,
                       p_segment9                   =>r3.segment9,
                       p_segment10                  =>r3.segment10,
                       p_segment11                  =>r3.segment11,
                       p_segment12                  =>r3.segment12,
                       p_segment13                  =>r3.segment13,
                       p_segment14                  =>r3.segment14,
                       p_segment15                  =>r3.segment15,
                       p_segment16                  =>r3.segment16,
                       p_segment17                  =>r3.segment17,
                       p_segment18                  =>r3.segment18,
                       p_segment19                  =>r3.segment19,
                       p_segment20                  =>r3.segment20,
                       p_segment21                  =>r3.segment21,
                       p_segment22                  =>r3.segment22,
                       p_segment23                  =>r3.segment23,
                       p_segment24                  =>r3.segment24,
                       p_segment25                  =>r3.segment25,
                       p_segment26                  =>r3.segment26,
                       p_segment27                  =>r3.segment27,
                       p_segment28                  =>r3.segment28,
                       p_segment29                  =>r3.segment29,
                       p_segment30                  =>r3.segment30,
                       p_concat_segments            =>r3.concatenated_segments
                       );
       end loop;
       --
       end if;
       --
       hr_utility.set_location('hr_assignment.load_assignment_allocation  ',15);
       --
     end loop;
     --
     hr_utility.set_location('hr_assignment.load_assignment_allocation  ',16);
     --
   end if;
   --
   hr_utility.set_location('hr_assignment.load_assignment_allocation  ',17);
   --
END load_assignment_allocation;
-----------------------------------------------------------------------
-- update_assgn_context_value
--
-- populates the per_all_assignments_f.ass_attribute_category value
--
PROCEDURE update_assgn_context_value(
                                 p_business_group_id IN number
                                 ,p_person_id IN number
                                 ,p_assignment_id IN number
                                 ,p_effective_start_date IN date)
IS
 l_context_val varchar2(150);
 l_output_context_val varchar2(240);

 l_ass_attribute_category varchar2(150);

 l_sql varchar2(2000);

 l_effective_start_date date;
 l_proc_name varchar2(100):='update_assgn_context_val :';

 cursor csr_dff_context is
	select nvl(DEFAULT_CONTEXT_FIELD_NAME,'-100')
	from FND_DESCRIPTIVE_FLEXS_VL
	where DESCRIPTIVE_FLEXFIELD_NAME='PER_ASSIGNMENTS'
	-- fix for the bug 8252045 starts here
	AND CONTEXT_USER_OVERRIDE_FLAG='N'
   	AND CONTEXT_SYNCHRONIZATION_FLAG='N';
	-- fix for the bug 8252045 ends here

 cursor csr_ass_data is
    select ass_attribute_category
    from per_all_assignments_f
    where business_group_id = p_business_group_id
    and person_id = p_person_id
    and assignment_id = p_assignment_id
    and effective_start_date = p_effective_start_date
    and primary_flag = 'Y';

begin

 hr_utility.set_location('Entering: '||l_proc_name,10);

 hr_utility.set_location('Business_group_id: '||p_business_group_id,11);
 hr_utility.set_location('Person_id: '||p_person_id,12);
 hr_utility.set_location('Assignment_id: '||p_assignment_id,13);
 hr_utility.set_location('Effective_start_date: '||p_effective_start_date,14);

  open csr_dff_context ;
  fetch csr_dff_context  into l_context_val;

  if csr_dff_context%found then

    if l_context_val <> '-100' then

     hr_utility.set_location('DFF setting exists',20);

     if instr(upper(l_context_val),'$PROFILES$') <> 0 then
      l_context_val:=replace(upper(l_context_val),'$PROFILES$.PER_');
      l_context_val:=replace(upper(l_context_val),'$PROFILES$.');
     end if;

      open csr_ass_data;
      fetch csr_ass_data into l_ass_attribute_category;

      if csr_ass_data%found then

       hr_utility.set_location('l_ass_att: '||l_ass_attribute_category,15);

        if l_ass_attribute_category is null
         or trim(l_ass_attribute_category) = '' then

        begin

         hr_utility.set_location(l_proc_name||' got value for reference field',30);

         l_effective_start_date:= p_effective_start_date;

         hr_utility.set_location(l_proc_name||' selecting records ',30);

	    l_sql := '
         declare
          g_rec per_assignments_v%rowtype;
         begin
          HR_ASSIGNMENT.get_assgn_dff_value('||p_business_group_id||','||p_person_id||','||p_assignment_id||','||':1,g_rec);
          select g_rec.'||l_context_val||' into :2 from dual;
         end;';

         EXECUTE IMMEDIATE l_sql using
	     in out l_effective_start_date,
	     in out l_output_context_val;

         hr_utility.set_location(l_proc_name||'l_output_context_val: '||l_output_context_val,35);


         if l_output_context_val is not null then

          update per_all_assignments_f
           set ass_attribute_category = l_output_context_val
           where business_group_id = p_business_group_id
           and person_id = p_person_id
           and assignment_id = p_assignment_id
           and effective_start_date = p_effective_start_date;

          hr_utility.set_location('dynamic sql updated '||sql%rowcount||' records',50);

         end if;

         close csr_ass_data;

         exception
          when others then
           close csr_ass_data;
           hr_utility.set_location(sqlerrm,55);
         end;
      end if;

    end if;

    end if;
    close  csr_dff_context;

  end if;

  hr_utility.set_location('Leaving: '||l_proc_name,60);

END update_assgn_context_value;

-- get_assgn_dff_value
--
-- returns the per_assignments_v row according to the passed arguments
--
PROCEDURE get_assgn_dff_value(
                                p_business_group_id IN number
                                 ,p_person_id IN number
                                 ,p_assignment_id IN number
                                 ,p_effective_start_date IN date
                                 , p_asg_rec in out NOCOPY g_asg_type)
Is

  cursor csr_asg IS
      SELECT  PA.ASSIGNMENT_ID                                                                                                                                                                              ,
        '11111111111' as row_id                                                                                                                                                                               ,
        PA.EFFECTIVE_START_DATE                                                                                                                                                                             ,
        DECODE(PA.EFFECTIVE_END_DATE , TO_DATE('4712/12/31', 'YYYY/MM/DD'), to_date(NULL), PA.EFFECTIVE_END_DATE) D_EFFECTIVE_END_DATE                                                                      ,
        PA.EFFECTIVE_END_DATE                                                                                                                                                                               ,
        PA.BUSINESS_GROUP_ID + 0 BUSINESS_GROUP_ID                                                                                                                                                          ,
        PA.GRADE_ID                                                                                                                                                                                         ,
        GDT.NAME GRADE_NAME                                                                                                                                                                                 ,
        PA.POSITION_ID                                                                                                                                                                                      ,
        HR_GENERAL.DECODE_POSITION_LATEST_NAME(PA.POSITION_ID) POSITION_NAME                                                                                                                                ,
        PA.JOB_ID                                                                                                                                                                                           ,
        JBT.NAME JOB_NAME                                                                                                                                                                                   ,
        PA.ASSIGNMENT_STATUS_TYPE_ID                                                                                                                                                                        ,
        NVL(AMDTL.USER_STATUS, STTL.USER_STATUS) USER_STATUS                                                                                                                                                ,
        NVL(AMD.PER_SYSTEM_STATUS, ST.PER_SYSTEM_STATUS) PER_SYSTEM_STATUS                                                                                                                                  ,
        PA.PAYROLL_ID                                                                                                                                                                                       ,
        PAY.PAYROLL_NAME                                                                                                                                                                                    ,
        PA.LOCATION_ID                                                                                                                                                                                      ,
        LOCTL.LOCATION_CODE                                                                                                                                                                                 ,
        PA.SUPERVISOR_ID                                                                                                                                                                                    ,
        SUP.FULL_NAME SUPERVISOR_NAME                                                                                                                                                                       ,
        NVL(SUP.EMPLOYEE_NUMBER, SUP.NPW_NUMBER) SUPERVISOR_EMPLOYEE_NUMBER                                                                                                                                 ,
        PA.SPECIAL_CEILING_STEP_ID                                                                                                                                                                          ,
        PSP.SPINAL_POINT                                                                                                                                                                                    ,
        PSPS.SEQUENCE SPINAL_POINT_STEP_SEQUENCE                                                                                                                                                            ,
        PA.PERSON_ID                                                                                                                                                                                        ,
        PA.ORGANIZATION_ID                                                                                                                                                                                  ,
        OTL.NAME ORGANIZATION_NAME                                                                                                                                                                          ,
        PA.PEOPLE_GROUP_ID                                                                                                                                                                                  ,
        PA.ASSIGNMENT_SEQUENCE                                                                                                                                                                              ,
        PA.PRIMARY_FLAG                                                                                                                                                                                     ,
        PA.ASSIGNMENT_NUMBER                                                                                                                                                                                ,
        PA.CHANGE_REASON                                                                                                                                                                                    ,
        DECODE(PA.ASSIGNMENT_TYPE ,'E', HR_GENERAL.DECODE_LOOKUP('EMP_ASSIGN_REASON', PA.CHANGE_REASON) ,'C', HR_GENERAL.DECODE_LOOKUP('CWK_ASSIGN_REASON', PA.CHANGE_REASON)) CHANGE_REASON_MEANING        ,
        PA.COMMENT_ID                                                                                                                                                                                       ,
        COM.COMMENT_TEXT                                                                                                                                                                                    ,
        PA.DATE_PROBATION_END                                                                                                                                                                               ,
        PA.DATE_PROBATION_END D_DATE_PROBATION_END                                                                                                                                                          ,
        PA.FREQUENCY                                                                                                                                                                                        ,
        HR_GENERAL.DECODE_LOOKUP('FREQUENCY', PA.FREQUENCY) FREQUENCY_MEANING                                                                                                                               ,
        PA.INTERNAL_ADDRESS_LINE                                                                                                                                                                            ,
        PA.MANAGER_FLAG                                                                                                                                                                                     ,
        PA.NORMAL_HOURS                                                                                                                                                                                     ,
        PA.PROBATION_PERIOD                                                                                                                                                                                 ,
        PA.PROBATION_UNIT                                                                                                                                                                                   ,
        HR_GENERAL.DECODE_LOOKUP('QUALIFYING_UNITS', PA.PROBATION_UNIT) PROBATION_UNIT_MEANING                                                                                                              ,
        PA.TIME_NORMAL_FINISH                                                                                                                                                                               ,
        PA.TIME_NORMAL_START                                                                                                                                                                                ,
        PA.BARGAINING_UNIT_CODE                                                                                                                                                                             ,
        HR_GENERAL.DECODE_LOOKUP('BARGAINING_UNIT_CODE', PA.BARGAINING_UNIT_CODE) BARGAINING_UNIT_CODE_MEANING                                                                                              ,
        PA.LABOUR_UNION_MEMBER_FLAG                                                                                                                                                                         ,
        PA.HOURLY_SALARIED_CODE                                                                                                                                                                             ,
        HR_GENERAL.DECODE_LOOKUP('HOURLY_SALARIED_CODE', PA.HOURLY_SALARIED_CODE)                                                                                                                           ,
        PA.LAST_UPDATE_DATE                                                                                                                                                                                 ,
        PA.LAST_UPDATED_BY                                                                                                                                                                                  ,
        PA.LAST_UPDATE_LOGIN                                                                                                                                                                                ,
        PA.CREATED_BY                                                                                                                                                                                       ,
        PA.CREATION_DATE                                                                                                                                                                                    ,
        PA.SAL_REVIEW_PERIOD                                                                                                                                                                                ,
        HR_GENERAL.DECODE_LOOKUP('FREQUENCY', PA.SAL_REVIEW_PERIOD_FREQUENCY) SAL_REV_PERIOD_FREQ_MEANING                                                                                                   ,
        PA.SAL_REVIEW_PERIOD_FREQUENCY                                                                                                                                                                      ,
        PA.PERF_REVIEW_PERIOD                                                                                                                                                                               ,
        HR_GENERAL.DECODE_LOOKUP('FREQUENCY', PA.PERF_REVIEW_PERIOD_FREQUENCY) PERF_REV_PERIOD_FREQ_MEANING                                                                                                 ,
        PA.PERF_REVIEW_PERIOD_FREQUENCY                                                                                                                                                                     ,
        PA.PAY_BASIS_ID                                                                                                                                                                                     ,
        PB.NAME SALARY_BASIS                                                                                                                                                                                ,
        PB.PAY_BASIS PAY_BASIS                                                                                                                                                                              ,
        PA.RECRUITER_ID                                                                                                                                                                                     ,
        PA.PERSON_REFERRED_BY_ID                                                                                                                                                                            ,
        PA.RECRUITMENT_ACTIVITY_ID                                                                                                                                                                          ,
        PA.SOURCE_ORGANIZATION_ID                                                                                                                                                                           ,
        PA.SOFT_CODING_KEYFLEX_ID                                                                                                                                                                           ,
        PA.VACANCY_ID                                                                                                                                                                                       ,
        PA.ASSIGNMENT_TYPE                                                                                                                                                                                  ,
        PA.APPLICATION_ID                                                                                                                                                                                   ,
        PA.DEFAULT_CODE_COMB_ID                                                                                                                                                                             ,
        PA.PERIOD_OF_SERVICE_ID                                                                                                                                                                             ,
        PA.SET_OF_BOOKS_ID                                                                                                                                                                                  ,
        GL.NAME D_SET_OF_BOOKS                                                                                                                                                                              ,
        GL.CHART_OF_ACCOUNTS_ID GL_KEYFLEX_STRUCTURE                                                                                                                                                        ,
        PA.SOURCE_TYPE                                                                                                                                                                                      ,
        PA.REQUEST_ID                                                                                                                                                                                       ,
        PA.PROGRAM_APPLICATION_ID                                                                                                                                                                           ,
        PA.PROGRAM_ID                                                                                                                                                                                       ,
        PA.PROGRAM_UPDATE_DATE                                                                                                                                                                              ,
        PA.ASS_ATTRIBUTE_CATEGORY                                                                                                                                                                           ,
        PA.ASS_ATTRIBUTE1                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE2                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE3                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE4                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE5                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE6                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE7                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE8                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE9                                                                                                                                                                                   ,
        PA.ASS_ATTRIBUTE10                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE11                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE12                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE13                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE14                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE15                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE16                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE17                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE18                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE19                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE20                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE21                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE22                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE23                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE24                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE25                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE26                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE27                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE28                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE29                                                                                                                                                                                  ,
        PA.ASS_ATTRIBUTE30                                                                                                                                                                                  ,
        PA.EMPLOYMENT_CATEGORY                                                                                                                                                                              ,
        DECODE(PA.ASSIGNMENT_TYPE, 'E', HR_GENERAL.DECODE_LOOKUP('EMP_CAT', PA.EMPLOYMENT_CATEGORY) ,'C', HR_GENERAL.DECODE_LOOKUP('CWK_ASG_CATEGORY', PA.EMPLOYMENT_CATEGORY)) EMPLOYMENT_CATEGORY_MEANING ,
        PA.ESTABLISHMENT_ID                                                                                                                                                                                 ,
        PA.COLLECTIVE_AGREEMENT_ID                                                                                                                                                                          ,
        PA.CONTRACT_ID                                                                                                                                                                                      ,
        PA.CAGR_GRADE_DEF_ID                                                                                                                                                                                ,
        PA.CAGR_ID_FLEX_NUM                                                                                                                                                                                 ,
        CA.NAME AGREEMENT_NAME                                                                                                                                                                              ,
        O1.NAME ESTABLISHMENT_NAME                                                                                                                                                                          ,
        CO.REFERENCE REFERENCE                                                                                                                                                                              ,
        PA.NOTICE_PERIOD                                                                                                                                                                                    ,
        PA.NOTICE_PERIOD_UOM                                                                                                                                                                                ,
        HR_GENERAL.DECODE_LOOKUP('QUALIFYING_UNITS', PA.NOTICE_PERIOD_UOM) NOTICE_PERIOD_UOM_MEANING                                                                                                        ,
        PA.EMPLOYEE_CATEGORY                                                                                                                                                                                ,
        HR_GENERAL.DECODE_LOOKUP('EMPLOYEE_CATG', PA. EMPLOYEE_CATEGORY) EMPLOYEE_CATEGORY_MEANING                                                                                                          ,
        PA.WORK_AT_HOME                                                                                                                                                                                     ,
        PA.JOB_POST_SOURCE_NAME                                                                                                                                                                             ,
        PA.TITLE                                                                                                                                                                                            ,
        PA.PROJECT_TITLE                                                                                                                                                                                    ,
        PA.PERIOD_OF_PLACEMENT_DATE_START                                                                                                                                                                   ,
        PA.VENDOR_ID                                                                                                                                                                                        ,
        POV.VENDOR_NAME                                                                                                                                                                                     ,
        PA.VENDOR_SITE_ID                                                                                                                                                                                   ,
        POVS.VENDOR_SITE_CODE                                                                                                                                                                               ,
        PA.PO_HEADER_ID                                                                                                                                                                                     ,
        POH.SEGMENT1 PO_NUMBER                                                                                                                                                                              ,
        PA.PO_LINE_ID                                                                                                                                                                                       ,
        POL.LINE_NUM PO_LINE_NUMBER                                                                                                                                                                         ,
        PA.PROJECTED_ASSIGNMENT_END                                                                                                                                                                         ,
        PA.VENDOR_EMPLOYEE_NUMBER                                                                                                                                                                           ,
        PA.VENDOR_ASSIGNMENT_NUMBER                                                                                                                                                                         ,
        PA.ASSIGNMENT_CATEGORY                                                                                                                                                                              ,
        PA.GRADE_LADDER_PGM_ID                                                                                                                                                                              ,
        PA.SUPERVISOR_ASSIGNMENT_ID                                                                                                                                                                         ,
        PGM.NAME GRADE_LADDER_NAME                                                                                                                                                                          ,
        PA2.ASSIGNMENT_NUMBER SUPERVISOR_ASSIGNMENT_NUMBER
FROM    PER_ALL_ASSIGNMENTS_F PA            ,
        PER_ALL_ASSIGNMENTS_F PA2           ,
        PER_GRADES PG                       ,
        PER_JOBS J                          ,
        PER_GRADES_TL GDT                   ,
        PER_JOBS_TL JBT                     ,
        PER_ASSIGNMENT_STATUS_TYPES ST      ,
        PER_ASSIGNMENT_STATUS_TYPES_TL STTL ,
        PER_ASS_STATUS_TYPE_AMENDS AMD      ,
        PER_ASS_STATUS_TYPE_AMENDS_TL AMDTL ,
        PAY_ALL_PAYROLLS_F PAY              ,
        HR_LOCATIONS_ALL_TL LOCTL           ,
        HR_LOCATIONS_NO_JOIN LOC            ,
        PER_ALL_PEOPLE_F SUP                ,
        PER_SPINAL_POINT_STEPS_F PSPS       ,
        PER_SPINAL_POINTS PSP               ,
        HR_ALL_ORGANIZATION_UNITS O         ,
        HR_ALL_ORGANIZATION_UNITS_TL OTL    ,
        HR_COMMENTS COM                     ,
        GL_SETS_OF_BOOKS GL                 ,
        PER_PAY_BASES PB                    ,
        FND_SESSIONS FND                    ,
        PER_COLLECTIVE_AGREEMENTS CA        ,
        PER_CONTRACTS_F CO                  ,
        HR_ALL_ORGANIZATION_UNITS O1        ,
        BEN_PGM_F PGM                       ,
        PO_VENDORS POV                      ,
        PO_VENDOR_SITES_ALL POVS            ,
        PO_HEADERS_ALL POH                  ,
        PO_LINES_ALL POL
WHERE   PA.ASSIGNMENT_TYPE          IN ( 'E','C')
    AND PA.ORGANIZATION_ID           = O.ORGANIZATION_ID
    AND PA.GRADE_ID                  = PG.GRADE_ID (+)
    AND PA.GRADE_ID                  =GDT.GRADE_ID (+)
    AND GDT.LANGUAGE(+)              = userenv('LANG')
    AND PA.JOB_ID                    = JBT.JOB_ID (+)
    AND JBT.LANGUAGE(+)              = userenv('LANG')
    AND PA.JOB_ID                    = J.JOB_ID (+)
    AND PA.ASSIGNMENT_STATUS_TYPE_ID = ST.ASSIGNMENT_STATUS_TYPE_ID
    AND PA.ASSIGNMENT_STATUS_TYPE_ID = AMD.ASSIGNMENT_STATUS_TYPE_ID (+)
    AND PA.BUSINESS_GROUP_ID + 0     = AMD.BUSINESS_GROUP_ID (+) + 0
    AND PA.PAYROLL_ID                = PAY.PAYROLL_ID (+)
    AND PA.LOCATION_ID               = LOC.LOCATION_ID (+)
    AND PA.SUPERVISOR_ID             = SUP.PERSON_ID (+)
    AND PA.SPECIAL_CEILING_STEP_ID   = PSPS.STEP_ID (+)
    AND PSPS.SPINAL_POINT_ID         = PSP.SPINAL_POINT_ID (+)
    AND PA.SET_OF_BOOKS_ID           = GL.SET_OF_BOOKS_ID (+)
    AND PA.COMMENT_ID                = COM.COMMENT_ID (+)
    AND PA.PAY_BASIS_ID              = PB.PAY_BASIS_ID (+)
    AND (
		( PA2.EFFECTIVE_START_DATE IS NULL
		  AND PA2.EFFECTIVE_END_DATE      IS NULL
		)
     OR (PA2.EFFECTIVE_START_DATE IS NOT NULL
		AND PA2.EFFECTIVE_END_DATE    IS NOT NULL
	    AND PA2.EFFECTIVE_END_DATE =
        (SELECT MAX(PA3.EFFECTIVE_END_DATE)
        FROM    PER_ALL_ASSIGNMENTS_F PA3
        WHERE   PA3.ASSIGNMENT_ID = PA.SUPERVISOR_ASSIGNMENT_ID
        )
        )
	   )
    AND O.organization_id                                              = OTL.organization_id
    AND OTL.language                                                   = userenv('LANG')
    AND ST.assignment_status_type_id                                   = STTL.assignment_status_type_id
    AND STTL.language                                                  = userenv('LANG')
    AND AMD.ass_status_type_amend_id                                   = AMDTL.ass_status_type_amend_id (+)
    AND DECODE(amdtl.ass_status_type_amend_id,NULL,'1',AMDTL.language) = DECODE(amdtl.ass_status_type_amend_id,NULL,'1',userenv('LANG'))
    AND LOC.location_id                                                = LOCTL.location_id (+)
    AND DECODE(LOCTL.location_id,NULL,'1',loctl.language)              = DECODE(LOCTL.location_id,NULL,'1',userenv('LANG'))
    AND PA.ESTABLISHMENT_ID                                            = O1.ORGANIZATION_ID (+)
    AND CA.COLLECTIVE_AGREEMENT_ID (+)                                 = PA.COLLECTIVE_AGREEMENT_ID
    AND CO.CONTRACT_ID (+)                                             = PA.CONTRACT_ID
    AND PA.GRADE_LADDER_PGM_ID                                         = PGM.PGM_ID (+)
    AND PA.VENDOR_ID                                                   = POV.VENDOR_ID (+)
    AND PA.VENDOR_SITE_ID                                              = POVS.VENDOR_SITE_ID (+)
    AND PA.PO_HEADER_ID                                                = POH.PO_HEADER_ID (+)
    AND PA.PO_LINE_ID                                                  = POL.PO_LINE_ID (+)
    AND PA2.ASSIGNMENT_ID(+) = PA.SUPERVISOR_ASSIGNMENT_ID
    AND PA.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
    AND PA.PERSON_ID = P_PERSON_ID
    AND PA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
    AND PA.EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE;


    l_proc_name varchar2(20):= 'get_assgn_dff_value';
begin

 hr_utility.set_location('Entering: '||l_proc_name,10);

 OPEN csr_asg;
 FETCH csr_asg INTO p_asg_rec;
 if csr_asg%found then
     close csr_asg;
 end if;
  hr_utility.set_location('Leaving: '||l_proc_name,10);
END get_assgn_dff_value;

--end for bug 6598795
---------------------------------------------------------------------------------------
end hr_assignment;

/

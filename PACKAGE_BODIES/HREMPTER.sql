--------------------------------------------------------
--  DDL for Package Body HREMPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HREMPTER" AS
/* $Header: peempter.pkb 120.18.12010000.5 2009/12/08 12:56:44 sidsaxen ship $ */
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
 Name        : hrempter  (BODY)

 Description : This package declares procedures required to
               terminate and cancel the termination of an employee.


 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    11-FEB-93 SZWILLIA             Date Created
 70.1    18-FEB-93 SZWILLIA             Corrected deletes from
                                        PER_BOOKINGS and PER_EVENTS.
                                        Also, added future actions
                                        check to cancellations.
                                        Added messages
 70.2     11-MAR-93 NKHAN               Added 'exit' to end
 70.3    26-MAR-93 SZWILLIA             Addition of maintain_entries_asg
                                        to cancel_termination.
 70.4    04-MAY-93 SZWILLIA             Check on employee_shutdown
                                        modified to deal with FPD on
                                        the same date as ATD - AFTER
                                        termination.
 80.1    15-OCT-93 JRHODES              Added check_cobra_benefits
 80.2    29-OCT-93 JHOBBS      B258     Corrected cursor rec_entries in
                                        terminate_entries_and_alus so that it
                                        only selects recurring entries.
 80.3    03-NOV-93 JHOBBS               Altered terminate_entries_and_alus so
                                        that nonrecurring entries are shortened
                                        if they exist past the final process
                                        date. Pay proposals are also now
                                        removed if there are no entries for it.
 80.4    01-JUN-94 JHOBBS      G847     Corrected check_for_future_actions so
                                        that it can only return one row if
                                        future actions exist. The new SQL
                                        should be more efficient.
                               #218334  Added check_for_future_person_type
                                        which is used to validate the
                                        cancellation of a termination. It
                                        checks to see if there are future
                                        person types which are not EX_EMP. If
                                        the cancellation was allowed to take
                                        place overlapping periods of service
                                        etc ... would be created.
 70.13   16-JUN-94 PSHERGILL            fix 220466 added ATTRIBUTE21..30 and
                                        ASS_ATTRIBUTE21..30
 70.15   14-JUL-94 SZWILLIA    #225892  Problem which came to light on 7.1.3,
                                        related to PL/SQL bug number 225900.
                                        Explicit OPEN of cursor prior to
                                        cursor for loop causes oracle error
                                        when terminating from PERPETEM. However
                                        PERPETEM, although trapping the oracle
                                        error was not failing.
 70.16   23-NOV-94 RFINE       G1725    Suppressed index on business_group_id
 70.17   20-APR-95 TMathers   265290,269193,271941 Fixed these WWBUGS
                                        Added code to check for Future
                                        Person rows and insert/deletes to
                                        per_person_list_changes. Also added
                                        flag to allow only some of Term
                                        details to be deleted.
 70.18   25-APR-95 TMathers   276096    Added legislation code to terminate_alus
                                        and terminate employee so that
                                        If legislation is 'US' and Last_standard
                                        process is null the package will
                                        not fall over.
 70.19   12-MAY-95 TMathers   281104    added rest of fields save notified
                                        and projected to clear_details update.
 70.20   03-JUL-95 RFine      288341    Fixed error in check put in revision
                                        70.18. The lack of an NVL meant that
                                        leg_code <> 'US' was failing when it
                                        was null. Removed the check in
                                        question, as it is now unnecessary.
 70.21   07-JUL-95 RFine      289454    Allow cancel termination to succeed if
                                        future person type changes are to
                                        EX_EMP_APL as well as to EX_EMP,
                                        providing both types don't exist for
                                        the same person. This allows
                                        terminations to be cancelled for
                                        Employee-Applicants.
 70.22   24-JUL-95 TMathers   294069    Update LAST_UPDATE_DATE on
                                        pay_element_entries_f with
                                        sysdate.
 70.23   26-JUL-95 RFine      291763    Added missing column PAY_BASIS_ID to
                                        the SQL statement which inserts the new
                                        term_assign row in per_assignments_f.
                                        It was missing, with the effective
                                        result that terminating the person also
                                        cleared the assignments' pay basis.
 70.24   29-AUG-95 RFine      270356    Get the default TERM_ASSIGN status
                                        immediately before inserting a
                                        TERM_ASSIGN assignment record, if one
                                        hasn't already been passed in.
 70.25   19-Sep-95 TMathers   307957    Added and Assignment_type = 'E'
                                        to update cursor of assignments.
 70.27   31-Oct-95 TMathers   314277    Changed updates and checks for
                                        delete_entries to use the p_term_date
                                        a la termination rule instead of
                                        p_final_process_date.
 70.28   23-Jan-96 MSwanson   317302    Add 'not exists' to insert on
                                        per_person_list_changes and update
                                        where record does exist.
 70.29   08-Mar-96 VTreiger   314277    Changed the logic of closing down
                                        the non-recurring element
                                        entries when the final process
                                        date is entered before the end of
                                        the payroll period.
                               334654   Setting the employee assignment
                               334681   status to TERM_ASSIGN is not allowed
                                        if there are certain types of future
                                        non-recurring element entries which
                                        have not been processed in a payroll
                                        run.
                               311763   Delete of future spinal point
                                        placements.
 70.30   13-Mar-1996 VTreiger           Restored code in terminate employee
                                        procedure to state from 70.28
 70.31   18-Mar-1996 Vtreiger           Fixed a bug in post_update for
                                        terminate_employee procedure.
 70.32   15-Apr-1996 VTreiger  354874   Included employment category in the
                                        explicit insert for per_assignments_f.
 70.33   15-May-1996 VTreiger  364214   Included additional criteria for
                                        function check_for_future_actions
 70.34   22-May-1996 VTreiger  364214   Restored back to version 70.32.
 70.35   04-Jun-1996 VTreiger  364214   Added function check_for_compl_actions.
                                        This function returns :
                                        Y - if there are any assignment
                                        actions after the Final Process Date.
                                        W - if there exists any completed assignment
                                        action after Actual Termination Date but
                                        before Final Process Date.
                                        N - in all other cases.
                                        New function call is used in procedures :
                                        terminate_employee,employee_shutdown,
                                        cancel_termination.
 70.36   28-Jun-1996 VTreiger  375157   Commented out nocopy removal of pay proposals
                                        when non-recurring entries are processed
                                        while employee termination.
 70.37   11-Oct-1996 VTreiger  441206   Suffix value is saved at termination.
 70.38   17-Oct-1996 VTreiger  306710   Changed procedure terminate_entries_and
                                        alus to return the value of entries
                                        changed warning as 'N' or 'Y' or 'S'.
                               398699   Commented out nocopy contents of procedure
                                        check_cobra_benefits to return false
                                        always.
 70.39   01-Nov-1996 VTreiger  306710   Added procedure terminate_entries_
                                        and_alus overload.
 70.40   03-APR-1998 DShannon  519738    Added calls to delete_covered_dependents and
                                        delete_beneficiaries when entry is terminated
                                        - for both recurring and non-recurring entries
 110.3   30-APR-1998 SASmith            Changes made due to date tracking of assignment_budget_
                                        values_f.
                                        Addition of processing in :
                                        1. delete_assign_fpd - include deletion/update of
                                        assignment_budget_values_f
                                        2. cancel_termination - inclusing of update to assignment_budget
                                        values_f when the termination is cancelled.
 115.1   16-OCT-1998 CCarter            New parameters added to insert into per_people_f
                                        in the  terminate employee procedure for OAB.
 115.5   19-Jul-1999 mmillmor 895018    removed some bad code and altered to use
                                        internal security procedures in terminate
 115.6   27-Sep-1999 alogue             Changed insert into per_People to per_all_people_f
                                        inside terminate_employee.
 115.8   27-OCT-1999 rmonge             Added code fixes for bug 920233 and 969491
                                        Bug fix 920233  resolves the problem
                                        with tax records not reversed when reverse
                                        termination process is done on a terminated
                                        employee, and bug 969491
                                        fixes tax records not end dated when the
                                        employee is terminated.
 115.9   06-MAR-2000  Rvydyana          Leapfroged version created for v115.6
                                        with backported changes for 1176101
 115.10  06-MAR-2000  Rvydyana          Leapfroged version of v115.8 with code fix
                                        for 1176101 ie. Added call to
                                        ben_dt_trg_handle in cancel termination.
115.11   16-NOV-1999 I Harding 1076054  Added extra attributes to insert into
                                        PER_ASSIGNMENTS_F during the post update
                                        work following a termination of an
                                        employee. Requested by John Rhodes
                                        following French Phase 1.
115.12   13-MAR-2000 CSimpson           Added town_of_birth, region_of_birth,
                                        country_of_birth and global_person_id attribs
                                        into per_all_people_f insert in terminate_employee.
115.13   26-Jul-2000 mmillmor 996015    Added code to delete pay proposals at the same
                                        time as element entries
115.14   17-Aug-2000 VTreiger 1363723   Commented out nocopy copying of ATTRIBUTEx columns
                                        from EMP record to EX_EMP record.
115.15   04-Aug-2000 Dscully  1348553   Fixed end dating of tax records.
115.16   12-Sep-2000 MReid    889806    Excluded Magnetic Reports from check for
                                        future dated completed actions.
115.17   15-SEP-00   GPERRY             Added hook points to benefits code whenerever
                                        per_periods_of_service is inserted or updated.
                                        Fixed WWBUG 1390173
115.18   15-SEP-00   GPERRY             Leapfrog of 115.16 with fix for
                                        WWBUG 1390173.
115.19   06-OCT-00   TMATHERS           11.5.3 incompatibility, 1348553 is patchset B for
                                        payroll, so need to back out nocopy that change to work
                                        woth base 11.5.3.
115.20   06-OCT-00   TMATHERS           Leapfrog of 115.18 including AND requiring fix
                                        for 1348553, new paramater to
                                        pay_us_update_tax_rec_pkg
115.21   19-OCT-00   GPERRY             Fixed WWBUG 1408379.
                                        Added support for life event triggers for OAB.
115.22   23-OCT-00   SBIRNAGE           Added an extra line to two where clauses to fix bug
                                        1406063.
115.23   29-MAR-01   vshukhat           Bug 1711085. Commented out nocopy code that disables
                                        last_standard_process for US legislature.
115.24   09-APR-01                      Reverted back some previous changes.
115.25   09-MAY-01   MGettins           Reverse out nocopy changes for bug 1363723
115.26   10-jul-01   rvydyana           TAR 1660650.999
115.27   06-Jul-01   pbodla             - Bug 1877018 : added final_process_date
                                        before calling ben_pps_ler.ler_chk
                                        to detect potential life events.
                                        - Bug 1854968 : Pass old actual termination
                                        date to ben_dt_trgr_handle.periods_of_service
                                        call.
115.28   02-oct-01  vsjain              Added notice_period, notice_period_uom,
                                        work_at_home,job_post_source_name,
                                        employee_category to terminate employee proc
115.29                                  LEAPFROG VERSION BASED ON 115.27
115.30   05-Oct-01  mbocutt 1570258     Prevent delete of events which are 'I'nterview
                                        as these may be linked to reviews and pay
                                        proposals.
115.31   30-Oct-01  mbocutt 1271513     Change cancel terminate code to correctly
                                        handle future dated assignments on reverse
                                        termination.
115.32   01-Nov-01  mbocutt             Added som emissed variable declarations.
115.33   05-NOV-01  kmullapu            Modified INSERT INTO PER_ALL_PEOPLE_F in
                                        terminate_employee to include
                                        PER_INFORMATION 21 TO 30
115.35   22-AUG-02  adhunter            correct gscc warning. change msg name
                                        HR_6519_CANC_ACTIONS_EXIST
                                        to HR_6519_EMP_CANC_ACTIONS_EXIST
115.38   05-DEC-02   pkakar             added nocopy to parameters
115.39   16-DEC-02   dcasemor 2711532   Added predicate to exclude BEE
                                        payroll actions to:
                                        - check_for_compl_actions
                                        - check_for_future_actions
115.40   10-FEB-02  vramanai 2784295    Removed the code which requires LSPD
                                        to be not null for non-US legislations
115.42   3-Mar-03   mbocutt  2820633    Changes to reverse term code so that the
                                        assignment update made during termination on
                                        ATD is removed if there are no differences
                                        between it and the previous DT instance of
                                        the assignment.  Modified behaviour introduced
                                        in fix for bug 1271513.
115.43   11-Mar-03  mbocutt  2843882    The above fix did not work when ATD=FPD. Adjus
                                        ted fix to handle this case.
115.44   Sept-2003  mbocutt             Ex-person security enhancements.
                                        Remove call to copy_to_person_list_changes and
                                        other direct refs to PER_PERSON_LIST_CHANGES.
                                        This file is now dependent on other
                                        security changes delivered in Nov 2003 FP.
115.45   17-Oct-2003 smparame 3077943   Procedure Cancel_termination modified.
                                        l_final_process_date is set to
                                        p_actual_termination_date + 1 if it is equal
                                        to p_actual_termination_date before resetting
                                        assignment records.
115.46   19-FEB-04  smparame 3446768    Cursor rec_entries in terminate_entries_and_alus
                                        procedure modified to increase performance.
115.47   11-MAR-04  adudekul 3100620.   In proc cancel_termination,
                                        changed warning message HR_6519_EMP_CANC_ACTIONS_EXIST
                                        to PER_449053_EMP_TERM_FUT_ERROR.
115.48   11-MAR-04  adudekul 3100620.   Modified proc check_for_compl_actions.
115.49   02-APR-04  smparame 3077943.   Changes made to the 3077943 are reverted.
115.50   04-Apr-04  bsubrama 1370960.   Added code to revert the roles when
                                        termination is reversed.
115.51   23-Aug-2004 njaladi 3735333.   Modified proc terminate_employee
                                        and delete_assign_atd for better performance.
115.52   16-SEP-2004 adudekul 3889294.  In procedure cancel_termination, added
                                        code to manipulate the PTU records, legislation
                                        specific actions and hr workflow sync code.
115.53   14-SEP-2004 smparame 3983715   Cursor rec_entries in
                                        terminate_entries_and_alus procedure
                                        modified to increase performance.
115.54   16-Jun-2005 ghshanka 4436297   cursor 'future_person_types'
                                        in the funtion 'check_for_future_person_type' is
                                        modified to query from per_person_type_usages_f table.
115.55   27-jun-2005 njaladi            Backed out changes done in 115.54 and this version
                                        is same as 115.53.
115.58   13-Jan-2006 ghshanka 4919804   Modified the procedure cancel_termination to call
                                        the procedure pay_pog_all_assignments_pkg.after_delete
115.58   16-jan-2006 ghshanka 4919804   Modified the call to pay_pog_all_assignments_pkg.after_delete
                                        by passing the end of time value to p_effective_end_date parameter.
115.58   17-Jan-2006 ghshanka 4919804   Modified the procedure cancel_termination to call
                                        the procedure pay_pog_all_assignments_pkg.after_delete when
                                        Finalprocessdate is not null.
115.59   22-Mar-2006 LSilveir 4449472   Overloaded terminate_entries_and_alus and added
                                        new ALU validation into delete_alus.
115.60   04-Apr-2006 ghshanka 4457651   modified the function check_for_future_person_type
                                        by adding a new cursor to check for COMBINATION of
                                        future person types of type 'CWK and EMP'.
115.61   24-Apr-2006 asgugupt 5152164   modified the procedure CANCEL_TERMINATION
115.62   09-May-2006 ghshanka 5152164   modified the procedure CANCEL_TERMINATION
115.63   19-May-2006 ggnanagu           Added the call to adjust_salary_proposals
                                        in per_saladmin_utility to fix bug 5200269
115.65   14-JUN-2006 avarri   4371218   Modified cancel_termination to fix 4371218
115.66   17-JUL-2006 agolechh 4308892   This version of hrempter calls pay_element_entry_api
					instead of performing direct DML statements on
					pay_element_entries_f.
115.67   26-Jul-2006 thabara  5368246   Modified terminate_entries_and_alus and
                                        delete_alus to end date ALUs with final
                                        process date regardless of the
                                        termination rule.
115.68   20-Sep-2006 SNukala  5507290   Modified cancel_termination and added call to
                                        maintain EX-EMP incase of canceling termination
                                        Leaving reason 'Retirement' type ex-employee.
115.69  10-AUG-2007 pchowdav  6313195   Reverted back the changes done for
                                        bug 4371218.
115.71  07-FEB-2008 ckesanap  6801103   Modified cursor rec_entries in delete_entries(). Also
                                        added a condition - to call pay_element_entry_api in
					DELETE mode only if p_term_date is not equal to
					max_effective_end_date for the record.
115.72  16-MAR-2009 sgundoju  8214333   added the Logical NOT condition to fix the bug
                                        in cancel_termination procedure
115.73 08-Apr-2009  ghshanka  8214333   Moved the cancel_termination procedure .
115.74 28-Aug-2009  sidsaxen  8841176   Modified cursor c_assignment in hrempter.cancel_termination(),
                                        so when final_process_date and actual_termination_date
                                        are unequal then system should picks only those assignment
                                        which has "Terminated Assignment" in future.
115.75 08-Dec-2009  sidsaxen  8841176   Modified cursor c_assignment in hrempter.cancel_termination()
================================================================= */
g_package  varchar2(33)    := '  hrempter.';  -- Global package name

--
-- ====================== delete_assign_atd =========================
--
  PROCEDURE delete_assign_atd(p_assignment_id           NUMBER
                             ,p_actual_termination_date DATE)
  IS
  --
  l_proc varchar2(72):=g_package||'delete_assign_atd';
  begin
  hr_utility.trace('Entered delete_assign_atd for assign '||p_assignment_id);
  --
  hr_utility.set_location(l_proc,1);
  --  Remove booking and event where the event is for the assignment
  --
  --
  -- 3735333 Modified the query of per_bookings for better performance.
  --
  --
  DELETE per_bookings  pb
  WHERE event_id in ( SELECT event_id
                FROM   per_events  pev
                WHERE  pev.assignment_id = p_assignment_id
                AND    pev.date_start    > p_actual_termination_date
                );
  --
  hr_utility.set_location(l_proc,2);
  DELETE per_events pev
  WHERE  pev.assignment_id = p_assignment_id
  AND    pev.date_start > p_actual_termination_date
  AND    pev.event_or_interview = 'E';
  --
  hr_utility.set_location(l_proc,3);
  DELETE per_letter_request_lines lrl
  WHERE  lrl.assignment_id = p_assignment_id
  AND    lrl.date_from > p_actual_termination_date;
  --
  end delete_assign_atd;
--
--
-- ====================== delete_assign_fpd =========================
--
  PROCEDURE delete_assign_fpd(p_assignment_id           NUMBER
                             ,p_final_process_date   DATE)
  IS
  --
  l_proc varchar2(72):=g_package||'delete_assign_fpd';
  --
  -- Start of Fix for WWBUG 1408379
  --
  l_old ben_abv_ler.g_abv_ler_rec;
  l_new ben_abv_ler.g_abv_ler_rec;
  --
  cursor c1 is
    select *
    from   per_assignment_budget_values_f abv
    where  abv.assignment_id = p_assignment_id
    and    p_final_process_date
           between  abv.effective_start_date
           and      abv.effective_end_date;
  --
  l_c1 c1%rowtype;
  --
  -- End of Fix for WWBUG 1408379
  --
  begin
  hr_utility.trace('Entered delete_assign_fpf for assign '||p_assignment_id);
  --
  hr_utility.set_location(l_proc,1);
  UPDATE per_secondary_ass_statuses sas
  SET    sas.end_date      = p_final_process_date
  WHERE  sas.assignment_id = p_assignment_id
  AND    sas.end_date IS NULL;
  --
  hr_utility.set_location(l_proc,5);
  DELETE per_secondary_ass_statuses sas
  WHERE  sas.assignment_id = p_assignment_id
  AND    sas.start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc,10);
  UPDATE pay_personal_payment_methods_f  ppm
  SET    ppm.effective_end_date = p_final_process_date
  WHERE  ppm.assignment_id      = p_assignment_id
  AND    p_final_process_date
         BETWEEN ppm.effective_start_date
         AND     ppm.effective_end_date;
  --
  hr_utility.set_location(l_proc,15);
  DELETE pay_personal_payment_methods_f  ppm
  WHERE  ppm.assignment_id = p_assignment_id
  AND    ppm.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc,20);
  UPDATE pay_cost_allocations_f pca
  SET    pca.effective_end_date = p_final_process_date
  WHERE  pca.assignment_id      = p_assignment_id
  AND    p_final_process_date
         BETWEEN  pca.effective_start_date
         AND      pca.effective_end_date;
  --
  hr_utility.set_location(l_proc,25);
  DELETE pay_cost_allocations_f pca
  WHERE  pca.assignment_id = p_assignment_id
  AND    pca.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc,30);
  UPDATE per_spinal_point_placements_f  spp
  SET    spp.effective_end_date = p_final_process_date
  WHERE  spp.assignment_id      = p_assignment_id
  AND    p_final_process_date
         BETWEEN  spp.effective_start_date
         AND      spp.effective_end_date;
  --
  -- VT 03/06/96 bug #311763
  hr_utility.set_location(l_proc,35);
  DELETE per_spinal_point_placements_f spp
  WHERE spp.assignment_id = p_assignment_id
  AND spp.effective_start_date > p_final_process_date;
  --

  -- Due to date tracking of assignment_budget_values.
  -- SASmith 30-APR-1998

  hr_utility.set_location(l_proc,40);
  DELETE per_assignment_budget_values_f  abv
  WHERE  abv.assignment_id = p_assignment_id
  AND    abv.effective_start_date > p_final_process_date;
  --
  hr_utility.set_location(l_proc,45);
  --
  -- Start of FIX for WWBUG 1408379
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_c1;
      exit when c1%notfound;
      --
      l_old.assignment_id := l_c1.assignment_id;
      l_old.business_group_id := l_c1.business_group_id;
      l_old.value := l_c1.value;
      l_old.assignment_budget_value_id := l_c1.assignment_budget_value_id;
      l_old.effective_start_date := l_c1.effective_start_date;
      l_old.effective_end_date := l_c1.effective_end_date;
      l_new.assignment_id := l_c1.assignment_id;
      l_new.business_group_id := l_c1.business_group_id;
      l_new.value := l_c1.value;
      l_new.assignment_budget_value_id := l_c1.assignment_budget_value_id;
      l_new.effective_start_date := l_c1.effective_start_date;
      l_new.effective_end_date := p_final_process_date;
      --
      update per_assignment_budget_values_f  abv
      set    abv.effective_end_date = p_final_process_date
      where  abv.assignment_budget_value_id = l_c1.assignment_budget_value_id
      and    abv.effective_start_date = l_c1.effective_start_date
      and    abv.effective_end_date = l_c1.effective_end_date;
      --
      ben_abv_ler.ler_chk(p_old            => l_old,
                          p_new            => l_new,
                          p_effective_date => l_c1.effective_start_date);
      --
    end loop;
    --
  close c1;
  --
  -- End of FIX for WWBUG 1408379
  --
  end delete_assign_fpd;
--
--
-- ====================== delete_employee_atd ==========================
--
--
  PROCEDURE delete_employee_atd(p_person_id               NUMBER
                               ,p_actual_termination_date DATE)
  IS
  --
  l_proc varchar2(72):=g_package||'delete_employee_atd';
  begin
  hr_utility.trace('Entered delete_employee_atd for person '||p_person_id);
  --
  hr_utility.set_location(l_proc,1);
  DELETE per_absence_attendances  paa
  WHERE  paa.person_id         = p_person_id
  AND    paa.date_start        > p_actual_termination_date;
  --
  hr_utility.set_location(l_proc,5);
  --  Remove bookings on employee events
  DELETE per_bookings pb
  WHERE  pb.person_id  = p_person_id
  AND EXISTS (SELECT ''
              FROM   per_events  pev
              WHERE  pev.date_start         > p_actual_termination_date
              AND    pev.emp_or_apl         = 'E'
              AND    pev.event_or_interview = 'E'
              AND    pb.event_id            = pev.event_id);
  --
  hr_utility.set_location(l_proc,7);
  --  Remove bookings as an interviewer for either employee or applicant
  --   interviews
  DELETE per_bookings pb
  WHERE  pb.person_id = p_person_id
  AND EXISTS (SELECT ''
              FROM   per_events pev
              WHERE  pev.event_id           = pb.event_id
              AND    pev.date_start         > p_actual_termination_date
              AND    pev.event_or_interview = 'I'
              AND    pev.assignment_id IS NOT NULL
              AND    pev.assignment_id NOT IN (SELECT assignment_id
                                               FROM   per_assignments_f
                                               WHERE  person_id = p_person_id
                                              )
             );
  --
  hr_utility.set_location(l_proc,10);
  DELETE per_letter_request_lines lrl
  WHERE  lrl.person_id = p_person_id
  AND    lrl.date_from > p_actual_termination_date;
  --
  end delete_employee_atd;
--
--
-- ====================== delete_de_assign ==========================
--
--
  PROCEDURE delete_de_assign(p_assignment_id    NUMBER
                            ,p_delete_date      DATE )

  IS
  --
  l_proc varchar2(72):=g_package||'delete_de_assign';
  --
  begin
  hr_utility.trace('Entered delete_de_assign for '||p_assignment_id);
  --
  hr_utility.set_location(l_proc,1);
  DELETE per_assignments_f ass
  WHERE  ass.assignment_id = p_assignment_id
  AND    ass.effective_start_date > p_delete_date;
  --
  end delete_de_assign;
--
--
-- ======================= get_max_end_date =========================
--
--
  FUNCTION get_max_end_date(p_assignment_id  NUMBER) return DATE
  IS
  --
  l_max_end_date  DATE;
  --
  l_proc varchar2(72):=g_package||'get_max_end_date';
  begin
  hr_utility.trace('Entered get_max_end_date for '||p_assignment_id);
  --
  hr_utility.set_location(l_proc,1);
  SELECT  max(ass.effective_end_date)
  INTO    l_max_end_date
  FROM    per_assignments_f  ass
  WHERE   ass.assignment_id = p_assignment_id;
  --
  return l_max_end_date;
  --
  end get_max_end_date;
--
--
-- ====================== check_for_future_actions ===================
--
--
  FUNCTION check_for_future_actions(p_person_id   NUMBER
                                   ,p_action_date DATE) RETURN VARCHAR2
  IS
  --
  l_action_chk VARCHAR2(1) := 'N';
  --
  l_proc varchar2(72):=g_package||'check_for_future_actions';
  begin
  hr_utility.trace('Entered check_for_future_actions for '||p_person_id);
  --
  hr_utility.set_location(l_proc,1);
  -- VT 05/15/96 added criteria for action_status and action_type
  --        AND  pac.action_status = 'C'
  --        AND  pac.action_type IN ('R','Q')
  -- VT 05/22/96 restored back to version 70.32
    SELECT 'Y'
    INTO   l_action_chk
    FROM   sys.dual
    WHERE  exists
         (SELECT null
          FROM   pay_payroll_actions pac,
                 pay_assignment_actions act,
                 per_assignments_f asg
          WHERE  asg.person_id = p_person_id
          AND    act.assignment_id = asg.assignment_id
          AND    pac.payroll_action_id = act.payroll_action_id
          AND    pac.action_type <> 'BEE'
          AND    pac.effective_date > p_action_date);
    --
    hr_utility.set_location(l_proc,5);
    return l_action_chk;
  --
  exception when NO_DATA_FOUND then null;
  return 'N';
  --
  end check_for_future_actions;
--
--
-- ====================== check_for_compl_actions ===================
--
-- VT 06/04/96 #364214 added new function to check for future
-- completed actions
  FUNCTION check_for_compl_actions(p_person_id   NUMBER
                                   ,p_act_date DATE
                                   ,p_lsp_date DATE
                                   ,p_fpr_date DATE) RETURN VARCHAR2
  IS
  --
  l_action_chk VARCHAR2(1) := 'N';
  l_action_date DATE;
  --
  l_proc varchar2(72):=g_package||'check_for_compl_actions';
  begin
  hr_utility.trace('Entered check_for_compl_actions for '||p_person_id);
  --
  IF p_lsp_date IS NOT NULL THEN
    --
    -- For bug 3100620. Added = in the following check.
    --
    IF p_act_date IS NOT NULL AND p_lsp_date >= p_act_date THEN
      l_action_date := p_lsp_date;
    ELSE
      l_action_date := NULL;
    END IF;
  ELSE
    l_action_date := p_act_date;
  END IF;
  hr_utility.set_location(l_proc,1);
    BEGIN
    SELECT 'Y'
      INTO   l_action_chk
      FROM   sys.dual
      WHERE  exists
           (SELECT null
            FROM   pay_payroll_actions pac,
                   pay_assignment_actions act,
                   per_assignments_f asg
            WHERE  asg.person_id = p_person_id
            AND  act.assignment_id = asg.assignment_id
            AND  pac.payroll_action_id = act.payroll_action_id
            AND  pac.action_type NOT IN ('X','BEE') -- Bug 889806, 2711532
            AND  pac.effective_date > p_fpr_date);
    exception when NO_DATA_FOUND then null;
    END;
    --
    hr_utility.set_location(l_proc,5);
    IF l_action_chk = 'N' THEN
        BEGIN
      SELECT 'W'
      INTO   l_action_chk
      FROM   sys.dual
      WHERE  exists
         (SELECT null
          FROM   pay_payroll_actions pac,
                 pay_assignment_actions act,
                 per_assignments_f asg
          WHERE  asg.person_id = p_person_id
          AND    act.assignment_id = asg.assignment_id
          AND    pac.payroll_action_id = act.payroll_action_id
          AND    pac.action_status = 'C'
          AND    pac.action_type <> 'BEE'
          AND    (pac.effective_date BETWEEN l_action_date AND p_fpr_date));
        --
        hr_utility.set_location(l_proc,7);
        exception when NO_DATA_FOUND then null;
        END;
    END IF;
    return l_action_chk;
  --
  end check_for_compl_actions;
--
-- ====================== check_for_future_person_records ===================
--
--
  FUNCTION check_for_future_person_rows(p_person_id   NUMBER
                                       ,p_action_date DATE) RETURN VARCHAR2
  IS
  --
  l_action_chk VARCHAR2(1) := 'N';
  --
  l_proc varchar2(72):=g_package||'check_for_future_person_rows';
  begin
  --
  hr_utility.set_location(l_proc,5);
  --
    SELECT 'Y'
    INTO   l_action_chk
    FROM   sys.dual
    WHERE  exists
       (select '1'
      from per_people_f ppf
    where ppf.person_id = p_person_id
    and  p_action_date < ppf.effective_start_date);
  --
  hr_utility.set_location(l_proc,10);
  --
  return l_action_chk;
  --
  exception when NO_DATA_FOUND then null;
  --
  return 'N';
  --
  end check_for_future_person_rows;
--
--
-- ====================== check_for_future_person_type ===================
--
--
  FUNCTION check_for_future_person_type(p_person_id   NUMBER
                                       ,p_action_date DATE) RETURN VARCHAR2
  IS
  --
  CURSOR  future_person_types IS
  SELECT  ppt.system_person_type
  FROM    per_people_f ppf,
      per_person_types ppt
  WHERE   ppf.person_type_id = ppt.person_type_id
  AND      ppf.person_id = p_person_id
  AND     ppf.business_group_id + 0 = ppt.business_group_id + 0
  AND      p_action_date < ppf.effective_start_date;
  --
  --bug 4457651
  --
  L_TYPE VARCHAR2(100);
  l_bus_id per_all_people_f.business_group_id %type;

  CURSOR  fptypes_for_cwk1   IS
   SELECT  ppt.system_person_type
   FROM
     per_person_types ppt ,
     per_person_type_usages_f pptf
   WHERE
             pptf.person_id = p_person_id
    AND     p_action_date < pptf.effective_start_date
    AND      pptf.person_type_id = ppt.person_type_id
    and    ppt.business_group_id=l_bus_id
    and    ppt.system_person_type like 'CWK';

    cursor bus_grp_id is
   select business_group_id
    from per_people_f ppf
    where person_id=p_person_id
    and p_action_date < ppf.effective_start_date;
  --
  -- bug 4457651

  fpt_rec    future_person_types%ROWTYPE;
   fpt_rec1    fptypes_for_cwk1%ROWTYPE;
  l_action_chk    VARCHAR2(1) := 'N';
  l_ex_emp    VARCHAR2(1) := 'N';
  l_ex_emp_apl    VARCHAR2(1) := 'N';
  --
  l_proc varchar2(72):=g_package||'check_for_future_person_type';
  begin
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- #289454 Allow cancel termination to succeed if future person type changes
    -- are to EX_EMP_APL as well as to EX_EMP, providing both types don't exist
    -- for the same person. This allows terminations to be cancelled for
    -- Employee-Applicants.
    --
    FOR fpt_rec IN future_person_types LOOP
      --
      hr_utility.set_location(l_proc, 20);
      --
      IF fpt_rec.system_person_type = 'EX_EMP' THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
    l_ex_emp := 'Y';
      ELSIF fpt_rec.system_person_type = 'EX_EMP_APL' THEN
    --
    hr_utility.set_location(l_proc, 40);
    --
    l_ex_emp_apl := 'Y';
      ELSE
    --
    -- Found a person type which will prohibit the cancel termination.
    -- Can bale out now.
    --
    hr_utility.set_location(l_proc, 50);
    --
    l_action_chk := 'Y';
    exit;
      END IF;
      --
      -- Now check if we've found both types: that's an error too.
      --
      IF l_ex_emp = 'Y' AND l_ex_emp_apl = 'Y' THEN
    --
    hr_utility.set_location(l_proc, 60);
    --
    l_action_chk := 'Y';
    exit;
      END IF;
    END LOOP;
    --
    -- bug 4457651
    --
    open bus_grp_id ;
   fetch bus_grp_id into l_bus_id ;
   close bus_grp_id ;

    hr_utility.set_location('thisis the bus id   '||l_bus_id,100);
    hr_utility.set_location('this is the action date  '||p_action_date,110);
    hr_utility.set_location('this is personid value '||p_person_id,115);

  open fptypes_for_cwk1;
    loop
        fetch fptypes_for_cwk1 into l_type;
        exit when fptypes_for_cwk1%notfound;
        hr_utility.set_location('this isthe value of'||L_TYPE, 140);

        if (l_type = 'CWK' and l_ex_emp='Y')
            THEN
                l_action_chk := 'Y';
        END IF;
     end loop;
 close fptypes_for_cwk1;
 --
 -- bug 4457651
    --
    hr_utility.set_location(l_proc, 70);
    --
    return l_action_chk;
    --
  end check_for_future_person_type;
--
-- ====================== check_cobra_benefits =========================
--
-- If the FPD has been entered a check is required to ensure that any
-- COBRA Coverage Benefits do exist after the proposed Final Process Date.
--
  FUNCTION check_cobra_benefits(p_person_id               NUMBER
                               ,p_final_process_date DATE) RETURN BOOLEAN
  IS
  --
  l_cobra_benefits_exist VARCHAR2(1) := 'N';
  --
  l_proc varchar2(72):=g_package||'check_cobra_benefits';
  begin
     hr_utility.set_location(l_proc,10);
     -- VT 10/18/96 bug #398699 commented out
--     begin
--     select 'Y'
--     into   l_cobra_benefits_exist
--     from   sys.dual
--     where exists
--       (select null
--        from   per_assignments_f a
--    ,      per_cobra_cov_enrollments e
--    ,      per_cobra_coverage_benefits_f b
--    where  a.person_id = p_person_id
--    and    p_final_process_date between
--           a.effective_start_date and a.effective_end_date
--    and    e.assignment_id = a.assignment_id
--    and    e.cobra_coverage_enrollment_id
--             = b.cobra_coverage_enrollment_id
--    and    b.effective_end_date > p_final_process_date);
--     exception
--    when no_data_found then null;
--     end;
  --
     return (l_cobra_benefits_exist = 'Y');
  end check_cobra_benefits;
--
--
-- =================== terminate_entries_and_alus overload ============
-- VT 11/01/96 #306710 procedure overload
  PROCEDURE terminate_entries_and_alus(p_assignment_id      NUMBER,
                                       p_actual_term_date   DATE,
                                       p_last_standard_date DATE,
                                       p_final_process_date DATE,
                                     p_legislation_code   VARCHAR2 DEFAULT
                                     NULL)
  IS
  --
  l_entries_changed_ov VARCHAR2(1) := 'N';
  BEGIN
      terminate_entries_and_alus(p_assignment_id
                                ,p_actual_term_date
                                ,p_last_standard_date
                                ,p_final_process_date
                                ,p_legislation_code
                                ,l_entries_changed_ov);
 END terminate_entries_and_alus;
--
-- 115.59 (START)
--
-- =================== terminate_entries_and_alus overload ===================
--
  PROCEDURE terminate_entries_and_alus(p_assignment_id      NUMBER,
                                       p_actual_term_date   DATE,
                                       p_last_standard_date DATE,
                                       p_final_process_date DATE,
                                     p_legislation_code   VARCHAR2 DEFAULT
                                     NULL,
                                     p_entries_changed_warning
                                     IN OUT NOCOPY VARCHAR2)
  IS
  --
  l_alu_change_warning_ovl VARCHAR2(1) := 'N';
  --
  BEGIN
    --
    terminate_entries_and_alus(p_assignment_id
                              ,p_actual_term_date
                              ,p_last_standard_date
                              ,p_final_process_date
                              ,p_legislation_code
                              ,p_entries_changed_warning
                              ,l_alu_change_warning_ovl);
    --
  END terminate_entries_and_alus;
--
-- 115.59 (END)
--
-- ========================= terminate_entries_and_alus ======================
--
  PROCEDURE terminate_entries_and_alus(p_assignment_id      NUMBER,
                                       p_actual_term_date   DATE,
                                       p_last_standard_date DATE,
                                       p_final_process_date DATE,
                                       p_legislation_code   VARCHAR2 DEFAULT
                                     NULL,
                                     p_entries_changed_warning
--
-- 115.59 (START)
--
                                     --IN OUT NOCOPY VARCHAR2)
                                     IN OUT NOCOPY VARCHAR2,
                                     p_alu_change_warning
                                     IN OUT NOCOPY VARCHAR2)
--
-- 115.59 (END)
--
  IS
  --
  -- VT 10/07/96 bug #306710
  -- p_entries_changed_warning = N no entries changed
  -- p_entries_changed_warning = Y non_salary entries changed
  -- p_entries_changed_warning = S salary entries changed
  --
  l_entries_changed VARCHAR2(1) := 'N';
  l_cur_entries VARCHAR2(1) := 'N';
  l_cur_alus VARCHAR2(1) := 'N';
  l_proc varchar2(72):=g_package||'terminate_entries_and_alus';
  --
  PROCEDURE delete_entries(p_assignment_id      NUMBER,
                           p_term_date          DATE,
                           p_term_rule          VARCHAR2,
               p_final_process_date DATE,
               p_entries_changed_warning IN OUT
               VARCHAR2) IS
   --
   -- Cursor to return all recurring element entries for the assignment that
   -- are for an element with the correct post termination rule and also exists
   -- after the termination date

   -- bug fix 3446768. Cursor modified to increase
   -- performance.
   -- bug fix 3983715. Cursor modified to improve execution
   -- time.cursor split into two.
   -- bug fix 4308892. Cursor modified to return min ee.effective_start_date,
   -- which is required for element entry API call.
   -- 6801103. Modified the effective_end_date condition.
      CURSOR rec_entries(p_assignment_id  NUMBER,
                         p_term_date      DATE
                         ) IS
       SELECT ee.element_entry_id,
              ee.element_link_id,
   	          ee.element_type_id,
              MIN(ee.effective_start_date) effective_start_date,
              MAX(ee.effective_end_date) effective_end_date
       FROM   pay_element_entries_f ee
       WHERE  ee.assignment_id = p_assignment_id
         AND  ee.effective_end_date >= p_term_date
         AND  ee.entry_type = 'E'
       GROUP BY ee.element_entry_id, ee.element_link_id,ee.element_type_id;

      CURSOR chk_element_type_csr(p_element_type_id number,
                                       p_term_rule varchar2 ) IS
        SELECT 'Y'
           FROM   pay_element_types_f et
        WHERE  et.element_type_id = p_element_type_id
           AND  et.post_termination_rule = p_term_rule
        AND  et.processing_type = 'R';
  --
   -- Cursor to return all nonrecurring element entries for the assignment that
   -- are for an element with the correct post termination rule and also exists
   -- after the termination date
  -- bug fix 4308892. Cursor modified to return min ee.effective_start_date and
   -- max ee.effective_end_date which are required for element entry API call.
   CURSOR nonrec_entries(p_assignment_id  NUMBER,
                         p_term_date      DATE,
                         p_term_rule      VARCHAR2) IS
    SELECT ee.element_entry_id,
           ee.element_link_id,
           min(ee.effective_start_date) effective_start_date,
           max(ee.effective_end_date) effective_end_date
    FROM   pay_element_entries_f ee
    WHERE  ee.assignment_id = p_assignment_id
      AND  ee.effective_end_date > p_term_date
      AND  ((ee.entry_type <> 'E')
       OR   (ee.entry_type = 'E'
      AND  EXISTS (SELECT NULL
                   FROM   pay_element_links_f el,
                          pay_element_types_f et
                   WHERE  el.element_link_id = ee.element_link_id
                     AND  et.element_type_id = el.element_type_id
                     AND  et.processing_type = 'N')))
      AND  EXISTS (SELECT NULL
                   FROM   pay_element_links_f el,
                          pay_element_types_f et
                   WHERE  el.element_link_id = ee.element_link_id
                     AND  et.element_type_id = el.element_type_id
                     AND  et.post_termination_rule = p_term_rule)
    GROUP BY ee.element_entry_id, ee.element_link_id;
  --
   -- VT #553177 12/11/97
   -- Cursor to return the current period end for
   -- nonrecurring element entry
   CURSOR period_end (p_asg_id in NUMBER,
                      p_start_date in DATE) IS
   SELECT ptp.end_date
   FROM per_time_periods ptp,
        per_all_assignments_f paaf
   WHERE paaf.assignment_id = p_asg_id
     AND p_start_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
     AND paaf.payroll_id = ptp.payroll_id
     AND p_start_date BETWEEN ptp.start_date AND ptp.end_date;
  --
  CURSOR get_pay_proposals(p_assignment_id number
                          ,p_term_date     date
                          ,p_term_rule     varchar2) is
    select ppp.pay_proposal_id
    ,      ppp.multiple_components
    from per_pay_proposals ppp
    ,    per_all_assignments_f asg
    ,    per_pay_bases ppb
    ,    pay_element_types_f pet
    ,    pay_input_values_f piv
    where ppp.assignment_id=p_assignment_id
    and   asg.assignment_id=p_assignment_id
    and   ppp.change_date between asg.effective_start_date and asg.effective_end_date
    and   ppb.pay_basis_id=asg.pay_basis_id
    and   ppb.input_value_id=piv.input_value_id
    and   ppp.change_date between piv.effective_start_date and piv.effective_end_date
    and   piv.element_type_id=pet.element_type_id
    and   ppp.change_date between pet.effective_start_date and pet.effective_end_date
    and   pet.post_termination_rule = p_term_rule
    and   ppp.change_date>p_term_date;

   -- Local Constants
   c_eot              constant date := to_date('31/12/4712','DD/MM/YYYY');
   l_last_update_date constant date := trunc(sysdate);
  --
   -- Local variables
   l_element_type_id  NUMBER;
   -- VT 02/27/96 variable to check current value of process_in_run_flag
   -- VT 02/27/96 bug #334654,#334681
   l_process_in_run_flag VARCHAR2(1);
  -- VT 10/07/96 bug #306710
  l_entries_changed_warning VARCHAR2(1) := 'N';
  --
  l_y_chng number := 0;
  l_s_chng number := 0;
  l_ret_chng VARCHAR2(1) := 'N';
  --
  l_current_period_end DATE;
  l_type_exists varchar2(1);
  --
  -- Bug fix 4308892
  -- Variables added for element entry API calls...
    l_ee_object_version_number number := null;
    l_ee_effective_start_date  date   := null;
    l_ee_effective_end_date    date   := null;
    l_delete_warning           boolean;
  --
  l_proc varchar2(72):=g_package||'delete_entries';
  BEGIN
  -- VT 10/07/96 bug #306710 added new loops for element entries
    FOR rec_entry IN rec_entries(p_assignment_id,
                                   p_term_date
                                  )
    LOOP

        -- Bug fix 3983715.
        -- Cursor to check whether the type exists.

       OPEN chk_element_type_csr( rec_entry.element_type_id,p_term_rule);
       FETCH chk_element_type_csr INTO l_type_exists;
       CLOSE chk_element_type_csr;

       IF nvl(l_type_exists,'N') = 'Y' THEN

          l_type_exists := 'N';

          SELECT el.element_type_id
          INTO   l_element_type_id
          FROM   pay_element_links_f el
          WHERE  el.element_link_id = rec_entry.element_link_id
            AND  rec_entry.effective_end_date BETWEEN el.effective_start_date
                                                  AND el.effective_end_date;
          hr_entry.chk_element_entry_open(l_element_type_id,
                                          p_term_date,
                                          p_term_date,
                                          rec_entry.effective_end_date,
                                          p_assignment_id);
          BEGIN
          l_ret_chng := 'N';
          SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entry_values_f eev
                      WHERE  eev.element_entry_id     = rec_entry.element_entry_id
                      AND  eev.effective_start_date > p_term_date);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
          IF l_ret_chng = 'Y' THEN
            l_y_chng := l_y_chng + 1;
          END IF;
          BEGIN
          l_ret_chng := 'N';
          SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entries_f ee
                      WHERE  ee.element_entry_id     = rec_entry.element_entry_id
                      AND  ee.effective_start_date > p_term_date);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
          IF l_ret_chng = 'Y' THEN
            l_y_chng := l_y_chng + 1;
          END IF;
          BEGIN
          l_ret_chng := 'N';
          SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entry_values_f eev
                      WHERE  eev.element_entry_id   = rec_entry.element_entry_id
                      AND  eev.effective_end_date > p_term_date);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
          IF l_ret_chng = 'Y' THEN
            l_y_chng := l_y_chng + 1;
          END IF;
          BEGIN
          l_ret_chng := 'N';
          SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entries_f ee
                      WHERE  ee.element_entry_id   = rec_entry.element_entry_id
                      AND  ee.effective_end_date > p_term_date);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
          IF l_ret_chng = 'Y' THEN
            l_y_chng := l_y_chng + 1;
          END IF;
          BEGIN
          l_ret_chng := 'N';
          SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entries_f ee
                      WHERE  ee.element_entry_id     = rec_entry.element_entry_id
                      AND ee.creator_type = 'SP'
                      AND  ee.effective_start_date > p_term_date);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
          IF l_ret_chng = 'Y' THEN
            l_s_chng := l_s_chng + 1;
          END IF;
          BEGIN
          l_ret_chng := 'N';
          SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entries_f ee
                      WHERE  ee.element_entry_id   = rec_entry.element_entry_id
                      AND ee.creator_type = 'SP'
                      AND  ee.effective_end_date > p_term_date);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
          END;
          IF l_ret_chng = 'Y' THEN
            l_s_chng := l_s_chng + 1;
          END IF;
       END IF; -- if l_type_exists
   END LOOP; -- FOR rec_entry IN ...
  --
  IF (l_y_chng + l_s_chng) = 0 THEN
   FOR nonrec_entry IN nonrec_entries(p_assignment_id,
                                      p_term_date,
                                      p_term_rule) LOOP
     l_process_in_run_flag := 'N';
     SELECT el.element_type_id, et.process_in_run_flag
     INTO   l_element_type_id, l_process_in_run_flag
     FROM   pay_element_links_f el, pay_element_types_f et
     WHERE  el.element_link_id = nonrec_entry.element_link_id
       AND  et.element_type_id = el.element_type_id
       AND  nonrec_entry.effective_end_date BETWEEN el.effective_start_date
                                                AND el.effective_end_date
       /*   Bug 1406063 */
       AND  nonrec_entry.effective_end_date BETWEEN et.effective_start_date
                                       AND et.effective_end_date;
      /*   End Bug 1406063 */
     hr_entry.chk_element_entry_open(l_element_type_id,
                                     nonrec_entry.effective_start_date,
                                     nonrec_entry.effective_start_date,
                                     nonrec_entry.effective_end_date,
                                     p_assignment_id);
     IF nonrec_entry.effective_start_date > p_term_date THEN
       IF l_process_in_run_flag = 'Y' and p_term_rule IN ('A','L') THEN
         hr_utility.set_message(801,'HR_51208_EMP_ASS_NO_TERM_EE');
         hr_utility.raise_error;
         EXIT;
       ELSE
         BEGIN
         l_ret_chng := 'N';
         SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entry_values_f eev
                 WHERE  eev.element_entry_id     = nonrec_entry.element_entry_id);
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
         END;
         IF l_ret_chng = 'Y' THEN
           l_y_chng := l_y_chng + 1;
         END IF;
         BEGIN
         l_ret_chng := 'N';
         SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entries_f ee
                 WHERE  ee.element_entry_id     = nonrec_entry.element_entry_id);
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
         END;
         IF l_ret_chng = 'Y' THEN
           l_y_chng := l_y_chng + 1;
         END IF;
         BEGIN
         l_ret_chng := 'N';
         SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entries_f ee
                 WHERE  ee.element_entry_id     = nonrec_entry.element_entry_id
                 AND ee.creator_type = 'SP');
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
         END;
         IF l_ret_chng = 'Y' THEN
           l_s_chng := l_s_chng + 1;
         END IF;
       END IF;
     ELSIF nonrec_entry.effective_start_date <= p_term_date AND
       nonrec_entry.effective_end_date > nvl(p_term_date,c_eot) THEN
       IF p_final_process_date IS NULL THEN
         BEGIN
         l_ret_chng := 'N';
         SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
          (SELECT 'Y' FROM pay_element_entry_values_f eev
             WHERE  eev.element_entry_id   = nonrec_entry.element_entry_id
             AND  eev.effective_end_date = nonrec_entry.effective_end_date);
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
         END;
         IF l_ret_chng = 'Y' THEN
           l_y_chng := l_y_chng + 1;
         END IF;
       ELSE
         IF p_term_rule IN ('A','L','F') THEN
           BEGIN
           l_ret_chng := 'N';
           SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
            (SELECT 'Y' FROM pay_element_entries_f ee
               WHERE  ee.element_entry_id   = nonrec_entry.element_entry_id
               AND  ee.effective_end_date = nonrec_entry.effective_end_date);
           EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
           END;
           IF l_ret_chng = 'Y' THEN
             l_y_chng := l_y_chng + 1;
           END IF;
           BEGIN
           l_ret_chng := 'N';
           SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
            (SELECT 'Y' FROM pay_element_entries_f ee
               WHERE  ee.element_entry_id   = nonrec_entry.element_entry_id
               AND ee.creator_type = 'SP'
               AND  ee.effective_end_date = nonrec_entry.effective_end_date);
           EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
           END;
           IF l_ret_chng = 'Y' THEN
             l_s_chng := l_s_chng + 1;
           END IF;
           BEGIN
           l_ret_chng := 'N';
           SELECT 'Y' INTO l_ret_chng FROM dual WHERE EXISTS
            (SELECT 'Y' FROM pay_element_entry_values_f eev
             WHERE  eev.element_entry_id   = nonrec_entry.element_entry_id
             AND  eev.effective_end_date = nonrec_entry.effective_end_date);
           EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
           END;
           IF l_ret_chng = 'Y' THEN
             l_y_chng := l_y_chng + 1;
           END IF;
         END IF;
       END IF;
     END IF;
   END LOOP; -- FOR nonrec_entry IN ...
  END IF;
  -- VT 10/14/96 bug #306710
  -- Warning message
  --
  l_entries_changed_warning := 'N';
  p_entries_changed_warning := l_entries_changed_warning;
  IF l_s_chng > 0 THEN
    l_entries_changed_warning := 'S';
    p_entries_changed_warning := l_entries_changed_warning;
  ELSE
     IF l_y_chng > 0 THEN
       l_entries_changed_warning := 'Y';
       p_entries_changed_warning := l_entries_changed_warning;
     END IF;
  END IF;
  --
   hr_utility.set_location(l_proc,5);
  --
   -- Process all recurrring entries for the assignment
   FOR rec_entry IN rec_entries(p_assignment_id,
                                   p_term_date
                                   )
   LOOP
       --
        hr_utility.set_location(l_proc,10);
       --
       -- Bug fix 3983715.
       -- Cursor to check whether the type exists.

        OPEN chk_element_type_csr( rec_entry.element_type_id,p_term_rule);
        FETCH chk_element_type_csr INTO l_type_exists;
        CLOSE chk_element_type_csr;

        IF nvl(l_type_exists,'N') = 'Y' THEN

           l_type_exists := 'N';

           -- Find the element type id for the entry for use in checking if there
           -- are open periods

           SELECT el.element_type_id
           INTO   l_element_type_id
           FROM   pay_element_links_f el
           WHERE  el.element_link_id = rec_entry.element_link_id
             AND  rec_entry.effective_end_date BETWEEN el.effective_start_date
                                                   AND el.effective_end_date;
           --
           hr_utility.set_location(l_proc,15);
           --
           -- Make sure delete doew not overlap with a closed period
           hr_entry.chk_element_entry_open(l_element_type_id,
                                           p_term_date,
                                           p_term_date,
                                           rec_entry.effective_end_date,
                                           p_assignment_id);
           --
           hr_utility.set_location(l_proc,20);
           --
           -- Delete covered_dependents and beneficiaries for the recurring
           -- element entries
           --

           hr_entry.delete_covered_dependants(
            p_element_entry_id => rec_entry.element_entry_id,
            p_end_date => p_term_date,
            p_validation_start_date => p_term_date);


           hr_entry.delete_beneficiaries(
            p_element_entry_id => rec_entry.element_entry_id,
            p_end_date => p_term_date,
            p_validation_start_date => p_term_date);
           --
           -- Bugfix 4308892
           -- Replace DELETE statements with equivalent calls to
           -- pay_element_entry_api.delete_element_entry
           --
           if rec_entry.effective_start_date > p_term_date then
             --
             hr_utility.set_location(l_proc,21);
             /*
             ** Original code, below, performs a delete from PAY_ELEMENT_ENTRIES_F
             ** and PAY_ELEMENT_ENTRY_VALUES_F where the entry effective start
             ** date is greater than the termination date (i.e. the entry starts
             ** after the employee is terminated). Therefore the entry, and its
             ** values, can be completely removed.
             ** The DML statements can be replaced with a single call to
             ** pay_element_entry_api.delete_element_entry using the 'ZAP' mode.
             **
             --
             DELETE FROM pay_element_entry_values_f eev
             WHERE  eev.element_entry_id     = rec_entry.element_entry_id
               AND  eev.effective_start_date > p_term_date;
             --
             hr_utility.set_location(l_proc,25);
             --
             DELETE FROM pay_element_entries_f ee
             WHERE  ee.element_entry_id     = rec_entry.element_entry_id
               AND  ee.effective_start_date > p_term_date;
             **
             */
             --
             select object_version_number
             into l_ee_object_version_number
             from pay_element_entries_f
             where element_entry_id = rec_entry.element_entry_Id
             and effective_start_date = rec_entry.effective_start_date;
             --
             pay_element_entry_api.delete_element_entry(
               p_validate => false,
               p_datetrack_delete_mode => 'ZAP',
               p_effective_date => rec_entry.effective_start_date,
               p_element_entry_id => rec_entry.element_entry_id,
               p_object_version_number => l_ee_object_version_number,
               p_effective_start_date => l_ee_effective_start_date,
               p_effective_end_date => l_ee_effective_end_date,
               p_delete_warning => l_delete_warning
               );
             --
           ELSIF rec_entry.effective_end_date <> p_term_date THEN        -- 6801103
             --
             hr_utility.set_location(l_proc,30);
             --
             /*
             ** Original code, below, updates PAY_ELEMENT_ENTRIES_F and
             ** PAY_ELEMENT_ENTRY_VALUES_F, setting the effective_end_date
             ** of the entry end date to the termination date where the
             ** entry end date falls some point after the termination date.
             ** The DML statements can be replaced with a single call to
             ** pay_element_entry_api.delete_element_entry using the 'DELETE' mode.
             **
             --
             UPDATE pay_element_entry_values_f eev
             SET    eev.effective_end_date = p_term_date
             WHERE  eev.element_entry_id   = rec_entry.element_entry_id
               AND  eev.effective_end_date > p_term_date;
             --
             hr_utility.set_location(l_proc,35);
             --
             UPDATE pay_element_entries_f ee
             SET    ee.effective_end_date = p_term_date
             ,      ee.last_update_date   = l_last_update_date
             WHERE  ee.element_entry_id   = rec_entry.element_entry_id
               AND  ee.effective_end_date > p_term_date;
             **
             */
             --
             select object_version_number
             into l_ee_object_version_number
             from pay_element_entries_f
             where element_entry_id = rec_entry.element_entry_Id
             and effective_start_date = rec_entry.effective_start_date;
             --
             l_ee_effective_end_date := rec_entry.effective_end_date;
             --
             pay_element_entry_api.delete_element_entry(
               p_validate => false,
               p_datetrack_delete_mode => 'DELETE',
               p_effective_date => p_term_date,
               p_element_entry_id => rec_entry.element_entry_id,
               p_object_version_number => l_ee_object_version_number,
               p_effective_start_date => l_ee_effective_start_date,
               p_effective_end_date => l_ee_effective_end_date,
               p_delete_warning => l_delete_warning
               );
             --
           end if;
           --
       END IF; -- l_type_exists
   END LOOP; -- FOR rec_entry IN ...
  --
   hr_utility.set_location(l_proc,40);
  --
   -- Process all non-recurrring entries for the assignment
   FOR nonrec_entry IN nonrec_entries(p_assignment_id,
                                      p_term_date,
                                      p_term_rule) LOOP
  --
     hr_utility.set_location(l_proc,45);
  --
     l_process_in_run_flag := 'N';
     -- Find the element type id for the entry for use in checking if there
     -- are open periods
     -- VT 03/01/96 changed to fix bug #334654,#334681
     SELECT el.element_type_id, et.process_in_run_flag
     INTO   l_element_type_id, l_process_in_run_flag
     FROM   pay_element_links_f el, pay_element_types_f et
     WHERE  el.element_link_id = nonrec_entry.element_link_id
       AND  et.element_type_id = el.element_type_id
       AND  nonrec_entry.effective_end_date BETWEEN el.effective_start_date
                                                AND el.effective_end_date
       /*   Bug 1406063 */
       AND  nonrec_entry.effective_end_date BETWEEN et.effective_start_date
                                       AND et.effective_end_date;
      /*   End Bug 1406063 */
  --
     hr_utility.set_location(l_proc,50);
  --
     -- Make sure delete doew not overlap with a closed period
     hr_entry.chk_element_entry_open(l_element_type_id,
                                     nonrec_entry.effective_start_date,
                                     nonrec_entry.effective_start_date,
                                     nonrec_entry.effective_end_date,
                                     p_assignment_id);
  --
     -- Nonrecurring entry starts after its termination date so it must be
     -- removed.
     if nonrec_entry.effective_start_date > p_term_date then
       -- VT 03/01/96 additional check to fix bug #334654,#334681
       if l_process_in_run_flag = 'Y' and p_term_rule IN ('A','L') then
         hr_utility.set_message(801,'HR_51208_EMP_ASS_NO_TERM_EE');
         hr_utility.raise_error;
         exit;
       else
  --
  hr_utility.set_location(l_proc,53);
  --

  -- Delete covered_dependents and beneficiaries for the non recurring
  -- element entries that start after the termination date.
  --

  hr_entry.delete_covered_dependants(
      p_element_entry_id => nonrec_entry.element_entry_id,
      p_end_date => p_term_date,
      p_validation_start_date => p_term_date);


  hr_entry.delete_beneficiaries(
      p_element_entry_id => nonrec_entry.element_entry_id,
      p_end_date => p_term_date,
      p_validation_start_date => p_term_date);



  --
       hr_utility.set_location(l_proc,55);
  --
-- TAR 1660650.999
-- Changed where clause

       DELETE FROM pay_run_results rr
       WHERE  rr.source_type = 'E'
         AND  rr.source_id = nonrec_entry.element_entry_id
         AND  rr.status not like 'P%';
  --
       hr_utility.set_location(l_proc,60);
       -- Bugfix 4308892
       -- Replace DELETE statements with equivalent calls to
       -- pay_element_entry_api.delete_element_entry
       --
       /*
       ** Original code, below, performs a delete from PAY_ELEMENT_ENTRIES_F
       ** and PAY_ELEMENT_ENTRY_VALUES_F since the entry effective start
       ** date is greater than the termination date (i.e. the entry starts
       ** after the employee is terminated). Therefore the entry, and its
       ** values, can be completely removed.
       ** The DML statements can be replaced with a single call to
       ** pay_element_entry_api.delete_element_entry using the 'ZAP' mode.
       **
       DELETE FROM pay_element_entry_values_f eev
       WHERE  eev.element_entry_id = nonrec_entry.element_entry_id;
  --
       hr_utility.set_location(l_proc,65);
  --
       DELETE FROM pay_element_entries_f ee
       WHERE  ee.element_entry_id = nonrec_entry.element_entry_id;
       **
       */
       --
       select object_version_number
       into l_ee_object_version_number
       from pay_element_entries_f
       where element_entry_id = nonrec_entry.element_entry_Id
       and effective_start_date = nonrec_entry.effective_start_date;
       --
       pay_element_entry_api.delete_element_entry(
         p_validate => false,
         p_datetrack_delete_mode => 'ZAP',
         p_effective_date => nonrec_entry.effective_start_date,
         p_element_entry_id => nonrec_entry.element_entry_id,
         p_object_version_number => l_ee_object_version_number,
         p_effective_start_date => l_ee_effective_start_date,
         p_effective_end_date => l_ee_effective_end_date,
         p_delete_warning => l_delete_warning
         );
       --
  --
       end if;
     -- Nonrecurring entry straddles its termination date so it can still
     -- exist. If the final process date is less than the nonrecurring end date
     -- then the end date is updated to that of the final process date.
     --
     -- 31-oct-1995 WWBUG 314277 changed test for p_final_process_date
     -- to be p_term_date as this agrees with the relevant termination rule.
     elsif nonrec_entry.effective_start_date <= p_term_date and
       nonrec_entry.effective_end_date > nvl(p_term_date,
                         c_eot) then
       -- VT 03/05/96 additional check to fix bug #314277
       IF p_final_process_date IS NULL THEN

  --
  hr_utility.set_location(l_proc,67);
  --

   -- Delete covered_dependents and beneficiaries for the non recurring
   -- element entries that have no final process date
  --

  hr_entry.delete_covered_dependants(
      p_element_entry_id => nonrec_entry.element_entry_id,
      p_end_date => p_term_date,
      p_validation_start_date => p_term_date);


  hr_entry.delete_beneficiaries(
      p_element_entry_id => nonrec_entry.element_entry_id,
      p_end_date => p_term_date,
      p_validation_start_date => p_term_date);

  --
       hr_utility.set_location(l_proc,70);
  --
     -- 31-oct-1995 WWBUG 314277 changed update to p_final_process_date
     -- to be p_term_date as this agrees with the relevant termination rule.
     -- VT #553177 12/10/97
       null;
     --  UPDATE pay_element_entry_values_f eev
     --  SET    eev.effective_end_date = p_term_date
     --  WHERE  eev.element_entry_id   = nonrec_entry.element_entry_id
     --    AND  eev.effective_end_date = nonrec_entry.effective_end_date;
  --
       hr_utility.set_location(l_proc,75);
  --
     -- 31-oct-1995 WWBUG 314277 changed update to p_final_process_date
     -- to be p_term_date as this agrees with the relevant termination rule.
     -- VT 03/05/96 commented out to fix bug #314277
  --     UPDATE pay_element_entries_f ee
  --     SET    ee.last_update_date = p_term_date
  --     WHERE  ee.element_entry_id   = nonrec_entry.element_entry_id
  --       AND  ee.effective_end_date = nonrec_entry.effective_end_date;
  --
       ELSE
     -- VT 01/03/96 bug #314277 effective end date is to be set to
     -- p_final_process_date when p_final_process_date is not null.
  --
         hr_utility.set_location(l_proc,80);
  --
         -- VT #553177 12/11/97
         l_current_period_end := null;
         OPEN period_end(p_assignment_id, nonrec_entry.effective_start_date);
         FETCH period_end INTO l_current_period_end;
         CLOSE period_end;
         --
         IF p_term_rule IN ('A','L','F')
           AND l_current_period_end IS NOT NULL
           AND p_final_process_date <= l_current_period_end THEN
  --
  --
  hr_utility.set_location(l_proc,83);
  --

  -- Delete covered_dependents and beneficiaries for the non-recurring
  -- element entries which have a final process date.
  --

      hr_entry.delete_covered_dependants(
          p_element_entry_id => nonrec_entry.element_entry_id,
          p_end_date => p_term_date,
          p_validation_start_date => p_final_process_date);


      hr_entry.delete_beneficiaries(
          p_element_entry_id => nonrec_entry.element_entry_id,
          p_end_date => p_term_date,
          p_validation_start_date => p_final_process_date);

           --
           -- Bugfix 4308892
           -- Replace DELETE statements with equivalent calls to
           -- pay_element_entry_api.delete_element_entry
           --
           /*
           ** Original code, below, updates PAY_ELEMENT_ENTRIES_F and
           ** PAY_ELEMENT_ENTRY_VALUES_F, setting the effective_end_date
           ** of the entry end date to the termination date where the
           ** entry end date falls some point after the termination date.
           ** The DML statements can be replaced with a single call to
           ** pay_element_entry_api.delete_element_entry using the 'DELETE' mode.
           **
           UPDATE pay_element_entries_f ee
           SET ee.effective_end_date = p_final_process_date
           ,   ee.last_update_date   = l_last_update_date
           WHERE ee.element_entry_id = nonrec_entry.element_entry_id
             AND ee.effective_end_date = nonrec_entry.effective_end_date;
           UPDATE pay_element_entry_values_f eev
           SET eev.effective_end_date = p_final_process_date
           WHERE eev.element_entry_id = nonrec_entry.element_entry_id
             AND eev.effective_end_date = nonrec_entry.effective_end_date;
           **
           */
           --
           select object_version_number
           into l_ee_object_version_number
           from pay_element_entries_f
           where element_entry_id = nonrec_entry.element_entry_Id
           and effective_start_date = nonrec_entry.effective_start_date;
           --
           pay_element_entry_api.delete_element_entry(
             p_validate => false,
             p_datetrack_delete_mode => 'DELETE',
             p_effective_date => p_final_process_date,
             p_element_entry_id => nonrec_entry.element_entry_id,
             p_object_version_number => l_ee_object_version_number,
             p_effective_start_date => l_ee_effective_start_date,
             p_effective_end_date => l_ee_effective_end_date,
             p_delete_warning => l_delete_warning
             );
           --
         hr_utility.set_location(l_proc,85);
  --
         END IF;
       END IF;
     end if;
  --
     hr_utility.set_location(l_proc,90);
  --
     -- VT #375157 06/28/96
     -- Remove any pay proposals for which there are no element entries.
     --delete from per_pay_proposals pp
     --where  pp.assignment_id = p_assignment_id
     --  and  not exists
     --  (select null
     --     from   pay_element_entries_f ee
     --     where  ee.assignment_id = pp.assignment_id
     --     and  ee.entry_type = 'SP'
     --     and  ee.creator_id = pp.pay_proposal_id);
  --
   END LOOP; -- FOR nonrec_entry IN ...
    --
    hr_utility.set_location(l_proc,100);
    --
    for pay_rec in get_pay_proposals(p_assignment_id,p_term_date,p_term_rule) LOOP
      --
      hr_utility.set_location(l_proc,110);
      --
      if pay_rec.multiple_components='Y' then
        DELETE FROM per_pay_proposal_components
        WHERE pay_proposal_id=pay_rec.pay_proposal_id;
      end if;
      --
      DELETE FROM per_pay_proposals
      WHERE pay_proposal_id=pay_rec.pay_proposal_id;
      --
      hr_utility.set_location(l_proc,120);
      --
    end loop;
    --
    hr_utility.set_location(l_proc,130);
    --
  END delete_entries;
  --
  -- Bug 5368246.
  -- We delete or end date ALUs only when the final process date
  -- is specified, ie. only when the assignment is end dated.
  -- Therefore, we no longer check the term rule, and p_term_date
  -- is always set to the final process date.
  --
  PROCEDURE delete_alus(p_assignment_id  NUMBER,
                        p_term_date      DATE,
                        --p_term_rule      VARCHAR2,
--
-- 115.59 (START)
--
                        --p_changes IN OUT NOCOPY VARCHAR2) IS
                        p_changes IN OUT NOCOPY VARCHAR2,
                        p_alu_change_warning IN OUT NOCOPY VARCHAR2) IS
--
-- 115.59 (END)
--
  --
  l_alu_change VARCHAR2(1) := 'N';
  l_alu_del VARCHAR2(1) := 'N';
  l_alu_upd VARCHAR2(1) := 'N';
  l_proc varchar2(72):=g_package||'delete_alus';
  --
--
-- 115.59 (START)
--
  CURSOR csr_alu_actions IS
    SELECT NULL
      FROM pay_payroll_actions    ppa
          ,pay_assignment_actions paa
     WHERE ppa.payroll_action_id = paa.payroll_action_id
       AND ppa.action_type IN ('R','Q','V','B')
       AND paa.assignment_id = p_assignment_id
       AND NVL(ppa.date_earned,ppa.effective_date) > p_term_date;
  --
  l_dummy VARCHAR2(1);
--
-- 115.59 (END)
--
  BEGIN
  --
--
-- 115.59 (START)
--
  OPEN csr_alu_actions;
  FETCH csr_alu_actions INTO l_dummy;
  IF csr_alu_actions%FOUND THEN
    p_alu_change_warning := 'Y';
  ELSE
    p_alu_change_warning := 'N';
  END IF;
  CLOSE csr_alu_actions;
--
-- 115.59 (END)
--
  --
   hr_utility.set_location(l_proc,1);
  --
   DELETE FROM pay_assignment_link_usages_f alu
   WHERE  alu.assignment_id = p_assignment_id
     AND  alu.effective_start_date > p_term_date;
   --
   if sql%found then
     l_alu_del := 'Y';
   end if;
  --
   hr_utility.set_location(l_proc,2);
  --
   UPDATE pay_assignment_link_usages_f alu
   SET    alu.effective_end_date = p_term_date
   WHERE  alu.assignment_id = p_assignment_id
     AND  alu.effective_end_date > p_term_date;
   --
   if sql%found then
     l_alu_upd := 'Y';
   end if;

   IF l_alu_del = 'Y' OR l_alu_upd = 'Y' THEN
     l_alu_change := 'Y';
     p_changes := l_alu_change;
   END IF;
  --
  END delete_alus;
  --
 -- Main code starts here
 BEGIN -- PROCEDURE terminate_entries_and_alus
  --
  hr_utility.set_location(l_proc,1);
  --
  -- Validates the combination of dates passed. The valid combinations are
  --
  -- Actual                                (if legislation US)
  -- Actual   Last Standard
  -- Actual   Last Standard   Final Process
  -- Actual                   Final Process(if legislation US)
  --                          Final Process
  --
  -- 288341. Removed unnecessary clause "p_legislation_code <> 'US'", which
  -- was causing the check to fail when p_legislation_code was NULL.
  -- RMF 03.07.95.
  --
  -- Bug 1711085. VS. 29-Mar-01. Removed references to US legislation
  -- in association with last_standard_process.
  --
  -- Bug 2784295 : commenting the code which requires LSPD to be not null
  -- for non-US legislations
   IF p_actual_term_date IS NOT NULL THEN
   /*  (p_legislation_code = 'US' or
     p_last_standard_date IS NOT NULL) THEN */
  --
    -- Valid combination of parameters
    NULL;
  --
    ELSIF
      p_final_process_date IS NOT NULL AND
          p_actual_term_date IS NULL AND
      p_last_standard_date IS NULL THEN
  --
      -- Valid combination of parameters
      NULL;
  --
      ELSE
  --
        hr_utility.set_location(l_proc,2);
  --
    -- All other parameter combinations invalid
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','TERMINATE_ENTRIES');
    hr_utility.set_message_token('STEP', '1');
    hr_utility.raise_error;
  --
  END IF; -- p_actual_term_date IS NOT NULL ...
  l_entries_changed := 'N';
  l_cur_entries := 'N';
  l_cur_alus := 'N';
  --
  hr_utility.set_location(l_proc,3);
  --
  -- Shut down all element entries and ALU's for element types which have
  -- a post termination rule of 'Actual Termination'
  IF p_actual_term_date IS NOT NULL THEN
  --
    hr_utility.set_location(l_proc,4);
  --
    l_cur_entries := 'N';
    delete_entries(p_assignment_id,
                   p_actual_term_date,
                   'A',
           p_final_process_date,
           l_cur_entries);
    if l_cur_entries = 'S' then
      l_entries_changed := 'S';
    else
      if l_entries_changed = 'N' and l_cur_entries = 'Y' then
        l_entries_changed := 'Y';
      end if;
    end if;
  --
    hr_utility.set_location(l_proc,5);
  --
    --
    -- Bug 5368246.
    -- We delete alus only when final process date is specified,
    -- hence commented out the followings.
    /******
    l_cur_alus := 'N';
    delete_alus(p_assignment_id,
                p_actual_term_date,
                'A',
                l_cur_alus,
                p_alu_change_warning);
    ******/
  --
  END IF; -- IF p_actual_term_date ...
  --
  hr_utility.set_location(l_proc,6);
  --
  -- Shut down all element entries and ALU's for element types which have a
  -- post termination rule of 'Last Standard Process'
  IF p_last_standard_date IS NOT NULL THEN
  --
    hr_utility.set_location(l_proc,7);
  --
    l_cur_entries := 'N';
    delete_entries(p_assignment_id,
                   p_last_standard_date,
                   'L',
           p_final_process_date,
           l_cur_entries);
    if l_cur_entries = 'S' then
      l_entries_changed := 'S';
    else
      if l_entries_changed = 'N' and l_cur_entries = 'Y' then
        l_entries_changed := 'Y';
      end if;
    end if;
  --
    hr_utility.set_location(l_proc,8);
  --
    --
    -- Bug 5368246.
    -- We delete alus only when final process date is specified,
    -- hence commented out the followings.
    /******
    l_cur_alus := 'N';
    delete_alus(p_assignment_id,
                p_last_standard_date,
                'L',
                l_cur_alus,
                p_alu_change_warning);
    ******/
  --
  END IF; -- IF p_last_standard_date ...
  --
  hr_utility.set_location(l_proc,9);
  --
  -- Shut down all element entries and ALU's for element types which have a
  -- post termination rule of 'Final Close'
  IF p_final_process_date IS NOT NULL THEN
    l_cur_entries := 'N';
    delete_entries(p_assignment_id,
                   p_final_process_date,
                   'A',
                   p_final_process_date,
                   l_cur_entries);
    if l_cur_entries = 'S' then
      l_entries_changed := 'S';
    else
      if l_entries_changed = 'N' and l_cur_entries = 'Y' then
        l_entries_changed := 'Y';
      end if;
    end if;
    l_cur_entries := 'N';
    delete_entries(p_assignment_id,
                   p_final_process_date,
                   'L',
                   p_final_process_date,
                   l_cur_entries);
    if l_cur_entries = 'S' then
      l_entries_changed := 'S';
    else
      if l_entries_changed = 'N' and l_cur_entries = 'Y' then
        l_entries_changed := 'Y';
      end if;
    end if;
  --
    hr_utility.set_location(l_proc,10);
  --
    l_cur_entries := 'N';
    delete_entries(p_assignment_id,
                   p_final_process_date,
                   'F',
           p_final_process_date,
           l_cur_entries);
    if l_cur_entries = 'S' then
      l_entries_changed := 'S';
    else
      if l_entries_changed = 'N' and l_cur_entries = 'Y' then
        l_entries_changed := 'Y';
      end if;
    end if;
  --
    hr_utility.set_location(l_proc,11);
  --
    l_cur_alus := 'N';
    --
    -- Bug 5368246.
    -- When final process date is specified, we delete or end date
    -- all of the alus regardless of the termination rule.
    --
    delete_alus(p_assignment_id,
                p_final_process_date,
                --'F',
                l_cur_alus,
                p_alu_change_warning);
  --
  END IF; -- IF p_final_process_date ...
  --
  -- VT 10/07/96 bug #306710 return value
  p_entries_changed_warning := l_entries_changed;
 END terminate_entries_and_alus;
--
--
-- ====================== terminate_employee ========================
--
  PROCEDURE terminate_employee(p_trigger                    VARCHAR2
                              ,p_business_group_id          NUMBER
                              ,p_person_id                  NUMBER
                              ,p_assignment_status_type_id  NUMBER
                              ,p_actual_termination_date    DATE
                              ,p_last_standard_process_date DATE
                              ,p_final_process_date         DATE)
  IS
  --
  l_current_applicant_flag     VARCHAR2(30);
  l_current_employee_flag      VARCHAR2(30);
  l_current_emp_or_apl_flag    VARCHAR2(30);
  l_person_type_id             NUMBER;
  l_assignment_status_type_id  NUMBER;
  l_max_end_date               DATE;
  l_effective_end_date         DATE;
  l_per_system_status          VARCHAR2(30);
  l_action_chk                 VARCHAR2(1) := 'N';
  l_legislation_code           VARCHAR2(30);
  --
  FPD_FLAG                     BOOLEAN;
  TA_FLAG                      BOOLEAN;
  --
  -- VT 10/07/96 bug #306710
  l_entries_changed VARCHAR2(1) := 'N';
  l_ent_loop VARCHAR2(1) := 'N';
  --
  CURSOR c_employee IS
  SELECT *
  FROM   per_people_f pp
  WHERE  pp.person_id = p_person_id
  FOR UPDATE;
  --
  -- Added AND    assignment_type = 'E' 307957 tm 19-sep-1995
  --
  CURSOR c_assignment IS
  SELECT *
  FROM   per_assignments_f ass
  WHERE  ass.person_id = p_person_id
  AND    p_actual_termination_date
         BETWEEN ass.effective_start_date
         AND     ass.effective_end_date
  AND    assignment_type = 'E'
  FOR UPDATE;
  --
  -- Added for US legsilation specific code.
  --
  cursor legislation is
  select legislation_code
  from per_business_groups
  where business_group_id = p_business_group_id;
--
  l_proc varchar2(72):=g_package||'terminate_employee';
  begin
  hr_utility.trace('Entered terminate_employee for '||p_person_id);
  --
  open legislation;
  fetch legislation into l_legislation_code;
  close legislation;
  --
  hr_utility.set_location(l_proc,1);
  if p_trigger = 'PRE_UPDATE' then
     hr_utility.set_location(l_proc,2);
    --
    -- Added for US legsilation specific code.
    --
 -- Bug 1711085. VS. Removed reference to US legislature.
 --    if (l_legislation_code <> 'US') then
      if (p_actual_termination_date IS NOT NULL AND
          p_last_standard_process_date IS NOT NULL)
         then null;
      else
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','TERMINATE_EMPLOYEE');
         hr_utility.set_message_token('STEP',2);
         hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc,5);
      if (p_actual_termination_date <= p_last_standard_process_date
         AND p_last_standard_process_date <=
          nvl(p_final_process_date,to_date('31/12/4712','DD/MM/YYYY')))
        then null;
      else
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','TERMINATE_EMPLOYEE');
        hr_utility.set_message_token('STEP',5);
        hr_utility.raise_error;
      end if;
 --    end if;
     --
    hr_utility.set_location(l_proc,7);
    l_action_chk := hrempter.check_for_future_person_rows(p_person_id
                                     ,p_actual_termination_date);
    --
    if l_action_chk = 'Y' then
       hr_utility.set_message(801,'HR_7440_TERM_FUT_ROWS_EXST');
       hr_utility.raise_error;
    end if;
  --
     hr_utility.set_location(l_proc,10);
     SELECT current_employee_flag
     INTO   l_current_employee_flag
     FROM   per_people_f  pp
     WHERE  pp.person_id = p_person_id
     AND    p_actual_termination_date + 1
            BETWEEN pp.effective_start_date
            AND     pp.effective_end_date;
     --
     hr_utility.set_location(l_proc,15);
     if l_current_employee_flag = 'Y' then null;
     else hr_utility.set_message(801,'HR_6513_EMP_TERMINATED');
          hr_utility.raise_error;
     end if;
     --
     hr_utility.set_location(l_proc,20);
     -- VT 06/04/96 changed function call
     l_action_chk := hrempter.check_for_compl_actions(p_person_id
                                      ,p_actual_termination_date
                                      ,p_last_standard_process_date
                                      ,p_final_process_date);
     IF l_action_chk = 'W' THEN
       hr_utility.set_message(801,'HR_6516_EMP_TERM_ACTIONS_EXIST');
       hr_utility.set_warning;
     END IF;
     --
     if l_action_chk = 'Y' then
       hr_utility.set_message(801,'HR_6516_EMP_TERM_ACTIONS_EXIST');
       hr_utility.raise_error;
     end if;
     --
     -----------------------------------------------------------------
     -- If the FPD is not null then check that COBRA Benefits do not
     -- exist after the FPD
     --
     hr_utility.set_location(l_proc,23);
     if p_final_process_date IS NOT NULL then
    if hrempter.check_cobra_benefits
            (p_person_id
            ,p_final_process_date) then
       hr_utility.set_message(801,'HR_6968_EMP_COBRA_BENS_EXIST');
       hr_utility.raise_error;
        end if;
     end if;
     --
     hr_utility.set_location(l_proc,30);
     FOR c_emp_rec IN c_employee LOOP
     --
     if (c_emp_rec.effective_start_date <= p_actual_termination_date
         AND p_actual_termination_date <= c_emp_rec.effective_end_date) then
       hr_utility.set_location(l_proc,35);
       -- Bug 3735333 - Removed the suppression of business group index.
       --
       SELECT person_type_id
       ,      c_emp_rec.current_applicant_flag
       ,      null
       ,      c_emp_rec.current_applicant_flag
       INTO   l_person_type_id
       ,      l_current_applicant_flag
       ,      l_current_employee_flag
       ,      l_current_emp_or_apl_flag
       FROM   per_person_types
       WHERE  business_group_id  = p_business_group_id --#3735333
       AND    default_flag       = 'Y'
       AND    active_flag        = 'Y'
       AND  ((c_emp_rec.current_applicant_flag = 'Y'
         AND  system_person_type = 'EX_EMP_APL')
       OR    (c_emp_rec.current_applicant_flag IS NULL
         AND  system_person_type = 'EX_EMP'));
       --
       hr_utility.set_location(l_proc,40);
       INSERT INTO PER_ALL_PEOPLE_F
       (person_id
       ,effective_start_date
       ,effective_end_date
       ,business_group_id
       ,person_type_id
       ,last_name
       ,start_date
       ,applicant_number
       ,comment_id
       ,current_applicant_flag
       ,current_emp_or_apl_flag
       ,current_employee_flag
       ,date_employee_data_verified
       ,date_of_birth
       ,email_address
       ,employee_number
       ,expense_check_send_to_address
       ,first_name
       ,full_name
       ,known_as
       ,marital_status
       ,middle_names
       ,nationality
       ,national_identifier
       ,previous_last_name
       ,registered_disabled_flag
       ,sex
       ,title
       ,suffix
       ,vendor_id
--       ,work_telephone
       ,request_id
       ,program_application_id
       ,program_id
       ,program_update_date
       ,attribute_category
       ,attribute1
       ,attribute2
       ,attribute3
       ,attribute4
       ,attribute5
       ,attribute6
       ,attribute7
       ,attribute8
       ,attribute9
       ,attribute10
       ,attribute11
       ,attribute12
       ,attribute13
       ,attribute14
       ,attribute15
       ,attribute16
       ,attribute17
       ,attribute18
       ,attribute19
       ,attribute20
       ,attribute21
       ,attribute22
       ,attribute23
       ,attribute24
       ,attribute25
       ,attribute26
       ,attribute27
       ,attribute28
       ,attribute29
       ,attribute30
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date
       ,per_information_category
       ,per_information1
       ,per_information2
       ,per_information3
       ,per_information4
       ,per_information5
       ,per_information6
       ,per_information7
       ,per_information8
       ,per_information9
       ,per_information10
       ,per_information11
       ,per_information12
       ,per_information13
       ,per_information14
       ,per_information15
       ,per_information16
       ,per_information17
       ,per_information18
       ,per_information19
       ,per_information20
       ,per_information21
       ,per_information22
       ,per_information23
       ,per_information24
       ,per_information25
       ,per_information26
       ,per_information27
       ,per_information28
       ,per_information29
       ,per_information30
       ,work_schedule
       ,correspondence_language
       ,student_status
       ,fte_capacity
       ,on_military_service
       ,second_passport_exists
       ,background_check_status
       ,background_date_check
       ,blood_type
       ,last_medical_test_date
       ,last_medical_test_by
       ,rehire_recommendation
       ,rehire_reason
       ,resume_exists
       ,resume_last_updated
       ,office_number
       ,internal_location
       ,mailstop
       ,honors
       ,pre_name_adjunct
       ,hold_applicant_date_until
       ,benefit_group_id
       ,receipt_of_death_cert_date
       ,coord_ben_med_pln_no
       ,coord_ben_no_cvg_flag
       ,uses_tobacco_flag
       ,dpdnt_adoption_date
       ,dpdnt_vlntry_svce_flag
       ,date_of_death
       ,original_date_of_hire
       ,town_of_birth
      ,region_of_birth
      ,country_of_birth
      ,global_person_id
       )
       VALUES
       (      c_emp_rec.person_id
       ,      p_actual_termination_date + 1
       ,      c_emp_rec.effective_end_date
       ,      c_emp_rec.business_group_id
       ,      l_person_type_id
       ,      c_emp_rec.last_name
       ,      c_emp_rec.start_date
       ,      c_emp_rec.applicant_number
       ,      c_emp_rec.comment_id
       ,      l_current_applicant_flag
       ,      l_current_emp_or_apl_flag
       ,      l_current_employee_flag
       ,      c_emp_rec.date_employee_data_verified
       ,      c_emp_rec.date_of_birth
       ,      c_emp_rec.email_address
       ,      c_emp_rec.employee_number
       ,      c_emp_rec.expense_check_send_to_address
       ,      c_emp_rec.first_name
       ,      c_emp_rec.full_name
       ,      c_emp_rec.known_as
       ,      c_emp_rec.marital_status
       ,      c_emp_rec.middle_names
       ,      c_emp_rec.nationality
       ,      c_emp_rec.national_identifier
       ,      c_emp_rec.previous_last_name
       ,      c_emp_rec.registered_disabled_flag
       ,      c_emp_rec.sex
       ,      c_emp_rec.title
       ,      c_emp_rec.suffix
       ,      c_emp_rec.vendor_id
--       ,      c_emp_rec.work_telephone
       ,      c_emp_rec.request_id
       ,      c_emp_rec.program_application_id
       ,      c_emp_rec.program_id
       ,      c_emp_rec.program_update_date
       ,      c_emp_rec.attribute_category
       ,      c_emp_rec.attribute1
       ,      c_emp_rec.attribute2
       ,      c_emp_rec.attribute3
       ,      c_emp_rec.attribute4
       ,      c_emp_rec.attribute5
       ,      c_emp_rec.attribute6
       ,      c_emp_rec.attribute7
       ,      c_emp_rec.attribute8
       ,      c_emp_rec.attribute9
       ,      c_emp_rec.attribute10
       ,      c_emp_rec.attribute11
       ,      c_emp_rec.attribute12
       ,      c_emp_rec.attribute13
       ,      c_emp_rec.attribute14
       ,      c_emp_rec.attribute15
       ,      c_emp_rec.attribute16
       ,      c_emp_rec.attribute17
       ,      c_emp_rec.attribute18
       ,      c_emp_rec.attribute19
       ,      c_emp_rec.attribute20
       ,      c_emp_rec.attribute21
       ,      c_emp_rec.attribute22
       ,      c_emp_rec.attribute23
       ,      c_emp_rec.attribute24
       ,      c_emp_rec.attribute25
       ,      c_emp_rec.attribute26
       ,      c_emp_rec.attribute27
       ,      c_emp_rec.attribute28
       ,      c_emp_rec.attribute29
       ,      c_emp_rec.attribute30
       ,      SYSDATE
       ,      -1
       ,      -1
       ,      c_emp_rec.created_by
       ,      c_emp_rec.creation_date
       ,      c_emp_rec.per_information_category
       ,      c_emp_rec.per_information1
       ,      c_emp_rec.per_information2
       ,      c_emp_rec.per_information3
       ,      c_emp_rec.per_information4
       ,      c_emp_rec.per_information5
       ,      c_emp_rec.per_information6
       ,      c_emp_rec.per_information7
       ,      c_emp_rec.per_information8
       ,      c_emp_rec.per_information9
       ,      c_emp_rec.per_information10
       ,      c_emp_rec.per_information11
       ,      c_emp_rec.per_information12
       ,      c_emp_rec.per_information13
       ,      c_emp_rec.per_information14
       ,      c_emp_rec.per_information15
       ,      c_emp_rec.per_information16
       ,      c_emp_rec.per_information17
       ,      c_emp_rec.per_information18
       ,      c_emp_rec.per_information19
       ,      c_emp_rec.per_information20
       ,      c_emp_rec.per_information21
       ,      c_emp_rec.per_information22
       ,      c_emp_rec.per_information23
       ,      c_emp_rec.per_information24
       ,      c_emp_rec.per_information25
       ,      c_emp_rec.per_information26
       ,      c_emp_rec.per_information27
       ,      c_emp_rec.per_information28
       ,      c_emp_rec.per_information29
       ,      c_emp_rec.per_information30
       ,      c_emp_rec.work_schedule
       ,      c_emp_rec.correspondence_language
       ,      c_emp_rec.student_status
       ,      c_emp_rec.fte_capacity
       ,      c_emp_rec.on_military_service
       ,      c_emp_rec.second_passport_exists
       ,      c_emp_rec.background_check_status
       ,      c_emp_rec.background_date_check
       ,      c_emp_rec.blood_type
       ,      c_emp_rec.last_medical_test_date
       ,      c_emp_rec.last_medical_test_by
       ,      c_emp_rec.rehire_recommendation
       ,      c_emp_rec.rehire_reason
       ,      c_emp_rec.resume_exists
       ,      c_emp_rec.resume_last_updated
       ,      c_emp_rec.office_number
       ,      c_emp_rec.internal_location
       ,      c_emp_rec.mailstop
       ,      c_emp_rec.honors
       ,      c_emp_rec.pre_name_adjunct
       ,      c_emp_rec.hold_applicant_date_until
       ,      c_emp_rec.benefit_group_id
       ,      c_emp_rec.receipt_of_death_cert_date
       ,      c_emp_rec.coord_ben_med_pln_no
       ,      c_emp_rec.coord_ben_no_cvg_flag
       ,      c_emp_rec.uses_tobacco_flag
       ,      c_emp_rec.dpdnt_adoption_date
       ,      c_emp_rec.dpdnt_vlntry_svce_flag
       ,      c_emp_rec.date_of_death
       ,      c_emp_rec.original_date_of_hire
       ,      c_emp_rec.town_of_birth
      ,      c_emp_rec.region_of_birth
      ,      c_emp_rec.country_of_birth
      ,      c_emp_rec.global_person_id
       );
       --
       hr_utility.set_location(l_proc,45);
       UPDATE per_people_f pp
       SET    pp.effective_end_date = p_actual_termination_date
       WHERE CURRENT OF c_employee;
       --
      end if;
    --
    END LOOP;
  --
  elsif p_trigger = 'POST_UPDATE' then
  --
    --
    hr_utility.set_location(l_proc,50);
    FOR  c_ass_rec IN c_assignment LOOP
    --
      hr_utility.set_location(l_proc,55);
      l_max_end_date := hrempter.get_max_end_date(c_ass_rec.assignment_id);
      --
      hr_utility.set_location(l_proc,60);
      FPD_FLAG := (p_final_process_date IS NOT NULL AND
                   p_final_process_date < l_max_end_date);
      --
      hr_utility.set_location(l_proc,65);
      SELECT per_system_status
      INTO   l_per_system_status
      FROM   per_assignment_status_types
      WHERE  assignment_status_type_id = c_ass_rec.assignment_status_type_id;
      --
      hr_utility.set_location(l_proc,70);
      TA_FLAG := (l_per_system_status = 'TERM_ASSIGN' AND
                  c_ass_rec.effective_start_date < p_actual_termination_date);
      --
      if NOT TA_FLAG then
        hr_utility.set_location(l_proc,75);
        hrempter.delete_assign_atd(c_ass_rec.assignment_id
                                  ,p_actual_termination_date);
      end if;
      --
      if FPD_FLAG then
        hr_utility.set_location(l_proc,80);
        hrempter.delete_assign_fpd(c_ass_rec.assignment_id
                                  ,p_final_process_date);
      end if;
      --
      hr_utility.set_location(l_proc,85);
    --
    -- Added for US legsilation specific code.
    -- Legislation code will change valid values
    -- checking for the termination.
    --
    -- VT 10/07/96 bug #306710 new parameter
      l_ent_loop := 'N';
      hrempter.terminate_entries_and_alus(c_ass_rec.assignment_id
                                ,p_actual_termination_date
                                ,p_last_standard_process_date
                                ,p_final_process_date
                                ,l_legislation_code
                                ,l_ent_loop);
      if l_ent_loop = 'S' then
        l_entries_changed := 'S';
      end if;
      if l_ent_loop = 'Y' and l_entries_changed = 'N' then
        l_entries_changed := 'Y';
      end if;
      --
      -- Fix for bug: 969491
      -- When the employee is terminated the tax records tables have to
      -- updated to reflect the final process date. This is done when the
      -- termination process has a FINAL PROCESS DATE.
      -- Adding an extra verification to make sure the tax records are reverse
      -- only for US legislation or Ceridian Customers. This extra
      -- verification is done because this package peempter.pkb is part of
      -- the CORE HR code and UK customers do not use these TAX tables.
      -- fix for bug: 1348553 et al.
      -- we always call the terminate_tax_records proc since we need to erase
      -- future changes if the termination date is set w/o a final process date.
      --
      if hr_general.chk_geocodes_installed = 'Y' then
           pay_us_update_tax_rec_pkg.terminate_emp_tax_records
                                     (c_ass_rec.assignment_id
                                     ,p_final_process_date
                                 ,p_actual_termination_date);
      end if; /* Check if geocodes is installed */
      --
      hr_utility.set_location(l_proc,1000);
      if (FPD_FLAG AND TA_FLAG) OR
         (p_actual_termination_date = p_final_process_date) then
        --
        hr_utility.set_location(l_proc,90);
        hrempter.delete_de_assign(c_ass_rec.assignment_id
                                 ,p_final_process_date);
        --
        hr_utility.set_location(l_proc,95);
        UPDATE per_assignments_f
        SET    effective_end_date = p_final_process_date
        WHERE CURRENT OF c_assignment;
        --
      hr_utility.set_location(l_proc,1200);
      elsif NOT TA_FLAG then
        hr_utility.set_location(l_proc,95);
          if FPD_FLAG then
            l_effective_end_date := p_final_process_date;
          else
            l_effective_end_date := l_max_end_date;
          end if;
          --
          hr_utility.set_location(l_proc,100);
          hrempter.delete_de_assign(c_ass_rec.assignment_id
                                   ,p_actual_termination_date);
          --
          hr_utility.set_location(l_proc,105);
      --
      -- #270356. There was a possible problem here, if the user passes
      -- a null assignment status type, and a final process date which is
      -- is later than the actual termination date. Under these
      -- circumstances, the following insert is needed to create a new
      -- Terminated Assignment record, and fails because
      -- ASSIGNMENT_STATUS_TYPE_ID is mandatory. Fix is to get the default
      -- TERM_ASSIGN status immediately before the insert, if one hasn't
      -- already been passed in. The code looks for the default status in
      -- both the per_assignment_status_types table and the
      -- per_ass_status_type_amends table.
      --
      if p_assignment_status_type_id is null then
        select stt.assignment_status_type_id
        into   l_assignment_status_type_id
        from   per_assignment_status_types stt,
           per_ass_status_type_amends sta
        where  nvl(sta.per_system_status,stt.per_system_status) =
                            'TERM_ASSIGN'
        and       stt.assignment_status_type_id =
                    sta.assignment_status_type_id (+)
        and       sta.business_group_id(+) = c_ass_rec.BUSINESS_GROUP_ID
        and    nvl(stt.business_group_id, c_ass_rec.BUSINESS_GROUP_ID) =
                        c_ass_rec.BUSINESS_GROUP_ID
        and    nvl(sta.active_flag,stt.active_flag) = 'Y'
        and    nvl(sta.default_flag, stt.default_flag) = 'Y';
      end if;
      --
          hr_utility.set_location(l_proc,108);
          -- VT 04/12/96 bug #354874 added EMPLOYMENT_CATEGORY processing
          INSERT INTO per_assignments_f
           ( ASSIGNMENT_ID
           , EFFECTIVE_START_DATE
           , EFFECTIVE_END_DATE
           , BUSINESS_GROUP_ID
           , RECRUITER_ID
           , GRADE_ID
           , POSITION_ID
           , JOB_ID
           , ASSIGNMENT_STATUS_TYPE_ID
           , PAYROLL_ID
           , LOCATION_ID
           , SUPERVISOR_ID
           , SPECIAL_CEILING_STEP_ID
           , PERSON_ID
           , ORGANIZATION_ID
           , PEOPLE_GROUP_ID
           , SOFT_CODING_KEYFLEX_ID
           , VACANCY_ID
           , ASSIGNMENT_SEQUENCE
           , ASSIGNMENT_TYPE
           , PRIMARY_FLAG
           , APPLICATION_ID
           , ASSIGNMENT_NUMBER
           , CHANGE_REASON
           , COMMENT_ID
           , DATE_PROBATION_END
           , DEFAULT_CODE_COMB_ID
           , EMPLOYMENT_CATEGORY
           , FREQUENCY
           , INTERNAL_ADDRESS_LINE
           , MANAGER_FLAG
           , NORMAL_HOURS
           , PERIOD_OF_SERVICE_ID
           , PROBATION_PERIOD
           , PROBATION_UNIT
           , SET_OF_BOOKS_ID
           , TIME_NORMAL_FINISH
           , TIME_NORMAL_START
           , PAY_BASIS_ID
           , REQUEST_ID
           , BARGAINING_UNIT_CODE
           , LABOUR_UNION_MEMBER_FLAG
           , HOURLY_SALARIED_CODE
           , PROGRAM_APPLICATION_ID
           , PROGRAM_ID
           , PROGRAM_UPDATE_DATE
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , CREATED_BY
           , CREATION_DATE
           , ASS_ATTRIBUTE_CATEGORY
           , ASS_ATTRIBUTE1
           , ASS_ATTRIBUTE2
           , ASS_ATTRIBUTE3
           , ASS_ATTRIBUTE4
           , ASS_ATTRIBUTE5
           , ASS_ATTRIBUTE6
           , ASS_ATTRIBUTE7
           , ASS_ATTRIBUTE8
           , ASS_ATTRIBUTE9
           , ASS_ATTRIBUTE10
           , ASS_ATTRIBUTE11
           , ASS_ATTRIBUTE12
           , ASS_ATTRIBUTE13
           , ASS_ATTRIBUTE14
           , ASS_ATTRIBUTE15
           , ASS_ATTRIBUTE16
           , ASS_ATTRIBUTE17
           , ASS_ATTRIBUTE18
           , ASS_ATTRIBUTE19
           , ASS_ATTRIBUTE20
           , ASS_ATTRIBUTE21
           , ASS_ATTRIBUTE22
           , ASS_ATTRIBUTE23
           , ASS_ATTRIBUTE24
           , ASS_ATTRIBUTE25
           , ASS_ATTRIBUTE26
           , ASS_ATTRIBUTE27
           , ASS_ATTRIBUTE28
           , ASS_ATTRIBUTE29
           , ASS_ATTRIBUTE30
           , CAGR_GRADE_DEF_ID
           , CAGR_ID_FLEX_NUM
           , COLLECTIVE_AGREEMENT_ID
           , CONTRACT_ID
           , ESTABLISHMENT_ID
           , OBJECT_VERSION_NUMBER
           , PERF_REVIEW_PERIOD
           , PERF_REVIEW_PERIOD_FREQUENCY
           , PERSON_REFERRED_BY_ID
           , RECRUITMENT_ACTIVITY_ID
           , SAL_REVIEW_PERIOD
           , SAL_REVIEW_PERIOD_FREQUENCY
           , SOURCE_ORGANIZATION_ID
           , SOURCE_TYPE
           , TITLE
      , NOTICE_PERIOD
           , NOTICE_PERIOD_UOM
           , WORK_AT_HOME
           , EMPLOYEE_CATEGORY
           , JOB_POST_SOURCE_NAME )
          VALUES
           ( c_ass_rec.ASSIGNMENT_ID
           , p_actual_termination_date + 1
           , l_effective_end_date
           , c_ass_rec.BUSINESS_GROUP_ID
           , c_ass_rec.RECRUITER_ID
           , c_ass_rec.GRADE_ID
           , c_ass_rec.POSITION_ID
           , c_ass_rec.JOB_ID
           , nvl (p_assignment_status_type_id, l_assignment_status_type_id)
           , c_ass_rec.PAYROLL_ID
           , c_ass_rec.LOCATION_ID
           , c_ass_rec.SUPERVISOR_ID
           , c_ass_rec.SPECIAL_CEILING_STEP_ID
           , c_ass_rec.PERSON_ID
           , c_ass_rec.ORGANIZATION_ID
           , c_ass_rec.PEOPLE_GROUP_ID
           , c_ass_rec.SOFT_CODING_KEYFLEX_ID
           , c_ass_rec.VACANCY_ID
           , c_ass_rec.ASSIGNMENT_SEQUENCE
           , c_ass_rec.ASSIGNMENT_TYPE
           , c_ass_rec.PRIMARY_FLAG
           , c_ass_rec.APPLICATION_ID
           , c_ass_rec.ASSIGNMENT_NUMBER
           , c_ass_rec.CHANGE_REASON
           , c_ass_rec.COMMENT_ID
           , c_ass_rec.DATE_PROBATION_END
           , c_ass_rec.DEFAULT_CODE_COMB_ID
           , c_ass_rec.EMPLOYMENT_CATEGORY
           , c_ass_rec.FREQUENCY
           , c_ass_rec.INTERNAL_ADDRESS_LINE
           , c_ass_rec.MANAGER_FLAG
           , c_ass_rec.NORMAL_HOURS
           , c_ass_rec.PERIOD_OF_SERVICE_ID
           , c_ass_rec.PROBATION_PERIOD
           , c_ass_rec.PROBATION_UNIT
           , c_ass_rec.SET_OF_BOOKS_ID
           , c_ass_rec.TIME_NORMAL_FINISH
           , c_ass_rec.TIME_NORMAL_START
           , c_ass_rec.PAY_BASIS_ID
           , c_ass_rec.REQUEST_ID
           , c_ass_rec.BARGAINING_UNIT_CODE
           , c_ass_rec.LABOUR_UNION_MEMBER_FLAG
           , c_ass_rec.HOURLY_SALARIED_CODE
           , c_ass_rec.PROGRAM_APPLICATION_ID
           , c_ass_rec.PROGRAM_ID
           , c_ass_rec.PROGRAM_UPDATE_DATE
           , SYSDATE
           , -1
           , -1
           , c_ass_rec.CREATED_BY
           , c_ass_rec.CREATION_DATE
           , c_ass_rec.ASS_ATTRIBUTE_CATEGORY
           , c_ass_rec.ASS_ATTRIBUTE1
           , c_ass_rec.ASS_ATTRIBUTE2
           , c_ass_rec.ASS_ATTRIBUTE3
           , c_ass_rec.ASS_ATTRIBUTE4
           , c_ass_rec.ASS_ATTRIBUTE5
           , c_ass_rec.ASS_ATTRIBUTE6
           , c_ass_rec.ASS_ATTRIBUTE7
           , c_ass_rec.ASS_ATTRIBUTE8
           , c_ass_rec.ASS_ATTRIBUTE9
           , c_ass_rec.ASS_ATTRIBUTE10
           , c_ass_rec.ASS_ATTRIBUTE11
           , c_ass_rec.ASS_ATTRIBUTE12
           , c_ass_rec.ASS_ATTRIBUTE13
           , c_ass_rec.ASS_ATTRIBUTE14
           , c_ass_rec.ASS_ATTRIBUTE15
           , c_ass_rec.ASS_ATTRIBUTE16
           , c_ass_rec.ASS_ATTRIBUTE17
           , c_ass_rec.ASS_ATTRIBUTE18
           , c_ass_rec.ASS_ATTRIBUTE19
           , c_ass_rec.ASS_ATTRIBUTE20
           , c_ass_rec.ASS_ATTRIBUTE21
           , c_ass_rec.ASS_ATTRIBUTE22
           , c_ass_rec.ASS_ATTRIBUTE23
           , c_ass_rec.ASS_ATTRIBUTE24
           , c_ass_rec.ASS_ATTRIBUTE25
           , c_ass_rec.ASS_ATTRIBUTE26
           , c_ass_rec.ASS_ATTRIBUTE27
           , c_ass_rec.ASS_ATTRIBUTE28
           , c_ass_rec.ASS_ATTRIBUTE29
           , c_ass_rec.ASS_ATTRIBUTE30
           , c_ass_rec.CAGR_GRADE_DEF_ID
           , c_ass_rec.CAGR_ID_FLEX_NUM
           , c_ass_rec.COLLECTIVE_AGREEMENT_ID
           , c_ass_rec.CONTRACT_ID
           , c_ass_rec.ESTABLISHMENT_ID
           , c_ass_rec.OBJECT_VERSION_NUMBER
           , c_ass_rec.PERF_REVIEW_PERIOD
           , c_ass_rec.PERF_REVIEW_PERIOD_FREQUENCY
           , c_ass_rec.PERSON_REFERRED_BY_ID
           , c_ass_rec.RECRUITMENT_ACTIVITY_ID
           , c_ass_rec.SAL_REVIEW_PERIOD
           , c_ass_rec.SAL_REVIEW_PERIOD_FREQUENCY
           , c_ass_rec.SOURCE_ORGANIZATION_ID
           , c_ass_rec.SOURCE_TYPE
           , c_ass_rec.TITLE
           , c_ass_rec.NOTICE_PERIOD
           , c_ass_rec.NOTICE_PERIOD_UOM
           , c_ass_rec.WORK_AT_HOME
           , c_ass_rec.EMPLOYEE_CATEGORY
           , c_ass_rec.JOB_POST_SOURCE_NAME);
          --
          hr_utility.set_location(l_proc,110);
            UPDATE per_assignments_f ass
            SET    ass.effective_end_date = p_actual_termination_date
            WHERE CURRENT OF c_assignment;
          --
        end if;
      --
      hr_utility.set_location(l_proc,1300);
      if NOT TA_FLAG then
        hr_utility.set_location(l_proc,115);
        hrempter.delete_employee_atd(p_person_id
                                    ,p_actual_termination_date);
      end if;
    --
    END LOOP;
  -- VT 10/14/96 bug #306710
  IF l_entries_changed IN ('S','Y') THEN
    IF l_entries_changed = 'S' THEN
      hr_utility.set_warning;
      fnd_message.set_name('PAY','HR_7442_ASS_SAL_ENT_CHANGED');
    END IF;
    IF l_entries_changed = 'Y' THEN
      hr_utility.set_warning;
      fnd_message.set_name('PAY','HR_7016_ASS_ENTRIES_CHANGED');
    END IF;
  END IF;
  --
  --
  else hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','TERMINATE_EMPLOYEE');
       hr_utility.set_message_token('STEP',1);
       hr_utility.raise_error;
  --
  end if;
  --
  end terminate_employee;
--
--
-- ====================== employee_shutdown ==========================
--
--
  PROCEDURE employee_shutdown(p_trigger            VARCHAR2
                             ,p_person_id          NUMBER
                             ,p_final_process_date DATE)
  IS
  --
  l_current_employee_flag VARCHAR2(30);
  l_max_end_date          DATE;
  l_actual_termination_date  DATE;
  l_action_chk            VARCHAR2(1) := 'N';
  l_last_standard_process_date DATE := NULL;
  --
  l_entries_changed VARCHAR2(1) := 'N';
  l_ent_loop VARCHAR2(1) := 'N';
  --
  CURSOR c_assignment IS
  SELECT ass.assignment_id
  FROM   per_assignments_f ass
  WHERE  ass.person_id = p_person_id
  AND    p_final_process_date
         BETWEEN ass.effective_start_date
         AND     ass.effective_end_date
  FOR UPDATE;
  --
  l_proc varchar2(72):=g_package||'employee_shutdown';
  begin
  hr_utility.trace('Entered employee_shutdown for '||p_person_id);
  --
  hr_utility.set_location(l_proc,1);
  if p_trigger = 'PRE_UPDATE' then
  --
  hr_utility.set_location(l_proc,2);
  SELECT actual_termination_date
  INTO   l_actual_termination_date
  FROM   per_periods_of_service
  WHERE  person_id = p_person_id
  AND    final_process_date IS NULL
  AND    p_final_process_date BETWEEN date_start
                              AND     to_date('31/12/4712','DD/MM/YYYY');
  --
  hr_utility.set_location(l_proc,3);
    SELECT current_employee_flag
    INTO   l_current_employee_flag
    FROM   per_people_f  pp
    WHERE  pp.person_id = p_person_id
    AND  ((p_final_process_date = l_actual_termination_date
       AND p_final_process_date + 1 BETWEEN pp.effective_start_date
                                    AND     pp.effective_end_date)
       OR (p_final_process_date > l_actual_termination_date
    AND    p_final_process_date
           BETWEEN pp.effective_start_date
           AND     pp.effective_end_date));
    --
    if l_current_employee_flag = 'Y' then
      hr_utility.set_message(801,'HR_6514_EMP_NOT_TERMINATED');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,5);
    -- VT 06/04/96 changed function call
    l_action_chk := hrempter.check_for_compl_actions(p_person_id
                                     ,l_actual_termination_date
                                     ,l_last_standard_process_date
                                     ,p_final_process_date);
    --
    IF l_action_chk = 'W' THEN
      hr_utility.set_message(801,'HR_6517_EMP_FPD_ACTIONS_EXIST');
       hr_utility.set_warning;
    END IF;
    --
    if l_action_chk = 'Y' then
       hr_utility.set_message(801,'HR_6517_EMP_FPD_ACTIONS_EXIST');
       hr_utility.raise_error;
    end if;
  --
    -----------------------------------------------------------------
    -- If the FPD is not null then check that COBRA Benefits do not
    -- exist after the FPD
    --
    hr_utility.set_location(l_proc,7);
    if hrempter.check_cobra_benefits
        (p_person_id
        ,p_final_process_date) then
       hr_utility.set_message(801,'HR_6968_EMP_COBRA_BENS_EXIST');
       hr_utility.raise_error;
    end if;
     --
  elsif p_trigger = 'POST_UPDATE' then
  --
    --
    hr_utility.set_location(l_proc,15);
    FOR c_ass_rec IN c_assignment LOOP
    --
      hr_utility.set_location(l_proc,20);
      l_max_end_date := hrempter.get_max_end_date(c_ass_rec.assignment_id);
      --
      if p_final_process_date < l_max_end_date then
        hr_utility.set_location(l_proc,25);
        hrempter.delete_assign_fpd(c_ass_rec.assignment_id
                                  ,p_final_process_date);
        --
        hr_utility.set_location(l_proc,30);
        -- VT 10/07/96 bug #306710 new parameter
        l_ent_loop := 'N';
        hrempter.terminate_entries_and_alus(c_ass_rec.assignment_id
                                  ,null
                                  ,null
                                  ,p_final_process_date
                                  ,null
                                  ,l_ent_loop);
        if l_ent_loop = 'S' then
          l_entries_changed := 'S';
        end if;
        if l_ent_loop = 'Y' and l_entries_changed = 'N' then
          l_entries_changed := 'Y';
        end if;
        --
        hr_utility.set_location(l_proc,35);
        hrempter.delete_de_assign(c_ass_rec.assignment_id
                                 ,p_final_process_date);
        --
        hr_utility.set_location(l_proc,40);
        UPDATE per_assignments_f  ass
        SET    ass.effective_end_date = p_final_process_date
        WHERE CURRENT OF c_assignment;
      end if;
    --
      -- bug 1348553 - if you set the atd, and later set the fpd, we need to
      -- terminate the tax records
      if hr_general.chk_geocodes_installed = 'Y' then
           pay_us_update_tax_rec_pkg.terminate_emp_tax_records
                                     (c_ass_rec.assignment_id
                                     ,p_final_process_date);
      end if; /* Check if geocodes is installed */
    END LOOP;
    -- VT 10/14/96 bug #306710
    IF l_entries_changed IN ('S','Y') THEN
      IF l_entries_changed = 'S' THEN
        hr_utility.set_warning;
        fnd_message.set_name('PAY','HR_7442_ASS_SAL_ENT_CHANGED');
      END IF;
      IF l_entries_changed = 'Y' THEN
        hr_utility.set_warning;
        fnd_message.set_name('PAY','HR_7016_ASS_ENTRIES_CHANGED');
      END IF;
    END IF;
    --
  --
  else hr_utility.set_location(l_proc,1);
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','EMPLOYEE_SHUTDOWN');
       hr_utility.set_message_token('STEP',1);
       hr_utility.raise_error;
  --
  end if;
  --
  end employee_shutdown;
--
-- ======================== Compare_assignments ========================
--
  FUNCTION compareAssignments(p_assignment_id1   NUMBER,
                              p_effective_date1   DATE,
               p_assignment_id2    NUMBER,
               p_effective_date2   DATE)
  return BOOLEAN IS

  cursor c_full_assignment(c_assignment_id number,
                           c_effective_date date) is
     select *
       from per_all_assignments_f
      where assignment_id = c_assignment_id
        and c_effective_date between effective_start_date
                            and effective_end_date;

     l_asg1 c_full_assignment%rowtype;
     l_asg2 c_full_assignment%rowtype;

     l_return boolean := FALSE;

     l_proc varchar2(90) := g_package||'compareAssignment';

  begin

   hr_utility.set_location('Entering : '||l_proc,10);

   open c_full_assignment(p_assignment_id1, p_effective_date1);
   fetch c_full_assignment into l_asg1;
   close c_full_assignment;

   open c_full_assignment(p_assignment_id2, p_effective_date2);
   fetch c_full_assignment into l_asg2;
   close c_full_assignment;

   if (    nvl(l_asg1.RECRUITER_ID,hr_api.g_number)
                             = nvl(l_asg2.RECRUITER_ID,hr_api.g_number)
       and nvl(l_asg1.GRADE_ID,hr_api.g_number)
                             = nvl(l_asg2.GRADE_ID,hr_api.g_number)
       and nvl(l_asg1.POSITION_ID,hr_api.g_number)
                             = nvl(l_asg2.POSITION_ID,hr_api.g_number)
       and nvl(l_asg1.JOB_ID,hr_api.g_number)
                             = nvl(l_asg2.JOB_ID,hr_api.g_number)
       and nvl(l_asg1.ASSIGNMENT_STATUS_TYPE_ID,hr_api.g_number)
                             = nvl(l_asg2.ASSIGNMENT_STATUS_TYPE_ID,hr_api.g_number)
       and nvl(l_asg1.PAYROLL_ID,hr_api.g_number)
                             = nvl(l_asg2.PAYROLL_ID,hr_api.g_number)
       and nvl(l_asg1.LOCATION_ID,hr_api.g_number)
                             = nvl(l_asg2.LOCATION_ID,hr_api.g_number)
       and nvl(l_asg1.PERSON_REFERRED_BY_ID,hr_api.g_number)
                             = nvl(l_asg2.PERSON_REFERRED_BY_ID,hr_api.g_number)
       and nvl(l_asg1.SUPERVISOR_ID,hr_api.g_number)
                             = nvl(l_asg2.SUPERVISOR_ID,hr_api.g_number)
       and nvl(l_asg1.SPECIAL_CEILING_STEP_ID,hr_api.g_number)
                             = nvl(l_asg2.SPECIAL_CEILING_STEP_ID,hr_api.g_number)
       and nvl(l_asg1.PERSON_ID,hr_api.g_number)
                             = nvl(l_asg2.PERSON_ID,hr_api.g_number)
       and nvl(l_asg1.RECRUITMENT_ACTIVITY_ID,hr_api.g_number)
                             = nvl(l_asg2.RECRUITMENT_ACTIVITY_ID,hr_api.g_number)
       and nvl(l_asg1.SOURCE_ORGANIZATION_ID,hr_api.g_number)
                             = nvl(l_asg2.SOURCE_ORGANIZATION_ID,hr_api.g_number)
       and nvl(l_asg1.ORGANIZATION_ID,hr_api.g_number)
                             = nvl(l_asg2.ORGANIZATION_ID,hr_api.g_number)
       and nvl(l_asg1.PEOPLE_GROUP_ID,hr_api.g_number)
                             = nvl(l_asg2.PEOPLE_GROUP_ID,hr_api.g_number)
       and nvl(l_asg1.SOFT_CODING_KEYFLEX_ID,hr_api.g_number)
                             = nvl(l_asg2.SOFT_CODING_KEYFLEX_ID,hr_api.g_number)
       and nvl(l_asg1.VACANCY_ID,hr_api.g_number)
                             = nvl(l_asg2.VACANCY_ID,hr_api.g_number)
       and nvl(l_asg1.PAY_BASIS_ID,hr_api.g_number)
                             = nvl(l_asg2.PAY_BASIS_ID,hr_api.g_number)
       and nvl(l_asg1.ASSIGNMENT_SEQUENCE,hr_api.g_number)
                             = nvl(l_asg2.ASSIGNMENT_SEQUENCE,hr_api.g_number)
       and nvl(l_asg1.ASSIGNMENT_TYPE, hr_api.g_varchar2)
                             = nvl(l_asg2.ASSIGNMENT_TYPE, hr_api.g_varchar2)
       and nvl(l_asg1.PRIMARY_FLAG, hr_api.g_varchar2)
                             = nvl(l_asg2.PRIMARY_FLAG, hr_api.g_varchar2)
       and nvl(l_asg1.APPLICATION_ID,hr_api.g_number)
                             = nvl(l_asg2.APPLICATION_ID,hr_api.g_number)
       and nvl(l_asg1.ASSIGNMENT_NUMBER,hr_api.g_number)
                             = nvl(l_asg2.ASSIGNMENT_NUMBER,hr_api.g_number)
       and nvl(l_asg1.CHANGE_REASON, hr_api.g_varchar2)
                             = nvl(l_asg2.CHANGE_REASON, hr_api.g_varchar2)
       and nvl(l_asg1.COMMENT_ID,hr_api.g_number)
                             = nvl(l_asg2.COMMENT_ID,hr_api.g_number)
       and nvl(l_asg1.DATE_PROBATION_END, hr_api.g_date)
                             = nvl(l_asg2.DATE_PROBATION_END, hr_api.g_date)
       and nvl(l_asg1.DEFAULT_CODE_COMB_ID,hr_api.g_number)
                             = nvl(l_asg2.DEFAULT_CODE_COMB_ID,hr_api.g_number)
       and nvl(l_asg1.EMPLOYMENT_CATEGORY, hr_api.g_varchar2)
                             = nvl(l_asg2.EMPLOYMENT_CATEGORY, hr_api.g_varchar2)
       and nvl(l_asg1.FREQUENCY, hr_api.g_varchar2)
                             = nvl(l_asg2.FREQUENCY, hr_api.g_varchar2)
       and nvl(l_asg1.INTERNAL_ADDRESS_LINE, hr_api.g_varchar2)
                             = nvl(l_asg2.INTERNAL_ADDRESS_LINE, hr_api.g_varchar2)
       and nvl(l_asg1.MANAGER_FLAG, hr_api.g_varchar2)
                             = nvl(l_asg2.MANAGER_FLAG, hr_api.g_varchar2)
       and nvl(l_asg1.NORMAL_HOURS,hr_api.g_number)
                             = nvl(l_asg2.NORMAL_HOURS,hr_api.g_number)
       and nvl(l_asg1.PERF_REVIEW_PERIOD,hr_api.g_number)
                             = nvl(l_asg2.PERF_REVIEW_PERIOD,hr_api.g_number)
       and nvl(l_asg1.PERF_REVIEW_PERIOD_FREQUENCY, hr_api.g_varchar2)
                             = nvl(l_asg2.PERF_REVIEW_PERIOD_FREQUENCY, hr_api.g_varchar2)
       and nvl(l_asg1.PERIOD_OF_SERVICE_ID,hr_api.g_number)
                             = nvl(l_asg2.PERIOD_OF_SERVICE_ID,hr_api.g_number)
       and nvl(l_asg1.PROBATION_PERIOD,hr_api.g_number)
                             = nvl(l_asg2.PROBATION_PERIOD,hr_api.g_number)
       and nvl(l_asg1.PROBATION_UNIT, hr_api.g_varchar2)
                             = nvl(l_asg2.PROBATION_UNIT, hr_api.g_varchar2)
       and nvl(l_asg1.SAL_REVIEW_PERIOD,hr_api.g_number)
                             = nvl(l_asg2.SAL_REVIEW_PERIOD,hr_api.g_number)
       and nvl(l_asg1.SAL_REVIEW_PERIOD_FREQUENCY, hr_api.g_varchar2)
                             = nvl(l_asg2.SAL_REVIEW_PERIOD_FREQUENCY, hr_api.g_varchar2)
       and nvl(l_asg1.SET_OF_BOOKS_ID,hr_api.g_number)
                             = nvl(l_asg2.SET_OF_BOOKS_ID,hr_api.g_number)
       and nvl(l_asg1.SOURCE_TYPE, hr_api.g_varchar2)
                             = nvl(l_asg2.SOURCE_TYPE, hr_api.g_varchar2)
       and nvl(l_asg1.TIME_NORMAL_FINISH, hr_api.g_varchar2)
                             = nvl(l_asg2.TIME_NORMAL_FINISH, hr_api.g_varchar2)
       and nvl(l_asg1.TIME_NORMAL_START, hr_api.g_varchar2)
                             = nvl(l_asg2.TIME_NORMAL_START, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE_CATEGORY, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE_CATEGORY, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE1, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE1, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE2, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE2, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE3, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE3, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE4, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE4, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE5, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE5, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE6, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE6, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE7, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE7, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE8, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE8, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE9, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE9, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE10, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE10, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE11, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE11, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE12, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE12, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE13, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE13, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE14, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE14, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE15, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE15, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE16, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE16, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE17, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE17, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE18, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE18, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE19, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE19, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE20, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE20, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE21, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE21, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE22, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE22, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE23, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE23, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE24, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE24, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE25, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE25, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE26, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE26, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE27, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE27, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE28, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE28, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE29, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE29, hr_api.g_varchar2)
       and nvl(l_asg1.ASS_ATTRIBUTE30, hr_api.g_varchar2)
                             = nvl(l_asg2.ASS_ATTRIBUTE30, hr_api.g_varchar2)
       and nvl(l_asg1.TITLE, hr_api.g_varchar2)
                             = nvl(l_asg2.TITLE, hr_api.g_varchar2)
       and nvl(l_asg1.BARGAINING_UNIT_CODE, hr_api.g_varchar2)
                             = nvl(l_asg2.BARGAINING_UNIT_CODE, hr_api.g_varchar2)
       and nvl(l_asg1.LABOUR_UNION_MEMBER_FLAG, hr_api.g_varchar2)
                             = nvl(l_asg2.LABOUR_UNION_MEMBER_FLAG, hr_api.g_varchar2)
       and nvl(l_asg1.HOURLY_SALARIED_CODE, hr_api.g_varchar2)
                             = nvl(l_asg2.HOURLY_SALARIED_CODE, hr_api.g_varchar2)
       and nvl(l_asg1.CONTRACT_ID,hr_api.g_number)
                             = nvl(l_asg2.CONTRACT_ID,hr_api.g_number)
       and nvl(l_asg1.COLLECTIVE_AGREEMENT_ID,hr_api.g_number)
                             = nvl(l_asg2.COLLECTIVE_AGREEMENT_ID,hr_api.g_number)
       and nvl(l_asg1.CAGR_ID_FLEX_NUM,hr_api.g_number)
                             = nvl(l_asg2.CAGR_ID_FLEX_NUM,hr_api.g_number)
       and nvl(l_asg1.CAGR_GRADE_DEF_ID,hr_api.g_number)
                             = nvl(l_asg2.CAGR_GRADE_DEF_ID,hr_api.g_number)
       and nvl(l_asg1.ESTABLISHMENT_ID,hr_api.g_number)
                             = nvl(l_asg2.ESTABLISHMENT_ID,hr_api.g_number)
       and nvl(l_asg1.NOTICE_PERIOD,hr_api.g_number)
                             = nvl(l_asg2.NOTICE_PERIOD,hr_api.g_number)
       and nvl(l_asg1.NOTICE_PERIOD_UOM, hr_api.g_varchar2)
                             = nvl(l_asg2.NOTICE_PERIOD_UOM, hr_api.g_varchar2)
       and nvl(l_asg1.EMPLOYEE_CATEGORY, hr_api.g_varchar2)
                             = nvl(l_asg2.EMPLOYEE_CATEGORY, hr_api.g_varchar2)
       and nvl(l_asg1.WORK_AT_HOME, hr_api.g_varchar2)
                             = nvl(l_asg2.WORK_AT_HOME, hr_api.g_varchar2)
       and nvl(l_asg1.JOB_POST_SOURCE_NAME, hr_api.g_varchar2)
                             = nvl(l_asg2.JOB_POST_SOURCE_NAME, hr_api.g_varchar2)
       and nvl(l_asg1.POSTING_CONTENT_ID,hr_api.g_number)
                             = nvl(l_asg2.POSTING_CONTENT_ID,hr_api.g_number)
       and nvl(l_asg1.PERIOD_OF_PLACEMENT_DATE_START, hr_api.g_date)
                             = nvl(l_asg2.PERIOD_OF_PLACEMENT_DATE_START, hr_api.g_date)
       and nvl(l_asg1.VENDOR_ID,hr_api.g_number)
                             = nvl(l_asg2.VENDOR_ID,hr_api.g_number)
       and nvl(l_asg1.VENDOR_EMPLOYEE_NUMBER, hr_api.g_varchar2)
                             = nvl(l_asg2.VENDOR_EMPLOYEE_NUMBER, hr_api.g_varchar2)
       and nvl(l_asg1.VENDOR_ASSIGNMENT_NUMBER, hr_api.g_varchar2)
                             = nvl(l_asg2.VENDOR_ASSIGNMENT_NUMBER, hr_api.g_varchar2)
       and nvl(l_asg1.ASSIGNMENT_CATEGORY, hr_api.g_varchar2)
                             = nvl(l_asg2.ASSIGNMENT_CATEGORY, hr_api.g_varchar2)
       and nvl(l_asg1.PROJECT_TITLE, hr_api.g_varchar2)
                             = nvl(l_asg2.PROJECT_TITLE, hr_api.g_varchar2)
       and nvl(l_asg1.APPLICANT_RANK,hr_api.g_number)
                             = nvl(l_asg2.APPLICANT_RANK,hr_api.g_number)
       ) then
     hr_utility.set_location(l_proc, 20);
     l_return := TRUE;
   end if;
   hr_utility.set_location('Leaving : '||l_proc, 30);
   return l_return;
  end; /* compareAssignments */
--
-- ======================= cancel_termination ==========================
--
--
  PROCEDURE cancel_termination(p_person_id                NUMBER
                              ,p_actual_termination_date  DATE
                              ,p_clear_details            VARCHAR2 DEFAULT 'N')
  IS
  --
  --
  l_final_process_date         DATE;
  l_last_standard_process_date DATE;
  l_per_system_status      VARCHAR2(30);
  l_max_end_date           DATE;
  l_effective_end_date     DATE;
  l_action_chk             VARCHAR2(1) := 'N';
  l_asg_status_type_id     NUMBER;
  l_new_effective_end_date DATE;
  --
  l_period_of_service_id   number;
  l_business_group_id      number;
  l_date_start             DATE;
  l_old_leaving_reason     varchar2(60);
  l_proc_call              varchar2(500);
  l_package_name           varchar2(50);
  l_procedure_name         varchar2(50);
  l_leg_code               varchar2(150);
  l_dummy                  varchar2(1);
  --
  FPD_FLAG                 BOOLEAN;
  --
  -- start of bug 4919804
 /*
  CURSOR c_assignment IS
  SELECT assignment_id
  ,      assignment_status_type_id
  ,      business_group_id
  FROM   per_assignments_f ass
  WHERE  ass.person_id = p_person_id
  AND    ass.effective_end_date = p_actual_termination_date
  FOR UPDATE;
  */
  -- commmented the cursor and redeclared the cursor c_assignment

  CURSOR c_assignment(lp_final_process_date date) IS --modified for bug 8841176
  SELECT assignment_id
  ,      assignment_status_type_id
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      payroll_id
  ,      object_version_number
  FROM   per_assignments_f ass
  WHERE  ass.person_id = p_person_id
  AND    ass.effective_end_date = p_actual_termination_date
  -- start changes for bug 8841176
  AND    (
          (p_actual_termination_date = lp_final_process_date)
           or
          (p_actual_termination_date <> nvl(lp_final_process_date,to_date('31/12/4712','dd/mm/yyyy'))
           and
           exists (select 1
                 from per_assignments_f ass1, per_assignment_status_types past
                 where ass1.assignment_status_type_id = past.assignment_status_type_id
                 and past.per_system_status = 'TERM_ASSIGN'
                 and ass1.person_id = ass.person_id
                 and ass1.assignment_id = ass.assignment_id
                 and ass1.effective_start_date = p_actual_termination_date + 1)
           )
         )
  -- end changes for bug 8841176
  FOR UPDATE;
  --
   l_effective_end_of_time date;
   l_session_date date;
   l_effective_end_date1 date;
   l_effective_start_date1 date;
   l_object_version_number number :=null;
  -- end of bug 4919804

  cursor c1 is
    select *
    from   per_periods_of_service
    where  person_id = p_person_id
    and    actual_termination_date = p_actual_termination_date;
  --
  -- fix 1370960
    cursor csr_roles is
    select role_id
    ,object_version_number
    ,old_end_date from
    per_roles
    where person_id = p_person_id
    and end_date = p_actual_termination_date
    for update nowait;
  -- fix 1370960 end

  l_c1 c1%rowtype;
  --
--
-- START WWBUG fix for 1390173
--
  l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
  --
--
-- END WWBUG fix for 1390173
--
  --
  -- Start of Fix for WWBUG 1408379
  --
  cursor c2(p_assignment_id number) is
    select *
    from   per_assignment_budget_values_f
    where  assignment_id = p_assignment_id
    and    effective_end_date = l_final_process_date;
  --
  l_old_abv   ben_abv_ler.g_abv_ler_rec;
  l_new_abv   ben_abv_ler.g_abv_ler_rec;
  l_c2 c2%rowtype;
  --
  -- End of Fix for WWBUG 1408379
  --
  -- following cursors added for bug fix 3889294.
  --
  cursor csr_leg_code(p_business_group_id number) is
  select legislation_code
  from per_business_groups
  where business_group_id = p_business_group_id;
  --
  cursor csr_leg_pkg(p_pkg_name varchar2) is
  select '1'
  from user_objects
  where object_name = p_pkg_name
  and object_type = 'PACKAGE';
  --
  l_proc varchar2(72):=g_package||'cancel_termination';
  --
begin
  --
  hr_utility.trace('Entering cancel_termination for '||p_person_id);
  --
  hr_utility.set_location(l_proc,1);
  --
  begin
  --
    SELECT pos.period_of_service_id
    ,      pos.business_group_id
    ,      pos.leaving_reason
    ,      pos.date_start
    ,      pos.final_process_date
    ,      pos.last_standard_process_date
    INTO   l_period_of_service_id
    ,      l_business_group_id
    ,      l_old_leaving_reason
    ,      l_date_start
    ,      l_final_process_date
    ,      l_last_standard_process_date
    FROM   per_periods_of_service pos
    WHERE  pos.person_id = p_person_id
    AND    pos.actual_termination_date = p_actual_termination_date;
  --
  exception when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_6515_EMP_NO_CANCEL');
    hr_utility.raise_error;
  --
  end;
  --
 --- newly added code to cancel termination of contracts start
 /* UPDATE per_contracts_f pc
  SET    pc.effective_end_date = to_date('31/12/4712','DD/MM/YYYY')
  WHERE  pc.person_id          = p_person_id
  AND    p_actual_termination_date
         BETWEEN pc.effective_start_date
         AND     pc.effective_end_date;
  --
  DELETE from per_contracts_f pc
  WHERE  pc.person_id = p_person_id
  AND    pc.effective_start_date > p_actual_termination_date;*/
--- newly added code to cancel termination of contracts end
--
--  hr_utility.set_location(l_proc,2);
  l_action_chk := hrempter.check_for_future_person_type(p_person_id
                                   ,p_actual_termination_date);
  --
  if l_action_chk = 'Y' then
     hr_utility.set_message(801,'HR_7122_EMP_CNCL_TERM_INVLD');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,99);
  -- VT 06/04/96 changed function call
  l_action_chk := hrempter.check_for_compl_actions(p_person_id
                                   ,p_actual_termination_date
                                   ,l_last_standard_process_date
                                   ,l_final_process_date);
  --
  IF l_action_chk = 'W' THEN
    --
    -- Fix for bug 3100620 starts here. message is changed.
    --
    -- hr_utility.set_message(801,'HR_6519_EMP_CANC_ACTIONS_EXIST');
    hr_utility.set_message(800,'PER_449053_EMP_TERM_FUT_ERROR');
    --
    -- Fix for bug 3100620 ends here.
    --
    hr_utility.set_warning;
  END IF;
  --
  if l_action_chk = 'Y' then
     hr_utility.set_message(801,'HR_6519_EMP_CANC_ACTIONS_EXIST');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,3);
  FPD_FLAG := (l_final_process_date IS NOT NULL);
  --
  hr_utility.set_location(l_proc,4);
  UPDATE per_all_people_f pp
  SET    pp.effective_end_date = to_date('31/12/4712','DD/MM/YYYY')
  WHERE  pp.person_id          = p_person_id
  AND    p_actual_termination_date
         BETWEEN pp.effective_start_date
         AND     pp.effective_end_date;
  --
  hr_utility.set_location(l_proc,6);
  DELETE per_all_people_f pp
  WHERE  pp.person_id = p_person_id
  AND    pp.effective_start_date > p_actual_termination_date;
  --
  hr_utility.set_location(l_proc,8);
  --
  -- WWBUG #       - CERN want to keep old details
  --    was a feature of rel 9
  if (p_clear_details = 'N') then
     --
--
-- START WWBUG fix for 1390173
--
     open c1;
       fetch c1 into l_c1;
       if c1%found then
         --
         l_old.PERSON_ID := l_c1.person_id;
         l_old.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_old.DATE_START := l_c1.date_start;
         l_old.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
         l_old.LEAVING_REASON := l_c1.leaving_reason;
         l_old.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
         l_old.ATTRIBUTE1 := l_c1.attribute1;
         l_old.ATTRIBUTE2 := l_c1.attribute2;
         l_old.ATTRIBUTE3 := l_c1.attribute3;
         l_old.ATTRIBUTE4 := l_c1.attribute4;
         l_old.ATTRIBUTE5 := l_c1.attribute5;
         l_old.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         l_new.PERSON_ID := l_c1.person_id;
         l_new.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_new.DATE_START := l_c1.date_start;
         l_new.ACTUAL_TERMINATION_DATE := null;
         l_new.LEAVING_REASON := null;
         l_new.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
         l_new.ATTRIBUTE1 := l_c1.attribute1;
         l_new.ATTRIBUTE2 := l_c1.attribute2;
         l_new.ATTRIBUTE3 := l_c1.attribute3;
         l_new.ATTRIBUTE4 := l_c1.attribute4;
         l_new.ATTRIBUTE5 := l_c1.attribute5;
         l_new.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         --
         ben_pps_ler.ler_chk(p_old            => l_old
                            ,p_new            => l_new
                            ,p_event          => 'UPDATING'
                            ,p_effective_date => l_c1.date_start);
         --
       end if;
     close c1;
     --
--
-- END WWBUG fix for 1390173
--
     UPDATE per_periods_of_service pos
     SET    pos.actual_termination_date           = null
     ,      pos.last_standard_process_date        = null
     ,      pos.final_process_date                = null
     ,      pos.termination_accepted_person_id    = null
     ,      pos.leaving_reason                    = null
     ,      pos.accepted_termination_date         = null
     WHERE  pos.person_id               = p_person_id
     AND    pos.actual_termination_date = p_actual_termination_date;
  else
     --
--
-- START WWBUG fix for 1390173
--
     open c1;
       fetch c1 into l_c1;
       if c1%found then
         --
         l_old.PERSON_ID := l_c1.person_id;
         l_old.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_old.DATE_START := l_c1.date_start;
         l_old.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
         l_old.LEAVING_REASON := l_c1.leaving_reason;
         l_old.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
         l_old.ATTRIBUTE1 := l_c1.attribute1;
         l_old.ATTRIBUTE2 := l_c1.attribute2;
         l_old.ATTRIBUTE3 := l_c1.attribute3;
         l_old.ATTRIBUTE4 := l_c1.attribute4;
         l_old.ATTRIBUTE5 := l_c1.attribute5;
         l_old.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         l_new.PERSON_ID := l_c1.person_id;
         l_new.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_new.DATE_START := l_c1.date_start;
         l_new.ACTUAL_TERMINATION_DATE := null;
         l_new.LEAVING_REASON := null;
         l_new.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
         l_new.ATTRIBUTE1 := l_c1.attribute1;
         l_new.ATTRIBUTE2 := l_c1.attribute2;
         l_new.ATTRIBUTE3 := l_c1.attribute3;
         l_new.ATTRIBUTE4 := l_c1.attribute4;
         l_new.ATTRIBUTE5 := l_c1.attribute5;
         l_new.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         --
         ben_pps_ler.ler_chk(p_old            => l_old
                            ,p_new            => l_new
                            ,p_event          => 'UPDATING'
                            ,p_effective_date => l_c1.date_start);
         --
       end if;
     close c1;
     --
--
-- END WWBUG fix for 1390173
--
     UPDATE per_periods_of_service pos
     SET    pos.actual_termination_date           = null
     ,      pos.last_standard_process_date        = null
     ,      pos.final_process_date                = null
     ,      pos.termination_accepted_person_id    = null
     ,      pos.leaving_reason                    = null
     ,      pos.notified_termination_date         = null
     ,      pos.projected_termination_date        = null
     ,      pos.accepted_termination_date         = null
     WHERE  pos.person_id               = p_person_id
     AND    pos.actual_termination_date = p_actual_termination_date;
     --
  end if;
  --
  --
  --
  -- FIX to WWBUG 1176101
  --
  ben_dt_trgr_handle.periods_of_service
    (p_rowid              => null
    ,p_person_id          => p_person_id
    ,p_pds_atd            => null
    ,p_pds_leaving_reason => null
    -- Bug 1854968
    ,p_pds_old_atd        => l_old.actual_termination_date
    ,p_pds_fpd            => null);
  --
  --
  --
  hr_utility.set_location(l_proc,12);

  FOR c_ass_rec IN c_assignment(l_final_process_date) LOOP --modified for bug 8841176
  --
    hr_utility.set_location(l_proc,14);
    SELECT per_system_status
    INTO   l_per_system_status
    FROM   per_assignment_status_types
    WHERE  assignment_status_type_id = c_ass_rec.assignment_status_type_id;
    --
    --
    -- Note the assignment_status_id from the record which ended on ATD
    -- so that we can set the other records for this assignment which
    -- are currently TERM_ASSIGN back to the appropriate ACTIVE_ASG status.
    --
    l_asg_status_type_id := c_ass_rec.assignment_status_type_id;
    --
    hr_utility.set_location(l_proc,16);
    l_max_end_date := hrempter.get_max_end_date(c_ass_rec.assignment_id);
    --
    --if l_per_system_status <> 'TERM_ASSIGN' then
    -- bug 5152164 commented out the above if condition and removed the condition
    -- added in previous fix for the same bug
    --
      hr_utility.set_location(l_proc,18);
      if FPD_FLAG then
        hr_utility.set_location(l_proc,20);
        if l_max_end_date <> l_final_process_date then
           l_effective_end_date := l_max_end_date;
        else
           hr_utility.set_location(l_proc,22);
           l_effective_end_date := to_date('31/12/4712','DD/MM/YYYY');
        end if;
      else
         hr_utility.set_location(l_proc,24);
         l_effective_end_date := l_max_end_date;
      end if;
      --
      hr_utility.set_location(l_proc,26);
      --
      -- Open out the last dated assignment record to the end of time or
      -- max_end_date based on above logic.
      --
      -- start of bug fix 4919804
       l_effective_end_of_time := to_date('31/12/4712','DD/MM/YYYY');
       l_object_version_number := c_ass_rec.object_version_number;
       l_session_date :=hr_general.effective_date();
       l_effective_end_date1 := c_ass_rec.effective_end_date;
       l_effective_start_date1:=c_ass_rec.effective_start_date;
-- end of bug fix 4919804

      UPDATE per_assignments_f ass
      SET    ass.effective_end_date = l_effective_end_date
      WHERE  assignment_id = c_ass_rec.assignment_id
        AND  effective_end_date = l_max_end_date;

-- added the following call as per the bug 4919804

-- bug 5152164 added the following if condition
--
if l_per_system_status <> 'TERM_ASSIGN' then

   pay_pog_all_assignments_pkg.after_delete
        (p_effective_date                       => l_session_date
        ,p_datetrack_mode                       => 'DELETE_NEXT_CHANGE'
        ,p_validation_start_date            => c_ass_rec.effective_START_DATE
        ,p_validation_end_date          => c_ass_rec.effective_end_date
        ,P_ASSIGNMENT_ID                        => c_ass_rec.assignment_id
        ,P_EFFECTIVE_END_DATE           => l_effective_end_of_time
        ,P_EFFECTIVE_START_DATE         => c_ass_rec.effective_START_DATE
        ,P_OBJECT_VERSION_NUMBER            => l_object_version_number
        ,P_ORG_NOW_NO_MANAGER_WARNING  => null
        ,P_APPLICANT_RANK_O            => null
        ,P_APPLICATION_ID_O            => null
        ,P_ASSIGNMENT_CATEGORY_O => null
        , P_ASSIGNMENT_NUMBER_O => null
        ,P_ASSIGNMENT_SEQUENCE_O => null
        ,P_ASSIGNMENT_STATUS_TYPE_ID_O => null
        ,P_ASSIGNMENT_TYPE_O => null
        ,P_ASS_ATTRIBUTE1_O => null
        ,P_ASS_ATTRIBUTE10_O => null
        ,P_ASS_ATTRIBUTE11_O => null
        ,P_ASS_ATTRIBUTE12_O => null
        ,P_ASS_ATTRIBUTE13_O => null
        ,P_ASS_ATTRIBUTE14_O => null
        ,P_ASS_ATTRIBUTE15_O => null
        ,P_ASS_ATTRIBUTE16_O => null
        ,P_ASS_ATTRIBUTE17_O => null
        ,P_ASS_ATTRIBUTE18_O => null
        ,P_ASS_ATTRIBUTE19_O => null
        ,P_ASS_ATTRIBUTE2_O => null
        ,P_ASS_ATTRIBUTE20_O => null
        ,P_ASS_ATTRIBUTE21_O => null
        ,P_ASS_ATTRIBUTE22_O => null
        ,P_ASS_ATTRIBUTE23_O => null
        ,P_ASS_ATTRIBUTE24_O => null
        ,P_ASS_ATTRIBUTE25_O => null
        ,P_ASS_ATTRIBUTE26_O => null
        ,P_ASS_ATTRIBUTE27_O => null
        ,P_ASS_ATTRIBUTE28_O => null
        ,P_ASS_ATTRIBUTE29_O => null
        ,P_ASS_ATTRIBUTE3_O => null
        ,P_ASS_ATTRIBUTE30_O =>null
        ,P_ASS_ATTRIBUTE4_O =>null
        ,P_ASS_ATTRIBUTE5_O => null
        ,P_ASS_ATTRIBUTE6_O => null
        ,P_ASS_ATTRIBUTE7_O => null
         ,P_ASS_ATTRIBUTE8_O => null
        ,P_ASS_ATTRIBUTE9_O => null
        ,P_ASS_ATTRIBUTE_CATEGORY_O => null
        ,P_BARGAINING_UNIT_CODE_O => null
        ,P_BUSINESS_GROUP_ID_O => c_ass_rec.business_group_id
        ,P_CAGR_GRADE_DEF_ID_O => null
        ,P_CAGR_ID_FLEX_NUM_O => null
        ,P_CHANGE_REASON_O => null
        ,P_COLLECTIVE_AGREEMENT_ID_O => null
        ,P_COMMENT_ID_O => null
        ,P_CONTRACT_ID_O => null
        ,P_DATE_PROBATION_END_O => null
        ,P_DEFAULT_CODE_COMB_ID_O => null
        ,P_EFFECTIVE_END_DATE_O => l_effective_end_date1
        ,P_EFFECTIVE_START_DATE_O => l_effective_start_date1
        ,P_EMPLOYEE_CATEGORY_O => null
        ,P_EMPLOYMENT_CATEGORY_O => null
        ,P_ESTABLISHMENT_ID_O => null
        ,P_FREQUENCY_O => null
        ,P_GRADE_ID_O => null
        ,P_HOURLY_SALARIED_CODE_O => null
        ,P_INTERNAL_ADDRESS_LINE_O => null
        ,P_JOB_ID_O => null
        ,P_JOB_POST_SOURCE_NAME_O => null
        ,P_LABOUR_UNION_MEMBER_FLAG_O => null
        ,P_LOCATION_ID_O => null
        ,P_MANAGER_FLAG_O => null
        ,P_NORMAL_HOURS_O => null
        ,P_NOTICE_PERIOD_O => null
        ,P_NOTICE_PERIOD_UOM_O => null
        ,P_OBJECT_VERSION_NUMBER_O => null
        ,P_ORGANIZATION_ID_O => null
        ,P_PAYROLL_ID_O => c_ass_rec.payroll_id
        ,P_PAY_BASIS_ID_O => null
        ,P_PEOPLE_GROUP_ID_O => null
        ,P_PERF_REVIEW_PERIOD_O => null
        ,P_PERF_REVIEW_PERIOD_FREQUEN_O => null
        ,P_PERIOD_OF_SERVICE_ID_O => null
        ,P_PERSON_ID_O => null
        ,P_PERSON_REFERRED_BY_ID_O => null
        ,P_PLACEMENT_DATE_START_O => null
        ,P_POSITION_ID_O => null
        ,P_POSTING_CONTENT_ID_O => null
        ,P_PRIMARY_FLAG_O => null
        ,P_PROBATION_PERIOD_O => null
        ,P_PROBATION_UNIT_O => null
        ,P_PROGRAM_APPLICATION_ID_O => null
        ,P_PROGRAM_ID_O => null
        ,P_PROGRAM_UPDATE_DATE_O => null
        ,P_PROJECT_TITLE_O => null
        ,P_RECRUITER_ID_O => null
        ,P_RECRUITMENT_ACTIVITY_ID_O => null
        ,P_REQUEST_ID_O => null
        ,P_SAL_REVIEW_PERIOD_O => null
        ,P_SAL_REVIEW_PERIOD_FREQUEN_O => null
        ,P_SET_OF_BOOKS_ID_O => null
        ,P_SOFT_CODING_KEYFLEX_ID_O => null
        ,P_SOURCE_ORGANIZATION_ID_O => null
        ,P_SOURCE_TYPE_O => null
        ,P_SPECIAL_CEILING_STEP_ID_O => null
        ,P_SUPERVISOR_ID_O => null
        ,P_TIME_NORMAL_FINISH_O => null
        ,P_TIME_NORMAL_START_O => null
        ,P_TITLE_O => null
        ,P_VACANCY_ID_O => null
        ,P_VENDOR_ASSIGNMENT_NUMBER_O => null
        ,P_VENDOR_EMPLOYEE_NUMBER_O => null
        ,P_VENDOR_ID_O => null
        ,P_WORK_AT_HOME_O => null
        ,P_GRADE_LADDER_PGM_ID_O => null
        ,P_SUPERVISOR_ASSIGNMENT_ID_O => null
        ,P_VENDOR_SITE_ID_O => null
        ,P_PO_HEADER_ID_O => null
        ,P_PO_LINE_ID_O => null
        ,P_PROJECTED_ASSIGNMENT_END_O => null
);

end if;
--bug 5152164 end of fix
--
-- end of bug 4919804
      --
      -- We want to keep most of the assignment records after the ATD so
      -- update them all to the same assignment_status as the record
      -- which ends on ATD.
      --
      -- The fix for bug 1271513 has been modified slightly.  We update
      -- all assignments which start after ATD so that we preserve future
      -- assignment changes.  Since the terminate code created the assignment
      -- change starting on ATD+1 we will try and delete it.  It will get
      -- deleted provided it is identical to the assignment which ends on
      -- ATD (the records will be considered identical if all columns between
      -- the two records are the same with the exception of effective dates,
      -- AOL WHO and OVN columns.
      --
      -- First update all future assignments to set the assignment status...
      --
      UPDATE per_assignments_f ass
      SET    ass.assignment_status_type_id = l_asg_status_type_id
      WHERE  assignment_id = c_ass_rec.assignment_id
        AND  effective_start_date >= p_actual_termination_date;
      --
      -- ... if the ATD and FPD are different compare the record ending on ATD
      -- and one starting on ATD+1 if they are identical delete the one starting
      -- on ATD+1 and open the other to the end date of the deleted record.
      --
      -- removed the Logical condition to fix the bug8214333

  /*    if not (compareAssignments(p_assignment_id1 => c_ass_rec.assignment_id,
                              p_effective_date1 => p_actual_termination_date,
               p_assignment_id2 => c_ass_rec.assignment_id,
               p_effective_date2 => p_actual_termination_date+1)
          and p_actual_termination_date <> nvl(l_final_process_date,
                                          hr_general.end_of_time))
*/
   hr_utility.set_location('c_ass_rec.assignment_id'||c_ass_rec.assignment_id,27);
   hr_utility.set_location('p_actual_termination_date'||p_actual_termination_date,27);
   hr_utility.set_location('l_final_process_date'||l_final_process_date,27);

 if  p_actual_termination_date <> nvl(l_final_process_date,
                                          hr_general.end_of_time)
      then
        hr_utility.set_location(l_proc,27);
        --
   -- The assignments are identical....
   --
   -- ...get the end date of the assignment created by the termination
   -- and which starts the day after the ATD...
   --
   select effective_end_date
     into l_new_effective_end_date
     from per_all_assignments_f
    where assignment_id = c_ass_rec.assignment_id
      and effective_start_date = p_actual_termination_date+1;
   --
   -- ...now update the assignment ending on ATD to have the selected
   -- end date...
   --
   update per_all_assignments_f
      set effective_end_date = l_new_effective_end_date
    where current of c_assignment;
   --
   -- ...now delete the assignment which starts on ATD+1...
   --
   delete from per_all_assignments_f
    where assignment_id = c_ass_rec.assignment_id
      and effective_start_date = p_actual_termination_date +1;
      end if;
--  end if;
    --
    if FPD_FLAG then
    --
     -- added the following call as per the bug 4919804
   pay_pog_all_assignments_pkg.after_delete
        (p_effective_date                       => l_session_date
        ,p_datetrack_mode                       => 'DELETE_NEXT_CHANGE'
        ,p_validation_start_date            => c_ass_rec.effective_START_DATE
        ,p_validation_end_date          => c_ass_rec.effective_end_date
        ,P_ASSIGNMENT_ID                        => c_ass_rec.assignment_id
        ,P_EFFECTIVE_END_DATE           => l_effective_end_of_time
        ,P_EFFECTIVE_START_DATE         => c_ass_rec.effective_START_DATE
        ,P_OBJECT_VERSION_NUMBER            => l_object_version_number
        ,P_ORG_NOW_NO_MANAGER_WARNING  => null
        ,P_APPLICANT_RANK_O            => null
        ,P_APPLICATION_ID_O            => null
        ,P_ASSIGNMENT_CATEGORY_O => null
        , P_ASSIGNMENT_NUMBER_O => null
        ,P_ASSIGNMENT_SEQUENCE_O => null
        ,P_ASSIGNMENT_STATUS_TYPE_ID_O => null
        ,P_ASSIGNMENT_TYPE_O => null
        ,P_ASS_ATTRIBUTE1_O => null
        ,P_ASS_ATTRIBUTE10_O => null
        ,P_ASS_ATTRIBUTE11_O => null
        ,P_ASS_ATTRIBUTE12_O => null
        ,P_ASS_ATTRIBUTE13_O => null
        ,P_ASS_ATTRIBUTE14_O => null
        ,P_ASS_ATTRIBUTE15_O => null
        ,P_ASS_ATTRIBUTE16_O => null
        ,P_ASS_ATTRIBUTE17_O => null
        ,P_ASS_ATTRIBUTE18_O => null
        ,P_ASS_ATTRIBUTE19_O => null
        ,P_ASS_ATTRIBUTE2_O => null
        ,P_ASS_ATTRIBUTE20_O => null
        ,P_ASS_ATTRIBUTE21_O => null
        ,P_ASS_ATTRIBUTE22_O => null
        ,P_ASS_ATTRIBUTE23_O => null
        ,P_ASS_ATTRIBUTE24_O => null
        ,P_ASS_ATTRIBUTE25_O => null
        ,P_ASS_ATTRIBUTE26_O => null
        ,P_ASS_ATTRIBUTE27_O => null
        ,P_ASS_ATTRIBUTE28_O => null
        ,P_ASS_ATTRIBUTE29_O => null
        ,P_ASS_ATTRIBUTE3_O => null
        ,P_ASS_ATTRIBUTE30_O =>null
        ,P_ASS_ATTRIBUTE4_O =>null
        ,P_ASS_ATTRIBUTE5_O => null
        ,P_ASS_ATTRIBUTE6_O => null
        ,P_ASS_ATTRIBUTE7_O => null
         ,P_ASS_ATTRIBUTE8_O => null
        ,P_ASS_ATTRIBUTE9_O => null
        ,P_ASS_ATTRIBUTE_CATEGORY_O => null
        ,P_BARGAINING_UNIT_CODE_O => null
        ,P_BUSINESS_GROUP_ID_O => c_ass_rec.business_group_id
        ,P_CAGR_GRADE_DEF_ID_O => null
        ,P_CAGR_ID_FLEX_NUM_O => null
        ,P_CHANGE_REASON_O => null
        ,P_COLLECTIVE_AGREEMENT_ID_O => null
        ,P_COMMENT_ID_O => null
        ,P_CONTRACT_ID_O => null
        ,P_DATE_PROBATION_END_O => null
        ,P_DEFAULT_CODE_COMB_ID_O => null
        ,P_EFFECTIVE_END_DATE_O => l_final_process_date
        ,P_EFFECTIVE_START_DATE_O => l_effective_start_date1
        ,P_EMPLOYEE_CATEGORY_O => null
        ,P_EMPLOYMENT_CATEGORY_O => null
        ,P_ESTABLISHMENT_ID_O => null
        ,P_FREQUENCY_O => null
        ,P_GRADE_ID_O => null
        ,P_HOURLY_SALARIED_CODE_O => null
        ,P_INTERNAL_ADDRESS_LINE_O => null
        ,P_JOB_ID_O => null
        ,P_JOB_POST_SOURCE_NAME_O => null
        ,P_LABOUR_UNION_MEMBER_FLAG_O => null
        ,P_LOCATION_ID_O => null
        ,P_MANAGER_FLAG_O => null
        ,P_NORMAL_HOURS_O => null
        ,P_NOTICE_PERIOD_O => null
        ,P_NOTICE_PERIOD_UOM_O => null
        ,P_OBJECT_VERSION_NUMBER_O => null
        ,P_ORGANIZATION_ID_O => null
        ,P_PAYROLL_ID_O => c_ass_rec.payroll_id
        ,P_PAY_BASIS_ID_O => null
        ,P_PEOPLE_GROUP_ID_O => null
        ,P_PERF_REVIEW_PERIOD_O => null
        ,P_PERF_REVIEW_PERIOD_FREQUEN_O => null
        ,P_PERIOD_OF_SERVICE_ID_O => null
        ,P_PERSON_ID_O => null
        ,P_PERSON_REFERRED_BY_ID_O => null
        ,P_PLACEMENT_DATE_START_O => null
        ,P_POSITION_ID_O => null
        ,P_POSTING_CONTENT_ID_O => null
        ,P_PRIMARY_FLAG_O => null
        ,P_PROBATION_PERIOD_O => null
        ,P_PROBATION_UNIT_O => null
        ,P_PROGRAM_APPLICATION_ID_O => null
        ,P_PROGRAM_ID_O => null
        ,P_PROGRAM_UPDATE_DATE_O => null
        ,P_PROJECT_TITLE_O => null
        ,P_RECRUITER_ID_O => null
        ,P_RECRUITMENT_ACTIVITY_ID_O => null
        ,P_REQUEST_ID_O => null
        ,P_SAL_REVIEW_PERIOD_O => null
        ,P_SAL_REVIEW_PERIOD_FREQUEN_O => null
        ,P_SET_OF_BOOKS_ID_O => null
        ,P_SOFT_CODING_KEYFLEX_ID_O => null
        ,P_SOURCE_ORGANIZATION_ID_O => null
        ,P_SOURCE_TYPE_O => null
        ,P_SPECIAL_CEILING_STEP_ID_O => null
        ,P_SUPERVISOR_ID_O => null
        ,P_TIME_NORMAL_FINISH_O => null
        ,P_TIME_NORMAL_START_O => null
        ,P_TITLE_O => null
        ,P_VACANCY_ID_O => null
        ,P_VENDOR_ASSIGNMENT_NUMBER_O => null
        ,P_VENDOR_EMPLOYEE_NUMBER_O => null
        ,P_VENDOR_ID_O => null
        ,P_WORK_AT_HOME_O => null
        ,P_GRADE_LADDER_PGM_ID_O => null
        ,P_SUPERVISOR_ASSIGNMENT_ID_O => null
        ,P_VENDOR_SITE_ID_O => null
        ,P_PO_HEADER_ID_O => null
        ,P_PO_LINE_ID_O => null
        ,P_PROJECTED_ASSIGNMENT_END_O => null
);
--
-- end of bug 4919804
--
      hr_utility.set_location(l_proc,30);
      if l_max_end_date <> l_final_process_date then
        null;
      else
        hr_utility.set_location(l_proc,32);
        l_effective_end_date := to_date('31/12/4712','DD/MM/YYYY');
        --
        hr_utility.set_location(l_proc,34);
        UPDATE per_secondary_ass_statuses sas
        SET    sas.end_date = null
        WHERE  sas.assignment_id = c_ass_rec.assignment_id
        AND    sas.end_date = l_final_process_date;
        --
        hr_utility.set_location(l_proc,36);
        UPDATE pay_personal_payment_methods_f ppm
        SET    ppm.effective_end_date = l_effective_end_date
        WHERE  ppm.assignment_id      = c_ass_rec.assignment_id
        AND    ppm.effective_end_date = l_final_process_date;
        --
        hr_utility.set_location(l_proc,38);
        UPDATE pay_cost_allocations_f pca
        SET    pca.effective_end_date = l_effective_end_date
        WHERE  pca.assignment_id      = c_ass_rec.assignment_id
        AND    pca.effective_end_date = l_final_process_date;
        --
        hr_utility.set_location(l_proc,40);
        UPDATE per_spinal_point_placements_f spp
        SET    spp.effective_end_date = l_effective_end_date
        WHERE  spp.assignment_id      = c_ass_rec.assignment_id
        AND    spp.effective_end_date = l_final_process_date;
        --
        --
        -- Adding code to update the date tracked tax tables to resolve bug
        -- 920233.
        -- Adding an extra verification to make sure the tax records are reverse
        -- only for US legislation. This extra verification is done because
        -- this package peempter.pkb is part of the CORE HR code and UK
        -- customer do not use these TAX tables. Only Customers with HR/CERIDIAN
        -- use this TAX tables.

        if hr_general.chk_geocodes_installed ='Y' then
          hr_utility.set_location(l_proc,41);
          pay_us_update_tax_rec_pkg.reverse_term_emp_tax_records
                                   (c_ass_rec.assignment_id
                                   ,l_final_process_date);

        end if; /* verification chk_geocodes_installed */
        --
        -- SASmith 30-APR-1998
        -- Due to date tracking of assignment_budget_values

        hr_utility.set_location(l_proc,45);
        --
        -- Start of Fix for WWBUG 1408379
        --
        open c2(c_ass_rec.assignment_id);
          --
          loop
            --
            fetch c2 into l_c2;
            exit when c2%notfound;
            --
            l_old_abv.assignment_id := l_c2.assignment_id;
            l_old_abv.business_group_id := l_c2.business_group_id;
            l_old_abv.value := l_c2.value;
            l_old_abv.assignment_budget_value_id := l_c2.assignment_budget_value_id;
            l_old_abv.effective_start_date := l_c2.effective_start_date;
            l_old_abv.effective_end_date := l_c2.effective_end_date;
            l_new_abv.assignment_id := l_c2.assignment_id;
            l_new_abv.business_group_id := l_c2.business_group_id;
            l_new_abv.value := l_c2.value;
            l_new_abv.assignment_budget_value_id := l_c2.assignment_budget_value_id;
            l_new_abv.effective_start_date := l_c2.effective_start_date;
            l_new_abv.effective_end_date := l_effective_end_date;
            --
            update per_assignment_budget_values_f abv
            set    abv.effective_end_date = l_effective_end_date
            where  abv.assignment_id      = c_ass_rec.assignment_id
            and    abv.assignment_budget_value_id = l_c2.assignment_budget_value_id
            and    abv.effective_end_date = l_final_process_date;
            --
            ben_abv_ler.ler_chk(p_old            => l_old_abv,
                                p_new            => l_new_abv,
                                p_effective_date => l_c2.effective_start_date);
            --
          end loop;
          --
        close c2;
        --
        -- End of Fix for WWBUG 1408379
        --
      end if;
    --
    end if;
  --
  -- open up element entries closed down by the termination
  --
  hr_utility.set_location(l_proc,42);
  hrentmnt.maintain_entries_asg(c_ass_rec.assignment_id
                               ,c_ass_rec.business_group_id
                               ,'CNCL_TERM'
                               ,p_actual_termination_date
                               ,l_last_standard_process_date
                               ,l_final_process_date
                               ,'DELETE_NEXT_CHANGE'
                               ,null
                               ,null);
  --
         per_saladmin_utility.adjust_pay_proposals(p_assignment_id =>c_ass_rec.assignment_id);
  --
  END LOOP;
  --
  -- fix 1370960
  for roles_rec in csr_roles
  loop
    per_supplementary_role_api.update_supplementary_role(
        p_effective_date                => p_actual_termination_date
        ,p_role_id                      => roles_rec.role_id
        ,p_object_version_number        => roles_rec.object_version_number
        ,p_end_date                     => roles_rec.old_end_date
        ,p_old_end_date                 => null
        );
  end loop;
  -- 1370960 end
  --
  -- Fix for bug 3889294 starts here. Code added to perform legislation
  -- specific actions if exists.
  --
  open csr_leg_code(l_business_group_id);
  fetch csr_leg_code into l_leg_code;
  --
  if csr_leg_code%found then
    --
    -- If one exists then we must check whether there exists a legislation
    -- specific Validate_Delete procedure. This should be named in the format
    -- PER_XX_TERMINATION.REVERSE
    -- If it does exist then construct an anonymous PL/SQL block to call
    -- the procedure.
    --
    hr_utility.set_location(l_proc,43);
    --
    l_package_name   := 'PER_'||l_leg_code||'_TERMINATION';
    l_procedure_name := 'REVERSE';
    --
    -- Close Cursor added a part of fix for bug 1858597
    --
    close csr_leg_code;
    --
    -- Check package exists
    --
    open csr_leg_pkg(l_package_name);
    fetch csr_leg_pkg into l_dummy;
    --
    if csr_leg_pkg%found then
      --
      hr_utility.set_location(l_proc,44);
      --
      close csr_leg_pkg;
      --
      -- Added as part of fix for bug 1858597
      --
      EXECUTE IMMEDIATE 'BEGIN '||l_package_name||'.'||l_procedure_name||
          '(:P_PERIOD_OF_SERVICE_ID,'||':P_ACTUAL_TERMINATION_DATE,'||
          ':P_LEAVING_REASON); END;'
           USING l_period_of_service_id
                ,p_actual_termination_date
                ,l_old_leaving_reason;
      --
    end if;
    --
  end if;
  --
  -- Update the PTU records.
  --
  hr_utility.set_location(l_proc,65);
  --
  if l_old_leaving_reason = 'R' then
    --
    hr_utility.set_location(l_proc,66);
    --
    hr_per_type_usage_internal.cancel_person_type_usage
     (p_effective_date         => p_actual_termination_date+1
     ,p_person_id              => p_person_id
     ,p_system_person_type     => 'RETIREE');
    -- end if; fix Bug 2048953
--
-- Added for Bug 5507290. Need to cancel EX_EMP PTU record
-- aswell along with RETIREE
--
     hr_utility.set_location(l_proc,67);
     --
     hr_per_type_usage_internal.cancel_person_type_usage
     (p_effective_date         => p_actual_termination_date+1
     ,p_person_id              => p_person_id
     ,p_system_person_type     => 'EX_EMP');
--
-- End of Bug 5507290.
--
  else
     hr_utility.set_location('REV_TERM '||l_proc,68);
     hr_per_type_usage_internal.cancel_person_type_usage
     (p_effective_date         => p_actual_termination_date+1
     ,p_person_id              => p_person_id
     ,p_system_person_type     => 'EX_EMP');
  end if;
  --
  -- call Hr workflow sync code.
  --
  hr_utility.set_location(l_proc,70);
  --
  per_hrwf_synch_cover.per_pds_wf(
                         p_person_id    => p_person_id,
                         p_date         => null,
                         p_date_start   => l_date_start,
                         p_action       => 'REVERSE TERMINATION');
  --
  -- Fix for bug 3889294 ends here.
  --
  end cancel_termination;
--
--
end hrempter;

/

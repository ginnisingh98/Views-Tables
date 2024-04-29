--------------------------------------------------------
--  DDL for Package Body HR_PYOINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PYOINT" as
/* $Header: pyasgint.pkb 120.0 2005/05/29 03:01:14 appldev noship $ */
/*
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
   Name        : hr_pyoint
--
   Description : Package contains procedure that does interlock checking.
--
   Test List
   ---------
   Procedure                     Name       Date        Test Id Status
   +----------------------------+----------+-----------+-------+--------------+
   validate                      dsaxby     20-JAN-1993         Completed.
--
   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   24-SEP-2004  NBRISTOW    115.4           Fixed GSCC errors.
   24-SEP-2004  NBRISTOW    115.3           Changes for the Process Groups.
   30-OCT-1996  ARASHID     40.3   397298   Modified return codes to indicate
                                            why the interlock failed. Also
                                            return assignment_number in an
                                            extra parameter.
                                            Also, fixed to use cursors because
                                            the code SQL can return multiple
                                            rows.
   04-SEP-1995  DSAXBY      40.2            Missing '/' after the select from
                                            user_errors at bottom of file.
   28-SEP-1993  DSAXBY      40.1            Alter time dependent leg check to
                                            join via per_periods_of_service.
   22-APR-1993  DSAXBY      3.1             Chge per_all_ass to per_ass.
   29-JAN-1993  DSAXBY      3.0             First created.
*/
   ----------------------------- validate -------------------------------------
   /*
      NAME
         validate - validates assignment interlocks.
      DESCRIPTION
         This procedure validates assignment level interlock rules
         for the run on an individual assignment basis.
         It is called from the main run code when interlock flag
         is set to 'Y'.
      NOTES
         There is currently no code within this package to
         report those assignments failing interlock rules.
         This can only currently be done by setting logging
         on and examining the resultant log file.
         The reporting ability will be added in due course.
   */
   procedure validate
   (
      pactid   in out nocopy number,   -- payroll_action_id.
      assignid in out nocopy number,   -- assignment_id to check.
      itpflag  in out nocopy varchar2, -- independent time periods flag.
      assnum   in out nocopy varchar2, -- returned assignment_number.
      intstat  in out nocopy number    -- interlock status.
   ) is
      SUCC   constant number := 0;
      FUTURE constant number := 1; -- Action in payroll with later start date.
      PAST   constant number := 2; -- Action incomplete in past payroll.
      failed number; -- used to tell if interlock failed or not.
      -- Effective dates used to determine why the interlock failed.
      ed1    date;
      ed2    date;
      -- Independent time periods cursor.
      cursor c_indep(pactid in number, assignid in number) is
      select 1,
             pa1.effective_date,
             pa2.effective_date
      from   pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_assignment_actions     ac2
      where  pa1.payroll_action_id    = pactid
      and    ac2.assignment_id        = assignid
      and    pa2.payroll_action_id    = ac2.payroll_action_id
      and    pcl.classification_name  = 'SEQUENCED'
      and    pa2.action_type          = pcl.action_type
      and   (pa2.effective_date > pa1.effective_date
         or (ac2.action_status not in ('C', 'S')
      and    pa2.effective_date <= pa1.effective_date));
--
      -- Group Dependent time periods cursor.
      cursor c_grpdep(pactid in number, assignid in number) is
      select 1,
             pa1.effective_date,
             pa2.effective_date,
             as1.assignment_number
      from   per_assignments_f          as1,
             pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_assignment_actions     ac2,
             pay_object_groups          pog_act,
             pay_object_groups          pog_grp
      where  pa1.payroll_action_id    = pactid
      and    as1.assignment_id        = assignid
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    pog_act.source_id        = as1.assignment_id
      and    pog_act.source_type      = 'PAF'
      and    pog_act.parent_object_group_id = pog_grp.parent_object_group_id
      and    pog_grp.source_type      = 'PAF'
      and    pog_grp.source_id        = ac2.assignment_id
      and    pa2.payroll_action_id    = ac2.payroll_action_id
      and    pcl.classification_name  = 'SEQUENCED'
      and    pa2.action_type          = pcl.action_type
      and   (pa2.effective_date > pa1.effective_date
         or (ac2.action_status not in ('C', 'S')
      and    pa2.effective_date <= pa1.effective_date));
--
      -- Dependent time periods cursor.
      cursor c_dep(pactid in number, assignid in number) is
      select 1,
             pa1.effective_date,
             pa2.effective_date,
             as1.assignment_number
      from   per_assignments_f          as1,
             per_assignments_f          as2,
             pay_payroll_actions        pa1,
             pay_payroll_actions        pa2,
             pay_action_classifications pcl,
             pay_assignment_actions     ac2,
             per_periods_of_service     pos
      where  pa1.payroll_action_id    = pactid
      and    as1.assignment_id        = assignid
      and    pa1.effective_date between
             as1.effective_start_date and as1.effective_end_date
      and    pos.period_of_service_id = as1.period_of_service_id
      and    as2.period_of_service_id = pos.period_of_service_id
      and    ac2.assignment_id        = as2.assignment_id
      and    pa2.payroll_action_id    = ac2.payroll_action_id
      and    pcl.classification_name  = 'SEQUENCED'
      and    pa2.action_type          = pcl.action_type
      and   (pa2.effective_date > pa1.effective_date
         or (ac2.action_status not in ('C', 'S')
      and    pa2.effective_date <= pa1.effective_date));
   begin
      failed := NULL;
      if(itpflag = 'Y') then
         -- check interlock status for the independent
         -- time periods case (e.g. the US).
         begin
            hr_utility.set_location('hr_pyoint.validate',1);
            open c_indep(pactid,assignid);
            fetch c_indep into failed, ed1, ed2;

            -- Get the assignment_number (note: per_assignments_f is
            -- datetracked).
            hr_utility.set_location('hr_pyoint.validate',2);
            if(not c_indep%NOTFOUND) then
               select ass.assignment_number
               into   assnum
               from   pay_payroll_actions ppa,
                      per_assignments_f ass
               where  ppa.payroll_action_id = pactid
               and    ass.assignment_id = assignid
               and    ass.payroll_id = ppa.payroll_id
               and    (ppa.effective_date between
                      ass.effective_start_date and ass.effective_end_date);
            end if;

            -- Close the cursor.
            close c_indep;
         end;
      elsif(itpflag = 'G') then
         -- check interlock status for the dependent
         -- time periods case (e.g. the UK).
         begin
            hr_utility.set_location('hr_pyoint.validate',3);
            open c_grpdep(pactid,assignid);
            fetch c_grpdep into failed, ed1, ed2, assnum;
            close c_grpdep;
         end;
      else
         -- check interlock status for the dependent
         -- time periods case (e.g. the UK).
         begin
            hr_utility.set_location('hr_pyoint.validate',4);
            open c_dep(pactid,assignid);
            fetch c_dep into failed, ed1, ed2, assnum;
            close c_dep;
         end;
      end if;
      if(failed is not null) then
         if(ed2 > ed1) then
            intstat := FUTURE;
         else
            intstat := PAST;
         end if;
      else
         intstat := SUCC;
      end if;
   end validate;
end hr_pyoint;

/

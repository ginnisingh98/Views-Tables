--------------------------------------------------------
--  DDL for Package Body PER_GB_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_TERMINATION" as
/* $Header: pergbtem.pkb 120.1 2006/10/26 10:58:50 kthampan noship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  GB Termination package
**
**  Change List
**  ===========
**
**  Date        Author    Version Reference Description
**  ----------+----------+-------+---------+------------------------------------
**  16-MAY-05  K.Thampan  115.0    4351635  Added SSP/SMP recalculation when
**                                          reverse termination.
**  17-MAY-05  K.Thampan  115.1             Added ssp_smp_support_pkg.
**                                          recalculate_ssp_and_smp method
**  24-OCT-06  K.Thampan  115.2             Added validation for P45
-------------------------------------------------------------------------------
*/
-- Gets Person_id for given period_of_service_id

   CURSOR c_get_person_id (c_period_of_service_id per_periods_of_service.period_of_service_id%Type) is
	select ppos.person_id
    	from per_periods_of_service ppos
        where period_of_service_id = c_period_of_service_id;

   PROCEDURE actual_termination(
      p_period_of_service_id per_periods_of_service.period_of_service_id%TYPE,
      p_actual_termination_date per_periods_of_service.actual_termination_date%TYPE)
   IS
   BEGIN
      --  doing no processing here
      hr_utility.set_location('Entering per_gb_termination.actual_termination',10);
      hr_utility.set_location('Leaving pay_gb_termination.actual_termination',100);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error(-20001, SQLERRM(SQLCODE) );
   END actual_termination;

   PROCEDURE Final_termination(   p_period_of_service_id per_periods_of_service.period_of_service_id%TYPE
                                 ,p_final_process_date Date)
   IS
   BEGIN
       --  doing no processing here
      hr_utility.set_location('Entering per_gb_termination.final_termination',10);
      hr_utility.set_location('Leaving pay_gb_termination.final_termination',100);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error(-20001, SQLERRM(SQLCODE) );
   END Final_termination;

   PROCEDURE REVERSE(
      p_period_of_service_id per_periods_of_service.period_of_service_id%TYPE,
      p_actual_termination_date per_periods_of_service.actual_termination_date%TYPE,
      p_leaving_reason per_periods_of_service.leaving_reason%TYPE)
   IS
      l_person_id     per_periods_of_service.person_id%TYPE;
      l_date_of_birth DATE;
      l_token         varchar2(255);
      l_count         number;

   CURSOR c_date_of_birth(p_person_id Number)
   IS
      SELECT date_of_birth
        FROM per_all_people_f
       WHERE person_id = p_person_id
         AND p_actual_termination_date between effective_start_date and effective_end_date;

   CURSOR c_assignment_id(p_person_id number,
                          p_date_active date)
   IS
       SELECT assignment_id, assignment_number
         FROM per_all_assignments_f asg,
              per_assignment_status_types typ
        WHERE asg.person_id = p_person_id
          AND asg.period_of_service_id = p_period_of_service_id
          AND asg.assignment_status_type_id = typ.assignment_status_type_id
          AND typ.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
          AND p_date_active between asg.effective_start_date and asg.effective_end_date
       ORDER BY assignment_id;
--
   BEGIN
      hr_utility.set_location('Entering per_gb_termination.reverse',10);

      if hr_general.g_data_migrator_mode <> 'Y' then
         OPEN c_get_person_id (p_period_of_service_id);
         FETCH c_get_person_id into l_person_id;
         CLOSE c_get_person_id;

         if ssp_ssp_pkg.ssp_is_installed then
            --
            hr_utility.set_location('Checking SSP/SMP Details',20);
            --
            OPEN c_date_of_birth(l_person_id);
            FETCH c_date_of_birth into l_date_of_birth;
            CLOSE c_date_of_birth;

            ssp_smp_pkg.person_control ( l_person_id, p_actual_termination_date);
            ssp_ssp_pkg.person_control ( l_Person_id, p_actual_termination_date, l_date_of_birth);

         end if;
         ssp_smp_support_pkg.recalculate_ssp_and_smp;
         --
         hr_utility.set_location('Checking for P45 Details',20);
         --
         l_count := 0;
         for assignment in c_assignment_id(l_person_id,p_actual_termination_date)
         loop
             if pay_p45_pkg.return_p45_issued_flag(assignment.assignment_id) = 'Y' then
                l_count := l_count + 1;
                l_token := l_token || ', ' || assignment.assignment_number;
             end if;
         end loop;
         if l_count > 0 then
            l_token := substr(l_token,3);
            if l_count > 1 then
               l_token := substr(l_token,1, instr(l_token,',',-1,1) -1) || ' and ' ||
                          substr(l_token,instr(l_token,',',-1,1) + 2);
            end if;
            fnd_message.set_name ('PER', 'HR_GB_78089_P45_ISSUED');
            fnd_message.set_token ('ASG_NUM',l_token);
            fnd_message.raise_error;
         end if;
         --
      end if;
      hr_utility.set_location('Leaving pay_gb_termination.reverse',100);
   END REVERSE;
END per_gb_termination;

/

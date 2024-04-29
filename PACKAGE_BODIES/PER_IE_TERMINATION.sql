--------------------------------------------------------
--  DDL for Package Body PER_IE_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IE_TERMINATION" as
/* $Header: peieterm.pkb 120.1 2006/09/18 08:48:03 spendhar noship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE PAYE package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  15 SEP 2003 srkotwal  N/A        Created for bug 3134506
    24-oct-2003 vmkhande             bug fix for 3208777
    18-SEP-06   spendhar  5472781    Added a check for chk_product_install so that
                                     validation fires only if legislation installed.
-------------------------------------------------------------------------------
*/
-- Gets Person_id for given period_of_service_id

CURSOR c_get_person_id (c_period_of_service_id per_periods_of_service.period_of_service_id%Type) is
	select ppos.person_id
    	from per_periods_of_service ppos
	   where period_of_service_id = c_period_of_service_id;

-- Gets assignment_id from per_all_assignments_f for above generated person_id
CURSOR c_get_asg_id (c_person_id per_periods_of_service.person_id%type,
                     c_effective_date DATE ) is
	select paaf.assignment_id
    	from per_all_assignments_f paaf
	    where paaf.person_id = c_person_id and
              c_effective_date between effective_start_date
                                    and effective_end_date;

   PROCEDURE actual_termination(
      p_period_of_service_id per_periods_of_service.period_of_service_id%TYPE,
      p_actual_termination_date per_periods_of_service.actual_termination_date%TYPE)
   IS
   --end Local vriables---------
   BEGIN
/*
   doing no processing here as we need to set the end dates in
   paye and prsi tables to final process date.
   final process date is not available in this user hook.
   so created another user use which is called by FINAL_PROCESS_DATE
*/
      hr_utility.set_location(
         'Entering pay_ie_termination ....'|| 'per_ie_termination',
         10);
      hr_utility.set_location(
         'Leaving pay_ie_termination ....'|| 'per_ie_termination',
         10);
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error(-20001, SQLERRM(SQLCODE) );
   END actual_termination;

   PROCEDURE Final_termination(   p_period_of_service_id per_periods_of_service.period_of_service_id%TYPE
                                 ,p_final_process_date Date)
   IS
   /*
   cursor csr_asg_id is
   select assignment_id
    from per_assignments_f
        where period_of_service_id = p_period_of_service_id;
    */
-- Get paye_details_id,effective_start_date and effective_end_date for above assignment_id

      CURSOR c_get_paye_details(
        p_assignment_id per_all_assignments_f.assignment_id%TYPE)
      IS
         SELECT   paye_details_id,
                  effective_start_date,
                  effective_end_date
             FROM pay_ie_paye_details_f
            WHERE assignment_id = p_assignment_id AND
                  p_final_process_date BETWEEN effective_start_date
                                                AND effective_end_date
         ORDER BY effective_start_date;

-- Get prsi_details_id,effective_start_date and effective_end_date for above assignment_id
      CURSOR c_get_prsi_details(
         p_assignment_id per_all_assignments_f.assignment_id%TYPE)
      IS
         SELECT   prsi_details_id, effective_start_date, effective_end_date
             FROM pay_ie_prsi_details_f
            WHERE assignment_id = p_assignment_id AND
                  p_final_process_date BETWEEN effective_start_date
                                                AND effective_end_date
         ORDER BY effective_start_date;
      --Local vriables-----
      l_person_id         per_periods_of_service.person_id%TYPE;
--      l_assignment_id     per_all_assignments_f.assignment_id%TYPE;
      l_paye_detail_id    pay_ie_paye_details_f.paye_details_id%TYPE;
      l_paye_start_date   pay_ie_paye_details_f.effective_start_date%TYPE;
      l_paye_end_date     pay_ie_paye_details_f.effective_end_date%TYPE;
      l_prsi_detail_id    pay_ie_prsi_details_f.prsi_details_id%TYPE;
      l_prsi_start_date   pay_ie_prsi_details_f.effective_start_date%TYPE;
      l_prsi_end_date     pay_ie_prsi_details_f.effective_end_date%TYPE;
   --end Local vriables---------
   BEGIN


    /* Added for GSI Bug 5472781 */
    IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN

      hr_utility.set_location(
         'Entering pay_ie_termination ....'|| 'per_ie_termination',
         10);

	    OPEN c_get_person_id (p_period_of_service_id);
	    FETCH c_get_person_id into l_person_id;
	    CLOSE c_get_person_id;
	/*
	    OPEN c_get_asg_id(l_person_id, p_final_process_date);
	    FETCH c_get_asg_id into l_assignment_id;
	    CLOSE c_get_asg_id;
	*/
	    for asg_id in c_get_asg_id(l_person_id, p_final_process_date)
	    loop
	          l_prsi_detail_id := null;
	          l_prsi_start_date := null;
	          l_prsi_end_date := null;
	          l_paye_detail_id := null;
	          l_paye_start_date := null;
	          l_paye_end_date := null;
	        -- Processing PRSI data
	          OPEN c_get_prsi_details(asg_id.assignment_id);
	          FETCH c_get_prsi_details INTO l_prsi_detail_id,
	                                        l_prsi_start_date,
	                                        l_prsi_end_date;

	          UPDATE pay_ie_prsi_details_f
	             SET effective_end_date = p_final_process_date
	           WHERE prsi_details_id = l_prsi_detail_id AND
	                 p_final_process_date BETWEEN effective_start_date
	                                          AND effective_end_date;

	          DELETE FROM pay_ie_prsi_details_f
	                WHERE prsi_details_id = l_prsi_detail_id AND
	                      effective_start_date > p_final_process_date;

	          CLOSE c_get_prsi_details;
	         -- Processing PAYE data
	          OPEN c_get_paye_details(asg_id.assignment_id);
	          FETCH c_get_paye_details INTO l_paye_detail_id,
	                                        l_paye_start_date,
	                                        l_paye_end_date;
	          UPDATE pay_ie_paye_details_f
	             SET effective_end_date = p_final_process_date
	           WHERE paye_details_id = l_paye_detail_id AND
	                 p_final_process_date BETWEEN effective_start_date
	                                          AND effective_end_date;
	          DELETE FROM pay_ie_paye_details_f
	                WHERE paye_details_id = l_paye_detail_id AND
	                      effective_start_date > p_final_process_date;
	          CLOSE c_get_paye_details;
	          hr_utility.set_location(
	             'Leaving pay_ie_termination ....'|| 'per_ie_termination',
	             10);
	   End Loop;

    END IF;  /* Added for GSI Bug 5472781 */

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
      l_person_id         per_periods_of_service.person_id%TYPE;
--      l_assignment_id     per_all_assignments_f.assignment_id%TYPE;
      l_final_process_date DATE;

   CURSOR csr_final_process_date(p_assignment_id Number)
   IS
      SELECT max(effective_end_date)
        FROM pay_ie_paye_details_f
       WHERE assignment_id = p_assignment_id;
--
   BEGIN
      hr_utility.trace('Inside reverse term');

      OPEN c_get_person_id (p_period_of_service_id);
      FETCH c_get_person_id into l_person_id;
      CLOSE c_get_person_id;
/*
      OPEN c_get_asg_id(l_person_id, p_actual_termination_date);
      FETCH c_get_asg_id into l_assignment_id;
      CLOSE c_get_asg_id;
  */
      for asg_id in c_get_asg_id(l_person_id, p_actual_termination_date)
      loop
          l_final_process_date:=null;
          OPEN csr_final_process_date(asg_id.assignment_id);
          FETCH csr_final_process_date INTO l_final_process_date;
          CLOSE csr_final_process_date;
          hr_utility.trace('l_final_process_date' || to_char(l_final_process_date));
--
          UPDATE pay_ie_paye_details_f
             SET effective_end_date = TO_CHAR(hr_general.end_of_time, 'DD-MON-YYYY')
           WHERE assignment_id = asg_id.assignment_id AND
                 l_final_process_date BETWEEN effective_start_date
                                          AND effective_end_date;

          UPDATE pay_ie_prsi_details_f
             SET effective_end_date = TO_CHAR(hr_general.end_of_time, 'DD-MON-YYYY')
           WHERE assignment_id = asg_id.assignment_id AND
                 l_final_process_date BETWEEN effective_start_date
                                          AND effective_end_date;
      End loop;
   END REVERSE;
END per_ie_termination;

/

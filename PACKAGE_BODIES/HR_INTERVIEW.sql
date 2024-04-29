--------------------------------------------------------
--  DDL for Package Body HR_INTERVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INTERVIEW" AS
/* $Header: peintviw.pkb 120.1 2006/01/13 06:10:33 irgonzal noship $ */
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
 Name        : hr_interview (BODY)

 Description : This package declares procedures required to
               INSERT, UPDATE and DELETE Assignment Statuses for
               Applicant Interviews called from PERREAB.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+-----------------------
 70.0    09-FEB-93 PShergill            Date Created
 70.1    11-MAR-93 Nkhan        Added 'exit' to the end
 70.2    17-AUG-93 Nkhan        Added SOURCE_TYPE field
                                        references to per_assignments_f
 70.3    16-JUN-94 PShergill     Fix 220466 added ATTRIBUTE21..30
 70.11   23-NOV-94 RFine         Suppressed index on business_group_id
 115.3   23-DEC-03 bsubrama      Bug 3333891 - Changed the NVL values
                                 for salary rewiew period, performance
                                 review period and pay basis to -99999
                                 rather than ' '. Also made GSCC
                                 compliant.
 115.4   13-Jan-06 irgonzal      Pef bug 4894555. Added function
                                 chk_duplicate.
 ================================================================= */

--
--
------------------- insert_interview -----------------------------
/*
  NAME
     insert_interview

  DESCRIPTION
     Inserts an assignment of type specified in the paramenter list
     starting from applicant interview start date
  PARAMETERS
     p_assignment_id             - assignment_id of applicant
     p_idate                     - New Interview Date
     p_assignment_status_type_id - Assignment Status Type Id of Interview
     p_last_updated_by           - Required for Auditing
     p_last_update_login         - Required for Auditing
*/
PROCEDURE insert_interview
                            (
                             p_assignment_id IN INTEGER,
                             p_idate IN DATE,
                             p_assignment_status_type_id IN INTEGER,
                             p_last_updated_by IN INTEGER,
                             p_last_update_login IN INTEGER
                             ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
   p_int_date DATE;
   p_dummy      VARCHAR2(1);
--
   CURSOR select_ass_for_insert IS
   SELECT *
   FROM   per_assignments_f
   WHERE  assignment_id = p_assignment_id
   FOR UPDATE;
--
--
 BEGIN
--
   p_int_date := p_idate;
--
  BEGIN
  --
  hr_utility.set_location('hr_interview.insert_interview',1);
  --
  -- This for loop has a purpose to the lock all the assignment records
  -- specified by the cursor
  --
  FOR ass_rec_ins IN select_ass_for_insert LOOP
          NULL;
  END LOOP;
  --
  hr_utility.set_location('hr_interview.insert_interview',2);
  --
  SELECT 'Y'
  INTO   p_dummy
  FROM   sys.dual
  WHERE  EXISTS
         ( SELECT '1'
           FROM  per_assignments_f
           WHERE assignment_id = p_assignment_id
           AND   ((effective_end_date <> to_date('31/12/4712','DD/MM/YYYY')
                  AND   effective_end_date >= p_int_date)
                  OR (effective_start_date = p_int_date)));
--
  EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
  END;
  --
  IF p_dummy = 'Y' THEN
     hr_utility.set_message(801,'HR_6456_APP_ASS_FUTURE_CHANGES');
     hr_utility.raise_error;
  END IF;
--
  -- Insert the Interview
         hr_utility.set_location('hr_interview.insert_interview',3);
    --
    INSERT INTO per_assignments_f
    (
          assignment_id
          ,effective_start_date
          ,effective_end_date
          ,business_group_id
          ,grade_id
          ,position_id
          ,job_id
          ,assignment_status_type_id
          ,payroll_id
          ,location_id
          ,person_referred_by_id
          ,person_id
          ,recruitment_activity_id
          ,source_organization_id
          ,organization_id
          ,people_group_id
          ,soft_coding_keyflex_id
          ,vacancy_id
          ,assignment_sequence
          ,assignment_type
          ,manager_flag
          ,primary_flag
          ,application_id
          ,assignment_number
          ,change_reason
          ,comment_id
          ,date_probation_end
          ,default_code_comb_id
          ,frequency
          ,internal_address_line
          ,normal_hours
          ,period_of_service_id
          ,probation_period
          ,probation_unit
          ,recruiter_id
          ,set_of_books_id
          ,special_ceiling_step_id
          ,supervisor_id
          ,time_normal_finish
          ,time_normal_start
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,ass_attribute_category
          ,ass_attribute1
          ,ass_attribute2
          ,ass_attribute3
          ,ass_attribute4
          ,ass_attribute5
          ,ass_attribute6
          ,ass_attribute7
          ,ass_attribute8
          ,ass_attribute9
          ,ass_attribute10
          ,ass_attribute11
          ,ass_attribute12
          ,ass_attribute13
          ,ass_attribute14
          ,ass_attribute15
          ,ass_attribute16
          ,ass_attribute17
          ,ass_attribute18
          ,ass_attribute19
          ,ass_attribute20
          ,ass_attribute21
          ,ass_attribute22
          ,ass_attribute23
          ,ass_attribute24
          ,ass_attribute25
          ,ass_attribute26
          ,ass_attribute27
          ,ass_attribute28
          ,ass_attribute29
          ,ass_attribute30
          ,sal_review_period
          ,sal_review_period_frequency
          ,perf_review_period
          ,perf_review_period_frequency
          ,pay_basis_id
          ,employment_category
          ,bargaining_unit_code
          ,labour_union_member_flag
          ,hourly_salaried_code
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          ,source_type
    )
    SELECT
           assignment_id
          ,effective_start_date
          ,p_int_date - 1
          ,business_group_id
          ,grade_id
          ,position_id
          ,job_id
          ,assignment_status_type_id
          ,payroll_id
          ,location_id
          ,person_referred_by_id
          ,person_id
          ,recruitment_activity_id
          ,source_organization_id
          ,organization_id
          ,people_group_id
          ,soft_coding_keyflex_id
          ,vacancy_id
          ,assignment_sequence
          ,assignment_type
          ,manager_flag
          ,primary_flag
          ,application_id
          ,assignment_number
          ,change_reason
          ,comment_id
          ,date_probation_end
          ,default_code_comb_id
          ,frequency
          ,internal_address_line
          ,normal_hours
          ,period_of_service_id
          ,probation_period
          ,probation_unit
          ,recruiter_id
          ,set_of_books_id
          ,special_ceiling_step_id
          ,supervisor_id
          ,time_normal_finish
          ,time_normal_start
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,ass_attribute_category
          ,ass_attribute1
          ,ass_attribute2
          ,ass_attribute3
          ,ass_attribute4
          ,ass_attribute5
          ,ass_attribute6
          ,ass_attribute7
          ,ass_attribute8
          ,ass_attribute9
          ,ass_attribute10
          ,ass_attribute11
          ,ass_attribute12
          ,ass_attribute13
          ,ass_attribute14
          ,ass_attribute15
          ,ass_attribute16
          ,ass_attribute17
          ,ass_attribute18
          ,ass_attribute19
          ,ass_attribute20
          ,ass_attribute21
          ,ass_attribute22
          ,ass_attribute23
          ,ass_attribute24
          ,ass_attribute25
          ,ass_attribute26
          ,ass_attribute27
          ,ass_attribute28
          ,ass_attribute29
          ,ass_attribute30
          ,sal_review_period
          ,sal_review_period_frequency
          ,perf_review_period
          ,perf_review_period_frequency
          ,pay_basis_id
          ,employment_category
          ,bargaining_unit_code
          ,labour_union_member_flag
          ,hourly_salaried_code
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          ,source_type
          FROM   per_assignments_f
          WHERE  assignment_id = p_assignment_id
     AND    p_int_date
     BETWEEN effective_start_date and effective_end_date;
          --
          IF SQL%ROWCOUNT <> 1 THEN
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','INSERT_INTERVIEW');
             hr_utility.set_message_token('STEP','3');
             hr_utility.raise_error;
          ELSE
            hr_utility.set_location('hr_interview.insert_interview',4);
       --
            UPDATE per_assignments_f
            SET    effective_start_date = p_int_date
            ,      assignment_status_type_id = p_assignment_status_type_id
            ,      last_updated_by = p_last_updated_by
            ,      last_update_login = p_last_update_login
            ,      last_update_date  = sysdate
       WHERE  assignment_id = p_assignment_id
       AND    p_int_date
       BETWEEN effective_start_date and effective_end_date;
       --
       IF SQL%ROWCOUNT <> 1 THEN
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','INSERT_INTERVIEW');
       hr_utility.set_message_token('STEP','4');
            hr_utility.raise_error;
            END IF;
         END IF;
  -- End the insert
 END insert_interview;
--
--
-- --------------------------------------------------------------+
-- ---------------<< chk_duplicate >>----------------------------|
-- --------------------------------------------------------------+
-- Returns 'Y' if previous record matches current record.
-- Otherwise, it returns 'N'.
--
-- Parameters:
-- Name              Description
-- ---------------   -------------------------------------------
-- p_assignment_id   Uniquely identifies an assignment
-- p_effective_date  Date to be used to compare records
-- p_use_asg_date    Determines how to retrieve the previous
--                   record. If TRUE, it uses start date of
--                   current assignment, if FALSE it uses the
--                   effective date - 1.
--
FUNCTION chk_duplicate (p_assignment_id   IN number
                       ,p_effective_date  IN date
                       ,p_use_asg_date    IN boolean) return varchar2 is
--
  l_results varchar2(10);
--
  cursor csr_asg is
    SELECT *
     FROM  per_assignments_f c
    WHERE  c.assignment_id = p_assignment_id
    AND    p_effective_date BETWEEN
           c.effective_start_date AND c.effective_end_date;
  --
  cursor csr_prev_asg(cp_asg_id number, cp_effective_date date, cp_bg_id number) is
    SELECT *
      FROM  per_assignments_f o
    WHERE   o.assignment_id       = cp_asg_id
      AND   o.effective_end_date  = cp_effective_date
      AND   o.business_group_id + 0  = cp_bg_id + 0;
  --
  l_prev_rec          csr_prev_asg%ROWTYPE;
  l_current_asg_rec   csr_asg%ROWTYPE;
  --
begin
  l_results := 'N';
  --
  open csr_asg;
  fetch csr_asg into l_current_asg_rec;
  if csr_asg%FOUND then
    close csr_asg;
    if p_use_asg_date then
      open csr_prev_asg(l_current_asg_rec.assignment_id,
                        l_current_asg_rec.effective_start_date -1,
                        l_current_asg_rec.business_group_id);
    else
      open csr_prev_asg(l_current_asg_rec.assignment_id,
                        p_effective_date -1,
                        l_current_asg_rec.business_group_id);
    end if;
    LOOP
      fetch csr_prev_asg into l_prev_rec;
      exit when csr_prev_asg%NOTFOUND or l_results = 'Y';
       if   NVL(l_prev_rec.grade_id,-99999)              = NVL(l_current_asg_rec.grade_id,-99999)
       AND  NVL(l_prev_rec.position_id,-99999)           = NVL(l_current_asg_rec.position_id,-99999)
       AND  NVL(l_prev_rec.job_id,-99999)                = NVL(l_current_asg_rec.job_id,-99999)
       AND  NVL(l_prev_rec.payroll_id,-99999)            = NVL(l_current_asg_rec.payroll_id,-99999)
       AND  NVL(l_prev_rec.location_id,-99999)           = NVL(l_current_asg_rec.location_id,-99999)
       AND  NVL(l_prev_rec.person_referred_by_id,-99999)
              = NVL(l_current_asg_rec.person_referred_by_id,-99999)
       AND    l_prev_rec.person_id                       = l_current_asg_rec.person_id
       AND    NVL(l_prev_rec.recruitment_activity_id,-99999)
              = NVL(l_current_asg_rec.recruitment_activity_id,-99999)
       AND    NVL(l_prev_rec.source_organization_id,-99999)
              = NVL(l_current_asg_rec.source_organization_id,-99999)
       AND    l_prev_rec.organization_id                 = l_current_asg_rec.organization_id
       AND    NVL(l_prev_rec.people_group_id,-99999)     = NVL(l_current_asg_rec.people_group_id,-99999)
       AND    NVL(l_prev_rec.soft_coding_keyflex_id,-99999)
              = NVL(l_current_asg_rec.soft_coding_keyflex_id,-99999)
       AND    NVL(l_prev_rec.vacancy_id,-99999)          = NVL(l_current_asg_rec.vacancy_id,-99999)
       AND    l_prev_rec.assignment_sequence             = l_current_asg_rec.assignment_sequence
       AND    l_prev_rec.assignment_type                 = l_current_asg_rec.assignment_type
       AND    l_prev_rec.manager_flag                    = l_current_asg_rec.manager_flag
       AND    l_prev_rec.primary_flag                    = l_current_asg_rec.primary_flag
       AND    NVL(l_prev_rec.application_id,-99999)      = NVL(l_current_asg_rec.application_id,-99999)
       AND    NVL(l_prev_rec.assignment_number,' ')      = NVL(l_current_asg_rec.assignment_number,' ')
       AND    NVL(l_prev_rec.change_reason,' ')          = NVL(l_current_asg_rec.change_reason,' ')
       AND    NVL(l_prev_rec.comment_id,-99999)          = NVL(l_current_asg_rec.comment_id,-99999)
       AND    NVL(l_prev_rec.date_probation_end,to_date('01/01/0001','DD/MM/YYYY'))
              = NVL(l_current_asg_rec.date_probation_end,to_date('01/01/0001','DD/MM/YYYY'))
       AND    NVL(l_prev_rec.default_code_comb_id,-99999)
              = NVL(l_current_asg_rec.default_code_comb_id,-99999)
       AND    NVL(l_prev_rec.frequency,' ')                = NVL(l_current_asg_rec.frequency,' ')
       AND    NVL(l_prev_rec.internal_address_line,' ')    = NVL(l_current_asg_rec.internal_address_line,' ')
       AND    NVL(l_prev_rec.normal_hours,-99999.99)       = NVL(l_current_asg_rec.normal_hours,-99999.99)
       AND    NVL(l_prev_rec.period_of_service_id,-99999)
              = NVL(l_current_asg_rec.period_of_service_id,-99999)
       AND    NVL(l_prev_rec.probation_period,-99999.99)
              = NVL(l_current_asg_rec.probation_period,-99999.99)
       AND    NVL(l_prev_rec.probation_unit,' ')           = NVL(l_current_asg_rec.probation_unit,' ')
       AND    NVL(l_prev_rec.recruiter_id,-99999)          = NVL(l_current_asg_rec.recruiter_id,-99999)
       AND    NVL(l_prev_rec.set_of_books_id,-99999)       = NVL(l_current_asg_rec.set_of_books_id,-99999)
       AND    NVL(l_prev_rec.special_ceiling_step_id,-99999)
              = NVL(l_current_asg_rec.special_ceiling_step_id,-99999)
       AND    NVL(l_prev_rec.supervisor_id,-99999)         = NVL(l_current_asg_rec.supervisor_id,-99999)
       AND    NVL(l_prev_rec.time_normal_finish,' ')       = NVL(l_current_asg_rec.time_normal_finish,' ')
       AND    NVL(l_prev_rec.time_normal_start,' ')        = NVL(l_current_asg_rec.time_normal_start,' ')
       AND    NVL(l_prev_rec.source_type,' ')              = NVL(l_current_asg_rec.source_type,' ')
       AND    NVL(l_prev_rec.ass_attribute_category,' ')
              = NVL(l_current_asg_rec.ass_attribute_category,' ')
       AND    NVL(l_prev_rec.ass_attribute1|| l_prev_rec.ass_attribute2|| l_prev_rec.ass_attribute3||
                  l_prev_rec.ass_attribute4|| l_prev_rec.ass_attribute5|| l_prev_rec.ass_attribute6||
                  l_prev_rec.ass_attribute7|| l_prev_rec.ass_attribute8|| l_prev_rec.ass_attribute9||
                  l_prev_rec.ass_attribute10|| l_prev_rec.ass_attribute11|| l_prev_rec.ass_attribute12||
                  l_prev_rec.ass_attribute13|| l_prev_rec.ass_attribute14|| l_prev_rec.ass_attribute15||
                  l_prev_rec.ass_attribute16|| l_prev_rec.ass_attribute17|| l_prev_rec.ass_attribute18||
                  l_prev_rec.ass_attribute19|| l_prev_rec.ass_attribute20|| l_prev_rec.ass_attribute21||
                  l_prev_rec.ass_attribute22|| l_prev_rec.ass_attribute23|| l_prev_rec.ass_attribute24||
                  l_prev_rec.ass_attribute25|| l_prev_rec.ass_attribute26|| l_prev_rec.ass_attribute27||
                  l_prev_rec.ass_attribute28|| l_prev_rec.ass_attribute29|| l_prev_rec.ass_attribute30,' ') =
              NVL(l_current_asg_rec.ass_attribute1|| l_current_asg_rec.ass_attribute2|| l_current_asg_rec.ass_attribute3||
                  l_current_asg_rec.ass_attribute4|| l_current_asg_rec.ass_attribute5|| l_current_asg_rec.ass_attribute6||
                  l_current_asg_rec.ass_attribute7|| l_current_asg_rec.ass_attribute8|| l_current_asg_rec.ass_attribute9||
                  l_current_asg_rec.ass_attribute10|| l_current_asg_rec.ass_attribute11|| l_current_asg_rec.ass_attribute12||
                  l_current_asg_rec.ass_attribute13|| l_current_asg_rec.ass_attribute14|| l_current_asg_rec.ass_attribute15||
                  l_current_asg_rec.ass_attribute16|| l_current_asg_rec.ass_attribute17|| l_current_asg_rec.ass_attribute18||
                  l_current_asg_rec.ass_attribute19|| l_current_asg_rec.ass_attribute20|| l_current_asg_rec.ass_attribute21||
                  l_current_asg_rec.ass_attribute22|| l_current_asg_rec.ass_attribute23|| l_current_asg_rec.ass_attribute24||
                  l_current_asg_rec.ass_attribute25|| l_current_asg_rec.ass_attribute26|| l_current_asg_rec.ass_attribute27||
                  l_current_asg_rec.ass_attribute28|| l_current_asg_rec.ass_attribute29|| l_current_asg_rec.ass_attribute30,' ')
        AND    NVL(l_prev_rec.sal_review_period,-99999) = NVL(l_current_asg_rec.sal_review_period,-99999) -- Bug 3333891
        AND    NVL(l_prev_rec.sal_review_period_frequency,' ') = NVL(l_current_asg_rec.sal_review_period_frequency,' ')
        AND    NVL(l_prev_rec.perf_review_period,-99999) = NVL(l_current_asg_rec.perf_review_period,-99999) -- Bug 3333891
        AND    NVL(l_prev_rec.perf_review_period_frequency,' ') = NVL(l_current_asg_rec.perf_review_period_frequency,' ')
        AND    NVL(l_prev_rec.pay_basis_id,-99999) = NVL(l_current_asg_rec.pay_basis_id,-99999) -- Bug 3333891
        AND    NVL(l_prev_rec.employment_category,' ') = NVL(l_current_asg_rec.employment_category,' ')
        AND    NVL(l_prev_rec.bargaining_unit_code,' ')  = NVL(l_current_asg_rec.bargaining_unit_code,' ')
        AND    NVL(l_prev_rec.labour_union_member_flag,' ') = NVL(l_current_asg_rec.labour_union_member_flag,' ')
        AND    NVL(l_prev_rec.hourly_salaried_code,' ') = NVL(l_current_asg_rec.hourly_salaried_code,' ')
      THEN
        l_results := 'Y';
      END IF;

    end loop;
    close csr_prev_asg;
  else
    close csr_asg;
  end if;
  --
  RETURN l_results;
  --
END chk_duplicate;
--
------------------- delete_interview -----------------------------
/*
  NAME
     delete_interview
  DESCRIPTION
     Deletes assignment for associated applicant interview
  PARAMETERS
     p_assignment_id             - assignment_id of applicant
     p_idate                     - New Interview Date
     p_last_updated_by           - Required for Auditing
     p_last_update_login         - Required for Auditing
*/
PROCEDURE delete_interview
                            (p_assignment_id IN INTEGER,
                             p_idate IN DATE,
                             p_last_updated_by IN INTEGER,
                             p_last_update_login IN INTEGER
                             ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
   p_int_date             DATE;
   p_dummy_date           DATE;
   p_dummy                VARCHAR2(1);
   p_dummy_x                VARCHAR2(1);
   p_previous_status      INTEGER;
   p_old_interview_status INTEGER;
   p_nxt_interview_date   DATE;
   p_new_status_type_date DATE;
--
   CURSOR select_ass_for_delete IS
   SELECT *
   FROM   per_assignments_f
   WHERE  assignment_id = p_assignment_id
   FOR UPDATE;
--
 BEGIN
 --
   p_int_date := p_idate;
   p_dummy    := 'N';
  --
  -- Check if status was the only field to change
  -- IF it is then CASE A B and C
  --
  -- CASE A B C D
  hr_utility.set_location('hr_interview.delete_interview',1);
  --
  -- This for loop has a purpose to the lock all the assignment records
  -- specified by the cursor
  FOR ass_rec_del IN select_ass_for_delete LOOP
          NULL;
  END LOOP;
  --
  hr_utility.set_location('hr_interview.delete_interview',2);
  --
  -- #4894555: replaced SQL statement with function call.
  --
  p_dummy := chk_duplicate(p_assignment_id, p_int_date, TRUE);
  --
  hr_utility.set_location('hr_interview.delete_interview',25);
   --
   --
   BEGIN
   --
     hr_utility.set_location('hr_interview.delete_interview',3);
     --
     SELECT a.assignment_status_type_id
     INTO   p_old_interview_status
     FROM   per_assignments_f a
     WHERE  a.assignment_id = p_assignment_id
     AND    a.effective_start_date = p_int_date;
   --
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','DELETE_INTERVIEW');
            hr_utility.set_message_token('STEP','2');
            hr_utility.raise_error;
   END;
   --
   IF p_dummy = 'Y' THEN
   --
      --
      -- set the end date of the previous row to the
      -- effective end date of the row that begins on the
      -- interview start date
      -- Done For CASE A, B, and C
      --
      -- delete the row that has effective start date = interview start date
      -- done For CASE A, B, and C
      --
      hr_utility.set_location('hr_interview.delete_interview',4);
      --
      UPDATE per_assignments_f a
      SET    effective_end_date = (SELECT effective_end_date
                                   FROM   per_assignments_f b
                                   WHERE  b.assignment_id = p_assignment_id
                                   AND    b.effective_start_date =
                                          p_int_date)
      ,      last_updated_by = p_last_updated_by
      ,      last_update_login = p_last_update_login
      ,      last_update_date  = sysdate
      WHERE  a.assignment_id = p_assignment_id
      AND    a.effective_end_date = p_int_date -1;
      --
      IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','DELETE_INTERVIEW');
            hr_utility.set_message_token('STEP','3');
            hr_utility.raise_error;
      END IF;
      --
      hr_utility.set_location('hr_interview.delete_interview',5);
      --
      DELETE per_assignments_f a
      WHERE  a.assignment_id = p_assignment_id
      AND    a.effective_start_date = p_int_date;
      --
      IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','DELETE_INTERVIEW');
            hr_utility.set_message_token('STEP','4');
            hr_utility.raise_error;
      END IF;
   --
   END IF;
   --
   --
   -- Check for CASE A if effective_end_date = EOT then no need to ripple
   --
   BEGIN
   --
   hr_utility.set_location('hr_interview.delete_interview',6);
   --
   SELECT a.effective_end_date
   INTO   p_dummy_date
   FROM   per_assignments_f a
   WHERE  a.assignment_id = p_assignment_id
   AND    p_int_date BETWEEN a.effective_start_date AND a.effective_end_date;
   --
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','DELETE_INTERVIEW');
          hr_utility.set_message_token('STEP','5');
          hr_utility.raise_error;
   END;
   --
   IF p_dummy_date = TO_DATE('31/12/4712','DD/MM/YYYY') AND
      p_dummy = 'N' THEN
      --
      BEGIN
      --
      -- CASE D when the last record no need to ripple forward.
      --
      hr_utility.set_location('hr_interview.delete_interview',7);
      --
      SELECT d.assignment_status_type_id
      INTO   p_previous_status
      FROM   per_assignments_f d
      WHERE  d.assignment_id  = p_assignment_id
      AND    d.effective_end_date = p_int_date -1;
      --
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
                hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE','DELETE_INTERVIEW');
                hr_utility.set_message_token('STEP','6');
                hr_utility.raise_error;
      END;
      --
      UPDATE per_assignments_f a
      SET    assignment_status_type_id = p_previous_status
      ,      last_updated_by = p_last_updated_by
      ,      last_update_login = p_last_update_login
      ,      last_update_date  = sysdate
      WHERE  a.assignment_id = p_assignment_id
      AND    a.effective_start_date = p_int_date;
      --
   END IF;
   --
   IF p_dummy_date <> TO_DATE('31/12/4712','DD/MM/YYYY') THEN
   --
      -- Test for Case C and D a new assignment corresponds to start date of
      -- another interview.
      --
      hr_utility.set_location('hr_interview.delete_interview',8);
      --
      SELECT MIN(e.date_start)
      INTO   p_nxt_interview_date
      FROM   per_events e
      WHERE  e.assignment_id = p_assignment_id
      AND    e.date_start > p_int_date;
      --
      hr_utility.trace('p_nxt_interview_date '||
                    substr(to_char(p_nxt_interview_date,'DD-MON-YYYY'),1,11));
      --
      -- Test for Case B and D the assignment status changes.
      --
      -- Get previous status
      --
      IF p_dummy = 'Y' THEN
      --
         BEGIN
         --
         hr_utility.set_location('hr_interview.delete_interview',9);
         --
         SELECT d.assignment_status_type_id
         INTO   p_previous_status
         FROM   per_assignments_f d
         WHERE  d.assignment_id  = p_assignment_id
         AND    p_int_date
                BETWEEN d.effective_start_date AND d.effective_end_date;
         --
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
                hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE','DELETE_INTERVIEW');
                hr_utility.set_message_token('STEP','7');
                hr_utility.raise_error;
         END;
      --
      ELSE
      --
         BEGIN
         --
         hr_utility.set_location('hr_interview.delete_interview',10);
         --
         SELECT d.assignment_status_type_id
         INTO   p_previous_status
         FROM   per_assignments_f d
         WHERE  d.assignment_id  = p_assignment_id
         AND    d.effective_end_date = p_int_date -1;
         --
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
                hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
                hr_utility.set_message_token('PROCEDURE','DELETE_INTERVIEW');
                hr_utility.set_message_token('STEP','8');
                hr_utility.raise_error;
         END;
      --
      END IF;
      --
      hr_utility.trace('p_previous_status '|| p_previous_status);
      hr_utility.trace('p_old_interview_status '|| p_old_interview_status);
      --
      hr_utility.set_location('hr_interview.delete_interview',11);
      --
      SELECT MIN(c.effective_start_date)
      INTO   p_new_status_type_date
      FROM   per_assignments_f c
      WHERE  c.assignment_id = p_assignment_id
      AND    c.effective_start_date > p_int_date
      AND    c.assignment_status_type_id <> p_old_interview_status;
      --
      hr_utility.trace('p_new_status_type_date '||
                    substr(to_char(p_new_status_type_date,'DD-MON-YYYY'),1,11));
      --
      -- Ripple the pre interview status CASE B,C and D.
      --
      hr_utility.set_location('hr_interview.delete_interview',12);
      --
      UPDATE per_assignments_f a
      SET    assignment_status_type_id = p_previous_status
      ,      last_updated_by = p_last_updated_by
      ,      last_update_login = p_last_update_login
      ,      last_update_date  = sysdate
      WHERE a.assignment_id = p_assignment_id
      AND   a.effective_start_date >= p_int_date
      AND  ((a.effective_end_date <  least(nvl(p_nxt_interview_date,
                                    to_date('31/12/4712','DD/MM/YYYY')),
                                    nvl(p_new_status_type_date,
                                    to_date('31/12/4712','DD/MM/YYYY')))));
      --
      IF SQL%ROWCOUNT = 0 THEN
      --
      hr_utility.set_location('hr_interview.delete_interview',13);
      --
        IF p_nxt_interview_date IS NULL AND p_new_status_type_date IS NULL THEN
        --
          hr_utility.set_location('hr_interview.delete_interview',14);
          --
          UPDATE per_assignments_f a
          SET    assignment_status_type_id = p_previous_status
          ,      last_updated_by = p_last_updated_by
          ,      last_update_login = p_last_update_login
          ,      last_update_date  = sysdate
          WHERE a.assignment_id = p_assignment_id
          AND   a.effective_start_date >= p_int_date
          AND   a.effective_end_date = to_date('31/12/4712','DD/MM/YYYY');
        --
        END IF;
      --
      END IF;
      --
   END IF;
   --
END delete_interview;
------------------- update_interview -------------------------------
/*
  NAME
       update_interview
  DESCRIPTION
       Update assignment for associated applicant interview
  PARAMETERS
     p_assignment_id             - assignment_id of applicant
     p_idate                     - New Interview Date
     p_odate                     - Old Interview Date
     p_last_updated_by           - Required for Auditing
     p_last_update_login         - Required for Auditing
*/
PROCEDURE update_interview
                            (p_assignment_id IN INTEGER,
                             p_idate IN DATE,
                             p_odate IN DATE,
                             p_last_updated_by IN INTEGER,
                             p_last_update_login IN INTEGER
                             ) IS
-----------------------------------------------------------
-- DECLARE THE LOCAL VARIABLES
-----------------------------------------------------------
   p_int_date             DATE;
   p_old_int_date         DATE;
   p_old_prev_start_date  DATE;
   p_dummy_date           DATE;
   p_dummy                VARCHAR2(1);
   p_matches              VARCHAR2(1);
   p_no_update            VARCHAR2(1);
   p_ass_status_type_id   INTEGER;
 --
   CURSOR select_ass_for_update IS
   SELECT *
   FROM   per_assignments_f
   WHERE  assignment_id = p_assignment_id
   FOR UPDATE;
--
 BEGIN
 --
   p_int_date := p_idate;
   p_old_int_date := p_odate;
   p_no_update    := 'N';
   p_dummy        := 'N';
   p_matches      := 'N';
  --
  BEGIN
  --
  hr_utility.set_location('hr_interview.update_interview',1);
  --
  -- This for loop has a purpose to the lock all the assignment records
  -- specified by the cursor
  --
  FOR ass_rec_upd IN select_ass_for_update LOOP
          NULL;
  END LOOP;
  --
  hr_utility.set_location('hr_interview.update_interview',2);
  --
  SELECT 'Y'
  INTO   p_no_update
  FROM   sys.dual
  WHERE  EXISTS
  (SELECT '1'
   FROM per_assignments_f a
   WHERE a.assignment_id = p_assignment_id
   AND (((a.effective_start_date
          BETWEEN p_old_int_date + 1 AND p_int_date -1)
          AND     p_old_int_date < p_int_date)
          OR
         ((a.effective_start_date
           BETWEEN p_int_date AND p_old_int_date -1)
           AND     p_old_int_date > p_int_date)));
  --
  EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
  END;
  --
  IF p_no_update = 'Y' THEN /* CASE D or E */
     hr_utility.set_message(801,'HR_6629_APPL_STATUS_MOVE');
     hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location('hr_interview.update_interview',3);
  --
  -- #4894555: replace SQL with function call.
  --
  p_dummy := chk_duplicate(p_assignment_id, p_old_int_date, FALSE);
  --
  --
  hr_utility.trace('p_dummy is'||p_dummy);
   IF p_dummy = 'Y' THEN
   --
      hr_utility.set_location('hr_interview.update_interview',4);
      BEGIN
      SELECT 'Y'
      INTO p_matches
      FROM per_assignments_f a
      WHERE a.assignment_id = p_assignment_id
      AND   a.effective_start_date = p_int_date;
      EXCEPTION
               WHEN NO_DATA_FOUND THEN NULL;
      END;
      --
      hr_utility.set_location('hr_interview.update_interview',5);
      --
      IF p_matches = 'N' THEN /* CASE A */
      --
         hr_utility.set_location('hr_interview.update_interview',6);
         UPDATE per_assignments_f a
         SET    a.effective_start_date = p_int_date
         ,      a.last_updated_by = p_last_updated_by
         ,      a.last_update_login = p_last_update_login
         ,      a.last_update_date  = sysdate
         WHERE  a.assignment_id = p_assignment_id
         AND    a.effective_start_date = p_old_int_date;
         --
         IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
            hr_utility.set_message_token('STEP','1');
            hr_utility.raise_error;
         END IF;
         --
         hr_utility.set_location('hr_interview.update_interview',7);
         UPDATE per_assignments_f a
         SET    a.effective_end_date = p_int_date -1
         ,      a.last_updated_by = p_last_updated_by
         ,      a.last_update_login = p_last_update_login
         ,      a.last_update_date  = sysdate
         WHERE  a.assignment_id = p_assignment_id
         AND    a.effective_end_date = p_old_int_date -1;
         --
         IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
            hr_utility.set_message_token('STEP','2');
            hr_utility.raise_error;
         END IF;
         --
      ELSE /* CASE C */
         --
         hr_utility.set_location('hr_interview.update_interview',8);
         DELETE per_assignments_f a
         WHERE a.assignment_id = p_assignment_id
         AND a.effective_start_date = p_old_int_date;
         --
         IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
            hr_utility.set_message_token('STEP','3');
            hr_utility.raise_error;
         END IF;
         --
         hr_utility.set_location('hr_interview.update_interview',9);
         UPDATE per_assignments_f a
         SET    a.effective_end_date = p_int_date -1
         ,      a.last_updated_by = p_last_updated_by
         ,      a.last_update_login = p_last_update_login
         ,      a.last_update_date  = sysdate
         WHERE  a.assignment_id = p_assignment_id
         AND    a.effective_end_date = p_old_int_date -1;
         --
         IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
            hr_utility.set_message_token('STEP','4');
            hr_utility.raise_error;
         END IF;
         --
      END IF;
      --
   ELSE  /* CASE B */
   --
      -- check whether insert is forward or backward
      --
      IF p_int_date > p_old_int_date THEN
         --
         p_no_update  := 'N';
         --
         hr_utility.set_location('hr_interview.update_interview',10);
         BEGIN
         --
         SELECT 'Y'
         INTO   p_no_update
         FROM   sys.dual
         WHERE  EXISTS
         (SELECT '1'
          FROM per_assignments_f a
          WHERE a.assignment_id = p_assignment_id
          AND   a.effective_start_date >= p_int_date);
         EXCEPTION
         --
          WHEN NO_DATA_FOUND THEN NULL;
         --
         END;
         --
         IF p_no_update = 'Y' THEN
            hr_utility.set_message(801,'HR_6629_APPL_STATUS_MOVE');
            hr_utility.raise_error;
         END IF;
         --
         hr_utility.set_location('hr_interview.update_interview',11);
         --
         SELECT a.assignment_status_type_id
         INTO   p_ass_status_type_id
         FROM   per_assignments_f a
         WHERE  a.assignment_id = p_assignment_id
         AND    a.effective_end_date = p_old_int_date -1;
         --
         IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
            hr_utility.set_message_token('STEP','5');
            hr_utility.raise_error;
         END IF;
         --
         hr_utility.set_location('hr_interview.update_interview',12);
         --
    INSERT INTO per_assignments_f
    (
          assignment_id
          ,effective_start_date
          ,effective_end_date
          ,business_group_id
          ,grade_id
          ,position_id
          ,job_id
          ,assignment_status_type_id
          ,payroll_id
          ,location_id
          ,person_referred_by_id
          ,person_id
          ,recruitment_activity_id
          ,source_organization_id
          ,organization_id
          ,people_group_id
          ,soft_coding_keyflex_id
          ,vacancy_id
          ,assignment_sequence
          ,assignment_type
          ,manager_flag
          ,primary_flag
          ,application_id
          ,assignment_number
          ,change_reason
          ,comment_id
          ,date_probation_end
          ,default_code_comb_id
          ,frequency
          ,internal_address_line
          ,normal_hours
          ,period_of_service_id
          ,probation_period
          ,probation_unit
          ,recruiter_id
          ,set_of_books_id
          ,special_ceiling_step_id
          ,supervisor_id
          ,time_normal_finish
          ,time_normal_start
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,ass_attribute_category
          ,ass_attribute1
          ,ass_attribute2
          ,ass_attribute3
          ,ass_attribute4
          ,ass_attribute5
          ,ass_attribute6
          ,ass_attribute7
          ,ass_attribute8
          ,ass_attribute9
          ,ass_attribute10
          ,ass_attribute11
          ,ass_attribute12
          ,ass_attribute13
          ,ass_attribute14
          ,ass_attribute15
          ,ass_attribute16
          ,ass_attribute17
          ,ass_attribute18
          ,ass_attribute19
          ,ass_attribute20
          ,ass_attribute21
          ,ass_attribute22
          ,ass_attribute23
          ,ass_attribute24
          ,ass_attribute25
          ,ass_attribute26
          ,ass_attribute27
          ,ass_attribute28
          ,ass_attribute29
          ,ass_attribute30
          ,sal_review_period
          ,sal_review_period_frequency
          ,perf_review_period
          ,perf_review_period_frequency
          ,pay_basis_id
          ,employment_category
          ,bargaining_unit_code
          ,labour_union_member_flag
          ,hourly_salaried_code
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          ,source_type
    )
    SELECT
           assignment_id
          ,p_old_int_date
          ,p_int_date - 1
          ,business_group_id
          ,grade_id
          ,position_id
          ,job_id
          ,p_ass_status_type_id
          ,payroll_id
          ,location_id
          ,person_referred_by_id
          ,person_id
          ,recruitment_activity_id
          ,source_organization_id
          ,organization_id
          ,people_group_id
          ,soft_coding_keyflex_id
          ,vacancy_id
          ,assignment_sequence
          ,assignment_type
          ,manager_flag
          ,primary_flag
          ,application_id
          ,assignment_number
          ,change_reason
          ,comment_id
          ,date_probation_end
          ,default_code_comb_id
          ,frequency
          ,internal_address_line
          ,normal_hours
          ,period_of_service_id
          ,probation_period
          ,probation_unit
          ,recruiter_id
          ,set_of_books_id
          ,special_ceiling_step_id
          ,supervisor_id
          ,time_normal_finish
          ,time_normal_start
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,ass_attribute_category
          ,ass_attribute1
          ,ass_attribute2
          ,ass_attribute3
          ,ass_attribute4
          ,ass_attribute5
          ,ass_attribute6
          ,ass_attribute7
          ,ass_attribute8
          ,ass_attribute9
          ,ass_attribute10
          ,ass_attribute11
          ,ass_attribute12
          ,ass_attribute13
          ,ass_attribute14
          ,ass_attribute15
          ,ass_attribute16
          ,ass_attribute17
          ,ass_attribute18
          ,ass_attribute19
          ,ass_attribute20
          ,ass_attribute21
          ,ass_attribute22
          ,ass_attribute23
          ,ass_attribute24
          ,ass_attribute25
          ,ass_attribute26
          ,ass_attribute27
          ,ass_attribute28
          ,ass_attribute29
          ,ass_attribute30
          ,sal_review_period
          ,sal_review_period_frequency
          ,perf_review_period
          ,perf_review_period_frequency
          ,pay_basis_id
          ,employment_category
          ,bargaining_unit_code
          ,labour_union_member_flag
          ,hourly_salaried_code
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          ,source_type
          FROM   per_assignments_f
          WHERE  assignment_id = p_assignment_id
     AND    effective_start_date = p_old_int_date;
          --
          IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
            hr_utility.set_message_token('STEP','6');
            hr_utility.raise_error;
          ELSE
            hr_utility.set_location('hr_interview.update_interview',13);
            UPDATE per_assignments_f a
            SET    a.effective_start_date = p_int_date
            ,      a.last_updated_by = p_last_updated_by
            ,      a.last_update_login = p_last_update_login
            ,      a.last_update_date  = sysdate
       WHERE  assignment_id = p_assignment_id
       AND    effective_end_date = TO_DATE('31/12/4712','DD/MM/YYYY');
       --
       IF SQL%ROWCOUNT <> 1 THEN
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
          hr_utility.set_message_token('STEP','7');
               hr_utility.raise_error;
            END IF;
          END IF;
      ELSE
         -- insert back in time
         --
         hr_utility.set_location('hr_interview.update_interview',14);
         SELECT a.assignment_status_type_id
         INTO   p_ass_status_type_id
         FROM   per_assignments_f a
         WHERE  a.assignment_id = p_assignment_id
         AND    a.effective_start_date = p_old_int_date;
         --
         IF SQL%ROWCOUNT <> 1 THEN
            hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
            hr_utility.set_message_token('STEP','8');
            hr_utility.raise_error;
         END IF;
         --
         hr_utility.set_location('hr_interview.update_interview',15);
         SELECT a.effective_start_date
         INTO   p_old_prev_start_date
         FROM   per_assignments_f a
         WHERE  a.assignment_id = p_assignment_id
         AND    a.effective_end_date = p_old_int_date -1;
         --
         IF SQL%ROWCOUNT <> 1 THEN
               hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
               hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
               hr_utility.set_message_token('STEP','9');
               hr_utility.raise_error;
         END IF;
         --
   -- Insert the Interview
         hr_utility.set_location('hr_interview.update_interview',16);
    --
    INSERT INTO per_assignments_f
    (
          assignment_id
          ,effective_start_date
          ,effective_end_date
          ,business_group_id
          ,grade_id
          ,position_id
          ,job_id
          ,assignment_status_type_id
          ,payroll_id
          ,location_id
          ,person_referred_by_id
          ,person_id
          ,recruitment_activity_id
          ,source_organization_id
          ,organization_id
          ,people_group_id
          ,soft_coding_keyflex_id
          ,vacancy_id
          ,assignment_sequence
          ,assignment_type
          ,manager_flag
          ,primary_flag
          ,application_id
          ,assignment_number
          ,change_reason
          ,comment_id
          ,date_probation_end
          ,default_code_comb_id
          ,frequency
          ,internal_address_line
          ,normal_hours
          ,period_of_service_id
          ,probation_period
          ,probation_unit
          ,recruiter_id
          ,set_of_books_id
          ,special_ceiling_step_id
          ,supervisor_id
          ,time_normal_finish
          ,time_normal_start
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,ass_attribute_category
          ,ass_attribute1
          ,ass_attribute2
          ,ass_attribute3
          ,ass_attribute4
          ,ass_attribute5
          ,ass_attribute6
          ,ass_attribute7
          ,ass_attribute8
          ,ass_attribute9
          ,ass_attribute10
          ,ass_attribute11
          ,ass_attribute12
          ,ass_attribute13
          ,ass_attribute14
          ,ass_attribute15
          ,ass_attribute16
          ,ass_attribute17
          ,ass_attribute18
          ,ass_attribute19
          ,ass_attribute20
          ,ass_attribute21
          ,ass_attribute22
          ,ass_attribute23
          ,ass_attribute24
          ,ass_attribute25
          ,ass_attribute26
          ,ass_attribute27
          ,ass_attribute28
          ,ass_attribute29
          ,ass_attribute30
          ,sal_review_period
          ,sal_review_period_frequency
          ,perf_review_period
          ,perf_review_period_frequency
          ,pay_basis_id
          ,employment_category
          ,bargaining_unit_code
          ,labour_union_member_flag
          ,hourly_salaried_code
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          ,source_type
    )
    SELECT
           assignment_id
          ,p_int_date
          ,p_old_int_date - 1
          ,business_group_id
          ,grade_id
          ,position_id
          ,job_id
          ,p_ass_status_type_id
          ,payroll_id
          ,location_id
          ,person_referred_by_id
          ,person_id
          ,recruitment_activity_id
          ,source_organization_id
          ,organization_id
          ,people_group_id
          ,soft_coding_keyflex_id
          ,vacancy_id
          ,assignment_sequence
          ,assignment_type
          ,manager_flag
          ,primary_flag
          ,application_id
          ,assignment_number
          ,change_reason
          ,comment_id
          ,date_probation_end
          ,default_code_comb_id
          ,frequency
          ,internal_address_line
          ,normal_hours
          ,period_of_service_id
          ,probation_period
          ,probation_unit
          ,recruiter_id
          ,set_of_books_id
          ,special_ceiling_step_id
          ,supervisor_id
          ,time_normal_finish
          ,time_normal_start
          ,request_id
          ,program_application_id
          ,program_id
          ,program_update_date
          ,ass_attribute_category
          ,ass_attribute1
          ,ass_attribute2
          ,ass_attribute3
          ,ass_attribute4
          ,ass_attribute5
          ,ass_attribute6
          ,ass_attribute7
          ,ass_attribute8
          ,ass_attribute9
          ,ass_attribute10
          ,ass_attribute11
          ,ass_attribute12
          ,ass_attribute13
          ,ass_attribute14
          ,ass_attribute15
          ,ass_attribute16
          ,ass_attribute17
          ,ass_attribute18
          ,ass_attribute19
          ,ass_attribute20
          ,ass_attribute21
          ,ass_attribute22
          ,ass_attribute23
          ,ass_attribute24
          ,ass_attribute25
          ,ass_attribute26
          ,ass_attribute27
          ,ass_attribute28
          ,ass_attribute29
          ,ass_attribute30
          ,sal_review_period
          ,sal_review_period_frequency
          ,perf_review_period
          ,perf_review_period_frequency
          ,pay_basis_id
          ,employment_category
          ,bargaining_unit_code
          ,labour_union_member_flag
          ,hourly_salaried_code
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          ,source_type
          FROM   per_assignments_f
          WHERE  assignment_id = p_assignment_id
     AND    effective_end_date = p_old_int_date -1;
          --
          IF SQL%ROWCOUNT <>1 THEN
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
             hr_utility.set_message_token('STEP','10');
             hr_utility.raise_error;
          ELSE
            hr_utility.set_location('hr_interview.update_interview',17);
       --
            UPDATE per_assignments_f a
            SET    a.effective_end_date = p_int_date -1
            ,      a.last_updated_by = p_last_updated_by
            ,      a.last_update_login = p_last_update_login
            ,      a.last_update_date  = sysdate
       WHERE  assignment_id = p_assignment_id
            AND    effective_start_date = p_old_prev_start_date
       AND    effective_end_date = p_old_int_date -1;
       --
       IF SQL%ROWCOUNT <> 1 THEN
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','UPDATE_INTERVIEW');
          hr_utility.set_message_token('STEP','11');
               hr_utility.raise_error;
            END IF;
         END IF;
         -- End the insert backward
     END IF;
     --     End the insert forward
   END IF;
   --
 END update_interview;
--
--
end hr_interview;

/

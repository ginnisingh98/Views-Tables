--------------------------------------------------------
--  DDL for Package Body PQH_LENGTH_OF_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_LENGTH_OF_SERVICE_PKG" AS
/* $Header: pqlosclc.pkb 120.0 2005/05/29 02:11:12 appldev noship $ */

g_end_of_time     DATE := TO_DATE('31/12/4712','DD/MM/RRRR');
g_package varchar2(30) := 'PQH_LENGTH_OF_SERVICE_PKG.';
g_emp_type        varchar2(30);
g_determination_date DATE;
-- -----------------------------------------------------------------------*
-- FUNCTION get_effective_date
-- This function returns the session date for the Current Session
-- -----------------------------------------------------------------------*

FUNCTION get_effective_date RETURN DATE IS
 l_proc varchar2(60) := g_package||'get_effective_date';
 l_date  DATE;
BEGIN
   SELECT   effective_date
   INTO     l_date
   FROM     fnd_sessions
   WHERE    session_id = USERENV('sessionid');

   RETURN l_date;

EXCEPTION
   When No_Data_Found Then
      l_date := Sysdate;
      RETURN l_date;
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_effective_date;


-- -----------------------------------------------------------------------*
-- PROCEDURE bg_normal_hours
-- This procedure gets the Normal Workd Day Hours, Normal Hours and its Frequency defined
-- at the Business Group level.
-- -----------------------------------------------------------------------*

PROCEDURE bg_normal_hours          (p_bg_id            IN     per_all_organization_units.organization_id%TYPE,
                                    p_bg_normal_day_hours    OUT NOCOPY NUMBER,
                                    p_bg_normal_hours  OUT NOCOPY NUMBER,
                                    p_bg_frequency     OUT NOCOPY VARCHAR2)
IS
l_proc varchar2(60) := g_package||'bg_normal_hours';
l_bg_start_time  VARCHAR2(150);
l_bg_end_time    VARCHAR2(150);

CURSOR Csr_bg_norm_hours IS
  SELECT org_information1,      -- normal start time
         org_information2,      -- normal end time
         NVL(org_information3,0),  -- normal hours
         org_information4   -- frequency
  FROM   hr_organization_information
  WHERE  organization_id = p_bg_id
  AND    org_information_context = 'Work Day Information';
 BEGIN
    OPEN Csr_bg_norm_hours;
    FETCH Csr_bg_norm_hours INTO l_bg_start_time, l_bg_end_time,p_bg_normal_hours, p_bg_frequency;
    CLOSE Csr_bg_norm_hours;
    IF p_bg_normal_hours IS NULL THEN -- if normal working hours not defined then default it to 40 hours per week
       p_bg_normal_hours := 35;
       p_bg_frequency := 'W';
    END IF;
    IF l_bg_start_time IS NOT NULL AND l_bg_end_time IS NOT NULL THEN
         p_bg_normal_day_hours := TO_DATE(l_bg_end_time,'HH24:MI')-TO_DATE(l_bg_start_time,'HH24:MI');--normal work hours per a day
    ELSE
         p_bg_normal_day_hours := 7; -- if not defined, default it to 7 hours per day
    END IF;
 EXCEPTION
   When Others THEN
   p_bg_normal_day_hours := null;
   p_bg_normal_hours := null;
   p_bg_frequency := null;
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
 END;


FUNCTION get_working_time_ratio( p_bg_normal_day IN NUMBER,
                                 p_bg_hours  IN NUMBER,
                                 p_bg_frequency  IN VARCHAR2,
                                 p_asg_hours  IN NUMBER,
                                 p_asg_frequency IN VARCHAR2)
RETURN NUMBER IS
l_proc varchar2(60) := g_package||'get_working_time_ratio';
l_working_time_ratio  NUMBER(4,2) := 1;
l_asg_hours NUMBER(22,3) := 0;
BEGIN
   hr_utility.set_location('Entering '||l_proc,1);
   IF p_bg_frequency = 'D' THEN
      IF p_asg_frequency = 'W' THEN
           l_asg_hours := p_asg_hours/5; --(one week is taken as 5 days)
      ELSIF p_asg_frequency = 'M' THEN
           l_asg_hours := p_asg_hours/20; --(one month is taken as 4 week)
      ELSIF p_asg_frequency = 'Y' THEN
           l_asg_hours := p_asg_hours/240; --(one year is taken as 12 months)
      END IF;
   ELSIF p_bg_frequency = 'W' THEN
       IF p_asg_frequency = 'D' THEN
           l_asg_hours := p_asg_hours * 5;
       ELSIF p_asg_frequency = 'M' THEN
           l_asg_hours := p_asg_hours/4;
       ELSIF p_asg_hours = 'Y' THEN
           l_asg_hours := p_asg_hours/48;
       END IF;
    ELSIF p_bg_frequency = 'M' THEN
       IF p_asg_frequency = 'D' THEN
          l_asg_hours := p_asg_hours*20;
       ELSIF p_asg_frequency = 'W' THEN
          l_asg_hours := p_asg_hours*4;
       ELSIF p_asg_frequency = 'Y' THEN
          l_asg_hours := p_asg_hours/12;
       END IF;
    ELSIF p_bg_frequency = 'Y' THEN
       IF p_asg_frequency = 'D' THEN
          l_asg_hours := p_asg_hours*24;
       ELSIF p_asg_frequency = 'W' THEN
          l_asg_hours := p_asg_hours*48;
       ELSIF p_asg_frequency = 'M' THEN
          l_asg_hours := p_asg_hours*12;
       END IF;
   END IF;
-- calculate the ratio of Assignment hours to the Business group hours (for proportional to Parttime hours)
   l_working_time_ratio := l_asg_hours/p_bg_hours;

   RETURN l_working_time_ratio;
 EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);

END get_working_time_ratio;

-- -----------------------------------------------------------------------*
-- FUNCTION get_employee_type
-- This function returns the agent type (as held in PER_INFORMATION15 of PER_ALL_PEOPLE_F)
-- for the person
-- -----------------------------------------------------------------------*

FUNCTION get_employee_type (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE)
RETURN VARCHAR2 IS
  l_emp_type  per_assignments_f.employee_category%TYPE;
  l_proc varchar2(60) := g_package||'get_emp_type';
  l_leg_code varchar2(30) := 'x';
CURSOR csr_emp_type IS
  SELECT   per.per_information15
  FROM     per_all_people_f per
  WHERE    per.person_id = p_person_id
  AND      p_determination_date between per.effective_start_date and per.effective_end_date;

CURSOR csr_leg_code IS
 SELECT hr_api.return_legislation_code(per.business_group_id)
   FROM per_all_people_f per
  WHERE per.person_id = p_person_id
    AND trunc(sysdate) between per.effective_start_date and per.effective_end_date;

CURSOR csr_emp_catg IS
 SELECT employee_category
   FROM per_all_assignments_f
  WHERE person_id = p_person_id
    AND p_determination_date between effective_start_date and effective_end_date;

BEGIN

    OPEN csr_leg_code;
    FETCH csr_leg_code INTO l_leg_code;
    CLOSE csr_leg_code;

    IF l_leg_code = 'DE' THEN
	OPEN csr_emp_catg;
	FETCH csr_emp_catg INTO l_emp_type;
	CLOSE csr_emp_catg;
	RETURN l_emp_type;
    END IF;

    OPEN csr_emp_type;

    FETCH csr_emp_type INTO l_emp_type;

    CLOSE csr_emp_type;

    IF l_emp_type IS NULL THEN
        hr_utility.set_location ('emp_type is NULL',10);
        RETURN TO_CHAR(NULL);
    END IF;

    hr_utility.set_location ('emp_type is '||l_emp_type||' '||l_proc,10);
    RETURN l_emp_type;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_employee_type;

-- -----------------------------------------------------------------------*
-- FUNCTION get_absent_period
-- This function returns the absence duration to be deducted from the
-- Length of service calculations after evaluating the relevant entitlements.
-- -----------------------------------------------------------------------*


FUNCTION get_absent_period (p_bg_id      IN per_all_organization_units.organization_id%TYPE,
                            p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
                            p_los_type   IN hr_lookups.lookup_code%TYPE,
                            p_start_date IN DATE,
                            p_end_date   IN DATE
                            )
RETURN NUMBER IS

   l_absence_duration   NUMBER(22,3) := 0;
   l_entitlement        NUMBER := 0;
   l_emp_type           VARCHAR2(30);
   l_abs_catg           VARCHAR2(30);
   l_net_absence        NUMBER(22,3) := 0;
   l_abs_hours_to_days  NUMBER(22,3) := 0;
   l_proc varchar2(60) := g_package||'get_absent_period';
-- BG Normaly day info for converting the Absent hours to days
   l_bg_normal_day_hours NUMBER(22,3);
   l_bg_normal_hours     NUMBER(22,3);
   l_bg_normal_frequency VARCHAR2(30);

-- Absence details for the person for the given period
  CURSOR Csr_absence_details IS
      SELECT NVL(aat.absence_category,'*') ABSENCE_CATEGORY,
             NVL(paa.absence_days,0) ABSENCE_DAYS,
             NVL(paa.absence_hours,0) ABSENCE_HOURS,
             paa.date_start,
             paa.date_end
      FROM   per_absence_attendances paa,
             per_absence_attendance_types aat
      WHERE  paa.business_group_id = p_bg_id
      AND    paa.person_id  =  p_person_id
      AND   ( paa.date_start BETWEEN p_start_date AND  p_end_date
      OR      paa.date_end   BETWEEN p_start_date AND  p_end_date)
      AND    paa.absence_attendance_type_id = aat.absence_attendance_type_id;

-- entitlement for the employee category, for the given LOS type, for the give absence type
   CURSOR Csr_absence_entitlements (p_abs_catg VARCHAR2, p_emp_type VARCHAR2) IS
      SELECT NVL(entitlement_value,0)
      FROM   pqh_situations
      WHERE  business_group_id = p_bg_id
      AND    situation_type = 'ABSENCE'
      AND    length_of_service = p_los_type
      AND    situation = p_abs_catg
      AND    employee_type = p_emp_type
      AND    g_determination_date BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time)
      AND    entitlement_flag = 'Y';
BEGIN
    hr_utility.set_location('Entering '||l_proc,1);
-- get the BG normal day hours for converting absence hours to days
    bg_normal_hours(p_bg_id => p_bg_id,
                    p_bg_normal_day_hours => l_bg_normal_day_hours,
                    p_bg_normal_hours  => l_bg_normal_hours,
                    p_bg_frequency     => l_bg_normal_frequency);
    l_emp_type := g_emp_type;

    IF l_emp_type IS NOT NULL THEN

        FOR lr_absence IN Csr_absence_details
        LOOP
          l_absence_duration := 0;
          l_entitlement := 0;
          l_abs_hours_to_days := lr_absence.absence_hours/l_bg_normal_day_hours;-- take into account the absent hours
          l_absence_duration  := lr_absence.absence_days + l_abs_hours_to_days;
          l_abs_catg   :=         lr_absence.absence_category;
          OPEN Csr_absence_entitlements(l_abs_catg,l_emp_type);
          FETCH Csr_absence_entitlements INTO l_entitlement;
          CLOSE Csr_absence_entitlements;
          l_net_absence := l_net_absence + (l_absence_duration * (1-(NVL(l_entitlement,0)/100)) );
        END LOOP;
     END IF;
        hr_utility.set_location(l_proc||' Net Absence Duration '||l_net_absence,2);
        RETURN l_net_absence;
 EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
  END get_absent_period;

-- -----------------------------------------------------------------------*
-- FUNCTION get_parttime_entitlement
-- This function returns the parttime entitlement defined for the
-- the assignment.
-- -----------------------------------------------------------------------*

FUNCTION get_parttime_entitlement(p_person_id      IN per_all_assignments_f.person_id%TYPE,
                                  p_assignment_id  IN per_all_assignments_f.assignment_id%TYPE,
                                  p_bg_id          IN per_all_organization_units.organization_id%TYPE,
                                  p_los_type       IN hr_lookups.lookup_code%TYPE,
                                  p_start_date     IN DATE,
                                  p_end_date       IN DATE)

RETURN NUMBER IS
   l_emp_type             per_assignments_f.employee_category%TYPE;
   l_emp_catg             per_assignments_f.employment_category%TYPE;
   l_entitlement_flag     VARCHAR2(30);
   l_work_proportional    VARCHAR2(30) ;
   l_parttime_entitlement NUMBER(22,3) := 0;
   l_bg_normal_day        NUMBER(22,3) := 0;
   l_bg_hours             NUMBER(22,3) := 0;
   l_bg_frequency         VARCHAR2(30);
   l_temp_duration        NUMBER(22,3) := 0;
   l_asg_duration         NUMBER(22,3) := 0;
   l_proc varchar2(60) := g_package||'get_parttime_entitlement';

   CURSOR Csr_employment_category IS
   SELECT  NVL(asg.employment_category,'$#') EMPLOYMENT_CATEGORY,
           asg.effective_start_date,
           asg.effective_end_date,
           NVL(asg.normal_hours,0) NORMAL_HOURS,
           asg.frequency
   FROM    per_all_assignments_f asg
   WHERE   asg.assignment_id = p_assignment_id
   AND    (p_end_date BETWEEN asg.effective_start_date  AND asg.effective_end_date
   OR     p_start_date BETWEEN  asg.effective_start_date AND asg.effective_end_date);


-- entitlement for the employee type, for the given LOS type, for the given Employment Category
   CURSOR Csr_parttime_entitlements IS
      SELECT NVL(worktime_proportional,'N'),
             NVL(entitlement_value,0)
      FROM   pqh_situations
      WHERE  business_group_id = p_bg_id
      AND    situation_type = 'PARTTIME'
      AND    length_of_service = p_los_type
--      AND    NVL(situation,'PT') = l_emp_catg
      AND    employee_type = l_emp_type
      AND    entitlement_flag = 'Y'
      AND    g_determination_date BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time);
BEGIN
     hr_utility.set_location('Entering '||l_proc,1);
     bg_normal_hours(p_bg_id, l_bg_normal_day, l_bg_hours,l_bg_frequency);
     hr_utility.set_location(l_proc||' BG Normal Hours '||l_bg_hours||'Determination Date'||to_char(p_end_date,'dd-mm-RRRR')||l_bg_frequency,2);
     hr_utility.set_location(l_proc||'Determination Date'||to_char(p_end_date,'dd-mm-RRRR')||l_bg_frequency,2);
     l_emp_type := g_emp_type;

    hr_utility.set_location(l_proc||'Emp Type '||l_emp_type,2);
    hr_utility.set_location(l_proc||'Assignment ID '||p_assignment_id,2);
     IF l_emp_type IS NOT NULL THEN
        FOR lr_employment_catg IN Csr_employment_category
        LOOP
            l_emp_catg := lr_employment_catg.employment_category;
            IF lr_employment_catg.effective_end_date > p_end_date THEN
               lr_employment_catg.effective_end_date := p_end_date;
            END IF;
            IF lr_employment_catg.effective_start_date < p_start_date THEN
               lr_employment_catg.effective_start_date := p_start_date;
            END IF;

            hr_utility.set_location(l_proc||' period '||to_char(lr_employment_catg.effective_start_date,'dd-mm-RRRR')||to_char(lr_employment_catg.effective_end_date,'dd-mm-RRRR'),3);
            l_temp_duration := lr_employment_catg.effective_end_date - lr_employment_catg.effective_start_date+1;
            hr_utility.set_location(l_proc||' temp duration'||l_temp_duration,3);
            IF l_emp_catg IN ('PT','PR') THEN

               hr_utility.set_location(l_proc,3);
               OPEN Csr_parttime_entitlements;
               FETCH Csr_parttime_entitlements INTO l_work_proportional,
                                                    l_parttime_entitlement;
               IF csr_parttime_entitlements%FOUND THEN
		       IF l_work_proportional = 'Y' THEN
			   IF lr_employment_catg.frequency = l_bg_frequency THEN
			       l_parttime_entitlement := lr_employment_catg.normal_hours/l_bg_hours;
			   ELSE
			       l_parttime_entitlement := get_working_time_ratio( p_bg_normal_day => l_bg_normal_day,
										 p_bg_hours => l_bg_hours,
										 p_bg_frequency => l_bg_frequency,
										 p_asg_hours => lr_employment_catg.normal_hours,
										 p_asg_frequency => lr_employment_catg.frequency);
			   END IF;
		       END IF;
                       l_temp_duration := l_temp_duration * NVL(l_parttime_entitlement,0)/100;
                ELSE
                       l_temp_duration := 0; -- don't count the entire duration if not entitled.
                END IF;

               CLOSE Csr_parttime_entitlements;

             END IF;
             hr_utility.set_location(l_proc||' l_asg_duration in loop '||l_asg_duration,2);
             l_asg_duration := l_asg_duration + l_temp_duration;
          END LOOP;
      ELSE
          l_asg_duration := p_end_date - p_start_date;
      END IF;
       hr_utility.set_location(l_proc||' returning duration '||l_asg_duration,2);
       RETURN l_asg_duration;
 EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_parttime_entitlement;

-- -----------------------------------------------------------------------*
-- FUNCTION get_previous_employment
-- This function returns the previous employment duration to be taken into
-- while calculating the LOS.
-- -----------------------------------------------------------------------*

FUNCTION get_previous_employment(p_person_id     IN per_all_people_f.person_id%TYPE,
                                 p_assignment_id IN per_assignments_f.assignment_id%TYPE,
                                 p_start_date   IN DATE,
                                 p_end_date     IN DATE) RETURN NUMBER IS
l_prev_emp_period   NUMBER(22,3) := 0;
   l_proc varchar2(60) := g_package||'get_previous_employment';

BEGIN
     hr_utility.set_location('Entering '||l_proc,1);
     RETURN l_prev_emp_period;
 EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END;

-- -----------------------------------------------------------------------*
-- FUNCTION get_previous_employment
-- This function returns the length of previous employment to be taken into
-- while calculating the LOS for French Public Sector.
-- -----------------------------------------------------------------------*

FUNCTION get_length_previous_employment(p_person_id     IN per_all_people_f.person_id%TYPE,
                                 p_bg_id          IN per_all_organization_units.organization_id%TYPE,
                                 p_los_type   IN hr_lookups.lookup_code%TYPE,
                                 p_previous_job_id IN per_previous_jobs.previous_job_id%TYPE
) RETURN NUMBER IS
   l_prev_emp_period    NUMBER(22,3) := 0;
   l_temp_duration      NUMBER(22,3) := 0;
   l_entitlement        NUMBER(22,3) := 0;
   l_proc varchar2(60) := g_package||'get_length_previous_employment';
   l_emp_type           VARCHAR2(30);
   l_start_date         date;
   l_end_date           date;
   l_all_assignments     varchar2(2);
   l_person_id number(10);
   l_corps_id number(10);
   l_grade_id number(10);
   l_step_id number(10);
   l_position_id number(10);

   CURSOR csr_prevemp_entitlements IS
      SELECT situation, NVL(entitlement_value, 0)entitlement_value
      FROM   pqh_situations
      WHERE  business_group_id = p_bg_id
      AND    situation_type = 'EMPLOYMENT'
      AND    length_of_service = p_los_type
      AND    employee_type = l_emp_type
      AND    entitlement_flag = 'Y'
      AND    trunc(sysdate) between effective_start_date and NVL(effective_end_date,g_end_of_time);

    CURSOR csr_prev_job is
    select pem.person_id, pem.business_group_id, pem.all_assignments, nvl(pjo.pjo_information2, 'XX') emp_type, pju.pju_information2 corps_definition_id,
            pju.pju_information3 grade_id, pju.pju_information4 step_id, pju.pju_information5 position_id,
                nvl(pjo.start_date, trunc(sysdate)) pjo_start_date,
                    nvl(pjo.end_date, trunc(sysdate)) pjo_end_date,
                    nvl(pju.start_date, trunc(sysdate)) pju_start_date,
                    nvl(pju.end_date, trunc(sysdate)) pju_end_date
        from per_previous_employers pem, per_previous_jobs pjo, per_previous_job_usages pju
    where
        pem.previous_employer_id = pjo.previous_employer_id(+)
        and
        pjo.previous_job_id = pju.previous_job_id(+)
        and
        pem.person_id = p_person_id
        and
        pjo.previous_job_id = p_previous_job_id;

cursor cur_corps is
select to_number(hsck.segment7) corps_id
from hr_soft_coding_keyflex hsck,
     fnd_id_flex_structures fifs,
     per_all_assignments_f paf,
     per_all_people_f ppf
where hsck.id_flex_num = fifs.id_flex_num
and fifs.id_flex_structure_code = 'FR_STATUTORY_INFO.'
and fifs.application_id = 800
and fifs.id_flex_code = 'SCL'
and hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
and paf.person_id = ppf.person_id
and paf.primary_flag = 'Y'
and sysdate between paf.effective_start_date and paf.effective_end_date
and ppf.person_id = l_person_id;

cursor cur_grade is
select grade_id from
per_all_assignments_f
where person_id = l_person_id
and
primary_flag = 'Y'
and
sysdate between effective_start_date and effective_end_date;

cursor cur_step is
select special_ceiling_step_id from
per_all_assignments_f
where person_id = l_person_id
and
primary_flag = 'Y'
and
sysdate between effective_start_date and effective_end_date;

cursor cur_position is
select position_id from
per_all_assignments_f
where person_id = l_person_id
and
primary_flag = 'Y'
and
sysdate between effective_start_date and effective_end_date;
BEGIN
     hr_utility.set_location('Entering '||l_proc,1);
for prev_job in csr_prev_job loop
l_emp_type := prev_job.emp_type;
l_all_assignments := prev_job.all_assignments;
l_entitlement := 0;
l_temp_duration := 0;
for entitlement in csr_prevemp_entitlements loop
-- Look for the entitlement for this employee type and los type in pqh_situations
l_entitlement := entitlement.entitlement_value;
end loop;
if (l_entitlement <> 0 and l_emp_type <> '02') then
    if p_los_type = '10' then --  General Length of Service
       if l_all_assignments = 'Y' then
            l_temp_duration := prev_job.pjo_end_date-prev_job.pjo_start_date;
       else
            l_temp_duration := prev_job.pju_end_date-prev_job.pju_start_date;
       end if;
    elsif p_los_type = '20' then -- Length of Service in Public Services
       if l_all_assignments = 'Y' then
            l_temp_duration := prev_job.pjo_end_date-prev_job.pjo_start_date;
       else
            l_temp_duration := prev_job.pju_end_date-prev_job.pju_start_date;
       end if;
    elsif p_los_type = '30' then -- Length of Service in Corps
		l_person_id := prev_job.person_id;
		for c_corps in cur_corps loop
		l_corps_id := c_corps.corps_id;
		end loop;

		if l_corps_id = prev_job.corps_definition_id then
	            l_temp_duration := prev_job.pju_end_date-prev_job.pju_start_date;
	         end if;
    elsif p_los_type = '40' then -- Length of Service in Grade
		for c_grade in cur_grade loop
		l_grade_id := c_grade.grade_id;
		end loop;

		if l_grade_id = prev_job.grade_id then
	            l_temp_duration := prev_job.pju_end_date-prev_job.pju_start_date;
	         end if;
    elsif p_los_type = '50' then -- Length of Service in Step
		for c_step in cur_step loop
		l_step_id := c_step.special_ceiling_step_id;
		end loop;

		if l_step_id = prev_job.step_id then
	            l_temp_duration := prev_job.pju_end_date-prev_job.pju_start_date;
	         end if;
    elsif p_los_type = '60' then -- Length of Service in Position
		for c_position in cur_position loop
		l_position_id := c_position.position_id;
		end loop;

		if l_position_id = prev_job.position_id then
	            l_temp_duration := prev_job.pju_end_date-prev_job.pju_start_date;
	         end if;
    end if;

l_temp_duration := trunc(l_entitlement*l_temp_duration/100.0);
end if;
end loop;
      hr_utility.set_location('Leaving from '||l_proc,5);
         RETURN l_temp_duration;
 EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END;

-- -----------------------------------------------------------------------*
-- FUNCTION get_correction_factor
-- This function returns corrected number of days defined for the person
-- in Person EIT FR_PQH_ADDL_SENIORITY_INFO
-- -----------------------------------------------------------------------*


FUNCTION get_correction_factor ( p_person_id   IN per_all_people_f.person_id%TYPE,
                                 p_los_type    IN hr_lookups.lookup_code%TYPE,
                                 p_effective_date  IN DATE)
RETURN NUMBER IS

   l_correct_days   NUMBER(22,3) := 0;
   l_proc varchar2(60) := g_package||'get_correction_factor';

 CURSOR Csr_correction  IS
     SELECT  NVL(fnd_number.canonical_to_number(peit.pei_information4),0)
     FROM    per_people_extra_info peit
     WHERE   peit.person_id = p_person_id
     AND     peit.information_type = 'FR_PQH_ADDL_SENIORITY_INFO'
     AND     peit.pei_information1 = p_los_type
     AND     p_effective_date between fnd_date.canonical_to_date(peit.pei_information2)
     AND     NVL(fnd_date.canonical_to_date(peit.pei_information3),g_end_of_time);
 BEGIN
     hr_utility.set_location('Entering '||l_proc,1);
     OPEN Csr_correction;
     FETCH Csr_correction INTO l_correct_days;
     CLOSE Csr_correction;
     hr_utility.set_location(l_proc||' Correction Factor '||l_correct_days,2);
     RETURN l_correct_days;
 EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
 END get_correction_factor;

-- -----------------------------------------------------------------------*
-- FUNCTION get_military_service_period
-- This function returns corrected number of days in Military Service for the
-- person as held in FR_PQH_BONIFICATION_DETAILS
-- -----------------------------------------------------------------------*
FUNCTION get_military_service_period (p_bg_id         IN   hr_all_organization_units.organization_id%TYPE,
                                      p_person_id     IN   per_all_people_f.person_id%TYPE,
                                      p_assignment_id IN   per_assignments_f.assignment_id%TYPE,
                                      p_los_type      IN   hr_lookups.lookup_code%TYPE,
                                      p_start_date    IN   DATE,
                                      p_end_date      IN   DATE)
RETURN NUMBER IS

l_emp_type   per_assignments_f.employee_category%TYPE;
l_entitlement_value NUMBER(22,3) := 0;
l_proc varchar2(60) := g_package||'get_military_service_period';
l_military_duration    NUMBER(22,3) :=0;

CURSOR csr_military_entitlement IS
      SELECT NVL(entitlement_value,0)
      FROM   pqh_situations
      WHERE  business_group_id = p_bg_id
      AND    situation_type = 'MILITARY'
      AND    length_of_service = p_los_type
      AND    employee_type = l_emp_type
      AND    entitlement_flag = 'Y'
      AND    g_determination_date BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time);

CURSOR csr_military_periods IS
       SELECT NVL(pei_information7,0) LENGTH_OF_SERVICE
       FROM   per_people_extra_info
       WHERE  person_id = p_person_id
       AND    information_type = 'FR_PQH_BONIFICATION_DETAILS'
       AND    (NVL(fnd_date.canonical_to_date(pei_information3),g_end_of_time) BETWEEN p_start_date AND p_end_date
       OR      fnd_date.canonical_to_date(pei_information2) BETWEEN p_start_date AND p_end_date  );

BEGIN
     hr_utility.set_location('Entering '||l_proc,1);
     l_emp_type := get_employee_type(p_person_id  => p_person_id,
                                     p_determination_date => p_end_date);
     hr_utility.set_location(l_proc||' employee type '||l_emp_type||to_char(p_start_date,'dd-mm-RRRR')||to_char(p_end_date,'dd-mm-RRRR'),1);
    IF l_emp_type IS NOT NULL THEN
       OPEN csr_military_entitlement;
       FETCH csr_military_entitlement INTO l_entitlement_value;
       CLOSE csr_military_entitlement;
       hr_utility.set_location(l_proc||' military entitlement '||l_entitlement_value,1);
      	 FOR lr_military IN csr_military_periods
	 LOOP
	     l_military_duration := l_military_duration + fnd_number.canonical_to_number(lr_military.length_of_service)*(NVL(l_entitlement_value,0)/100);
	 END LOOP;
   END IF;
     hr_utility.set_location(l_proc||' Military Duration '||l_military_duration,1);
     RETURN l_military_duration;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_military_service_period;

-- -----------------------------------------------------------------------*
-- FUNCTION get_gen_pub_length_of_service
-- This function returns the general / public length of service for the employee
-- -----------------------------------------------------------------------*

FUNCTION get_gen_pub_length_of_service( p_bg_id               IN   per_all_organization_units.organization_id%TYPE,
 					p_person_id	      IN   per_all_people_f.person_id%TYPE,
					p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE,
					p_los_type            IN   VARCHAR2,
                                        p_determination_date  IN   DATE)
RETURN NUMBER IS
/*
CURSOR csr_asg_period IS
SELECT Min(effective_start_date)
FROM   per_all_assignments_f
WHERE  person_id = p_person_id
AND    assignment_id = p_assignment_id;

*/
-- rewritten the above cursor to consider the service start date as a basis for the General LOS
CURSOR csr_service_start_date IS
   SELECT date_start
   FROM   per_periods_of_service
   WHERE  person_id = p_person_id
   AND    business_group_id = p_bg_id
   AND    p_determination_date BETWEEN date_start AND NVL(actual_termination_date,g_end_of_time);

l_start_date  DATE;
l_asg_duration            NUMBER(22,3) := 0;
l_absent_duration         NUMBER(22,3) := 0;
l_prev_employment         NUMBER(22,3) := 0;
l_correction_factor       NUMBER(22,3) := 0;
l_general_los             NUMBER(22,3) := 0;
l_military_duration       NUMBER(22,3) := 0;
l_parttime_duration       NUMBER(22,3) := 0;
l_proc varchar2(60) := g_package||'get_gen_pub_LOS';

BEGIN
   hr_utility.set_location('Entering '||l_proc,1);
   OPEN csr_service_start_date;
   FETCH csr_service_start_date INTO l_start_date;
   CLOSE csr_service_start_date;
   hr_utility.set_location(l_proc,2);
-- get the actual assignment period
   hr_utility.set_location(l_proc||'person_id'||p_person_id||'assignment_id'||p_assignment_id||'start_date '||to_char(l_start_date,'dd-mm-RRRR'),3);
   l_asg_duration := p_determination_date - l_start_date+1;
   hr_utility.set_location(l_proc||' Assignment duration '||l_asg_duration,2);
-- findout any Impact because of Parttime entitlements defined for the LOS type
   l_parttime_duration := get_parttime_entitlement(p_person_id      => p_person_id,
                                                   p_assignment_id  => p_assignment_id,
                                                   p_bg_id          => p_bg_id,
                                                   p_los_type       => p_los_type,
                                                   p_start_date     => l_start_date,
                                                   p_end_date       => p_determination_date);
   hr_utility.set_location(l_proc||' Post Parttime Entitlement Duration '||l_parttime_duration,4);
   l_prev_employment := get_previous_employment(p_person_id       => p_person_id,
                                                p_assignment_id   => p_assignment_id,
                                                p_start_date      => l_start_date,
                                                p_end_date        => p_determination_date);
   hr_utility.set_location(l_proc||' Previous Employment Duration '||l_prev_employment,5);
-- findout the absence duration for the person during this period
   l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                           p_person_id     => p_person_id,
                                           p_assignment_id =>p_assignment_id,
                                           p_los_type      => p_los_type,
                                           p_start_date    => l_start_date,
                                           p_end_date      => p_determination_date);
--Approximately proportionating the Absence duration to consider the Parttime periods
--   l_absent_duration := l_absent_duration * l_parttime_duration/l_asg_duration;
--
   l_asg_duration := l_parttime_duration;
   hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);
-- collect the correction factor defined (if any) for the person
   l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                p_los_type       => p_los_type,
                                                p_effective_date => p_determination_date);
   hr_utility.set_location(l_proc||' Corrected Days '||l_correction_Factor,7);
   l_military_duration := get_military_service_period (p_bg_id => p_bg_id,
                                                       p_person_id => p_person_id,
                                                       p_assignment_id => p_assignment_id,
                                                       p_los_type      => p_los_type,
                                                       p_start_date    => l_start_date,
                                                       p_end_date      => p_determination_date);
   hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8);

   l_general_los := l_asg_duration + l_prev_employment + l_correction_factor + l_military_duration - l_absent_duration;

   hr_utility.set_location(l_proc||p_los_type||' Length of Service '||l_general_los,8);

   RETURN l_general_los;

EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_gen_pub_length_of_service;

-- -----------------------------------------------------------------------*
-- FUNCTION get_grade_length_of_service
-- This function returns the  length of service in the current grade for the employee
-- -----------------------------------------------------------------------*

FUNCTION get_grade_length_of_service(p_bg_id   IN per_all_organization_units.organization_id%TYPE,
                                     p_person_id  IN per_all_people_f.person_id%TYPE,
                                     p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
                                     p_determination_date IN DATE)
RETURN NUMBER IS


CURSOR csr_asg_grade IS
   SELECT     asg.assignment_id,
              asg.grade_id
   FROM       per_all_assignments_f asg
   WHERE      asg.person_id = p_person_id
   AND        (p_assignment_id IS NOT NULL OR asg.primary_flag ='Y')
   AND        (p_assignment_id IS NULL OR asg.assignment_id = p_assignment_id)
   AND         p_determination_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

   l_assignment_id per_assignments_f.assignment_id%TYPE;
   l_grade_id         per_assignments_f.grade_id%TYPE;

   l_proc varchar2(60) := g_package||'get_grade_LOS';

CURSOR csr_grade_period IS
   SELECT     asg.effective_start_date,
              asg.effective_end_date
   FROM       per_all_assignments_f asg
   WHERE      asg.assignment_id = l_assignment_id
   AND        asg.grade_id = l_grade_id
   AND        asg.effective_start_date <= p_determination_date
   ORDER BY   asg.effective_start_date, asg.effective_end_date;

   l_start_date  DATE;
   l_end_date    DATE;
   l_grade_los                 NUMBER(22,3) := 0;
   l_absent_duration           NUMBER(22,3) := 0;
   l_grade_entitlements        NUMBER(22,3) := 0;
   l_correction_factor         NUMBER(22,3) := 0;
   l_parttime_duration         NUMBER(22,3) := 0;
   l_prev_employment           NUMBER(22,3) := 0;
   l_military_duration         NUMBER(22,3) := 0;
   l_net_grade_los             NUMBER(22,3) := 0;
BEGIN
    hr_utility.set_location('Entering '||l_proc,1);
    OPEN      csr_asg_grade;
    FETCH     csr_asg_grade INTO l_assignment_id, l_grade_id;
    CLOSE     csr_asg_grade;
    IF l_grade_id IS NOT NULL THEN
        FOR l_grade_period IN csr_grade_period
        LOOP
                l_start_date := l_grade_period.effective_start_date;
                l_end_date := l_grade_period.effective_end_date;
                IF p_determination_date < l_end_date THEN
                    l_end_date := p_determination_date;
                END IF;
                l_grade_los := l_end_date - l_start_date+1;
                hr_utility.set_location(l_proc||' Grade Duration '||l_grade_los,2);
-- findout any parttime entitlements defined for the LOS type
                l_parttime_duration := get_parttime_entitlement(   p_person_id      => p_person_id,
                                                                   p_assignment_id  => p_assignment_id,
                                                                   p_bg_id          => p_bg_id,
                                                                   p_los_type       => '40',
                                                                   p_start_date     => l_start_date,
                                                                   p_end_date       => l_end_date);
                hr_utility.set_location(l_proc||'Parttime Grade Duration '||l_parttime_duration,4);
                l_prev_employment := get_previous_employment(p_person_id       => p_person_id,
                                                             p_assignment_id   => l_assignment_id,
                                                             p_start_date      => l_start_date,
                                                             p_end_date        => l_end_date);
                hr_utility.set_location(l_proc||' Previous Employment '||l_prev_employment,5);
-- findout the absence duration for the person during this period
                l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                                        p_person_id     => p_person_id,
                                                        p_assignment_id  => l_assignment_id,
                                                        p_los_type      => '40',
                                                        p_start_date    => l_start_date,
                                                        p_end_date      => l_end_date);

--Approximately proportionating the Absence duration to consider the Parttime periods
--                l_absent_duration := l_absent_duration * l_parttime_duration/l_grade_los;
                l_grade_los := l_parttime_duration;
                hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);
-- collect the correction factor defined (if any) for the person
                l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                             p_los_type       => '40',
                                                             p_effective_date => p_determination_date);
                hr_utility.set_location(l_proc||' Corrected Days '||l_correction_factor,7);
                l_military_duration := get_military_service_period (p_bg_id => p_bg_id,
                                                                     p_person_id => p_person_id,
                                                                     p_assignment_id => p_assignment_id,
                                                                     p_los_type      => '40',
                                                                     p_start_date    => l_start_date,
                                                                     p_end_date      => l_end_date);
                 hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8);
                 hr_utility.set_location(l_proc||'Calculation net_grade_los l_grade_los is '||l_grade_los,9);
                 hr_utility.set_location(l_proc||'Calculation net_grade_los l_prev_employment is '||l_prev_employment,10);
                 hr_utility.set_location(l_proc||'Calculation net_grade_los l_correction_factor is '||l_correction_factor,11);
                 hr_utility.set_location(l_proc||'Calculation net_grade_los l_military_duration is '||l_military_duration,12);
                 hr_utility.set_location(l_proc||'Calculation net_grade_los l_absent_duration is '||l_absent_duration,13);
                l_net_grade_los := l_net_grade_los + (l_grade_los + l_prev_employment + l_correction_factor + l_military_duration - l_absent_duration);
        END LOOP;
    END IF;
    hr_utility.set_location(l_proc||' Net Grade LOS '||l_net_grade_los,8);
    RETURN l_net_grade_los;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_grade_length_of_service;

-- -----------------------------------------------------------------------*
-- FUNCTION get_position_length_of_service
-- This function returns the  length of service in the current position for the employee
-- -----------------------------------------------------------------------*

FUNCTION get_position_length_of_service(p_bg_id   IN per_all_organization_units.organization_id%TYPE,
                                     p_person_id  IN per_all_people_f.person_id%TYPE,
                                     p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
                                     p_determination_date IN DATE)
RETURN NUMBER IS


   l_proc varchar2(60) := g_package||'get_position_LOS';

CURSOR csr_asg_position IS
   SELECT     asg.assignment_id,
              asg.position_id
   FROM       per_all_assignments_f asg
   WHERE      asg.person_id = p_person_id
   AND        (p_assignment_id IS NOT NULL OR asg.primary_flag ='Y')
   AND        (p_assignment_id IS NULL OR asg.assignment_id = p_assignment_id)
   AND         p_determination_date BETWEEN asg.effective_start_date AND asg.effective_end_date;
   l_assignment_id    per_assignments_f.assignment_id%TYPE;
   l_position_id      per_assignments_f.position_id%TYPE;

CURSOR csr_position_period IS
   SELECT     asg.effective_start_date,
              asg.effective_end_date
   FROM       per_all_assignments_f asg
   WHERE      asg.assignment_id = l_assignment_id
   AND        asg.position_id = l_position_id
   AND        asg.effective_start_date <= p_determination_date
   ORDER BY   asg.effective_start_date, asg.effective_end_date;

   l_start_date  DATE;
   l_end_date    DATE;
   l_position_los              NUMBER(22,3) := 0;
   l_absent_duration           NUMBER(22,3) := 0;
   l_position_entitlements     NUMBER(22,3) := 0;
   l_correction_factor         NUMBER(22,3) := 0;
   l_parttime_duration         NUMBER(22,3) := 0;
   l_prev_employment           NUMBER(22,3) := 0;
   l_military_duration         NUMBER(22,3) := 0;
   l_net_position_los          NUMBER(22,3) := 0;
BEGIN
    hr_utility.set_location('Entering '||l_proc,1);
    OPEN      csr_asg_position;
    FETCH     csr_asg_position INTO l_assignment_id, l_position_id;
    CLOSE     csr_asg_position;
    IF l_position_id IS NOT NULL THEN
        FOR l_position_period IN csr_position_period
        LOOP
                l_start_date := l_position_period.effective_start_date;
                l_end_date := l_position_period.effective_end_date;
                IF p_determination_date < l_end_date THEN
                    l_end_date := p_determination_date;
                END IF;
                l_position_los := l_end_date - l_start_date+1;
                hr_utility.set_location(l_proc||' Position Duration '||l_position_los,2);
-- findout any parttime entitlements defined for the LOS type
                l_parttime_duration := get_parttime_entitlement(   p_person_id      => p_person_id,
                                                                   p_assignment_id  => p_assignment_id,
                                                                   p_bg_id          => p_bg_id,
                                                                   p_los_type       => '60',
                                                                   p_start_date    => l_start_date,
                                                                   p_end_date => l_end_date);

                hr_utility.set_location(l_proc||' Post Parttime Duration '||l_position_los,4);
                l_prev_employment := get_previous_employment(p_person_id       => p_person_id,
                                                             p_assignment_id   => l_assignment_id,
                                                             p_start_date      => l_start_date,
                                                             p_end_date        => l_end_date);
                hr_utility.set_location(l_proc||' Previous Employment Duration '||l_position_los,5);
-- findout the absence duration for the person during this period
                l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                                        p_person_id     => p_person_id,
                                                        p_assignment_id  => l_assignment_id,
                                                        p_los_type      => '60',
                                                        p_start_date    => l_start_date,
                                                        p_end_date      => l_end_date);
--Approximately proportionating the Absence duration to consider the Parttime periods
--               l_absent_duration := l_absent_duration * l_parttime_duration/l_position_los;
               l_position_los := l_parttime_duration;
               hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);
-- collect the correction factor defined (if any) for the person
                l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                             p_los_type       => '60',
                                                             p_effective_date => p_determination_date);
                hr_utility.set_location(l_proc||' Correct Days '||l_correction_factor,7);
-- get the military service duration, if entitled for this LOS calculation
                l_military_duration := get_military_service_period (p_bg_id => p_bg_id,
                                                                    p_person_id => p_person_id,
                                                                    p_assignment_id => p_assignment_id,
                                                                    p_los_type      => '60',
                                                                    p_start_date    => l_start_date,
                                                                    p_end_date      => l_end_date);
                hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8);

                l_net_position_los := l_net_position_los + (l_position_los + l_prev_employment + l_correction_factor + l_military_duration - l_absent_duration);
        END LOOP;
    END IF;

    hr_utility.set_location(l_proc||' Net Position LOS '||l_net_position_los,8);

    RETURN l_net_position_los;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_position_length_of_service;


-- -----------------------------------------------------------------------*
-- FUNCTION get_corps_length_of_service
-- This function returns the  length of service in the current position for the employee
-- -----------------------------------------------------------------------*

FUNCTION get_corps_length_of_service(p_bg_id   IN per_all_organization_units.organization_id%TYPE,
                                     p_person_id  IN per_all_people_f.person_id%TYPE,
                                     p_assignment_id IN per_all_assignments_f.assignment_id%TYPE,
                                     p_determination_date IN DATE)
RETURN NUMBER IS


   l_proc varchar2(60) := g_package||'get_corps_LOS';

     CURSOR csr_asg_corps
      IS
         SELECT asg.assignment_id, grade_ladder_pgm_id
           FROM per_all_assignments_f asg
          WHERE asg.person_id = p_person_id
            AND (p_assignment_id IS NOT NULL OR asg.primary_flag = 'Y')
            AND (p_assignment_id IS NULL
                 OR asg.assignment_id = p_assignment_id
                )
            AND p_determination_date BETWEEN asg.effective_start_date
                                         AND asg.effective_end_date;


   l_assignment_id    per_assignments_f.assignment_id%TYPE;
   l_corps_id         hr_soft_coding_keyflex.segment7%TYPE;

      CURSOR csr_corps_period
      IS
         SELECT asg.effective_start_date, asg.effective_end_date
           FROM per_all_assignments_f asg
          WHERE asg.assignment_id = l_assignment_id
            AND asg.effective_start_date <= p_determination_date
            AND asg.grade_ladder_pgm_id = l_corps_id;


   l_start_date  DATE;
   l_end_date    DATE;
   l_corps_los                 NUMBER(22,3) := 0;
   l_absent_duration           NUMBER(22,3) := 0;
   l_corps_entitlements        NUMBER(22,3) := 0;
   l_correction_factor         NUMBER(22,3) := 0;
   l_parttime_duration         NUMBER(22,3) := 0;
   l_prev_employment           NUMBER(22,3) := 0;
   l_military_duration         NUMBER(22,3) := 0;
   l_net_corps_los             NUMBER(22,3) := 0;
BEGIN
    hr_utility.set_location('Entering '||l_proc,1);
    OPEN      csr_asg_corps;
    FETCH     csr_asg_corps INTO l_assignment_id, l_corps_id;
    CLOSE     csr_asg_corps;
    IF l_corps_id IS NOT NULL THEN
        FOR l_corps_period IN csr_corps_period
        LOOP
                l_start_date := l_corps_period.effective_start_date;
                l_end_date := l_corps_period.effective_end_date;
                IF p_determination_date < l_end_date THEN
                    l_end_date := p_determination_date;
                END IF;
                l_corps_los := l_end_date - l_start_date+1;
                hr_utility.set_location(l_proc||' Corps Duration '||l_corps_los,2);
-- findout any parttime entitlements defined for the LOS type
                l_parttime_duration := get_parttime_entitlement(   p_person_id      => p_person_id,
                                                                   p_assignment_id  => p_assignment_id,
                                                                   p_bg_id          => p_bg_id,
                                                                   p_los_type       => '30',
                                                                   p_start_date    => l_start_date,
                                                                   p_end_date => l_end_date);

                hr_utility.set_location(l_proc||' Post Parttime Duration '||l_parttime_duration,4);
                l_prev_employment := get_previous_employment(p_person_id       => p_person_id,
                                                             p_assignment_id   => l_assignment_id,
                                                             p_start_date      => l_start_date,
                                                             p_end_date        => l_end_date);
                hr_utility.set_location(l_proc||' Previous Employment Duration '||l_corps_los,5);
-- findout the absence duration for the person during this period
                l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                                        p_person_id     => p_person_id,
                                                        p_assignment_id  => l_assignment_id,
                                                        p_los_type      => '30',
                                                        p_start_date    => l_start_date,
                                                        p_end_date      => l_end_date);
--Approximately proportionating the Absence duration to consider the Parttime periods
--               l_absent_duration := l_absent_duration * l_parttime_duration/l_corps_los;
               l_corps_los := l_parttime_duration;
               hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);
-- collect the correction factor defined (if any) for the person
                l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                             p_los_type       => '60',
                                                             p_effective_date => p_determination_date);
                hr_utility.set_location(l_proc||' Correct Days '||l_correction_factor,7);
-- get the military service duration, if entitled for this LOS calculation
                l_military_duration := get_military_service_period (p_bg_id => p_bg_id,
                                                                    p_person_id => p_person_id,
                                                                    p_assignment_id => p_assignment_id,
                                                                    p_los_type      => '60',
                                                                    p_start_date    => l_start_date,
                                                                    p_end_date      => l_end_date);
                hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8);

                l_net_corps_los := l_net_corps_los + (l_corps_los + l_prev_employment + l_correction_factor + l_military_duration - l_absent_duration);
        END LOOP;
    END IF;

    hr_utility.set_location(l_proc||' Net Corps LOS '||l_net_corps_los,8);

    RETURN l_net_corps_los;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_corps_length_of_service;

-- -----------------------------------------------------------------------*
-- FUNCTION get_step_length_of_service
-- This function returns the  length of service in the current grade step for the employee
-- -----------------------------------------------------------------------*

FUNCTION get_step_length_of_service (p_bg_id                IN    per_all_organization_units.organization_id%TYPE,
                                     p_person_id            IN    per_all_people_f.person_id%TYPE,
                                     p_assignment_id        IN    per_all_assignments_f.assignment_id%TYPE,
                                     p_determination_date   IN    DATE)
RETURN NUMBER IS
  Cursor Csr_asg_step IS
    SELECT spp.assignment_id,
           spp.step_id,
           spp.effective_start_date,
           spp.effective_end_date
    FROM   per_spinal_point_placements_f spp, per_all_assignments_f asg
    WHERE  asg.person_id = p_person_id
    AND    (p_assignment_id IS NOT NULL OR asg.primary_flag = 'Y')
    AND    (p_assignment_id IS NULL OR asg.assignment_id = p_assignment_id)
    AND    p_determination_date BETWEEN asg.effective_start_date AND asg.effective_end_date
    AND    spp.assignment_id = asg.assignment_id
    AND    p_determination_date BETWEEN spp.effective_start_date and spp.effective_end_date;

    l_assignment_id        per_assignments_f.assignment_id%TYPE;
    l_step_id              per_spinal_point_placements_f.step_id%TYPE;
    l_start_date           DATE;
    l_end_date             DATE;
    l_step_los             NUMBER(22,3) := 0;
    l_absent_duration      NUMBER(22,3) := 0;
    l_step_entitlements    NUMBER(22,3) := 0;
    l_correction_factor    NUMBER(22,3) := 0;
    l_parttime_duration    NUMBER(22,3) := 0;
    l_prev_employment      NUMBER(22,3) := 0;
    l_military_duration    NUMBER(22,3) := 0;
    l_net_step_los     NUMBER(22,3) := 0;
    l_proc varchar2(60) := g_package||'get_step_LOS';


BEGIN
     hr_utility.set_location('Entering '||l_proc,1);
     OPEN csr_asg_step;

     FETCH csr_asg_step INTO l_assignment_id, l_step_id, l_start_date, l_end_date;

     IF csr_asg_step%NOTFOUND THEN
        CLOSE  csr_asg_step;
        RETURN l_net_step_los;
     END IF;
     CLOSE csr_asg_step;
     IF l_end_date > p_determination_date THEN
        l_end_date := p_determination_date;
     END IF;
     l_step_los := l_end_date - l_start_date;

     hr_utility.set_location(l_proc||' Step Duration '||l_step_los,2);
-- findout any parttime entitlements defined for the LOS type
     l_parttime_duration := get_parttime_entitlement(   p_person_id     => p_person_id,
                                                        p_assignment_id  => p_assignment_id,
                                                        p_bg_id          => p_bg_id,
                                                        p_los_type       => '50',
                                                        p_start_date => l_start_date,
                                                        p_end_date => l_end_date);

     hr_utility.set_location(l_proc||' Post parttime Step Duration '||l_step_los,4);
     l_prev_employment := get_previous_employment(p_person_id       => p_person_id,
                                                  p_assignment_id   => l_assignment_id,
                                                  p_start_date      => l_start_date,
                                                  p_end_date        => l_end_date);
     hr_utility.set_location(l_proc||' Previous Emp Duration '||l_prev_employment,5);

-- findout the absence duration for the person during this period
     l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                             p_person_id     => p_person_id,
                                             p_assignment_id  => l_assignment_id,
                                             p_los_type      => '50',
                                             p_start_date    => l_start_date,
                                             p_end_date      => l_end_date);
--Approximately proportionating the Absence duration to consider the Parttime periods
  --   l_absent_duration := l_absent_duration * l_parttime_duration/l_step_los;
     l_step_los := l_parttime_duration;
     hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);

-- collect the correction factor defined (if any) for the person
      l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                   p_los_type       => '50',
                                                   p_effective_date => p_determination_date);
      hr_utility.set_location(l_proc||' Correct Days '||l_correction_factor,7);

-- get the military service duration, if entitled for this LOS calculation
     l_military_duration := get_military_service_period (p_bg_id => p_bg_id,
                                                         p_person_id => p_person_id,
                                                         p_assignment_id => p_assignment_id,
                                                         p_los_type      => '50',
                                                         p_start_date    => l_start_date,
                                                         p_end_date      => l_end_date);
      hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8);

      l_net_step_los := l_net_step_los + (l_step_los + l_prev_employment + l_correction_factor + l_military_duration - l_absent_duration);
      hr_utility.set_location(l_proc||' LOS on Step '||l_net_step_los,8);
      RETURN l_net_step_los;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);

END get_step_length_of_service;

FUNCTION get_los_for_display  (  p_bg_id               IN    NUMBER,
                                 p_person_id           IN    NUMBER default NULL,
                                 p_assignment_id       IN    NUMBER default NULL,
                                 p_los_type            IN    VARCHAR2,
                                 p_determination_date  IN    DATE default SYSDATE) RETURN VARCHAR2 IS
 l_display_los Varchar2(200);
 l_yy number(5);
 l_mm number(5);
 l_dd number(5);
 l_temp_los_mm number(22,3);
 l_temp_los_yy number(22,3);
 l_los_days NUMBER(22,3);
 l_adj_service_date DATE;
 l_determination_date DATE := TRUNC(p_determination_date);
 l_proc varchar2(60) := g_package||'get_los_for_display';
BEGIN
        hr_utility.set_location(l_proc||' Entering',10);
        l_los_days := get_length_of_service( p_bg_id              => p_bg_id,
                                             p_person_id          => p_person_id,
                                             p_assignment_id      => p_assignment_id,
                                             p_los_type           => p_los_type,
                                             p_return_units       =>'D',
                                             p_determination_date => l_determination_date);

        l_adj_service_date := l_determination_date - l_los_days;

        l_temp_los_mm := months_between(l_determination_date ,l_adj_service_date);
        l_yy := NVL((l_temp_los_mm - mod(l_temp_los_mm,12))/12,0);
        l_temp_los_mm := l_temp_los_mm - l_yy*12;
        l_mm := NVL(TRUNC(l_temp_los_mm,0),0);
        l_dd := NVL(l_determination_date - TRUNC( ADD_MONTHS(l_adj_service_date,(l_mm+l_yy*12))),0);

        l_display_los := NVL(l_yy,0)||' '||hr_general.decode_lookup('QUALIFYING_UNITS','Y')||'  '||NVL(l_mm,0)||' '||hr_general.decode_lookup('QUALIFYING_UNITS','M')||'  '||l_dd||' '||hr_general.decode_lookup('QUALIFYING_UNITS','D');

        hr_utility.set_location(l_proc||l_display_los,15);

        hr_utility.set_location(l_proc||' Leaving',20);

   RETURN l_display_los;
END get_los_for_display;
-- -----------------------------------------------------------------------*
-- FUNCTION get_length_of_service
-- This function returns the appropriate length of service for the employee
-- depending on the type of length of service required for
-- -----------------------------------------------------------------------*


FUNCTION get_length_of_service(  p_bg_id               IN    NUMBER,
                                 p_person_id           IN    NUMBER default NULL,
                                 p_assignment_id       IN    NUMBER default NULL,
                                 p_los_type            IN    VARCHAR2,
                                 p_return_units        IN    VARCHAR2 default 'D',
                                 p_determination_date  IN    DATE default NULL)
RETURN NUMBER

IS

 l_start_date         DATE;
 l_determination_date DATE := p_determination_date;
 l_assignment_id      PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE;
 l_los_days           NUMBER(22,3) := 0;
 l_los_return         NUMBER(22,3);
 l_emp_type           PER_ALL_ASSIGNMENTS_F.employee_category%TYPE;
 l_person_id          PER_ALL_PEOPLE_F.person_id%TYPE;
 l_bg_id              per_all_organization_units.organization_id%TYPE := p_bg_id;
 l_adj_service_date   DATE;
 l_proc varchar2(60) := g_package||'get_length_of_sevice';
 l_exists             VARCHAR2(2) := '0';

 CURSOR CSR_validate_person IS
   SELECT   '1'
   FROM     per_all_people_f
   WHERE    person_id = p_person_id
   AND      l_determination_date BETWEEN effective_start_date AND effective_end_date;

 CURSOR CSR_validate_assignment IS
   SELECT   person_id
   FROM     per_all_assignments_f
   WHERE    assignment_id = p_assignment_id
   AND      l_determination_date BETWEEN effective_start_date AND effective_end_date;
CURSOR Csr_get_primary_asg IS
   SELECT   assignment_id
   FROM     per_all_assignments_f
   WHERE    person_id = p_person_id
   AND      primary_flag = 'Y'
   AND      l_determination_date BETWEEN effective_start_date AND effective_end_date;


BEGIN

      hr_utility.set_location('Entering '||l_proc,1);

      -- take session date as the determination date if determination date is not passed
      IF l_determination_date IS NULL THEN
            l_determination_date := get_effective_date;
      END IF;
      --
      hr_utility.set_location(l_proc||' Effective Date  '||to_char(l_determination_date,'dd-mm-RRRR'),2);

      IF p_bg_id IS NULL THEN
         hr_api.mandatory_arg_error(p_api_name => l_proc,
                                    p_argument => 'p_bg_id',
                                    p_argument_value => p_bg_id);
      ELSE
          hr_api.validate_bus_grp_id(p_business_group_id=>p_bg_id);
      END IF;
      hr_utility.set_location(l_proc||' BG ID Validated',2);
      IF p_person_id IS NULL AND p_assignment_id IS NULL THEN
            hr_api.mandatory_arg_error(p_api_name => l_proc,
	                               p_argument => 'p_person_id',
                                       p_argument_value => p_person_id);
      END IF;
      hr_utility.set_location(l_proc||' Person ID Validated',2);
      IF p_person_id IS NOT NULL THEN
         OPEN Csr_validate_person;
         FETCH Csr_validate_person INTO l_exists;
         CLOSE Csr_validate_person;
         IF l_exists = '0' THEN
            fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
            fnd_message.set_token('VALUE',to_char(p_person_id));
            fnd_message.set_token('PARAMETER','p_person_id');
            fnd_message.raise_error;
         END IF;
         IF p_assignment_id IS NULL THEN
           OPEN  Csr_Get_Primary_Asg;
           Fetch Csr_Get_Primary_Asg INTO l_assignment_id;
           CLOSE Csr_Get_Primary_Asg;
         END IF;
      END IF;

      IF p_assignment_id IS NOT NULL THEN
               l_assignment_id := p_assignment_id;
               OPEN Csr_validate_assignment;
               FETCH Csr_validate_assignment INTO l_person_id;
               IF Csr_validate_assignment%NOTFOUND THEN
                  CLOSE Csr_validate_assignment;
                  fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
                  fnd_message.set_token('VALUE',to_char(p_assignment_id));
                  fnd_message.set_token('PARAMETER','p_assignment_id');
                  fnd_message.raise_error;
               END IF;
               CLOSE Csr_validate_assignment;
      END IF;
      l_person_id := NVL(p_person_id,l_person_id);
      hr_utility.set_location(l_proc||' Assignment iD Validated',2);
      IF p_los_type IS NULL THEN
          hr_api.mandatory_arg_error(p_api_name => l_proc,
	                             p_argument => 'p_los_type',
                                     p_argument_value => p_los_type);
      ELSE
          IF hr_api.NOT_EXISTS_IN_HR_LOOKUPS(p_effective_date => l_determination_date,
                                             p_lookup_type => 'FR_PQH_LENGTH_OF_SERVICE_TYPE',
                                             p_lookup_code => p_los_type) THEN
               fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
               fnd_message.set_token('VALUE',p_los_type);
               fnd_message.set_token('PARAMETER','p_los_type');
          END IF;
      END IF;
      hr_utility.set_location(l_proc||' LOS TYPE Validated',2);
      IF p_return_units IS NULL THEN
          hr_api.mandatory_arg_error(p_api_name => l_proc,
	                             p_argument => 'p_return_units',
                                     p_argument_value => p_return_units);
      ELSE
          IF hr_api.NOT_EXISTS_IN_HR_LOOKUPS(p_effective_date => l_determination_date,
                                             p_lookup_type => 'QUALIFYING_UNITS',
                                             p_lookup_code => p_return_units) THEN
              fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
              fnd_message.set_token('VALUE',p_return_units);
              fnd_message.set_token('PARAMETER','p_return_units');

          END IF;
      END IF;
      g_emp_type := get_employee_type(p_person_id      => p_person_id,
                                      p_determination_date => l_determination_date);
      g_determination_date :=  l_determination_date;
      hr_utility.set_location(l_proc||' Completed Validations ',2);
      hr_utility.set_location(l_proc||' Person Id '||to_char(L_person_id),2);
      hr_utility.set_location(l_proc||' Assignment Id '||to_char(L_Assignment_Id),2);
      IF p_los_type IN ('10','20') THEN -- General Length of service and Length of service in Public Service
          hr_utility.set_location(l_proc||' Calling  get_gen_pub_length_of_service',3);
          l_los_days := get_gen_pub_length_of_service(       p_bg_id                => l_bg_id,
                                                             p_person_id            => l_person_id,
                                                             p_assignment_id        => l_assignment_id,
                                                             p_los_type             => p_los_type,
                                                             p_determination_date   => l_determination_date);

      ELSIF p_los_type = '30' THEN -- Length of Service in Corps

          l_los_days := get_corps_length_of_service(p_bg_id                => p_bg_id,
                                                    p_person_id            => l_person_id,
                                                    p_assignment_id        => l_assignment_id,
                                                    p_determination_date   => l_determination_date);

      ELSIF p_los_type = '40' THEN -- Length of Service in Grade

          l_los_days := get_grade_length_of_service(p_bg_id                => p_bg_id,
                                                    p_person_id            => l_person_id,
                                                    p_assignment_id        => l_assignment_id,
                                                    p_determination_date   => l_determination_date);
      ELSIF p_los_type = '50' THEN -- Length of Service in Step

          l_los_days := get_step_length_of_service(p_bg_id                => p_bg_id,
                                                   p_person_id            => l_person_id,
                                                   p_assignment_id        => l_assignment_id,
                                                   p_determination_date   => l_determination_date);
      ELSIF p_los_type = '60' THEN -- Length of service in Position

          l_los_days := get_position_length_of_service(p_bg_id                => p_bg_id,
                                                       p_person_id            => l_person_id,
                                                       p_assignment_id        => l_assignment_id,
                                                       p_determination_date   => l_determination_date);

      END IF;

      hr_utility.set_location(l_proc,2);

      l_adj_service_date := l_determination_date - l_los_days;

      hr_utility.set_location(l_proc||' Adjusted Service Date '||To_Char(l_adj_service_date,'dd-Mm-RRRR'),3);

      IF p_return_units = 'D' THEN
          l_los_return := l_los_days;
      ELSIF p_return_units = 'W' THEN
          l_los_return := l_los_days/7;
      ELSIF p_return_units = 'M' THEN
          l_los_return := Months_Between(l_determination_date,l_adj_service_date);
      ELSIF p_return_units = 'Y' THEN
          l_los_return := Months_Between(l_determination_date,l_adj_service_date)/12;
      END IF;

      hr_utility.set_location(l_proc||' LOS in '||p_return_units||' '||l_los_return,4);

      return l_los_return;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);

END get_length_of_service;


--
-- This Function returns the military service duration for an employee
--
FUNCTION get_de_military_service_period(p_bg_id         IN   hr_all_organization_units.organization_id%TYPE,
                                        p_person_id     IN   per_all_people_f.person_id%TYPE,
                                        p_los_type      IN   hr_lookups.lookup_code%TYPE,
                                        p_start_date    IN   DATE,
                                        p_end_date      IN   DATE)
RETURN VARCHAR2 IS

l_emp_type             per_assignments_f.employee_category%TYPE;
l_military_entitlement VARCHAR2(30);
l_proc                 VARCHAR2(60) := g_package||'get_military_service_period';
l_military_duration    NUMBER(22,3) :=0;
l_los_return	       VARCHAR2(240);
l_los_years	       NUMBER := 0;
l_los_months	       NUMBER := 0;
l_adj_service_date     DATE;

CURSOR csr_military_entitlement IS
      SELECT '1'
      FROM   pqh_situations
      WHERE  business_group_id = p_bg_id
      AND    situation_type = 'MILITARY'
      AND    length_of_service = p_los_type
      AND    employee_type = l_emp_type
      AND    entitlement_flag = 'Y'
      AND    p_start_date BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time)
      AND    p_end_date BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time);

CURSOR csr_military_periods IS
       SELECT nvl((p_end_date - p_start_date),0) los
       FROM   per_people_extra_info
       WHERE  person_id = p_person_id
       AND    information_type = 'DE_MILITARY_SERVICE'
       AND    p_start_date = fnd_date.canonical_to_date(pei_information1)
       AND    p_end_date = fnd_date.canonical_to_date(pei_information2);

BEGIN
     hr_utility.set_location('Entering '||l_proc,1);
     l_emp_type := get_employee_type(p_person_id  => p_person_id,
                                     p_determination_date => trunc(sysdate));
     hr_utility.set_location(l_proc||' employee type '||l_emp_type||to_char(p_start_date,'dd-mm-RRRR')||to_char(p_end_date,'dd-mm-RRRR'),1);
     OPEN csr_military_entitlement;
     FETCH csr_military_entitlement INTO l_military_entitlement;
     CLOSE csr_military_entitlement;
     hr_utility.set_location(l_proc||' military entitlement '||l_military_entitlement,1);
     IF l_military_entitlement IS NOT NULL THEN
        OPEN csr_military_periods;
        FETCH csr_military_periods INTO l_military_duration;
        IF csr_military_periods%FOUND THEN
            l_military_duration := l_military_duration + 1;
        END IF;    --both dates inclusive
        CLOSE csr_military_periods;
     END IF;

     l_adj_service_date := p_end_date - l_military_duration;

     l_los_years := months_between(p_end_date,l_adj_service_date)/12;

     If instr(l_los_years,'.',1) <> 0 Then
       l_los_months := substr(l_los_years,instr(l_los_years,'.',1)) * 12;
     End If;

     IF trunc(l_los_years) = 0 and trunc(l_los_months) = 0 THEN
         l_los_return := 0||'/'||0||'/'||l_military_duration;
     ELSE
         l_military_duration := round(substr(l_los_months,instr(l_los_months,'.',1)) * 31);
         l_los_return := trunc(l_los_years)||'/'||trunc(l_los_months)||'/'||l_military_duration;
     END IF;

     hr_utility.set_location(l_proc||' Military Duration '||l_military_duration,1);
     RETURN l_los_return;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_de_military_service_period;


-- -----------------------------------------------------------------------*
-- FUNCTION get_de_pub_length_of_service
-- This function returns the length of service in Public Services for an employee
-- -----------------------------------------------------------------------*

FUNCTION get_de_pub_length_of_service(p_bg_id               IN   per_all_organization_units.organization_id%TYPE,
 	 	        	      p_person_id	    IN   per_all_people_f.person_id%TYPE,
				      p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE,
				      p_los_type            IN   VARCHAR2,
				      p_assg_start_date     IN   DATE ,
				      p_assg_end_date       IN   DATE
                                     )
RETURN NUMBER IS

CURSOR c_person_dob IS
SELECT date_of_birth
  FROM per_all_people_f
 WHERE person_id = p_person_id
   AND effective_start_date <= p_assg_end_date
   AND effective_end_date >= p_assg_start_date;

CURSOR c_assg_los_type IS
SELECT '1'
  FROM per_assignment_extra_info
 WHERE assignment_id = p_assignment_id
   AND nvl(aei_information1,'x') = p_los_type
   AND information_type = 'DE_PQH_ASSG_LOS_INFO';


l_start_date              DATE;
l_asg_duration            NUMBER(22,3) := 0;
l_absent_duration         NUMBER(22,3) := 0;
l_correction_factor       NUMBER(22,3) := 0;
l_general_los             NUMBER(22,3) := 0;
l_military_duration       NUMBER(22,3) := 0;
l_proc                    VARCHAR2(60) := g_package||'get_de_pub_LOS';
l_date_of_birth           DATE;
l_assg_los_type           varchar2(1);


BEGIN
   hr_utility.set_location('Entering '||l_proc,1);

   OPEN c_assg_los_type;
   FETCH c_assg_los_type INTO l_assg_los_type;
   CLOSE c_assg_los_type;

   --
   -- If the length of service type is present in the Extra Info then the assignment
   -- is not taken for LOS calculation.
   --

   IF l_assg_los_type IS NOT NULL THEN
     RETURN 0;
   END IF;

   OPEN c_person_dob;
   FETCH c_person_dob INTO l_date_of_birth;
   CLOSE c_person_dob;

   hr_utility.set_location(' date of birth '||l_date_of_birth,2);
   hr_utility.set_location(' assignment start date '||p_assg_start_date,2);

   IF l_date_of_birth IS NOT NULL THEN
     IF Months_between(p_assg_start_date,l_date_of_birth)/12 < 18 THEN
         l_start_date := add_months(l_date_of_birth,18*12);
     ELSE
         l_start_date := p_assg_start_date;
     END IF;
   ELSE
     l_start_date := p_assg_start_date;
   END IF;

   IF (p_assg_end_date - l_start_date) < 0 THEN
       RETURN 0;
   END IF;
   l_asg_duration := trunc(p_assg_end_date - l_start_date);

   hr_utility.set_location(l_proc||' Assignment duration '||l_asg_duration,2);

-- findout the absence duration for the person during this period
   l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                           p_person_id     => p_person_id,
                                           p_assignment_id => p_assignment_id,
                                           p_los_type      => p_los_type,
                                           p_start_date    => l_start_date,
                                           p_end_date      => p_assg_end_date);

   hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);

-- collect the correction factor defined (if any) for the person
  /* l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                p_los_type       => p_los_type,
                                                p_effective_date => p_assg_end_date);
   hr_utility.set_location(l_proc||' Corrected Days '||l_correction_Factor,7);
   l_military_duration := get_de_military_service_period (p_bg_id         => p_bg_id,
                                                          p_person_id     => p_person_id,
                                                          p_los_type      => p_los_type,
                                                          p_start_date    => l_start_date,
                                                          p_end_date      => p_assg_end_date);

   hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8); */

   l_general_los := (l_asg_duration + 1) - l_absent_duration;
   hr_utility.set_location(l_proc||p_los_type||' Length of Service '||l_general_los,8);

   RETURN l_general_los;

EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_de_pub_length_of_service;


-- -----------------------------------------------------------------------*
-- FUNCTION get_jub_mon_length_of_service
-- This function returns the length of service for Jubilee Money for an employee
-- -----------------------------------------------------------------------*

FUNCTION get_jub_mon_length_of_service(p_bg_id               IN   per_all_organization_units.organization_id%TYPE,
 	 	        	       p_person_id	     IN   per_all_people_f.person_id%TYPE,
				       p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE,
				       p_los_type            IN   VARCHAR2,
				       p_assg_start_date     IN   DATE ,
				       p_assg_end_date       IN   DATE
                                      )
RETURN NUMBER IS

l_start_date              DATE;
l_asg_duration            NUMBER(22,3) := 0;
l_absent_duration         NUMBER(22,3) := 0;
l_correction_factor       NUMBER(22,3) := 0;
l_general_los             NUMBER(22,3) := 0;
l_military_duration       NUMBER(22,3) := 0;
l_proc                    VARCHAR2(60) := g_package||'get_jub_mon_los';
l_date_of_birth           DATE;
l_per_los_flag            per_all_people_f.per_information10%TYPE;
l_assg_los_type           varchar2(1);
l_entitlement             pqh_situations.entitlement_value%TYPE :=0;
l_emp_type                per_all_assignments_f.employee_category%TYPE;


CURSOR c_person_dob IS
SELECT date_of_birth, nvl(per_information10,'N')
  FROM per_all_people_f
 WHERE person_id = p_person_id
   AND effective_start_date < p_assg_end_date
   AND effective_end_date > p_assg_start_date;

CURSOR c_assg_los_type IS
SELECT '1'
  FROM per_assignment_extra_info
 WHERE assignment_id = p_assignment_id
   AND nvl(aei_information1,'x') = p_los_type
   AND information_type = 'DE_PQH_ASSG_LOS_INFO';

CURSOR c_18yrs_entitlements IS
 SELECT nvl(entitlement_value,0)
   FROM pqh_situations
  WHERE business_group_id = p_bg_id
    AND situation_type = 'PERSON'
    AND length_of_service = p_los_type
    AND situation = 'BEFORE_18'
    AND employee_type = l_emp_type
    AND p_assg_start_date BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time)
    AND p_assg_end_date  BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time)
    AND entitlement_flag = 'Y';


BEGIN
   hr_utility.set_location('Entering '||l_proc,1);

   OPEN c_assg_los_type;
   FETCH c_assg_los_type INTO l_assg_los_type;
   CLOSE c_assg_los_type;

   --
   -- If the length of service type is present in the Extra Info then the assignment
   -- is not taken for LOS calculation.
   --

   IF l_assg_los_type IS NOT NULL THEN
     RETURN 0;
   END IF;

   OPEN c_person_dob;
   FETCH c_person_dob INTO l_date_of_birth, l_per_los_flag;
   CLOSE c_person_dob;


   l_emp_type := get_employee_type(p_person_id          => p_person_id,
   	                           p_determination_date => p_assg_end_date);

   OPEN c_18yrs_entitlements;
   FETCH c_18yrs_entitlements INTO l_entitlement;
   CLOSE c_18yrs_entitlements;

   IF l_date_of_birth IS NOT NULL THEN
     IF Months_between(p_assg_start_date,l_date_of_birth)/12 < 18 THEN
       IF l_per_los_flag = 'Y' THEN
         l_start_date := p_assg_start_date;
       ELSE
         l_start_date := add_months(l_date_of_birth,18*12);
       END IF;
     ELSE
       l_start_date := p_assg_start_date;
     END IF;
   ELSE
     l_start_date := p_assg_start_date;
   END IF;

   IF (p_assg_end_date - l_start_date) < 0 THEN
          RETURN 0;
   END IF;
   l_asg_duration := trunc(p_assg_end_date - l_start_date) * l_entitlement/100;

   hr_utility.set_location(l_proc||' Assignment duration '||l_asg_duration,2);

-- findout the absence duration for the person during this period
   l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                           p_person_id     => p_person_id,
                                           p_assignment_id => p_assignment_id,
                                           p_los_type      => p_los_type,
                                           p_start_date    => l_start_date,
                                           p_end_date      => p_assg_end_date);

   hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);
-- collect the correction factor defined (if any) for the person
   /*l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                p_los_type       => p_los_type,
                                                p_effective_date => p_assg_end_date);
   hr_utility.set_location(l_proc||' Corrected Days '||l_correction_Factor,7);
   l_military_duration := get_de_military_service_period (p_bg_id         => p_bg_id,
                                                          p_person_id     => p_person_id,
                                                          p_los_type      => p_los_type,
                                                          p_start_date    => l_start_date,
                                                          p_end_date      => p_assg_end_date);
   hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8); */

   l_general_los := (l_asg_duration + 1) - l_absent_duration;
   hr_utility.set_location(l_proc||p_los_type||' Length of Service '||l_general_los,8);

   RETURN l_general_los;

EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_jub_mon_length_of_service;

-- -----------------------------------------------------------------------*
-- FUNCTION get_bda_length_of_service
-- This function returns the length of service for BDA calculation of an employee
-- -----------------------------------------------------------------------*

FUNCTION get_bda_length_of_service(p_bg_id               IN   per_all_organization_units.organization_id%TYPE,
 		        	   p_person_id	         IN   per_all_people_f.person_id%TYPE,
				   p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE,
				   p_los_type            IN   VARCHAR2,
				   p_assg_start_date     IN   DATE ,
				   p_assg_end_date       IN   DATE
                                  )
RETURN NUMBER IS

CURSOR c_assg_emp_catg IS
SELECT employee_category, position_id
  FROM per_all_assignments_f
 WHERE person_id = p_person_id
   AND assignment_id = p_assignment_id
   AND effective_start_date = p_assg_start_date
   AND effective_end_date = decode(p_assg_end_date,trunc(sysdate),effective_end_date,p_assg_end_date);

CURSOR c_person_dob IS
SELECT date_of_birth
  FROM per_all_people_f
 WHERE person_id = p_person_id
   AND effective_start_date <= p_assg_end_date
   AND effective_end_date >= p_assg_start_date;

CURSOR c_tariff_contract(p_position_id per_all_assignments_f.position_id%type) IS
SELECT wkvr.tariff_contract_code
  FROM hr_all_positions_f pos, pqh_de_wrkplc_vldtn_vers wkvr
 WHERE pos.position_id = p_position_id
   AND pos.information1='WP'
   AND to_char(wkvr.wrkplc_vldtn_ver_id) = decode(pos.information6,'A',pos.information5,pos.information9)
   AND p_assg_end_date between pos.effective_start_date and pos.effective_end_date
   AND pos.business_group_id = wkvr.business_group_id;

CURSOR c_assg_los_type IS
SELECT '1'
  FROM per_assignment_extra_info
 WHERE assignment_id = p_assignment_id
   AND nvl(aei_information1,'x') = p_los_type
   AND information_type = 'DE_PQH_ASSG_LOS_INFO';

l_employee_category     per_all_assignments_f.employee_category%TYPE;
l_position_id		per_all_assignments_f.position_id%TYPE;
l_tariff_contract_code  pqh_de_wrkplc_vldtn_vers.tariff_contract_code%TYPE;
l_date_of_birth         DATE;
l_dob_21                DATE;
l_dob_31                DATE;
l_dob_35                DATE;
l_proc                  VARCHAR2(60) := g_package||'get_bda_los';
l_days_betn_assg_35dob  NUMBER;
l_days_betn_35dob_31dob NUMBER;
l_days_betn_assg_31dob  NUMBER;
l_postpone_bda          NUMBER;
l_bda_date              DATE;
l_asg_duration          NUMBER(22,3) := 0;
l_absent_duration       NUMBER(22,3) := 0;
l_bda_los               NUMBER(22,3) := 0;
l_assg_los_type         VARCHAR2(1);


BEGIN
    hr_utility.set_location('Entering '||l_proc,1);

    OPEN c_assg_los_type;
    FETCH c_assg_los_type INTO l_assg_los_type;
    CLOSE c_assg_los_type;

    --
    -- If the length of service type is present in the Extra Info then the assignment
    -- is not taken for LOS calculation.
    --

    IF l_assg_los_type IS NOT NULL THEN
      RETURN 0;
    END IF;

    OPEN c_assg_emp_catg;
    FETCH c_assg_emp_catg INTO l_employee_category, l_position_id;
    CLOSE c_assg_emp_catg;

    hr_utility.set_location('Position id '|| l_position_id,1);

 /*   OPEN c_tariff_contract(l_position_id);
    FETCH c_tariff_contract INTO l_tariff_contract_code;
    CLOSE c_tariff_contract; */

    hr_utility.set_location('Employee catg '||l_employee_category,2);

    IF nvl(l_employee_category,'x') = 'BE'  Then
       -- and nvl(l_tariff_contract_code,'x') = 'CS' THEN
        OPEN c_person_dob;
        FETCH c_person_dob INTO l_date_of_birth;
	CLOSE c_person_dob;

        IF l_date_of_birth IS NULL THEN
	    fnd_message.set_name('PER','HR_BE_DNP_INVALID_BIRTHDATE');
	    fnd_message.raise_error;
	else
--
--Truncating the date of birth to the first of the month. Bug Fix 2419524
--
		l_date_of_birth := trunc(l_date_of_birth, 'MM');
        END IF;
    --
    -- Get the 1st of the 21st Birthday
    --
        l_dob_21 := trunc(add_months(l_date_of_birth,(12 * 21)), 'MM');

    --
    -- Get the 1st of the 31st Birthday
    --
        l_dob_31 := trunc(add_months(l_date_of_birth,(12 * 31)), 'MM');
    --
    -- Get the 1st of the 35th Birthday
    --
        l_dob_35 := trunc(add_months(l_date_of_birth,(12 * 35)), 'MM');


        IF (p_assg_start_date - l_date_of_birth) > 21 THEN
            IF (p_assg_start_date - l_dob_31) > 0 THEN
                IF (p_assg_start_date - l_dob_35) > 0 THEN

                  --  l_days_betn_assg_35dob := (p_assg_start_date - 1) - l_dob_35;
                    l_days_betn_assg_35dob := Months_Between((p_assg_start_date - 1), l_dob_35);

                  --  l_days_betn_35dob_31dob := l_dob_35 - l_dob_31;
                    l_days_betn_35dob_31dob := Months_Between(l_dob_35, l_dob_31);
                    --
                    -- Get the postponing BDA in months
                    --
                 --   l_postpone_bda := trunc(((l_days_betn_assg_35dob/2) + (l_days_betn_35dob_31dob/4))/30);
                    --
                    -- Add the postponing BDA months to the 1st of the 21st birthday
                    --
                  --  l_bda_date := add_months(l_dob_21,l_postpone_bda);
                    l_bda_date := add_months(l_dob_21,trunc(((l_days_betn_assg_35dob/2) + (l_days_betn_35dob_31dob/4))));

                ELSE
                 -- l_days_betn_assg_31dob := (p_assg_start_date - 1) - l_dob_31;
                    l_days_betn_assg_31dob := Months_Between((p_assg_start_date - 1), l_dob_31);
                    --
                    -- Get the postponing BDA in months
                    --
                  --  l_postpone_bda := trunc((l_days_betn_assg_31dob/4)/30);
                    --
                    -- Add the postponing BDA months to the 1st of the 21st birthday
                    --
                    l_bda_date   := add_months(l_dob_21,trunc(l_days_betn_assg_31dob/4));
                END IF;

		l_asg_duration := trunc(p_assg_end_date - l_bda_date);

		hr_utility.set_location(l_proc||' Assignment duration '||l_asg_duration,2);

		l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
							p_person_id     => p_person_id,
							p_assignment_id => p_assignment_id,
							p_los_type      => p_los_type,
							p_start_date    => l_bda_date,
							p_end_date      => p_assg_end_date);

                l_bda_los := (l_asg_duration + 1) - l_absent_duration;
                hr_utility.set_location(l_proc||p_los_type||' Length of Service '||l_bda_los,8);
                RETURN l_bda_los;

            ELSIF (p_assg_start_date >= l_dob_21) and (p_assg_start_date <= l_dob_31) THEN
                RETURN 0;
            END IF;
	  RETURN 0;
        END IF;

    ELSE
        RETURN 0;
    END IF;

END get_bda_length_of_service;

--
-- Function to get the current grade for a person
--
FUNCTION get_current_grade(p_person_id	  IN   per_all_people_f.person_id%TYPE)
RETURN NUMBER IS

CURSOR c_curr_grade IS
SELECT grade_id
  FROM per_all_assignments_f asg
 WHERE asg.person_id = p_person_id
   AND trunc(sysdate) between effective_start_date and effective_end_date;

l_curr_grade_id  per_assignments_f.grade_id%TYPE;

BEGIN
    --
    -- Fetch the grade in the current assignment
    --
    OPEN    c_curr_grade;
    FETCH   c_curr_grade INTO l_curr_grade_id;
    CLOSE   c_curr_grade;

    RETURN l_curr_grade_id;

END;

--
-- This function return the Length of service in a Grade for an Employee - German PS
--

FUNCTION get_de_grade_length_of_service(p_bg_id           IN   per_all_organization_units.organization_id%TYPE,
 		        	        p_person_id	  IN   per_all_people_f.person_id%TYPE,
				        p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
				        p_los_type        IN   VARCHAR2,
				        p_assg_start_date IN   DATE ,
				        p_assg_end_date   IN   DATE
				       )
RETURN NUMBER IS


CURSOR csr_asg_grade IS
SELECT asg.grade_id
  FROM per_all_assignments_f asg
 WHERE asg.person_id = p_person_id
   AND asg.assignment_id = p_assignment_id
   AND asg.effective_start_date = p_assg_start_date
   AND asg.effective_end_date = decode(p_assg_end_date,trunc(sysdate),asg.effective_end_date,p_assg_end_date);

CURSOR c_curr_grade IS
SELECT grade_id
  FROM per_all_assignments_f asg
 WHERE asg.person_id = p_person_id
   AND trunc(sysdate) between effective_start_date and effective_end_date;

CURSOR c_assg_los_type IS
SELECT '1'
  FROM per_assignment_extra_info
 WHERE assignment_id = p_assignment_id
   AND nvl(aei_information1,'x') = p_los_type
   AND information_type = 'DE_PQH_ASSG_LOS_INFO';

   l_grade_id         per_assignments_f.grade_id%TYPE;
   l_curr_grade_id    per_assignments_f.grade_id%TYPE;
   l_proc                      VARCHAR2(60) := g_package||'get_grade_LOS';
   l_grade_los                 NUMBER(22,3) := 0;
   l_absent_duration           NUMBER(22,3) := 0;
   l_grade_entitlements        NUMBER(22,3) := 0;
   l_correction_factor         NUMBER(22,3) := 0;
   l_military_duration         NUMBER(22,3) := 0;
   l_net_grade_los             NUMBER(22,3) := 0;
   l_assg_los_type             VARCHAR2(1);
BEGIN
    hr_utility.set_location('Entering '||l_proc,1);
    OPEN      csr_asg_grade;
    FETCH     csr_asg_grade INTO l_grade_id;
    CLOSE     csr_asg_grade;

    --
    -- If the length of service type is present in the Extra Info then the assignment
    -- is not taken for LOS calculation.
    --

    OPEN c_assg_los_type;
    FETCH c_assg_los_type INTO l_assg_los_type;
    CLOSE c_assg_los_type;

    IF l_assg_los_type IS NOT NULL THEN
      RETURN 0;
    END IF;

    IF l_grade_id IS NOT NULL THEN
        l_curr_grade_id := get_current_grade(p_person_id);
        --
        -- Check if the Grade is the current assignment Grade.
        --
        IF l_grade_id <> nvl(l_curr_grade_id,-1) THEN
            RETURN l_grade_los;
        END IF;
	l_grade_los := p_assg_end_date - p_assg_start_date;
	hr_utility.set_location(l_proc||' Grade Duration '||l_grade_los,2);


-- findout the absence duration for the person during this period
	l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
						p_person_id     => p_person_id,
						p_assignment_id  => p_assignment_id,
						p_los_type      => '40',
						p_start_date    => p_assg_start_date,
						p_end_date      => p_assg_end_date);

--Approximately proportionating the Absence duration to consider the Parttime periods
	hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);
-- collect the correction factor defined (if any) for the person
	/*l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
				                     p_los_type       => '40',
				     	             p_effective_date => p_assg_end_date);
	hr_utility.set_location(l_proc||' Corrected Days '||l_correction_factor,7);
	l_military_duration := get_de_military_service_period (p_bg_id => p_bg_id,
				  			       p_person_id => p_person_id,
							       p_los_type      => '40',
							       p_start_date    => p_assg_start_date,
							       p_end_date      => p_assg_end_date);
	 hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8); */

	l_net_grade_los := l_net_grade_los + (l_grade_los + 1 - l_absent_duration);

    END IF;
    hr_utility.set_location(l_proc||' Net Grade LOS '||l_net_grade_los,8);
    RETURN l_net_grade_los;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_de_grade_length_of_service;

--
-- This Function returns the step in the current assignment of a person
--
FUNCTION get_current_step(p_person_id	  IN   per_all_people_f.person_id%TYPE)
RETURN NUMBER IS

Cursor  c_current_step IS
SELECT  spp.step_id
  FROM  per_spinal_point_placements_f spp, per_all_assignments_f asg
 WHERE  asg.person_id = p_person_id
   AND  spp.assignment_id = asg.assignment_id
   AND  trunc(sysdate) BETWEEN spp.effective_start_date and spp.effective_end_date;

l_curr_step_id         per_spinal_point_placements_f.step_id%TYPE;

BEGIN
    OPEN c_current_step;
    FETCH c_current_step INTO l_curr_step_id;
    CLOSE c_current_step;

    RETURN l_curr_step_id;
END;

-- -----------------------------------------------------------------------*
-- FUNCTION get_step_length_of_service
-- This function returns the  length of service in the current grade step for the employee
-- -----------------------------------------------------------------------*

FUNCTION get_de_step_length_of_service (p_bg_id           IN   per_all_organization_units.organization_id%TYPE,
 		        	        p_person_id	  IN   per_all_people_f.person_id%TYPE,
				        p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
				        p_los_type        IN   VARCHAR2,
				        p_assg_start_date IN   DATE ,
				        p_assg_end_date   IN   DATE
				       )
RETURN NUMBER IS
    Cursor  Csr_asg_step IS
    SELECT  spp.step_id,
            spp.effective_start_date,
            spp.effective_end_date
      FROM  per_spinal_point_placements_f spp, per_all_assignments_f asg
     WHERE  asg.person_id = p_person_id
       AND  asg.assignment_id = p_assignment_id
       AND  spp.assignment_id = asg.assignment_id
       AND  p_assg_end_date BETWEEN spp.effective_start_date and spp.effective_end_date;

    CURSOR c_assg_los_type IS
    SELECT '1'
      FROM per_assignment_extra_info
     WHERE assignment_id = p_assignment_id
       AND nvl(aei_information1,'x') = p_los_type
       AND information_type = 'DE_PQH_ASSG_LOS_INFO';

    l_assignment_id        per_assignments_f.assignment_id%TYPE;
    l_step_id              per_spinal_point_placements_f.step_id%TYPE;
    l_curr_step_id         per_spinal_point_placements_f.step_id%TYPE;
    l_start_date           DATE;
    l_end_date             DATE;
    l_step_los             NUMBER(22,3) := 0;
    l_absent_duration      NUMBER(22,3) := 0;
    l_step_entitlements    NUMBER(22,3) := 0;
    l_correction_factor    NUMBER(22,3) := 0;
    l_military_duration    NUMBER(22,3) := 0;
    l_net_step_los         NUMBER(22,3) := 0;
    l_assg_los_type        VARCHAR2(1);
    l_proc varchar2(60) := g_package||'get_step_LOS';


BEGIN
   hr_utility.set_location('Entering '||l_proc,1);
   OPEN csr_asg_step;
   FETCH csr_asg_step INTO l_step_id, l_start_date, l_end_date;
   CLOSE csr_asg_step;

   OPEN c_assg_los_type;
   FETCH c_assg_los_type INTO l_assg_los_type;
   CLOSE c_assg_los_type;

   --
   -- If the length of service type is present in the Extra Info then the assignment
   -- is not taken for LOS calculation.
   --

   IF l_assg_los_type IS NOT NULL THEN
     RETURN 0;
   END IF;

   IF l_step_id IS NOT NULL THEN
     l_curr_step_id := get_current_step(p_person_id);

     IF l_step_id <> l_curr_step_id THEN
         RETURN l_step_los;
     END IF;

     l_step_los := l_end_date - l_start_date;

     hr_utility.set_location(l_proc||' Step Duration '||l_step_los,2);

-- findout the absence duration for the person during this period
     l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
                                             p_person_id     => p_person_id,
                                             p_assignment_id  => l_assignment_id,
                                             p_los_type      => '50',
                                             p_start_date    => l_start_date,
                                             p_end_date      => l_end_date);

     hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);

-- collect the correction factor defined (if any) for the person
     /*l_correction_factor := get_correction_factor(p_person_id      => p_person_id,
                                                  p_los_type       => '50',
                                                  p_effective_date => l_end_date);
     hr_utility.set_location(l_proc||' Correct Days '||l_correction_factor,7);     /

-- get the military service duration, if entitled for this LOS calculation
     l_military_duration := get_de_military_service_period (p_bg_id => p_bg_id,
                                                            p_person_id => p_person_id,
                                                            p_los_type      => '50',
                                                            p_start_date    => l_start_date,
                                                            p_end_date      => l_end_date);
      hr_utility.set_location(l_proc||' Military service Period '||l_military_duration,8); */

      l_net_step_los := l_net_step_los + (l_step_los + 1 - l_absent_duration);
      hr_utility.set_location(l_proc||' LOS on Step '||l_net_step_los,8);
    END IF;
    RETURN l_net_step_los;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);

END get_de_step_length_of_service;

--
-- This function checks whether the Employee's previous job length of service has
-- to be considered or not.
--

FUNCTION check_prev_job_info (p_prev_job_id   per_previous_jobs.previous_job_id%TYPE)
RETURN VARCHAR2 IS
l_los_flag varchar2(150) := 'N';
CURSOR c_los_flag IS
  SELECT nvl(pjo_information4,'N')
    FROM per_previous_jobs
   WHERE previous_job_id = p_prev_job_id;
BEGIN
    OPEN c_los_flag;
    FETCH c_los_flag INTO l_los_flag;
    CLOSE c_los_flag;
RETURN l_los_flag;

END;

-- -----------------------------------------------------------------------*
-- FUNCTION get_de_assg_length_of_service
-- This function returns the length of service in the current assignment for the employee
-- -----------------------------------------------------------------------*

FUNCTION get_de_assg_length_of_service( p_bg_id           IN   per_all_organization_units.organization_id%TYPE,
                                        p_person_id       IN   per_all_people_f.person_id%TYPE,
                                        p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
				        p_los_type        IN   VARCHAR2,
				        p_assg_start_date IN   DATE ,
				        p_assg_end_date   IN   DATE)
RETURN NUMBER IS


   l_proc varchar2(60) := g_package||'get_de_assg_LOS';

CURSOR c_assg_los_type IS
SELECT '1'
  FROM per_assignment_extra_info
 WHERE assignment_id = p_assignment_id
   AND nvl(aei_information1,'x') = p_los_type
   AND information_type = 'DE_PQH_ASSG_LOS_INFO';


   l_assignment_id             per_assignments_f.assignment_id%TYPE;
   l_position_id               per_assignments_f.position_id%TYPE;
   l_position_los              NUMBER(22,3) := 0;
   l_absent_duration           NUMBER(22,3) := 0;
   l_prev_employment           NUMBER(22,3) := 0;
   l_military_duration         NUMBER(22,3) := 0;
   l_assg_los_type             VARCHAR2(1);

BEGIN
    hr_utility.set_location('Entering '||l_proc,1);
--    OPEN      csr_asg_position;
--    FETCH     csr_asg_position INTO l_assignment_id, l_position_id;
--    CLOSE     csr_asg_position;

    OPEN c_assg_los_type;
    FETCH c_assg_los_type INTO l_assg_los_type;
    CLOSE c_assg_los_type;

    --
    -- If the length of service type is present in the Extra Info then the assignment
    -- is not taken for LOS calculation.
    --

    IF l_assg_los_type IS NOT NULL THEN
      RETURN 0;
    END IF;

    l_position_los := trunc(p_assg_end_date - p_assg_start_date);
	hr_utility.set_location(l_proc||' Position Duration '||l_position_los,2);

-- findout the absence duration for the person during this period
	l_absent_duration := get_absent_period( p_bg_id         => p_bg_id,
						p_person_id     => p_person_id,
						p_assignment_id  => l_assignment_id,
						p_los_type      => p_los_type,
						p_start_date    => p_assg_start_date,
						p_end_date      => p_assg_start_date);
        hr_utility.set_location(l_proc||' Absent Duration '||l_absent_duration,6);

        l_position_los := (l_position_los + 1)- l_absent_duration;

    hr_utility.set_location(l_proc||' Net Position LOS '||l_position_los,8);

    RETURN l_position_los;
EXCEPTION
   When Others THEN
      hr_utility.set_location('Erroring out from '||l_proc,5);
      RAISE_Application_Error(-20001,SQLERRM);
END get_de_assg_length_of_service;
--
-- This function returns the length of service for a person
-- This is called in the Report for Period of Employment - DEPS
--

FUNCTION get_length_of_service( p_bg_id               IN   per_all_organization_units.organization_id%TYPE,
 		        	p_person_id	      IN   per_all_people_f.person_id%TYPE,
				p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE DEFAULT NULL,
				p_prev_job_id         IN   per_previous_jobs.previous_job_id%TYPE DEFAULT NULL,
				p_los_type            IN   VARCHAR2,
				p_assg_start_date     IN   DATE ,
				p_assg_end_date       IN   DATE
                              ) RETURN VARCHAR2 is

 l_end_date           DATE := p_assg_end_date;
 l_los_days           NUMBER := 0;
 l_los_years 	      NUMBER := 0;
 l_los_months         NUMBER := 0;
 l_los_return         VARCHAR2(240);
 l_adj_service_date   DATE;
 l_date_of_birth      DATE;
 l_start_date	      DATE;
 l_exists             VARCHAR2(2) := '0';
 l_correction_factor  NUMBER(22,3) := 0;
 l_prev_grade_id      per_previous_jobs.pjo_information2%TYPE;
 l_prev_step_id       per_previous_jobs.pjo_information3%TYPE;
 l_curr_grade_id      per_assignments_f.grade_id%TYPE;
 l_curr_step_id       per_spinal_point_placements_f.step_id%TYPE;
 l_emp_type           per_previous_jobs.employment_category%TYPE := 'x';
 l_employer_type      per_previous_employers.employer_type%TYPE := 'x';
 l_prev_empl_id       per_previous_employers.previous_employer_id%TYPE;
 l_person_id          per_all_people_f.person_id%TYPE;
 l_bg_id              per_all_organization_units.organization_id%TYPE := p_bg_id;
 l_entitlement        pqh_situations.entitlement_value%TYPE :=0;
 l_assignment_id      per_all_assignments_f.assignment_id%TYPE := p_assignment_id;
 l_proc               VARCHAR2(60) := g_package||'get_length_of_service';
 l_primary_flag	      per_all_assignments_f.primary_flag%TYPE;

 CURSOR CSR_validate_person IS
 SELECT  '1'
   FROM  per_all_people_f
  WHERE  person_id = p_person_id
    AND  (p_assg_start_date BETWEEN effective_start_date AND effective_end_date
         or  l_end_date BETWEEN effective_start_date AND effective_end_date);

 CURSOR CSR_validate_assignment IS
 SELECT person_id, primary_flag
   FROM per_all_assignments_f
  WHERE assignment_id = p_assignment_id
    AND (p_assg_start_date BETWEEN effective_start_date AND effective_end_date
        or  l_end_date BETWEEN effective_start_date AND effective_end_date);

 CURSOR c_prev_job_info IS
 SELECT (end_date - start_date) los_days, previous_employer_id, pjo_information2, pjo_information3
   FROM per_previous_jobs
  WHERE previous_job_id = p_prev_job_id
    AND start_date = p_assg_start_date
    AND end_date   = l_end_date;

CURSOR c_prev_employers IS
SELECT nvl(employer_type,'x')
  FROM per_previous_employers
 WHERE previous_employer_id = l_prev_empl_id;

CURSOR c_person_dob IS
SELECT date_of_birth
  FROM per_all_people_f
 WHERE person_id = p_person_id
   AND trunc(sysdate) BETWEEN effective_start_date AND effective_end_date;

 CURSOR c_empl_entitlements IS
 SELECT NVL(entitlement_value,0)
   FROM pqh_situations
  WHERE business_group_id = p_bg_id
    AND situation_type = 'EMPLOYMENT'
    AND length_of_service = p_los_type
    AND situation = decode(l_employer_type,'CM','C',l_employer_type)
    AND employee_type = l_emp_type
    AND p_assg_start_date BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time)
    AND l_end_date  BETWEEN effective_start_date AND NVL(effective_end_date,g_end_of_time)
    AND entitlement_flag = 'Y';

CURSOR c_emp_catg IS
SELECT nvl(employment_category,'x')
  FROM per_previous_jobs
 WHERE previous_job_id = p_prev_job_id;

BEGIN

      hr_utility.set_location('Entering '||l_proc,1);

      IF p_assg_end_date = g_end_of_time THEN
          l_end_date := trunc(sysdate);
      END IF;

      IF p_bg_id IS NULL THEN
          hr_api.mandatory_arg_error(p_api_name => l_proc,
                                     p_argument => 'Business Group Id',
                                     p_argument_value => p_bg_id);
      ELSE
          hr_api.validate_bus_grp_id(p_business_group_id => p_bg_id);
      END IF;

      IF p_person_id IS NULL THEN
          hr_api.mandatory_arg_error(p_api_name => l_proc,
	                             p_argument => 'Person Id',
                                     p_argument_value => p_person_id);

      ELSIF p_person_id IS NOT NULL AND p_prev_job_id IS NULL THEN

          OPEN Csr_validate_person;
          FETCH Csr_validate_person INTO l_exists;
          CLOSE Csr_validate_person;
          IF l_exists = '0' THEN
            fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
            fnd_message.set_token('VALUE',to_char(p_person_id));
            fnd_message.set_token('PARAMETER','p_person_id');
            fnd_message.raise_error;
          END IF;
      END IF;

      IF p_assignment_id IS NOT NULL THEN
        OPEN Csr_validate_assignment;
        FETCH Csr_validate_assignment INTO l_person_id, l_primary_flag;
        IF Csr_validate_assignment%NOTFOUND THEN
 	  CLOSE Csr_validate_assignment;
	  fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
	  fnd_message.set_token('VALUE',to_char(p_assignment_id));
	  fnd_message.set_token('PARAMETER','p_assignment_id');
	  fnd_message.raise_error;
        END IF;
        CLOSE Csr_validate_assignment;
        IF l_person_id <> NVL(p_person_id,-999999) THEN
 	    fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
	    fnd_message.set_token('VALUE',to_char(p_person_id));
	    fnd_message.set_token('PARAMETER','p_person_id');
	    fnd_message.raise_error;
        END IF;
        l_person_id := NVL(p_person_id,l_person_id);
      END IF;

      IF p_los_type IS NULL THEN
        hr_api.mandatory_arg_error(p_api_name => l_proc,
	                           p_argument => 'Length of Service Type',
                                   p_argument_value => p_los_type);
      ELSE
	IF hr_api.NOT_EXISTS_IN_HR_LOOKUPS(p_effective_date => l_end_date,
				           p_lookup_type => 'FR_PQH_LENGTH_OF_SERVICE_TYPE',
				           p_lookup_code => p_los_type) THEN
	  fnd_message.set_name('PQH','PQH_INVALID_PARAM_VALUE');
	  fnd_message.set_token('VALUE',p_los_type);
	  fnd_message.set_token('PARAMETER','p_los_type');
	END IF;
      END IF;

      IF p_prev_job_id IS NOT NULL THEN
          IF p_los_type in ('20','40','50','70','90') THEN

	      OPEN c_emp_catg;
	      FETCH c_emp_catg INTO l_emp_type;
	      CLOSE c_emp_catg;

	      -- Check if the LOS flag is 'Yes' in Previous Employment
	      IF check_prev_job_info(p_prev_job_id) = 'Y' THEN
		OPEN c_prev_job_info;
		FETCH c_prev_job_info into l_los_days, l_prev_empl_id, l_prev_grade_id, l_prev_step_id;
		CLOSE c_prev_job_info;

                --
                -- Check whether the current grade is the same grade in the previous job.
                --

		IF p_los_type = '40' THEN
		    l_curr_grade_id := get_current_grade(p_person_id);

		    IF l_prev_grade_id <> l_curr_grade_id THEN
		      RETURN l_los_days;
		    END IF;
		END IF;

                --
                -- Check whether the current step is the same step in the previous job.
                --

		IF p_los_type = '50' THEN
		    l_curr_step_id := get_current_step(p_person_id);

		    IF l_prev_step_id <> l_curr_step_id THEN
		      RETURN l_los_days;
		    END IF;
		END IF;

		OPEN c_prev_employers;
		FETCH c_prev_employers INTO l_employer_type;
		CLOSE c_prev_employers;

		OPEN c_empl_entitlements;
		FETCH c_empl_entitlements INTO l_entitlement;
		CLOSE c_empl_entitlements;

		OPEN c_person_dob;
		FETCH c_person_dob INTO l_date_of_birth;
		CLOSE c_person_dob;

		IF l_date_of_birth IS NOT NULL THEN
		    IF months_between(p_assg_start_date,l_date_of_birth)/12 < 18 THEN
		       l_start_date := add_months(l_date_of_birth,18*12);
		       l_los_days := (p_assg_end_date - l_start_date);
		    END IF;
		END IF;

		l_los_days := (l_los_days + 1) * (l_entitlement/100);

	      END IF;
	  END IF;

      ELSE
        IF l_primary_flag = 'Y' THEN
          IF p_los_type = '10' THEN -- Length of service with Current Employer

              IF l_assignment_id IS NOT NULL THEN
                  l_los_days := get_de_pub_length_of_service( p_bg_id                => l_bg_id,
							      p_person_id            => l_person_id,
							      p_assignment_id        => l_assignment_id,
							      p_los_type             => p_los_type,
							      p_assg_start_date      => p_assg_start_date,
							      p_assg_end_date        => l_end_date);
              END IF;

          ELSIF p_los_type = '20' THEN -- General Length of service and Length of service in Public Service
              l_los_days := get_de_pub_length_of_service( p_bg_id                => l_bg_id,
							  p_person_id            => l_person_id,
							  p_assignment_id        => l_assignment_id,
							  p_los_type             => p_los_type,
							  p_assg_start_date      => p_assg_start_date,
							  p_assg_end_date        => l_end_date);


          ELSIF p_los_type = '40' THEN -- Length of Service in Current Grade
	      l_los_days := get_de_grade_length_of_service(p_bg_id                => p_bg_id,
						           p_person_id            => l_person_id,
						           p_assignment_id        => l_assignment_id,
						           p_los_type             => p_los_type,
						           p_assg_start_date      => p_assg_start_date,
						           p_assg_end_date        => l_end_date);

      	  ELSIF p_los_type = '50' THEN -- Length of Service in Current Step
	      l_los_days := get_de_step_length_of_service(p_bg_id                => p_bg_id,
	   					          p_person_id            => l_person_id,
						          p_assignment_id        => l_assignment_id,
						          p_los_type             => p_los_type,
						          p_assg_start_date      => p_assg_start_date,
						          p_assg_end_date        => l_end_date);


          ELSIF p_los_type = '70' THEN -- Length of Service for Jubilee Money
              l_los_days := get_jub_mon_length_of_service(p_bg_id                => l_bg_id,
                                                          p_person_id            => l_person_id,
                                                          p_assignment_id        => l_assignment_id,
                                                          p_los_type             => p_los_type,
                                 		          p_assg_start_date      => p_assg_start_date,
				                          p_assg_end_date        => l_end_date);

      	  ELSIF p_los_type = '80' THEN -- Length of service for BDA Calculation
              l_los_days := get_bda_length_of_service(p_bg_id                => l_bg_id,
						      p_person_id            => l_person_id,
						      p_assignment_id        => l_assignment_id,
						      p_los_type             => p_los_type,
						      p_assg_start_date      => p_assg_start_date,
						      p_assg_end_date        => l_end_date);
      	  ELSIF p_los_type = '90' THEN -- Length of service in Assignment
              l_los_days := get_de_assg_length_of_service(p_bg_id                => l_bg_id,
						      	  p_person_id            => l_person_id,
						      	  p_assignment_id        => l_assignment_id,
						      	  p_los_type             => p_los_type,
						      	  p_assg_start_date      => p_assg_start_date,
						      	  p_assg_end_date        => l_end_date);
          END IF;
        END IF;
      END IF;

   l_adj_service_date := l_end_date - l_los_days;

   hr_utility.set_location(l_proc||' Adjusted Service Date '||To_Char(l_adj_service_date,'DD-MM-RRRR'),3);

/*   IF nvl(l_los_days,0) < 365 THEN
       l_los_return := round(to_char(nvl(l_los_days,0)))|| ' Days ';
   ELSE
   --
   -- Return the Length of Service in Years and Days.
   --
       l_los_return := trunc(nvl(l_los_days,0)/365) || ' Years ' || round(substr((nvl(l_los_days,0)/365),instr((nvl(l_los_days,0)/365),'.',1)) * 365) || ' Days ';
       l_los_return := trunc(months_between(l_end_date,(l_end_date-l_los_days))/12)

   END IF;   */

        l_los_years := months_between(l_end_date,l_adj_service_date)/12;

        If instr(l_los_years,'.',1) <> 0 Then
          l_los_months := substr(l_los_years,instr(l_los_years,'.',1)) * 12;
        End If;

        IF trunc(l_los_years) = 0 and trunc(l_los_months) = 0 THEN
          l_los_return := 0||'/'||0||'/'||l_los_days;
        ELSE
          l_los_days := round(substr(l_los_months,instr(l_los_months,'.',1)) * 31);
          l_los_return := trunc(l_los_years)||'/'||trunc(l_los_months)||'/'||l_los_days;
        END IF;

   RETURN l_los_return;

END get_length_of_service;

FUNCTION get_de_correction_factor(p_person_id       IN per_all_people_f.person_id%TYPE,
                                  p_los_type        IN hr_lookups.lookup_code%TYPE,
                                  p_effective_date  IN DATE)
RETURN VARCHAR2 IS

CURSOR c_correction_factor IS
SELECT nvl(pei.pei_information4,'0')
  FROM per_people_extra_info pei
 WHERE pei.person_id = p_person_id
   AND pei.information_type ='DE_PQH_POE_INFO'
   AND pei.pei_information1 = p_los_type
   AND p_effective_date BETWEEN fnd_date.canonical_to_date(pei.pei_information2)
       AND NVL(fnd_date.canonical_to_date(pei.pei_information3),g_end_of_time);

l_correction_factor     per_people_extra_info.pei_information4%TYPE;

BEGIN

    OPEN c_correction_factor;
    FETCH c_correction_factor INTO l_correction_factor;
    CLOSE c_correction_factor;
    RETURN (nvl(l_correction_factor,'0'));

END get_de_correction_factor;

FUNCTION get_corps_name (p_assignment_id  IN per_all_assignments_f.assignment_id%TYPE,
                                 p_bg_id          IN per_all_organization_units.organization_id%TYPE)
RETURN VARCHAR2 IS

cursor csr_corps is
select segment7  from hr_soft_coding_keyflex where id_flex_num in
(select id_flex_num from fnd_id_flex_structures fifs
where id_flex_structure_code = 'FR_STATUTORY_INFO.'
and fifs.application_id = 800 and fifs.id_flex_code = 'SCL')
and soft_coding_keyflex_id in
(select soft_coding_keyflex_id from per_all_assignments_f where
 assignment_id = p_assignment_id
 and business_group_id = p_bg_id);
l_corps_id number(20);
l_corps_name varchar2(100);
BEGIN
for c_corps in csr_corps loop
	l_corps_id := to_number(c_corps.segment7);
end loop;

if l_corps_id is not null then
	select name into l_corps_name from pqh_corps_definitions
	where corps_definition_id = l_corps_id;
end if;

return l_corps_name;
END;

FUNCTION get_corps_name (p_corps_id IN pqh_corps_definitions.corps_definition_id%TYPE)
RETURN VARCHAR2 IS
l_corps_name varchar2(100);
BEGIN
if p_corps_id is not null then
	select name into l_corps_name from pqh_corps_definitions
	where corps_definition_id = p_corps_id;
end if;
return l_corps_name;
END;

FUNCTION get_grade_name (p_grade_id IN per_grades.grade_id%TYPE)
RETURN VARCHAR2 IS
l_grade_name varchar2(100);
BEGIN
if p_grade_id is not null then
select name into l_grade_name from per_grades_vl where
grade_id = p_grade_id;
end if;
return l_grade_name;
END;
--
   FUNCTION get_date_diff_for_display (
      p_start_date   IN   DATE,
      p_end_date     IN   DATE DEFAULT SYSDATE
   )
      RETURN VARCHAR2
   IS
      l_display_los   VARCHAR2 (200);
      l_yy            NUMBER (5);
      l_mm            NUMBER (5);
      l_dd            NUMBER (5);
      l_temp_los_mm   NUMBER (22, 3);
      l_proc          VARCHAR2 (60)
                                  := g_package || 'get_date_diff_for_display';
   BEGIN
      hr_utility.set_location (l_proc || ' Entering', 10);

      IF (p_start_date IS NOT NULL AND p_end_date IS NOT NULL)
      THEN
         l_temp_los_mm := MONTHS_BETWEEN (p_end_date, p_start_date);
         l_yy := NVL ((l_temp_los_mm - MOD (l_temp_los_mm, 12)) / 12, 0);
         l_temp_los_mm := l_temp_los_mm - l_yy * 12;
         l_mm := NVL (TRUNC (l_temp_los_mm, 0), 0);
         l_dd :=
            NVL (  p_end_date
                 - TRUNC (ADD_MONTHS (p_start_date, (l_mm + l_yy * 12))),
                 0
                );
         l_display_los :=
               NVL (l_yy, 0)
            || ' '
            || hr_general.decode_lookup ('QUALIFYING_UNITS', 'Y')
            || '  '
            || NVL (l_mm, 0)
            || ' '
            || hr_general.decode_lookup ('QUALIFYING_UNITS', 'M')
            || '  '
            || l_dd
            || ' '
            || hr_general.decode_lookup ('QUALIFYING_UNITS', 'D');
      END IF;

      hr_utility.set_location (l_proc || l_display_los, 15);
      hr_utility.set_location (l_proc || ' Leaving', 20);
      RETURN l_display_los;
   END get_date_diff_for_display;

--

END pqh_length_of_service_pkg;

/

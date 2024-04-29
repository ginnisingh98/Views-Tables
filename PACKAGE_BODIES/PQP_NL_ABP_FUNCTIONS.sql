--------------------------------------------------------
--  DDL for Package Body PQP_NL_ABP_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_NL_ABP_FUNCTIONS" AS
/* $Header: pqpnlabp.pkb 120.34 2008/01/03 12:53:48 rsahai noship $ */
-- =============================================================================
-- to_nl_date: Function to convert the date to the appropriate value
-- since the ben logs contain dates in the NL Language -- 31-MEI-05
-- 1-OKT-05 etc
-- =============================================================================
FUNCTION to_nl_date (p_date_value  IN VARCHAR2,
                     p_date_format IN VARCHAR2)
RETURN DATE IS

BEGIN

   IF LENGTH(p_date_value) = 9 THEN
      RETURN TO_DATE(p_date_value,p_date_format,'NLS_DATE_LANGUAGE = ''DUTCH''');
   ELSE
      RETURN TO_DATE(p_date_value,p_date_format);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   RETURN To_date(p_date_value,p_date_format,'NLS_DATE_LANGUAGE = ''AMERICAN''');

END to_nl_date;

--
-- ------------------------------------------------------------------------
-- |-----------------------< get_reporting_date >-------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_reporting_date
        (p_effective_date        IN  DATE
        ,p_person_id             IN  per_all_people_f.person_id%TYPE
        ,p_reporting_date        OUT NOCOPY DATE
        )
RETURN NUMBER IS

CURSOR c_last_ext IS
SELECT eff_dt
  FROM ben_ext_rslt res
 WHERE ext_dfn_id IN (SELECT ext_dfn_id
                        FROM pqp_extract_attributes
                       WHERE ext_dfn_type = 'NL_FPR')
   AND ext_stat_cd = 'A'
   AND EXISTS ( SELECT 1 FROM ben_ext_rslt_dtl dtl
                 WHERE dtl.ext_rslt_id = res.ext_rslt_id
                   AND dtl.person_id   = p_person_id)
ORDER BY ext_rslt_id DESC;

l_last_app_ext   DATE;

BEGIN
--
-- Fetch the last date for which the extract was sent to the provider
--
 OPEN c_last_ext;
FETCH c_last_ext INTO l_last_app_ext;
   IF c_last_ext%NOTFOUND THEN
      l_last_app_ext := NULL;
   END IF;
CLOSE c_last_ext;

IF l_last_app_ext IS NULL THEN
   p_reporting_date := trunc(p_effective_date);
ELSE
   p_reporting_date := add_months(TRUNC(l_last_app_ext),1);
END IF;

   p_reporting_date := GREATEST(p_reporting_date,trunc(p_effective_date));

hr_utility.set_location('.......... p_reporting_date IS '||p_reporting_date,10);
hr_utility.set_location('.......... l_last_app_ext IS '||l_last_app_ext,10);

RETURN 0;

EXCEPTION
WHEN OTHERS THEN
   p_reporting_date := NULL;
   RETURN 1;

END get_reporting_date;

--
-- ------------------------------------------------------------------------
-- |-----------------------< get_reporting_date >-------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_reporting_date
        (p_effective_date        IN  DATE
        ,p_assignment_id         IN  per_all_assignments_f.assignment_id%TYPE
        ,p_person_id             IN  per_all_people_f.person_id%TYPE
        ,p_reporting_date        OUT NOCOPY DATE
        )
RETURN NUMBER IS

CURSOR c_last_ext IS
SELECT eff_dt
  FROM ben_ext_rslt res
 WHERE ext_dfn_id IN (SELECT ext_dfn_id
                        FROM pqp_extract_attributes
                       WHERE ext_dfn_type = 'NL_FPR')
   AND ext_stat_cd = 'A'
   AND EXISTS ( SELECT 1 FROM ben_ext_rslt_dtl dtl
                 WHERE dtl.ext_rslt_id = res.ext_rslt_id
                   AND dtl.person_id   = p_person_id)
ORDER BY ext_rslt_id DESC;

CURSOR c_ppa_dt (c_eff_dt IN DATE) IS
SELECT effective_date
  FROM pay_payroll_actions pact
 WHERE action_type IN ('Q','R')
   AND action_status = 'C'
   AND EXISTS (SELECT 1 FROM pay_assignment_actions act
                WHERE act.payroll_action_id = pact.payroll_action_id
                  AND assignment_id         = p_assignment_id
                  AND action_status = 'C')
   AND effective_date >= c_eff_dt
ORDER BY payroll_action_id desc;

l_last_app_ext   DATE;
l_pa_eff_dt      DATE;

BEGIN


--
-- Fetch the last date for which the extract was sent to the provider
--
 OPEN c_last_ext;
FETCH c_last_ext INTO l_last_app_ext;
   IF c_last_ext%NOTFOUND THEN
      l_last_app_ext := NULL;
   END IF;
CLOSE c_last_ext;

--
-- Check if any payroll has been processed after the last file was sent
-- to the provider. If payroll has been processed then the reporting date
-- is  the next month as the change is being made after processing payroll
--
 OPEN c_ppa_dt ( TRUNC(NVL(l_last_app_ext,p_effective_date)));
FETCH c_ppa_dt INTO l_pa_eff_dt;
   IF c_ppa_dt%FOUND THEN
         p_reporting_date := add_months(TRUNC(l_pa_eff_dt),1);
   ELSIF c_ppa_dt%NOTFOUND THEN
      IF l_last_app_ext IS NULL THEN
         p_reporting_date := p_effective_date;
      ELSE
         p_reporting_date := add_months(TRUNC(l_last_app_ext),1);
      END IF;
   END IF;
CLOSE c_ppa_dt;
hr_utility.set_location('.......... p_reporting_date IS '||p_reporting_date,10);
hr_utility.set_location('.......... l_pa_eff_dt IS '||l_pa_eff_dt,10);
hr_utility.set_location('.......... l_last_app_ext IS '||l_last_app_ext,10);


RETURN 0;

EXCEPTION
WHEN OTHERS THEN
   p_reporting_date := NULL;
   RETURN 1;

END get_reporting_date;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_valid_start_date >-----------------------------|
-- ----------------------------------------------------------------------------
--

Function get_valid_start_date
   ( p_assignment_id in NUMBER
    ,p_eff_date      in DATE
    ,p_error_status out nocopy CHAR
    ,p_error_message out nocopy VARCHAR2)
Return DATE IS

--
--Cursor to fetch the Assignment Start Date
--
CURSOR c_chk_assgn_start_date IS
SELECT effective_start_date
  FROM per_all_assignments_f
 WHERE (assignment_id = p_assignment_id)
   AND assignment_type = 'E'
   AND (TO_DATE('01/01/'||TO_CHAR(p_eff_date,'YYYY'),'dd/mm/yyyy')
       BETWEEN effective_start_date and effective_end_date);

--
--Cursor to fetch the First Assignment Start Date of a particular year
--
CURSOR c_get_assgn_start_date IS
SELECT MIN(effective_start_date)
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND assignment_type = 'E'
   AND (effective_start_date
       BETWEEN TO_DATE('01/01/'||TO_CHAR(p_eff_date,'YYYY'),'dd/mm/yyyy')
           AND TO_DATE('31/12/'||TO_CHAR(p_eff_date,'YYYY'),'dd/mm/yyyy'));

l_hire_date       DATE;
l_assgn_st_date   DATE;
l_person_id       NUMBER;
l_curr_year       VARCHAR2(10);

BEGIN

   --
   --Fetch the current year from the eff date
   --
   l_curr_year := TO_CHAR(p_eff_date,'YYYY');
   p_error_status :=trim(to_char(0,'9'));

   OPEN c_chk_assgn_start_date;
      FETCH c_chk_assgn_start_date
       INTO l_assgn_st_date;
      --
      -- If  Assignment is valid on 1st jan of that
      -- year return 1st of Jan of that year
      --
         IF c_chk_assgn_start_date%FOUND THEN
	   CLOSE c_chk_assgn_start_date;
	   RETURN TO_DATE('01/01/'||l_curr_year,'dd/mm/yyyy');
	 ELSE
	   CLOSE c_chk_assgn_start_date;
           --
	   -- If not valid then return first
           -- assignment date for that year
           --
	   OPEN c_get_assgn_start_date;
	      FETCH c_get_assgn_start_date
               INTO l_assgn_st_date;

	      IF c_get_assgn_start_date%FOUND THEN
	         CLOSE c_get_assgn_start_date;
	         RETURN l_assgn_st_date;
	      ELSE
	         CLOSE c_get_assgn_start_date;
              --
	      -- No assignment found
              --
              p_error_message := 'PQP_230205_ASSGN_NOT_EXISTS';
              p_error_status  := trim(to_char(1,'9'));
              return to_date('31/12/4712','dd/mm/yyyy');
	      END IF;
	END IF;

END get_valid_start_date;

-- ----------------------------------------------------------------------------
-- |-----------------------< register_retro_change >---------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure updates the input value on one of the
-- ABP Pensions General Information element input values.
-- This is necessary so that the change in the ASG EIT will be
-- picked up in the retro notification report.
--

PROCEDURE register_retro_change
          (p_assignment_id    NUMBER
          ,p_effective_date   DATE
          ) IS

--
-- CURSOR to get the input_value_id
--
CURSOR c_inp_val IS
SELECT piv.input_value_id
      ,pet.element_type_id
  FROM pay_input_values_f  piv
      ,pay_element_types_f pet
 WHERE piv.element_type_id  = pet.element_type_id
   AND pet.element_name     = 'ABP Pensions Part Time Percentage'
   AND piv.name             = 'Part Time Percentage'
   AND pet.legislation_code = 'NL'
   AND piv.legislation_code = 'NL'
   AND p_effective_date BETWEEN piv.effective_start_date
                            AND piv.effective_end_date
   AND p_effective_date BETWEEN pet.effective_start_date
                            AND pet.effective_end_date;

--
-- CURSOR to get the element_entry_id
--
CURSOR c_ele_ent (c_element_type_id IN NUMBER)IS
SELECT pee.element_entry_id
  FROM pay_element_entries_f pee
      ,pay_element_links_f pel
 WHERE pee.element_link_id = pel.element_link_id
   AND pee.assignment_id = p_assignment_id
   AND pel.element_type_id = c_element_type_id
   AND p_effective_date BETWEEN pel.effective_start_date
                            AND pel.effective_end_date
   AND p_effective_date BETWEEN pee.effective_start_date
                            AND pee.effective_end_date;

--
-- CURSOR to check if valid assignment actions exist and
-- payroll has been processed.
--
CURSOR c_ass_act IS
SELECT 1
  FROM pay_payroll_actions ppa
 WHERE ppa.action_status  = 'C'
   AND ppa.action_type IN ('Q','R')
   AND ppa.effective_date >= p_effective_date
   AND EXISTS ( SELECT 1
                  FROM pay_assignment_actions paa
                 WHERE ppa.payroll_action_id = paa.payroll_action_id
                   AND paa.assignment_id     = p_assignment_id
                   AND paa.action_status     = 'C' )
   AND rownum = 1;

l_element_type_id   PAY_ELEMENT_TYPES_F.element_type_id%TYPE;
l_input_value_id    PAY_INPUT_VALUES_F.input_value_id%TYPE;
l_element_entry_id  PAY_ELEMENT_ENTRIES_F.element_entry_id%TYPE;
l_ass_act           NUMBER;

BEGIN

--
-- Check if the change made is a retrospective change.
-- Any changes that are made before the effictive date
-- passed in are considered retrospective. The reason is
-- the existence of asg acts after the effective date.
--

OPEN c_ass_act;
   FETCH c_ass_act INTO l_ass_act;
   --
   -- Proceed further only if a retrospective change is being made
   --
   IF c_ass_act%FOUND THEN
   --
   -- Get the value for the element_type and input value
   --
   OPEN c_inp_val;
      FETCH c_inp_val INTO
            l_input_value_id
           ,l_element_type_id;
        --
        -- Check if the seeded element and input exist
        --
        IF c_inp_val%FOUND THEN
           --
           -- Get the value for the element_entry_id
           --
           OPEN c_ele_ent(l_element_type_id);
              FETCH c_ele_ent INTO
                    l_element_entry_id;
              --
              -- Check if element_entry is found
              --
              IF c_ele_ent%NOTFOUND THEN
                 NULL;
                 -- Raise Warning
              ELSE
              --
              -- Update the element entry by calling the API
              --
                 hr_entry_api.update_element_entry
                    (p_dt_update_mode             => 'CORRECTION',
                     p_session_date               => p_effective_date,
                     p_element_entry_id           => l_element_entry_id,
                     p_input_value_id1            => l_input_value_id,
                     p_entry_value1               => 100,
                     p_entry_information_category => NULL,
                     p_override_user_ent_chk      => 'Y'
                    );

                 hr_entry_api.update_element_entry
                    (p_dt_update_mode             => 'CORRECTION',
                     p_session_date               => p_effective_date,
                     p_element_entry_id           => l_element_entry_id,
                     p_input_value_id1            => l_input_value_id,
                     p_entry_value1               => NULL,
                     p_entry_information_category => NULL,
                     p_override_user_ent_chk      => 'Y'
                    );

              END IF; -- Check if element_entry is found

           CLOSE c_ele_ent;

        END IF; -- Check if the seeded element and input exist

   CLOSE c_inp_val;

   END IF; -- Check if asg acts exist

CLOSE c_ass_act;

END register_retro_change;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< cre_ret_ent_ad >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to create retro entries after the deletion of
-- ABP participation and override information from the ASG EIT.
--
PROCEDURE cre_ret_ent_ad
           ( p_assignment_extra_info_id_o   IN NUMBER
            ,p_assignment_id_o              IN NUMBER
            ,p_information_type_o           IN VARCHAR2
            ,p_aei_information1_o           IN VARCHAR2
            ,p_aei_information2_o           IN VARCHAR2) IS
BEGIN

   IF p_information_type_o IN ('NL_ABP_PI','NL_ABP_PAR_INFO') THEN
      --
      -- Call the procedure to register this change
      --
      register_retro_change
      (p_assignment_id    => p_assignment_id_o
      ,p_effective_date   => trunc(to_date(substr(p_aei_information1_o,1,10)
                                   ,'YYYY/MM/DD')));
   END IF;

END cre_ret_ent_ad;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dup_pt_row_ins >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_pt_row_ins (  p_org_information_id      number
                               ,p_org_information_context varchar2
                               ,p_organization_id         number
                               ,p_org_information1        varchar2
                               ,p_org_information2        varchar2
                               ,p_org_information3        varchar2
                               ,p_org_information4        varchar2 default null
                               ,p_org_information5        varchar2 default null
                               ,p_org_information6        varchar2 default null
                             ) IS
CURSOR cur_abp_pt IS
SELECT org_information1
      ,nvl(org_information2,'4712/12/31') org_information2
  FROM hr_organization_information
 WHERE org_information3 = p_org_information3
   AND organization_id  = p_organization_id
   AND org_information_id <> p_org_information_id
   AND org_information_context = 'PQP_NL_ABP_PT';

CURSOR cur_pggm_pt IS
SELECT org_information1
      ,nvl(org_information2,'4712/12/31') org_information2
  FROM hr_organization_information
 WHERE org_information3 = p_org_information3
   AND organization_id  = p_organization_id
   AND org_information_id <> p_org_information_id
   AND org_information_context = 'PQP_NL_PGGM_PT';

CURSOR cur_pggm_info IS
SELECT org_information1
      ,nvl(org_information2,'4712/12/31') org_information2
  FROM hr_organization_information
 WHERE organization_id  = p_organization_id
   AND org_information_id <> p_org_information_id
   AND org_information_context = 'PQP_NL_PGGM_INFO';

--
--Cursor to find the pension sub category for the ABP Pension Type
--
CURSOR cur_get_pen_sub_cat(c_pension_type_id  in varchar2) IS
SELECT pension_sub_category,
       threshold_conversion_rule,
       contribution_conversion_rule,
       pension_basis_calc_method
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--
--Cursor to find the start and end dates for a particular pension type
--
CURSOR cur_get_st_end_dates(c_pension_type_id in varchar2) IS
SELECT effective_start_date,effective_end_date
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--cursor to fetch the effective date the user has datetracked to
CURSOR c_get_eff_date IS
SELECT effective_date
   FROM fnd_sessions
WHERE session_id IN
                 (SELECT userenv('sessionid')
                    FROM dual
                 );

--
--Cursor to find all rows which have dates overlapping the current record dates
--
CURSOR cur_get_overlap_rows IS
SELECT org_information3
  FROM hr_organization_information
WHERE organization_id = p_organization_id
  AND org_information_id <> p_org_information_id
  AND org_information_context = 'PQP_NL_ABP_PT'
  AND ((trunc(to_date(substr(org_information1,1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
        AND trunc(to_date(substr(org_information1,1,10),'YYYY/MM/DD'))
            <= trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(nvl(org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
       AND trunc(to_date(substr(nvl(org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
           <= trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(org_information1,1,10),'YYYY/MM/DD'))
      <= trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
      AND trunc(to_date(substr(nvl(org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
          >= trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      );

--Cursor to find the start and end dates of schemes created using the given PT
CURSOR cur_get_schm_st_end(c_pension_type_id IN varchar2) IS
SELECT to_date(substr(eei_information10,1,10),'DD/MM/YYYY') start_date,
       to_date(substr(eei_information11,1,10),'DD/MM/YYYY') end_date
  FROM pay_element_type_extra_info
WHERE  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND  eei_information2 = c_pension_type_id;

l_min_start_date       DATE;
l_max_end_date         DATE;
l_counter              NUMBER := 0;
l_pen_sub_cat1         pqp_pension_types_f.pension_sub_category%TYPE;
l_pen_sub_cat2         pqp_pension_types_f.pension_sub_category%TYPE;
l_thresh_conv_rule1    pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_thresh_conv_rule2    pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_contrib_conv_rule1   pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_contrib_conv_rule2   pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_basis_method1        pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_basis_method2        pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_min_st_dt            DATE;
l_max_end_dt           DATE;
l_min_schm_st          DATE;
l_max_schm_end         DATE;
l_eff_date             DATE;

BEGIN
IF p_org_information_context = 'PQP_NL_ABP_PT' THEN

      --first find the eff date the user had datetracked to
      OPEN c_get_eff_date;
      FETCH c_get_eff_date INTO l_eff_date;
      CLOSE c_get_eff_date;

      --
      -- Check if the End Date is Less than or equal
      -- to the Start Date
      --
      IF trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   --
   -- Check to see that the start and end dates entered are between the
   -- min start date and max end date of the pension type
   --
   FOR temp_rec IN cur_get_st_end_dates(p_org_information3)
      LOOP

      -- Loop through all the date tracked rows of the pension type and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_st_dt  := temp_rec.effective_start_date;
         l_max_end_dt := temp_rec.effective_end_date;
      ELSE
         IF temp_rec.effective_start_date <  l_min_st_dt THEN
            l_min_st_dt := temp_rec.effective_start_date;
         END IF;

         IF temp_rec.effective_end_date > l_max_end_dt THEN
            l_max_end_dt := temp_rec.effective_end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and
   -- greatest end date,of all date tracked rows of the PT, raise an error
   IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
      <  l_min_st_dt
      OR trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      > l_max_end_dt THEN
       hr_utility.set_message(8303,'PQP_230047_INV_ST_END_DATES');
       hr_utility.raise_error;
   END IF;

   l_counter := 0;
/*
   --
   -- Check to see that atleast one scheme created using the pension
   -- type exists between the date from and date to
   --
   FOR temp_rec IN cur_get_schm_st_end(p_org_information3)
      LOOP

      -- Loop through all the rows of the element extra info and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_schm_st  := temp_rec.start_date;
         l_max_schm_end := temp_rec.end_date;
      ELSE
         IF temp_rec.start_date <  l_min_schm_st THEN
            l_min_schm_st := temp_rec.start_date;
         END IF;

         IF temp_rec.end_date > l_max_schm_end THEN
            l_max_schm_end := temp_rec.end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and
   -- greatest end date,of all element EIT rows of the PT, raise an error
   IF fnd_date.canonical_to_date(p_org_information1)
      <  l_min_schm_st
      OR fnd_date.canonical_to_date(nvl(p_org_information2,'4712/12/31'))
      > l_max_schm_end THEN
       hr_utility.set_message(8303,'PQP_230070_INV_SCHM_DATES');
       hr_utility.raise_error;
   END IF;
*/
   l_counter := 0;

   FOR temp_rec IN cur_abp_pt
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

    IF (trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) >=
        trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
        trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) <=
        trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
           hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
           hr_utility.raise_error;
    ELSIF (trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
           trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
           trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
           trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
              hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
              hr_utility.raise_error;
    END IF;

    -- Store the Min Start Date and Max End Date
    IF l_counter = 0 THEN
       l_min_start_date := trunc(to_date(substr(temp_rec.org_information1
                                         ,1,10),'YYYY/MM/DD'));
       l_max_end_date   := trunc(to_date(substr(temp_rec.org_information2
                                         ,1,10),'YYYY/MM/DD'));
    ELSE
       IF trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD'))
                < l_min_start_date THEN
          l_min_start_date := trunc(to_date(substr(temp_rec.org_information1
                                            ,1,10),'YYYY/MM/DD'));
       END IF;

       IF trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))
                > l_max_end_date THEN
          l_max_end_date := trunc(to_date(substr(temp_rec.org_information2
                                         ,1,10),'YYYY/MM/DD'));
       END IF;
    END IF;

         l_counter := l_counter + 1;

      END LOOP;

      -- Check to see if the records are in continuous order
      -- and there are no gaps (no longer need to chk since gaps are allowed now)
      /*IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
         > l_max_end_date + 1 THEN
         hr_utility.set_message(8303, 'PQP_230042_GAP_EXIST_IN_PT_ROW');
         hr_utility.raise_error;
      ELSIF trunc(to_date(substr(p_org_information2,1,10),'YYYY/MM/DD'))
         < l_min_start_date - 1 THEN
         hr_utility.set_message(8303, 'PQP_230042_GAP_EXIST_IN_PT_ROW');
         hr_utility.raise_error;
      END IF;*/

      --Check to see if the start and end dates encompasses all other rows
      IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
         <= l_min_start_date AND
         trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
         >= l_max_end_date  THEN
         hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
         hr_utility.raise_error;
      END IF;

      --Check to see that there is only one pension type of a particular sub
      --category and conversion rule on a particular date

      hr_utility.set_location('name'||p_org_information3,7);
      -- find the pension sub category for the current pension type row
      OPEN cur_get_pen_sub_cat(p_org_information3);
      FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat1
                                    ,l_thresh_conv_rule1
                                    ,l_contrib_conv_rule1
                                    ,l_basis_method1;
      CLOSE cur_get_pen_sub_cat;
      hr_utility.set_location('Current sub category'||l_pen_sub_cat1,10);
      -- now loop through the rows of all overlapping pension type rows
      --if a row with the same sub category exists , raise an error
      FOR temp_rec1 in cur_get_overlap_rows
      LOOP
         OPEN cur_get_pen_sub_cat(temp_rec1.org_information3);
         FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat2
                                       ,l_thresh_conv_rule2
                                       ,l_contrib_conv_rule2
                                       ,l_basis_method2;
         CLOSE cur_get_pen_sub_cat;
         hr_utility.set_location('pension subcategory'||l_pen_sub_cat2,20);
         IF l_pen_sub_cat1 = l_pen_sub_cat2
            AND l_thresh_conv_rule1  = l_thresh_conv_rule2
            AND l_contrib_conv_rule1 = l_contrib_conv_rule2
            AND l_basis_method1      = l_basis_method2 THEN

            hr_utility.set_message(8303,'PQP_230046_SAME_SUB_CAT_ERR');
            hr_utility.raise_error;

         END IF;

      END LOOP;
      /*--validate that the end date should be greater than or equal to the eff date
      IF l_eff_date > fnd_date.canonical_to_date(nvl(p_org_information2,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
         hr_utility.set_message(8303,'PQP_230099_DT_TO_BEF_END_DT');
         hr_utility.raise_error;
      END IF; */
      --hr_utility.trace_off;
      --call the procedure to fire insert of the change events in the
      --ben_ext_chg_evt_log table
      pqp_nl_ext_functions.create_org_pt_ins_chg_evt
                           (p_organization_id         => p_organization_id
                           ,p_org_information1        => p_org_information1
                           ,p_org_information2        => p_org_information2
                           ,p_org_information3        => p_org_information3
                           ,p_org_information6        => p_org_information6
                           ,p_effective_date          => l_eff_date
                           );

ELSIF p_org_information_context = 'PQP_NL_PGGM_PT' THEN

      --first find the eff date the user had datetracked to
      OPEN c_get_eff_date;
      FETCH c_get_eff_date INTO l_eff_date;
      CLOSE c_get_eff_date;

      --
      -- Check if the End Date is Less than or equal
      -- to the Start Date
      --
      IF trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   --
   -- Check to see that the start and end dates entered are between the
   -- min start date and max end date of the pension type
   --
   FOR temp_rec IN cur_get_st_end_dates(p_org_information3)
      LOOP

      -- Loop through all the date tracked rows of the pension type and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_st_dt  := temp_rec.effective_start_date;
         l_max_end_dt := temp_rec.effective_end_date;
      ELSE
         IF temp_rec.effective_start_date <  l_min_st_dt THEN
            l_min_st_dt := temp_rec.effective_start_date;
         END IF;

         IF temp_rec.effective_end_date > l_max_end_dt THEN
            l_max_end_dt := temp_rec.effective_end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and
   -- greatest end date,of all date tracked rows of the PT, raise an error
   IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
      <  l_min_st_dt
      OR trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      > l_max_end_dt THEN
       hr_utility.set_message(8303,'PQP_230047_INV_ST_END_DATES');
       hr_utility.raise_error;
   END IF;

   l_counter := 0;

   FOR temp_rec IN cur_pggm_pt
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

    IF (trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) >=
        trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
        trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) <=
        trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
           hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
           hr_utility.raise_error;
    ELSIF (trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
           trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
           trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
           trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
              hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
              hr_utility.raise_error;
    END IF;

    -- Store the Min Start Date and Max End Date
    IF l_counter = 0 THEN
       l_min_start_date := trunc(to_date(substr(temp_rec.org_information1
                                         ,1,10),'YYYY/MM/DD'));
       l_max_end_date   := trunc(to_date(substr(temp_rec.org_information2
                                         ,1,10),'YYYY/MM/DD'));
    ELSE
       IF trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD'))
                < l_min_start_date THEN
          l_min_start_date := trunc(to_date(substr(temp_rec.org_information1
                                            ,1,10),'YYYY/MM/DD'));
       END IF;

       IF trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))
                > l_max_end_date THEN
          l_max_end_date := trunc(to_date(substr(temp_rec.org_information2
                                         ,1,10),'YYYY/MM/DD'));
       END IF;
    END IF;

         l_counter := l_counter + 1;

      END LOOP;

      --Check to see if the start and end dates encompasses all other rows
      IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
         <= l_min_start_date AND
         trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
         >= l_max_end_date  THEN
         hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
         hr_utility.raise_error;
      END IF;

      --validate that if the total contribution percentage has been entered
      -- then it should be atleast equal to the employee contribution percentage
      IF p_org_information5 IS NOT NULL THEN
         IF fnd_number.canonical_to_number(nvl(p_org_information5,'0'))
           < fnd_number.canonical_to_number(nvl(p_org_information4,'0')) THEN
            hr_utility.set_message(8303,'PQP_230215_PGGM_INV_CONTRIB');
            hr_utility.raise_error;
         END IF;
      END IF;

ELSIF p_org_information_context = 'PQP_NL_PGGM_INFO' THEN

      --first find the eff date the user had datetracked to
      OPEN c_get_eff_date;
      FETCH c_get_eff_date INTO l_eff_date;
      CLOSE c_get_eff_date;

      --
      -- Check if the End Date is Less than or equal
      -- to the Start Date
      --
      IF trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   l_counter := 0;

   FOR temp_rec IN cur_pggm_info
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

    IF (trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) >=
        trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
        trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) <=
        trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
           hr_utility.set_message(8303, 'PQP_230219_OVERLAP_ROWS');
           hr_utility.raise_error;
    ELSIF (trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
           trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
           trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
           trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
              hr_utility.set_message(8303, 'PQP_230219_OVERLAP_ROWS');
              hr_utility.raise_error;
    END IF;

    -- Store the Min Start Date and Max End Date
    IF l_counter = 0 THEN
       l_min_start_date := trunc(to_date(substr(temp_rec.org_information1
                                         ,1,10),'YYYY/MM/DD'));
       l_max_end_date   := trunc(to_date(substr(temp_rec.org_information2
                                         ,1,10),'YYYY/MM/DD'));
    ELSE
       IF trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD'))
                < l_min_start_date THEN
          l_min_start_date := trunc(to_date(substr(temp_rec.org_information1
                                            ,1,10),'YYYY/MM/DD'));
       END IF;

       IF trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))
                > l_max_end_date THEN
          l_max_end_date := trunc(to_date(substr(temp_rec.org_information2
                                         ,1,10),'YYYY/MM/DD'));
       END IF;
    END IF;

         l_counter := l_counter + 1;

      END LOOP;

      --Check to see if the start and end dates encompasses all other rows
      IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
         <= l_min_start_date AND
         trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
         >= l_max_end_date  THEN
         hr_utility.set_message(8303,'PQP_230219_OVERLAP_ROWS');
         hr_utility.raise_error;
      END IF;

--if the EIT context is Dutch ABP Provider
ELSIF p_org_information_context = 'PQP_ABP_PROVIDER' THEN
   --call the procedure to handle the validations for this EIT context
   chk_dup_pp_row_ins(p_org_information_id       =>  p_org_information_id
                     ,p_org_information_context  =>  p_org_information_context
                     ,p_organization_id          =>  p_organization_id
                     ,p_org_information1         =>  p_org_information1
                     ,p_org_information2         =>  p_org_information2
                     ,p_org_information3         =>  p_org_information3
                     );
END IF;

END chk_dup_pt_row_ins;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dup_pt_row_upd >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_pt_row_upd (  p_org_information_id      number
                               ,p_org_information_context varchar2
                               ,p_organization_id         number
                               ,p_org_information1        varchar2
                               ,p_org_information2        varchar2
                               ,p_org_information3        varchar2
                               ,p_org_information4        varchar2 default null
                               ,p_org_information5        varchar2 default null
                               ,p_org_information6        varchar2 default null
                               ,p_org_information1_o      varchar2
                               ,p_org_information2_o      varchar2
                               ,p_org_information3_o      varchar2
                               ,p_org_information4_o      varchar2 default null
                               ,p_org_information5_o      varchar2 default null
                               ,p_org_information6_o      varchar2 default null
                             ) IS
CURSOR cur_abp_pt IS
SELECT org_information1
      ,nvl(org_information2,'4712/12/31') org_information2
  FROM hr_organization_information
 WHERE org_information3 = p_org_information3
   AND organization_id  = p_organization_id
   AND org_information_id <> p_org_information_id
   AND org_information_context = 'PQP_NL_ABP_PT';

CURSOR cur_pggm_pt IS
SELECT org_information1
      ,nvl(org_information2,'4712/12/31') org_information2
  FROM hr_organization_information
 WHERE org_information3 = p_org_information3
   AND organization_id  = p_organization_id
   AND org_information_id <> p_org_information_id
   AND org_information_context = 'PQP_NL_PGGM_PT';

CURSOR cur_pggm_info IS
SELECT org_information1
      ,nvl(org_information2,'4712/12/31') org_information2
  FROM hr_organization_information
 WHERE organization_id  = p_organization_id
   AND org_information_id <> p_org_information_id
   AND org_information_context = 'PQP_NL_PGGM_INFO';

--Cursor to find the start and end dates for a particular pension type
CURSOR cur_get_st_end_dates(c_pension_type_id   in varchar2) IS
SELECT effective_start_date,effective_end_date
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--Cursor to find the pension sub category for the ABP Pension Type
CURSOR cur_get_pen_sub_cat(c_pension_type_id   in varchar2) IS
SELECT pension_sub_category
      ,threshold_conversion_rule
      ,contribution_conversion_rule
      ,pension_basis_calc_method
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--Cursor to find all rows which have dates overlapping the current record dates
CURSOR cur_get_overlap_rows IS
SELECT org_information3
  FROM hr_organization_information
WHERE organization_id = p_organization_id
  AND org_information_id <> p_org_information_id
  AND org_information_context = 'PQP_NL_ABP_PT'
  AND ((trunc(to_date(substr(org_information1,1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
        AND trunc(to_date(substr(org_information1,1,10),'YYYY/MM/DD'))
            <= trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(nvl(org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
       AND trunc(to_date(substr(nvl(org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
           <= trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(org_information1,1,10),'YYYY/MM/DD'))
      <= trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
      AND trunc(to_date(substr(nvl(org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
          >= trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      );

--Cursor to find the start and end dates of schemes created using the given PT
CURSOR cur_get_schm_st_end(c_pension_type_id IN varchar2) IS
SELECT to_date(substr(eei_information10,1,10),'DD/MM/YYYY') start_date,
       to_date(substr(eei_information11,1,10),'DD/MM/YYYY') end_date
  FROM pay_element_type_extra_info
WHERE  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND  eei_information2 = c_pension_type_id;

--Cursor to derive the assignment Ids for all assignments with
--payroll actions between the old start and end dates , and which have
-- a run result for this current old pension type
CURSOR c_run_results_exist IS
SELECT paa.assignment_id,ppa.date_earned
  FROM pay_assignment_actions paa,pay_payroll_actions ppa
WHERE  paa.payroll_action_id = ppa.payroll_action_id
  AND  ppa.date_earned between
       fnd_date.canonical_to_date(p_org_information1_o)
  AND  fnd_date.canonical_to_date(nvl(p_org_information2_o,fnd_date.date_to_canonical(hr_api.g_eot)))
  AND  paa.assignment_action_id IN
         (SELECT assignment_action_id
            FROM pay_run_results
          WHERE  element_type_id IN
                 (SELECT element_type_id
                    FROM pay_element_type_extra_info
                  WHERE  information_type = 'PQP_NL_ABP_DEDUCTION'
                    AND  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
                    AND  eei_information2         =  p_org_information3_o
                 )
         );

CURSOR c_get_eff_date IS
SELECT effective_date
  FROM fnd_sessions
WHERE  session_id IN
                  (SELECT userenv('sessionid')
                     FROM dual
                  );

l_eff_date            DATE;
l_min_start_date      DATE   := NULL;
l_max_end_date        DATE   := NULL;
l_counter             NUMBER := 0;
l_pen_sub_cat1        pqp_pension_types_f.pension_sub_category%TYPE;
l_pen_sub_cat2        pqp_pension_types_f.pension_sub_category%TYPE;
l_thresh_conv_rule1   pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_thresh_conv_rule2   pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_basis_method1       pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_basis_method2       pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_contrib_conv_rule1  pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_contrib_conv_rule2  pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_min_st_dt       DATE;
l_max_end_dt      DATE;
l_min_schm_st     DATE;
l_max_schm_end    DATE;
l_allow_update    NUMBER := 1;
i                 NUMBER := 1;
l_asg_or_org      NUMBER;
l_org_id          NUMBER;
l_date_earned     DATE;

BEGIN

OPEN c_get_eff_date;
FETCH c_get_eff_date INTO l_eff_date;
CLOSE c_get_eff_date;

IF p_org_information_context = 'PQP_NL_ABP_PT' THEN
     hr_utility.set_location('in update',10);
      --check to see if the pension type has been changed. If so, throw an error
      IF p_org_information3 <> p_org_information3_o THEN
         hr_utility.set_message(8303,'PQP_230100_PT_UPD_NOT_ALLOWED');
         hr_utility.raise_error;
      END IF;
      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   -- check to see that the start and end dates entered are between the
   -- min start date and max end date of the pension type
   FOR temp_rec IN cur_get_st_end_dates(p_org_information3)
      LOOP

      -- loop through all the date tracked rows of the pension type and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_st_dt  := temp_rec.effective_start_date;
         l_max_end_dt := temp_rec.effective_end_date;
      ELSE
         IF temp_rec.effective_start_date <  l_min_st_dt THEN
            l_min_st_dt := temp_rec.effective_start_date;
         END IF;

         IF temp_rec.effective_end_date > l_max_end_dt THEN
            l_max_end_dt := temp_rec.effective_end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and greatest
   -- end date,of all date tracked rows of the PT, raise an error
   IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
      <  l_min_st_dt
      OR trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      > l_max_end_dt THEN
       hr_utility.set_message(8303,'PQP_230047_INV_ST_END_DATES');
       hr_utility.raise_error;
   END IF;

   l_counter := 0;
/*
   --
   -- Check to see that atleast one scheme created using the pension
   -- type exists between the date from and date to
   --
   FOR temp_rec IN cur_get_schm_st_end(p_org_information3)
      LOOP

      -- Loop through all the rows of the element extra info and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_schm_st  := temp_rec.start_date;
         l_max_schm_end := temp_rec.end_date;
      ELSE
         IF temp_rec.start_date <  l_min_schm_st THEN
            l_min_schm_st := temp_rec.start_date;
         END IF;

         IF temp_rec.end_date > l_max_schm_end THEN
            l_max_schm_end := temp_rec.end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and
   -- greatest end date,of all element EIT rows of the PT, raise an error
   IF fnd_date.canonical_to_date(p_org_information1)
      <  l_min_schm_st
      OR fnd_date.canonical_to_date(nvl(p_org_information2,'4712/12/31'))
      > l_max_schm_end THEN
       hr_utility.set_message(8303,'PQP_230070_INV_SCHM_DATES');
       hr_utility.raise_error;
   END IF;
*/
   l_counter := 0;

   FOR temp_rec IN cur_abp_pt
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

   IF (trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) >=
       trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
       trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) <=
       trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
          hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
          hr_utility.raise_error;
   ELSIF (trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
          trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
          trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
          trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
             hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
             hr_utility.raise_error;
   END IF;

 END LOOP;

  FOR temp_rec1 IN cur_abp_pt
     LOOP
   --  hr_utility.set_location('start date'||temp_rec1.org_information1,10);
   --  hr_utility.set_location('end date'||temp_rec1.org_information2,20);
   -- Store the Min Start Date and Max End Date
      IF l_counter = 0 THEN
         l_min_start_date := trunc(to_date(substr(temp_rec1.org_information1
                             ,1,10),'YYYY/MM/DD'));
         l_max_end_date   := trunc(to_date(substr(temp_rec1.org_information2
                             ,1,10),'YYYY/MM/DD'));
      ELSE
         IF trunc(to_date(substr(temp_rec1.org_information1,1,10),'YYYY/MM/DD'))
                  < l_min_start_date THEN
            l_min_start_date :=
                   trunc(to_date(substr(temp_rec1.org_information1
                                 ,1,10),'YYYY/MM/DD'));
         END IF;
          IF trunc(to_date(substr(temp_rec1.org_information2,1,10),'YYYY/MM/DD'))
               > l_max_end_date THEN
            l_max_end_date := trunc(to_date(substr(temp_rec1.org_information2
                                           ,1,10),'YYYY/MM/DD'));
               END IF;
            END IF;
            l_counter := l_counter + 1;
         END LOOP;
      --hr_utility.trace_off;

      -- Check to see if the records are in continuous order
      -- and there are no gaps (no longer need to chk since gaps are allowed)
      /*IF trunc(to_date(substr(p_org_information1_o,1,10),'YYYY/MM/DD'))
         > l_min_start_date THEN

         IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
            > trunc(to_date(substr(p_org_information1_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230042_GAP_EXIST_IN_PT_ROW');
            hr_utility.raise_error;

         ELSIF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
            < trunc(to_date(substr(p_org_information1_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
            hr_utility.raise_error;

         END IF;

      ELSIF trunc(to_date(substr(p_org_information2_o,1,10),'YYYY/MM/DD'))
            < l_max_end_date THEN

         IF trunc(to_date(substr(p_org_information2,1,10),'YYYY/MM/DD'))
            < trunc(to_date(substr(p_org_information2_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230042_GAP_EXIST_IN_PT_ROW');
            hr_utility.raise_error;

         ELSIF trunc(to_date(substr(p_org_information2,1,10),'YYYY/MM/DD'))
            > trunc(to_date(substr(p_org_information2_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;*/

      --Check to see if the start and end dates encompasses all other rows
      IF l_min_start_date IS NOT NULL AND l_max_end_date IS NOT NULL THEN

         IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
            <= l_min_start_date AND
            trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
            >= l_max_end_date  THEN

            hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;

      --Check to see that there is only one pension type of a particular sub
      --category on a particular date

      hr_utility.set_location('name'||p_org_information3,7);
      -- find the pension sub category for the current pension type row
      OPEN cur_get_pen_sub_cat(p_org_information3);
      FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat1
                                    ,l_thresh_conv_rule1
                                    ,l_contrib_conv_rule1
                                    ,l_basis_method1;
      CLOSE cur_get_pen_sub_cat;
      hr_utility.set_location('Current sub category'||l_pen_sub_cat1,10);
      -- now loop through the rows of all overlapping pension type rows
      --if a row with the same sub category exists , raise an error
      FOR temp_rec1 in cur_get_overlap_rows
      LOOP
         OPEN cur_get_pen_sub_cat(temp_rec1.org_information3);
         FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat2
                                       ,l_thresh_conv_rule2
                                       ,l_contrib_conv_rule2
                                       ,l_basis_method2;
         CLOSE cur_get_pen_sub_cat;
         hr_utility.set_location('pension subcategory'||l_pen_sub_cat2,20);
         IF l_pen_sub_cat1 = l_pen_sub_cat2
            AND l_thresh_conv_rule1  =  l_thresh_conv_rule2
            AND l_contrib_conv_rule1 =  l_contrib_conv_rule2
            AND l_basis_method1      =  l_basis_method2 THEN

            hr_utility.set_message(8303,'PQP_230046_SAME_SUB_CAT_ERR');
            hr_utility.raise_error;

         END IF;
      --hr_utility.trace_off;
      END LOOP;
     hr_utility.set_location('now chking for run results',40);
      --check to see if any payroll has been run where enrollment comes from
      --this EIT row, if so do not allow an update of this row.
      -- also store the last date when payroll has been run so that the end date
      -- can be updated to a date after that.
      FOR csr_row IN c_run_results_exist
      LOOP
        hr_utility.set_location('calling get part org',50);
        get_participation_org(p_assignment_id   =>  csr_row.assignment_id
                             ,p_date_earned     =>  csr_row.date_earned
                             ,p_pension_type_id =>  fnd_number.canonical_to_number(p_org_information3_o)
                             ,p_asg_or_org      =>  l_asg_or_org
                             ,p_org_id          =>  l_org_id
                             );
        IF l_asg_or_org = 1 AND l_org_id = p_organization_id THEN
           l_allow_update := 0;

           IF i = 1 THEN
              l_date_earned := csr_row.date_earned;
              i             := i + 1;
           ELSIF csr_row.date_earned > l_date_earned THEN
              l_date_earned := csr_row.date_earned;
           END IF;

        END IF;
       hr_utility.set_location('came back from partn org',60);
      END LOOP;
      hr_utility.set_location('nw chk if upd is allowd or not',70);

      --allow an update of pension type only if the update is allowed
      IF l_allow_update = 0 THEN
         IF p_org_information3 <> p_org_information3_o THEN
            hr_utility.set_message(8303,'PQP_230101_UPD_NOT_ALLOWED');
            hr_utility.raise_error;
         END IF;
      END IF;

/*         ELSIF fnd_date.canonical_to_date(nvl(p_org_information2,fnd_date.date_to_canonical(hr_api.g_eot)))
            <> fnd_date.canonical_to_date(nvl(p_org_information2_o,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
            IF l_eff_date <= l_date_earned OR fnd_date.canonical_to_date(nvl(p_org_information2,fnd_date.date_to_canonical(hr_api.g_eot)))
               <= l_date_earned THEN
               hr_utility.set_message(8303,'PQP_230102_DT_TO_AFTER_PAY_RUN');
               hr_utility.raise_error;
            ELSIF l_eff_date > fnd_date.canonical_to_date(nvl(p_org_information2,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
               hr_utility.set_message(8303,'PQP_230099_DT_TO_BEF_END_DT');
               hr_utility.raise_error;
            END IF;
         END IF;
      ELSIF l_allow_update = 1 THEN
         IF (fnd_date.canonical_to_date(nvl(p_org_information2,fnd_date.date_to_canonical(hr_api.g_eot)))
             <> fnd_date.canonical_to_date(nvl(p_org_information2_o,fnd_date.date_to_canonical(hr_api.g_eot))))
        AND (l_eff_date > fnd_date.canonical_to_date(nvl(p_org_information2,fnd_date.date_to_canonical(hr_api.g_eot)))) THEN
            hr_utility.set_message(8303,'PQP_230099_DT_TO_BEF_END_DT');
            hr_utility.raise_error;
         END IF;
      END IF;   */
     hr_utility.set_location('calling insert process',20);
      --call the procedure to fire insert of the change events in the
      --ben_ext_chg_evt_log table
      pqp_nl_ext_functions.create_org_pt_upd_chg_evt
                           (p_organization_id         => p_organization_id
                           ,p_org_information1        => p_org_information1
                           ,p_org_information2        => p_org_information2
                           ,p_org_information3        => p_org_information3
                           ,p_org_information6        => p_org_information6
                           ,p_org_information1_o      => p_org_information1_o
                           ,p_org_information2_o      => p_org_information2_o
                           ,p_org_information3_o      => p_org_information3_o
                           ,p_org_information6_o      => p_org_information6_o
                           ,p_effective_date          => l_eff_date
                           );
hr_utility.set_location('leaving',30);

--context is PGGM PT
ELSIF p_org_information_context = 'PQP_NL_PGGM_PT' THEN
     hr_utility.set_location('in update',10);
      --check to see if the pension type has been changed. If so, throw an error
      IF p_org_information3 <> p_org_information3_o THEN
         hr_utility.set_message(8303,'PQP_230100_PT_UPD_NOT_ALLOWED');
         hr_utility.raise_error;
      END IF;
      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   -- check to see that the start and end dates entered are between the
   -- min start date and max end date of the pension type
   FOR temp_rec IN cur_get_st_end_dates(p_org_information3)
      LOOP

      -- loop through all the date tracked rows of the pension type and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_st_dt  := temp_rec.effective_start_date;
         l_max_end_dt := temp_rec.effective_end_date;
      ELSE
         IF temp_rec.effective_start_date <  l_min_st_dt THEN
            l_min_st_dt := temp_rec.effective_start_date;
         END IF;

         IF temp_rec.effective_end_date > l_max_end_dt THEN
            l_max_end_dt := temp_rec.effective_end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and greatest
   -- end date,of all date tracked rows of the PT, raise an error
   IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
      <  l_min_st_dt
      OR trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      > l_max_end_dt THEN
       hr_utility.set_message(8303,'PQP_230047_INV_ST_END_DATES');
       hr_utility.raise_error;
   END IF;

   l_counter := 0;

   FOR temp_rec IN cur_pggm_pt
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

   IF (trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) >=
       trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
       trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) <=
       trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
          hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
          hr_utility.raise_error;
   ELSIF (trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
          trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
          trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
          trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
             hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
             hr_utility.raise_error;
   END IF;

 END LOOP;

  FOR temp_rec1 IN cur_pggm_pt
     LOOP
   --  hr_utility.set_location('start date'||temp_rec1.org_information1,10);
   --  hr_utility.set_location('end date'||temp_rec1.org_information2,20);
   -- Store the Min Start Date and Max End Date
      IF l_counter = 0 THEN
         l_min_start_date := trunc(to_date(substr(temp_rec1.org_information1
                             ,1,10),'YYYY/MM/DD'));
         l_max_end_date   := trunc(to_date(substr(temp_rec1.org_information2
                             ,1,10),'YYYY/MM/DD'));
      ELSE
         IF trunc(to_date(substr(temp_rec1.org_information1,1,10),'YYYY/MM/DD'))
                  < l_min_start_date THEN
            l_min_start_date :=
                   trunc(to_date(substr(temp_rec1.org_information1
                                 ,1,10),'YYYY/MM/DD'));
         END IF;
          IF trunc(to_date(substr(temp_rec1.org_information2,1,10),'YYYY/MM/DD'))
               > l_max_end_date THEN
            l_max_end_date := trunc(to_date(substr(temp_rec1.org_information2
                                           ,1,10),'YYYY/MM/DD'));
               END IF;
            END IF;
            l_counter := l_counter + 1;
         END LOOP;

      --Check to see if the start and end dates encompasses all other rows
      IF l_min_start_date IS NOT NULL AND l_max_end_date IS NOT NULL THEN

         IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
            <= l_min_start_date AND
            trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
            >= l_max_end_date  THEN

            hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;

      --validate that if the total contribution percentage has been entered
      -- then it should be atleast equal to the employee contribution percentage
      IF p_org_information5 IS NOT NULL THEN
         IF fnd_number.canonical_to_number(nvl(p_org_information5,'0'))
           < fnd_number.canonical_to_number(nvl(p_org_information4,'0')) THEN
            hr_utility.set_message(8303,'PQP_230215_PGGM_INV_CONTRIB');
            hr_utility.raise_error;
         END IF;
      END IF;

hr_utility.set_location('leaving',30);

--context is PGGM INFO
ELSIF p_org_information_context = 'PQP_NL_PGGM_INFO' THEN
     hr_utility.set_location('in update',10);
      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   l_counter := 0;

   FOR temp_rec IN cur_pggm_info
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

   IF (trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) >=
       trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
       trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD')) <=
       trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
          hr_utility.set_message(8303, 'PQP_230219_OVERLAP_ROWS');
          hr_utility.raise_error;
   ELSIF (trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
          trunc(to_date(substr(temp_rec.org_information1,1,10),'YYYY/MM/DD')) AND
          trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
          trunc(to_date(substr(temp_rec.org_information2,1,10),'YYYY/MM/DD'))) THEN
             hr_utility.set_message(8303, 'PQP_230219_OVERLAP_ROWS');
             hr_utility.raise_error;
   END IF;

 END LOOP;

  FOR temp_rec1 IN cur_pggm_info
     LOOP
   --  hr_utility.set_location('start date'||temp_rec1.org_information1,10);
   --  hr_utility.set_location('end date'||temp_rec1.org_information2,20);
   -- Store the Min Start Date and Max End Date
      IF l_counter = 0 THEN
         l_min_start_date := trunc(to_date(substr(temp_rec1.org_information1
                             ,1,10),'YYYY/MM/DD'));
         l_max_end_date   := trunc(to_date(substr(temp_rec1.org_information2
                             ,1,10),'YYYY/MM/DD'));
      ELSE
         IF trunc(to_date(substr(temp_rec1.org_information1,1,10),'YYYY/MM/DD'))
                  < l_min_start_date THEN
            l_min_start_date :=
                   trunc(to_date(substr(temp_rec1.org_information1
                                 ,1,10),'YYYY/MM/DD'));
         END IF;
          IF trunc(to_date(substr(temp_rec1.org_information2,1,10),'YYYY/MM/DD'))
               > l_max_end_date THEN
            l_max_end_date := trunc(to_date(substr(temp_rec1.org_information2
                                           ,1,10),'YYYY/MM/DD'));
               END IF;
            END IF;
            l_counter := l_counter + 1;
         END LOOP;

      --Check to see if the start and end dates encompasses all other rows
      IF l_min_start_date IS NOT NULL AND l_max_end_date IS NOT NULL THEN

         IF trunc(to_date(substr(p_org_information1,1,10),'YYYY/MM/DD'))
            <= l_min_start_date AND
            trunc(to_date(substr(nvl(p_org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
            >= l_max_end_date  THEN

            hr_utility.set_message(8303,'PQP_230219_OVERLAP_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;

hr_utility.set_location('leaving',30);

--if the EIT context is PQP_ABP_PROVIDER then
ELSIF p_org_information_context = 'PQP_ABP_PROVIDER' THEN
   --call the procedure to handle validations for After Update
   chk_dup_pp_row_upd(p_org_information_id       =>  p_org_information_id
                     ,p_org_information_context  =>  p_org_information_context
                     ,p_organization_id          =>  p_organization_id
                     ,p_org_information1         =>  p_org_information1
                     ,p_org_information2         =>  p_org_information2
                     ,p_org_information3         =>  p_org_information3
                     ,p_org_information1_o       =>  p_org_information1_o
                     ,p_org_information2_o       =>  p_org_information2_o
                     ,p_org_information3_o       =>  p_org_information3_o
                     );
END IF;

END chk_dup_pt_row_upd;

--------------------------------------------------------------------------------

PROCEDURE chk_dup_pt_row (  p_org_information_id      number
                               ,p_org_information_context varchar2
                               ,p_organization_id         number
                               ,p_org_information1        varchar2
                               ,p_org_information2        varchar2
                               ,p_org_information3        varchar2
                             ) IS
begin
   null;
end;
--

PROCEDURE gen_dynamic_formula ( p_si_tax_balances  IN  NUMBER
                               ,p_formula_string   OUT NOCOPY varchar2
                             ) IS
begin
   null;
end;

--
-- ----------------------------------------------------------------------------
-- |------------------< chk_dup_asg_info_row_ins >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_asg_info_row_ins (p_assignment_extra_info_id IN number
                                   ,p_assignment_id            IN number
                                   ,p_information_type         IN varchar2
                                   ,p_aei_information1         IN varchar2
                                   ,p_aei_information2         IN varchar2
                                   ,p_aei_information3         IN varchar2
                                   ,p_aei_information4         IN varchar2
                                   ,p_aei_information5         IN varchar2
                                   ,p_aei_information6         IN varchar2
                                   ,p_aei_information7         IN varchar2
                                   ,p_aei_information8         IN varchar2
                                   ,p_aei_information9         IN varchar2
                                   ,p_aei_information10        IN varchar2
                                   ,p_aei_information11        IN varchar2
                                   ,p_aei_information12        IN varchar2
                                   ,p_aei_information13        IN varchar2
                                   ,p_aei_information14        IN varchar2
                                   ,p_aei_information15        IN varchar2
                                   ,p_aei_information16        IN varchar2
                                   ,p_aei_information20        IN varchar2
                                   ,p_aei_information21        IN varchar2
                                   ,p_aei_information22        IN varchar2
                                   ) IS
CURSOR cur_abp_asg_info IS
SELECT aei_information1
      ,nvl(aei_information2,'4712/12/31') aei_information2
  FROM per_assignment_extra_info
 WHERE aei_information3 = p_aei_information3
   AND assignment_id  = p_assignment_id
   AND assignment_extra_info_id <> p_assignment_extra_info_id
   AND aei_information_category = 'NL_ABP_PI'
   AND information_type = 'NL_ABP_PI';

CURSOR cur_abp_asg_info1 IS
SELECT aei_information1
      ,nvl(aei_information2,'4712/12/31') aei_information2
  FROM per_assignment_extra_info
WHERE  assignment_id  = p_assignment_id
   AND assignment_extra_info_id <> p_assignment_extra_info_id
   AND aei_information_category = 'NL_ABP_PAR_INFO'
   AND information_type = 'NL_ABP_PAR_INFO';

--cursor to find all other rows with the same period number
--and the same savings type
CURSOR cur_sav_asg_info IS
SELECT 1
  FROM per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  assignment_extra_info_id <> p_assignment_extra_info_id
  AND  aei_information_category = 'NL_SAV_INFO'
  AND  information_type = 'NL_SAV_INFO'
  AND  aei_information1 = p_aei_information1
  AND  aei_information2 = p_aei_information2;

--cursor to fetch the number of periods per year
CURSOR cur_periods_per_yr(c_eff_date IN DATE) IS
SELECT decode(hrl.lookup_code,'W',53,number_per_fiscal_year)
  FROM per_time_period_types,hr_lookups hrl
WHERE  period_type =
       (SELECT period_type
          FROM pay_payrolls_f
        WHERE  payroll_id =
               (SELECT payroll_id
                  FROM per_all_assignments_f
                WHERE  assignment_id = p_assignment_id
                  AND  c_eff_date BETWEEN effective_start_date
                  AND  nvl(effective_end_date,hr_api.g_eot)
               )
          AND  c_eff_date BETWEEN effective_start_date
          AND  nvl(effective_end_date,hr_api.g_eot)
       )
   AND hrl.lookup_type = 'PROC_PERIOD_TYPE'
   AND hrl.meaning     = period_type;

--Cursor to find the start and end dates for a particular pension type
CURSOR cur_get_st_end_dates(c_pension_type_id   in varchar2) IS
SELECT effective_start_date,effective_end_date
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--cursor to find all the EIT rows which have a salary override
--and fall in the current year
CURSOR cur_get_sal_rows(c_year IN varchar2) IS
SELECT aei_information1,aei_information2
 FROM  per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  assignment_extra_info_id <> p_assignment_extra_info_id
  AND  aei_information_category = 'NL_ABP_PAR_INFO'
  AND  information_type = 'NL_ABP_PAR_INFO'
  AND  to_char(trunc(fnd_date.canonical_to_date(aei_information1)),'YYYY')
       = c_year
  AND  to_char(trunc(fnd_date.canonical_to_date(nvl(aei_information2,
       fnd_date.date_to_canonical(hr_api.g_eot)))),'YYYY')
       = c_year
  AND  aei_information6 IS NOT NULL;

--Cursor to find the pension sub category for the ABP Pension Type
CURSOR cur_get_pen_sub_cat(c_pension_type_id   in varchar2) IS
SELECT pension_sub_category
      ,threshold_conversion_rule
      ,contribution_conversion_rule
      ,pension_basis_calc_method
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--Cursor to find all rows which have dates overlapping the current record dates
CURSOR cur_get_overlap_rows IS
SELECT aei_information3
  FROM per_assignment_extra_info
WHERE assignment_id = p_assignment_id
  AND assignment_extra_info_id <> p_assignment_extra_info_id
  AND aei_information_category = 'NL_ABP_PI'
  AND information_type         = 'NL_ABP_PI'
  AND ((trunc(to_date(substr(aei_information1,1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
        AND trunc(to_date(substr(aei_information1,1,10),'YYYY/MM/DD'))
            <= trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(nvl(aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
       AND trunc(to_date(substr(nvl(aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
           <= trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(aei_information1,1,10),'YYYY/MM/DD'))
      <= trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
      AND trunc(to_date(substr(nvl(aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
          >= trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      );

--Cursor to fetch the hire date of the employee
CURSOR c_get_hire_date(c_eff_date in date) IS
SELECT max(date_start)
  FROM per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = p_assignment_id
   AND pps.business_group_id = asg.business_group_id
   AND date_start <= c_eff_date;

--Cursor to find the start and end dates of schemes created using the given PT
CURSOR cur_get_schm_st_end(c_pension_type_id IN varchar2) IS
SELECT to_date(substr(eei_information10,1,10),'DD/MM/YYYY') start_date,
       to_date(substr(eei_information11,1,10),'DD/MM/YYYY') end_date
  FROM pay_element_type_extra_info
WHERE  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND  eei_information2 = c_pension_type_id;

CURSOR c_get_person_id IS
Select person_id from per_all_assignments_f
where assignment_id = p_assignment_id;

CURSOR c_get_eff_date IS
SELECT effective_date
  FROM fnd_sessions
WHERE  session_id = userenv('sessionid');

CURSOR cur_ret_addl_info_calc IS
SELECT aei_information1
      ,nvl(aei_information2,'4712/12/31') aei_information2
  FROM per_assignment_extra_info
WHERE  assignment_id  = p_assignment_id
   AND assignment_extra_info_id <> p_assignment_extra_info_id
   AND aei_information_category = 'NL_ADDL_CALC'
   AND information_type = 'NL_ADDL_CALC';

l_min_start_date  DATE;
l_max_end_date    DATE;
l_counter         NUMBER := 0;
l_pen_sub_cat1        pqp_pension_types_f.pension_sub_category%TYPE;
l_pen_sub_cat2        pqp_pension_types_f.pension_sub_category%TYPE;
l_thresh_conv_rule1   pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_thresh_conv_rule2   pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_contrib_conv_rule1  pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_contrib_conv_rule2  pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_basis_method1       pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_basis_method2       pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_min_st_dt       DATE;
l_max_end_dt      DATE;
l_hire_date       DATE;
l_min_schm_st     DATE;
l_max_schm_end    DATE;
l_log_id number;
l_ovn number;
l_person_id number;
l_eff_date            DATE;
l_abp_rep_date        DATE;
l_asg_sav_info_exists NUMBER;
l_periods_per_yr      NUMBER;
l_curr_year           VARCHAR2(4);
l_start_year          VARCHAR2(4);
l_end_year            VARCHAR2(4);
l_min_sal_start       DATE := null;
l_max_sal_end         DATE := null;
l_error_status        CHAR :='0';
l_error_message       VARCHAR2(100);
l_ret_val             NUMBER;

BEGIN
hr_utility.set_location('entered chkdupasginfo'||p_information_type,5);
Open c_get_person_id;
Fetch c_get_person_id INTO l_person_id;
CLOSE c_get_person_id;
hr_utility.set_location('person id : '||l_person_id,7);

--fetch the effective date first
OPEN c_get_eff_date;
FETCH c_get_eff_date INTO l_eff_date;
CLOSE c_get_eff_date;
hr_utility.set_location('eff date : '||l_eff_date,9);

IF p_information_type = 'NL_ABP_PI' THEN

      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   -- check to see that the start and end dates entered are between the
   -- min start date and max end date of the pension type
   FOR temp_rec IN cur_get_st_end_dates(p_aei_information3)
      LOOP

      -- loop through all the date tracked rows of the pension type and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_st_dt  := temp_rec.effective_start_date;
         l_max_end_dt := temp_rec.effective_end_date;
      ELSE
         IF temp_rec.effective_start_date <  l_min_st_dt THEN
            l_min_st_dt := temp_rec.effective_start_date;
         END IF;

         IF temp_rec.effective_end_date > l_max_end_dt THEN
            l_max_end_dt := temp_rec.effective_end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and greatest end date,
   -- of all date tracked rows of the PT, raise an error
   IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
      <  l_min_st_dt
      OR trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      > l_max_end_dt THEN
       hr_utility.set_message(8303,'PQP_230047_INV_ST_END_DATES');
       hr_utility.raise_error;
   END IF;

   l_counter := 0;
/*
   --
   -- Check to see that atleast one scheme created using the pension
   -- type exists between the date from and date to
   --
   FOR temp_rec IN cur_get_schm_st_end(p_aei_information3)
      LOOP

      -- Loop through all the rows of the element extra info and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_schm_st  := temp_rec.start_date;
         l_max_schm_end := temp_rec.end_date;
      ELSE
         IF temp_rec.start_date <  l_min_schm_st THEN
            l_min_schm_st := temp_rec.start_date;
         END IF;

         IF temp_rec.end_date > l_max_schm_end THEN
            l_max_schm_end := temp_rec.end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and
   -- greatest end date,of all element EIT rows of the PT, raise an error
   IF fnd_date.canonical_to_date(p_aei_information1)
      <  l_min_schm_st
      OR fnd_date.canonical_to_date(nvl(p_aei_information2,'4712/12/31'))
      > l_max_schm_end THEN
       hr_utility.set_message(8303,'PQP_230070_INV_SCHM_DATES');
       hr_utility.raise_error;
   END IF;
*/
   l_counter := 0;

   FOR temp_rec IN cur_abp_asg_info
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

         IF (trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) >=
             trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
             trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) <=
             trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
                hr_utility.raise_error;
         ELSIF (trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
                trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
                trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
                trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                   hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
                   hr_utility.raise_error;
         END IF;

         -- Store the Min Start Date and Max End Date
         IF l_counter = 0 THEN
            l_min_start_date := trunc(to_date(substr(temp_rec.aei_information1
                                              ,1,10),'YYYY/MM/DD'));
            l_max_end_date   := trunc(to_date(substr(temp_rec.aei_information2
                                              ,1,10),'YYYY/MM/DD'));
         ELSE
            IF trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD'))
                     < l_min_start_date THEN
               l_min_start_date := trunc(to_date(substr(temp_rec.aei_information1
                                                 ,1,10),'YYYY/MM/DD'));
            END IF;

            IF trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))
                     > l_max_end_date THEN
               l_max_end_date := trunc(to_date(substr(temp_rec.aei_information2
                                              ,1,10),'YYYY/MM/DD'));
            END IF;
         END IF;

         l_counter := l_counter + 1;

      END LOOP;

      -- Check to see if the records are in continuous order
      -- and there are no gaps (no longer need to chk since gaps are allowed)
      /*IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
         > l_max_end_date + 1 THEN
         hr_utility.set_message(8303, 'PQP_230042_GAP_EXIST_IN_PT_ROW');
         hr_utility.raise_error;
      ELSIF trunc(to_date(substr(p_aei_information2,1,10),'YYYY/MM/DD'))
         < l_min_start_date - 1 THEN
         hr_utility.set_message(8303, 'PQP_230042_GAP_EXIST_IN_PT_ROW');
         hr_utility.raise_error;
      END IF;*/

      --Check to see if the start and end dates encompasses all other rows
      IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
         <= l_min_start_date AND
         trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
         >= l_max_end_date  THEN
         hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
         hr_utility.raise_error;
      END IF;

      --Check to see that there is only one pension type of a particular sub
      --category and conversion rule on a particular date

      hr_utility.set_location('name'||p_aei_information3,7);
      -- find the pension sub category for the current pension type row
      OPEN cur_get_pen_sub_cat(p_aei_information3);
      FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat1
                                    ,l_thresh_conv_rule1
                                    ,l_contrib_conv_rule1
                                    ,l_basis_method1;
      CLOSE cur_get_pen_sub_cat;
      hr_utility.set_location('Current sub category'||l_pen_sub_cat1,10);
      -- now loop through the rows of all overlapping pension type rows
      --if a row with the same sub category exists , raise an error
      FOR temp_rec1 in cur_get_overlap_rows
      LOOP
         OPEN cur_get_pen_sub_cat(temp_rec1.aei_information3);
         FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat2
                                       ,l_thresh_conv_rule2
                                       ,l_contrib_conv_rule2
                                       ,l_basis_method2;
         CLOSE cur_get_pen_sub_cat;
         hr_utility.set_location('pension subcategory'||l_pen_sub_cat2,20);
         IF l_pen_sub_cat1 = l_pen_sub_cat2
            AND l_thresh_conv_rule1  = l_thresh_conv_rule2
            AND l_contrib_conv_rule1 = l_contrib_conv_rule2
            AND l_basis_method1      = l_basis_method2 THEN

            hr_utility.set_message(8303,'PQP_230046_SAME_SUB_CAT_ERR');
            hr_utility.raise_error;

         END IF;

      END LOOP;

      -- if the contribution method is PE the value should be between 0 and 999.999
      IF nvl(p_aei_information13,'PE') = 'PE' THEN
         IF fnd_number.canonical_to_number(nvl(p_aei_information14,'0')) > 999.999 THEN
            hr_utility.set_message(8303,'PQP_230052_INV_PERCENT_VALUE');
            hr_utility.raise_error;
         END IF;
      END IF;

      -- if the contribution method is PE the value should be between 0 and 999.999
      IF nvl(p_aei_information15,'PE') = 'PE' THEN
         IF fnd_number.canonical_to_number(nvl(p_aei_information16,'0')) > 999.999 THEN
            hr_utility.set_message(8303,'PQP_230052_INV_PERCENT_VALUE');
            hr_utility.raise_error;
         END IF;
      END IF;

      --validate that the Date From is equal to or greater than the hire date
      OPEN c_get_hire_date(l_eff_date);
      FETCH c_get_hire_date INTO l_hire_date;
      CLOSE c_get_hire_date;
      IF l_hire_date > trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
         hr_utility.set_message(8303,'PQP_230055_DATE_FRM_BEF_HIRE');
         hr_utility.set_message_token(8303,'HIREDATE',to_char(l_hire_date));
         hr_utility.raise_error;
      END IF;

      --validate that if the override value is entered , the reason is also entered
      IF ((p_aei_information7 IS NOT NULL) AND (p_aei_information8 IS NULL)
          OR (p_aei_information9 IS NOT NULL) AND (p_aei_information10 IS NULL)
          OR (p_aei_information11 IS NOT NULL) AND (p_aei_information12 IS NULL)
          OR (p_aei_information20 IS NOT NULL) AND (p_aei_information21 IS NULL)
         ) THEN
            hr_utility.set_message(8303,'PQP_230056_NO_OVERRIDE_REASON');
            hr_utility.raise_error;
      END IF;

      --validate that only one among Pension Salary,Basis or Contribution is overridden
      IF NOT (((p_aei_information7 IS NOT NULL)
               AND (p_aei_information9 IS NULL)
               AND ((p_aei_information11 IS NULL) AND (p_aei_information20 IS NULL))
              )
              OR
              ((p_aei_information9 IS NOT NULL)
               AND (p_aei_information7 IS NULL)
               AND ((p_aei_information11 IS NULL) AND (p_aei_information20 IS NULL))
              )
              OR
              (((p_aei_information11 IS NOT NULL) OR (p_aei_information20 IS NOT NULL))
               AND (p_aei_information7 IS NULL)
               AND (p_aei_information9 IS NULL)
              )
              OR
              ((p_aei_information7 IS NULL)
               AND (p_aei_information9 IS NULL)
               AND ((p_aei_information11 IS NULL) AND (p_aei_information20 IS NULL))
             )) THEN
                hr_utility.set_message(8303,'PQP_230057_INVALID_OVERRIDES');
                hr_utility.raise_error;
      END IF;

      --validate that if the override is entered for contribution value, then
      -- the contribution type is also entered
      /*IF ((p_aei_information13 IS NOT NULL AND p_aei_information14 IS NULL)
          OR (p_aei_information13 IS NULL AND p_aei_information14 IS NOT NULL)
          OR (p_aei_information15 IS NOT NULL AND p_aei_information16 IS NULL)
          OR (p_aei_information15 IS NULL AND p_aei_information16 IS NOT NULL)
         ) THEN
          hr_utility.set_message(8303,'PQP_230058_INVALID_CONTRIB');
          hr_utility.raise_error;
      END IF;*/

      --this validation has now changed as follows
      --the following combinations would occur
      /*---------------------------------------------------------------
        CONTRIBUTION TYPE         CONTRIBUTION VALUE
        ---------------------------------------------------------------
        null                      null -- age dependant contribution
        null                      non-null value -- validate this case
        PE                        null -- age dependant contribution
        PE                        non-null value -- normal case
        FA                        null -- validate this case
        FA                        non-null value -- normal case
        ---------------------------------------------------------------
      */

       IF ((p_aei_information13 IS NULL AND p_aei_information14 IS NOT NULL)
        OR (p_aei_information15 IS NULL AND p_aei_information16 IS NOT NULL)
          ) THEN
          hr_utility.set_message(8303,'PQP_230140_INV_CONTRIBUTION');
          hr_utility.raise_error;
       END IF;

       IF ((nvl(p_aei_information13,'PE') = 'FA' AND p_aei_information14 IS NULL)
        OR (nvl(p_aei_information15,'PE') = 'FA' AND p_aei_information16 IS NULL)
          ) THEN
          hr_utility.set_message(8303,'PQP_230058_INVALID_CONTRIB');
          hr_utility.raise_error;
       END IF;

   --validate that if an end date is entered, then end reason should also be entered
   IF p_aei_information2 IS NOT NULL AND p_aei_information4 IS NULL THEN
      hr_utility.set_message(8303,'PQP_230103_ENTER_END_REASON');
      hr_utility.raise_error;
   END IF;

   /*--validate that the eff date is lesser or equal to the end date
   IF l_eff_date > fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
      hr_utility.set_message(8303,'PQP_230099_DT_TO_BEF_END_DT');
      hr_utility.raise_error;
   END IF; */

   --
   -- Derive the next abp reporting date
   --
   l_ret_val := get_reporting_date
   (p_effective_date   => fnd_date.canonical_to_date(to_char(TRUNC(
                          fnd_date.canonical_to_date(p_aei_information1)),'YYYY/MM')||'/01')
   ,p_assignment_id    => fnd_number.canonical_to_number(p_assignment_id)
   ,p_person_id        => l_person_id
   ,p_reporting_date   => l_abp_rep_date );

   IF p_aei_information22 IS NOT NULL THEN
      l_abp_rep_date := fnd_date.canonical_to_date(p_aei_information22);
   ELSE
      l_abp_rep_date := greatest(l_abp_rep_date,fnd_date.canonical_to_date(p_aei_information1));
   END IF;

   --call the procedure to insert rows into the ben_ext_chg_evt_log table
   pqp_nl_ext_functions.create_asg_info_ins_chg_evt
                        (p_assignment_id              =>   p_assignment_id
                        ,p_assignment_extra_info_id   =>   p_assignment_extra_info_id
                        ,p_aei_information1           =>   p_aei_information1
                        ,p_aei_information2           =>   p_aei_information2
                        ,p_aei_information3           =>   p_aei_information3
                        ,p_aei_information4           =>   p_aei_information4
                        ,p_effective_date             =>   l_eff_date
                        ,p_abp_reporting_date         =>   l_abp_rep_date
                        );

   --
   -- Call the procedure to register this change
   --
   register_retro_change
   (p_assignment_id    => p_assignment_id
   ,p_effective_date   => trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')));

ELSIF p_information_type = 'NL_ABP_PAR_INFO' THEN

     --fetch the current year from the eff date
     l_curr_year    := to_char(l_eff_date,'YYYY');
     l_start_year   := to_char(fnd_date.canonical_to_date(p_aei_information1),'YYYY');
     l_end_year     := to_char(fnd_date.canonical_to_date(nvl(p_aei_information2,
                          fnd_date.date_to_canonical(hr_api.g_eot))),'YYYY');

      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   l_counter := 0;

   FOR temp_rec IN cur_abp_asg_info1
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

         IF (trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) >=
             trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
             trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) <=
             trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
                hr_utility.raise_error;
         ELSIF (trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
                trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
                trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
                trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                   hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
                   hr_utility.raise_error;
         END IF;

         -- Store the Min Start Date and Max End Date
         IF l_counter = 0 THEN
            l_min_start_date := trunc(to_date(substr(temp_rec.aei_information1
                                              ,1,10),'YYYY/MM/DD'));
            l_max_end_date   := trunc(to_date(substr(temp_rec.aei_information2
                                              ,1,10),'YYYY/MM/DD'));
         ELSE
            IF trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD'))
                     < l_min_start_date THEN
               l_min_start_date := trunc(to_date(substr(temp_rec.aei_information1
                                                 ,1,10),'YYYY/MM/DD'));
            END IF;

            IF trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))
                     > l_max_end_date THEN
               l_max_end_date := trunc(to_date(substr(temp_rec.aei_information2
                                              ,1,10),'YYYY/MM/DD'));
            END IF;
         END IF;

         l_counter := l_counter + 1;

      END LOOP;

      --Check to see if the start and end dates encompasses all other rows
      IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
         <= l_min_start_date AND
         trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
         >= l_max_end_date  THEN
         hr_utility.set_message(8303,'PQP_230134_EIT_OVERLAP_ROWS');
         hr_utility.raise_error;
      END IF;

      --validate that the Date From is equal to or greater than the hire date
      OPEN c_get_hire_date(l_eff_date);
      FETCH c_get_hire_date INTO l_hire_date;
      CLOSE c_get_hire_date;
      IF l_hire_date > trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
         hr_utility.set_message(8303,'PQP_230055_DATE_FRM_BEF_HIRE');
         hr_utility.set_message_token(8303,'HIREDATE',to_char(l_hire_date));
         hr_utility.raise_error;
      END IF;

      --validate that if the override value is entered , the reason is also entered
      IF ((p_aei_information6 IS NOT NULL) AND (p_aei_information7 IS NULL)
          OR (p_aei_information8 IS NOT NULL) AND (p_aei_information9 IS NULL)
         ) THEN
            hr_utility.set_message(8303,'PQP_230056_NO_OVERRIDE_REASON');
            hr_utility.raise_error;
      END IF;

      --validate that only one among Pension Salary,Basis or Contribution is overridden
      IF NOT (((p_aei_information6 IS NOT NULL)
               AND (p_aei_information8 IS NULL)
              )
              OR
              ((p_aei_information8 IS NOT NULL)
               AND (p_aei_information6 IS NULL)
              )
              OR
              ((p_aei_information6 IS NULL)
               AND (p_aei_information8 IS NULL)
              )
             ) THEN
                hr_utility.set_message(8303,'PQP_230135_INV_EIT_OVERRIDES');
                hr_utility.raise_error;
      END IF;

   /*--validate that the eff date is lesser or equal to the end date
   IF l_eff_date > trunc(fnd_date.canonical_to_date(
      nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot)))) THEN
      hr_utility.set_message(8303,'PQP_230099_DT_TO_BEF_END_DT');
      hr_utility.raise_error;
   END IF;*/

   --validations for the salary override rows
   IF p_aei_information6 IS NOT NULL THEN

      --ensure that the end date is also entered
      IF p_aei_information2 IS NULL THEN
         hr_utility.set_message(8303,'PQP_230155_ENTER_END_DATE');
         hr_utility.raise_error;
      END IF;

      --ensure that the start date and end date are in the same year
      IF NOT ((l_start_year = l_curr_year)
              AND (l_end_year = l_curr_year)
             ) THEN
         hr_utility.set_message(8303,'PQP_230156_ENTER_CURR_YEAR');
         hr_utility.raise_error;
      END IF;

      --find the minimum and maximum start and end dates
      l_counter := 0;
      FOR temp_rec IN cur_get_sal_rows(l_curr_year)
      LOOP
         IF l_counter = 0 THEN
            l_min_sal_start := fnd_date.canonical_to_date(temp_rec.aei_information1);
            l_max_sal_end   := fnd_date.canonical_to_date(temp_rec.aei_information2);
         ELSE
            IF trunc(fnd_date.canonical_to_date(temp_rec.aei_information1))
               < l_min_sal_start THEN
               l_min_sal_start := trunc(fnd_date.canonical_to_date(temp_rec.aei_information1));
            END IF;
            IF trunc(fnd_date.canonical_to_date(p_aei_information2))
               > l_max_sal_end THEN
               l_max_sal_end := trunc(fnd_date.canonical_to_date(temp_rec.aei_information2));
            END IF;
         END IF;
         l_counter := l_counter + 1;
      END LOOP;

      -- Check to see if the records are in continuous order
      -- and there are no gaps
      IF l_min_sal_start IS NOT NULL AND l_max_sal_end IS NOT NULL THEN
         IF trunc(fnd_date.canonical_to_date(p_aei_information1))
            > l_max_sal_end + 1 THEN
            hr_utility.set_message(8303, 'PQP_230157_GAP_IN_SAL_ROW');
            hr_utility.raise_error;
         ELSIF trunc(fnd_date.canonical_to_date(p_aei_information2))
            < l_min_sal_start - 1 THEN
            hr_utility.set_message(8303, 'PQP_230157_GAP_IN_SAL_ROW');
            hr_utility.raise_error;
         END IF;
      END IF;

     IF nvl(l_min_sal_start,fnd_date.canonical_to_date(p_aei_information1))
         > fnd_date.canonical_to_date(p_aei_information1) THEN
         l_min_sal_start := fnd_date.canonical_to_date(p_aei_information1);
     END IF;

      --verify that the minimum date is correct date of the year
      IF (nvl(l_min_sal_start,fnd_date.canonical_to_date(p_aei_information1))
         <> get_valid_start_date(p_assignment_id,l_eff_date,l_error_status,l_error_message)) THEN
        hr_utility.set_message(8303,'PQP_230158_ST_DT_JAN_01');
        hr_utility.raise_error;
      Else
          IF (l_error_status = trim(to_char(1,'9'))) Then
             hr_utility.set_message(8303,'PQP_230205_ASSGN_NOT_EXISTS');
             hr_utility.raise_error;
          End IF;
     END IF;

  END IF; /*End of check if salary has been overridden*/

   --
   -- Derive the next abp reporting date
   --
   l_ret_val := get_reporting_date
   (p_effective_date   => fnd_date.canonical_to_date(to_char(TRUNC(
                          fnd_date.canonical_to_date(p_aei_information1)),'YYYY/MM')||'/01')
   ,p_assignment_id    => fnd_number.canonical_to_number(p_assignment_id)
   ,p_person_id        => l_person_id
   ,p_reporting_date   => l_abp_rep_date );

   --call the procedure to insert rows into the ben_ext_chg_evt_log table
   pqp_nl_ext_functions.create_sal_info_ins_chg_evt
                        (p_assignment_id              =>   p_assignment_id
                        ,p_assignment_extra_info_id   =>   p_assignment_extra_info_id
                        ,p_aei_information1           =>   p_aei_information1
                        ,p_aei_information2           =>   p_aei_information2
                        ,p_aei_information4           =>   p_aei_information4
                        ,p_aei_information5           =>   p_aei_information5
                        ,p_aei_information6           =>   p_aei_information6
                        ,p_effective_date             =>   l_eff_date
                        ,p_abp_reporting_date         =>   l_abp_rep_date
                        );

   --
   -- Call the procedure to register this change
   --
   register_retro_change
   (p_assignment_id    => p_assignment_id
   ,p_effective_date   => trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')));

--if the information context is Social Insurance Information, then call the
--procedure to insert information into the ben log tables
ELSIF p_information_type = 'NL_SII' THEN
   pqp_nl_ext_functions.create_si_info_ins_chg_evt
                        (p_assignment_id              =>   p_assignment_id
                        ,p_aei_information1           =>   p_aei_information1
                        ,p_aei_information2           =>   p_aei_information2
                        ,p_aei_information3           =>   p_aei_information3
                        ,p_effective_date             =>   l_eff_date
                        );

--if the information context is Saving Schemes Additional Contribution Informaiton,then
--perform the required validations
ELSIF p_information_type = 'NL_SAV_INFO' THEN
hr_utility.set_location('chking for sav eit',10);
   --validate that there is no other EIT row with the same savings type
   --and period number combination
   OPEN cur_sav_asg_info;
   FETCH cur_sav_asg_info INTO l_asg_sav_info_exists;
   IF cur_sav_asg_info%FOUND THEN
      CLOSE cur_sav_asg_info;
hr_utility.set_location('found same sav info',20);
      hr_utility.set_message(8303,'PQP_230141_SAV_INFO_EXISTS');
      hr_utility.raise_error;
   ELSE
      CLOSE cur_sav_asg_info;
   END IF;

   --validate that the period number entered is not greater than
   --the number of payroll periods in a year
   OPEN cur_periods_per_yr(c_eff_date => l_eff_date);
   FETCH cur_periods_per_yr INTO l_periods_per_yr;
   IF cur_periods_per_yr%FOUND THEN
      CLOSE cur_periods_per_yr;
hr_utility.set_location('found period number'||l_periods_per_yr,30);
      IF fnd_number.canonical_to_number(p_aei_information2) > l_periods_per_yr THEN
         hr_utility.set_message(8303,'PQP_230142_INV_PERIOD_NUMBER');
         hr_utility.raise_error;
      END IF;
   ELSE
      CLOSE cur_periods_per_yr;
   END IF;

   --validate that the amount entered is > 0
   IF fnd_number.canonical_to_number(p_aei_information3) <= 0 THEN
      hr_utility.set_message(8303,'PQP_230149_INV_ADDNL_AMT');
      hr_utility.raise_error;
   END IF;


ELSIF p_information_type = 'NL_ADDL_CALC' THEN

     --fetch the current year from the eff date
     --l_curr_year    := to_char(l_eff_date,'YYYY');
     --l_start_year   := to_char(fnd_date.canonical_to_date(p_aei_information1),'YYYY');
     --l_end_year     := to_char(fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot))),'YYYY');

      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

	l_counter := 0;

      FOR temp_rec IN cur_ret_addl_info_calc
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

	   IF (trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) >=
		 trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
		 trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) <=
		 trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
		    hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
		    hr_utility.raise_error;
	   ELSIF (trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
		    trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
		    trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
		    trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
			 hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
			 hr_utility.raise_error;
	   END IF;

	   -- Store the Min Start Date and Max End Date
	   IF l_counter = 0 THEN
		l_min_start_date := trunc(to_date(substr(temp_rec.aei_information1
							    ,1,10),'YYYY/MM/DD'));
		l_max_end_date   := trunc(to_date(substr(temp_rec.aei_information2
							    ,1,10),'YYYY/MM/DD'));
	   ELSE
		IF trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD'))
			   < l_min_start_date THEN
		   l_min_start_date := trunc(to_date(substr(temp_rec.aei_information1
								 ,1,10),'YYYY/MM/DD'));
		END IF;

		IF trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))
			   > l_max_end_date THEN
		   l_max_end_date := trunc(to_date(substr(temp_rec.aei_information2
							    ,1,10),'YYYY/MM/DD'));
		END IF;
	   END IF;

	   l_counter := l_counter + 1;

	END LOOP;

      --Check to see if the start and end dates encompasses all other rows
      IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
         <= l_min_start_date AND
         trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
         >= l_max_end_date  THEN
         hr_utility.set_message(8303,'PQP_230134_EIT_OVERLAP_ROWS');
         hr_utility.raise_error;
      END IF;

      --validate that the Date From is equal to or greater than the hire date
      OPEN c_get_hire_date(l_eff_date);
      FETCH c_get_hire_date INTO l_hire_date;
      CLOSE c_get_hire_date;

      IF l_hire_date > trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
         hr_utility.set_message(8303,'PQP_230055_DATE_FRM_BEF_HIRE');
         hr_utility.set_message_token(8303,'HIREDATE',to_char(l_hire_date));
         hr_utility.raise_error;
      END IF;


END IF;
END chk_dup_asg_info_row_ins;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dup_asg_info_row_upd >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dup_asg_info_row_upd (  p_assignment_extra_info_id    number
                                     ,p_assignment_id               number
                                     ,p_information_type            varchar2
                                     ,p_aei_information1            varchar2
                                     ,p_aei_information2            varchar2
                                     ,p_aei_information3            varchar2
                                     ,p_aei_information4            varchar2
                                     ,p_aei_information5         IN varchar2
                                     ,p_aei_information6         IN varchar2
                                     ,p_aei_information7         IN varchar2
                                     ,p_aei_information8         IN varchar2
                                     ,p_aei_information9         IN varchar2
                                     ,p_aei_information10        IN varchar2
                                     ,p_aei_information11        IN varchar2
                                     ,p_aei_information12        IN varchar2
                                     ,p_aei_information13        IN varchar2
                                     ,p_aei_information14        IN varchar2
                                     ,p_aei_information15        IN varchar2
                                     ,p_aei_information16        IN varchar2
                                     ,p_aei_information20        IN varchar2
                                     ,p_aei_information21        IN varchar2
                                     ,p_aei_information22        IN varchar2
                                     ,p_aei_information1_o          varchar2
                                     ,p_aei_information2_o          varchar2
                                     ,p_aei_information3_o          varchar2
                                     ,p_aei_information4_o          varchar2
                                     ,p_aei_information5_o        IN varchar2
                                     ,p_aei_information6_o        IN varchar2
                                     ,p_aei_information7_o        IN varchar2
                                   ) IS
CURSOR cur_abp_asg_info IS
SELECT aei_information1
      ,nvl(aei_information2,'4712/12/31') aei_information2
  FROM per_assignment_extra_info
 WHERE aei_information3 = p_aei_information3
   AND assignment_id  = p_assignment_id
   AND assignment_extra_info_id <> p_assignment_extra_info_id
   AND aei_information_category = 'NL_ABP_PI'
   AND information_type = 'NL_ABP_PI';

CURSOR cur_abp_asg_info1 IS
SELECT aei_information1
      ,nvl(aei_information2,'4712/12/31') aei_information2
  FROM per_assignment_extra_info
WHERE  assignment_id  = p_assignment_id
   AND assignment_extra_info_id <> p_assignment_extra_info_id
   AND aei_information_category = 'NL_ABP_PAR_INFO'
   AND information_type = 'NL_ABP_PAR_INFO';

--cursor to find all other rows with the same period number
--and the same savings type
CURSOR cur_sav_asg_info IS
SELECT 1
  FROM per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  assignment_extra_info_id <> p_assignment_extra_info_id
  AND  aei_information_category = 'NL_SAV_INFO'
  AND  information_type = 'NL_SAV_INFO'
  AND  aei_information1 = p_aei_information1
  AND  aei_information2 = p_aei_information2;

--cursor to find all the EIT rows which have a salary override
--and fall in the current year
CURSOR cur_get_sal_rows(c_year IN varchar2) IS
SELECT aei_information1,aei_information2
 FROM  per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
  AND  assignment_extra_info_id <> p_assignment_extra_info_id
  AND  aei_information_category = 'NL_ABP_PAR_INFO'
  AND  information_type = 'NL_ABP_PAR_INFO'
  AND  to_char(trunc(fnd_date.canonical_to_date(aei_information1)),'YYYY')
       = c_year
  AND  to_char(trunc(fnd_date.canonical_to_date(nvl(aei_information2,
       fnd_date.date_to_canonical(hr_api.g_eot)))),'YYYY')
       = c_year
  AND  aei_information6 IS NOT NULL;

--cursor to fetch the number of periods per year
CURSOR cur_periods_per_yr(c_eff_date IN DATE) IS
SELECT decode(hrl.lookup_code,'W',53,number_per_fiscal_year)
  FROM per_time_period_types,hr_lookups hrl
WHERE  period_type =
       (SELECT period_type
          FROM pay_payrolls_f
        WHERE  payroll_id =
               (SELECT payroll_id
                  FROM per_all_assignments_f
                WHERE  assignment_id = p_assignment_id
                  AND  c_eff_date BETWEEN effective_start_date
                  AND  nvl(effective_end_date,hr_api.g_eot)
               )
          AND  c_eff_date BETWEEN effective_start_date
          AND  nvl(effective_end_date,hr_api.g_eot)
       )
   AND hrl.lookup_type = 'PROC_PERIOD_TYPE'
   AND hrl.meaning     = period_type;

--Cursor to find the start and end dates for a particular pension type
CURSOR cur_get_st_end_dates(c_pension_type_id   in varchar2) IS
SELECT effective_start_date,effective_end_date
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--Cursor to find the pension sub category for the ABP Pension Type
CURSOR cur_get_pen_sub_cat(c_pension_type_id   in varchar2) IS
SELECT pension_sub_category
      ,threshold_conversion_rule
      ,contribution_conversion_rule
      ,pension_basis_calc_method
  FROM pqp_pension_types_f
WHERE pension_type_id = to_number(c_pension_type_id);

--Cursor to find all rows which have dates overlapping the current record dates
CURSOR cur_get_overlap_rows IS
SELECT aei_information3
  FROM per_assignment_extra_info
WHERE assignment_id = p_assignment_id
  AND assignment_extra_info_id <> p_assignment_extra_info_id
  AND information_type = 'NL_ABP_PI'
  AND aei_information_category = 'NL_ABP_PI'
  AND ((trunc(to_date(substr(aei_information1,1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
        AND trunc(to_date(substr(aei_information1,1,10),'YYYY/MM/DD'))
            <= trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(nvl(aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
       >= trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
       AND trunc(to_date(substr(nvl(aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
           <= trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      OR
      (trunc(to_date(substr(aei_information1,1,10),'YYYY/MM/DD'))
      <= trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
      AND trunc(to_date(substr(nvl(aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
          >= trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      )
      );

--Cursor to fetch the hire date of the employee
CURSOR c_get_hire_date(c_eff_date in date) IS
SELECT max(date_start)
  FROM per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = p_assignment_id
   AND pps.business_group_id = asg.business_group_id
   AND date_start <= c_eff_date;

--Cursor to find the start and end dates of schemes created using the given PT
CURSOR cur_get_schm_st_end(c_pension_type_id IN varchar2) IS
SELECT to_date(substr(eei_information10,1,10),'DD/MM/YYYY') start_date,
       to_date(substr(eei_information11,1,10),'DD/MM/YYYY') end_date
  FROM pay_element_type_extra_info
WHERE  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
  AND  information_type         = 'PQP_NL_ABP_DEDUCTION'
  AND  eei_information2 = c_pension_type_id;

--cursor to find the eff date
CURSOR c_get_eff_date IS
SELECT effective_date
   FROM fnd_sessions
WHERE session_id = userenv('sessionid');

CURSOR c_get_person_id IS
Select person_id from per_all_assignments_f
where assignment_id = p_assignment_id;

CURSOR c_run_results_exist IS
SELECT ppa.date_earned
  FROM pay_assignment_actions paa,pay_payroll_actions ppa
WHERE  paa.payroll_action_id = ppa.payroll_action_id
  AND  paa.assignment_id     = p_assignment_id
  AND  ppa.date_earned between
       fnd_date.canonical_to_date(p_aei_information1_o)
  AND  nvl(fnd_date.canonical_to_date(p_aei_information2_o),hr_api.g_eot)
  AND  paa.assignment_action_id IN
         (SELECT assignment_action_id
            FROM pay_run_results
          WHERE  element_type_id IN
                 (SELECT element_type_id
                    FROM pay_element_type_extra_info
                  WHERE  information_type = 'PQP_NL_ABP_DEDUCTION'
                    AND  eei_information_category = 'PQP_NL_ABP_DEDUCTION'
                    AND  eei_information2         =  p_aei_information3_o
                 )
         );


CURSOR cur_ret_addl_info_calc IS
SELECT aei_information1
      ,nvl(aei_information2,'4712/12/31') aei_information2
  FROM per_assignment_extra_info
WHERE  assignment_id  = p_assignment_id
   AND assignment_extra_info_id <> p_assignment_extra_info_id
   AND aei_information_category = 'NL_ADDL_CALC'
   AND information_type = 'NL_ADDL_CALC';


l_min_start_date      DATE   := NULL;
l_max_end_date        DATE   := NULL;
l_counter             NUMBER := 0;
l_pen_sub_cat1        pqp_pension_types_f.pension_sub_category%TYPE;
l_pen_sub_cat2        pqp_pension_types_f.pension_sub_category%TYPE;
l_thresh_conv_rule1   pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_thresh_conv_rule2   pqp_pension_types_f.threshold_conversion_rule%TYPE;
l_contrib_conv_rule1  pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_contrib_conv_rule2  pqp_pension_types_f.contribution_conversion_rule%TYPE;
l_basis_method1       pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_basis_method2       pqp_pension_types_f.pension_basis_calc_method%TYPE;
l_min_st_dt           DATE;
l_max_end_dt          DATE;
l_hire_date           DATE;
l_min_schm_st         DATE;
l_max_schm_end        DATE;
l_eff_date            DATE;
l_abp_rep_date        DATE;
l_allow_update        NUMBER := 1;
i                     NUMBER := 1;
l_date_earned         DATE;
l_asg_sav_info_exists NUMBER;
l_periods_per_yr      NUMBER;
l_curr_year           VARCHAR2(4);
l_start_year          VARCHAR2(4);
l_end_year            VARCHAR2(4);
l_min_sal_start       DATE := null;
l_max_sal_end         DATE := null;
l_error_status        CHAR :='0';
l_error_message       VARCHAR2(100);
l_ret_val             NUMBER;
l_person_id           NUMBER;

BEGIN

--fetch the eff date
OPEN c_get_eff_date;
FETCH c_get_eff_date INTO l_eff_date;
CLOSE c_get_eff_date;

Open c_get_person_id;
Fetch c_get_person_id INTO l_person_id;
CLOSE c_get_person_id;

IF p_information_type = 'NL_ABP_PI' THEN

      --check to see if the pension type has been changed. If so, throw an error
      IF p_aei_information3 <> p_aei_information3_o THEN
         hr_utility.set_message(8303,'PQP_230100_PT_UPD_NOT_ALLOWED');
         hr_utility.raise_error;
      END IF;
      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   -- check to see that the start and end dates entered are between the
   -- min start date and max end date of the pension type
   FOR temp_rec IN cur_get_st_end_dates(p_aei_information3)
      LOOP

      -- loop through all the date tracked rows of the pension type and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_st_dt  := temp_rec.effective_start_date;
         l_max_end_dt := temp_rec.effective_end_date;
      ELSE
         IF temp_rec.effective_start_date <  l_min_st_dt THEN
            l_min_st_dt := temp_rec.effective_start_date;
         END IF;

         IF temp_rec.effective_end_date > l_max_end_dt THEN
            l_max_end_dt := temp_rec.effective_end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and greatest end date,
   -- of all date tracked rows of the PT, raise an error
   IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
      <  l_min_st_dt
      OR trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
      > l_max_end_dt THEN
       hr_utility.set_message(8303,'PQP_230047_INV_ST_END_DATES');
       hr_utility.raise_error;
   END IF;

   l_counter := 0;
/*
   --
   -- Check to see that atleast one scheme created using the pension
   -- type exists between the date from and date to
   --
   FOR temp_rec IN cur_get_schm_st_end(p_aei_information3)
      LOOP

      -- Loop through all the rows of the element extra info and find
      -- the minimum start date and maximum end date
      IF (l_counter = 0) THEN
         l_min_schm_st  := temp_rec.start_date;
         l_max_schm_end := temp_rec.end_date;
      ELSE
         IF temp_rec.start_date <  l_min_schm_st THEN
            l_min_schm_st := temp_rec.start_date;
         END IF;

         IF temp_rec.end_date > l_max_schm_end THEN
            l_max_schm_end := temp_rec.end_date;
         END IF;
      END IF;

      l_counter := l_counter + 1;

      END LOOP;

   -- if the start/end date is not between the least start date and
   -- greatest end date,of all element EIT rows of the PT, raise an error
   IF fnd_date.canonical_to_date(p_aei_information1)
      <  l_min_schm_st
      OR fnd_date.canonical_to_date(nvl(p_aei_information2,'4712/12/31'))
      > l_max_schm_end THEN
       hr_utility.set_message(8303,'PQP_230070_INV_SCHM_DATES');
       hr_utility.raise_error;
   END IF;
*/
   l_counter := 0;

   FOR temp_rec IN cur_abp_asg_info
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

         IF (trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) >=
             trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
             trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) <=
             trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
                hr_utility.raise_error;
         ELSIF (trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
                trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
                trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
                trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                   hr_utility.set_message(8303, 'PQP_230041_OVERLAP_PT_ROWS');
                   hr_utility.raise_error;
         END IF;

      END LOOP;

      FOR temp_rec1 IN cur_abp_asg_info
         LOOP
       --  hr_utility.set_location('start date'||temp_rec1.org_information1,10);
       --  hr_utility.set_location('end date'||temp_rec1.org_information2,20);
         -- Store the Min Start Date and Max End Date
            IF l_counter = 0 THEN
               l_min_start_date := trunc(to_date(substr(temp_rec1.aei_information1
                                   ,1,10),'YYYY/MM/DD'));
               l_max_end_date   := trunc(to_date(substr(temp_rec1.aei_information2
                                   ,1,10),'YYYY/MM/DD'));
            ELSE
               IF trunc(to_date(substr(temp_rec1.aei_information1,1,10),'YYYY/MM/DD'))
                        < l_min_start_date THEN
                  l_min_start_date :=
                         trunc(to_date(substr(temp_rec1.aei_information1
                                       ,1,10),'YYYY/MM/DD'));
               END IF;

               IF trunc(to_date(substr(temp_rec1.aei_information2,1,10),'YYYY/MM/DD'))
                     > l_max_end_date THEN
                  l_max_end_date := trunc(to_date(substr(temp_rec1.aei_information2
                                                 ,1,10),'YYYY/MM/DD'));
               END IF;
            END IF;
            l_counter := l_counter + 1;
         END LOOP;
      --hr_utility.trace_off;

      -- Check to see if the records are in continuous order
      -- and there are no gaps (no longer need to chk since gaps are allowed)
      /*IF trunc(to_date(substr(p_aei_information1_o,1,10),'YYYY/MM/DD'))
         > l_min_start_date THEN

         IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
            > trunc(to_date(substr(p_aei_information1_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230042_GAP_EXIST_IN_PT_ROW');
            hr_utility.raise_error;

         ELSIF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
            < trunc(to_date(substr(p_aei_information1_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
            hr_utility.raise_error;

         END IF;

      ELSIF trunc(to_date(substr(p_aei_information2_o,1,10),'YYYY/MM/DD'))
            < l_max_end_date THEN

         IF trunc(to_date(substr(p_aei_information2,1,10),'YYYY/MM/DD'))
            < trunc(to_date(substr(p_aei_information2_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230042_GAP_EXIST_IN_PT_ROW');
            hr_utility.raise_error;

         ELSIF trunc(to_date(substr(p_aei_information2,1,10),'YYYY/MM/DD'))
            > trunc(to_date(substr(p_aei_information2_o,1,10),'YYYY/MM/DD')) THEN

            hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;*/

      --Check to see if the start and end dates encompasses all other rows
      IF l_min_start_date IS NOT NULL AND l_max_end_date IS NOT NULL THEN

         IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
            <= l_min_start_date AND
            trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
            >= l_max_end_date  THEN

            hr_utility.set_message(8303,'PQP_230041_OVERLAP_PT_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;

      --Check to see that there is only one pension type of a particular sub
      --category on a particular date

      hr_utility.set_location('name'||p_aei_information3,7);
      -- find the pension sub category for the current pension type row
      OPEN cur_get_pen_sub_cat(p_aei_information3);
      FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat1
                                    ,l_thresh_conv_rule1
                                    ,l_contrib_conv_rule1
                                    ,l_basis_method1;
      CLOSE cur_get_pen_sub_cat;
      hr_utility.set_location('Current sub category'||l_pen_sub_cat1,10);
      -- now loop through the rows of all overlapping pension type rows
      --if a row with the same sub category exists , raise an error
      FOR temp_rec1 in cur_get_overlap_rows
      LOOP
         OPEN cur_get_pen_sub_cat(temp_rec1.aei_information3);
         FETCH cur_get_pen_sub_cat INTO l_pen_sub_cat2
                                       ,l_thresh_conv_rule2
                                       ,l_contrib_conv_rule2
                                       ,l_basis_method2;
         CLOSE cur_get_pen_sub_cat;
         hr_utility.set_location('pension subcategory'||l_pen_sub_cat2,20);
         IF l_pen_sub_cat1 = l_pen_sub_cat2
            AND l_thresh_conv_rule1  =  l_thresh_conv_rule2
            AND l_contrib_conv_rule1 =  l_contrib_conv_rule2
            AND l_basis_method1      =  l_basis_method2 THEN

            hr_utility.set_message(8303,'PQP_230046_SAME_SUB_CAT_ERR');
            hr_utility.raise_error;

         END IF;
      --hr_utility.trace_off;
      END LOOP;

      -- if the contribution method is PE the value should be between 0 and 999.999
      IF nvl(p_aei_information13,'PE') = 'PE' THEN
         IF fnd_number.canonical_to_number(nvl(p_aei_information14,'0')) > 999.999 THEN
            hr_utility.set_message(8303,'PQP_230052_INV_PERCENT_VALUE');
            hr_utility.raise_error;
         END IF;
      END IF;

      -- if the contribution method is PE the value should be between 0 and 999.999
      IF nvl(p_aei_information15,'PE') = 'PE' THEN
         IF fnd_number.canonical_to_number(nvl(p_aei_information16,'0')) > 999.999 THEN
            hr_utility.set_message(8303,'PQP_230052_INV_PERCENT_VALUE');
            hr_utility.raise_error;
         END IF;
      END IF;

      --validate that the Date From is equal to or greater than the hire date
      OPEN c_get_hire_date(l_eff_date);
      FETCH c_get_hire_date INTO l_hire_date;
      CLOSE c_get_hire_date;
      IF l_hire_date > trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
         hr_utility.set_message(8303,'PQP_230055_DATE_FRM_BEF_HIRE');
         hr_utility.set_message_token(8303,'HIREDATE',to_char(l_hire_date));
         hr_utility.raise_error;
      END IF;

      --validate that if the override value is entered , the reason is also entered
      IF ((p_aei_information7 IS NOT NULL) AND (p_aei_information8 IS NULL)
          OR (p_aei_information9 IS NOT NULL) AND (p_aei_information10 IS NULL)
          OR (p_aei_information11 IS NOT NULL) AND (p_aei_information12 IS NULL)
          OR (p_aei_information20 IS NOT NULL) AND (p_aei_information21 IS NULL)
         ) THEN
            hr_utility.set_message(8303,'PQP_230056_NO_OVERRIDE_REASON');
            hr_utility.raise_error;
      END IF;

      --validate that only one among Pension Salary,Basis or Contribution is overridden
      IF NOT (((p_aei_information7 IS NOT NULL)
               AND (p_aei_information9 IS NULL)
               AND ((p_aei_information11 IS NULL) AND (p_aei_information20 IS NULL))
              )
              OR
              ((p_aei_information9 IS NOT NULL)
               AND (p_aei_information7 IS NULL)
               AND ((p_aei_information11 IS NULL) AND (p_aei_information20 IS NULL))
              )
              OR
              (((p_aei_information11 IS NOT NULL) OR (p_aei_information20 IS NOT NULL))
               AND (p_aei_information7 IS NULL)
               AND (p_aei_information9 IS NULL)
              )
              OR
              ((p_aei_information7 IS NULL)
               AND (p_aei_information9 IS NULL)
               AND ((p_aei_information11 IS NULL) AND (p_aei_information20 IS NULL))
             )) THEN
                hr_utility.set_message(8303,'PQP_230057_INVALID_OVERRIDES');
                hr_utility.raise_error;
      END IF;

      /*--validate that if the override is entered for contribution value, then
      -- the contribution type is also entered
      IF ((p_aei_information13 IS NOT NULL AND p_aei_information14 IS NULL)
          OR (p_aei_information13 IS NULL AND p_aei_information14 IS NOT NULL)
          OR (p_aei_information15 IS NOT NULL AND p_aei_information16 IS NULL)
          OR (p_aei_information15 IS NULL AND p_aei_information16 IS NOT NULL)
         ) THEN
          hr_utility.set_message(8303,'PQP_230058_INVALID_CONTRIB');
          hr_utility.raise_error;
      END IF; */

      --this validation has now changed as follows
      --the following combinations would occur
      /*---------------------------------------------------------------
        CONTRIBUTION TYPE         CONTRIBUTION VALUE
        ---------------------------------------------------------------
        null                      null -- age dependant contribution
        null                      non-null value -- validate this case
        PE                        null -- age dependant contribution
        PE                        non-null value -- normal case
        FA                        null -- validate this case
        FA                        non-null value -- normal case
        ---------------------------------------------------------------
      */

       IF ((p_aei_information13 IS NULL AND p_aei_information14 IS NOT NULL)
        OR (p_aei_information15 IS NULL AND p_aei_information16 IS NOT NULL)
          ) THEN
          hr_utility.set_message(8303,'PQP_230140_INV_CONTRIBUTION');
          hr_utility.raise_error;
       END IF;

       IF ((nvl(p_aei_information13,'PE') = 'FA' AND p_aei_information14 IS NULL)
        OR (nvl(p_aei_information15,'PE') = 'FA' AND p_aei_information16 IS NULL)
          ) THEN
          hr_utility.set_message(8303,'PQP_230058_INVALID_CONTRIB');
          hr_utility.raise_error;
       END IF;

      /*--validate that if an end date is entered, then end reason should also be entered
      IF p_aei_information2 IS NOT NULL AND p_aei_information4 IS NULL THEN
         hr_utility.set_message(8303,'PQP_230103_ENTER_END_REASON');
         hr_utility.raise_error;
      END IF; */

    --check to see if update can be allowed on the ASG EIT row
    --also fetch the greatest date earned, so that any end date entered
    --should be greater than this date
    FOR csr_row IN c_run_results_exist
       LOOP
          l_allow_update   := 0;
          IF i = 1 THEN
             l_date_earned := csr_row.date_earned;
             i             := i+1;
          ELSIF l_date_earned < csr_row.date_earned THEN
             l_date_earned := csr_row.date_earned;
          END IF;
       END LOOP;

    --do not allow an update of pension type if an update is not
    --allowed
    IF l_allow_update = 0 THEN
       IF (p_aei_information3 <> p_aei_information3_o) THEN
          hr_utility.set_message(8303,'PQP_230101_UPD_NOT_ALLOWED');
          hr_utility.raise_error;
       END IF;
    END IF;

/*       ELSIF fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot))) <>
             fnd_date.canonical_to_date(nvl(p_aei_information2_o,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
          IF l_eff_date <= l_date_earned OR fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot)))
             <= l_date_earned THEN
             hr_utility.set_message(8303,'PQP_230102_DT_TO_AFTER_PAY_RUN');
             hr_utility.raise_error;
          ELSIF l_eff_date > fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
             hr_utility.set_message(8303,'PQP_230099_DT_TO_BEF_END_DT');
             hr_utility.raise_error;
          END IF;
       END IF;
     --else update is allowed
     ELSE
        IF fnd_date.canonical_to_date(nvl(p_aei_information2_o,fnd_date.date_to_canonical(hr_api.g_eot))) <>
           fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
           IF l_eff_date > fnd_date.canonical_to_date(nvl(p_aei_information2,fnd_date.date_to_canonical(hr_api.g_eot))) THEN
              hr_utility.set_message(8303,'PQP_230099_DT_TO_BEF_END_DT');
              hr_utility.raise_error;
           END IF;
        END IF;
     END IF;*/

   IF p_aei_information1 <> p_aei_information1_o OR
      p_aei_information2 <> p_aei_information2_o OR
      p_aei_information22 IS NOT NULL THEN
   --
   -- Derive the next abp reporting date
   --
   l_ret_val := get_reporting_date
   (p_effective_date   => fnd_date.canonical_to_date(to_char(TRUNC(
                          fnd_date.canonical_to_date(p_aei_information1)),'YYYY/MM')||'/01')
   ,p_assignment_id    => fnd_number.canonical_to_number(p_assignment_id)
   ,p_person_id        => l_person_id
   ,p_reporting_date   => l_abp_rep_date );

   IF p_aei_information22 IS NOT NULL THEN
      l_abp_rep_date := fnd_date.canonical_to_date(p_aei_information22);
   ELSE
      l_abp_rep_date := greatest(l_abp_rep_date,fnd_date.canonical_to_date(p_aei_information1));
   END IF;

    --Call the procedure to insert the rows in the ben_ext_chg_evt_log table
    pqp_nl_ext_functions.create_asg_info_upd_chg_evt
                         (p_assignment_id         =>   p_assignment_id
                         ,p_assignment_extra_info_id => p_assignment_extra_info_id
                         ,p_aei_information1      =>   p_aei_information1
                         ,p_aei_information2      =>   p_aei_information2
                         ,p_aei_information3      =>   p_aei_information3
                         ,p_aei_information4      =>   p_aei_information4
                         ,p_aei_information1_o    =>   p_aei_information1_o
                         ,p_aei_information2_o    =>   p_aei_information2_o
                         ,p_effective_date        =>   l_eff_date
                         ,p_abp_reporting_date    =>   l_abp_rep_date
                         );
    END IF;

   --
   -- Call the procedure to register this change
   --
   register_retro_change
   (p_assignment_id    => p_assignment_id
   ,p_effective_date   => LEAST( trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')),
                          trunc(to_date(substr(p_aei_information1_o,1,10),'YYYY/MM/DD'))));

ELSIF p_information_type = 'NL_ABP_PAR_INFO' THEN

     --fetch the current year from the eff date
     l_curr_year    := to_char(l_eff_date,'YYYY');
     l_start_year   := to_char(fnd_date.canonical_to_date(p_aei_information1),'YYYY');
     l_end_year     := to_char(fnd_date.canonical_to_date(nvl(p_aei_information2,
                          fnd_date.date_to_canonical(hr_api.g_eot))),'YYYY');

      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   l_counter := 0;

   FOR temp_rec IN cur_abp_asg_info1
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

         IF (trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) >=
             trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
             trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) <=
             trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
                hr_utility.raise_error;
         ELSIF (trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
                trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
                trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
                trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                   hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
                   hr_utility.raise_error;
         END IF;

      END LOOP;

      FOR temp_rec1 IN cur_abp_asg_info1
         LOOP
       --  hr_utility.set_location('start date'||temp_rec1.org_information1,10);
       --  hr_utility.set_location('end date'||temp_rec1.org_information2,20);
         -- Store the Min Start Date and Max End Date
            IF l_counter = 0 THEN
               l_min_start_date := trunc(to_date(substr(temp_rec1.aei_information1
                                   ,1,10),'YYYY/MM/DD'));
               l_max_end_date   := trunc(to_date(substr(temp_rec1.aei_information2
                                   ,1,10),'YYYY/MM/DD'));
            ELSE
               IF trunc(to_date(substr(temp_rec1.aei_information1,1,10),'YYYY/MM/DD'))
                        < l_min_start_date THEN
                  l_min_start_date :=
                         trunc(to_date(substr(temp_rec1.aei_information1
                                       ,1,10),'YYYY/MM/DD'));
               END IF;

               IF trunc(to_date(substr(temp_rec1.aei_information2,1,10),'YYYY/MM/DD'))
                     > l_max_end_date THEN
                  l_max_end_date := trunc(to_date(substr(temp_rec1.aei_information2
                                                 ,1,10),'YYYY/MM/DD'));
               END IF;
            END IF;
            l_counter := l_counter + 1;
         END LOOP;
      --hr_utility.trace_off;

      --Check to see if the start and end dates encompasses all other rows
      IF l_min_start_date IS NOT NULL AND l_max_end_date IS NOT NULL THEN

         IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
            <= l_min_start_date AND
            trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
            >= l_max_end_date  THEN

            hr_utility.set_message(8303,'PQP_230134_EIT_OVERLAP_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;

      --validate that the Date From is equal to or greater than the hire date
      OPEN c_get_hire_date(l_eff_date);
      FETCH c_get_hire_date INTO l_hire_date;
      CLOSE c_get_hire_date;
      IF l_hire_date > trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
         hr_utility.set_message(8303,'PQP_230055_DATE_FRM_BEF_HIRE');
         hr_utility.set_message_token(8303,'HIREDATE',to_char(l_hire_date));
         hr_utility.raise_error;
      END IF;

      --validate that if the override value is entered , the reason is also entered
      IF ((p_aei_information6 IS NOT NULL) AND (p_aei_information7 IS NULL)
          OR (p_aei_information8 IS NOT NULL) AND (p_aei_information9 IS NULL)
         ) THEN
            hr_utility.set_message(8303,'PQP_230056_NO_OVERRIDE_REASON');
            hr_utility.raise_error;
      END IF;

      --validate that only one among Pension Salary,Basis is overridden
      IF NOT (((p_aei_information6 IS NOT NULL)
               AND (p_aei_information8 IS NULL)
              )
              OR
              ((p_aei_information8 IS NOT NULL)
               AND (p_aei_information6 IS NULL)
              )
              OR
              ((p_aei_information6 IS NULL)
               AND (p_aei_information8 IS NULL)
             )) THEN
                hr_utility.set_message(8303,'PQP_230135_INV_EIT_OVERRIDES');
                hr_utility.raise_error;
      END IF;

   --validations for the salary override rows
   IF p_aei_information6 IS NOT NULL THEN

      --ensure that the end date is also entered
      IF p_aei_information2 IS NULL THEN
         hr_utility.set_message(8303,'PQP_230155_ENTER_END_DATE');
         hr_utility.raise_error;
      END IF;

      --ensure that the start date and end date are in the same year
      IF NOT ((l_start_year = l_curr_year)
              AND (l_end_year = l_curr_year)
             ) THEN
         hr_utility.set_message(8303,'PQP_230156_ENTER_CURR_YEAR');
         hr_utility.raise_error;
      END IF;

      --find the minimum and maximum start and end dates
      l_counter := 0;
      FOR temp_rec IN cur_get_sal_rows(l_curr_year)
      LOOP
         IF l_counter = 0 THEN
            l_min_sal_start := fnd_date.canonical_to_date(temp_rec.aei_information1);
            l_max_sal_end   := fnd_date.canonical_to_date(temp_rec.aei_information2);
         ELSE
            IF trunc(fnd_date.canonical_to_date(temp_rec.aei_information1))
               < l_min_sal_start THEN
               l_min_sal_start := trunc(fnd_date.canonical_to_date(temp_rec.aei_information1));
            END IF;
            IF trunc(fnd_date.canonical_to_date(p_aei_information2))
               > l_max_sal_end THEN
               l_max_sal_end := trunc(fnd_date.canonical_to_date(temp_rec.aei_information2));
            END IF;
         END IF;
         l_counter := l_counter + 1;
      END LOOP;

      -- Check to see if the records are in continuous order
      -- and there are no gaps
    IF l_min_sal_start IS NOT NULL AND l_max_sal_end IS NOT NULL THEN
      IF fnd_date.canonical_to_date(p_aei_information1_o)
         > l_min_start_date THEN

         IF fnd_date.canonical_to_date(p_aei_information1)
            > fnd_date.canonical_to_date(p_aei_information1_o) THEN

            hr_utility.set_message(8303,'PQP_230157_GAP_IN_SAL_ROW');
            hr_utility.raise_error;

         ELSIF fnd_date.canonical_to_date(p_aei_information1)
            < fnd_date.canonical_to_date(p_aei_information1_o) THEN

            hr_utility.set_message(8303,'PQP_230134_EIT_OVERLAP_ROWS');
            hr_utility.raise_error;

         END IF;

      ELSIF fnd_date.canonical_to_date(p_aei_information2_o)
            < l_max_end_date THEN

         IF fnd_date.canonical_to_date(p_aei_information2)
            < fnd_date.canonical_to_date(p_aei_information2_o) THEN

            hr_utility.set_message(8303,'PQP_230157_GAP_IN_SAL_ROW');
            hr_utility.raise_error;

         ELSIF fnd_date.canonical_to_date(p_aei_information2)
            > fnd_date.canonical_to_date(p_aei_information2_o) THEN

            hr_utility.set_message(8303,'PQP_230134_EIT_OVERLAP_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;
   END IF;/*only if other rows exist*/

      IF nvl(l_min_sal_start,fnd_date.canonical_to_date(p_aei_information1))
	  > fnd_date.canonical_to_date(p_aei_information1) THEN
	  l_min_sal_start := fnd_date.canonical_to_date(p_aei_information1);
      END IF;

      --verify that the minimum date is correct date or not

     IF (nvl(l_min_sal_start,fnd_date.canonical_to_date(p_aei_information1))
         <> get_valid_start_date(p_assignment_id,l_eff_date,l_error_status,l_error_message)) THEN
        hr_utility.set_message(8303,'PQP_230158_ST_DT_JAN_01');
        hr_utility.raise_error;
     Else
          IF (l_error_status = trim(to_char(1,'9'))) Then
            hr_utility.set_message(8303,'PQP_230205_ASSGN_NOT_EXISTS');
            hr_utility.raise_error;
          End IF;
     END IF;

  END IF; /*End of check if salary has been overridden*/

   --
   -- Derive the next abp reporting date
   --
   l_ret_val := get_reporting_date
   (p_effective_date   => fnd_date.canonical_to_date(to_char(TRUNC(
                          fnd_date.canonical_to_date(p_aei_information1)),'YYYY/MM')||'/01')
   ,p_assignment_id    => fnd_number.canonical_to_number(p_assignment_id)
   ,p_person_id        => l_person_id
   ,p_reporting_date   => l_abp_rep_date );

    --Call the procedure to insert the rows in the ben_ext_chg_evt_log table
    pqp_nl_ext_functions.create_sal_info_upd_chg_evt
                         (p_assignment_id         =>   p_assignment_id
                         ,p_assignment_extra_info_id =>   p_assignment_extra_info_id
                         ,p_aei_information1      =>   p_aei_information1
                         ,p_aei_information2      =>   p_aei_information2
                         ,p_aei_information4      =>   p_aei_information4
                         ,p_aei_information5      =>   p_aei_information5
                         ,p_aei_information6      =>   p_aei_information6
                         ,p_aei_information1_o    =>   p_aei_information1_o
                         ,p_aei_information2_o    =>   p_aei_information2_o
                         ,p_aei_information4_o    =>   p_aei_information4_o
                         ,p_aei_information5_o    =>   p_aei_information5_o
                         ,p_aei_information6_o    =>   p_aei_information6_o
                         ,p_effective_date        =>   l_eff_date
                         ,p_abp_reporting_date    =>   l_abp_rep_date
                         );

   --
   -- Call the procedure to register this change
   --
   register_retro_change
   (p_assignment_id    => p_assignment_id
   ,p_effective_date   => LEAST( trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')),
                          trunc(to_date(substr(p_aei_information1_o,1,10),'YYYY/MM/DD'))));

--if the information type is Social Insurance Information , then call the extract function
--to insert rows as required into the ben log tables for logging the changes
ELSIF p_information_type = 'NL_SII' THEN
   pqp_nl_ext_functions.create_si_info_upd_chg_evt
                        (p_assignment_id          =>   p_assignment_id
                        ,p_aei_information1       =>   p_aei_information1
                        ,p_aei_information2       =>   p_aei_information2
                        ,p_aei_information3       =>   p_aei_information3
                        ,p_aei_information1_o     =>   p_aei_information1_o
                        ,p_aei_information2_o     =>   p_aei_information2_o
                        ,p_aei_information3_o     =>   p_aei_information3_o
                        ,p_effective_date         =>   l_eff_date
                        );

--if the information context is Saving Schemes Additional Contribution Informaiton,then
--perform the required validations
ELSIF p_information_type = 'NL_SAV_INFO' THEN

   --validate that there is no other EIT row with the same savings type
   --and period number combination
   OPEN cur_sav_asg_info;
   FETCH cur_sav_asg_info INTO l_asg_sav_info_exists;
   IF cur_sav_asg_info%FOUND THEN
      CLOSE cur_sav_asg_info;
      hr_utility.set_message(8303,'PQP_230141_SAV_INFO_EXISTS');
      hr_utility.raise_error;
   ELSE
      CLOSE cur_sav_asg_info;
   END IF;

   --validate that the period number entered is not greater than
   --the number of payroll periods in a year
   OPEN cur_periods_per_yr(c_eff_date => l_eff_date);
   FETCH cur_periods_per_yr INTO l_periods_per_yr;
   IF cur_periods_per_yr%FOUND THEN
      CLOSE cur_periods_per_yr;
      IF fnd_number.canonical_to_number(p_aei_information2) > l_periods_per_yr THEN
         hr_utility.set_message(8303,'PQP_230142_INV_PERIOD_NUMBER');
         hr_utility.raise_error;
      END IF;
   ELSE
      CLOSE cur_periods_per_yr;
   END IF;

   --validate that the amount entered is > 0
   IF fnd_number.canonical_to_number(p_aei_information3) <= 0 THEN
      hr_utility.set_message(8303,'PQP_230149_INV_ADDNL_AMT');
      hr_utility.raise_error;
   END IF;


ELSIF p_information_type = 'NL_ADDL_CALC' THEN

      -- Check if the End Date is Less than or equal
      -- to the Start Date
      IF trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <
         trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
            hr_utility.set_message(8303, 'PQP_230040_END_DT_BEF_ST_DT');
            hr_utility.raise_error;
      END IF;

   l_counter := 0;

   FOR temp_rec IN cur_ret_addl_info_calc
      LOOP

      -- We need to check if the pension type row
      -- being entered now is overlapping with data
      -- that has already been entered for this
      -- pension type.
      -- Here are the cases we check for overlap
      -- D1 is Old St Date and D2 is Old End Date
      -- N1 is New St Date and N2 is New End Date

      -------D1----------------------D2-------
      -------------N1-------N2----------------
      -------------N1----------------N2-------
      -------------N1---------------------N2--
      -------N1-------------N2----------------
      -------N1----------------------N2-------
      -------N1---------------------------N2--
      --N1------------------N2----------------
      --N1---------------------------N2-------
      --N1--------------------------------N2--
      --N1---N2-------------------------------
      -------------------------------N1---N2--

         IF (trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) >=
             trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
             trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) <=
             trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
                hr_utility.raise_error;
         ELSIF (trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) >=
                trunc(to_date(substr(temp_rec.aei_information1,1,10),'YYYY/MM/DD')) AND
                trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD')) <=
                trunc(to_date(substr(temp_rec.aei_information2,1,10),'YYYY/MM/DD'))) THEN
                   hr_utility.set_message(8303, 'PQP_230134_EIT_OVERLAP_ROWS');
                   hr_utility.raise_error;
         END IF;

      END LOOP;

      FOR temp_rec1 IN cur_ret_addl_info_calc
         LOOP
       --  hr_utility.set_location('start date'||temp_rec1.org_information1,10);
       --  hr_utility.set_location('end date'||temp_rec1.org_information2,20);
         -- Store the Min Start Date and Max End Date
            IF l_counter = 0 THEN
               l_min_start_date := trunc(to_date(substr(temp_rec1.aei_information1
                                   ,1,10),'YYYY/MM/DD'));
               l_max_end_date   := trunc(to_date(substr(temp_rec1.aei_information2
                                   ,1,10),'YYYY/MM/DD'));
            ELSE
               IF trunc(to_date(substr(temp_rec1.aei_information1,1,10),'YYYY/MM/DD'))
                        < l_min_start_date THEN
                  l_min_start_date :=
                         trunc(to_date(substr(temp_rec1.aei_information1
                                       ,1,10),'YYYY/MM/DD'));
               END IF;

               IF trunc(to_date(substr(temp_rec1.aei_information2,1,10),'YYYY/MM/DD'))
                     > l_max_end_date THEN
                  l_max_end_date := trunc(to_date(substr(temp_rec1.aei_information2
                                                 ,1,10),'YYYY/MM/DD'));
               END IF;
            END IF;
            l_counter := l_counter + 1;
         END LOOP;
      --hr_utility.trace_off;

      --Check to see if the start and end dates encompasses all other rows
      IF l_min_start_date IS NOT NULL AND l_max_end_date IS NOT NULL THEN

         IF trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD'))
            <= l_min_start_date AND
            trunc(to_date(substr(nvl(p_aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'))
            >= l_max_end_date  THEN

            hr_utility.set_message(8303,'PQP_230134_EIT_OVERLAP_ROWS');
            hr_utility.raise_error;

         END IF;

      END IF;

      --validate that the Date From is equal to or greater than the hire date
      OPEN c_get_hire_date(l_eff_date);
      FETCH c_get_hire_date INTO l_hire_date;
      CLOSE c_get_hire_date;
      IF l_hire_date > trunc(to_date(substr(p_aei_information1,1,10),'YYYY/MM/DD')) THEN
         hr_utility.set_message(8303,'PQP_230055_DATE_FRM_BEF_HIRE');
         hr_utility.set_message_token(8303,'HIREDATE',to_char(l_hire_date));
         hr_utility.raise_error;
      END IF;


END IF;

END chk_dup_asg_info_row_upd;

--
-- Funtion to get the prorated value of ptpn
--
FUNCTION get_vop
          (p_assignment_id      IN per_all_assignments_f.assignment_id%TYPE
          ,p_date_earned        IN DATE
          ,p_business_group_id  IN pqp_pension_types_f.business_group_id%TYPE
          ,p_pension_type_id    IN pqp_pension_types_f.pension_type_id%TYPE
          ,p_vop               OUT NOCOPY VARCHAR2
          ,p_error_message     OUT NOCOPY VARCHAR2
         ) RETURN NUMBER IS

--cursor to fetch the pay period start and end dates
--for the particular assignment
CURSOR c_get_period_dates IS
SELECT ptp.start_date,ptp.end_date
  FROM per_all_assignments_f asg
      ,per_time_periods ptp
WHERE  asg.assignment_id = p_assignment_id
  AND  asg.payroll_id    = ptp.payroll_id
  AND  p_date_earned BETWEEN ptp.start_date
  AND  ptp.end_date;

--
-- Cursor to get the start date for the active asg
--
CURSOR c_get_assign_start_date(c_start_date in date
                              ,c_end_date   in date) IS
SELECT min(asg.effective_start_date)
      ,max(asg.effective_end_date)
  FROM per_assignments_f asg
      ,per_assignment_status_types past
 WHERE asg.assignment_status_type_id = past.assignment_status_type_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.effective_start_date <= trunc(c_end_date)
   AND nvl(asg.effective_end_date, trunc(c_end_date)) >= trunc(c_start_date)
   AND asg.assignment_id = p_assignment_id
   group by asg.assignment_id;

CURSOR c_vop_current (c_st_dt IN DATE
                     ,c_ed_dt IN DATE ) IS
 --
 -- Rows that start in the current period
 --
 SELECT fnd_number.canonical_to_number(nvl(aei_information5,'1'))    VOP
       ,TRUNC(fnd_date.canonical_to_date(aei_information1)) St_Dt
       ,TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt)) Ed_Dt
  FROM per_assignment_extra_info
 WHERE assignment_id            = p_assignment_id
   AND information_type         = 'NL_ABP_PAR_INFO'
   AND aei_information_category = 'NL_ABP_PAR_INFO'
   AND TRUNC(fnd_date.canonical_to_date(aei_information1))
       BETWEEN c_st_dt AND c_ed_dt
UNION
 --
 -- Rows that end in the current period
 --
 SELECT fnd_number.canonical_to_number(nvl(aei_information5,'1'))    VOP
       ,TRUNC(fnd_date.canonical_to_date(aei_information1)) St_Dt
       ,TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt)) Ed_Dt
  FROM per_assignment_extra_info
 WHERE assignment_id            = p_assignment_id
   AND information_type         = 'NL_ABP_PAR_INFO'
   AND aei_information_category = 'NL_ABP_PAR_INFO'
   AND TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt))
       BETWEEN c_st_dt AND c_ed_dt
UNION
 --
 -- Rows that neither start or end in the current period
 -- but the data in the EIT is valid for the current period
 --
 SELECT fnd_number.canonical_to_number(nvl(aei_information5,'1'))    VOP
       ,TRUNC(fnd_date.canonical_to_date(aei_information1)) St_Dt
       ,TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt)) Ed_Dt
  FROM per_assignment_extra_info
 WHERE assignment_id            = p_assignment_id
   AND information_type         = 'NL_ABP_PAR_INFO'
   AND aei_information_category = 'NL_ABP_PAR_INFO'
   AND c_ed_dt BETWEEN TRUNC(fnd_date.canonical_to_date(aei_information1))
                   AND TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt))
ORDER BY st_dt;

-- Bug# 6506736 Start
CURSOR c_vop_current_or (c_st_dt IN DATE
                        ,c_ed_dt IN DATE ) IS
 --
 -- Rows that start in the current period
 --
SELECT fnd_number.canonical_to_number(nvl(aei_information23,'1'))       VOP
       ,TRUNC(fnd_date.canonical_to_date(aei_information1))              St_Dt
       ,TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt)) Ed_Dt
  FROM per_assignment_extra_info aei,
       pqp_pension_types_f pty
 WHERE assignment_id            = p_assignment_id
   AND aei_information3         = p_pension_type_id
   AND pty.pension_type_id      = fnd_number.canonical_to_number(aei.aei_information3)
   AND pension_sub_category IN ('PPP'       ,'OPNP'    ,'OPNP_65'
                               ,'OPNP_AOW'  ,'OPNP_W25','OPNP_W50', 'AAOP'
					 ,'FPU_B', 'FPU_C', 'FPU_E', 'FPU_R', 'FPU_S', 'FPU_T')
   AND c_ed_dt BETWEEN pty.effective_start_date AND NVL(pty.effective_end_date,to_date('31/12/4712','DD/MM/YYYY'))
   AND aei_information23 IS NOT NULL
   AND information_type         = 'NL_ABP_PI'
   AND aei_information_category = 'NL_ABP_PI'
   AND TRUNC(fnd_date.canonical_to_date(aei_information1))
       BETWEEN c_st_dt AND c_ed_dt
UNION
 --
 -- Rows that end in the current period
 --
 SELECT fnd_number.canonical_to_number(nvl(aei_information23,'1'))       VOP
       ,TRUNC(fnd_date.canonical_to_date(aei_information1))              St_Dt
       ,TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt)) Ed_Dt
  FROM per_assignment_extra_info aei,
       pqp_pension_types_f pty
 WHERE assignment_id            = p_assignment_id
   AND aei_information3         = p_pension_type_id
   AND pty.pension_type_id      = fnd_number.canonical_to_number(aei.aei_information3)
   AND pension_sub_category in ('PPP'       ,'OPNP'    ,'OPNP_65'
                               ,'OPNP_AOW'  ,'OPNP_W25','OPNP_W50', 'AAOP'
					 ,'FPU_B', 'FPU_C', 'FPU_E', 'FPU_R', 'FPU_S', 'FPU_T')
   AND c_ed_dt BETWEEN pty.effective_start_date AND NVL(pty.effective_end_date ,to_date('31/12/4712','DD/MM/YYYY'))
   AND aei_information23 IS NOT NULL
   AND information_type         = 'NL_ABP_PI'
   AND aei_information_category = 'NL_ABP_PI'
   AND TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt))
  BETWEEN c_st_dt AND c_ed_dt
UNION
 --
 -- Rows that neither start or end in the current period
 -- but the data in the EIT is valid for the current period
 --
 SELECT fnd_number.canonical_to_number(nvl(aei_information23,'1'))    VOP
       ,TRUNC(fnd_date.canonical_to_date(aei_information1)) St_Dt
       ,TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt)) Ed_Dt
  FROM per_assignment_extra_info aei,
       pqp_pension_types_f pty
 WHERE assignment_id            = p_assignment_id
   AND aei_information3         = p_pension_type_id
   AND pty.pension_type_id      = fnd_number.canonical_to_number(aei.aei_information3)
   AND pension_sub_category in ('PPP'       ,'OPNP'    ,'OPNP_65'
                               ,'OPNP_AOW'  ,'OPNP_W25','OPNP_W50', 'AAOP'
					 ,'FPU_B', 'FPU_C', 'FPU_E', 'FPU_R', 'FPU_S', 'FPU_T')
   AND c_ed_dt BETWEEN pty.effective_start_date and NVL(pty.effective_end_date ,to_date('31/12/4712','DD/MM/YYYY'))
   AND aei_information23 IS NOT NULL
   AND information_type         = 'NL_ABP_PI'
   AND aei_information_category = 'NL_ABP_PI'
  AND c_ed_dt BETWEEN TRUNC(fnd_date.canonical_to_date(aei_information1))
                   AND TRUNC(NVL(fnd_date.canonical_to_date(aei_information2),c_ed_dt))
ORDER BY st_dt;
-- Bug# 6506736 End

l_period_start_date   DATE;
l_period_end_date     DATE;
l_min_start_date      DATE;
l_max_end_date        DATE;
l_effective_date      DATE;
l_days_in_pp          NUMBER;
l_payroll_days        NUMBER;
l_min_vop_start       DATE;
l_max_vop_end         DATE;
l_min_vop_start_or    DATE;
l_max_vop_end_or      DATE;
l_vop_num             NUMBER;
l_vop_num_or          NUMBER;

BEGIN

hr_utility.set_location('entered get_proration_factor',10);


--
-- Fetch the pay period start and end dates
--
 OPEN c_get_period_dates;
FETCH c_get_period_dates INTO l_period_start_date
                             ,l_period_end_date;
CLOSE c_get_period_dates;

hr_utility.set_location('start date of pay period : '||l_period_start_date,30);
hr_utility.set_location('end date of pay period : '||l_period_end_date,40);

--
-- Fetch the greater of the assigment start date or the period start date
--
OPEN c_get_assign_start_date(c_start_date => l_period_start_date
                            ,c_end_date   => l_period_end_date);
FETCH c_get_assign_start_date INTO l_effective_date,l_max_end_date;

IF c_get_assign_start_date%FOUND THEN
   CLOSE c_get_assign_start_date;
ELSE
   CLOSE c_get_assign_start_date;
   p_vop := '0';
   RETURN 0;
END IF;

l_min_start_date := GREATEST(l_effective_date,trunc(l_period_start_date));
l_max_end_date   := LEAST(l_max_end_date,trunc(l_period_end_date));

hr_utility.set_location('l_min_start_date : '||l_min_start_date,50);
hr_utility.set_location('l_max_end_date   : '||l_max_end_date,50);

--
-- Calcualte the total number of days in the pay period
--
l_payroll_days    := (trunc(l_period_end_date)
                    - trunc(l_period_start_date)) + 1;

--
-- Find the number of days the assignments has been effective in the
-- current period
--
l_days_in_pp := nvl(l_max_end_date,  trunc(l_period_end_date  ))
              - nvl(l_min_start_date,trunc(l_period_start_date)) + 1;

hr_utility.set_location('days in pay period : '||l_payroll_days,55);
hr_utility.set_location('days asg valid :     '||l_days_in_pp,57);

l_min_vop_start      := NULL;
l_max_vop_end        := NULL;
l_min_vop_start_or   := NULL;
l_max_vop_end_or     := NULL;
l_vop_num            := NULL;
l_vop_num_or         := NULL;

--
-- Calculate the normal VOP
--
FOR l_vop_current_rec IN c_vop_current (nvl(l_min_start_date,trunc(l_period_start_date))
                                       ,nvl(l_max_end_date,  trunc(l_period_end_date )))
LOOP

IF l_vop_current_rec.st_dt < NVL(l_min_vop_start,TO_DATE('31/12/4712','DD/MM/YYYY')) THEN
   l_min_vop_start := GREATEST(l_vop_current_rec.st_dt,nvl(l_min_start_date,trunc(l_period_start_date)));
END IF;

l_max_vop_end := LEAST(l_vop_current_rec.ed_dt,nvl(l_max_end_date,trunc(l_period_end_date )));

l_vop_num := NVL(l_vop_num,0) + (l_vop_current_rec.vop *
                               ((l_max_vop_end - GREATEST(l_vop_current_rec.st_dt,nvl(l_min_start_date,trunc(l_period_start_date)))) + 1 ));
END LOOP;

--
-- Calculate the override VOP
--
FOR l_vop_current_rec_or IN c_vop_current_or (nvl(l_min_start_date,trunc(l_period_start_date))
                                             ,nvl(l_max_end_date,  trunc(l_period_end_date )))
LOOP

IF l_vop_current_rec_or.st_dt < NVL(l_min_vop_start_or,TO_DATE('31/12/4712','DD/MM/YYYY')) THEN
   l_min_vop_start_or := GREATEST(l_vop_current_rec_or.st_dt,nvl(l_min_start_date,trunc(l_period_start_date)));
END IF;

l_max_vop_end_or := LEAST(l_vop_current_rec_or.ed_dt,nvl(l_max_end_date,trunc(l_period_end_date )));

l_vop_num_or := NVL(l_vop_num_or,0) + (l_vop_current_rec_or.vop *
                               ((l_max_vop_end_or - GREATEST(l_vop_current_rec_or.st_dt,nvl(l_min_start_date,trunc(l_period_start_date)))) + 1 ));
END LOOP;

IF l_vop_num_or IS NOT NULL THEN

   l_vop_num_or := TRUNC(l_vop_num_or/l_days_in_pp,4);
   p_vop        := fnd_number.number_to_canonical(l_vop_num_or);
   RETURN 0;

ELSIF l_vop_num IS NOT NULL THEN

   l_vop_num := TRUNC(l_vop_num/l_days_in_pp,4);
   p_vop     := fnd_number.number_to_canonical(l_vop_num);
   RETURN 0;

ELSIF l_vop_num IS NULL AND l_vop_num_or IS NULL THEN

   -- Could not find any data
   -- VOP information is not entered for this period
   -- Assignment is still valid so return vop as 1
   p_vop := '1';
   RETURN 0;
END IF;


END get_vop;

--
-- ------------------------------------------------------------------------
-- |------------------< get_assignment_attribute >-------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION  get_assignment_attribute
          (p_assignment_id     in  per_all_assignments_f.assignment_id%TYPE
          ,p_date_earned       in  date
          ,p_business_group_id in  pqp_pension_types_f.business_group_id%TYPE
          ,p_pension_type_id   in  pqp_pension_types_f.pension_type_id%TYPE
          ,p_attrib_name       in  varchar2
          ,p_attrib_value      out NOCOPY varchar2
          ,p_error_message     out NOCOPY varchar2
         )

RETURN number IS

type t_asg_extra_info is table of per_assignment_extra_info%rowtype index by Binary_Integer;

g_asg_extra_info_rec        t_asg_extra_info;

--new record structure for fetching the override for salary,basis,value and kind of
--participation
g_asg_extra_info_rec1        t_asg_extra_info;

l_ret_value          number := 0; --return
l_is_ptype_valid     number;
l_pen_type_name      pqp_pension_types_f.pension_type_name%type;
l_asg_extra_info_id  per_assignment_extra_info.assignment_extra_info_id%type;
l_asg_extra_info_id1 per_assignment_extra_info.assignment_extra_info_id%type;
l_override_found     number := 0;
l_vop_ret_val        NUMBER;

--Cursor to check if the pension type is valid on the date earned
Cursor c_is_ptype_valid Is
   Select 1
      from pqp_pension_types_f pty
      where pty.pension_type_id   = p_pension_type_id
        and pty.business_group_id = p_business_group_id
        and p_date_earned between pty.effective_start_date and pty.effective_end_date;

--Cursor to find the pension type name from the id
Cursor c_find_pen_type_name Is
Select pension_type_name
  from pqp_pension_types_f
 where pension_type_id = p_pension_type_id
  and business_group_id = p_business_group_id;

--Cursor to find if the pension type has a valid information row at the --assignment level
-- if so qry up the asg extra info id
CURSOR c_get_asg_extra_info_id IS
   Select paei.assignment_extra_info_id
     from per_assignment_extra_info paei,
          pqp_pension_types_f pty
     where paei.information_type = 'NL_ABP_PI'
       and paei.aei_information_category = 'NL_ABP_PI'
       and paei.aei_information3 = to_char(p_pension_type_id)
       and paei.assignment_id    = p_assignment_id
       and p_date_earned between trunc(to_date(substr(paei.aei_information1,1,10),'YYYY/MM/DD'))
                             and trunc(to_date(substr(nvl(paei.aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'));

-- cursor to get the data in per_assignment_extra_info for a particular --asg_extra_info_id
Cursor c_get_asg_extra_info(c_asg_extra_info_id in per_assignment_extra_info.assignment_extra_info_id%type) Is
   Select *
     from per_assignment_extra_info
   where assignment_extra_info_id = c_asg_extra_info_id;

--cursor to get the assignment extra info id for the NL_ABP_PAR_INFO context
CURSOR c_get_extra_info_id IS
 SELECT assignment_extra_info_id
  FROM  per_assignment_extra_info
 WHERE  assignment_id = p_assignment_id
  AND   information_type = 'NL_ABP_PAR_INFO'
  AND   aei_information_category = 'NL_ABP_PAR_INFO'
  AND   p_date_earned BETWEEN trunc(fnd_date.canonical_to_date(aei_information1))
  AND   trunc(nvl(fnd_date.canonical_to_date(aei_information2),hr_api.g_eot));

BEGIN

 --if the attribute is stored in the participation EIT then
 --check first in the participation and salary information EIT
   IF p_attrib_name IN ('KIND_OF_PARTICIPATION','VALUE_OF_PARTICIPATION',
                        'OVERRIDE_ANNUAL_PENSION_SALARY','PENSION_SALARY_OVERRIDE_REASON'
                       ,'OVERRIDE_PENSION_BASIS','PENSION_BASIS_OVERRIDE_REASON'
                       ) THEN
      hr_utility.set_location('searching in the participation EIT',10);
      OPEN c_get_extra_info_id;
      FETCH c_get_extra_info_id INTO l_asg_extra_info_id1;
      IF c_get_extra_info_id%FOUND THEN
          CLOSE c_get_extra_info_id;
          hr_utility.set_location('found a row in the participation EIT',20);
          OPEN c_get_asg_extra_info(l_asg_extra_info_id1);
          FETCH c_get_asg_extra_info INTO g_asg_extra_info_rec1(l_asg_extra_info_id1);
          CLOSE c_get_asg_extra_info;

          If p_attrib_name = 'KIND_OF_PARTICIPATION' THEN
             p_attrib_value
             := g_asg_extra_info_rec1(l_asg_extra_info_id1).aei_information4;

          Elsif p_attrib_name = 'VALUE_OF_PARTICIPATION' THEN

            l_vop_ret_val := get_vop
             (p_assignment_id      => p_assignment_id
             ,p_date_earned        => p_date_earned
             ,p_business_group_id  => p_business_group_id
             ,p_pension_type_id    => p_pension_type_id
             ,p_vop                => p_attrib_value
             ,p_error_message      => p_error_message);

          Elsif p_attrib_name = 'OVERRIDE_ANNUAL_PENSION_SALARY' THEN
             p_attrib_value
             := g_asg_extra_info_rec1(l_asg_extra_info_id1).aei_information6;

          Elsif p_attrib_name = 'PENSION_SALARY_OVERRIDE_REASON' THEN
             p_attrib_value
             := g_asg_extra_info_rec1(l_asg_extra_info_id1).aei_information7;

          Elsif p_attrib_name = 'OVERRIDE_PENSION_BASIS' THEN
             p_attrib_value
             := g_asg_extra_info_rec1(l_asg_extra_info_id1).aei_information8;

          Elsif p_attrib_name = 'PENSION_BASIS_OVERRIDE_REASON' THEN
             p_attrib_value
             := g_asg_extra_info_rec1(l_asg_extra_info_id1).aei_information9;
          End If;

     ELSE
          CLOSE c_get_extra_info_id;
          return 1;
     END IF;

  --else search for the attribute in the ABP Pension Information EIT
  ELSE
    -- find the pension type name from the pension type id
       OPEN c_find_pen_type_name;
       FETCH c_find_pen_type_name INTO l_pen_type_name;
       If c_find_pen_type_name%NOTFOUND THEN
          p_error_message := 'Unable to find the details for the Pension Type';
          p_error_message := p_error_message||'. Pension Type Id =  '||to_char(p_pension_type_id);
          CLOSE c_find_pen_type_name;
          return 1;
       Else
          CLOSE c_find_pen_type_name;
       End If;

   -- check to see that the pension type is valid on the date earned
      OPEN c_is_ptype_valid;
      FETCH c_is_ptype_valid INTO l_is_ptype_valid;
      If c_is_ptype_valid%NOTFOUND THEN
         p_error_message := 'Pension Type : '||l_pen_type_name;
         p_error_message:= p_error_message||' is not valid as of '||to_char(p_date_earned);
         CLOSE c_is_ptype_valid;
         return 1;
      Else
         CLOSE c_is_ptype_valid;
      End If;

 -- check to see if there is a valid asg extra info row for the current PT
 -- if such a row exists, the cursor returns the assignment_extra_info_id
    OPEN c_get_asg_extra_info_id;
    FETCH c_get_asg_extra_info_id INTO l_asg_extra_info_id;
    -- no row is found for the pension type
    -- or the row has been end-dated
    If c_get_asg_extra_info_id%NOTFOUND THEN
       p_error_message := 'No overrides have been specified at the Assignment ';
       p_error_message := p_error_message ||'Extra Information for Pension Type : '||l_pen_type_name;
       CLOSE c_get_asg_extra_info_id;
       return 1;

    -- a row has been found, return it to the record type
    Else
       CLOSE c_get_asg_extra_info_id;
       OPEN c_get_asg_extra_info(l_asg_extra_info_id);
       FETCH c_get_asg_extra_info INTO g_asg_extra_info_rec(l_asg_extra_info_id);
       CLOSE c_get_asg_extra_info;

       -- now FETCH the field required, depending on the input attribute name
       If p_attrib_name = 'DATE_FROM' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information1;

       Elsif p_attrib_name = 'DATE_TO' THEN
          p_attrib_value
          := nvl(g_asg_extra_info_rec(l_asg_extra_info_id).aei_information2,'4712/12/31');

       Elsif p_attrib_name = 'PENSION_TYPE_NAME' THEN
          p_attrib_value
          := l_pen_type_name;

       Elsif p_attrib_name = 'PARTICIPATE_END_REASON' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information4;

       /*Elsif p_attrib_name = 'KIND_OF_PARTICIPATION' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information5;

       Elsif p_attrib_name = 'VALUE_OF_PARTICIPATION' THEN

            l_vop_ret_val := get_vop
             (p_assignment_id      => p_assignment_id
             ,p_date_earned        => p_date_earned
             ,p_business_group_id  => p_business_group_id
             ,p_vop                => p_attrib_value
             ,p_error_message      => p_error_message);

       Elsif p_attrib_name = 'OVERRIDE_ANNUAL_PENSION_SALARY' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information7;

       Elsif p_attrib_name = 'PENSION_SALARY_OVERRIDE_REASON' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information8;

       Elsif p_attrib_name = 'OVERRIDE_PENSION_BASIS' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information9;

       Elsif p_attrib_name = 'PENSION_BASIS_OVERRIDE_REASON' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information10; */

       Elsif p_attrib_name = 'OVERRIDE_EE_CONTRIBUTION' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information11;

       Elsif p_attrib_name = 'EE_CONTRIB_OVERRIDE_REASON' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information12;

       Elsif p_attrib_name = 'EE_CONTRIB_DEDN_MTHD' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information13;

       Elsif p_attrib_name = 'EE_CONTRIB_VALUE' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information14;

       Elsif p_attrib_name = 'ER_CONTRIB_DEDN_MTHD' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information15;

       Elsif p_attrib_name = 'ER_CONTRIB_VALUE' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information16;

       Elsif p_attrib_name = 'OVERRIDE_EE_ANNUAL_LIMIT' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information17;

       Elsif p_attrib_name = 'OVERRIDE_ER_ANNUAL_LIMIT' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information18;

       Elsif p_attrib_name = 'OVERRIDE_PENSION_DAYS' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information19;

       Elsif p_attrib_name = 'OVERRIDE_ER_CONTRIBUTION' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information20;

       Elsif p_attrib_name = 'ER_CONTRIB_OVERRIDE_REASON' THEN
          p_attrib_value
          := g_asg_extra_info_rec(l_asg_extra_info_id).aei_information21;

       Else
          p_error_message
          := 'Error occured while Fetching values for Assignment Attributes : ';
          p_error_message := p_error_message ||'Attribute '||p_attrib_name||' is invalid.';
          return 1;
       End If;

    End If;

  End If;
    IF p_attrib_value IS NOT NULL THEN
       return 0;
    ELSE
       return 2;
    END IF;

END get_assignment_attribute;

--
-- ------------------------------------------------------------------------
-- |------------------< get_contribution_percent >----------------------------|
-- ------------------------------------------------------------------------
--


FUNCTION  get_contribution_percent
          ( p_assignment_id      in  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        in  date
           ,p_business_group_id  in  pqp_pension_types_f.business_group_id%TYPE
           ,p_pension_sub_cat    in  pqp_pension_types_f.pension_sub_category%TYPE
           ,p_udt_table_name     in  VARCHAR2
           ,p_column_value       out NOCOPY  number
          )
          RETURN NUMBER IS

 CURSOR  c_get_person_age IS
    SELECT to_char(per.date_of_birth,'RRRR')
    FROM   per_all_people_f per,per_all_assignments_f paa
    WHERE  per.person_id = paa.person_id
    AND    p_date_earned between paa.effective_start_date and paa.effective_end_date
    AND    p_date_earned between per.effective_start_date and per.effective_end_date
    AND    paa.assignment_id = p_assignment_id;

 CURSOR c_get_subcat (c_sub_cat IN VARCHAR2) IS
   SELECT meaning
     FROM fnd_lookup_values
   WHERE  lookup_type = 'PQP_PENSION_SUB_CATEGORY'
     AND  lookup_code = c_sub_cat
     AND  language = 'US'
     AND  nvl(enabled_flag,'N') = 'Y';


  CURSOR c_get_part_st_age IS
   SELECT aei_information3
   FROM   per_assignment_extra_info
   WHERE  p_date_earned  between fnd_date.canonical_to_date(aei_information1)
   AND    fnd_date.canonical_to_date(nvl(aei_information2,fnd_date.date_to_canonical(hr_api.g_eot)))
   AND    assignment_id = p_assignment_id
   AND    aei_information_category = 'NL_ABP_PAR_INFO';


l_person_year_of_birth  VARCHAR2(10);
l_subcat                VARCHAR2(80);
l_part_start_age        NUMBER;
l_return_value          VARCHAR2(50);

BEGIN

    OPEN  c_get_person_age;
    FETCH c_get_person_age into l_person_year_of_birth;
       IF (c_get_person_age%FOUND and l_person_year_of_birth IS NOT NULL) THEN

           hr_utility.set_location(' l_person_year_of_birth is '||l_person_year_of_birth,35);

          OPEN c_get_subcat(p_pension_sub_cat);
          FETCH c_get_subcat INTO l_subcat;
          CLOSE c_get_subcat;

          OPEN c_get_part_st_age;
          FETCH c_get_part_st_age into l_part_start_age;
          CLOSE c_get_part_st_age;

          hr_utility.set_location(' l_subcat is '||l_subcat,40);
          hr_utility.set_location(' l_part_start_age is '||l_part_start_age,50);


          IF l_subcat IS NOT NULL THEN

             l_return_value :=
             hruserdt.get_table_value
             (
              p_bus_group_id    => p_business_group_id
             ,p_table_name      => p_udt_table_name
             ,p_col_name        => l_subcat||'-'||l_part_start_age
             ,p_row_value       => l_person_year_of_birth
             ,p_effective_date  => p_date_earned
             );

            l_return_value := NVL(l_return_value,trim(to_char(0,'9')));

            hr_utility.set_location(' l_return_value is '||l_return_value,50);

            p_column_value := fnd_number.canonical_to_number(l_return_value);

            hr_utility.set_location(' p_column_value is '||p_column_value,60);

          END IF;-- subcat check

       END IF;--c_get_person_age%FOUND
       CLOSE c_get_person_age;

       RETURN 0;

      EXCEPTION

      WHEN NO_DATA_FOUND THEN
        hr_utility.set_location('NO_DATA_FOUND for UDT : ', 90);

        p_column_value := 0;

        RETURN 1;

        WHEN OTHERS THEN

             hr_utility.set_location('sqlcode '||SQLCODE, 70);
             hr_utility.set_location('sqlerr '||SQLERRM, 80);
             hr_utility.set_location('error occurred while getting values for UDT ', 90);
             p_column_value := 0;

         RETURN 1;

END get_contribution_percent;


-- ------------------------------------------------------------------------
-- |-----------------------< chk_pt_eligibility >--------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION  chk_pt_eligibility
          ( p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        IN  DATE
           ,p_business_group_id  IN  pqp_pension_types_f.business_group_id%TYPE
           ,p_pt_id              IN  NUMBER
           ,p_hr_org_org_id      IN  NUMBER
           ,p_le_org_id          IN  NUMBER)
RETURN NUMBER IS

--
-- Cursor to find the validity of a PT at the HR org level
-- Note that this qry considers the "Valid" and
-- "Applicable to all EE" flags
--
CURSOR c_pt_valid_hr_org IS
SELECT 1
  FROM hr_organization_information hoi
 WHERE hoi.org_information_context      = 'PQP_NL_ABP_PT'
   AND hoi.org_information3             = TO_CHAR(p_pt_id)
   AND NVL(hoi.org_information6,'N')    = 'Y'
   AND NVL(hoi.org_information7,'N')    = 'Y'
   AND hoi.organization_id              = p_hr_org_org_id
   AND p_date_earned BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
                         AND fnd_date.canonical_to_date(NVL(hoi.org_information2,
                             fnd_date.date_to_canonical(hr_api.g_eot)));
--
-- Cursor to find the validity of a PT at the Legal ER Level
-- Note that this qry considers the "Valid" and
-- "Applicable to all EE" flags
-- Query also checks to ensure that the PT is also valid at the
-- HR Org level OR no information is entered at the HR org level
--

CURSOR c_pt_valid_le IS
SELECT 1
  FROM hr_organization_information hoi
 WHERE hoi.org_information_context      = 'PQP_NL_ABP_PT'
   AND hoi.org_information3             = TO_CHAR(p_pt_id)
   AND NVL(hoi.org_information6,'N')    = 'Y'
   AND NVL(hoi.org_information7,'N')    = 'Y'
   AND hoi.organization_id              = p_le_org_id
   AND p_date_earned BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
                         AND fnd_date.canonical_to_date(NVL(hoi.org_information2,
                             fnd_date.date_to_canonical(hr_api.g_eot)))
   AND NOT EXISTS ( SELECT 1
                      FROM hr_organization_information hoi
                     WHERE hoi.org_information_context      = 'PQP_NL_ABP_PT'
                       AND hoi.org_information3             = TO_CHAR(p_pt_id)
                       AND (   NVL(hoi.org_information6,'N')= 'N'
                            OR NVL(hoi.org_information7,'N')= 'N')
                       AND hoi.organization_id              = p_hr_org_org_id
                       AND p_date_earned BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
                        AND fnd_date.canonical_to_date(NVL(hoi.org_information2,
                            fnd_date.date_to_canonical(hr_api.g_eot))));
l_pt_valid NUMBER;
l_ret_val  NUMBER;

BEGIN

--
-- Note that this function returns 0 if the EE assignment is NOT ELIGIBLE for the PT
-- Note that this function returns 1 if the EE assignment is ELIGIBLE for the PT
--
OPEN c_pt_valid_hr_org;
FETCH c_pt_valid_hr_org INTO l_pt_valid;
IF c_pt_valid_hr_org%FOUND THEN
   --
   -- PT is valid at the HR Org and EE can contribute towards the PT
   --
   l_ret_val := 1;

ELSIF c_pt_valid_hr_org%NOTFOUND THEN
   --
   -- Check if the PT is valid at the Legal ER
   --
   OPEN c_pt_valid_le;
   FETCH c_pt_valid_le INTO l_pt_valid;

   IF c_pt_valid_le%FOUND THEN
   --
   -- PT is valid at the HR Org and Legal ER and the EE
   -- can contribute towards the PT
   --
      l_ret_val := 1;
   ELSE
   --
   -- PT is not valid at the HR Org or Legal ER and the EE
   -- cannot contribute towards the PT
   --
      l_ret_val := 0;
   END IF;

   CLOSE c_pt_valid_le;

END IF;

CLOSE c_pt_valid_hr_org;

RETURN l_ret_val;

EXCEPTION
WHEN OTHERS THEN
   RETURN 0;

END chk_pt_eligibility;

--
-- ------------------------------------------------------------------------
-- |------------------< get_abp_org_contrib_percent >----------------------|
-- ------------------------------------------------------------------------
--
FUNCTION  get_abp_org_contrib_percent
          ( p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        IN  DATE
           ,p_business_group_id  IN  pqp_pension_types_f.business_group_id%TYPE
           ,p_pension_type_id    IN  pqp_pension_types_f.pension_type_id%TYPE
           ,p_ee_contrib         OUT NOCOPY  NUMBER
           ,p_er_contrib         OUT NOCOPY  NUMBER
           ,p_app_to_all_ee      IN  VARCHAR2)
RETURN NUMBER IS

--
-- Cursor to find the contrib% for a given org id
-- Note that this fetches the values for the
-- pension types that are valid. The applicable to
-- all EE's flag does not matter as the PT is attached
-- at the assignment level.
--
CURSOR c_get_contribution
       (c_org_id IN hr_organization_information.organization_id%TYPE) IS
SELECT fnd_number.canonical_to_number(NVL(hoi.org_information4,'-1'))
      ,fnd_number.canonical_to_number(NVL(hoi.org_information5,'-1'))
  FROM hr_organization_information hoi
 WHERE hoi.org_information_context      = 'PQP_NL_ABP_PT'
   AND hoi.org_information3             = TO_CHAR(p_pension_type_id)
   AND hoi.org_information6             = 'Y'
   AND hoi.organization_id              = c_org_id
   AND p_date_earned BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
                         AND fnd_date.canonical_to_date(NVL(hoi.org_information2,
                             fnd_date.date_to_canonical(hr_api.g_eot)));

--
-- Cursor to find the org id,payroll and legal ER from the assignment
--
CURSOR c_find_org IS
SELECT asg.organization_id
      ,asg.payroll_id
      ,fnd_number.canonical_to_number(ppf.prl_information1)
  FROM per_all_assignments_f asg,
       pay_payrolls_f ppf
 WHERE asg.assignment_id = p_assignment_id
   AND asg.payroll_id = ppf.payroll_id
   AND TRUNC(p_date_earned) BETWEEN asg.effective_start_date
                                AND asg.effective_end_date
   AND TRUNC(p_date_earned) BETWEEN ppf.effective_start_date
                                AND ppf.effective_end_date
   AND asg.business_group_id = p_business_group_id;

--
-- Cursor to fetch contribution values from the Pension Type
--
CURSOR c_pt_val IS
SELECT fnd_number.canonical_to_number(nvl(ee_contribution_percent,'0'))
      ,fnd_number.canonical_to_number(nvl(er_contribution_percent,'0'))
 FROM pqp_pension_types_f
WHERE pension_type_id = p_pension_type_id
  AND p_date_earned BETWEEN effective_start_date
                        AND effective_end_date;

l_hr_org_id             NUMBER;
l_legal_er_org_id       NUMBER;
l_payroll_id            NUMBER;
l_pt_er_perc            NUMBER;
l_pt_ee_perc            NUMBER;
l_le_ee_perc            NUMBER;
l_le_er_perc            NUMBER;
l_proc_name             VARCHAR2(30) := 'get_abp_org_contrib_percent';

BEGIN

   hr_utility.set_location(' Entering '||l_proc_name,10);
   --
   -- Get the Org id, Legal ER org id and Payroll id
   --
   OPEN c_find_org;
   FETCH c_find_org
   INTO l_hr_org_id,l_payroll_id,l_legal_er_org_id;

   CLOSE c_find_org;

   hr_utility.set_location('... The HR Org org id is   -- '||l_hr_org_id,10);
   hr_utility.set_location('... The payroll id is      -- '||l_payroll_id,15);
   hr_utility.set_location('... The legal ER org id is -- '||l_legal_er_org_id,20);

   --
   -- Derive the contribution values from the pension type
   --
   hr_utility.set_location('... Fetching contrib values from the PT',25);

   OPEN c_pt_val;
   FETCH c_pt_val
   INTO l_pt_ee_perc
       ,l_pt_er_perc;

   IF c_pt_val%NOTFOUND THEN
      l_pt_ee_perc := 0;
      l_pt_er_perc := 0;
   END IF;

   CLOSE c_pt_val;

   --
   -- Initialize EE and ER contribution values
   --
   p_ee_contrib := -1;
   p_er_contrib := -1;

   --
   -- Check if valid values exist at the HR Org Level
   --
    OPEN c_get_contribution(l_hr_org_id);
   FETCH c_get_contribution
    INTO p_ee_contrib
        ,p_er_contrib;
   CLOSE c_get_contribution;

   --
   -- Check if valid values exist at the Legal ER Level
   -- This condition also caters to the fact that either
   -- the EE or ER percentage was left blank at the HR Org level
   -- and we need to fetch it from the Legal ER level.
   -- Note -- The definition of an legal employer is -- The org
   -- attached to the payroll definition of the EE assignment
   --
   IF (p_ee_contrib = -1 OR p_er_contrib = -1) THEN

      OPEN c_get_contribution(l_legal_er_org_id);
     FETCH c_get_contribution
      INTO l_le_ee_perc
          ,l_le_er_perc;
      --
      -- Assign the values only if these were not derived
      -- previously from the HR Org.
      --
      IF p_ee_contrib = -1 AND l_le_ee_perc IS NOT NULL THEN
         p_ee_contrib := l_le_ee_perc;
      END IF;

      IF p_er_contrib = -1 AND l_le_er_perc IS NOT NULL THEN
         p_er_contrib := l_le_er_perc;
      END IF;

      CLOSE c_get_contribution;

   END IF;


   --
   -- All levels -- HR Org and Legal ER have been searched for
   -- a valid contribution percentage. Since it is not available
   -- at either levels , derive the value from the Pension Type.
   -- Assign the percentage only if it has not been previously
   -- derived at the HR Org or Legal ER levels
   --
   IF p_ee_contrib = -1 THEN
      p_ee_contrib := l_pt_ee_perc;
   END IF;

   IF p_er_contrib = -1 THEN
      p_er_contrib := l_pt_er_perc;
   END IF;

RETURN 0;

EXCEPTION WHEN OTHERS THEN
   p_ee_contrib := 0;
   p_er_contrib := 0;
   RETURN 1;

END get_abp_org_contrib_percent;
--
-- ------------------------------------------------------------------------
-- |------------------< chk_abp_scheme_created >---------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION chk_abp_scheme_created
    (p_date_earned        IN  DATE
    ,p_business_group_id  IN  pqp_pension_types_f.business_group_id%TYPE
    ,p_pension_sub_cat    IN  pqp_pension_types_f.pension_sub_category%TYPE
    ,p_pension_type_id    OUT NOCOPY  NUMBER)

RETURN NUMBER IS
--
-- This function checks to see if an ABP Pension scheme is created
-- for a particular ABP Sub Cat/BG combination. If the scheme is created,
-- it returns the valid pension type id for the scheme
--
CURSOR c_abp_schm IS
SELECT fnd_number.canonical_to_number(eei_information2) pty_id
  FROM pay_element_type_extra_info pete,
       pay_element_types_f pet
 WHERE pete.information_type = 'PQP_NL_ABP_DEDUCTION'
   AND pete.element_type_id = pet.element_type_id
   AND p_date_earned BETWEEN pet.effective_start_date
                         AND pet.effective_end_date
   AND pet.business_group_id  = p_business_group_id
   AND pete.eei_information12 = p_pension_sub_cat
   AND p_date_earned between TO_DATE(pete.eei_information10,'DD/MM/YYYY')
                         and TO_DATE(pete.eei_information11,'DD/MM/YYYY');

l_ret_val NUMBER;

BEGIN

OPEN c_abp_schm ;

FETCH c_abp_schm INTO p_pension_type_id;

   IF c_abp_schm%FOUND THEN
      l_ret_val := 1;
   ELSE
      l_ret_val := 0;
   END IF;

CLOSE c_abp_schm;

RETURN l_ret_val;

END chk_abp_scheme_created;

-- ----------------------------------------------------------------------------
-- |--------------------< get_abp_late_hire_indicator >------------------------|
-- ----------------------------------------------------------------------------
--
-- Function is to check if an assignment is a late hire from an ABP perspective
-- this checks if a payroll has been processed effective the current year
-- with a date paid in the prev year. ABP pension salary
-- calculation has issues in such cases.
--
FUNCTION  get_abp_late_hire_indicator
          (p_payroll_action_id IN NUMBER)

RETURN NUMBER IS

l_eff_dt    DATE;
l_dt_earned DATE;

BEGIN

SELECT effective_date, date_earned
  INTO l_eff_dt , l_dt_earned
  FROM pay_payroll_actions
 WHERE payroll_action_id = p_payroll_action_id;

IF to_char(l_eff_dt,'YYYY') <> to_char(l_dt_earned,'YYYY') THEN
   RETURN 1 ;
ELSE
   RETURN 0;
END IF;

END get_abp_late_hire_indicator;


--
-- ------------------------------------------------------------------------
-- |------------------< get_abp_contribution >----------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_abp_contribution
        (p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
        ,p_date_earned        IN  DATE
        ,p_business_group_id  IN  pqp_pension_types_f.business_group_id%TYPE
        ,p_payroll_action_id  IN  NUMBER
        ,p_pension_sub_cat    IN  pqp_pension_types_f.pension_sub_category%TYPE
        ,p_conversion_rule    IN  pqp_pension_types_f.threshold_conversion_rule%TYPE
        ,p_basis_method       IN  pqp_pension_types_f.pension_basis_calc_method%TYPE
        ,p_ee_contrib_type    OUT NOCOPY  NUMBER
        ,p_ee_contrib_value   OUT NOCOPY  NUMBER
        ,p_er_contrib_type    OUT NOCOPY  NUMBER
        ,p_er_contrib_value   OUT NOCOPY  NUMBER
       )
RETURN NUMBER IS

l_org_id                hr_all_organization_units.organization_id%TYPE;
l_payroll_id            NUMBER;
l_legal_er_org_id       NUMBER;
l_ret_value             NUMBER := 0;
l_asg_ret_value         NUMBER := 0;
l_pension_type_id       NUMBER;
l_ee_contrib_value      NUMBER;
l_er_contrib_value      NUMBER;
l_er_contrib_value_fa   NUMBER;
l_pt_ee_contrib         NUMBER;
l_pt_er_contrib         NUMBER;
l_ee_return_value       NUMBER;
l_er_return_value       NUMBER;
l_ee_contrib_type       VARCHAR2(2) := 'PE';
l_er_contrib_type       VARCHAR2(2) := 'PE';
l_ee_age_contribution   VARCHAR2(1);
l_er_age_contribution   VARCHAR2(1);
l_ee_age_contri_value   VARCHAR2(30);
l_er_age_contri_value   VARCHAR2(30);
l_chk_abp_scheme        NUMBER;
l_dummy                 NUMBER;
l_ee_asg_eligible       NUMBER;
l_ee_hr_org_contrib     NUMBER;
l_er_hr_org_contrib     NUMBER;
l_er_le_contrib         NUMBER;
l_ee_le_contrib         NUMBER;
l_cur_ptp               NUMBER;
l_date_earned           DATE;
l_late_hire_ind         NUMBER;
l_abp_sub_cat           VARCHAR2(30);

--
-- Cursor to find the contribution values(% or flat amount)
-- and the contribution type from assignment level information,
-- only if the row is valid on date earned.
--
CURSOR c_get_asg_info (c_pty_id IN NUMBER
                      ,c_date_earned IN DATE) IS
SELECT NVL(paei.aei_information13,'PE'),
           fnd_number.canonical_to_number(NVL(paei.aei_information14,'-1'))
      ,NVL(paei.aei_information15,'PE'),
           fnd_number.canonical_to_number(NVL(paei.aei_information16,'-1'))
  FROM per_assignment_extra_info paei
 WHERE paei.information_type         = 'NL_ABP_PI'
   AND paei.aei_information_category = 'NL_ABP_PI'
   AND paei.assignment_id            = p_assignment_id
   AND fnd_number.canonical_to_number(NVL(aei_information3,-1)) = c_pty_id
   AND c_date_earned between fnd_date.canonical_to_date(paei.aei_information1)
   AND fnd_date.canonical_to_date(NVL(paei.aei_information2,
                                      fnd_date.date_to_canonical(hr_api.g_eot)));

--
-- Cursor to find the contrib% for a given org id
-- Note that this fetches the values for the information
-- with "Applicable to all EE" flag as a param
--
CURSOR c_get_contribution
       (c_org_id IN hr_organization_information.organization_id%TYPE
       ,c_pt_id  IN NUMBER
       ,c_date_earned IN DATE) IS
SELECT fnd_number.canonical_to_number(NVL(hoi.org_information4,'-1'))
      ,fnd_number.canonical_to_number(NVL(hoi.org_information5,'-1'))
  FROM hr_organization_information hoi
 WHERE hoi.org_information_context      = 'PQP_NL_ABP_PT'
   AND hoi.org_information3             = TO_CHAR(c_pt_id)
   AND hoi.org_information6             = 'Y'
   AND NVL(hoi.org_information7,'Y')    = 'Y'
   AND hoi.organization_id              = c_org_id
   AND c_date_earned BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
                         AND fnd_date.canonical_to_date(NVL(hoi.org_information2,
                             fnd_date.date_to_canonical(hr_api.g_eot)));

CURSOR c_pt_dtls (c_pty_id IN NUMBER
                 ,c_date_earned IN DATE) IS
SELECT NVL(pty.ee_age_contribution,'N')
      ,NVL(pty.er_age_contribution,'N')
      ,ee_contribution_percent
      ,er_contribution_percent
  FROM pqp_pension_types_f pty
 WHERE c_date_earned BETWEEN pty.effective_start_date
                         AND pty.effective_end_date
   AND pension_type_id = c_pty_id;

CURSOR c_find_org (c_date_earned IN DATE)IS
SELECT asg.organization_id
      ,asg.payroll_id
      ,fnd_number.canonical_to_number(ppf.prl_information1)
  FROM per_all_assignments_f asg,
       pay_payrolls_f ppf
 WHERE asg.assignment_id = p_assignment_id
   AND asg.payroll_id = ppf.payroll_id
   AND TRUNC(c_date_earned) BETWEEN asg.effective_start_date
                                AND asg.effective_end_date
   AND TRUNC(c_date_earned) BETWEEN ppf.effective_start_date
                                AND ppf.effective_end_date
   AND asg.business_group_id = p_business_group_id;

CURSOR c_cur_ptp (c_eff_dt IN DATE
                 ,c_asg_id IN NUMBER) IS
SELECT LEAST(fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')),125) ptp
  FROM per_assignments_f asg
      ,hr_soft_coding_keyflex target
 WHERE target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND asg.assignment_id   = c_asg_id
   AND target.enabled_flag = 'Y'
   AND TRUNC(c_eff_dt) BETWEEN asg.effective_start_date AND
       asg.effective_end_date;

BEGIN

hr_utility.set_location('Entering...',5);
hr_utility.set_location('...Value of p_assignment_id is     '||p_assignment_id,10);
hr_utility.set_location('...Value of p_date_earned is       '||p_date_earned,15);
hr_utility.set_location('...Value of p_business_group_id is '||p_business_group_id,20);
hr_utility.set_location('...Value of p_pension_sub_cat is   '||p_pension_sub_cat,25);
hr_utility.set_location('...Value of p_conversion_rule is   '||p_conversion_rule,30);
hr_utility.set_location('...Value of p_basis_method is      '||p_basis_method,35);

--
-- Initialize to p_date_earned.
--
l_date_earned := p_date_earned;

--
-- Initialize the variable to the sub cat
--
l_abp_sub_cat := p_pension_sub_cat;

--
-- Check if the date earned is for the month of December
--
IF TO_CHAR(p_date_earned,'MM') = '12' THEN
   --
   -- Check if the EE is hourly or Regular.
   --
    OPEN c_cur_ptp(p_date_earned,p_assignment_id);
   FETCH c_cur_ptp INTO l_cur_ptp;
   CLOSE c_cur_ptp;

   IF l_cur_ptp = 0 THEN
      l_date_earned := ADD_MONTHS(LAST_DAY(p_date_earned),1);
   END IF;

END IF;

--
-- Check if the EE assignment is a late hire for ABP.
-- An EE assignment is a late hire for ABP if it
-- crosses years. For e.g. an EE is hired as of Nov 2006
-- but first payroll is processed in Jan 2007. In such cases
-- for the 2006 calcualtions, percentages from 2007
-- have to be used. This regulation is from ABP (to use
-- the contribution percentages at the moment of payment (date_paid))
--
   l_late_hire_ind := 0;
   l_late_hire_ind := get_abp_late_hire_indicator(p_payroll_action_id);

   IF l_late_hire_ind = 1 THEN

      --
      -- Check if the sub cat is IPH or IPL. These sub cats are
      -- obselete starting from 1 1 2007. But ABP regulation is
      -- that if there are EE assignments making contributions
      -- for IPH and IPL in 2007 ( over 2006), these should
      -- use the AAOP percentages.
      --
      IF p_pension_sub_cat IN ('IPBW_H','IPBW_L') AND
         TRUNC(p_date_earned) < TO_DATE('01/01/2007','DD/MM/YYYY') THEN

         --
         -- Check if IPH or IPL schemes are created as of p_date_earned
         --
         l_chk_abp_scheme := chk_abp_scheme_created
         (p_date_earned        => p_date_earned
         ,p_business_group_id  => p_business_group_id
         ,p_pension_sub_cat    => l_abp_sub_cat
         ,p_pension_type_id    => l_pension_type_id);

         IF l_chk_abp_scheme = 1 THEN
         --
         -- Scheme was created . Check if EE is eligible for the same
         --
         OPEN c_get_asg_info(l_pension_type_id,p_date_earned);
        FETCH c_get_asg_info
         INTO l_ee_contrib_type
             ,l_ee_contrib_value
             ,l_er_contrib_type
             ,l_er_contrib_value;

         IF c_get_asg_info%FOUND THEN
            --
            -- Details for IPH and IPL are entered at the assignment
            -- set the subcat to AAOP so that the contributions
            -- are calculated as per AAOP percentages.
            --
            SELECT effective_date
              INTO l_date_earned
              FROM pay_payroll_actions
             WHERE payroll_action_id = p_payroll_action_id;

            l_abp_sub_cat := 'AAOP';

         ELSE
            --
            -- Check if the EE is eligible for IPL or IPL at the org level
            --
            --
            -- Get the Org id, Legal ER org id and Payroll id
            --
            OPEN c_find_org(p_date_earned);
            FETCH c_find_org
            INTO l_org_id,l_payroll_id,l_legal_er_org_id;
            CLOSE c_find_org;

            hr_utility.set_location('...LH Asg Override not found. Deriving from the org',150);
            hr_utility.set_location('...LH Value of l_org_id is'||l_org_id,160);
            hr_utility.set_location('...LH Value of l_payroll_id is'||l_payroll_id,170);
            hr_utility.set_location('...LH Value of l_legal_er_org_id is'||l_legal_er_org_id,180);

            l_ee_asg_eligible := 0;

            l_ee_asg_eligible :=  chk_pt_eligibility
            ( p_assignment_id      => p_assignment_id
             ,p_date_earned        => p_date_earned
             ,p_business_group_id  => p_business_group_id
             ,p_pt_id              => l_pension_type_id
             ,p_hr_org_org_id      => l_org_id
             ,p_le_org_id          => l_legal_er_org_id);

           IF l_ee_asg_eligible = 1 THEN

              l_abp_sub_cat := 'AAOP';

              SELECT effective_date
                INTO l_date_earned
                FROM pay_payroll_actions
               WHERE payroll_action_id = p_payroll_action_id;

           END IF;

         END IF;

         CLOSE c_get_asg_info;

         END IF;

      ELSE

         SELECT effective_date
           INTO l_date_earned
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      END IF;

   END IF;

hr_utility.set_location('...Value of l_date_earned is      '||l_date_earned,35);

--
-- For a particular ABP Sub Category/BG combination,
-- check if a ABP Pension Scheme is created. No need to go through
-- the logic if a scheme is not created for a sub cat.
--

l_chk_abp_scheme := chk_abp_scheme_created
   (p_date_earned        => l_date_earned
   ,p_business_group_id  => p_business_group_id
   ,p_pension_sub_cat    => l_abp_sub_cat
   ,p_pension_type_id    => l_pension_type_id);

hr_utility.set_location('...Value of l_chk_abp_scheme is '||l_chk_abp_scheme,40);

IF l_chk_abp_scheme = 1 THEN

hr_utility.set_location('...ABP Pension Scheme created for PT '||l_pension_type_id,45);

--
-- For IPH and IPL after 31 Dec 2006 Return 0%. This is necessary so that
-- the Tax and SI for the retro contributions in 2006 are reduced in 2007.
--
-- IF p_pension_sub_cat IN ('IPBW_H','IPBW_L') AND TRUNC(l_date_earned) > TO_DATE('31/12/2006','DD/MM/YYYY') THEN
--    p_ee_contrib_type  := 0;
--    p_er_contrib_type  := 0;
--    p_ee_contrib_value := 0;
--    p_er_contrib_value := 0;
--    RETURN 0;
-- END IF;


    --
    -- Derive the Pension Type details
    --
    OPEN c_pt_dtls(l_pension_type_id,l_date_earned);
   FETCH c_pt_dtls INTO
         l_ee_age_contribution
        ,l_er_age_contribution
        ,l_pt_ee_contrib
        ,l_pt_er_contrib;
   CLOSE c_pt_dtls;

   --
   -- Derive the value of ER Age Dpndnt Contribution
   --
   IF l_er_age_contribution = 'Y' THEN

      hr_utility.set_location('...ABP ER component is age dependant',50);
      l_er_return_value := get_contribution_percent
                           (p_assignment_id
                           ,l_date_earned
                           ,p_business_group_id
                           ,l_abp_sub_cat
                           ,'PQP_NL_ABP_ER_CONTRIBUTION_PERCENT'
                           ,l_er_age_contri_value);

   END IF;

   --
   -- Derive the value of EE Age Dpndnt Contribution
   --
   IF l_ee_age_contribution = 'Y' THEN

      hr_utility.set_location('...ABP EE component is age dependant',55);

      l_ee_return_value := get_contribution_percent
                           (p_assignment_id
                           ,l_date_earned
                           ,p_business_group_id
                           ,l_abp_sub_cat
                           ,'PQP_NL_ABP_EE_CONTRIBUTION_PERCENT'
                           ,l_ee_age_contri_value);

   END IF;

   --
   -- Find the contribution value and type from the asg extra info.
   --
    OPEN c_get_asg_info(l_pension_type_id,l_date_earned);
   FETCH c_get_asg_info
    INTO l_ee_contrib_type
        ,l_ee_contrib_value
        ,l_er_contrib_type
        ,l_er_contrib_value;

   IF c_get_asg_info%FOUND THEN

      hr_utility.set_location('...Data found at the Asg EIT',60);
      hr_utility.set_location('...c_get_asg_info %found ',65);

      IF l_er_contrib_type = 'FA' THEN
         l_er_contrib_value_fa := l_er_contrib_value;
      END IF;
      --
      -- If the contribution % is not entered, check if the pension type
      -- has age dependant contribution enabled.
      --
      IF l_ee_contrib_type = 'PE' AND l_ee_contrib_value = -1 THEN

         --
         -- Contribution value is null or empty.Check to see if the pension
         -- type has age dependant contribution enabled.
         --

         IF l_ee_age_contribution = 'Y' THEN

            hr_utility.set_location('...Deriving EE age dependant contribution',70);
            p_ee_contrib_value := l_ee_age_contri_value;
            p_ee_contrib_type  := 0;

         ELSE
                -- Derive the contribution percentage for certain set of
                -- assignments. This is indicated at the org level via the
                -- "Applicable to all employees" flag in the org developer df

                hr_utility.set_location('...Deriving contribution based on Applicable to all employees flag',75);

                l_asg_ret_value:= get_abp_org_contrib_percent
                  (p_assignment_id      => p_assignment_id
                  ,p_date_earned        => l_date_earned
                  ,p_business_group_id  => p_business_group_id
                  ,p_pension_type_id    => l_pension_type_id
                  ,p_ee_contrib         => l_ee_contrib_value
                  ,p_er_contrib         => l_dummy
                  ,p_app_to_all_ee      => 'N');

                   p_ee_contrib_value := l_ee_contrib_value;
                   p_ee_contrib_type  := 0;
                   l_ee_return_value  := l_asg_ret_value;

         END IF;-- EE Age Dependant Check

      ELSE
         --
         -- User has defined either a FA or PE return these
         --
         hr_utility.set_location('...EE Asg Contribution is a PE or FA ',80);
         SELECT DECODE(l_ee_contrib_type,'PE',0,'FA',1)
           INTO p_ee_contrib_type
           FROM dual;
         p_ee_contrib_value := l_ee_contrib_value;
         l_ee_return_value  := 0;

      END IF;

      IF l_er_contrib_type = 'PE' AND l_er_contrib_value = -1 THEN
         --
         -- contribution type or value has been left empty,
         -- so check to see if the pension type has age
         -- dependant contribution enabled
         --

         IF l_er_age_contribution = 'Y' THEN

            hr_utility.set_location('...Deriving ER age dependant contribution',90);
            p_er_contrib_value := l_er_age_contri_value;
            p_er_contrib_type  := 0;

         ELSE
            --
            -- Derive the contribution percentage for certain set of
            -- assignments. This is indicated at the org level via the
            -- "Applicable to all employees" flag in the org developer df
            --
            hr_utility.set_location('...Deriving contribution based on Applicable to all employees flag',95);
            l_asg_ret_value:= get_abp_org_contrib_percent
                  (p_assignment_id      => p_assignment_id
                  ,p_date_earned        => l_date_earned
                  ,p_business_group_id  => p_business_group_id
                  ,p_pension_type_id    => l_pension_type_id
                  ,p_ee_contrib         => l_dummy
                  ,p_er_contrib         => l_er_contrib_value
                  ,p_app_to_all_ee      => 'N');

            p_er_contrib_value := l_er_contrib_value;
            p_er_contrib_type  := 0;
            l_er_return_value  := l_asg_ret_value;

         END IF;

      ELSE

         SELECT DECODE(l_er_contrib_type,'PE',0,'FA',1)
           INTO p_er_contrib_type
           FROM dual;
         hr_utility.set_location('...ER Asg Contribution is a PE or FA ',100);
         p_er_contrib_value := l_er_contrib_value;
         l_er_return_value := 0;

      END IF;

      CLOSE c_get_asg_info;

      IF l_ee_return_value = 1 and l_er_return_value = 1 THEN
         l_ret_value := 1;
      ELSE
         l_ret_value := 0;
      END IF;

      hr_utility.set_location('...Asg EE Contrib Type is '||p_ee_contrib_type,110);
      hr_utility.set_location('...Asg ER Contrib Type is '||p_er_contrib_type,120);
      hr_utility.set_location('...Asg EE Contrib Val is  '||p_ee_contrib_value,130);
      hr_utility.set_location('...Asg ER Contrib Val is  '||p_er_contrib_value,140);

   ELSE
      --
      -- No overridden row at ASG level on this date,
      -- so search at the HR org and ER Levels.
      --
      CLOSE c_get_asg_info;

      --
      -- Get the Org id, Legal ER org id and Payroll id
      --
      OPEN c_find_org(l_date_earned);
      FETCH c_find_org
      INTO l_org_id,l_payroll_id,l_legal_er_org_id;
      CLOSE c_find_org;

      hr_utility.set_location('...Asg Override not found. Deriving from the org',150);
      hr_utility.set_location('...Value of l_org_id is'||l_org_id,160);
      hr_utility.set_location('...Value of l_payroll_id is'||l_payroll_id,170);
      hr_utility.set_location('...Value of l_legal_er_org_id is'||l_legal_er_org_id,180);

      l_ee_asg_eligible := 0;

      l_ee_asg_eligible :=  chk_pt_eligibility
          ( p_assignment_id      => p_assignment_id
           ,p_date_earned        => l_date_earned
           ,p_business_group_id  => p_business_group_id
           ,p_pt_id              => l_pension_type_id
           ,p_hr_org_org_id      => l_org_id
           ,p_le_org_id          => l_legal_er_org_id);

      IF l_ee_asg_eligible = 1 THEN
         --
         -- Intialize various variables
         --
         p_ee_contrib_type  := 0;
         p_er_contrib_type  := 0;
         p_ee_contrib_value := -1;
         p_er_contrib_value := -1;
         l_ret_value        := 0;

         --
         -- If the PT is age dependant, assign these values.
         --
         IF l_ee_age_contribution = 'Y' THEN
            hr_utility.set_location('...Age dependant contribution enabled',20);
            p_ee_contrib_value := l_ee_age_contri_value;
         END IF;

         IF l_er_age_contribution = 'Y' THEN
            hr_utility.set_location('...Age dependant contribution enabled',20);
            p_er_contrib_value := l_er_age_contri_value;
         END IF;

         --
         -- If the values are not populated derive from the HR Org.
         --
         IF p_ee_contrib_value = -1 OR p_er_contrib_value = -1 THEN

            OPEN c_get_contribution
              (c_org_id => l_org_id
              ,c_pt_id  => l_pension_type_id
              ,c_date_earned => l_date_earned);
            FETCH c_get_contribution
             INTO l_ee_hr_org_contrib,l_er_hr_org_contrib;
             CLOSE c_get_contribution;

            IF p_ee_contrib_value = -1 AND l_ee_hr_org_contrib IS NOT NULL THEN
               p_ee_contrib_value := l_ee_hr_org_contrib;
            END IF;

            IF p_er_contrib_value = -1 AND l_er_hr_org_contrib IS NOT NULL THEN
               p_er_contrib_value := l_er_hr_org_contrib;
            END IF;

         END IF;

         --
         -- If the values are not populated derive from the Legal ER.
         --
         IF p_ee_contrib_value = -1 OR p_er_contrib_value = -1 THEN

            OPEN c_get_contribution
              (c_org_id => l_legal_er_org_id
              ,c_pt_id  => l_pension_type_id
              ,c_date_earned => l_date_earned);
            FETCH c_get_contribution
             INTO l_ee_le_contrib,l_er_le_contrib;
             CLOSE c_get_contribution;

             IF p_ee_contrib_value = -1 AND l_ee_le_contrib IS NOT NULL THEN
                p_ee_contrib_value := l_ee_le_contrib;
             END IF;

             IF p_er_contrib_value = -1 AND l_er_le_contrib IS NOT NULL THEN
                p_er_contrib_value := l_er_le_contrib;
             END IF;

         END IF;

         --
         -- If the values are not populated derive from the PT
         --
         IF p_ee_contrib_value = -1 OR p_er_contrib_value = -1 THEN

             IF p_ee_contrib_value = -1 THEN
                p_ee_contrib_value  := l_pt_ee_contrib;
             END IF;

             IF p_er_contrib_value  = -1 THEN
                p_er_contrib_value := l_pt_er_contrib;
             END IF;

         END IF;

      ELSE
         --
         -- EE is not eligible for this PT as there is no valid
         -- information at the org level as of date earned.
         --
         l_ret_value := 1;

      END IF; -- Check for EE Asg eligibility

   END IF; -- Asg Override Found

ELSE

   --
   -- Scheme is not created no need to derive %
   --
   l_ret_value := 1;

END IF; -- Scheme creation check for a subcat

   hr_utility.set_location('...EE Contrib Type is '||p_ee_contrib_type,40);
   hr_utility.set_location('...ER Contrib Type is '||p_er_contrib_type,50);
   hr_utility.set_location('...EE Contrib Value is '||p_ee_contrib_value,40);
   hr_utility.set_location('...ER Contrib Value is '||p_er_contrib_value,50);

RETURN l_ret_value;

EXCEPTION

WHEN OTHERS THEN
   hr_utility.set_location('...Entered WHEN OTHERS EXCEPTION ',40);
   l_ret_value := 1;

END get_abp_contribution;

--
-- ------------------------------------------------------------------------
-- |------------------< get_participation_date >----------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION  get_participation_date
           (p_assignment_id      in  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        in  date
           ,p_business_group_id  in  pqp_pension_types_f.business_group_id%TYPE
           ,p_pension_type_id    in  pqp_pension_types_f.pension_type_id%TYPE
           ,p_start_date         out NOCOPY date
          )
RETURN number IS

l_org_id hr_all_organization_units.organization_id%type;
l_ret_value number := 0; --return
l_asg_extra_info_id per_assignment_extra_info.assignment_extra_info_id%type;
l_org_info_id hr_organization_information.org_information_id%type;
l_named_hierarchy       number;
l_version_id            per_org_structure_versions_v.org_structure_version_id%type  default null;
l_loop_again number;
l_is_org_info_valid varchar2(1);

--Cursor to find the org id from the assignment id
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id
  AND trunc(p_date_earned) between effective_start_date and effective_end_date
  AND business_group_id = p_business_group_id;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy Is
select org_information1
 from hr_organization_information
where organization_id = p_business_group_id
 and org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id in Number) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where organization_structure_id = c_hierarchy_id
  and p_date_earned between date_from
  and nvl(date_to,hr_api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where business_group_id = p_business_group_id
  and p_date_earned between date_from
  and nvl( date_to,hr_api.g_eot);

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id in number
                       ,c_version_id in number) IS
select organization_id_parent
  from per_org_structure_elements
  where organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--Cursor to find if there is any information record at the assignment level
--if so return the asg extra info id
CURSOR c_get_valid_asg_info Is
   Select paei.assignment_extra_info_id
     from per_assignment_extra_info paei
     where paei.information_type         = 'NL_ABP_PI'
       and paei.aei_information_category = 'NL_ABP_PI'
       and paei.aei_information3         = to_char(p_pension_type_id)
       and paei.assignment_id            = p_assignment_id;

--Cursor to find if there is any information record at the org level
--if so return the org info id
CURSOR c_get_valid_org_info(c_org_id in hr_all_organization_units.organization_id%type) IS
   Select hoi.org_information_id
     from hr_organization_information hoi
     where hoi.org_information_context      = 'PQP_NL_ABP_PT'
       and hoi.org_information3             = to_char(p_pension_type_id)
       AND hoi.org_information6             = 'Y'
       AND NVL(hoi.org_information7,'Y')             = 'Y'
       and hoi.organization_id              = c_org_id;

--Cursor to find the participation start date from assignment level information
CURSOR c_get_asg_info Is
SELECT fnd_date.canonical_to_date(paei.aei_information1)
  FROM per_assignment_extra_info paei
  WHERE paei.information_type         = 'NL_ABP_PI'
       and paei.aei_information_category = 'NL_ABP_PI'
       and paei.aei_information3         = to_char(p_pension_type_id)
       and paei.assignment_id            = p_assignment_id
       and p_date_earned between fnd_date.canonical_to_date(paei.aei_information1)
       and fnd_date.canonical_to_date(nvl(paei.aei_information2,fnd_date.date_to_canonical(hr_api.g_eot)));

--Cursor to find the participation start date from org level information
CURSOR c_get_org_info(c_org_id in hr_organization_information.organization_id%type) Is
SELECT fnd_date.canonical_to_date(hoi.org_information1)
  FROM hr_organization_information hoi
     where hoi.org_information_context      = 'PQP_NL_ABP_PT'
       and hoi.org_information3             = to_char(p_pension_type_id)
       and hoi.org_information6             = 'Y'
       and NVL(hoi.org_information7,'Y')             = 'Y'
       and hoi.organization_id              = c_org_id
       and p_date_earned between fnd_date.canonical_to_date(hoi.org_information1)
       and fnd_date.canonical_to_date(nvl(hoi.org_information2,fnd_date.date_to_canonical(hr_api.g_eot)));

BEGIN
     -- first check to see if any row exists at the ASG attribute level
     OPEN c_get_valid_asg_info;
     FETCH c_get_valid_asg_info INTO l_asg_extra_info_id;
     IF c_get_valid_asg_info%FOUND THEN
        hr_utility.set_location('found row at ASG EIT level',10);
        -- find the participation start date from the asg extra info
	CLOSE c_get_valid_asg_info;
        OPEN c_get_asg_info;
	FETCH c_get_asg_info INTO p_start_date;
        IF c_get_asg_info%FOUND THEN
           l_ret_value := 0;
	   CLOSE c_get_asg_info;
        ELSE
           p_start_date := hr_api.g_eot;
           l_ret_value    := 1;
           CLOSE c_get_asg_info;
        END IF;
     ELSE -- no row at ASG level on this date,so search up the org hierarchy
	CLOSE c_get_valid_asg_info;
        -- find the org the assignment is attached to
        OPEN c_find_org_id;
        FETCH c_find_org_id INTO l_org_id;
        CLOSE c_find_org_id;

        --first chk to see if a named hierarchy exists for the BG
        OPEN c_find_named_hierarchy;
        FETCH c_find_named_hierarchy INTO l_named_hierarchy;
        -- if a named hiearchy is found , find the valid version on that date
        IF c_find_named_hierarchy%FOUND THEN
           CLOSE c_find_named_hierarchy;
           -- now find the valid version on that date
           OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
           FETCH c_find_ver_frm_hierarchy INTO l_version_id;
             --if no valid version is found, try to get it frm the BG
             IF c_find_ver_frm_hierarchy%NOTFOUND THEN
                CLOSE c_find_ver_frm_hierarchy;
                -- find the valid version id from the BG
                OPEN c_find_ver_frm_bg;
                FETCH c_find_ver_frm_bg INTO l_version_id;
                CLOSE c_find_ver_frm_bg;
             -- else a valid version has been found for the named hierarchy
             ELSE
                CLOSE c_find_ver_frm_hierarchy;
             END IF; --end of if no valid version found
        -- else find the valid version from BG
        ELSE
           CLOSE c_find_named_hierarchy;
           --now find the version number from the BG
           OPEN c_find_ver_frm_bg;
           FETCH c_find_ver_frm_bg INTO l_version_id;
           CLOSE c_find_ver_frm_bg;
        END IF; -- end of if named hierarchy found

        -- loop through the org hierarchy to find the participation start date at
        -- this org level or its parents
        l_loop_again := 1;
        WHILE (l_loop_again = 1)

        LOOP
           -- if any org info row is found for this particular org id
           -- for a pension type with the given pension type id
           -- then return that org info id
	   OPEN c_get_valid_org_info(l_org_id);
	   FETCH c_get_valid_org_info INTO l_org_info_id;
	   IF c_get_valid_org_info%FOUND THEN
              hr_utility.set_location('found row @ org info level'||l_org_id,20);
              l_loop_again := 0;
              CLOSE c_get_valid_org_info;
	      -- fetch the participation start date from the org info row
              OPEN c_get_org_info(l_org_id);
              FETCH c_get_org_info INTO p_start_date;
              IF c_get_org_info%FOUND THEN
	         l_ret_value  := 0;
                 l_loop_again := 0;
                 CLOSE c_get_org_info;
              ELSE
	         l_ret_value        := 1;
                 l_loop_again       := 0;
                 CLOSE c_get_org_info;
              END IF;

	   ELSE -- search at the parent level of the current org
	      CLOSE c_get_valid_org_info;
              -- fetch the parent of this org and loop again
	      OPEN c_find_parent_id(l_org_id,l_version_id);
	      FETCH c_find_parent_id INTO l_org_id;
	      IF c_find_parent_id%NOTFOUND THEN -- the topmost org has been reached
	         CLOSE c_find_parent_id;
	         l_ret_value        := 1;
                 l_loop_again       := 0;
	      ELSE
	         CLOSE c_find_parent_id;
	      END IF;
           END IF;
        END LOOP;
     END IF; -- end of if valid asg info row found
  --hr_utility.trace_off;
 return l_ret_value;

END get_participation_date;

--
-- ------------------------------------------------------------------------
-- |------------------< get_participation_org >----------------------------|
-- ------------------------------------------------------------------------
--
PROCEDURE  get_participation_org
           (p_assignment_id      in  per_all_assignments_f.assignment_id%TYPE
           ,p_date_earned        in  date
           ,p_pension_type_id    in  pqp_pension_types_f.pension_type_id%TYPE
           ,p_asg_or_org         out NOCOPY number
           ,p_org_id             out NOCOPY number
          )
IS

l_org_id hr_all_organization_units.organization_id%type;
l_asg_extra_info_id per_assignment_extra_info.assignment_extra_info_id%type;
l_org_info_id hr_organization_information.org_information_id%type;
l_named_hierarchy       number;
l_version_id            per_org_structure_versions_v.org_structure_version_id%type  default null;
l_loop_again number;
l_is_org_info_valid varchar2(1);
l_bgid number;

--Cursor to find the org id from the assignment id
CURSOR c_find_org_id IS
SELECT organization_id,business_group_id
  FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id
  AND trunc(p_date_earned) between effective_start_date and effective_end_date;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy(c_bgid in number) Is
select org_information1
 from hr_organization_information
where organization_id = c_bgid
 and org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id in Number) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where organization_structure_id = c_hierarchy_id
  and p_date_earned between date_from
  and nvl(date_to,hr_api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg(c_bgid in number) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where business_group_id = c_bgid
  and p_date_earned between date_from
  and nvl( date_to,hr_api.g_eot);

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id in number
                       ,c_version_id in number
                       ,c_bgid in number) IS
select organization_id_parent
  from per_org_structure_elements
  where organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = c_bgid;

--Cursor to find if the information record at the assignment level is valid
-- on the date earned and if so return the asg extra info id
CURSOR c_get_valid_asg_info Is
   Select paei.assignment_extra_info_id
     from per_assignment_extra_info paei
     where paei.information_type         = 'NL_ABP_PI'
       and paei.aei_information_category = 'NL_ABP_PI'
       and paei.aei_information3         = to_char(p_pension_type_id)
       and paei.assignment_id            = p_assignment_id
       and p_date_earned between trunc(to_date(substr(paei.aei_information1,1,10),'YYYY/MM/DD'))
                             and trunc(to_date(substr(nvl(paei.aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'));

--Cursor to find if the information record at the org level is valid
--on the date earned and if so return the org info id
CURSOR c_get_valid_org_info(c_org_id in hr_all_organization_units.organization_id%type) IS
   Select hoi.org_information_id
     from hr_organization_information hoi
     where hoi.org_information_context      = 'PQP_NL_ABP_PT'
       and hoi.org_information3             = to_char(p_pension_type_id)
       and hoi.org_information6             = 'Y'
       AND NVL(hoi.org_information7,'Y')             = 'Y'
       and hoi.organization_id              = c_org_id
       and p_date_earned between trunc(to_date(substr(hoi.org_information1,1,10),'YYYY/MM/DD'))
                             and trunc(to_date(substr(nvl(hoi.org_information2,'4712/12/31'),1,10),'YYYY/MM/DD'));

BEGIN

     -- first check to see if a valid row exists at the ASG attribute level
     -- on the date earned for the pension type id given
     OPEN c_get_valid_asg_info;
     FETCH c_get_valid_asg_info INTO l_asg_extra_info_id;
     IF c_get_valid_asg_info%FOUND THEN
        --set the participation as frm ASG and org id to 0
	CLOSE c_get_valid_asg_info;
	p_asg_or_org := 0;
        p_org_id     := 0;
     ELSE -- no valid row at ASG level on this date,so search up the org hierarchy
	CLOSE c_get_valid_asg_info;
        -- find the org the assignment is attached to
        OPEN c_find_org_id;
        FETCH c_find_org_id INTO l_org_id,l_bgid;
        CLOSE c_find_org_id;

        --first chk to see if a named hierarchy exists for the BG
        OPEN c_find_named_hierarchy(l_bgid);
        FETCH c_find_named_hierarchy INTO l_named_hierarchy;
        -- if a named hiearchy is found , find the valid version on that date
        IF c_find_named_hierarchy%FOUND THEN
           CLOSE c_find_named_hierarchy;
           -- now find the valid version on that date
           OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
           FETCH c_find_ver_frm_hierarchy INTO l_version_id;
             --if no valid version is found, try to get it frm the BG
             IF c_find_ver_frm_hierarchy%NOTFOUND THEN
                CLOSE c_find_ver_frm_hierarchy;
                -- find the valid version id from the BG
                OPEN c_find_ver_frm_bg(l_bgid);
                FETCH c_find_ver_frm_bg INTO l_version_id;
                CLOSE c_find_ver_frm_bg;
             -- else a valid version has been found for the named hierarchy
             ELSE
                CLOSE c_find_ver_frm_hierarchy;
             END IF; --end of if no valid version found
        -- else find the valid version from BG
        ELSE
           CLOSE c_find_named_hierarchy;
           --now find the version number from the BG
           OPEN c_find_ver_frm_bg(l_bgid);
           FETCH c_find_ver_frm_bg INTO l_version_id;
           CLOSE c_find_ver_frm_bg;
        END IF; -- end of if named hierarchy found

        -- loop through the org hierarchy to find the ORG trigerring
        -- this enrollment
        l_loop_again := 1;
        WHILE (l_loop_again = 1)

        LOOP
           -- if a valid org info row is found for this particular org id
           -- for a pension type with the given pension type id
           -- on this date, then return that org info id
	   OPEN c_get_valid_org_info(l_org_id);
	   FETCH c_get_valid_org_info INTO l_org_info_id;
	   IF c_get_valid_org_info%FOUND THEN
              CLOSE c_get_valid_org_info;
              p_asg_or_org       := 1;
              p_org_id           := l_org_id;
              l_loop_again       := 0;
	   ELSE -- search at the parent level of the current org
	      CLOSE c_get_valid_org_info;
              -- fetch the parent of this org and loop again
	      OPEN c_find_parent_id(l_org_id,l_version_id,l_bgid);
	      FETCH c_find_parent_id INTO l_org_id;
              IF c_find_parent_id%NOTFOUND THEN
                 l_loop_again := 0;
	         CLOSE c_find_parent_id;
              ELSE
                 CLOSE c_find_parent_id;
              END IF;
           END IF;
        END LOOP;
     END IF; -- end of if valid asg info row found

END get_participation_org;

--
-- ------------------------------------------------------------------------
-- |---------------------< chk_dup_pp_row_ins >----------------------------|
-- ------------------------------------------------------------------------
--
PROCEDURE chk_dup_pp_row_ins(p_org_information_id      IN number
                            ,p_org_information_context IN varchar2
                            ,p_organization_id         IN number
                            ,p_org_information1        IN varchar2
                            ,p_org_information2        IN varchar2
                            ,p_org_information3        IN varchar2
                            ) IS

--cursor to fetch the effective date the user has datetracked to
CURSOR c_get_eff_date IS
SELECT effective_date
   FROM fnd_sessions
WHERE session_id = userenv('sessionid');

--cursor to check to see if there are any rows in the ORG EIT
CURSOR c_rows_exist IS
SELECT 1
  FROM hr_organization_information
WHERE EXISTS
      (SELECT 1
         FROM hr_organization_information
       WHERE  organization_id = p_organization_id
         AND  org_information_context = p_org_information_context
         AND  org_information_id      <> p_org_information_id
      );

l_eff_date             DATE;
l_rows_exist           NUMBER := 0;
l_proc                 varchar2(20) := 'chk_dup_pp_row_ins';

BEGIN
   hr_utility.set_location('Entering : '||l_proc,10);
   --first find the eff date the user had datetracked to
   OPEN c_get_eff_date;
   FETCH c_get_eff_date INTO l_eff_date;
   CLOSE c_get_eff_date;
   hr_utility.set_location('got the effective date : '||l_eff_date,20);

   --check to see if a row already exists in the EIT for this org
   OPEN c_rows_exist;
   FETCH c_rows_exist INTO l_rows_exist;
   IF c_rows_exist%FOUND THEN
      CLOSE c_rows_exist;
      hr_utility.set_message(8303,'ONLY_ONE_ROW_CAN_EXIST');
      hr_utility.raise_error;
   ELSE
      CLOSE c_rows_exist;
   END IF;

   --call the procedure to fire insert of the change events in the
   --ben_ext_chg_evt_log table
   pqp_nl_ext_functions.create_org_pp_ins_chg_evt
                        (p_organization_id         => p_organization_id
                        ,p_org_information1        => p_org_information1
                        ,p_org_information2        => p_org_information2
                        ,p_org_information3        => p_org_information3
                        ,p_effective_date          => l_eff_date
                        );

   hr_utility.set_location('leaving : '||l_proc,100);
END chk_dup_pp_row_ins;

--
-- ------------------------------------------------------------------------
-- |---------------------< chk_dup_pp_row_upd >----------------------------|
-- ------------------------------------------------------------------------
--
PROCEDURE chk_dup_pp_row_upd(p_org_information_id      IN number
                            ,p_org_information_context IN varchar2
                            ,p_organization_id         IN number
                            ,p_org_information1        IN varchar2
                            ,p_org_information2        IN varchar2
                            ,p_org_information3        IN varchar2
                            ,p_org_information1_o      IN varchar2
                            ,p_org_information2_o      IN varchar2
                            ,p_org_information3_o      IN varchar2
                            ) IS

CURSOR c_get_eff_date IS
SELECT effective_date
   FROM fnd_sessions
WHERE session_id = userenv('sessionid');

l_eff_date             DATE;

BEGIN

   --first find the eff date the user had datetracked to
   OPEN c_get_eff_date;
   FETCH c_get_eff_date INTO l_eff_date;
   CLOSE c_get_eff_date;

   --call the procedure to insert the change in the row into the ben_ext_chg_evt_log table
   pqp_nl_ext_functions.create_org_pp_upd_chg_evt
                        (p_organization_id         => p_organization_id
                        ,p_org_information1        => p_org_information1
                        ,p_org_information2        => p_org_information2
                        ,p_org_information3        => p_org_information3
                        ,p_org_information1_o      => p_org_information1_o
                        ,p_org_information2_o      => p_org_information2_o
                        ,p_org_information3_o      => p_org_information3_o
                        ,p_effective_date          => l_eff_date
                        );


END chk_dup_pp_row_upd;

--
-- ------------------------------------------------------------------------
-- |--------------------< get_absence_adjustment >------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_absence_adjustment
          (p_assignment_id     in  per_all_assignments_f.assignment_id%TYPE
          ,p_date_earned       in  date
          ,p_business_group_id in  pqp_pension_types_f.business_group_id%TYPE
          ,p_dedn_amt          in number
          ,p_adjust_amt        out NOCOPY number
          ,p_error_message     out NOCOPY varchar2
         )
RETURN number IS

--cursor to fetch the pay period start and end dates
--for the particular assignment
CURSOR c_get_period_dates IS
SELECT ptp.start_date,ptp.end_date
  FROM per_all_assignments_f asg
      ,per_time_periods ptp
WHERE  asg.assignment_id = p_assignment_id
  AND  asg.payroll_id    = ptp.payroll_id
  AND  p_date_earned BETWEEN ptp.start_date
  AND  ptp.end_date;

--
-- Cursor to get the start date for the active asg
--
CURSOR c_get_assign_start_date(c_start_date in date
                              ,c_end_date   in date) IS
SELECT min(asg.effective_start_date)
      ,max(asg.effective_end_date)
  FROM per_assignments_f asg
      ,per_assignment_status_types past
 WHERE asg.assignment_status_type_id = past.assignment_status_type_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.effective_start_date <= trunc(c_end_date)
   AND nvl(asg.effective_end_date, trunc(c_end_date)) >= trunc(c_start_date)
   AND asg.assignment_id = p_assignment_id
   group by asg.assignment_id;

--cursor to get the sickness element type id and the input value id
--for the Reduction Percentage input
CURSOR c_get_abs_ele IS
SELECT piv.input_value_id
      ,pet.element_type_id
FROM   pay_input_values_f piv
      ,pay_element_types_f pet
WHERE  piv.name = 'Reduction Percentage'
 AND   piv.element_type_id = pet.element_type_id
 AND   pet.element_name = 'ABP Pensions Premium Reduction Information'
 AND   p_date_earned BETWEEN piv.effective_start_date
 AND   piv.effective_end_date
 AND   p_date_earned BETWEEN pet.effective_start_date
 AND   pet.effective_end_date;

--cursor to fetch the start and end dates and the element entry id
--for all date tracked element entries made for the Premium Reduction
--element
CURSOR c_get_abs_ele_entry(c_effective_date   in date
                          ,c_element_type_id  in number
                          ,c_input_value_id   in number
                          ,c_period_end_date IN DATE ) IS
SELECT fnd_number.canonical_to_number(nvl(screen_entry_value,'0')) perc_value
      ,pee.effective_start_date start_date
      ,pee.effective_end_date end_date
  FROM pay_element_entry_values_f pef,
             pay_element_entries_f pee
 WHERE pef.input_value_id = c_input_value_id
   AND pef.element_entry_id = pee.element_entry_id
   AND pef.effective_start_date = pee.effective_start_date
   AND pef.effective_end_date = pee.effective_end_date
   AND pee.assignment_id = p_assignment_id
   AND pee.element_type_id = c_element_type_id
           AND (c_effective_date BETWEEN pee.effective_start_date AND
                                         pee.effective_end_date OR
               ( pee.effective_start_date > c_effective_date
                 AND pee.effective_start_date <= c_period_end_date ));
--
l_start_date          DATE;
l_end_date            DATE;
l_period_start_date   DATE;
l_period_end_date     DATE;
l_min_start_date      DATE;
l_max_end_date        DATE;
l_effective_date      DATE;
l_person_id           NUMBER;
l_days_in_pp          NUMBER;
l_payroll_days        NUMBER;
l_abs_ele_id          NUMBER;
l_abs_iv_id           NUMBER;
l_completed           VARCHAR2(1);
l_abs_percent         NUMBER := 0;

BEGIN
hr_utility.set_location('entered get_absence_adjustment',10);

--fetch the pay period start and end dates
OPEN c_get_period_dates;
FETCH c_get_period_dates INTO l_period_start_date
                             ,l_period_end_date;
CLOSE c_get_period_dates;
hr_utility.set_location('start date of pay period : '||l_period_start_date,30);
hr_utility.set_location('end date of pay period : '||l_period_end_date,40);

--fetch the greater of the assigment start date or the period start date
OPEN c_get_assign_start_date(c_start_date => l_period_start_date
                            ,c_end_date   => l_period_end_date);
FETCH c_get_assign_start_date INTO l_effective_date,l_max_end_date;
IF c_get_assign_start_date%FOUND THEN
   CLOSE c_get_assign_start_date;
ELSE
   CLOSE c_get_assign_start_date;
   p_adjust_amt  := 0;
   return 0;
END IF;

--fetch the element type id and the input value id for the premium
--reduction element
OPEN c_get_abs_ele;
FETCH c_get_abs_ele INTO l_abs_iv_id,l_abs_ele_id;
CLOSE c_get_abs_ele;

hr_utility.set_location('element id : '||l_abs_ele_id,42);
hr_utility.set_location('input value id : '||l_abs_iv_id,45);


l_completed      := 'N';

l_effective_date := GREATEST(l_effective_date,trunc(l_period_start_date));
l_min_start_date := l_effective_date;
l_max_end_date   := LEAST(l_max_end_date,trunc(l_period_end_date));
hr_utility.set_location('eff date : '||l_effective_date,50);

--find days in the pay period
l_payroll_days    := (trunc(l_period_end_date)
                   - trunc(l_period_start_date)) + 1;

--find the number of days the assignments has been effective in the
--current period
l_days_in_pp := nvl(l_max_end_date,trunc(l_period_end_date))
                - nvl(l_min_start_date,trunc(l_period_start_date))
                + 1;

hr_utility.set_location('days in pay period : '||l_payroll_days,55);
hr_utility.set_location('days asg valid : '||l_days_in_pp,57);

FOR temp_rec in c_get_abs_ele_entry ( trunc(l_effective_date)
                                     ,l_abs_ele_id
                                     ,l_abs_iv_id
                                     ,l_period_end_date)

LOOP

   IF l_completed = 'N' THEN

      IF temp_rec.end_date >= trunc(l_period_end_date) THEN
         l_end_date := trunc(l_period_end_date);
         l_completed      := 'Y';
      ELSE
         l_end_date := temp_rec.end_date;
      END IF;

      IF temp_rec.start_date < trunc(l_period_start_date) THEN
         l_start_date := trunc(l_period_start_date);
      ELSE
         l_start_date := temp_rec.start_date;
      END IF;

hr_utility.set_location('start date : '||l_start_date,60);
hr_utility.set_location('end date : '||l_end_date,70);
hr_utility.set_location('entry value : '||temp_rec.perc_value,80);

      l_abs_percent := l_abs_percent + temp_rec.perc_value * ((trunc(l_end_date) -
                                 trunc(l_start_date)) + 1);

   END IF;

END LOOP;

--find the average part time percentage value
l_abs_percent := l_abs_percent/l_days_in_pp;

hr_utility.set_location('final value : '||l_abs_percent,90);

p_adjust_amt := ROUND(l_abs_percent,4);

--hr_utility.trace_off;
return 0;

EXCEPTION

WHEN OTHERS THEN

p_adjust_amt := 0;
p_error_message := 'Error occured in get_absence_adjustment : '||SQLERRM;
hr_utility.set_location('error occured exiting get_absence_adjustment',110);
return 1;

END get_absence_adjustment;

--
-- ------------------------------------------------------------------------
-- |----------------------< get_proration_factor>--------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_proration_factor
          (p_assignment_id     in  per_all_assignments_f.assignment_id%TYPE
          ,p_date_earned       in  date
          ,p_business_group_id in  pqp_pension_types_f.business_group_id%TYPE
          ,p_proration_factor  out NOCOPY number
          ,p_error_message     out NOCOPY varchar2
         )
RETURN number IS

--cursor to fetch the pay period start and end dates
--for the particular assignment
CURSOR c_get_period_dates IS
SELECT ptp.start_date,ptp.end_date
  FROM per_all_assignments_f asg
      ,per_time_periods ptp
WHERE  asg.assignment_id = p_assignment_id
  AND  asg.payroll_id    = ptp.payroll_id
  AND  p_date_earned BETWEEN ptp.start_date
  AND  ptp.end_date;

--
-- Cursor to get the start date for the active asg
--
CURSOR c_get_assign_start_date(c_start_date in date
                              ,c_end_date   in date) IS
SELECT min(asg.effective_start_date)
      ,max(asg.effective_end_date)
  FROM per_assignments_f asg
      ,per_assignment_status_types past
 WHERE asg.assignment_status_type_id = past.assignment_status_type_id
   AND past.per_system_status = 'ACTIVE_ASSIGN'
   AND asg.effective_start_date <= trunc(c_end_date)
   AND nvl(asg.effective_end_date, trunc(c_end_date)) >= trunc(c_start_date)
   AND asg.assignment_id = p_assignment_id
   group by asg.assignment_id;

l_period_start_date   DATE;
l_period_end_date     DATE;
l_min_start_date      DATE;
l_max_end_date        DATE;
l_effective_date      DATE;
l_days_in_pp          NUMBER;
l_payroll_days        NUMBER;
l_proration_factor    NUMBER;

BEGIN
hr_utility.set_location('entered get_proration_factor',10);

--fetch the pay period start and end dates
OPEN c_get_period_dates;
FETCH c_get_period_dates INTO l_period_start_date
                             ,l_period_end_date;
CLOSE c_get_period_dates;
hr_utility.set_location('start date of pay period : '||l_period_start_date,30);
hr_utility.set_location('end date of pay period : '||l_period_end_date,40);

--fetch the greater of the assigment start date or the period start date
OPEN c_get_assign_start_date(c_start_date => l_period_start_date
                            ,c_end_date   => l_period_end_date);
FETCH c_get_assign_start_date INTO l_effective_date,l_max_end_date;
IF c_get_assign_start_date%FOUND THEN
   CLOSE c_get_assign_start_date;
ELSE
   CLOSE c_get_assign_start_date;
   p_proration_factor := 0;
   return 0;
END IF;


l_effective_date := GREATEST(l_effective_date,trunc(l_period_start_date));
l_min_start_date := l_effective_date;
l_max_end_date   := LEAST(l_max_end_date,trunc(l_period_end_date));
hr_utility.set_location('eff date : '||l_effective_date,50);

--find days in the pay period
l_payroll_days    := (trunc(l_period_end_date)
                   - trunc(l_period_start_date)) + 1;

--find the number of days the assignments has been effective in the
--current period
l_days_in_pp := nvl(l_max_end_date,trunc(l_period_end_date))
                - nvl(l_min_start_date,trunc(l_period_start_date))
                + 1;

hr_utility.set_location('days in pay period : '||l_payroll_days,55);
hr_utility.set_location('days asg valid : '||l_days_in_pp,57);

--find the proration factor
l_proration_factor := l_days_in_pp/l_payroll_days;

hr_utility.set_location('final value : '||l_proration_factor,90);

p_proration_factor := l_proration_factor;

--hr_utility.trace_off;
return 0;

EXCEPTION

WHEN OTHERS THEN

p_proration_factor := 1;
p_error_message := 'Error occured in get_proration_factor : '||SQLERRM;
hr_utility.set_location('error occured exiting get_proration_factor',110);
return 1;

END get_proration_factor;

--
-- ------------------------------------------------------------------------
-- |--------------------< get_abp_calc_eff_dt >----------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_abp_calc_eff_dt
        (p_date_earned           IN  DATE
        ,p_business_group_id     IN  pqp_pension_types_f.business_group_id%TYPE
        ,p_assignment_id         IN  per_all_assignments_f.assignment_id%TYPE
        ,p_effective_date        OUT NOCOPY DATE
        )

RETURN NUMBER IS

-- Cursor to get the hire date of the person
CURSOR c_hire_dt_cur(c_asg_id IN NUMBER) IS
SELECT max(date_start)
 FROM  per_all_assignments_f asg
      ,per_periods_of_service pps
 WHERE pps.person_id     = asg.person_id
   AND asg.assignment_id = c_asg_id
   AND pps.business_group_id = p_business_group_id
   AND date_start <= p_date_earned;

--cursor to fetch the assignment start date
CURSOR c_get_asg_start IS
SELECT min(effective_start_date)
  FROM per_all_assignments_f
 WHERE assignment_id = p_assignment_id
   AND assignment_type = 'E';

l_run_year            NUMBER;
l_begin_of_year_date  DATE;
l_asg_st_date         DATE;
l_hire_date           DATE;

BEGIN

l_run_year := TO_NUMBER(TO_CHAR(p_date_earned,'YYYY'));

--
-- Get the date for 1 JAN of the run year
--
l_begin_of_year_date := TO_DATE('01/01/'||to_char(l_run_year),'DD/MM/YYYY');

--
-- Get the latest start date of the assignment
--
OPEN c_get_asg_start;
FETCH c_get_asg_start INTO l_asg_st_date;
IF c_get_asg_start%FOUND THEN
   CLOSE c_get_asg_start;
ELSE
   CLOSE c_get_asg_start;
   RETURN 1;
END IF;

--
-- Get the hire date
--
OPEN c_hire_dt_cur (p_assignment_id);

FETCH c_hire_dt_cur INTO l_hire_date;
   IF c_hire_dt_cur%FOUND THEN
         -- The effective date is now the greatest of 1 Jan of the year
         -- the hire date and asg start date .
         p_effective_date := GREATEST(l_begin_of_year_date,l_hire_date,l_asg_st_date);
         CLOSE c_hire_dt_cur;
   ELSE
      CLOSE c_hire_dt_cur;
      RETURN 1;
   END IF; -- Hire date found

RETURN 0;

EXCEPTION WHEN OTHERS THEN
  RETURN 1;

END;

--
-- ------------------------------------------------------------------------
-- |--------------------< get_proration_flag >----------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_proration_flag
        (p_date_earned           IN  DATE
        ,p_business_group_id     IN  pqp_pension_types_f.business_group_id%TYPE
        ,p_assignment_id         IN  per_all_assignments_f.assignment_id%TYPE
        ,p_assignment_action_id  IN  per_all_assignments_f.assignment_id%TYPE
        ,p_element_type_id       IN  pay_element_types_f.element_type_id%TYPE
        ,p_start_date            IN  DATE
        ,p_end_date              IN  DATE
        )

RETURN VARCHAR2 IS

l_ret_val         NUMBER;
l_effective_date  DATE;

BEGIN

l_ret_val := pqp_nl_abp_functions.get_abp_calc_eff_dt
        (p_date_earned        => p_date_earned
        ,p_business_group_id  => p_business_group_id
        ,p_assignment_id      => p_assignment_id
        ,p_effective_date     => l_effective_date
        );

IF l_ret_val = 0 THEN
   IF trunc(l_effective_date) BETWEEN
      trunc(p_start_date) AND
      trunc(p_end_date)   THEN
         RETURN 'Y';
   ELSE
         RETURN 'N';
   END IF;
ELSE
   RETURN 'E';
END IF;

END get_proration_flag;

--
-- ------------------------------------------------------------------------
-- |------------------< get_eoy_bonus_percentage >-------------------------|
-- ------------------------------------------------------------------------
--
FUNCTION get_eoy_bonus_percentage
        (p_date_earned           IN  date
        ,p_business_group_id     IN  pqp_pension_types_f.business_group_id%TYPE
        ,p_assignment_id         IN  per_all_assignments_f.assignment_id%TYPE
        ,p_eoy_bonus_percentage  OUT NOCOPY number
        )
RETURN NUMBER IS

--Cursor to find the org id from the assignment id
CURSOR c_find_org_id IS
SELECT organization_id
  FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id
  AND trunc(p_date_earned) between effective_start_date and effective_end_date
  AND business_group_id = p_business_group_id;

--Cursor to find the named hierarchy associated with the BG
CURSOR c_find_named_hierarchy Is
select org_information1
 from hr_organization_information
where organization_id = p_business_group_id
 and org_information_context = 'NL_BG_INFO';

--Cursor to find the valid version id for the particular named hierarchy
CURSOR c_find_ver_frm_hierarchy(c_hierarchy_id in Number) Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where organization_structure_id = c_hierarchy_id
  and p_date_earned between date_from
  and nvl(date_to,hr_api.g_eot);

--Cursor to find the valid version id for a particular business group
CURSOR c_find_ver_frm_bg Is
select ORG_STRUCTURE_VERSION_ID
  from per_org_structure_versions_v
where business_group_id = p_business_group_id
  and p_date_earned between date_from
  and nvl( date_to,hr_api.g_eot);

--Cursor to find the parent id from the org id
CURSOR c_find_parent_id(c_org_id in number
                       ,c_version_id in number) IS
select organization_id_parent
  from per_org_structure_elements
  where organization_id_child = c_org_id
    AND org_structure_version_id = c_version_id
    AND business_group_id = p_business_group_id;

--Cursor to find the eoy bonus percentage
--if entered at the org level
CURSOR c_find_eoy_percent(c_org_id IN NUMBER) IS
SELECT org_information3
  FROM hr_organization_information
WHERE  organization_id = c_org_id
  AND  org_information_context = 'PQP_NL_ABP_PTP_METHOD'
  AND  org_information3 IS NOT NULL;

l_ret_val              NUMBER;
l_named_hierarchy      NUMBER;
l_loop_again           NUMBER;
l_eoy_percent          hr_organization_information.org_information3%TYPE;
l_org_id               hr_all_organization_units.organization_id%type;
l_org_info_id          hr_organization_information.org_information_id%type;
l_version_id           per_org_structure_versions_v.org_structure_version_id%type  default null;

BEGIN

hr_utility.set_location('Entering get_eoy_bonus_percentage',10);
--fetch the hr org id from the assignment
OPEN c_find_org_id;
FETCH c_find_org_id INTO l_org_id;
CLOSE c_find_org_id;

hr_utility.set_location('org id for the asg : '||l_org_id,20);
--check to see if a value has been entered for
--the eoy bonus percentage at this org level
OPEN c_find_eoy_percent(l_org_id);
FETCH c_find_eoy_percent INTO l_eoy_percent;
IF c_find_eoy_percent%FOUND THEN
   hr_utility.set_location('EOY Bonus Percentage : '||l_eoy_percent,30);
   --found a value for the percentage at this org level
   --return from this point
   CLOSE c_find_eoy_percent;
   hr_utility.set_location('Leaving get_eoy_bonus_percentage',35);
   p_eoy_bonus_percentage := fnd_number.canonical_to_number(l_eoy_percent);
   RETURN 0;
ELSE
   --no value found at this org level,try to traverse up the
   --org hierarchy to find a value at the parent levels
   hr_utility.set_location('no value found at hr org level,going up the tree',40);
   CLOSE c_find_eoy_percent;

   --first chk to see if a named hierarchy exists for the BG
   OPEN c_find_named_hierarchy;
   FETCH c_find_named_hierarchy INTO l_named_hierarchy;
   -- if a named hiearchy is found , find the valid version on that date
   IF c_find_named_hierarchy%FOUND THEN
      CLOSE c_find_named_hierarchy;
      -- now find the valid version on that date
      OPEN c_find_ver_frm_hierarchy(l_named_hierarchy);
      FETCH c_find_ver_frm_hierarchy INTO l_version_id;
      --if no valid version is found, try to get it frm the BG
      IF c_find_ver_frm_hierarchy%NOTFOUND THEN
         CLOSE c_find_ver_frm_hierarchy;
         -- find the valid version id from the BG
         OPEN c_find_ver_frm_bg;
         FETCH c_find_ver_frm_bg INTO l_version_id;
         CLOSE c_find_ver_frm_bg;
      -- else a valid version has been found for the named hierarchy
      ELSE
         CLOSE c_find_ver_frm_hierarchy;
      END IF; --end of if no valid version found
   -- else find the valid version from BG
   ELSE
      CLOSE c_find_named_hierarchy;
      --now find the version number from the BG
      OPEN c_find_ver_frm_bg;
      FETCH c_find_ver_frm_bg INTO l_version_id;
      CLOSE c_find_ver_frm_bg;
   END IF; -- end of if named hierarchy found

   hr_utility.set_location('  l_version_id '||l_version_id,50);

   IF l_version_id IS NULL THEN
      --no hierarchy has been defined, so return 0%
      hr_utility.set_location('No hierarchy found,hence returning 0',60);
      hr_utility.set_location('Leaving get_eoy_bonus_percentage',65);
      p_eoy_bonus_percentage := 0;
      RETURN 0;
   END IF;

   -- loop through the org hierarchy to find the % values at this org level or its parents
   l_loop_again := 1;
   WHILE (l_loop_again = 1)
   LOOP
      --find the parent of this org
      OPEN c_find_parent_id(l_org_id,l_version_id);
      FETCH c_find_parent_id INTO l_org_id;
      IF c_find_parent_id%FOUND THEN
         hr_utility.set_location('searching at parent : '||l_org_id,70);
         CLOSE c_find_parent_id;
         OPEN c_find_eoy_percent(l_org_id);
         FETCH c_find_eoy_percent INTO l_eoy_percent;
         IF c_find_eoy_percent%FOUND THEN
            hr_utility.set_location('found eoy percent as : '||l_eoy_percent,80);
            CLOSE c_find_eoy_percent;
            p_eoy_bonus_percentage := fnd_number.canonical_to_number(l_eoy_percent);
            l_ret_val := 0;
            l_loop_again := 0;
         ELSE
            CLOSE c_find_eoy_percent;
         END IF;
      ELSE
         --no parent found, so return 0
         CLOSE c_find_parent_id;
         hr_utility.set_location('no parents found,returning 0',90);
         p_eoy_bonus_percentage := 0;
         l_loop_again := 0;
         l_ret_val := 0;
      END IF;
   END LOOP;
END IF;

hr_utility.set_location('Leaving get_eoy_bonus_percentage',95);
RETURN l_ret_val;

EXCEPTION

WHEN OTHERS THEN
   p_eoy_bonus_percentage := 0;
   hr_utility.set_location('Error occured : '||SQLERRM,100);
   RETURN 1;

END get_eoy_bonus_percentage;

-------------------------------------------------------------------------------
-----------------------------< upd_chg_evt >-----------------------------------
-- ----------------------------------------------------------------------------
-- This procedure updates the change event log registered with a
-- parameter prmtr_09 that contains the ABP Reporting date. The date
-- is derived based on the approval of an ABP Pensions Notification.
-- All reporting to ABP for e.g. Rec 05 and other relevant records
-- are done based on this date. This is also to address certification
-- issues that have been reported due to retrospective changes to various
-- reporting components.
--
PROCEDURE upd_chg_evt
   (p_ext_chg_evt_log_id    IN NUMBER
   ,p_chg_evt_cd            IN VARCHAR2
   ,p_chg_eff_dt            IN DATE
   ,p_chg_user_id           IN NUMBER
   ,p_prmtr_01              IN VARCHAR2
   ,p_prmtr_02              IN VARCHAR2
   ,p_prmtr_03              IN VARCHAR2
   ,p_prmtr_04              IN VARCHAR2
   ,p_prmtr_05              IN VARCHAR2
   ,p_prmtr_06              IN VARCHAR2
   ,p_prmtr_07              IN VARCHAR2
   ,p_prmtr_08              IN VARCHAR2
   ,p_prmtr_09              IN VARCHAR2
   ,p_prmtr_10              IN VARCHAR2
   ,p_person_id             IN NUMBER
   ,p_business_group_id     IN NUMBER
   ,p_object_version_number IN NUMBER
   ,p_effective_date        IN DATE
   ,p_chg_actl_dt           IN DATE
   ,p_new_val1              IN VARCHAR2
   ,p_new_val2              IN VARCHAR2
   ,p_new_val3              IN VARCHAR2
   ,p_new_val4              IN VARCHAR2
   ,p_new_val5              IN VARCHAR2
   ,p_new_val6              IN VARCHAR2
   ,p_old_val1              IN VARCHAR2
   ,p_old_val2              IN VARCHAR2
   ,p_old_val3              IN VARCHAR2
   ,p_old_val4              IN VARCHAR2
   ,p_old_val5              IN VARCHAR2
   ,p_old_val6              IN VARCHAR2 ) IS

--
-- Cursor to get the part time perc from the SC KFF
--
CURSOR c_ptp (c_kff_id   IN NUMBER) IS
SELECT fnd_number.canonical_to_number(segment29)
  FROM hr_soft_coding_keyflex
 WHERE soft_coding_keyflex_id = c_kff_id;

CURSOR c_log_xst( c_kff_id   IN NUMBER
                 ,c_st_dt    IN ben_ext_chg_evt_log.prmtr_04%TYPE
                 ,c_ed_dt    IN ben_ext_chg_evt_log.prmtr_05%TYPE
                 ,c_rep_dt   IN ben_ext_chg_evt_log.prmtr_09%TYPE
                 ,c_asg_id   IN ben_ext_chg_evt_log.prmtr_01%TYPE ) IS
SELECT *
  FROM ben_ext_chg_evt_log
 WHERE chg_evt_cd = 'COPTP'
   AND person_id  = p_person_id
   AND prmtr_04   = c_st_dt
   -- AND prmtr_05   = c_ed_dt
   AND prmtr_01   = c_asg_id
   AND prmtr_02   = c_kff_id;

CURSOR c_upd_log_kff_upd(c_asg_id   IN ben_ext_chg_evt_log.prmtr_01%TYPE ) IS
SELECT ext_chg_evt_log_id
      ,prmtr_09
  FROM ben_ext_chg_evt_log
 WHERE chg_evt_cd = 'COPTP'
   AND person_id  = p_person_id
   AND prmtr_01   = c_asg_id
   AND prmtr_02   = p_old_val1
   AND DECODE(prmtr_05,'4712/12/31 00:00:00',
              TRUNC(p_chg_eff_dt) - 1,
              TRUNC(fnd_date.canonical_to_date(prmtr_05)))
            = TRUNC(p_chg_eff_dt) - 1;

CURSOR c_upd_log_kff(c_asg_id   IN ben_ext_chg_evt_log.prmtr_01%TYPE ) IS
SELECT ext_chg_evt_log_id
      ,prmtr_09
  FROM ben_ext_chg_evt_log
 WHERE chg_evt_cd = 'COPTP'
   AND person_id  = p_person_id
   AND prmtr_01   = c_asg_id
   AND prmtr_02   = p_old_val1;

CURSOR c_del_log (c_asg_id   IN ben_ext_chg_evt_log.prmtr_01%TYPE ) IS
SELECT object_version_number
      ,ext_chg_evt_log_id
  FROM ben_ext_chg_evt_log
 WHERE chg_evt_cd = 'COPTP'
   AND person_id  = p_person_id
   AND prmtr_01   = c_asg_id
   AND prmtr_02   = p_old_val1;

l_old_ptp         NUMBER;
l_new_ptp         NUMBER;
l_ovn             NUMBER;
l_ovn1            NUMBER;
l_upd_ovn         NUMBER;
l_id              NUMBER;
l_id1             NUMBER;
l_xst_log_rec     ben_ext_chg_evt_log%ROWTYPE;
l_asg_st_dt       ben_ext_chg_evt_log.prmtr_04%TYPE;
l_asg_ed_dt       ben_ext_chg_evt_log.prmtr_05%TYPE;
l_out_rep_dt      DATE;
l_reporting_dt    ben_ext_chg_evt_log.prmtr_09%TYPE;
l_new_log_cre     NUMBER;
l_ret_val         NUMBER;

BEGIN

--
-- Check if the change event code is COSCKFF
--
IF p_chg_evt_cd = 'COSCKFF' THEN

--
-- Get the reporting date
--
   l_ret_val := get_reporting_date
   (p_effective_date   => fnd_date.canonical_to_date(to_char(TRUNC(p_chg_eff_dt),'YYYY/MM')||'/01')
   ,p_assignment_id    => fnd_number.canonical_to_number(p_prmtr_01)
   ,p_person_id        => p_person_id
   ,p_reporting_date   => l_out_rep_dt );

   l_reporting_dt := fnd_date.date_to_canonical(l_out_rep_dt);
   l_new_log_cre  := 0;

   hr_utility.set_location('GAA -- The change event code is COSCKFF',10 );
   hr_utility.set_location('GAA -- Reporting date is '||l_reporting_dt,10 );
   --
   -- Update the change event log row so that prmtr_09 is
   -- populated with the next reporting date.
   --
   l_upd_ovn := p_object_version_number;

   ben_xcl_upd.upd
       (p_effective_date          => TRUNC(p_effective_date)
       ,p_ext_chg_evt_log_id      => p_ext_chg_evt_log_id
       ,p_chg_evt_cd              => p_chg_evt_cd
       ,p_chg_eff_dt              => p_chg_eff_dt
       ,p_chg_user_id             => p_chg_user_id
       ,p_prmtr_01                => p_prmtr_01
       ,p_prmtr_02                => p_prmtr_02
       ,p_prmtr_03                => p_prmtr_03
       ,p_prmtr_04                => p_prmtr_04
       ,p_prmtr_05                => p_prmtr_05
       ,p_prmtr_06                => p_prmtr_06
       ,p_prmtr_07                => p_prmtr_07
       ,p_prmtr_08                => p_prmtr_08
       ,p_prmtr_09                => l_reporting_dt
       ,p_prmtr_10                => p_prmtr_10
       ,p_person_id               => p_person_id
       ,p_business_group_id       => p_business_group_id
       ,p_object_version_number   => l_upd_ovn);

   hr_utility.set_location('GAA -- Updated prmtr_09 to the reporting date',10 );

   IF p_old_val1 IS NULL and p_new_val1 IS NOT NULL THEN
      --
      -- This is the first time the SC KFF is being assigned
      -- to the assignment . If the value of segment 29 on the
      -- SC KFF is NULL, then the PTP to be recorded is NULL
      -- For ABP Pensions , NULL will be interpreted as 100%
      -- For PGGM it is 0.

      -- Call the API to register the part time percentage change
      -- event.
      NULL;
   ELSIF p_old_val1 IS NOT NULL and p_new_val1 IS NOT NULL THEN
      hr_utility.set_location('GAA -- KFF Id has changed',10 );
      --
      -- Assign appropriate assignment start and end dates
      --
      IF p_prmtr_10 = 'UPDATE' THEN
         l_asg_st_dt := p_prmtr_04;
         l_asg_ed_dt := p_prmtr_05;
      ELSIF p_prmtr_10 = 'CORRECTION' THEN
         l_asg_st_dt := p_prmtr_02;
         l_asg_ed_dt := p_prmtr_03;
      END IF;
      hr_utility.set_location('GAA -- prmtr_10 value is : '||p_prmtr_10,10 );

      -- Make sure that the reporting date is set to the correct value
      -- if the changes are being made for a future date then we use that date
      -- to report the change.
      IF TRUNC(fnd_date.canonical_to_date(l_asg_st_dt)) >
         TRUNC(fnd_date.canonical_to_date(l_reporting_dt)) THEN
         l_reporting_dt := fnd_date.date_to_canonical(add_months(fnd_date.canonical_to_date(TO_CHAR(TRUNC(fnd_date.canonical_to_date(l_asg_st_dt)),'YYYY/MM')||'/01'),1) - 1);
      END IF;

      -- The old KFF id is being replaced by a new one. But it
      -- does not nencessarily mean that there has been a change
      -- in part time percentage. It can be because of other changes that
      -- have happened to the SC KFF segments.

      OPEN c_ptp(fnd_number.canonical_to_number(p_old_val1));
         FETCH c_ptp INTO l_old_ptp;
      CLOSE c_ptp;

      OPEN c_ptp(fnd_number.canonical_to_number(p_new_val1));
         FETCH c_ptp INTO l_new_ptp;
      CLOSE c_ptp;

      IF NVL(l_old_ptp,100) <> NVL(l_new_ptp,100) THEN
      hr_utility.set_location('GAA -- PTP has changed : ',10 );
         --
         -- Check the log rows to see if there has been a change of ptp
         -- event registerted by the old KFF. If this is true,and the
         -- exact same row exists in the db , update it with the changed
         -- ptp and the surrogate key that replaced it.
         --

         OPEN c_log_xst(
                  c_kff_id   => fnd_number.number_to_canonical(p_old_val1)
                 ,c_st_dt    => l_asg_st_dt
                 ,c_ed_dt    => l_asg_ed_dt
                 ,c_rep_dt   => l_reporting_dt
                 ,c_asg_id   => p_prmtr_01);
         FETCH c_log_xst INTO l_xst_log_rec;

         IF c_log_xst%FOUND THEN
            --
            -- Update the existing log with the changed part time percentages
            --
            hr_utility.set_location('GAA -- An existing row is found in the logs: ',10 );
            UPDATE ben_ext_chg_evt_log
               SET new_val1 = fnd_number.number_to_canonical(l_new_ptp)
                  ,old_val1 = fnd_number.number_to_canonical(l_old_ptp)
                  ,prmtr_09 = l_reporting_dt
            WHERE ext_chg_evt_log_id = l_xst_log_rec.ext_chg_evt_log_id;

         ELSIF c_log_xst%NOTFOUND THEN
            hr_utility.set_location('GAA -- Did not find any existing row. Creating new log',10);
            --
            -- Create new log to register that there has been a
            -- change in part time percentage
            --
            ben_xcl_ins.ins
               (p_ext_chg_evt_log_id      => l_id
               ,p_chg_evt_cd              => 'COPTP'
               ,p_chg_eff_dt              => p_chg_eff_dt
               ,p_chg_user_id             => p_chg_user_id
               ,p_prmtr_01                => p_prmtr_01  -- Assignment Id
               ,p_prmtr_02                => p_new_val1  -- New KFF Id
               ,p_prmtr_03                => p_prmtr_10  -- Update or Correction
               ,p_prmtr_04                => l_asg_st_dt -- Start of change
               ,p_prmtr_05                => l_asg_ed_dt -- End of change
               ,p_prmtr_06                => NULL
               ,p_prmtr_07                => NULL
               ,p_prmtr_08                => NULL
               ,p_prmtr_09                => l_reporting_dt -- Reporting Date
               ,p_prmtr_10                => NULL
               ,p_person_id               => p_person_id
               ,p_business_group_id       => p_business_group_id
               ,p_object_version_number   => l_ovn
               ,p_effective_date          => TRUNC(p_effective_date)
               ,p_chg_actl_dt             => p_chg_actl_dt
               ,p_new_val1                => fnd_number.number_to_canonical(l_new_ptp)
               ,p_new_val2                => NULL
               ,p_new_val3                => NULL
               ,p_new_val4                => NULL
               ,p_new_val5                => NULL
               ,p_new_val6                => NULL
               ,p_old_val1                => fnd_number.number_to_canonical(l_old_ptp)
               ,p_old_val2                => NULL
               ,p_old_val3                => NULL
               ,p_old_val4                => NULL
               ,p_old_val5                => NULL
               ,p_old_val6                => NULL);

               l_new_log_cre := 1;
            END IF;

            CLOSE c_log_xst;

      ELSIF NVL(l_old_ptp,100) = NVL(l_new_ptp,100) THEN
      --
      -- Part time percentage has not changed but the flex id is changing.
      -- update the surrogate key in the log tables for any changes
      -- logged by the old KFF id.
      --
      hr_utility.set_location('GAA -- PTP is the same no change. KFF id has changed: ',10 );
         IF p_prmtr_10 = 'UPDATE' THEN
            ben_xcl_ins.ins
               (p_ext_chg_evt_log_id      => l_id1
               ,p_chg_evt_cd              => 'COPTP'
               ,p_chg_eff_dt              => p_chg_eff_dt
               ,p_chg_user_id             => p_chg_user_id
               ,p_prmtr_01                => p_prmtr_01  -- Assignment Id
               ,p_prmtr_02                => p_new_val1  -- New KFF Id
               ,p_prmtr_03                => p_prmtr_10  -- Update or Correction
               ,p_prmtr_04                => l_asg_st_dt -- Start of change
               ,p_prmtr_05                => l_asg_ed_dt -- End of change
               ,p_prmtr_06                => NULL
               ,p_prmtr_07                => NULL
               ,p_prmtr_08                => NULL
               ,p_prmtr_09                => l_reporting_dt -- Reporting Date
               ,p_prmtr_10                => NULL
               ,p_person_id               => p_person_id
               ,p_business_group_id       => p_business_group_id
               ,p_object_version_number   => l_ovn1
               ,p_effective_date          => TRUNC(p_effective_date)
               ,p_chg_actl_dt             => p_chg_actl_dt
               ,p_new_val1                => fnd_number.number_to_canonical(l_new_ptp)
               ,p_new_val2                => NULL
               ,p_new_val3                => NULL
               ,p_new_val4                => NULL
               ,p_new_val5                => NULL
               ,p_new_val6                => NULL
               ,p_old_val1                => fnd_number.number_to_canonical(l_old_ptp)
               ,p_old_val2                => NULL
               ,p_old_val3                => NULL
               ,p_old_val4                => NULL
               ,p_old_val5                => NULL
               ,p_old_val6                => NULL);
               hr_utility.set_location('GAA -- log row to track update of KFF Id . No chages to ptp ',10 );

         END IF; -- If a correction is made to the KFF but ptp did not change

      END IF; -- PTP is not equal

      --
      -- There has been no change in the PTP but the KFF has changed
      -- update the surrogate keys to track the current KFF id in the
      -- change log rows.
      --
      IF p_prmtr_10 = 'UPDATE' THEN
         --
         -- Update any existing log rows based on the changes made
         -- also set the end date in case of an update
         --
         FOR upd_rec IN c_upd_log_kff_upd(c_asg_id => p_prmtr_01) LOOP
            IF trunc(fnd_date.canonical_to_date(upd_rec.prmtr_09)) =
               trunc(fnd_date.canonical_to_date(l_reporting_dt)) THEN
               UPDATE ben_ext_chg_evt_log
                  SET prmtr_05 = fnd_date.date_to_canonical(TRUNC(p_chg_eff_dt)-1)
                     ,prmtr_09 = l_reporting_dt
                WHERE ext_chg_evt_log_id = upd_rec.ext_chg_evt_log_id;
            ELSE
               UPDATE ben_ext_chg_evt_log
                  SET prmtr_05 = fnd_date.date_to_canonical(TRUNC(p_chg_eff_dt)-1)
                WHERE ext_chg_evt_log_id = upd_rec.ext_chg_evt_log_id;
            END IF;
         END LOOP;
         hr_utility.set_location('GAA -- Updated the existing log to set the end as eff dt -1 ',10 );

      ELSIF p_prmtr_10 = 'CORRECTION' THEN
         --
         -- Update any existing log rows based on the changes made
         --
         IF l_new_log_cre = 0 THEN
            FOR upd_rec IN c_upd_log_kff(c_asg_id => p_prmtr_01) LOOP
            IF trunc(fnd_date.canonical_to_date(upd_rec.prmtr_09)) =
               trunc(fnd_date.canonical_to_date(l_reporting_dt)) THEN
               UPDATE ben_ext_chg_evt_log
                  SET prmtr_02 = p_new_val1
                     ,prmtr_09 = l_reporting_dt
                WHERE ext_chg_evt_log_id = upd_rec.ext_chg_evt_log_id;
             ELSE
                UPDATE ben_ext_chg_evt_log
                  SET prmtr_02 = p_new_val1
                WHERE ext_chg_evt_log_id = upd_rec.ext_chg_evt_log_id;
             END IF;
            END LOOP;
         ELSIF l_new_log_cre = 1 THEN
            FOR upd_rec IN c_upd_log_kff_upd(c_asg_id => p_prmtr_01) LOOP
            IF trunc(fnd_date.canonical_to_date(upd_rec.prmtr_09)) =
               trunc(fnd_date.canonical_to_date(l_reporting_dt)) THEN
               UPDATE ben_ext_chg_evt_log
                  SET prmtr_05 = fnd_date.date_to_canonical(TRUNC(p_chg_eff_dt)-1)
                     ,prmtr_09 = l_reporting_dt
                WHERE ext_chg_evt_log_id = upd_rec.ext_chg_evt_log_id;
            ELSE
                   UPDATE ben_ext_chg_evt_log
                  SET prmtr_05 = fnd_date.date_to_canonical(TRUNC(p_chg_eff_dt)-1)
                WHERE ext_chg_evt_log_id = upd_rec.ext_chg_evt_log_id;
            END IF;
            END LOOP;
         END IF; -- check if new logs are created

         hr_utility.set_location('GAA -- Updated the existing log to set the KFF id as the new KFF id ',10 );
       END IF; -- Check for update or correction

   END IF; -- KFF Ids are not equal

 ELSIF p_chg_evt_cd IN ('AAT','DAT','COLN','COSS','COUN'
                       ,'COG','CODB','COM','CCFN'
                       ,'CORC','COPR','APA','COCN','ASEA'
                       ) THEN

--
-- Get the reporting date
--
   l_ret_val := get_reporting_date
   (p_effective_date   => fnd_date.canonical_to_date(to_char(TRUNC(p_chg_eff_dt),'YYYY/MM')||'/01')
   ,p_person_id        => p_person_id
   ,p_reporting_date   => l_out_rep_dt );

   l_reporting_dt := fnd_date.date_to_canonical(l_out_rep_dt);

   hr_utility.set_location('... Reporting date is '||l_reporting_dt,10 );
   --
   -- Update the change event log row so that prmtr_09 is
   -- populated with the next reporting date.
   --
   l_upd_ovn := p_object_version_number;

   ben_xcl_upd.upd
       (p_effective_date          => TRUNC(p_effective_date)
       ,p_ext_chg_evt_log_id      => p_ext_chg_evt_log_id
       ,p_chg_evt_cd              => p_chg_evt_cd
       ,p_chg_eff_dt              => p_chg_eff_dt
       ,p_chg_user_id             => p_chg_user_id
       ,p_prmtr_01                => p_prmtr_01
       ,p_prmtr_02                => p_prmtr_02
       ,p_prmtr_03                => p_prmtr_03
       ,p_prmtr_04                => p_prmtr_04
       ,p_prmtr_05                => p_prmtr_05
       ,p_prmtr_06                => p_prmtr_06
       ,p_prmtr_07                => p_prmtr_07
       ,p_prmtr_08                => p_prmtr_08
       ,p_prmtr_09                => l_reporting_dt
       ,p_prmtr_10                => p_prmtr_10
       ,p_person_id               => p_person_id
       ,p_business_group_id       => p_business_group_id
       ,p_object_version_number   => l_upd_ovn);

   hr_utility.set_location('... -- Updated prmtr_09 to the reporting date',10 );
 ELSIF p_chg_evt_cd = ('COPOS') THEN
  --
-- Get the reporting date
--
   l_ret_val := get_reporting_date
   (p_effective_date   => fnd_date.canonical_to_date(to_char(TRUNC(p_chg_eff_dt),'YYYY/MM')||'/01')
   ,p_person_id        => p_person_id
   ,p_reporting_date   => l_out_rep_dt );

   IF TRUNC(l_out_rep_dt) < TRUNC(to_nl_date(p_old_val1,'DD-MM-RRRR'))  THEN
      l_out_rep_dt :=  TRUNC(to_nl_date(p_old_val1,'DD-MM-RRRR'));
   END IF;

   l_reporting_dt := fnd_date.date_to_canonical(l_out_rep_dt);

   hr_utility.set_location('... Reporting date is '||l_reporting_dt,10 );
   --
   -- Update the change event log row so that prmtr_09 is
   -- populated with the next reporting date.
   --
   l_upd_ovn := p_object_version_number;

   ben_xcl_upd.upd
       (p_effective_date          => TRUNC(p_effective_date)
       ,p_ext_chg_evt_log_id      => p_ext_chg_evt_log_id
       ,p_chg_evt_cd              => p_chg_evt_cd
       ,p_chg_eff_dt              => p_chg_eff_dt
       ,p_chg_user_id             => p_chg_user_id
       ,p_prmtr_01                => p_prmtr_01
       ,p_prmtr_02                => p_prmtr_02
       ,p_prmtr_03                => p_prmtr_03
       ,p_prmtr_04                => p_prmtr_04
       ,p_prmtr_05                => p_prmtr_05
       ,p_prmtr_06                => p_prmtr_06
       ,p_prmtr_07                => p_prmtr_07
       ,p_prmtr_08                => p_prmtr_08
       ,p_prmtr_09                => l_reporting_dt
       ,p_prmtr_10                => p_prmtr_10
       ,p_person_id               => p_person_id
       ,p_business_group_id       => p_business_group_id
       ,p_object_version_number   => l_upd_ovn);

   hr_utility.set_location('... -- Updated prmtr_09 to the reporting date',10 );

ELSIF p_chg_evt_cd = 'COAPP' THEN

   update per_assignment_extra_info
      set aei_information22 = NULL
    where assignment_extra_info_id = fnd_number.canonical_to_number(p_prmtr_03);

END IF; -- If the change event code is COSCKFF


EXCEPTION
   WHEN OTHERS THEN
   RAISE;

END upd_chg_evt;

-- ----------------------------------------------------------------------------
-- |-------------------------< abp_proration >-------------------------------|
-- ----------------------------------------------------------------------------
--
function abp_proration
  (p_business_group_id      in  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned            in  date
  ,p_assignment_id          in  per_all_assignments_f.assignment_id%TYPE
  ,p_amount                 in  number
  ,p_payroll_period         in  varchar2
  ,p_work_pattern           in  varchar2
  ,p_conversion_rule        in  varchar2
  ,p_prorated_amount        out nocopy number
  ,p_error_message          out nocopy varchar2
  ,p_payroll_period_prorate in varchar2
  ,p_override_pension_days  in NUMBER DEFAULT -9999
  ) return NUMBER IS

--
-- Cursor to get the current ptp.
-- this is also used to identify if an EE is a regular EE or
-- a declerant (hourly EE)
--
CURSOR c_cur_ptp (c_eff_dt IN DATE
                 ,c_asg_id IN NUMBER) IS
SELECT LEAST(fnd_number.canonical_to_number(NVL(target.SEGMENT29,'100')),125) ptp
  FROM per_assignments_f asg
      ,hr_soft_coding_keyflex target
WHERE  target.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
  AND  asg.assignment_id = c_asg_id
  AND  target.enabled_flag = 'Y'
  AND  trunc(c_eff_dt) BETWEEN asg.effective_start_date AND
       asg.effective_end_date;

l_current_ptp NUMBER;
l_ret_val     NUMBER;

BEGIN

OPEN c_cur_ptp (p_date_earned,p_assignment_id);
FETCH c_cur_ptp INTO l_current_ptp;
CLOSE c_cur_ptp;

IF l_current_ptp = 0 THEN
   --
   -- Hourly EE do not do any proration.
   --
   p_prorated_amount := ROUND(p_amount/12,2);
   p_error_message   := ' ';
   l_ret_val := 0;
ELSE
   --
   -- Regular EE do normal proration.
   --
   l_ret_val := pqp_pension_functions.prorate_amount
  (p_business_group_id      => p_business_group_id
  ,p_date_earned            => p_date_earned
  ,p_assignment_id          => p_assignment_id
  ,p_amount                 => p_amount
  ,p_payroll_period         => p_payroll_period
  ,p_work_pattern           => p_work_pattern
  ,p_conversion_rule        => p_conversion_rule
  ,p_prorated_amount        => p_prorated_amount
  ,p_error_message          => p_error_message
  ,p_payroll_period_prorate => p_payroll_period_prorate
  ,p_override_pension_days  => p_override_pension_days
  ) ;

END IF;

RETURN l_ret_val;

EXCEPTION
WHEN OTHERS THEN
   p_prorated_amount := 0;
   RETURN 1;

END abp_proration;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Get_Retro_Addnl_Amt >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Any retrospective change in basis over previous year, the
-- contribution needs to be calculated using contribution
-- percentage of the current period.
-- Function calculates all this additional amount, that is
-- paid along with current years premium amount.
--
FUNCTION Get_Retro_Addnl_Amt
        (p_bg_id           IN NUMBER,
         p_date_earned     IN DATE,
         p_asg_id          IN NUMBER,
         p_element_type_id IN NUMBER,
         p_payroll_id      IN NUMBER,
         p_contri_perc     IN NUMBER,
         p_sick_flag       IN VARCHAR2,
         p_dedn_retro_amt  OUT NOCOPY NUMBER,
         p_ee_er_flag      IN VARCHAR2
        ) RETURN NUMBER IS

-- Local Variables
l_addn_ded_retro_amt NUMBER := 0;
l_addn_ded_basis     NUMBER := 0;
l_sick_perc          NUMBER := 0;
l_contri_perc        NUMBER := 0;
l_iv_id_basis        NUMBER := 0;
l_iv_id_pv           NUMBER := 0;
l_error_msg          VARCHAR2(250);
l_ret_val            NUMBER := 1;
l_already_retro_paid NUMBER:= 0;
l_sick_flag          VARCHAR2(2) := 'Y';
l_payroll_prd_name   VARCHAR2(30);
l_prorated_amount    NUMBER := 0;
l_ee_er_flag         VARCHAR2(2);
l_addn_ded_amt_temp  NUMBER := 0;
l_time_span_id       NUMBER := 0;
l_retro_basis_exists NUMBER := 0;

--
-- Cursor to fetch the time span id for Correction
-- over previous year.
--
CURSOR csr_time_span_id IS
SELECT ts.time_span_id
 FROM pay_time_definitions s, pay_time_definitions e, pay_time_spans ts, pay_retro_components prc
 WHERE ts.creator_id = prc.retro_component_id
   AND prc.component_name ='Correction'
   AND prc.legislation_code = 'NL'
   AND ts.creator_type = 'RC'
   AND ts.start_time_def_id = s.time_definition_id
   AND ts.end_time_def_id = e.time_definition_id
   AND s.legislation_code = 'NL'
   AND s.definition_name  = 'Start of Time'
   AND e.legislation_code = 'NL'
   AND e.definition_name  = 'End of Previous Year';

--
-- Cursor to fetch all retro elements' info based on element_type_id, date_earned
-- This Cursor also gets already paid value in Retro for previous year
--
CURSOR csr_scr_ent_val(p_iv_id        IN NUMBER,
                       p_iv_id_pv     IN NUMBER,
                       p_time_span_id IN NUMBER)
IS
SELECT peev1.screen_entry_value basis,
       peev2.screen_entry_value paid,
       pay_paywsmee_pkg.get_original_date_earned(pee.element_entry_id) orig_date_earned
  FROM pay_element_entry_values_f peev1,
       pay_element_entry_values_f peev2,
       pay_element_entries_f pee,
       pay_retro_component_usages prcu,
       pay_retro_components prc,
       pay_element_span_usages pesu
WHERE (prc.component_name ='Adjustment' OR (prc.component_name ='Correction'
                                            AND pesu.TIME_SPAN_ID = p_time_span_id) )
  AND pee.assignment_id = p_asg_id
  AND prc.legislation_code = 'NL'
  AND prcu.retro_component_id = prc.retro_component_id
  AND prcu.creator_id = p_element_type_id
  AND pesu.retro_component_usage_id = prcu.retro_component_usage_id
  AND pesu.retro_element_type_id = pee.element_type_id
  AND pee.element_entry_id = peev1.element_entry_id
  AND peev1.input_value_id = p_iv_id
  AND pee.element_entry_id = peev2.element_entry_id
  AND peev2.input_value_id = p_iv_id_pv
  AND p_date_earned BETWEEN pee.effective_start_date AND pee.effective_end_date
  AND p_date_earned BETWEEN peev1.effective_start_date AND peev1.effective_end_date
  AND TO_NUMBER(TO_CHAR(pay_paywsmee_pkg.get_original_date_earned(pee.element_entry_id),'YYYY'))
      < TO_NUMBER(TO_CHAR(p_date_earned,'YYYY'))
  AND p_date_earned BETWEEN peev2.effective_start_date AND peev2.effective_end_date;

--
-- Cursor to fetch input value id for PAY VALUE
--
CURSOR csr_iv_pv_id(p_time_span_id IN number)
IS
SELECT piv.element_type_id ele_id, piv.input_value_id iv_id
  FROM pay_input_values_f piv,
       pay_retro_component_usages prcu,
       pay_retro_components prc,
       pay_element_span_usages pesu
 WHERE prc.legislation_code = 'NL'
   AND prcu.retro_component_id = prc.retro_component_id
   AND prcu.creator_id = p_element_type_id
   AND (prc.component_name ='Adjustment' OR (prc.component_name ='Correction'
                                             AND pesu.TIME_SPAN_ID = p_time_span_id) )
   AND pesu.retro_component_usage_id = prcu.retro_component_usage_id
   AND piv.name = 'Pay Value'
   AND piv.element_type_id = pesu.retro_element_type_id
   AND p_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date;

--
-- Cursor to fetch input value id based on retro_element_type_id
--
CURSOR csr_iv_id(p_iv_name IN pay_input_values_f.name%TYPE
                ,p_retr_ele_type_id pay_element_types_f.element_type_id%TYPE)
IS
SELECT input_value_id
  FROM pay_input_values_f
 WHERE element_type_id = p_retr_ele_type_id
   AND name = p_iv_name
   AND p_date_earned BETWEEN effective_start_date AND effective_end_date;
--

--Cursor To detect Whether do additional calculation with Old/New functionality.
CURSOR csr_addl_calc
IS
SELECT  NVL(aei_information3,'Y') aei_information3
FROM    per_assignment_extra_info
WHERE   information_type = 'NL_ADDL_CALC'
AND	assignment_id = p_asg_id
--AND	 p_date_earned BETWEEN fnd_date.canonical_to_date(aei_information1) AND fnd_date.canonical_to_date(nvl(aei_information2,'4712/12/31'));
AND     p_date_earned BETWEEN trunc(to_date(substr(aei_information1,1,10),'YYYY/MM/DD'))
                          AND trunc(to_date(substr(nvl(aei_information2,'4712/12/31'),1,10),'YYYY/MM/DD'));

l_addl_calc_flag	per_assignment_extra_info.aei_information3%TYPE;

BEGIN

hr_utility.set_location ('Entering function: pqp_nl_abp_functions.Get_Retro_Addnl_Amt' , 2100);
hr_utility.set_location ('p_bg_id:           '||TO_CHAR(p_bg_id) , 2110);
hr_utility.set_location ('p_date_earned :    '||TO_CHAR(p_date_earned) , 2120);
hr_utility.set_location ('p_asg_id:          '||TO_CHAR(p_asg_id) , 2130);
hr_utility.set_location ('p_element_type_id: '||TO_CHAR(p_element_type_id) , 2140);
hr_utility.set_location ('p_payroll_id:      '||TO_CHAR(p_payroll_id) , 2150);
hr_utility.set_location ('p_contri_perc:     '||TO_CHAR(p_contri_perc) , 2160);
hr_utility.set_location ('p_sick_flag:       '||TO_CHAR(p_sick_flag) , 2170);
hr_utility.set_location ('p_ee_er_flag :     '||TO_CHAR(p_ee_er_flag) , 2170);

-- Assign parameter values to local variables
l_sick_flag   := p_sick_flag;
l_contri_perc := p_contri_perc;
l_ee_er_flag  := p_ee_er_flag;

hr_utility.set_location ('l_sick_flag: '||TO_CHAR(l_sick_flag) , 2180);
hr_utility.set_location ('l_contri_perc: '||TO_CHAR(l_contri_perc) , 2190);
hr_utility.set_location ('l_ee_er_flag : '||TO_CHAR(l_ee_er_flag) , 2200);

OPEN csr_addl_calc;
FETCH csr_addl_calc INTO l_addl_calc_flag;
CLOSE csr_addl_calc;

hr_utility.set_location ('l_addl_calc_flag : '|| NVL(l_addl_calc_flag,'Y') , 2202);

-- If user has entered "No" In Additional Amout Calc EIT then dont calc addl Amt.
IF NVL(l_addl_calc_flag,'Y') = 'Y' THEN

hr_utility.set_location ('Inside EIT If Condition: ', 2205);
	-- Get the time span id for correction previous year
	-- Pass it as parameter to csr_scr_ent_val
	OPEN  csr_time_span_id;
	FETCH csr_time_span_id INTO l_time_span_id;
	CLOSE csr_time_span_id;

	hr_utility.set_location ('Time Span Id: ' || TO_CHAR(l_time_span_id), 2210);

	-- At Run time decide whether the previous year entry is
	-- for Adjustment or Correction.
	-- Based on this, fetch the Input value Id for pay_value
	-- and subsequently fetch the input value ID
	-- for the basis in retro element.
	-- Pass that to the main cursor.
	FOR csr_iv IN csr_iv_pv_id(l_time_span_id)
	LOOP
	   hr_utility.set_location ('csr_iv.ele_id: ' || TO_CHAR(csr_iv.ele_id), 2212);
	   hr_utility.set_location ('csr_iv.iv_id: '  || TO_CHAR(csr_iv.iv_id), 2214);
	   -- Delta in basis is obtained using entry value
	   -- Names of input value differ for EE and ER.
	   IF l_ee_er_flag = 'EE' THEN
	     OPEN csr_iv_id('ABP Employee Pension Basis',csr_iv.ele_id);
	     FETCH csr_iv_id INTO l_iv_id_basis;
	     CLOSE csr_iv_id;
	     hr_utility.set_location ('iv basis id EE: ' || TO_CHAR(l_iv_id_basis), 2220);
	   ELSIF l_ee_er_flag = 'ER' THEN
	     OPEN csr_iv_id('ABP Employer Pension Basis',csr_iv.ele_id);
	     FETCH csr_iv_id INTO l_iv_id_basis;
	     CLOSE csr_iv_id;
	     hr_utility.set_location ('iv basis id ER:' || TO_CHAR(l_iv_id_basis), 2230);
	   ELSE
	     hr_utility.set_location ('Exiting pqp_nl_abp_functions.Get_Retro_addnl_Amt function', 2240);
	     p_dedn_retro_amt := 0;
	     RETURN 1; -- return failure, since parameter passed in not EE or ER*/
	   END IF;

	    -- Run the loop for all previous year retro entries in the current year.
	    -- Add up all additional amount that needs to be paid
	    -- along with current period's premium
	     FOR csr_basis IN csr_scr_ent_val(l_iv_id_basis,
							csr_iv.iv_id,
							l_time_span_id)
	     LOOP

		l_addn_ded_basis     := nvl(fnd_number.canonical_to_number(csr_basis.basis),0);
		l_already_retro_paid := nvl(fnd_number.canonical_to_number(csr_basis.paid),0);

		hr_utility.set_location ('l_addn_ded_basis: ' || l_addn_ded_basis, 2260);
		hr_utility.set_location ('l_already_retro_paid: ' || l_already_retro_paid, 2270);

		/* code for checking the sickness flag as yes or no in the formula */
		IF p_sick_flag = 'Y' THEN
		  hr_utility.set_location ('Sickness flag is Y', 2290);
		  l_ret_val := pqp_nl_abp_functions.get_absence_adjustment
				  (p_asg_id,
				   csr_basis.orig_date_earned, --p_date_earned,
					   p_bg_id,
					   0,
					   l_sick_perc,
					   l_error_msg
					   );
		  hr_utility.set_location ('l_sick_perc: ' || TO_CHAR(l_sick_perc), 2300);
		  hr_utility.set_location ('l_ret_val: '|| TO_CHAR(l_ret_val), 2310);
		  IF l_ret_val = 0 THEN -- Success of previous function call
		    -- Check if Formula is running for EE/ER, else return Zero.
		    -- For EE, sickness amount is deducted from premium.
		    -- For ER, sickness amount is added to premium.
		    IF l_ee_er_flag = 'EE' THEN
			 l_addn_ded_basis := l_addn_ded_basis - (l_addn_ded_basis * l_sick_perc/100);
		    ELSIF l_ee_er_flag = 'ER' THEN
			 l_addn_ded_basis := l_addn_ded_basis + (l_addn_ded_basis * l_sick_perc/100);
		    END IF;
		 --
		    hr_utility.set_location ('l_addn_ded_basis: ' || TO_CHAR(l_addn_ded_basis), 2320);

		    l_addn_ded_retro_amt := l_addn_ded_retro_amt
						    + (l_addn_ded_basis * p_contri_perc/100)
						    - l_already_retro_paid;

		    hr_utility.set_location ('l_addn_ded_retro_amt: ' || TO_CHAR(l_addn_ded_retro_amt), 2330);
		  ELSE -- l_ret_val = 1, previous function call failed
		    l_addn_ded_retro_amt := 0;
		    hr_utility.set_location ('l_addn_ded_retro_amt ' || TO_CHAR(l_addn_ded_retro_amt), 2340);
		  END IF;

		ELSE -- no Sickness is attached
		   hr_utility.set_location ('Sickness flag is N', 2350);
		   l_addn_ded_retro_amt := l_addn_ded_retro_amt
						   + (l_addn_ded_basis * p_contri_perc/100)
						   - l_already_retro_paid ;
		   hr_utility.set_location ('l_addn_ded_retro_amt ' || TO_CHAR(l_addn_ded_retro_amt), 2360);
	     END IF; -- Sickness attached or not.

	    END LOOP; -- iv cursor

	END LOOP; -- Cursor csr_scr_ent_val closed

	--Get the Final Additional amount

	p_dedn_retro_amt := ROUND(NVL(l_addn_ded_retro_amt,0),2); -- final_amt

ELSE

	hr_utility.set_location ('Inside EIT Else Condition: ', 2365);
	p_dedn_retro_amt := 0;

END IF;

hr_utility.set_location ('p_dedn_retro_amt: ' || TO_CHAR(p_dedn_retro_amt), 2370);
hr_utility.set_location ('Returning from pqp_nl_abp_functions.Get_Retro_addnl_Amt function', 2375);

RETURN 0;  -- success

EXCEPTION
WHEN OTHERS THEN
hr_utility.set_location ('Exception occured in pqp_nl_abp_functions.get_retro_addnl_amt', 2380);
p_dedn_retro_amt := 0;
RETURN 1; -- fail

--hr_utility.trace_off;
END Get_Retro_Addnl_Amt;
--
END pqp_nl_abp_functions;

/

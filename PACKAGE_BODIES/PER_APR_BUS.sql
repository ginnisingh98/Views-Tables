--------------------------------------------------------
--  DDL for Package Body PER_APR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APR_BUS" as
/* $Header: peaprrhi.pkb 120.8.12010000.18 2010/05/25 12:18:15 psugumar ship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_apr_bus.';  -- Global package name

-- The following two global variables are only to be used by the
-- return_legislation_code function.

g_appraisal_id number default null;
g_legislation_code varchar2(150) default null;

--  --------------------------------------------------------------------------+
--  |----------------------<  set_security_group_id  >------------------------|
--  --------------------------------------------------------------------------+

   procedure set_security_group_id
   (
    p_appraisal_id                in per_appraisals.appraisal_id%TYPE
    ,p_associated_column1 in varchar2 default null
   ) is

  -- Declare cursor

     cursor csr_sec_grp is
       select inf.org_information14
      from hr_organization_information inf
         , per_appraisals  apr
     where apr.appraisal_id = p_appraisal_id
       and inf.organization_id = apr.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';

  -- Local variables

  l_security_group_id number;
  l_proc              varchar2(72) := g_package||'set_security_group_id';

  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Ensure that all the mandatory parameter are not null

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'appraisal_id',
                             p_argument_value => p_appraisal_id);

  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  if csr_sec_grp%notfound then
    close csr_sec_grp;

    -- The primary key is invalid therefore we must error

    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_multi_message.add(p_associated_column1 =>
                         nvl(p_associated_column1,'PER_APPRAISALS.PERSON_ID'));
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end set_security_group_id;


--ExEmp Enhancements
--  --------------------------------------------------------------------------+
--  |----------------------<  chk_future_termination_exist >------------------------|
--  --------------------------------------------------------------------------+

PROCEDURE chk_future_termination_exist (
   p_appraisee_person_id     IN   per_people_f.person_id%TYPE,
   p_appraisal_template_id   IN   per_appraisals.appraisal_template_id%TYPE
)
IS
   --
   l_proc                 VARCHAR2 (72) := g_package || 'chk_future_termination_exist';

   --
   CURSOR csr_is_future_term_exist
   IS
      SELECT 'Y'
        FROM DUAL
       WHERE EXISTS (
                SELECT NULL
                  FROM per_periods_of_service ppser
                 WHERE person_id = p_appraisee_person_id
                   AND ppser.date_start = (SELECT MAX (date_start)
                                             FROM per_periods_of_service
                                            WHERE person_id = ppser.person_id)
                   AND NVL (ppser.actual_termination_date, TRUNC (SYSDATE)) > TRUNC (SYSDATE)
                UNION
                SELECT NULL
                  FROM per_periods_of_placement ppser
                 WHERE person_id = p_appraisee_person_id
                   AND ppser.date_start = (SELECT MAX (date_start)
                                             FROM per_periods_of_placement
                                            WHERE person_id = ppser.person_id)
                   AND NVL (ppser.actual_termination_date, TRUNC (SYSDATE)) > TRUNC (SYSDATE));

   CURSOR csr_template_info
   IS
      SELECT show_future_term_employee
        FROM per_appraisal_templates
       WHERE appraisal_template_id = p_appraisal_template_id;

   l_show_term_employee   VARCHAR2 (10) := 'Y';
   l_future_term_exist    VARCHAR2 (2)  := 'N';
BEGIN
   hr_utility.set_location ('Entering:' || l_proc, 10);

   OPEN csr_template_info;

   FETCH csr_template_info
    INTO l_show_term_employee;

   CLOSE csr_template_info;

   IF (NVL (l_show_term_employee, 'Y') <> 'Y')
   THEN
      OPEN csr_is_future_term_exist;

      FETCH csr_is_future_term_exist
       INTO l_future_term_exist;

      CLOSE csr_is_future_term_exist;

      IF (NVL (l_future_term_exist, 'N') = 'Y')
      THEN
         fnd_message.set_name ('PER', 'HR_34297_FUTURE_TERM_EXIST');
         fnd_message.raise_error;
      END IF;
   END IF;

   hr_utility.set_location ('Leaving:' || l_proc, 970);
EXCEPTION
   WHEN app_exception.application_exception
   THEN
      IF hr_multi_message.exception_add (p_associated_column1 => 'PER_APPRAISALS.APPRAISAL_DATE')
      THEN
         hr_utility.set_location (' Leaving:' || l_proc, 980);
         RAISE;
      END IF;

      hr_utility.set_location (' Leaving:' || l_proc, 990);
END chk_future_termination_exist;




-- -------------------------------------------------------------------------+
-- |----------------------< chk_non_updateable_args >-----------------------|
-- -------------------------------------------------------------------------+

Procedure chk_non_updateable_args(p_rec in per_apr_shd.g_rec_type) is

  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema

  if not per_apr_shd.api_updating
                (p_appraisal_id             => p_rec.appraisal_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;

  hr_utility.set_location(l_proc, 6);

  if p_rec.business_group_id <> per_apr_shd.g_old_rec.business_group_id then
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'BUSINESS_GROUP_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
  elsif p_rec.appraisal_template_id <> per_apr_shd.g_old_rec.appraisal_template_id then
     hr_utility.set_location(l_proc, 7);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'APPRAISAL_TEMPLATE_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
  elsif p_rec.appraisee_person_id <> per_apr_shd.g_old_rec.appraisee_person_id then
     hr_utility.set_location(l_proc, 8);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'APPRAISEE_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
   elsif p_rec.assignment_id <> per_apr_shd.g_old_rec.assignment_id then
     hr_utility.set_location(l_proc, 9);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'ASSIGNMENT_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
   elsif p_rec.assignment_start_date <> per_apr_shd.g_old_rec.assignment_start_date then
     hr_utility.set_location(l_proc, 10);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'ASSIGNMENT_START_DATE'
     ,p_base_table => per_per_shd.g_tab_nam
     );
   elsif p_rec.assignment_business_group_id <> per_apr_shd.g_old_rec.assignment_business_group_id then
     hr_utility.set_location(l_proc, 11);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'ASSIGNMENT_BUSINESS_GROUP_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
   elsif p_rec.assignment_organization_id <> per_apr_shd.g_old_rec.assignment_organization_id then
     hr_utility.set_location(l_proc, 12);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'ASSIGNMENT_ORGANIZATION_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
   elsif p_rec.assignment_job_id <> per_apr_shd.g_old_rec.assignment_job_id then
     hr_utility.set_location(l_proc, 13);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'ASSIGNMENT_JOB_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
   elsif p_rec.assignment_position_id <> per_apr_shd.g_old_rec.assignment_position_id then
     hr_utility.set_location(l_proc, 14);
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'ASSIGNMENT_POSITION_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );

   end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);

end chk_non_updateable_args;

-- --------------------------------------------------------------------------+
-- |--------------------------< chk_open >-----------------------------------|
-- --------------------------------------------------------------------------+

-- Description:
--  Validates that p_open exists in HR_LOOKUPS, where the lookup type is
--  'YES_NO'.  A null value is assumed to be valid.

-- Pre-requisites:
--  None.

-- IN Parameters:
--  p_open
--  p_effective_date

-- Post Success:
--  Processing continues if the open column is valid against the lookup

-- Post Failure:
--  An application error is raised, and processing is terminated if OPEN is
--  invalid.

-- Developer/Implementation Notes:
--  None.

-- Access Status:
--  Internal Row Handler Use Only.

-- ---------------------------------------------------------------------------+
procedure chk_open
  (p_open in per_appraisals.open%TYPE
  ,p_effective_date in date
  )
  is

  l_proc varchar2(72) := g_package || 'chk_open';

begin

  hr_utility.set_location('Entering: '||l_proc,10);

  if (p_open <> null) and
     (hr_api.not_exists_in_hr_lookups
            (p_effective_date => p_effective_date
            ,p_lookup_type    => 'YES_NO'
            ,p_lookup_code    => p_open
            )) then
      -- p_open does not exist in lookup, thus error.
      fnd_message.set_name('PER','PER_52459_APR_INVALID_OPEN_TYPE');
      fnd_message.raise_error;
  end if;

  hr_utility.set_location('Leaving: '||l_proc,20);

EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_APPRAISALS.OPEN'
             ) then
          raise;
        end if;
end chk_open;

-- ---------------------------------------------------------------------------+
-- |---------------------< chk_update_allowed >-------------------------------|
-- ---------------------------------------------------------------------------+

-- Description:
--  Validates that update is allowed, by checking that on APPRAISAL_DATE,
--  the system_person_type of appraisee_person_id is not 'EX_EMP' or
--  'EX_EMP_APL'.
--  Also - that OPEN is 'Y', or is being changed to 'Y'.

-- Pre-requisites:
--  p_open is a valid parameter

-- IN Parameters:
--  p_appraisee_person_id
--  p_appraisal_date
--  p_open

-- Post Success:
--  Processing continues if the update is allowed.

-- Post Failure:
--  An application error is raised, and processing is terminated, if it is
--  found that the update is invalid.

-- Developer/Implementation Notes:
--  None.

-- Access Status:
--  Internal Row Handler Use Only

-- ---------------------------------------------------------------------------+
procedure chk_update_allowed
  (p_rec in per_apr_shd.g_rec_type
  )
  is

  l_proc varchar2(72) := g_package || 'chk_update_allowed';
  l_type per_person_types.system_person_type%TYPE;

  -- Cursor to fetch system_person_type for appraisee_person_id

   cursor csr_fetch_type is
    select ppt.system_person_type
      from per_person_types ppt
	     , per_person_type_usages_f ptu
         , per_all_people_f per
     where per.person_id = p_rec.appraisee_person_id
       and p_rec.appraisal_date BETWEEN per.effective_start_date AND per.effective_end_date
	   AND ptu.person_id = per.person_id
       and p_rec.appraisal_date BETWEEN ptu.effective_start_date AND ptu.effective_end_date
       and ptu.person_type_id = ppt.person_type_id;

       l_allow_appraisal BOOLEAN := FALSE;

   cursor csr_allow_term_update is
    SELECT
     'Y'
    FROM
      per_people_f ppf,
      per_appraisals appr,
      per_appraisal_templates apprt
    WHERE person_id = p_rec.appraisee_person_id
      AND appr.appraisal_id=p_rec.appraisal_id
      AND trunc(sysdate) BETWEEN effective_start_date AND effective_end_date
      and appr.appraisal_template_id = apprt.appraisal_template_id
      AND ( ppf.CURRENT_NPW_FLAG  is  null and  ppf.CURRENT_EMPLOYEE_FLAG is  null  and nvl(apprt.SHOW_TERM_CONTIGENT,nvl(apprt.SHOW_TERM_EMPLOYEE,'N'))='Y' );

       l_allow_term_emp varchar2(2) := 'N';

begin

  hr_utility.set_location('Entering: '||l_proc,10);

  -- Fetch person_type

  for i in csr_fetch_type
  LOOP
     -- IF i.system_person_type IN ('CWK','EMP') THEN Commented for 8208886
  -- Added a new OR condition that would allow delete appraisal for ex empoyees
  IF ( i.system_person_type IN ('CWK','EMP') ) OR
         ( ( (i.system_person_type = 'EX_EMP') or (i.system_person_type = 'EX_EMP_APL') )
            AND
           (p_rec.appraisal_system_status = 'DELETED')) THEN

       l_allow_appraisal := TRUE;
	 END IF;
  END LOOP;

--9733043 Fix
/*  open csr_allow_term_update;
  fetch csr_allow_term_update into l_allow_term_emp;
  if csr_allow_term_update%notfound then
   close csr_allow_term_update;
  end if;

     -- Update not allowed
  IF NOT l_allow_appraisal  AND  l_allow_term_emp  ='N' THEN
         fnd_message.set_name('PER','PER_52456_APR_UPD_EX_EMP_APR');
         fnd_message.raise_error;
  END IF;*/

    IF NOT fnd_function.test('HR_VIEW_SYSAPPR_MGR_SS') THEN  -- HR Prof appraisal function
	  open csr_allow_term_update;
	  fetch csr_allow_term_update into l_allow_term_emp;
	  if csr_allow_term_update%notfound then
	   close csr_allow_term_update;
	  end if;
	  hr_utility.set_location('l_allow_term_emp: '||l_allow_term_emp,10);
	     -- Update not allowed
	  IF NOT l_allow_appraisal  AND  l_allow_term_emp  ='N' THEN
		 fnd_message.set_name('PER','PER_52456_APR_UPD_EX_EMP_APR');
		 fnd_message.raise_error;
	  END IF;
	  hr_utility.set_location('l_allow_term_emp: '||l_allow_term_emp,10);
	--ExEmpEnhancements
	  per_apr_bus.chk_future_termination_exist (
		 p_appraisee_person_id => p_rec.appraisee_person_id ,
		 p_appraisal_template_id  => p_rec.appraisal_template_id
	 );
   END IF;


  -- Check also that the appraisal is OPEN.

  if (p_rec.open = 'N') then
    -- Check that columns arent being updated (except OPEN column)

    if p_rec.appraiser_person_id
         <> per_apr_shd.g_old_rec.appraiser_person_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.appraisal_date
         <> per_apr_shd.g_old_rec.appraisal_date then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.appraisal_period_end_date
         <> per_apr_shd.g_old_rec.appraisal_period_end_date then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.appraisal_period_start_date
         <> per_apr_shd.g_old_rec.appraisal_period_start_date then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.type
         <> per_apr_shd.g_old_rec.type then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.next_appraisal_date
         <> per_apr_shd.g_old_rec.next_appraisal_date then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.status
         <> per_apr_shd.g_old_rec.status then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.comments
         <> per_apr_shd.g_old_rec.comments then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.overall_performance_level_id
         <> per_apr_shd.g_old_rec.overall_performance_level_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute_category
         <> per_apr_shd.g_old_rec.attribute_category then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute1
         <> per_apr_shd.g_old_rec.attribute1 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute2
         <> per_apr_shd.g_old_rec.attribute2 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute3
         <> per_apr_shd.g_old_rec.attribute3 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute4
         <> per_apr_shd.g_old_rec.attribute4 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute5
         <> per_apr_shd.g_old_rec.attribute5 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute6
         <> per_apr_shd.g_old_rec.attribute6 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute7
         <> per_apr_shd.g_old_rec.attribute7 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute8
         <> per_apr_shd.g_old_rec.attribute8 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute9
         <> per_apr_shd.g_old_rec.attribute9 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute10
         <> per_apr_shd.g_old_rec.attribute10 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute11
         <> per_apr_shd.g_old_rec.attribute11 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute12
         <> per_apr_shd.g_old_rec.attribute12 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute13
         <> per_apr_shd.g_old_rec.attribute13 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute14
         <> per_apr_shd.g_old_rec.attribute14 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute15
         <> per_apr_shd.g_old_rec.attribute15 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute16
         <> per_apr_shd.g_old_rec.attribute16 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute17
         <> per_apr_shd.g_old_rec.attribute17 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute18
         <> per_apr_shd.g_old_rec.attribute18 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute19
         <> per_apr_shd.g_old_rec.attribute19 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.attribute20
         <> per_apr_shd.g_old_rec.attribute20 then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.system_type
         <> per_apr_shd.g_old_rec.system_type then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.system_params
         <> per_apr_shd.g_old_rec.system_params then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.appraisee_access
         <> per_apr_shd.g_old_rec.appraisee_access then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.main_appraiser_id
         <> per_apr_shd.g_old_rec.main_appraiser_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.assignment_id
         <> per_apr_shd.g_old_rec.assignment_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.assignment_start_date
         <> per_apr_shd.g_old_rec.assignment_start_date then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.assignment_business_group_id
         <> per_apr_shd.g_old_rec.assignment_business_group_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.assignment_organization_id
         <> per_apr_shd.g_old_rec.assignment_organization_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.assignment_job_id
         <> per_apr_shd.g_old_rec.assignment_job_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.assignment_position_id
         <> per_apr_shd.g_old_rec.assignment_position_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.assignment_grade_id
         <> per_apr_shd.g_old_rec.assignment_grade_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.potential_readiness_level
         <> per_apr_shd.g_old_rec.potential_readiness_level then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.potential_short_term_workopp
         <> per_apr_shd.g_old_rec.potential_short_term_workopp then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.potential_long_term_workopp
         <> per_apr_shd.g_old_rec.potential_long_term_workopp then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.potential_details
         <> per_apr_shd.g_old_rec.potential_details then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;
    elsif p_rec.event_id
         <> per_apr_shd.g_old_rec.event_id then
       fnd_message.set_name('PER','PER_52458_APR_UPD_PUBLSHD_APR');
       fnd_message.raise_error;

    end if;


  end if;

  hr_utility.set_location('Leaving: '||l_proc,20);

end chk_update_allowed;


-- ---------------------------------------------------------------------------+
-- |--------------------< chk_appraiser_person_id >---------------------------|
-- ---------------------------------------------------------------------------+

-- Description:
--  Validates that, on update, the appraiser_person_id cannot be updated
--  if an answer set exists.
--  flemonni added and appraiser_person_id is being changed

-- Pre-requisites:
--   None.

-- IN Parameters:
--  p_appraisal_id

-- Post Success:
--  Processing continues, and the appraiser_person_id is updated if an answer
--  set does not already exist.

-- Post Failure:
--  An application error is raised, and processing is terminated if an answer
-- set already exists.

-- Developer/Implementation Notes:
--  None.

-- Access Status:
--  Internal Row Handler Use Only.

-- ---------------------------------------------------------------------------+
procedure chk_appraiser_person_id
  (p_appraisal_id in per_appraisals.appraisal_id%TYPE
  )
  is

  l_proc varchar2(72) := g_package || 'chk_appraiser_person_id';
  l_exists varchar2(1);

  -- Cursor to determine id an answer set exists for the current
  -- appraiser_person_id.

  cursor csr_answer_set_exists is
    select null
      from hr_quest_answers qsa
     where p_appraisal_id = qsa.type_object_id
       and qsa.type = 'APPRAISAL';

begin

  hr_utility.set_location('Entering: '|| l_proc,10);

  -- flemonni added

  if p_appraisal_id <> per_apr_shd.g_old_rec.appraisal_id then
    open csr_answer_set_exists;
    fetch csr_answer_set_exists into l_exists;

    if csr_answer_set_exists%found then
       -- answer set does exists, thus cannot update => error!
       close csr_answer_set_exists;
       fnd_message.set_name('PER','PER_52457_APR_UPD_COMPLTD_APR');
       fnd_message.raise_error;
    end if;
    close csr_answer_set_exists;
  else
    null;
  end if;

  hr_utility.set_location('Leaving: '||l_proc,20);

EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_APPRAISALS.APPRAISER_PERSON_ID'
             ) then
          raise;
        end if;

end chk_appraiser_person_id;


----------------------------------------------------------------------------+
---------------------------<chk_appraisal_template>-------------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the appraisal template exists and is within the same business
--     group as that of appraisal
--   - Validates that the appraisal template exists as of the users effetcive date

--  Pre_conditions:


--  In Arguments:
--    p_appraisal_template_id
--    p_business_group_id
--    p_effective_date

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- appraisal template does not exist
--      -- appraisal template exists but not with the same business group
--	-- appraisal_template_id is not set
--	-- appraisal template exists but not as of the effective date

--  Access Status
--    Internal Table Handler Use Only.


procedure chk_appraisal_template
(p_appraisal_template_id     in      per_appraisals.appraisal_template_id%TYPE
,p_business_group_id	     in	     per_appraisals.business_group_id%TYPE
,p_effective_date	     in	     date
)
is

	l_exists	     varchar2(1);
        l_proc               varchar2(72)  :=  g_package||'chk_appraisal_template';
        l_business_group_id  per_appraisals.business_group_id%TYPE;


	-- Cursor to check if appraisal exists

	Cursor csr_appraisal_exists
          is
	select  business_group_id
	from	per_appraisal_templates
	where   appraisal_template_id = p_appraisal_template_id;

	-- Cursor to check if the appraisal template is
	-- valid as of users effective date

	Cursor csr_appraisal_template_valid
          is
	select  'Y'
	from	per_appraisal_templates
	where   appraisal_template_id = p_appraisal_template_id
	and     p_effective_date between
		nvl(date_from,hr_api.g_sot) and nvl(date_to,hr_api.g_eot);


begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );


   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );

  hr_utility.set_location('Entering:'|| l_proc, 2);

  -- check if the user has entered a appraisal_template_id
  -- It is mandatory column.

     if p_appraisal_template_id is null then
       hr_utility.set_message(800,'HR_52256_APR_TEMP_MANDATORY');
       hr_utility.raise_error;
     end if;

  hr_utility.set_location(l_proc, 3);

     if p_appraisal_template_id is not null then
        open csr_appraisal_exists;
        fetch csr_appraisal_exists into l_business_group_id;
	if csr_appraisal_exists%notfound then
            close csr_appraisal_exists;
            hr_utility.set_message(801,'HR_52246_APR_TEMP_NOT_EXIST');
            hr_utility.raise_error;
	end if;
        close csr_appraisal_exists;

	-- check if appraisal template is in the same business group

        if l_business_group_id <> p_business_group_id then
	       hr_utility.set_message(801,'HR_51883_TEMP_DIFF_BUS_GRP');
	       hr_utility.raise_error;
        end if;

	-- check if appraisal template exists as of users effective date

	open csr_appraisal_template_valid;
	fetch csr_appraisal_template_valid into l_exists;
	if csr_appraisal_template_valid%notfound then
            close csr_appraisal_template_valid;
            hr_utility.set_message(801,'HR_51884_APR_TEMP_NOT_DATE');
            hr_utility.raise_error;
	end if;
        close csr_appraisal_template_valid;
     end if;

   hr_utility.set_location(l_proc, 4);

  hr_utility.set_location('Leaving: '|| l_proc, 10);
EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_APPRAISALS.APPRAISAL_TEMPLATE_ID'
             ) then
          raise;
        end if;

end chk_appraisal_template;

----------------------------------------------------------------------------+
----------------------------<chk_appraisee_appraiser>-----------------------+
----------------------------------------------------------------------------+

--  Description:
--   - Validates that the person_id (appraisee_id or appraiser_id) have been entered
--     as these are mandatory fields
--   - Validates that the person is in the same business group as the appraisal
--   - Validates that the person is valid as of appraisal date

--  Pre_conditions:

--  In Arguments:
--    p_person_id
--    p_effective_date
--    p_business_group_id
--    p_person_type

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- effective_date is not set
--      -- person is not in the same business group as the appraisal
--	-- person does not exist as of effective date

--  Access Status
--    Internal Table Handler Use Only.


procedure chk_appraisee_appraiser
(p_person_id    	     in      per_people_f.person_id%TYPE
,p_business_group_id	     in	     per_appraisals.business_group_id%TYPE
,p_effective_date	     in	     date
,p_person_type		     in	     varchar2
)
is

	l_exists	     varchar2(1);
	l_business_group_id  per_appraisals.business_group_id%TYPE;
        l_proc               varchar2(72)  :=  g_package||'chk_appraisee_appraiser';
    lv_cross_business_group varchar2(10); -- bug 1980440 fix


	-- Cursor to check if the person_exists

	Cursor csr_person_bg
          is
	select  business_group_id
	from	per_all_people_f
	where   person_id = p_person_id;

    -- bug 1980440 fix
	-- WE NEED to use different cursors as Appraiser can be changed to
    -- a person from a different BG
	-- Cursor to check if the person_exists

	Cursor csr_cbg_person_bg
          is
	select  business_group_id
	from	per_all_people_f
	where   person_id = p_person_id;

	-- Cursor to check if person is valid
	-- as of effective date

	Cursor csr_person_valid_date
          is
	select  'Y'
	from	per_all_people_f
	where   person_id = p_person_id
	and	p_effective_date between
		effective_start_date and nvl(effective_end_date,hr_api.g_eot);

    -- bug 1980440 fix
	-- WE NEED to use different cursors as Appraiser can be changed to
    -- a person from a different BG
	-- Cursor to check if person is valid
	-- as of effective date

	Cursor csr_cbg_person_valid_date
          is
	select  'Y'
	from	per_all_people_f
	where   person_id = p_person_id
	and	p_effective_date between
		effective_start_date and nvl(effective_end_date,hr_api.g_eot);

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

   if (p_person_id is NULL) then
	if p_person_type = 'APPRAISEE' then
          	hr_utility.set_message(801, 'HR_51887_APR_APPRAISEE_NULL');
          	hr_utility.raise_error;
	elsif p_person_type = 'APPRAISER' then
		hr_utility.set_message(801, 'HR_51888_APR_APPRAISER_NULL');
          	hr_utility.raise_error;
  	end if;
   end if;

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );


  hr_utility.set_location('Entering:'|| l_proc, 2);

  -- bug 1980440 fix starts
  -- if CROSS_BUSINESS_GROUP option is enabled we shouldn't do a comparison
  -- between appraisers BG and appraisee BG as they may be different
  lv_cross_business_group := fnd_profile.value('HR_CROSS_BUSINESS_GROUP');

     if p_person_id is not null then
       IF lv_cross_business_group <> 'Y' THEN
          open csr_person_bg;
          fetch csr_person_bg into l_business_group_id;
	      if csr_person_bg%notfound then
            close csr_person_bg;
            hr_utility.set_message(801,'HR_51889_APR_PERSON_NOT_EXIST');
            hr_utility.raise_error;
	      end if;
          close csr_person_bg;
       ELSE
          open csr_cbg_person_bg;
          fetch csr_cbg_person_bg into l_business_group_id;
	      if csr_cbg_person_bg%notfound then
            close csr_cbg_person_bg;
            hr_utility.set_message(801,'HR_51889_APR_PERSON_NOT_EXIST');
            hr_utility.raise_error;
	      end if;
          close csr_cbg_person_bg;
       END IF;

       IF lv_cross_business_group <> 'Y' THEN
	      hr_utility.set_location(l_proc, 3);
	      -- check if business group match
	      if p_business_group_id <> l_business_group_id then
	        hr_utility.set_message(801,'HR_51890_APR_PERSON_DIFF_BG');
            hr_utility.raise_error;
	      end if;
       end if;

	   hr_utility.set_location(l_proc, 4);
	   -- check if person is valid as of effective date
       IF lv_cross_business_group <> 'Y' THEN
	      open csr_person_valid_date;
          fetch csr_person_valid_date into l_exists;
	      if csr_person_valid_date%notfound then
            close csr_person_valid_date;
            hr_utility.set_message(801,'HR_51891_APR_PERSON_DATE_RANGE');
            hr_utility.raise_error;
	      end if;
            close csr_person_valid_date;
       ELSE
          open csr_cbg_person_valid_date;
          fetch csr_cbg_person_valid_date into l_exists;
	      if csr_cbg_person_valid_date%notfound then
            close csr_cbg_person_valid_date;
            hr_utility.set_message(801,'HR_51891_APR_PERSON_DATE_RANGE');
            hr_utility.raise_error;
	      end if;
            close csr_cbg_person_valid_date;
       END IF;
       -- bug 1980440 fix ends
   end if;

   hr_utility.set_location(l_proc, 5);

  hr_utility.set_location('Leaving: '|| l_proc, 10);

end chk_appraisee_appraiser;

------------------------------------------------------------------------------+
------------------------------<chk_main_appraiser_id>-------------------------+
------------------------------------------------------------------------------+
--  Description:
--   - Validates that the main appraiser is valid as of effective date.

--  Pre_conditions:

--  In Arguments:
--    p_main_appraiser_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- effective_date is not set
--	-- main appraiser does not exist as of effective date

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_main_appraiser_id
(p_main_appraiser_id  	     in      per_appraisals.main_appraiser_id%TYPE
,p_business_group_id	     in	     per_appraisals.business_group_id%TYPE
,p_effective_date            in      date

)
is

--
l_proc               varchar2(72)  :=  g_package||'chk_main_appraiser_id';
lv_cross_business_group varchar2(10);
l_exists	     varchar2(1);
l_business_group_id  per_appraisals.business_group_id%TYPE;

--

	-- Cursor to check if person is valid
	-- as of effective date

	Cursor csr_person_valid_date
          is
        select  'Y'
        from    per_all_people_f
        where   person_id = p_main_appraiser_id
        and     business_group_id = p_business_group_id
        and     p_effective_date between
                effective_start_date and nvl(effective_end_date,hr_api.g_eot);

-- Cursor to check if person is valid
	-- as of effective date

	Cursor csr_cbg_person_valid_date
          is
        select  'Y'
        from    per_all_people_f
        where   person_id = p_main_appraiser_id
        and     p_effective_date between
                effective_start_date and nvl(effective_end_date,hr_api.g_eot);


begin

hr_utility.set_location('Entering:'|| l_proc, 5);

lv_cross_business_group := fnd_profile.value('HR_CROSS_BUSINESS_GROUP');

	IF p_main_appraiser_id IS NULL  OR p_main_appraiser_id = -1 THEN
		return;
	END IF;

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );

hr_utility.set_location( l_proc, 6);

	   -- check if person is valid as of effective date
       IF lv_cross_business_group <> 'Y' THEN
              hr_utility.set_location( l_proc, 7);
	      open csr_person_valid_date;
          fetch csr_person_valid_date into l_exists;
	      if csr_person_valid_date%notfound then
	      hr_utility.set_location( l_proc, 8);
            close csr_person_valid_date;
            hr_utility.set_message(800,'HR_449030_MA_PERSON_DATE_RANGE');
            hr_utility.raise_error;
	      end if;
            close csr_person_valid_date;
       ELSE
          open csr_cbg_person_valid_date;
          hr_utility.set_location( l_proc, 9);
          fetch csr_cbg_person_valid_date into l_exists;
	      if csr_cbg_person_valid_date%notfound then
	    hr_utility.set_location( l_proc, 10);
            close csr_cbg_person_valid_date;
            hr_utility.set_message(800,'HR_449030_MA_PERSON_DATE_RANGE');
            hr_utility.raise_error;
	      end if;
            close csr_cbg_person_valid_date;
       END IF;
       -- bug 1980440 fix ends
hr_utility.set_location('Leaving:'|| l_proc, 10);

EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_APPRAISALS.MAIN_APPRAISER_ID'
             ) then
          raise;
        end if;

end chk_main_appraiser_id;
------------------------------------------------------------------------------+
------------------------------<chk_appraisal_type>----------------------------+
------------------------------------------------------------------------------+

--  Description:
--   - Validates that a valid appraisal type is set
--   - Validates that it is exists as lookup code for that type

--  Pre_conditions:

--  In Arguments:
--    p_appraisal_id
--    p_appraisal_type
--    p_object_version_number
--    p_effective_date

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - appraisal type is invalid

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_appraisal_type
(p_appraisal_id              in      per_appraisals.appraisal_id%TYPE
,p_object_version_number     in      per_appraisals.object_version_number%TYPE
,p_type	     		     in      per_appraisals.type%TYPE
,p_effective_date            in      date
)
is

        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_appraisal_type';


begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );

  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for appraisal type flag has changed

  l_api_updating := per_apr_shd.api_updating
         (p_appraisal_id           => p_appraisal_id
         ,p_object_version_number  => p_object_version_number);

  if (  (l_api_updating and nvl(per_apr_shd.g_old_rec.type,
                                hr_api.g_varchar2)
                        <> nvl(p_type,hr_api.g_varchar2)
         ) or
        (NOT l_api_updating)
      ) then

     hr_utility.set_location(l_proc, 2);


     -- If appraisal type is not null then
     -- check if the value exists in hr_lookups
     -- where the lookup_type = 'APPRAISAL_TYPE'


     if p_type is not null then
       if hr_api.not_exists_in_hr_lookups
            (p_effective_date   => p_effective_date
            ,p_lookup_type      => 'APPRAISAL_TYPE'
            ,p_lookup_code      => p_type
            ) then
            -- error invalid type
          hr_utility.set_message(801,'HR_51892_APR_INVALID_TYPE');
          hr_utility.raise_error;
       end if;
       hr_utility.set_location(l_proc, 3);
     end if;
  end if;
 hr_utility.set_location('Leaving: '|| l_proc, 10);
EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_APPRAISALS.APPRAISAL_TYPE'
             ) then
          raise;
        end if;


end chk_appraisal_type;

------------------------------------------------------------------------------+
------------------------------<chk_appraisal_status>--------------------------+
------------------------------------------------------------------------------+

--  Description:
--   - Validates that a valid appraisal status set
--   - Validates that it is exists as lookup code for that type

--  Pre_conditions:

--  In Arguments:
--    p_appraisal_id
--    p_status
--    p_object_version_number
--    p_effective_date

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - appraisal status is invalid

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_appraisal_status
(p_appraisal_id              in      per_appraisals.appraisal_id%TYPE
,p_object_version_number     in      per_appraisals.object_version_number%TYPE
,p_status		     in      per_appraisals.status%TYPE
,p_effective_date            in      date
)
is

        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_appraisal_status';


begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for appraisal status flag has changed

  l_api_updating := per_apr_shd.api_updating
         (p_appraisal_id           => p_appraisal_id
         ,p_object_version_number  => p_object_version_number);

  if (  (l_api_updating and nvl(per_apr_shd.g_old_rec.status,
                                hr_api.g_varchar2)
                        <> nvl(p_status,hr_api.g_varchar2)
         ) or
        (NOT l_api_updating)
      ) then

     hr_utility.set_location(l_proc, 2);


     -- If appraisal status is not null then
     -- check if the value exists in hr_lookups
     -- where the lookup_type = 'APPRAISAL_ASSESSMENT_STATUS'


     if p_status is not null then
       if hr_api.not_exists_in_hr_lookups
            (p_effective_date   => p_effective_date
            ,p_lookup_type      => 'APPRAISAL_ASSESSMENT_STATUS'
            ,p_lookup_code      => p_status
            ) then
            -- error invalid type
          hr_utility.set_message(801,'HR_51893_APR_INVALID_STATUS');
          hr_utility.raise_error;
       end if;
       hr_utility.set_location(l_proc, 3);
    end if;
 end if;
 hr_utility.set_location('Leaving: '|| l_proc, 10);

 EXCEPTION
 when app_exception.application_exception then
         if hr_multi_message.exception_add
              (p_associated_column1      => 'PER_APPRAISALS.APPRAISAL_STATUS'
              ) then
           raise;
         end if;

end chk_appraisal_status;


-- ---------------------------------------------------------------------------+
-- |----------------------< chk_group_date_id >-------------------------------|
-- ---------------------------------------------------------------------------+

-- DESCRIPTION
--   If the GROUP_INITIATOR_ID is not null, the GROUP_DATE must also be not null
--   and vica versa.

-- PRE-REQUISITES

-- IN PARAMETERS
--  group_initiator_id
--  group_date

-- POST SUCCESS
--   Processing continues

-- POST FAILURE
--   Processing terminates

-- ACCESS STATUS
--  Internal Development Use Only

Procedure chk_group_date_id
  (p_group_initiator_id	in  per_assessments.group_initiator_id%TYPE
  ,p_group_date    in  per_assessments.group_date%TYPE
  )
is

  l_proc        varchar2(72):=g_package||'chk_group_date_id';


begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

-- Tests are carried out on insert only.


  If ((p_group_initiator_id is not null And p_group_date is null) Or
      (p_group_initiator_id is null AND p_group_date is not null)) Then
/*
    If (p_group_initiator_id is null and p_group_date is null) then
     null;
    elsif (p_group_initiator_id is not null and p_group_date is not null) then
     null;
    else
*/

    -- raise an error as the either both should exist or neither should.

    hr_utility.set_message(801, 'HR_52308_CM_GPR_DATE_ID_PROB');
    hr_utility.raise_error;

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 2);
EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_ASSESSMENTS.GROUP_DATE'
             ) then
          raise;
        end if;

end chk_group_date_id;

-- ---------------------------------------------------------------------------+
-- |----------------------< chk_group_initiator_id >--------------------------|
-- ---------------------------------------------------------------------------+

-- DESCRIPTION
--   GROUP_INITIATOR_ID must be of the same business group and must exist on
--   the group_date.

-- PRE-REQUISITES

-- IN PARAMETERS
--  group_initiator_id
--  business_group_id
--  group_date

-- POST SUCCESS
--   Processing continues

-- POST FAILURE
--   Processing terminates

-- ACCESS STATUS
--  Internal Development Use Only

Procedure chk_group_initiator_id
  (p_group_initiator_id	in  per_assessments.group_initiator_id%TYPE
  ,p_business_group_id  in  per_assessments.business_group_id%TYPE
  ,p_group_date    in  per_assessments.group_date%TYPE
  )
is

  l_proc        varchar2(72):=g_package||'chk_group_initiator_id';

  cursor csr_chk_grp_per_sta_date is
    select distinct(min(effective_start_date)), business_group_id
    from per_all_people_f per
    where per.person_id = p_group_initiator_id
    group by business_group_id;

  l_asn_grp_pers_sta_date	per_people_f.start_date%TYPE;
  l_asn_grp_pers_bg		per_people_f.business_group_id%TYPE;

  lv_cross_business_group VARCHAR2(10); -- bug 1980440 fix
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

-- Tests are carried out on insert, and update (even if values haven't changed)
-- as data in the referenced table may have.

-- chk_group_date_id contains check whether group_date and group_initiator_id
-- values are valid.  return if null;
  if p_group_initiator_id IS NOT NULL THEN

  open csr_chk_grp_per_sta_date;
  fetch csr_chk_grp_per_sta_date into l_asn_grp_pers_sta_date,l_asn_grp_pers_bg;

  if (csr_chk_grp_per_sta_date%notfound or l_asn_grp_pers_sta_date IS NULL) then

    close csr_chk_grp_per_sta_date;

    -- raise an error as the person_id doesn't exist

    hr_utility.set_message(801, 'HR_52305_ASN_GRPPER_NOT_EXIST');
    hr_utility.raise_error;

  end if;
  close csr_chk_grp_per_sta_date;

  -- The person has to be in the correct business group

  -- bug 1980440 fix starts
  -- if CROSS_BUSINESS_GROUP option is enabled we shouldn't do a comparison
  -- between GroupInitiator's BG and Appraisee BG as they may be different
  lv_cross_business_group := fnd_profile.value('HR_CROSS_BUSINESS_GROUP');

  if lv_cross_business_group <> 'Y' THEN

    if (l_asn_grp_pers_bg <> p_business_group_id) then

        -- raise an error as the person is in the wrong business_group

        hr_utility.set_message(801, 'HR_52306_ASN_GRPPER_NOT_BG');
        hr_utility.raise_error;

    end if;
  end if;
  -- bug 1980440 fix ends

  -- The group_date has to be on or after the group initiators start date

  if (p_group_date < l_asn_grp_pers_sta_date) then

    hr_utility.set_message(801, 'HR_52307_ASN_GRPPER_NO_XIST_DA');
    hr_utility.raise_error;

  end if;
  ELSE
   NULL;
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 1);

EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_ASSESSMENTS.GROUP_INITIATOR_ID'
             ) then
          raise;
        end if;
end chk_group_initiator_id;



------------------------------------------------------------------------------+
----------------------------<chk_appraisal_period_dates>----------------------+
------------------------------------------------------------------------------+

--  Description:
--   - Validates that the appraisal_period_start_date is less than or equal to
--     appraisal_period_end_date
--   - Validates that the appraisal_period_end_date is greater than or equal to
--     appraisal_period_start_date

--  Pre_conditions:

--  In Arguments:
--    p_appraisal_id
--    p_appraisal_period_start_date
--    p_appraisal_period_end_date
--    p_object_version_number

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--    - the appraisal_period_start_date is greater than appraisal_period_end_date
--    - the appraisal_period_end_date is less than appraisal_period_start_date

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_appraisal_period_dates
(p_appraisal_id              	in     per_appraisals.appraisal_id%TYPE
,p_object_version_number     	in     per_appraisals.object_version_number%TYPE
,p_appraisal_period_start_date	in     per_appraisals.appraisal_period_start_date%TYPE
,p_appraisal_period_end_date	in     per_appraisals.appraisal_period_end_date%TYPE
)
is

        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_appraisal_period_dates';

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  if (p_appraisal_period_start_date is NULL) then
      hr_utility.set_message(801, 'HR_51894_APR_START_DATE_NULL');
      hr_utility.raise_error;
  elsif (p_appraisal_period_end_date is NULL) then
      hr_utility.set_message(801, 'HR_51895_APR_END_DATE_NULL');
      hr_utility.raise_error;
  end if;

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and

  l_api_updating := per_apr_shd.api_updating
         (p_appraisal_id           => p_appraisal_id
         ,p_object_version_number  => p_object_version_number);

  -- Do the check
     hr_utility.set_location(l_proc, 2);

  --  The start date has to be <= the end date and end date >= strat date, else error.

  -- Fix 3062009
  -- Removed If condition for raising error when  start date < end date.

  if (p_appraisal_period_end_date < p_appraisal_period_start_date) then
      hr_utility.set_message(801, 'HR_51897_APR_END_DATE_LATER');
      hr_utility.raise_error;
  end if;

 hr_utility.set_location('Leaving: '|| l_proc, 10);
end chk_appraisal_period_dates;

-- ---------------------------------------------------------------------------+
-- |---------------------< chk_appraisal_dates >------------------------------|
-- ---------------------------------------------------------------------------+

-- Description:
--  Validates that the appraisal_period_start_date,
--                     appraisal_period_end_date,
--                     appraisal_date
--   cannot be set to a date where the appraisee_person_id has a system_
--   person_type of 'EX_EMP' or 'EX_EMP_APL'.
--  Also, that the appraisal_date cannot be set to a day when the
--   appraiser_person_id has a system_person_type of 'EX_EMP' or 'EX_EMP_APL'

-- Pre-requisites:
--  Dates are valid.

-- IN Parameters:
--    p_appraisal_period_end_date
--    p_appraisal_period_start_date
--    p_appraisal_date
--    p_appraisee_person_id
--    p_appraiser_person_id
--    p_main_appraiser_id

-- Post Success:
--   Processing continues if the dates are all valid.

-- Post Failure:
--   An application error is raised, and processing is terminated if the
--   dates are invalid.

-- Developer/Implementation Notes:
--   None.

-- Access Status:
--   Internal Row Handler Use Only.

-- ---------------------------------------------------------------------------+
procedure chk_appraisal_dates
  (p_appraisal_date in per_appraisals.appraisal_date%TYPE
  ,p_appraisal_period_start_date
     in    per_appraisals.appraisal_period_start_date%TYPE
  ,p_appraisal_period_end_date
     in    per_appraisals.appraisal_period_end_date%TYPE
  ,p_next_appraisal_date in per_appraisals.next_appraisal_date%TYPE
  ,p_appraisee_person_id
     in    per_appraisals.appraisee_person_id%TYPE
  ,p_appraiser_person_id
     in    per_appraisals.appraiser_person_id%TYPE
  ,p_main_appraiser_id  in per_appraisals.main_appraiser_id%TYPE
  )
  is

-- Modified this procedure to add check on next appraisal date. Fix for bug 3061901

  l_proc  varchar2(72) := g_package || 'chk_appraisal_dates';
  l_valid boolean;

  -- Function to return whether or not the date is valid

  function validate_date
            (p_date in date
            ,p_person_id in per_all_people_f.person_id%TYPE
            ) RETURN boolean IS

    l_exists varchar2(1);
    l_person_type per_person_types.system_person_type%TYPE;
    l_return boolean;

    -- Cursor to fetch the person_type

-- Added person_type_id where clause
-- Bug 820841
-- changed the cursor for bug 7113142
    cursor csr_fetch_type is
    select     pt.system_person_type
    from
            per_all_people_f per
           ,per_person_type_usages_f ptu
           ,per_person_types pt
    where   per.person_id = p_person_id
         and p_date BETWEEN per.effective_start_date and per.effective_end_date
         AND per.person_id = ptu.person_id
         AND p_date between ptu.effective_start_date AND ptu.effective_End_date
         AND ptu.person_type_id = pt.person_type_id
         AND pt.system_person_type  IN ('EMP','CWK','EMP_APL','CWK_APL');

  begin
    -- fetch person_type
    open csr_fetch_type;
    fetch csr_fetch_type into l_person_type;
    -- Fix 3082788 Start
    IF csr_fetch_type%NOTFOUND then
        CLOSE csr_fetch_type;
        return FALSE;
   -- Fix 3082788 End
    ELSE
    close csr_fetch_type;
    return TRUE;
    END IF;

  end validate_date;


begin

  hr_utility.set_location('Entering: '||l_proc,10);

  -- Determine whether each of the dates are valid
  l_valid :=
      validate_date(p_appraisal_period_start_date, p_appraisee_person_id);
  if not l_valid then
     fnd_message.set_name('PER','PER_52452_APR_INVALID_START');   -- Fix 2516903
     hr_multi_message.add(p_associated_column1 => 'PER_APPRAISALS.APPRAISAL_PERIOD_START_DATE');
     --fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc,20);

  l_valid :=
      validate_date(p_appraisal_date,p_appraisee_person_id);
  if not l_valid then
     fnd_message.set_name('PER','PER_52453_APR_INVALID_APR_DATE');
     hr_multi_message.add(p_associated_column1 => 'PER_APPRAISALS.APPRAISAL_DATE');
     --fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc,30);

  l_valid :=
      validate_date(p_appraisal_period_end_date, p_appraisee_person_id);
  if not l_valid then
     fnd_message.set_name('PER','PER_52454_APR_INVALID_END');  -- Fix 2485178
     hr_multi_message.add(p_associated_column1 => 'PER_APPRAISALS.APPRAISAL_PERIOD_END_DATE');
     --fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc,40);

  -- Check that appraisal_date is not set to a date when appraiser_person_id
  -- in not person type of 'EX_EMP' or 'EX_EMP_APL'
-- 6825820   Bug Fix
-- Checking if appraiser is different from the appraisee and the main appraiser and if so by passing the validation
if((p_appraisee_person_id <> p_appraiser_person_id) and (p_appraiser_person_id <> p_main_appraiser_id))
then
  l_valid := true;
else
  l_valid :=
     validate_date(p_appraisal_date, p_appraiser_person_id);
  if not l_valid then
     fnd_message.set_name('PER','PER_52455_APR_INVALID_APR_DATE');
     hr_multi_message.add(p_associated_column1 => 'PER_APPRAISALS.APPRAISAL_DATE');
    -- fnd_message.raise_error;
  end if;
end if;


  -- Check added for Bug 820841

  hr_utility.set_location(l_proc,50);
  --  The appraisal date has to be >= appraisal start date, else error.

  if (p_appraisal_period_start_date > p_appraisal_date) then

      hr_utility.set_message(800, 'HR_52792_INVALID_APPR_DATE'); -- Fix 3061934.
      hr_multi_message.add(p_associated_column1 => 'PER_APPRAISALS.APPRAISAL_DATE'
                          ,p_associated_column2 => 'PER_APPRAISALS.APPRAISAL_PERIOD_START_DATE'
                           );
      --hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc,60);

  -- Fix 3061901

  if ( nvl(p_next_appraisal_date,hr_api.g_eot ) < p_appraisal_date) then
      hr_utility.set_message(800, 'HR_449014_INV_NEXT_APPR_DATE');
      hr_multi_message.add(p_associated_column1 => 'PER_APPRAISALS.NEXT_APPRAISAL_DATE'
                           ,p_associated_column2 => 'PER_APPRAISALS.APPRAISAL_DATE'
                           );
      --hr_utility.raise_error;

  end if;

  hr_utility.set_location('Leaving: '||l_proc,70);


end chk_appraisal_dates;


------------------------------------------------------------------------------+
-------------------------------<chk_overall_rating>---------------------------+
------------------------------------------------------------------------------+

--  Description:
--   - Validates that the OVERALL_PERFORMANCE_LEVEL_ID is in the same business group as
--     the appraisal and the same scale as appraisal template.

--  Pre_conditions:
--    Valid appraisal_template_id

--  In Arguments:
--    p_appraisal_id
--    p_overall_performance_level_id
--    p_appraisal_template_id
--    p_object_version_number
--    p_business_group_id

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--     - overall_performance_level_id is not in the same business group as
--       the appraisal and the same scale as appraisal template.

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_overall_rating
(p_appraisal_id              in      per_appraisals.appraisal_id%TYPE
,p_object_version_number     in      per_appraisals.object_version_number%TYPE
,p_appraisal_template_id     in      per_appraisals.appraisal_template_id%TYPE
,p_overall_performance_level_id in   per_appraisals.overall_performance_level_id%TYPE
,p_business_group_id	     in	     per_appraisals.business_group_id%TYPE
)
is

	l_exists	     varchar2(1);
	l_business_group_id  per_appraisals.business_group_id%TYPE;
	l_rating_scale_id    per_rating_levels.rating_scale_id%TYPE;
        l_api_updating       boolean;
        l_proc               varchar2(72)  :=  g_package||'chk_overall_rating';


	-- Cursor to check if overall rating id exists and is
	-- in the same business group as appraisal

	Cursor csr_overall_rating_bg
          is
	select  business_group_id,rating_scale_id
	from	per_rating_levels
	where 	rating_level_id       	= p_overall_performance_level_id;


	-- Cursor to check if overall rating id is for the ratibng scale
	-- defined in the appraisal template

	Cursor csr_overall_rating_valid
          is
	select	'Y'
	from	per_appraisal_templates
	where	rating_scale_id 	= l_rating_scale_id
	and	appraisal_template_id 	= p_appraisal_template_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'appraisal_template_id'
    ,p_argument_value => p_appraisal_template_id
    );

  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for overall_performance_level_id has changed

  l_api_updating := per_apr_shd.api_updating
         (p_appraisal_id           => p_appraisal_id
         ,p_object_version_number  => p_object_version_number);

  if (  (l_api_updating and nvl(per_apr_shd.g_old_rec.overall_performance_level_id,
                                hr_api.g_number)
                        <> nvl(p_overall_performance_level_id,hr_api.g_number)
         ) or
        (NOT l_api_updating)
      ) then
  -- Do the check
     hr_utility.set_location(l_proc, 2);
  if p_overall_performance_level_id is not null then
	open csr_overall_rating_bg;
        fetch csr_overall_rating_bg into l_business_group_id , l_rating_scale_id;
	if csr_overall_rating_bg%notfound then
            close csr_overall_rating_bg;
            hr_utility.set_message(801,'HR_51898_APR_NO_SUCH_LEVEL');
            hr_utility.raise_error;
	end if;
        close csr_overall_rating_bg;
	-- check if the business groups match
	hr_utility.set_location(l_proc, 3);
        -- ngundura changes as per pa requirement
        -- added l_business_group_id is not null criteria to facilitate global rating scales
	if p_business_group_id <> l_business_group_id and l_business_group_id is not null then
	    hr_utility.set_message(801,'HR_51899_APR_LVL_DIFF_BG');
            hr_utility.raise_error;
	end if;
	-- check if the rating level is for the rating scale
	-- defined in the appraisal template
	hr_utility.set_location(l_proc, 4);
	open csr_overall_rating_valid;
        fetch csr_overall_rating_valid into l_exists;
	if csr_overall_rating_valid%notfound then
            close csr_overall_rating_valid;
            hr_utility.set_message(801,'HR_51900_APR_LVL_DIFF_SCALE');
            hr_utility.raise_error;
	end if;
        close csr_overall_rating_valid;
   end if;
  end if;
 hr_utility.set_location('Leaving: '|| l_proc, 10);

EXCEPTION
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_APPRAISALS.OVERALL_PERFORMANCE_LEVEL_ID'
             ) then
          raise;
        end if;

end chk_overall_rating;

------------------------------------------------------------------------------+
------------------------------<chk_appraisal_delete>--------------------------+
------------------------------------------------------------------------------+

--  Description:
--   - Validates that an appraisal cannot be deleted if:
--	 -Appraisal overall_performance_level_id is not null
--     	 -Appraisal is referenced in:
--		- per_assign_proposal_answers
--		- per_objectives
--		- per_assessments
--		- per_performance_ratings

--  Pre_conditions:
--   - A valid appraisal_id

--  In Arguments:
--    p_appraisal_id
--    p_object_version_number

--  Post Success:
--    Process continues if :
--    All the in parameters are valid.

--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	- appraisal overall_performance_level_id is not null
--      - appraisal is refrenced in per_assign_proposal_answers, per_objectives
--	  per_assessments, per_performance_ratings

--  Access Status
--    Internal Table Handler Use Only.

procedure chk_appraisal_delete
(p_appraisal_id              in      per_appraisals.appraisal_id%TYPE
,p_object_version_number     in      per_appraisals.object_version_number%TYPE
,p_overall_performance_level_id	     in	     per_appraisals.overall_performance_level_id%TYPE
)
is

      l_exists		   varchar2(1);
      l_proc               varchar2(72)  :=  g_package||'chk_appraisal_delete';


    	-- Cursor to check if the appraisal is used in per_assign_proposal_answers

        -- Change to use exists for WWBUG 1833930.

    	cursor csr_apr_exists_in_answers
	 is
     	select 'Y'
     	from   dual
        where  exists (select null
                       from   per_assign_proposal_answers
     	               where  answer_for_key = p_appraisal_id);
        -- 07/03/97 Changed

	-- Cursor to check if the appraisal is used in per_objectives

    	cursor csr_apr_exits_in_objectives
	 is
     	select 'Y'
     	from   per_objectives
     	where  appraisal_id    = p_appraisal_id;

	-- Cursor to check if the appraisal is used in per_assessments

    	cursor csr_apr_exists_in_assessments
	 is
     	select 'Y'
     	from   per_assessments
     	where  appraisal_id    = p_appraisal_id;

	-- Cursor to check if the appraisal is used in per_performance_ratings

    	cursor csr_apr_exits_in_perf_rat
	 is
     	select 'Y'
     	from   per_performance_ratings
     	where  appraisal_id    = p_appraisal_id;


        -- Cursor to check if the appraisal is used in PER_PARTICIPANTS

        cursor csr_apr_exists_in_per_part is
           select 'Y'
             from per_participants par
            where par.participation_in_id = p_appraisal_id
              and par.participation_in_table = 'PER_APPRAISALS'
              and par.participation_in_column = 'APPRAISAL_ID';

        -- Cursor to check if the appraisal is used in HR_QUEST_ANSWERS

        cursor csr_apr_exists_in_hr_qsa is
           select 'Y'
             from hr_quest_answers qsa
            where qsa.type_object_id = p_appraisal_id
              and qsa.type = 'APPRAISAL';

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  -- Check mandatory parameters have been set

    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'appraisal_id'
    ,p_argument_value => p_appraisal_id
    );

  hr_utility.set_location(l_proc, 2);

  -- check if overall_performance_level_id is null. If it is not null then
  -- do not allow the appraisal to be deleted.

     if p_overall_performance_level_id is not null then
	 hr_utility.set_message(801,'HR_51902_APR_LVL_NOT_NULL');
         hr_utility.raise_error;
     end if;

  open csr_apr_exists_in_answers;
  fetch csr_apr_exists_in_answers into l_exists;
	if csr_apr_exists_in_answers%found then
            close csr_apr_exists_in_answers;
            hr_utility.set_message(801,'HR_51903_APR_IN_ANSWERS');
            hr_utility.raise_error;
	end if;
  close csr_apr_exists_in_answers;

  hr_utility.set_location(l_proc, 3);

  open csr_apr_exits_in_objectives;
  fetch csr_apr_exits_in_objectives into l_exists;
	if csr_apr_exits_in_objectives%found then
            close csr_apr_exits_in_objectives;
            hr_utility.set_message(801,'HR_51904_APR_IN_OBJECT');
            hr_utility.raise_error;
	end if;
  close csr_apr_exits_in_objectives;

  hr_utility.set_location(l_proc, 4);

  open csr_apr_exists_in_assessments;
  fetch csr_apr_exists_in_assessments into l_exists;
	if csr_apr_exists_in_assessments%found then
            close csr_apr_exists_in_assessments;
            hr_utility.set_message(801,'HR_51905_APR_IN_ASSMNT');
            hr_utility.raise_error;
	end if;
  close csr_apr_exists_in_assessments;

  hr_utility.set_location(l_proc, 5);

  open  csr_apr_exits_in_perf_rat;
  fetch  csr_apr_exits_in_perf_rat into l_exists;
	if  csr_apr_exits_in_perf_rat%found then
            close  csr_apr_exits_in_perf_rat;
            hr_utility.set_message(801,'HR_51906_APR_IN_PERF_RAT');
            hr_utility.raise_error;
	end if;
  close  csr_apr_exits_in_perf_rat;

  hr_utility.set_location(l_proc, 6);

  open csr_apr_exists_in_per_part;
  fetch csr_apr_exists_in_per_part into l_exists;
  if csr_apr_exists_in_per_part%found then
     close csr_apr_exists_in_per_part;
     fnd_message.set_name('PER','PER_52450_APR_ANSWERS_EXIST');
     fnd_message.raise_error;
  end if;
  close csr_apr_exists_in_per_part;

  hr_utility.set_location(l_proc,7);

  open csr_apr_exists_in_hr_qsa;
  fetch csr_apr_exists_in_hr_qsa into l_exists;
  if csr_apr_exists_in_hr_qsa%found then
     close csr_apr_exists_in_hr_qsa;
     fnd_message.set_name('PER','PER_52451_APR_PARTICIP_EXIST');
     fnd_message.raise_error;
  end if;
  close csr_apr_exists_in_hr_qsa;

  hr_utility.set_location('Leaving: '|| l_proc, 10);
end chk_appraisal_delete;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_plan_id >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the specified performance
--   management plan exists.
--
-- Pre Conditions:
--   The plan must already exist.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the plan is valid.
--
-- Post Failure:
--   An application error is raised if the plan does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_plan_id
  (p_appraisal_id          IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_plan_id';
  l_api_updating  boolean;
  l_plan_id       number;
  --

  CURSOR csr_chk_plan_id IS
  SELECT pmp.plan_id
  FROM   per_perf_mgmt_plans pmp
  WHERE  pmp.plan_id = p_plan_id;
--
BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_apr_shd.api_updating
         (p_appraisal_id           => p_appraisal_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_apr_shd.g_old_rec.plan_id, hr_api.g_number)
    = nvl(p_plan_id, hr_api.g_number))
  THEN
     RETURN;
  END IF;

  IF p_plan_id IS NOT null THEN
    --
    -- Check that plan exists.
    --
    hr_utility.set_location(l_proc, 20);
    OPEN  csr_chk_plan_id;
    FETCH csr_chk_plan_id INTO l_plan_id;
    CLOSE csr_chk_plan_id;

    IF l_plan_id IS null THEN
      fnd_message.set_name('PER', 'HR_50264_PMS_INVALID_PLAN');
      fnd_message.raise_error;
    END IF;

  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 970);

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_APPRAISALS.PLAN_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_plan_id;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_offline_status >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the offline status value
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the offline status value is valid.
--
-- Post Failure:
--   An application error is raised if the offline status value is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_offline_status
  (p_appraisal_id          IN number
  ,p_object_version_number IN number
  ,p_offline_status        IN varchar2
 ,p_effective_date        IN date
  ) IS


  --
  l_proc           varchar2(72) := g_package || 'chk_offline_status';
  l_api_updating   boolean;
  l_offline_status varchar2(30);
  --
--
BEGIN


  hr_utility.set_location('Entering:'|| l_proc, 10);


  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The offline status value has changed
  --
  l_api_updating := per_apr_shd.api_updating
         (p_appraisal_id           => p_appraisal_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_apr_shd.g_old_rec.offline_status, hr_api.g_varchar2)
    = nvl(p_offline_status, hr_api.g_varchar2))
  THEN
     RETURN;
  END IF;

  IF p_offline_status IS NOT null THEN
    --
    -- Check that offline status is valid.
    --
    hr_utility.set_location(l_proc, 20);
    IF hr_api.not_exists_in_hr_lookups(
    p_effective_date   => p_effective_date
    ,p_lookup_type      => 'APPRAISAL_OFFLINE_STATUS'
    ,p_lookup_code      => upper(p_offline_status)
    ) THEN
        fnd_message.set_name('PER', 'HR_34568_INV_OFFLINE_STATUS');
        fnd_message.raise_error;
    END IF;

  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 970);
EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_APPRAISALS.OFFLINE_STATUS')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_offline_status;
--
-- ----------------------------------------------------------------------+
-- |------------------------------< chk_df >-----------------------------|
-- ----------------------------------------------------------------------+

-- Description:
--   Validates the all Descriptive Flexfield values.

-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.

-- In Arguments:
--   p_rec

-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.

-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.

-- Access Status:
--   Internal Row Handler Use Only.

procedure chk_df
  (p_rec in per_apr_shd.g_rec_type) is

  l_proc     varchar2(72) := g_package||'chk_df';

begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  if ((p_rec.appraisal_id is not null) and (
    nvl(per_apr_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_apr_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.appraisal_id is null) then

   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.

   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_APPRAISALS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      );
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_df;

-- ---------------------------------------------------------------------------+
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure insert_validate(p_rec in per_apr_shd.g_rec_type
			  ,p_effective_date in date)
is

  l_proc  varchar2(72) := g_package||'insert_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call all supporting business operations

  hr_api.validate_bus_grp_id
  (p_business_group_id => p_rec.business_group_id
  ,p_associated_column1 => per_per_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
  ); -- VALIDATE BUSINESS GROUP


  hr_utility.set_location(l_proc, 6);

 per_apr_bus.chk_appraisee_appraiser
 (p_person_id    		=>	p_rec.appraisee_person_id
 ,p_business_group_id		=>	p_rec.business_group_id
 ,p_effective_date		=>	p_effective_date
 ,p_person_type			=>	'APPRAISEE'
 );

 hr_utility.set_location(l_proc, 7);

 per_apr_bus.chk_appraisee_appraiser
 (p_person_id    		=>	p_rec.appraiser_person_id
 ,p_business_group_id		=>	p_rec.business_group_id
 ,p_effective_date		=>	p_effective_date
 ,p_person_type			=>	'APPRAISER'
 );

 per_apr_bus.chk_main_appraiser_id
  (p_main_appraiser_id 		=>	p_rec.main_appraiser_id
  ,p_business_group_id		=>	p_rec.business_group_id
  ,p_effective_date		=>	p_effective_date
 );

 hr_utility.set_location(l_proc, 8);

 per_apr_bus.chk_appraisal_period_dates
 (p_appraisal_id              	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_appraisal_period_start_date	=>	p_rec.appraisal_period_start_date
 ,p_appraisal_period_end_date	=>	p_rec.appraisal_period_end_date
 );

 hr_utility.set_location(l_proc, 9);
 per_apr_bus.chk_appraisal_dates
  (p_appraisal_date              => p_rec.appraisal_date
  ,p_appraisal_period_start_date => p_rec.appraisal_period_start_date
  ,p_appraisal_period_end_date   => p_rec.appraisal_period_end_date
  ,p_next_appraisal_date         => p_rec.next_appraisal_date
  ,p_appraisee_person_id         => p_rec.appraisee_person_id
  ,p_appraiser_person_id         => p_rec.appraiser_person_id
,p_main_appraiser_id           =>   p_rec.main_appraiser_id
  );
 hr_utility.set_location(l_proc, 10);

 per_apr_bus.chk_appraisal_template
 (p_appraisal_template_id	=>	p_rec.appraisal_template_id
 ,p_business_group_id	     	=>	p_rec.business_group_id
 ,p_effective_date	     	=>	p_rec.appraisal_period_start_date
 );

 -- Fix 3061985.
 -- Template validation should be done on appraisal start date and appraisal end date.


 per_apr_bus.chk_appraisal_template
  (p_appraisal_template_id	=>	p_rec.appraisal_template_id
  ,p_business_group_id	     	=>	p_rec.business_group_id
  ,p_effective_date	     	=>	p_rec.appraisal_period_end_date
 );


 hr_utility.set_location(l_proc, 11);

 per_apr_bus.chk_appraisal_type
 (p_appraisal_id              	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_type	     		=>	p_rec.type
 ,p_effective_date		=>	p_effective_date
 );

 hr_utility.set_location(l_proc, 12);

 per_apr_bus.chk_overall_rating
 (p_appraisal_id             	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_appraisal_template_id     	=>	p_rec.appraisal_template_id
 ,p_overall_performance_level_id =>	p_rec.overall_performance_level_id
 ,p_business_group_id	     	=>	p_rec.business_group_id
 );

 hr_utility.set_location(l_proc, 13);

 per_apr_bus.chk_appraisal_status
 (p_appraisal_id    		=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_status		     	=>	p_rec.status
 ,p_effective_date        	=>	p_effective_date
 );

 hr_utility.set_location(l_proc, 14);


 per_apr_bus.chk_group_date_id
    (p_group_initiator_id	=> p_rec.group_initiator_id
    ,p_group_date    		=> p_rec.group_date
    );

 per_apr_bus.chk_group_initiator_id
    (p_group_initiator_id	=> p_rec.group_initiator_id
    ,p_business_group_id  	=> p_rec.business_group_id
    ,p_group_date    		=> p_rec.group_date
    );

 per_apr_bus.chk_plan_id
 (p_appraisal_id              	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_plan_id	     		=>	p_rec.plan_id
 );
 per_apr_bus.chk_offline_status
 (p_appraisal_id                =>      p_rec.appraisal_id
 ,p_object_version_number       =>      p_rec.object_version_number
 ,p_offline_status              =>      p_rec.offline_status
 ,p_effective_date              =>      p_effective_date
 );

--ExEmpEnhancements
  per_apr_bus.chk_future_termination_exist (
	 p_appraisee_person_id => p_rec.appraisee_person_id ,
   p_appraisal_template_id  => p_rec.appraisal_template_id
 );


  -- Call descriptive flexfield validation routines

  per_apr_bus.chk_df(p_rec => p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;

-- ---------------------------------------------------------------------------+
-- |---------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure update_validate(p_rec in per_apr_shd.g_rec_type
			  ,p_effective_date in date) is

  l_proc  varchar2(72) := g_package||'update_validate';

cursor csr_term_wkr_type is
	SELECT
	  ppt.system_person_type person_type
	FROM
	  per_people_f ppf,
	  per_appraisals appr,
	  per_appraisal_templates apprt,
	    PER_PERSON_TYPES ppt
	WHERE person_id = p_rec.appraisee_person_id
	  AND appr.appraisal_id=p_rec.appraisal_id
	  AND trunc(sysdate) BETWEEN effective_start_date AND effective_end_date
	  and appr.appraisal_template_id = apprt.appraisal_template_id
	  AND ( ppf.CURRENT_NPW_FLAG  is  null and  ppf.CURRENT_EMPLOYEE_FLAG is  null  and nvl(apprt.SHOW_TERM_CONTIGENT,nvl(apprt.SHOW_TERM_EMPLOYEE,'N'))='Y' )
	  AND (apprt.disp_term_emp_period_from is null OR ( trunc(sysdate)-appr.appraisal_period_end_date <= nvl(apprt.disp_term_emp_period_from,0 ) ) )
	  AND ppf.person_type_id = ppt.person_type_id;

cursor csr_term_emp_finaldate is
SELECT
  'Y'
FROM
  per_periods_of_service ppser
WHERE ppser.person_id = p_rec.appraisee_person_id
  AND ppser.date_start = (
SELECT
    max(date_start)
  FROM
    per_periods_of_service
  WHERE person_id = p_rec.appraisee_person_id )
  AND SIGN (  TRUNC (SYSDATE)   - NVL  (ppser.final_process_date,   TRUNC (SYSDATE)  ) ) >= 0;

cursor csr_term_cwk_finaldate is
SELECT
  'Y'
FROM
  PER_PERIODS_OF_PLACEMENT ppser
WHERE ppser.person_id = p_rec.appraisee_person_id
  AND ppser.date_start = (
SELECT
    max(date_start)
  FROM
    PER_PERIODS_OF_PLACEMENT
  WHERE person_id = p_rec.appraisee_person_id )
  AND SIGN (  TRUNC (SYSDATE)   - NVL  (ppser.final_process_date,   TRUNC (SYSDATE)  ) ) >= 0;

   CURSOR csr_template_info
   IS
      SELECT show_future_term_employee
        FROM per_appraisal_templates
       WHERE appraisal_template_id = p_rec.appraisal_template_id;
l_template_future_term varchar2(2) := 'N';

l_wkr_type PER_PERSON_TYPES.system_person_type%TYPE := 'CUREMP';
l_allow_upd_term_wkr varchar2(2) := 'N';



Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  open csr_term_wkr_type;
  fetch csr_term_wkr_type into l_wkr_type;
  if csr_term_wkr_type%notfound then
   close csr_term_wkr_type;
  end if;

if(l_wkr_type <> 'CUREMP' ) then
  if(l_wkr_type= 'EMP' or l_wkr_type= 'EMP_APL' or l_wkr_type= 'EX_EMP' or l_wkr_type= 'EX_EMP_APL' ) then
    open csr_term_emp_finaldate;
    fetch csr_term_emp_finaldate into l_allow_upd_term_wkr;
    if csr_term_emp_finaldate%notfound then
     close csr_term_emp_finaldate;
    end if;
  else
    open csr_term_cwk_finaldate;
    fetch csr_term_cwk_finaldate into l_allow_upd_term_wkr;
    if csr_term_cwk_finaldate%notfound then
     close csr_term_cwk_finaldate;
    end if;
  end if;
end if;

   OPEN csr_template_info;
   FETCH csr_template_info
    INTO l_template_future_term;
   CLOSE csr_template_info;


  -- Call all supporting business operations

  -- Rule Check non-updateable fields cannot be updated

  hr_api.validate_bus_grp_id
  (p_business_group_id => p_rec.business_group_id
  ,p_associated_column1 => per_per_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
  ); -- VALIDATE BUSINESS GROUP

  chk_non_updateable_args(p_rec	=> p_rec);

  hr_utility.set_location(l_proc,6);

  per_apr_bus.chk_open(p_open => p_rec.open
                      ,p_effective_date => p_effective_date
                      );

  hr_utility.set_location(l_proc,7);

  per_apr_bus.chk_update_allowed
               (p_rec => p_rec);


  hr_utility.set_location(l_proc, 8);
  -- Appraisee is non updatable argument. So, no need for that check during update.

  per_apr_bus.chk_appraisee_appraiser
  (p_person_id    		=>	p_rec.appraiser_person_id
  ,p_business_group_id		=>	p_rec.business_group_id
  ,p_effective_date		=>	p_effective_date
  ,p_person_type		=>	'APPRAISER'
  );


 /*
 per_apr_bus.chk_appraiser_person_id
   (p_appraisal_id => p_rec.appraisal_id);
   -- Call to current behavior of chk_appraiser_person_id is not required..
 */
 hr_utility.set_location(l_proc,9);

 per_apr_bus.chk_appraisal_period_dates
 (p_appraisal_id              	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_appraisal_period_start_date	=>	p_rec.appraisal_period_start_date
 ,p_appraisal_period_end_date	=>	p_rec.appraisal_period_end_date
 );

 hr_utility.set_location(l_proc, 9);

 if (NOT fnd_function.test('HR_VIEW_SYSAPPR_MGR_SS') AND p_rec.appraisal_system_status <> 'DELETED' AND l_allow_upd_term_wkr = 'N' AND  NVL (l_template_future_term, 'N') <> 'Y'  ) then
   per_apr_bus.chk_appraisal_dates
    (p_appraisal_date              => p_rec.appraisal_date
    ,p_appraisal_period_start_date => p_rec.appraisal_period_start_date
    ,p_appraisal_period_end_date   => p_rec.appraisal_period_end_date
    ,p_next_appraisal_date         => p_rec.next_appraisal_date
    ,p_appraisee_person_id         => p_rec.appraisee_person_id
    ,p_appraiser_person_id         => p_rec.appraiser_person_id
   ,p_main_appraiser_id          =>   p_rec.main_appraiser_id
    );
 end if;

 per_apr_bus.chk_appraisal_type
 (p_appraisal_id              	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_type	     		=>	p_rec.type
 ,p_effective_date		=>	p_effective_date
 );

 hr_utility.set_location(l_proc, 10);

 per_apr_bus.chk_appraisal_template
   (p_appraisal_template_id	=>	p_rec.appraisal_template_id
   ,p_business_group_id	     	=>	p_rec.business_group_id
   ,p_effective_date	     	=>	p_rec.appraisal_period_start_date
 );

 -- Fix 3061985.
 -- Template validation should be done on appraisal start date and appraisal end date.


 per_apr_bus.chk_appraisal_template
  (p_appraisal_template_id	=>	p_rec.appraisal_template_id
  ,p_business_group_id	     	=>	p_rec.business_group_id
  ,p_effective_date	     	=>	p_rec.appraisal_period_end_date
 );

 per_apr_bus.chk_overall_rating
 (p_appraisal_id             	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_appraisal_template_id     	=>	p_rec.appraisal_template_id
 ,p_overall_performance_level_id	    	=>	p_rec.overall_performance_level_id
 ,p_business_group_id	     	=>	p_rec.business_group_id
 );

 hr_utility.set_location(l_proc, 13);

 per_apr_bus.chk_appraisal_status
 (p_appraisal_id    		=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_status		     	=>	p_rec.status
 ,p_effective_date        	=>	p_effective_date
 );

hr_utility.set_location(l_proc, 14);

 per_apr_bus.chk_main_appraiser_id
  (p_main_appraiser_id 		=>	p_rec.main_appraiser_id
  ,p_business_group_id		=>	p_rec.business_group_id
  ,p_effective_date		=>	p_effective_date
 );

 hr_utility.set_location(l_proc, 15);

 per_apr_bus.chk_plan_id
 (p_appraisal_id              	=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_plan_id	     		=>	p_rec.plan_id
 );

 hr_utility.set_location(l_proc, 16);
 per_apr_bus.chk_offline_status
 (p_appraisal_id                =>      p_rec.appraisal_id
 ,p_object_version_number       =>      p_rec.object_version_number
 ,p_offline_status              =>      p_rec.offline_status
 ,p_effective_date              =>      p_effective_date
 );

  -- Call descriptive flexfield validation routines

  per_apr_bus.chk_df(p_rec => p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;

-- ---------------------------------------------------------------------------+
-- |---------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure delete_validate(p_rec in per_apr_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'delete_validate';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call all supporting business operations

 per_apr_bus.chk_appraisal_delete
 (p_appraisal_id    		=>	p_rec.appraisal_id
 ,p_object_version_number     	=>	p_rec.object_version_number
 ,p_overall_performance_level_id		=>	p_rec.overall_performance_level_id
 ) ;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End delete_validate;


-- ---------------------------------------------------------------------------+
-- |-----------------------< return_legislation_code >------------------------|
-- ---------------------------------------------------------------------------+
Function return_legislation_code
         (  p_appraisal_id     in number
          ) return varchar2 is

-- Declare cursor

   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups pbg,
                 per_appraisals      pap
          where  pap.appraisal_id      = p_appraisal_id
            and  pbg.business_group_id = pap.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Ensure that all the mandatory parameters are not null

  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'appraisal_id',
                              p_argument_value => p_appraisal_id );

  if nvl(g_appraisal_id, hr_api.g_number) = p_appraisal_id then

    -- The legislation has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.

    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else

    -- The ID is different to the last call to this function
    -- or this is the first call to this function.

  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;

     -- The primary key is invalid therefore we must error out

     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;

  close csr_leg_code;
   g_appraisal_id     := p_appraisal_id;
   g_legislation_code := l_legislation_code;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

  return l_legislation_code;
End return_legislation_code;


end per_apr_bus;

/

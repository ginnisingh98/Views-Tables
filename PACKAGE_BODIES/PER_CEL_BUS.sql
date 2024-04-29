--------------------------------------------------------
--  DDL for Package Body PER_CEL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEL_BUS" as
/* $Header: pecelrhi.pkb 120.3 2006/03/28 05:27:21 arumukhe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cel_bus.';  -- Global package name
--
-- Followwing two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code         varchar2(150) default null;
g_competence_element_id    number        default null;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_non_updateable_args(p_rec in per_cel_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema

  --
  if not per_cel_shd.api_updating
                (p_competence_element_id    => p_rec.competence_element_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_cel_shd.g_old_rec.business_group_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'BUSINESS_GROUP_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if p_rec.competence_id <> per_cel_shd.g_old_rec.competence_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'COMPETENCE_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 8);
  --
  if p_rec.competence_element_id <>
     per_cel_shd.g_old_rec.competence_element_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'COMPETENCE_ELEMENT_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );

  end if;
  hr_utility.set_location(l_proc, 9);
  --
  if p_rec.parent_competence_element_id <>
     per_cel_shd.g_old_rec.parent_competence_element_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PARENT_COMPETENCE_ELEMENT_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 10);
  --
  if p_rec.activity_version_id <> per_cel_shd.g_old_rec.activity_version_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'ACTIVITY_VERSION_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 13);
  --
  hr_utility.set_location(l_proc, 14);
  --
  if p_rec.person_id <> per_cel_shd.g_old_rec.person_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PERSON_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  -- HR/TCA merge support party_id
  -- But allow change to NULL or if currently NULL
  if nvl(p_rec.party_id,per_cel_shd.g_old_rec.party_id) <>
              nvl(per_cel_shd.g_old_rec.party_id,p_rec.party_id) then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PARTY_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;

  hr_utility.set_location(l_proc, 15);
  --
  if p_rec.job_id <> per_cel_shd.g_old_rec.job_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'JOB_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );

  end if;
  hr_utility.set_location(l_proc, 16);
  --
  if p_rec.valid_grade_id <> per_cel_shd.g_old_rec.valid_grade_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'VALID_GRADE_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 16);
  --
  if p_rec.organization_id <> per_cel_shd.g_old_rec.organization_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'ORGANIZATION_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 17);

  --
  if p_rec.assessment_id <> per_cel_shd.g_old_rec.assessment_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'ASSESSMENT_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 18);
  --
  --
  if p_rec.enterprise_id <> per_cel_shd.g_old_rec.enterprise_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'ENTERPRISE_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 20);

  --
  --
  if p_rec.position_id <> per_cel_shd.g_old_rec.position_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'POSITION_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 22);
  --
  if p_rec.type <> per_cel_shd.g_old_rec.type then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'TYPE'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if p_rec.object_id <> per_cel_shd.g_old_rec.object_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'OBJECT_ID'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
  --
  if p_rec.object_name <> per_cel_shd.g_old_rec.object_name then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'OBJECT_NAME'
    ,p_base_table => per_cel_shd.g_tab_nam
    );
  end if;
end check_non_updateable_args;
--
------------------------------------------------------------------------------
-- |--------------------------<CHK_mandatory >-------------------------------|
-----------------------------------------------------------------------------

--
-- Description;
--   Validates that the value entered for mandatory exists
--   in HR_LOOKUPS
--
-- Pre-Conditions:
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_effective_date
--   p_mandatory
--   p_object_version_number

--
-- Post Success:
--   Processing continues if:
--     - The mandatory value is valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The mandatory value is invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--

--
procedure chk_mandatory
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_effective_date		in Date
   ,p_mandatory
    in per_competence_elements.mandatory%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ) is
--
   l_proc              varchar2(72):= g_package||'chk_mandatory';
   l_api_updating      boolean;

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
  -- Only proceed with validation if :

  -- a) The current  g_old_rec is current and
  -- b) The value for mandatory  has changed
  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id      => p_competence_element_id
         ,p_object_version_number  	 => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.mandatory,
      hr_api.g_varchar2) <>
      nvl(p_mandatory,hr_api.g_varchar2))
     OR not l_api_updating ) then
     hr_utility.set_location(l_proc, 6);
     --
     -- check that the p_mandatory exists in hr_lookups.
     --
   if (p_mandatory IS NOT NULL ) then
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date         => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_mandatory
        ) then
        --  Error: Invalid certification_method
        hr_utility.set_location(l_proc, 10);
        hr_utility.set_message(801,'HR_51635_CEL_MANDATORY_INVL');
        hr_multi_message.add
       (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.MANDATORY');

        hr_utility.raise_error;
     end if;

  --
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.MANDATORY'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,25);
end chk_mandatory;
--
------------------------------------------------------------------------------
-- |--------------------------<CHK_CERTIFICATION_METHOD >--------------------|
-----------------------------------------------------------------------------
--
-- Description;

--   Validates that the value entered for certification method exists
--   in HR_LOOKUPS
--
-- Pre-Conditions:
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_effective_date
--   p_certification_method
--   p_object_version_number
--
-- Post Success:

--   Processing continues if:
--     - The certification_method value is valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The certification_method value is invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
procedure chk_certification_method
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_effective_date		in Date
   ,p_certification_method
    in per_competence_elements.certification_method%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ) is
--
   l_proc              varchar2(72):= g_package||'chk_certification_method';
   l_api_updating      boolean;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for certification_method  has changed
  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id        => p_competence_element_id
         ,p_object_version_number  	 => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.certification_method,
      hr_api.g_varchar2) <>
      nvl(p_certification_method,hr_api.g_varchar2))
     OR not l_api_updating ) then
     hr_utility.set_location(l_proc, 6);
     --
     -- check that the p_certification_method exists in hr_lookups.
     --

   if (p_certification_method IS NOT NULL ) then
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date         => p_effective_date
         ,p_lookup_type           => 'CERTIFICATION_METHOD'
         ,p_lookup_code           => p_certification_method
        ) then
        --  Error: Invalid certification_method
        hr_utility.set_location(l_proc, 10);
        hr_utility.set_message(801,'HR_51636_CEL_CERTIF_INVL');
        hr_multi_message.add
        (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_METHOD');
        hr_utility.raise_error;
     end if;
     --
   end if;
   --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_METHOD'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,25);
end chk_certification_method;
--
--
------------------------------------------------------------------------------
-- |--------------------< CHK_CERTIFICATION_METHOD_DATE >--------------------|
-----------------------------------------------------------------------------
--
-- Description;
-- Validates that if the certification method is entered then the certificatio
--   Date is also entered and vice versa.
--
-- Pre-Conditions:
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_certification_method
--   p_certification_date
--   p_object_version_number
--
-- Post Success:

--   Processing continues if:
--     - The certification_method value and certification date are both valid
--
-- Post Failure:
-- application error is raised and processing is terminated if any
--      - The certification_method and certification date are  invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
procedure chk_certification_method_date
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_certification_date
    in per_competence_elements.certification_date%TYPE
   ,p_certification_method
   in per_competence_elements.certification_method%TYPE
   ,p_object_version_number
   in per_competence_elements.object_version_number%TYPE
   ) is
--
   l_proc              varchar2(72):= g_package||'chk_certification_method';
   l_api_updating      boolean;
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  -- Only proceed with certification method/certification_date validation
  -- when the multi message list does not already contain an error
  -- associated with the certification_method.
  if hr_multi_message.no_exclusive_error
   ( p_check_column1 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_METHOD'
   ) then
    --
    -- Only proceed with validation if :
    -- a) The current  g_old_rec is current and
    -- b) The value for certification_method  has changed
    --
    l_api_updating := per_cel_shd.api_updating
           (p_competence_element_id        => p_competence_element_id
           ,p_object_version_number        => p_object_version_number);
    --
    if (l_api_updating AND ((nvl(per_cel_shd.g_old_rec.certification_method,
        hr_api.g_varchar2) <>
        nvl(p_certification_method,hr_api.g_varchar2)) OR
        (nvl(per_cel_shd.g_old_rec.certification_date , hr_api.g_date ) <>
         nvl(p_certification_date,hr_api.g_date)))
        OR not l_api_updating ) then
        hr_utility.set_location(l_proc, 6);
       --
       -- if the certification_date is null and certification_method is
       -- not null then raise an error
       --
       if (   (p_certification_method is NOT NULL)
          and (p_certification_date is NULL) )
       then
         hr_utility.set_location(l_proc,10);
         hr_utility.set_message(801,'HR_51637_CEL_CERF_DATE_METHOD');

         -- Issue with Error not coming up
         hr_multi_message.add
    	 (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_DATE'
--          ,p_associated_column2 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_METHOD'
         );

        hr_utility.raise_error;

       end if;
       --
       if (   (p_certification_method is NULL)
          and (p_certification_date is NOT NULL) )
       then
         hr_utility.set_location(l_proc, 20);
         hr_utility.set_message(801,'HR_51629_CEL_CERF_METHOD_DATE');
         -- Issue with Error not coming up
         hr_multi_message.add
    	 (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_METHOD'
--         ,p_associated_column2 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_DATE'
         );

        hr_utility.raise_error;
       end if;
       --
        hr_utility.set_location('Leaving: '||l_proc,15);
    end if;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_METHOD'
       ,p_associated_column2 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_DATE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,25);
end chk_certification_method_date;
--
--
----------------------------------------------------------------------------
---|-----------------------<CHK_NEXT_CERTIFICATION_DATE>-----------|--
--
-- Description:
--   Validates that the date entered for the next certication date is ahead
--   of the date entered for the initial certification date
--
-- Pre-Conditions:
--   There must be an existing certification date
--
-- In Arguments:
--   p_competence_element_id
--   p_certification_date
--   p_next_certification_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues if
--    - The next_certification_date is valid
--
-- Post Failure:
--   An application error is raised and processing is terminated if
--    - The next_certification_date is invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
procedure chk_next_certification_date

  (p_competence_element_id
   in per_competence_elements.competence_element_id%TYPE
  ,p_certification_date
   in per_competence_elements.certification_date%TYPE
  ,p_next_certification_date
   in per_competence_elements.next_certification_date%TYPE
  ,p_object_version_number
   in per_competence_elements.object_version_number%TYPE
  ,p_effective_date_from
   in per_competence_elements.effective_date_from%TYPE --added for fix of #731089
  ) is
--
  l_proc   varchar2(72):=g_package||'chk_next_certification_date';
  l_api_updating  boolean;
--


begin
 hr_utility.set_location('Entering:'||l_proc, 1);
 --
 if hr_multi_message.no_all_inclusive_error
    ( p_check_column1 => 'PER_COMPETENCE_ELEMENTS.CERTIFICATION_DATE' ) then
   --
   -- Only Proceed if the value for g_old_rec is current
   -- and the value for the certification method has changed
   --
   l_api_updating := per_cel_shd.api_updating
    (p_competence_element_id =>p_competence_element_id
    ,p_object_version_number =>p_object_version_number);

   if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.certification_date,
       hr_api.g_date)<> nvl(p_certification_date,hr_api.g_date))
      OR
       (l_api_updating AND (nvl(per_cel_shd.g_old_rec.next_certification_date,
       hr_api.g_date)<> nvl(p_next_certification_date,hr_api.g_date))
      OR not l_api_updating))
   then hr_utility.set_location(l_proc, 6);
    --
    -- Raise error if certification date is NULL
    -- or next certification date occurs before certification date
    --

     if((p_certification_date is NULL
        AND p_next_certification_date is NOT NULL)
        OR
        (p_certification_date is NOT NULL AND
         p_next_certification_date <= p_certification_date)) THEN
        --
        hr_utility.set_location(l_proc,10);
        hr_utility.set_message(800,'PER_52861_CHK_NEXT_CERT_DATE');
    	hr_multi_message.add
	    (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.NEXT_CERTIFICATION_DATE');
        hr_utility.raise_error;
     end if;
    -- Added the code for  fix of #731089
     if p_next_certification_date is not null then
       if p_next_certification_date < p_effective_date_from THEN
          hr_utility.set_location(l_proc,12);
          hr_utility.set_message(800,'PER_289487_CEL_CERT_REV_DATE');
          hr_multi_message.add
	      (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.NEXT_CERTIFICATION_DATE');
          hr_utility.raise_error;
       end if;
     end if;
    -- Added the code for  fix of #731089

   end if;
 --
 end if; -- end for if checking for no_exclusive_error for CERTIFICATION_DATE
 --
 hr_utility.set_location('Leaving:'||l_proc,15);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
                     'PER_COMPETENCE_ELEMENTS.NEXT_CERTIFICATION_DATE'
       ,p_associated_column2 =>
                     'PER_COMPETENCE_ELEMENTS.CERTIFICATION_DATE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,25);
end chk_next_certification_date;
--
--
------------------------------------------------------------------------------
-- |--------------------------<CHK_COMPETENCE_TYPE >-----------------------|
-----------------------------------------------------------------------------
--
-- Description;
--   Validates that the value entered for competence_type exists
--   in HR_LOOKUPS
--
-- Pre-Conditions:
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_effective_date
--   p_competence_type
--   p_object_version_number
--
-- Post Success:
--   Processing continues if:
--     - The competence_type value is valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The competence_type value is invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
procedure chk_competence_type
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_effective_date            in Date
   ,p_competence_type
    in per_competence_elements.competence_type%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ) is
--
   l_proc              varchar2(72):= g_package||'chk_competence_type';

   l_api_updating      boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for competence_type  has changed
  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id        => p_competence_element_id
         ,p_object_version_number        => p_object_version_number);
  --
  if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.competence_type,
      hr_api.g_varchar2) <>
      nvl(p_competence_type,hr_api.g_varchar2))
     OR not l_api_updating ) then

     hr_utility.set_location(l_proc, 6);
     --
     -- check that the p_competence_type exists in hr_lookups.
     --
   if (p_competence_type IS NOT NULL ) then
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date         => p_effective_date
         ,p_lookup_type           => 'COMPETENCE_TYPE'
         ,p_lookup_code           => p_competence_type
        ) then
        --  Error: Invalid competence_type
        hr_utility.set_location(l_proc, 10);
        hr_utility.set_message(801,'HR_51638_CEL_COMP_TYPE_INVL');
    	hr_multi_message.add
	   (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.COMPETENCE_TYPE');

        hr_utility.raise_error;
     end if;
     --
   end if;
   --
 end if;
 --
 hr_utility.set_location(' Leaving:'|| l_proc, 15);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
                     'PER_COMPETENCE_ELEMENTS.COMPETENCE_TYPE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,25);
end chk_competence_type;
--
--
------------------------------------------------------------------------------
-- |---------------------<CHK_source_of_proficiency >------------------------|
-----------------------------------------------------------------------------
--
-- Description;
--   Validates that the value entered for source_of_proficiency exists
--   in HR_LOOKUPS
--
-- Pre-Conditions:
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_effective_date
--   p_source_of_proficiency
--   p_object_version_number
--
-- Post Success:
--   Processing continues if:
--     - The source_of_proficiency value is valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The source_of_proficiency value is invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
procedure chk_source_of_proficiency
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_effective_date            in Date
   ,p_source_of_proficiency_level
    in per_competence_elements.source_of_proficiency_level%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ) is
--
   l_proc              varchar2(72):=

		       g_package||'chk_source_of_proficiency';
   l_api_updating      boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );

  --
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for source_of_proficiency  has changed
  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id        => p_competence_element_id
         ,p_object_version_number        => p_object_version_number);
  --
  if (l_api_updating AND
      (nvl(per_cel_shd.g_old_rec.source_of_proficiency_level,
      hr_api.g_varchar2) <>

      nvl(p_source_of_proficiency_level,hr_api.g_varchar2))
     OR not l_api_updating ) then
     hr_utility.set_location(l_proc, 6);
     --
     -- check that the p_source_of_proficiency exists in hr_lookups.
     --
   if (p_source_of_proficiency_level IS NOT NULL ) then
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date         => p_effective_date
         ,p_lookup_type           => 'PROFICIENCY_SOURCE'
         ,p_lookup_code           => p_source_of_proficiency_level
        ) then
        --  Error: Invalid source_of_proficiency

        hr_utility.set_location(l_proc, 10);
        hr_utility.set_message(801,'HR_51639_CEL_SOURCE_PROF_INVL');
    	hr_multi_message.add
	   (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.SOURCE_OF_PROFICIENCY_LEVEL');

        hr_utility.raise_error;
     end if;
  --
   end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
                     'PER_COMPETENCE_ELEMENTS.SOURCE_OF_PROFICIENCY_LEVEL'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,25);
end chk_source_of_proficiency;
--
--
--
------------------------------------------------------------------------------
-- |--------------------------<CHK_TYPE >------------------------------------|
-----------------------------------------------------------------------------
--
-- Description;
--   Validates that the value entered for type exists
--   in HR_LOOKUPS and type is not updateable.
--
--
-- Pre-Conditions:
--   None
--

-- In Arguments:
--   p_competence_element_id
--   p_effective_date
--   p_type
--   p_object_version_number
--
-- Post Success:
--   Processing continues if:
--     - The type value is valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The type value is invalid

--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
procedure chk_type
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_effective_date            in Date
   ,p_type     			in per_competence_elements.type%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ) is
--
   l_proc              varchar2(72):= g_package||'chk_type';
   l_api_updating      boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name          => l_proc
     ,p_argument         => 'type'
     ,p_argument_value   => p_type
    );
  --
  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id        => p_competence_element_id

         ,p_object_version_number        => p_object_version_number);
  --
     hr_utility.set_location(l_proc, 6);
     --
     -- check that the p_type exists in hr_lookups.
     --
 if (NOT l_api_updating) then
   if (p_type IS NOT NULL ) then
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date         => p_effective_date
         ,p_lookup_type           => 'COMPETENCE_ELEMENT_TYPE'
         ,p_lookup_code           => p_type
        ) then

        --  Error: Invalid competence_type
        hr_utility.set_location(l_proc, 10);
        hr_utility.set_message(801,'HR_51641_CEL_COMP_ELTP_INVL');
    	hr_multi_message.add
	   (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.COMPETENCE_TYPE');
        hr_utility.raise_error;

     end if;
  --
   end if;
  --
 end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
                     'PER_COMPETENCE_ELEMENTS.TYPE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,25);
end chk_type;

-------------------------------------------------------------------------------
-----------------------------< chk_foreign_keys >------------------------------
-------------------------------------------------------------------------------
--
--
--  Description:
--   - Validates that the person_id,activity_version_id
--     position_id,organization_id,job_id, valid_grade_id,assessment_id,
--     high_proficiency_id,
--     competence_id,proficiency_level_id,
--     rating_level_id, weighting_level_id, p_parent_competence_element_id,
--     corresponding tables.
--
--
--  Pre_conditions:
--    A valid business_group_id
--
--  In Arguments:
--    p_competence_element_id
--    p_activity_version_id
--    p_business_group_id
--    p_enterprise_id
--    p_person_id
--    p_position_id
--    p_organization_id
--    p_job_id
--    p_valid_grade_id
--    p_assessment_id
--    p_assessment_type_id
--    p_competence_id
--    p_proficiency_level_id
--    p_high_proficiency_level_id
--    p_rating_level_id
--    p_weighting_level_id
--    p_parent_competence_element_id
--    p_business_group_id
--    p_object_version_number
--    p_party_id -- HR/TCA merge
--    p_qualification_type_id    BUG3356369
--
--  Post Success:
--    Process continues if :
--      - The job_id
--            competence_element_id
--            activity_version_id
--            person_id
--            position_id
--            valid_grade_id
--            organization_id
--            assessment_id
--	      assessment_type_id
--            competence_id
--            proficiency_level_id
--            high_proficiency_level_id
--            rating_level_id
--            weighting_level_id
--            parent_competence_element_id
--        exits inthe corresponding table and in correct business_group.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of

--    the following cases are found :
--        - The job_id
--            competence_element_id
--            activity_version_id
--            person_id
--            party_id
--            position_id
--            organization_id
--            assessment_id
--	      assessment_type_id
--            competence_id
--            proficiency_level_id
--            high_proficiency_level_id
--            valid_grade_id
--            rating_level_id
--            weighting_level_id
--            parent_competence_element_id
--          not found.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_foreign_keys
  (p_competence_element_id
  in     per_competence_elements.competence_element_id%TYPE
  ,p_job_id
  in     per_competence_elements.job_id%TYPE
  ,p_valid_grade_id
  in 	 per_competence_elements.valid_grade_id%TYPE
  ,p_activity_version_id
  in     per_competence_elements.activity_version_id%TYPE
  ,p_person_id
  in  	per_competence_elements.person_id%TYPE
  ,p_position_id
  in 	per_competence_elements.position_id%TYPE
  ,p_organization_id
  in	per_competence_elements.organization_id%TYPE
  ,p_assessment_id
  in 	per_competence_elements.assessment_id%TYPE
  ,p_assessment_type_id
   in	per_competence_elements.assessment_type_id%TYPE
  ,p_competence_id
  in	per_competence_elements.competence_id%TYPE
  ,p_proficiency_level_id
  in 	per_competence_elements.proficiency_level_id%TYPE
  ,p_high_proficiency_level_id
  in	per_competence_elements.high_proficiency_level_id%TYPE
  ,p_rating_level_id
  in	per_competence_elements.rating_level_id%TYPE
  ,p_weighting_level_id
  in	per_competence_elements.weighting_level_id%TYPE
  ,p_parent_competence_element_id
  in 	per_competence_elements.parent_competence_element_id%TYPE
  ,p_business_group_id
  in     per_competence_elements.business_group_id%TYPE
  ,p_enterprise_id
  in per_competence_elements.enterprise_id%TYPE
  ,p_object_version_number
  in     per_competence_elements.object_version_number%TYPE
  ,p_effective_date_from
	 per_competence_elements.effective_date_from%TYPE
  ,p_effective_date_to
	 per_competence_elements.effective_date_to%TYPE
  ,p_effective_date  date
  ,p_type per_competence_elements.type%TYPE
  ,p_party_id per_competence_elements.party_id%TYPE -- HR/TCA merge
  ,p_qualification_type_id per_competence_elements.qualification_type_id%TYPE
  )is
--
  l_proc    varchar2(72)  :=  g_package||'chk_foreign_keys';
  l_business_group_id   per_jobs.business_group_id%TYPE;
  l_start_date		per_jobs.date_from%TYPE;
  l_end_date		per_jobs.date_to%TYPE;
  l_start_date_2        per_jobs.date_from%TYPE;
  l_end_date_2		per_jobs.date_to%TYPE;
  l_date_of_birth       per_people_f.date_of_birth%TYPE;
  l_exist		varchar2(1);
  l_api_updating        boolean;
  l_party_id            per_competence_elements.party_id%TYPE; -- HR/TCA merge
  l_qualification_type_id per_competence_elements.qualification_type_id%TYPE;
--
  --
  -- cursor to check that the job_id exists.
  --
  cursor csr_valid_job_id is

  select business_group_id,date_from,date_to
  from per_jobs_v
  where  p_job_id = job_id;
  --and    p_effective_date_from  >= date_from
  --and    nvl(p_effective_date_to,hr_api.g_eot)<=
  --	   nvl(date_to,hr_api.g_eot);
  --
  -- cursor to check that the valid_grade_id exists.
  --
  cursor csr_valid_grade_id is

  select business_group_id, date_from, date_to
  from  per_valid_grades
  where  p_valid_grade_id = valid_grade_id;
  --and    p_effective_date_from  >= date_from
  --and    nvl(p_effective_date_to,hr_api.g_eot)<=
  --	   nvl(date_to,hr_api.g_eot);
  --
  --
  --
  -- cursor to check that the activity_version_id exists.
  --
  cursor csr_valid_activity_id is
  select actd.business_group_id,
         actv.start_date,
         nvl(actv.end_date, hr_api.g_eot)
  from   ota_activity_versions actv,
         ota_activity_definitions actd
  where  p_activity_version_id = actv.activity_version_id
  and    actv.activity_id      = actd.activity_id;
  --
  --
  -- cursor to check that the person_id exists.
  -- We are only intereted to see the person exists. We are not restricting
  -- it by a date because the person may have had the skill before
  -- he joined.
  --

  cursor csr_valid_person_id is
  select business_group_id,effective_start_date, effective_end_date
  from  per_people_f
  where  p_person_id = person_id;
  --and    p_effective_date  between
  --       effective_start_date and effective_end_date;
  --
  -- Cursor to check that the start_date is valid
  -- (Part of fix for bug 572277)
  -- Updated to check against date_of_birth not effective_start_date
  -- for bug #794075
  --
  cursor csr_valid_date_of_birth is
  select min(date_of_birth)
  from  per_people_f
  where  p_person_id = person_id;
  --
  -- Cursor to check that the end_date is valid
  -- Removed (bug #794075)
  --
  -- cursor csr_valid_person_end is
  --  select max(effective_end_date)
  --  from  per_people_f
  --  where  p_person_id = person_id;
  --
  -- Cursor to check that the position_id exists
  --
  -- Changed 12-Oct-99 SCNair (per_positions to hr_positions_f) date track position req.
  --
  cursor csr_valid_position_id is
  select business_group_id, date_effective, hr_general.get_position_date_end(p_position_id)
  from   hr_positions_f
  where  p_position_id = position_id;
  -- and p_effective_date
  -- between effective_start_date
  -- and effective_end_date;
  --and    p_effective_date_from >= date_effective
  --and    nvl(p_effective_date_to,hr_api.g_eot)<=
  -- 	 nvl(date_end,hr_api.g_eot);
  --
  -- Cursor to check that competence_id exists
  --
  cursor csr_valid_competence_id is
  select business_group_id, date_from, date_to
  from   per_competences
  where  p_competence_id = competence_id;
  -- and    nvl(p_effective_date_from,hr_api.g_eot)  >= date_from
  -- and    nvl(p_effective_date_to,hr_api.g_eot)<=
  --	 nvl(date_to,hr_api.g_eot);
  --

  --
  -- Cursor to check that competence_id when the type is 'COMPETENCE_USAGE'
  -- Note; there should not be a date checking for the competence if it
  -- is going to be used for COMPETENCE_USAGE, ASSESSMENT,ASSESSMENT_GROUP
  -- AND ASSESSMENT_COMPETENCE type.
  --
  cursor csr_usage_competence_id is
  select business_group_id
  from   per_competences
  where  p_competence_id = competence_id;

  --
  -- cursor to check that the organization_id is valid
  --
  cursor csr_valid_organization_id is
  select business_group_id,date_from,date_to
  from   hr_organization_units
  where  organization_id	= p_organization_id;
  -- and    p_effective_date_from  >= date_from
  -- and    nvl(p_effective_date_to,hr_api.g_eot)<=
  --	 nvl(date_to,hr_api.g_eot);
  --
  -- cursor to check that the assessment_id is valid
  --
  cursor csr_valid_assessment_id is
  select business_group_id
  from   per_assessments
  where  p_assessment_id = assessment_id;
  --
  --
  -- cursor to check that the assessment_type_id is valid
  --
  cursor csr_valid_assessment_type_id is
  select business_group_id
  from   per_assessment_types
  where  p_assessment_type_id = assessment_type_id;
  --
  -- cursor to check that the rating_level_id is valid
  --
  cursor csr_val_prof_id
  (c_level_id	per_rating_levels.rating_level_id%TYPE) is
  select business_group_id
  from   per_rating_levels
  where  c_level_id = rating_level_id;

  --
  -- cursor to check that the parent_comp_element_id is valid
  --
  cursor csr_valid_comp_id is
  select business_group_id
  from   per_competence_elements
  where  p_parent_competence_element_id =
         competence_element_id;

  --
  -- cursor to check that the qualification_type_id
  --
  cursor csr_valid_qualification_type is
  select qualification_type_id
  from   per_qualification_types
  where  p_qualification_type_id =
         qualification_type_id;
--
--
-- This function was included as part of a fix for bug 572277, but
-- checked the comptence dates against the person's effective dates.
-- This doesn't make sense, since a skill could be learnt before
-- the person was an employee. The check has now been limited to
-- the person's date of birth.
--
function invalid_person_dates(p_date_from in date, p_date_to in date) return boolean is
--
 l_proc		varchar2(72) := g_package||'invalid_person_dates';
--
 Begin
   --
   -- A person cannot have gained a competence before they are born
   -- so check that here... (Changes to fix bug #794075)
   --
   l_date_of_birth := NULL;
   open csr_valid_date_of_birth;
   fetch csr_valid_date_of_birth into l_date_of_birth;
   if p_date_from < nvl(l_date_of_birth, hr_api.g_sot) THEN
      close csr_valid_date_of_birth;
      return true;
   else
      close csr_valid_date_of_birth;
      return false;
   end if;
 end invalid_person_dates;


--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have being set.
  -- ngundura should check only if object_type is not
  -- PROJECT_ROLE AND OPEN_ASSIGNMENT
  if per_cel_shd.g_bus_grp then
  	hr_api.mandatory_arg_error
       	 (p_api_name         => l_proc
       	,p_argument         => 'business_group_id'
       	,p_argument_value   => p_business_group_id
        );
  end if;
  --
  --
  -- We only proceed with the checking if it is not updating and
  -- the p_person_id is not null.
  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id        => p_competence_element_id
         ,p_object_version_number        => p_object_version_number);
  --
  IF ( NOT l_api_updating ) then

     hr_utility.set_location(l_proc, 6);
     --
     -- Check that the person_id exists in the correct BG.
     --
     if(p_person_id IS NOT NULL) then
        --hr_utility.set_location(l_proc, 7);
        open csr_valid_person_id;
        fetch csr_valid_person_id into l_business_group_id,l_start_date,l_end_date;
        if csr_valid_person_id%notfound then
           --hr_utility.set_location(l_proc, 10);
           close csr_valid_person_id;
           --per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK7');
        else

	   close csr_valid_person_id;
	   if
             p_business_group_id <> l_business_group_id then
             --
             -- The  person_id exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 15);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
           elsif invalid_person_dates(p_effective_date_from,p_effective_date_to) then
             --
             -- The person_id is not date valid
             -- Part of fix for bug 572277
             --
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK19');
	   end if;
        end if;
        --
     end if;

     -- check that the activity_version_id is valid
     --
     if(p_activity_version_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 40);
        open csr_valid_activity_id;
        fetch csr_valid_activity_id into l_business_group_id,
                                         l_start_date,
                                         l_end_date;

        if csr_valid_activity_id%notfound then
           hr_utility.set_location(l_proc, 45);
	   hr_utility.set_message(801,'HR_51701_CEL_ACTIVE_ID_INVL');
           hr_multi_message.add
	   (p_associated_column1 =>
	                     'PER_COMPETENCE_ELEMENTS.ACTIVITY_VERSION_ID'
	   );
           close csr_valid_activity_id;
        else
	   close csr_valid_activity_id;
	   if p_business_group_id <> l_business_group_id then
             --
             -- The activity_version exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 50);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
           --
           elsif l_start_date > p_effective_date_from or
                 l_end_date < nvl(p_effective_date_to, l_end_date) then
             --
             -- The activity_version is not date valid
             --
             hr_utility.set_message(810,'OTA_13673_TAV_COMPETENCY_DATES');
             hr_multi_message.add
	     (p_associated_column1 =>
                             'PER_COMPETENCE_ELEMENTS.ACTIVITY_VERSION_ID'
             ,p_associated_column2 =>
                             'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM'
             ,p_associated_column3 =>
                             'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_TO'
	     );
	   end if;
        end if;
        --
     end if;
     --
     -- check that the job_id is valid
     --
     if(p_job_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 80);
        open csr_valid_job_id;
        fetch csr_valid_job_id into l_business_group_id, l_start_date,l_end_date;
        if csr_valid_job_id%notfound then
           hr_utility.set_location(l_proc, 85);
           close csr_valid_job_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK8');
        else
	   close csr_valid_job_id;
	   if
             p_business_group_id <> l_business_group_id then

             --
             -- The job_id exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 90);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
           elsif (p_effective_date_from < l_start_date) OR
                 (nvl(p_effective_date_to,hr_api.g_eot) >
                  nvl(l_end_date,hr_api.g_eot)) THEN
             --
             -- The job_id is not date valid
             -- Part of fix for bug 572277
             --
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK20');


	   end if;
        end if;
        --
     end if;
     --
     -- check that the valid_grade_id is valid
     --
     if(p_valid_grade_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 81);
        open csr_valid_grade_id;
        fetch csr_valid_grade_id into l_business_group_id,l_start_date,l_end_date;
        if csr_valid_grade_id%notfound then
           hr_utility.set_location(l_proc, 82);
           close csr_valid_grade_id;
           hr_utility.set_message(800, 'HR_52372_CEL_INVL_GRD_ID');
           hr_utility.set_location(l_proc,83);
           hr_multi_message.add
	   (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.VALID_GRADE_ID'
	   );
        else
	   close csr_valid_grade_id;
	   if
             p_business_group_id <> l_business_group_id then

             --
             -- The valid_grade_id exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 84);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
          elsif (p_effective_date_from  < l_start_date) OR
  		(nvl(p_effective_date_to,hr_api.g_eot) >
 		 nvl(l_end_date,hr_api.g_eot)) THEN
             --
             -- The valid_grade_id is not date valid
             -- Part of fix for bug 572277
             --
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK22');

	   end if;
        end if;
        --
     end if;

     --
     -- check that the position_id is valid
     --
     if(p_position_id IS NOT NULL) then

        hr_utility.set_location(l_proc, 95);
        open csr_valid_position_id;
        fetch csr_valid_position_id into l_business_group_id,l_start_date,l_end_date;
        if csr_valid_position_id%notfound then
           hr_utility.set_location(l_proc, 100);
           close csr_valid_position_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK9');
        else
	   close csr_valid_position_id;
	   if
             p_business_group_id <> l_business_group_id then
             --
             -- The position_id exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 105);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
           elsif (p_effective_date_from  < l_start_date) OR
  		(nvl(p_effective_date_to,hr_api.g_eot) >
 		 nvl(l_end_date,hr_api.g_eot)) THEN
             --
             -- The position_id is not date valid
             -- Part of fix for bug 572277
             --
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK20');

	   end if;
        end if;
        --
     end if;
     --
     -- check that the organization_id is valid
     --
     if(p_organization_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 110);
        open csr_valid_organization_id;
        fetch csr_valid_organization_id into l_business_group_id,l_start_date,l_end_date;
        if csr_valid_organization_id%notfound then
           hr_utility.set_location(l_proc, 115);
           close csr_valid_organization_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK10');
        else
	   close csr_valid_organization_id;
	   if
             p_business_group_id <> l_business_group_id then
             --
             -- The organization_id exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 120);

             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
           elsif (p_effective_date_from  < l_start_date) OR
  		(nvl(p_effective_date_to,hr_api.g_eot) >
 		 nvl(l_end_date,hr_api.g_eot)) THEN
             --
             -- The organization_id is not date valid
             -- Part of fix for bug 572277
             --
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK20');
	   end if;
	   --
        end if;
        --
     end if;
     --
     -- check that the assessment_id is valid
     --
     if(p_assessment_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 125);
        open csr_valid_assessment_id;
        fetch csr_valid_assessment_id into l_business_group_id;

        if csr_valid_assessment_id%notfound then
           hr_utility.set_location(l_proc, 130);
           close csr_valid_assessment_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK14');
        else
	   close csr_valid_assessment_id;
	   if
             p_business_group_id <> l_business_group_id then
             --
             -- The assessment_id exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 135);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');

	  end if;
	  --
        end if;
        --
     end if;
     --
     -- check that the assessment_type_id is valid
     --
     --
     if (p_assessment_type_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 151);
        open csr_valid_assessment_type_id;
        fetch csr_valid_assessment_type_id into l_business_group_id;
        if csr_valid_assessment_type_id%notfound then

           hr_utility.set_location(l_proc, 152);
           close csr_valid_assessment_type_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK15');
        else
	   close csr_valid_assessment_type_id;
	   if
             p_business_group_id <> l_business_group_id then
             --
             -- The assessment_type_id exists in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 153);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
           end if;

	   --
        end if;
     end if;
     --
     -- check that the parent_comp_elements_id is valid
     --
     if(p_parent_competence_element_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 155);
        open csr_valid_comp_id;
        fetch csr_valid_comp_id into l_business_group_id;
        if csr_valid_comp_id%notfound then
           hr_utility.set_location(l_proc, 160);
           close csr_valid_comp_id;

           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK18');
        else
	   close csr_valid_comp_id;
	   if
             p_business_group_id <> l_business_group_id then
             --
             -- The parent_comp_element_id exists in
	     -- a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 165);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
           end if;
	   --

        end if;
        --
     end if;
     --
     --
     -- check that the high_proficiency_level_id is valid
     --
     if(p_high_proficiency_level_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 205);
        open csr_val_prof_id(p_high_proficiency_level_id);
        fetch csr_val_prof_id into l_business_group_id;
        if csr_val_prof_id%notfound then
           hr_utility.set_location(l_proc, 210);
           close csr_val_prof_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK6');
        else

	   close csr_val_prof_id;
	   if
             p_business_group_id <> l_business_group_id and l_business_group_id is not null then
             --
             -- The high_proficiency_level_id exists in a
             -- different_business_group_id.
             --
             hr_utility.set_location(l_proc, 215);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
	   end if;
        end if;
        --
     end if;

     --
     -- check that the proficiency_level_id is valid
     --
     if(p_proficiency_level_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 220);
        open csr_val_prof_id(p_proficiency_level_id);
	hr_utility.set_location(l_proc, 221);
        fetch csr_val_prof_id into l_business_group_id;
        if csr_val_prof_id%notfound then
           hr_utility.set_location(l_proc, 225);
           close csr_val_prof_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK5');
        else

	   hr_utility.set_location(l_proc, 226);
	   close csr_val_prof_id;
	   hr_utility.set_location(l_proc, 227);
      -- ngundura changes done for pa requirements
	   if
             p_business_group_id <> l_business_group_id and l_business_group_id is not null then
             --
             -- The proficiency_level_id exists
	     -- in a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 230);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
	   end if;
        end if;

        --
     end if;
     --
     -- check that the weighting_level_id is valid
     --
     if(p_weighting_level_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 235);
        open csr_val_prof_id(p_weighting_level_id);
        fetch csr_val_prof_id into l_business_group_id;
        if csr_val_prof_id%notfound then
           hr_utility.set_location(l_proc, 240);
           close csr_val_prof_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK17');

        else
	   close csr_val_prof_id;
  	   if
             p_business_group_id <> l_business_group_id and l_business_group_id is not null then
             --
             -- The weighting_level_id exists in
	     -- a different_business_group_id.
             --
             hr_utility.set_location(l_proc, 245);
             per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
	  end if;
        end if;
        --

     end if;
     --
     -- check that the rating_level_id is valid
     --
     if(p_rating_level_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 250);
        open csr_val_prof_id(p_rating_level_id);
        fetch csr_val_prof_id into l_business_group_id;
        if csr_val_prof_id%notfound then
           hr_utility.set_location(l_proc, 255);
           close csr_val_prof_id;
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK16');
        else

	  close csr_val_prof_id;
     -- ngundura changes done for pa requirements
	  if
            p_business_group_id <> l_business_group_id and l_business_group_id is not null then
            --
            -- The rating_level_id exists in a different_business_group_id.
            --
            hr_utility.set_location(l_proc, 260);
            per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
	  end if;
        end if;
        --
     end if;
     --

     -- check that the competence_id is valid
     --
     if(p_competence_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 265);
        if p_type = 'COMPETENCE_USAGE' OR p_type = 'ASSESSMENT_GROUP' OR
	   p_type = 'ASSESSMENT' OR p_type= 'ASSESSMENT_COMPETENCE' then
	   open csr_usage_competence_id;
	   fetch csr_usage_competence_id into l_business_group_id;
	   if csr_usage_competence_id%notfound then
	     close csr_usage_competence_id;
	     per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK1');
	   else
	     close csr_usage_competence_id;
     -- ngundura changes done for pa requirements
     -- added the AND condition in the following if
   	     if
               p_business_group_id <> l_business_group_id and l_business_group_id is not null then
               --
               -- The competence_id exists in a different_business_group_id.
               --
               per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
             end if;
	   end if;
         else
           open csr_valid_competence_id;
	   hr_utility.set_location(l_proc, 266);
           fetch csr_valid_competence_id into l_business_group_id,l_start_date,l_end_date;
	   hr_utility.set_location(l_proc, 267);
           if csr_valid_competence_id%notfound then
              hr_utility.set_location(l_proc, 270);
              close csr_valid_competence_id;
              per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK1');
           else
	      hr_utility.set_location(l_proc, 271);
	      close csr_valid_competence_id;
       -- ngundura changes done for pa requirement
       -- added the AND condition in the following if
   	      if
               p_business_group_id <> l_business_group_id and l_business_group_id is not null then
               --
               -- The competence_id exists in a different_business_group_id.
               --
               hr_utility.set_location(l_proc, 275);
               per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
              elsif (nvl(p_effective_date_from,hr_api.g_eot) <
                     nvl(l_start_date,hr_api.g_eot)) OR
    		    (nvl(p_effective_date_to,nvl(l_end_date,hr_api.g_eot)) >                                 		     nvl(l_end_date,hr_api.g_eot)) THEN
                --
                -- The competence_id is not date valid
                -- Part of fix for bug 572277
                --
                per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK21');

	      end if;
          end if;
          --
        end if;
     end if;
     --
  elsif (l_api_updating and (nvl(per_cel_shd.g_old_rec.high_proficiency_level_id,
	 hr_api.g_number)
	 <> nvl(p_high_proficiency_level_id,hr_api.g_number) OR
         nvl(per_cel_shd.g_old_rec.proficiency_level_id, hr_api.g_number)
         <> nvl(p_proficiency_level_id,hr_api.g_number))) then
         --
         -- check that the high_proficiency_level_id is valid
         --
         if(p_high_proficiency_level_id IS NOT NULL) then
           hr_utility.set_location(l_proc, 280);

           open csr_val_prof_id(p_high_proficiency_level_id);
           fetch csr_val_prof_id into l_business_group_id;
           if csr_val_prof_id%notfound then
              hr_utility.set_location(l_proc, 285);
              close csr_val_prof_id;
              per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK6');
           else
              close csr_val_prof_id;
         -- ngundura changes for pa requirements
              if
               p_business_group_id <> l_business_group_id and l_business_group_id is not null then
               --
               -- The high_proficiency_level_id exists in a
               -- different_business_group_id.

               --
               hr_utility.set_location(l_proc, 290);
               per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
              end if;
            end if;
           --
        end if;
        --
        -- check that the proficiency_level_id is valid
        --
        if(p_proficiency_level_id IS NOT NULL) then
           hr_utility.set_location(l_proc, 295);
           open csr_val_prof_id(p_proficiency_level_id);

           fetch csr_val_prof_id into l_business_group_id;
           if csr_val_prof_id%notfound then
              hr_utility.set_location(l_proc, 300);
              close csr_val_prof_id;
              per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK5');
           else
              close csr_val_prof_id;
        -- ngundura changes for pa requirements
        -- added the AND condition in the following if
              if
                p_business_group_id <> l_business_group_id and l_business_group_id is not null then
                --
                -- The proficiency_level_id exists in a
                -- different_business_group_id.
                --

                hr_utility.set_location(l_proc, 305);
                per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK2');
              end if;
           end if;
        --
        end if;
	--
	-- Check the enterprise_id is valid
	--
	--
	if(p_enterprise_id is not null ) then
	  hr_utility.set_location(l_proc, 310);
	  if (p_enterprise_id <> p_business_group_id) then
	      hr_utility.set_message(800,'HR_52252_CEL_ENTPISE_ID_INVL');
	      hr_utility.set_location(l_proc,315);

	  end if;
       end if;
  elsif l_api_updating then
    --

     if(p_person_id IS NOT NULL) then
        --hr_utility.set_location(l_proc, 7);
        open csr_valid_person_id;
        fetch csr_valid_person_id into l_business_group_id,l_start_date,l_end_date;
	close csr_valid_person_id;
        if invalid_person_dates(p_effective_date_from,p_effective_date_to) then
           --
           -- The person_id is not date valid
           -- Part of fix for bug 572277
           --
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK19');
        end if;
        --
     end if;
     --
     -- check that the activity_version_id is valid
     --
     if(p_activity_version_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 330);
        open csr_valid_activity_id;
        fetch csr_valid_activity_id into l_business_group_id,
                                         l_start_date,
                                         l_end_date;
	close csr_valid_activity_id;
        if l_start_date > p_effective_date_from or
           l_end_date < nvl(p_effective_date_to, l_end_date) THEN
           --
           -- The activity_version is not date valid
           --
           hr_utility.set_message(810,'OTA_13673_TAV_COMPETENCY_DATES');
           hr_multi_message.add
           (p_associated_column1 =>
                             'PER_COMPETENCE_ELEMENTS.ACTIVITY_VERSION_ID'
           ,p_associated_column2 =>
                             'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM'
           ,p_associated_column3 =>
                             'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_TO'
	   );
        end if;
        --
     end if;
     --
     -- check that the job_id is valid
     --
     if(p_job_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 340);
        open csr_valid_job_id;
        fetch csr_valid_job_id into l_business_group_id, l_start_date,l_end_date;
	close csr_valid_job_id;
        if (p_effective_date_from < l_start_date) OR
           (nvl(p_effective_date_to,hr_api.g_eot) >
            nvl(l_end_date,hr_api.g_eot)) THEN
          --
          -- The job_id is not date valid
          -- Part of fix for bug 572277
          --
          per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK20');
        end if;
        --
     end if;
     --
     -- check that the valid_grade_id is valid
     --
     if(p_valid_grade_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 350);
        open csr_valid_grade_id;
        fetch csr_valid_grade_id into l_business_group_id,l_start_date,l_end_date;
	close csr_valid_grade_id;
        if (p_effective_date_from  < l_start_date) OR
  	   (nvl(p_effective_date_to,hr_api.g_eot) >
 	    nvl(l_end_date,hr_api.g_eot)) THEN
          --
          -- The valid_grade_id is not date valid
          -- Part of fix for bug 572277
          --
          per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK22');

        end if;
        --
     end if;

     --
     -- check that the position_id is valid
     --
     if(p_position_id IS NOT NULL) then

        hr_utility.set_location(l_proc, 360);
        open csr_valid_position_id;
        fetch csr_valid_position_id into l_business_group_id,l_start_date,l_end_date;
	close csr_valid_position_id;
        if (p_effective_date_from  < l_start_date) OR
  	   (nvl(p_effective_date_to,hr_api.g_eot) >
 	    nvl(l_end_date,hr_api.g_eot)) THEN
          --
          -- The position_id is not date valid
          -- Part of fix for bug 572277
          --
          per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK20');

	end if;
        --
     end if;
     --
     -- check that the organization_id is valid
     --
     if(p_organization_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 370);
        open csr_valid_organization_id;
        fetch csr_valid_organization_id into l_business_group_id,l_start_date,l_end_date;
	close csr_valid_organization_id;
        if (p_effective_date_from  < l_start_date) OR
       	   (nvl(p_effective_date_to,hr_api.g_eot) >
	    nvl(l_end_date,hr_api.g_eot)) THEN
           --
           -- The organization_id is not date valid
           -- Part of fix for bug 572277
           --
           per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK20');
	end if;
	   --
     end if;
     --
     -- check that the competence_id is valid
     --
     if(p_competence_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 380);
        open csr_valid_competence_id;
        fetch csr_valid_competence_id into l_business_group_id,l_start_date,l_end_date;
	close csr_valid_competence_id;
        if (nvl(p_effective_date_from,hr_api.g_eot) <
            nvl(l_start_date,hr_api.g_eot)) OR
    	   (nvl(p_effective_date_to,nvl(l_end_date,hr_api.g_eot)) >
 	    nvl(l_end_date,hr_api.g_eot)) THEN
           --
           -- The competence_id is not date valid
           -- Part of fix for bug 572277
           --
           Per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK21');

        end if;
          --
     end if;
     --
     -- check that the qualification_type_id is valid
     --
     if(p_qualification_type_id IS NOT NULL) then
        hr_utility.set_location(l_proc, 390);

        open csr_valid_qualification_type;
        fetch csr_valid_qualification_type into l_qualification_type_id;

        if csr_valid_qualification_type%NOTFOUND then
	   close csr_valid_qualification_type;
           Per_cel_shd.constraint_error('PER_COMPETENCE_ELEMENTS_FK23');
        else
	   close csr_valid_qualification_type;
        end if;
        --
     end if;
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 400);
  --

end chk_foreign_keys;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_party_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the person_id and the party_id are matched in
--     per_all_people_f
--     and if person_id is not null and party_id is null, derive party_id
--     from per_all_people_f from person_id
--
--  Pre_conditions:
--    A valid business_group_id
--
--  In Arguments:
--    A Pl/Sql record structre.
--    effective_date

--
--  Post Success:
--    Process continues if :
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of

--  Access Status:
--    Internal Table Handler Use Only.
--
--
Procedure chk_party_id(
   p_rec             in out nocopy per_cel_shd.g_rec_type
  ,p_effective_date  in date
  )is
--
  l_proc    varchar2(72)  :=  g_package||'chk_party_id';
  l_party_id     per_competence_elements.party_id%TYPE;
  l_party_id2    per_competence_elements.party_id%TYPE;
--
  --
  -- cursor to check that the party_id maches person_id
  --
  cursor csr_get_party_id is
  select party_id
  from    per_all_people_f per
    where   per.person_id = p_rec.person_id
    and     p_effective_date
    between per.effective_start_date
    and     nvl(per.effective_end_date,hr_api.g_eot);
  --
  cursor csr_valid_party_id is
  select party_id
  from hz_parties hzp
  where hzp.party_id = p_rec.party_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  if p_rec.person_id is not null then
    --
    open csr_get_party_id;
    fetch csr_get_party_id into l_party_id;
    close csr_get_party_id;
    hr_utility.set_location(l_proc,20);
    if p_rec.party_id is not null then
      if p_rec.party_id <> nvl(l_party_id,-1) then
        hr_utility.set_message(800, 'HR_289343_PERSONPARTY_MISMATCH');
        hr_utility.set_location(l_proc,30);
        hr_multi_message.add
       (p_associated_column1 =>
                          'PER_COMPETENCE_ELEMENTS.PARTY_ID'
       ,p_associated_column2 =>
                          'PER_COMPETENCE_ELEMENTS.PERSON_ID'
	);
      end if;
    --
    else -- if party_id is null
      --
      -- derive party_id from per_all_people_f using person_id
      --
        hr_utility.set_location(l_proc,50);
        p_rec.party_id := l_party_id;
    end if;
    --
  else  -- if person_id is null
    --
    if p_rec.party_id is not null then
      open csr_valid_party_id;
      fetch csr_valid_party_id into l_party_id2;
      if csr_valid_party_id%notfound then
        close csr_valid_party_id;
        hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
        hr_utility.set_location(l_proc,70);
        hr_multi_message.add
        (p_associated_column1 =>
                          'PER_COMPETENCE_ELEMENTS.PARTY_ID'
        );
      else
        --
        close csr_valid_party_id;
	--
      end if;
      --
    end if; -- end if for if party is not null.
    --
  end if; -- end if for if person_id is null.
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
End chk_party_id;
--
--
------------------------------------------------------------------------------
--|--------------------------< Chk_proficiency_level_id >--------------------|
------------------------------------------------------------------------------
--
-- Description:
--   It checks that if the parent of the proficiency_level is the rating
--   scale,then the rating_sacle should be for the same competence which is
--   referenced in the competence_element.
--   It checks that if the parent of the proficiency_level is the competence,
--   then the competence should be the same as the one which is referenced
--   in competence_element.
--   If the high and low proficiency levels are not null then the high proficiency
--   level should be greater or equal to the low_proficiency level.
--
-- Pre-Condition
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_object_version_number
--   p_proficiency_level_id
--   p_high_proficiency_level_id
--   p_competence_id
--
-- Post Success:
--   Processing continues if:
--     - The proficiency or high proficiency value is valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The proficiency or high proficiency value is invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_proficiency_level_id
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_business_group_id
    in per_competence_elements.business_group_id%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ,p_proficiency_level_id
    in per_competence_elements.proficiency_level_id%TYPE
   ,p_high_proficiency_level_id
    in per_competence_elements.high_proficiency_level_id%TYPE
   ,p_competence_id
   in per_competence_elements.competence_id%TYPE
   ,p_party_id
   in per_competence_elements.party_id%TYPE
   ) is
--
   l_proc              varchar2(72):=
		       g_package||'chk_proficiency_level_id';
   l_api_updating      boolean;
   l_competence_id1    number(9);
   l_rating_scale_id1  number(9);
   l_competence_id2    number(9);
   l_rating_scale_id2  number(9);
   l_step_value1       number(15);
   l_step_value2       number(15);
   l_rating_scale_id   number(9);

--
--
procedure validate_comp_levels (
                                 p_prof_id	in  number,
				 p_error	in  varchar2,
				 p_step_val out nocopy number) is
  l_proc		varchar2(80):= 'per_cel_bus.validate_comp_levels';
  --
  -- cursor to check that the rating_scale referenced by the proficiency
  -- is the same as the one that the competence in competence_element is
  -- referencing.
  --
  -- Cursor to check that the rating_scale_id is for the same competence
  -- which is referenced in the proficiecy_level.
  --
  cursor csr_get_rating_scale (p_prof_id in NUMBER) is
  select step_value
  --
  --  This is when the parent of the proficiency is the competence.
  --
  -- ngundura changes for pa requirements

  from   per_rating_levels
  where  p_competence_id = competence_id
  and    p_prof_id = rating_level_id
--  where  p_business_group_id  = business_group_id + 0
--  and    p_competence_id = competence_id
--  and    p_prof_id = rating_level_id

  union
  --
  -- This is when the parent of the proficiency level is the rating scale.
  --

  select ral.step_value
  from   per_rating_levels  ral,
	 per_rating_scales  ras,
	 per_competences    comp
  where  p_competence_id          = comp.competence_id
  and    ras.rating_scale_id      = comp.rating_scale_id
  and    ral.rating_scale_id      = ras.rating_scale_id
  and    p_prof_id                = ral.rating_level_id;

--  where  p_business_group_id + 0  = ral.business_group_id
--  and	 p_business_group_id + 0  = ras.business_group_id
--  and    p_business_group_id + 0  = comp.business_group_id
--  and    p_competence_id	  = comp.competence_id
--  and    ras.rating_scale_id	  = comp.rating_scale_id
--  and    ral.rating_scale_id	  = ras.rating_scale_id;
  -- ngundura end of changes.
  --
begin
      open csr_get_rating_scale(p_prof_id);
      fetch csr_get_rating_scale into p_step_val;
      hr_utility.set_location(l_proc,5);

      if csr_get_rating_scale%notfound then
         --
 	 -- raise an error. The proficiency_level_id must be invalid
	 --
	 close csr_get_rating_scale;
	 if p_error = 'HIGH_PROF' then
	    hr_utility.set_message(801,'HR_51616_CEL_HG_PROF_ID_INVL');
	    hr_utility.set_location(l_proc,15);
            hr_multi_message.add
            (p_associated_column1 =>
	                   'PER_COMPETENCE_ELEMENTS.HIGH_PROFICIENCY_LEVEL_ID'
            ,p_associated_column2 =>
                           'PER_COMPETENCE_ELEMENTS.COMPETENCE_ID'
            );
         else
	    hr_utility.set_message(801,'HR_51615_CEL_PROF_ID_INVL');
	    hr_utility.set_location(l_proc,20);
            hr_multi_message.add
           (p_associated_column1 =>
	                   'PER_COMPETENCE_ELEMENTS.PROFICIENCY_LEVEL_ID'
           ,p_associated_column2 =>
                           'PER_COMPETENCE_ELEMENTS.COMPETENCE_ID'
	    );
         end if;
	 --
	 hr_utility.set_location(l_proc,25);
     else
        close csr_get_rating_scale;
     end if;
     hr_utility.set_location('LEAVING: ' ||l_proc,30);
end validate_comp_levels;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  -- Check mandatory parameters have being set.
  -- ngundura check for business group_id only if its business_group specific
  if per_cel_shd.g_bus_grp then
      hr_api.mandatory_arg_error
       (p_api_name         => l_proc
       ,p_argument         => 'business_group_id'
       ,p_argument_value   => p_business_group_id
       );
  end if;
  --
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for proficiency has changed
  --
  --
  l_api_updating := per_cel_shd.api_updating
           (p_competence_element_id        => p_competence_element_id
           ,p_object_version_number        => p_object_version_number);
  --
  --
  if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.proficiency_level_id,
     hr_api.g_number)<> nvl(p_proficiency_level_id,hr_api.g_number) OR
     nvl(per_cel_shd.g_old_rec.high_proficiency_level_id,hr_api.g_number)
     <>  nvl(p_high_proficiency_level_id,hr_api.g_number))
     OR  not l_api_updating) then
     --
     -- do nothing if both high and low proficiencies are null
     --
     if (p_high_proficiency_level_id is null AND
         p_proficiency_level_id is null) then
         hr_utility.set_location(l_proc,5);
         --
         -- raise error if the high_prof is set but not the proficiency_level.
         --
     elsif (p_proficiency_level_id is null AND
              p_high_proficiency_level_id is not null) then
	      hr_utility.set_location(l_proc,6);
	      hr_utility.set_message(801,'HR_51726_CEL_PROF_HG_PROF');
              hr_multi_message.add
              (p_associated_column1 =>
	                 'PER_COMPETENCE_ELEMENTS.HIGH_PROFICIENCY_LEVEL_ID'
              ,p_associated_column2 =>
	                 'PER_COMPETENCE_ELEMENTS.PROFICIENCY_LEVEL_ID'
	      );
     else
         --
         -- validate competence_id against the proficiency_levels
         -- the competence_id MUST not be null
         --
         if p_competence_id is null then
           --
   	   -- issue an error message if the competence_id is null
           --
            hr_utility.set_location(l_proc,10);
            hr_utility.set_message(801,'HR_51642_COMP_ID_MANDATORY');
            hr_multi_message.add
            (p_associated_column1 =>
                          'PER_COMPETENCE_ELEMENTS.COMPETENCE_ID'
             );
	 --
         else -- if p_competence_id is not null
	 --
           if p_proficiency_level_id is not null then
  	       validate_comp_levels (p_prof_id      => p_proficiency_level_id,
		                     p_error        => 'PROF',
				     p_step_val     => l_step_value1);
               hr_utility.set_location(l_proc,15);
               --
           end if;
   	   if p_high_proficiency_level_id is not null then
  	       validate_comp_levels (p_prof_id      => p_high_proficiency_level_id,
		                     p_error        => 'HIGH_PROF',
				     p_step_val     => l_step_value2);
               hr_utility.set_location(l_proc,20);
     	     --
           end if;
	   --
	   --
           -- Validate that if both high and low proficiency level_id are
	   -- not null. then the step value of the high proficiec is greater
 	   -- or equal to the step value of the proficiency level id.
	   --
           if (p_high_proficiency_level_id is not null and p_proficiency_level_id
	      is not null) then
	     if(l_step_value1 > l_step_value2) then
                hr_utility.set_location(l_proc,25);
                hr_utility.set_message(801,'HR_51644_CEL_PROF_VAL_ERROR');
                hr_multi_message.add
               (p_associated_column1 =>
	                    'PER_COMPETENCE_ELEMENTS.HIGH_PROFICIENCY_LEVEL_ID'
               ,p_associated_column2 =>
	                    'PER_COMPETENCE_ELEMENTS.PROFICIENCY_LEVEL_ID'
	        );
             end if;
           end if;
          --
        end if; -- end if p_competence_id is not null
      --
      end if;
      --
  end if;   -- end if for api_updating
 hr_utility.set_location('Leaving: ' || l_proc, 30);
end chk_proficiency_level_id;
--
--
------------------------------------------------------------------------------
--|--------------------------< Chk_rating_weighting_id >--------------------|
------------------------------------------------------------------------------
--
-- Description:
--   It checks that if the rating_level_id on the competence_element is not
--   null then it refers to the same rating_scale as the corresponding
--   assessment_type.
--
--   It checks that if the weighting_level_id on the competence_element is not
--   null then it refers to the same weighting_scale as the corresponding
--   assessment_type.
--
--   It checks if either rateing_level_id or weighting level_id are entered then
--   the assemment_id or assessment_type_id is not null.
--
-- Pre-Condition
--   None.
--
-- In Arguments:
--   p_competence_element_id
--   p_object_version_number
--   p_rating_level_id

--   p_weighting_level_id
--   p_assessment_id
--   p_assessment_type_id
--
-- Post Success:
--   Processing continues if:
--     - The rating_level and weighting_level values are valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The rating_level and weighting_level values are invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_rating_weighting_id
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_business_group_id
    in per_competence_elements.business_group_id%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ,p_rating_level_id
    in per_competence_elements.rating_level_id%TYPE
   ,p_weighting_level_id
    in per_competence_elements.weighting_level_id%TYPE
   ,p_assessment_id
    in per_competence_elements.assessment_id%TYPE
   ,p_type
    in per_competence_elements.type%TYPE
   ,p_party_id
    in per_competence_elements.party_id%TYPE
   ) is
--
   l_proc              varchar2(72):= g_package||'chk_rating_weighting_id';
   l_api_updating      boolean;
   l_rate_weight       number(9);
   l_perf_weight       varchar2(30);
   l_assessment_type_id number(9);
   l_rating_scale_id    number(9);

   l_weighting_scale_id number(9);
--
  -- cursor to check that the rating_sacle referenced by the rating_level
  -- is the same one that the assessment_type in competence_element is
  -- referencing.
  --
  cursor csr_valid_rate_weight_id (c_rate_level_id in number,
				   c_scale_type	   in varchar2)is
  select ast.rating_scale_id, ast.weighting_scale_id
  from   per_assessment_types ast,
	 per_assessments      ass,
	 per_rating_levels    ral
  where  ass.assessment_id	=  p_assessment_id
  and    ass.assessment_type_id =  ast.assessment_type_id
  and    decode(c_scale_type, 'PERFORMANCE', ast.rating_scale_id,
	ast.weighting_scale_id) = ral.rating_scale_id
  and	 ral.rating_level_id    = c_rate_level_id
  and    nvl(ast.business_group_id +0,p_business_group_id)  = p_business_group_id
  and    nvl(ast.business_group_id,ass.business_group_id+0) = ass.business_group_id+0
  and	 ass.business_group_id+0  = NVL(ral.business_group_id , ass.business_group_id);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  -- Check mandatory parameters have being set.
  --  ngundura check should only be for business group specific
  if per_cel_shd.g_bus_grp then
      hr_api.mandatory_arg_error
         (p_api_name         => l_proc
         ,p_argument         => 'business_group_id'
         ,p_argument_value   => p_business_group_id
         );
  end if;
  --
  if hr_multi_message.no_exclusive_error
   ( p_check_column1 => 'PER_COMPETENCE_ELEMENTS.TYPE'
   ) then
    --
    -- Only proceed with validation if :
    -- a) The current  g_old_rec is current and
    -- b) The value for proficiency has changed
    --
    --
    l_api_updating := per_cel_shd.api_updating
           (p_competence_element_id        => p_competence_element_id
           ,p_object_version_number        => p_object_version_number);
    --
    -- only do this procedure if the type is assessment.
    --
    if p_type = 'ASSESSMENT' then
      --
      if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.rating_level_id,
          hr_api.g_number)<> nvl(p_rating_level_id,hr_api.g_number) OR
         nvl(per_cel_shd.g_old_rec.weighting_level_id,hr_api.g_number)
         <>  nvl(p_weighting_level_id,hr_api.g_number))
         OR  not l_api_updating) then
         --
         -- do nothing if both rating and weighting are null
         --
         if (p_rating_level_id is null AND p_weighting_level_id is null) then
             hr_utility.set_location(l_proc,5);
         else
           if (p_assessment_id is null) then
   	     hr_utility.set_location(l_proc,10);
             hr_utility.set_message(801,'HR_51645_CEL_ASS_ASS_TP_NULL');
             hr_multi_message.add
             (p_associated_column1 =>
	                      'PER_COMPETENCE_ELEMENTS.ASSESSMENT_ID'
             ,p_associated_column2 =>
	                      'PER_COMPETENCE_ELEMENTS.RATING_LEVEL_ID'
             ,p_associated_column3 =>
	                      'PER_COMPETENCE_ELEMENTS.WEIGHTING_LEVEL_ID'
             ,p_associated_column4 =>
	                      'PER_COMPETENCE_ELEMENTS.TYPE'
             );

           end if;
           --
           -- now the cursor with appropriate assessment_type parameter.
           --
           if p_rating_level_id is not null then
	     l_perf_weight := 'PERFORMANCE';
	     l_rate_weight := p_rating_level_id;
           else
  	     l_perf_weight := 'WEIGHTING';
             l_rate_weight := p_weighting_level_id;
           end if;
           --
           open csr_valid_rate_weight_id (l_rate_weight,
      		                        l_perf_weight);
           fetch csr_valid_rate_weight_id into l_rating_scale_id,
					   l_weighting_scale_id;
           if csr_valid_rate_weight_id%notfound then
             close csr_valid_rate_weight_id;
       	     hr_utility.set_location(l_proc,15);
	     hr_utility.set_message(801,'HR_51727_CEL_RATE_ASS_ID_INVL');
             --
	     if p_rating_level_id is not null then
	       --
               hr_multi_message.add
               (p_associated_column1 =>
	                    'PER_COMPETENCE_ELEMENTS.ASSESSMENT_ID'
               ,p_associated_column2 =>
	                    'PER_COMPETENCE_ELEMENTS.RATING_LEVEL_ID'
               ,p_associated_column3 =>
                            'PER_COMPETENCE_ELEMENTS.TYPE'
                );
             else
               --
               hr_multi_message.add
               (p_associated_column1 =>
	                      'PER_COMPETENCE_ELEMENTS.ASSESSMENT_ID'
               ,p_associated_column2 =>
	                      'PER_COMPETENCE_ELEMENTS.WEIGHTING_LEVEL_ID'
               ,p_associated_column3 =>
                            'PER_COMPETENCE_ELEMENTS.TYPE'
                );
	     end if;
	   --
           else
	     close csr_valid_rate_weight_id;
	     hr_utility.set_location(l_proc,20);
           end if;  -- end if for csr_valid_rate_weight_id%notfound
        end if; -- end if for any of rating_level_id or weighting_level_id is not null.
      end if; -- end if for api_updating
    end if; -- end if for checking whether TYPE is assessment.
  end if; -- end if for no_exclusive_error check for TYPE
hr_utility.set_location('Leaving: ' || l_proc, 30);
end chk_rating_weighting_id;
--
--
------------------------------------------------------------------------------
--|--------------------------< Chk_competence_element_dates >----------------|
------------------------------------------------------------------------------
--
-- Description:
--   It checks that the dates for a specifice competence_id are not overlapped
--   for a person_id,Job_id,valid_grade_id,Position_id,organisation_id and
--   then it refers to the same rating_scale as the corresponding
--   assessment_type.
--
-- Pre-Condition
--   None.
--
-- In Arguments:
--   p_competence_element_id
--   p_competence_id
--   p_business_group_id
--   p_object_version_number
--   p_effective_date_from
--   p_effective_date_to
--   p_person_id
--   p_job_id
--   p_valid_grade_id
--   p_position_id
--   p_organization_id
--   p_enterprise_id
--
-- Post Success:
--   Processing continues if:
--     - The p_person_id, p_job_id, p_valid_grade_id,
--       p_position_id,p_organization_id,
--       are valid
--
-- Post Failure:
--    An application error is raised and processing is terminated if any

--      - The p_person_id or  p_job_id or p_position_id or p_organization_id or
--	  are invalid.
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_competence_element_dates
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_business_group_id
    in per_competence_elements.business_group_id%TYPE
   ,p_competence_id
    in per_competence_elements.competence_id%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ,p_person_id
    in per_competence_elements.person_id%TYPE
   ,p_position_id
    in per_competence_elements.position_id%TYPE
   ,p_organization_id
    in per_competence_elements.organization_id%TYPE
   ,p_job_id
    in per_competence_elements.job_id%TYPE
   ,p_valid_grade_id
    in per_competence_elements.valid_grade_id%TYPE
   ,p_effective_date_from
    in per_competence_elements.effective_date_from%type
   ,p_effective_date_to
    in per_competence_elements.effective_date_to%TYPE
   ,p_enterprise_id
    in per_competence_elements.enterprise_id%TYPE
   ) is
--
   l_proc              varchar2(72)
	 	       := g_package||'chk_competence_element_dates';
   l_api_updating      boolean;
   l_exists	       varchar2(1);
   --
   l_associate_attribute varchar2(50);
   --
--
procedure check_all_dates (p_check_type in varchar2,
                           p_key_id     in number,
                           p_valid_grade_null in varchar2,
                           p_error_app  in number,
                           p_error      in varchar2) is
--
l_proc			varchar2(80):= 'check_all_dates';
l_exists		varchar2(1);
TYPE csr_check_dates_type is ref cursor;
csr_check_dates csr_check_dates_type;
v_check_type varchar2(20);
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 1);
--
   if p_check_type = 'GRADE' then
           v_check_type := 'VALID_GRADE_ID';
        else
           v_check_type := p_check_type || '_ID';
   end if;

   open csr_check_dates for 'select null from per_competence_elements where '
           || v_check_type || ' = :p_key_id'
           || ' and competence_id =  :p_competence_id'
           || ' and nvl(business_group_id,-999) = nvl(:p_business_group_id,-999)'
           || ' and :p_effective_date_from <= nvl(effective_date_to,:eot1)'
           || ' and nvl(:p_effective_date_to,:eot2) >= effective_date_from'
           || ' and (competence_element_id <> :p_competence_element_id1  or :p_competence_element_id2 is null)'
           || ' and decode(:p_valid_grade_null,''Y'',valid_grade_id,null) is null'
           using p_key_id,p_competence_id,p_business_group_id,p_effective_date_from,
			hr_api.g_eot,p_effective_date_to, hr_api.g_eot,
				p_competence_element_id,p_competence_element_id,p_valid_grade_null;

   fetch csr_check_dates into l_exists;
   if csr_check_dates%found then
      hr_utility.set_location(l_proc,2);
      close csr_check_dates;
      hr_utility.set_message(p_error_app,p_error);
      if p_check_type = 'ENTERPRISE' then
        l_associate_attribute := 'PER_COMPETENCE_ELEMENTS.ENTERPRISE_ID';
      elsif p_check_type = 'PERSON' then
        l_associate_attribute := 'PER_COMPETENCE_ELEMENTS.PERSON_ID';
      elsif p_check_type = 'JOB' then
        l_associate_attribute := 'PER_COMPETENCE_ELEMENTS.JOB_ID';
      elsif p_check_type = 'POSITION' then
        l_associate_attribute := 'PER_COMPETENCE_ELEMENTS.POSITION_ID';
      elsif p_check_type = 'GRADE' then
        l_associate_attribute := 'PER_COMPETENCE_ELEMENTS.VALID_GRADE_ID';
      elsif p_check_type = 'ORGANIZATION' then
        l_associate_attribute := 'PER_COMPETENCE_ELEMENTS.ORGANIZATION_ID';
      end if;
      if p_valid_grade_null is null then
        hr_multi_message.add
        (
         p_associated_column1 => l_associate_attribute
--       p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM'
        ,p_associated_column2 => 'PER_COMPETENCE_ELEMENTS.COMPETENCE_ID'
        ,p_associated_column3 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM'
        ,p_associated_column4 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_TO'
        );
      else
        hr_multi_message.add
        (
        p_associated_column1 => l_associate_attribute
--      p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM'
        ,p_associated_column2 => 'PER_COMPETENCE_ELEMENTS.COMPETENCE_ID'
        ,p_associated_column3 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM'
        ,p_associated_column4 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_TO'
        ,p_associated_column5 => 'PER_COMPETENCE_ELEMENTS.VALID_GRADE_ID'
        );
      end if;
   else -- if no records are found in the cursor, close the cursor.
      hr_utility.set_location(l_proc,3);
      close csr_check_dates;
   end if;
   hr_utility.set_location('LEAVING: ' || l_proc,4);
   --

end check_all_dates;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  -- Check mandatory parameters have being set.
  -- ngundura this check should not be there for global competences
  if per_cel_shd.g_bus_grp then
       hr_api.mandatory_arg_error
         (p_api_name         => l_proc
         ,p_argument         => 'business_group_id'
         ,p_argument_value   => p_business_group_id
         );
  end if;
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for proficiency has changed
  --
  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id        => p_competence_element_id
         ,p_object_version_number        => p_object_version_number);
  --
  --
  if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.effective_date_from,
     hr_api.g_date)<> nvl(p_effective_date_from,hr_api.g_date) OR
     nvl(per_cel_shd.g_old_rec.effective_date_to,hr_api.g_date)
     <>  nvl(p_effective_date_to,hr_api.g_date))
     OR  not l_api_updating) then
     --
     -- check that the effective_date_from is before the effective_date_to
     --
     if (p_effective_date_from > nvl(p_effective_date_to,hr_api.g_eot))
         then
         hr_utility.set_location(l_proc,10);
         hr_utility.set_message(801,'HR_51647_CEL_DATES_INVL');
         --
	 hr_multi_message.add
	 (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM');

     elsif (p_enterprise_id is not null) then
         --
         -- Check that the dates for enterprise_id does not overlap.
         --
         check_all_dates('ENTERPRISE',p_enterprise_id,null,
	                  801,'HR_52288_CEL_ENT_DATES_OVLAP');
         hr_utility.set_location(l_proc,13);
     elsif (p_person_id is not null) then
         --
         -- Check that the dates for person_id does not overlap.
	 --
         check_all_dates('PERSON',p_person_id,null,
	                       801,'HR_51648_CEL_PER_DATES_OVLAP');
         hr_utility.set_location(l_proc,15);
     elsif (p_valid_grade_id is not null) then
         if p_job_id is not null then
           --
           -- Check that the dates from valid_grade_id do not overlap
           --
           check_all_dates('GRADE',p_valid_grade_id, null,
                           800,'HR_52353_CEL_JGD_DATES_OVLAP');
           --
           -- Also ensure that there isn't a record with just the job or position
           -- ID with overlapping dates.
           --
           check_all_dates('JOB',p_job_id , 'Y',
                            800,'HR_52355_CEL_JEX_DATES_OVLAP');
           --
         elsif p_position_id is not null then
           --
           -- Check that the dates from valid_grade_id do not overlap
           --
           check_all_dates('GRADE',p_valid_grade_id, null,
                              800,'HR_52354_CEL_PGD_DATES_OVLAP');
           --
           -- Also ensure that there isn't a record with just the job or position
           -- ID with overlapping dates.
           --
           check_all_dates('POSITION',p_position_id , 'Y',
                               800,'HR_52356_CEL_PEX_DATES_OVLAP');
         end if;
      elsif (p_job_id is not null) then
         --
 	 -- Check that the dates for job_id does not overlap.
	 --
	 check_all_dates('JOB',p_job_id,null,
                         801,'HR_51649_CEL_JOB_DATES_OVLAP');
         hr_utility.set_location(l_proc,20);
         --
      elsif (p_position_id is not null) then
	 --
 	 -- Check that the dates for position_id does not overlap.
	 --
         check_all_dates('POSITION',p_position_id,null,
	                 801,'HR_51650_CEL_POS_DATES_OVLAP');
         hr_utility.set_location(l_proc,25);
	 --
      elsif (p_organization_id is not null) then
	 --
 	 -- Check that the dates for organization_id does not overlap.
	 --
         check_all_dates('ORGANIZATION',p_organization_id,null,
	                 801,'HR_51651_CEL_ORG_DATES_OVLAP');
         hr_utility.set_location(l_proc,30);
         --
     end if;
    end if;     -- end if for api_updating
  hr_utility.set_location('Leaving: ' || l_proc, 40);
end chk_competence_element_dates;
--
------------------------------------------------------------------------------
--|--------------------------< Chk_normal_elapse_duration >----------------|
------------------------------------------------------------------------------
--
-- Description:
--   It checks that either both the normal_elapse_duration and normal_duration
--   units are entered or niether of them are.
--   It checks that the normal_elapse_duration_unints exits in HR_LOOKUPS
--
-- Pre-Condition
--   None.
--
-- In Arguments:

--   p_competence_element_id
--   p_object_version_number
--   p_effective_date
--   p_normal_elapse_duration
--   p_normal_elapse_duration_unit
--
--
-- Post Success:
--   Processing continues if:
--     The normal_elapse_duration and normal_duration units are both valid.
--
-- Post Failure:
--    An application error is raised and processing is terminated if any

--    The normal_elapse_duration and normal_duration units are invalid
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_normal_elapse_duration
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_object_version_number
    in per_competence_elements.object_version_number%TYPE
   ,p_effective_date
    in Date
   ,p_normal_elapse_duration
    in per_competence_elements.normal_elapse_duration%TYPE
   ,p_normal_elapse_duration_unit
    in per_competence_elements.normal_elapse_duration_unit%TYPE
   ) is
--
   l_proc              varchar2(72)
		       := g_package||'chk_normal_elapse_duration';
   l_api_updating      boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --

  --
  -- Check mandatory parameters have being set.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for elapse_duration or unit has changed
  --

  --
  l_api_updating := per_cel_shd.api_updating
         (p_competence_element_id        => p_competence_element_id
         ,p_object_version_number        => p_object_version_number);
  --
  --
  if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.normal_elapse_duration,
     hr_api.g_number)
     <> nvl(p_normal_elapse_duration,hr_api.g_number) OR
     nvl(per_cel_shd.g_old_rec.normal_elapse_duration_unit,hr_api.g_varchar2)
     <>  nvl(p_normal_elapse_duration_unit,hr_api.g_varchar2))
     OR  not l_api_updating) then
     if (p_normal_elapse_duration IS NULL AND

         p_normal_elapse_duration_unit IS NULL) then
         --
  	 -- Do nothing if both are null.
	 --
         hr_utility.set_location(l_proc, 5);
     elsif ((p_normal_elapse_duration IS NULL AND
	 p_normal_elapse_duration_unit IS NOT NULL) OR
         (p_normal_elapse_duration IS NOT NULL AND
         p_normal_elapse_duration_unit IS  NULL)) then
         --
	 -- Raise an error if one is set but not the other
         --
         hr_utility.set_location(l_proc,10);

	 hr_utility.set_message(801,'HR_51653_CEL_NOR_ELPS_COMB');
         hr_multi_message.add
         (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.NORMAL_ELAPSE_DURATION'
         ,p_associated_column2 => 'PER_COMPETENCE_ELEMENTS.NORMAL_ELAPSE_DURATION_UNIT'
        );
     elsif (p_normal_elapse_duration IS NOT NULL AND
            p_normal_elapse_duration_unit IS NOT NULL) then
         --
	 -- Check that the p_normal_elapse_duration_unit exists in
	 -- hr_lookups.
	 --
         if hr_api.not_exists_in_hr_lookups
            (p_effective_date         => p_effective_date
            ,p_lookup_type            => 'ELAPSE_DURATION'
            ,p_lookup_code            => p_normal_elapse_duration_unit
            )then

            --  Error: Invalid normal_elapse_duration_unit
            hr_utility.set_location(l_proc, 15);
            hr_utility.set_message(801,'HR_51654_CEL_NOR_ELPS_INVL');
            hr_multi_message.add
            (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.NORMAL_ELAPSE_DURATION_UNIT'
           );
         end if;
     end if;
   end if;
   hr_utility.set_location('Leaving: ' || l_proc, 20);
end chk_normal_elapse_duration;
--
--
--
/**********

-----------------------------------------------------------------------------
-- |---------------------<Chk_rating_weighting_ass_type >--------------------|
-----------------------------------------------------------------------------
--
-- Description;
--   Validates that if an assessment type has a performance rating Scale
--   specified then the rating_level_id is not null on the assessment
--   competence element.
--   It checks that if an assessment type has no performance rating Scale
--   then the rating_level_id is null on the assessment competence_element.
--
--   Validates that if an assessment type has a performance weighting Scale
--   specified then the weigthing_level_id is not null on the assessment

--   competence element.
--   It checks that if an assessment type has no performance weighting Scale
--   then the weighting_level_id is null on the assessment competence_element.
--
-- Pre-Conditions:
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_object_version_number
--   p_business_group_id
--   p_assessment_id
--   p_assessment_type_id

--   p_rating_level_id
--
-- Post Success:
--   Processing continues if:
--     - The rating_level_id is not null when the assessment type
--        has performance specified. The process also succeeds when the
--        rating_level_id is null and assessment_type has no performance
--        specified.
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The assessment type has a performance rating specified and the
--      competence elem,ent has no rating_level_id specefied and vice versa.

--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
--
procedure chk_rating_weighting_ass_type
   (p_competence_element_id
    in per_competence_elements.competence_element_id%TYPE
   ,p_business_group_id
    in per_competence_elements.business_group_id%TYPE
   ,p_object_version_number

    in per_competence_elements.object_version_number%TYPE
   ,p_rating_level_id
    in per_competence_elements.rating_level_id%TYPE
   ,p_weighting_level_id
    in per_competence_elements.weighting_level_id%TYPE
   ,p_assessment_id
    in per_competence_elements.assessment_id%TYPE
   ,p_assessment_type_id
    in per_competence_elements.assessment_type_id%TYPE
   ) is
--
   l_proc             varchar2(72)
		      := g_package||'chk_rating_weighting_ass_type';

   l_api_updating      boolean;
   l_assessment_type_id number(9);
   l_rating_scale_id    number(9);
   l_weighting_scale_id number(9);
--
  -- cursor to check that the rating_sacle referenced by the rating_level
  -- is the same one that the assessment_type in competence_element is
  -- referencing.
  --
  -- ngundura changes done for pa requirements
  -- commented the business_group_id check
  cursor csr_get_rating_scale_id(c_ass_type_id in number) is
  select ast.rating_scale_id, ast.weighting_scale_id
  from   per_rating_levels ral,
         per_assessment_types ast,

         per_rating_scales    ras
  where  ast.assessment_type_id = c_ass_type_id
--  and    p_business_group_id +0 = ast.business_group_id
--  and    p_business_group_id +0 = ral.business_group_id
--  and    p_business_group_id +0 = ras.business_group_id
  and    ral.rating_scale_id    = ras.rating_scale_id
  and    ras.rating_scale_id    = ast.rating_scale_id
  and    ras.type in ( 'PERFORMANCE', 'WEIGHTING');
  --
  --
  -- Cursor to get the assessment_type_id from assessment
  -- which is referenced in the proficiecy_level.
  --

  cursor csr_get_ass_type_id is
  select assessment_type_id
  from   per_assessments
  where  p_business_group_id + 0 = business_group_id
  and    p_assessment_id = assessment_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  -- Check mandatory parameters have being set.
  -- ngundura this check should not be there for global competence elements
  if per_cel_shd.g_bus_grp then
       hr_api.mandatory_arg_error
         (p_api_name         => l_proc
         ,p_argument         => 'business_group_id'
         ,p_argument_value   => p_business_group_id
         );
  end if;
  --
  --
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for rating_level_id or weighting level_id has changed.
  --
  --
  l_api_updating := per_cel_shd.api_updating

         (p_competence_element_id        => p_competence_element_id
         ,p_object_version_number        => p_object_version_number);
  --
  --
  if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.rating_level_id,
     hr_api.g_number)<> nvl(p_rating_level_id,hr_api.g_number) OR
     nvl(per_cel_shd.g_old_rec.weighting_level_id,hr_api.g_number)
     <>  nvl(p_weighting_level_id,hr_api.g_number))
     OR  not l_api_updating) then
     --
     -- Do nothing if the assessment_type and assessment_id are null
     --
     if (p_assessment_type_id is null and p_assessment_id is null) then

         hr_utility.set_location (l_proc,5);
     else
        if(p_assessment_type_id is null) then
           open csr_get_ass_type_id;
	   fetch csr_get_ass_type_id into l_assessment_type_id;
           if csr_get_ass_type_id%notfound then
              hr_utility.set_location (l_proc,10);
              close csr_get_ass_type_id;
              hr_utility.set_message(801,'HR_51748_CEL_ASS_TYPE_ID_INVL');
              hr_utility.raise_error;
           end if;
           close csr_get_ass_type_id;
         --

         end if;
          --
          -- get the rating and weighting from the assessment_type
          --
          open  csr_get_rating_scale_id(l_assessment_type_id);
          fetch csr_get_rating_scale_id into l_rating_scale_id,
                l_weighting_scale_id;
          if csr_get_rating_scale_id%notfound then
             close csr_get_rating_scale_id;
             hr_utility.set_location(l_proc,15);
             hr_utility.set_message(801,'HR_51748_CEL_ASS_TYPE_ID_INVL');
             hr_utility.raise_error;
          else

             close csr_get_rating_scale_id;
             --
	     -- Now check if the rating_scale_id or weighting_scale
	     -- on assessment_type is null then the rating_level_id
	     -- or weighting_level_id must be null on the competence_element.
  	     -- And vice versa.
             --
             if((l_rating_scale_id is NULL AND
                 p_rating_level_id is NOT NULL) OR
                 (l_rating_scale_id is not NULL AND
                  p_rating_level_id is NULL) OR
	         (l_weighting_scale_id is NULL AND
		  p_weighting_level_id is NOT NULL) OR

		 (l_weighting_scale_id is NOT NULL AND
                 p_weighting_level_id is NULL)) then
                --
	        hr_utility.set_location(l_proc,20);
                hr_utility.set_message(801,'HR_51646_CEL_RATE_WEG_INVL');
                hr_utility.raise_error;
             end if;
          --
          end if;
       end if;
 end if;
 hr_utility.set_location('Leaving: ' || l_proc, 30);
 end chk_rating_weighting_ass_type;

--
********/
-- --------------------------------------------------------------------------
-- |---------------------------< Chk_type_and_validation >-------------------|
-----------------------------------------------------------------------------
-- Description;
--  It validates that the value entered for TYPE exists in HR_LOOKUPS.
--  Depending on which type is entered, it validates which attributes has
--  to be null or not null.
--
-- Pre-Conditions:
--   None
--

-- In Arguments:
--   p_competence_element_id
--   p_object_version_number
--   p_business_group_id
--   p_enterprise_id
--   p_type
--   p_competence_id
--   p_assessment_id
--   p_assessment_type_id
--   p_activity_version_id
--   p_organization_id
--   p_job_id
--   p_valid_grade_id
--   p_position_id
--   p_person_id
--   p_parent_competence_element_id
--   p_group_competence_type
--   p_effective_date_to
--   p_effective_date_from
--   p_proficiency_level_id
--   p_certification_date
--   p_certification_method
--   p_next_certification_date
--   p_mandatory
--   p_normal_elapse_duration
--   p_normal_elapse_duration_unit

--   p_high_proficiency_level_id
--   p_competence_type
--   p_sequence_number
--   p_source_of_proficiency_level
--   p_weighting_level_id
--   p_rating_level_id
--   p_comments
--   p_party_id -- HR/TCA merge
--
-- Post Success:
--   Processing continues if:
--     - The value of the in arguments are null or not null depending
--       on the type. For more details refer to percel.bru document.

--
--
-- Post Failure:
--    An application error is raised and processing is terminated if any
--      - The value of some of the in parameters are not valid.
--
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
procedure chk_type_and_validation
   (p_competence_element_id
     in per_competence_elements.competence_element_ID%TYPE
    ,p_object_version_number
     in per_competence_elements.object_version_number%TYPE
    ,p_business_group_id
     in per_competence_elements.business_group_id%TYPE
    ,p_enterprise_id
    in per_competence_elements.enterprise_id%TYPE
    ,p_type
     in per_competence_elements.type%TYPE
    ,p_competence_id
     in per_competence_elements.competence_id%TYPE
    ,p_assessment_id
     in per_competence_elements.assessment_id%TYPE
    ,p_assessment_type_id
     in per_competence_elements.assessment_type_id%TYPE
    ,p_activity_version_id
     in per_competence_elements.activity_version_id%TYPE
    ,p_organization_id
     in per_competence_elements.organization_id%TYPE
    ,p_job_id
     in per_competence_elements.job_id%TYPE
    ,p_valid_grade_id
    in per_competence_elements.valid_grade_id%TYPE
    ,p_position_id
     in per_competence_elements.position_id%TYPE
    ,p_person_id
     in per_competence_elements.person_id%TYPE
    ,p_parent_competence_element_id
     in per_competence_elements.parent_competence_element_id%TYPE
    ,p_group_competence_type
     in per_competence_elements.group_competence_type%TYPE
    ,p_effective_date_to
     in per_competence_elements.effective_date_to%TYPE
    ,p_effective_date_from
     in per_competence_elements.effective_date_from%TYPE
    ,p_proficiency_level_id
     in per_competence_elements.proficiency_level_id%TYPE
    ,p_certification_date
     in per_competence_elements.certification_date%TYPE
    ,p_certification_method
    in per_competence_elements.certification_method%TYPE
    ,p_next_certification_date
     in per_competence_elements.next_certification_date%TYPE
    ,p_mandatory
     in per_competence_elements.mandatory%TYPE
    ,p_normal_elapse_duration
     in per_competence_elements.normal_elapse_duration%TYPE
    ,p_normal_elapse_duration_unit
     in per_competence_elements.normal_elapse_duration_unit%TYPE
    ,p_high_proficiency_level_id
     in per_competence_elements.high_proficiency_level_id%TYPE
    ,p_competence_type
     in per_competence_elements.competence_type%TYPE
    ,p_sequence_number
     in per_competence_elements.sequence_number%TYPE
    ,p_source_of_proficiency_level
     in per_competence_elements.source_of_proficiency_level%TYPE
    ,p_weighting_level_id
     in per_competence_elements.weighting_level_id%TYPE
    ,p_rating_level_id
     in per_competence_elements.rating_level_id%TYPE
    ,p_line_score
     in per_competence_elements.line_score%TYPE
    ,p_object_id
     in per_competence_elements.object_id%TYPE
    ,p_object_name
     in per_competence_elements.object_name%TYPE
    ,p_party_id                               -- HR/TCA merge
     in per_competence_elements.party_id%TYPE
    ,p_qualification_type_id                  -- BUG3356369
     in per_competence_elements.qualification_type_id%TYPE
    ) is
--
-- Cursor to check that the parent_competence_element has
-- type 'ASSESSMENT_GROUP'
--
cursor csr_parent_comp_element is
select null
from   per_competence_elements
where  competence_element_id	= p_parent_competence_element_id
and    nvl(business_group_id,-1) = nvl(p_business_group_id,-1)
and    type			= 'ASSESSMENT_GROUP';

--
-- Cursor to check that the combination of competence and
-- qualification_type is unique when thpe is 'QUALIFICATION'
--
cursor csr_comp_qual_link is
  select null from per_competence_elements cel
  where cel.competence_id = p_competence_id
  and   cel.qualification_type_id = p_qualification_type_id
  and   cel.type = 'QUALIFICATION'
  and   cel.qualification_type_id = p_qualification_type_id
  and   (p_effective_date_from <= nvl(cel.effective_date_to, hr_api.g_eot)
        and NVL(p_effective_date_to, hr_api.g_eot) >= cel.effective_date_from);

cursor csr_upd_comp_qual_link is
  select null from per_competence_elements cel
  where cel.competence_element_id <> p_competence_element_id
  and   cel.competence_id = p_competence_id
  and   cel.qualification_type_id = p_qualification_type_id
  and   cel.type = 'QUALIFICATION'
  and   cel.qualification_type_id = p_qualification_type_id
  and   (p_effective_date_from <= nvl(cel.effective_date_to, hr_api.g_eot)
        and NVL(p_effective_date_to, hr_api.g_eot) >= cel.effective_date_from);

--
   l_proc              varchar2(72)
		       := g_package||'chk_type_and_validation';
   l_api_updating      boolean;
   l_exists	       varchar2(1);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if hr_multi_message.no_exclusive_error
  (p_check_column1 => 'PER_COMPETENCE_ELEMENTS.TYPE')  then
    --
    -- Check mandatory parameters have being set.
    --
    hr_api.mandatory_arg_error
       (p_api_name         => l_proc
       ,p_argument         => 'type'
       ,p_argument_value   => p_type
       );
    -- mandatory parameter
    --
    -- ngundura should check only when p_type is not
    -- 'PROJECT_ROLE' and 'OPEN_ASSIGNMENT'
    if per_cel_shd.g_bus_grp then
    	hr_api.mandatory_arg_error
    	  (p_api_name         => l_proc
          ,p_argument         => 'business_group_id'
          ,p_argument_value   => p_business_group_id
       	  );
     	if p_object_id is not null or p_object_name is not null then
          hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
       	  hr_utility.set_message_token('API_NAME', l_proc);
       	  hr_utility.set_message_token('ARGUMENT', 'object_id, object_name');
     	end if;
    end if;
    --
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and

    -- b) The value for group_competence_type,competence_type,effective_date_from
    --    effective_date_to,high_proficiency_level_id,mandatory,normal_elapse
    -- ration ,normal_elapse_duration_unit,sequence_number,source_of_prof_level


    --   certification_date,certification_method,next_certification_date,
    --   proficiency_level_id,line_score
    --
    -- NOTE: Only updateable parameters are checked
    --
    --
    l_api_updating := per_cel_shd.api_updating
  	   (p_competence_element_id        => p_competence_element_id

	    ,p_object_version_number        => p_object_version_number);

    --
    if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.group_competence_type,
        hr_api.g_varchar2) <> nvl(p_group_competence_type,hr_api.g_varchar2)
        OR nvl(per_cel_shd.g_old_rec.competence_type,hr_api.g_varchar2) <>
        nvl(p_competence_type,hr_api.g_varchar2) OR
        nvl(per_cel_shd.g_old_rec.effective_date_from,hr_api.g_date) <>
        nvl(p_effective_date_from,hr_api.g_date) OR
        nvl(per_cel_shd.g_old_rec.effective_date_to,hr_api.g_date) <>
        nvl(p_effective_date_to,hr_api.g_date) OR
        nvl(per_cel_shd.g_old_rec.high_proficiency_level_id,hr_api.g_number) <>
        nvl(p_high_proficiency_level_id,hr_api.g_number) OR
        nvl(per_cel_shd.g_old_rec.mandatory,hr_api.g_varchar2) <>
        nvl(p_mandatory,hr_api.g_varchar2) OR
        nvl(per_cel_shd.g_old_rec.normal_elapse_duration,hr_api.g_number) <>
        nvl(p_normal_elapse_duration,hr_api.g_number) OR
        nvl(per_cel_shd.g_old_rec.normal_elapse_duration_unit,hr_api.g_varchar2)
        <> nvl(p_normal_elapse_duration_unit,hr_api.g_varchar2) OR
        nvl(per_cel_shd.g_old_rec.sequence_number,hr_api.g_number) <>
        nvl(p_sequence_number,hr_api.g_number) OR
        nvl(per_cel_shd.g_old_rec.certification_date,hr_api.g_date) <>
        nvl(p_certification_date,hr_api.g_date) OR
        nvl(per_cel_shd.g_old_rec.source_of_proficiency_level,
        hr_api.g_varchar2) <>
        nvl(p_source_of_proficiency_level,hr_api.g_varchar2) OR
        nvl(per_cel_shd.g_old_rec.certification_method,hr_api.g_varchar2) <>
        nvl(p_certification_method,hr_api.g_varchar2) OR
        nvl(per_cel_shd.g_old_rec.next_certification_date,hr_api.g_date) <>
        nvl(p_next_certification_date,hr_api.g_date)OR
        nvl(per_cel_shd.g_old_rec.proficiency_level_id,hr_api.g_number) <>
        nvl(p_proficiency_level_id,hr_api.g_number) OR
        nvl(per_cel_shd.g_old_rec.line_score,hr_api.g_number) <>
        nvl(p_line_score,hr_api.g_number) OR
        nvl(per_cel_shd.g_old_rec.qualification_type_id,hr_api.g_number) <>
        nvl(p_qualification_type_id,hr_api.g_number))
        OR NOT l_api_updating) then
        hr_utility.set_location(l_proc, 6);
        --
        -- Check the parameters status when the type is 'REQUIREMENT'
        --
        if p_type = 'REQUIREMENT' then
        -- type 'REQUIREMENT and object_name 'VACANCY' won't have org, job etc.
        if (p_object_name is not NULL AND
            p_object_name <> 'VACANCY') then
          if (p_organization_id is NULL AND
	      p_job_id is null AND p_position_id IS NULL AND
	      p_enterprise_id is null) then
	      --
	    hr_utility.set_location(l_proc, 7);
            hr_utility.set_message(801,'HR_51655_CEL_ORG_JOB_POS');

	    hr_utility.raise_error;
          --
          elsif  ((p_organization_id is not null OR p_enterprise_id is not NULL)
	     AND (p_valid_grade_id is not null) ) then
	     hr_utility.set_location(l_proc, 8);
             hr_utility.set_message(800,'HR_52373_CEL_GRD_ID_MST_NULL');
    	hr_multi_message.add
	   (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.VALID_GRADE_ID');

	     hr_utility.raise_error;
	  --
	  elsif ((p_enterprise_id is not null AND(p_organization_id
	       is not null OR p_job_id is not null OR p_position_id is not null))
	      OR
              (p_organization_id is not null AND(p_enterprise_id is not null
	       OR p_job_id is not null OR p_position_id is not null))
	      OR
              (p_job_id is not null AND(p_enterprise_id is not null OR
	      p_organization_id is not null OR p_position_id is not null))
	      OR
              (p_position_id is not null AND(p_enterprise_id is not null OR
	      p_job_id is not null OR p_organization_id is not null))) then
	      --
	     hr_utility.set_location(l_proc, 10);
	     hr_utility.set_message(801,'HR_51656_CEL_ORG_JOB_POS_ENT');
	     hr_utility.raise_error;
	  --
          elsif(p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_activity_version_id is not null
	      OR p_person_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      OR p_competence_type is not null
	      OR p_line_score is not null
	      OR p_sequence_number is not null
	      OR p_normal_elapse_duration is not null
	      OR p_normal_elapse_duration_unit is not null
	      OR p_source_of_proficiency_level is not null
	      OR p_certification_date is not null
	      OR p_certification_method is not null
	      OR p_next_certification_date is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null
	      OR p_effective_date_from is NULL
	      OR p_competence_id is NULL
	      OR p_mandatory is  null)
	      then
	    --
	     hr_utility.set_location(l_proc, 15);
	     hr_utility.set_message(801,'HR_51657_CEL_REQ_TYPE_ERROR');
	     hr_utility.raise_error;
	     --
           end if;
           end if;
 	 --
        elsif (p_type = 'ASSESSMENT') then
	   --
           if  (p_assessment_id is NULL
	        OR p_competence_id is NULL
	        OR p_effective_date_from is NULL
	        OR p_assessment_type_id is not null
	        OR p_organization_id is not null
	        OR p_job_id is not null
	        OR p_valid_grade_id is not null
  	        OR p_enterprise_id is not null
	        OR p_position_id is not null
                OR p_activity_version_id is not null
	        OR p_person_id is not null
	        OR p_group_competence_type is not null
	        OR p_competence_type is not null
	        OR p_high_proficiency_level_id is not null
	        OR p_mandatory is not null
	        OR p_normal_elapse_duration is not null
	        OR p_normal_elapse_duration_unit is not null
	        OR p_sequence_number is not null
	        OR p_source_of_proficiency_level is not null
	        OR p_certification_date is not null
	        OR p_certification_method is not null
	        OR p_next_certification_date is not null
	      )
	      then
	      --
	      hr_utility.set_location(l_proc, 20);
	      hr_utility.set_message(801,'HR_51658_CEL_ASS_TYPE_ERROR');
	      hr_utility.raise_error;
	      --
            end if;
	    --
          elsif (p_type = 'ASSESSMENT_GROUP') then
           if  (p_assessment_type_id is NULL
               OR p_group_competence_type is  NULL
	        OR p_competence_id is not NULL
	        OR p_parent_competence_element_id is not null
	        OR p_organization_id is not null
	        OR p_job_id is not null
	        OR p_valid_grade_id is not null
	        OR p_enterprise_id is not null
	        OR p_position_id is not null
	        OR p_activity_version_id is not null
	        OR p_person_id is not null
	        OR p_effective_date_from is not null
	        OR p_effective_date_to is not null
	        OR p_high_proficiency_level_id is not null
	        OR p_mandatory is not null
	        OR p_normal_elapse_duration is not null
	        OR p_normal_elapse_duration_unit is not null
	        OR p_source_of_proficiency_level is not null
	        OR p_certification_date is not null
	        OR p_certification_method is not null
	        OR p_next_certification_date is not null
	        OR p_proficiency_level_id is not null
                OR p_competence_type is not null
	        OR p_assessment_id is not null
	        OR p_weighting_level_id is not null
	        OR p_rating_level_id is not null
	       )
	       then
	      --
	      hr_utility.set_location(l_proc, 25);
	      hr_utility.set_message(801,'HR_51659_CEL_ASS_GRP_ERROR');
	      hr_utility.raise_error;
	      --
          end if;
        elsif (p_type = 'ASSESSMENT_COMPETENCE') then
	  if(p_parent_competence_element_id IS NOT NULL) then
	    open csr_parent_comp_element;
	    fetch csr_parent_comp_element into l_exists;
	    if csr_parent_comp_element%notfound then
	       close csr_parent_comp_element;
	       --
	       -- raise an error message because the
	       -- parent_competence_element type is not
	       -- 'ASSESSMENT_GROUP'
	       --
	       hr_utility.set_location(l_proc, 30);
	       hr_utility.set_message(801,'HR_51660_CEL_ASS_COMP_ERROR');
	       hr_utility.raise_error;
	    end if;
	    close csr_parent_comp_element;
        end if;
	    if ((p_assessment_type_id is null AND p_parent_competence_element_id
	      is NULL )
	      OR

              (p_assessment_type_id is not null AND
	      p_parent_competence_element_id is not null )) then
	      --
	      hr_utility.set_location(l_proc, 35);
	      hr_utility.set_message(801,'HR_51662_CEL_ASS_COMP_MUTA');
	      hr_utility.raise_error;
	      --
            end if;
           if(p_assessment_id is not null
	       OR p_competence_id is NULL
	       OR p_effective_date_from is not NULL
	       OR p_effective_date_to is not NULL
	       OR p_enterprise_id is not null
	       OR p_organization_id is not null
	       OR p_job_id is not null
	       OR p_valid_grade_id is not null
	       OR p_position_id is not null
	       OR p_activity_version_id is not null
	       OR p_person_id is not null
	       OR p_group_competence_type is not null
	       OR p_high_proficiency_level_id is not null
	       OR p_mandatory is not null
	       OR p_normal_elapse_duration is not null
	       OR p_normal_elapse_duration_unit is not null
	       OR p_source_of_proficiency_level is not null
	       OR p_certification_date is not null
	       OR p_certification_method is not null
	       OR p_next_certification_date is not null
	       OR p_proficiency_level_id is not null
	       OR p_competence_type is not null
	       OR p_weighting_level_id is not null
	       OR p_rating_level_id is not null
	      )
	       then
	       --
	       hr_utility.set_location(l_proc, 40);
	       hr_utility.set_message(801,'HR_51663_CEL_ASS_COMP_ERR');
	       hr_utility.raise_error;

	       --
         end if;
	 --
      elsif (p_type = 'COMPETENCE_USAGE') then
	 if ( p_competence_type is NULL
	      OR p_competence_id is NULL
	      OR p_effective_date_from is not NULL
	      OR p_effective_date_to is not null
	      OR p_organization_id is not null
	      OR p_job_id is not null
	      OR p_valid_grade_id is not null
	      OR p_position_id is not null
	      OR p_enterprise_id is not null
	      OR p_activity_version_id is not null
	      OR p_person_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      OR p_high_proficiency_level_id is not null
	      OR p_mandatory is not null
	      OR p_normal_elapse_duration is not null
	      OR p_normal_elapse_duration_unit is not null
	      OR p_sequence_number is not null
	      OR p_source_of_proficiency_level is not null
	      OR p_certification_date is not null
	      OR p_certification_method is not null
	      OR p_next_certification_date is not null
	      OR p_proficiency_level_id is not null
	      OR p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null
	      )
	       then
	       --
	       hr_utility.set_location(l_proc, 45);
	       hr_utility.set_message(801,'HR_51664_CEL_COMP_USG_ERR');
	       hr_utility.raise_error;
               --
	 end if;

	 --
      elsif (p_type = 'DELIVERY') then
	 if  (p_activity_version_id is NULL)
	     then
	      --
	      hr_utility.set_location(l_proc, 50);
	      hr_utility.set_message(801,'HR_51665_CEL_DELVR_ERROR');
	      hr_utility.raise_error;
	      --
	 elsif(p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_organization_id is not null
	      OR p_job_id is not null
	      OR p_valid_grade_id is not null
	      OR p_mandatory is not null
	      OR p_position_id is not null
	      OR p_enterprise_id is not null
	      OR p_person_id is not null
	      OR p_high_proficiency_level_id is not null
	      OR p_competence_type is not null
	      OR p_normal_elapse_duration is not null
	      OR p_normal_elapse_duration_unit is not null
	      OR p_sequence_number is not null
	      OR p_source_of_proficiency_level is not null
	      OR p_certification_date is not null
	      OR p_certification_method is not null
	      OR p_next_certification_date is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      OR p_competence_id is NULL
	      OR p_effective_date_from is NULL
	      )
	       then
	       --
	       hr_utility.set_location(l_proc, 55);
	       hr_utility.set_message(801,'HR_51666_CEL_DELVR_ERROR');

	       hr_utility.raise_error;
               --
	 end if;
	 --
	 -- Note: The PREREQUISITE type is the same as the DELIVERY
	 -- But we have included this so that we are able to modify it
	 -- for the future versions.
	 --
      elsif (p_type = 'PREREQUISITE') then
	 if ( p_activity_version_id is NULL)
	      then
	       --
	       hr_utility.set_location(l_proc, 60);

	       hr_utility.set_message(801,'HR_51667_CEL_PRE_REQ_MUTA');
	       hr_utility.raise_error;
	       --
	 elsif(p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_organization_id is not null
	      OR p_job_id is not null
	      OR p_valid_grade_id is not null
	      OR p_position_id is not null
	      OR p_enterprise_id is not null
	      OR p_person_id is not null
	      OR p_high_proficiency_level_id is not null
	      OR p_competence_type is not null
	      OR p_normal_elapse_duration is not null
	      OR p_normal_elapse_duration_unit is not null
	      OR p_sequence_number is not null
	      OR p_source_of_proficiency_level is not null
	      OR p_certification_date is not null
	      OR p_certification_method is not null
	      OR p_next_certification_date is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      OR p_competence_id is NULL
	      OR p_effective_date_from is NULL
	      OR p_mandatory is NULL
	      )
	       then
	       --
	       hr_utility.set_location(l_proc, 65);
	       hr_utility.set_message(801,'HR_51668_CEL_PRE_REQ_ERR');
	       hr_utility.raise_error;
               --
	 end if;
	 --
      elsif (p_type = 'PATH') then
         if (p_sequence_number is  NULL
	      OR p_competence_id is not null
	      OR p_competence_type is not null
	      OR p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_organization_id is not null
	      OR p_job_id is not null
	      OR p_valid_grade_id is not null
	      OR p_position_id is not null
	      OR p_activity_version_id is not null
	      OR p_person_id is not null
	      OR p_high_proficiency_level_id is not null
	      OR p_proficiency_level_id is not null
	      OR p_effective_date_from is not null
	      OR p_effective_date_to is not null
	      OR p_mandatory is not null
	      OR p_source_of_proficiency_level is not null
	      OR p_certification_date is not null
	      OR p_certification_method is not null
	      OR p_next_certification_date is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      )

	       then
	       --
	       hr_utility.set_location(l_proc, 70);
	       hr_utility.set_message(801,'HR_51669_CEL_PATH_ERROR');
	       hr_utility.raise_error;
               --
	 end if;
	 --
      elsif (p_type = 'PERSONAL') then
	 if  ((p_person_id is NULL and p_party_id is NULL) -- HR/TCA merge
	      OR p_competence_id is NULL
	      OR p_effective_date_from is NULL
	      OR p_competence_type is not null
	      OR p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_activity_version_id is not null
	      OR p_enterprise_id is not null
	      OR p_organization_id is not null
	      OR p_job_id is not null
	      OR p_valid_grade_id is not null
	      OR p_position_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      OR p_high_proficiency_level_id is not null
	      OR p_mandatory is not null
	      OR p_normal_elapse_duration is not null
	      OR p_normal_elapse_duration_unit is not null
	      OR p_sequence_number is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null
	      OR p_competence_type is not null
	      )
	       then
	       --
           hr_utility.set_location(l_proc, 75);
	       hr_utility.set_message(801,'HR_51670_CEL_PER_TYPE_ERROR');
           hr_multi_message.add
      	     (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.EFFECTIVE_DATE_FROM');
	       hr_utility.raise_error;
               --
	 end if;
	 --
      elsif (p_type = 'PROPOSAL') then
	   if(p_competence_id is NULL
	      OR p_effective_date_from is NULL
	      OR p_mandatory is NULL
	      OR p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_organization_id is not null
	      OR p_job_id is not null
	      OR p_valid_grade_id is not null
	      OR p_enterprise_id is not null
	      OR p_activity_version_id is not null
	      OR p_position_id is not null
	      OR p_person_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      OR p_high_proficiency_level_id is not null
	      OR p_competence_type is not null
	      OR p_normal_elapse_duration is not null
	      OR p_normal_elapse_duration_unit is not null
	      OR p_sequence_number is not null
	      OR p_source_of_proficiency_level is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null

	      )
	       then
	       --
	       hr_utility.set_location(l_proc, 85);
	       hr_utility.set_message(801,'HR_51672_CEL_PRO_TYPE_ERROR');
	       hr_utility.raise_error;
               --
	 end if;
	 --
      elsif (p_type = 'SET') then
	 if  (p_competence_id is NULL
	      OR p_effective_date_from is not NULL
	      OR p_assessment_id is not null
	      OR p_assessment_type_id is not null
	      OR p_organization_id is not null
	      OR p_job_id is not null
	      OR p_valid_grade_id is not null
	      OR p_position_id is not null
	      OR p_enterprise_id is not null
	      OR p_activity_version_id is not null
	      OR p_person_id is not null
	      OR p_parent_competence_element_id is not null
	      OR p_group_competence_type is not null
	      OR p_high_proficiency_level_id is not null
	      OR p_proficiency_level_id is not null
	      OR p_source_of_proficiency_level is not null
	      OR p_certification_date is not null
	      OR p_certification_method is not null
	      OR p_next_certification_date is not null
	      OR p_mandatory is not null
	      OR p_competence_type is not null
	      OR p_normal_elapse_duration is not null
	      OR p_normal_elapse_duration_unit is not null
	      OR p_sequence_number is not null
	      OR p_weighting_level_id is not null
	      OR p_rating_level_id is not null
	      )
	       then

	       --
	       hr_utility.set_location(l_proc, 90);
	       hr_utility.set_message(801,'HR_51673_CEL_SET_TYPE_ERROR');
	       hr_utility.raise_error;
               --
	 end if;
      elsif (p_type = 'QUALIFICATION') then
         hr_utility.trace('date_from : ' || p_effective_date_from);
         hr_utility.trace('date_to : ' || p_effective_date_to);
	 hr_utility.set_location(l_proc, 100);

         --
         -- Mandatory parameter check
         --
         hr_api.mandatory_arg_error
           (p_api_name       => l_proc,
            p_argument       => 'qualification_type_id',
            p_argument_value => p_qualification_type_id);

         hr_api.mandatory_arg_error
           (p_api_name       => l_proc,
            p_argument       => 'effective_date_from',
            p_argument_value => p_effective_date_from);
         --
         if (NOT l_api_updating) then
	   hr_utility.set_location(l_proc, 103);
           --
           -- Mandatory parameter check
           --
           hr_api.mandatory_arg_error
             (p_api_name       => l_proc,
              p_argument       => 'competence_id',
              p_argument_value => p_competence_id);

           open csr_comp_qual_link;
           fetch csr_comp_qual_link into l_exists;
           if csr_comp_qual_link%FOUND then
             close csr_comp_qual_link;
             hr_utility.set_message(800,'HR_449136_QUA_FWK_LINK_EXISTS');
             hr_utility.raise_error;
           end if;
           close csr_comp_qual_link;
         else
	   hr_utility.set_location(l_proc, 105);

           open csr_upd_comp_qual_link;
           fetch csr_upd_comp_qual_link into l_exists;
           if csr_upd_comp_qual_link%FOUND then
             close csr_upd_comp_qual_link;
             hr_utility.set_message(800,'HR_449136_QUA_FWK_LINK_EXISTS');
             hr_utility.raise_error;
           end if;
           close csr_upd_comp_qual_link;
        end if;
      end if;
      hr_utility.set_location('Leaving: ' || l_proc, 110);
    end if;
 end if; -- check for no_exclusive_error for TYPE.
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.TYPE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,110);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,120);
end chk_type_and_validation;
--
--
--
-- --------------------------------------------------------------------------
-- |----------------< Chk_unique_competence_element >-----------------------|
-----------------------------------------------------------------------------
-- Description;
--  It validates that the competence element is unique for any of the foreign
--  key relationships.
--
-- Pre-Conditions:
--   None
--
-- In Arguments:
--   p_competence_element_id
--   p_object_version_number
--   p_business_group_id
--   p_enterprise_id
--   p_type
--   p_competence_id
--   p_assessment_id
--   p_assessment_type_id
--   p_activity_version_id
--   p_organization_id
--   p_job_id
--   p_valid_grade_id
--   p_position_id
--   p_person_id
--   p_parent_competence_element_id
--   p_group_competence_type
--   p_effective_date_from
--   p_competence_type
--   p_party_id -- HR/TCA merge
--
-- Post Success:
--   Processing continues if:
--     - The value of the in arguments don't violate the uniqueness
--       test.
--
--
-- Post Failure:
--    An application error is raised and processing is terminated if any

--      - The value entered are not unique.
--
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
--
--
procedure chk_unique_competence_element
   (p_competence_element_id
     in per_competence_elements.competence_element_ID%TYPE
    ,p_object_version_number
     in per_competence_elements.object_version_number%TYPE
    ,p_business_group_id
     in per_competence_elements.business_group_id%TYPE
    ,p_enterprise_id
     in per_competence_elements.enterprise_id%TYPE
    ,p_type		 in per_competence_elements.type%TYPE
    ,p_competence_id	 in per_competence_elements.competence_id%TYPE
    ,p_assessment_id	 in per_competence_elements.assessment_id%TYPE
    ,p_assessment_type_id
     in per_competence_elements.assessment_type_id%TYPE
    ,p_activity_version_id
     in per_competence_elements.activity_version_id%TYPE
    ,p_organization_id
     in per_competence_elements.organization_id%TYPE
    ,p_job_id		 in per_competence_elements.job_id%TYPE
    ,p_valid_grade_id    in per_competence_elements.valid_grade_id%TYPE
    ,p_position_id
     in per_competence_elements.position_id%TYPE
    ,p_person_id	 in per_competence_elements.person_id%TYPE
    ,p_parent_competence_element_id
     in per_competence_elements.parent_competence_element_id%TYPE
    ,p_group_competence_type
     in per_competence_elements.group_competence_type%TYPE
    ,p_effective_date_from	 in per_competence_elements.effective_date_from%TYPE
    ,p_competence_type		 in per_competence_elements.competence_type%TYPE
    ,p_object_name      in per_competence_elements.object_name%type
    ,p_object_id        in per_competence_elements.object_id%type
    ,p_party_id         in per_competence_elements.party_id%type -- HR/TCA merge
    ,p_qualification_type_id in per_competence_elements.qualification_type_id%type
    ) is
--
   l_proc              varchar2(72):=
		       g_package||'chk_unique_competence_element';
   l_sql_stmt VARCHAR2(1500);
   l_api_updating      boolean;
   l_exists	       varchar2(1);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  if hr_multi_message.no_exclusive_error
  (p_check_column1 => 'PER_COMPETENCE_ELEMENTS.TYPE') then
    --
    -- Check mandatory parameters have being set.
    --
    hr_api.mandatory_arg_error
       (p_api_name         => l_proc
       ,p_argument         => 'type'
       ,p_argument_value   => p_type
       );
    -- mandatory parameter
    --
    -- ngundura this check should not be there for global competence elements
    if per_cel_shd.g_bus_grp then
     hr_api.mandatory_arg_error
     (p_api_name          => l_proc
     ,p_argument         => 'business_group_id'
     ,p_argument_value   => p_business_group_id
     );
    end if;
    --
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value for group_competence_type,competence_type,effective_date_from
    --    or any of the above in arguments has changed.
    --
    --
    l_api_updating := per_cel_shd.api_updating
             (p_competence_element_id        => p_competence_element_id
             ,p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating AND (nvl(per_cel_shd.g_old_rec.group_competence_type,
        hr_api.g_varchar2) <> nvl(p_group_competence_type,hr_api.g_varchar2)
        OR nvl(per_cel_shd.g_old_rec.competence_type,hr_api.g_varchar2) <>
        nvl(p_competence_type,hr_api.g_varchar2) OR
        nvl(per_cel_shd.g_old_rec.effective_date_from,hr_api.g_date) <>
        nvl(p_effective_date_from,hr_api.g_date))
        OR NOT l_api_updating) then
      hr_utility.set_location(l_proc, 6);
      --
      -- build the NATIVE dynamic SQL
      -- note: native dynamic SQL has been used for performance
      l_sql_stmt := 'SELECT NULL '||
                    'FROM   per_competence_elements '||
                    'WHERE  business_group_id = :p_business_group_id '||
                    'AND    type = :p_type ';
      -- evaluate each bind determining the predicate
      -- note: if the bind is null we still add a predicate
      -- because the USING clause is not dynamic but will be faster than
      -- using DBMS_SQL.BIND calls.
      IF p_parent_competence_element_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt||
          'AND parent_competence_element_id = :p_parent_competence_element_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
        'AND :p_parent_competence_element_id IS NULL /* p_parent_competence_element_id IS NULL*/ ';
      END IF;
      --
      IF p_competence_id IS NOT NULL THEN
       l_sql_stmt := l_sql_stmt|| 'AND competence_id = :p_competence_id ';
      ELSE
       l_sql_stmt := l_sql_stmt||
           'AND :p_competence_id IS NULL /* p_competence_id IS NULL */';
      END IF;
      --
      IF p_person_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND person_id = :p_person_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
                'AND :p_person_id IS NULL /* p_person_id IS NULL */ ';
      END IF;
      --
      IF p_job_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND job_id = :p_job_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
              'AND :p_job_id IS NULL /* p_job_id IS NULL */ ';
      END IF;
      --
      IF p_valid_grade_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND valid_grade_id = :p_valid_grade_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
             'AND :p_valid_grade_id IS NULL /* p_valid_grade_id IS NULL*/';
      END IF;
      --
      IF p_position_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND position_id = :p_position_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
                'AND :p_position_id IS NULL /* p_position_id IS NULL */ ';
      END IF;
      --
      IF p_enterprise_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND enterprise_id = :p_enterprise_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
              'AND :p_enterprise_id IS NULL /* p_enterprise_id IS NULL */';
      END IF;
      --
      IF p_organization_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND organization_id = :p_organization_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
             'AND :p_organization_id IS NULL /* p_organization_id IS NULL*/';
      END IF;
      --
      IF p_activity_version_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt||
                    'AND activity_version_id = :p_activity_version_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
               'AND :p_activity_version_id IS NULL /* p_activity_version_id IS NULL */ ';
      END IF;
      --
      IF p_assessment_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND assessment_id = :p_assessment_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
                'AND :p_assessment_id IS NULL /* p_assessment_id IS NULL */ ';
      END IF;
      --
      IF p_assessment_type_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND assessment_type_id = :p_assessment_type_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
         'AND :p_assessment_type_id IS NULL /* p_assessment_type_id IS NULL */ ';
      END IF;
      --
      IF p_effective_date_from IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND effective_date_from = :p_effective_date_from ';
      ELSE
        l_sql_stmt := l_sql_stmt||
          'AND :p_effective_date_from IS NULL /* p_effective_date_from IS NULL */ ';
      END IF;
      --
      IF p_group_competence_type IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt||
                'AND group_competence_type = :p_group_competence_type ';
      ELSE
        l_sql_stmt := l_sql_stmt||
          'AND :p_group_competence_type IS NULL /* p_group_competence_type IS NULL */ ';
      END IF;
      --
      IF p_competence_type IS NOT NULL THEN
       l_sql_stmt := l_sql_stmt||
                'AND competence_type = :p_competence_type ';
      ELSE
        l_sql_stmt := l_sql_stmt||
          'AND :p_competence_type IS NULL /* p_competence_type IS NULL */ ';
      END IF;
      --
      IF p_object_id IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND object_id = :p_object_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
                'AND :p_object_id IS NULL /* p_object_id IS NULL */ ';
      END IF;
      --
      IF p_object_name IS NOT NULL THEN
        l_sql_stmt := l_sql_stmt|| 'AND object_name = :p_object_name ';
      ELSE
        l_sql_stmt := l_sql_stmt||
                'AND :p_object_name IS NULL /* p_object_name IS NULL */ ';
      END IF;
      --
      IF p_party_id IS NOT NULL THEN -- HR/TCA merge
        l_sql_stmt := l_sql_stmt|| 'AND party_id = :p_party_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
                'AND :p_party_id IS NULL /* p_party_id IS NULL */ ';
      END IF;
      --
      IF p_qualification_type_id IS NOT NULL THEN -- BUG3356369
        l_sql_stmt := l_sql_stmt|| 'AND qualification_type_id = :p_qualification_type_id ';
      ELSE
        l_sql_stmt := l_sql_stmt||
                'AND :p_qualification_type_id IS NULL /* qualification_type_id IS NULL */ ';
      END IF;
        hr_utility.set_location(l_proc,10);
       --hr_utility.trace('l_sql_stmt : ' || l_sql_stmt);
      -- dynamically execute the SQL
       BEGIN
         EXECUTE IMMEDIATE l_sql_stmt
        INTO  l_exists
        USING p_business_group_id,
              p_type,
              p_parent_competence_element_id,
              p_competence_id,
              p_person_id,
              p_job_id,
              p_valid_grade_id,
              p_position_id,
              p_enterprise_id,
              p_organization_id,
              p_activity_version_id,
              p_assessment_id,
              P_assessment_type_id,
              p_effective_date_from,
              p_group_competence_type,
              p_competence_type,
              p_object_id,
              p_object_name,
              p_party_id, -- HR/TCA merge
              p_qualification_type_id;
         -- executed successful therefore a row has been found
          if p_type = 'COMPETENCE_USAGE' then
            hr_utility.set_message(800,'HR_52262_CEL_UNIQUE_COMP_USAGE');
          elsif p_type = 'ASSESSMENT' then
	    hr_utility.set_message(800,'HR_52263_CEL_UNIQUE_ASSESSMENT');
          elsif p_type = 'ASSESSMNET_COMPETENCE' then
   	    hr_utility.set_message(800,'HR_52264_CEL_UNIQUE_ASM_COMP');
          elsif p_type = 'ASSESSMENT_GROUP' then
	    hr_utility.set_message(800,'HR_52265_CEL_UNIQUE_ASM_GROUP');
          elsif p_type = 'REQUIREMENT' then
    	    hr_utility.set_message(800,'HR_52266_CEL_UNIQUE_REQUIREMEN');
          elsif p_type = 'DELIVERY' then
	    hr_utility.set_message(800,'HR_52267_CEL_UNIQUE_DELIVERY');
          elsif p_type = 'PERSONAL' then
	    hr_utility.set_message(800,'HR_52268_CEL_UNIQUE_PERSONAL');
          else
            hr_utility.set_message(801,'HR_51674_CEL_COMP_UNIQ_ERROR');
          end if;
        --
        hr_utility.raise_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
      END;
    end if;
    hr_utility.set_location(l_proc,7);
  --
  end if; -- no_exclusive_check for TYPE
hr_utility.set_location('Leaving: ' || l_proc, 10);
exception
  when app_exception.application_exception then
    hr_multi_message.add;
    hr_utility.set_location(' Leaving:'||l_proc,105);
end chk_unique_competence_element;
/*
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_unique_comp_qual >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a combination of competence_id and
--   qualification_type_id is unique.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_competence_element_id
--   p_competence_id
--   p_qualification_type_id
--   p_object_version_number
--   p_effective_date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_unique_comp_qual(p_competence_element_id   in number
                              ,p_competence_id           in number
                              ,p_qualification_type_id   in number
                              ,p_object_version_number   in number
                              ,p_effective_date          in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_unique_comp_qual';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor csr_unique_comp_qual is
         select 'x'
         from per_competence_elements
         where type = 'QUALIFICATION'
	 and   competence_id = p_competence_id
         and   qualification_type_id = p_qualification_type_id
         and   p_effective_date between effective_date_from
               and nvl(effective_date_to,hr_api.g_eot);
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_qualification_type_id is not NULL and p_competence_id is not NULL
  then
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value for competence_id or qualification_type_id have changed
    --
    l_api_updating := per_cel_shd.api_updating
           (p_competence_element_id  => p_competence_element_id
           ,p_object_version_number  => p_object_version_number);
    --
    if (l_api_updating
         and nvl(per_cel_shd.g_old_rec.competence_id,
           hr_api.g_number) = nvl(p_competence_id, hr_api.g_number)
         and nvl(per_cel_shd.g_old_rec.qualification_type_id,hr_api.g_number)
           = nvl(p_qualification_type_id, hr_api.g_number)
       ) then
       hr_utility.set_location('Leaving.... ' || l_proc,20);
       return;
    end if;

    hr_utility.set_location(l_proc,20);

    open csr_unique_comp_qual;
    fetch csr_unique_comp_qual into l_exists;
    if csr_unique_comp_qual%found then
      close csr_unique_comp_qual;
      --
      hr_utility.set_message(801,'HR_51674_CEL_COMP_UNIQ_ERROR');
      hr_utility.raise_error;
      --
    end if;
    close csr_unique_comp_qual;
  end if;

  hr_utility.set_location('Leaving:'||l_proc,30);
  --
End chk_unique_comp_qual;
*/
--
-- ---------------------------------------------------------------------------
-- |----------------< CHK_COMP_ELEMENT_DELETE >------------------------------|
-----------------------------------------------------------------------------
--
-- Description:
--   It checks that a competence_element of type personal cannot be
--   deleted. It checks that the competence_element of a compeleted
--   assessment cannot be deleted.
--   It also check that the competence_element of type 'COMPETENCE_USAGE'
--   cannot be deleted if there is a competence element of type 'ASSESSMENT_
--   COMPETENCE' which references those competences and also has a parent_
--   competence_element_id which correspond to a competence_element
--   containing the competences in the group_competence_type_column.
--
-- In Arguments:

--   type
--   competence_type
--   competence_element_id
--   p_parent_competence_element_id
--   group_competence_type
--   assessment_id
--   assessment_type_id
--   competence_id
--   business_group_id
--
-- Post Success:
--   The process succeeds if:
--   the competence_element which need to be deleted is not referenced

--   by another competence element
--
-- Post Failure:
--   An application error is raised and processing is terminated if any:
--   the competence_element which need to be deleted is referenced
--   by another competence element.
--
-- Access Status:
--    Internal Table Handler Use Only.
--
--
procedure chk_comp_element_delete
  ( p_competence_element_id
     in per_competence_elements.competence_element_id%TYPE
   ,p_business_group_id
     in per_competence_elements.business_group_id%TYPE
   ,p_parent_competence_element_id
     in per_competence_elements.parent_competence_element_id%TYPE
   ,p_type
     in per_competence_elements.type%TYPE
   ,p_competence_type
     in per_competence_elements.competence_type%TYPE
   ,p_group_competence_type
     in per_competence_elements.group_competence_type%TYPE
   ,p_assessment_id
     in per_competence_elements.assessment_id%TYPE
   ,p_assessment_type_id
     in per_competence_elements.assessment_type_id%TYPE
   ,p_competence_id
     in per_competence_elements.competence_id%TYPE
   ) is
--
   l_proc              varchar2(72):= g_package||'chk_comp_element_delete';
   l_exists	       varchar2(1);
   l_assessment_type_id per_assessment_types.assessment_type_id%TYPE;
--
-- Cursor which is used to check whether the competence being removed from the assessment template
-- is being used by any assessments (ie.TYPE='ASSESSMENT').  This cursor only makes sure that the
-- competence isnt' being used, not whether the assessment in which the competence is being used.
-- Maybe the business rules need tighting up around here as maybe the form should change.
--
cursor csr_get_used_comp_element is
select null
from per_competence_elements
where type = 'ASSESSMENT'
and   competence_id = p_competence_id
and assessment_id in
        (Select asn.assessment_id
         From per_assessments asn
         Where asn.assessment_type_id =
                (Select assessment_type_id
                 From per_competence_elements
                 Where competence_element_id =
                        (Select parent_competence_element_id
                         From per_competence_elements
                         Where competence_element_id=p_competence_element_id
                        )
               )
        )
;
-- Cursor to check that whether a competence element is
-- the parent of other competence element.
--
cursor csr_is_parent_comp is
select null
from   per_competence_elements
where  parent_competence_element_id = p_competence_element_id
and    business_group_id	    = p_business_group_id;
--
-- Cursor to check the COMPETENCE_USAGE' type referenced by
-- competence element of type "ASSESSMENT_COMPETENCE'
--
cursor csr_get_comp_group is
select null
from   per_competence_elements comp1
where  comp1.type = 'ASSESSMENT_COMPETENCE'
and    comp1.parent_competence_element_id is not null
and    comp1.business_group_id     = p_business_group_id
and    comp1.competence_id = p_competence_id
and    exists (select null
       from    per_competence_elements comp2
       where   comp2.competence_element_id =
	       comp1.parent_competence_element_id
       and     comp1.business_group_id =

	       comp2.business_group_id
       and     comp2.group_competence_type =
	       p_competence_type);
--
-- Cursor to check the COMPETENCE_ELMENT_ID' referenced by
-- per_comp_element_outcmes table BUG3356369
--
cursor csr_comp_element_outcome is
   select 'x' from per_comp_element_outcomes
   where competence_element_id = p_competence_element_id;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Only do the delete validation if the type is
  -- ASSESSESSMENT_GROUP, ASSESSMENT_COMPETENCE, COMPETENCE_USAGE or
  -- or PERSONAL,ASSESSMENT.
  --
  if (p_type= 'ASSESSESSMENT_GROUP' OR p_type = 'ASSESSMENT_COMPETENCE' OR
      p_type= 'COMPETENCE_USAGE' or p_type = 'ASSESSMENT' OR p_type = 'PERSONAL'

) then

    --
    -- raise an error message if the type = 'PERSONAL'
    --
    -- commented out following section due to bug raised (no. 525537) 1-09-97
    --    if p_type = 'PERSONAL' then
    --      hr_utility.set_location(l_proc,5);
    --      hr_utility.set_message(801,'HR_51675_CEL_PER_CANT_DEL');
    --      hr_utility.raise_error;
    --    end if;
    --
     --
     if(p_type = 'ASSESSMENT_GROUP') then
       --
       -- check that a parent competence_element cannot be deleted
       -- if it is referenced by another competence_element.
       --
       open csr_is_parent_comp;
       fetch csr_is_parent_comp into l_exists;
       if csr_is_parent_comp%found then
  	 close csr_is_parent_comp;
	 hr_utility.set_location(l_proc,15);
         hr_utility.set_message(801,'HR_51677_CEL_PARNT_CANT_DEL');
         hr_utility.raise_error;

       end if;
       close csr_is_parent_comp;
     end if;
     --
     -- Now check that if the type is COMPETENCE_USAGE and there is
     -- a competence_element of type 'ASSESSMENT_COMPETENCE' with
     -- the same competence_type(i.e. Via the parent)and refernces
     -- the same competence.
     --
     if(p_type= 'COMPETENCE_USAGE') then
       open csr_get_comp_group;
       fetch csr_get_comp_group into l_exists;
       if csr_get_comp_group%found then

	 close csr_get_comp_group;
	 hr_utility.set_location(l_proc,20);
         hr_utility.set_message(801,'HR_51678_CEL_COM_USG_CANT_DEL');
         hr_utility.raise_error;
       end if;
       close csr_get_comp_group;
     end if;
     --
     -- Now check that if an element of ASSESSMENT_COMPETENCE type is
     -- going to be deleted, then the competence is not referenced by any
     -- other element of type 'ASSESSMENT'
     --
     if (p_type = 'ASSESSMENT_COMPETENCE') then

       open csr_get_used_comp_element;
       fetch csr_get_used_comp_element into l_exists;
       if csr_get_used_comp_element%found then
	 close csr_get_used_comp_element;
	 hr_utility.set_location(l_proc,25);
	 hr_utility.set_message(801,'HR_51679_CEL_ASS_COMP_CANT_DEL');
         hr_utility.raise_error;
       end if;
       --
       close csr_get_used_comp_element;
     end if;
  --
  end if;
  --
  hr_utility.set_location(l_proc,30);

  open csr_comp_element_outcome;
  fetch csr_comp_element_outcome into l_exists;
  if csr_comp_element_outcome%FOUND then
    close csr_comp_element_outcome;
    hr_utility.set_message(800,'HR_449135_QUA_FWK_CEL_TAB_REF');
    hr_utility.raise_error;
  end if;
  close csr_comp_element_outcome;

  hr_utility.set_location('Leaving: ' || l_proc,40);
end chk_comp_element_delete;
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in per_cel_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.valid_grade_id is not null) and (
    nvl(per_cel_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_cel_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.valid_grade_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_COMPETENCE_ELEMENTS'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);

end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_cel_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.competence_element_id is not null)  and (
    nvl(per_cel_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_cel_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)))
    or (p_rec.competence_element_id is not null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Competence Element Developer'
      ,p_attribute_category              => p_rec.INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in out nocopy per_cel_shd.g_rec_type,
			  p_effective_date  in Date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate important attributes
  --
  -- Call all supporting business operations
  --
  -- Validate business_group_id
  --
  -- HR/TCA merge
  -- if party_id is null or business_group_id is not null
  -- no need to check business_grroup_id
  if p_rec.party_id is null or p_rec.business_group_id is not null then
  -- ngundura added this if condition

   if ( p_rec.type not in ('PROJECT_ROLE','OPEN_ASSIGNMENT','QUALIFICATION','ASSESSMENT_GROUP','ASSESSMENT_COMPETENCE')) then
      -- Validate Bus Grp
      hr_api.validate_bus_grp_id(
        p_business_group_id  => p_rec.business_group_id
       ,p_associated_column1 => per_cel_shd.g_tab_nam ||
                                 '.BUSINESS_GROUP_ID'
      );
      --
      -- After validating the set of important attributes,
      -- if Mulitple message detection is enabled and at least
      -- one error has been found then abort further validation.
      --
      hr_multi_message.end_validation_set;
      --
      per_cel_shd.g_bus_grp := true;
    else
      per_cel_shd.g_bus_grp := false;
    end if;
  else
     per_cel_shd.g_bus_grp := false;
  end if;
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TYPE
  --
  chk_type
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_type			=> p_rec.type
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 10);
  --
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TYPE_AND_VALIDATION
  --
  chk_type_and_validation
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_enterprise_id		=> p_rec.enterprise_id
     ,p_type			=> p_rec.type
     ,p_competence_id		=> p_rec.competence_id
     ,p_assessment_id		=> p_rec.assessment_id
     ,p_assessment_type_id	=> p_rec.assessment_type_id
     ,p_activity_version_id	=> p_rec.activity_version_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id		=> p_rec.valid_grade_id
     ,p_position_id		=> p_rec.position_id
     ,p_person_id		=> p_rec.person_id

     ,p_parent_competence_element_id
				=> p_rec.parent_competence_element_id
     ,p_group_competence_type	=> p_rec.group_competence_type
     ,p_effective_date_to	=> p_rec.effective_date_to
     ,p_effective_date_from	=> p_rec.effective_date_from
     ,p_proficiency_level_id	=> p_rec.proficiency_level_id
     ,p_certification_date	=> p_rec.certification_date
     ,p_certification_method	=> p_rec.certification_method
     ,p_next_certification_date => p_rec.next_certification_date
     ,p_mandatory		=> p_rec.mandatory
     ,p_normal_elapse_duration	=> p_rec.normal_elapse_duration
     ,p_normal_elapse_duration_unit
				=> p_rec.normal_elapse_duration_unit

     ,p_high_proficiency_level_id
				=> p_rec.high_proficiency_level_id
     ,p_competence_type		=> p_rec.competence_type
     ,p_sequence_number		=> p_rec.sequence_number
     ,p_source_of_proficiency_level
				=> p_rec.source_of_proficiency_level
     ,p_weighting_level_id	=> p_rec.weighting_level_id
     ,p_rating_level_id		=> p_rec.rating_level_id
     ,p_line_score		=> p_rec.line_score
     ,p_object_id               => p_rec.object_id
     ,p_object_name             => p_rec.object_name
     ,p_party_id		=> p_rec.party_id -- HR/TCA merge
     ,p_qualification_type_id	=> p_rec.qualification_type_id
     );
     --

  hr_utility.set_location(l_proc, 15);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_UNIQUE_COMPETENCE_ELEMENT
  --
  chk_unique_competence_element
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_enterprise_id		=> p_rec.enterprise_id
     ,p_type			=> p_rec.type
     ,p_competence_id		=> p_rec.competence_id
     ,p_assessment_id		=> p_rec.assessment_id

     ,p_assessment_type_id	=> p_rec.assessment_type_id
     ,p_activity_version_id	=> p_rec.activity_version_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id		=> p_rec.valid_grade_id
     ,p_position_id		=> p_rec.position_id
     ,p_person_id		=> p_rec.person_id
     ,p_parent_competence_element_id
				=> p_rec.parent_competence_element_id
     ,p_group_competence_type	=> p_rec.group_competence_type
     ,p_effective_date_from	=> p_rec.effective_date_from

     ,p_competence_type		=> p_rec.competence_type
     ,p_object_version_number	=> p_rec.object_version_number

     ,p_object_name             => p_rec.object_name
     ,p_object_id               => p_rec.object_id
     ,p_party_id		=> p_rec.party_id -- HR/TCA merge
     ,p_qualification_type_id	=> p_rec.qualification_type_id
     );
     --
     hr_utility.set_location(l_proc, 16);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_CERTIFICATION_METHOD
  --
  chk_certification_method
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_certification_method	=> p_rec.certification_method
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 20);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_COMPETENCE_TYPE
  --
  chk_competence_type
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_competence_type		=> p_rec.competence_type
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 25);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_GROUP_COMPETENCE_TYPE
  --
  chk_competence_type
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_competence_type		=> p_rec.group_competence_type
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 30);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MANDATORY
  --
  chk_mandatory
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date

     ,p_mandatory		=> p_rec.mandatory
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 35);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_SOURC_OF_PROFICIENCY_LEVEL
  --
  chk_source_of_proficiency
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date

     ,p_source_of_proficiency_level
     				=> p_rec.source_of_proficiency_level
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 40);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_CERTIFICATION_METHOD_DATE
  --
  chk_certification_method_date
     (p_competence_element_id 	=> p_rec.competence_element_id

     ,p_certification_date	=> p_rec.certification_date
     ,p_certification_method	=> p_rec.certification_method
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 45);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NEXT_CERTIFICATION_DATE
  --
  chk_next_certification_date
     (p_competence_element_id  => p_rec.competence_element_id
     ,p_certification_date     => p_rec.certification_date
     ,p_next_certification_date => p_rec.next_certification_date
     ,p_object_version_number  => p_rec.object_version_number
     ,p_effective_date_from    => p_rec.effective_date_from -- added for fix of #731089
     );
     --
     hr_utility.set_location(l_proc, 48);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FOREIGN_KEYS
  --
  chk_foreign_keys
     (p_competence_element_id 	=> p_rec.competence_element_id

     ,p_object_version_number	=> p_rec.object_version_number
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_enterprise_id		=> p_rec.enterprise_id
     ,p_competence_id		=> p_rec.competence_id
     ,p_assessment_id		=> p_rec.assessment_id
     ,p_assessment_type_id	=> p_rec.assessment_type_id
     ,p_activity_version_id	=> p_rec.activity_version_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id		=> p_rec.valid_grade_id
     ,p_position_id		=> p_rec.position_id
     ,p_person_id		=> p_rec.person_id
     ,p_parent_competence_element_id

				=> p_rec.parent_competence_element_id
     ,p_effective_date_to	=> p_rec.effective_date_to
     ,p_effective_date_from	=> p_rec.effective_date_from
     ,p_proficiency_level_id	=> p_rec.proficiency_level_id
     ,p_high_proficiency_level_id
				=> p_rec.high_proficiency_level_id
     ,p_weighting_level_id	=> p_rec.weighting_level_id
     ,p_rating_level_id		=> p_rec.rating_level_id
     ,p_effective_date		=> p_effective_date
     ,p_type			=> p_rec.type
     ,p_party_id		=> p_rec.party_id -- HR/TCA merge
     ,p_qualification_type_id   => p_rec.qualification_type_id
     );
     --
     hr_utility.set_location('Entering:'||l_proc, 50);

     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PARTY_ID
  --
  chk_party_id
     (p_rec
     ,p_effective_date
     );

     --
     hr_utility.set_location('Entering:'||l_proc, 52);

     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROFICIENCY_LEVEL_ID
  --
  chk_proficiency_level_id
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_proficiency_level_id	=> p_rec.proficiency_level_id
     ,p_high_proficiency_level_id
				=> p_rec.high_proficiency_level_id
     ,p_competence_id		=> p_rec.competence_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_party_id        	=> p_rec.party_id
     );
     --
     hr_utility.set_location(l_proc, 55);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_RATING_WEIGHTING_ID
  --
  chk_rating_weighting_id
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_rating_level_id		=> p_rec.rating_level_id
     ,p_weighting_level_id	=> p_rec.weighting_level_id

     ,p_assessment_id		=> p_rec.assessment_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_type			=> p_rec.type
     ,p_party_id		=> p_rec.party_id
     );
     --
     hr_utility.set_location(l_proc, 60);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_COMPETENCE_ELEMENT_DATES
  --
  chk_competence_element_dates
     (p_competence_element_id 	=> p_rec.competence_element_id

     ,p_business_group_id	=> p_rec.business_group_id
     ,p_competence_id		=> p_rec.competence_id
     ,p_person_id		=> p_rec.person_id
     ,p_position_id		=> p_rec.position_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id => p_rec.valid_grade_id
     ,p_effective_date_from	=> p_rec.effective_date_from
     ,p_effective_date_to	=> p_rec.effective_date_to
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_enterprise_id           => p_rec.enterprise_id
     );
     --
     hr_utility.set_location(l_proc, 65);

     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NORMAL_ELAPSE_DURATION
  --
  chk_normal_elapse_duration
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_normal_elapse_duration	=> p_rec.normal_elapse_duration
     ,p_normal_elapse_duration_unit
				=> p_rec.normal_elapse_duration_unit
     ,p_object_version_number	=> p_rec.object_version_number
     );

     --
     hr_utility.set_location(l_proc, 70);

/*
  -- Business Rule Mapping
  -- =====================
  -- CHK_UNIQUE_COMP_QUAL
  --
  chk_unique_comp_qual
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_competence_id		=> p_rec.competence_id
     ,p_qualification_type_id   => p_rec.qualification_type_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_effective_date		=> p_effective_date
     );
*/
     --
     hr_utility.set_location(l_proc, 80);
     --
     -- do the descriptive flex validation.
     --
     per_cel_bus.chk_df(p_rec => p_rec);

     hr_utility.set_location(l_proc, 90);

     --
     -- do the developer descriptive flex validation.
     --
     per_cel_bus.chk_ddf(p_rec => p_rec);
     --
     hr_utility.set_location('Leaving:'||l_proc, 100);
     --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_cel_shd.g_rec_type,
			  p_effective_date in Date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Validate Important Attributes
  --
  -- Business Rule Mapping
  -- =====================
  -- Check non_updateable arguments
  --
  -- if party_id is pecified, business_group is not mandatory
  -- HR/TCA merge
  if p_rec.party_id is null or p_rec.business_group_id is not null then
    --
    -- Validate business_group_id
    --
    if ( p_rec.type not in ('PROJECT_ROLE','OPEN_ASSIGNMENT','QUALIFICATION','ASSESSMENT_GROUP','ASSESSMENT_COMPETENCE')) then
      hr_api.validate_bus_grp_id(
        p_business_group_id  => p_rec.business_group_id
       ,p_associated_column1 => per_cel_shd.g_tab_nam ||
                                 '.BUSINESS_GROUP_ID'
      );
      --
      -- After validating the set of important attributes,
      -- if Mulitple message detection is enabled and at least
      -- one error has been found then abort further validation.
      --
      hr_multi_message.end_validation_set;
      --
      per_cel_shd.g_bus_grp := true;
    else
      per_cel_shd.g_bus_grp := false;
    end if;
  else
       per_cel_shd.g_bus_grp := false;
  end if;
  --
  --
  per_cel_bus.check_non_updateable_args
    (p_rec              =>p_rec);
  --
  hr_utility.set_location (l_proc,6);
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TYPE_AND_VALIDATION
  --
  chk_type_and_validation
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_object_version_number	=> p_rec.object_version_number

     ,p_business_group_id	=> p_rec.business_group_id
     ,p_enterprise_id		=> p_rec.enterprise_id
     ,p_type			=> p_rec.type
     ,p_competence_id		=> p_rec.competence_id
     ,p_assessment_id		=> p_rec.assessment_id
     ,p_assessment_type_id	=> p_rec.assessment_type_id
     ,p_activity_version_id	=> p_rec.activity_version_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id		=> p_rec.valid_grade_id
     ,p_position_id		=> p_rec.position_id
     ,p_person_id		=> p_rec.person_id
     ,p_parent_competence_element_id

				=> p_rec.parent_competence_element_id
     ,p_group_competence_type	=> p_rec.group_competence_type
     ,p_effective_date_to	=> p_rec.effective_date_to
     ,p_effective_date_from	=> p_rec.effective_date_from
     ,p_proficiency_level_id	=> p_rec.proficiency_level_id
     ,p_certification_date	=> p_rec.certification_date
     ,p_certification_method	=> p_rec.certification_method
     ,p_next_certification_date => p_rec.next_certification_date
     ,p_mandatory		=> p_rec.mandatory
     ,p_normal_elapse_duration	=> p_rec.normal_elapse_duration
     ,p_normal_elapse_duration_unit
				=> p_rec.normal_elapse_duration_unit

     ,p_high_proficiency_level_id
				=> p_rec.high_proficiency_level_id
     ,p_competence_type		=> p_rec.competence_type
     ,p_sequence_number		=> p_rec.sequence_number
     ,p_source_of_proficiency_level
				=> p_rec.source_of_proficiency_level
     ,p_weighting_level_id	=> p_rec.weighting_level_id
     ,p_rating_level_id		=> p_rec.rating_level_id
     ,p_line_score		=> p_rec.line_score
     ,p_object_id               => p_rec.object_id
     ,p_object_name             => p_rec.object_name
     ,p_party_id		=> p_rec.party_id -- HR/TCA merge
     ,p_qualification_type_id   => p_rec.qualification_type_id -- BUG3356369
     );
     --
  hr_utility.set_location(l_proc, 15);

  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_UNIQUE_COMPETENCE_ELEMENT
  --
  chk_unique_competence_element
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_enterprise_id		=> p_rec.enterprise_id
     ,p_type			=> p_rec.type
     ,p_competence_id		=> p_rec.competence_id
     ,p_assessment_id		=> p_rec.assessment_id
     ,p_assessment_type_id	=> p_rec.assessment_type_id

     ,p_activity_version_id	=> p_rec.activity_version_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id		=> p_rec.valid_grade_id
     ,p_position_id		=> p_rec.position_id
     ,p_person_id		=> p_rec.person_id
     ,p_parent_competence_element_id
				=> p_rec.parent_competence_element_id
     ,p_group_competence_type	=> p_rec.group_competence_type
     ,p_effective_date_from	=> p_rec.effective_date_from
     ,p_competence_type		=> p_rec.competence_type

     ,p_object_version_number	=> p_rec.object_version_number

     ,p_object_name             => p_rec.object_name
     ,p_object_id               => p_rec.object_id
     ,p_party_id                => p_rec.party_id -- HR/TCA merge
     ,p_qualification_type_id	=> p_rec.qualification_type_id
     );
     --
     hr_utility.set_location(l_proc, 16);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_CERTIFICATION_METHOD
  --
  chk_certification_method
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_certification_method	=> p_rec.certification_method

     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 20);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_COMPETENCE_TYPE
  --
  chk_competence_type
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_competence_type		=> p_rec.competence_type

     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 25);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_GROUP_COMPETENCE_TYPE
  --
  chk_competence_type
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_competence_type		=> p_rec.group_competence_type

     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 30);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_MANDATORY
  --
  chk_mandatory
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_mandatory		=> p_rec.mandatory

     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 35);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_SOURC_OF_PROFICIENCY_LEVEL
  --
  chk_source_of_proficiency
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date
     ,p_source_of_proficiency_level

     				=> p_rec.source_of_proficiency_level
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 40);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_CERTIFICATION_METHOD_DATE
  --
  chk_certification_method_date
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_certification_date	=> p_rec.certification_date

     ,p_certification_method	=> p_rec.certification_method
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 45);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NEXT_CERTIFICATION_DATE
  --
  chk_next_certification_date
     (p_competence_element_id   => p_rec.competence_element_id
     ,p_certification_date      => p_rec.certification_date

     ,p_next_certification_date    => p_rec.next_certification_date
     ,p_object_version_number   => p_rec.object_version_number
     ,p_effective_date_from    => p_rec.effective_date_from --added for bug fix of #731089
     );
     --
     hr_utility.set_location(l_proc, 48);

  -- Business Rule Mapping
  -- =====================
  -- CHK_PROFICIENCY_LEVEL_ID
  --
  chk_proficiency_level_id
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_business_group_id	=> p_rec.business_group_id

     ,p_proficiency_level_id	=> p_rec.proficiency_level_id
     ,p_high_proficiency_level_id
				=> p_rec.high_proficiency_level_id
     ,p_competence_id		=> p_rec.competence_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_party_id        	=> p_rec.party_id
     );
     --
     hr_utility.set_location(l_proc, 55);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_RATING_WEIGHTING_ID
  --

  chk_rating_weighting_id
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_rating_level_id		=> p_rec.rating_level_id
     ,p_weighting_level_id	=> p_rec.weighting_level_id
     ,p_assessment_id		=> p_rec.assessment_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_type			=> p_rec.type
     ,p_party_id		=> p_rec.party_id
     );
     --
     hr_utility.set_location(l_proc, 60);
     --
  -- Business Rule Mapping

  -- =====================
  -- CHK_COMPETENCE_ELEMENT_DATES
  --
  chk_competence_element_dates
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_competence_id		=> p_rec.competence_id
     ,p_person_id		=> p_rec.person_id
     ,p_position_id		=> p_rec.position_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id => p_rec.valid_grade_id
     ,p_effective_date_from	=> p_rec.effective_date_from

     ,p_effective_date_to	=> p_rec.effective_date_to
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_enterprise_id           => p_rec.enterprise_id
     );
     --
     hr_utility.set_location(l_proc, 65);
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_NORMAL_ELAPSE_DURATION
  --
  chk_normal_elapse_duration
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_effective_date		=> p_effective_date

     ,p_normal_elapse_duration	=> p_rec.normal_elapse_duration
     ,p_normal_elapse_duration_unit
				=> p_rec.normal_elapse_duration_unit
     ,p_object_version_number	=> p_rec.object_version_number
     );
     --
     hr_utility.set_location(l_proc, 70);
     --
     --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FOREIGN_KEYS
  --

  chk_foreign_keys
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_business_group_id	=> p_rec.business_group_id
     ,p_enterprise_id		=> p_rec.enterprise_id
     ,p_competence_id		=> p_rec.competence_id
     ,p_assessment_id		=> p_rec.assessment_id
     ,p_assessment_type_id	=> p_rec.assessment_type_id
     ,p_activity_version_id	=> p_rec.activity_version_id
     ,p_organization_id		=> p_rec.organization_id
     ,p_job_id			=> p_rec.job_id
     ,p_valid_grade_id		=> p_rec.valid_grade_id
     ,p_position_id		=> p_rec.position_id

     ,p_person_id		=> p_rec.person_id
     ,p_parent_competence_element_id
				=> p_rec.parent_competence_element_id
     ,p_effective_date_to	=> p_rec.effective_date_to
     ,p_effective_date_from	=> p_rec.effective_date_from
     ,p_proficiency_level_id	=> p_rec.proficiency_level_id
     ,p_high_proficiency_level_id
				=> p_rec.high_proficiency_level_id
     ,p_weighting_level_id	=> p_rec.weighting_level_id
     ,p_rating_level_id		=> p_rec.rating_level_id
     ,p_effective_date		=> p_effective_date
     ,p_type			=> p_rec.type
     ,p_party_id		=> p_rec.party_id -- HR/TCA merge
     ,p_qualification_type_id   => p_rec.qualification_type_id
     );

     --
     hr_utility.set_location(l_proc, 70);
/*
  -- Business Rule Mapping
  -- =====================
  -- CHK_UNIQ_COMP_QUAL
  --
  chk_unique_comp_qual
     (p_competence_element_id 	=> p_rec.competence_element_id
     ,p_competence_id	        => p_rec.competence_id
     ,p_qualification_type_id   => p_rec.qualification_type_id
     ,p_object_version_number	=> p_rec.object_version_number
     ,p_effective_date		=> p_effective_date
     );

*/
     hr_utility.set_location(l_proc, 80);

     --
     -- do the descriptive flex validation.
     --
     per_cel_bus.chk_df(p_rec => p_rec);

     hr_utility.set_location(l_proc, 80);

     --
     -- do the developer descriptive flex validation.
     --
     per_cel_bus.chk_ddf(p_rec => p_rec);

     hr_utility.set_location('Leaving:'||l_proc, 80);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_cel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Business Rule Mapping
  -- =====================
  -- CHK_COMP_ELEMENT_DELETE
  chk_comp_element_delete

     (p_competence_element_id	=> per_cel_shd.g_old_rec.competence_element_id
     ,p_business_group_id	=> per_cel_shd.g_old_rec.business_group_id
     ,p_parent_competence_element_id
     			=> per_cel_shd.g_old_rec.parent_competence_element_id
     ,p_type		=> per_cel_shd.g_old_rec.type
     ,p_competence_type	=> per_cel_shd.g_old_rec.competence_type
     ,p_assessment_id	=> per_cel_shd.g_old_rec.assessment_id
     ,p_assessment_type_id	=> per_cel_shd.g_old_rec.assessment_type_id
     ,p_competence_id		=> per_cel_shd.g_old_rec.competence_id
     ,p_group_competence_type	=> per_cel_shd.g_old_rec.group_competence_type
     );
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_competence_element_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups     pbg,
                 per_competence_elements pce
          where  pce.competence_element_id = p_competence_element_id
            and  pbg.business_group_id     = pce.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
   l_business_group_flag varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'competence_element_id',
                              p_argument_value => p_competence_element_id );
    --
  Select 'Y' into l_business_group_flag
  from per_competence_elements
  where competence_element_id = p_competence_element_id
  and business_group_id is null;


  if l_business_group_flag = 'Y' then
     return null;
  end if;

   if nvl(g_competence_element_id, hr_api.g_number) = p_competence_element_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
	 (p_associated_column1 => 'PER_COMPETENCE_ELEMENTS.COMPETENCE_ELEMENT_ID');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
    g_competence_element_id:= p_competence_element_id;
    g_legislation_code := l_legislation_code;
  end if;
  return l_legislation_code;
  --
 hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;
--
--

end per_cel_bus;

/

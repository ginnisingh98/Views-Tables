--------------------------------------------------------
--  DDL for Package Body PER_APL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APL_BUS" as
/* $Header: peaplrhi.pkb 120.1 2005/10/25 00:31:11 risgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_apl_bus.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |                        Local Procedure Definitions                       |
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_non_updateable_args >-------------------------|
-- ----------------------------------------------------------------------------
Procedure check_non_updateable_args(p_rec in per_apl_shd.g_rec_type)
is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_apl_shd.api_updating
                (p_application_id          => p_rec.application_id
                ,p_object_version_number   => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
                                per_apl_shd.g_old_rec.business_group_id then
      hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'BUSINESS_GROUP_ID'
      ,p_base_table => per_apl_shd.g_tab_nam
      );
  end if;
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
                                        per_apl_shd.g_old_rec.person_id then
      hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'PERSON_ID'
      ,p_base_table => per_apl_shd.g_tab_nam
      );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 14);
end check_non_updateable_args;
--
-- ---------------------------------------------------------------------------
-- |----------------------<  df_update_validate  >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--   Calls the descriptive flex validation routine (hr_dflex_utility)
--   if either the attribute_category or attribute1..30 have changed.
--
-- Pre-conditions:
--   Can only be called from update_validate
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the attribute_category and attribute1.30 haven't changed then the
--   validation is not performed and the processing continues.
--   If the attribute_category or attribute1.30 have changed then routine
--   hr_dflex_utility.ins_or_upd_descflex_attribs validates the descriptive
--   flex.
--   If an exception is not raised then processing continues.
--
-- Post Failure:
--   If an exception is raised within this procedure or lower
--   procedure calls, then it is raised through the normal exception
--   handling mechanism.
--
-- Access Status:
--   Internal Table Handler Use Only.
-- ---------------------------------------------------------------------------
procedure df_update_validate
  (p_rec in per_apl_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'df_update_validate';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if nvl(per_apl_shd.g_old_rec.appl_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute_category, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute1, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute2, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute3, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute4, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute5, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute6, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute7, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute8, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute9, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute10, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute11, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute12, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute13, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute14, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute15, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute16, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute17, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute18, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute19, hr_api.g_varchar2) or
     nvl(per_apl_shd.g_old_rec.appl_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.appl_attribute20, hr_api.g_varchar2)
  then
    -- either the attribute_category or attribute1..30 have changed
    -- so we must call the DFF validation routine
--
    hr_dflex_utility.ins_or_upd_descflex_attribs(
	 p_appl_short_name	=> 'PER'
	,p_descflex_name	=> 'PER_APPLICATIONS'
	,p_attribute_category	=> p_rec.appl_attribute_category
	,p_attribute1_name	=> 'APPL_ATTRIBUTE1'
	,p_attribute1_value	=> p_rec.appl_attribute1
	,p_attribute2_name	=> 'APPL_ATTRIBUTE2'
	,p_attribute2_value	=> p_rec.appl_attribute2
	,p_attribute3_name	=> 'APPL_ATTRIBUTE3'
	,p_attribute3_value	=> p_rec.appl_attribute3
	,p_attribute4_name	=> 'APPL_ATTRIBUTE4'
	,p_attribute4_value	=> p_rec.appl_attribute4
	,p_attribute5_name	=> 'APPL_ATTRIBUTE5'
	,p_attribute5_value	=> p_rec.appl_attribute5
	,p_attribute6_name	=> 'APPL_ATTRIBUTE6'
	,p_attribute6_value	=> p_rec.appl_attribute6
	,p_attribute7_name	=> 'APPL_ATTRIBUTE7'
	,p_attribute7_value	=> p_rec.appl_attribute7
	,p_attribute8_name	=> 'APPL_ATTRIBUTE8'
	,p_attribute8_value	=> p_rec.appl_attribute8
	,p_attribute9_name	=> 'APPL_ATTRIBUTE9'
	,p_attribute9_value	=> p_rec.appl_attribute9
	,p_attribute10_name	=> 'APPL_ATTRIBUTE10'
	,p_attribute10_value	=> p_rec.appl_attribute10
	,p_attribute11_name	=> 'APPL_ATTRIBUTE11'
	,p_attribute11_value	=> p_rec.appl_attribute11
	,p_attribute12_name	=> 'APPL_ATTRIBUTE12'
	,p_attribute12_value	=> p_rec.appl_attribute12
	,p_attribute13_name	=> 'APPL_ATTRIBUTE13'
	,p_attribute13_value	=> p_rec.appl_attribute13
	,p_attribute14_name	=> 'APPL_ATTRIBUTE14'
	,p_attribute14_value	=> p_rec.appl_attribute14
	,p_attribute15_name	=> 'APPL_ATTRIBUTE15'
	,p_attribute15_value	=> p_rec.appl_attribute15
	,p_attribute16_name	=> 'APPL_ATTRIBUTE16'
	,p_attribute16_value	=> p_rec.appl_attribute16
	,p_attribute17_name	=> 'APPL_ATTRIBUTE17'
	,p_attribute17_value	=> p_rec.appl_attribute17
	,p_attribute18_name	=> 'APPL_ATTRIBUTE18'
	,p_attribute18_value	=> p_rec.appl_attribute18
	,p_attribute19_name	=> 'APPL_ATTRIBUTE19'
	,p_attribute19_value	=> p_rec.appl_attribute19
	,p_attribute20_name	=> 'APPL_ATTRIBUTE20'
	,p_attribute20_value	=> p_rec.appl_attribute20
	);
--
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end df_update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_apl_shd.g_rec_type
			 ,p_effective_date in date
			 ,p_validate_df_flex in boolean default true) is -- 4689836
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 => per_apl_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
    );  -- Validate Bus Grp
  --
  --After validating the set of important attributes,
  --if multiple message detection is enabled and atleast
  --one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Call all supporting business operations
  --
  -- Validate PERSON_ID, DATE_RECEIVED_COMBINATION
  --
  per_apl_bus.chk_date_received_person_id
     (p_person_id             => p_rec.person_id
     ,p_application_id        => p_rec.application_id
     ,p_business_group_id     => p_rec.business_group_id
     ,p_date_received         => p_rec.date_received
     ,p_date_end              => p_rec.date_end
     ,p_projected_hire_date   => p_rec.projected_hire_date
     ,p_object_version_number => p_rec.object_version_number
     );
  --
  -- Validate PROJECTED_HIRE_DATE
  --
  per_apl_bus.chk_projected_hire_date
     (p_date_received         => p_rec.date_received
     ,p_projected_hire_date   => p_rec.projected_hire_date
     ,p_application_id        => p_rec.application_id
     ,p_object_version_number => p_rec.object_version_number
     );
  --
  -- Validate TERMINATION_REASON
  --
  per_apl_bus.chk_termination_reason
     (p_termination_reason    => p_rec.termination_reason
     ,p_application_id        => p_rec.application_id
     ,p_effective_date        => p_effective_date
     ,p_object_version_number => p_rec.object_version_number
     );
  --
  -- Validate Descriptive flexfields
  --
   if nvl(p_validate_df_flex,true) then -- 4689836
     hr_dflex_utility.ins_or_upd_descflex_attribs(
	 p_appl_short_name	=> 'PER'
	,p_descflex_name	=> 'PER_APPLICATIONS'
	,p_attribute_category	=> p_rec.appl_attribute_category
	,p_attribute1_name	=> 'APPL_ATTRIBUTE1'
	,p_attribute1_value	=> p_rec.appl_attribute1
	,p_attribute2_name	=> 'APPL_ATTRIBUTE2'
	,p_attribute2_value	=> p_rec.appl_attribute2
	,p_attribute3_name	=> 'APPL_ATTRIBUTE3'
	,p_attribute3_value	=> p_rec.appl_attribute3
	,p_attribute4_name	=> 'APPL_ATTRIBUTE4'
	,p_attribute4_value	=> p_rec.appl_attribute4
	,p_attribute5_name	=> 'APPL_ATTRIBUTE5'
	,p_attribute5_value	=> p_rec.appl_attribute5
	,p_attribute6_name	=> 'APPL_ATTRIBUTE6'
	,p_attribute6_value	=> p_rec.appl_attribute6
	,p_attribute7_name	=> 'APPL_ATTRIBUTE7'
	,p_attribute7_value	=> p_rec.appl_attribute7
	,p_attribute8_name	=> 'APPL_ATTRIBUTE8'
	,p_attribute8_value	=> p_rec.appl_attribute8
	,p_attribute9_name	=> 'APPL_ATTRIBUTE9'
	,p_attribute9_value	=> p_rec.appl_attribute9
	,p_attribute10_name	=> 'APPL_ATTRIBUTE10'
	,p_attribute10_value	=> p_rec.appl_attribute10
	,p_attribute11_name	=> 'APPL_ATTRIBUTE11'
	,p_attribute11_value	=> p_rec.appl_attribute11
	,p_attribute12_name	=> 'APPL_ATTRIBUTE12'
	,p_attribute12_value	=> p_rec.appl_attribute12
	,p_attribute13_name	=> 'APPL_ATTRIBUTE13'
	,p_attribute13_value	=> p_rec.appl_attribute13
	,p_attribute14_name	=> 'APPL_ATTRIBUTE14'
	,p_attribute14_value	=> p_rec.appl_attribute14
	,p_attribute15_name	=> 'APPL_ATTRIBUTE15'
	,p_attribute15_value	=> p_rec.appl_attribute15
	,p_attribute16_name	=> 'APPL_ATTRIBUTE16'
	,p_attribute16_value	=> p_rec.appl_attribute16
	,p_attribute17_name	=> 'APPL_ATTRIBUTE17'
	,p_attribute17_value	=> p_rec.appl_attribute17
	,p_attribute18_name	=> 'APPL_ATTRIBUTE18'
	,p_attribute18_value	=> p_rec.appl_attribute18
	,p_attribute19_name	=> 'APPL_ATTRIBUTE19'
	,p_attribute19_value	=> p_rec.appl_attribute19
	,p_attribute20_name	=> 'APPL_ATTRIBUTE20'
	,p_attribute20_value	=> p_rec.appl_attribute20
	);
   end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_apl_shd.g_rec_type
			 ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 => per_apl_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
    );  -- Validate Bus Grp
  --
  --After validating the set of important attributes,
  --if multiple message detection is enabled and atleast
  --one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Check the non-updateable arguments have in fact not been modified
  --
  per_apl_bus.check_non_updateable_args(p_rec => p_rec);
  --
  -- Validate DATE_RECEIVED
  --
  per_apl_bus.chk_date_received_person_id
     (p_person_id             => p_rec.person_id
     ,p_application_id        => p_rec.application_id
     ,p_business_group_id     => p_rec.business_group_id
     ,p_date_received         => p_rec.date_received
     ,p_date_end              => p_rec.date_end
     ,p_projected_hire_date   => p_rec.projected_hire_date
     ,p_object_version_number => p_rec.object_version_number
     );
  --
  -- Validate DATE_END
  --
  per_apl_bus.chk_date_end
   (p_date_end              => p_rec.date_end
   ,p_date_received         => p_rec.date_received
   ,p_application_id        => p_rec.application_id
   ,p_object_version_number => p_rec.object_version_number
   );
  --
  -- Validate PROJECTED_HIRE_DATE
  --
  per_apl_bus.chk_projected_hire_date
     (p_date_received         => p_rec.date_received
     ,p_projected_hire_date   => p_rec.projected_hire_date
     ,p_application_id        => p_rec.application_id
     ,p_object_version_number => p_rec.object_version_number
     );
  --
  -- Validate TERMINATION_REASON
  --
  per_apl_bus.chk_termination_reason
     (p_termination_reason    => p_rec.termination_reason
     ,p_application_id        => p_rec.application_id
     ,p_effective_date        => p_effective_date
     ,p_object_version_number => p_rec.object_version_number
     );
  --
  -- Validate Descriptive flexfields
  --
  per_apl_bus.df_update_validate(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_apl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
-- ----------------------------------------------------------------------------
-- |--------------------< chk_date_received_person_id >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_date_received_person_id
       (p_person_id             in per_applications.person_id%TYPE
       ,p_business_group_id     in per_applications.business_group_id%TYPE
       ,p_date_received         in per_applications.date_received%TYPE
       ,p_date_end              in per_applications.date_end%TYPE
       ,p_projected_hire_date   in per_applications.projected_hire_date%TYPE
       ,p_application_id        in per_applications.application_id%TYPE
       ,p_object_version_number in per_applications.object_version_number%TYPE
       ) is
--
  l_proc                 varchar2(72) := g_package||'chk_person_id';
  l_business_group_id    per_applications.business_group_id%TYPE;
  l_system_person_type   per_person_types.system_person_type%TYPE;
  l_api_updating         boolean;
  l_application_id       per_applications.application_id%TYPE;
--
  --
  -- Cursor to check that person_id exists, in addition obtain
  -- the system_person_type and the business_group_id for the
  -- other validation checks
  --
  cursor csr_valid_person_per_people_f is
    select   per.business_group_id,
             typ.system_person_type
    from     per_all_people_f     per,
             per_person_types typ
    where    per.person_id   = p_person_id
      and    per.person_type_id = typ.person_type_id
      and    per.effective_start_date = p_date_received;
  --
  --
  -- Cursor to check person_id, date_received combination
  --
  cursor csr_valid_person_per_apl is
    select application_id
    from   per_applications
    where  person_id     = p_person_id
      and  date_received = p_date_received;
--
begin
  hr_utility.set_location('Entering:'||l_proc,1);
  --
  -- Perform mandatory parameter checks
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_received'
    ,p_argument_value => p_date_received
   );
  --
  -- Perform person_id mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
   );
  --
  hr_utility.set_location(l_proc,11);
  --
  -- Check if application is being updated and load g_old_rec if applicable
  --
  l_api_updating := per_apl_shd.api_updating
        (p_application_id        => p_application_id
        ,p_object_version_number => p_object_version_number);
  --
  -- Proceed with validation based on outcome of api_updating call
  -- On update, only the date_received can change so no need to check
  -- for person_id changes.
  --
  if ((l_api_updating and
      per_apl_shd.g_old_rec.date_received <> p_date_received)
      or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,21);
    --
    -- Check the person_id exist date_effectively
    --
    open csr_valid_person_per_people_f;
    fetch csr_valid_person_per_people_f
          into l_business_group_id, l_system_person_type;
    if (csr_valid_person_per_people_f%notfound) then
      close csr_valid_person_per_people_f;
      hr_utility.set_message(801,'HR_51194_APL_INV_DT_PERSON');
      hr_multi_message.add
	(p_associated_column1  => 'PER_APPLICATIONS.PERSON_ID'
        ,p_associated_column2  => 'PER_APPLICATIONS.DATE_RECEIVED'
        );
    else
      close csr_valid_person_per_people_f;
      --
      hr_utility.set_location(l_proc,31);
      --
      -- The following person checks only need to be performed on an
      -- insert.
      --
      if NOT l_api_updating then
        --
        hr_utility.set_location(l_proc,41);
        --
        -- Check the system_person_type of the applicant is 'APL','EMP_APL',
        -- 'APL_EX_APL','EX_EMP_APL'
        --
        if (NOT l_api_updating and
          l_system_person_type <> 'APL'        AND
          l_system_person_type <> 'EMP_APL'    AND
          l_system_person_type <> 'APL_EX_APL' AND
          l_system_person_type <> 'EX_EMP_APL') then
          hr_utility.set_message(801,'HR_51185_APL_INV_SYS_PER_TYPE');
          hr_multi_message.add
	    (p_associated_column1  => 'PER_APPLICATIONS.PERSON_ID'
            );
        end if;
        --
        hr_utility.set_location(l_proc,51);
        --
        -- Check the application is in the same business group as the person
        --
        if (p_business_group_id <> l_business_group_id) then
            hr_utility.set_message(801,'HR_51187_APL_INV_BUS_GRP');
            hr_multi_message.add
	      (p_associated_column1  => 'PER_APPLICATIONS.PERSON_ID'
              );
        end if;
      end if;
    end if;
    --
    hr_utility.set_location(l_proc,61);
    --
    -- Validate date received with respect to DATE_END
    --
    if (p_date_received > nvl(p_date_end,hr_api.g_eot)) then
	hr_utility.set_message(801,'HR_51188_APL_DTE_REC_DTE_END');
	hr_multi_message.add
	  (p_associated_column1  => 'PER_APPLICATIONS.DATE_RECEIVED'
          ,p_associated_column2  => 'PER_APPLICATIONS.DATE_END'
          );
    end if;
    --
    hr_utility.set_location(l_proc,71);
    --
    -- Validate date received with respect to PROJECTED HIRE DATE
    --
    if (p_date_received > nvl(p_projected_hire_date,hr_api.g_eot)) then
      hr_utility.set_message(801,'HR_51189_APL_DTE_REC_PROJ_HIRE');
      hr_multi_message.add
        (p_associated_column1  => 'PER_APPLICATIONS.DATE_RECEIVED'
        ,p_associated_column2  => 'PER_APPLICATIONS.PROJECTED_HIRE_DATE'
        );
    end if;
    --
    hr_utility.set_location(l_proc,81);
    --
/*  Removed 18-Aug-97
    Reinstated 19-Jan-98, Version 110.3, S.Bhattal
*/
    --
    -- Validate date_received, person_id combination not exists
    --
    open csr_valid_person_per_apl;
    fetch csr_valid_person_per_apl into l_application_id;
    if (csr_valid_person_per_apl%found) then
       close csr_valid_person_per_apl;
       hr_utility.set_message(801,'HR_51190_APL_DTE_REC_PERSON');
       hr_multi_message.add
	 (p_associated_column1  => 'PER_APPLICATIONS.PERSON_ID'
         ,p_associated_column2  => 'PER_APPLICATIONS.DATE_RECEIVED'
         );
    else
      close csr_valid_person_per_apl;
    end if;
    --
    hr_utility.set_location(l_proc,91);
/*
*/
    --
  end if;
  hr_utility.set_location('Leaving '||l_proc, 101);
end chk_date_received_person_id;
--
-- ---------------------------------------------------------------------------
-- |----------------< chk_projected_hire_date >------------------------------|
-- ---------------------------------------------------------------------------
Procedure chk_projected_hire_date
   (p_date_received         in per_applications.date_received%TYPE
   ,p_projected_hire_date   in per_applications.projected_hire_date%TYPE
   ,p_application_id        in per_applications.application_id%TYPE
   ,p_object_version_number in per_applications.object_version_number%TYPE
   ) is
  --
  l_proc                 varchar2(72) := g_package||'chk_proj_hire_date';
  l_api_updating         boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,1);
  --
  -- Check if projected hire date is not null, only validate if it is not null
  --
  if hr_multi_message.no_all_inclusive_error
    (p_check_column1  =>  'PER_APPLICATIONS.DATE_RECEIVED'
    ) then
    if (p_projected_hire_date is not null) then
      --
      -- Check if application is being updated and load g_old_rec if applicable
      --
      l_api_updating := per_apl_shd.api_updating
          (p_application_id     => p_application_id
          ,p_object_version_number => p_object_version_number);
      --
      -- Proceed with validation based on outcome of api_updating call
      --
      if ((l_api_updating and
         nvl(per_apl_shd.g_old_rec.projected_hire_date,hr_api.g_date) <>
                                nvl(p_projected_hire_date,hr_api.g_date))
        or
        NOT l_api_updating) then
        --
        hr_utility.set_location('Inside:'||l_proc,11);
        --
        -- Validate projected hire date WRT date received.
        --
        if (p_date_received > p_projected_hire_date) then
          hr_utility.set_message(801,'HR_51192_APL_PROJ_HIRE_DTE_REC');
          hr_multi_message.add
	    (p_associated_column1  => 'PER_APPLICATIONS.DATE_RECEIVED'
            ,p_associated_column2  => 'PER_APPLICATIONS.PROJECTED_HIRE_DATE'
            );
        end if;
      end if;
      hr_utility.set_location('Inside:'||l_proc,21);
      --
    end if;
    hr_utility.set_location('Inside:'||l_proc,31);
    --
  end if;
  hr_utility.set_location(' Leaving:' || l_proc, 41);
end chk_projected_hire_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_end >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_date_end
   (p_date_end              in per_applications.date_end%TYPE
   ,p_date_received         in per_applications.date_received%TYPE
   ,p_application_id        in per_applications.application_id%TYPE
   ,p_object_version_number in per_applications.object_version_number%TYPE
   ) is
  --
  l_proc                 varchar2(72) := g_package||'chk_date_end';
  l_api_updating         boolean;
  l_person_id            number;
  l_assignment_id        number;
  --
  -- Cursors
  --
  cursor csr_chk_asg_future_changes is
     select assignment_id
     from   per_assignments_f
     where  application_id = p_application_id
     and    effective_start_date > p_date_end;
  --
  cursor csr_chk_apl_future_changes is
     select ppf.person_id
     from   per_people_f      ppf,
            per_applications  pa
     where  pa.application_id        = p_application_id
     and    pa.person_id             = ppf.person_id
     and    ppf.effective_start_date > p_date_end;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,1);
  --
  -- If date_end is non null then do the remaining validation otherwise end
  --
  if (p_date_end is not null) then
    --
    hr_utility.set_location(l_proc,11);
    --
    -- Check if application is being updated and load g_old_rec if applicable
    --
    l_api_updating := per_apl_shd.api_updating
          (p_application_id     => p_application_id
          ,p_object_version_number => p_object_version_number);
    --
    -- Proceed with validation based on outcome of api_updating call
    --
    if (NOT l_api_updating) then
      --
      -- On insert and not null, so raise error
      --
      hr_utility.set_location(l_proc,21);
      --
      hr_utility.set_message(801,'HR_7441_API_ARG_NOT_SET');
      hr_utility.set_message_token('ARG_NAME','DATE_END');
      hr_multi_message.add
	(p_associated_column1  => 'PER_APPLICATIONS.DATE_END'
        );
      --
    elsif (l_api_updating           and
             nvl(per_apl_shd.g_old_rec.date_end,hr_api.g_date) <>
                                                             p_date_end) then
				      --
      -- Date end changed to a not null value so do validation
      --
      hr_utility.set_location(l_proc,31);
      --
      -- If change is from not-null to different not-null then raise error
      --
      if (per_apl_shd.g_old_rec.date_end is not null and
          per_apl_shd.g_old_rec.date_end <> p_date_end) then
        hr_utility.set_location('Inside:'||l_proc,35);
        hr_utility.set_message(801,'HR_51234_APL_INVALID_UPDATE');
        hr_multi_message.add
	  (p_associated_column1  => 'PER_APPLICATIONS.DATE_END'
          );
      end if;
      hr_utility.set_location(l_proc,41);
      --
      -- Raise error if date_end before date_received
      --
      if (p_date_end < p_date_received) then
        hr_utility.set_message(801,'HR_51235_APL_DTE_END_DTE_REC');
        hr_multi_message.add
	  (p_associated_column1  => 'PER_APPLICATIONS.DATE_RECEIVED'
          ,p_associated_column2  => 'PER_APPLICATIONS.DATE_END'
          );
      end if;
      hr_utility.set_location(l_proc,51);
      --
      -- Raise error if there are future changes to the applicant assignments
      -- after date_end.
      --
      open csr_chk_asg_future_changes;
      fetch csr_chk_asg_future_changes into l_assignment_id;
      if csr_chk_asg_future_changes%found then
	--
        close csr_chk_asg_future_changes;
        --
        hr_utility.set_message(801,'HR_51236_APL_ASG_FUTURE_CHGS');
        hr_multi_message.add
	  (p_associated_column1  => 'PER_APPLICATIONS.DATE_END'
          );
      else
        --
        close csr_chk_asg_future_changes;
        --
      end if;

      hr_utility.set_location(l_proc,61);
      --
      -- Raise error if there are future changes to the applicant person
      -- after date_end.
      --
      open csr_chk_apl_future_changes;
      fetch csr_chk_apl_future_changes into l_person_id;
      if csr_chk_apl_future_changes%found then
	--
        close csr_chk_apl_future_changes;
        --
        hr_utility.set_message(801,'HR_51237_APL_PER_FUTURE_CHGS');
        hr_multi_message.add
	  (p_associated_column1  => 'PER_APPLICATIONS.DATE_END'
          );
      else
        --
        close csr_chk_apl_future_changes;
        --
      end if;
      hr_utility.set_location(l_proc,71);
      --
    end if;
    hr_utility.set_location(l_proc,81);
    --
  end if;
  hr_utility.set_location(' Leaving:' || l_proc,91);
end chk_date_end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_successful_flag >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_successful_flag
   (p_successful_flag       in per_applications.successful_flag%TYPE
   ,p_application_id        in per_applications.application_id%TYPE
   ,p_object_version_number in per_applications.object_version_number%TYPE
   ) is
   --
   l_proc                 varchar2(72) := g_package||'chk_successful_flag';
   l_api_updating         boolean;
   --
Begin
   hr_utility.set_location('Entering:'||l_proc,1);
   --
   --
   -- Check if application is being updated and load g_old_rec if applicable
   --
   l_api_updating := per_apl_shd.api_updating
          (p_application_id     => p_application_id
          ,p_object_version_number => p_object_version_number);
   --
   -- Proceed with validation based on outcome of api_updating call
   --
   if ((l_api_updating and
        nvl(per_apl_shd.g_old_rec.successful_flag,hr_api.g_date) <>
                                    nvl(p_successful_flag,hr_api.g_varchar2))
        or
        NOT l_api_updating) then
      --
      hr_utility.set_location('Inside:'||l_proc,11);
      --
      --  Check that successful flag is null
      --
      if p_successful_flag is not null then
        --  Error: Invalid value
        hr_utility.set_message(801, 'HR_7441_API_ARG_NOT_SET');
        hr_utility.set_message_token('ARG_NAME','SUCCESSFUL_FLAG');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location('Inside:'||l_proc,21);
      --
  end if;
  --
  hr_utility.set_location(' Leaving:' || l_proc, 31);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_APPLICATIONS.SUCCESSFUL_FLAG'
      ) then
      hr_utility.set_location(' Leaving:' || l_proc,40);
      raise;
    end if;
  hr_utility.set_location(' Leaving:' || l_proc,41);
end chk_successful_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_termination_reason >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_termination_reason
   (p_termination_reason    in per_applications.termination_reason%TYPE
   ,p_application_id        in per_applications.application_id%TYPE
   ,p_effective_date        in date
   ,p_object_version_number in per_applications.object_version_number%TYPE
   ) is
   --
   l_proc                 varchar2(72) := g_package||'chk_termination_reason';
   l_api_updating         boolean;
   --
Begin
   hr_utility.set_location('Entering:'||l_proc,1);
   --
   -- Check mandatory parameters have been set
   --
   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
   --
   -- If termination_reason is NULL do nothing
   --
   if p_termination_reason is not null then
     --
     -- Check if application is being updated and load g_old_rec if applicable
     --
     l_api_updating := per_apl_shd.api_updating
            (p_application_id     => p_application_id
            ,p_object_version_number => p_object_version_number);
     --
     -- Proceed with validation based on outcome of api_updating call
     --
     if ((l_api_updating and
          nvl(per_apl_shd.g_old_rec.termination_reason,hr_api.g_varchar2) <>
                                  nvl(p_termination_reason,hr_api.g_varchar2))
          or
          NOT l_api_updating) then
        --
        hr_utility.set_location('Inside:'||l_proc,11);
        --
        --  Check that termination reason is in the lookups table
        --
	if hr_api.not_exists_in_hr_lookups
	    (p_effective_date  => p_effective_date
	    ,p_lookup_type     => 'TERM_APL_REASON'
	    ,p_lookup_code     => p_termination_reason
	    )then
          -- Error : Invalid Termination Reason
          hr_utility.set_message(801,'HR_51238_APL_TERM_REASON');
         hr_utility.raise_error;
        end if;
        hr_utility.set_location('Inside:'||l_proc,21);
        --
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 31);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1  => 'PER_APPLICATIONS.TERMINATION_REASON'
        ) then
        hr_utility.set_location(' Leaving:'||l_proc,40);
        raise;
      end if;
  hr_utility.set_location(' Leaving:' ||l_proc,41);
end chk_termination_reason;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_application_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_applications     apl
     where apl.application_id    = p_application_id
       and pbg.business_group_id = apl.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'application_id',
                             p_argument_value => p_application_id);
  --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
    close csr_leg_code;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  hr_utility.set_location(' Leaving:' || l_proc, 20);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_apl_bus;

/

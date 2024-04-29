--------------------------------------------------------
--  DDL for Package Body PER_PER_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PER_BUS1" as
/* $Header: peperrhi.pkb 120.14.12010000.5 2009/08/17 12:07:47 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_per_bus1.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
procedure df_update_validate
  (p_rec in per_per_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'df_update_validate';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if nvl(per_per_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
     nvl(p_rec.attribute21, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
     nvl(p_rec.attribute22, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
     nvl(p_rec.attribute23, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
     nvl(p_rec.attribute24, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
     nvl(p_rec.attribute25, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
     nvl(p_rec.attribute26, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
     nvl(p_rec.attribute27, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
     nvl(p_rec.attribute28, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
     nvl(p_rec.attribute29, hr_api.g_varchar2) or
     nvl(per_per_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
     nvl(p_rec.attribute30, hr_api.g_varchar2) then
    -- either the attribute_category or attribute1..30 have changed
    -- so we must call the flex stub
    per_per_flex.df(p_rec => p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end df_update_validate;
--
--  ---------------------------------------------------------------------------
--  |------------------<  chk_unsupported_attributes  >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_unsupported_attributes
  (p_person_id               in     per_all_people_f.person_id%TYPE
  ,p_fast_path_employee      in     per_all_people_f.fast_path_employee%TYPE
  ,p_order_name              in     per_all_people_f.order_name%TYPE
  ,p_projected_start_date    in     per_all_people_f.projected_start_date%TYPE
  ,p_rehire_authorizor       in     per_all_people_f.rehire_authorizor%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_unsupported_attributes';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  if (l_api_updating and nvl(per_per_shd.g_old_rec.fast_path_employee, hr_api.g_varchar2)
       <> nvl(p_fast_path_employee, hr_api.g_varchar2))
    or
     (l_api_updating and nvl(per_per_shd.g_old_rec.order_name, hr_api.g_varchar2)
       <> nvl(p_order_name, hr_api.g_varchar2))
    or
     (l_api_updating and nvl(per_per_shd.g_old_rec.projected_start_date, hr_api.g_date)
       <> nvl(p_projected_start_date, hr_api.g_date))
    or
     (l_api_updating and nvl(per_per_shd.g_old_rec.rehire_authorizor, hr_api.g_varchar2)
       <> nvl(p_rehire_authorizor, hr_api.g_varchar2))
    or
      (NOT l_api_updating)
  then
    --
    -- Check if any of the unsupported attributes are set
    --
    if p_fast_path_employee is not null then
      --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', 'Fast Path Employee Null Check');
      hr_utility.raise_error;
      --
    end if;
    --
    if p_order_name is not null then
      --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', 'Order Name Null Check');
      hr_utility.raise_error;
      --
    end if;
    --
    if p_projected_start_date is not null then
      --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', 'Projected Start Date Null Check');
      hr_utility.raise_error;
      --
    end if;
    --
    if p_rehire_authorizor is not null then
      --
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', 'Rehire Authorizor Null Check');
      hr_utility.raise_error;
      --
    end if;
    --
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_unsupported_attributes;
--
--  ---------------------------------------------------------------------------
--  |----------------< chk_correspondence_language >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_correspondence_language
  (p_person_id               in    per_all_people_f.person_id%TYPE
  ,p_effective_date          in    date
  ,p_correspondence_language in    per_all_people_f.correspondence_language%TYPE
  ,p_object_version_number   in    per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_correspondence_language';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
  Cursor C_Sel1 Is
    select null
    from   fnd_languages
    where  p_correspondence_language = language_code;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.correspondence_language, hr_api.g_varchar2)
       <> nvl(p_correspondence_language, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    --
    --  Check if correspondence language is set.
    --
    if p_correspondence_language is not null then
      --
      -- Check the correspondence language exists in FND_LANGUAGES table.
      --
      open C_Sel1;
      fetch C_Sel1 into l_exists;
      if C_Sel1%NOTFOUND
      then
        --
   close C_Sel1;
        hr_utility.set_message(801, 'PER_????_PER_INV_COR_LANG');
        hr_utility.raise_error;
        --
      end if;
      close C_Sel1;
    end if;
  end if;
  hr_utility.set_location('Leaving '||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE'
      )
      then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
end chk_correspondence_language;
--
--  ---------------------------------------------------------------------------
--  |----------------< chk_coord_ben_med_cvg_dates >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_coord_ben_med_cvg_dates
  (p_coord_ben_med_cvg_strt_dt in  date
  ,p_coord_ben_med_cvg_end_dt  in  date
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_coord_ben_med_cvg_dates';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Make sure that the coverage start date is before the coverage end date.
  --
  if p_coord_ben_med_cvg_strt_dt is not null or
     p_coord_ben_med_cvg_end_dt is not null then
    --
    -- Make sure that cvg strt dt is after cvg strt dt.
    --
    if (p_coord_ben_med_cvg_strt_dt is null and
       p_coord_ben_med_cvg_end_dt is not null) or
       (p_coord_ben_med_cvg_strt_dt >
       nvl(p_coord_ben_med_cvg_end_dt,hr_api.g_eot)) then
      --
      -- Error as end dt can not be set unless strt dt has been set
      --
      fnd_message.set_name('PER','HR_289110_MED_CVG_DATES');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  hr_utility.set_location('Leaving '||l_proc,30);
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
       (p_associated_column1    => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_STRT_DT'
       ,p_associated_column2    => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_END_DT'
       ) then
         hr_utility.set_location(' Leaving:'||l_proc, 40);
         raise;
       end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
end;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_other_coverages >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_other_coverages
  (p_attribute10                 in varchar2
  ,p_coord_ben_med_insr_crr_name in varchar2
  ,p_coord_ben_med_cvg_end_dt    in date
  ,p_coord_ben_no_cvg_flag       in varchar2
  ,p_effective_date              in date
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_other_coverages';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check that the ben_no_cvg_flag is set accordingly based on the value
  -- of the covered under medicare flag.
  --
  if hr_multi_message.no_all_inclusive_error
       (p_check_column1      => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_INSR_CRR_NAME'
       ,p_check_column2      => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_END_DT'
       )
  then
    if p_attribute10 = 'Y' or
       (p_coord_ben_med_insr_crr_name is not null and
        nvl(p_coord_ben_med_cvg_end_dt,hr_api.g_eot) > p_effective_date) then
      --
      if p_coord_ben_no_cvg_flag = 'Y' then
        --
        fnd_message.set_name('PER','HR_289111_CVG_FLAG_SET');
        fnd_message.raise_error;
        --
      end if;
      --
    end if;
 end if;
    hr_utility.set_location('Leaving '||l_proc,30);
    exception
      when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1 => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_INSR_CRR_NAME'
        ,p_associated_column2 => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_END_DT'
        ,p_associated_column3 => 'PER_ALL_PEOPLE_F.COORD_BEN_NO_CVG_FLAG'
        ,p_associated_column4 => 'PER_ALL_PEOPLE_F.ATTRIBUTE10'
        ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
end;
--  ---------------------------------------------------------------------------
--  |----------------< chk_fte_capacity >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_fte_capacity
  (p_person_id               in    per_all_people_f.person_id%TYPE
  ,p_effective_date          in    date
  ,p_fte_capacity            in    per_all_people_f.fte_capacity%TYPE
  ,p_object_version_number   in    per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_fte_capacity';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.fte_capacity, hr_api.g_number)
       <> nvl(p_fte_capacity, hr_api.g_number)) or
      (NOT l_api_updating))
  then
    --
    --  Check if fte_capacity is set.
    --
    if p_fte_capacity is not null then
      --
      -- Check the fte capacity is in the correct range
      --
      if p_fte_capacity < 0   OR
    p_fte_capacity > 100
      then
        --Changes done for Bug 7201892
        hr_utility.set_message(801, 'HR_51856_EMP_FTE_VALUE');
        hr_utility.raise_error;
        --
      end if;
    end if;
  end if;
  hr_utility.set_location('Leaving '||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
           (p_associated_column1      => 'PER_ALL_PEOPLE_F.FTE_CAPACITY'
           ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
end chk_fte_capacity;
--
--  ---------------------------------------------------------------------------
--  |----------------< chk_coord_ben_med_details >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_coord_ben_med_details
  (p_coord_ben_med_cvg_strt_dt    in  date
  ,p_coord_ben_med_cvg_end_dt     in  date
  ,p_coord_ben_med_ext_er         in  varchar2
  ,p_coord_ben_med_pl_name        in  varchar2
  ,p_coord_ben_med_insr_crr_name  in  varchar2
  ,p_coord_ben_med_insr_crr_ident in  varchar2
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_coord_ben_med_details';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if the correct attributes have been set
  -- If any of the attributes have been set for benefits coverage then at
  -- minimum the insurance carrier name must be set.
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_STRT_DT'
     ,p_check_column2      => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_END_DT'
     )
  then
    if p_coord_ben_med_insr_crr_name is null and
      (p_coord_ben_med_cvg_strt_dt is not null or
       p_coord_ben_med_cvg_end_dt is not null or
       p_coord_ben_med_ext_er is not null or
       p_coord_ben_med_pl_name is not null or
       p_coord_ben_med_insr_crr_name is not null or
       p_coord_ben_med_insr_crr_ident is not null) then
      --
      -- Error as benefit coverage info has been entered without the carrier
      -- name being entered.
      --
      fnd_message.set_name('PER','HR_289112_BEN_MED_DETAILS');
      fnd_message.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_PEOPLE_F.COORD_BEN_MED_INSR_CRR_NAME'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
 hr_utility.set_location(' Leaving:'||l_proc,50);
--
end;
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_BACKGROUND_CHECK_STATUS  >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_BACKGROUND_CHECK_STATUS
  (p_person_id               in     per_all_people_f.person_id%TYPE
  ,p_BACKGROUND_CHECK_STATUS in     per_all_people_f.BACKGROUND_CHECK_STATUS%TYPE
  ,p_effective_date          in     date
  ,p_validation_start_date   in     date
  ,p_validation_end_date     in     date
  ,p_object_version_number   in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_BACKGROUND_CHECK_STATUS';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.BACKGROUND_CHECK_STATUS, hr_api.g_varchar2)
       <> nvl(p_BACKGROUND_CHECK_STATUS, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    --
    --  Check if Background Check Status is set.
    --
    if p_BACKGROUND_CHECK_STATUS is not null then
      --
      -- Check that the Background Check Status exists in hr_lookups for the
      -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that the
      -- effective start date of the Person is between start date active and
      -- end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'YES_NO'
        ,p_lookup_code           => p_BACKGROUND_CHECK_STATUS
        )
      then
        --
        hr_utility.set_message(801, 'PER_52083_PER_INV_BK_CH_ST');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1   => 'PER_ALL_PEOPLE_F.BACKGROUND_CHECK_STATUS'
        ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_BACKGROUND_CHECK_STATUS;
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_blood_type  >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_blood_type
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_blood_type            in     per_all_people_f.blood_type%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_blood_type';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.blood_type, hr_api.g_varchar2)
       <> nvl(p_blood_type, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    --
    --  Check if Blood Type is set.
    --
    if p_blood_type is not null then
      --
      -- Check that the Blood Type exists in hr_lookups for the
      -- lookup type 'BLOOD_TYPE' with an enabled flag set to 'Y' and that the
      -- effective start date of the Person is between start date active and
      -- end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'BLOOD_TYPE'
        ,p_lookup_code           => p_blood_type
        )
      then
        --
        hr_utility.set_message(800, 'PER_52111_PER_INV_BL_TYPE');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
        (p_associated_column1      => 'PER_ALL_PEOPLE_F.BLOOD_TYPE'
        ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
       end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_blood_type;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_student_status  >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_student_status
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_student_status        in     per_all_people_f.student_status%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_student_status';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.student_status, hr_api.g_varchar2)
       <> nvl(p_student_status, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    --
    --  Check if Student Status is set.
    --
    if p_student_status is not null then
      --
      -- Check that the Student Status exists in hr_lookups for the
      -- lookup type 'STUDENT_STATUS' with an enabled flag set to 'Y' and that the
      -- effective start date of the Person is between start date active and
      -- end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'STUDENT_STATUS'
        ,p_lookup_code           => p_student_status
        )
      then
        --
        hr_utility.set_message(800, 'PER_52112_PER_INV_STUD_STAT');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.STUDENT_STATUS'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc,50);
        raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_student_status;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_work_schedule  >-------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_work_schedule
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_work_schedule         in     per_all_people_f.work_schedule%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_work_schedule';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.work_schedule, hr_api.g_varchar2)
       <> nvl(p_work_schedule, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    --
    --  Check if Work Schedule is set.
    --
    if p_work_schedule is not null then
      --
      -- Check that the Work Schedule exists in hr_lookups for the
      -- lookup type 'WORK_SCHEDULE' with an enabled flag set to 'Y' and that the
      -- effective start date of the Person is between start date active and
      -- end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'WORK_SCHEDULE'
        ,p_lookup_code           => p_work_schedule
        )
      then
        --
        hr_utility.set_message(800, 'PER_52113_PER_INV_WK_SCHD');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.WORK_SCHEDULE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_work_schedule;
--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_rehire_recommendation  >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_rehire_recommendation
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_rehire_recommendation in     per_all_people_f.rehire_recommendation%TYPE
  ,p_effective_date        in     date
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_rehire_recommendation';
  l_api_updating     boolean;
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.rehire_recommendation, hr_api.g_varchar2)
       <> nvl(p_rehire_recommendation, hr_api.g_varchar2)) or
      (NOT l_api_updating))
  then
    --
    --  Check if Rehire Recommendation is set.
    --
    if p_rehire_recommendation is not null then
      --
      -- Check that the Rehire Recommendation exists in hr_lookups for the
      -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that the
      -- effective start date of the Person is between start date active and
      -- end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'YES_NO'
        ,p_lookup_code           => p_rehire_recommendation
        )
      then
        --
        hr_utility.set_message(800, 'PER_52114_PER_INV_REH_REC');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.REHIRE_RECOMMENDATION'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_rehire_recommendation;
-- ----------------------------------------------------------------------------
-- |----------------------< chk_benefit_group_id >----------------------------|
-- ----------------------------------------------------------------------------
--
--
--  Description:
--    - Validates that benefit_group_id exists in BEN_BENFTS_GRP where
--      on the effective date.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_benefit_group_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - benefit_group_id = benfts_grp_id in the BEN_BENFTS_GRP on the
--        effective date.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Benefit group id doesn't exist in BEN_BENFTS_GRP on the
--        effective date.
--
--  Access Status:
--    Internal Table Handler Use Only.

procedure chk_benefit_group_id
  (p_person_id              in     per_all_people_f.person_id%TYPE
  ,p_benefit_group_id       in     per_all_people_f.benefit_group_id%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_people_f.object_version_number%TYPE
  )
  is
--
cursor csr_chk_benefit_group_id is
select null
from   ben_benfts_grp
where  benfts_grp_id = p_benefit_group_id;
  --
  l_proc           varchar2(72)  :=  g_package||'chk_benefit_group_id';
  l_benefit_group_id number;
  --
  begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  if p_benefit_group_id is NOT NULL then
    open csr_chk_benefit_group_id;
    fetch csr_chk_benefit_group_id into l_benefit_group_id;
    if csr_chk_benefit_group_id%NOTFOUND then
      close csr_chk_benefit_group_id;
      hr_utility.set_message(800, 'PER_52385_BEN_GROUP_ID');
      hr_utility.raise_error;
    end if;
    close csr_chk_benefit_group_id;
  --
  end if;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1      => 'PER_ALL_PEOPLE_F.BENEFIT_GROUP_ID'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
end chk_benefit_group_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_date_death_and_rcpt_cert >--------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    - Validates that if the date of death is null the date of recipt of death
--      certificate is also null. Also validates that the date the death
--      certificate is received is the same or later than the date of death.
--
--  Pre-conditions:
--    Valid p_person_id
--
--  In Arguments:
--    p_person_id
--    p_receipt_of_death_cert_date
--    p_effective_date
--    p_date_of_death
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - date_of_death is null and the receipt_of_death_cert_date is null.
--      - receipt_of_death_cert_date is on or later than the date_of_death.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - The receipt_of_death_cert date is not null and the date_of_death is null.
--      - The receipt_of_death_cert_date is earlier than the date_of_death.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_date_death_and_rcpt_cert
  (p_person_id                  in     per_all_people_f.person_id%TYPE
  ,p_receipt_of_death_cert_date in     per_all_people_f.receipt_of_death_cert_date%TYPE
  ,p_effective_date             in     date
  ,p_object_version_number      in     per_all_people_f.object_version_number%TYPE
  ,p_date_of_death              in     date
   )
  is
--
l_proc          varchar2(72)  :=  g_package||'chk_date_death_and_rcpt_cert';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  if p_receipt_of_death_cert_date is NOT NULL then
    if p_date_of_death is NULL then
      hr_utility.set_message(800,'PER_52424_DATE_DEATH_RCPT_CERT');
      hr_multi_message.add
      (p_associated_column1 => 'PER_ALL_PEOPLE_F.RECEIPT_OF_DEATH_CERT_DATE'
      ,p_associated_column2 => 'PER_ALL_PEOPLE_F.DATE_OF_DEATH'
      );
    elsif p_receipt_of_death_cert_date <= nvl(p_date_of_death, hr_api.g_date) then
      hr_utility.set_message(800,'PER_52962_CERT_DTE_LT_DOD');
      hr_multi_message.add
      (p_associated_column1 => 'PER_ALL_PEOPLE_F.RECEIPT_OF_DEATH_CERT_DATE'
      ,p_associated_column2 => 'PER_ALL_PEOPLE_F.DATE_OF_DEATH'
      );
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_date_death_and_rcpt_cert;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_birth_adoption_date >---------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    - Validates that  if the date of birth is null then the dependent's adoption
--      date is also null. Also validates that the dependent's date of adoption
--      is the same or later than the date of birth.
--
--  Pre-conditions:
--    Valid p_person_id
--
--  In Arguments:
--    p_person_id
--    p_dpdnt_adoption_date
--    p_effective_date
--    p_date_of_birth
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - dpdnt_adoption_date is null if date_of_birth is null
--      - dpdnt_adoption_date is on or later than the date_of_birth.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - The dpdnt_adoption_date is not null and the date_of_birth is null.
--      - The dpdnt_adoption_date is earlier than the date_of_birth.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_birth_adoption_date
  (p_person_id              in     per_all_people_f.person_id%TYPE
  ,p_dpdnt_adoption_date    in     per_all_people_f.dpdnt_adoption_date%TYPE
  ,p_date_of_birth          in     date
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_people_f.object_version_number%TYPE
  )
  is
--
l_proc          varchar2(72)  :=  g_package||'chk_birth_adoption_date';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  if p_dpdnt_adoption_date is NOT NULL then
    if p_date_of_birth IS NULL then
      hr_utility.set_message(800,'PER_52425_DATE_BIRTH_ADOPTION');
      hr_multi_message.add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.DPDNT_ADOPTION_DATE'
      ,p_associated_column2      => 'PER_ALL_PEOPLE_F.DATE_OF_BIRTH'
      );

-- bug fix : 2164967 begins

    elsif p_dpdnt_adoption_date < nvl(p_date_of_birth, hr_api.g_date) then
      hr_utility.set_message(800,'PER_52961_ADOPT_LT_DOB');
      hr_multi_message.add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.DPDNT_ADOPTION_DATE'
      ,p_associated_column2      => 'PER_ALL_PEOPLE_F.DATE_OF_BIRTH'
      );

-- bug fix : 2164967 ends

    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
end chk_birth_adoption_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_date_of_death >-------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    - Validates that the date of death is the same or later than the
--      date of birth.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_date_of_death
--    p_effective_date
--    p_date_of_birth
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - date_of_death is on or later than the date_of_birth.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - The date_of_death is earlier than the date_of_birth.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_date_of_death
  (p_person_id              in     per_all_people_f.person_id%TYPE
  ,p_date_of_death          in     per_all_people_f.date_of_death%TYPE
  ,p_date_of_birth          in     per_all_people_f.date_of_birth%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_people_f.object_version_number%TYPE
  )
  is
--
l_proc          varchar2(72)  :=  g_package||'chk_date_of_death';
--
--fix for bug 4262496 starts here.
l_con_start_date date;

cursor csr_chk_sd is
select date_start
from per_contact_relationships
where contact_person_id=p_person_id;
--fix for bug 4262496 ends here.
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  if hr_multi_message.no_exclusive_error
           (p_check_column1      => 'PER_ALL_PEOPLE_F.DATE_OF_BIRTH'
           ,p_check_column2      => 'PER_ALL_PEOPLE_F.DATE_OF_DEATH'
           ) then
    if p_date_of_death is NOT NULL then
     if p_date_of_death < nvl(p_date_of_birth, hr_api.g_date) then --fix for bug 4262496.
    hr_utility.set_message(800,'PER_52963_DOD_LT_DOB');
        hr_utility.raise_error;
      end if;
    end if;
    --fix for bug 4262496 starts here.
  open csr_chk_sd;
  loop
  fetch csr_chk_sd into l_con_start_date;
  exit when csr_chk_sd%notfound ;
  if p_date_of_death  < l_con_start_date then
    hr_utility.set_message(800,'HR_449686_RELATION_EXISTS');
    hr_utility.raise_error;

  end if;
  end loop;
  close  csr_chk_sd;
--fix for bug 4262496 ends here.
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1      => 'PER_ALL_PEOPLE_F.DATE_OF_BIRTH'
    ,p_associated_column2      => 'PER_ALL_PEOPLE_F.DATE_OF_DEATH'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 20);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,30);
end chk_date_of_death;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_rd_flag >----------------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that registered disabled exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'REGISTERED_DISABLED' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_registered_disabled_flag
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Student Status exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'REGISTERED_DISABLED' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Registered_disabled doesn't exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'REGISTERED_DISABLED' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_rd_flag
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_registered_disabled_flag in     per_all_people_f.registered_disabled_flag%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_rd_flag';
  l_exists           varchar2(1);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
    --  Check if registered_disabled_flag is set.
    --
    if p_registered_disabled_flag is not null then
      --
      -- Check that the registered_disabled_flag exists in hr_lookups for the
      -- lookup type 'REGISTERED_DISABLED' with an enabled flag set to 'Y' and that the
      -- effective start date of the Person is between start date active and
      -- end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'REGISTERED_DISABLED'
        ,p_lookup_code           => p_registered_disabled_flag
        )
        then
        --
        hr_utility.set_message(800, 'PER_52386_REG_DISABLED');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
    hr_utility.set_location(l_proc, 30);
    --
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1     => 'PER_ALL_PEOPLE_F.REGISTERED_DISABLED_FLAG'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_rd_flag;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_uses_tobacco >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that Uses Tobacco exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'TOBACCO_USER' with an enabled
--      flag set to 'Y' and the effective start date of the Person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_uses_tobacco_flag
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - Uses tobacco exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'TOBACCO_USER' where the enabled flag is 'Y' and
--        the effective start date of the Person is between start date
--        active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - Uses Tobacco doesn't exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'TOBACCO_USER' where the enabled flag
--        is 'Y' and the effective start date of the person is between
--        start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_uses_tobacco
   (p_person_id                in     per_all_people_f.person_id%TYPE
   ,p_uses_tobacco_flag        in     per_all_people_f.uses_tobacco_flag%TYPE
   ,p_effective_date           in     date
   ,p_validation_start_date    in     date
   ,p_validation_end_date      in     date
   ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
    )
  is
--
  l_proc             varchar2(72)  :=  g_package||'chk_uses_tobacco';
  l_exists           varchar2(1);
  --
  begin
hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
     );
  --
   hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
     );
  --
   hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location('Entering:'|| l_proc, 20);
    --
    --  Check if uses_tobacco_flag is set.
    --
  if p_uses_tobacco_flag is not null then
    --
    -- Check that the uses_tobacco_flag exists in hr_lookups for the
    -- lookup type 'TOBACCO_USER' with an enabled flag set to 'Y' and that the
    -- effective start date of the Person is between start date active and
    -- end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'TOBACCO_USER'
      ,p_lookup_code           => p_uses_tobacco_flag
      )
      then
      --
      hr_utility.set_message(800, 'PER_52388_USES_TOBACCO_F');
      hr_utility.raise_error;
      --
    end if;
  --
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.USES_TOBACCO_FLAG'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
  end chk_uses_tobacco;
--
end per_per_bus1;

/

--------------------------------------------------------
--  DDL for Package Body PER_KW_DISABILITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KW_DISABILITY_API" as
/* $Header: pediskwi.pkb 120.0 2005/05/31 07:40:04 appldev noship $ */


--
-- Package Variables
--
g_package  varchar2(33) := 'per_kw_disability_api.';
--
-- ----------------------------------------------------------------------
-- |-----------------------< create_kw_disability >---------------------|
-- ----------------------------------------------------------------------
--
procedure create_kw_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_category                      in     varchar2
  ,p_status                        in     varchar2
  ,p_quota_fte                     in     number   default 1.00
  ,p_organization_id               in     number   default null
  ,p_registration_id               in     varchar2 default null
  ,p_registration_date             in     date     default null
  ,p_registration_exp_date         in     date     default null
  ,p_description                   in     varchar2 default null
  ,p_degree                        in     number   default null
  ,p_reason                        in     varchar2 default null
  ,p_work_restriction              in     varchar2 default null
  ,p_incident_id                   in     number   default null
  ,p_medical_assessment_id         in     number   default null
  ,p_pre_registration_job          in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_range_of_disability           in     varchar2 default null
  ,p_reporting_description         in     varchar2 default null
  ,p_disability_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  l_proc              varchar2(72) := g_package||'create_kw_contract';
  l_legislation_code  varchar2(2);
  --
  cursor csr_get_business_group_id is
    select per.business_group_id
    from per_all_people_f per
    where per.person_id = p_person_id
    and   p_effective_date between per.effective_start_date
                               and per.effective_end_date;
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = l_business_group_id;
  --
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_kw_disability;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Get person details.
  --
  open  csr_get_business_group_id;
  fetch csr_get_business_group_id
  into l_business_group_id;
  --
  if csr_get_business_group_id%NOTFOUND then
    close csr_get_business_group_id;
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  close csr_get_business_group_id;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  hr_utility.set_location(l_proc, 50);
  --
  -- Check that the legislation of the specified business group is 'KW'.
  --
  if l_legislation_code <> 'KW' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','KW');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the disability business process
  --
  per_disability_api.create_disability
       (p_validate                      => p_validate
       ,p_effective_date                => p_effective_date
       ,p_person_id                     => p_person_id
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => p_registration_date
       ,p_registration_exp_date         => p_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_medical_assessment_id         => p_medical_assessment_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => 'KW'
       ,p_dis_information1              => p_range_of_disability
       ,p_dis_information2              => p_reporting_description
       ,p_disability_id                 => p_disability_id
       ,p_object_version_number         => p_object_version_number
       ,p_effective_start_date          => p_effective_start_date
       ,p_effective_end_date            => p_effective_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end create_kw_disability;
--
-- ----------------------------------------------------------------------
-- |------------------------< update_kw_disability >--------------------|
-- ----------------------------------------------------------------------
--
procedure update_kw_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_disability_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_category                      in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_quota_fte                     in     number   default hr_api.g_number
  ,p_organization_id               in     number   default hr_api.g_number
  ,p_registration_id               in     varchar2 default hr_api.g_varchar2
  ,p_registration_date             in     date     default hr_api.g_date
  ,p_registration_exp_date         in     date     default hr_api.g_date
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_degree                        in     number   default hr_api.g_number
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_work_restriction              in     varchar2 default hr_api.g_varchar2
  ,p_incident_id                   in     number   default hr_api.g_number
  ,p_medical_assessment_id         in     number   default hr_api.g_number
  ,p_pre_registration_job          in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_range_of_disability           in     varchar2 default hr_api.g_varchar2
  ,p_reporting_description         in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id    per_contracts_f.business_group_id%TYPE;
  l_proc                 varchar2(72) := g_package||'update_kw_disability';
  l_legislation_code     varchar2(2);
  --
  cursor csr_get_business_group_id is
    select per.business_group_id
    from per_all_people_f per
    where per.person_id in (select dis.person_id
                           from    per_disabilities_f dis
                           where   dis.disability_id = p_disability_id
                           and     p_effective_date between dis.effective_start_date
                                                    and     dis.effective_end_date)
    and   p_effective_date between per.effective_start_date
                               and per.effective_end_date;
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = l_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_kw_disability;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Get person details.
  --
  open  csr_get_business_group_id;
  fetch csr_get_business_group_id
  into l_business_group_id;
  --
  if csr_get_business_group_id%NOTFOUND then
    close csr_get_business_group_id;
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  close csr_get_business_group_id;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Check that the legislation of the specified business group is 'KW'.
  --
  if l_legislation_code  <>  'KW' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','KW');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the contract business process
  --
  per_disability_api.update_disability
       (p_validate                      => p_validate
       ,p_effective_date                => p_effective_date
       ,p_datetrack_mode                => p_datetrack_mode
       ,p_disability_id                 => p_disability_id
       ,p_object_version_number         => p_object_version_number
       ,p_category                      => p_category
       ,p_status                        => p_status
       ,p_quota_fte                     => p_quota_fte
       ,p_organization_id               => p_organization_id
       ,p_registration_id               => p_registration_id
       ,p_registration_date             => p_registration_date
       ,p_registration_exp_date         => p_registration_exp_date
       ,p_description                   => p_description
       ,p_degree                        => p_degree
       ,p_reason                        => p_reason
       ,p_work_restriction              => p_work_restriction
       ,p_incident_id                   => p_incident_id
       ,p_medical_assessment_id         => p_medical_assessment_id
       ,p_pre_registration_job          => p_pre_registration_job
       ,p_attribute_category            => p_attribute_category
       ,p_attribute1                    => p_attribute1
       ,p_attribute2                    => p_attribute2
       ,p_attribute3                    => p_attribute3
       ,p_attribute4                    => p_attribute4
       ,p_attribute5                    => p_attribute5
       ,p_attribute6                    => p_attribute6
       ,p_attribute7                    => p_attribute7
       ,p_attribute8                    => p_attribute8
       ,p_attribute9                    => p_attribute9
       ,p_attribute10                   => p_attribute10
       ,p_attribute11                   => p_attribute11
       ,p_attribute12                   => p_attribute12
       ,p_attribute13                   => p_attribute13
       ,p_attribute14                   => p_attribute14
       ,p_attribute15                   => p_attribute15
       ,p_attribute16                   => p_attribute16
       ,p_attribute17                   => p_attribute17
       ,p_attribute18                   => p_attribute18
       ,p_attribute19                   => p_attribute19
       ,p_attribute20                   => p_attribute20
       ,p_attribute21                   => p_attribute21
       ,p_attribute22                   => p_attribute22
       ,p_attribute23                   => p_attribute23
       ,p_attribute24                   => p_attribute24
       ,p_attribute25                   => p_attribute25
       ,p_attribute26                   => p_attribute26
       ,p_attribute27                   => p_attribute27
       ,p_attribute28                   => p_attribute28
       ,p_attribute29                   => p_attribute29
       ,p_attribute30                   => p_attribute30
       ,p_dis_information_category      => 'KW'
       ,p_dis_information1              => p_range_of_disability
       ,p_dis_information2              => p_reporting_description
       ,p_effective_start_date          => p_effective_start_date
       ,p_effective_end_date            => p_effective_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end update_kw_disability;
--
end per_kw_disability_api;

/
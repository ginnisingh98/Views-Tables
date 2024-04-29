--------------------------------------------------------
--  DDL for Package Body HR_FR_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_CONTRACT_API" as
/* $Header: hrctcfri.pkb 120.3 2006/07/19 06:36:11 nmuthusa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_fr_contract_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_fr_contract >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fr_contract
  (p_validate                       in  boolean
  ,p_contract_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          out nocopy number
  ,p_person_id                      in  number
  ,p_reference                      in  varchar2
  ,p_type                           in  varchar2
  ,p_status                         in  varchar2
  ,p_status_reason                  in  varchar2
  ,p_doc_status                     in  varchar2
  ,p_doc_status_change_date         in  date
  ,p_description                    in  varchar2
  ,p_duration                       in  number
  ,p_duration_units                 in  varchar2
  ,p_contractual_job_title          in  varchar2
  ,p_parties                        in  varchar2
  ,p_start_reason                   in  varchar2
  ,p_end_reason                     in  varchar2
  ,p_number_of_extensions           in  number
  ,p_extension_reason               in  varchar2
  ,p_extension_period               in  number
  ,p_extension_period_units         in  varchar2
  ,p_employee_type	            in  varchar2
  ,p_contract_category              in  varchar2
  ,p_proposed_end_date              in  varchar2
  ,p_end_event		            in  varchar2
  ,p_person_replaced                in  varchar2
  ,p_probation_period               in  varchar2
  ,p_probation_period_units         in  varchar2
  ,p_probation_end_date             in  varchar2
  ,p_smic_adjusted_duration_days    in  number
  ,p_fixed_working_time		    in  varchar2
  ,p_amount			    in	number
  ,p_units			    in  varchar2
  ,p_frequency			    in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_effective_date                 in  date
  ) is

  --
  -- Declare cursors and local variables
  --
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  l_proc                 varchar2(72) := g_package||'create_fr_contract';
  l_legislation_code     varchar2(2);
  l_amount		 varchar2(30);
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
  savepoint create_fr_contract;
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
    --
    close csr_get_business_group_id;
    --
    hr_utility.set_location(l_proc, 30);
    --
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  --
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
  -- Check that the legislation of the specified business group is 'FR'.
  --
  if l_legislation_code <> 'FR' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','FR');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Number to canonical conversion
  --
  l_amount := fnd_number.number_to_canonical(p_amount);
  --
  -- Call the contract business process
  --
  hr_contract_api.create_contract
     (
     p_validate			     => p_validate
    ,p_contract_id                   => p_contract_id
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date
    ,p_object_version_number         => p_object_version_number
    ,p_person_id                     => p_person_id
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
    ,p_doc_status                    => p_doc_status
    ,p_doc_status_change_date        => p_doc_status_change_date
    ,p_description                   => p_description
    ,p_duration                      => p_duration
    ,p_duration_units                => p_duration_units
    ,p_contractual_job_title         => p_contractual_job_title
    ,p_parties                       => p_parties
    ,p_start_reason                  => p_start_reason
    ,p_end_reason                    => p_end_reason
    ,p_number_of_extensions          => p_number_of_extensions
    ,p_extension_reason              => p_extension_reason
    ,p_extension_period              => p_extension_period
    ,p_extension_period_units        => p_extension_period_units
    ,p_ctr_information_category      => 'FR'
    ,p_ctr_information1	             => p_employee_type
    ,p_ctr_information2              => p_contract_category
    ,p_ctr_information3              => p_proposed_end_date
    ,p_ctr_information4		     => p_end_event
    ,p_ctr_information5              => p_person_replaced
    ,p_ctr_information6              => p_probation_period
    ,p_ctr_information7              => p_probation_period_units
    ,p_ctr_information8              => p_probation_end_date
    ,p_ctr_information9              => p_smic_adjusted_duration_days
    ,p_ctr_information10             => p_fixed_working_time
    ,p_ctr_information11             => l_amount
    ,p_ctr_information12             => p_units
    ,p_ctr_information13             => p_frequency
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
    ,p_effective_date                => p_effective_date
    );
  --
hr_utility.set_location(' Leaving:'||l_proc, 70);
end create_fr_contract;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_fr_contract >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_fr_contract
  (p_validate                       in  boolean
  ,p_contract_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_person_id                      in  number
  ,p_reference                      in  varchar2
  ,p_type                           in  varchar2
  ,p_status                         in  varchar2
  ,p_status_reason                  in  varchar2
  ,p_doc_status                     in  varchar2
  ,p_doc_status_change_date         in  date
  ,p_description                    in  varchar2
  ,p_duration                       in  number
  ,p_duration_units                 in  varchar2
  ,p_contractual_job_title          in  varchar2
  ,p_parties                        in  varchar2
  ,p_start_reason                   in  varchar2
  ,p_end_reason                     in  varchar2
  ,p_number_of_extensions           in  number
  ,p_extension_reason               in  varchar2
  ,p_extension_period               in  number
  ,p_extension_period_units         in  varchar2
  ,p_employee_type	            in  varchar2
  ,p_contract_category              in  varchar2
  ,p_proposed_end_date              in  varchar2
  ,p_end_event		            in  varchar2
  ,p_person_replaced                in  varchar2
  ,p_probation_period               in  varchar2
  ,p_probation_period_units         in  varchar2
  ,p_probation_end_date             in  varchar2
  ,p_smic_adjusted_duration_days    in  number
  ,p_fixed_working_time		    in  varchar2
  ,p_amount			    in	number
  ,p_units			    in  varchar2
  ,p_frequency			    in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is

  --
  -- Declare cursors and local variables
  --
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  l_proc                 varchar2(72) := g_package||'create_fr_contract';
  l_legislation_code     varchar2(2);
  l_amount		 varchar2(30);
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
  savepoint update_fr_contract;
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
    --
    close csr_get_business_group_id;
    --
    hr_utility.set_location(l_proc, 30);
    --
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  --
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
  -- Check that the legislation of the specified business group is 'FR'.
  --
  if l_legislation_code  <>  'FR' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','FR');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Check that valid value for l_amount.
  --
  if p_amount = hr_api.g_number then
    l_amount := hr_api.g_varchar2;
  else
    l_amount := fnd_number.number_to_canonical(p_amount);
  end if;
  --
  -- Call the contract business process
  --
  hr_contract_api.update_contract
     (
     p_validate			     => p_validate
    ,p_contract_id                   => p_contract_id
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date
    ,p_object_version_number         => p_object_version_number
    ,p_person_id                     => p_person_id
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
    ,p_doc_status                    => p_doc_status
    ,p_doc_status_change_date        => p_doc_status_change_date
    ,p_description                   => p_description
    ,p_duration                      => p_duration
    ,p_duration_units                => p_duration_units
    ,p_contractual_job_title         => p_contractual_job_title
    ,p_parties                       => p_parties
    ,p_start_reason                  => p_start_reason
    ,p_end_reason                    => p_end_reason
    ,p_number_of_extensions          => p_number_of_extensions
    ,p_extension_reason              => p_extension_reason
    ,p_extension_period              => p_extension_period
    ,p_extension_period_units        => p_extension_period_units
    ,p_ctr_information_category      => 'FR'
    ,p_ctr_information1	             => p_employee_type
    ,p_ctr_information2              => p_contract_category
    ,p_ctr_information3              => p_proposed_end_date
    ,p_ctr_information4		     => p_end_event
    ,p_ctr_information5              => p_person_replaced
    ,p_ctr_information6              => p_probation_period
    ,p_ctr_information7              => p_probation_period_units
    ,p_ctr_information8              => p_probation_end_date
    ,p_ctr_information9              => p_smic_adjusted_duration_days
    ,p_ctr_information10             => p_fixed_working_time
    ,p_ctr_information11             => l_amount
    ,p_ctr_information12             => p_units
    ,p_ctr_information13             => p_frequency
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
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
hr_utility.set_location(' Leaving:'||l_proc, 70);
--
end update_fr_contract;
end hr_fr_contract_api;

/

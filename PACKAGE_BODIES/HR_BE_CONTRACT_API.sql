--------------------------------------------------------
--  DDL for Package Body HR_BE_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BE_CONTRACT_API" as
/* $Header: hrctcbei.pkb 115.6 2002/12/09 19:48:58 hjonnala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_be_contract_api.';
--
-- ----------------------------------------------------------------------
-- |------------------------< create_be_contract >----------------------|
-- ----------------------------------------------------------------------
--
procedure create_be_contract
(p_validate                       in  boolean   default false
,p_contract_id                    out nocopy number
,p_effective_start_date           out nocopy date
,p_effective_end_date             out nocopy date
,p_object_version_number          out nocopy number
,p_person_id                      in  number
,p_reference                      in  varchar2
,p_type                           in  varchar2
,p_status                         in  varchar2
,p_status_reason                  in  varchar2  default null
,p_description                    in  varchar2  default null
,p_duration                       in  number    default null
,p_duration_units                 in  varchar2  default null
,p_contractual_job_title          in  varchar2  default null
,p_parties                        in  varchar2  default null
,p_start_reason                   in  varchar2  default null
,p_end_reason                     in  varchar2  default null
,p_number_of_extensions           in  number    default null
,p_extension_reason               in  varchar2  default null
,p_extension_period               in  number    default null
,p_extension_period_units         in  varchar2  default null
,p_contract_category	          in  varchar2  default null
,p_first_date_worked              in  varchar2  default null
,p_last_date_worked               in  varchar2  default null
,p_payment_start_date		  in  varchar2  default null
,p_payment_end_date               in  varchar2  default null
,p_notice_period                  in  varchar2  default null
,p_notice_period_units            in  varchar2  default null
,p_replacing_employee             in  varchar2  default null
,p_attribute_category             in  varchar2  default null
,p_attribute1                     in  varchar2  default null
,p_attribute2                     in  varchar2  default null
,p_attribute3                     in  varchar2  default null
,p_attribute4                     in  varchar2  default null
,p_attribute5                     in  varchar2  default null
,p_attribute6                     in  varchar2  default null
,p_attribute7                     in  varchar2  default null
,p_attribute8                     in  varchar2  default null
,p_attribute9                     in  varchar2  default null
,p_attribute10                    in  varchar2  default null
,p_attribute11                    in  varchar2  default null
,p_attribute12                    in  varchar2  default null
,p_attribute13                    in  varchar2  default null
,p_attribute14                    in  varchar2  default null
,p_attribute15                    in  varchar2  default null
,p_attribute16                    in  varchar2  default null
,p_attribute17                    in  varchar2  default null
,p_attribute18                    in  varchar2  default null
,p_attribute19                    in  varchar2  default null
,p_attribute20                    in  varchar2  default null
,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  l_proc              varchar2(72) := g_package||'create_be_contract';
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
  savepoint create_be_contract;
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
  -- Check that the legislation of the specified business group is 'BE'.
  --
  if l_legislation_code <> 'BE' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','BE');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the contract business process
  --
  hr_contract_api.create_contract
    (p_validate			     => p_validate
    ,p_contract_id                   => p_contract_id
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date
    ,p_object_version_number         => p_object_version_number
    ,p_person_id                     => p_person_id
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
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
    ,p_ctr_information_category      => 'BE'
    ,p_ctr_information1	             => p_contract_category
    ,p_ctr_information2              => p_first_date_worked
    ,p_ctr_information3              => p_last_date_worked
    ,p_ctr_information4		     => p_payment_start_date
    ,p_ctr_information5              => p_payment_end_date
    ,p_ctr_information6              => p_notice_period
    ,p_ctr_information7              => p_notice_period_units
    ,p_ctr_information8              => p_replacing_employee
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
    ,p_effective_date                => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end create_be_contract;
--
-- ----------------------------------------------------------------------
-- |------------------------< update_be_contract >----------------------|
-- ----------------------------------------------------------------------
--
procedure update_be_contract
(p_validate                       in  boolean   default false
,p_contract_id                    in  number
,p_effective_start_date           out nocopy date
,p_effective_end_date             out nocopy date
,p_object_version_number          in out nocopy number
,p_person_id                      in  number
,p_reference                      in  varchar2
,p_type                           in  varchar2
,p_status                         in  varchar2
,p_status_reason                  in  varchar2  default hr_api.g_varchar2
,p_description                    in  varchar2  default hr_api.g_varchar2
,p_duration                       in  number    default hr_api.g_number
,p_duration_units                 in  varchar2  default hr_api.g_varchar2
,p_contractual_job_title          in  varchar2  default hr_api.g_varchar2
,p_parties                        in  varchar2  default hr_api.g_varchar2
,p_start_reason                   in  varchar2  default hr_api.g_varchar2
,p_end_reason                     in  varchar2  default hr_api.g_varchar2
,p_number_of_extensions           in  number    default hr_api.g_number
,p_extension_reason               in  varchar2  default hr_api.g_varchar2
,p_extension_period               in  number    default hr_api.g_number
,p_extension_period_units         in  varchar2  default hr_api.g_varchar2
,p_contract_category	          in  varchar2  default hr_api.g_varchar2
,p_first_date_worked              in  varchar2  default hr_api.g_varchar2
,p_last_date_worked               in  varchar2  default hr_api.g_varchar2
,p_payment_start_date		  in  varchar2  default hr_api.g_varchar2
,p_payment_end_date               in  varchar2  default hr_api.g_varchar2
,p_notice_period                  in  varchar2  default hr_api.g_varchar2
,p_notice_period_units            in  varchar2  default hr_api.g_varchar2
,p_replacing_employee             in  varchar2  default hr_api.g_varchar2
,p_attribute_category             in  varchar2  default hr_api.g_varchar2
,p_attribute1                     in  varchar2  default hr_api.g_varchar2
,p_attribute2                     in  varchar2  default hr_api.g_varchar2
,p_attribute3                     in  varchar2  default hr_api.g_varchar2
,p_attribute4                     in  varchar2  default hr_api.g_varchar2
,p_attribute5                     in  varchar2  default hr_api.g_varchar2
,p_attribute6                     in  varchar2  default hr_api.g_varchar2
,p_attribute7                     in  varchar2  default hr_api.g_varchar2
,p_attribute8                     in  varchar2  default hr_api.g_varchar2
,p_attribute9                     in  varchar2  default hr_api.g_varchar2
,p_attribute10                    in  varchar2  default hr_api.g_varchar2
,p_attribute11                    in  varchar2  default hr_api.g_varchar2
,p_attribute12                    in  varchar2  default hr_api.g_varchar2
,p_attribute13                    in  varchar2  default hr_api.g_varchar2
,p_attribute14                    in  varchar2  default hr_api.g_varchar2
,p_attribute15                    in  varchar2  default hr_api.g_varchar2
,p_attribute16                    in  varchar2  default hr_api.g_varchar2
,p_attribute17                    in  varchar2  default hr_api.g_varchar2
,p_attribute18                    in  varchar2  default hr_api.g_varchar2
,p_attribute19                    in  varchar2  default hr_api.g_varchar2
,p_attribute20                    in  varchar2  default hr_api.g_varchar2
,p_effective_date                 in  date
,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id    per_contracts_f.business_group_id%TYPE;
  l_proc                 varchar2(72) := g_package||'create_be_contract';
  l_legislation_code     varchar2(2);
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
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_be_contract;
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
  -- Check that the legislation of the specified business group is 'BE'.
  --
  if l_legislation_code  <>  'BE' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','BE');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 60);
  --
  -- Call the contract business process
  --
  hr_contract_api.update_contract
    (p_validate			     => p_validate
    ,p_contract_id                   => p_contract_id
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date
    ,p_object_version_number         => p_object_version_number
    ,p_person_id                     => p_person_id
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
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
    ,p_ctr_information_category      => 'BE'
    ,p_ctr_information1	             => p_contract_category
    ,p_ctr_information2              => p_first_date_worked
    ,p_ctr_information3              => p_last_date_worked
    ,p_ctr_information4		     => p_payment_start_date
    ,p_ctr_information5              => p_payment_end_date
    ,p_ctr_information6              => p_notice_period
    ,p_ctr_information7              => p_notice_period_units
    ,p_ctr_information8              => p_replacing_employee
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
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end update_be_contract;
--
end hr_be_contract_api;

/

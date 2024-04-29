--------------------------------------------------------
--  DDL for Package Body HR_FR_PERIODS_OF_SERVICE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_PERIODS_OF_SERVICE_API" as
/* $Header: pepdsfri.pkb 115.3 2002/12/16 14:58:13 sfmorris noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_fr_periods_of_service_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_fr_pds_details >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_fr_pds_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_attribute_category            in varchar2     default hr_api.g_varchar2
  ,p_attribute1                    in varchar2     default hr_api.g_varchar2
  ,p_attribute2                    in varchar2     default hr_api.g_varchar2
  ,p_attribute3                    in varchar2     default hr_api.g_varchar2
  ,p_attribute4                    in varchar2     default hr_api.g_varchar2
  ,p_attribute5                    in varchar2     default hr_api.g_varchar2
  ,p_attribute6                    in varchar2     default hr_api.g_varchar2
  ,p_attribute7                    in varchar2     default hr_api.g_varchar2
  ,p_attribute8                    in varchar2     default hr_api.g_varchar2
  ,p_attribute9                    in varchar2     default hr_api.g_varchar2
  ,p_attribute10                   in varchar2     default hr_api.g_varchar2
  ,p_attribute11                   in varchar2     default hr_api.g_varchar2
  ,p_attribute12                   in varchar2     default hr_api.g_varchar2
  ,p_attribute13                   in varchar2     default hr_api.g_varchar2
  ,p_attribute14                   in varchar2     default hr_api.g_varchar2
  ,p_attribute15                   in varchar2     default hr_api.g_varchar2
  ,p_attribute16                   in varchar2     default hr_api.g_varchar2
  ,p_attribute17                   in varchar2     default hr_api.g_varchar2
  ,p_attribute18                   in varchar2     default hr_api.g_varchar2
  ,p_attribute19                   in varchar2     default hr_api.g_varchar2
  ,p_attribute20                   in varchar2     default hr_api.g_varchar2
  ,p_starting_reason               in varchar2     default hr_api.g_varchar2
  ,p_ending_reason                 in varchar2     default hr_api.g_varchar2
  ,p_qualification_level           in varchar2     default hr_api.g_varchar2
  ,p_type_work                     in varchar2     default hr_api.g_varchar2
  ,p_employee_status               in varchar2     default hr_api.g_varchar2
  ,p_affiliated_alsace_moselle     in varchar2     default hr_api.g_varchar2
  ,p_relationship_MD               in varchar2     default hr_api.g_varchar2
  ,p_final_payment_schedule        in varchar2     default hr_api.g_varchar2
  ,p_social_plan                   in varchar2     default hr_api.g_varchar2
 ) is
  --
  -- Declare cursors and local variables
  --
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  l_proc                 varchar2(72) := g_package||'update_fr_pds_details';
  l_legislation_code     varchar2(2);

  --
  cursor csr_get_business_group_id is
    select pds.business_group_id
    from per_periods_of_service pds
    where pds.period_of_service_id = p_period_of_service_id;
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
  savepoint create_contract;
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
  -- Call the contract business process
  --
   hr_periods_of_service_api.update_pds_details
    ( p_validate 		      => p_validate
     ,p_effective_date                => p_effective_date
     ,p_period_of_service_id          => p_period_of_service_id
     ,p_termination_accepted_person   => p_termination_accepted_person
     ,p_accepted_termination_date     => p_accepted_termination_date
     ,p_comments                      => p_comments
     ,p_leaving_reason                => p_leaving_reason
     ,p_notified_termination_date     => p_notified_termination_date
     ,p_projected_termination_date    => p_projected_termination_date
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
     ,p_pds_information_category      => 'FR'
     ,p_pds_information1              => p_starting_reason
     ,p_pds_information2              => p_ending_reason
     ,p_pds_information3              => p_qualification_level
     ,p_pds_information4              => p_type_work
     ,p_pds_information5              => p_employee_status
     ,p_pds_information6              => p_affiliated_alsace_moselle
     ,p_pds_information7              => p_relationship_MD
     ,p_pds_information11             => p_final_payment_schedule
     ,p_pds_information12             => p_social_plan
     ,p_object_version_number         => p_object_version_number
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
end update_fr_pds_details;
--
end hr_fr_periods_of_service_api;

/

--------------------------------------------------------
--  DDL for Package Body HR_CONTRACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTRACT_API" as
/* $Header: hrctcapi.pkb 120.0.12010000.2 2009/07/21 09:22:21 sgundoju ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_contract_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_contract >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_contract
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
  ,p_doc_status                in  varchar2  default null
  ,p_doc_status_change_date    in  date      default null
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
  ,p_ctr_information_category       in  varchar2  default null
  ,p_ctr_information1               in  varchar2  default null
  ,p_ctr_information2               in  varchar2  default null
  ,p_ctr_information3               in  varchar2  default null
  ,p_ctr_information4               in  varchar2  default null
  ,p_ctr_information5               in  varchar2  default null
  ,p_ctr_information6               in  varchar2  default null
  ,p_ctr_information7               in  varchar2  default null
  ,p_ctr_information8               in  varchar2  default null
  ,p_ctr_information9               in  varchar2  default null
  ,p_ctr_information10              in  varchar2  default null
  ,p_ctr_information11              in  varchar2  default null
  ,p_ctr_information12              in  varchar2  default null
  ,p_ctr_information13              in  varchar2  default null
  ,p_ctr_information14              in  varchar2  default null
  ,p_ctr_information15              in  varchar2  default null
  ,p_ctr_information16              in  varchar2  default null
  ,p_ctr_information17              in  varchar2  default null
  ,p_ctr_information18              in  varchar2  default null
  ,p_ctr_information19              in  varchar2  default null
  ,p_ctr_information20              in  varchar2  default null
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
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_contract_id per_contracts_f.contract_id%TYPE;
  l_effective_start_date per_contracts_f.effective_start_date%TYPE;
  l_effective_end_date per_contracts_f.effective_end_date%TYPE;
  l_effective_date date;
  l_proc varchar2(72) := g_package||'create_contract';
  l_object_version_number per_contracts_f.object_version_number%TYPE;
  l_business_group_id per_contracts_f.business_group_id%TYPE;
  --
  cursor csr_get_derived_details is
    select per.business_group_id
    from per_all_people_f per
    where per.person_id = p_person_id
    and   p_effective_date between per.effective_start_date
                               and per.effective_end_date;
begin
  --
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
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_business_group_id;
  --
  if csr_get_derived_details%NOTFOUND then
    --
    close csr_get_derived_details;
    --
    hr_utility.set_location(l_proc, 30);
    --
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
  hr_utility.set_location(l_proc, 40);
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_contract
    --
    hr_contract_bk1.create_contract_b
      (
       p_business_group_id              =>  l_business_group_id
      ,p_person_id                      =>  p_person_id
      ,p_reference                      =>  p_reference
      ,p_type                           =>  p_type
      ,p_status                         =>  p_status
      ,p_status_reason                  =>  p_status_reason
      ,p_doc_status                =>  p_doc_status
      ,p_doc_status_change_date    =>  p_doc_status_change_date
      ,p_description                    =>  p_description
      ,p_duration                       =>  p_duration
      ,p_duration_units                 =>  p_duration_units
      ,p_contractual_job_title          =>  p_contractual_job_title
      ,p_parties                        =>  p_parties
      ,p_start_reason                   =>  p_start_reason
      ,p_end_reason                     =>  p_end_reason
      ,p_number_of_extensions           =>  p_number_of_extensions
      ,p_extension_reason               =>  p_extension_reason
      ,p_extension_period               =>  p_extension_period
      ,p_extension_period_units         =>  p_extension_period_units
      ,p_ctr_information_category       =>  p_ctr_information_category
      ,p_ctr_information1               =>  p_ctr_information1
      ,p_ctr_information2               =>  p_ctr_information2
      ,p_ctr_information3               =>  p_ctr_information3
      ,p_ctr_information4               =>  p_ctr_information4
      ,p_ctr_information5               =>  p_ctr_information5
      ,p_ctr_information6               =>  p_ctr_information6
      ,p_ctr_information7               =>  p_ctr_information7
      ,p_ctr_information8               =>  p_ctr_information8
      ,p_ctr_information9               =>  p_ctr_information9
      ,p_ctr_information10              =>  p_ctr_information10
      ,p_ctr_information11              =>  p_ctr_information11
      ,p_ctr_information12              =>  p_ctr_information12
      ,p_ctr_information13              =>  p_ctr_information13
      ,p_ctr_information14              =>  p_ctr_information14
      ,p_ctr_information15              =>  p_ctr_information15
      ,p_ctr_information16              =>  p_ctr_information16
      ,p_ctr_information17              =>  p_ctr_information17
      ,p_ctr_information18              =>  p_ctr_information18
      ,p_ctr_information19              =>  p_ctr_information19
      ,p_ctr_information20              =>  p_ctr_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_contract'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_contract
    --
    hr_utility.set_location(l_proc, 30);
    --
      --
  -- Validation in addition to Table Handlers
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => l_effective_date
     );
  --
  hr_utility.set_location(l_proc, 40);
  --
  end;
  --
  per_ctc_ins.ins
    (
     p_contract_id                   => l_contract_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => l_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_person_id                     => p_person_id
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
    ,p_doc_status               => p_doc_status
    ,p_doc_status_change_date   => p_doc_status_change_date
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
    ,p_ctr_information_category      => p_ctr_information_category
    ,p_ctr_information1              => p_ctr_information1
    ,p_ctr_information2              => p_ctr_information2
    ,p_ctr_information3              => p_ctr_information3
    ,p_ctr_information4              => p_ctr_information4
    ,p_ctr_information5              => p_ctr_information5
    ,p_ctr_information6              => p_ctr_information6
    ,p_ctr_information7              => p_ctr_information7
    ,p_ctr_information8              => p_ctr_information8
    ,p_ctr_information9              => p_ctr_information9
    ,p_ctr_information10             => p_ctr_information10
    ,p_ctr_information11             => p_ctr_information11
    ,p_ctr_information12             => p_ctr_information12
    ,p_ctr_information13             => p_ctr_information13
    ,p_ctr_information14             => p_ctr_information14
    ,p_ctr_information15             => p_ctr_information15
    ,p_ctr_information16             => p_ctr_information16
    ,p_ctr_information17             => p_ctr_information17
    ,p_ctr_information18             => p_ctr_information18
    ,p_ctr_information19             => p_ctr_information19
    ,p_ctr_information20             => p_ctr_information20
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
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_contract
    --
    hr_contract_bk1.create_contract_a
      (
       p_contract_id                    =>  l_contract_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  l_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_person_id                      =>  p_person_id
      ,p_reference                      =>  p_reference
      ,p_type                           =>  p_type
      ,p_status                         =>  p_status
      ,p_status_reason                  =>  p_status_reason
      ,p_doc_status                =>  p_doc_status
      ,p_doc_status_change_date    =>  p_doc_status_change_date
      ,p_description                    =>  p_description
      ,p_duration                       =>  p_duration
      ,p_duration_units                 =>  p_duration_units
      ,p_contractual_job_title          =>  p_contractual_job_title
      ,p_parties                        =>  p_parties
      ,p_start_reason                   =>  p_start_reason
      ,p_end_reason                     =>  p_end_reason
      ,p_number_of_extensions           =>  p_number_of_extensions
      ,p_extension_reason               =>  p_extension_reason
      ,p_extension_period               =>  p_extension_period
      ,p_extension_period_units         =>  p_extension_period_units
      ,p_ctr_information_category       =>  p_ctr_information_category
      ,p_ctr_information1               =>  p_ctr_information1
      ,p_ctr_information2               =>  p_ctr_information2
      ,p_ctr_information3               =>  p_ctr_information3
      ,p_ctr_information4               =>  p_ctr_information4
      ,p_ctr_information5               =>  p_ctr_information5
      ,p_ctr_information6               =>  p_ctr_information6
      ,p_ctr_information7               =>  p_ctr_information7
      ,p_ctr_information8               =>  p_ctr_information8
      ,p_ctr_information9               =>  p_ctr_information9
      ,p_ctr_information10              =>  p_ctr_information10
      ,p_ctr_information11              =>  p_ctr_information11
      ,p_ctr_information12              =>  p_ctr_information12
      ,p_ctr_information13              =>  p_ctr_information13
      ,p_ctr_information14              =>  p_ctr_information14
      ,p_ctr_information15              =>  p_ctr_information15
      ,p_ctr_information16              =>  p_ctr_information16
      ,p_ctr_information17              =>  p_ctr_information17
      ,p_ctr_information18              =>  p_ctr_information18
      ,p_ctr_information19              =>  p_ctr_information19
      ,p_ctr_information20              =>  p_ctr_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_contract'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_contract
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_contract_id := l_contract_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_contract;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_contract_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_contract;
    -- Set OUT parameters to null
    p_contract_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_contract;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_contract >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_contract
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
  ,p_doc_status                in  varchar2  default hr_api.g_varchar2
  ,p_doc_status_change_date    in  date      default hr_api.g_date
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
  ,p_ctr_information_category       in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information1               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information2               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information3               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information4               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information5               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information6               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information7               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information8               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information9               in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information10              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information11              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information12              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information13              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information14              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information15              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information16              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information17              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information18              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information19              in  varchar2  default hr_api.g_varchar2
  ,p_ctr_information20              in  varchar2  default hr_api.g_varchar2
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
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_contract';
  l_object_version_number per_contracts_f.object_version_number%TYPE;
  l_effective_start_date per_contracts_f.effective_start_date%TYPE;
  l_effective_end_date per_contracts_f.effective_end_date%TYPE;
  l_business_group_id per_contracts_f.business_group_id%TYPE;

  l_temp_ovn   number := p_object_version_number;
  --
  cursor csr_get_derived_details is
    select per.business_group_id
    from per_all_people_f per
    where per.person_id = p_person_id
    and   p_effective_date between per.effective_start_date
                               and per.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_contract;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  -- Get person details.
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_business_group_id;
  --
  if csr_get_derived_details%NOTFOUND then
    close csr_get_derived_details;
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_message(801,'HR_7432_ASG_INVALID_PERSON');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
  hr_utility.set_location(l_proc, 40);
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_contract
    --
    hr_contract_bk2.update_contract_b
      (
       p_contract_id                    =>  p_contract_id
      ,p_business_group_id              =>  l_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_person_id                      =>  p_person_id
      ,p_reference                      =>  p_reference
      ,p_type                           =>  p_type
      ,p_status                         =>  p_status
      ,p_status_reason                  =>  p_status_reason
      ,p_doc_status                =>  p_doc_status
      ,p_doc_status_change_date    =>  p_doc_status_change_date
      ,p_description                    =>  p_description
      ,p_duration                       =>  p_duration
      ,p_duration_units                 =>  p_duration_units
      ,p_contractual_job_title          =>  p_contractual_job_title
      ,p_parties                        =>  p_parties
      ,p_start_reason                   =>  p_start_reason
      ,p_end_reason                     =>  p_end_reason
      ,p_number_of_extensions           =>  p_number_of_extensions
      ,p_extension_reason               =>  p_extension_reason
      ,p_extension_period               =>  p_extension_period
      ,p_extension_period_units         =>  p_extension_period_units
      ,p_ctr_information_category       =>  p_ctr_information_category
      ,p_ctr_information1               =>  p_ctr_information1
      ,p_ctr_information2               =>  p_ctr_information2
      ,p_ctr_information3               =>  p_ctr_information3
      ,p_ctr_information4               =>  p_ctr_information4
      ,p_ctr_information5               =>  p_ctr_information5
      ,p_ctr_information6               =>  p_ctr_information6
      ,p_ctr_information7               =>  p_ctr_information7
      ,p_ctr_information8               =>  p_ctr_information8
      ,p_ctr_information9               =>  p_ctr_information9
      ,p_ctr_information10              =>  p_ctr_information10
      ,p_ctr_information11              =>  p_ctr_information11
      ,p_ctr_information12              =>  p_ctr_information12
      ,p_ctr_information13              =>  p_ctr_information13
      ,p_ctr_information14              =>  p_ctr_information14
      ,p_ctr_information15              =>  p_ctr_information15
      ,p_ctr_information16              =>  p_ctr_information16
      ,p_ctr_information17              =>  p_ctr_information17
      ,p_ctr_information18              =>  p_ctr_information18
      ,p_ctr_information19              =>  p_ctr_information19
      ,p_ctr_information20              =>  p_ctr_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_contract'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_contract
    --
  end;
  --
  -- Validation in addition to Table Handlers
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => p_effective_date
     );
  --
  per_ctc_upd.upd
    (
     p_contract_id                   => p_contract_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_reference                     => p_reference
    ,p_type                          => p_type
    ,p_status                        => p_status
    ,p_status_reason                 => p_status_reason
    ,p_doc_status               => p_doc_status
    ,p_doc_status_change_date   => p_doc_status_change_date
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
    ,p_ctr_information_category      => p_ctr_information_category
    ,p_ctr_information1              => p_ctr_information1
    ,p_ctr_information2              => p_ctr_information2
    ,p_ctr_information3              => p_ctr_information3
    ,p_ctr_information4              => p_ctr_information4
    ,p_ctr_information5              => p_ctr_information5
    ,p_ctr_information6              => p_ctr_information6
    ,p_ctr_information7              => p_ctr_information7
    ,p_ctr_information8              => p_ctr_information8
    ,p_ctr_information9              => p_ctr_information9
    ,p_ctr_information10             => p_ctr_information10
    ,p_ctr_information11             => p_ctr_information11
    ,p_ctr_information12             => p_ctr_information12
    ,p_ctr_information13             => p_ctr_information13
    ,p_ctr_information14             => p_ctr_information14
    ,p_ctr_information15             => p_ctr_information15
    ,p_ctr_information16             => p_ctr_information16
    ,p_ctr_information17             => p_ctr_information17
    ,p_ctr_information18             => p_ctr_information18
    ,p_ctr_information19             => p_ctr_information19
    ,p_ctr_information20             => p_ctr_information20
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
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_contract
    --
    hr_contract_bk2.update_contract_a
      (
       p_contract_id                    =>  p_contract_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  l_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_person_id                      =>  p_person_id
      ,p_reference                      =>  p_reference
      ,p_type                           =>  p_type
      ,p_status                         =>  p_status
      ,p_status_reason                  =>  p_status_reason
      ,p_doc_status                =>  p_doc_status
      ,p_doc_status_change_date    =>  p_doc_status_change_date
      ,p_description                    =>  p_description
      ,p_duration                       =>  p_duration
      ,p_duration_units                 =>  p_duration_units
      ,p_contractual_job_title          =>  p_contractual_job_title
      ,p_parties                        =>  p_parties
      ,p_start_reason                   =>  p_start_reason
      ,p_end_reason                     =>  p_end_reason
      ,p_number_of_extensions           =>  p_number_of_extensions
      ,p_extension_reason               =>  p_extension_reason
      ,p_extension_period               =>  p_extension_period
      ,p_extension_period_units         =>  p_extension_period_units
      ,p_ctr_information_category       =>  p_ctr_information_category
      ,p_ctr_information1               =>  p_ctr_information1
      ,p_ctr_information2               =>  p_ctr_information2
      ,p_ctr_information3               =>  p_ctr_information3
      ,p_ctr_information4               =>  p_ctr_information4
      ,p_ctr_information5               =>  p_ctr_information5
      ,p_ctr_information6               =>  p_ctr_information6
      ,p_ctr_information7               =>  p_ctr_information7
      ,p_ctr_information8               =>  p_ctr_information8
      ,p_ctr_information9               =>  p_ctr_information9
      ,p_ctr_information10              =>  p_ctr_information10
      ,p_ctr_information11              =>  p_ctr_information11
      ,p_ctr_information12              =>  p_ctr_information12
      ,p_ctr_information13              =>  p_ctr_information13
      ,p_ctr_information14              =>  p_ctr_information14
      ,p_ctr_information15              =>  p_ctr_information15
      ,p_ctr_information16              =>  p_ctr_information16
      ,p_ctr_information17              =>  p_ctr_information17
      ,p_ctr_information18              =>  p_ctr_information18
      ,p_ctr_information19              =>  p_ctr_information19
      ,p_ctr_information20              =>  p_ctr_information20
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_contract'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_contract
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_contract;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset IN OUT and set OUT parameters.
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := l_temp_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_contract;
        -- Reset IN OUT and set OUT parameters.
        p_effective_start_date   := null;
        p_effective_end_date     := null;
        p_object_version_number  := l_temp_ovn;
    raise;
    --
end update_contract;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_contract >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contract
  (p_validate                       in  boolean  default false
  ,p_contract_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_contract';
  l_object_version_number per_contracts_f.object_version_number%TYPE;
  l_effective_start_date per_contracts_f.effective_start_date%TYPE;
  l_effective_end_date per_contracts_f.effective_end_date%TYPE;

  l_temp_ovn   number := p_object_version_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_contract;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  hr_utility.set_location(l_proc, 30);
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_contract
    --
    hr_contract_bk3.delete_contract_b
      (
       p_contract_id                    =>  p_contract_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_contract'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_contract
    --
  end;
  --
  per_ctc_del.del
    (
     p_contract_id                   => p_contract_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_contract
    --
    hr_contract_bk3.delete_contract_a
      (
       p_contract_id                    =>  p_contract_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CONTRACT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_contract
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_contract;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_contract;
        -- Reset IN OUT and set OUT parameters.
        p_effective_start_date   := null;
        p_effective_end_date     := null;
        p_object_version_number  := l_temp_ovn;
    raise;
    --
end delete_contract;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_contract_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_ctc_shd.lck
    (
      p_contract_id                => p_contract_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< maintain_contracts >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure maintain_contracts
  (
  p_person_id      number,
  p_new_start_date date,
  p_old_start_date date
  ) is
  --
  -- This procedure is called to mantain contracts when person's start-date changes
  --
  cursor csr_ctr_before IS
  SELECT contract_id, effective_start_date, effective_end_date, object_version_number
    FROM per_contracts_f pcf
    WHERE pcf.person_id            = p_person_id
    AND   pcf.effective_start_date < p_new_start_date
    ORDER BY 1,2;  -- 'Order by' Added for bug#8670853
  --
  -- This cursor will bring back all the contracts that
  -- start before the new start-date
  -- (used when the start-date is moved forward)
  --
  cursor csr_asg_ctr IS
    SELECT assignment_id, contract_id
       FROM per_all_assignments_f paf
       WHERE paf.person_id = p_person_id
       AND   p_old_start_date BETWEEN paf.effective_start_date AND
                                      paf.effective_end_date
       AND   paf.contract_id IS NOT NULL;
  --
  -- This cursor will bring back all the assignments which
  -- exist as of the old start-date
  -- and which reference a contract
  --
  cursor csr_ctr_min (p_contract_id in number) IS
    SELECT min(effective_start_date)
      FROM per_contracts_f
      WHERE contract_id = p_contract_id;
  --
  cursor csr_ctr_ovn (p_contract_id in number, p_start_date in date) IS
    SELECT object_version_number
      FROM per_contracts_f
      WHERE contract_id = p_contract_id and
	    effective_start_date = p_start_date;
  --
  -- cursor for finding orphaned contracts
  --
  cursor csr_ctr_orphaned (p_person_id in number) is
     select contract_id, effective_start_date, object_version_number
       from per_contracts_f
       where person_id = p_person_id
         and not exists(select 1 from per_all_people_f
                          where person_id = p_person_id);
  --
  l_contract_id           per_contracts_f.contract_id%TYPE;
  l_assignment_id         per_all_assignments_f.assignment_id%TYPE;
  l_start_date            per_contracts_f.effective_start_date%TYPE;
  l_end_date              per_contracts_f.effective_end_date%TYPE;
  l_effective_start_date  per_contracts_f.effective_start_date%TYPE;
  l_object_version_number per_contracts_f.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'maintain_contracts';
  --Added below variables for bug#8670853
  l_contract_start_date  per_contracts_f.effective_start_date%TYPE;
  l_temp varchar2(1);
  l_prev_con_num per_contracts_f.contract_id%TYPE;
  --
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   l_prev_con_num := 0; -- Fix for bug#8670853
   --
   IF p_new_start_date > p_old_start_date THEN
      --
      -- The start-date is moving forward in time :
      -- either update start-date for related contracts
      -- or remove contracts (when completely out of synch)
      --
      OPEN csr_ctr_before;
      LOOP
	 FETCH csr_ctr_before INTO l_contract_id, l_start_date, l_end_date,
				 l_object_version_number;
	 EXIT WHEN csr_ctr_before%NOTFOUND;
	   --
	   -- Fix for bug#8670853
	   -- The below cursor is used to the find the start date of the current contract
	       OPEN csr_ctr_min(l_contract_id);
	       FETCH csr_ctr_min into l_contract_start_date;
	       IF l_contract_start_date >= p_old_start_date then
	          l_temp := 'Y';
	       ELSE
	          l_temp := 'N';
	       END IF;
         CLOSE csr_ctr_min;
     -- l_temp holds the flag, which is used while updating/deleting the contract records
         IF l_end_date < p_new_start_date OR l_prev_con_num = l_contract_id THEN
            IF l_temp = 'Y' OR l_prev_con_num = l_contract_id THEN -- Fix for bug#8670853
               l_prev_con_num := l_contract_id;
	   --
	   -- Remove the contract as it now ends before the person exists
	   --
	           hr_utility.set_location('Entering:'||l_proc, 10);
	   --
	               per_ctc_del.delete_row
	                (l_contract_id,
	                 l_start_date,
	                 l_object_version_number);
            END IF;
         ELSE
	   --
	   -- Row spanning the new start-date : move its start-date forward
	   --
	   hr_utility.set_location('Entering:'||l_proc, 20);
	   --
     -- Added the below condition for bug#8670853
     IF l_temp = 'Y' THEN
	     per_ctc_upd.update_effective_start_date
	     (l_contract_id,
	      l_start_date,
	      p_new_start_date,
	      l_object_version_number);
     END IF;
           --
         END IF;
      END LOOP;
      CLOSE csr_ctr_before;
      --
   ELSE
      --
      -- The start-date is moving backward in time :
      -- move contracts start-date (if any moving assignments).
      --
      OPEN csr_asg_ctr;
      --
      LOOP
	 FETCH csr_asg_ctr INTO l_assignment_id, l_contract_id;
	 EXIT WHEN csr_asg_ctr%NOTFOUND;
	 --
         OPEN csr_ctr_min (l_contract_id);
	 --
	 LOOP
	   --
	   FETCH csr_ctr_min INTO l_start_date;
	   EXIT WHEN csr_ctr_min%NOTFOUND;
	   --
	   OPEN csr_ctr_ovn (l_contract_id, l_start_date);
           FETCH csr_ctr_ovn INTO  l_object_version_number;
	   CLOSE csr_ctr_ovn;
	   --
	   IF l_start_date > p_new_start_date THEN
	     --
	     -- The earliest assigned contract does not exist
	     -- as of the new start-date : move it backwards.
	     --
	     hr_utility.set_location('Entering:'||l_proc, 30);
	     --
	     per_ctc_upd.update_effective_start_date
              (l_contract_id,
               l_start_date,
               p_new_start_date,
	       l_object_version_number);
             --
	 END IF;
	 --
        END LOOP;
	CLOSE csr_ctr_min;
	--
      END LOOP;
      --
      CLOSE csr_asg_ctr;
      --
   END IF;
  --
  -- delete all contracts orphaned as a result of purging a person
  --
  OPEN csr_ctr_orphaned(p_person_id);
  loop
  FETCH csr_ctr_orphaned into l_contract_id, l_effective_start_date,
			      l_object_version_number;
  EXIT WHEN csr_ctr_orphaned%NOTFOUND;
  --
  delete_contract
    (
     p_contract_id           => l_contract_id,
     p_effective_start_date  => l_start_date,
     p_effective_end_date    => l_end_date,
     p_object_version_number => l_object_version_number,
     p_effective_date        => l_effective_start_date,
     p_datetrack_mode        => 'ZAP'
    );
  end loop;
  --
  CLOSE csr_ctr_orphaned;
  --
END maintain_contracts;
--
function get_pps_start_date
  (p_person_id in number,
   p_active_date in date) return date is

  cursor csr_date is select  pps.date_start
                 from    per_periods_of_service pps
                 where   p_person_id=pps.person_id
                 and     p_active_date between pps.date_start
		 and    		   nvl(pps.actual_termination_date, hr_general.end_of_time);

  -- set up the variables

  l_start_date per_periods_of_service.date_start%type;

begin

  open csr_date;
  fetch csr_date into l_start_date;
  close csr_date;

  return(l_start_date);

end get_pps_start_date;
--
function get_pps_end_date
  (p_person_id in number,
   p_active_date in date) return date is

  cursor csr_date is select  pps.actual_termination_date
                 from    per_periods_of_service pps
                 where   p_person_id=pps.person_id
                 and     p_active_date between pps.date_start
		 and    		    pps.actual_termination_date;

  -- set up the variables

  l_end_date per_periods_of_service.actual_termination_date%type;

begin

  open csr_date;
  fetch csr_date into l_end_date;
  close csr_date;

  return(l_end_date);

end get_pps_end_date;
--
function get_meaning
   (p_lookup_code in varchar2,
    p_lookup_type in varchar2) return varchar2 is

  cursor csr_meaning is select  meaning
                        from    hr_lookups hrl
                        where   p_lookup_code = hrl.lookup_code
                        and     p_lookup_type = hrl.lookup_type
		        and     hrl.application_id = 800;

  -- set up the variables

  l_meaning hr_lookups.meaning%type;

begin

  open csr_meaning;
  fetch csr_meaning into l_meaning;
  close csr_meaning;

  return(l_meaning);

end get_meaning;
--
function get_active_start_date
   (p_contract_id in number,
    p_effective_date in date,
    p_status in varchar2) return date is

  cursor csr_date_active is select  min(pcf1.effective_start_date)
                        from    per_contracts_f pcf1
                        where   p_contract_id=pcf1.contract_id
                        and     p_effective_date >= pcf1.effective_start_date
		        and     pcf1.status like 'A-%';

  cursor csr_date_other  is select  max(pcf1.effective_end_date) + 1
                        from    per_contracts_f pcf1
                        where   p_contract_id=pcf1.contract_id
                        and     p_effective_date >= pcf1.effective_end_date
		        and     pcf1.status  not like 'A-%';


  cursor csr_prev_date_active is select  max(pcf1.effective_start_date)
                        from    per_contracts_f pcf1
                        where   p_contract_id=pcf1.contract_id
                        and     p_effective_date > pcf1.effective_start_date
		        and     pcf1.status like 'A-%';

  -- set up the variables

  l_other_start_date per_contracts_f.EFFECTIVE_END_DATE%type;
  l_active_start_date per_contracts_f.EFFECTIVE_START_DATE%type;
  l_prev_start_date per_contracts_f.EFFECTIVE_START_DATE%type;


begin

if p_status like 'A-%' then

  open csr_date_active;
  fetch csr_date_active into l_active_start_date;
  close csr_date_active;

  open csr_date_other;
  fetch csr_date_other into l_other_start_date;
  close csr_date_other;

  if l_other_start_date is null then
      l_other_start_date := hr_general.start_of_time;
  end if;

  if (l_active_start_date > l_other_start_date) then
    return(l_active_start_date);
  else
    return(l_other_start_date);
  end if;

else

  open csr_prev_date_active;
  fetch csr_prev_date_active into l_prev_start_date;
  close csr_prev_date_active;
  return(l_prev_start_date);
end if;

end get_active_start_date;
--
function get_active_end_date (p_contract_id in number,
			  p_effective_date in date,
			  p_status in varchar2) return date is

  cursor csr_date_active is select  max(pcf1.effective_end_date)
                        from    per_contracts_f pcf1
                        where   p_contract_id = pcf1.contract_id
                        and     p_effective_date <= pcf1.effective_end_date
		        and     pcf1.status like 'A-%';

  cursor csr_date_other is select  min(pcf1.effective_start_date) - 1
                        from    per_contracts_f pcf1
                        where   p_contract_id=pcf1.contract_id
                        and     p_effective_date <=pcf1.effective_start_date
		        and     pcf1.status not like 'A-%';

  cursor csr_prev_date_active is select  max(pcf1.effective_end_date)
                        from    per_contracts_f pcf1
                        where   p_contract_id = pcf1.contract_id
                        and     p_effective_date > pcf1.effective_end_date
		        and     pcf1.status like 'A-%';


  -- set up the variables

  l_other_end_date per_contracts_f.EFFECTIVE_END_DATE%type;
  l_active_end_date per_contracts_f.EFFECTIVE_START_DATE%type;
  l_prev_end_date per_contracts_f.EFFECTIVE_START_DATE%type;


begin

if p_status like 'A-%' then

  open csr_date_active;
  fetch csr_date_active into l_active_end_date;
  close csr_date_active;

  open csr_date_other;
  fetch csr_date_other into l_other_end_date;
  close csr_date_other;

  if l_other_end_date is null then
      l_other_end_date := hr_general.end_of_time;
  end if;

  if  (l_active_end_date <= l_other_end_date)  then

     if (l_active_end_date = hr_general.end_of_time) then
         l_active_end_date := null;
      end if;
    return(l_active_end_date);
  else
   return(l_other_end_date);
  end if;

else
  open csr_prev_date_active;
  fetch csr_prev_date_active into l_prev_end_date;
  close csr_prev_date_active;
  return(l_prev_end_date);
end if;

end get_active_end_date;
--
end hr_contract_api;

/

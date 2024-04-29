--------------------------------------------------------
--  DDL for Package Body PQH_ASSIGN_ACCOMMODATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ASSIGN_ACCOMMODATIONS_API" as
/* $Header: pqasaapi.pkb 115.2 2002/11/26 22:34:16 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_ASSIGN_ACCOMMODATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------<create_assign_accommodation>-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_assign_accommodation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_assignment_id                  in     number
  ,p_accommodation_given            in     varchar2
  ,p_temporary_assignment           in     varchar2 default null
  ,p_accommodation_id               in     number   default null
  ,p_acceptance_date                in     date     default null
  ,p_moving_date                    in     date     default null
  ,p_refusal_date                   in     date     default null
  ,p_comments                       in     varchar2 default null
  ,p_indemnity_entitlement          in     varchar2 default null
  ,p_indemnity_amount               in     number   default null
  ,p_type_of_payment                in     varchar2 default null
  ,p_information_category           in     varchar2 default null
  ,p_information1                   in     varchar2 default null
  ,p_information2                   in     varchar2 default null
  ,p_information3                   in     varchar2 default null
  ,p_information4                   in     varchar2 default null
  ,p_information5                   in     varchar2 default null
  ,p_information6                   in     varchar2 default null
  ,p_information7                   in     varchar2 default null
  ,p_information8                   in     varchar2 default null
  ,p_information9                   in     varchar2 default null
  ,p_information10                  in     varchar2 default null
  ,p_information11                  in     varchar2 default null
  ,p_information12                  in     varchar2 default null
  ,p_information13                  in     varchar2 default null
  ,p_information14                  in     varchar2 default null
  ,p_information15                  in     varchar2 default null
  ,p_information16                  in     varchar2 default null
  ,p_information17                  in     varchar2 default null
  ,p_information18                  in     varchar2 default null
  ,p_information19                  in     varchar2 default null
  ,p_information20                  in     varchar2 default null
  ,p_information21                  in     varchar2 default null
  ,p_information22                  in     varchar2 default null
  ,p_information23                  in     varchar2 default null
  ,p_information24                  in     varchar2 default null
  ,p_information25                  in     varchar2 default null
  ,p_information26                  in     varchar2 default null
  ,p_information27                  in     varchar2 default null
  ,p_information28                  in     varchar2 default null
  ,p_information29                  in     varchar2 default null
  ,p_information30                  in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_reason_for_no_acco             in     varchar2 default null
  ,p_indemnity_currency             in     varchar2 default null
  ,p_assignment_acco_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'CREATE_ASSIGN_ACCOMMODATION';

  l_assignment_acco_id     pqh_assign_accommodations_f.assignment_acco_id%TYPE;
  l_object_version_number  pqh_assign_accommodations_f.object_version_number%TYPE;
  l_effective_start_date   pqh_assign_accommodations_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_assign_accommodations_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_ASSIGN_ACCOMMODATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_ASSIGN_ACCOMMODATIONS_BK1.create_assign_accommodation_b
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_accommodation_given           => p_accommodation_given
      ,p_temporary_assignment          => p_temporary_assignment
      ,p_accommodation_id              => p_accommodation_id
      ,p_acceptance_date               => p_acceptance_date
      ,p_moving_date                   => p_moving_date
      ,p_refusal_date                  => p_refusal_date
      ,p_comments                      => p_comments
      ,p_indemnity_entitlement         => p_indemnity_entitlement
      ,p_indemnity_amount              => p_indemnity_amount
      ,p_type_of_payment               => p_type_of_payment
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_reason_for_no_acco            => p_reason_for_no_acco
      ,p_indemnity_currency            => p_indemnity_currency
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ASSIGN_ACCOMMODATION'
        ,p_hook_type   => 'BP'
        );
  end create_assign_accommodation;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_asa_ins.ins
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_accommodation_given           => p_accommodation_given
      ,p_temporary_assignment          => p_temporary_assignment
      ,p_accommodation_id              => p_accommodation_id
      ,p_acceptance_date               => p_acceptance_date
      ,p_moving_date                   => p_moving_date
      ,p_refusal_date                  => p_refusal_date
      ,p_comments                      => p_comments
      ,p_indemnity_entitlement         => p_indemnity_entitlement
      ,p_indemnity_amount              => p_indemnity_amount
      ,p_type_of_payment               => p_type_of_payment
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_reason_for_no_acco            => p_reason_for_no_acco
      ,p_indemnity_currency            => p_indemnity_currency
      ,p_assignment_acco_id            => l_assignment_acco_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_ASSIGN_ACCOMMODATIONS_BK1.create_assign_accommodation_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_accommodation_given           => p_accommodation_given
      ,p_temporary_assignment          => p_temporary_assignment
      ,p_accommodation_id              => p_accommodation_id
      ,p_acceptance_date               => p_acceptance_date
      ,p_moving_date                   => p_moving_date
      ,p_refusal_date                  => p_refusal_date
      ,p_comments                      => p_comments
      ,p_indemnity_entitlement         => p_indemnity_entitlement
      ,p_indemnity_amount              => p_indemnity_amount
      ,p_type_of_payment               => p_type_of_payment
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_reason_for_no_acco            => p_reason_for_no_acco
      ,p_indemnity_currency            => p_indemnity_currency
      ,p_assignment_acco_id            => l_assignment_acco_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ASSIGN_ACCOMMODATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_assignment_acco_id     := l_assignment_acco_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ASSIGN_ACCOMMODATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_acco_id     := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    p_assignment_acco_id     := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_ASSIGN_ACCOMMODATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_assign_accommodation;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------<update_assign_accommodation>----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_assign_accommodation
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_assignment_acco_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_accommodation_given          in     varchar2  default hr_api.g_varchar2
  ,p_temporary_assignment         in     varchar2  default hr_api.g_varchar2
  ,p_accommodation_id             in     number    default hr_api.g_number
  ,p_acceptance_date              in     date      default hr_api.g_date
  ,p_moving_date                  in     date      default hr_api.g_date
  ,p_refusal_date                 in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_entitlement        in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_amount             in     number    default hr_api.g_number
  ,p_type_of_payment              in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_no_acco           in     varchar2  default hr_api.g_varchar2
  ,p_indemnity_currency           in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'UPDATE_ASSIGN_ACCOMMODATION';

  l_effective_start_date   pqh_assign_accommodations_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_assign_accommodations_f.effective_end_date%TYPE;
  l_object_version_number number := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ASSIGN_ACCOMMODATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_ASSIGN_ACCOMMODATIONS_BK2.update_assign_accommodation_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_assignment_acco_id            => p_assignment_acco_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_accommodation_given           => p_accommodation_given
      ,p_temporary_assignment          => p_temporary_assignment
      ,p_accommodation_id              => p_accommodation_id
      ,p_acceptance_date               => p_acceptance_date
      ,p_moving_date                   => p_moving_date
      ,p_refusal_date                  => p_refusal_date
      ,p_comments                      => p_comments
      ,p_indemnity_entitlement         => p_indemnity_entitlement
      ,p_indemnity_amount              => p_indemnity_amount
      ,p_type_of_payment               => p_type_of_payment
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_reason_for_no_acco            => p_reason_for_no_acco
      ,p_indemnity_currency            => p_indemnity_currency
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ASSIGN_ACCOMMODATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_asa_upd.upd
      (p_effective_date                => p_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_assignment_acco_id            => p_assignment_acco_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_accommodation_given           => p_accommodation_given
      ,p_temporary_assignment          => p_temporary_assignment
      ,p_accommodation_id              => p_accommodation_id
      ,p_acceptance_date               => p_acceptance_date
      ,p_moving_date                   => p_moving_date
      ,p_refusal_date                  => p_refusal_date
      ,p_comments                      => p_comments
      ,p_indemnity_entitlement         => p_indemnity_entitlement
      ,p_indemnity_amount              => p_indemnity_amount
      ,p_type_of_payment               => p_type_of_payment
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_reason_for_no_acco            => p_reason_for_no_acco
      ,p_indemnity_currency            => p_indemnity_currency
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_ASSIGN_ACCOMMODATIONS_BK2.update_assign_accommodation_a
      (p_effective_date                => p_effective_date
      ,p_datetrack_mode                => p_datetrack_mode
      ,p_assignment_acco_id            => p_assignment_acco_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_assignment_id                 => p_assignment_id
      ,p_accommodation_given           => p_accommodation_given
      ,p_temporary_assignment          => p_temporary_assignment
      ,p_accommodation_id              => p_accommodation_id
      ,p_acceptance_date               => p_acceptance_date
      ,p_moving_date                   => p_moving_date
      ,p_refusal_date                  => p_refusal_date
      ,p_comments                      => p_comments
      ,p_indemnity_entitlement         => p_indemnity_entitlement
      ,p_indemnity_amount              => p_indemnity_amount
      ,p_type_of_payment               => p_type_of_payment
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
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
      ,p_reason_for_no_acco            => p_reason_for_no_acco
      ,p_indemnity_currency            => p_indemnity_currency
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ASSIGN_ACCOMMODATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := p_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_ASSIGN_ACCOMMODATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_ASSIGN_ACCOMMODATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_assign_accommodation;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------<delete_assign_accommodation>----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_assign_accommodation
  (p_validate                         in     boolean  default false
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_assignment_acco_id               in     number
  ,p_object_version_number            in out nocopy number
  ,p_effective_start_date                out nocopy date
  ,p_effective_end_date                  out nocopy date
   ) is
  --
  -- Declare cursors and local variables
  --

  l_proc      varchar2(72) := g_package||'DELETE_SITUATION';
  l_effective_start_date   pqh_assign_accommodations_f.effective_start_date%TYPE;
  l_effective_end_date     pqh_assign_accommodations_f.effective_end_date%TYPE;
  l_object_version_number number := p_object_version_number;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_ASSIGN_ACCOMMODATION;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_ASSIGN_ACCOMMODATIONS_BK3.delete_assign_accommodation_b
      (p_effective_date                   => p_effective_date
      ,p_datetrack_mode                   => p_datetrack_mode
      ,p_assignment_acco_id               => p_assignment_acco_id
      ,p_object_version_number            => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ASSIGN_ACCOMMODATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqh_asa_del.del
      (p_effective_date                   => p_effective_date
      ,p_datetrack_mode                   => p_datetrack_mode
      ,p_assignment_acco_id               => p_assignment_acco_id
      ,p_object_version_number            => p_object_version_number
      ,p_effective_start_date             => l_effective_start_date
      ,p_effective_end_date               => l_effective_end_date
      );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_ASSIGN_ACCOMMODATIONS_BK3.delete_assign_accommodation_a
      (p_effective_date                   => p_effective_date
      ,p_datetrack_mode                   => p_datetrack_mode
      ,p_assignment_acco_id               => p_assignment_acco_id
      ,p_object_version_number            => p_object_version_number
      ,p_effective_start_date             => l_effective_start_date
      ,p_effective_end_date               => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ASSIGN_ACCOMMODATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number  := p_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_ASSIGN_ACCOMMODATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_ASSIGN_ACCOMMODATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_assign_accommodation;
--
end pqh_assign_accommodations_api;

/
